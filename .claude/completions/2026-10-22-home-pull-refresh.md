# Home pull to refresh

- Added pull-to-refresh to both master and client home tabs, including short lists.
- Master refresh re-fetches the current calendar month, customers, schedule, billing, profile, and connection requests.
- Client refresh re-fetches bookings, connected masters, and notifications.
- `flutter analyze --no-pub lib` has no errors; only the existing two unused-element warnings in cabinet files remain.
