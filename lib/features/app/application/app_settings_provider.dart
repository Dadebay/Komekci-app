import 'package:flutter/foundation.dart';

import '../../../core/localization/language_provider.dart';
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

  /// Currency as written in UI copy: Turkmen manat is spelled out in Turkmen
  /// and Russian, anything else shows the ISO code the API sent.
  String currencyLabel(AppLanguage language) {
    if (currency.toUpperCase() == 'TMT') {
      return pickTr(language, tk: 'manat', ru: 'манат', en: 'TMT');
    }
    return currency;
  }

  /// Never throws: on failure the current (fallback) settings stay in place.
  Future<void> load() async {
    try {
      _settings = await _repository.fetchPublic();
      _loaded = true;
      notifyListeners();
    } catch (error) {
      debugPrint('Public settings request failed: $error');
    }
  }
}
