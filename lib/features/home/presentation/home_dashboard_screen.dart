part of '../../../app/komekci_app.dart';

/// Master's home dashboard — a live clock, at-a-glance queue stats, and
/// today's appointment timeline. Mobile-first rebuild of a tablet mock:
/// the wide multi-column layout became a 2×2 stat grid and a vertical card
/// list instead of a literal table.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.onViewSchedule});
  final ValueChanged<DateTime> onViewSchedule;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with TickerProviderStateMixin {
  late DateTime _clock = DateTime.now();
  late final AnimationController _numberShimmer;
  late final AnimationController _numberCountUp;
  late final MasterBookingAlertController _bookingAlerts;
  String? _refreshedAlertId;
  bool _refreshingNumbers = false;
  Timer? _timer;
  late final VoidCallback _bookingAlertListener = _refreshForNewBooking;

  Future<void> _refresh({bool refreshBookings = true}) =>
      _refreshDashboard(update: setState, refreshBookings: refreshBookings);

  @override
  void initState() {
    super.initState();
    _bookingAlerts = context.read<MasterBookingAlertController>();
    _bookingAlerts.addListener(_bookingAlertListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshForNewBooking();
    });
    _numberShimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _numberCountUp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      value: 1,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _clock = DateTime.now());
    });
  }

  @override
  void dispose() {
    _bookingAlerts.removeListener(_bookingAlertListener);
    _timer?.cancel();
    _numberShimmer.dispose();
    _numberCountUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    final bookingProvider = context.watch<BookingProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedule = scheduleProvider.schedule;
    final canPop = Navigator.of(context).canPop();
    final tokens = context.appTokens;

    final today = appToday();
    bookingProvider.prefetch(today);
    scheduleProvider.prefetchClosedTimes(today);

    final todayLoaded = bookingProvider.isMonthLoaded(today);
    final availabilityLoaded =
        todayLoaded &&
        schedule != null &&
        scheduleProvider.closedTimesLoaded(today);
    final todayAppointments = bookingProvider.onDay(today);
    final entries = todayLoaded
        ? _buildTimeline(
                todayAppointments,
                today,
                scheduleProvider.closedTimesLoaded(today) ? schedule : null,
                closedTimes: scheduleProvider.closedTimesOn(today),
                // Free slots that have already started are no longer bookable.
              )
              .where(
                (entry) =>
                    entry is! _FreeEntry || entry.start.isAfter(DateTime.now()),
              )
              .toList()
        : <_TimelineEntry>[];
    final freeSlotsToday = entries.whereType<_FreeEntry>().length;
    final unavailableHint = AppStrings.homeNotLoaded.select(language);

    // Compared against the live clock's time-of-day projected onto the mock
    // "today" date, since [dashboardToday] and [_clock] don't share a date.
    final nowOnMockDay = DateTime(
      today.year,
      today.month,
      today.day,
      _clock.hour,
      _clock.minute,
      _clock.second,
    );
    final activeToday =
        todayAppointments
            .where(
              (a) =>
                  a.status != AppointmentStatus.cancelled &&
                  a.status != AppointmentStatus.noShow,
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    Appointment? nextAppointment;
    for (final a in activeToday) {
      if (a.startsAt.isAfter(nowOnMockDay)) {
        nextAppointment = a;
        break;
      }
    }
    // The end of today's working window from the saved schedule (so 10:00 –
    // 22:00 shows 22:00), or the last booking if that runs later. No schedule
    // loaded or a day off with no bookings: nothing to show.
    DateTime? workEndsAt;
    if (schedule != null) {
      for (final window in workingTimeRanges(schedule, today)) {
        if (workEndsAt == null || window.end.isAfter(workEndsAt)) {
          workEndsAt = window.end;
        }
      }
    }
    if (activeToday.isNotEmpty) {
      final lastEnd = activeToday.last.startsAt.add(
        Duration(minutes: activeToday.last.minutes),
      );
      if (workEndsAt == null || lastEnd.isAfter(workEndsAt)) {
        workEndsAt = lastEnd;
      }
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 10, 16, canPop ? 20 : 100),
            children: [
              _DashboardHero(
                tk: tk,
                now: _clock,
                today: today,
                refreshingNumbers: _refreshingNumbers,
                numberShimmer: _numberShimmer,
                numberCountUp: _numberCountUp,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HomeStatCard(
                      refreshingNumbers: _refreshingNumbers,
                      numberShimmer: _numberShimmer,
                      numberCountUp: _numberCountUp,
                      icon: Icons.people_outline,
                      color: tokens.accent,
                      label: AppStrings.homeTodaySQueue.select(language),
                      value: todayLoaded ? '${todayAppointments.length}' : '—',
                      hint: todayLoaded
                          ? AppStrings.homePeople3.select(language)
                          : unavailableHint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HomeStatCard(
                      refreshingNumbers: _refreshingNumbers,
                      numberShimmer: _numberShimmer,
                      numberCountUp: _numberCountUp,
                      icon: Icons.person_outline,
                      color: freeSlotColorDark,
                      label: AppStrings.homeNextCustomer.select(language),
                      value: nextAppointment == null
                          ? '—'
                          : formatTime(
                              TimeOfDay.fromDateTime(nextAppointment.startsAt),
                            ),
                      hint: nextAppointment == null
                          ? todayLoaded
                                ? AppStrings.homeNone.select(language)
                                : unavailableHint
                          : '${nextAppointment.clientName} · ${nextAppointment.serviceName}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _HomeStatCard(
                      refreshingNumbers: _refreshingNumbers,
                      numberShimmer: _numberShimmer,
                      numberCountUp: _numberCountUp,
                      icon: Icons.schedule_outlined,
                      color: const Color(0xff2A5DB0),
                      label: AppStrings.homeFreeSlots.select(language),
                      value: availabilityLoaded ? '$freeSlotsToday' : '—',
                      hint: availabilityLoaded
                          ? AppStrings.homeFreeSlots2.select(language)
                          : unavailableHint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HomeStatCard(
                      refreshingNumbers: _refreshingNumbers,
                      numberShimmer: _numberShimmer,
                      numberCountUp: _numberCountUp,
                      icon: Icons.flag_outlined,
                      color: const Color(0xff5B5FC7),
                      label: AppStrings.homeWorkEnds.select(language),
                      value: todayLoaded && workEndsAt != null
                          ? formatTime(TimeOfDay.fromDateTime(workEndsAt))
                          : '—',
                      hint: todayLoaded
                          ? AppStrings.homeEndOfWorkDay.select(language)
                          : unavailableHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DayTimelineCard(
                tk: tk,
                title: AppStrings.homeToday.select(language),
                dateLabel: formatDate(today),
                accent: freeSlotColorDark,
                accentBg: freeSlotBg,
                count: todayAppointments.length,
                showHeader: false,
                child: !todayLoaded
                    ? bookingProvider.loading
                          ? const Center(child: CircularProgressIndicator())
                          : RetryErrorState(
                              title: AppStrings.homeCouldNotShowTodayS.select(
                                language,
                              ),
                              text: AppStrings.homeConnectToTheInternetAnd
                                  .select(language),
                              retryLabel: AppStrings.profileTryAgain.select(
                                language,
                              ),
                              onRetry: () => bookingProvider.refreshDay(today),
                            )
                    : todayAppointments.isEmpty
                    ? BookingsEmptyState(
                        framed: false,
                        compact: true,
                        title: AppStrings.homeNoBookingsToday.select(language),
                        text: AppStrings.homeViewAvailableTimesInThe.select(
                          language,
                        ),
                      )
                    : _HomeApptTable(
                        entries: entries,
                        customers: customerProvider.customers,
                        language: language,
                        onTapAppointment: (appointment, customer) =>
                            _openAppointmentActions(
                              context,
                              appointment,
                              customer,
                              language,
                            ),
                        onTapFree: (start, end, availableEnd) =>
                            _showFreeTimeActions(
                              context,
                              start: start,
                              end: end,
                              availableEnd: availableEnd,
                            ),
                        onTapClosed: (closed) =>
                            _reopenClosedTime(context, closed),
                      ),
              ),
              const SizedBox(height: 6),
              _OutlineActionButton(
                icon: Icons.calendar_month_outlined,
                label: AppStrings.homeViewFullSchedule.select(language),
                onTap: () => widget.onViewSchedule(today),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
