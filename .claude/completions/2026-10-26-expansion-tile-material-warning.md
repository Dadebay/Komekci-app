# ExpansionTile Material warning

- Replaced the decorated `Container` around the master notification-type expander and the subscription balance explainer with a clipped `Material` of the same color, rounded border, and radius.
- This puts each `ExpansionTile`'s internal `ListTile` on its own material surface, allowing its background and ink effects to render without the Flutter assertion.

Verification: focused `flutter analyze` for the two changed presentation files and `git diff --check` passed.
