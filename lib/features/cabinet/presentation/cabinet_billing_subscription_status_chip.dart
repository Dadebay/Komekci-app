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
        ? (
            pickTr(
              language,
              tk: 'Mugt aý',
              ru: 'Бесплатный месяц',
              en: 'Free month',
            ),
            tokens.success,
          )
        : promo?.isAvailable == true
        ? (
            pickTr(
              language,
              tk: 'Mugt aý bar',
              ru: 'Месяц доступен',
              en: 'Free month available',
            ),
            tokens.accent,
          )
        : promo?.paidAccess == true
        ? (
            pickTr(language, tk: 'Aktiw', ru: 'Активна', en: 'Active'),
            tokens.success,
          )
        : switch (status) {
            SubscriptionStatus.active => (
              pickTr(language, tk: 'Aktiw', ru: 'Активна', en: 'Active'),
              tokens.success,
            ),
            SubscriptionStatus.grace => (
              pickTr(
                language,
                tk: 'Töleg wagty',
                ru: 'Льготный период',
                en: 'Grace period',
              ),
              tokens.warning,
            ),
            SubscriptionStatus.suspended => (
              pickTr(
                language,
                tk: 'Duruzylan',
                ru: 'Приостановлена',
                en: 'Suspended',
              ),
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
