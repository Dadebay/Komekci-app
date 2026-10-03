import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/master_models.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/models/appointment.dart';
import '../../../data/repositories/master_repository.dart';

/// The master's calendar (`GET /me/calendar`), cached month by month.
///
/// Reads are synchronous over whatever is cached so list/timeline widgets
/// stay simple; call [ensureLoaded] for the month a screen is about to show.
/// Every change is sent to the server first and the cache is updated from its
/// answer, so the server stays the authority on what is booked.
class BookingProvider extends SessionScoped {
  BookingProvider(this._repository);

  final MasterRepository _repository;

  final Map<String, Appointment> _byId = {};
  final Set<String> _loadedMonths = {};
  final Set<String> _inFlightMonths = {};
  final Set<String> _arrived = {};
  bool _loading = false;
  ApiException? _error;

  List<Appointment> get appointments =>
      List.unmodifiable(_byId.values.map(_withLocalState));
  List<Appointment> get active => [
    for (final a in appointments)
      if (a.status == AppointmentStatus.expected || a.status == AppointmentStatus.arrived) a,
  ];
  List<Appointment> get history => [
    for (final a in appointments)
      if (a.status != AppointmentStatus.expected && a.status != AppointmentStatus.arrived) a,
  ];
  bool get loading => _loading;
  ApiException? get error => _error;

  Appointment _withLocalState(Appointment a) =>
      a.status == AppointmentStatus.expected && _arrived.contains(a.id)
      ? a.copyWith(status: AppointmentStatus.arrived)
      : a;

  List<Appointment> onDay(DateTime day) =>
      appointments
          .where(
            (a) =>
                a.startsAt.year == day.year &&
                a.startsAt.month == day.month &&
                a.startsAt.day == day.day,
          )
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  /// True when [start]..[start]+[minutes] overlaps an existing, non-cancelled
  /// appointment. A convenience for the UI; the server has the final say and
  /// answers `SLOT_TAKEN` if the slot went in the meantime.
  bool hasConflict(DateTime start, int minutes, {String? excludeId}) {
    final end = start.add(Duration(minutes: minutes));
    for (final a in _byId.values) {
      if (a.id == excludeId ||
          a.status == AppointmentStatus.cancelled ||
          a.status == AppointmentStatus.noShow) {
        continue;
      }
      if (start.isBefore(a.endsAt) && a.startsAt.isBefore(end)) return true;
    }
    return false;
  }

  @override
  void reset() {
    _byId.clear();
    _loadedMonths.clear();
    _inFlightMonths.clear();
    _arrived.clear();
    _loading = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (!me.isMaster) return;
    final now = DateTime.now();
    await Future.wait([
      ensureLoaded(now),
      ensureLoaded(DateTime(now.year, now.month + 1)),
      ensureLoaded(DateTime(now.year, now.month - 1)),
    ]);
  }

  static String _key(DateTime d) => '${d.year}-${d.month}';

  /// Loads the whole month containing [day] unless it is already cached.
  Future<void> ensureLoaded(DateTime day) => _loadMonth(day, force: false);

  /// [ensureLoaded] that is safe to call from a widget's `build`: the work
  /// starts after the current frame, so listeners may be notified.
  void prefetch(DateTime day) {
    if (_loadedMonths.contains(_key(day)) || _inFlightMonths.contains(_key(day))) return;
    Future.microtask(() => ensureLoaded(day));
  }

  /// Re-reads every month seen so far (pull-to-refresh, after a push).
  Future<void> refresh() async {
    final months = {..._loadedMonths};
    _loadedMonths.clear();
    for (final key in months) {
      final parts = key.split('-');
      await _loadMonth(DateTime(int.parse(parts[0]), int.parse(parts[1])), force: true);
    }
  }

  Future<void> _loadMonth(DateTime day, {required bool force}) async {
    final key = _key(day);
    if (!force && (_loadedMonths.contains(key) || _inFlightMonths.contains(key))) return;
    _inFlightMonths.add(key);
    _loading = true;
    _error = null;
    notifyListeners();
    final from = DateTime(day.year, day.month);
    final to = DateTime(day.year, day.month + 1, 0);
    try {
      final fetched = await _repository.calendar(from, to);
      final monthEnd = DateTime(to.year, to.month, to.day + 1);
      // Replace what we had for this month so cancelled/removed rows vanish.
      _byId.removeWhere(
        (_, a) => !a.startsAt.isBefore(from) && a.startsAt.isBefore(monthEnd),
      );
      for (final a in fetched) {
        final appointment = Appointment.fromApi(a);
        _byId[appointment.id] = appointment;
      }
      _loadedMonths.add(key);
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading calendar for $key failed: $e');
    }
    _inFlightMonths.remove(key);
    _loading = _inFlightMonths.isNotEmpty;
    notifyListeners();
  }

  /// Books a client in. [phone] links the booking to a connected client with
  /// that number; otherwise an offline client is created. Throws
  /// `SLOT_TAKEN` (with `suggestedSlots`), `SUBSCRIPTION_SUSPENDED`,
  /// `PAST_TIME`, `OUTSIDE_WORKING_HOURS`.
  Future<Appointment> create({
    required int serviceId,
    required String clientName,
    required DateTime startsAt,
    String? phone,
  }) async {
    final created = await _repository.createAppointment(
      name: clientName,
      phone: phone,
      serviceId: serviceId,
      startsAt: startsAt,
    );
    final appointment = Appointment.fromApi(created);
    _byId[appointment.id] = appointment;
    notifyListeners();
    return appointment;
  }

  Future<void> complete(String id) => _setStatus(id, ApiAppointmentStatus.completed, AppointmentStatus.completed);

  Future<void> markNoShow(String id) => _setStatus(id, ApiAppointmentStatus.noShow, AppointmentStatus.noShow);

  Future<void> cancel(String id) => _setStatus(id, ApiAppointmentStatus.cancelled, AppointmentStatus.cancelled);

  /// Client has arrived. Only remembered on this device — the API has no such
  /// status; the booking stays `expected` on the server until completed.
  void arrive(String id) {
    _arrived.add(id);
    notifyListeners();
  }

  Future<void> _setStatus(String id, ApiAppointmentStatus wire, AppointmentStatus local) async {
    await _repository.setAppointmentStatus(int.parse(id), wire);
    _arrived.remove(id);
    _replace(id, (a) => a.copyWith(status: local));
  }

  /// Throws `SLOT_TAKEN` (with suggested slots) when the new time is busy.
  Future<void> reschedule(String id, DateTime startsAt) async {
    await _repository.moveAppointment(int.parse(id), startsAt);
    _replace(id, (a) => a.copyWith(startsAt: startsAt));
  }

  void _replace(String id, Appointment Function(Appointment) transform) {
    final current = _byId[id];
    if (current == null) return;
    _byId[id] = transform(current);
    notifyListeners();
  }
}
