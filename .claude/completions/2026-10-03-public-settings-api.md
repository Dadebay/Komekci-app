# Public settings API (GET /api/settings/public)

- `lib/core/network/api_config.dart` — base URL + timeout
- `lib/data/models/app_settings.dart` — model, `fallback` (20 TMT, tk/ru/en)
- `lib/data/repositories/settings_repository.dart` — `fetchPublic()` via `http`
- `lib/features/app/application/app_settings_provider.dart` — `monthlyFee`, `currency`, `currencyLabel(lang)`, `locales`, `load()` (never throws)
- Loaded in `SplashScreen._bootstrap`, in parallel with the 2.5s minimum splash.
- Replaced hardcoded `_monthlyFee`, "manat/TMT" labels, and the 3 language cards (now filtered by `locales`).
- Android main manifest now has `INTERNET` (was only in debug/profile).
- Not wired yet: `support_contact` (empty today), `_topUpAmounts` in `master_setup_shared.part.dart` is still `[20, 30, 40, 50]`.
- Tests: `test/app_settings_test.dart`
