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
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final canPop = _canPop;
    final provider = context.watch<ClientBookingsProvider>();
    final allBookings = provider.bookings;
    final masters = allBookings.map((b) => b.masterName).toSet().toList()..sort();

    final filtered = allBookings.where((b) {
      if (_filterMaster != null && b.masterName != _filterMaster) return false;
      if (_filterStatus != null &&
          b.status != _filterStatus &&
          !(_filterStatus == ClientBookingStatus.cancelled && b.status == ClientBookingStatus.noShow)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    final visible = filtered.take(_visibleCount).toList();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Ýazgylarym', ru: 'Мои записи', en: 'My bookings'),
        action: GestureDetector(
          onTap: () => _openFilterSheet(context, language: language, masters: masters),
          child: SizedBox(
            width: 34,
            height: 34,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AppIcon(Icons.filter_list, color: _hasActiveFilter ? tokens.accent : tokens.textPrimary, size: 21),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.load,
          child: filtered.isEmpty
            ? ListView(children: [Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, canPop ? 20 : 110),
                    child: EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: t(tk: 'Ýazgy tapylmady', ru: 'Записи не найдены', en: 'No bookings found'),
                      text: t(tk: 'Süzgüçi üýtgediň.', ru: 'Измените фильтр.', en: 'Try a different filter.'),
                    ),
                  ),
                ),
              )])
            : ListView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, canPop ? 20 : 110),
                children: [
                  ...visible.map((b) => _ClientBookingCard(booking: b, tk: tk)),
                  if (visible.length < filtered.length || provider.hasMoreHistory)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 10),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: tokens.border),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () {
                          if (visible.length >= filtered.length) provider.loadMoreHistory();
                          setState(() => _visibleCount += _pageSize);
                        },
                        child: Text(
                          t(
                            tk: 'Has köp görkez',
                            ru: 'Показать ещё',
                            en: 'Show more',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context, {required AppLanguage language, required List<String> masters}) {
    final tokens = context.appTokens;
    showDialog(
      context: context,
      barrierColor: tokens.scrim,
      // StatefulBuilder gives the dialog its own setState so tapping a chip
      // repaints it as selected immediately, while still writing into the
      // parent's state (via the outer setState) so the list behind it updates too.
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
          void select(VoidCallback change) {
            setState(change);
            setDialogState(() {});
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(26)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t(tk: 'Süzgüç', ru: 'Фильтр', en: 'Filter'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: AppIcon(Icons.close, size: 18, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(tk: 'Master', ru: 'Мастер', en: 'Master'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChipButton(
                                label: t(tk: 'Ähli', ru: 'Все', en: 'All'),
                                selected: _filterMaster == null,
                                onTap: () => select(() {
                                  _filterMaster = null;
                                  _visibleCount = _pageSize;
                                }),
                              ),
                              ...masters.map(
                                (m) => _FilterChipButton(
                                  label: m,
                                  selected: _filterMaster == m,
                                  onTap: () => select(() {
                                    _filterMaster = m;
                                    _visibleCount = _pageSize;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            t(tk: 'Ýagdaý', ru: 'Статус', en: 'Status'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChipButton(
                                label: t(tk: 'Ähli', ru: 'Все', en: 'All'),
                                selected: _filterStatus == null,
                                onTap: () => select(() {
                                  _filterStatus = null;
                                  _visibleCount = _pageSize;
                                }),
                              ),
                              _FilterChipButton(
                                label: t(tk: 'Tassyklanan', ru: 'Подтверждено', en: 'Confirmed'),
                                selected: _filterStatus == ClientBookingStatus.expected,
                                onTap: () => select(() {
                                  _filterStatus = ClientBookingStatus.expected;
                                  _visibleCount = _pageSize;
                                }),
                              ),
                              _FilterChipButton(
                                label: t(tk: 'Tamamlandy', ru: 'Завершено', en: 'Completed'),
                                selected: _filterStatus == ClientBookingStatus.completed,
                                onTap: () => select(() {
                                  _filterStatus = ClientBookingStatus.completed;
                                  _visibleCount = _pageSize;
                                }),
                              ),
                              _FilterChipButton(
                                label: t(tk: 'Ýatyryldy', ru: 'Отменено', en: 'Cancelled'),
                                selected: _filterStatus == ClientBookingStatus.cancelled,
                                onTap: () => select(() {
                                  _filterStatus = ClientBookingStatus.cancelled;
                                  _visibleCount = _pageSize;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: tokens.border),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () => select(() {
                              _filterMaster = null;
                              _filterStatus = null;
                              _visibleCount = _pageSize;
                            }),
                            child: Text(
                              t(tk: 'Arassala', ru: 'Сбросить', en: 'Clear'),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              t(tk: 'Ulan', ru: 'Применить', en: 'Apply'),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.surface),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.label, required this.selected, required this.onTap});
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
          border: Border.all(color: selected ? tokens.textPrimary : tokens.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? tokens.surface : tokens.textPrimary),
        ),
      ),
    );
  }
}
