part of '../../../app/komekci_app.dart';

/// One upcoming day's bookings in the same table design as the home
/// dashboard's "today" card — reached by tapping an "Öňümizdäki günler" row
/// instead of jumping to the full Senenama tab.
class DayTimelineScreen extends StatelessWidget {
  const DayTimelineScreen({super.key, required this.day});
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    final tokens = context.appTokens;
    final bookingProvider = context.watch<BookingProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedule = scheduleProvider.schedule;
    bookingProvider.prefetch(day);
    scheduleProvider.prefetchClosedTimes(day);
    final dayAppointments = bookingProvider.onDay(day);
    final entries =
        _buildTimeline(
              dayAppointments,
              day,
              scheduleProvider.closedTimesLoaded(day) ? schedule : null,
              closedTimes: scheduleProvider.closedTimesOn(day),
            )
            .where(
              (entry) =>
                  entry is! _FreeEntry || entry.start.isAfter(DateTime.now()),
            )
            .toList();

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title:
            '${formatDate(day)} · ${_weekdayFullName(day.weekday, language)}',
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            _DayTimelineCard(
              tk: tk,
              title: AppStrings.homeBookings.select(language),
              dateLabel: formatDate(day),
              accent: freeSlotColorDark,
              accentBg: freeSlotBg,
              count: dayAppointments.length,
              child: entries.isEmpty
                  // The table itself is full-bleed inside the day card, so
                  // only the empty state needs an inset of its own.
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: EmptyState(
                        icon: Icons.event_busy_outlined,
                        title: AppStrings.homeNoBookingsThisDay.select(
                          language,
                        ),
                        text: AppStrings.homeAFreeDay.select(language),
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
          ],
        ),
      ),
    );
  }
}
