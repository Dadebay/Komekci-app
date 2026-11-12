part of '../../../app/komekci_app.dart';

/// Cabinet cards sit on the elevated surface, so their outline is softer
/// than the app default.
Color _softLine(AppThemeTokens tokens) => tokens.border.withValues(alpha: .55);

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Clear 24-hour time picker: a rounded sheet with a big readout and two
/// looping wheels (hours, minutes) sharing one highlighted band.
/// Minutes move in steps of 5; an off-grid [initial] is rounded down.
Future<TimeOfDay?> showClearTimePicker(
  BuildContext context, {
  required TimeOfDay initial,
  required AppLanguage language,
  String? title,
}) {
  final tokens = context.appTokens;
  var hour = initial.hour;
  var minute = initial.minute - initial.minute % 5;
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    // Without this the sheet is capped at 9/16 of the screen and overflows.
    isScrollControlled: true,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title ??
                    AppStrings.cabinetSelectTime.select(language),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: tokens.accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  formatTime(TimeOfDay(hour: hour, minute: minute)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    height: 1.1,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                    color: tokens.accent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeWheel(
                            count: 24,
                            value: hour,
                            label: (i) => i.toString().padLeft(2, '0'),
                            onChanged: (i) => setSheetState(() => hour = i),
                          ),
                        ),
                        const Text(
                          ':',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                        Expanded(
                          child: _TimeWheel(
                            count: 12,
                            value: minute ~/ 5,
                            label: (i) => (i * 5).toString().padLeft(2, '0'),
                            onChanged: (i) => setSheetState(() => minute = i * 5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              MasterActionButton(
                label: AppStrings.cabinetDone.select(language),
                enabled: true,
                leading: Icons.check_rounded,
                onTap: () => Navigator.pop(
                  sheetContext,
                  TimeOfDay(hour: hour, minute: minute),
                ),
              ),
              const SizedBox(height: 4),
              _DialogCancelButton(
                label: AppStrings.servicesCancel.select(language),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// One looping number wheel of [count] items; the centred one is [value].
class _TimeWheel extends StatefulWidget {
  const _TimeWheel({
    required this.count,
    required this.value,
    required this.label,
    required this.onChanged,
  });
  final int count;
  final int value;
  final String Function(int) label;
  final ValueChanged<int> onChanged;

  @override
  State<_TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<_TimeWheel> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: 48,
      diameterRatio: 1.8,
      perspective: .003,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        HapticFeedback.selectionClick();
        widget.onChanged(index % widget.count);
      },
      childDelegate: ListWheelChildLoopingListDelegate(
        children: [
          for (var i = 0; i < widget.count; i++)
            Center(
              child: Text(
                widget.label(i),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: i == widget.value ? FontWeight.w800 : FontWeight.w500,
                  color: i == widget.value
                      ? tokens.textPrimary
                      : tokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom sheet to edit a start/end time pair (used by the day rows and the break-time row).
Future<(String, String)?> _pickTimeRange(
  BuildContext context, {
  required AppLanguage language,
  required String title,
  required String start,
  required String end,
}) {
  var localStart = start;
  var localEnd = end;
  final tokens = context.appTokens;
  return showModalBottomSheet<(String, String)>(
    context: context,
    backgroundColor: tokens.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        int minutesOf(String value) {
          final t = _parseTime(value);
          return t.hour * 60 + t.minute;
        }

        final invalid = minutesOf(localEnd) <= minutesOf(localStart);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PickerField(
                      label: AppStrings.cabinetStart.select(language),
                      value: localStart,
                      icon: Icons.schedule_outlined,
                      trailingIcon: Icons.expand_more,
                      onTap: () async {
                        final picked = await showClearTimePicker(
                          sheetContext,
                          initial: _parseTime(localStart),
                          language: language,
                          title: AppStrings.cabinetStartTime.select(language),
                        );
                        if (picked != null) {
                          setSheetState(() => localStart = formatTime(picked));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerField(
                      label: AppStrings.cabinetEnd.select(language),
                      value: localEnd,
                      icon: Icons.schedule_outlined,
                      trailingIcon: Icons.expand_more,
                      onTap: () async {
                        final picked = await showClearTimePicker(
                          sheetContext,
                          initial: _parseTime(localEnd),
                          language: language,
                          title: AppStrings.cabinetEndTime.select(language),
                        );
                        if (picked != null) {
                          setSheetState(() => localEnd = formatTime(picked));
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (invalid) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppIcon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: tokens.danger,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppStrings.cabinetEndTimeMustBeAfter.select(language),
                      style: TextStyle(fontSize: 11.5, color: tokens.danger),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              MasterActionButton(
                label: AppStrings.servicesSave.select(language),
                enabled: !invalid,
                leading: Icons.save_outlined,
                onTap: () =>
                    Navigator.pop(sheetContext, (localStart, localEnd)),
              ),
            ],
          ),
        );
      },
    ),
  );
}
