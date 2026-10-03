import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/session_scoped.dart';
import '../../../data/models/api/client_models.dart';
import '../../../data/models/api/master_models.dart';
import '../../../data/models/api/user_models.dart';
import '../../../data/repositories/client_repository.dart';

enum ClientBookingStatus { expected, completed, cancelled, noShow }

/// One of the client's own upcoming or past bookings, made with any master —
/// distinct from `Appointment`/`BookingProvider`, which model a single
/// master's day calendar of many different clients. A client's booking list
/// is inherently cross-master, so it needs its own shape and its own store.
class ClientBooking {
  const ClientBooking({
    required this.id,
    required this.masterId,
    required this.masterName,
    required this.serviceId,
    required this.serviceName,
    required this.startsAt,
    required this.minutes,
    required this.price,
    this.status = ClientBookingStatus.expected,
    this.note = '',
    this.lateMinutes,
    this.masterPhotoUrl,
    this.waitlistEarlier = false,
  });

  final String id;
  final int masterId;
  final String masterName;
  final String? masterPhotoUrl;
  final int serviceId;
  final String serviceName;
  final DateTime startsAt;
  final int minutes;
  final double price;
  final ClientBookingStatus status;
  final String note;
  final bool waitlistEarlier;

  /// 5 or 10 once the client has signalled they're running late; null
  /// otherwise. Sending again overwrites the previous value.
  final int? lateMinutes;

  DateTime get endsAt => startsAt.add(Duration(minutes: minutes));

  factory ClientBooking.fromApi(ClientAppointment a) => ClientBooking(
    id: '${a.id}',
    masterId: a.master.id,
    masterName: a.master.name,
    masterPhotoUrl: a.master.photoUrl,
    serviceId: a.service.id,
    serviceName: a.service.name,
    startsAt: a.startsAt,
    minutes: a.service.durationMin > 0
        ? a.service.durationMin
        : a.endsAt.difference(a.startsAt).inMinutes,
    price: a.service.price,
    status: switch (a.status) {
      ApiAppointmentStatus.expected => ClientBookingStatus.expected,
      ApiAppointmentStatus.completed => ClientBookingStatus.completed,
      ApiAppointmentStatus.cancelled => ClientBookingStatus.cancelled,
      ApiAppointmentStatus.noShow => ClientBookingStatus.noShow,
    },
    note: a.note ?? '',
    lateMinutes: a.lateMinutes,
    waitlistEarlier: a.waitlistEarlier,
  );

  ClientBooking copyWith({
    ClientBookingStatus? status,
    int? lateMinutes,
    DateTime? startsAt,
  }) => ClientBooking(
    id: id,
    masterId: masterId,
    masterName: masterName,
    masterPhotoUrl: masterPhotoUrl,
    serviceId: serviceId,
    serviceName: serviceName,
    startsAt: startsAt ?? this.startsAt,
    minutes: minutes,
    price: price,
    status: status ?? this.status,
    note: note,
    lateMinutes: lateMinutes ?? this.lateMinutes,
    waitlistEarlier: waitlistEarlier,
  );
}

/// The client's appointments (`/appointments`).
class ClientBookingsProvider extends SessionScoped {
  ClientBookingsProvider(this._repository);

  final ClientRepository _repository;

  /// Pages read per list on a full load.
  static const _maxPages = 5;

  List<ClientBooking> _upcoming = const [];
  List<ClientBooking> _history = const [];
  String? _historyCursor;
  bool _loading = false;
  bool _loadingMore = false;
  ApiException? _error;

  List<ClientBooking> get bookings => List.unmodifiable([..._upcoming, ..._history]);

  List<ClientBooking> get upcoming => List.of(_upcoming)..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  List<ClientBooking> get history => List.of(_history)..sort((a, b) => b.startsAt.compareTo(a.startsAt));

  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMoreHistory => _historyCursor != null;
  ApiException? get error => _error;

  @override
  void reset() {
    _upcoming = const [];
    _history = const [];
    _historyCursor = null;
    _loading = _loadingMore = false;
    _error = null;
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (!me.isMaster) await load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final upcoming = <ClientBooking>[];
      String? cursor;
      var pages = 0;
      do {
        final page = await _repository.appointments(scope: 'upcoming', cursor: cursor);
        upcoming.addAll(page.items.map(ClientBooking.fromApi));
        cursor = page.nextCursor;
      } while (cursor != null && ++pages < _maxPages);
      final history = await _repository.appointments(scope: 'history');
      _upcoming = upcoming;
      _history = history.items.map(ClientBooking.fromApi).toList();
      _historyCursor = history.nextCursor;
    } on ApiException catch (e) {
      _error = e;
      debugPrint('Loading client appointments failed: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMoreHistory() async {
    final cursor = _historyCursor;
    if (cursor == null || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final page = await _repository.appointments(scope: 'history', cursor: cursor);
      _history = [..._history, ...page.items.map(ClientBooking.fromApi)];
      _historyCursor = page.nextCursor;
    } on ApiException catch (e) {
      debugPrint('Loading more history failed: $e');
    }
    _loadingMore = false;
    notifyListeners();
  }

  /// Books a slot. [idempotencyKey] makes a retry after a lost response safe.
  /// Throws `SLOT_TAKEN` (with `suggestedSlots`), `NOT_CONNECTED`,
  /// `SUBSCRIPTION_SUSPENDED`, `PAST_TIME`, …
  Future<ClientBooking> book({
    required int serviceId,
    required DateTime startsAt,
    String? note,
    bool waitlistEarlier = false,
    String? idempotencyKey,
  }) async {
    final created = await _repository.book(
      serviceId: serviceId,
      startsAt: startsAt,
      note: note,
      waitlistEarlier: waitlistEarlier,
      idempotencyKey: idempotencyKey,
    );
    final booking = ClientBooking.fromApi(created);
    _upcoming = [..._upcoming.where((b) => b.id != booking.id), booking];
    notifyListeners();
    return booking;
  }

  Future<void> cancel(String id) async {
    await _repository.cancelAppointment(int.parse(id));
    _moveToHistory(id, ClientBookingStatus.cancelled);
  }

  /// Throws `SLOT_TAKEN` (with suggested slots) when the new time is busy.
  Future<void> reschedule(String id, DateTime startsAt) async {
    await _repository.moveAppointment(int.parse(id), startsAt);
    _upcoming = [
      for (final b in _upcoming) b.id == id ? b.copyWith(startsAt: startsAt) : b,
    ];
    notifyListeners();
  }

  Future<void> setLate(String id, int minutes) async {
    await _repository.reportLate(int.parse(id), minutes);
    _upcoming = [
      for (final b in _upcoming) b.id == id ? b.copyWith(lateMinutes: minutes) : b,
    ];
    notifyListeners();
  }

  /// Books the same service again (`POST /appointments/{id}/rebook`).
  Future<ClientBooking> rebook(String id, {DateTime? startsAt}) async {
    final created = await _repository.rebook(int.parse(id), startsAt: startsAt);
    final booking = ClientBooking.fromApi(created);
    _upcoming = [..._upcoming.where((b) => b.id != booking.id), booking];
    notifyListeners();
    return booking;
  }

  // ---- waitlist offers ---------------------------------------------------

  /// Moves a booking to the earlier slot the master freed up.
  Future<void> acceptWaitlistOffer(int offerId) async {
    await _repository.acceptWaitlistOffer(offerId);
    await load();
  }

  Future<void> declineWaitlistOffer(int offerId) =>
      _repository.declineWaitlistOffer(offerId);

  void _moveToHistory(String id, ClientBookingStatus status) {
    final index = _upcoming.indexWhere((b) => b.id == id);
    if (index == -1) return;
    final moved = _upcoming[index].copyWith(status: status);
    _upcoming = [..._upcoming]..removeAt(index);
    _history = [moved, ..._history];
    notifyListeners();
  }
}
