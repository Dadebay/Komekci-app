# KOMEKCI MVP structure

- `core/theme` - theme state and design tokens
- `data/models` - API-compatible domain models
- `data/repositories` - mock repositories; Laravel repository replaces these later
- `features/auth/application` - authentication and role state
- `features/booking/application` - appointments and booking mutations
- `features/splash/presentation` - network-aware animated splash screen
- `features/onboarding/presentation` - role-specific onboarding and shared action button
- `features/home/presentation` - client/master navigation shells, dashboards and lists
- `features/appointments/presentation` - appointment details, requests, billing and settings
- `features/auth/presentation` - language selection, login, OTP and registration flows
- `shared/widgets` - reusable UI components

Presentation files are Dart `part` files of `main.dart`: they share the MVP's
existing app-level state and design tokens while keeping every screen group below
500 lines. New feature work can progressively move shared widgets and providers
to their own imported libraries without changing the screen flow.

The UI currently uses the mock repositories through Provider. Laravel integration should implement the same repository contracts and replace the registered mocks in `main.dart`.
