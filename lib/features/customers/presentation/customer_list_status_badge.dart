part of '../../../app/komekci_app.dart';

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.language});
  final CustomerStatus status;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: _statusColor(status, context.appTokens).withValues(alpha: .13),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(_statusIcon(status), size: 12, color: _statusColor(status, context.appTokens)),
        const SizedBox(width: 4),
        Text(
          _statusLabel(status, language),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _statusColor(status, context.appTokens),
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.language});
  final CustomerStatus status;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _statusBg(status, context.appTokens),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(_statusIcon(status), size: 14, color: _statusColor(status, context.appTokens)),
        const SizedBox(width: 6),
        Text(
          _statusLabel(status, language),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _statusColor(status, context.appTokens),
          ),
        ),
        const SizedBox(width: 2),
        AppIcon(Icons.expand_more, size: 14, color: _statusColor(status, context.appTokens)),
      ],
    ),
  );
}

/// Bottom sheet used to change a customer's status. Mirrors the app's other
/// "pick a value" sheets (see `_pickDuration` in cabinet_screens.dart).
Customer? _findCustomer(List<Customer> customers, String id) {
  for (final customer in customers) {
    if (customer.id == id) return customer;
  }
  return null;
}
