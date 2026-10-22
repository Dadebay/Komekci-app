import '../../core/localization/language_provider.dart';
import '../../core/theme/backend_theme_colors.dart';
import '../../core/theme/theme_provider.dart';

class AppContact {
  const AppContact({
    this.phone,
    this.email,
    this.imo,
    this.whatsapp,
    this.address,
  });

  final String? phone;
  final String? email;
  final String? imo;
  final String? whatsapp;
  final String? address;

  static String? _value(Object? value) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? null : text;
  }

  factory AppContact.fromJson(Map<String, dynamic> json) => AppContact(
    phone: _value(json['phone']),
    email: _value(json['email']),
    imo: _value(json['imo']),
    whatsapp: _value(json['whatsapp']),
    address: _value(json['address']),
  );
}

class AppAbout {
  const AppAbout({this.locale = 'tk', this.title, this.content});

  final String locale;
  final String? title;
  final String? content;

  factory AppAbout.fromJson(Map<String, dynamic> json) => AppAbout(
    locale: json['locale'] as String? ?? 'tk',
    title: AppContact._value(json['title']),
    content: AppContact._value(json['content']),
  );
}

/// Public app settings served by `GET /settings/public`:
/// `{"subscription_price": "20.00", "currency": "TMT",
///   "support_contact": "", "locales": ["tk", "ru", "en"]}`.
class AppSettings {
  const AppSettings({
    required this.subscriptionPrice,
    required this.currency,
    required this.supportContact,
    required this.locales,
    required this.themes,
    this.themeColors = const {},
    required this.contact,
    required this.about,
  });

  /// Used until the API answers, and whenever it can't be reached.
  static const fallback = AppSettings(
    subscriptionPrice: 20,
    currency: 'TMT',
    supportContact: '',
    locales: [AppLanguage.tk, AppLanguage.ru, AppLanguage.en],
    themes: [
      KomekciTheme.ivory,
      KomekciTheme.onyx,
      KomekciTheme.champagne,
      KomekciTheme.rose,
    ],
    contact: AppContact(),
    about: AppAbout(),
  );

  final double subscriptionPrice;
  final String currency;
  final String supportContact;

  /// Languages the backend enables, restricted to the ones the app has
  /// translations for.
  final List<AppLanguage> locales;
  final List<KomekciTheme> themes;
  final Map<KomekciTheme, BackendThemeColors> themeColors;
  final AppContact contact;
  final AppAbout about;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final locales = <AppLanguage>[
      for (final code in (json['locales'] as List? ?? const []))
        for (final language in AppLanguage.values)
          if (language.name == code) language,
    ];
    final currency = (json['currency'] as String?)?.trim() ?? '';
    final themes = <KomekciTheme>[
      for (final item in (json['themes'] as List? ?? const []))
        if (item is Map && item['enabled'] == true)
          for (final theme in KomekciTheme.values)
            if (theme.name == item['code']) theme,
    ];
    final themeColors = <KomekciTheme, BackendThemeColors>{};
    for (final item in (json['themes'] as List? ?? const [])) {
      if (item is! Map || item['enabled'] != true || item['colors'] is! Map) {
        continue;
      }
      for (final theme in KomekciTheme.values) {
        if (theme.name == item['code']) {
          themeColors[theme] = BackendThemeColors.fromJson(item['colors'] as Map);
        }
      }
    }
    return AppSettings(
      subscriptionPrice:
          double.tryParse('${json['subscription_price']}') ??
          fallback.subscriptionPrice,
      currency: currency.isEmpty ? fallback.currency : currency,
      supportContact: (json['support_contact'] as String?)?.trim() ?? '',
      locales: locales,
      themes: json['themes'] is List ? themes : fallback.themes,
      themeColors: themeColors,
      contact: json['contact'] is Map<String, dynamic>
          ? AppContact.fromJson(json['contact'] as Map<String, dynamic>)
          : const AppContact(),
      about: json['about'] is Map<String, dynamic>
          ? AppAbout.fromJson(json['about'] as Map<String, dynamic>)
          : const AppAbout(),
    );
  }
}
