part of '../../../app/komekci_app.dart';

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.backgroundColor,
  });
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border.withValues(alpha: .7)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: false,
          prefixIcon: AppIcon(
            Icons.search,
            color: tokens.textSecondary,
            size: 17,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 42,
            minHeight: 20,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: tokens.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.language});
  final Customer customer;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final statusColor = _statusColor(customer.status, tokens);
    final next = customer.nextVisit;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        pageRoute(CustomerDetailScreen(customerId: customer.id)),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.border.withValues(alpha: .6)),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // The ring doubles as the loyalty tier marker.
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: .55),
                      width: 1.6,
                    ),
                  ),
                  child: _CustomerAvatar(customer: customer, radius: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customer.offline) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: tokens.border),
                              ),
                              child: Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AppIcon(
                            Icons.phone_outlined,
                            size: 12,
                            color: tokens.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customer.phone.isNotEmpty
                                  ? customer.phone
                                  : (customer.nickname.isNotEmpty
                                        ? '@${customer.nickname}'
                                        : '—'),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: tokens.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: customer.status, language: language),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: tokens.border.withValues(alpha: .7)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _CardFact(
                      icon: Icons.history,
                      label: pickTr(language, tk: 'Soňky sapar', ru: 'Последний визит', en: 'Last visit'),
                      value: customer.lastVisitDate == null
                          ? '—'
                          : formatDate(customer.lastVisitDate!),
                    ),
                  ),
                  Container(width: 1, height: 26, color: tokens.border),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CardFact(
                      icon: next == null
                          ? Icons.calendar_today_outlined
                          : Icons.schedule_outlined,
                      label: next == null
                          ? pickTr(language, tk: 'Gelişi', ru: 'Визитов', en: 'Visits')
                          : pickTr(language, tk: 'Indiki', ru: 'Следующий', en: 'Next'),
                      value: next == null
                          ? '${customer.totalVisits}'
                          : formatDate(next),
                      highlight: next != null,
                    ),
                  ),
                  AppIcon(
                    Icons.chevron_right,
                    color: tokens.disabled,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One "icon · caption / value" cell in the footer strip of [_CustomerCard].
class _CardFact extends StatelessWidget {
  const _CardFact({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        AppIcon(
          icon,
          size: 15,
          color: highlight ? tokens.accent : tokens.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: tokens.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: highlight ? tokens.accent : tokens.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
