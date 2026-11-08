import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:smart_auth/smart_auth.dart';

/// Reads the verification code out of the incoming SMS so the user does not
/// have to type it.
///
/// Android: Google's SMS User Consent API. It needs no SMS permission and no
/// special text in the message; when a message with a 4–10 character code
/// arrives from a number that is not in the contacts, Android asks the user
/// once "Allow Kömekçi to read this message?" and hands the text over. It
/// listens for up to 5 minutes.
///
/// iOS has no such API — there the keyboard suggests the code above the
/// keys (the code field is marked `AutofillHints.oneTimeCode`) and tapping
/// it fills the field.
///
/// Nothing here throws; anything unexpected simply means "no code".
class SmsCodeListener {
  const SmsCodeListener();

  /// A six digit run that is not part of a longer number.
  static final _sixDigits = r'(?<!\d)\d{6}(?!\d)';

  /// Resolves with the six-digit code from the next matching SMS, or null
  /// when the user declined, the wait timed out, or the platform has no
  /// support.
  Future<String?> listen() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final result = await SmartAuth.instance.getSmsWithUserConsentApi(matcher: _sixDigits);
      final code = result.data?.code;
      return code != null && code.length == 6 ? code : null;
    } catch (error) {
      debugPrint('SMS code listener failed: $error');
      return null;
    }
  }

  /// Stops waiting (screen left, or about to listen again after a resend).
  Future<void> cancel() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await SmartAuth.instance.removeUserConsentApiListener();
    } catch (_) {}
  }
}
