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

    final notificationPrefs =
        context.watch<AuthProvider>().me?.notificationPrefs ??
        const <String, bool>{};
    final notificationsOn =
        notificationPrefs.isEmpty || notificationPrefs.values.any((v) => v);
    return Builder(
      builder: (context) {
        final accountRows = <Widget>[
          _ClientProfileMenuRow(
            icon: Icons.groups_outlined,
            title: AppStrings.profileMyMasters.select(language),
            subtitle: '$mastersCount',
            onTap: () =>
                Navigator.push(context, pageRoute(const MyMastersScreen())),
          ),
          _ClientProfileMenuRow(
            icon: Icons.notifications_none,
            title: AppStrings.profileNotifications.select(language),
            subtitle: notificationsOn
                ? AppStrings.profileOn.select(language)
                : AppStrings.profileOff.select(language),
            onTap: () => Navigator.push(
              context,
              pageRoute(const ClientNotificationSettingsScreen()),
            ),
          ),
        ];
        final appRows = <Widget>[
          _ClientProfileMenuRow(
            icon: Icons.brush_outlined,
            title: AppStrings.profileAppearance.select(language),
            subtitle: _themeName(theme),
            onTap: () => _showThemeSheet(context),
          ),
          _ClientProfileMenuRow(
            icon: Icons.language,
            title: AppStrings.profileLanguage.select(language),
            subtitle: _languageName(language),
            onTap: () => _showLanguageSheet(context),
          ),
        ];
        final helpRows = <Widget>[
          _ClientProfileMenuRow(
            icon: Icons.help_outline,
            title: AppStrings.profileSupport.select(language),
            subtitle: AppStrings.profileFaq.select(language),
            onTap: () =>
                Navigator.push(context, pageRoute(const ClientSupportScreen())),
          ),
        ];

        return Scaffold(
          backgroundColor: tokens.surface,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              children: [
                Text(
                  AppStrings.profileProfile.select(language),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                _ClientProfileCard(
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(const ClientEditProfileScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                _ClientProfileGroup(
                  title: AppStrings.profileAccount.select(language),
                  children: accountRows,
                ),
                const SizedBox(height: 20),
                _ClientProfileGroup(
                  title: AppStrings.profileApp.select(language),
                  children: appRows,
                ),
                const SizedBox(height: 20),
                _ClientProfileGroup(
                  title: AppStrings.profileHelp.select(language),
                  children: helpRows,
                ),
                const SizedBox(height: 20),
                _ClientLogoutButton(t: t),
                Center(
                  child: TextButton(
                    onPressed: () => _confirmDeleteAccount(context),
                    child: Text(
                      AppStrings.profileDeleteAccount.select(language),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'KÖMEKÇI · v1.0.0',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: tokens.textSecondary,
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
}

String _themeName(KomekciTheme theme) => switch (themeStyleFor(theme)) {
  KomekciThemeStyle.gold => 'Ivory',
  KomekciThemeStyle.blue => 'Onyx',
  KomekciThemeStyle.red => 'Champagne',
  KomekciThemeStyle.dark => 'Rose',
};

String _languageName(AppLanguage language) => switch (language) {
  AppLanguage.tk => AppStrings.languageTurkmen,
  AppLanguage.ru => AppStrings.languageRussian,
  AppLanguage.en => AppStrings.languageEnglish,
};

/// "Dil" row's destination — a floating sheet, since picking a language is a
/// single tap with nothing else to configure.
void _showLanguageSheet(BuildContext context) {
  final languageProvider = context.read<LanguageProvider>();
  final authProvider = context.read<AuthProvider>();
  final settingsProvider = context.read<AppSettingsProvider>();
  final language = languageProvider.language;
  _showFloatingSheet<void>(
    context,
    icon: Icons.translate_rounded,
    title: AppStrings.profileChooseLanguage.select(language),
    subtitle: AppStrings.profileChangeTheAppLanguage.select(language),
    builder: (sheetContext) {
      final current = sheetContext.watch<LanguageProvider>().language;
      final locales = sheetContext.watch<AppSettingsProvider>().locales;
      return _SheetChoiceGroup(
        children: [
          for (final option in _languageOptions.where(
            (o) => locales.contains(o.language),
          ))
            _SheetChoiceRow(
              leading: LanguageFlag(language: option.language, size: 36),
              title: option.primary,
              subtitle: option.secondary,
              selected: current == option.language,
              onTap: () {
                languageProvider.select(option.language);
                settingsProvider.load(locale: option.language);
                authProvider.savePreferences(locale: option.language.name);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      );
    },
  );
}

/// "Görnüşi" row's destination — a floating sheet mirroring
/// [_showLanguageSheet].
void _showThemeSheet(BuildContext context) {
  final themeProvider = context.read<ThemeProvider>();
  final authProvider = context.read<AuthProvider>();
  final language = context.read<LanguageProvider>().language;
  _showFloatingSheet<void>(
    context,
    icon: Icons.palette_outlined,
    title: AppStrings.profileChooseATheme.select(language),
    subtitle: AppStrings.profileYourChoiceAppliesImmediately.select(language),
    builder: (sheetContext) {
      final tokens = sheetContext.appTokens;
      final selected = sheetContext.watch<ThemeProvider>().selected;
      final settings = sheetContext.watch<AppSettingsProvider>();
      final options = <(KomekciTheme, AppThemeTokens)>[
        for (final style in [
          KomekciThemeStyle.gold,
          KomekciThemeStyle.blue,
          KomekciThemeStyle.red,
          KomekciThemeStyle.dark,
        ])
          if (enabledThemeForStyle(settings.themes, style) case final code?)
            (code, settings.themeTokensFor(code)),
      ];
      if (options.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            AppStrings.profileThemesAreUnavailableRightNow.select(language),
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textSecondary, fontSize: 14),
          ),
        );
      }
      return _SheetChoiceGroup(
        children: [
          for (final (code, palette) in options)
            _SheetChoiceRow(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.border),
                ),
              ),
              title: _themeLabel(themeStyleFor(code), language),
              subtitle: _themeDescription(themeStyleFor(code), language),
              selected: themeStyleFor(selected) == themeStyleFor(code),
              onTap: () {
                themeProvider.select(code);
                authProvider.savePreferences(theme: code.name);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      );
    },
  );
}

String _themeLabel(KomekciThemeStyle style, AppLanguage language) =>
    switch (style) {
      KomekciThemeStyle.gold => AppStrings.profileGold.select(language),
      KomekciThemeStyle.blue => AppStrings.profileBlue.select(language),
      KomekciThemeStyle.red => AppStrings.profileRed.select(language),
      KomekciThemeStyle.dark => AppStrings.profileDark.select(language),
    };

String _themeDescription(KomekciThemeStyle style, AppLanguage language) =>
    switch (style) {
      KomekciThemeStyle.gold => AppStrings.profileClassicLook.select(language),
      KomekciThemeStyle.blue => AppStrings.profileBlueAccents.select(language),
      KomekciThemeStyle.red => AppStrings.profileRedAccents.select(language),
      KomekciThemeStyle.dark => AppStrings.profileDarkTheme.select(language),
    };
