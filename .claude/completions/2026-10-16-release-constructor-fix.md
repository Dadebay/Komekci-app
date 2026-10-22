# Release constructor fix

Changed the second initializer-list colon in `_SettingRow` to a comma, preserving the existing intent to keep its unused switch fields null.

Verified with `flutter analyze --no-pub lib/app/komekci_app.dart`, `flutter build apk --release --no-pub`, and `git diff --check`. The release APK is `build/app/outputs/flutter-apk/app-release.apk`.
