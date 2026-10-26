part of '../../../app/komekci_app.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();

  /// Matches the rendered height of [_CustomerControls] so the collapsing
  /// sliver header knows how far it can slide away.
  static const _controlsHeight = 138.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.watch<CustomerProvider>();
    final results = provider.visible;
    final canPop = Navigator.of(context).canPop();
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Müşderiler', ru: 'Клиенты', en: 'Customers'),
        action: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () =>
                Navigator.push(context, pageRoute(const CustomerFormScreen())),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surface,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.textPrimary, width: 1.2),
              ),
              child: AppIcon(Icons.add, color: tokens.textPrimary, size: 17),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    floating: true,
                    delegate: _ControlsHeaderDelegate(
                      height: _controlsHeight,
                      vsync: this,
                      child: _CustomerControls(
                        searchController: _searchController,
                        provider: provider,
                        language: language,
                        onFilterTap: () => _openFilterSheet(
                          context,
                          language: language,
                          provider: provider,
                        ),
                      ),
                    ),
                  ),
                  if (results.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: EmptyState(
                          icon: Icons.people_outline,
                          backgroundColor: tokens.surface,
                          title: t(tk: 'Müşderi tapylmady', ru: 'Клиенты не найдены', en: 'No customers found'),
                          text: t(tk: 'Gözlegi ýa-da süzgüçi üýtgediň.', ru: 'Измените поиск или фильтр.', en: 'Try a different search or filter.'),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      // Clears the floating bottom nav bar when this is a tab root.
                      padding: EdgeInsets.fromLTRB(20, 4, 20, canPop ? 16 : 110),
                      sliver: SliverList.builder(
                        itemCount: results.length,
                        itemBuilder: (_, index) =>
                            _CustomerCard(customer: results[index], language: language),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(
    BuildContext context, {
    required AppLanguage language,
    required CustomerProvider provider,
  }) {
    final tokens = context.appTokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickTr(language, tk: 'Süzgüç', ru: 'Фильтр', en: 'Filter'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...[
                (CustomerFilter.all, pickTr(language, tk: 'Ähli', ru: 'Все', en: 'All'), Icons.people_outline),
                (CustomerFilter.vip, 'VIP', Icons.emoji_events_outlined),
                (
                  CustomerFilter.regular,
                  pickTr(language, tk: 'Hemişelik', ru: 'Постоянные', en: 'Regular'),
                  Icons.star_border,
                ),
                (
                  CustomerFilter.newClient,
                  pickTr(language, tk: 'Täze', ru: 'Новые', en: 'New'),
                  Icons.person_add_alt_1,
                ),
                (
                  CustomerFilter.inactive,
                  pickTr(language, tk: 'Uzak wagt gelmedi', ru: 'Давно не приходили', en: 'Inactive'),
                  Icons.history,
                ),
              ].map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AppIcon(
                    item.$3,
                    size: 19,
                    color: tokens.textPrimary,
                  ),
                  title: Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: provider.filter == item.$1
                      ? AppIcon(Icons.check, color: tokens.accent)
                      : null,
                  onTap: () {
                    provider.setFilter(item.$1);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pins [child] at a fixed [height] and lets it float away as the list below
/// scrolls up, sliding straight back the moment the user scrolls down again.
class _ControlsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ControlsHeaderDelegate({
    required this.height,
    required this.child,
    required this.vsync,
  });
  final double height;
  final Widget child;

  @override
  final TickerProvider vsync;

  @override
  double get minExtent => 0;
  @override
  double get maxExtent => height;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      FloatingHeaderSnapConfiguration(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ClipRect(
    child: OverflowBox(
      minHeight: height,
      maxHeight: height,
      alignment: Alignment.topCenter,
      child: child,
    ),
  );

  @override
  bool shouldRebuild(covariant _ControlsHeaderDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

/// Search field, filter button and the 1×4 stat row — everything that
/// floats away while scrolling the customer list.
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
