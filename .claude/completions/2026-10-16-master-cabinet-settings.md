# Master Cabinet settings

- Added a settings gear to the left of the Master Cabinet header.
- Added `CabinetSettingsScreen` with language and appearance rows showing the current selections.
- Reused the existing selection sheets, which filter options from public backend settings, apply changes immediately, and save account preferences.
- Added the settings icon to the shared icon map.

Verification: targeted `flutter analyze --no-pub`, `flutter build apk --debug --no-pub`, and installation on the connected Android device succeeded.
