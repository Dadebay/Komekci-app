import '../../core/network/api_client.dart';
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
  Future<void> register(RegistrationData data) async {
    String? clean(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final locale = clean(data.locale);
    final address = clean(data.address);
    final description = clean(data.description);
    final instagram = clean(data.instagramUrl);
    final tiktok = clean(data.tiktokUrl);
    await _api.request(
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
  }

  /// SMS code for an existing, active account.
  Future<void> requestOtp(String phone) async {
    await _api.post('/auth/otp/request', json: {'phone': phone}, auth: false);
  }

  /// Confirms the code (sign-up and sign-in alike) and stores the tokens.
  Future<void> verifyOtp(String phone, String code) async {
    final body = await _api.post(
      '/auth/otp/verify',
      json: {'phone': phone, 'code': code},
      auth: false,
    );
    await _api.saveSession(AuthTokens.fromJson(asMap(body)));
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
