part of '../../../app/komekci_app.dart';

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
          color: tokens.surface,
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
                        style: TextStyle(
                          fontSize: 13,
                          color: tokens.textSecondary,
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
                AppIcon(
                  Icons.chevron_right,
                  color: tokens.textSecondary,
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
                    color: tokens.accent.withValues(alpha: .1),
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
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tokens.textSecondary,
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
          style: TextStyle(fontSize: 12.5, color: context.appTokens.textSecondary),
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
    this.badgeCount = 0,
  });
  final int index;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: tokens.surface,
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
                color: tokens.accent.withValues(alpha: .1),
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
            if (badgeCount > 0) ...[
              Container(
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: tokens.danger,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
            ],
            AppIcon(Icons.chevron_right, color: tokens.textSecondary, size: 18),
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
          color: tokens.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tokens.border,
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
            AppIcon(Icons.chevron_right, color: tokens.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Tells a master whose subscription is not active that new bookings are
/// closed, with a shortcut to top up. Renders nothing when all is well.
