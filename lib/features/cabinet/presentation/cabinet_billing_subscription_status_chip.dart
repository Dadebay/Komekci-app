part of '../../../app/komekci_app.dart';

class _SubscriptionStatusChip extends StatelessWidget {
  const _SubscriptionStatusChip({required this.status, required this.language});
  final SubscriptionStatus status;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (label, color) = switch (status) {
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
