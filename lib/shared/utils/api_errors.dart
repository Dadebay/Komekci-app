import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/language_provider.dart';
import '../../core/network/api_exception.dart';

/// Text to show for a failed call: the server's own message in the user's
/// language, or a friendly line when the request never got through.
String apiErrorMessage(Object error, AppLanguage language) {
  if (error is ApiException) {
    if (error.isNetwork) {
      return pickTr(
        language,
        tk: 'Internet baglanyşygy ýok. Täzeden synanyşyň.',
        ru: 'Нет соединения с интернетом. Попробуйте снова.',
        en: 'No internet connection. Please try again.',
      );
    }
    if (error.code == ApiErrors.rateLimited && error.retryAfterSeconds != null) {
      final s = error.retryAfterSeconds!;
      return pickTr(
        language,
        tk: 'Gaty köp synanyşyk. $s sekuntdan soň täzeden synanyşyň.',
        ru: 'Слишком часто. Повторите через $s сек.',
        en: 'Too many attempts. Try again in $s s.',
      );
    }
    return error.localized(language);
  }
  return pickTr(
    language,
    tk: 'Näbelli ýalňyşlyk. Täzeden synanyşyň.',
    ru: 'Неизвестная ошибка. Попробуйте снова.',
    en: 'Something went wrong. Please try again.',
  );
}

/// `+993` + the eight digits found in [input] (any spacing/prefix).
String toApiPhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('993') && digits.length > 8) digits = digits.substring(3);
  return '+993$digits';
}

/// `+993 65 123456` for display.
String displayPhone(String apiPhone) {
  final d = apiPhone.replaceAll(RegExp(r'\D'), '');
  final local = d.startsWith('993') ? d.substring(3) : d;
  if (local.length != 8) return apiPhone;
  return '+993 ${local.substring(0, 2)} ${local.substring(2)}';
}

/// Backend nickname rule (`^[a-z_][a-z0-9_]{2,19}$`).
final nicknamePattern = RegExp(r'^[a-z_][a-z0-9_]{2,19}$');

/// Turns "@ayna" / "ayna" / a full link into a URL for `instagram_url` /
/// `tiktok_url`; null for blank input.
String? socialUrl(String input, {required String host, bool atPrefix = false}) {
  final value = input.trim();
  if (value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  final handle = value.replaceFirst('@', '');
  return 'https://$host/${atPrefix ? '@' : ''}$handle';
}

/// Runs [action]; an `ApiException` (or any failure) is shown as a snackbar
/// in the user's language. Resolves true when the action succeeded.
Future<bool> runApi(BuildContext context, Future<void> Function() action) async {
  final language = context.read<LanguageProvider>().language;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(error, language))));
    return false;
  }
}
