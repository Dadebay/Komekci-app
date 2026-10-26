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
  Timer? _availabilityTicker;

  @override
  void initState() {
    super.initState();
    _availabilityTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _availabilityTicker?.cancel();
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

  Future<void> _addWorkingHours() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final language = context.read<LanguageProvider>().language;
    final existing = scheduleProvider.overrides.any(
      (override) => _sameDay(override.date, _selected),
    );
    if (existing) {
      await Navigator.push(context, pageRoute(const SpecialDaysScreen()));
      return;
    }
    final windows = workingTimeRanges(scheduleProvider.schedule, _selected);
    final range = await _pickTimeRange(
      context,
      language: language,
      title: pickTr(
        language,
        tk: 'Şu gün üçin iş wagty',
        ru: 'Рабочие часы на этот день',
        en: 'Working hours for this day',
      ),
      start: windows.isEmpty ? '10:00' : formatTime(TimeOfDay.fromDateTime(windows.first.start)),
      end: windows.isEmpty ? '16:00' : formatTime(TimeOfDay.fromDateTime(windows.last.end)),
    );
    if (range == null || !mounted) return;
    await runApi(context, () => scheduleProvider.addCustomHours(_selected, range.$1, range.$2));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final bookingProvider = context.watch<BookingProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedule = scheduleProvider.schedule;
    final canPop = Navigator.of(context).canPop();
    bookingProvider
      ..prefetch(_selected)
      ..prefetch(_visibleMonth)
      ..prefetch(_weekStart.add(const Duration(days: 6)));
    scheduleProvider.prefetchClosedTimes(_selected);

    final monthLoaded = bookingProvider.isMonthLoaded(_selected);
    final dayAppointments = bookingProvider.onDay(_selected);
    final closedLoaded = scheduleProvider.closedTimesLoaded(_selected);
    final closedError = scheduleProvider.closedTimesError(_selected);
    final query = _searching ? _searchController.text.trim().toLowerCase() : '';
    final now = DateTime.now();
    final timeline = monthLoaded
        ? (_buildTimeline(
            dayAppointments,
            _selected,
            closedLoaded ? schedule : null,
            closedTimes: scheduleProvider.closedTimesOn(_selected),
          ).where((entry) => entry is! _FreeEntry || entry.start.isAfter(now)).toList())
        : <_TimelineEntry>[];
    final entries = query.isEmpty
        ? timeline
        : timeline.where((entry) {
            if (entry is! _ApptEntry) return false;
            final appointment = entry.appointment;
            return appointment.clientName.toLowerCase().contains(query) ||
                appointment.serviceName.toLowerCase().contains(query);
          }).toList();

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
                  child: Text(t(tk: 'Şu gün', ru: 'Сегодня', en: 'Today')),
                ),
              ),
            IconButton(
              tooltip: t(tk: 'Hepdelik görnüş', ru: 'Неделя', en: 'Week view'),
              icon: AppIcon(
                Icons.grid_view_outlined,
                size: 21,
                color: tokens.textPrimary,
              ),
              onPressed: () => Navigator.push(
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
            IconButton(
              tooltip: _searching
                  ? t(
                      tk: 'Gözlegi ýap',
                      ru: 'Закрыть поиск',
                      en: 'Close search',
                    )
                  : t(tk: 'Gözle', ru: 'Поиск', en: 'Search'),
              icon: AppIcon(
                _searching ? Icons.close : Icons.search,
                size: 21,
                color: tokens.textPrimary,
              ),
              onPressed: () => setState(() => _searching = !_searching),
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
                    color: tokens.textSecondary,
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
                AppIcon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: tokens.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selected.day} ${_byLang(language, _monthsFullTk, _monthsFullRu, _monthsFullEn)[_selected.month - 1]}, ${_selected.year} • ${_byLang(language, _weekdaysFullTk, _weekdaysFullRu, _weekdaysFullEn)[_selected.weekday - 1]}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (!_selected.isBefore(DateTime(appToday().year, appToday().month, appToday().day))) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addWorkingHours,
                  icon: const Icon(Icons.add_alarm_outlined, size: 18),
                  label: Text(t(
                    tk: 'Iş wagty goş',
                    ru: 'Добавить рабочие часы',
                    en: 'Add working hours',
                  )),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (!monthLoaded && bookingProvider.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!monthLoaded && !bookingProvider.loading)
              RetryErrorState(
                title: t(tk: 'Bu aýyň ýazgylaryny görüp bolmaýar', ru: 'Не удалось показать записи за этот месяц', en: 'Could not show this month’s bookings'),
                text: t(tk: 'Internet bilen birigip, ýazgylary ýükläň.', ru: 'Подключитесь к интернету, чтобы загрузить записи.', en: 'Connect to the internet to load bookings.'),
                retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                onRetry: () => bookingProvider.refreshDay(_selected),
              ),
            if (monthLoaded && !closedLoaded && closedError == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (monthLoaded && !closedLoaded && closedError != null)
              RetryErrorState(
                title: t(tk: 'Ýapyk wagtlary alyp bolmady', ru: 'Не удалось загрузить закрытое время', en: 'Could not load blocked times'),
                text: t(tk: 'Boş wagtlary görkezmek üçin täzeden synanyşyň.', ru: 'Повторите попытку, чтобы увидеть свободное время.', en: 'Retry to show available times.'),
                retryLabel: t(tk: 'Täzeden', ru: 'Повторить', en: 'Retry'),
                onRetry: () => scheduleProvider.loadClosedTimes(_selected, force: true),
              ),
            if (monthLoaded && query.isNotEmpty && entries.isEmpty)
              EmptyState(
                icon: Icons.search_off,
                title: t(
                  tk: 'Netije tapylmady',
                  ru: 'Ничего не найдено',
                  en: 'No results found',
                ),
                text: t(
                  tk: 'Başga at ýa-da hyzmat bilen gözläň.',
                  ru: 'Попробуйте другое имя или услугу.',
                  en: 'Try another name or service.',
                ),
              ),
            if (query.isEmpty &&
                entries.isEmpty &&
                schedule != null &&
                closedLoaded &&
                bookingProvider.isMonthLoaded(_selected))
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: BookingsEmptyState(
                  framed: false,
                  title: _sameDay(_selected, appToday())
                      ? t(
                          tk: 'Bu gün iş wagtyňyz galmady',
                          ru: 'На сегодня рабочих часов не осталось',
                          en: 'No working hours left today',
                        )
                      : t(
                          tk: 'Bu gün iş wagtyňyz ýok',
                          ru: 'На этот день рабочих часов нет',
                          en: 'No working hours on this day',
                        ),
                  text: t(
                    tk: 'Başga güni saýlaň ýa-da iş wagtyňyzy sazlaň.',
                    ru: 'Выберите другой день или настройте рабочее время.',
                    en: 'Choose another day or update your working hours.',
                  ),
                ),
              ),
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
              if (entry is _ClosedEntry) {
                return _ClosedTimeRow(
                  closed: entry.closed,
                  language: language,
                  onTap: () => _reopenClosedTime(context, entry.closed),
                );
              }
              final free = entry as _FreeEntry;
              return _FreeSlotRow(
                start: free.start,
                end: free.end,
                language: language,
                onTap: () {
                  if (!free.start.isAfter(DateTime.now())) {
                    setState(() {});
                    AppToast.of(context).error(
                      t(
                        tk: 'Bu wagt indi elýeterli däl. Başga wagt saýlaň.',
                        ru: 'Это время уже недоступно. Выберите другое.',
                        en: 'This time is no longer available. Choose another.',
                      ),
                    );
                    return;
                  }
                  _showFreeTimeActions(
                    context,
                    start: free.start,
                    end: free.end,
                    availableEnd: free.availableEnd,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
