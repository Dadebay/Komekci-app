import '../../../data/models/api/master_models.dart';

class WorkingTimeRange {
  const WorkingTimeRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// The API rejects starts in the past or closer than `min_lead_min`.
bool meetsBookingLeadTime(DateTime start, DateTime now, int minLeadMinutes) =>
    start.isAfter(now) &&
    !start.isBefore(now.add(Duration(minutes: minLeadMinutes)));

/// The bookable parts of a day, after one-off hours, days off, vacations,
/// and the weekly break have been applied. All times are Ashgabat wall time.
List<WorkingTimeRange> workingTimeRanges(Schedule? schedule, DateTime date) {
  if (schedule == null) return const [];

  final day = DateTime(date.year, date.month, date.day);
  bool sameDay(DateTime other) =>
      other.year == day.year &&
      other.month == day.month &&
      other.day == day.day;

  for (final vacation in schedule.vacations) {
    final first = DateTime(
      vacation.start.year,
      vacation.start.month,
      vacation.start.day,
    );
    final last = DateTime(
      vacation.end.year,
      vacation.end.month,
      vacation.end.day,
    );
    if (!day.isBefore(first) && !day.isAfter(last)) return const [];
  }

  ScheduleDay? weekly;
  for (final entry in schedule.days) {
    if (entry.weekday == day.weekday - 1) {
      weekly = entry;
      break;
    }
  }

  ScheduleOverride? override;
  for (final entry in schedule.overrides) {
    if (sameDay(entry.date)) override = entry;
  }
  if (override?.type == OverrideType.dayOff) return const [];

  final custom = override?.type == OverrideType.customHours;
  if (!custom && (weekly == null || !weekly.isWorking)) return const [];

  final start = _onDay(day, custom ? override?.startTime : weekly?.startTime);
  final end = _onDay(day, custom ? override?.endTime : weekly?.endTime);
  if (start == null || end == null || !end.isAfter(start)) return const [];

  final breakStart = _onDay(day, weekly?.breakStart);
  final breakEnd = _onDay(day, weekly?.breakEnd);
  if (breakStart == null ||
      breakEnd == null ||
      !breakEnd.isAfter(breakStart) ||
      !breakStart.isBefore(end) ||
      !breakEnd.isAfter(start)) {
    return [WorkingTimeRange(start, end)];
  }

  return [
    if (breakStart.isAfter(start))
      WorkingTimeRange(start, breakStart.isBefore(end) ? breakStart : end),
    if (breakEnd.isBefore(end))
      WorkingTimeRange(breakEnd.isAfter(start) ? breakEnd : start, end),
  ];
}

bool appointmentFitsWorkingTime(
  Schedule? schedule,
  DateTime start,
  int durationMinutes,
) {
  if (durationMinutes <= 0) return false;
  final end = start.add(Duration(minutes: durationMinutes));
  return workingTimeRanges(
    schedule,
    start,
  ).any((range) => !start.isBefore(range.start) && !end.isAfter(range.end));
}

DateTime? _onDay(DateTime day, String? time) {
  final parts = time?.split(':');
  if (parts == null || parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    return null;
  }
  return DateTime(day.year, day.month, day.day, hour, minute);
}
