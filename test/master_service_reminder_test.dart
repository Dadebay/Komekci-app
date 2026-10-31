import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komekci/core/services/local_notifications_service.dart';
import 'package:komekci/features/services/application/master_service_reminder_scheduler.dart';

class FakeNotifications implements LocalNotificationsService {
  final requests = <int, PendingNotificationRequest>{};
  final cancelled = <int>[];
  DateTime? scheduledFor;

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
  Future<void> scheduleMasterServiceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required String payload,
  }) async {
    scheduledFor = when;
    requests[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime startsAt,
    required String payload,
  }) async {}

  @override
  Future<void> show({String? title, String? body, String? payload}) async {}

  @override
  Future<void> scheduleTestNotification({
    required String title,
    required String body,
  }) async {}
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'registration schedules once for three days later and preserves deadline',
    () async {
      final notifications = FakeNotifications();
      var now = DateTime.utc(2030, 1, 1, 10);
      final scheduler = MasterServiceReminderScheduler(
        notifications: notifications,
        now: () => now,
      );

      await scheduler.registered(masterId: 15, locale: 'tk');
      expect(notifications.scheduledFor, DateTime.utc(2030, 1, 4, 10));
      expect(
        notifications.requests.values.single.payload,
        'komekci:master-service-reminder:15',
      );

      final originalId = notifications.requests.keys.single;
      await scheduler.sync(masterId: null, hasServices: false, locale: 'tk');
      expect(notifications.cancelled, contains(originalId));
      now = now.add(const Duration(days: 1));
      await scheduler.sync(masterId: 15, hasServices: false, locale: 'tk');
      expect(notifications.scheduledFor, DateTime.utc(2030, 1, 4, 10));
      expect(notifications.requests, hasLength(1));
    },
  );

  test('saving a service cancels reminder permanently', () async {
    final notifications = FakeNotifications();
    final scheduler = MasterServiceReminderScheduler(
      notifications: notifications,
      now: () => DateTime.utc(2030, 1, 1),
    );

    await scheduler.registered(masterId: 15, locale: 'en');
    expect(notifications.requests, hasLength(1));
    await scheduler.sync(masterId: 15, hasServices: true, locale: 'en');
    expect(notifications.requests, isEmpty);
    await scheduler.sync(masterId: 15, hasServices: false, locale: 'en');
    expect(notifications.requests, isEmpty);
  });
}
