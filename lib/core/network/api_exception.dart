import '../localization/language_provider.dart';

/// Error codes from the backend's `{ "error": "...", ... }` body, plus the
/// two the client raises itself.
abstract final class ApiErrors {
  static const network = 'NETWORK';
  static const unknown = 'ERROR';
  static const unauthenticated = 'UNAUTHENTICATED';
  static const forbidden = 'FORBIDDEN';
  static const notConnected = 'NOT_CONNECTED';
  static const subscriptionSuspended = 'SUBSCRIPTION_SUSPENDED';
  static const notFound = 'NOT_FOUND';
  static const masterNotFound = 'MASTER_NOT_FOUND';
  static const phoneNotFound = 'PHONE_NOT_FOUND';
  static const paymentUnavailable = 'PAYMENT_UNAVAILABLE';
  static const slotTaken = 'SLOT_TAKEN';
  static const validation = 'VALIDATION';
  static const nicknameTaken = 'NICKNAME_TAKEN';
  static const phoneTaken = 'PHONE_TAKEN';
  static const otpInvalid = 'OTP_INVALID';
  static const otpExpired = 'OTP_EXPIRED';
  static const pastTime = 'PAST_TIME';
  static const outsideWorkingHours = 'OUTSIDE_WORKING_HOURS';
  static const appointmentLocked = 'APPOINTMENT_LOCKED';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const offerExpired = 'OFFER_EXPIRED';
  static const alreadyConnected = 'ALREADY_CONNECTED';
  static const requestPending = 'REQUEST_PENDING';
  static const rateLimited = 'RATE_LIMITED';
  static const smsUnavailable = 'SMS_UNAVAILABLE';
}

/// A failed API call. [message] is already in the user's language as chosen
/// by the server; [localized] picks one of the three translations it sends.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.messages = const {},
    this.details = const {},
  });

  /// 0 when the request never got an HTTP response (offline, timeout, TLS).
  final int statusCode;
  final String code;
  final String message;

  /// `tk` / `ru` / `en` → text, when the server sent them.
  final Map<String, String> messages;
  final Map<String, dynamic> details;

  factory ApiException.network([Object? cause]) => ApiException(
    statusCode: 0,
    code: ApiErrors.network,
    message: cause == null ? 'Network error' : 'Network error: $cause',
  );

  factory ApiException.fromBody(int statusCode, Object? body) {
    if (body is Map<String, dynamic>) {
      final details = body['details'];
      return ApiException(
        statusCode: statusCode,
        code: body['error'] as String? ?? ApiErrors.unknown,
        message: body['message'] as String? ?? 'Request failed ($statusCode)',
        messages: {
          for (final lang in AppLanguage.values)
            if (body['message_${lang.name}'] is String)
              lang.name: body['message_${lang.name}'] as String,
        },
        details: details is Map<String, dynamic> ? details : const {},
      );
    }
    return ApiException(
      statusCode: statusCode,
      code: ApiErrors.unknown,
      message: 'Request failed ($statusCode)',
    );
  }

  bool get isNetwork => code == ApiErrors.network;
  bool get isUnauthenticated => statusCode == 401;
  bool is_(String errorCode) => code == errorCode;

  /// The server's message in [language], falling back to [message].
  String localized(AppLanguage language) => messages[language.name] ?? message;

  /// `details` of a `VALIDATION` error: field → first message.
  Map<String, String> get fieldErrors => {
    for (final entry in details.entries)
      if (entry.value is List && (entry.value as List).isNotEmpty)
        entry.key: '${(entry.value as List).first}',
  };

  /// `details.suggestions` of `NICKNAME_TAKEN`.
  List<String> get nicknameSuggestions => [
    for (final s in (details['suggestions'] as List? ?? const [])) '$s',
  ];

  /// `details.suggested_slots` of `SLOT_TAKEN` / rebook conflicts.
  List<String> get suggestedSlots => [
    for (final s in (details['suggested_slots'] as List? ?? const [])) '$s',
  ];

  /// Seconds to wait before another OTP, from `RATE_LIMITED`.
  int? get retryAfterSeconds => switch (details['retry_after']) {
    final num n => n.toInt(),
    final String s => int.tryParse(s),
    _ => null,
  };

  @override
  String toString() => 'ApiException($statusCode $code: $message)';
}
