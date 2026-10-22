import 'package:flutter/material.dart';

import 'app_theme_tokens.dart';

/// The seven colour fields returned by `GET /settings/public` for one theme.
/// Invalid or missing fields fall back to the app's bundled palette.
class BackendThemeColors {
  const BackendThemeColors({
    this.primary,
    this.secondary,
    this.background,
    this.text,
    this.button,
    this.buttonText,
    this.accent,
  });

  final Color? primary;
  final Color? secondary;
  final Color? background;
  final Color? text;
  final Color? button;
  final Color? buttonText;
  final Color? accent;

  static final _hexColor = RegExp(r'^#[0-9a-fA-F]{6}$');

  static Color? _parseColor(Object? value) {
    if (value is! String) return null;
    final hex = value.trim();
    if (!_hexColor.hasMatch(hex)) return null;
    return Color(0xff000000 | int.parse(hex.substring(1), radix: 16));
  }

  factory BackendThemeColors.fromJson(Map json) => BackendThemeColors(
    primary: _parseColor(json['primary']),
    secondary: _parseColor(json['secondary']),
    background: _parseColor(json['background']),
    text: _parseColor(json['text']),
    button: _parseColor(json['button']),
    buttonText: _parseColor(json['button_text']),
    accent: _parseColor(json['accent']),
  );

  AppThemeTokens applyTo(AppThemeTokens fallback) {
    final surface = background ?? fallback.surface;
    final elevated = secondary ?? fallback.surfaceElevated;
    final foreground = text ?? fallback.textPrimary;
    final highlight = accent ?? fallback.accent;
    final buttonColor = button ?? fallback.button;
    final isDark = surface.computeLuminance() < .5;
    Color contrastingText(Color color) =>
        color.computeLuminance() > .45 ? Colors.black : Colors.white;

    return fallback.copyWith(
      brightness: background == null
          ? fallback.brightness
          : isDark
          ? Brightness.dark
          : Brightness.light,
      surface: surface,
      surfaceElevated: elevated,
      primary: primary,
      textPrimary: foreground,
      textSecondary: text == null && background == null
          ? fallback.textSecondary
          : Color.lerp(foreground, surface, .4),
      border: secondary == null && accent == null
          ? fallback.border
          : Color.alphaBlend(highlight.withValues(alpha: .16), elevated),
      accent: highlight,
      accentOn: accent == null ? fallback.accentOn : contrastingText(highlight),
      button: buttonColor,
      buttonText:
          buttonText ??
          (button == null ? fallback.buttonText : contrastingText(buttonColor)),
      success: isDark ? const Color(0xff5FBE85) : fallback.success,
      warning: isDark ? const Color(0xffE0B75B) : fallback.warning,
      danger: isDark ? const Color(0xffE5766B) : fallback.danger,
      disabled: text == null && background == null
          ? fallback.disabled
          : Color.lerp(foreground, surface, .6),
      scrim: isDark ? Colors.black87 : fallback.scrim,
    );
  }
}
