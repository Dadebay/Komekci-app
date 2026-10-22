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
    required this.primary,
    required this.accent,
    required this.accentOn,
    required this.button,
    required this.buttonText,
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

  /// The backend's primary brand colour, used by Material controls.
  final Color primary;

  /// Brand accent — CTAs, selection, links.
  final Color accent;

  /// Colour to use for content painted on top of [accent].
  final Color accentOn;
  final Color button;
  final Color buttonText;
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
    Color? primary,
    Color? accent,
    Color? accentOn,
    Color? button,
    Color? buttonText,
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
    primary: primary ?? this.primary,
    accent: accent ?? this.accent,
    accentOn: accentOn ?? this.accentOn,
    button: button ?? this.button,
    buttonText: buttonText ?? this.buttonText,
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
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentOn: Color.lerp(accentOn, other.accentOn, t)!,
      button: Color.lerp(button, other.button, t)!,
      buttonText: Color.lerp(buttonText, other.buttonText, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

const goldTokens = AppThemeTokens(
  brightness: Brightness.light,
  surface: Colors.white,
  surfaceElevated: cream,
  textPrimary: ink,
  textSecondary: Colors.black54,
  border: line,
  primary: ink,
  accent: gold,
  accentOn: Colors.white,
  button: ink,
  buttonText: Colors.white,
  success: Color(0xff2F7D4F),
  warning: Color(0xff9C6B14),
  danger: Color(0xffC0392B),
  disabled: Colors.black26,
  scrim: Colors.black45,
);

const blueTokens = AppThemeTokens(
  brightness: Brightness.light,
  surface: Colors.white,
  surfaceElevated: Color(0xffF2F7FF),
  textPrimary: Color(0xff172334),
  textSecondary: Color(0xff5B6B7D),
  border: Color(0xffD9E5F5),
  primary: Color(0xff172334),
  accent: Color(0xff0867D8),
  accentOn: Colors.white,
  button: Color(0xff0867D8),
  buttonText: Colors.white,
  success: Color(0xff2F7D4F),
  warning: Color(0xff9C6B14),
  danger: Color(0xffC93438),
  disabled: Color(0xffAAB7C7),
  scrim: Colors.black45,
);

const redTokens = AppThemeTokens(
  brightness: Brightness.light,
  surface: Colors.white,
  surfaceElevated: Colors.white,
  textPrimary: Color(0xff251B1C),
  textSecondary: Color(0xff705D60),
  border: Color(0xffF0D8DA),
  primary: Color(0xff251B1C),
  accent: Color(0xffE32027),
  accentOn: Colors.white,
  button: Color(0xffE32027),
  buttonText: Colors.white,
  success: Color(0xff2F7D4F),
  warning: Color(0xff9C6B14),
  danger: Color(0xffB91D24),
  disabled: Color(0xffD6B9BC),
  scrim: Colors.black45,
);

AppThemeTokens tokensFor(KomekciTheme theme) => switch (themeStyleFor(theme)) {
  KomekciThemeStyle.gold => goldTokens,
  KomekciThemeStyle.blue => blueTokens,
  KomekciThemeStyle.red => redTokens,
};

/// The app's font (declared in `pubspec.yaml`). Widgets that set their own
/// [DefaultTextStyle] — snack bars, for one — do not inherit it from the
/// theme and need it named.
const appFontFamily = 'Gilroy';

ThemeData buildThemeData(AppThemeTokens t) {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    brightness: t.brightness,
    scaffoldBackgroundColor: t.surface,
    colorScheme: ColorScheme(
      brightness: t.brightness,
      primary: t.primary,
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
        backgroundColor: t.button,
        foregroundColor: t.buttonText,
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
    // Plain `SnackBar(content: Text(...))` calls across the app pick this up;
    // `AppToast` adds an icon on top of the same look.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.textPrimary,
      contentTextStyle: TextStyle(
        fontFamily: appFontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: t.surface,
      ),
      actionTextColor: t.accent,
      elevation: 6,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: t.surface),
    dialogTheme: DialogThemeData(backgroundColor: t.surface),
    cardColor: t.surfaceElevated,
  );
  return base.copyWith(extensions: [t]);
}

extension AppThemeContext on BuildContext {
  AppThemeTokens get appTokens =>
      Theme.of(this).extension<AppThemeTokens>() ?? goldTokens;
}
