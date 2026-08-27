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

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late DateTime _clock = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _clock = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final canPop = Navigator.of(context).canPop();
    final tokens = context.appTokens;

    final today = DateTime(
      dashboardToday.$1,
      dashboardToday.$2,
      dashboardToday.$3,
    );

    final todayAppointments = bookingProvider.onDay(today);
    final entries = _buildTimeline(todayAppointments, today);
    final freeSlotsToday = entries.whereType<_FreeEntry>().length;

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

    final upcomingDays = <DateTime>[];
    for (var i = 1; i <= 4; i++) {
      final day = today.add(Duration(days: i));
      if (bookingProvider.onDay(day).isNotEmpty) upcomingDays.add(day);
    }

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, canPop ? 20 : 100),
          children: [
            _DashboardHero(tk: tk, now: _clock, today: today),
            const SizedBox(height: 22),
            Text(
              t(
                tk: 'Nobat maglumaty',
                ru: 'Обзор очереди',
                en: 'Queue overview',
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _HomeStatCard(
                    icon: Icons.people_outline,
                    color: tokens.accent,
                    label: t(
                      tk: 'Bugünki nobat',
                      ru: 'Очередь сегодня',
                      en: "Today's queue",
                    ),
                    value: '${todayAppointments.length}',
                    hint: t(tk: 'adam', ru: 'человек', en: 'people'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HomeStatCard(
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
                        ? t(tk: 'Nobat ýok', ru: 'Никого', en: 'None')
                        : '${nextAppointment.clientName} · ${nextAppointment.serviceName}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _HomeStatCard(
                    icon: Icons.schedule_outlined,
                    color: const Color(0xff2A5DB0),
                    label: t(
                      tk: 'Boş wagtlar',
                      ru: 'Свободные окна',
                      en: 'Free slots',
                    ),
                    value: '$freeSlotsToday',
                    hint: t(
                      tk: 'boş aralyk',
                      ru: 'окон свободно',
                      en: 'free slots',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HomeStatCard(
                    icon: Icons.flag_outlined,
                    color: const Color(0xff5B5FC7),
                    label: t(
                      tk: 'Iş gutarýar',
                      ru: 'Работа заканчивается',
                      en: 'Work ends',
                    ),
                    value: formatTime(TimeOfDay.fromDateTime(workEndsAt)),
                    hint: t(
                      tk: 'soňky müşderi',
                      ru: 'последний клиент',
                      en: 'last customer',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _DayTimelineCard(
              tk: tk,
              title: t(tk: 'ŞU GÜN', ru: 'СЕГОДНЯ', en: 'TODAY'),
              dateLabel: formatDate(today),
              accent: freeSlotColorDark,
              accentBg: freeSlotBg,
              count: todayAppointments.length,
              child: entries.isEmpty
                  ? EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: t(
                        tk: 'Şu gün ýazgy ýok',
                        ru: 'На сегодня записей нет',
                        en: 'No bookings today',
                      ),
                      text: t(
                        tk: 'Boş gün — dynç alyň!',
                        ru: 'Свободный день.',
                        en: 'A free day — relax!',
                      ),
                    )
                  : _HomeApptTable(
                      entries: entries,
                      customers: customerProvider.customers,
                      language: language,
                      onTap: () => widget.onViewSchedule(today),
                    ),
            ),
            if (upcomingDays.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                t(
                  tk: 'Öňümizdäki günler',
                  ru: 'Ближайшие дни',
                  en: 'Upcoming days',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...upcomingDays.map(
                (day) => _UpcomingDayRow(
                  day: day,
                  count: bookingProvider.onDay(day).length,
                  tk: tk,
                  onTap: () => Navigator.push(context, pageRoute(DayTimelineScreen(day: day))),
                ),
              ),
            ],
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
    );
  }
}

