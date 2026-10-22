# Master home banner

- The master dashboard hero now reads the saved banner from `MasterProfileProvider` and renders the local upload or server URL across the full header. The existing gradient remains visible when no banner exists or image loading fails.
- The overlapping avatar now uses the same profile photo source as the profile editor.
- `flutter analyze --no-pub` found no new errors; its six existing unrelated warnings remain. `git diff --check` passed. No device run was performed.
