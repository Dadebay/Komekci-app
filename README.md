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
flutter build apk --debug
```

The GitHub Actions workflow runs these checks on pull requests and on `main`. The test suite covers appointment rules, API contracts, offline data, reminders, and key screen layouts.

## Android release

The app ID is `com.gurbanov.salon`; its version is set in [`pubspec.yaml`](pubspec.yaml). Android release builds require a local `android/key.properties` file and a keystore. Use [`android/key.properties.example`](android/key.properties.example) as the template. Both the properties file and keystore are excluded from Git.

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Verify its package, version, and signing certificate before sharing it. GitHub Releases are for direct APK downloads; publishing to Google Play requires the store's own release process.
