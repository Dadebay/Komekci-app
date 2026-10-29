part of 'client_bookings_provider.dart';

class ClientBookingsProvider extends SessionScoped {
  ClientBookingsProvider(
    this._repository, {
    AppointmentReminderScheduler? reminders,
    ClientCalendarService? calendar,
  }) : _reminders = reminders ?? AppointmentReminderScheduler(),
       _calendar = calendar ?? ClientCalendarService.instance;

  final ClientRepository _repository;
  final AppointmentReminderScheduler _reminders;
  final ClientCalendarService _calendar;
  int? _reminderUserId;
  bool _remindersEnabled = true;
  String _reminderLocale = 'tk';

  /// Pages read per list on a full load.
  static const _maxPages = 5;

  List<ClientBooking> _upcoming = const [];
  List<ClientBooking> _history = const [];
  String? _historyCursor;
  bool _loading = false;
  bool _loadingMore = false;
  ApiException? _error;

  List<ClientBooking> get bookings =>
      List.unmodifiable([..._upcoming, ..._history]);

  List<ClientBooking> get upcoming =>
      List.of(_upcoming)..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  List<ClientBooking> get history =>
      List.of(_history)..sort((a, b) => b.startsAt.compareTo(a.startsAt));

  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMoreHistory => _historyCursor != null;
  ApiException? get error => _error;

  /// Called when the account's notification preference or language changes.
  void configureReminders(Me? me) {
    final userId = me?.isMaster == true ? null : me?.id;
    final enabled = me?.notificationPrefs['reminders'] ?? true;
    final locale = me?.locale ?? 'tk';
    final sameUser = _reminderUserId == userId;
    if (sameUser && _remindersEnabled == enabled && _reminderLocale == locale) {
      return;
    }
    _reminderUserId = userId;
    _remindersEnabled = enabled;
    _reminderLocale = locale;
    if (sameUser) _syncReminders();
  }

  void _syncReminders() {
    unawaited(
      _reminders
          .sync(
            userId: _reminderUserId,
            bookings: [
              for (final booking in _upcoming)
                ReminderBooking(
                  id: booking.id,
                  masterName: booking.masterName,
                  serviceName: booking.serviceName,
                  startsAt: booking.startsAt,
                  active: booking.status == ClientBookingStatus.expected,
                ),
            ],
            enabled: _remindersEnabled,
            locale: _reminderLocale,
          )
          .catchError((Object error) {
            debugPrint('Could not update appointment reminders: $error');
          }),
    );
  }

  Future<CalendarSaveResult> saveToCalendar(ClientBooking booking) async {
    final userId = sessionUserId;
    if (userId == null) return CalendarSaveResult.unavailable;
    return _calendar.save(userId, booking.calendarDetails);
  }

  Future<void> openCalendarSettings() => _calendar.openSettings();

  void _syncCalendar() {
    if (!_calendar.isSupported) return;
    final userId = sessionUserId;
    if (userId == null) return;
    final upcoming = List<ClientBooking>.of(_upcoming);
    final history = List<ClientBooking>.of(_history);
    unawaited(() async {
      try {
        for (final booking in upcoming) {
          if (booking.status == ClientBookingStatus.expected) {
            await _calendar.reconcile(userId, booking.calendarDetails);
          }
        }
        for (final booking in history) {
          if (booking.status == ClientBookingStatus.cancelled) {
            await _calendar.remove(userId, booking.id);
          }
        }
      } catch (error) {
        debugPrint('Could not reconcile calendar bookings: $error');
      }
    }());
  }

  @override
  void reset() {
    _upcoming = const [];
    _history = const [];
    _historyCursor = null;
    _loading = _loadingMore = false;
    _error = null;
    unawaited(
      _reminders
          .sync(
            userId: null,
            bookings: const [],
            enabled: false,
            locale: _reminderLocale,
          )
          .catchError((Object error) {
            debugPrint('Could not clear appointment reminders: $error');
          }),
    );
  }

  @override
  Future<void> onSignedIn(Me me) async {
    if (!me.isMaster) {
      configureReminders(me);
      await load();
    }
  }

  Future<void> load() async {
    final userId = sessionUserId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final upcoming = <ClientBooking>[];
      String? cursor;
      var pages = 0;
      do {
        final page = await _repository.appointments(
          scope: 'upcoming',
          cursor: cursor,
        );
        upcoming.addAll(page.items.map(ClientBooking.fromApi));
        cursor = page.nextCursor;
      } while (cursor != null && ++pages < _maxPages);
      final history = await _repository.appointments(scope: 'history');
      if (sessionUserId != userId) return;
      _upcoming = upcoming;
      _history = history.items.map(ClientBooking.fromApi).toList();
      _historyCursor = history.nextCursor;
      _syncReminders();
      _syncCalendar();
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
      final page = await _repository.appointments(
        scope: 'history',
        cursor: cursor,
      );
      _history = [..._history, ...page.items.map(ClientBooking.fromApi)];
      _historyCursor = page.nextCursor;
      _syncCalendar();
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
    _syncReminders();
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
      for (final b in _upcoming)
        b.id == id ? b.copyWith(startsAt: startsAt) : b,
    ];
    notifyListeners();
    _syncReminders();
    _syncCalendar();
  }

  Future<void> setLate(String id, int minutes) async {
    await _repository.reportLate(int.parse(id), minutes);
    _upcoming = [
      for (final b in _upcoming)
        b.id == id ? b.copyWith(lateMinutes: minutes) : b,
    ];
    notifyListeners();
  }

  /// Books the same service again (`POST /appointments/{id}/rebook`).
  Future<ClientBooking> rebook(String id, {DateTime? startsAt}) async {
    final created = await _repository.rebook(int.parse(id), startsAt: startsAt);
    final booking = ClientBooking.fromApi(created);
    _upcoming = [..._upcoming.where((b) => b.id != booking.id), booking];
    notifyListeners();
    _syncReminders();
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
    _syncReminders();
    _syncCalendar();
  }
}
