import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/core/services/local_notifications_service.dart';
import 'package:komekci/features/booking/application/appointment_reminder_scheduler.dart';

class FakeNotifications implements LocalNotificationsService {
  final requests = <int, PendingNotificationRequest>{};
  final cancelled = <int>[];

  @override
  void Function(String payload)? onNotificationTap;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> notificationLaunchPayload() async => null;

  @override
  Future<List<PendingNotificationRequest>> pending() async =>
      requests.values.toList();

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    requests.remove(id);
  }

  @override
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime startsAt,
    required String payload,
  }) async {
    requests[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  Future<void> show({String? title, String? body, String? payload}) async {}

  @override
  Future<void> scheduleTestNotification({
    required String title,
    required String body,
  }) async {}
}

ReminderBooking booking(String id, DateTime start, {bool active = true}) =>
    ReminderBooking(
      id: id,
      masterName: 'Ayna',
      serviceName: 'Haircut',
      startsAt: start,
      active: active,
    );

void main() {
  test('10:00 Ashgabat appointment fires at 04:00 UTC, one hour before', () {
    final reminders = buildAppointmentReminders(
      userId: 7,
      bookings: [booking('42', DateTime(2030, 10, 26, 10))],
      locale: 'en',
      now: DateTime.utc(2030, 10, 26, 3),
    );
    expect(reminders, hasLength(1));
    expect(reminders.single.firesAtUtc, DateTime.utc(2030, 10, 26, 4));
    expect(reminders.single.body, contains('10:00'));
  });

  test('past, cancelled, and completed bookings do not produce reminders', () {
    final reminders = buildAppointmentReminders(
      userId: 7,
      bookings: [
        booking('1', DateTime(2030, 10, 26, 10)),
        booking('2', DateTime(2030, 10, 27, 10), active: false),
        booking('3', DateTime(2030, 10, 27, 11), active: false),
      ],
      locale: 'tk',
      now: DateTime.utc(2030, 10, 26, 4),
    );
    expect(reminders, isEmpty);
  });

  test(
    'reschedule replaces the old reminder; opt-out and sign-out clear it',
    () async {
      final notifications = FakeNotifications();
      final scheduler = AppointmentReminderScheduler(
        notifications: notifications,
      );
      final futureUtc = DateTime.now().toUtc().add(
        const Duration(days: 2, hours: 5),
      );
      final start = DateTime(
        futureUtc.year,
        futureUtc.month,
        futureUtc.day,
        futureUtc.hour,
      );
      final original = booking('42', start);
      final moved = booking('42', start.add(const Duration(hours: 2)));

      await scheduler.sync(
        userId: 7,
        bookings: [original],
        enabled: true,
        locale: 'en',
      );
      expect(notifications.requests, hasLength(1));
      final oldId = notifications.requests.keys.single;
      notifications.requests[123] = const PendingNotificationRequest(
        123,
        'Push',
        'Other',
        'fcm',
      );

      await scheduler.sync(
        userId: 7,
        bookings: [moved],
        enabled: true,
        locale: 'en',
      );
      expect(notifications.cancelled, contains(oldId));
      expect(
        notifications.requests.values.where(
          (item) => item.payload!.startsWith('komekci:'),
        ),
        hasLength(1),
      );

      await scheduler.sync(
        userId: 7,
        bookings: [moved],
        enabled: false,
        locale: 'en',
      );
      expect(notifications.requests.keys, [123]);

      await scheduler.sync(
        userId: 7,
        bookings: [moved],
        enabled: true,
        locale: 'en',
      );
      await scheduler.sync(
        userId: null,
        bookings: const [],
        enabled: false,
        locale: 'en',
      );
      expect(notifications.requests.keys, [123]);
    },
  );
}
