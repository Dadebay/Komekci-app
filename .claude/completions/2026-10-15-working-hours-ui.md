# Working hours screen UI

- Reworked the Master Cabinet working hours page with a weekly open-day summary and clearer day cards.
- Separated each day's open switch from its tappable time range. The break control now follows the same layout.
- Added a loading/error state with retry so placeholder hours are not shown as saved data.
- Kept the existing schedule API, time picker, vacation, special-day, and save behavior.

Verification: `flutter analyze --no-pub lib/features/cabinet/presentation/cabinet_working_hours_screen.dart`, `flutter build apk --debug --no-pub`, and installation on the connected Android device succeeded.
