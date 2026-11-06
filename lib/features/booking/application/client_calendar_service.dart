import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum CalendarSaveResult { saved, permissionDenied, unavailable, failed }

@immutable
class CalendarBookingDetails {
  const CalendarBookingDetails({
    required this.id,
    required this.masterName,
    required this.serviceName,
    required this.startsAt,
    required this.endsAt,
    this.locale = 'tk',
  });

  final String id;
  final String masterName;
  final String serviceName;

  /// Asia/Ashgabat wall time, as returned by the appointment API.
  final DateTime startsAt;
  final DateTime endsAt;

  /// `tk`, `ru` or `en`: the language of the calendar texts.
  final String locale;

  CalendarBookingDetails withLocale(String value) => CalendarBookingDetails(
    id: id,
    masterName: masterName,
    serviceName: serviceName,
    startsAt: startsAt,
    endsAt: endsAt,
    locale: value,
  );

  String _pick({required String tk, required String ru, required String en}) =>
      switch (locale) {
        'ru' => ru,
        'en' => en,
        _ => tk,
      };

  static String _clock(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  /// The morning "you have an appointment today" entry, at 10:00 Ashgabat
  /// time on the appointment day. Only for bookings made for a later day, and
  /// only when the appointment is after 10:00. [nowAshgabat] is the current
  /// Ashgabat wall time.
  bool wantsDayPlanEntry(DateTime nowAshgabat) {
    final today = DateTime(
      nowAshgabat.year,
      nowAshgabat.month,
      nowAshgabat.day,
    );
    final day = DateTime(startsAt.year, startsAt.month, startsAt.day);
    return day.isAfter(today) &&
        startsAt.isAfter(DateTime(day.year, day.month, day.day, 10));
  }

  DateTime get dayPlanStart =>
      DateTime(startsAt.year, startsAt.month, startsAt.day, 10);
  DateTime get dayPlanEnd =>
      DateTime(startsAt.year, startsAt.month, startsAt.day, 10, 30);

  String get dayPlanTitle => _pick(
    tk: 'Şu gün ýazgyňyz bar — $masterName master',
    ru: 'Сегодня у вас запись — мастер $masterName',
    en: 'You have a booking today — $masterName',
  );

  String get dayPlanDescription {
    final start = _clock(startsAt);
    return _pick(
      tk: 'Şu gün sagat $start-da $masterName master bilen ýazgyňyz bar ($serviceName). Bellenen wagtyňyzda geliň.',
      ru: 'Сегодня в $start у вас запись к мастеру $masterName ($serviceName). Пожалуйста, приходите вовремя.',
      en: 'Today at $start you have a booking with $masterName ($serviceName). Please arrive on time.',
    );
  }

  String get title => '$serviceName — $masterName master';

  String get description {
    final months = locale == 'tk'
        ? const [
            'ýanwar',
            'fewral',
            'mart',
            'aprel',
            'maý',
            'iýun',
            'iýul',
            'awgust',
            'sentýabr',
            'oktýabr',
            'noýabr',
            'dekabr',
          ]
        : locale == 'ru'
        ? const [
            'января',
            'февраля',
            'марта',
            'апреля',
            'мая',
            'июня',
            'июля',
            'августа',
            'сентября',
            'октября',
            'ноября',
            'декабря',
          ]
        : const [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ];
    final start = _clock(startsAt);
    final day = '${startsAt.day} ${months[startsAt.month - 1]}';
    return '$day · $start–${_clock(endsAt)}\n'
        '${_pick(tk: 'Ýazgyňyz $start-da. Haýyş edýäris, bellenen wagtyňyzda geliň.', ru: 'Ваша запись в $start. Пожалуйста, приходите вовремя.', en: 'Your booking is at $start. Please arrive on time.')}';
  }

  String get signature => jsonEncode([
    // Bump when the way the event is laid out changes so already saved
    // events are rewritten on the next sync.
    'lead-1h-day',
    locale,
    title,
    startsAt.year,
    startsAt.month,
    startsAt.day,
    startsAt.hour,
    startsAt.minute,
    endsAt.year,
    endsAt.month,
    endsAt.day,
    endsAt.hour,
    endsAt.minute,
  ]);
}

/// A server appointment's Ashgabat wall clock converted into a real instant.
/// The native calendar then displays that instant in the phone's own zone.
@visibleForTesting
DateTime ashgabatTimeOnDevice(DateTime wallTime) => DateTime.utc(
  wallTime.year,
  wallTime.month,
  wallTime.day,
  wallTime.hour,
  wallTime.minute,
  wallTime.second,
).subtract(const Duration(hours: 5)).toLocal();

/// How long before the appointment its calendar event is placed. The event
/// itself sits this much earlier (15:00–15:40 shows as 14:00–14:40) and the
/// alert fires when it starts. The description keeps the real appointment time.
const calendarLead = Duration(hours: 1);

class _CalendarLink {
  const _CalendarLink(this.eventId, this.signature, [this.dayEventId]);
  final String eventId;
  final String signature;

  /// The morning "appointment today" entry, when one was created.
  final String? dayEventId;

  factory _CalendarLink.fromJson(String raw) {
    final value = jsonDecode(raw) as Map<String, dynamic>;
    return _CalendarLink(
      value['event_id'] as String,
      value['signature'] as String,
      value['day_event_id'] as String?,
    );
  }

  String toJson() => jsonEncode({
    'event_id': eventId,
    'signature': signature,
    if (dayEventId != null) 'day_event_id': dayEventId,
  });
}

/// Writes only appointments explicitly saved by this app. The stored native
/// event ID lets a later reschedule or cancellation update that same event.
class ClientCalendarService {
  ClientCalendarService({
    DeviceCalendar? calendar,
    FlutterSecureStorage? storage,
  }) : _calendar = calendar ?? DeviceCalendar.instance,
       _storage = storage ?? const FlutterSecureStorage();

  static final instance = ClientCalendarService();

  final DeviceCalendar _calendar;
  final FlutterSecureStorage _storage;
  Future<void> _queue = Future<void>.value();

  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  String _key(int userId, String bookingId) =>
      'komekci.calendar_booking.$userId.$bookingId';

  Future<T> _serialized<T>(Future<T> Function() work) {
    final result = _queue.then((_) => work());
    _queue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        debugPrint('Calendar sync failed: $error');
      },
    );
    return result;
  }

  Future<CalendarSaveResult> save(
    int userId,
    CalendarBookingDetails booking, {
    bool requestPermission = true,
  }) => _serialized(
    () => _save(userId, booking, requestPermission: requestPermission),
  );

  /// Reconciles only bookings previously added by this app; no permission
  /// dialog appears during background reloads or on a reschedule.
  Future<void> reconcile(int userId, CalendarBookingDetails booking) =>
      _serialized(() async {
        if (!isSupported) return;
        if (await _readLink(userId, booking.id) == null) return;
        await _save(userId, booking, requestPermission: false);
      });

  Future<void> remove(int userId, String bookingId) => _serialized(() async {
    if (!isSupported) return;
    final link = await _readLink(userId, bookingId);
    if (link == null || !await _hasFullPermission(request: false)) return;
    await _deleteEvent(link.eventId);
    final dayEventId = link.dayEventId;
    if (dayEventId != null) await _deleteEvent(dayEventId);
    await _storage.delete(key: _key(userId, bookingId));
  });

  Future<void> openSettings() => _calendar.openAppSettings();

  Future<CalendarSaveResult> _save(
    int userId,
    CalendarBookingDetails booking, {
    required bool requestPermission,
  }) async {
    if (!isSupported) return CalendarSaveResult.unavailable;
    try {
      if (!await _hasFullPermission(request: requestPermission)) {
        return CalendarSaveResult.permissionDenied;
      }
      final link = await _readLink(userId, booking.id);
      if (link != null && link.signature == booking.signature) {
        if (!requestPermission) return CalendarSaveResult.saved;
        try {
          if (await _calendar.getEvent(link.eventId) != null) {
            return CalendarSaveResult.saved;
          }
        } on DeviceCalendarException catch (error) {
          if (error.errorCode != DeviceCalendarError.notFound) rethrow;
        }
      }
      final start = ashgabatTimeOnDevice(
        booking.startsAt,
      ).subtract(calendarLead);
      final end = ashgabatTimeOnDevice(booking.endsAt).subtract(calendarLead);
      var eventId = link?.eventId;
      if (eventId != null) {
        try {
          await _calendar.updateEvent(
            instanceId: eventId,
            title: booking.title,
            startDate: start,
            endDate: end,
            description: Patch.set(booking.description),
            reminders: const Patch.set([Duration.zero]),
          );
        } on DeviceCalendarException catch (error) {
          if (error.errorCode != DeviceCalendarError.notFound) rethrow;
          eventId = null;
        }
      }
      eventId ??= await _calendar.createEvent(
        title: booking.title,
        startDate: start,
        endDate: end,
        description: booking.description,
        reminders: const [Duration.zero],
      );
      String? dayEventId;
      try {
        dayEventId = await _syncDayPlanEntry(booking, link?.dayEventId);
        await _writeLink(userId, booking, eventId, dayEventId);
      } catch (_) {
        // If we cannot remember the native IDs, remove what was just made so
        // a retry cannot create duplicate reminders.
        if (link == null || link.eventId != eventId) {
          await _deleteEvent(eventId);
        }
        if (dayEventId != null && dayEventId != link?.dayEventId) {
          await _deleteEvent(dayEventId);
        }
        rethrow;
      }
      return CalendarSaveResult.saved;
    } on DeviceCalendarException catch (error) {
      debugPrint('Could not save appointment to calendar: $error');
      return error.errorCode == DeviceCalendarError.permissionDenied
          ? CalendarSaveResult.permissionDenied
          : CalendarSaveResult.failed;
    } catch (error) {
      debugPrint('Could not save appointment to calendar: $error');
      return CalendarSaveResult.failed;
    }
  }

  /// Ashgabat wall clock right now (UTC+5, no DST).
  static DateTime get _nowAshgabat =>
      DateTime.now().toUtc().add(const Duration(hours: 5));

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _calendar.deleteEvent(instanceId: eventId);
    } on DeviceCalendarException catch (error) {
      if (error.errorCode != DeviceCalendarError.notFound) rethrow;
    }
  }

  /// Keeps the 10:00 "you have a booking today" entry in step with the
  /// booking: created or moved for a later day, removed when it no longer
  /// applies. Returns the entry's ID, or null when there is none.
  Future<String?> _syncDayPlanEntry(
    CalendarBookingDetails booking,
    String? existingId,
  ) async {
    if (!booking.wantsDayPlanEntry(_nowAshgabat)) {
      if (existingId != null) await _deleteEvent(existingId);
      return null;
    }
    final start = ashgabatTimeOnDevice(booking.dayPlanStart);
    final end = ashgabatTimeOnDevice(booking.dayPlanEnd);
    if (existingId != null) {
      try {
        await _calendar.updateEvent(
          instanceId: existingId,
          title: booking.dayPlanTitle,
          startDate: start,
          endDate: end,
          description: Patch.set(booking.dayPlanDescription),
          reminders: const Patch.set([Duration.zero]),
        );
        return existingId;
      } on DeviceCalendarException catch (error) {
        if (error.errorCode != DeviceCalendarError.notFound) rethrow;
      }
    }
    return _calendar.createEvent(
      title: booking.dayPlanTitle,
      startDate: start,
      endDate: end,
      description: booking.dayPlanDescription,
      reminders: const [Duration.zero],
    );
  }

  Future<bool> _hasFullPermission({required bool request}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    final status = request
        ? await _calendar.requestPermissions()
        : await _calendar.hasPermissions();
    return status == CalendarPermissionStatus.granted;
  }

  Future<_CalendarLink?> _readLink(int userId, String bookingId) async {
    final raw = await _storage.read(key: _key(userId, bookingId));
    if (raw == null) return null;
    try {
      return _CalendarLink.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeLink(
    int userId,
    CalendarBookingDetails booking,
    String eventId,
    String? dayEventId,
  ) => _storage.write(
    key: _key(userId, booking.id),
    value: _CalendarLink(eventId, booking.signature, dayEventId).toJson(),
  );
}
