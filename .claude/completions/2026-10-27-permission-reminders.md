# Periodic permission reminders

- Added a 30-second in-app reminder for signed-in users missing notification access, and calendar access for clients. It continues on pushed pages, pauses in the background, waits 30 seconds after dismissal, and stops showing once all needed permissions are granted.
- The dialog offers Later, Allow, and Settings. Allow uses the existing Firebase permission flow so push token registration is retried, and the calendar plugin requests full access for event reconciliation. Settings handles OS-level permanent denials.
- Verified with three permission widget tests (timing, role, navigation), related notification/calendar tests, targeted Flutter analysis, and an Android debug APK build.
