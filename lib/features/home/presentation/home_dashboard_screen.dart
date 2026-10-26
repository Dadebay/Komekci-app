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
  bool _refreshingNumbers = false;
  Timer? _timer;

  Future<void> _refresh() async {
    if (_refreshingNumbers) return;
    final bookings = context.read<BookingProvider>();
    final customers = context.read<CustomerProvider>();
    final schedule = context.read<ScheduleProvider>();
    final billing = context.read<BillingProvider>();
    final profile = context.read<MasterProfileProvider>();
    final requests = context.read<ConnectionRequestsProvider>();
    _numberCountUp.stop();
    setState(() => _refreshingNumbers = true);
    _numberShimmer.repeat();
    try {
      await Future.wait<void>([
        bookings.refreshDay(appToday()),
        customers.load(),
        schedule.load(),
        billing.refresh(),
        profile.refresh(),
        requests.load(),
        Future<void>.delayed(const Duration(milliseconds: 450)),
      ]);
      if (mounted &&
          (bookings.error != null ||
              customers.error != null ||
              schedule.error != null ||
              billing.error != null ||
              requests.error != null)) {
        final language = context.read<LanguageProvider>().language;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pickTr(
                language,
                tk: 'Maglumatlary täzelemek başartmady. Öňki maglumatlar görkezilýär.',
                ru: 'Не удалось обновить данные. Показаны прежние значения.',
                en: 'Could not refresh data. Previous values are shown.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        _numberShimmer.stop();
        setState(() => _refreshingNumbers = false);
        _numberCountUp.forward(from: 0);
      }
    }
  }

  @override
  void initState() {
    super.initState();
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
    _timer?.cancel();
    _numberShimmer.dispose();
    _numberCountUp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
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
    final availabilityLoaded = todayLoaded &&
        schedule != null &&
        scheduleProvider.closedTimesLoaded(today);
    final todayAppointments = bookingProvider.onDay(today);
    final entries = todayLoaded
        ? _buildTimeline(
            todayAppointments,
            today,
            scheduleProvider.closedTimesLoaded(today) ? schedule : null,
            closedTimes: scheduleProvider.closedTimesOn(today),
          )
        : <_TimelineEntry>[];
    final freeSlotsToday = entries.whereType<_FreeEntry>().length;
    final unavailableHint = t(tk: 'Ýüklenmedi', ru: 'Не загружено', en: 'Not loaded');

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
    final workEndsAt = activeToday.isEmpty
        ? DateTime(today.year, today.month, today.day, 19)
        : activeToday.last.startsAt.add(
            Duration(minutes: activeToday.last.minutes),
          );

    return Scaffold(
      backgroundColor: tokens.surface,
      body: RefreshIndicator(
        onRefresh: _refresh,
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
                    label: t(
                      tk: 'Şu günki nobat',
                      ru: 'Очередь сегодня',
                      en: "Today's queue",
                    ),
                    value: todayLoaded ? '${todayAppointments.length}' : '—',
                    hint: todayLoaded ? t(tk: 'adam', ru: 'человек', en: 'people') : unavailableHint,
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
                    label: t(
                      tk: 'Indiki müşderi',
                      ru: 'Следующий клиент',
                      en: 'Next customer',
                    ),
                    value: nextAppointment == null
                        ? '—'
                        : formatTime(
                            TimeOfDay.fromDateTime(nextAppointment.startsAt),
                          ),
                    hint: nextAppointment == null
                        ? todayLoaded ? t(tk: 'Nobat ýok', ru: 'Никого', en: 'None') : unavailableHint
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
                    label: t(
                      tk: 'Boş wagtlar',
                      ru: 'Свободные окна',
                      en: 'Free slots',
                    ),
                    value: availabilityLoaded ? '$freeSlotsToday' : '—',
                    hint: availabilityLoaded ? t(
                      tk: 'boş aralyk',
                      ru: 'окон свободно',
                      en: 'free slots',
                    ) : unavailableHint,
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
                    label: t(
                      tk: 'Iş gutarýar',
                      ru: 'Работа заканчивается',
                      en: 'Work ends',
                    ),
                    value: todayLoaded ? formatTime(TimeOfDay.fromDateTime(workEndsAt)) : '—',
                    hint: todayLoaded ? t(
                      tk: 'soňky müşderi',
                      ru: 'последний клиент',
                      en: 'last customer',
                    ) : unavailableHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DayTimelineCard(
              tk: tk,
              title: t(tk: 'ŞU GÜN', ru: 'СЕГОДНЯ', en: 'TODAY'),
              dateLabel: formatDate(today),
              accent: freeSlotColorDark,
              accentBg: freeSlotBg,
              count: todayAppointments.length,
              showHeader: false,
              child: !todayLoaded
                  ? bookingProvider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : RetryErrorState(
                          title: t(tk: 'Şu günki ýazgylary görüp bolmaýar', ru: 'Не удалось показать записи на сегодня', en: 'Could not show today’s bookings'),
                          text: t(tk: 'Internet bilen birigip, täzeden synanyşyň.', ru: 'Подключитесь к интернету и попробуйте ещё раз.', en: 'Connect to the internet and try again.'),
                          retryLabel: t(tk: 'Täzeden synanyş', ru: 'Повторить', en: 'Try again'),
                          onRetry: () => bookingProvider.refreshDay(today),
                        )
                  : todayAppointments.isEmpty
                  ? BookingsEmptyState(
                      framed: false,
                      compact: true,
                      title: t(
                        tk: 'Şu gün ýazgy ýok',
                        ru: 'На сегодня записей нет',
                        en: 'No bookings today',
                      ),
                      text: t(
                        tk: 'Boş wagtlary senenamadan görüp bilersiňiz.',
                        ru: 'Свободное время можно посмотреть в расписании.',
                        en: 'View available times in the schedule.',
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
                          _showFreeTimeActions(context, start: start, end: end, availableEnd: availableEnd),
                      onTapClosed: (closed) => _reopenClosedTime(context, closed),
                    ),
            ),
            const SizedBox(height: 6),
            _OutlineActionButton(
              icon: Icons.calendar_month_outlined,
              label: t(
                tk: 'Ähli nobaty görmek',
                ru: 'Смотреть всё расписание',
                en: 'View full schedule',
              ),
              onTap: () => widget.onViewSchedule(today),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
