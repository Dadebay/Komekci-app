# Supplied logo on Flutter splash screen

- Copied the user's supplied KÖMEKÇI image into `assets/images/splash_logo.png`.
- Replaced the sparkles mark in the Flutter splash animation with this logo, kept the warm background and loading indicator, and removed the duplicate text wordmark beneath it.
- Removed the unused sparkles painter.

Verification: focused `flutter analyze`, `git diff --check`, and `flutter build apk --debug` passed. The app was not installed on a device in this task.
