part of '../../../app/komekci_app.dart';


/// Client's "Profil" bottom-nav tab — a profile summary card that opens
/// [ClientEditProfileScreen], and a menu of real destinations (no stubs):
/// connected masters, notification preferences, appearance, language and
/// support, plus sign-out.
class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final theme = context.watch<ThemeProvider>().selected;

    final notificationPrefs = context.watch<AuthProvider>().me?.notificationPrefs ?? const <String, bool>{};
    final notificationsOn = notificationPrefs.isEmpty || notificationPrefs.values.any((v) => v);
    return Builder(
      builder: (context) {
        final entries = <(IconData, String, String, VoidCallback)>[
          (
            Icons.groups_outlined,
            t(tk: 'Ussalarym', ru: 'Мои мастера', en: 'My masters'),
            t(
              tk: 'Baglanan ussalaryňyz',
              ru: 'Связанные мастера',
              en: 'Masters you follow',
            ),
            () => Navigator.push(context, pageRoute(const MyMastersScreen())),
          ),
          (
            Icons.notifications_none,
            t(tk: 'Bildirişler', ru: 'Уведомления', en: 'Notifications'),
            notificationsOn
                ? t(tk: 'Işjeň', ru: 'Включены', en: 'Enabled')
                : t(tk: 'Öçürilen', ru: 'Отключены', en: 'Disabled'),
            () => Navigator.push(
              context,
              pageRoute(const ClientNotificationSettingsScreen()),
            ),
          ),
          (
            Icons.brush_outlined,
            t(tk: 'Görnüşi', ru: 'Оформление', en: 'Appearance'),
            _themeName(theme),
            () => _showThemeSheet(context),
          ),
          (
            Icons.language,
            t(tk: 'Dil', ru: 'Язык', en: 'Language'),
            _languageName(language),
            () => _showLanguageSheet(context),
          ),
          (
            Icons.help_outline,
            t(tk: 'Goldaw', ru: 'Поддержка', en: 'Support'),
            t(
              tk: 'Soraglar we habarlaşyk',
              ru: 'Вопросы и контакты',
              en: 'FAQ & contact',
            ),
            () => Navigator.push(context, pageRoute(const ClientSupportScreen())),
          ),
        ];

        return Scaffold(
          backgroundColor: tokens.surface,
          appBar: CabinetAppBar(
            title: t(tk: 'Profil', ru: 'Профиль', en: 'Profile'),
          ),
          body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          children: [
            _ClientProfileCard(
              onTap: () => Navigator.push(
                context,
                pageRoute(const ClientEditProfileScreen()),
              ),
            ),
            const SizedBox(height: 22),
            ...entries.map(
              (entry) => _ClientProfileMenuRow(
                icon: entry.$1,
                title: entry.$2,
                subtitle: entry.$3,
                onTap: entry.$4,
              ),
            ),
            const SizedBox(height: 14),
            _ClientLogoutButton(t: t),
            Center(
              child: TextButton(
                onPressed: () => _confirmDeleteAccount(context),
                child: Text(
                  t(tk: 'Hasaby poz', ru: 'Удалить аккаунт', en: 'Delete account'),
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'KÖMEKÇI · v1.0.0',
                style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
              ),
            ),
          ],
          ),
        );
      },
    );
  }
}

String _themeName(KomekciTheme theme) => switch (theme) {
  KomekciTheme.ivory => 'Ivory',
  KomekciTheme.onyx => 'Onyx',
  KomekciTheme.champagne => 'Champagne',
  KomekciTheme.rose => 'Rose',
};

String _languageName(AppLanguage language) => switch (language) {
  AppLanguage.tk => 'Türkmençe',
  AppLanguage.ru => 'Русский',
  AppLanguage.en => 'English',
};

/// "Dil" row's destination — a bottom sheet instead of a full screen push,
/// since picking a language is a single tap with nothing else to configure.
void _showLanguageSheet(BuildContext context) {
  final languageProvider = context.read<LanguageProvider>();
  final authProvider = context.read<AuthProvider>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final language = sheetContext.watch<LanguageProvider>().language;
      final locales = sheetContext.watch<AppSettingsProvider>().locales;
      String t({required String tk, required String ru, required String en}) =>
          pickTr(language, tk: tk, ru: ru, en: en);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(tk: 'Dil', ru: 'Язык', en: 'Language'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (final option in _languageOptions.where(
                (o) => locales.contains(o.language),
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: LanguageOptionCard(
                    flag: option.flag,
                    primary: option.primary,
                    secondary: option.secondary,
                    selected: language == option.language,
                    onTap: () {
                      languageProvider.select(option.language);
                      authProvider.savePreferences(locale: option.language.name);
                      Navigator.maybePop(sheetContext);
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// "Görnüşi" row's destination — a bottom sheet instead of a full screen
/// push, mirroring [_showLanguageSheet] since picking a theme is a single
/// tap with nothing else to configure.
void _showThemeSheet(BuildContext context) {
  final themeProvider = context.read<ThemeProvider>();
  final authProvider = context.read<AuthProvider>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final language = sheetContext.watch<LanguageProvider>().language;
      final selected = sheetContext.watch<ThemeProvider>().selected;
      String t({required String tk, required String ru, required String en}) =>
          pickTr(language, tk: tk, ru: ru, en: en);
      final tokens = sheetContext.appTokens;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(tk: 'Görnüşi', ru: 'Оформление', en: 'Appearance'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                t(
                  tk: 'Reňk görnüşini saýlaň',
                  ru: 'Выберите цветовую тему',
                  en: 'Choose a colour theme',
                ),
                style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
              ),
              const SizedBox(height: 14),
              // Each swatch's fill/icon/text colours are that theme's own
              // fixed identity (e.g. Ivory's cream/ink), not the currently
              // active theme — deliberately not read from context.appTokens,
              // or every swatch would render in the active theme's colours.
              ...[
                ('Ivory', cream, ink, KomekciTheme.ivory),
                ('Onyx', const Color(0xff1A1A1C), Colors.white, KomekciTheme.onyx),
                (
                  'Champagne',
                  const Color(0xffFAF6EE),
                  const Color(0xffB9963F),
                  KomekciTheme.champagne,
                ),
                (
                  'Rose',
                  const Color(0xffFCF7F6),
                  const Color(0xffB0757C),
                  KomekciTheme.rose,
                ),
              ].map(
                (swatch) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      themeProvider.select(swatch.$4);
                      authProvider.savePreferences(theme: swatch.$4.name);
                      Navigator.maybePop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(17),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: swatch.$2,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: swatch.$3,
                            child: AppIcon(
                              selected == swatch.$4 ? Icons.check : Icons.circle_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            swatch.$1,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: swatch.$3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
