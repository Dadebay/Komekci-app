# Cabinet billing simplification

- Replaced the cabinet billing page's numbered sections and repeated renewal message with a single balance/subscription summary, one top-up action, and a compact recent payment history.
- Added pull-to-refresh plus loading and retry states so the page does not show a false zero balance when billing has not loaded.
- Made the cabinet top-up flow compact: balance and monthly fee summary, smaller amount choices, visible available payment methods, and a clear continue action. The onboarding subscription presentation remains separate.
- Preserved billing provider data, amount selection, phone/card payment dialogs, and server-owned subscription status.
- Verified on the connected Android device: both screens fit in the viewport, the amount choice updates the footer, and no payment was initiated. Debug APK build succeeded. `flutter analyze --no-pub` reported no app errors; four existing info notices remain in `third_party/background_sms`.

Rollback: revert the three billing presentation files. No API or stored data changed.
