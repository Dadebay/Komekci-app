import 'package:flutter/foundation.dart';

enum AppLanguage { tk, ru, en }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.tk;
  AppLanguage get language => _language;
  bool get isTurkmen => _language == AppLanguage.tk;
  bool get isRussian => _language == AppLanguage.ru;
  bool get isEnglish => _language == AppLanguage.en;
  void select(AppLanguage value) {
    _language = value;
    notifyListeners();
  }
}

/// Picks a translated string based on the current [AppLanguage]. Screens
/// still migrating off the legacy `tk ? a : b` pattern can use this directly:
/// `pickTr(language, tk: '...', ru: '...', en: '...')`.
String pickTr(
  AppLanguage language, {
  required String tk,
  required String ru,
  required String en,
}) => switch (language) {
  AppLanguage.tk => tk,
  AppLanguage.ru => ru,
  AppLanguage.en => en,
};

class Tr {
  const Tr(this.language);
  final AppLanguage language;

  String _t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);

  String get appSubtitle => _t(
    tk: 'HYZMAT ÝAZYLYŞLARY',
    ru: 'ЗАПИСЬ НА УСЛУГИ',
    en: 'SERVICE APPOINTMENTS',
  );
  String get tapContinue => _t(
    tk: 'Dowam etmek üçin basyň',
    ru: 'Нажмите, чтобы продолжить',
    en: 'Tap to continue',
  );
  String get chooseLanguage =>
      _t(tk: 'Dili saýlaň', ru: 'Выберите язык', en: 'Choose your language');
  String get continueText =>
      _t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue');
  String get chooseRole => _t(
    tk: 'Roluňyzy saýlaň',
    ru: 'Выберите свою роль',
    en: 'Choose your role',
  );
  String get master => _t(tk: 'MASTER', ru: 'МАСТЕР', en: 'MASTER');
  String get client => _t(tk: 'KLIENT', ru: 'КЛИЕНТ', en: 'CLIENT');
  String get masterText => _t(
    tk: 'Işiňizi we müşderileriňizi dolandyryň',
    ru: 'Управляйте услугами и клиентами',
    en: 'Manage your work and clients',
  );
  String get clientText => _t(
    tk: 'Hyzmatlara aňsat ýazdyryň',
    ru: 'Выбирайте нужную услугу',
    en: 'Book services with ease',
  );
  String get getStarted => _t(tk: 'Başla', ru: 'Начать', en: 'Get started');
  String get haveAccount => _t(
    tk: 'Hasabyňyz barmy? Giriň',
    ru: 'Уже есть аккаунт? Войти',
    en: 'Already have an account? Log in',
  );
}
