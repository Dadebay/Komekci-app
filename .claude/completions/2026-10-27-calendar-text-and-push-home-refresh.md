# Calendar text and master home refresh on booking push

- Client calendar entries now use `Service — Master master` as their title. The description includes the Ashgabat date and time range plus the requested Turkmen arrival reminder. Both newly created and previously linked events receive the description when updated; the one-hour native calendar reminder remains in place.
- The master dashboard listens for a visible new-booking alert and refreshes its customer, schedule, billing, profile, and request data with the existing pull-to-refresh animation. The FCM handler still refreshes booked appointments, avoiding a second calendar request from the dashboard.
- Verified with `flutter test test/client_calendar_service_test.dart test/home_refresh_data_test.dart test/master_booking_alert_test.dart` (9 passing), targeted `flutter analyze` (no issues), and `flutter build apk --debug` (success).
