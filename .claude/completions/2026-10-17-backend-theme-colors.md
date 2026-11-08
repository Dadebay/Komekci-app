# Backend-driven theme colors

- Parsed the seven `themes[].colors` HEX fields from `GET /settings/public`, keyed by each enabled API theme code. Invalid or missing colors keep the bundled palette. The cached settings JSON continues to provide the same colors offline.
- Applied backend primary, secondary, background, text, button, button text and accent colors to shared `ThemeData`, semantic tokens, buttons, navigation and theme picker previews. Derived border and secondary text because the API has no dedicated fields for them.
- Kept the existing Gold, Blue and Red choices. When the backend enables explicit `gold`, `blue` or `red` codes, restored legacy selections resolve to the explicit code of the same style.
- Added focused parsing, dark palette, malformed color, provider load and button color tests. Four focused test files pass (14 tests). `flutter analyze --no-pub` reports only the six existing unrelated warnings.
- No device run was performed; the user runs the app locally.
