part of '../../../app/komekci_app.dart';

class _CustomerControls extends StatelessWidget {
  const _CustomerControls({
    required this.searchController,
    required this.provider,
    required this.language,
    required this.onFilterTap,
  });
  final TextEditingController searchController;
  final CustomerProvider provider;
  final AppLanguage language;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    // "Uzak wagt gelmedi" is the one filter the tab bar has no slot for, so
    // the filter button lights up while it is the active one.
    final sheetFilterActive = provider.filter == CustomerFilter.inactive;
    return Container(
      color: tokens.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _SearchField(
                    controller: searchController,
                    hint: pickTr(language, tk: 'Müşderi gözlemek', ru: 'Поиск клиента', en: 'Search customers'),
                    onChanged: provider.setQuery,
                    backgroundColor: tokens.surface,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onFilterTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: sheetFilterActive
                          ? tokens.textPrimary
                          : tokens.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sheetFilterActive
                            ? tokens.textPrimary
                            : tokens.border.withValues(alpha: .7),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: AppIcon(
                          Icons.filter_list,
                          color: sheetFilterActive
                              ? tokens.surface
                              : tokens.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _StatGrid(provider: provider, language: language),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.provider, required this.language});
  final CustomerProvider provider;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _StatCard(
          icon: Icons.people_outline,
          label: pickTr(language, tk: 'Ähli', ru: 'Все', en: 'All'),
          value: provider.allCount,
          color: context.appTokens.textPrimary,
          selected: provider.filter == CustomerFilter.all,
          onTap: () => provider.setFilter(CustomerFilter.all),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _StatCard(
          icon: Icons.emoji_events_outlined,
          label: 'VIP',
          value: provider.vipCount,
          color: _statusColor(CustomerStatus.vip, context.appTokens),
          selected: provider.filter == CustomerFilter.vip,
          onTap: () => provider.setFilter(CustomerFilter.vip),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _StatCard(
          icon: Icons.star_border,
          label: pickTr(language, tk: 'Hemişelik', ru: 'Постоянные', en: 'Regular'),
          value: provider.regularCount,
          color: _statusColor(CustomerStatus.regular, context.appTokens),
          selected: provider.filter == CustomerFilter.regular,
          onTap: () => provider.setFilter(CustomerFilter.regular),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _StatCard(
          icon: Icons.person_add_alt_1,
          label: pickTr(language, tk: 'Täze', ru: 'Новые', en: 'New'),
          value: provider.newCount,
          color: _statusColor(CustomerStatus.newClient, context.appTokens),
          selected: provider.filter == CustomerFilter.newClient,
          onTap: () => provider.setFilter(CustomerFilter.newClient),
        ),
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withValues(alpha: .45) : tokens.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon, color: color, size: 12),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
