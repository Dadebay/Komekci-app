part of '../../../app/komekci_app.dart';

class _VacationScreenState extends State<VacationScreen> {
  late DateTime _start = appToday();
  late DateTime _end = appToday().add(const Duration(days: 7));
  bool _saving = false;

  Future<void> _pickDate({required bool isStart}) =>
      _pickDateWithUpdate(isStart: isStart, update: setState);

  Future<void> _add() async {
    if (_saving) return;
    final bookings = context.read<BookingProvider>();
    final schedule = context.read<ScheduleProvider>();
    setState(() => _saving = true);
    try {
      await _loadMonthsBetween(bookings, _start, _end);
    } catch (_) {
      // Counting affected bookings is advisory; the server decides.
    }
    if (!mounted) return;
    final rangeEnd = DateTime(_end.year, _end.month, _end.day, 23, 59);
    final affected = bookings.appointments
        .where(
          (a) =>
              !a.startsAt.isBefore(_start) &&
              !a.startsAt.isAfter(rangeEnd) &&
              a.status == AppointmentStatus.expected,
        )
        .toList();
    if (affected.isNotEmpty) {
      final rangeLabel = '${formatDate(_start)} – ${formatDate(_end)}';
      final proceed = await _showAffectedAppointmentsDialog(
        context,
        dateLabel: rangeLabel,
        count: affected.length,
      );
      if (!mounted) return;
      if (proceed == null) {
        setState(() => _saving = false);
        return;
      }
      if (!proceed) {
        setState(() => _saving = false);
        Navigator.push(context, pageRoute(ScheduleScreen(initialDate: _start)));
        return;
      }
    }
    final ok = await runApi(context, () => schedule.addVacation(_start, _end));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      setState(() {
        _start = appToday();
        _end = appToday().add(const Duration(days: 7));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    final vacations = context.watch<ScheduleProvider>().vacations;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.cabinetVacation2.select(language),
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
                    text: AppStrings.cabinetDuringThisTimeYouWill.select(language),
                  ),
                  if (vacations.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      AppStrings.cabinetAddedPeriods.select(language),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    for (final v in vacations)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: tokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _softLine(tokens)),
                        ),
                        child: Row(
                          children: [
                            AppIcon(Icons.event_busy_outlined, color: tokens.accent, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${formatDate(v.start)} – ${formatDate(v.end)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => runApi(
                                context,
                                () => context.read<ScheduleProvider>().removeVacation(v.id),
                              ),
                              child: AppIcon(Icons.close, color: tokens.textSecondary, size: 18),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    AppStrings.cabinetNewVacationPeriod.select(language),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PickerField(
                    label: AppStrings.cabinetStartDate.select(language),
                    value: formatDate(_start),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isStart: true),
                  ),
                  const SizedBox(height: 14),
                  _PickerField(
                    label: AppStrings.cabinetEndDate.select(language),
                    value: formatDate(_end),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: MasterActionButton(
                label: _saving
                    ? AppStrings.servicesSaving.select(language)
                    : AppStrings.cabinetAddVacation.select(language),
                enabled: !_saving,
                leading: Icons.add,
                onTap: _add,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warns before closing a day that already has bookings on it.
/// Returns `true` to close the day anyway, `false` to go review the day's
/// appointments instead, `null` if the master backed out entirely.
Future<bool?> _showAffectedAppointmentsDialog(
  BuildContext context, {
  required String dateLabel,
  required int count,
}) {
  final language = context.read<LanguageProvider>().language;
  final tokens = context.appTokens;
  return showDialog<bool>(
    context: context,
    barrierColor: tokens.scrim,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.warning_amber_rounded,
                size: 25,
                color: tokens.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.cabinetThereAreBookingsInThis.select(language),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.cabinetThereAreBookingSFor(dateLabel, count).select(language),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: tokens.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: tokens.border),
                ),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  AppStrings.cabinetViewBookings.select(language),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.textPrimary,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  AppStrings.cabinetCloseAnyway.select(language),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(AppStrings.servicesCancel.select(language)),
            ),
          ],
        ),
      ),
    ),
  );
}
