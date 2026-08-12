import 'package:flutter/foundation.dart';

enum AppLanguage { tk, ru }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.tk;
  AppLanguage get language => _language;
  bool get isTurkmen => _language == AppLanguage.tk;
  void select(AppLanguage value) {
    _language = value;
    notifyListeners();
  }
}

class Tr {
  const Tr(this.language);
  final AppLanguage language;
  String get appSubtitle =>
      language == AppLanguage.tk ? 'HYZMAT ÝAZYLYŞLARY' : 'ЗАПИСЬ НА УСЛУГИ';
  String get tapContinue => language == AppLanguage.tk
      ? 'Dowam etmek üçin basyň'
      : 'Нажмите, чтобы продолжить';
  String get chooseLanguage =>
      language == AppLanguage.tk ? 'Dili saýlaň' : 'Выберите язык';
  String get continueText =>
      language == AppLanguage.tk ? 'Dowam et' : 'Продолжить';
  String get chooseRole =>
      language == AppLanguage.tk ? 'Roluňyzy saýlaň' : 'Выберите свою роль';
  String get master => language == AppLanguage.tk ? 'MASTER' : 'МАСТЕР';
  String get client => language == AppLanguage.tk ? 'KLIENT' : 'КЛИЕНТ';
  String get masterText => language == AppLanguage.tk
      ? 'Işiňizi we müşderileriňizi dolandyryň'
      : 'Управляйте услугами и клиентами';
  String get clientText => language == AppLanguage.tk
      ? 'Hyzmatlara aňsat ýazdyryň'
      : 'Выбирайте нужную услугу';
  String get getStarted => language == AppLanguage.tk ? 'Başla' : 'Начать';
}
