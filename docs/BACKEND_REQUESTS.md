# Backend requests

Everything the Flutter app is waiting on from the backend, in one place. The API contract itself is in
`API_DOCUMENTATION.md`; these are the things it does **not** cover yet.

Last updated: 2026-10-04. Nothing below is built; the app works without all three, with the limits noted.

## Summary

| # | Request | Endpoint | Why it matters |
| --- | --- | --- | --- |
| 1 | [Sign-up gets stuck on `PHONE_TAKEN` for unconfirmed accounts](#1-sign-up-gets-stuck-on-phonetaken-for-unconfirmed-accounts) | `POST /auth/register`, `POST /auth/otp/request` | Blocks real users today: a person who did not finish the SMS code is locked out of their own number. |
| 2 | [List of masters for new clients](#2-list-of-masters-for-new-clients) | `GET /masters` (new) | A new client lands on an empty "Connect to your master" page unless they already know a nickname. |
| 3 | [A master sends a push message to their clients](#3-a-master-sends-a-push-message-to-their-clients) | `POST /me/messages` (new) | Today the cabinet sends SMS from the master's own SIM; there is no push. |

Suggested order: **1** first (it locks real users out), then 2 and 3, which are product features.

---

## 1. Sign-up gets stuck on `PHONE_TAKEN` for unconfirmed accounts

Status: **requested, not built.**

### Problem

`POST /auth/register` creates the account with status `pending` and sends the SMS code. If the person does not
finish `POST /auth/otp/verify` (closes the app, code not delivered, etc.), the pending account stays and keeps the
phone number. Registering again with that number answers:

```json
{ "error": "PHONE_TAKEN", "message": "Bu telefon eýýäm hasaba alyndy." }
```

and signing in does not work either: `POST /auth/otp/request` is only for *active* accounts, so it answers
`PHONE_NOT_FOUND`. The person is locked out of their own number until someone deletes the row by hand.

### What we need (any one of these)

1. **Preferred:** `POST /auth/register` for a phone whose account is still `pending` should *replace* the pending
   data with the new submission and send a fresh SMS code (same 201 `{ "status": "otp_sent" }`), instead of
   `PHONE_TAKEN`. `PHONE_TAKEN` stays for `active` accounts only.
2. Or: `POST /auth/otp/request` also works for `pending` accounts, so the app can just re-send the code and the
   person finishes verification.
3. Or: a scheduled clean-up that deletes accounts that stayed `pending` for, say, 24 hours.

Also worth deciding: one phone number is one account with one role. A number that is already a **client** cannot
register as a **master** (and vice versa). If that should be possible, it needs a product decision and a different
data model.

### What the app does today

On `PHONE_TAKEN` the sign-up screens show "An account with this number already exists" with a **Sign in with this
number** button. It calls `POST /auth/otp/request`:

- success → the code screen opens (the person signs in to the existing active account);
- `PHONE_NOT_FOUND` → the account is pending/unconfirmed; the app says to contact support. This is the case only
  the backend can fix, ideally with option 1 above.

### One-off unblock

Delete (or activate) the pending account row for the stuck phone number in the database.

---

## 2. List of masters for new clients

Status: **requested, not built.** The Flutter app cannot show masters without searching until this exists.

### Why

After sign-up a client lands on "Connect to your master". Today the only way to find a master is
`GET /masters/lookup?q=` — an **exact** nickname or phone match, minimum 3 characters. A new client who does not
already know a master's nickname sees an empty page. The product wants: show some masters right away, let the
client pick one, and keep the search for people who already have a master.

### Endpoint

`GET /masters`

- Auth: Bearer, role `client` (same as `/masters/lookup`).
- Query: `cursor` (optional, same cursor scheme as other lists), `limit` (optional, default 20, max 50).
- Behaviour:
  - only active masters that are **listed** (see "Privacy" below);
  - order: `accepting_bookings = true` first, then newest or a stable shuffle;
  - exclude masters the client is already connected to or has a pending request with (or return them with
    `connection_status` so the app can show "Connected"/"Request sent").
- Rate limit: the normal 120/min is fine.
- Cache: `ETag` like other GETs.

#### Response 200

Same envelope as the other paginated lists:

```json
{
  "data": [
    {
      "id": 12,
      "name": "Ayna",
      "nickname": "ayna_style",
      "photo_url": "https://.../avatar_256.jpg",
      "address": "Ashgabat",
      "description": "Barber",
      "accepting_bookings": true,
      "connection_status": null
    }
  ],
  "next_cursor": null
}
```

Fields are the same as the brief master object already returned by `/masters/lookup` and `/connections`
(`id`, `name`, `nickname`, `photo_url`, `address`, `accepting_bookings`), plus:

| Field | Type | Notes |
| --- | --- | --- |
| `description` | string or null | optional, one line shown on the card |
| `connection_status` | `null` / `pending` / `accepted` | the caller's relation to this master (optional) |

Nothing else is needed: the client app connects with the existing `POST /connections { "master_id": 12 }`.

### Privacy / product decision (needs a yes from the product owner)

`/masters/lookup` is exact-match **on purpose** — the API doc says partial search never finds a master. A public
directory changes that. Suggested guard: a master setting that defaults to **off**:

- `listed_in_directory` (bool) on the master profile, editable with the existing `PATCH /me/profile`
  (`"listed_in_directory": true`) and returned by `GET /me/profile`.
- `GET /masters` returns only masters with it on.

Without such a flag every master becomes visible to every client the day this ships.

### Optional extras (not required for the first version)

- `q` — partial match on name/nickname, only if the owner is happy with partial search.
- `district` or `city` filter, if masters have a structured location (today `address` is free text).

### What the app does once it exists

A "Masters" list under the search box on the connect page, with a one-tap **Connect** button on each card, an
infinite scroll via `next_cursor`, and the search box kept for people who already know their master. Roughly half
a day of app work; no change to the connection flow.

---

## 3. A master sends a push message to their clients

Status: **requested, not built.** The API has no endpoint for this today.

### What exists now

- The app's cabinet → "Müşderilere bildiriş" sends **SMS** from the master's own phone (SIM) to the chosen clients
  (`background_sms` plugin). It is not a push notification and costs the master SMS credit.
- Clients already have a notification switch `master_messages` in `notification_prefs`, so the backend clearly plans
  master → client messages, but there is no endpoint to send one.

### Endpoint

`POST /me/messages`

- Auth: Bearer, role `master`; only while the subscription accepts bookings (`SUBSCRIPTION_SUSPENDED` otherwise).
- Body (JSON):

```json
{
  "title": "Yeni kolleksiýa",
  "body": "Ertir 10:00-dan 15:00-a çenli arzanladyş.",
  "audience": "selected",
  "client_ids": ["c12", "c15"]
}
```

| Field | Rule |
| --- | --- |
| `title` | required, 1–60 characters |
| `body` | required, 1–500 characters |
| `audience` | `all` (every connected client) or `selected` |
| `client_ids` | required when `audience` is `selected`; ids as in `GET /me/clients` (`c12`) |

- Behaviour:
  - sends a push (FCM) **and** stores an inbox notification (`GET /me/notifications`) for each recipient;
  - skips clients who switched `master_messages` off;
  - offline clients (`o…` ids, no app account) cannot receive a push: skip them and report the count, so the app
    can offer SMS for those.
- Rate limit: for example 5 messages per master per day (the number is the backend's call), plus the normal 120/min.

#### Response 202

```json
{
  "queued": 12,
  "skipped": { "offline": 3, "muted": 2 }
}
```

#### What the client receives

A normal notification in `GET /me/notifications` with a new event code (for example `N-20`), `title`, `body`, and
`payload` carrying `{ "master_id": 12 }` so the app can open that master's profile when tapped.

### Optional

`GET /me/messages` — the master's sent messages (date, title, audience, recipient count) for a history screen.

### What the app does once it exists

The existing compose screen sends through this endpoint instead of SMS, shows "12 sent, 3 offline (send by SMS?)",
and keeps the SMS path only for offline clients. Roughly half a day of app work.
