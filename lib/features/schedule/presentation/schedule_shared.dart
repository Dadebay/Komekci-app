part of '../../../app/komekci_app.dart';

const _weekdaysTk = AppStrings.weekdaysShortTk;
const _weekdaysRu = AppStrings.weekdaysShortRu;
const _weekdaysFullTk = AppStrings.weekdaysFullTk;
const _weekdaysFullRu = AppStrings.weekdaysFullRu;
const _weekdaysFullEn = AppStrings.weekdaysFullEn;
const _monthsShortTk = AppStrings.monthsShortTk;
const _monthsShortRu = AppStrings.monthsShortRu;
const _monthsShortEn = AppStrings.monthsShortEn;
const _monthsFullTk = AppStrings.monthsFullTk;
const _monthsFullRu = AppStrings.monthsFullRu;
const _monthsFullEn = AppStrings.monthsFullEn;

/// Picks the value for [language] from parallel tk/ru/en arrays or constants
/// (e.g. `_byLang(language, _weekdaysTk, _weekdaysRu, weekdaysEn)`).
T _byLang<T>(AppLanguage language, T tk, T ru, T en) => switch (language) {
  AppLanguage.tk => tk,
  AppLanguage.ru => ru,
  AppLanguage.en => en,
};
