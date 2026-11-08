# Theme consistency and bottom navigation

## Request
Changing appearance did not visibly update every main screen or the selected bottom navigation tab.

## Cause
The root `ThemeProvider` already rebuilt `MaterialApp`, but several master Home and Cabinet widgets still painted fixed white, cream, brown, and black colours. The selected docked navigation slot used a very faint accent tint. The Onyx theme's white check mark disappeared on a white selection circle.

## Changes
- Applied theme tokens to the master Home background, hero, balance and contact chips, stat cards, timeline card, queue header, and edit button.
- Applied theme tokens to shared Cabinet surfaces, avatar and photo placeholders, and secondary text in relevant schedule, customer, service, and notification screens.
- Made the docked navigation selection an opaque accent pill with contrasting icon and legible selected label; the floating bar now uses the current theme surface.
- Made the selected theme swatch indicator contrast correctly for all four themes.
- Added a widget regression test that changes the theme from Ivory to Onyx to Rose and checks the selected bottom navigation pill colour.

## Verification
- `flutter test --no-pub`: all 5 tests passed.
- Focused `flutter analyze --no-pub lib/app/komekci_app.dart lib/shared/widgets/glass_nav_bar.dart test/theme_navigation_test.dart`: no issues.
- `flutter build apk --debug --no-pub`: successful.
- Installed the final debug APK on the connected Android phone with `adb install -r`: successful.
- `git diff --check`: clean.
- Full `flutter analyze --no-pub` reported no errors; it still reports existing unused declarations in Cabinet and third-party SMS plugin lint notices.

## Note
The connected Android phone was in another app during final verification, so no live UI interaction was performed after the final build.
