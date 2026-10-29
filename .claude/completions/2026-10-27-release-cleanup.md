# Release preparation and code cleanup — 2026-10-27

## Changes

- Removed unused `cupertino_icons` and `restart_app` direct dependencies, unused image/font assets, and two dead cabinet declarations.
- Listed only used runtime images in `pubspec.yaml`; retained image attribution in the repository.
- Moved the master action and cabinet help buttons to shared widgets.
- Split oversized Dart sources by coherent UI, action, data, and state boundaries. Every Dart file under `lib/` is now at most 300 lines.
- Excluded vendored `third_party/` source from the app analyzer; the vendored packages are still built normally.
- Replaced Android debug signing for release with a private `android/key.properties` configuration. Added `android/key.properties.example`. Release packaging fails clearly until a real keystore is supplied.
- Replaced Flutter's placeholder package description.

## Verification

- `flutter analyze --no-pub`: no issues.
- `flutter test --no-pub`: 33 tests passed.
- Android release APK compiled before signing configuration was hardened. The temporary debug-signed artifact was removed afterward so it cannot be mistaken for a store package.
- iOS `flutter build ios --release --no-codesign`: compiled successfully after final structural changes.
- Android `flutter build apk --debug`: compiled successfully with the new signing setup.
- `git diff --check`: clean.
- `lib/` line audit: zero Dart files over 300 lines.

## Remaining publication inputs

- A private Android upload keystore and `android/key.properties` are required to create a signed Android store build. Do not commit either.
- iOS distribution signing/provisioning must be supplied by the project owner's Apple account; `--no-codesign` verifies compilation only.
