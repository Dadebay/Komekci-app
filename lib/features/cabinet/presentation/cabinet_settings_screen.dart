part of '../../../app/komekci_app.dart';

class CabinetSettingsScreen extends StatelessWidget {
  const CabinetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final theme = context.watch<ThemeProvider>().selected;
    final tokens = context.appTokens;

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: AppStrings.profileSettings.select(language)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _softLine(tokens)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _CabinetPreferenceTile(
                    icon: Icons.translate_rounded,
                    title: AppStrings.profileLanguage.select(language),
                    value: _languageName(language),
                    trailing: LanguageFlag(language: language, size: 22),
                    onTap: () => _showLanguageSheet(context),
                  ),
                  Divider(height: 1, indent: 70, color: _softLine(tokens)),
                  _CabinetPreferenceTile(
                    icon: Icons.palette_outlined,
                    title: AppStrings.profileAppearance.select(language),
                    value: _themeLabel(themeStyleFor(theme), language),
                    trailing: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: tokens.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.border),
                      ),
                    ),
                    onTap: () => _showThemeSheet(context),
                  ),
                ],
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
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AppIcon(icon, color: tokens.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing,
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(color: tokens.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(width: 4),
            AppIcon(Icons.chevron_right, color: tokens.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
