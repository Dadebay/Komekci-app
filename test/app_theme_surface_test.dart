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
            'code': 'champagne',
            'enabled': true,
            'colors': {'background': '#F8F1E7', 'secondary': '#C6A57B'},
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

      final champagne = settings.themeTokensFor(KomekciTheme.champagne);
      expect(champagne.surface, const Color(0xffF8F1E7));
      expect(champagne.surfaceElevated, const Color(0xffC6A57B));
    },
  );
}
