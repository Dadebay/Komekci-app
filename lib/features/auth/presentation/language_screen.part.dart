part of '../../../app/komekci_app.dart';

const _languageOptions = [
  (
    language: AppLanguage.tk,
    flag: '🇹🇲',
    primary: 'Türkmençe',
    secondary: 'Türkmen dili',
  ),
  (
    language: AppLanguage.ru,
    flag: '🇷🇺',
    primary: 'Русский',
    secondary: 'Русский язык',
  ),
  (
    language: AppLanguage.en,
    flag: '🇬🇧',
    primary: 'English',
    secondary: 'English language',
  ),
];

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key, this.standalone = false});

  /// True when opened from the client's Profile menu rather than the
  /// onboarding flow: shows a back button and "Save" just pops back to
  /// Profile instead of pushing [RoleScreen] onto a signed-in user's stack.
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final tr = Tr(language.language);
    final tokens = context.appTokens;
    return Scaffold(
      appBar: standalone
          ? CabinetAppBar(
              title: pickTr(
                language.language,
                tk: 'Dil',
                ru: 'Язык',
                en: 'Language',
              ),
            )
          : null,
      body: Container(
        color: tokens.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: standalone ? 12 : 48),
                // Fixed heights (not just maxLines) so switching languages —
                // whose strings wrap to a different number of lines — never
                // shifts the cards below up or down.
                SizedBox(
                  height: 64,
                  child: Center(
                    child: Text(
                      tr.chooseLanguage,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      pickTr(
                        language.language,
                        tk: 'Programmany ulanmak üçin öz diliňizi saýlaň',
                        ru: 'Выберите предпочтительный язык для приложения',
                        en: 'Choose your preferred language for the app',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                for (final option in _languageOptions.where(
                  (o) => settings.locales.contains(o.language),
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LanguageOptionCard(
                      flag: option.flag,
                      primary: option.primary,
                      secondary: option.secondary,
                      selected: language.language == option.language,
                      onTap: () => language.select(option.language),
                    ),
                  ),
                const Spacer(),
                PrimaryButton(
                  label: standalone
                      ? pickTr(
                          language.language,
                          tk: 'Ýatda sakla',
                          ru: 'Сохранить',
                          en: 'Save',
                        )
                      : tr.continueText,
                  onTap: () => standalone
                      ? (() {
                          context.read<AuthProvider>().savePreferences(
                            locale: language.language.name,
                          );
                          Navigator.maybePop(context);
                        })()
                      : Navigator.push(
                          context,
                          pageRoute(const RoleScreen()),
                        ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageOptionCard extends StatelessWidget {
  const LanguageOptionCard({
    super.key,
    required this.flag,
    required this.primary,
    required this.secondary,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String primary;
  final String secondary;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 61,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: selected ? tokens.surfaceElevated : tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? tokens.accent : tokens.border,
            width: selected ? 1.7 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    secondary,
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? tokens.accent : Colors.transparent,
                border: Border.all(
                  color: selected ? tokens.accent : tokens.border,
                ),
              ),
              child: selected
                  ? AppIcon(Icons.check, color: tokens.accentOn, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
