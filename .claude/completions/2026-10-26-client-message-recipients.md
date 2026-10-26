# Client message recipients

- The send screen now watches `CustomerProvider` and refreshes the client book when opened, so an asynchronous load updates the recipient count.
- Loading failures show a retry action. A nonempty client book with no eligible push recipients explains why push cannot be sent.
- Selected and recent pickers show all of the master's clients. Customers without a verifiable push account or SMS phone number remain visible but cannot be selected for that channel.
- The send request still uses only numeric `account_id` values; a `c12` connection ID is never treated as an account ID.

Remaining backend dependency: the documented `GET /me/clients` response omits numeric `account_id`, while `POST /me/notifications/send` requires numeric `account_ids`. Connected client rows must include the target account ID, or the send endpoint must accept connection IDs explicitly.

Validation: the existing notification API contract tests pass; targeted analysis of the three screens passes. A separate pre-existing unused `_TimeChip` warning appears when analyzing `cabinet_widgets.dart` directly. No live authenticated push send was attempted.
