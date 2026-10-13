# Flutter API integration

- Pushed the previously uncommitted app work as `fe871cb` on `feature/api-integration` before editing the new API integration.
- Extended public settings parsing, caching, enabled language/theme handling, contact and About screens.
- Wired master personal notification sending to `POST /me/notifications/send` using numeric `account_id` when the backend provides it; the supplied `/me/clients` contract omits that field, so this flow remains partial pending backend confirmation or change.
- Replaced mock recipient lists with loaded customers and preserved the existing SMS option.
- Used server `retry_after` for sign-in, registration, and phone change OTP cooldowns. Prevented repeated submits while requests are active.
- Kept the existing FCM topic and device token flows, and guarded push listeners against duplicate registration.
- Added an importable Insomnia export and a per-endpoint status document.
- Verified public settings returned HTTP 200 with expected fields; `flutter analyze --no-pub lib test/app_settings_test.dart` passed; four Flutter tests passed with the required local `dot-shorthands` experiment flag.
