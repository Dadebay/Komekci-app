# KOMEKCI structure

Details and endpoint status: `.claude/completions/2026-10-03-api-integration.md`.

- `core/network` - `ApiClient` (Bearer, 401 refresh, multipart), `ApiException`, token storage, base URL
- `core/session` - `SessionScoped`: base for providers that belong to the signed-in account
- `core/theme`, `core/localization`, `core/services` - theme/language state, FCM, `DeviceRegistrar`
- `data/models/api` - API response models; `data/models` - UI models built from them
- `data/repositories` - one repository per endpoint group (auth, me, master, billing, client, settings)
- `features/*/application` - providers; they load on sign-in and reset on sign-out
- `features/*/presentation` - screens as `part` files of `app/komekci_app.dart`
- `shared` - reusable widgets, `api_errors.dart` (`apiErrorMessage`, `runApi`), `app_today.dart`

`app/komekci_app.dart` builds the provider tree: `ApiClient` -> repositories -> `AuthProvider`
-> data providers via `ChangeNotifierProxyProvider<AuthProvider, X>`.

All `DateTime`s are Asia/Ashgabat wall-clock time (UTC+5); see `data/models/api/json_helpers.dart`.
