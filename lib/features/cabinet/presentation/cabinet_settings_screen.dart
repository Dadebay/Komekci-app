part of '../../../app/komekci_app.dart';

class CabinetSettingsScreen extends StatelessWidget {
  const CabinetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final theme = context.watch<ThemeProvider>().selected;
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Sazlamalar', ru: 'Настройки', en: 'Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _softLine(tokens)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: AppIcon(
                      Icons.settings_outlined,
                      color: tokens.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(
                            tk: 'Programma sazlamalary',
                            ru: 'Настройки приложения',
                            en: 'App preferences',
                          ),
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t(
                            tk: 'Dili we görnüşi özüňize görä saýlaň.',
                            ru: 'Выберите язык и оформление.',
                            en: 'Choose your language and appearance.',
                          ),
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(
              t(tk: 'Saýlawlar', ru: 'Параметры', en: 'Preferences'),
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _CabinetPreferenceTile(
              icon: Icons.language,
              title: t(tk: 'Dil', ru: 'Язык', en: 'Language'),
              value: _languageName(language),
              onTap: () => _showLanguageSheet(context),
            ),
            _CabinetPreferenceTile(
              icon: Icons.brush_outlined,
              title: t(tk: 'Görnüşi', ru: 'Оформление', en: 'Appearance'),
              value: _themeName(theme),
              onTap: () => _showThemeSheet(context),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                t(
                  tk: 'Saýlawlaryňyz dessine ulanylýar.',
                  ru: 'Изменения применяются сразу.',
                  en: 'Changes apply immediately.',
                ),
                style: TextStyle(color: tokens.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinetPreferenceTile extends StatelessWidget {
  const _CabinetPreferenceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softLine(tokens)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AppIcon(icon, color: tokens.accent, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  Icons.chevron_right,
                  color: tokens.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
