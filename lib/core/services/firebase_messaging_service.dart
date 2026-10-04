import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notifications_service.dart';

typedef FcmTokenHandler = Future<void> Function(String token);
typedef FcmMessageHandler = void Function(RemoteMessage message);

class FirebaseMessagingService {
  FirebaseMessagingService({required this.onToken, this.onMessage});
  final FcmTokenHandler onToken;

  /// Fired for every message that carries a [RemoteMessage.notification] —
  /// while the app is foregrounded, when a background notification is
  /// tapped, and once at startup if the app was launched from a notification.
  final FcmMessageHandler? onMessage;

  /// Everyone who opens the app joins this topic; broadcasts are sent to it.
  static const topic = 'komekci';

  /// Long enough for a fresh install on a slow network.
  static const _apnsWait = Duration(seconds: 6);

  Future<void> initialize() async {
    await LocalNotificationsService.instance.initialize();
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // The OS already showed these in the notification tray — just record them.
    FirebaseMessaging.onMessageOpenedApp.listen(_recordMessage);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _recordMessage(initialMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
    // Not awaited: waiting for APNs can take seconds (and never ends on a
    // simulator), which must not hold up the splash screen.
    unawaited(_registerDevice());
  }

  /// Joins the broadcast [topic] and reports the device token.
  ///
  /// On iOS the FCM token and topic subscriptions both depend on the APNs
  /// token; asking before it exists returns null / throws, with no second
  /// attempt, so wait for it first.
  Future<void> _registerDevice() async {
    try {
      await _awaitApns();
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        developer.log('Subscribed to topic "$topic"', name: 'Komekci FCM');
      } on Object catch (e) {
        developer.log('Topic subscription failed: $e', name: 'Komekci FCM');
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        developer.log('FCM TOKEN: $token', name: 'Komekci FCM');
        _printToken(label: 'FCM TOKEN', token: token, ansiColor: '32');
        await onToken(token);
      } else {
        _printToken(label: 'FCM TOKEN', token: 'not available yet', ansiColor: '33');
      }
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        _printToken(label: 'APNS TOKEN', token: apnsToken ?? 'not available yet (physical iPhone + APNs setup required)', ansiColor: apnsToken == null ? '33' : '35');
      }
    } on Object catch (e) {
      developer.log('Push device registration failed: $e', name: 'Komekci FCM');
    }
  }

  /// Waits for APNs to hand iOS its device token, up to [_apnsWait]. A no-op
  /// on Android; on the simulator it simply runs out and push stays off.
  Future<void> _awaitApns() async {
    if (!Platform.isIOS) return;
    final deadline = DateTime.now().add(_apnsWait);
    while (DateTime.now().isBefore(deadline)) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    developer.log('APNs did not answer in ${_apnsWait.inSeconds}s', name: 'Komekci FCM');
  }

  void _printToken({required String label, required String token, required String ansiColor}) {
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
      LocalNotificationsService.instance.show(title: notification.title, body: notification.body, payload: message.data.toString());
    }
    _recordMessage(message);
  }

  void _recordMessage(RemoteMessage message) {
    if (message.notification != null) onMessage?.call(message);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  developer.log('Background message: ${message.messageId}', name: 'Komekci FCM');
}
