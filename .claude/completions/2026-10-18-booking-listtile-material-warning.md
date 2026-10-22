# Booking confirmation ListTile warning

- Traced Flutter's `ListTile background color or ink splashes may be invisible` warning to the `CheckboxListTile` inside the colored booking note card.
- Added a transparent `Material` directly around the tile so its ink effects paint above the card background.
- Verified with `flutter analyze --no-pub lib/app/komekci_app.dart` and `git diff --check`. Device runtime was not used.
