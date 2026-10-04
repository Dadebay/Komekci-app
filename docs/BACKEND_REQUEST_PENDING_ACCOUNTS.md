# Backend request: sign-up gets stuck on `PHONE_TAKEN` for unconfirmed accounts

Status: **requested, not built.**

## Problem

`POST /auth/register` creates the account with status `pending` and sends the SMS code. If the person does not
finish `POST /auth/otp/verify` (closes the app, code not delivered, etc.), the pending account stays and keeps the
phone number. Registering again with that number answers:

```json
{ "error": "PHONE_TAKEN", "message": "Bu telefon eýýäm hasaba alyndy." }
```

and signing in does not work either: `POST /auth/otp/request` is only for *active* accounts, so it answers
`PHONE_NOT_FOUND`. The person is locked out of their own number until someone deletes the row by hand.

## What we need (any one of these)

1. **Preferred:** `POST /auth/register` for a phone whose account is still `pending` should *replace* the pending
   data with the new submission and send a fresh SMS code (same 201 `{ "status": "otp_sent" }`), instead of
   `PHONE_TAKEN`. `PHONE_TAKEN` stays for `active` accounts only.
2. Or: `POST /auth/otp/request` also works for `pending` accounts, so the app can just re-send the code and the
   person finishes verification.
3. Or: a scheduled clean-up that deletes accounts that stayed `pending` for, say, 24 hours.

Also worth deciding: one phone number is one account with one role. A number that is already a **client** cannot
register as a **master** (and vice versa). If that should be possible, it needs a product decision and a different
data model.

## What the app does today

On `PHONE_TAKEN` the sign-up screens show "An account with this number already exists" with a **Sign in with this
number** button. It calls `POST /auth/otp/request`:

- success → the code screen opens (the person signs in to the existing active account);
- `PHONE_NOT_FOUND` → the account is pending/unconfirmed; the app says to contact support. This is the case only
  the backend can fix, ideally with option 1 above.

## One-off unblock

Delete (or activate) the pending account row for the stuck phone number in the database.
