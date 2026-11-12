import 'package:material_ui/material_ui.dart';

/// API theme codes. Legacy codes stay valid for existing accounts and servers.
enum KomekciTheme { ivory, onyx, champagne, rose, blue, gold, red }

enum KomekciThemeStyle { gold, blue, red, dark }

KomekciThemeStyle themeStyleFor(KomekciTheme theme) => switch (theme) {
  KomekciTheme.ivory || KomekciTheme.gold => KomekciThemeStyle.gold,
  KomekciTheme.onyx || KomekciTheme.blue => KomekciThemeStyle.blue,
  KomekciTheme.champagne || KomekciTheme.red => KomekciThemeStyle.red,
  KomekciTheme.rose => KomekciThemeStyle.dark,
};

/// Use a new API code when enabled; otherwise save an enabled legacy code.
KomekciTheme? enabledThemeForStyle(
  Iterable<KomekciTheme> enabled,
  KomekciThemeStyle style,
) {
  final canonical = switch (style) {
    KomekciThemeStyle.gold => KomekciTheme.ivory,
    KomekciThemeStyle.blue => KomekciTheme.onyx,
    KomekciThemeStyle.red => KomekciTheme.champagne,
    KomekciThemeStyle.dark => KomekciTheme.rose,
  };
  for (final theme in enabled) {
    if (theme == canonical) return theme;
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
