# Home number shimmer and refresh verification

- The four master dashboard values and balance disappear behind shimmer placeholders during pull-to-refresh. After the requests complete, integers, times, and the balance animate from zero to the API-backed result. A 450 ms minimum makes the loading state visible for fast responses.
- Added a translated error message when a dashboard data request fails, so retained values are identified as previous data.
- Added `test/home_refresh_data_test.dart` with mocked HTTP responses proving that forced calendar refresh replaces appointment counts, including deleted entries, and billing refresh replaces the displayed balance.
- Verification: `flutter test --no-pub test/home_refresh_data_test.dart` passed (2 tests). `flutter analyze --no-pub lib test/home_refresh_data_test.dart` reported only two existing unused declarations in cabinet files.
