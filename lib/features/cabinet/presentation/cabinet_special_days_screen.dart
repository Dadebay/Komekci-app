part of '../../../app/komekci_app.dart';

class SpecialDaysScreen extends StatefulWidget {
  const SpecialDaysScreen({super.key});

  @override
  State<SpecialDaysScreen> createState() => _SpecialDaysScreenState();
}

class _SpecialDaysScreenState extends State<SpecialDaysScreen> {
  bool _busy = false;

  Future<void> _addDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final schedule = context.read<ScheduleProvider>();
    final bookings = context.read<BookingProvider>();
    final exists = schedule.daysOff.any(
      (o) =>
          o.date.year == picked.year &&
          o.date.month == picked.month &&
          o.date.day == picked.day,
    );
    if (exists) return;

    setState(() => _busy = true);
    // Closing a day that already has bookings on it needs the master's
    // explicit acknowledgement — those appointments don't disappear on
    // their own, so surface them before the day is marked closed.
    try {
      await bookings.ensureLoaded(picked);
    } catch (_) {}
    if (!mounted) return;
    final affected = bookings
        .onDay(picked)
        .where((a) => a.status == AppointmentStatus.expected || a.status == AppointmentStatus.arrived)
        .toList();
    if (affected.isNotEmpty) {
      final proceed = await _showAffectedAppointmentsDialog(
        context,
        dateLabel: formatDate(picked),
        count: affected.length,
      );
      if (!mounted) return;
      if (proceed == null) {
        setState(() => _busy = false);
        return;
      }
      if (!proceed) {
        setState(() => _busy = false);
        Navigator.push(context, pageRoute(ScheduleScreen(initialDate: picked)));
        return;
      }
    }
    await runApi(context, () => schedule.addDayOff(picked));
    if (mounted) setState(() => _busy = false);
  }

  /// A one-off day with different opening hours (`custom_hours`).
  Future<void> _addCustomHours() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    final language = context.read<LanguageProvider>().language;
    final range = await _pickTimeRange(
      context,
      language: language,
      title: AppStrings.cabinetWorkingHoursForThatDay.select(language),
      start: '10:00',
      end: '16:00',
    );
    if (range == null || !mounted) return;
    final schedule = context.read<ScheduleProvider>();
    setState(() => _busy = true);
    await runApi(context, () => schedule.addCustomHours(picked, range.$1, range.$2));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final daysOff = context.watch<ScheduleProvider>().overrides;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.cabinetSpecialDays.select(language),
        action: AppHelpButton(
          onTap: () =>
              Navigator.push(context, pageRoute(const SupportScreen())),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.event_busy_outlined,
                    text: AppStrings.cabinetBookingsAreNotAcceptedOn.select(language),
                  ),
                  const SizedBox(height: 18),
                  if (daysOff.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          AppStrings.cabinetNoSpecialDaysAddedYet.select(language),
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    ...daysOff.map(
                      (o) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _softLine(tokens)),
                        ),
                        child: Row(
                          children: [
                            AppIcon(
                              o.type == OverrideType.dayOff
                                  ? Icons.event_busy_outlined
                                  : Icons.schedule_outlined,
                              color: tokens.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                o.type == OverrideType.dayOff
                                    ? formatDate(o.date)
                                    : '${formatDate(o.date)} · ${o.startTime}–${o.endTime}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => runApi(
                                context,
                                () => context.read<ScheduleProvider>().removeOverride(o.id),
                              ),
                              child: AppIcon(
                                Icons.close,
                                color: tokens.textSecondary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _busy ? null : _addCustomHours,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(Icons.schedule_outlined, color: tokens.textPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.cabinetAddSpecialHours.select(language),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _busy ? null : _addDay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            Icons.add,
                            color: tokens.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.cabinetAddDay.select(language),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: MasterActionButton(
                label: AppStrings.cabinetDone2.select(language),
                enabled: true,
                leading: Icons.check,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
