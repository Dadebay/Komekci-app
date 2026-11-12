part of '../../../app/komekci_app.dart';

/// Full booking list — the destination for "Ähli ýazgylar" and the
/// "Ýazgylarym" bottom-nav tab. Filterable by master and status, newest
/// first, loaded 20 at a time.
class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
  static const _pageSize = 20;

  String? _filterMaster;
  ClientBookingStatus? _filterStatus;
  bool _showPast = false;
  int _visibleCount = _pageSize;

  // Read once at mount instead of on every build: the filter dialog's chip
  // taps call this screen's own setState while the dialog is still open,
  // which would otherwise re-evaluate canPop() while a modal route sits on
  // top of us and briefly (and wrongly) show a back button in the app bar.
  late final bool _canPop = Navigator.of(context).canPop();

  bool get _hasActiveFilter => _filterMaster != null || _filterStatus != null;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    final tokens = context.appTokens;
    final canPop = _canPop;
    final provider = context.watch<ClientBookingsProvider>();
    final allBookings = provider.bookings;
    final masters = allBookings.map((b) => b.masterName).toSet().toList()
      ..sort();

    final upcomingAll = allBookings.where((b) => b.isUpcoming).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final pastCount = allBookings.length - upcomingAll.length;

    final filtered =
        allBookings.where((b) {
            final isUpcoming = b.isUpcoming;
            if (isUpcoming == _showPast) return false;
            if (_filterMaster != null && b.masterName != _filterMaster) {
              return false;
            }
            if (_filterStatus != null &&
                b.status != _filterStatus &&
                !(_filterStatus == ClientBookingStatus.cancelled &&
                    b.status == ClientBookingStatus.noShow)) {
              return false;
            }
            return true;
          }).toList()
          // Next appointment first; history newest first.
          ..sort(
            (a, b) => _showPast
                ? b.startsAt.compareTo(a.startsAt)
                : a.startsAt.compareTo(b.startsAt),
          );
    final visible = filtered.take(_visibleCount).toList();
    final showHero = !_showPast && visible.isNotEmpty && _filterMaster == null;

    Widget tabButton(String label, int count, bool past) {
      final selected = _showPast == past;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _showPast = past;
            _filterStatus = null;
            _visibleCount = _pageSize;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? tokens.textPrimary : tokens.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? tokens.textPrimary
                    : tokens.border.withValues(alpha: .7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? tokens.surface : tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? tokens.surface.withValues(alpha: .2)
                        : tokens.accent.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected ? tokens.surface : tokens.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.homeMyBookings.select(language),
        action: GestureDetector(
          onTap: () =>
              _openFilterSheet(context, language: language, masters: masters),
          child: SizedBox(
            width: 34,
            height: 34,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AppIcon(
                Icons.filter_list,
                color: _hasActiveFilter ? tokens.accent : tokens.textPrimary,
                size: 21,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  tabButton(
                    AppStrings.homeUpcoming.select(language),
                    upcomingAll.length,
                    false,
                  ),
                  const SizedBox(width: 10),
                  tabButton(
                    AppStrings.homePast.select(language),
                    pastCount,
                    true,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.load,
                child: filtered.isEmpty
                    ? ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              10,
                              20,
                              canPop ? 20 : 110,
                            ),
                            child: EmptyState(
                              icon: Icons.event_busy_outlined,
                              title: _hasActiveFilter
                                  ? AppStrings.homeNoBookingsFound.select(
                                      language,
                                    )
                                  : _showPast
                                  ? AppStrings.homeNoPastBookings.select(
                                      language,
                                    )
                                  : AppStrings.homeNoUpcomingBookings.select(
                                      language,
                                    ),
                              text: _hasActiveFilter
                                  ? AppStrings.homeTryADifferentFilter.select(
                                      language,
                                    )
                                  : _showPast
                                  ? AppStrings.homeFinishedBookingsShowUpHere
                                        .select(language)
                                  : AppStrings.homeChooseAMasterAndBook.select(
                                      language,
                                    ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          canPop ? 20 : 110,
                        ),
                        children: [
                          if (showHero) ...[
                            _NextBookingHero(
                              booking: visible.first,
                              language: language,
                            ),
                            if (visible.length > 1) ...[
                              const SizedBox(height: 22),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: tokens.accent,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.homeMoreBookings.select(
                                        language,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                          ...visible
                              .skip(showHero ? 1 : 0)
                              .map(
                                (b) => _ClientBookingCard(booking: b, tk: tk),
                              ),
                          if (visible.length < filtered.length ||
                              (_showPast && provider.hasMoreHistory))
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 10,
                              ),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: tokens.border),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () {
                                  if (visible.length >= filtered.length) {
                                    provider.loadMoreHistory();
                                  }
                                  setState(() => _visibleCount += _pageSize);
                                },
                                child: Text(
                                  AppStrings.homeShowMore.select(language),
                                ),
                              ),
                            ),
                        ],
                      ),
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
    required List<String> masters,
  }) => _showFilterSheet(
    context,
    language: language,
    masters: masters,
    update: setState,
  );
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tokens.textPrimary : tokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? tokens.textPrimary : tokens.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? tokens.surface : tokens.textPrimary,
          ),
        ),
      ),
    );
  }
}
