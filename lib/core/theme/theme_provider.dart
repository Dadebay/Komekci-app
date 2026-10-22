import 'package:flutter/material.dart';

/// API theme codes. Legacy codes stay valid for existing accounts and servers.
enum KomekciTheme { ivory, onyx, champagne, rose, blue, gold, red }

enum KomekciThemeStyle { gold, blue, red }

KomekciThemeStyle themeStyleFor(KomekciTheme theme) => switch (theme) {
  KomekciTheme.champagne || KomekciTheme.gold => KomekciThemeStyle.gold,
  KomekciTheme.ivory || KomekciTheme.blue => KomekciThemeStyle.blue,
  KomekciTheme.onyx || KomekciTheme.rose || KomekciTheme.red =>
    KomekciThemeStyle.red,
};

/// Use a new API code when enabled; otherwise save an enabled legacy code.
KomekciTheme? enabledThemeForStyle(
  Iterable<KomekciTheme> enabled,
  KomekciThemeStyle style,
) {
  for (final theme in enabled) {
    if (theme.name == style.name) return theme;
  }
  for (final theme in enabled) {
    if (themeStyleFor(theme) == style) return theme;
  }
  return null;
}

class ThemeProvider extends ChangeNotifier {
  KomekciTheme _selected = KomekciTheme.ivory;
  KomekciTheme get selected => _selected;
  void select(KomekciTheme value) {
    _selected = value;
    notifyListeners();
  }
}
