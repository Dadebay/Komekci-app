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
    final mastersCount = context.watch<ClientMastersProvider>().accepted.length;

    final notificationPrefs = context.watch<AuthProvider>().me?.notificationPrefs ?? const <String, bool>{};
    final notificationsOn = notificationPrefs.isEmpty || notificationPrefs.values.any((v) => v);
    return Builder(
      builder: (context) {
        final accountRows = <Widget>[
          _ClientProfileMenuRow(
            icon: Icons.groups_outlined,
            title: t(tk: 'Masterlerim', ru: 'Мои мастера', en: 'My masters'),
            subtitle: '$mastersCount',
            onTap: () => Navigator.push(context, pageRoute(const MyMastersScreen())),
          ),
          _ClientProfileMenuRow(
            icon: Icons.notifications_none,
            title: t(tk: 'Bildirişler', ru: 'Уведомления', en: 'Notifications'),
            subtitle: notificationsOn ? t(tk: 'Işjeň', ru: 'Включены', en: 'On') : t(tk: 'Öçürilen', ru: 'Отключены', en: 'Off'),
            onTap: () => Navigator.push(context, pageRoute(const ClientNotificationSettingsScreen())),
          ),
        ];
        final appRows = <Widget>[
          _ClientProfileMenuRow(
            icon: Icons.brush_outlined,
            title: t(tk: 'Görnüşi', ru: 'Оформление', en: 'Appearance'),
            subtitle: _themeName(theme, language),
            onTap: () => _showThemeSheet(context),
          ),
          _ClientProfileMenuRow(
            icon: Icons.language,
            title: t(tk: 'Dil', ru: 'Язык', en: 'Language'),
            subtitle: _languageName(language),
            onTap: () => _showLanguageSheet(context),
          ),
        ];
        final helpRows = <Widget>[
          _ClientProfileMenuRow(
            icon: Icons.help_outline,
            title: t(tk: 'Goldaw', ru: 'Поддержка', en: 'Support'),
            subtitle: t(tk: 'Soraglar', ru: 'Вопросы', en: 'FAQ'),
            onTap: () => Navigator.push(context, pageRoute(const ClientSupportScreen())),
          ),
        ];

        return Scaffold(
          backgroundColor: tokens.surface,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              children: [
                Text(t(tk: 'Profil', ru: 'Профиль', en: 'Profile'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 18),
                _ClientProfileCard(
                  onTap: () => Navigator.push(context, pageRoute(const ClientEditProfileScreen())),
                ),
                const SizedBox(height: 24),
                _ClientProfileGroup(title: t(tk: 'Hasap', ru: 'Аккаунт', en: 'Account'), children: accountRows),
                const SizedBox(height: 20),
                _ClientProfileGroup(title: t(tk: 'Programma', ru: 'Приложение', en: 'App'), children: appRows),
                const SizedBox(height: 20),
                _ClientProfileGroup(title: t(tk: 'Kömek', ru: 'Помощь', en: 'Help'), children: helpRows),
                const SizedBox(height: 20),
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
                const SizedBox(height: 10),
                Center(
                  child: Text('KÖMEKÇI · v1.0.0', style: TextStyle(fontSize: 11.5, color: tokens.textSecondary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _themeName(KomekciTheme theme, AppLanguage language) => switch (
  themeStyleFor(theme)
) {
  KomekciThemeStyle.gold =>
    pickTr(language, tk: 'Altyn', ru: 'Золотой', en: 'Gold'),
  KomekciThemeStyle.blue =>
    pickTr(language, tk: 'Mawy', ru: 'Синий', en: 'Blue'),
  KomekciThemeStyle.red =>
    pickTr(language, tk: 'Gyzyl', ru: 'Красный', en: 'Red'),
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
    backgroundColor: context.appTokens.surface,
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
                      context.read<AppSettingsProvider>().load(locale: option.language);
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
    isScrollControlled: true,
    backgroundColor: context.appTokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final language = sheetContext.watch<LanguageProvider>().language;
      final selected = sheetContext.watch<ThemeProvider>().selected;
      final settings = sheetContext.watch<AppSettingsProvider>();
      final enabledThemes = settings.themes;
      final goldCode = enabledThemeForStyle(enabledThemes, KomekciThemeStyle.gold);
      final blueCode = enabledThemeForStyle(enabledThemes, KomekciThemeStyle.blue);
      final redCode = enabledThemeForStyle(enabledThemes, KomekciThemeStyle.red);
      final options = <(KomekciTheme, AppThemeTokens)>[
        if (goldCode != null) (goldCode, settings.themeTokensFor(goldCode)),
        if (blueCode != null) (blueCode, settings.themeTokensFor(blueCode)),
        if (redCode != null) (redCode, settings.themeTokensFor(redCode)),
      ];
      String t({required String tk, required String ru, required String en}) =>
          pickTr(language, tk: tk, ru: ru, en: en);
      final tokens = sheetContext.appTokens;
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * .82),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(tk: 'Görnüşi saýlaň', ru: 'Выберите тему', en: 'Choose a theme'),
                            style: TextStyle(color: tokens.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            t(tk: 'Saýlan reňkiňiz derrew ulanylýar.', ru: 'Цвет применится сразу.', en: 'Your choice applies immediately.'),
                            style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: tokens.surfaceElevated,
                      shape: CircleBorder(side: BorderSide(color: tokens.border)),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(sheetContext),
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(Icons.close, size: 18, color: tokens.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (options.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        t(tk: 'Häzir tema saýlawy elýeterli däl.', ru: 'Темы сейчас недоступны.', en: 'Themes are unavailable right now.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tokens.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                for (final option in options) ...[
                  _ThemeOptionCard(
                    title: _themeName(option.$1, language),
                    description: _themeDescription(themeStyleFor(option.$1), language),
                    palette: option.$2,
                    selected: themeStyleFor(selected) == themeStyleFor(option.$1),
                    onTap: () {
                      themeProvider.select(option.$1);
                      authProvider.savePreferences(theme: option.$1.name);
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _themeDescription(KomekciThemeStyle style, AppLanguage language) =>
    switch (style) {
      KomekciThemeStyle.gold => pickTr(language, tk: 'Adaty görnüş', ru: 'Классический стиль', en: 'Classic look'),
      KomekciThemeStyle.blue => pickTr(language, tk: 'Mawy öwüşgin', ru: 'Синие акценты', en: 'Blue accents'),
      KomekciThemeStyle.red => pickTr(language, tk: 'Gyzyl öwüşgin', ru: 'Красные акценты', en: 'Red accents'),
    };
