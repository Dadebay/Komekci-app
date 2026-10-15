# Home contact and wallet navigation

- Master home banner's contact button now opens the real Support screen instead of the placeholder Settings screen.
- Redesigned the Support screen with a concise hero, configured contact methods, a clear empty contact state, collapsible FAQs, and an About link.
- Home balance/wallet chip now opens Cabinet's Billing & subscription screen; the whole chip is tappable.
- Contact rows omit empty subtitles and only show an action arrow for actionable rows.

Verification: targeted `flutter analyze --no-pub`, `flutter build apk --debug --no-pub`, and installation on the connected Android device all succeeded.
