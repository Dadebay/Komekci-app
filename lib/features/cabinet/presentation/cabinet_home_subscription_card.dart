part of '../../../app/komekci_app.dart';

/// Home-screen subscription summary: status, the period, how many days are
/// left (with a progress bar) and the price that follows. Hidden until
/// billing has loaded and there is a date to count down to.
class _SubscriptionDaysCard extends StatelessWidget {
  const _SubscriptionDaysCard();

  /// Days until [end], rounded up so the last partial day still counts.
  static int _daysUntil(DateTime end) {
    final left = end.difference(DateTime.now());
    if (left.isNegative) return 0;
    return (left.inHours / 24).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    if (!billing.loaded) return const SizedBox.shrink();
    final promo = billing.promo;
    final isPromo = promo?.active == true;
    final DateTime? start = isPromo ? promo!.startsAt : billing.lastChargeAt;
    final DateTime? end = isPromo
        ? promo!.endsAt
        : billing.nextChargeAt ?? billing.paidUntil;
    final int? days;
    if (isPromo) {
      days = end != null ? _daysUntil(end) : promo!.daysLeft;
    } else {
      days = end != null && billing.status != SubscriptionStatus.suspended
          ? _daysUntil(end)
          : null;
    }
    if (days == null) return const SizedBox.shrink();

    final language = context.watch<LanguageProvider>().language;
    final settings = context.watch<AppSettingsProvider>();
    final tokens = context.appTokens;

    // Share of the period that is still ahead, when both ends are known.
    double? remaining;
    if (start != null && end != null && end.isAfter(start)) {
      remaining =
          (end.difference(DateTime.now()).inMinutes /
                  end.difference(start).inMinutes)
              .clamp(0.0, 1.0);
    }
    final price =
        billing.billing?.subscriptionPrice ?? settings.subscriptionPrice;
    final currency = settings.currencyLabel(language);
    final dateRange = start != null && end != null
        ? '${formatDate(start)} — ${formatDate(end)}'
        : end != null
        ? AppStrings.authUntil(formatDate(end)).select(language)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.push(context, pageRoute(const BillingScreen())),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      Icons.event_available_outlined,
                      color: tokens.accent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      AppStrings.cabinetSubscription.select(language),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _SubscriptionStatusChip(
                    status: billing.status,
                    language: language,
                    promo: promo,
                  ),
                ],
              ),
              if (dateRange != null) ...[
                const SizedBox(height: 8),
                Text(
                  isPromo
                      ? '${AppStrings.cabinetFreePeriod.select(language)} $dateRange'
                      : dateRange,
                  style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                AppStrings.cabinetDaysLeft(days).select(language),
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (remaining != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: remaining,
                    minHeight: 5,
                    backgroundColor: tokens.accent.withValues(alpha: .12),
                    valueColor: AlwaysStoppedAnimation(tokens.accent),
                  ),
                ),
              ],
              if (isPromo && price > 0) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.cabinetThenMonth(
                    formatMoney(price),
                    currency,
                  ).select(language),
                  style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${AppStrings.cabinetTapForSubscriptionDetails.select(language)} →',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: tokens.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
