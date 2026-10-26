import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/master_models.dart';
import '../../../data/models/api/json_helpers.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/master_repository.dart';

/// The master's availability rules, vacations, and one-off blocked times.
class ScheduleProvider extends SessionScoped {
  ScheduleProvider(this._repository);

  final MasterRepository _repository;

  Schedule? _schedule;
  final Map<String, List<ClosedTime>> _closedByDay = {};
  final Set<String> _closedDaysLoaded = {};
  final Set<String> _closedDaysLoading = {};
  final Map<String, ApiException> _closedErrors = {};
  bool _loading = false;
  ApiException? _error;

  Schedule? get schedule => _schedule;
  bool get loaded => _schedule != null;
  bool get loading => _loading;
  ApiException? get error => _error;

  List<ClosedTime> closedTimesOn(DateTime day) =>
      List.unmodifiable(_closedByDay[formatApiDate(day)] ?? const <ClosedTime>[]);

  bool closedTimesLoaded(DateTime day) => _closedDaysLoaded.contains(formatApiDate(day));
  ApiException? closedTimesError(DateTime day) => _closedErrors[formatApiDate(day)];

  bool hasClosedConflict(DateTime start, int minutes) {
    final end = start.add(Duration(minutes: minutes));
    return closedTimesOn(start).any(
      (closed) => start.isBefore(closed.endsAt) && closed.startsAt.isBefore(end),
    );
  }

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
    _closedByDay.clear();
    _closedDaysLoaded.clear();
    _closedDaysLoading.clear();
    _closedErrors.clear();
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (me.isMaster) {
      await Future.wait([load(), loadClosedTimes(DateTime.now())]);
    }
  }

  void prefetchClosedTimes(DateTime day) {
    final key = formatApiDate(day);
    if (_closedDaysLoaded.contains(key) ||
        _closedDaysLoading.contains(key) ||
        _closedErrors.containsKey(key)) {
      return;
    }
    Future.microtask(() => loadClosedTimes(day));
  }

  Future<void> loadClosedTimes(DateTime day, {bool force = false}) async {
    final key = formatApiDate(day);
    if (_closedDaysLoading.contains(key) || (!force && _closedDaysLoaded.contains(key))) return;
    final userId = sessionUserId;
    _closedDaysLoading.add(key);
    _closedErrors.remove(key);
    notifyListeners();
    try {
      final closed = await _repository.closedTimes(day);
      if (sessionUserId != userId) return;
      _closedByDay[key] = closed;
      _closedDaysLoaded.add(key);
    } on ApiException catch (error) {
      if (sessionUserId == userId) {
        _closedErrors[key] = error;
        debugPrint('Loading blocked time for $key failed: $error');
      }
    } finally {
      if (sessionUserId == userId) {
        _closedDaysLoading.remove(key);
        notifyListeners();
      }
    }
  }

  Future<ClosedTime> blockTime(DateTime start, DateTime end, {String? note}) async {
    final closed = await _repository.createClosedTime(start: start, end: end, note: note);
    final key = formatApiDate(start);
    _closedByDay[key] = [...?_closedByDay[key], closed];
    notifyListeners();
    return closed;
  }

  Future<void> reopenTime(ClosedTime closed) async {
    await _repository.deleteClosedTime(closed.id);
    final key = formatApiDate(closed.startsAt);
    _closedByDay[key] = [
      for (final item in _closedByDay[key] ?? const <ClosedTime>[])
        if (item.id != closed.id) item,
    ];
    notifyListeners();
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
