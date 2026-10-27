import 'dart:io' show Platform;

import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/firebase_messaging_service.dart';

class MissingAppPermissions {
  const MissingAppPermissions({
    required this.notifications,
    required this.calendar,
  });

  final bool notifications;
  final bool calendar;

  bool get any => notifications || calendar;
}

abstract interface class RequiredPermissions {
  Future<MissingAppPermissions> missing({required bool needsCalendar});
  Future<void> request(MissingAppPermissions permissions);
  Future<void> openSettings();
}

class DeviceRequiredPermissions implements RequiredPermissions {
  const DeviceRequiredPermissions();

  @override
  Future<MissingAppPermissions> missing({required bool needsCalendar}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const MissingAppPermissions(notifications: false, calendar: false);
    }
    final notificationStatus =
        (await FirebaseMessaging.instance.getNotificationSettings())
            .authorizationStatus;
    final calendarStatus = needsCalendar
        ? await DeviceCalendar.instance.hasPermissions()
        : CalendarPermissionStatus.granted;
    return MissingAppPermissions(
      notifications: notificationStatus != AuthorizationStatus.authorized,
      // Write-only access cannot reconcile moved or cancelled bookings.
      calendar: calendarStatus != CalendarPermissionStatus.granted,
    );
  }

  @override
  Future<void> request(MissingAppPermissions permissions) async {
    if (permissions.notifications) {
      await FirebaseMessagingService.requestNotificationPermission();
    }
    if (permissions.calendar) {
      await DeviceCalendar.instance.requestPermissions();
    }
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
