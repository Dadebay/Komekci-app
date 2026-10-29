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
