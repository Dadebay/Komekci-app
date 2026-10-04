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
  static const _controlsHeight = 194.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final provider = context.watch<CustomerProvider>();
    final results = provider.visible;
    final canPop = Navigator.of(context).canPop();
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: tk ? 'Müşderiler' : 'Клиенты',
        action: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconActionButton(
            icon: Icons.add,
            filled: true,
            onTap: () =>
                Navigator.push(context, pageRoute(const CustomerFormScreen())),
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
                        tk: tk,
                        onFilterTap: () => _openFilterSheet(
                          context,
                          tk: tk,
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
                          title: tk
                              ? 'Müşderi tapylmady'
                              : 'Клиенты не найдены',
                          text: tk
                              ? 'Gözlegi ýa-da süzgüçi üýtgediň.'
                              : 'Измените поиск или фильтр.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, canPop ? 16 : 14),
                      sliver: SliverList.builder(
                        itemCount: results.length,
                        itemBuilder: (_, index) =>
                            _CustomerCard(customer: results[index], tk: tk),
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
    required bool tk,
    required CustomerProvider provider,
  }) {
    final tokens = context.appTokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surfaceElevated,
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
                tk ? 'Süzgüç' : 'Фильтр',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...[
                (CustomerFilter.all, tk ? 'Ähli' : 'Все', Icons.people_outline),
                (CustomerFilter.vip, 'VIP', Icons.emoji_events_outlined),
                (
                  CustomerFilter.regular,
                  tk ? 'Hemişelik' : 'Постоянные',
                  Icons.star_border,
                ),
                (
                  CustomerFilter.newClient,
                  tk ? 'Täze' : 'Новые',
                  Icons.person_add_alt_1,
                ),
                (
                  CustomerFilter.inactive,
                  tk ? 'Uzak wagt gelmedi' : 'Давно не приходили',
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

/// Search field, filter chips and the 1×4 stat row — everything that floats
/// away while scrolling the customer list.
class _CustomerControls extends StatelessWidget {
  const _CustomerControls({
    required this.searchController,
    required this.provider,
    required this.tk,
    required this.onFilterTap,
  });
  final TextEditingController searchController;
  final CustomerProvider provider;
  final bool tk;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) => Container(
    color: context.appTokens.surface,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: _SearchField(
                  controller: searchController,
                  hint: tk ? 'Müşderi gözlemek' : 'Поиск клиента',
                  onChanged: provider.setQuery,
                ),
              ),
              const SizedBox(width: 10),
              IconActionButton(icon: Icons.filter_list, onTap: onFilterTap),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChip(
                label: tk ? 'Ähli' : 'Все',
                selected: provider.filter == CustomerFilter.all,
                onTap: () => provider.setFilter(CustomerFilter.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.emoji_events_outlined,
                label: 'VIP',
                selected: provider.filter == CustomerFilter.vip,
                onTap: () => provider.setFilter(CustomerFilter.vip),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.star_border,
                label: tk ? 'Hemişelik' : 'Постоянные',
                selected: provider.filter == CustomerFilter.regular,
                onTap: () => provider.setFilter(CustomerFilter.regular),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.person_add_alt_1,
                label: tk ? 'Täze' : 'Новые',
                selected: provider.filter == CustomerFilter.newClient,
                onTap: () => provider.setFilter(CustomerFilter.newClient),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.history,
                label: tk ? 'Uzak wagt gelmedi' : 'Давно не приходили',
                selected: provider.filter == CustomerFilter.inactive,
                onTap: () => provider.setFilter(CustomerFilter.inactive),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _StatGrid(provider: provider, tk: tk),
        ),
        const SizedBox(height: 14),
      ],
    ),
  );
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.provider, required this.tk});
  final CustomerProvider provider;
  final bool tk;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _StatCard(
          icon: Icons.people_outline,
          label: tk ? 'Ähli' : 'Все',
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
          color: _statusColor(CustomerStatus.vip),
          selected: provider.filter == CustomerFilter.vip,
          onTap: () => provider.setFilter(CustomerFilter.vip),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _StatCard(
          icon: Icons.star_border,
          label: tk ? 'Hemişelik' : 'Постоянные',
          value: provider.regularCount,
          color: _statusColor(CustomerStatus.regular),
          selected: provider.filter == CustomerFilter.regular,
          onTap: () => provider.setFilter(CustomerFilter.regular),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _StatCard(
          icon: Icons.person_add_alt_1,
          label: tk ? 'Täze' : 'Новые',
          value: provider.newCount,
          color: _statusColor(CustomerStatus.newClient),
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
          color: tokens.surfaceElevated,
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

