import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/master_models.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/master_repository.dart';

/// The master's availability rules (`/me/schedule`, `/me/vacations`):
/// weekly hours, one-off day-offs/custom hours and vacations.
class ScheduleProvider extends SessionScoped {
  ScheduleProvider(this._repository);

  final MasterRepository _repository;

  Schedule? _schedule;
  bool _loading = false;
  ApiException? _error;

  Schedule? get schedule => _schedule;
  bool get loaded => _schedule != null;
  bool get loading => _loading;
  ApiException? get error => _error;

  /// Seven entries, Monday (0) to Sunday (6).
  List<ScheduleDay> get days {
    final list = [...?_schedule?.days]..sort((a, b) => a.weekday.compareTo(b.weekday));
    return list;
  }

  List<ScheduleOverride> get overrides =>
      [...?_schedule?.overrides]..sort((a, b) => a.date.compareTo(b.date));

  /// Days the master closed completely.
  List<ScheduleOverride> get daysOff => [
    for (final o in overrides)
      if (o.type == OverrideType.dayOff) o,
  ];

  List<Vacation> get vacations =>
      [...?_schedule?.vacations]..sort((a, b) => a.start.compareTo(b.start));

  /// The vacation running today or the next one coming up.
  Vacation? get nextVacation {
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);
    for (final v in vacations) {
      if (!v.end.isBefore(midnight)) return v;
    }
    return null;
  }

  @override
  void reset() {
    _schedule = null;
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _schedule = await _repository.schedule();
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading schedule failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  /// Replaces the whole week. Throws `ApiException` (e.g. `VALIDATION`).
  Future<void> saveWeek(List<ScheduleDay> days) async {
    _schedule = await _repository.saveSchedule(days);
    notifyListeners();
  }

  Future<void> addDayOff(DateTime date) => _addOverride(date, OverrideType.dayOff);

  Future<void> addCustomHours(DateTime date, String start, String end) =>
      _addOverride(date, OverrideType.customHours, start: start, end: end);

  Future<void> _addOverride(
    DateTime date,
    OverrideType type, {
    String? start,
    String? end,
  }) async {
    final created = await _repository.addOverride(
      date: date,
      type: type,
      startTime: start,
      endTime: end,
    );
    _withSchedule((s) => _copy(s, overrides: [...s.overrides, created]));
  }

  Future<void> removeOverride(int id) async {
    await _repository.deleteOverride(id);
    _withSchedule(
      (s) => _copy(s, overrides: [for (final o in s.overrides) if (o.id != id) o]),
    );
  }

  Future<void> addVacation(DateTime start, DateTime end) async {
    final created = await _repository.addVacation(start, end);
    _withSchedule((s) => _copy(s, vacations: [...s.vacations, created]));
  }

  Future<void> removeVacation(int id) async {
    await _repository.deleteVacation(id);
    _withSchedule(
      (s) => _copy(s, vacations: [for (final v in s.vacations) if (v.id != id) v]),
    );
  }

  void _withSchedule(Schedule Function(Schedule) change) {
    final current = _schedule;
    if (current == null) return;
    _schedule = change(current);
    notifyListeners();
  }

  Schedule _copy(Schedule s, {List<ScheduleOverride>? overrides, List<Vacation>? vacations}) =>
      Schedule(
        gridStepMin: s.gridStepMin,
        minLeadMin: s.minLeadMin,
        days: s.days,
        overrides: overrides ?? s.overrides,
        vacations: vacations ?? s.vacations,
      );
}
