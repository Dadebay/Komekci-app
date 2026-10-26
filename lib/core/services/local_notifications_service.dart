import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  LocalNotificationsService._();
  static final instance = LocalNotificationsService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  static const _channel = AndroidNotificationChannel(
    'komekci_appointments',
    'Appointment notifications',
    description: 'Booking, reminder and waitlist notifications',
    importance: Importance.high,
  );

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    timezone_data.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> show({String? title, String? body, String? payload}) =>
      _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'komekci_appointments',
            'Appointment notifications',
            channelDescription: 'Booking, reminder and waitlist notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );

  Future<List<PendingNotificationRequest>> pending() async {
    await initialize();
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime startsAt,
    required String payload,
  }) async {
    await initialize();
    final ashgabat = tz.getLocation('Asia/Ashgabat');
    final start = tz.TZDateTime(
      ashgabat,
      startsAt.year,
      startsAt.month,
      startsAt.day,
      startsAt.hour,
      startsAt.minute,
    );
    await _schedule(
      id: id,
      title: title,
      body: body,
      when: start.subtract(const Duration(hours: 1)),
      payload: payload,
    );
  }

  /// Debug-only manual probe for the same scheduled notification channel.
  Future<void> scheduleTestNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    await _schedule(
      id: 99999,
      title: title,
      body: body,
      when: tz.TZDateTime.now(
        tz.getLocation('Asia/Ashgabat'),
      ).add(const Duration(seconds: 30)),
      payload: 'komekci:test-reminder',
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required String payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'komekci_appointments',
          'Appointment notifications',
          channelDescription: 'Booking, reminder and waitlist notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }
}
