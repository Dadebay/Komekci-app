import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'theme_provider.dart';

/// Semantic colour set for one [KomekciTheme]. Every screen should eventually
/// read colours through these tokens (via [AppThemeContext.appTokens])
/// instead of the fixed [ink]/[gold]/[cream]/[line] constants, so switching
/// themes actually changes what's on screen.
///
/// Scope note: this token system and [buildThemeData] are wired into the
/// shared chrome — [KomekciApp]'s [ThemeData], the bottom nav bar,
/// `AppScaffold`, `CabinetAppBar`, `PrimaryButton` and `Field` — which covers
/// most screens indirectly. Individual screens that hardcode
/// `Scaffold(backgroundColor: Colors.white)` or `color: ink` directly were
/// not migrated one by one; that's a larger follow-up pass.
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.brightness,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.accent,
    required this.accentOn,
    required this.success,
    required this.warning,
    required this.danger,
    required this.disabled,
    required this.scrim,
  });

  final Brightness brightness;

  /// Base screen background.
  final Color surface;

  /// Cards, inputs, chips — one step "up" from [surface].
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  /// Brand accent (gold in Ivory) — CTAs, selection, links.
  final Color accent;

  /// Colour to use for content painted on top of [accent].
  final Color accentOn;
  final Color success;
  final Color warning;
  final Color danger;
  final Color disabled;

  /// Modal/dialog backdrop.
  final Color scrim;

  @override
  AppThemeTokens copyWith({
    Brightness? brightness,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? accent,
    Color? accentOn,
    Color? success,
    Color? warning,
    Color? danger,
    Color? disabled,
    Color? scrim,
  }) => AppThemeTokens(
    brightness: brightness ?? this.brightness,
    surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    border: border ?? this.border,
    accent: accent ?? this.accent,
    accentOn: accentOn ?? this.accentOn,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    disabled: disabled ?? this.disabled,
    scrim: scrim ?? this.scrim,
  );

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      brightness: t < .5 ? brightness : other.brightness,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentOn: Color.lerp(accentOn, other.accentOn, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

const ivoryTokens = AppThemeTokens(
  brightness: Brightness.light,
  surface: Colors.white,
  surfaceElevated: cream,
  textPrimary: ink,
  textSecondary: Colors.black54,
  border: line,
  accent: gold,
  accentOn: Colors.white,
  success: Color(0xff2F7D4F),
  warning: Color(0xff9C6B14),
  danger: Color(0xffC0392B),
  disabled: Colors.black26,
  scrim: Colors.black45,
);

const onyxTokens = AppThemeTokens(
  brightness: Brightness.dark,
  surface: Color(0xff1A1A1C),
  surfaceElevated: Color(0xff242426),
  textPrimary: Colors.white,
  textSecondary: Colors.white70,
  border: Color(0xff3A3A3D),
  accent: Color(0xffD8B26A),
  accentOn: Color(0xff1A1A1C),
  success: Color(0xff5FBE85),
  warning: Color(0xffE0B75B),
  danger: Color(0xffE5766B),
  disabled: Colors.white24,
  scrim: Colors.black87,
);

const champagneTokens = AppThemeTokens(
  brightness: Brightness.light,
  surface: Color(0xffFAF6EE),
  surfaceElevated: Colors.white,
  textPrimary: Color(0xff5C4A22),
  textSecondary: Color(0xff8A7350),
  border: Color(0xffE9DCC0),
  accent: Color(0xffB9963F),
  accentOn: Colors.white,
  success: Color(0xff2F7D4F),
  warning: Color(0xff9C6B14),
  danger: Color(0xffC0392B),
  disabled: Color(0xffD8CBAA),
  scrim: Colors.black45,
);

const roseTokens = AppThemeTokens(
  brightness: Brightness.light,
  surface: Color(0xffFCF7F6),
  surfaceElevated: Colors.white,
  textPrimary: Color(0xff5C3A3D),
  textSecondary: Color(0xff9C7679),
  border: Color(0xffEBD7D8),
  accent: Color(0xffB0757C),
  accentOn: Colors.white,
  success: Color(0xff2F7D4F),
  warning: Color(0xff9C6B14),
  danger: Color(0xffC0392B),
  disabled: Color(0xffE3C9CB),
  scrim: Colors.black45,
);

AppThemeTokens tokensFor(KomekciTheme theme) => switch (theme) {
  KomekciTheme.ivory => ivoryTokens,
  KomekciTheme.onyx => onyxTokens,
  KomekciTheme.champagne => champagneTokens,
  KomekciTheme.rose => roseTokens,
};

ThemeData buildThemeData(AppThemeTokens t) {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Gilroy',
    brightness: t.brightness,
    scaffoldBackgroundColor: t.surface,
    colorScheme: ColorScheme(
      brightness: t.brightness,
      primary: t.textPrimary,
      onPrimary: t.surface,
      secondary: t.accent,
      onSecondary: t.accentOn,
      error: t.danger,
      onError: Colors.white,
      surface: t.surface,
      onSurface: t.textPrimary,
    ),
    dividerColor: t.border,
    iconTheme: IconThemeData(color: t.textPrimary),
    textTheme: TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w700,
        color: t.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w700,
        color: t.textPrimary,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: t.textPrimary),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: t.textPrimary),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, color: t.textPrimary),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: t.textPrimary),
      // bodyMedium is what most unstyled Text() widgets inherit as their
      // default — it must stay textPrimary (not textSecondary), or ordinary
      // titles/labels across the app render faded for no reason.
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: t.textPrimary),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, color: t.textPrimary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: t.surface,
      surfaceTintColor: t.surface,
      foregroundColor: t.textPrimary,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.textPrimary,
        foregroundColor: t.surface,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: t.accent),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.textPrimary,
        side: BorderSide(color: t.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: t.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: t.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: t.accent),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: t.surface),
    dialogTheme: DialogThemeData(backgroundColor: t.surface),
    cardColor: t.surfaceElevated,
  );
  return base.copyWith(extensions: [t]);
}

extension AppThemeContext on BuildContext {
  AppThemeTokens get appTokens =>
      Theme.of(this).extension<AppThemeTokens>() ?? ivoryTokens;
}
