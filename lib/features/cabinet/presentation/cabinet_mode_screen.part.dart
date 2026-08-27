part of '../../../app/komekci_app.dart';

/// Lets the master temporarily switch into the client-facing app (and back)
/// without signing out — [AuthProvider.role] drives which shell (MasterHome
/// vs ClientHome) is shown app-wide.
class ChangeModeScreen extends StatefulWidget {
  const ChangeModeScreen({super.key});

  @override
  State<ChangeModeScreen> createState() => _ChangeModeScreenState();
}

class _ChangeModeScreenState extends State<ChangeModeScreen> {
  late UserRole _selected = context.read<AuthProvider>().role;

  void _confirm(UserRole current) {
    if (_selected == current) return;
    context.read<AuthProvider>().chooseRole(_selected);
    Navigator.of(context).pushAndRemoveUntil(
      pageRoute(
        _selected == UserRole.master ? const MasterHome() : const ClientHome(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final current = context.watch<AuthProvider>().role;
    final tokens = context.appTokens;

    final options = [
      (
        role: UserRole.master,
        icon: Icons.account_box_outlined,
        title: t(tk: 'Režim master', ru: 'Режим мастера', en: 'Master mode'),
        subtitle: t(
          tk: 'Siz master hökmünde işleýärsiňiz',
          ru: 'Вы работаете как мастер',
          en: 'You are working as a master',
        ),
      ),
      (
        role: UserRole.client,
        icon: Icons.person_outline,
        title: t(tk: 'Režim ulanyjy', ru: 'Режим клиента', en: 'Client mode'),
        subtitle: t(
          tk: 'Siz hyzmat almak üçin ulanyjy hökmünde girersiňiz',
          ru: 'Вы войдёте как клиент, чтобы получать услуги',
          en: 'You will sign in as a client to receive services',
        ),
      ),
    ];
    final currentOption = options.firstWhere((o) => o.role == current);
    final otherOption = options.firstWhere((o) => o.role != current);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Režimi üýtgetmek',
          ru: 'Изменить режим',
          en: 'Change mode',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                children: [
                  _ModeExplainerBanner(
                    language: language,
                    currentLabel: currentOption.title,
                    otherLabel: otherOption.title,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    t(
                      tk: 'Häzirki režimiňiz',
                      ru: 'Ваш текущий режим',
                      en: 'Your current mode',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ModeOptionCard(
                    icon: currentOption.icon,
                    title: currentOption.title,
                    subtitle: currentOption.subtitle,
                    selected: _selected == currentOption.role,
                    onTap: () => setState(() => _selected = currentOption.role),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t(
                      tk: 'Beýleki režim',
                      ru: 'Другой режим',
                      en: 'Other mode',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ModeOptionCard(
                    icon: otherOption.icon,
                    title: otherOption.title,
                    subtitle: otherOption.subtitle,
                    selected: _selected == otherOption.role,
                    onTap: () => setState(() => _selected = otherOption.role),
                  ),
                  const SizedBox(height: 20),
                  _SecurityNote(language: language),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: _MasterActionButton(
                label: t(
                  tk: 'Režimi üýtgetmek',
                  ru: 'Изменить режим',
                  en: 'Change mode',
                ),
                enabled: _selected != current,
                leading: Icons.swap_horiz,
                onTap: () => _confirm(current),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeExplainerBanner extends StatelessWidget {
  const _ModeExplainerBanner({
    required this.language,
    required this.currentLabel,
    required this.otherLabel,
  });
  final AppLanguage language;
  final String currentLabel;
  final String otherLabel;

  @override
  Widget build(BuildContext context) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF6F5F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.surfaceElevated,
            ),
            child: AppIcon(
              Icons.info_outline,
              size: 16,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(
                    tk: 'Režimi näme üçin üýtgetmeli?',
                    ru: 'Зачем менять режим?',
                    en: 'Why change mode?',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(
                    tk: 'Siz häzirki wagtda "$currentLabel" režimindesiňiz. Bu režimde siz öz işiňizi dolandyryp we müşderileriňizi kabul edýärsiňiz.\n\nEger siz hem hyzmat almak isleseňiz, "$otherLabel" saýlap bilersiňiz.',
                    ru: 'Сейчас вы в режиме «$currentLabel». В этом режиме вы управляете своей работой и принимаете клиентов.\n\nЕсли вы также хотите получать услуги, выберите «$otherLabel».',
                    en: 'You are currently in "$currentLabel" mode. In this mode you manage your work and accept clients.\n\nIf you also want to receive services, you can switch to "$otherLabel".',
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFAF8F4) : tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? tokens.textPrimary : tokens.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? tokens.textPrimary.withValues(alpha: .08)
                    : tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon, size: 20, color: tokens.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? tokens.textPrimary : Colors.transparent,
                border: Border.all(
                  color: selected ? tokens.textPrimary : tokens.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? AppIcon(Icons.check, size: 12, color: tokens.surface)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF6F5F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.surfaceElevated,
            ),
            child: AppIcon(
              Icons.shield_outlined,
              size: 15,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(
                    tk: 'Maglumatlar howpsuz saklanýar',
                    ru: 'Данные хранятся безопасно',
                    en: 'Your data is stored securely',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t(
                    tk: 'Režimi üýtgetseňiz-de, ähli maglumatlaryňyz we sazlamalaryňyz saklanar.',
                    ru: 'Даже при смене режима все ваши данные и настройки сохранятся.',
                    en: 'Even if you change mode, all your data and settings are kept.',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
