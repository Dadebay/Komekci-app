# Master calendar closed times

- Connected the master Senenama timeline to `GET/POST/DELETE /api/me/closed-times` using Asia/Ashgabat timestamps.
- Tapping a free interval now offers booking a client or blocking the interval for private use. The block sheet accepts an optional private note and can extend the end time within the continuous free window.
- Blocked intervals appear in the calendar and can be reopened by tapping them. They are removed from locally shown free slots and from manual appointment eligibility; server availability remains authoritative for clients.
- Added a direct “Add working hours” action for the selected day. It uses the existing custom-hours override API, while personal blocks use the closed-times API.
- Home and day timelines show the same blocked intervals. Closed-time loading errors display a retry action instead of reopening free slots.

Verification: focused `flutter analyze` passed for changed feature files; `flutter test test/closed_times_test.dart` passed; `flutter build apk --debug` passed. Installed the APK on a connected Samsung A34, opened Senenama, created a 16:00–17:00 personal block, confirmed its calendar row, and reopened it successfully. No test block remains. Full-repository `flutter analyze` still reports pre-existing warnings in cabinet code and vendored `third_party` packages.
