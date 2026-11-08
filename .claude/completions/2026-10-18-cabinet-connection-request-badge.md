# Cabinet connection request badges

- Reused `ConnectionRequestsProvider.count` for the existing "Baglanyşyk haýyşlary" Cabinet row and added the same count to the Cabinet bottom navigation item.
- The master shell refreshes pending requests every 30 seconds while active and when the app resumes. The Cabinet screen also refreshes when opened; accepting or declining a request removes it from the count immediately.
- Prevented overlapping request fetches in `ConnectionRequestsProvider.load()`.
- Verified with `flutter analyze --no-pub` on the changed Dart entry points and `git diff --check`.
