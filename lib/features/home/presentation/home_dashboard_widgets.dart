part of '../../../app/komekci_app.dart';

/// Warm banner (avatar overlapping its lower edge) with the live clock and
/// date sitting below it — the master's "who am I, what time is it" panel.
class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.tk,
    required this.now,
    required this.today,
    required this.refreshingNumbers,
    required this.numberShimmer,
    required this.numberCountUp,
  });
  final bool tk;
  final DateTime now;
  final DateTime today;
  final bool refreshingNumbers;
  final Animation<double> numberShimmer;
  final Animation<double> numberCountUp;

  static const _avatarRadius = 30.0;
  static const _bannerHeight = 144.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final balance = context.watch<BillingProvider>().balance;
    final profile = context.watch<MasterProfileProvider>();
    final masterName = profile.name;
    final banner = profile.banner;
    final bannerUrl = profile.bannerUrl;
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final months = switch (language) {
      AppLanguage.tk => _monthsFullTk,
      AppLanguage.ru => _monthsFullRu,
      AppLanguage.en => _monthsFullEn,
    };
    final weekdays = switch (language) {
      AppLanguage.tk => _weekdaysFullTk,
      AppLanguage.ru => _weekdaysFullRu,
      AppLanguage.en => _weekdaysFullEn,
    };

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: _bannerHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tokens.brightness == Brightness.dark
                        ? tokens.surfaceElevated
                        : Color.lerp(tokens.textPrimary, tokens.accent, .25)!,
                    tokens.brightness == Brightness.dark
                        ? Color.lerp(tokens.surfaceElevated, tokens.accent, .5)!
                        : tokens.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (banner != null)
                    Image.file(banner, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
                  else if (bannerUrl != null)
                    Image.network(bannerUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroChip(
                          icon: Icons.chat_bubble_outline,
                          label: t(tk: 'Habarlaşmak', ru: 'Связаться', en: 'Contact us'),
                          onTap: () => Navigator.push(
                            context,
                            pageRoute(const SupportScreen()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _HeroBalanceChip(
                              refreshingNumbers: refreshingNumbers,
                              numberShimmer: numberShimmer,
                              numberCountUp: numberCountUp,
                              amount: balance,
                              currency: context
                                  .watch<AppSettingsProvider>()
                                  .currencyLabel(language),
                              onTap: () => Navigator.push(
                                context,
                                pageRoute(const BillingScreen()),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -_avatarRadius,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    shape: BoxShape.circle,
                  ),
                  child: RoundPhoto(
                    file: profile.avatar,
                    url: profile.avatarUrl,
                    radius: _avatarRadius - 4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _avatarRadius + 5),
        Text(
          masterName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: tokens.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$hh:$mm',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: tokens.textPrimary, height: 1),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: tokens.border,
            ),
            Expanded(
              child: Row(
                children: [
                  AppIcon(Icons.calendar_today_outlined, size: 18, color: tokens.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${today.day} ${months[today.month - 1]} ${today.year}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                        ),
                        Text(
                          weekdays[today.weekday - 1],
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// White pill action sitting on the hero banner — icon plus label, unlike
/// [IconActionButton] which is icon-only.
class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: context.appTokens.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 15, color: context.appTokens.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: context.appTokens.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

/// White pill on the hero banner showing the wallet balance.
class _HeroBalanceChip extends StatelessWidget {
  const _HeroBalanceChip({
    required this.refreshingNumbers,
    required this.numberShimmer,
    required this.numberCountUp,
    required this.amount,
    required this.currency,
    required this.onTap,
  });
  final bool refreshingNumbers;
  final Animation<double> numberShimmer;
  final Animation<double> numberCountUp;
  final String amount;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.appTokens.surface,
    borderRadius: BorderRadius.circular(30),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _DashboardNumber(
                loading: refreshingNumbers,
                shimmer: numberShimmer,
                countUp: numberCountUp,
                value: amount,
                suffix: ' $currency',
                color: context.appTokens.textPrimary,
                placeholderWidth: 56,
                placeholderHeight: 14,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: context.appTokens.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AppIcon(
              Icons.account_balance_wallet_outlined,
              size: 15,
              color: context.appTokens.textPrimary,
            ),
          ],
        ),
      ),
    ),
  );
}
