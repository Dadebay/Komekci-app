# KÖMEKÇI — Product & Technical Specification

**Beauty & Barber Appointment Application**
Client Side (Part 1) · Master Side (Part 2)

| | |
|---|---|
| **Document version** | 1.0 |
| **Date** | 31 July 2026 |
| **Status** | For review & cost estimation |
| **Platforms** | Android (primary), iOS |
| **Primary market** | Turkmenistan |
| **Currency** | TMT (manat) |
| **Languages** | Turkmen, Russian, English |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Market & Competitive Research](#2-market--competitive-research)
3. [Product Principles & Hard Constraints](#3-product-principles--hard-constraints)
4. [Roles, Onboarding & Navigation Map](#4-roles-onboarding--navigation-map)
5. [PART 1 — CLIENT SIDE](#5-part-1--client-side)
6. [PART 2 — MASTER SIDE](#6-part-2--master-side)
7. [Booking Engine — Shared Rules](#7-booking-engine--shared-rules)
8. [Notification System](#8-notification-system)
9. [Data Model](#9-data-model)
10. [API Surface](#10-api-surface)
11. [Design System](#11-design-system)
12. [Motion & Animation Specification](#12-motion--animation-specification)
13. [Non-Functional Requirements](#13-non-functional-requirements)
14. [Screen Inventory](#14-screen-inventory)
15. [Delivery Phasing](#15-delivery-phasing)
16. [Risks & Open Questions](#16-risks--open-questions)

---

## 1. Executive Summary

### 1.1 What KÖMEKÇI is

KÖMEKÇI is a **two-sided mobile appointment application** for independent beauty and barber professionals ("masters") and their clients.

The application opens on a **role selection screen** — *Master* or *Client* — and from that point the two sides are effectively two different products sharing one backend, one design system and one codebase.

### 1.2 What makes it different from Fresha / Booksy / YCLIENTS

This is the single most important architectural decision in the product, and it must be understood before estimating cost:

> **KÖMEKÇI is not a marketplace. It is a private client-book.**

In Fresha, Booksy, Treatwell and DIKIDI, a client opens the app, searches a map or a category, discovers a salon they have never met, reads reviews and books. Discovery is the core product.

In KÖMEKÇI there is **no discovery, no search catalogue, no map, no public ratings**. A client can only book with a master who has **explicitly approved them**. The connection flow is:

```
Client registers
   → enters master's @nickname or phone number
   → sends connection request
   → master receives push notification
   → master approves or declines
   → only then does the client see that master's calendar, services and prices
```

This makes KÖMEKÇI structurally closer to a **private CRM with a client-facing companion app** than to a booking marketplace. The consequences:

| Consequence | Impact |
|---|---|
| No search / catalogue / geo-index | **Removes** significant backend and UI cost |
| No public reviews or star ratings | **Removes** moderation, abuse handling, review UI |
| No commission or payment processing between client and master | **Removes** PCI/escrow/payout complexity |
| Master approval gate on every relationship | **Adds** a request/approval subsystem and its notifications |
| Master monetisation is a flat subscription | Revenue is predictable; billing subsystem is required |
| Master's reputation lives outside the app (Instagram/TikTok links) | Profile is a landing page, not a ranked listing |

### 1.3 Business model

The **client side is free**. The **master side is a paid subscription** — 20 TMT/month per the reference design (final figure to be confirmed).

The master tops up an in-app balance from **mobile phone balance** or **bank card**, in **any amount**. The system auto-debits the monthly subscription from that balance. If the balance is insufficient, the account enters a **restricted (paused) state** rather than being deleted — the master keeps read access to everything, but online booking is switched off and clients see *"The master is temporarily not accepting new bookings."*

---

## 2. Market & Competitive Research

Research was carried out across three groups of comparable products: global Western platforms, CIS/regional platforms, and solo-professional niche tools.

### 2.1 Global platforms

**Fresha** — currently the largest beauty and wellness booking platform worldwide. Its distinguishing commercial choice is that it does not add booking charges that create friction for the client, which improves client adoption compared to Booksy's paid "Boost" acquisition channel. Feature-wise it is a full business suite: calendar, POS, inventory, payroll, marketing, client records.

**Booksy** — over 50 million clients use Booksy to find and book beauty and wellness professionals; it is one of the most-reviewed booking apps in the category. Its client app centres on: booking, rescheduling, paying and managing appointments in-app; browsing verified reviews and provider portfolios; buying and tracking gift cards; and booking on behalf of family and friends. Booksy's separate *Booksy Biz* app is the professional-side product.

**Vagaro** — broad SMB suite (salon, spa, fitness), strong on multi-staff and multi-location, with a marketplace layer.

**Setmore / SimplyBook.me / Treatwell** — lighter-weight scheduling tools; Setmore's positioning is free-tier salon scheduling.

### 2.2 CIS / regional platforms

**YCLIENTS** — the dominant beauty-industry ecosystem in the Russian-speaking market. It provides online booking, client-base management and CRM, notifications, and analytics, and it ships a dedicated **app for the individual master** (not only for salon chains). Its core professional tool is an "electronic journal": day-view of visits, staff access control, push notifications for new bookings, client visit history, and SMS/Email reminders. **This is the closest existing analogue to the KÖMEKÇI master cabinet.**

**DIKIDI Business** — a free international CRM for online booking, automation, management and promotion of service businesses. Its free tier is the main competitive pressure in the region.

**Altegio** — positioned for chains: reduces administrator workload, centralises data across branches, automates payroll.

### 2.3 Solo-professional tools

**GlossGenius** — built for the independent stylist selling a personal brand. Client Profiles track past services, reference photos, client preferences, before/after images and birthdays. It reports 75 %+ rebooking rates driven by automated rebooking reminders built into checkout, plus automated reminders, confirmations and appointment updates to cut no-shows.

**Squire** — the only major platform built exclusively for barbershops rather than general salons, with an "Independent" tier for solo barbers / single-chair operations at roughly $30/month.

### 2.4 The "earlier slot" feature — validated by market practice

The client-side feature in this specification — *"notify me if an earlier time becomes free"* — is a real, proven pattern. In existing platforms, stylists let clients tick a box asking to be notified if an earlier appointment becomes available, optionally with preferred days and times; the stated purpose is to **keep the schedule full when cancellations happen**, while giving the client flexibility.

Industry guidance is consistent that the most effective no-show reduction combines **automated reminders**, **deposits/prepayment**, and a **clear cancellation policy**. Some platforms trigger a deposit requirement automatically after a configured number of no-shows.

> **Recommendation:** KÖMEKÇI implements reminders and the waitlist in v1. Deposits are *not* in scope (no payment rail between client and master), so the no-show lever available to us is **reminders + a no-show counter on the client card + the master's ability to decline/remove a client**. A "no-show" outcome status is therefore added to the appointment lifecycle in §7.4.

### 2.5 Feature matrix — what we take and what we deliberately skip

| Feature | Fresha | Booksy | YCLIENTS | GlossGenius | **KÖMEKÇI** |
|---|:---:|:---:|:---:|:---:|:---:|
| Public discovery / marketplace | ✅ | ✅ | ✅ | ➖ | ❌ **out of scope** |
| Master-approved private connection | ❌ | ❌ | ❌ | ❌ | ✅ **differentiator** |
| Online booking calendar | ✅ | ✅ | ✅ | ✅ | ✅ |
| Service list with price & duration | ✅ | ✅ | ✅ | ✅ | ✅ |
| Automated reminders | ✅ | ✅ | ✅ | ✅ | ✅ |
| Waitlist / earlier-slot alert | ✅ | ✅ | ✅ | ✅ | ✅ |
| Client reschedule & cancel | ✅ | ✅ | ✅ | ✅ | ✅ |
| Visit history + "book again" | ✅ | ✅ | ✅ | ✅ | ✅ |
| "I'm running late" signal | ❌ | ❌ | ❌ | ❌ | ✅ **differentiator** |
| Manual (offline / phone) booking by master | ✅ | ✅ | ✅ | ✅ | ✅ **critical for this market** |
| Master work schedule + vacation | ✅ | ✅ | ✅ | ✅ | ✅ |
| Client card with full history | ✅ | ✅ | ✅ | ✅ | ✅ |
| In-app payments / POS | ✅ | ✅ | ✅ | ✅ | ❌ out of scope |
| Reviews & star ratings | ✅ | ✅ | ✅ | ➖ | ❌ out of scope |
| Inventory / payroll / multi-branch | ✅ | ➖ | ✅ | ➖ | ❌ out of scope |
| Gift cards | ✅ | ✅ | ➖ | ✅ | ❌ out of scope |
| Master subscription billing | ✅ | ✅ | ✅ | ✅ | ✅ (local rails) |

### 2.6 Lessons applied to KÖMEKÇI

1. **The master app is the product; the client app is the companion.** YCLIENTS' master-focused app proves an individual professional will pay for a good electronic journal. Design investment should be weighted toward the master calendar.
2. **Rebooking is the retention engine.** GlossGenius' 75 %+ rebooking rate comes from making rebooking one tap away from history. Our "Book again" button in history must pre-fill master + service and jump straight to slot selection.
3. **Manual booking is not a secondary feature.** In a market with feature phones and low connectivity, the master must be able to enter a phone-call booking in under 15 seconds. This is a first-class flow, not a settings-buried form.
4. **Do not copy the suite.** Fresha/Vagaro breadth (POS, inventory, payroll) is the wrong target for a 20 TMT/month product on low-RAM devices.

---

## 3. Product Principles & Hard Constraints

### 3.1 Constraints given by the client

| # | Constraint | Engineering consequence |
|---|---|---|
| C-1 | Must run well on **low-RAM phones** | Target 1 GB RAM / Android 8. No heavy animation libraries, no video, aggressive image downscaling, list virtualisation everywhere. |
| C-2 | Must work on **slow / unstable internet** | Offline-first local cache, optimistic UI with rollback, small JSON payloads, image CDN with size variants, retry with backoff. |
| C-3 | **4 switchable colour themes** | Full design-token architecture; no hard-coded colours anywhere in the codebase. |
| C-4 | **Luxury minimalist** visual style | Reference design: serif wordmark, ivory/onyx palette, generous whitespace, thin strokes, gold accent. |
| C-5 | **Micro-animations only** | See §12. Motion must never block input or delay a screen. |

### 3.2 Design principles

1. **Nothing blocks on the network.** Every screen renders from cache first, then reconciles.
2. **The truth about a time slot lives on the server.** The client UI may be stale; therefore every booking, move and confirm is re-validated server-side at the moment of the action (this is already mandated in the source requirements and is generalised here into a rule).
3. **One tap from the calendar to any action.** The master's most frequent actions — mark done, call client, add manual booking — must be reachable from the day view.
4. **Silence is a feature.** No badge spam, no promotional pushes, no animated banners.

---

## 4. Roles, Onboarding & Navigation Map

### 4.1 First-run flow

```
┌──────────────────────┐
│  Splash / wordmark   │  KÖMEKÇI
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│   Role selection     │   "Choose your role"
│  ┌────────┬────────┐ │
│  │ MASTER │ CLIENT │ │
│  └────────┴────────┘ │
└─────┬──────────┬─────┘
      │          │
      ▼          ▼
 Subscription   Client
 information    registration
      │          │
      ▼          ▼
 Master         Connect to
 registration   first master
 (4 steps)          │
      │              ▼
      ▼          Client home
 Master home
```

**Role selection screen** (per reference design):
- Wordmark `KÖMEKÇI` in serif type.
- Caption: *"Choose your role"*.
- Two cards side by side:
  - **MASTER** — icon, caption *"Manage your work and clients"*.
  - **CLIENT** — icon, caption *"Book with your specialist"*.
- Primary CTA: `Get Started` (pill button, dark chevron block on the right).
- The role choice is persisted. It is **not** changeable in-app after registration; a user who needs both roles registers two accounts with different phone numbers. *(Flagged as an open question in §16.)*

### 4.2 Navigation — Client

Bottom tab bar, 4 tabs:

| Tab | Screen |
|---|---|
| **Home** | Active master, next appointment card, quick "Book" CTA |
| **Booking** | Calendar → service → time → note → confirm |
| **History** | Past appointments, "Book again" |
| **Profile** | My masters, personal data, theme, language, notifications |

### 4.3 Navigation — Master

Bottom tab bar, 5 tabs:

| Tab | Screen |
|---|---|
| **Calendar** | Day / week view, queue, manual add (FAB) |
| **Clients** | My clients list, statuses, search, client card |
| **Services** | Service catalogue CRUD |
| **Schedule** | Working days, hours, breaks, days off, vacation |
| **Profile** | Public profile, subscription & balance, settings |

---

# 5. PART 1 — CLIENT SIDE

## 5.1 Client registration

**Screen:** `client/register`

**Fields:**

| Field | Required | Validation |
|---|:---:|---|
| Profile photo | Yes | Image, cropped to square, compressed to ≤ 200 KB before upload |
| Name | Yes | 2–50 characters |
| Nickname | Yes | **Unique across the whole system.** 3–20 chars, `a–z 0–9 _`, lowercase, no leading digit |
| Phone number | Yes | Turkmenistan format `+993 XX XXXXXX`; unique |

**Behaviour:**

1. Client fills the form and presses **Register**.
2. The server checks **nickname uniqueness**.
   - If taken → inline error under the field: *"This nickname is already taken"* + 3 suggested alternatives.
   - If free → client profile is created.
3. Phone verification by SMS OTP (6 digits, 60-second resend cooldown). *(Required for account security; see §16 for SMS-gateway question.)*
4. On success → **Connect to your master** screen.

**Screen:** `client/connect-master`

- Single input: *"Enter your master's nickname or phone number"*.
- Live lookup as the client types (debounced 400 ms, minimum 3 characters).
- On match, a compact preview card appears: master's photo, name, `@nickname`, address.
- Button: **Send request**.
- The master receives a **push notification** about the new request and can **accept** or **decline**.
- Client-side states:

| State | UI |
|---|---|
| Request sent | Card with `Pending` chip, subtitle *"Waiting for confirmation"* |
| Accepted | Push to client; master moves into "My masters"; calendar unlocked |
| Declined | Card removed, neutral message *"Request was not accepted"* — no reason shown |

- Only after the master accepts is the client **automatically added to the master's client list** and granted access to the booking calendar.

**Edge cases:**
- Nickname / phone not found → *"No master found with these details"*.
- Duplicate request to the same master → button disabled with `Pending` state.
- Client may send requests to several masters in parallel.

---

## 5.2 Booking an appointment

**Screen:** `client/booking`

Available only after the master's confirmation. On entry the client receives a push notification confirming access.

### 5.2.1 What the calendar shows

- **Available dates** — derived from the master's working days, minus days off, minus vacation, minus fully booked days.
- **Available times** — slots free of existing bookings, respecting the selected service's duration and the master's break.
- **Service list** — every service the master publishes.
- **Price of each service** — displayed next to the service name in TMT.

Visual reference: horizontal week strip with the selected date in a filled circle, then a wrapped grid of time chips, then the service list. Unavailable dates/times are rendered at 35 % opacity and are not tappable.

### 5.2.2 Booking sequence

```
1. Select service   → duration is now known
2. Select date      → server returns slots valid for that duration
3. Select time
4. (optional) Note
5. (optional) ☐ Notify me if an earlier time frees up
6. Press "Book"
7. Server RE-VALIDATES availability
      ├─ free  → appointment created, confirmation ✓ animation
      └─ taken → error "Unfortunately, this time is already taken."
                 calendar refreshes, client picks again
```

### 5.2.3 The Note field

Optional free-text field, max 200 characters.
Placeholder examples given by the client: *eyebrow shaping, ear cleaning, nose cleaning, and other requests.*
The note is shown to the master on the appointment card in the calendar.

### 5.2.4 Earlier-slot waitlist

Checkbox on the booking screen: **☐ Notify me if an earlier time becomes available.**

Server behaviour:

1. When the flag is on, the appointment is registered in a **waitlist queue** for that master.
2. The server monitors cancellations and moves.
3. When a slot **earlier than the client's current appointment** and **on or before the same date** frees up, and it fits the booked service's duration, the server sends a push:
   > *"An earlier time has become available. Would you like to move your appointment?"*
   with **Yes** / **No** buttons.
4. On **Yes** → the server **re-checks availability**.
   - Free → the appointment is **moved automatically**; confirmation push to client, notification to master.
   - Taken → message: *"Unfortunately, this time is already taken."*
5. On **No** → the client keeps the waitlist flag active and remains eligible for the next freed slot.

**Race-condition rule:** the freed slot is offered to waitlisted clients **in order of booking creation time (FIFO)**, one at a time, with a **10-minute soft reservation** per offer. If the offer expires or is declined, it passes to the next client in the queue. *(This ordering rule is a design addition — it is required to make the feature deterministic; see §16.)*

---

## 5.3 Appointment reminders

Automatic push notifications:

| Trigger | Message |
|---|---|
| On the day of the appointment (default 10:00) | *"Reminder: you have an appointment with your master today at 18:00."* |
| 30 minutes before the start | *"Your appointment starts in 30 minutes. Please arrive on time."* |

**The send times must be configurable in the system** — i.e. exposed as backend configuration (admin-level), not hard-coded. Configurable parameters:

- Day-of reminder hour (default `10:00`)
- Pre-appointment lead time (default `30 min`)
- Whether each reminder type is enabled globally
- Per-client opt-out in Profile → Notifications

---

## 5.4 Changing and cancelling an appointment

Available **any time before the appointment start time**. The appointment card exposes two buttons: **Change appointment** and **Cancel appointment**.

### 5.4.1 Change

1. Opens the calendar of free dates and times (same component as booking).
2. Client selects a new slot.
3. Server checks slot availability.
   - Free → appointment is moved. Push to master: *"[Client] moved their appointment to [date, time]."*
   - Taken → error, client picks again.
4. The old slot is released immediately and becomes available to the waitlist.

### 5.4.2 Cancel

1. Confirmation dialog: *"Cancel your appointment on [date] at [time]?"* — **Yes, cancel** / **Keep it**.
2. On confirmation:
   - The appointment is removed from the **client's** calendar.
   - The appointment is removed from the **master's** calendar.
   - The time slot is **freed**.
   - The master receives a **push notification about the cancellation**.
   - Waitlisted clients are evaluated for the freed slot (§5.2.4).
3. The appointment moves to history with status **Cancelled**.

---

## 5.5 Appointment history

**Screen:** `client/history`

Each row shows:

| Field |
|---|
| Date |
| Time |
| Master |
| Service |
| Price |

Plus a status chip (Completed / Cancelled / No-show) using the colour language defined in §11.5.

**"Book again" button** on every row:
1. Pre-fills master + service.
2. Server checks availability of the equivalent slot.
3. If that time is taken, the client is taken to the calendar to **choose another free slot**.

Sorting: newest first. Filters: by master, by status. Infinite scroll, 20 items per page.

---

## 5.6 Running late

Inside an **active appointment** (today, not yet completed) a button is shown: **I'm running late**.

Options:
- **5 minutes**
- **10 minutes**

On confirmation the master receives a **push notification with the expected delay**:
> *"[Client name] will be about 10 minutes late."*

The appointment card in the master's calendar gains a **"Late"** status marker (see §6.6). The signal is informational — it does **not** automatically shift the schedule.

**Rules:**
- The button appears from `start_time − 60 min` until `start_time + 30 min`.
- The client may send the signal once; sending again replaces the previous value.

---

## 5.7 My masters

**Screen:** `client/profile/masters`

A client may be connected to **several masters**.

Capabilities:

| Action | Description |
|---|---|
| View list | All connected masters with photo, name, `@nickname`, address |
| Select **active master** | Radio/highlight selection; one active at a time |
| Change active master | At any time, one tap |
| Remove master | With confirmation; also removes the connection on the master's side |
| Add master | Re-uses the `connect-master` flow |

**The active master drives the entire client experience** — the booking calendar, the services and prices shown, the visit history filter, and the home screen card all reflect the currently active master.

Pending requests appear in the same list with a `Pending` chip and are not selectable as active.

---

## 5.8 Client profile & settings

| Section | Contents |
|---|---|
| Personal data | Photo, name, nickname (editable, uniqueness re-checked), phone (change requires OTP) |
| My masters | §5.7 |
| Notifications | Toggles: reminders, earlier-slot offers, master messages |
| Appearance | 4 colour themes (§11.2), light/dark follow-system |
| Language | Turkmen / Russian / English |
| About | Version, terms, privacy, support contact |
| Log out / Delete account | Deletion removes personal data and anonymises history |

---

# 6. PART 2 — MASTER SIDE

## 6.1 Subscription and payment

### 6.1.1 Pre-registration disclosure

After choosing the **Master** role and **before registration**, the user sees the paid-subscription screen (per reference design):

- Crown icon.
- Title: **FOR MASTERS**.
- Price: **20 manat / month** *(final figure to be confirmed)*.
- Subtitle: *"All the tools to manage bookings, clients and your schedule."*
- Checklist: ✓ 24/7 online booking · ✓ Calendar and schedule · ✓ Clients and booking history · ✓ Notifications and reminders · ✓ Support
- CTA: `Get Started`.

### 6.1.2 Balance top-up

The master can top up the balance:

- From **mobile phone balance**.
- By **bank card**.
- **Any amount** (no fixed packages).

After a successful top-up the funds are credited to the master's balance. **Every month the system automatically debits the subscription price** from that balance.

### 6.1.3 "Subscription and payment" section

Displays:

| Item |
|---|
| Current balance |
| Monthly subscription price |
| Date of the next automatic debit |
| End date of the paid period |
| History of top-ups and automatic debits |

The history is a chronological ledger: date, type (`Top-up` / `Subscription charge`), amount, resulting balance, status.

### 6.1.4 Billing notifications

- After a **successful debit** → push notification.
- **7 days, 3 days and 1 day before** the debit → reminder notifications.
- On **failed debit** → immediate notification explaining the restriction.

### 6.1.5 Insufficient funds — restricted state

If there are not enough funds, the subscription is **suspended**. In this state:

| Allowed | Blocked |
|---|---|
| ✅ Master can log into the app | ❌ New bookings cannot be created |
| ✅ Can view profile, calendar, clients, booking history | ❌ Online booking becomes inactive |
| ✅ All existing bookings are preserved | ❌ Manual booking creation is also blocked |

Clients of a suspended master see: **"The master is temporarily not accepting new bookings."** Their existing appointments remain valid and reminders still fire.

A persistent banner is shown at the top of every master screen with a **Top up** CTA.

**After the balance is topped up and the automatic debit succeeds, all functions become available again** — immediately, without re-registration.

### 6.1.6 Billing state machine

```
        top-up + successful debit
   ┌──────────────────────────────────┐
   ▼                                  │
ACTIVE ──debit fails / balance low──► SUSPENDED
   │                                     │
   │ (paid period still running)         │ (read-only, booking off)
   ▼                                     │
GRACE (0 days by default, configurable) ─┘
```

---

## 6.2 Master registration

Multi-step wizard with a 4-dot progress indicator (per reference design).

| Field | Required |
|---|:---:|
| Role: Master | Yes |
| Profile photo | Yes |
| Name | Yes |
| Nickname (**unique**) | Yes |
| Phone number | Yes |
| Address | Yes |
| Description | Yes |
| Instagram / TikTok and other links | **Optional** |
| Profile banner | Yes |

After registration the master's profile is created.

**Step grouping:**
1. Photo, name, nickname
2. Phone (+ OTP), address
3. Description, social links
4. Banner, review & finish

---

## 6.3 Master profile

**Screen:** `master/profile`

The public-facing profile contains:

| Element |
|---|
| Banner |
| Profile photo |
| Name |
| Nickname |
| Address |
| Contact information |
| Description |
| Social networks |

This is exactly what a connected client sees when they open the master's page. All fields are editable in place.

---

## 6.4 Services

**Screen:** `master/services`

Operations: **add**, **edit**, **delete** a service.

Each service specifies:

| Field | Required | Notes |
|---|:---:|---|
| Service photo | Yes | Thumbnail in lists, hero in detail |
| Service name | Yes | 2–60 characters |
| Description | **Optional** | Up to 300 characters |
| Price | Yes | TMT, integer or 2 decimals |
| **Duration (in minutes)** | Yes | Drives all slot calculations |

**Rules:**
- Duration is the atomic unit of the booking grid. Recommended increments: 15 / 30 / 45 / 60 / 90 / 120 minutes, plus custom.
- Deleting a service does **not** delete past appointments; historical records keep a snapshot of the service name, price and duration at the time of booking.
- A service can be **hidden** rather than deleted (recommended addition, so a master can pause a service seasonally — see §16).
- Reordering by drag handle.

---

## 6.5 Working schedule

**Screen:** `master/schedule`

The master can configure:

| Setting |
|---|
| Working days of the week |
| Start time of the working day |
| End time of the working day |
| Break (**optional**) |

Additionally the master can:
- **Change the schedule** at any time.
- **Mark a specific day as non-working.**
- **Change the working hours for a specific date** (a one-off override).

### 6.5.1 Vacation

The master specifies a **vacation period** (start date – end date). For that period:
- Booking is **automatically closed**.
- After the period ends, booking **reopens according to the regular working schedule**.

### 6.5.2 Server rule

> The server takes the **working schedule, days off and vacation** into account when computing available slots. No slot may be offered outside these boundaries.

Precedence, highest first:

```
1. Existing appointment (blocked)
2. Vacation period (blocked)
3. Date-specific override (non-working, or custom hours)
4. Break (blocked)
5. Weekly working schedule
6. Otherwise → unavailable
```

---

## 6.6 Calendar and client queue

**Screen:** `master/calendar` — the primary working screen of the app.

**All bookings are automatically sorted by date and time.**

Each appointment card shows:

| Field |
|---|
| Client photo |
| Name or nickname |
| Phone number |
| Service name |
| Date and time of the appointment |
| Client's note (if any) |
| **"Late" status** |

The list presents:
- **Upcoming appointments**
- **The current queue** (today)
- **Completed appointments** — shown **separately or at the bottom of the list**

### 6.6.1 Day view layout

```
┌─────────────────────────────────────┐
│  ‹  Wednesday, 15 August         ›  │   date strip
├─────────────────────────────────────┤
│  ● 10:00  Ali            Haircut    │  ← next up, accent border
│    +993 6X XXXXXX        45 min     │
│    ⚠ Late 10 min                    │
├─────────────────────────────────────┤
│  ○ 11:00  Myrat          Beard      │
│    note: "shorter on the sides"     │
├─────────────────────────────────────┤
│  ○ 12:00  Anna           Colouring  │
├─────────────────────────────────────┤
│  ▾ Completed (3)                    │  ← collapsed section
└─────────────────────────────────────┘
                              ⊕  FAB → manual booking
```

### 6.6.2 Card actions

Tap a card → bottom sheet with:
- **Mark as completed** (✓)
- **Cancel appointment**
- **Call client** (opens dialer)
- **Move appointment** (opens slot picker)
- **View client card**

---

## 6.7 My Clients

**Screen:** `master/clients`

> This section consolidates the original "Clients" requirement and the "My clients" addendum.

### 6.7.1 The list

The master sees a list of all their clients. Each row shows:

| Field | Source |
|---|---|
| Client photo | Client profile |
| Name or nickname | Client profile |
| **Appointment date** | Nearest relevant appointment |
| **Appointment time** | Nearest relevant appointment |
| **Selected service** | Nearest relevant appointment |
| Phone number | Client profile |
| Date of last visit | Derived |
| Total number of visits | Derived |

### 6.7.2 Client status

Every client row carries a status reflecting their nearest appointment. The three statuses are:

| Status | Meaning | Visual |
|---|---|---|
| **Expected** | The client is booked but has not arrived yet | **Yellow** indicator ● |
| **Completed** | The client arrived and received the service | **Green check** ✓ |
| **Cancelled** | The appointment was cancelled | **Red** indicator ● |

**The statuses must be visually distinct from one another.** Implementation: a coloured leading dot/icon *plus* a text label *plus* a tinted chip background — never colour alone, so the distinction survives on cheap low-gamut screens and for colour-blind users.

### 6.7.3 Sorting

**By default the nearest appointments are shown first.** Example:

```
10:00 — Ali
11:00 — Myrat
12:00 — Anna
```

**After an appointment is completed, the client is automatically moved to the visit history.** They leave the active queue and appear in the client's own history section and in the client card's history tab.

Additional sort options: by name, by last visit, by number of visits.

### 6.7.4 Search

The master can search a client by **name, nickname or phone number**. Search is local-first over the cached client list (works offline), then reconciles with the server.

### 6.7.5 Client card

Opening a client row shows the full client card:

- Header: photo, name, `@nickname`, phone, call button
- Stats: total visits, last visit, no-show count, total spend
- **Full history of bookings and visits**: dates, times, services rendered
- Master's private notes about the client *(recommended addition, see §16)*
- Actions: create booking for this client, remove client

---

## 6.8 Manual client booking

**Screen:** `master/booking/manual` — reached from the FAB on the calendar.

The master can create an appointment for a client themselves. This is necessary when:

- the client called by phone;
- the client uses an ordinary (feature) phone;
- the client does not use the internet;
- the master is queueing the client up personally.

### 6.8.1 Fields

| Field | Required |
|---|:---:|
| Client name | Yes |
| Phone number | **Optional** |
| Service | Yes |
| Date | Yes |
| Time | Yes |

If a phone number is entered and it matches an existing connected client, the app offers to link the booking to that client record instead of creating a new offline contact.

### 6.8.2 Behaviour after saving

> After saving, the appointment appears in the master's general calendar and **blocks the selected time**.

That is: the slot is immediately removed from the availability set exposed to app clients, exactly like an online booking. Offline-created appointments participate in every calendar rule — sorting, statuses, completion, cancellation and the waitlist release on cancellation.

### 6.8.3 Offline client records

A manually created client without an app account is stored as an **offline contact** on the master's side only. It:
- appears in "My clients" with a small `Offline` marker instead of a photo (initials avatar);
- accumulates visit history exactly like an app client;
- receives **no** push notifications (no account) — the master is responsible for calling them;
- can later be **merged** into a real client account when that person registers and connects with the same phone number.

---

## 6.9 Master settings

| Section | Contents |
|---|---|
| Subscription & payment | §6.1 |
| Public profile | §6.3 |
| Connection requests | Pending client requests, accept / decline |
| Notifications | Toggles per event type |
| Appearance | 4 colour themes, light/dark |
| Language | Turkmen / Russian / English |
| Support | Contact channel |

---

# 7. Booking Engine — Shared Rules

## 7.1 Slot computation

For a given master, date `D` and service duration `L`:

```
available_slots(D, L) =
    generate_grid(work_start(D), work_end(D), step = GRID_STEP)
  − break_intervals(D)
  − vacation(D)
  − existing_appointments(D)   [inflated by L]
  − past_times(if D == today)
```

- `GRID_STEP` default **15 minutes**, configurable per master *(recommended; see §16)*.
- A slot at time `T` is valid only if `[T, T+L]` fits entirely inside working hours and overlaps nothing.
- For today, slots earlier than `now + MIN_LEAD` are removed. `MIN_LEAD` default **30 minutes**, configurable.

## 7.2 Double-booking prevention

Every mutating operation (`create`, `move`, `waitlist accept`) executes inside a **database transaction with a uniqueness constraint on (master_id, time range)**. The server **re-validates availability at the moment of the action** and returns a typed conflict error if the slot was taken in the meantime. The client app then refreshes the calendar and asks the user to choose again.

This is the mechanism behind three separately stated requirements in the source specification: the re-check on **Book**, the re-check on **earlier-slot acceptance**, and the re-check on **Book again**.

## 7.3 Appointment lifecycle

```
                 ┌──────────────┐
   create ─────► │   EXPECTED   │
                 └──┬────┬───┬──┘
        client/master│    │   │ master marks done
              cancel │    │   └──────────► COMPLETED ──► moves to history
                     │    │
                     │    └─ client signals late ─► EXPECTED (late flag)
                     ▼
                 CANCELLED ──► slot freed ──► waitlist offer
                     
   start_time + NO_SHOW_WINDOW passed, not completed
                     └──────────► NO_SHOW  (master-confirmable)
```

| Status | Set by | Colour |
|---|---|---|
| `EXPECTED` | System on creation | Yellow |
| `COMPLETED` | Master | Green |
| `CANCELLED` | Client or master | Red |
| `NO_SHOW` | Master (suggested by system) | Grey-red |

`NO_SHOW` is an addition beyond the source document — it is required to make the no-show counter on the client card meaningful (§2.4). If the client prefers, it can be folded into `CANCELLED`.

## 7.4 Timezone

All timestamps stored in **UTC**, displayed in **Asia/Ashgabat (UTC+5)**. No DST.

---

# 8. Notification System

## 8.1 Event catalogue

| # | Event | Recipient | Trigger |
|---|---|---|---|
| N-01 | New connection request | Master | Client sends request |
| N-02 | Request accepted | Client | Master accepts |
| N-03 | Request declined | Client | Master declines |
| N-04 | New booking created | Master | Client books |
| N-05 | Booking confirmed | Client | Server creates appointment |
| N-06 | Day-of reminder (default 10:00) | Client | Scheduler |
| N-07 | 30-minute reminder | Client | Scheduler |
| N-08 | Earlier slot available | Client | Slot freed + waitlist match |
| N-09 | Appointment moved | Master & Client | Move committed |
| N-10 | Appointment cancelled by client | Master | Client cancels |
| N-11 | Appointment cancelled by master | Client | Master cancels |
| N-12 | Client running late | Master | Client presses "I'm late" |
| N-13 | Subscription debited successfully | Master | Billing job |
| N-14 | Debit reminder — 7 days | Master | Scheduler |
| N-15 | Debit reminder — 3 days | Master | Scheduler |
| N-16 | Debit reminder — 1 day | Master | Scheduler |
| N-17 | Subscription suspended | Master | Failed debit |
| N-18 | Subscription reactivated | Master | Successful top-up + debit |
| N-19 | Top-up successful | Master | Payment callback |

## 8.2 Delivery strategy — market-specific

Push delivery through Firebase Cloud Messaging depends on Google Play Services, which is not uniformly available or reliable on all devices and networks in this market. The system therefore implements a **layered delivery strategy**:

| Layer | Mechanism | Purpose |
|---|---|---|
| 1 | **FCM push** | Primary, when available |
| 2 | **Local notification scheduling** | All time-based reminders (N-06, N-07, N-14…N-16) are *also* scheduled locally on the device at booking time, so they fire without any network |
| 3 | **In-app inbox** | Every event is persisted server-side and shown in an in-app notification list on next launch |
| 4 | **SMS fallback** *(optional, costed separately)* | Critical events only (N-02, N-08) if an SMS gateway is contracted |

Local scheduling is cancelled/rescheduled whenever an appointment is moved or cancelled.

## 8.3 Message templates

All notification text is stored as **localised templates** with named placeholders, editable server-side without an app release:

```
N-06: "Reminder: you have an appointment with {master_name} today at {time}."
N-07: "Your appointment starts in 30 minutes. Please arrive on time."
N-08: "An earlier time has become available. Would you like to move your appointment?"
N-12: "{client_name} will be about {minutes} minutes late."
```

---

# 9. Data Model

## 9.1 Entities

```
User
  id, role(CLIENT|MASTER), phone, nickname*, name, photo_url,
  locale, theme, created_at, status

MasterProfile
  user_id, banner_url, address, description,
  instagram_url, tiktok_url, other_links[],
  subscription_status(ACTIVE|SUSPENDED), balance, next_charge_at,
  paid_until, grid_step_min, min_lead_min

Service
  id, master_id, photo_url, name, description,
  price, duration_min, is_hidden, sort_order

WorkSchedule
  master_id, weekday(0-6), is_working,
  start_time, end_time, break_start, break_end

ScheduleOverride
  id, master_id, date, type(DAY_OFF|CUSTOM_HOURS),
  start_time, end_time

Vacation
  id, master_id, start_date, end_date

Connection            -- client ⇄ master relationship
  id, client_id, master_id,
  status(PENDING|ACCEPTED|DECLINED|REMOVED),
  requested_at, decided_at

OfflineClient         -- manually added, no account
  id, master_id, name, phone?, created_at, merged_into_user_id?

Appointment
  id, master_id,
  client_id?  |  offline_client_id?,     -- exactly one
  service_id, service_snapshot{name, price, duration_min},
  starts_at, ends_at,
  status(EXPECTED|COMPLETED|CANCELLED|NO_SHOW),
  note, source(ONLINE|MANUAL),
  late_minutes?, waitlist_earlier bool,
  created_at, updated_at, cancelled_by?

WaitlistEntry
  id, appointment_id, client_id, master_id,
  before_time, created_at, offered_at?, offer_expires_at?

BalanceTransaction
  id, master_id, type(TOPUP|CHARGE|REFUND),
  amount, balance_after, method(MOBILE|CARD),
  external_ref, status, created_at

NotificationLog
  id, user_id, event_code, payload, channel, sent_at, read_at
```

`*` nickname is unique across all users.

## 9.2 Key indexes

```
users(nickname) UNIQUE
users(phone) UNIQUE
appointments(master_id, starts_at)
appointments(client_id, starts_at DESC)
EXCLUDE constraint on (master_id, tstzrange(starts_at, ends_at))
        WHERE status IN ('EXPECTED','COMPLETED')
connections(master_id, status)
connections(client_id, status)
```

The exclusion constraint is what makes double-booking structurally impossible rather than merely unlikely.

---

# 10. API Surface

REST/JSON over HTTPS. All list endpoints are cursor-paginated and support `If-None-Match` for cheap revalidation on slow networks.

## 10.1 Auth

```
POST   /auth/register            role, name, nickname, phone, photo
POST   /auth/otp/request         phone
POST   /auth/otp/verify          phone, code        → tokens
GET    /auth/nickname/available  ?nickname=
POST   /auth/refresh
```

## 10.2 Client

```
GET    /masters/lookup?q=            nickname or phone
POST   /connections                  master_id           → request
GET    /connections                  my masters + status
PATCH  /connections/{id}/active      set active master
DELETE /connections/{id}

GET    /masters/{id}/services
GET    /masters/{id}/availability?date=&service_id=
POST   /appointments                 service_id, starts_at, note, waitlist_earlier
PATCH  /appointments/{id}/move       starts_at
POST   /appointments/{id}/cancel
POST   /appointments/{id}/late       minutes(5|10)
POST   /appointments/{id}/rebook

GET    /appointments?scope=upcoming|history
POST   /waitlist/{id}/accept
POST   /waitlist/{id}/decline
```

## 10.3 Master

```
GET|PATCH  /me/profile
GET|POST|PATCH|DELETE  /me/services[/{id}]
GET|PUT    /me/schedule
POST|DELETE /me/schedule/overrides[/{id}]
POST|DELETE /me/vacations[/{id}]

GET    /me/calendar?from=&to=
GET    /me/clients?query=&sort=
GET    /me/clients/{id}
POST   /me/appointments              manual booking
PATCH  /me/appointments/{id}/status  COMPLETED|CANCELLED|NO_SHOW

GET    /me/connection-requests
POST   /me/connection-requests/{id}/accept
POST   /me/connection-requests/{id}/decline

GET    /me/billing                   balance, next charge, paid_until
GET    /me/billing/transactions
POST   /me/billing/topup             amount, method
```

## 10.4 Error contract

```json
{
  "error": "SLOT_TAKEN",
  "message": "Unfortunately, this time is already taken.",
  "message_tk": "...",
  "message_ru": "...",
  "details": { "suggested_slots": ["11:30", "12:15"] }
}
```

Typed error codes: `SLOT_TAKEN`, `NICKNAME_TAKEN`, `NOT_CONNECTED`, `SUBSCRIPTION_SUSPENDED`, `OUTSIDE_WORKING_HOURS`, `PAST_TIME`, `OFFER_EXPIRED`.

---

# 11. Design System

## 11.1 Visual direction

Derived from the approved reference design: **luxury minimalism**.

- Serif wordmark (`KÖMEKÇI`), wide letter-spacing.
- Ivory/off-white canvas, near-black ink, muted gold accent.
- Cards with 1 px hairline borders, very soft shadows, 16–20 px radii.
- Thin-stroke line icons (1.5 px), no filled/coloured icon sets.
- Generous whitespace; content breathes.
- Signature CTA: pill button, light body + dark chevron block on the right (`Get Started ››››`).
- Photography (client avatars, service photos) is the only source of saturated colour.

## 11.2 The four themes

All colour is expressed as **semantic design tokens**. Themes swap token values only; no component may reference a raw hex value.

| Token | 1. Ivory *(default)* | 2. Onyx *(dark)* | 3. Champagne | 4. Rose |
|---|---|---|---|---|
| `bg.canvas` | `#FBFAF7` | `#0E0E0F` | `#FAF6EE` | `#FCF7F6` |
| `bg.surface` | `#FFFFFF` | `#1A1A1C` | `#FFFDF8` | `#FFFFFF` |
| `bg.elevated` | `#FFFFFF` | `#232326` | `#FFFFFF` | `#FFFFFF` |
| `ink.primary` | `#111112` | `#F5F4F1` | `#1C1811` | `#1E1618` |
| `ink.secondary` | `#6B6B70` | `#A3A3A8` | `#7A7060` | `#7C6C70` |
| `ink.tertiary` | `#9C9CA1` | `#6E6E74` | `#A89C88` | `#A99598` |
| `border.hairline` | `#E8E6E1` | `#2E2E32` | `#EBE3D4` | `#F0E4E4` |
| `accent.primary` | `#111112` | `#F5F4F1` | `#B9963F` | `#B0757C` |
| `accent.on` | `#FFFFFF` | `#0E0E0F` | `#FFFFFF` | `#FFFFFF` |
| `accent.subtle` | `#F2F1ED` | `#26262A` | `#F5EBD6` | `#FAEDED` |
| `gold` | `#C9A961` | `#D4B876` | `#B9963F` | `#C9A961` |

Status colours are shared across all four themes so that the queue reads identically everywhere:

| Token | Light | Dark |
|---|---|---|
| `status.expected` | `#D9A21B` | `#E8B94A` |
| `status.completed` | `#2E7D5B` | `#4CAF83` |
| `status.cancelled` | `#C0392B` | `#E06055` |
| `status.late` | `#D9741B` | `#E8934A` |

Every foreground/background pair listed above meets **WCAG AA (≥ 4.5:1)** for body text and **≥ 3:1** for large text and icons.

**Theme switching** is instant, persisted locally, and applied without an app restart.

## 11.3 Typography

| Role | Font | Size / Line height | Weight |
|---|---|---|---|
| Wordmark | Serif display (e.g. Playfair Display) | 32 / 40 | 400, +8 % tracking |
| H1 screen title | Sans (Inter / SF) | 24 / 32 | 600 |
| H2 section | Sans | 18 / 26 | 600 |
| Body | Sans | 15 / 22 | 400 |
| Caption / meta | Sans | 13 / 18 | 400 |
| Numeric (time, price) | Sans, tabular figures | 15 / 22 | 500 |

Turkmen requires full Latin-extended coverage (`ä ö ü ç ň ş ý ž`). Fonts must be subset but must retain these glyphs. Cyrillic subset required for Russian.

## 11.4 Spacing & layout

- 4 px base grid; spacing scale `4 · 8 · 12 · 16 · 20 · 24 · 32 · 40`.
- Screen horizontal padding: **20 px**.
- Card radius **16 px**, button radius **28 px** (pill), chip radius **12 px**.
- Minimum touch target **44 × 44 px**.
- List row height: 72 px with avatar, 56 px without.

## 11.5 Status presentation

Statuses are never communicated by colour alone:

```
● Expected     yellow dot   + label "Expected"    + tinted chip
✓ Completed    green check  + label "Completed"   + tinted chip
● Cancelled    red dot      + label "Cancelled"   + tinted chip
⚠ Late         orange       + label "Late 10 min" + tinted chip
```

## 11.6 Component inventory

Buttons (primary pill, secondary outline, text, icon) · Input field · OTP input · Avatar (image / initials) · Card · List row · Status chip · Date strip · Time-slot chip · Service row · Bottom sheet · Dialog · Toast · Empty state · Skeleton loader · Segmented control · Toggle · Checkbox · Stepper dots · Banner (subscription warning) · FAB · Tab bar.

---

# 12. Motion & Animation Specification

Direct translation of the client's animation brief into implementable values.

## 12.1 Principles

| Requirement | Implementation |
|---|---|
| Short, smooth micro-animations on user actions | All durations **120–260 ms** |
| Button reacts slightly to touch | Scale **0.97**, 120 ms, `easeOut`; releases on `easeIn` |
| Selected element highlights smoothly | Background/border cross-fade 180 ms, `easeInOut` |
| Screen transitions smooth and fast | Shared-axis slide + fade, **220 ms**, `easeOutCubic` |
| Success shows a short ✓ animation | Stroke-draw check, **400 ms** total, then auto-dismiss after 800 ms |
| Animations must not delay the app or obstruct the user | No animation blocks input; all are interruptible and cancel on navigation |
| No excessive waves, strong effects or constant motion | **Banned:** ripple splash, parallax, bounce/spring overshoot, looping shimmer on idle content, confetti, particle effects, auto-playing carousels |
| Minimalist, smooth, premium (Luxury) | Opacity + subtle transform only. Never more than **two** properties animated at once. |

## 12.2 Motion tokens

```
duration.instant   = 120 ms   → press feedback
duration.fast      = 180 ms   → selection, chip state
duration.base      = 220 ms   → screen transition, sheet
duration.slow      = 400 ms   → success check draw

easing.standard    = cubic-bezier(0.2, 0.0, 0.2, 1.0)
easing.decelerate  = cubic-bezier(0.0, 0.0, 0.2, 1.0)
easing.accelerate  = cubic-bezier(0.4, 0.0, 1.0, 1.0)
```

No spring physics. No easing with overshoot.

## 12.3 Per-interaction specification

| Interaction | Animation |
|---|---|
| Button press | scale 1.0 → 0.97, 120 ms |
| Time-slot / date chip select | fill + ink colour cross-fade, 180 ms |
| Tab switch | content fade 150 ms; no sliding indicator bounce |
| Push screen | new screen slides 24 px + fades in, 220 ms |
| Bottom sheet | slide up 220 ms, backdrop fade 180 ms |
| Booking confirmed | ✓ stroke draw 400 ms + label fade, auto-dismiss 800 ms |
| List item appears | fade only, 150 ms, **no stagger** |
| Loading | static skeleton blocks; **no shimmer sweep** |
| Pull to refresh | thin 2 px progress line, no elastic bounce |
| Status change | chip colour cross-fade 180 ms |

## 12.4 Low-end device policy

- If the device reports **< 2 GB RAM** or the OS "reduce motion" setting is on, **all transforms are disabled** and only opacity fades remain.
- Frame budget: every animation must sustain 60 fps on the reference low-end device; if it cannot, it is removed rather than degraded.

---

# 13. Non-Functional Requirements

## 13.1 Performance targets (reference device: 1 GB RAM, Android 8)

| Metric | Target |
|---|---|
| Cold start to first meaningful paint | ≤ 2.0 s |
| Warm start | ≤ 800 ms |
| Screen transition | ≤ 300 ms |
| Calendar day view render (30 appointments) | ≤ 16 ms/frame |
| Peak RAM usage | ≤ 180 MB |
| APK size (Android, split per ABI) | ≤ 25 MB |

## 13.2 Network & offline behaviour

| Requirement | Implementation |
|---|---|
| App opens and is usable with no connection | Local database (SQLite/Isar) caches profile, services, schedule, clients, calendar ±30 days |
| Slow network never blocks the UI | Cache-first render, background revalidate, skeletons only on true cold cache |
| Actions survive connection loss | Write queue with idempotency keys; retries with exponential backoff; **booking actions are never optimistic** (they require server validation) and show an explicit "Sending…" state |
| Payload size | List responses ≤ 30 KB; gzip/brotli; no nested over-fetching |
| Images | Server-side resizing, 3 size variants (`64`, `256`, `1080`), WebP, on-disk LRU cache capped at 60 MB |
| Data saver mode | Optional setting: avatars only, skip banners and service photos |

## 13.3 Security & privacy

- Transport: TLS 1.2+, certificate pinning on the mobile client.
- Auth: short-lived JWT access token (15 min) + rotating refresh token; refresh token stored in Keystore/Keychain.
- Phone numbers of clients are visible **only** to masters they are connected to.
- No client can enumerate masters beyond exact nickname/phone lookup (rate-limited: 10 lookups/min/user).
- Payment credentials are never stored in the app; top-up is delegated to the provider's flow.
- Account deletion anonymises historical appointments rather than deleting the master's business records.
- Server-side rate limits on OTP request (3/hour/phone), connection requests (20/day/client).

## 13.4 Localisation

- Three languages: **Turkmen (tk)**, **Russian (ru)**, **English (en)**.
- All strings externalised; no concatenated sentences.
- Date/time formatting per locale; 24-hour clock everywhere.
- Currency: `20 TMT` / `20 манат` / `20 manat` per locale.
- Right-to-left not required.

## 13.5 Accessibility

- Minimum text size 13 px; supports OS font scaling to 130 % without clipping.
- All interactive elements have accessible labels.
- Status never conveyed by colour alone (§11.5).
- Contrast per §11.2.

## 13.6 Recommended technical stack

*(Proposal — to be confirmed with the development team.)*

| Layer | Choice | Rationale |
|---|---|---|
| Mobile | **Flutter** | One codebase for Android + iOS; strong control over rendering; good low-end performance if animation discipline is kept |
| State | Riverpod / BLoC | Predictable, testable |
| Local DB | Isar or Drift (SQLite) | Fast, small, offline-first |
| Backend | Node.js (NestJS) or Go | Either is adequate at this scale |
| Database | **PostgreSQL** | Required for the range-exclusion constraint in §9.2 |
| Jobs/scheduler | Redis + worker queue | Reminders, billing, waitlist offers |
| Push | FCM + local notifications | Layered per §8.2 |
| Media | S3-compatible storage + resizing service | Image variants |
| Admin | Lightweight web panel | Notification templates, subscription price, reminder timings, user support |

---

# 14. Screen Inventory

## 14.1 Shared (3)

1. Splash
2. Role selection
3. Language selection

## 14.2 Client (16)

4. Client registration (photo, name, nickname, phone)
5. OTP verification
6. Connect to master (search)
7. Master preview / send request
8. Request pending
9. Client home (active master, next appointment)
10. Master profile view (banner, description, services, socials)
11. Booking — service selection
12. Booking — date & time selection
13. Booking — note + waitlist + confirm
14. Booking success ✓
15. Appointment detail (change / cancel / I'm late)
16. Earlier-slot offer dialog
17. History list
18. History detail + Book again
19. My masters
20. Client profile & settings

## 14.3 Master (21)

21. Subscription information (pre-registration)
22. Master registration — step 1 (photo, name, nickname)
23. Master registration — step 2 (phone, OTP, address)
24. Master registration — step 3 (description, socials)
25. Master registration — step 4 (banner, finish)
26. Master home / calendar — day view
27. Calendar — week view
28. Appointment detail sheet
29. Manual booking form
30. Move appointment (slot picker)
31. My clients — list with statuses
32. Client search
33. Client card — profile + stats
34. Client card — visit history
35. Connection requests (accept / decline)
36. Services list
37. Service add / edit
38. Work schedule (weekly)
39. Schedule override / day-off
40. Vacation
41. Subscription & balance
42. Top-up (amount + method)
43. Transaction history
44. Master profile edit
45. Master settings

**Total: ≈ 45 screens** (excluding dialogs, sheets, empty and error states).

---

# 15. Delivery Phasing

| Phase | Scope | Outcome |
|---|---|---|
| **0 — Foundation** | Design system, 4 themes, motion tokens, component library, API skeleton, database schema | Reviewable UI kit |
| **1 — Core loop** | Role selection, both registrations, connection request/approval, services, work schedule, availability engine, online booking, master calendar, statuses | A master can be booked and can run their day |
| **2 — Retention** | Reminders (local + push), change/cancel, history, "Book again", my masters, manual booking, client card | Feature-complete for daily use |
| **3 — Monetisation** | Subscription screen, balance, top-up (mobile + card), auto-debit, suspended state, billing notifications, transaction history | Revenue-ready |
| **4 — Refinement** | Waitlist / earlier-slot offers, "I'm running late", no-show handling, data-saver mode, admin panel | Full specification delivered |
| **5 — Hardening** | Low-end device optimisation, offline testing, localisation QA, store submission | Release |

Phases 1 and 2 constitute a usable MVP. Phase 3 is required before commercial launch. Phase 4 items are individually separable and can be re-ordered or deferred to control cost.

---

# 16. Risks & Open Questions

## 16.1 Risks

| # | Risk | Mitigation |
|---|---|---|
| R-1 | **Push delivery reliability** in the target market (Google Play Services availability, network filtering) | Layered delivery per §8.2 — local notification scheduling means every time-based reminder works with zero connectivity |
| R-2 | **Payment integration** with mobile-balance and card rails is the least-specified part of the project and depends entirely on the acquirer/operator contract | Isolate behind a payment-provider interface; treat integration as a separately-scoped work item once the provider is named |
| R-3 | Low-RAM performance regressions creep in over time | Fixed reference device in CI; frame-time budget enforced in review |
| R-4 | Waitlist offers cause disputes if two clients are offered the same slot | FIFO queue + 10-minute soft reservation (§5.2.4) |
| R-5 | No discovery means empty-app problem for new clients | Product decision, accepted: growth comes from masters inviting their own clients |
| R-6 | SMS OTP cost and gateway availability | Confirm gateway before Phase 1; fallback to call-based verification if needed |

## 16.2 Questions requiring the client's decision

| # | Question | Our recommendation |
|---|---|---|
| Q-1 | **Final subscription price?** The reference design shows 20 TMT/month; the source document leaves it blank. | Confirm 20 TMT |
| Q-2 | Which **payment provider(s)** for mobile-balance and card top-up? | Must be named before Phase 3 estimation |
| Q-3 | Should a **trial period** exist for new masters (e.g. 14 days free)? | Yes — standard in the category, materially improves master acquisition |
| Q-4 | Can one person be **both** client and master with one account? | No — separate accounts, simpler and safer |
| Q-5 | Is a **grace period** allowed after a failed debit before suspension? | 3 days recommended |
| Q-6 | Should **no-show** be a distinct status, or folded into cancelled? | Distinct — needed for the client card counter |
| Q-7 | Should masters be able to **hide** a service instead of deleting it? | Yes — low cost, avoids destroying history |
| Q-8 | Should the master be able to add **private notes** on a client card? | Yes — proven retention feature in comparable products |
| Q-9 | Is the **booking grid step** fixed at 15 min or per-master configurable? | Per-master, default 15 |
| Q-10 | Does the client need a **chat** with the master? | Not in v1 — the "call client" action plus the note field covers the need at far lower cost |
| Q-11 | **iOS** in the first release, or Android first? | Android first; iOS in the same codebase one sprint later |
| Q-12 | Is an **admin web panel** in scope? | Yes, minimal — needed to edit notification timings and subscription price without an app release |

---

## Appendix A — Requirements Traceability

Every requirement from the source documents, mapped to its section here.

### Client section (ТЗ Раздел: Клиент)

| Source requirement | Section |
|---|---|
| Registration fields: photo, name, nickname, phone | §5.1 |
| Nickname uniqueness check on server | §5.1 |
| Client enters master's nickname/phone, sends request | §5.1 |
| Master receives push, accepts or declines | §5.1, N-01 |
| After confirmation client added to master's list, gets calendar access | §5.1 |
| Calendar shows free dates, free times, services, prices | §5.2.1 |
| Client selects date, time, service | §5.2.2 |
| Optional "Note" field | §5.2.3 |
| Checkbox: notify if earlier time frees up | §5.2.4 |
| Server monitors cancellations, sends offer with Yes/No | §5.2.4 |
| On Yes → re-check → move or "time already taken" | §5.2.4 |
| On "Book" → server re-checks availability | §5.2.2, §7.2 |
| Day-of reminder (e.g. 10:00) | §5.3, N-06 |
| 30-minute reminder | §5.3, N-07 |
| Notification times configurable in system | §5.3 |
| Change / cancel before appointment time | §5.4 |
| Change opens calendar, server checks, moves | §5.4.1 |
| Cancel → confirm → removed both sides, time freed, master notified | §5.4.2 |
| History: date, time, master, service, price | §5.5 |
| "Book again" with availability check | §5.5 |
| "I'm running late" — 5 / 10 minutes | §5.6 |
| Master receives push about expected delay | §5.6, N-12 |
| My masters: add several, list, select active, change, delete | §5.7 |
| Active master used for booking, calendar, history | §5.7 |

### Master section (ТЗ Раздел: Мастер)

| Source requirement | Section |
|---|---|
| Subscription info shown before registration | §6.1.1 |
| Price ___ manat/month | §6.1.1, Q-1 |
| Top up: mobile balance, bank card, any amount | §6.1.2 |
| Monthly automatic debit | §6.1.2 |
| Section shows balance, price, next debit, paid-until, history | §6.1.3 |
| Push after successful debit | §6.1.4, N-13 |
| Reminders 7, 3, 1 days before | §6.1.4, N-14–16 |
| Insufficient funds → subscription suspended | §6.1.5 |
| Suspended: login, view profile/calendar/clients/history, bookings kept | §6.1.5 |
| Suspended: no new bookings, online booking inactive | §6.1.5 |
| Client sees "Master is temporarily not accepting new bookings" | §6.1.5 |
| After top-up + debit, all functions restored | §6.1.5 |
| Registration: role, photo, name, unique nickname, phone, address, description, socials (optional), banner | §6.2 |
| Profile: banner, photo, name, nickname, address, contacts, description, socials | §6.3 |
| Services: add, edit, delete | §6.4 |
| Service fields: photo, name, description (optional), price, duration (min) | §6.4 |
| Schedule: working days, start, end, break (optional) | §6.5 |
| Change schedule, mark day non-working, change hours for a date | §6.5 |
| Vacation: period, booking closed then reopened | §6.5.1 |
| Server accounts for schedule, days off, vacation | §6.5.2 |
| Calendar sorted by date and time | §6.6 |
| Card: photo, name/nickname, phone, service, date/time, note, Late status | §6.6 |
| Upcoming, current queue, completed; completed separate or at bottom | §6.6 |
| Clients list: photo, name/nickname, phone, last visit, total visits | §6.7.1 |
| Search by name, nickname, phone | §6.7.4 |
| Client card with full history | §6.7.5 |

### Master addendum (Дополнение)

| Source requirement | Section |
|---|---|
| Separate "My clients" section | §6.7 |
| List shows photo, name/nickname, appointment date, time, service | §6.7.1 |
| Status: Expected / Completed / Cancelled | §6.7.2 |
| Statuses visually distinct — green check, yellow, red | §6.7.2, §11.5 |
| Nearest appointments first (10:00 Ali, 11:00 Myrat, 12:00 Anna) | §6.7.3 |
| After completion, client auto-moved to visit history | §6.7.3, §7.3 |
| Manual booking by master | §6.8 |
| Reasons: phone call, feature phone, no internet, master queues client | §6.8 |
| Fields: name, phone (optional), service, date, time | §6.8.1 |
| After saving appears in calendar and blocks the time | §6.8.2 |

### Animation brief

| Source requirement | Section |
|---|---|
| Short smooth micro-animations on user actions | §12.1, §12.2 |
| Button reacts slightly to touch | §12.3 |
| Selected element highlights smoothly | §12.3 |
| Screen transitions smooth and fast | §12.3 |
| Short ✓ animation on success | §12.3 |
| Animations must not delay or obstruct | §12.1, §12.4 |
| No excessive waves, strong effects, constant motion | §12.1 (banned list) |
| Minimalist, smooth, premium (Luxury) | §11.1, §12.1 |

### Platform constraints

| Source requirement | Section |
|---|---|
| 4 switchable colour themes | §11.2 |
| Must work on low-RAM phones | §13.1, §12.4 |
| Must work on slow internet | §13.2 |

---

## Appendix B — Sources

Market research was conducted against the following public sources:

- Fresha — [Best Salon Software 2026 comparison guide](https://www.fresha.com/for-business/salon/best-salon-software)
- GlossGenius — [Fresha vs Vagaro comparison](https://glossgenius.com/blog/fresha-vs-vagaro)
- GlossGenius — [Client management / CRM features](https://glossgenius.com/client-management)
- GlossGenius — [Best barber software 2026](https://glossgenius.com/blog/barber-software)
- GlossGenius — [Salon booking and payment apps](https://glossgenius.com/blog/appointment-booking-apps)
- Booksy — [Customer app features](https://biz.booksy.com/en-us/features/customer-app)
- Booksy — [Business tools and features](https://biz.booksy.com/features)
- Booksy for Customers — [Google Play listing](https://play.google.com/store/apps/details?id=net.booksy.customer&hl=en_US)
- YCLIENTS — [Application for the individual master](https://www.yclients.com/master)
- YCLIENTS — [Beauty salon software and online booking](https://www.yclients.com/ru/beauty-salon)
- a2is — [Altegio vs YCLIENTS feature and price comparison 2026](https://a2is.ru/catalog/rejting-crm-sistem/compare/altegio/yclients)
- a2is — [Altegio vs DIKIDI Business comparison 2026](https://a2is.ru/catalog/rejting-crm-sistem/compare/altegio/dikidi-business)
- STX Software — [How salon scheduling software reduces no-shows and cancellations](https://stxsoftware.com/blog/salon-scheduling-software-help-reduce-no-shows-cancellations/)
- CutieCure — [How to reduce salon no-shows: 2026 reminder playbook](https://www.cutiecure.app/blog/reduce-salon-no-shows)
- Waitlist Me — [Salon appointment and waitlist app](https://waitlist.me/salon-appointments-waitlist/)
- The Digital Merchant — [Best appointment apps for barbers](https://thedigitalmerchant.com/best-appointment-apps-for-barbers/)
- Booking Pro AI — [Best salon software 2026: comparison of 9 platforms](https://bookingpro.ai/blog/best-salon-software-2026/)

Visual references supplied by the client (Dribbble concepts and the approved KÖMEKÇI role-selection / subscription / registration mockups) informed §11 and §12.

---

*End of specification.*
