part of '../../../app/komekci_app.dart';

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
    this.callAction = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  final bool callAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: danger
                    ? tokens.danger.withValues(alpha: .14)
                    : tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                icon,
                size: 17,
                color: danger ? tokens.danger : tokens.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: danger ? tokens.danger : tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (callAction)
              // Deliberately fixed white icon: sits on the always-green call
              // avatar (0xff2FAE60), which is not part of the token system.
              const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xff2FAE60),
                child: AppIcon(
                  Icons.phone_outlined,
                  size: 15,
                  color: Colors.white,
                ),
              )
            else
              AppIcon(
                Icons.chevron_right,
                size: 16,
                color: tokens.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom date + time sheet used everywhere the app needs to pick a moment
/// in time — deliberately replaces the plain OS date/time pickers with a
/// sheet that matches the rest of the app (reuses [_MonthCalendar]).
Future<DateTime?> _pickAppointmentDateTime(
  BuildContext context, {
  required AppLanguage language,
  required DateTime initial,
  required int minutes,
  required String excludeId,
  required BookingProvider bookingProvider,
}) {
  var month = DateTime(initial.year, initial.month);
  var selectedDate = DateTime(initial.year, initial.month, initial.day);
  var selectedTime = TimeOfDay.fromDateTime(initial);
  final quickTimes = List.generate(20, (i) {
    final total = 9 * 60 + i * 30;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  });
  final tokens = context.appTokens;

  DateTime candidateFor(TimeOfDay time) => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    time.hour,
    time.minute,
  );

  bool canChoose(TimeOfDay time) {
    final candidate = candidateFor(time);
    return appointmentFitsWorkingTime(
          context.read<ScheduleProvider>().schedule,
          candidate,
          minutes,
        ) &&
        !bookingProvider.hasConflict(candidate, minutes, excludeId: excludeId);
  }

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: tokens.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pickTr(
                    language,
                    tk: 'Sene we wagt saýlaň',
                    ru: 'Выберите дату и время',
                    en: 'Choose a date and time',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pickTr(language, tk: 'Häzirki wagt', ru: 'Текущее время', en: 'Current time')}: ${formatDate(initial)} · ${formatTime(TimeOfDay.fromDateTime(initial))}',
                  style: TextStyle(fontSize: 12.5, color: tokens.textSecondary),
                ),
                const SizedBox(height: 16),
                _MonthCalendar(
                  month: month,
                  selected: selectedDate,
                  language: language,
                  onSelect: (d) {
                    setSheetState(() => selectedDate = d);
                    // Busy slots are drawn from the cached calendar; make
                    // sure that month has been fetched.
                    bookingProvider.ensureLoaded(d).then((_) {
                      if (sheetContext.mounted) setSheetState(() {});
                    });
                  },
                  onPrevMonth: () {
                    setSheetState(
                      () => month = DateTime(month.year, month.month - 1),
                    );
                    bookingProvider.ensureLoaded(month).then((_) {
                      if (sheetContext.mounted) setSheetState(() {});
                    });
                  },
                  onNextMonth: () {
                    setSheetState(
                      () => month = DateTime(month.year, month.month + 1),
                    );
                    bookingProvider.ensureLoaded(month).then((_) {
                      if (sheetContext.mounted) setSheetState(() {});
                    });
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  pickTr(language, tk: 'Wagt', ru: 'Время', en: 'Time'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickTimes.map((t) {
                    final selected =
                        selectedTime.hour == t.hour &&
                        selectedTime.minute == t.minute;
                    final taken = !canChoose(t);
                    return GestureDetector(
                      onTap: taken
                          ? null
                          : () => setSheetState(() => selectedTime = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: taken
                              ? tokens.disabled.withValues(alpha: .12)
                              : selected
                              ? tokens.textPrimary
                              : tokens.surface,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: taken
                                ? tokens.border
                                : selected
                                ? tokens.textPrimary
                                : tokens.border,
                          ),
                        ),
                        child: Text(
                          formatTime(t),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: taken
                                ? TextDecoration.lineThrough
                                : null,
                            color: taken
                                ? tokens.disabled
                                : selected
                                ? tokens.surface
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                MasterActionButton(
                  label: pickTr(
                    language,
                    tk: 'Tassykla',
                    ru: 'Подтвердить',
                    en: 'Confirm',
                  ),
                  enabled: canChoose(selectedTime),
                  leading: Icons.check,
                  onTap: () =>
                      Navigator.pop(sheetContext, candidateFor(selectedTime)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
