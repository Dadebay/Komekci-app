# Android Gradle warning update

- Upgraded the app to Android Gradle Plugin 9.0.1 and Kotlin Gradle Plugin 2.3.20. Kept the existing local Gradle wrapper change to 9.1.0, which AGP 9.0.1 requires.
- Updated the app's Gradle Kotlin DSL configuration and Java/Kotlin targets to 17.
- Updated the vendored `background_sms` Android module to target Java 17 and use the current Flutter binary messenger and Android 12+ SMS APIs, retaining older Android API fallbacks.
- Verified with `flutter build apk --debug` and a full `./gradlew :app:assembleDebug --rerun-tasks --console=plain` rebuild. Both succeeded. Recompiled the SMS module with `-Xlint:deprecation`; its Java source produced no warnings.
- Flutter still reports that some third-party plugins apply the legacy Kotlin Gradle Plugin. Those packages need their own built-in Kotlin migrations; the project retains Flutter's compatibility flags for now.

Rollback: revert the app and SMS module Gradle/Java edits together with the AGP/Kotlin version updates. Keep the Gradle wrapper at a version compatible with the restored AGP version.
