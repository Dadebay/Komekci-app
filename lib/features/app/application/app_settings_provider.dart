import 'package:flutter/foundation.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';

/// Holds the backend's public settings. Starts on [AppSettings.fallback] so
/// screens always have values; [load] swaps in the server's once they arrive.
class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository();

  final SettingsRepository _repository;

  AppSettings _settings = AppSettings.fallback;
  bool _loaded = false;

  /// True once the API answered at least once this session.
  bool get loaded => _loaded;

  double get subscriptionPrice => _settings.subscriptionPrice;

  /// Whole-currency monthly fee, for the top-up/coverage maths.
  int get monthlyFee => _settings.subscriptionPrice.round();
  String get currency => _settings.currency;
  String get supportContact => _settings.supportContact;
  List<AppLanguage> get locales => _settings.locales;
  List<KomekciTheme> get themes => _settings.themes;
  AppThemeTokens themeTokensFor(KomekciTheme theme) {
    final bundled = tokensFor(theme);
    final tokens = _settings.themeColors[theme]?.applyTo(bundled) ?? bundled;
    // Keep red-theme cards and inputs white even if the API sends a pink secondary.
    return themeStyleFor(theme) == KomekciThemeStyle.red
        ? tokens.copyWith(surfaceElevated: tokens.surface)
        : tokens;
  }
  AppContact get contact => _settings.contact;
  AppAbout get about => _settings.about;
  int _loadGeneration = 0;

  /// Currency as written in UI copy: Turkmen manat is spelled out in Turkmen
  /// and Russian, anything else shows the ISO code the API sent.
  String currencyLabel(AppLanguage language) {
    if (currency.toUpperCase() == 'TMT') {
      return pickTr(language, tk: 'manat', ru: 'манат', en: 'TMT');
    }
    return currency;
  }

  /// Never throws: on failure the current (fallback) settings stay in place.
  Future<void> load({AppLanguage locale = AppLanguage.tk}) async {
    final generation = ++_loadGeneration;
    try {
      final settings = await _repository.fetchPublic(locale: locale.name);
      if (generation != _loadGeneration) return;
      _settings = settings;
      _loaded = true;
      notifyListeners();
    } catch (error) {
      debugPrint('Public settings request failed: $error');
      final cached = await _repository.cached();
      if (cached != null && generation == _loadGeneration) {
        _settings = cached;
        notifyListeners();
      }
    }
  }
}
