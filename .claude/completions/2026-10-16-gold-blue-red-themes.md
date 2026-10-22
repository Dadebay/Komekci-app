# Gold, blue and red app themes

- Replaced the four visible appearance choices with localized Gold/Altyn, Blue/Mawy and Red/Gyzyl choices.
- Restored the original gold palette as the default and added blue and red palettes. All three apply to the shared Material theme and bottom navigation. Gold retains the classic dark primary button; blue and red use accent-coloured buttons.
- Kept legacy backend codes (`ivory`, `onyx`, `champagne`, `rose`) valid for existing accounts. The picker maps them to gold, red, blue, red respectively, and saves an enabled code. Future `gold`, `blue` and `red` codes are also supported.
- Updated theme tests for the three palettes, button styling, and legacy API compatibility. Ten focused Flutter tests pass; the earlier `flutter analyze --no-pub` run reported only six pre-existing unrelated warnings.
- User prefers to run the app on their own device; no device run for this change.
