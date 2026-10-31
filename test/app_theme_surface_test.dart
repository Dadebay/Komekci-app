import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/core/theme/app_theme_tokens.dart';
import 'package:komekci/core/theme/theme_provider.dart';
import 'package:komekci/data/models/app_settings.dart';
import 'package:komekci/data/repositories/settings_repository.dart';
import 'package:komekci/features/app/application/app_settings_provider.dart';

class _SettingsRepository extends SettingsRepository {
  @override
  Future<AppSettings> fetchPublic({String locale = 'tk'}) async =>
      AppSettings.fromJson({
        'themes': [
          {
            'code': 'ivory',
            'enabled': true,
            'colors': {
              'background': '#F7F3EE',
              'secondary': '#C4B7A6',
              'accent': '#8C7355',
            },
          },
          {
            'code': 'onyx',
            'enabled': true,
            'colors': {'background': '#121212', 'accent': '#D4D4D4'},
          },
          {
            'code': 'champagne',
            'enabled': true,
            'colors': {'background': '#F8F1E7', 'secondary': '#C6A57B'},
          },
          {
            'code': 'rose',
            'enabled': true,
            'colors': {'background': '#FDF6F7', 'accent': '#A14B5D'},
          },
        ],
      });
}

void main() {
  test(
    'ivory keeps white surfaces when public settings use dark beige',
    () async {
      final settings = AppSettingsProvider(repository: _SettingsRepository());
      await settings.load();

      final ivory = settings.themeTokensFor(KomekciTheme.ivory);
      expect(ivory.surface, Colors.white);
      expect(ivory.surfaceElevated, Colors.white);
      expect(ivory.border, goldTokens.border);
      expect(ivory.accent, const Color(0xff8C7355));

      expect(
        settings.themeTokensFor(KomekciTheme.onyx).accent,
        blueTokens.accent,
      );
      expect(
        settings.themeTokensFor(KomekciTheme.champagne).accent,
        redTokens.accent,
      );
      final rose = settings.themeTokensFor(KomekciTheme.rose);
      expect(rose.surface, darkTokens.surface);
      expect(rose.brightness, Brightness.dark);
    },
  );

  test('Ivory is the gold default and all four names have distinct styles', () {
    expect(ThemeProvider().selected, KomekciTheme.ivory);
    expect(tokensFor(KomekciTheme.ivory), goldTokens);
    expect(tokensFor(KomekciTheme.onyx), blueTokens);
    expect(tokensFor(KomekciTheme.champagne), redTokens);
    expect(tokensFor(KomekciTheme.rose), darkTokens);
    expect(
      enabledThemeForStyle(AppSettings.fallback.themes, KomekciThemeStyle.dark),
      KomekciTheme.rose,
    );
    expect(buildThemeData(darkTokens).brightness, Brightness.dark);
  });
}
