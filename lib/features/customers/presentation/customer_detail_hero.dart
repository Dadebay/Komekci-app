part of '../../../app/komekci_app.dart';

class _CustomerDetailHero extends StatelessWidget {
  const _CustomerDetailHero({required this.customer, required this.language});

  final Customer customer;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final statusColor = _statusColor(customer.status, tokens);
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_statusBg(customer.status, tokens), tokens.surfaceElevated],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: statusColor.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: .10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft decorative bubble tinted by the loyalty tier.
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withValues(alpha: .08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _SquareIconButton(
                    icon: Icons.edit_outlined,
                    onTap: () => Navigator.push(
                      context,
                      pageRoute(CustomerFormScreen(customer: customer)),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.surface,
                          border: Border.all(color: statusColor, width: 2.4),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: .25),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _CustomerAvatar(customer: customer, radius: 42),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        customer.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            Icons.phone_outlined,
                            size: 13,
                            color: tokens.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            customer.phone.isEmpty
                                ? (customer.nickname.isEmpty
                                      ? '—'
                                      : '@${customer.nickname}')
                                : displayPhone(customer.phone),
                            style: TextStyle(
                              fontSize: 13.5,
                              color: tokens.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () =>
                            _pickCustomerStatus(context, customer, language),
                        child: _StatusPill(
                          status: customer.status,
                          language: language,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStatCard(
                        icon: Icons.event_available_outlined,
                        value: '${customer.totalVisits}',
                        label: AppStrings.customersVisits2.select(language),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroStatCard(
                        icon: Icons.payments_outlined,
                        value: '${customer.totalSpent}',
                        label: currency,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroStatCard(
                        icon: Icons.history,
                        value: customer.lastVisitDate == null
                            ? '—'
                            : formatDate(customer.lastVisitDate!),
                        label: AppStrings.customersLastVisit.select(language),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border.withValues(alpha: .6)),
      ),
      child: Column(
        children: [
          AppIcon(icon, size: 16, color: tokens.accent),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
