import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/local_notifications_service.dart';

@immutable
class ReminderBooking {
  const ReminderBooking({
    required this.id,
    required this.masterName,
    required this.serviceName,
    required this.startsAt,
    required this.active,
  });

  final String id;
  final String masterName;
  final String serviceName;
  final DateTime startsAt;
  final bool active;
}

/// Reconciles this device's one-hour reminders with the server's upcoming list.
/// The appointment API exposes Ashgabat wall time even on phones in other zones.
class AppointmentReminderScheduler {
  AppointmentReminderScheduler({LocalNotificationsService? notifications})
    : _notifications = notifications ?? LocalNotificationsService.instance;

  final LocalNotificationsService _notifications;
  Future<void> _queue = Future<void>.value();

  static const _prefix = 'komekci:appointment-reminder:';
  static const _ashgabatOffset = Duration(hours: 5);
  static const _leadTime = Duration(hours: 1);
  // iOS keeps only the last 64 pending local notifications.
  static const _maxPending = 60;

  Future<void> sync({
    required int? userId,
    required List<ReminderBooking> bookings,
    required bool enabled,
    required String locale,
  }) {
    final snapshot = List<ReminderBooking>.of(bookings);
    final result = _queue.then(
      (_) => _sync(
        userId: userId,
        bookings: snapshot,
        enabled: enabled,
        locale: locale,
      ),
    );
    _queue = result.catchError((Object error, StackTrace stack) {
      debugPrint('Appointment reminder sync failed: $error');
    });
    return result;
  }

  Future<void> _sync({
    required int? userId,
    required List<ReminderBooking> bookings,
    required bool enabled,
    required String locale,
  }) async {
    final now = DateTime.now().toUtc();
    final desired = userId == null || !enabled
        ? <AppointmentReminder>[]
        : buildAppointmentReminders(
            userId: userId,
            bookings: bookings,
            locale: locale,
            now: now,
          );
    final byPayload = {
      for (final reminder in desired) reminder.payload: reminder,
    };
    final pending = await _notifications.pending();
    final active = <String>{};
    for (final item in pending) {
      final payload = item.payload;
      if (payload == null || !payload.startsWith(_prefix)) continue;
      final wanted = byPayload[payload];
      if (wanted == null || wanted.id != item.id) {
        await _notifications.cancel(item.id);
      } else {
        active.add(payload);
      }
    }
    for (final reminder in desired) {
      if (active.contains(reminder.payload)) continue;
      await _notifications.scheduleAppointmentReminder(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        startsAt: reminder.startsAt,
        payload: reminder.payload,
      );
    }
  }
}

@immutable
class AppointmentReminder {
  const AppointmentReminder({
    required this.id,
    required this.payload,
    required this.startsAt,
    required this.firesAtUtc,
    required this.title,
    required this.body,
  });

  final int id;
  final String payload;
  final DateTime startsAt;
  final DateTime firesAtUtc;
  final String title;
  final String body;
}

/// Pure scheduling plan: one reminder per future, expected appointment.
@visibleForTesting
List<AppointmentReminder> buildAppointmentReminders({
  required int userId,
  required List<ReminderBooking> bookings,
  required String locale,
  required DateTime now,
}) {
  final reminders = <AppointmentReminder>[];
  for (final booking in bookings) {
    if (!booking.active) continue;
    final start = booking.startsAt;
    final firesAt =
        DateTime.utc(
          start.year,
          start.month,
          start.day,
          start.hour,
          start.minute,
        ).subtract(
          AppointmentReminderScheduler._ashgabatOffset +
              AppointmentReminderScheduler._leadTime,
        );
    if (!firesAt.isAfter(now.toUtc())) continue;
    final payload =
        '${AppointmentReminderScheduler._prefix}$userId:${booking.id}:${start.millisecondsSinceEpoch}:$locale';
    final time =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final (title, body) = switch (locale) {
      'ru' => (
        'Напоминание о записи',
        'Через час у вас запись к ${booking.masterName} на $time: ${booking.serviceName}.',
      ),
      'en' => (
        'Appointment reminder',
        'Your ${booking.serviceName} appointment with ${booking.masterName} is at $time, in one hour.',
      ),
      _ => (
        'Ýazgy ýatlatmasy',
        '${booking.masterName} bilen ${booking.serviceName} hyzmatyna ýazgyňyz $time-da. 1 sagat galdy.',
      ),
    };
    reminders.add(
      AppointmentReminder(
        id: _notificationId(payload),
        payload: payload,
        startsAt: start,
        firesAtUtc: firesAt,
        title: title,
        body: body,
      ),
    );
  }
  reminders.sort((a, b) => a.firesAtUtc.compareTo(b.firesAtUtc));
  return reminders.take(AppointmentReminderScheduler._maxPending).toList();
}

int _notificationId(String payload) {
  var hash = 0x811c9dc5;
  for (final unit in payload.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }
  // Foreground FCM notifications currently use IDs below 100000.
  return 100000 + hash % (0x7fffffff - 100000);
}
