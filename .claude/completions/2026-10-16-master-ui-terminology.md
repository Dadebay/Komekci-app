# Master UI terminology

- Replaced user-facing Turkmen `Usta` and `Ussa` forms with `Master` forms in client connection, booking, profile, home, and notification screens.
- Kept API identifiers and Russian/English translations unchanged.
- Verified no `Usta` or `Ussa` text remains in `lib`, `assets`, or `test`; `git diff --check` passes.
- `flutter analyze --no-pub` reports only existing unrelated warnings in cabinet and the background SMS package.
