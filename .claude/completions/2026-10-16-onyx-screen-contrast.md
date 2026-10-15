# Onyx screen contrast

## Request
Fix widgets that stayed light or lost contrast in dark mode, specifically the Contact us card, Add client info card, and Calendar list.

## Cause and changes
- The master Support hero inverted `textPrimary` and `surface`. Onyx turns those values white and near-black, so the hero became a large white card. It now uses `surfaceElevated` and readable theme text on dark themes.
- The new customer info banner used a fixed pale blue fill and white icon circle. It now uses a theme accent tint and raised surface.
- Calendar free-slot rows used a fixed near-white green fill. A shared semantic free-slot surface/foreground now provides dark green-tinted rows in Onyx and preserves the light palette in other themes. The same treatment reaches the new-slot sheet and home timeline.
- Calendar appointment and customer status chips use dark theme semantic status colours and tinted backgrounds. The customer detail hero gradient no longer starts with a pale light-theme status colour.
- Replaced remaining fixed light surfaces or dark-only text in billing history, onboarding, role selection, login field hints, and the splash logo's fixed Ivory brand scene.
- Rebuilt the FAQ tile with a Material surface so the ExpansionTile can paint its ink correctly; a widget test exposed the existing assertion.

## Verification
- `flutter analyze --no-pub lib/app/komekci_app.dart lib/shared/utils/salon_colors.dart test/dark_theme_cards_test.dart`: no issues.
- `flutter test --no-pub`: all 8 tests passed, including checks for the Support hero, Add client banner, and dark Calendar free-slot palette.
- `flutter build apk --debug --no-pub`: successful.
- `adb install -r build/app/outputs/flutter-apk/app-debug.apk`: successful on the connected Android phone.
- `git diff --check`: clean.

## Limit
The final build was not navigated visually on the connected phone because the foreground app changed during the session.
