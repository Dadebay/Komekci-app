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

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
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
              )
              .where(
                (entry) => entry is! _FreeEntry || entry.start.isAfter(now),
              )
              .toList())
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ScheduleHeader(
              language: language,
              selected: _selected,
              weekStart: _weekStart,
              searching: _searching,
              onSelect: _select,
              onToggleSearch: () => setState(() => _searching = !_searching),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, canPop ? 20 : 100),
                children: [
                  if (_searching) ...[
                    _SearchField(
                      controller: _searchController,
                      hint: AppStrings.scheduleSearchCustomerOrService.select(
                        language,
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
                      () => _weekStart = _weekStart.subtract(
                        const Duration(days: 7),
                      ),
                    ),
                    onNextWeek: () => setState(
                      () =>
                          _weekStart = _weekStart.add(const Duration(days: 7)),
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
                  if (!_selected.isBefore(
                    DateTime(appToday().year, appToday().month, appToday().day),
                  )) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _addWorkingHours,
                        icon: const Icon(Icons.add_alarm_outlined, size: 18),
                        label: Text(
                          AppStrings.scheduleAddWorkingHours.select(language),
                        ),
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
                      title: AppStrings.scheduleCouldNotShowThisMonth.select(
                        language,
                      ),
                      text: AppStrings.scheduleConnectToTheInternetTo.select(
                        language,
                      ),
                      retryLabel: AppStrings.profileTryAgain.select(language),
                      onRetry: () => bookingProvider.refreshDay(_selected),
                    ),
                  if (monthLoaded && !closedLoaded && closedError == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (monthLoaded && !closedLoaded && closedError != null)
                    RetryErrorState(
                      title: AppStrings.scheduleCouldNotLoadBlockedTimes.select(
                        language,
                      ),
                      text: AppStrings.scheduleRetryToShowAvailableTimes.select(
                        language,
                      ),
                      retryLabel: AppStrings.scheduleRetry.select(language),
                      onRetry: () => scheduleProvider.loadClosedTimes(
                        _selected,
                        force: true,
                      ),
                    ),
                  if (monthLoaded && query.isNotEmpty && entries.isEmpty)
                    EmptyState(
                      icon: Icons.search_off,
                      title: AppStrings.scheduleNoResultsFound.select(language),
                      text: AppStrings.scheduleTryAnotherNameOrService.select(
                        language,
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
                            ? AppStrings.scheduleNoWorkingHoursLeftToday.select(
                                language,
                              )
                            : AppStrings.scheduleNoWorkingHoursOnThis.select(
                                language,
                              ),
                        text: AppStrings.scheduleChooseAnotherDayOrUpdate
                            .select(language),
                      ),
                    ),
                  ..._scheduleTimelineRows(
                    context: context,
                    entries: entries,
                    customerProvider: customerProvider,
                    language: language,
                    onExpired: () => setState(() {}),
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
