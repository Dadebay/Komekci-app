part of '../../../app/komekci_app.dart';

class _TopUpBalanceSummary extends StatelessWidget {
  const _TopUpBalanceSummary({
    required this.balance,
    required this.fee,
    required this.cur,
  });

  final String balance;
  final int fee;
  final String cur;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.cabinetBalance.select(language),
                  style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '$balance $cur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 40, color: tokens.border),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.authMonthly.select(language),
                style: TextStyle(fontSize: 12, color: tokens.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '$fee $cur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Balance and subscription state at a glance.
class _SubscriptionStatusStrip extends StatelessWidget {
  const _SubscriptionStatusStrip({required this.billing, required this.cur});
  final BillingProvider billing;
  final String cur;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final (label, color) = switch (billing.status) {
      SubscriptionStatus.active => (
        AppStrings.authSubscriptionActive.select(language),
        tokens.success,
      ),
      SubscriptionStatus.grace => (
        AppStrings.authPaymentDue.select(language),
        tokens.warning,
      ),
      SubscriptionStatus.suspended => (
        AppStrings.authSubscriptionInactive.select(language),
        tokens.danger,
      ),
    };
    final until = billing.paidUntil;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (until != null)
                  Text(
                    AppStrings.authUntil(formatDate(until)).select(language),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: tokens.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppStrings.cabinetBalance.select(language),
                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
              ),
              Text(
                '${billing.balance} $cur',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// What the subscription is and costs, on a dark card.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.fee, required this.cur});
  final int fee;
  final String cur;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final perks = [
      AppStrings.authAcceptOnlineBookings.select(language),
      AppStrings.authManageYourClientList.select(language),
      AppStrings.authSetYourHoursAndDays.select(language),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tokens.textPrimary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('♔', style: TextStyle(fontSize: 24, color: tokens.accent)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.authMasterSubscription.select(language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: tokens.surface.withValues(alpha: .75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$fee',
                style: TextStyle(
                  fontSize: 46,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: tokens.surface,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '$cur / ${AppStrings.authMonth.select(language)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: tokens.surface.withValues(alpha: .8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final perk in perks)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  AppIcon(Icons.check_circle, size: 18, color: tokens.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      perk,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: tokens.surface.withValues(alpha: .92),
                      ),
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

/// One selectable top-up amount ("40 TMT · 2 months").
