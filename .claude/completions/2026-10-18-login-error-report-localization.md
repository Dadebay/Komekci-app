# Login error report localization

- Updated the email error report action in Turkmen and Russian while preserving its English label.
- Completed Turkmen, Russian, and English translations for the login screen's welcome text, phone validation, OTP button, and terms text. English previously fell through to Russian in those places.
- Corrected the Turkmen fallback message shown when no email application is available.
- Verified with `flutter analyze --no-pub lib/app/komekci_app.dart` and `git diff --check`.
