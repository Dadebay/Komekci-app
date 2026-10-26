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
  });

  final String id;
  final String masterName;
  final String serviceName;

  /// Asia/Ashgabat wall time, as returned by the appointment API.
  final DateTime startsAt;
  final DateTime endsAt;

  String get title => '$serviceName · $masterName';

  String get signature => jsonEncode([
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

class _CalendarLink {
  const _CalendarLink(this.eventId, this.signature);
  final String eventId;
  final String signature;

  factory _CalendarLink.fromJson(String raw) {
    final value = jsonDecode(raw) as Map<String, dynamic>;
    return _CalendarLink(
      value['event_id'] as String,
      value['signature'] as String,
    );
  }

  String toJson() => jsonEncode({'event_id': eventId, 'signature': signature});
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
    try {
      await _calendar.deleteEvent(instanceId: link.eventId);
    } on DeviceCalendarException catch (error) {
      if (error.errorCode != DeviceCalendarError.notFound) rethrow;
    }
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
      final start = ashgabatTimeOnDevice(booking.startsAt);
      final end = ashgabatTimeOnDevice(booking.endsAt);
      if (link != null) {
        try {
          await _calendar.updateEvent(
            instanceId: link.eventId,
            title: booking.title,
            startDate: start,
            endDate: end,
            reminders: const Patch.set([Duration(hours: 1)]),
          );
          await _writeLink(userId, booking, link.eventId);
          return CalendarSaveResult.saved;
        } on DeviceCalendarException catch (error) {
          if (error.errorCode != DeviceCalendarError.notFound) rethrow;
        }
      }
      final eventId = await _calendar.createEvent(
        title: booking.title,
        startDate: start,
        endDate: end,
        description: 'KÖMEKÇI',
        reminders: const [Duration(hours: 1)],
      );
      try {
        await _writeLink(userId, booking, eventId);
      } catch (_) {
        // If we cannot remember the native ID, remove the event so a retry
        // cannot create a duplicate reminder.
        await _calendar.deleteEvent(instanceId: eventId);
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
  ) => _storage.write(
    key: _key(userId, booking.id),
    value: _CalendarLink(eventId, booking.signature).toJson(),
  );
}
