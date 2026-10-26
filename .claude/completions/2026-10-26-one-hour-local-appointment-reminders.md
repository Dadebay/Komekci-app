# One-hour local appointment reminders

- Client bookings in `expected` status now schedule one local notification one hour before their Ashgabat start time.
- The upcoming booking list reconciles pending reminders after booking, reload, reschedule, rebook, cancellation, waitlist move, preference change, and sign-out. A foreground push refreshes the list.
- Android manifest includes the scheduled notification and boot receivers. Scheduling uses `inexactAllowWhileIdle`; it does not claim alarm-clock precision or request special exact-alarm access.
- The existing client `reminders` notification preference controls local scheduling.
- A debug-only test action on the Notifications screen schedules the same local notification channel 30 seconds ahead, available to both client and master accounts.

Verification: `flutter analyze` on touched Dart files, `flutter test test/appointment_reminder_test.dart test/appointment_time_contract_test.dart`, and `flutter build apk --debug` all passed. Installed the debug APK on a connected Samsung A34 running Android 16. Its notification permission was granted; Android AlarmManager scheduled the debug reminder for 02:04:26 and fired it at 02:04:48. The notification appeared in NotificationManager's archive.
