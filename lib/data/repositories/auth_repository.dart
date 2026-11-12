import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_store.dart';
import '../models/api/json_helpers.dart';

class NicknameCheck {
  const NicknameCheck({required this.available, this.suggestions = const []});
  final bool available;
  final List<String> suggestions;
}

/// Fields of `POST /auth/register`. Masters additionally need [address],
/// [description] and [bannerPath].
class RegistrationData {
  const RegistrationData({
    required this.role,
    required this.name,
    required this.nickname,
    required this.phone,
    this.locale,
    this.photoPath,
    this.address,
    this.description,
    this.bannerPath,
    this.instagramUrl,
    this.tiktokUrl,
    this.otherLinks = const [],
  });

  /// `client` or `master`.
  final String role;
  final String name;
  final String nickname;

  /// `+993XXXXXXXX`.
  final String phone;
  final String? locale;
  final String? photoPath;
  final String? address;
  final String? description;
  final String? bannerPath;
  final String? instagramUrl;
  final String? tiktokUrl;
  final List<String> otherLinks;
}

/// What `POST /v1/auth/otp/request` returns: the code the user must SMS to
/// [smsDestination], and the secret needed to poll for the result.
class SmsOtpChallenge {
  const SmsOtpChallenge({
    required this.verificationId,
    required this.pollSecret,
    required this.otp,
    required this.smsDestination,
    required this.expiresIn,
  });
  final String verificationId;
  final String pollSecret;
  final String otp;
  final String smsDestination;

  /// Seconds the code stays valid (180).
  final int expiresIn;

  factory SmsOtpChallenge.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing SMS verification field: $key');
      }
      return value;
    }

    final expiresIn = parseIntOrNull(json['expires_in']) ?? 180;
    if (expiresIn <= 0) {
      throw const FormatException('Invalid SMS verification expiry');
    }
    return SmsOtpChallenge(
      verificationId: requiredString('verification_id'),
      pollSecret: requiredString('poll_secret'),
      otp: requiredString('otp'),
      smsDestination: requiredString('sms_destination'),
      expiresIn: expiresIn,
    );
  }
}

enum SmsOtpState { pending, verified, failed, expired }

/// `/auth/*` — sign-up, SMS code sign-in and token handling.
class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<NicknameCheck> nicknameAvailable(String nickname) async {
    final body = asMap(
      await _api.get(
        '/auth/nickname/available',
        query: {'nickname': nickname},
        auth: false,
      ),
    );
    return NicknameCheck(
      available: body['available'] as bool? ?? false,
      suggestions: [
        for (final s in (body['suggestions'] as List? ?? const [])) '$s',
      ],
    );
  }

  /// Creates the account and sends the SMS code. No tokens yet — finish with
  /// [verifyOtp].
  Future<int> register(RegistrationData data) async {
    String? clean(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final locale = clean(data.locale);
    final address = clean(data.address);
    final description = clean(data.description);
    final instagram = clean(data.instagramUrl);
    final tiktok = clean(data.tiktokUrl);
    final response = await _api.request(
      'POST',
      '/auth/register',
      auth: false,
      multipart: MultipartBody(
        fields: [
          MapEntry('role', data.role),
          MapEntry('name', data.name.trim()),
          MapEntry('nickname', data.nickname),
          MapEntry('phone', data.phone),
          if (locale != null) MapEntry('locale', locale),
          if (address != null) MapEntry('address', address),
          if (description != null) MapEntry('description', description),
          if (instagram != null) MapEntry('instagram_url', instagram),
          if (tiktok != null) MapEntry('tiktok_url', tiktok),
          for (final link in data.otherLinks)
            if (link.trim().isNotEmpty) MapEntry('other_links[]', link.trim()),
        ],
        files: [
          if (data.photoPath != null) UploadFile('photo', data.photoPath!),
          if (data.bannerPath != null) UploadFile('banner', data.bannerPath!),
        ],
      ),
    );
    return parseIntOrNull(asMap(response)['retry_after']) ?? 60;
  }

  /// SMS code for an existing, active account. The server's test number
  /// answers with tokens instead of sending an SMS: they are stored here and
  /// `signedIn` is true, so no code screen is needed.
  Future<({int retryAfter, bool signedIn})> requestOtp(String phone) async {
    final body = asMap(
      await _api.post('/auth/otp/request', json: {'phone': phone}, auth: false),
    );
    if (await _storeTokensIfPresent(body)) {
      return (retryAfter: 60, signedIn: true);
    }
    return (
      retryAfter: parseIntOrNull(body['retry_after']) ?? 60,
      signedIn: false,
    );
  }

  Future<bool> _storeTokensIfPresent(Map<String, dynamic> body) async {
    if (body['access_token'] is! String || body['refresh_token'] is! String) {
      return false;
    }
    await _api.saveSession(AuthTokens.fromJson(body), newAccount: true);
    return true;
  }

  /// Confirms the code (sign-up and sign-in alike) and stores the tokens.
  Future<void> verifyOtp(String phone, String code) async {
    final body = await _api.post(
      '/auth/otp/verify',
      json: {'phone': phone, 'code': code},
      auth: false,
    );
    await _api.saveSession(AuthTokens.fromJson(asMap(body)), newAccount: true);
  }

  /// Client SMS sign-in, step 1: the user texts the returned code to
  /// `smsDestination`. [purpose] is `login` or `register`.
  ///
  /// Returns null when the server signed the user in straight away (its test
  /// number answers `authenticated: true` with tokens): they are stored and
  /// there is nothing to send or poll.
  Future<SmsOtpChallenge?> requestSmsOtp(
    String phone, {
    String purpose = 'login',
  }) async {
    final body = asMap(
      await _api.post(
        '/v1/auth/otp/request',
        json: {'phone': phone, 'purpose': purpose},
        auth: false,
      ),
    );
    if (await _storeTokensIfPresent(body)) return null;
    return SmsOtpChallenge.fromJson(body);
  }

  /// Step 2, every 2 s: asks whether the SMS arrived. On `verified` the
  /// tokens are stored. A 404 (wrong secret) is raised as an [ApiException].
  Future<SmsOtpState> pollSmsOtp(SmsOtpChallenge challenge) async {
    final dynamic body;
    try {
      body = await _api.post(
        '/v1/auth/otp/status',
        json: {
          'verification_id': challenge.verificationId,
          'poll_secret': challenge.pollSecret,
        },
        auth: false,
      );
    } on ApiException catch (e) {
      switch (e.details['status']) {
        case 'expired':
          return SmsOtpState.expired;
        case 'failed':
          return SmsOtpState.failed;
      }
      rethrow;
    }
    final map = asMap(body);
    switch (map['status']) {
      case 'verified':
        if (map['access_token'] is! String || map['refresh_token'] is! String) {
          return SmsOtpState.failed;
        }
        await _api.saveSession(AuthTokens.fromJson(map), newAccount: true);
        return SmsOtpState.verified;
      case 'expired':
        return SmsOtpState.expired;
      case 'failed':
        return SmsOtpState.failed;
      default:
        return SmsOtpState.pending;
    }
  }

  /// Revokes the refresh token and forgets the session locally, even if the
  /// server can't be reached.
  Future<void> logout() async {
    final refresh = _api.refreshToken;
    try {
      await _api.post(
        '/auth/logout',
        json: refresh == null ? null : {'refresh_token': refresh},
      );
    } finally {
      await _api.clearSession();
    }
  }
}
