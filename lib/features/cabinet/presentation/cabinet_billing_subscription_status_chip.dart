part of '../../../app/komekci_app.dart';

class _SubscriptionStatusChip extends StatelessWidget {
  const _SubscriptionStatusChip({
    required this.status,
    required this.language,
    this.promo,
  });
  final SubscriptionStatus status;
  final AppLanguage language;
  final PromoStatus? promo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (label, color) = promo?.active == true
        ? (AppStrings.cabinetFreeMonth.select(language), tokens.success)
        : promo?.isAvailable == true
        ? (AppStrings.cabinetFreeMonthAvailable.select(language), tokens.accent)
        : promo?.paidAccess == true
        ? (AppStrings.cabinetActive.select(language), tokens.success)
        : switch (status) {
            SubscriptionStatus.active => (
              AppStrings.cabinetActive.select(language),
              tokens.success,
            ),
            SubscriptionStatus.grace => (
              AppStrings.cabinetGracePeriod.select(language),
              tokens.warning,
            ),
            SubscriptionStatus.suspended => (
              AppStrings.cabinetSuspended.select(language),
              tokens.danger,
            ),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
