# Cabinet notifications screen refinement

- Put the master's recent notifications before the settings section. The 19 individual preference switches were replaced with one switch that updates all 19 in a single request.
- Increased the notification heading hierarchy and added a count of unread items currently loaded.
- Refined notification cards so unread items have clearer emphasis and tap feedback; waitlist actions wrap on narrow screens.
- Added a retry state for failed inbox loads and kept pull to refresh available when the list is short.
- Removed the debug test notification action from the screen.
- Made read notification cards neutral grey with a softer title; the existing mark-all-read provider update applies the style immediately.

Validation: targeted `flutter analyze` passed, `git diff --check` passed, and `impeccable detect --json` returned no findings. Device visual testing was left to the user.
