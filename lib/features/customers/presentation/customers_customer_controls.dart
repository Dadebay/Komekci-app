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
                    hint: AppStrings.customersSearchCustomers.select(language),
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
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    // Pills take the width their label needs; the row scrolls sideways if
    // the four do not fit, so no label is ever cut off.
    child: ListView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _StatCard(
            icon: Icons.people_outline,
            label: AppStrings.homeAll.select(language),
            value: provider.allCount,
            color: context.appTokens.textPrimary,
            selected: provider.filter == CustomerFilter.all,
            onTap: () => provider.setFilter(CustomerFilter.all),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _StatCard(
            icon: Icons.emoji_events_outlined,
            label: 'VIP',
            value: provider.vipCount,
            color: _statusColor(CustomerStatus.vip, context.appTokens),
            selected: provider.filter == CustomerFilter.vip,
            onTap: () => provider.setFilter(CustomerFilter.vip),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _StatCard(
            icon: Icons.star_border,
            label: AppStrings.customersRegular.select(language),
            value: provider.regularCount,
            color: _statusColor(CustomerStatus.regular, context.appTokens),
            selected: provider.filter == CustomerFilter.regular,
            onTap: () => provider.setFilter(CustomerFilter.regular),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _StatCard(
            icon: Icons.person_add_alt_1,
            label: AppStrings.customersNew.select(language),
            value: provider.newCount,
            color: _statusColor(CustomerStatus.newClient, context.appTokens),
            selected: provider.filter == CustomerFilter.newClient,
            onTap: () => provider.setFilter(CustomerFilter.newClient),
          ),
        ),
      ],
    ),
  );
}

/// One status filter as a pill: icon, label and a count badge.
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        padding: const EdgeInsets.only(left: 12, right: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .14) : tokens.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected ? color.withValues(alpha: .55) : tokens.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, color: color, size: 16),
            const SizedBox(width: 7),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 26),
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color : color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? tokens.surface : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
