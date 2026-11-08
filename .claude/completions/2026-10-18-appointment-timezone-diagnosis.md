# Appointment timezone diagnosis — 2026-10-18

- User screenshots show a selected appointment at 2026-10-19 17:00 and confirmation at 22:00.
- The supplied POST /appointments response for appointment 8 contains starts_at=2026-10-19T17:00:00+00:00 and ends_at=2026-10-19T17:30:00+00:00.
- ClientRepository.book sends formatApiDateTime(startsAt), yielding 2026-10-19 17:00:00. The documented contract says the server reads timezone-less appointment input in Asia/Ashgabat.
- parseApiTime correctly converts UTC response timestamps to Asia/Ashgabat wall time. Correct responses for this selection are 17:00+05:00 or 12:00Z. The observed 17:00+00:00 represents 22:00 in Ashgabat.
- The evidence identifies a backend time-contract violation, but cannot distinguish incorrect persistence from incorrect response serialization without backend access. User confirmed backend access is unavailable.
- No production code changed and no live appointments created or modified. Do not strip offsets or subtract five hours from every response: valid UTC timestamps would become wrong.
- Added test/appointment_time_contract_test.dart: correct local/UTC representations, next-day conversion, matching client/master views, request body capture, and reproduction of the logged response's five-hour shift. All 7 tests passed with flutter test --no-pub test/appointment_time_contract_test.dart.
- Backend fix remains pending: trace request parsing, persisted time interpretation and response serialization, then verify create/list/calendar/move flows preserve the selected appointment time.
