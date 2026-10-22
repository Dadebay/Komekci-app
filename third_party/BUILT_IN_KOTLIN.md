# Android Built-in Kotlin compatibility copies

These copies keep the Android build on AGP 9's built-in Kotlin while preserving
the plugins' Dart, Android, iOS, macOS, and Windows implementations.

| Package | Upstream version | Local Android change |
| --- | --- | --- |
| `firebase_core` | 4.15.0 | Removed the legacy KGP fallback branch. |
| `firebase_analytics` | 12.6.0 | Removed the legacy KGP fallback branch. |
| `smart_auth` | 3.2.0 | Removed KGP and configured the Kotlin 11 JVM target through `kotlin.compilerOptions`. |

The Firebase packages are selected through `dependency_overrides` in the root
`pubspec.yaml`, so their transitive users resolve to the same local copies.
The upstream licenses are included with each copy. The Firebase package copies
also omit the upstream workspace resolution setting so they can be used outside
the FlutterFire monorepo.

When upstream packages no longer declare KGP and the Flutter build warning is
gone, remove these local substitutions, run `flutter pub get`, and verify an
Android debug build. Until then, Firebase plugin updates require refreshing
these copies and reviewing the local Gradle changes.
