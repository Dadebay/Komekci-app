part of '../../../app/komekci_app.dart';

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? tokens.textPrimary : tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? tokens.textPrimary : tokens.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(
                icon!,
                size: 14,
                color: selected ? tokens.surface : tokens.textPrimary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? tokens.surface : tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    decoration: BoxDecoration(
      color: context.appTokens.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: const AppIcon(
          Icons.search,
          color: Colors.black45,
          size: 15,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 38,
          minHeight: 20,
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),
  );
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.tk});
  final Customer customer;
  final bool tk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        pageRoute(CustomerDetailScreen(customerId: customer.id)),
      ),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CustomerAvatar(customer: customer, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tk ? 'Şodny gelişi' : 'Последний визит',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            customer.lastVisitDate == null
                                ? '—'
                                : formatDate(customer.lastVisitDate!),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  _StatusBadge(status: customer.status, tk: tk),
                ],
              ),
            ),
            const SizedBox(width: 4),
            AppIcon(Icons.chevron_right, color: tokens.disabled, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.tk});
  final CustomerStatus status;
  final bool tk;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: _statusBg(status),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(_statusIcon(status), size: 12, color: _statusColor(status)),
        const SizedBox(width: 4),
        Text(
          _statusLabel(status, tk),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _statusColor(status),
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.tk});
  final CustomerStatus status;
  final bool tk;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _statusBg(status),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(_statusIcon(status), size: 14, color: _statusColor(status)),
        const SizedBox(width: 6),
        Text(
          _statusLabel(status, tk),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _statusColor(status),
          ),
        ),
        const SizedBox(width: 2),
        AppIcon(Icons.expand_more, size: 14, color: _statusColor(status)),
      ],
    ),
  );
}

/// Bottom sheet used to change a customer's status. Mirrors the app's other
/// "pick a value" sheets (see `_pickDuration` in cabinet_screens.part.dart).
Customer? _findCustomer(List<Customer> customers, String id) {
  for (final customer in customers) {
    if (customer.id == id) return customer;
  }
  return null;
}
