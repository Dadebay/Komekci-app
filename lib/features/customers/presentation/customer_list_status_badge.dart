part of '../../../app/komekci_app.dart';

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.language, this.onTap});
  final CustomerStatus status;
  final AppLanguage language;

  /// When set, the badge opens the status picker and shows a chevron.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: _badge(context),
  );

  Widget _badge(BuildContext context) => Container(
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
        if (onTap != null) ...[
          const SizedBox(width: 2),
          AppIcon(Icons.expand_more, size: 13, color: _statusColor(status, context.appTokens)),
        ],
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

/// Bottom sheet used to change a customer's status
/// (`PATCH /me/clients/{id}` with `new`, `regular` or `vip`).
Future<void> _pickCustomerStatus(
  BuildContext context,
  Customer customer,
  AppLanguage language,
) async {
  final tokens = context.appTokens;
  final provider = context.read<CustomerProvider>();
  final picked = await showModalBottomSheet<CustomerStatus>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CustomerAvatar(customer: customer, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.customersCustomerStatus.select(language),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final status in const [
              CustomerStatus.vip,
              CustomerStatus.regular,
              CustomerStatus.newClient,
            ])
              _StatusOptionTile(
                status: status,
                language: language,
                selected: customer.status == status,
                onTap: () => Navigator.pop(sheetContext, status),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked == null || picked == customer.status || !context.mounted) return;
  await runApi(context, () => provider.setStatus(customer.id, picked));
}

String _statusHint(CustomerStatus status, AppLanguage language) => switch (status) {
  CustomerStatus.vip => AppStrings.customersPriorityClient.select(language),
  CustomerStatus.regular => AppStrings.customersVisitsRegularly.select(language),
  CustomerStatus.newClient => AppStrings.customersJustGettingToKnow.select(language),
};

class _StatusOptionTile extends StatelessWidget {
  const _StatusOptionTile({
    required this.status,
    required this.language,
    required this.selected,
    required this.onTap,
  });
  final CustomerStatus status;
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = _statusColor(status, tokens);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? _statusBg(status, tokens) : tokens.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? color : tokens.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AppIcon(_statusIcon(status), size: 21, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(status, language),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusHint(status, language),
                        style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(color: selected ? color : tokens.border, width: 1.6),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Customer? _findCustomer(List<Customer> customers, String id) {
  for (final customer in customers) {
    if (customer.id == id) return customer;
  }
  return null;
}
