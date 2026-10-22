# Built-in Kotlin migration

- Enabled AGP 9 built-in Kotlin for the Android application and removed its
  `kotlin-android` plugin application. The existing JVM 17 compiler options stay
  in place.
- Kept the Kotlin version declaration in `settings.gradle.kts` with `apply false`
  because Flutter 3.47's dependency validator still reads that version.
- Added local copies of `smart_auth` 3.2.0, `firebase_core` 4.15.0, and
  `firebase_analytics` 12.6.0. Their Android Gradle files no longer apply KGP.
  The package implementation and licenses remain intact.
- Updated `pubspec.yaml` and `pubspec.lock` to resolve those local copies.
- Verified `flutter pub get` and `flutter build apk --debug --no-pub`. The APK
  builds without the Kotlin Gradle Plugin warning. No device launch was run.

Maintenance: see `third_party/BUILT_IN_KOTLIN.md`. Local Firebase overrides
pin those two packages until upstream removes the legacy KGP fallback and the
project is switched back to hosted releases.
