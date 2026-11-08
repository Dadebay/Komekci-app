part of '../../../app/komekci_app.dart';

extension _SplashFirebaseSetup on _SplashScreenState {
  Future<void> _initializeFirebase() async {
    final devices = context.read<DeviceRegistrar>();
    final notifications = context.read<NotificationProvider>();
    final auth = context.read<AuthProvider>();
    final bookings = context.read<ClientBookingsProvider>();
    final masterBookings = context.read<BookingProvider>();
    final bookingAlerts = context.read<MasterBookingAlertController>();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseMessagingService(
        onToken: (token) async {
          devices.onToken(token);
        },
        onMessage: (message, {required bool openedFromTap}) {
          final notification = message.notification;
          if (notification == null || !auth.isSignedIn) return;
          notifications.add(
            title: notification.title ?? 'KÖMEKÇI',
            body: notification.body ?? '',
            data: message.data,
          );
          if (auth.isMaster) {
            final alert = MasterBookingAlert.fromPush(
              id: message.messageId ??
                  '${message.data['notification_id'] ?? message.data['appointment_id'] ?? DateTime.now().microsecondsSinceEpoch}',
              title: notification.title ?? '',
              body: notification.body ?? '',
              data: message.data,
            );
            if (alert != null) {
              bookingAlerts.show(alert, force: openedFromTap);
              unawaited(masterBookings.refresh());
            }
          } else {
            unawaited(bookings.load());
          }
        },
      ).initialize();
      await AnalyticsService(FirebaseAnalytics.instance).screen('splash');
    } catch (error) {
      debugPrint('Firebase bootstrap failed: $error');
    }
  }

}
