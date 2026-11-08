part of '../../../app/komekci_app.dart';

sealed class _TimelineEntry {}

class _ApptEntry extends _TimelineEntry {
  _ApptEntry(this.appointment);
  final Appointment appointment;
}

class _FreeEntry extends _TimelineEntry {
  _FreeEntry(this.start, this.end, this.availableEnd);
  final DateTime start;
  final DateTime end;
  final DateTime availableEnd;
}

class _ClosedEntry extends _TimelineEntry {
  _ClosedEntry(this.closed);
  final ClosedTime closed;
}

/// Fills gaps between appointments only inside the server's working windows.
/// Free time is displayed in one-hour chunks for the timeline.
List<_TimelineEntry> _buildTimeline(
  List<Appointment> appointments,
  DateTime day,
  Schedule? schedule, {
  List<ClosedTime> closedTimes = const [],
}) {
  final entries = <_TimelineEntry>[
    for (final appointment in appointments) _ApptEntry(appointment),
    for (final closed in closedTimes) _ClosedEntry(closed),
  ];

  void addFreeChunks(DateTime start, DateTime end) {
    var chunkStart = start;
    while (chunkStart.isBefore(end)) {
      final chunkEnd = chunkStart.add(const Duration(hours: 1));
      entries.add(
        _FreeEntry(chunkStart, chunkEnd.isBefore(end) ? chunkEnd : end, end),
      );
      chunkStart = chunkEnd;
    }
  }

  final busy = <(DateTime, DateTime)>[
    for (final appointment in appointments)
      if (appointment.status != AppointmentStatus.cancelled &&
          appointment.status != AppointmentStatus.noShow)
        (appointment.startsAt, appointment.endsAt),
    for (final closed in closedTimes) (closed.startsAt, closed.endsAt),
  ]..sort((a, b) => a.$1.compareTo(b.$1));

  for (final window in workingTimeRanges(schedule, day)) {
    var cursor = window.start;
    for (final (start, end) in busy) {
      if (!start.isBefore(window.end) || !end.isAfter(window.start)) {
        continue;
      }
      if (start.isAfter(cursor)) {
        addFreeChunks(
          cursor,
          start.isBefore(window.end) ? start : window.end,
        );
      }
      if (end.isAfter(cursor)) cursor = end;
    }
    if (window.end.isAfter(cursor)) addFreeChunks(cursor, window.end);
  }

  entries.sort((a, b) {
    DateTime startOf(_TimelineEntry entry) => switch (entry) {
      _ApptEntry(:final appointment) => appointment.startsAt,
      _ClosedEntry(:final closed) => closed.startsAt,
      _FreeEntry(:final start) => start,
    };
    final aStart = startOf(a);
    final bStart = startOf(b);
    return aStart.compareTo(bStart);
  });
  return entries;
}
