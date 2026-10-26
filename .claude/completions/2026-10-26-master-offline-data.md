# Master offline data

- Saved the last successful master `/me` response and authenticated `/me/*` GET responses in device secure storage. Cached responses are used only for network failures; authorization errors and writes still come from the server.
- Restored a signed-in master session from the saved `/me` response on a disconnected app launch. Stored data is scoped to the master ID and removed on sign-out or a new OTP sign-in.
- The master home shows a saved-data notice, refresh action, and automatic refresh after connectivity returns or the app resumes. Calendar and dashboard screens distinguish an unavailable month from a genuinely empty month.
- Successful master appointment changes re-read the affected calendar month so the saved copy reflects the latest bookings. Failed month prefetches wait for an explicit retry or reconnection instead of retrying on every rebuild.

Verification: focused Flutter tests passed, including disconnected restart, booking persistence after creation, account separation, sign-out cleanup, and noncached writes. Focused `flutter analyze` found no issues. `flutter build ios --release --no-codesign` succeeded. The app was not installed on a device in this task.
