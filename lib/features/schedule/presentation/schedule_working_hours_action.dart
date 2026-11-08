part of '../../../app/komekci_app.dart';

extension _ScheduleWorkingHoursAction on _ScheduleScreenState {
  Future<void> _addWorkingHours() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final language = context.read<LanguageProvider>().language;
    final existing = scheduleProvider.overrides.any(
      (override) => _sameDay(override.date, _selected),
    );
    if (existing) {
      await Navigator.push(context, pageRoute(const SpecialDaysScreen()));
      return;
    }
    final windows = workingTimeRanges(scheduleProvider.schedule, _selected);
    final range = await _pickTimeRange(
      context,
      language: language,
      title: pickTr(
        language,
        tk: 'Şu gün üçin iş wagty',
        ru: 'Рабочие часы на этот день',
        en: 'Working hours for this day',
      ),
      start: windows.isEmpty ? '10:00' : formatTime(TimeOfDay.fromDateTime(windows.first.start)),
      end: windows.isEmpty ? '16:00' : formatTime(TimeOfDay.fromDateTime(windows.last.end)),
    );
    if (range == null || !mounted) return;
    await runApi(context, () => scheduleProvider.addCustomHours(_selected, range.$1, range.$2));
  }

}
