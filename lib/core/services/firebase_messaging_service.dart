import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notifications_service.dart';

typedef FcmTokenHandler = Future<void> Function(String token);

class FirebaseMessagingService {
  FirebaseMessagingService({required this.onToken});
  final FcmTokenHandler onToken;

  Future<void> initialize() async {
    await LocalNotificationsService.instance.initialize();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      developer.log('FCM TOKEN: $token', name: 'Komekci FCM');
      _printToken(label: 'FCM TOKEN', token: token, ansiColor: '32');
      await onToken(token);
    } else {
      _printToken(
        label: 'FCM TOKEN',
        token: 'not available yet',
        ansiColor: '33',
      );
    }
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    developer.log(
      'APNS TOKEN: ${apnsToken ?? 'not available'}',
      name: 'Komekci FCM',
    );
    _printToken(
      label: 'APNS TOKEN',
      token:
          apnsToken ??
          'not available yet (physical iPhone + APNs setup required)',
      ansiColor: apnsToken == null ? '33' : '35',
    );
  }

  void _printToken({
    required String label,
    required String token,
    required String ansiColor,
  }) {
    // ANSI escapes render as coloured output in `flutter run` terminals.
    // ignore: avoid_print
    print('\x1B[1;${ansiColor}m╔══ KÖMEKÇI $label ══╗\x1B[0m');
    // ignore: avoid_print
    print('\x1B[${ansiColor}m$token\x1B[0m');
    // ignore: avoid_print
    print('\x1B[1;${ansiColor}m╚══════════════════════════════╝\x1B[0m');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      LocalNotificationsService.instance.show(
        title: notification.title,
        body: notification.body,
        payload: message.data.toString(),
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  developer.log(
    'Background message: ${message.messageId}',
    name: 'Komekci FCM',
  );
}
