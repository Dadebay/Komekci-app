part of '../../../app/komekci_app.dart';

const _mockTotalClients = 128;

/// Cabinet cards sit on the elevated surface, so their outline is softer
/// than the app default.
Color _softLine(AppThemeTokens tokens) => tokens.border.withValues(alpha: .55);

/// Mock client used across the notification / messaging screens.
typedef _MockClient = ({
  String name,
  String phone,
  String lastVisitDate,
  String lastVisitTime,
});

const _mockClients = <_MockClient>[
  (
    name: 'Aýgül Annagulyýewa',
    phone: '+993 65 123456',
    lastVisitDate: '03.06.2025',
    lastVisitTime: '14:30',
  ),
  (
    name: 'Maksat Geldiýew',
    phone: '+993 64 987654',
    lastVisitDate: '31.05.2025',
    lastVisitTime: '16:45',
  ),
  (
    name: 'Selbi Atajanowa',
    phone: '+993 65 555111',
    lastVisitDate: '29.05.2025',
    lastVisitTime: '11:00',
  ),
  (
    name: 'Oguljahan Muhammedowa',
    phone: '+993 63 222333',
    lastVisitDate: '27.05.2025',
    lastVisitTime: '13:20',
  ),
  (
    name: 'Dowletmyrat Ýazmammedow',
    phone: '+993 61 777888',
    lastVisitDate: '25.05.2025',
    lastVisitTime: '09:15',
  ),
  (
    name: 'Maral Rejepowa',
    phone: '+993 65 444777',
    lastVisitDate: '24.05.2025',
    lastVisitTime: '10:05',
  ),
];

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Bottom sheet to edit a start/end time pair (used by the day rows and the break-time row).
Future<(String, String)?> _pickTimeRange(
  BuildContext context, {
  required AppLanguage language,
  required String title,
  required String start,
  required String end,
}) {
  String t({required String tk, required String ru, required String en}) =>
      pickTr(language, tk: tk, ru: ru, en: en);
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
                      label: t(tk: 'Başlangyç', ru: 'Начало', en: 'Start'),
                      value: localStart,
                      icon: Icons.schedule_outlined,
                      trailingIcon: Icons.expand_more,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: sheetContext,
                          initialTime: _parseTime(localStart),
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
                      label: t(tk: 'Tamamlanyş', ru: 'Конец', en: 'End'),
                      value: localEnd,
                      icon: Icons.schedule_outlined,
                      trailingIcon: Icons.expand_more,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: sheetContext,
                          initialTime: _parseTime(localEnd),
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
                      t(
                        tk: 'Tamamlanyş wagty başlangyçdan soň bolmaly',
                        ru: 'Время окончания должно быть позже начала',
                        en: 'End time must be after the start time',
                      ),
                      style: TextStyle(fontSize: 11.5, color: tokens.danger),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _MasterActionButton(
                label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
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

/// Bottom sheet listing a fixed set of numeric choices (buffer minutes, reminder days, ...).
Future<int?> _pickDuration(
  BuildContext context, {
  required AppLanguage language,
  required int current,
  required List<int> options,
  required String unit,
}) {
  final tokens = context.appTokens;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: tokens.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickTr(
                  language,
                  tk: 'Sany saýlaň',
                  ru: 'Выберите значение',
                  en: 'Choose a value',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...options.map(
                (n) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '$n $unit',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: n == current
                      ? AppIcon(Icons.check, color: tokens.accent)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, n),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
