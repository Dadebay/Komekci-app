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
  static FirebaseMessagingService? _active;
  static bool _listenersRegistered = false;
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
    _active = this;
    await LocalNotificationsService.instance.initialize();
    // Keep the existing startup permission request, but never let an OS
    // prompt or a refusal hold up sign-in or topic subscription.
    unawaited(_requestPermission());
    if (!_listenersRegistered) {
      _listenersRegistered = true;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(
        (message) => _active?._handleForegroundMessage(message),
      );
      // The OS already showed these in the notification tray — just record them.
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _active?._recordMessage(message),
      );
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) => _active?.onToken(token),
      );
    }
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _recordMessage(initialMessage);
    // Not awaited: waiting for APNs can take seconds (and never ends on a
    // simulator), which must not hold up the splash screen.
    unawaited(_registerDevice());
  }

  Future<void> _requestPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _registerDevice();
      }
    } on Object catch (e) {
      developer.log(
        'Notification permission request failed: $e',
        name: 'Komekci FCM',
      );
    }
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
        await onToken(token);
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
    developer.log(
      'APNs did not answer in ${_apnsWait.inSeconds}s',
      name: 'Komekci FCM',
    );
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
    _recordMessage(message);
  }

  void _recordMessage(RemoteMessage message) {
    if (message.notification != null) onMessage?.call(message);
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
