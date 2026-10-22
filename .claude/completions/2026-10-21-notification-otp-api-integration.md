# Notification and OTP API integration check

- Confirmed existing public settings, contact, about, notification inbox, master send, device registration, guest topic, and OTP endpoints against the two supplied API documents.
- Removed FCM/APNs token logging. Firebase callbacks now retain long-lived providers after the splash route is disposed.
- Kept the platform permission prompt at startup while making it non-blocking. The iOS local notification plugin no longer prompts a second time during initialization.
- Serialized device registration with sign-out deletion, so an in-flight POST cannot re-register a signed-out device.
- Registration OTP resend now makes one registration request per tap. The message screen distinguishes inbox writes from confirmed pushes and explains rejected account IDs.
- Added focused API and sign-out ordering tests in `test/notification_api_contract_test.dart`.

Verification: `flutter test test/notification_api_contract_test.dart test/appointment_time_contract_test.dart` and targeted `dart analyze` passed. Full `flutter analyze` still reports pre-existing warnings in unrelated application files and bundled third-party packages. Device delivery and live SMS were not exercised on hardware.
