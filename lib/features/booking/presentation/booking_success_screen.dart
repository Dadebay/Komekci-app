part of '../../../app/komekci_app.dart';

// ── Step 4 — success ────────────────────────────────────────────────────────

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    super.key,
    required this.appointment,
    required this.masterName,
  });
  final ClientBooking appointment;
  final String masterName;

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  CalendarSaveResult? _calendarResult;
  bool _calendarSaving = true;
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _saveToCalendar();
    });
  }

  Future<void> _saveToCalendar() async {
    setState(() => _calendarSaving = true);
    final result = await context.read<ClientBookingsProvider>().saveToCalendar(
      widget.appointment,
    );
    if (!mounted) return;
    setState(() {
      _calendarSaving = false;
      _calendarResult = result;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final a = widget.appointment;
    final timeLabel =
        '${a.startsAt.hour.toString().padLeft(2, '0')}:${a.startsAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.elasticOut,
                ),
                // Two soft halos around the check read as a ripple.
                child: Container(
                  width: 144,
                  height: 144,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 112,
                    height: 112,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: .18),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.accent.withValues(alpha: .4),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AppIcon(
                        Icons.check,
                        size: 38,
                        color: tokens.accentOn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                AppStrings.bookingBookingConfirmed.select(language),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.bookingYourMasterHasBeenNotified.select(language),
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _bookingCardDecoration(tokens),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.serviceName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.masterName,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _BookingInfoTile(
                              icon: Icons.calendar_today_outlined,
                              caption: AppStrings.bookingDate.select(language),
                              value: formatDate(a.startsAt),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BookingInfoTile(
                              icon: Icons.schedule_outlined,
                              caption: AppStrings.bookingTime.select(language),
                              value:
                                  '$timeLabel · ${a.minutes} ${AppStrings.bookingMin.select(language)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_calendarSaving ||
                  _calendarResult != CalendarSaveResult.unavailable) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: _bookingCardDecoration(tokens),
                  child: Row(
                    children: [
                      AppIcon(
                        _calendarResult == CalendarSaveResult.saved
                            ? Icons.event_available_outlined
                            : Icons.calendar_today_outlined,
                        color: tokens.accent,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _calendarSaving
                              ? AppStrings.bookingAddingToCalendar.select(
                                  language,
                                )
                              : switch (_calendarResult) {
                                  CalendarSaveResult.saved =>
                                    AppStrings.bookingAddedToCalendarReminder1
                                        .select(language),
                                  CalendarSaveResult.permissionDenied =>
                                    AppStrings.bookingCalendarAccessIsNeeded
                                        .select(language),
                                  _ =>
                                    AppStrings.bookingCouldNotAddToCalendar
                                        .select(language),
                                },
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      if (!_calendarSaving &&
                          _calendarResult != CalendarSaveResult.saved) ...[
                        if (_calendarResult ==
                            CalendarSaveResult.permissionDenied)
                          TextButton(
                            onPressed: () => context
                                .read<ClientBookingsProvider>()
                                .openCalendarSettings(),
                            child: Text(
                              AppStrings.profileSettings.select(language),
                            ),
                          ),
                        IconButton(
                          tooltip: AppStrings.bookingRetry.select(language),
                          onPressed: _saveToCalendar,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.textPrimary,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    pageRoute(const ClientHome(initialTab: 2)),
                    (route) => false,
                  ),
                  child: Text(
                    AppStrings.bookingGoToMyBookings.select(language),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  pageRoute(const ClientHome()),
                  (route) => false,
                ),
                child: Text(AppStrings.bookingBackToHome.select(language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
