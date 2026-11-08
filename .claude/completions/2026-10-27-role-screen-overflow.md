# Role selection overflow

- Made the role screen scroll when its content exceeds the phone height while keeping the centered spacing on taller screens.
- Allowed role cards to grow beyond their previous fixed 230 px height when translated descriptions wrap on narrow phones.
- Added a 320 × 480 widget regression test that checks for rendering errors and confirms scrolling works.

Verification: `flutter test test/role_screen_layout_test.dart`, focused `flutter analyze`, and `git diff --check` passed.
