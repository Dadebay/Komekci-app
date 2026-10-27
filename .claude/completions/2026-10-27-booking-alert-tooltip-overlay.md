# Booking alert tooltip overlay fix

- Root cause: the booking alert is built in `MaterialApp.builder`, above the Navigator's Overlay. Its close `IconButton` tooltip therefore threw `No Overlay widget found` as soon as the alert appeared.
- Replaced the tooltip with a localized `Semantics` label on the close button. The close action and eight-second dismissal stay the same.
- Verified with `flutter test test/master_booking_alert_test.dart` (3 passed) and `flutter analyze lib/features/notifications/presentation/master_booking_alert_overlay.dart` (no issues).
