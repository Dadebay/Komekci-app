# Kömekçi

Kömekçi is a Flutter app for booking services with local professionals. It has two roles: clients can connect with a professional and manage appointments, while professionals can publish services, manage availability, and handle bookings.

## What the app does

- Clients can find and connect with professionals, browse their services, and book or reschedule appointments.
- Professionals can manage services, working hours, time off, clients, and their appointment calendar.
- The app includes booking notifications, reminders, profile settings, and a professional subscription flow.
- Recent data is cached so parts of the professional experience remain available when the connection drops.

The mobile client talks to the Kömekçi API configured in [`lib/core/network/api_config.dart`](lib/core/network/api_config.dart). A working backend is required for sign-in, bookings, and billing.

## Development

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and the Android or Xcode toolchain for your target platform. This repository uses Dart `^3.12.0` and includes local plugin forks under `third_party/`.

```sh
flutter pub get
flutter run
```

Firebase configuration is required for notifications and analytics. The Android configuration is in `android/app/google-services.json`; iOS configuration is in the Xcode project. Do not put signing passwords or private keys in Git.

## Checks

```sh
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
flutter build apk --debug
```

The GitHub Actions workflow runs formatting, analysis, tests, and a debug Android build on pull requests and on `main`. The test suite covers appointment rules, API contracts, offline data, reminders, and key screen layouts.

## Android release

The app ID is `com.gurbanov.salon`; its version is set in [`pubspec.yaml`](pubspec.yaml). Android release builds require a local `android/key.properties` file and a keystore. Use [`android/key.properties.example`](android/key.properties.example) as the template. Both the properties file and keystore are excluded from Git.

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Verify its package, version, and signing certificate before sharing it. GitHub Releases are for direct APK downloads; publishing to Google Play requires the store's own release process.

## Store release

Version `1.0.0+1` has not been published yet: there is no Google Play or App Store listing, so this README links to none. Add the verified links and the GitHub Release here once they exist.

Build the Play Store bundle and the iOS archive from the commit you intend to ship:

```sh
flutter build appbundle --release          # build/app/outputs/bundle/release/app-release.aab
flutter build ipa --release                # needs Apple signing set up in Xcode
```

Raise the build number (`+N` in `pubspec.yaml`) for every upload; Play and App Store Connect reject a repeated one. Signing material, store accounts, and the pre-release checklist are described in [`docs/RELEASE.md`](docs/RELEASE.md). It records only where secrets live and who owns them, never their values.

## Known limitations

- Professionals send bulk SMS through the phone's own messaging app, one client at a time (`sms:` link). The app cannot confirm that a message was actually sent.
- Several plugins are local forks under `third_party/` and some plugins do not support Swift Package Manager yet.
- A running Kömekçi backend is required for sign-in, bookings, and billing.
