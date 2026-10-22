# Service form neutral card backgrounds

- Removed the blue accent gradient from the empty service photo area and used the theme surface color instead.
- Gave the service form's information and price/time cards the theme surface color, leaving their borders and small accent icons in place.
- Added an optional background color to the shared profile section widget so the master profile screen keeps its existing appearance.
- Verified with `flutter analyze --no-pub lib/app/komekci_app.dart` and `git diff --check`.
