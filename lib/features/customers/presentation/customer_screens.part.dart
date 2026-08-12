part of '../../../app/komekci_app.dart';

Color _statusColor(CustomerStatus status) => switch (status) {
  CustomerStatus.vip => const Color(0xff9C6B14),
  CustomerStatus.regular => const Color(0xff2F7D4F),
  CustomerStatus.newClient => const Color(0xff2A5DB0),
};

Color _statusBg(CustomerStatus status) => switch (status) {
  CustomerStatus.vip => const Color(0xffFBF1D8),
  CustomerStatus.regular => const Color(0xffE3F3E7),
  CustomerStatus.newClient => const Color(0xffE6EEFB),
};

IconData _statusIcon(CustomerStatus status) => switch (status) {
  CustomerStatus.vip => Icons.emoji_events_outlined,
  CustomerStatus.regular => Icons.star_border,
  CustomerStatus.newClient => Icons.person_add_alt_1,
};

String _statusLabel(CustomerStatus status, bool tk) => switch (status) {
  CustomerStatus.vip => 'VIP',
  CustomerStatus.regular => tk ? 'Hemişelik' : 'Постоянный',
  CustomerStatus.newClient => tk ? 'Täze' : 'Новый',
};

/// Shared "are you sure" dialog: icon badge, centred copy, a cancel outline
/// button and a filled confirm button. Used for every destructive or
/// meaningful confirmation across the app instead of a bare [AlertDialog].
Future<bool> _showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .45),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger
                    ? const Color(0xffFDF0EE)
                    : const Color(0xffFBF1D8),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                icon,
                size: 25,
                color: danger ? const Color(0xffC0392B) : gold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black54,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(
                        cancelLabel,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: danger ? const Color(0xffC0392B) : ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Shared single-action info dialog (success / done states) matching
/// [_showConfirmDialog]'s look.
Future<void> _showInfoDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String actionLabel,
}) => showDialog<void>(
  context: context,
  barrierColor: Colors.black.withValues(alpha: .45),
  builder: (dialogContext) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 30),
    child: Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xffDCF3E3),
              shape: BoxShape.circle,
            ),
            child: AppIcon(icon, size: 25, color: const Color(0xff1F8A4C)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.black54,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

/// Shows the customer's picked photo when set, otherwise the generic
/// person-outline placeholder used across the app.
class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.customer, this.radius = 24});
  final Customer customer;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xffE6D2B1),
    backgroundImage: customer.photoPath.isEmpty
        ? null
        : FileImage(File(customer.photoPath)),
    child: customer.photoPath.isEmpty
        ? AppIcon(Icons.person_outline, size: radius * .75, color: ink)
        : null,
  );
}

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Müşderiler' : 'Клиенты',
        action: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _CustomerIconButton(
            icon: Icons.add,
            filled: true,
            onTap: () =>
                Navigator.push(context, _pageRoute(const CustomerFormScreen())),
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
                        child: _EmptyState(
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                  leading: AppIcon(item.$3, size: 19, color: ink),
                  title: Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: provider.filter == item.$1
                      ? const AppIcon(Icons.check, color: gold)
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
    color: Colors.white,
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
              _CustomerIconButton(icon: Icons.filter_list, onTap: onFilterTap),
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
          color: ink,
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? color.withValues(alpha: .45) : line,
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
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black54,
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? ink : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? ink : line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: 14, color: selected ? Colors.white : ink),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : ink,
            ),
          ),
        ],
      ),
    ),
  );
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
      color: cream,
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

class _CustomerIconButton extends StatelessWidget {
  const _CustomerIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? ink : cream,
        shape: BoxShape.circle,
        border: filled ? null : Border.all(color: line),
      ),
      child: AppIcon(icon, color: filled ? Colors.white : ink, size: 19),
    ),
  );
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.tk});
  final Customer customer;
  final bool tk;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(
      context,
      _pageRoute(CustomerDetailScreen(customerId: customer.id)),
    ),
    borderRadius: BorderRadius.circular(17),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: line),
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
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
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
                              : _formatDate(customer.lastVisitDate!),
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
          const AppIcon(Icons.chevron_right, color: Colors.black26, size: 18),
        ],
      ),
    ),
  );
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

Future<CustomerStatus?> _pickCustomerStatus(
  BuildContext context, {
  required bool tk,
  required CustomerStatus current,
}) => showModalBottomSheet<CustomerStatus>(
  context: context,
  backgroundColor: Colors.white,
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
            tk ? 'Statusy üýtgetmek' : 'Изменить статус',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...CustomerStatus.values.map(
            (status) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  _statusIcon(status),
                  size: 16,
                  color: _statusColor(status),
                ),
              ),
              title: Text(
                '${_statusLabel(status, tk)} ${tk ? "müşderi" : "клиент"}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: status == current
                  ? const AppIcon(Icons.check_circle, color: gold, size: 20)
                  : const AppIcon(
                      Icons.circle_outlined,
                      color: Colors.black26,
                      size: 20,
                    ),
              onTap: () => Navigator.pop(sheetContext, status),
            ),
          ),
        ],
      ),
    ),
  ),
);

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final provider = context.watch<CustomerProvider>();
    final customer = _findCustomer(provider.customers, customerId);
    if (customer == null) {
      Future.microtask(() {
        if (context.mounted) Navigator.maybePop(context);
      });
      return const SizedBox.shrink();
    }
    final recentVisits = customer.visits.take(4).toList();

    final statusColor = _statusColor(customer.status);

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      appBar: CabinetAppBar(
        title: tk ? 'Müşderi maglumatlary' : 'Информация о клиенте',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_statusBg(customer.status), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: line),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: statusColor,
                                  width: 2,
                                ),
                              ),
                              child: _CustomerAvatar(
                                customer: customer,
                                radius: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const AppIcon(
                                        Icons.phone_outlined,
                                        size: 12,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer.phone,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await _pickCustomerStatus(
                                        context,
                                        tk: tk,
                                        current: customer.status,
                                      );
                                      if (picked != null &&
                                          picked != customer.status &&
                                          context.mounted) {
                                        context
                                            .read<CustomerProvider>()
                                            .updateStatus(customer.id, picked);
                                      }
                                    },
                                    child: _StatusPill(
                                      status: customer.status,
                                      tk: tk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _SquareIconButton(
                              icon: Icons.edit_outlined,
                              onTap: () => Navigator.push(
                                context,
                                _pageRoute(
                                  CustomerFormScreen(customer: customer),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: .7),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _HeaderStat(
                                value: '${customer.totalVisits}',
                                label: tk ? 'Sapar' : 'Визитов',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withValues(alpha: .7),
                            ),
                            Expanded(
                              child: _HeaderStat(
                                value: '${customer.totalSpent}',
                                label: tk ? 'Manat' : 'Манат',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withValues(alpha: .7),
                            ),
                            Expanded(
                              child: _HeaderStat(
                                value: customer.lastVisitDate == null
                                    ? '—'
                                    : _formatDate(customer.lastVisitDate!),
                                label: tk ? 'Şodny gelişi' : 'Визит',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.content_cut,
                          accent: gold,
                          label: tk ? 'Şodny hyzmat' : 'Последняя услуга',
                          value: customer.lastVisit == null
                              ? '—'
                              : customer.lastVisit!.serviceName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.calendar_month_outlined,
                          accent: _statusColor(CustomerStatus.newClient),
                          label: tk ? 'Indiki ýazgy' : 'Следующая запись',
                          value: customer.nextVisit == null
                              ? (tk ? 'Ýok' : 'Нет')
                              : '${_formatDate(customer.nextVisit!)} • ${_formatTime(TimeOfDay.fromDateTime(customer.nextVisit!))}',
                          chevron: true,
                          onTap: () => Navigator.push(
                            context,
                            _pageRoute(
                              NewAppointmentScreen(customer: customer),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (customer.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xffFAF7F0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 34,
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: .5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tk ? 'Bellik' : 'Заметка',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  customer.note,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tk ? 'Sapar taryhy' : 'История визитов',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (customer.visits.length > recentVisits.length)
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            _pageRoute(
                              CustomerVisitsScreen(customerId: customer.id),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                tk ? 'Ählisini görmek' : 'Смотреть все',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const AppIcon(
                                Icons.chevron_right,
                                size: 14,
                                color: gold,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (recentVisits.isEmpty)
                    _EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: tk ? 'Sapar ýok' : 'Визитов пока нет',
                      text: tk
                          ? 'Bu müşderi entek gelen däldir.'
                          : 'Клиент ещё не приходил.',
                    )
                  else
                    ...recentVisits.map(
                      (visit) => _VisitRow(visit: visit, tk: tk),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _OutlineActionButton(
                      icon: Icons.phone_outlined,
                      label: tk ? 'Habarlaşmak' : 'Связаться',
                      onTap: () => launchUrl(
                        Uri(
                          scheme: 'tel',
                          path: customer.phone.replaceAll(' ', ''),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MasterActionButton(
                      label: tk ? 'Täze ýazgy etmek' : 'Новая запись',
                      enabled: true,
                      leading: Icons.calendar_month_outlined,
                      onTap: () => Navigator.push(
                        context,
                        _pageRoute(NewAppointmentScreen(customer: customer)),
                      ),
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
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = Colors.black45,
    this.chevron = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(icon, size: 12, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chevron)
                const AppIcon(
                  Icons.chevron_right,
                  size: 14,
                  color: Colors.black26,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.tk});
  final CustomerVisit visit;
  final bool tk;

  static const _monthsTk = [
    'Ýan',
    'Few',
    'Mart',
    'Apr',
    'Maý',
    'Iýun',
    'Iýul',
    'Awg',
    'Sen',
    'Okt',
    'Noý',
    'Dek',
  ];
  static const _monthsRu = [
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: line),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                visit.date.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: ink,
                ),
              ),
              Text(
                (tk ? _monthsTk : _monthsRu)[visit.date.month - 1],
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.serviceName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatTime(TimeOfDay.fromDateTime(visit.date)),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        Text(
          '${visit.price} ${tk ? "manat" : "манат"}',
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, size: 17, color: ink),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
        ],
      ),
    ),
  );
}

class CustomerVisitsScreen extends StatelessWidget {
  const CustomerVisitsScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final customer = _findCustomer(
      context.watch<CustomerProvider>().customers,
      customerId,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(title: tk ? 'Sapar taryhy' : 'История визитов'),
      body: SafeArea(
        child: customer == null
            ? const SizedBox.shrink()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: customer.visits.length,
                itemBuilder: (_, index) =>
                    _VisitRow(visit: customer.visits[index], tk: tk),
              ),
      ),
    );
  }
}

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  /// Null when adding, populated when editing an existing customer.
  final Customer? customer;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  late final _nameController = TextEditingController(
    text: widget.customer?.name ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.customer?.phone ?? '',
  );
  late final _nicknameController = TextEditingController(
    text: widget.customer?.nickname ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.customer?.note ?? '',
  );
  late CustomerStatus _status =
      widget.customer?.status ?? CustomerStatus.newClient;
  File? _photo;
  bool _showErrors = false;

  bool get _isEditing => widget.customer != null;
  bool get _nameOk => _nameController.text.trim().isNotEmpty;
  bool get _phoneOk => _phoneController.text.trim().length >= 8;
  bool get _complete => _nameOk && _phoneOk;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    final provider = context.read<CustomerProvider>();
    final photoPath = _photo?.path ?? widget.customer?.photoPath ?? '';
    if (_isEditing) {
      provider.update(
        widget.customer!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          nickname: _nicknameController.text.trim(),
          status: _status,
          note: _noteController.text.trim(),
          photoPath: photoPath,
        ),
      );
    } else {
      provider.add(
        Customer(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          nickname: _nicknameController.text.trim(),
          status: _status,
          note: _noteController.text.trim(),
          photoPath: photoPath,
        ),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final provider = context.read<CustomerProvider>();
    final customer = widget.customer!;
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      danger: true,
      title: tk ? 'Müşderini pozmaly?' : 'Удалить клиента?',
      message: tk
          ? '"${customer.name}" sanawdan aýrylar. Bu hereketi yzyna gaýtaryp bolmaýar.'
          : '«${customer.name}» будет удалён из списка без возможности восстановления.',
      confirmLabel: tk ? 'Poz' : 'Удалить',
      cancelLabel: tk ? 'Ýatyr' : 'Отмена',
    );
    if (confirmed && mounted) {
      provider.remove(customer.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: _isEditing
            ? (tk ? 'Müşderini üýtget' : 'Изменить клиента')
            : (tk ? 'Müşderi goşmak' : 'Добавить клиента'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _FormBanner(
                    title: tk
                        ? 'Täze müşderi goşuň.'
                        : 'Добавьте нового клиента.',
                    subtitle: tk
                        ? 'Esasy maglumatlary dolduryň.'
                        : 'Заполните основные данные.',
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Column(
                      children: [
                        AvatarPicker(
                          file: _photo,
                          radius: 46,
                          fallback:
                              !_isEditing ||
                                  (widget.customer?.photoPath ?? '').isEmpty
                              ? null
                              : FileImage(File(widget.customer!.photoPath)),
                          onPicked: (f) => setState(() => _photo = f),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tk
                              ? 'Surat goşmak (islege görä)'
                              : 'Добавить фото (необязательно)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(text: tk ? 'Ady' : 'Имя', required: true),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: tk ? 'Müşderiniň adyny ýazyň' : 'Введите имя клиента',
                    invalid: _showErrors && !_nameOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel(
                    text: tk ? 'Telefon belgisi' : 'Номер телефона',
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _phoneController,
                    hint: '+993 .. ... .. ..',
                    keyboardType: TextInputType.phone,
                    invalid: _showErrors && !_phoneOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        tk ? 'Lakamy (Nickname)' : 'Никнейм',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: tk
                            ? 'Müşderiniň Instagram ýa-da başga ulgamdaky lakamy. Islege görä.'
                            : 'Никнейм клиента в Instagram или другой сети. Необязательно.',
                        child: const AppIcon(
                          Icons.help_outline,
                          size: 14,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nicknameController,
                    hint: tk
                        ? 'Müşderiniň lakamyny ýazyň (islege görä)'
                        : 'Введите никнейм клиента (необязательно)',
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(text: tk ? 'Status' : 'Статус', required: true),
                  const SizedBox(height: 10),
                  Row(
                    children: CustomerStatus.values
                        .map(
                          (status) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: status == CustomerStatus.values.last
                                    ? 0
                                    : 8,
                              ),
                              child: _StatusOptionCard(
                                status: status,
                                tk: tk,
                                selected: _status == status,
                                onTap: () => setState(() => _status = status),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: tk ? 'Bellik' : 'Заметка',
                    optionalLabel: tk ? '(islege görä)' : '(необязательно)',
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _noteController,
                    hint: tk
                        ? 'Müşderi barada bellik goşuň...'
                        : 'Добавьте заметку о клиенте...',
                    maxLines: 4,
                    maxLength: 200,
                    onChanged: () => setState(() {}),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: _confirmDelete,
                        child: Text(
                          tk ? 'Müşderini poz' : 'Удалить клиента',
                          style: const TextStyle(
                            color: Color(0xffC0392B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                children: [
                  _MasterActionButton(
                    label: tk ? 'Ýatda sakla' : 'Сохранить',
                    enabled: _complete,
                    leading: Icons.save_outlined,
                    onTap: _save,
                  ),
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      tk ? 'Ýatyrmazdan yzyna dön' : 'Вернуться без сохранения',
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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
}

class _FormBanner extends StatelessWidget {
  const _FormBanner({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xffEEF0FB),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const AppIcon(
            Icons.info_outline,
            size: 15,
            color: Color(0xff5B5FC7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusOptionCard extends StatelessWidget {
  const _StatusOptionCard({
    required this.status,
    required this.tk,
    required this.selected,
    required this.onTap,
  });
  final CustomerStatus status;
  final bool tk;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: .06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : line,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  _statusIcon(status),
                  size: 20,
                  color: selected ? color : Colors.black45,
                ),
                const SizedBox(height: 6),
                Text(
                  _statusLabel(status, tk),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : ink,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const AppIcon(
                  Icons.check,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Books a new appointment for [customer] — picks a service from the real
/// catalogue, a date and a time, then records it and updates the customer's
/// next-visit date.
class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key, required this.customer});
  final Customer customer;

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  int? _serviceIndex;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _showErrors = false;

  Future<void> _pickDateTime() async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final picked = await _pickAppointmentDateTime(
      context,
      tk: tk,
      initial: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _time = TimeOfDay.fromDateTime(picked);
      });
    }
  }

  void _confirm(List<SalonService> services) {
    if (_serviceIndex == null) {
      setState(() => _showErrors = true);
      return;
    }
    final tk = context.read<LanguageProvider>().isTurkmen;
    final service = services[_serviceIndex!];
    final startsAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    context.read<BookingProvider>().create(
      service: service.name,
      startsAt: startsAt,
      price: service.price.toDouble(),
      clientName: widget.customer.name,
      customerId: widget.customer.id,
    );
    context.read<CustomerProvider>().update(
      widget.customer.copyWith(nextVisit: startsAt),
    );
    _finish(tk, service, startsAt);
  }

  Future<void> _finish(bool tk, SalonService service, DateTime startsAt) async {
    await _showInfoDialog(
      context,
      icon: Icons.check,
      title: tk ? 'Ýazgy döredildi' : 'Запись создана',
      message:
          '${widget.customer.name} — ${service.name}\n${_formatDate(startsAt)} • ${_formatTime(TimeOfDay.fromDateTime(startsAt))}',
      actionLabel: tk ? 'Bolýar' : 'Готово',
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final services = context.watch<ServiceProvider>().services;
    final selected = _serviceIndex != null && _serviceIndex! < services.length
        ? services[_serviceIndex!]
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(title: tk ? 'Täze ýazgy' : 'Новая запись'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _CustomerAvatar(customer: widget.customer, radius: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customer.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                widget.customer.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _FieldLabel(
                    text: tk ? 'Hyzmat saýlaň' : 'Выберите услугу',
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  if (services.isEmpty)
                    _EmptyState(
                      icon: Icons.content_cut,
                      title: tk ? 'Hyzmat ýok' : 'Услуг нет',
                      text: tk
                          ? 'Ilki bilen hyzmat goşuň.'
                          : 'Сначала добавьте услугу.',
                    )
                  else
                    ...services.asMap().entries.map((entry) {
                      final rowSelected = _serviceIndex == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _serviceIndex = entry.key;
                          _showErrors = false;
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: rowSelected
                                ? gold.withValues(alpha: .08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: rowSelected ? gold : line,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.value.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value.price} ${tk ? "manat" : "манат"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (rowSelected)
                                const AppIcon(
                                  Icons.check_circle,
                                  color: gold,
                                  size: 19,
                                )
                              else
                                const SizedBox(width: 19),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (_showErrors && _serviceIndex == null) _ErrorText(tk: tk),
                  const SizedBox(height: 22),
                  _PickerField(
                    label: tk ? 'Sene we wagt' : 'Дата и время',
                    value: '${_formatDate(_date)} • ${_formatTime(_time)}',
                    icon: Icons.calendar_month_outlined,
                    onTap: _pickDateTime,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: tk ? 'Ýazgyny tassykla' : 'Подтвердить запись',
                enabled: selected != null,
                leading: Icons.check,
                onTap: () => _confirm(services),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
