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
        Icons.person_add_alt_1_outlined,
        t(tk: 'Baglanyşyk haýyşlary', ru: 'Запросы на связь', en: 'Connection requests'),
        const RequestsScreen(),
      ),
      (
        Icons.inbox_outlined,
        t(tk: 'Bildirişler', ru: 'Уведомления', en: 'Notifications'),
        const ClientNotificationSettingsScreen(),
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
            const SizedBox(height: 14),
            _SubscriptionNotice(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.danger,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                ),
                icon: const AppIcon(Icons.logout, size: 18),
                label: Text(t(tk: 'Ulgamdan çyk', ru: 'Выйти', en: 'Sign out')),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => _confirmDeleteAccount(context),
                child: Text(
                  t(tk: 'Hasaby poz', ru: 'Удалить аккаунт', en: 'Delete account'),
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uploads the master's new profile photo, surfacing a failure as a snackbar.
Future<void> _uploadAvatar(BuildContext context, File file) async {
  final toast = AppToast.of(context);
  final language = context.read<LanguageProvider>().language;
  try {
    await context.read<MasterProfileProvider>().setAvatar(file);
  } catch (error) {
    toast.error(apiErrorMessage(error, language));
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
                  networkUrl: profile.avatarUrl,
                  onPicked: (file) => _uploadAvatar(context, file),
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
                        text: displayPhone(profile.phone),
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
                        '$balance ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
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
                    pageRoute(const MasterSubscriptionScreen(onboarding: false)),
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

/// Tells a master whose subscription is not active that new bookings are
/// closed, with a shortcut to top up. Renders nothing when all is well.
class _SubscriptionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    if (!billing.loaded || billing.status == SubscriptionStatus.active) {
      return const SizedBox.shrink();
    }
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final suspended = billing.status == SubscriptionStatus.suspended;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => Navigator.push(context, pageRoute(const BillingScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (suspended ? tokens.danger : tokens.warning).withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AppIcon(Icons.info_outline, color: suspended ? tokens.danger : tokens.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suspended
                      ? pickTr(
                          language,
                          tk: 'Abuna işjeň däl: täze ýazgylar ýapyk. Açmak üçin balansy dolduryň.',
                          ru: 'Подписка не активна: новые записи закрыты. Пополните баланс, чтобы открыть.',
                          en: 'Subscription is not active: new bookings are closed. Top up to reopen.',
                        )
                      : pickTr(
                          language,
                          tk: 'Tölegiň wagty ýakynlaşdy. Balansy dolduryň.',
                          ru: 'Скоро нужно оплатить подписку. Пополните баланс.',
                          en: 'Your subscription payment is due soon. Please top up.',
                        ),
                  style: const TextStyle(fontSize: 12.5, height: 1.4),
                ),
              ),
              const AppIcon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
