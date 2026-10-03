import '../../core/localization/language_provider.dart';

/// Public app settings served by `GET /settings/public`:
/// `{"subscription_price": "20.00", "currency": "TMT",
///   "support_contact": "", "locales": ["tk", "ru", "en"]}`.
class AppSettings {
  const AppSettings({
    required this.subscriptionPrice,
    required this.currency,
    required this.supportContact,
    required this.locales,
  });

  /// Used until the API answers, and whenever it can't be reached.
  static const fallback = AppSettings(
    subscriptionPrice: 20,
    currency: 'TMT',
    supportContact: '',
    locales: [AppLanguage.tk, AppLanguage.ru, AppLanguage.en],
  );

  final double subscriptionPrice;
  final String currency;
  final String supportContact;

  /// Languages the backend enables, restricted to the ones the app has
  /// translations for.
  final List<AppLanguage> locales;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final locales = <AppLanguage>[
      for (final code in (json['locales'] as List? ?? const []))
        for (final language in AppLanguage.values)
          if (language.name == code) language,
    ];
    final currency = (json['currency'] as String?)?.trim() ?? '';
    return AppSettings(
      subscriptionPrice:
          double.tryParse('${json['subscription_price']}') ??
          fallback.subscriptionPrice,
      currency: currency.isEmpty ? fallback.currency : currency,
      supportContact: (json['support_contact'] as String?)?.trim() ?? '',
      locales: locales.isEmpty ? fallback.locales : locales,
    );
  }
}
