# Backend request: list of masters for new clients

Status: **requested, not built.** The Flutter app cannot show masters without searching until this exists.

## Why

After sign-up a client lands on "Connect to your master". Today the only way to find a master is
`GET /masters/lookup?q=` — an **exact** nickname or phone match, minimum 3 characters. A new client who does not
already know a master's nickname sees an empty page. The product wants: show some masters right away, let the
client pick one, and keep the search for people who already have a master.

## Endpoint

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

### Response 200

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

## Privacy / product decision (needs a yes from the product owner)

`/masters/lookup` is exact-match **on purpose** — the API doc says partial search never finds a master. A public
directory changes that. Suggested guard: a master setting that defaults to **off**:

- `listed_in_directory` (bool) on the master profile, editable with the existing `PATCH /me/profile`
  (`"listed_in_directory": true`) and returned by `GET /me/profile`.
- `GET /masters` returns only masters with it on.

Without such a flag every master becomes visible to every client the day this ships.

## Optional extras (not required for the first version)

- `q` — partial match on name/nickname, only if the owner is happy with partial search.
- `district` or `city` filter, if masters have a structured location (today `address` is free text).

## What the app does once it exists

A "Masters" list under the search box on the connect page, with a one-tap **Connect** button on each card, an
infinite scroll via `next_cursor`, and the search box kept for people who already know their master. Roughly half
a day of app work; no change to the connection flow.
