# Release handover

This file records **where release material lives and who owns it**. It must never contain passwords, key contents, or tokens.

## Identifiers

| Item | Value |
| --- | --- |
| Android application ID | `com.gurbanov.salon` |
| iOS bundle ID | `com.gurbanov.salon` |
| Apple development team | `V793RH49BX` |
| Current version | `1.0.0+1` (see `pubspec.yaml`) |
| Android target SDK | 36 (checked on the release APK) |

## Android signing

- Upload key alias: `komekci-upload`, valid until 2054-03-14.
- Upload certificate SHA-256: `97:69:13:4E:CA:47:9B:C6:4B:93:74:C2:3C:A3:EE:09:7C:6A:9C:65:59:5A:C5:BD:3D:FA:26:B9:7F:81:CE:E1`. A fingerprint is public; it is what Firebase and Play ask for.
- The keystore and its `key.properties` are kept in the owner's private key storage, outside this repository. `android/key.properties` is git-ignored; copy `android/key.properties.example` and fill it locally.
- If Google Play App Signing is enabled, users receive the app signed with **Play's app signing certificate**, not the upload key. Register both SHA-256 values wherever a fingerprint is needed (Firebase, app links). An APK signed only with the upload key installs fresh but cannot update a Play-installed copy.
- Losing the upload key means asking Play support for an upload-key reset. Keep an offline backup.

## Build and verify

```sh
flutter build appbundle --release   # upload this to Play Console
flutter build apk --release         # direct install / testing only
```

Verify an APK before sharing it:

```sh
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
aapt2 dump badging build/app/outputs/flutter-apk/app-release.apk | head -3
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
```

The package, version code/name, and certificate SHA-256 must match the values above. Never publish a debug-signed build.

For iOS, archive and upload from Xcode or `flutter build ipa --release` with the team above. In `ios/Runner/Runner.entitlements`, `aps-environment` is `development`; Xcode switches it to `production` for distribution signing, but confirm it in the archived build.

## Before the first store submission

Decisions and declarations that need the owner, not code:

- [x] **SMS permission (Google Play).** Done: the professional "send message" screen opens the phone's messaging app through an `sms:` link, one client at a time. The app declares no `SEND_SMS` permission (checked in the release APK's merged manifest), so no SMS Permissions Declaration is needed. Do not re-add `SEND_SMS` or a plugin that sends SMS silently.
- [ ] **Advertising ID (Google Play).** The merged manifest contains `com.google.android.gms.permission.AD_ID`, added by Firebase Analytics. Answer the Advertising ID declaration to match, or remove the permission if the app shows no ads.
- [ ] **Data safety (Play) and privacy labels (App Store).** Match them to what the app and its SDKs collect: account data (name, phone, photo), push tokens, calendar access (optional), analytics.
- [ ] **Account deletion.** Both stores expect in-app account deletion and a deletion URL; the app has `DELETE /me`. Provide the public URL in Play Console.
- [ ] **Privacy policy URL** for both stores.
- [ ] **App Store review account.** The server signs in the test numbers `+99362990344` (master) and `+99371821848` (client) without an SMS code; give these to the reviewers.
- [ ] **iOS privacy manifest.** The app has no `PrivacyInfo.xcprivacy` of its own; plugins ship theirs. Add an app-level one if App Store Connect asks for it.
- [ ] **Push.** An APNs key (or certificate) must be uploaded to Firebase for iOS notifications.
- [ ] **Screenshots, description, and age rating** for both stores, in the supported languages (Turkmen, Russian, English).

## Services and owners

Fill in privately (not in Git): Firebase project owner, Apple Developer and Google Play account owners and 2FA recovery contacts, backend and server owner, and who holds billing for each.

## Rollback

- Play: halt the staged rollout and promote the previous release; a store version code can never be reused.
- App Store: remove the build from sale or submit the previous build; keep the last good IPA/archive.
- Server contract changes: the app talks to the live API, so check backward compatibility before shipping a backend change that older app versions still call.
