part of '../../../app/komekci_app.dart';

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final entries = <(IconData, String, Widget)>[
      (
        Icons.person_outline,
        t(tk: 'Profil', ru: 'Профиль', en: 'Profile'),
        const CabinetProfileScreen(),
      ),
      (
        Icons.content_cut,
        t(tk: 'Hyzmatlar', ru: 'Услуги', en: 'Services'),
        const ServicesScreen(),
      ),
      (
        Icons.schedule_outlined,
        t(tk: 'Iş wagty', ru: 'График работы', en: 'Working hours'),
        const WorkingHoursScreen(),
      ),
      (
        Icons.notifications_none,
        t(tk: 'Bildiriş', ru: 'Уведомления', en: 'Notifications'),
        const ClientNotifyScreen(),
      ),
      (
        Icons.account_balance_wallet_outlined,
        t(
          tk: 'Töleg we Abuna',
          ru: 'Оплата и подписка',
          en: 'Billing & subscription',
        ),
        const BillingScreen(),
      ),
      (
        Icons.switch_account_outlined,
        t(tk: 'Rejimi üýtgetmek', ru: 'Изменить режим', en: 'Change mode'),
        const ChangeModeScreen(),
      ),
    ];
    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    t(tk: 'KABINET', ru: 'КАБИНЕТ', en: 'CABINET'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _RoundIconButton(
                  icon: Icons.notifications_none,
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(const ClientNotifyScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _MasterCard(
              onTap: () => Navigator.push(
                context,
                pageRoute(const CabinetProfileScreen()),
              ),
            ),
            const SizedBox(height: 22),
            ...List.generate(entries.length, (index) {
              final entry = entries[index];
              return _CabinetRow(
                index: index + 1,
                icon: entry.$1,
                label: entry.$2,
                onTap: () => Navigator.push(context, pageRoute(entry.$3)),
              );
            }),
            const SizedBox(height: 10),
            _HelpCard(
              onTap: () =>
                  Navigator.push(context, pageRoute(const SupportScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final balance = context.watch<BillingProvider>().balance;
    final profile = context.watch<MasterProfileProvider>();
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _softLine(tokens)),
          boxShadow: [
            BoxShadow(
              color: tokens.textPrimary.withValues(alpha: .05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPicker(
                  file: profile.avatar,
                  onPicked: (file) =>
                      context.read<MasterProfileProvider>().setAvatar(file),
                  radius: 36,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${profile.nickname}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MetaLine(
                        icon: Icons.phone_outlined,
                        text: profile.phone,
                      ),
                      const SizedBox(height: 5),
                      _MetaLine(
                        icon: Icons.location_on_outlined,
                        text: profile.address,
                      ),
                    ],
                  ),
                ),
                const AppIcon(
                  Icons.chevron_right,
                  color: Colors.black26,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: _softLine(tokens), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xffFDF9F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppIcon(
                    Icons.account_balance_wallet_outlined,
                    color: tokens.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(tk: 'Balans', ru: 'Баланс', en: 'Balance'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$balance ${t(tk: "manat", ru: "манат", en: "TMT")}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(const MasterSubscriptionScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t(tk: 'Doldur', ru: 'Пополнить', en: 'Top up'),
                      style: TextStyle(
                        color: tokens.surface,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AppIcon(icon, color: context.appTokens.accent, size: 14),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _CabinetRow extends StatelessWidget {
  const _CabinetRow({
    required this.index,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final int index;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _softLine(tokens)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffFDF9F2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AppIcon(icon, color: tokens.accent, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                '$index. $label',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const AppIcon(Icons.chevron_right, color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xffFDF9F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xffF0E4CE).withValues(alpha: .6),
          ),
        ),
        child: Row(
          children: [
            AppIcon(Icons.info_outline, color: tokens.accent, size: 20),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                pickTr(
                  language,
                  tk: 'Kömek gerekmi?',
                  ru: 'Нужна помощь?',
                  en: 'Need help?',
                ),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const AppIcon(Icons.chevron_right, color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}
