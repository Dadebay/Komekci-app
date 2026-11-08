# Booking picker: 30-minute slot spacing

- The client booking date/time picker now shows only server-offered start times on `:00` or `:30` boundaries. Server availability remains authoritative.
- This is limited to the booking picker shown in the screenshot; appointment rescheduling and the master's calendar are unchanged.
- Verified with `flutter analyze --no-pub lib/app/komekci_app.dart` and `git diff --check`.
