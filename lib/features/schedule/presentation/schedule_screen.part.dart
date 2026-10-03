part of '../../../app/komekci_app.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.initialDate});

  /// Deep-links the timeline to a specific day, e.g. tapped from the home
  /// dashboard's day list. Defaults to the seeded "today" when omitted.
  final DateTime? initialDate;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selected = widget.initialDate ?? appToday();
  late DateTime _weekStart = _startOfWeek(_selected);
  late DateTime _visibleMonth = DateTime(_selected.year, _selected.month);
  bool _showMonth = false;
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _select(DateTime date) {
    setState(() {
      _selected = date;
      _weekStart = _startOfWeek(date);
      _visibleMonth = DateTime(date.year, date.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final bookingProvider = context.watch<BookingProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final canPop = Navigator.of(context).canPop();
    bookingProvider
      ..prefetch(_selected)
      ..prefetch(_visibleMonth)
      ..prefetch(_weekStart.add(const Duration(days: 6)));

    final dayAppointments = bookingProvider.onDay(_selected);
    final query = _searchController.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? dayAppointments
        : dayAppointments
              .where(
                (a) =>
                    a.clientName.toLowerCase().contains(query) ||
                    a.serviceName.toLowerCase().contains(query),
              )
              .toList();
    final entries = _buildTimeline(visible, _selected);

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Senenama', ru: 'Расписание', en: 'Schedule'),
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_sameDay(_selected, appToday()))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => _select(appToday()),
                  child: Text(t(tk: 'Bugün', ru: 'Сегодня', en: 'Today')),
                ),
              ),
            IconActionButton(
              icon: Icons.grid_view_outlined,
              onTap: () => Navigator.push(
                context,
                pageRoute(
                  WeekOverviewScreen(
                    weekStart: _weekStart,
                    onSelectDay: _select,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconActionButton(
              icon: Icons.search,
              onTap: () => setState(() => _searching = !_searching),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 10, 20, canPop ? 20 : 100),
          children: [
            if (_searching) ...[
              _SearchField(
                controller: _searchController,
                hint: t(
                  tk: 'Müşderi ýa-da hyzmat gözle',
                  ru: 'Поиск клиента или услуги',
                  en: 'Search customer or service',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
            ],
            _WeekStrip(
              weekStart: _weekStart,
              selected: _selected,
              language: language,
              onSelect: _select,
              onPrevWeek: () => setState(
                () => _weekStart = _weekStart.subtract(const Duration(days: 7)),
              ),
              onNextWeek: () => setState(
                () => _weekStart = _weekStart.add(const Duration(days: 7)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _showMonth = !_showMonth),
                child: Container(
                  width: 40,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: AppIcon(
                    _showMonth ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_showMonth) ...[
              _MonthCalendar(
                month: _visibleMonth,
                selected: _selected,
                language: language,
                onSelect: (date) {
                  _select(date);
                  setState(() => _showMonth = false);
                },
                onPrevMonth: () => setState(
                  () => _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  ),
                ),
                onNextMonth: () => setState(
                  () => _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const AppIcon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.black45,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selected.day} ${_byLang(language, _monthsFullTk, _monthsFullRu, _monthsFullEn)[_selected.month - 1]}, ${_selected.year} • ${_byLang(language, _weekdaysFullTk, _weekdaysFullRu, _weekdaysFullEn)[_selected.weekday - 1]}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              EmptyState(
                icon: Icons.event_busy_outlined,
                title: t(
                  tk: 'Bu gün ýazgy ýok',
                  ru: 'На этот день записей нет',
                  en: 'No bookings today',
                ),
                text: t(
                  tk: 'Boş gün — dynç alyň!',
                  ru: 'Свободный день.',
                  en: 'A free day — enjoy the rest!',
                ),
              )
            else
              ...entries.map((entry) {
                if (entry is _ApptEntry) {
                  final customer = entry.appointment.customerId == null
                      ? null
                      : _findCustomer(
                          customerProvider.customers,
                          entry.appointment.customerId!,
                        );
                  return _AppointmentRow(
                    appointment: entry.appointment,
                    customer: customer,
                    language: language,
                    onTap: () => _openAppointmentActions(
                      context,
                      entry.appointment,
                      customer,
                      language,
                    ),
                  );
                }
                final free = entry as _FreeEntry;
                return _FreeSlotRow(
                  start: free.start,
                  end: free.end,
                  language: language,
                  onTap: () => _NewSlotAppointmentSheet.show(
                    context,
                    start: free.start,
                    end: free.end,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
