import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

enum ToastKind { success, error, info }

/// Floating confirmation/error message with an icon, in the current theme's
/// colours.
///
/// Created from a [BuildContext] *before* any `await`, so it can be used
/// afterwards without touching a context that may be gone:
///
/// ```dart
/// final toast = AppToast.of(context);
/// await save();
/// toast.success('Saved.');
/// ```
class AppToast {
  AppToast._(this._messenger, this._tokens);

  factory AppToast.of(BuildContext context) =>
      AppToast._(ScaffoldMessenger.of(context), context.appTokens);

  final ScaffoldMessengerState _messenger;
  final AppThemeTokens _tokens;

  void success(String message) => _show(message, ToastKind.success);
  void error(String message) => _show(message, ToastKind.error);
  void info(String message) => _show(message, ToastKind.info);

  void _show(String message, ToastKind kind) {
    final tokens = _tokens;
    // Same inverted surface as the filled buttons: dark on light themes and
    // light on Onyx, so a toast stands out from whatever sits behind it.
    final background = tokens.textPrimary;
    final onBackground = tokens.surface;
    final tone = switch (kind) {
      ToastKind.success => tokens.success,
      ToastKind.error => tokens.danger,
      ToastKind.info => tokens.accent,
    };
    final icon = switch (kind) {
      ToastKind.success => Icons.check_circle,
      ToastKind.error => Icons.warning_amber_rounded,
      ToastKind.info => Icons.info_outline,
    };
    // The tone colours are tuned for the page background; on the inverted
    // toast they are pushed toward the text colour so they stay readable.
    final iconColor = Color.lerp(tone, onBackground, .25)!;

    _messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          duration: const Duration(milliseconds: 3200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: AppIcon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: appFontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: onBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
