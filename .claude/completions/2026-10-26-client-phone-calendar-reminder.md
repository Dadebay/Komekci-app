# Client bookings in the phone calendar

- Added `device_calendar_plus` for direct Android/iOS calendar events. A confirmed customer booking asks for calendar access, saves the service and master at the booked start/end time, and requests a reminder 60 minutes before start.
- Converted API Ashgabat wall time to the event's real instant so a phone in another time zone shows the corresponding local time.
- The booking success screen shows whether calendar save succeeded and offers permission settings or retry when needed. Existing upcoming bookings can also be added from their detail screen.
- Persisted each app-created native event ID per account and booking. Client booking reloads and reschedules update tracked events; cancellation removes them. Repeating the save avoids duplicate events. Calendar permission failure does not undo a server booking.
- Added Android calendar permissions and iOS calendar usage descriptions. The existing in-app one-hour local reminder remains active.

Verification: focused `flutter analyze`, `flutter test test/client_calendar_service_test.dart test/appointment_reminder_test.dart test/appointment_time_contract_test.dart`, and `flutter build apk --debug` passed. The user will test the native calendar flow on their device. An iOS build was started but interrupted before completion.
