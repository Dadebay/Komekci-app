# Master new-booking popup

- New-booking pushes (`N-04`, supported event types, or the localized “Täze ýazgy” title) show a centered card above the current master screen. The card displays the push title/body and closes automatically after eight seconds or when dismissed.
- The refined card uses a compact calendar header, a readable booking-details panel, a localized timer caption, and an eight-second progress indicator. Long push text scrolls inside the card on compact phones.
- The alert waits until the master home exists, so a notification tap that launches the app shows the card after the splash screen. It also appears for foreground pushes and taps on their locally displayed Android notifications.
- Other notification events do not trigger the card. Duplicate delivery of the same push does not reopen it unless the user explicitly tapped its notification. A new booking refreshes the master calendar data.
- Firebase launch payloads are read even when the device has gone offline since receiving the notification.

Verification: `flutter test test/master_booking_alert_test.dart test/notification_api_contract_test.dart`, focused `flutter analyze`, `flutter build apk --debug`, and `git diff --check` passed. A widget render was inspected at phone size. Live push delivery was not exercised on a device.
