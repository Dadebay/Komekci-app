# Theme picker bottom sheet redesign

- Reworked the shared appearance bottom sheet used by the client profile and master Cabinet settings. The sheet now has a clear heading, close control, compact theme previews, descriptions and a stronger selected state.
- Theme options still follow the backend enabled list and retain the existing immediate selection and preference save behavior. Added a localized empty state when no themes are enabled.
- The sheet scrolls within a height limit for small screens. A widget test confirms all three choices fit on a 320 × 640 viewport without layout exceptions.
- Focused Flutter tests pass. No device run was performed; the user runs the app locally.
