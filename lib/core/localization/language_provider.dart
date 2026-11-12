import 'app_language.dart';
import 'app_strings.dart';
import 'package:flutter/foundation.dart';

export 'app_language.dart';

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
/// `AppStrings.coreMessage.select(language)`.
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

  String get appSubtitle => AppStrings.coreServiceAppointments.select(language);
  String get tapContinue => AppStrings.coreTapToContinue.select(language);
  String get chooseLanguage =>
      AppStrings.coreChooseYourLanguage.select(language);
  String get continueText => AppStrings.onboardingContinue.select(language);
  String get chooseRole => AppStrings.coreChooseYourRole.select(language);
  String get master => AppStrings.coreMaster.select(language);
  String get client => AppStrings.coreClient.select(language);
  String get masterText =>
      AppStrings.coreManageYourWorkAndClients.select(language);
  String get clientText => AppStrings.coreBookServicesWithEase.select(language);
  String get getStarted => AppStrings.onboardingGetStarted.select(language);
  String get haveAccount =>
      AppStrings.coreAlreadyHaveAnAccountLog.select(language);
}
