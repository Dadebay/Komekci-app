# Salon release preparation — 2026-11-12

## Starting state

- `main` was at `f60fa33` with 223 uncommitted entries. Work was copied into an isolated worktree so the original working directory stayed intact.
- Flutter 3.50.0, Dart 3.14.0, Android and iOS targets. Android application ID: `com.gurbanov.salon`.
- Baseline analysis, 46 tests, and Android debug build passed. Formatting differed in 165 files.

## Changes

- Preserved the existing SMS sign-in, localization, UI, and release-documentation work on a dedicated branch.
- Kept valid sessions when token refresh returns a temporary error such as HTTP 429.
- Rejected missing SMS challenge fields and stopped debug API logs from printing query values and response bodies.
- Formatted `lib` and `test`, added CI formatting, and aligned CI with Flutter 3.50.0.
- Added local-secret ignore rules for `.env` files.

## Verification

- `dart format --output=none --set-exit-if-changed lib test`: passed.
- `flutter analyze --no-pub`: passed.
- `flutter test --no-pub`: 49 passed.
- `flutter build apk --debug --no-pub`: passed.
- No Android device was connected for smoke testing. iOS build was omitted per the owner's earlier direction.

## Remaining release gates

- The Android release APK and GitHub Release remain unpublished until a signed build is smoke tested on a device and its certificate is compared with the Play app-signing certificate.
- Store listings and legal/privacy URLs are unverified. The repository About homepage is intentionally unset.
- The operational and store handover checklist remains in `docs/RELEASE.md`.
