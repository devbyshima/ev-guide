# 12 — Operator app and web admin, by extension

Ticket 17, screen inventory part 2 of 2. The driver app's inventory is
[11](11-driver-screens.md); the measured design system both cite is
[10-design-system.md](10-design-system.md) and every token, size and section
reference below (`§5.6`, `space.pageMargin`, `size.ctaHeight`…) points at it.

**Neither surface has a reference screenshot.** Every screen here is *by
extension*: assembled from components measured off `refs/01.png`–`04.png`, and
named as such. Where the assembly needs something the four references do not
contain, that is recorded as a **[RAISE-OA-n]** rather than invented — the
standing rule applies with more force here, not less, because there is no
picture to check the invention against.

**The depth rule.** File 11 carries the full pixel spec, because the driver app
is what the reference *is*. This file specifies **only what the shared data
model forces** — the fields, the write boundaries, the derivation, the states
that exist because `packages/domain` says they exist. One exception: §4, the
availability write surface, is specified in full, because it is the operator
app's whole reason to exist and because getting it wrong breaks the honesty
guarantee the entire model is built on.

**Marking legend** (same as file 10). **[m]** measured in file 10 and cited
here · **[d]** derived by stated reasoning · **[?]** the reference cannot say ·
**[RAISE-OA-n]** raised, not resolved. **Fourteen are listed in §9.**

---

## 1. The governing finding: the reference is a read design

All four reference screens are **read surfaces with one button**. Before any
screen below can be assembled, this has to be said plainly, because it is the
source of most of §9:

**The reference contains no form control of any kind.** No text field, no
numeric input, no switch, no toggle, no segmented control, no stepper, no
picker, no checkbox, no radio, no slider, no date control, no search field, no
drag handle for reordering, no multi-select. It contains one CTA per screen,
five circular icon buttons, two chip variants and a settings list **with no
trailing affordance at all** (§5.6 — no chevrons).

**It also contains no:**

| Missing | Where the operator app or admin needs it |
| --- | --- |
| Sign-in screen | O1, A1 |
| Empty state | O9 (no memberships), every admin list |
| Pressed / disabled / focus state ([?] in file 10 §9) | every control on a write surface |
| Error, retry, or validation state | every write |
| Pending / in-flight state | every write, and the offline queue |
| Destructive confirmation | revoke membership, unpublish, delete a bay |
| Number, chart, or metric display | O7 stats |
| Table, dense row, or column header | the entire admin |
| Light theme | O4 used outdoors — [RAISE-OA-1] |
| Tab bar, nav bar, toolbar, or any persistent chrome | navigation, everywhere |

The last one is a positive finding and it fixes the operator app's navigation:
the reference's whole navigation vocabulary is **full-screen surfaces reached
by a push (back `←`, §5.2 md, 30.3 pt) or a presentation (close `×`, §5.2 sm,
27 pt), plus one floating avatar at `space.pageMargin`**. The operator app
inherits exactly that and **does not get a tab bar** — inventing one would be
the largest single deviation available, and nothing in the data model asks for
it.

---

## 2. Operator app — shape

Expo, `packages/ui`, one auth realm with the driver app and the admin
(ADR-0005), `packages/data` repository protocols (ADR-0006).

**Roles are membership edges, so the app has no modes.** `Membership` is
`(userId, stationId, role ∈ {owner, operator})` and the same human may be an
Owner at one station and an Operator at another (domain-model, ticket 11).
Three consequences that shape every screen below:

1. **There is no "Owner mode" and no "Operator mode".** Every role-dependent
   affordance is resolved **per station, at the station**: the rate *edit*
   surface appears where you hold `owner`, the rate *flag* surface where you
   hold `operator`.
2. **The Owner-only screens (operator management, stats) exist if you hold ≥1
   `owner` edge**, and are scoped to exactly those stations — never to "your
   account".
3. **One realm is not one session.** ADR-0005 gives one user table, not shared
   keychain state across two binaries. The user signs into the operator app
   once on its own. Sharing the session (iOS App Group, Android AccountManager)
   is build work nothing here specifies.

**Offline.** ADR-0007 is first-class here too: an operator standing in a
basement car park is the *modal* case, not the edge case. The write surface
works fully offline and queues (§4.7). The app has **no map** — the station
list is a membership query, not `stationsNear` — so it carries no basemap and
**no all-Rwanda map pack row**; that settings row is a driver affordance
(ticket 16 → file 11).

---

## 3. Operator app — screens

### O1 · Sign in

**Assembled from:** the 02 centred column (avatar §5.9 → app mark, `type.display`
26 pt Bold, accent link at `type.body` Regular `#C7FC2F`) + `§5.1` primary CTA
(46 pt, `radius.button` 4.5 pt) × 3.

Same providers as the driver app, unchanged by ADR-0003's amendment: Google,
Sign in with Apple, email magic link. **No SMS.** Sign in with Apple is
compelled on iOS by Guideline 4.8 here exactly as in the driver app, because
the operator app also offers Google.

**[d]** Three accent CTAs stacked would put three `#C7FC2F` fills on one screen
against a reference that spends the accent on **one** CTA per screen (~3.9% of
map-screen pixels, `refs/design-observations.md`). One provider takes the
accent CTA (platform-primary: Apple on iOS, Google on Android); the other two
take the same 46 pt / 4.5 pt geometry with `color.surface` `#393939` fill and
`color.text` label — a fill the reference uses for every other tappable thing
(§5.2). No new value is introduced.

**States:** idle · in-flight ([RAISE-OA-2]) · failed ([RAISE-OA-2]) · resumed
from a cross-app hand-off (§5).

### O2 · My stations

The root. **Content is fixed by `Membership`** — every station where the
signed-in user holds either role — never by geography.

**Assembled from:** `§5.10` hosting card as the row *container* (`#393939`,
`radius.card` 4.3 pt, `space.cardPadding` 13 pt, `space.cardMargin` 12.7 pt) +
`§5.4` sheet-body composition as its *contents* (leading 100 pt media at
`radius.image` 10 pt; `type.heading` 17 pt Bold title; `type.body` 13 pt
Regular subtitle; a bottom-right value slot where the sheet puts its price).
Screen title `type.title` 22 pt Bold — the only screen-level title weight the
reference shows (04). Profile reached by the `§5.9` 43 pt map avatar at
`space.pageMargin`.

| Slot | Content | Source |
| --- | --- | --- |
| Leading media | Station Photo #1, else the `§5.10` `#3E3E3E` tile carrying `Owner.icon` | `Photo` (ordered); `Owner.icon` is a bundled vector, so the fallback is the **offline-safe** one **[d]**, and the reference shows no image-absent state **[?]** |
| Title | `nameShort` (≤18) | authored, domain-model §Amendments 7 |
| Subtitle | `4 bays · 6 plugs` | structure, never prose |
| Value slot | the leading availability clause + age | availability-display §2.2 / §2.3 — **verbatim vocabulary**, no operator-app wording |
| Role marker | shown only where it differs across the list | `Membership.role` |

**Order: stalest first** — ascending `oldestContributingCapturedAt`
(availability-display §2.3). This is the operator's job queue, and freshness is
the only ordering signal the model carries that means anything to them.

**States:** loaded · loading · **no memberships → O9** · offline (quiet
indicator, ADR-0007; the driver app's indicator, reused) · queued writes
pending (count).

### O3 · Station detail (operator)

**Assembled from:** the whole 04 shell — `§5.2` close `×` 27 pt + overflow `⋯`
33.3 pt on one centre line; `§5.7` hero carousel (`Photo`, ordered, read-only —
operators do not write photos, domain-model §Write boundaries); `type.title`
22 pt title; `type.body` subtitle; the 04 owner row (25.3 pt `size.avatarOwner`
+ `type.label` 15 pt Bold); `§5.5` feature chips for connector types; `§5.8`
sticky bar.

**Substitutions, and the two slots with nothing behind them:**

- Hero badge (`§5.7`, accent near-pill + lightning glyph) → the station's
  **derived** headline availability clause, or absent. It is the one accent
  surface on the screen and must never carry a state the derivation did not
  produce.
- Feature chips → connector types from the closed vocabulary (`Type 2`, `CCS2`,
  `GB/T AC`, `GB/T DC`, `Other plug` — availability-display §2.4), with the
  `§6` 24 pt / 2 pt-stroke glyph in the chip's icon slot.
- Sticky bar left slot → the leading clause + freshness (not the rate; the
  operator's screen is about what they are here to change). CTA →
  **`Update availability`** → O4.
- **The 04 `Description` block has no field behind it.** `Station` carries
  `name`, `nameShort`, `geo`, `vehicleClassTag`, `updatedAt`, Photos, Bays —
  and **no description** (domain-model §Entity model). The block is dropped;
  adding one is a schema change, not a screen decision. [RAISE-OA-3]
- **The 04 owner row's trailing message icon has no equivalent.** EV Guide has
  no messaging entity and never will in v1 (`Messages` is one of the three
  reference quick actions with nothing behind it). The slot goes unused.

### O4 · Update availability — **§4 below, in full**

### O5 · Rate

One route, two surfaces, resolved by the membership edge on **this** station.

**O5a · Rate edit (`owner` edge).** Per-Connector `ratePerKwhRwf` + optional
`sessionFeeRwf`; saving stamps `rateConfirmedAt = now` (90-day decay, ticket
10). Assembled from `§5.6` settings rows with the value right-aligned at
`type.label` 15 pt Bold. **The reference contains no text input** — the resting
row is measured, the focused/editing row is not. [RAISE-OA-4]

**Bulk apply is correct here and forbidden in O4, and the asymmetry is the
point.** `rateCoverage` is denominated in plugs and returns `distinctRates[]`
(domain-model §Amendments 6), so one price across eight plugs is the normal
case. A rate is a **declaration about policy** — the owner knows it without
looking at anything. Availability is an **observation about the world** — you
have to walk to the gun. So O5a offers a plug multi-select and O4 offers no
bulk control at any level (§4.4).

**O5b · Rate flag (`operator` edge).** Ticket 10 grants operators a flag and
**no entity exists to write it into.** `Report` is availability-only;
domain-model has no `RateFlag`. [RAISE-OA-5] — the minimum shape a screen needs
is append-only `(connectorId, reporterId, capturedAt, reason?)`, but that is a
schema decision, not mine.

### O6 · Operators (Owner)

Membership CRUD scoped to the owner's own stations: list per station, invite by
email (ADR-0005: "operators and owners join by email invitation"), revoke.

**Assembled from:** `§5.6` settings rows (person glyph + name) + `§5.1` primary
CTA (`Invite operator`) + `§5.10` card for the explanatory block.

**`Membership` cannot express a pending invitation.** It is
`(userId, stationId, role)` unique — and an invitee has no `userId` until they
accept. [RAISE-OA-6] Revoke is destructive and the reference has **no
confirmation pattern** ([RAISE-OA-2]).

### O7 · Stats (Owner) — §6 below

### O8 · Profile (operator app)

**Assembled from:** 02 verbatim — `§5.9` 105.3 pt profile avatar with its
1 pt accent ring, `type.display` 26 pt name, accent link, `§5.6` settings list
under a `type.heading` 17 pt Bold `Settings`.

**Minus** the three quick-action circles: `Trips`/`Wishlist`/`Messages` have no
operator equivalent (`SavedStation` is a driver concept, there is no trip and
no messaging), and the trio is dropped rather than backfilled. **Minus**
`Payment & payouts`: doubly absent here, since operators earn nothing through
EV Guide. **Minus** `Notifications`: nothing pushes to an operator in v1
(`Watch` is a driver errand and ships with the car effort). **Minus** the
hosting card — see §5.4 on why there is no mirror.

Rows that survive: `Personal information`, `Login & security`, plus a queued-
writes row when the offline queue is non-empty.

### O9 · No memberships

An account that authenticates with zero membership edges. **Not an error
screen** — the same ethos ADR-0002 applies to `Unknown`.

**Assembled from:** `§5.10` hosting card as the explanatory block (85.7 pt
`#3E3E3E` tile + lime glyph + 17 pt Bold title + 13 pt body), centred on
`color.bg`.

**It offers no action, deliberately.** Admin creates Owners; Owners create
their own Operators (ticket 11). There is no self-serve path into either role,
so a "request access" button would either lie or require an entity the model
does not have.

---

## 4. The availability write surface (O4) — full spec

The one screen specified to the pixel, because it is the only place in EV Guide
where a human writes the thing the product exists to tell the truth about.

### 4.1 What the model permits it to write

```
Report(connectorId, state ∈ {Free, Occupied, OutOfService},
       source = operator, reporterId,
       capturedAt, capturedLocation, sourceOnline)      -- append-only
```

Four facts fall straight out and between them they design the screen:

1. **`Unknown` is not writable.** It is what the derivation returns when
   nothing was written or the window closed. There is therefore **no fourth
   button**, and *leaving a connector untouched is the only way to say "I
   didn't check"* — which is exactly the affordance the screen needs.
2. **Writes are per-Connector.** Bay propagation (a `Free` gun degrading while
   a sibling is `Occupied`, ADR-0008) happens at **read** time. The operator
   never writes a bay.
3. **`capturedAt` is distinct from `receivedAt`**, and most-recent-`capturedAt`
   wins regardless of source (ticket 11). The moment of capture is load-bearing
   data, not a save-time detail.
4. **Reports are append-only.** Nothing on this screen edits or deletes an
   earlier claim; a correction is a new report.

### 4.2 Structure

Presented over O3, so `§5.2` close `×` (27 pt) at `space.pageMargin` — the
reference's own push-vs-present distinction (`←` on the pushed 02, `×` on the
presented 04).

```
×                                                     ← §5.2 sm, 27 pt
Kigali Heights                                        ← type.title 22 pt Bold, name
3 bays · 5 plugs                                      ← type.body 13 pt Regular

Bay A                                                 ← type.label 15 pt Bold
In use · operator · 40 min ago                        ← type.body 13 pt Regular, DERIVED
  ⚡ Type 2 · 22 kW              free · 2 h ago       ← §5.6 settings row construction
  [ Free ] [ In use ] [ Out of service ]              ← §4.3 control row
  ────────────────────────────────────────           ← §5.6 divider, #3E3E3E 1 px, full width
  ⚡ CCS2 · 60 kW                unreported
  [ Free ] [ In use ] [ Out of service ]
  ────────────────────────────────────────
Bay B
  …
─────────────────────────────────────────────         ← §5.8 sticky bar, opaque #121212
3 to save                       [ Save 3 updates ]
```

- **The bay header line is derived and never written.** Showing
  `bayStateUnder(bay, ∅, now)` above the guns is how an operator learns that
  marking one gun `In use` took the bay's other gun with it
  (availability-display §1.1) — the rule is visible in the surface instead of
  surprising them later.
- **Bay naming has nothing behind it.** `Bay` carries no label, name or
  ordinal in domain-model, yet an operator standing at the third pedestal must
  be able to find its row. [RAISE-OA-7]
- Every word on screen comes from the closed vocabulary in availability-display
  §2.4. The write surface does **not** get its own words: no `Busy`, no
  `Broken`, no `Available`.

### 4.3 The control row

**Assembled from:** `§5.1` primary CTA geometry (`size.ctaHeight` 46 pt,
`radius.button` 4.5 pt) carrying the two fills the reference already
distinguishes — `color.surface` `#393939` + `color.text` label when unselected,
`color.accent` `#C7FC2F` + `color.onAccent` `#121212` Medium label when
selected. Full content width, `space.chipGap` 9 pt between, three up.

Why not the `§5.5` chips, which look like the obvious answer: the feature chip
is **35 pt** tall and the category chip **25.7 pt**, and neither is interactive
in the reference — they are labels. Both are under any tap-target floor. Using
CTA geometry keeps the target at 46 pt and introduces no value that was not
measured. **[d]**, and the accent-as-selection reading is the reference's own:
the 03 category chip marks an active attribute in accent, the 04 feature chips
do not.

The **[RAISE-OA-1]** sunlight problem lands here hardest: this is a dark-only
system (`color.bg` `#121212`) being read outdoors at midday, 2° south. Nothing
in §4.3 mitigates it; a light theme is not in the reference.

### 4.4 The four rules that stop it fabricating knowledge

This is the requirement the surface exists to satisfy, and each rule below
exists because the obvious convenience feature breaks it.

1. **Nothing is preselected, on every open.** Not the connector's current
   state, not the last thing this operator wrote, not a remembered form. A
   preselected control turns `Save` into a **bulk confirmation of things nobody
   looked at**, which is precisely the failure mode. The screen opens blank
   even when reopened thirty seconds later.
2. **No bulk control at any level.** No `All free`, no `Mark bay free`, no
   `Confirm all`, no swipe-to-confirm-row, no "same as last time". One tap
   writing N reports stamps N observations from one glance. Ticket 28 rejected
   admin-marked "known-busy patterns" **permanently** as synthetic data wearing
   the availability UI; a bulk button is the same fabrication with a human's
   finger on it. (Contrast O5a, where bulk is correct — §3/O5.)
3. **`capturedAt` and `capturedLocation` are stamped when *that connector's*
   button is tapped, not at Save.** Walking a row of four bays over four
   minutes produces four honest timestamps, and the queue preserves them. This
   is the single most important behaviour on the screen.
4. **Save writes only touched connectors**, and its label carries the count —
   `Save 3 updates` — so the operator sees the size of the claim before making
   it. At zero touches the CTA renders in `color.surface` and does nothing; at
   ≥1 it takes `color.accent`. The reference has **no disabled state** ([?],
   file 10 §9), so this is built from two measured fills rather than an
   invented one. **[d]**

**No proximity gate.** Driver reports are proximity-gated (ADR-0002);
operator reports are not (domain-model §Write boundaries), and that is right —
an owner marking a site `OutOfService` after a phone call from staff is a
legitimate claim. The guard against unchecked confirmation is the four rules
above, not a geofence. `capturedLocation` is still recorded on every report, so
an after-the-fact audit is possible; whether the admin should ever surface
capture distance is [RAISE-OA-8], not a thing to build now.

**Re-confirmation is a real write.** Tapping `Free` on an already-`Free`
connector refreshes `capturedAt` and is the operator's most valuable action on
a quiet site. An implementation that dedupes it as a no-op destroys the
freshness axis.

### 4.5 States

idle (nothing touched) · partially touched (n) · saving · saved · **queued
offline (n)** · rejected by the server (membership revoked mid-session, §5.5) ·
station has one bay/one plug (the singular forms of availability-display §2.2
law 6 apply to the derived lines) · a connector whose type is `OTHER`/`UNKNOWN`
(renders `Other plug`, still writable).

### 4.6 What it cannot do

Write `Unknown` · write a photo, a rate (operator), a bay, a connector or any
station field · write a station you hold no edge on · edit or delete an
existing Report · author a `capturedAt`.

### 4.7 Offline

The surface is fully functional offline; reports queue with their original
`capturedAt` and sync in that order (ADR-0007). An unsent report is dropped
client-side once it passes its own decay window — **6 h** for operator
`Free`/`Occupied`, **30 d** for `OutOfService` (ADR-0002 windows). The sticky
bar's left slot carries the queue count while non-empty.

**`sourceOnline` must not be set from the device's connectivity.**
[RAISE-OA-9] The field exists because a pedestal declaring itself `OFFLINE` was
still publishing a full gun-status array (ADR-0002); it describes **the
observed equipment's telemetry link**, not the reporter's signal bars. A naive
`sourceOnline = netInfo.isConnected` makes every queued operator report born
`Unknown` on arrival and empties the offline queue of all meaning. The operator
app is the first surface that writes reports from a device that may itself be
offline, which is why this trap appears here and not in the ADR.

---

## 5. The cross-app affordance, both ends

ADR-0006: the reference's `Switch to hosting mode` card is a **cross-app
affordance** — open-or-install the operator app — shown only to holders of an
Owner/Operator membership.

### 5.1 The driver-app end (the card's face)

`§5.10` verbatim: 376.7 × 111.7 pt, `color.surface` `#393939`,
`radius.card` 4.3 pt, `space.cardPadding` 13 pt all four sides, 85.7 pt
`#3E3E3E` tile at ~5 pt radius carrying a **lime** glyph at ≈3 pt stroke (the
reference's car-with-arrow → a charger-with-arrow, drawn to the `§6` rule),
tile→text 22.3 pt, title `type.heading` 17 pt Bold, body `type.body` 13 pt
ExtraLight over 3 lines at 15 pt pitch.

**The copy slot survives; the recruiting semantics do not.** The reference's
card is an upsell to *non*-hosts (`Still not an host ?`). EV Guide's is the
opposite — it appears **only** to people who already hold the role, because
there is no self-serve path into it (§3/O9). Title `Open EV Guide Operator`;
body names the second app and what it is for.

**Consequence:** for the overwhelming majority of drivers the card is **absent
entirely**, and the reference gives no evidence of how 02 lays out without it
**[?]** — the gap between the quick actions and `Settings` (154 + 164 px in
file 10 §3.2) is measured only in the with-card case. File 11 owns that layout;
flagged here because this file causes it.

### 5.2 Arriving at the operator app

| Case | Behaviour |
| --- | --- |
| Installed, signed in, ≥1 membership | straight to O2. **No welcome interstitial** — the reference has no onboarding screen and none is invented. |
| Installed, signed out | O1, then **resume the pending intent** into O2. Same auto-resume pattern ADR-0004/0003 specify for the driver's inline auth sheet; `pendingIntents[]` already exists as a concept (domain-model §Amendments 4). |
| Not installed | App Store / Play. **After install the user lands on the operator app's own cold start** (O1 → O2) with no context: there is **no deferred deep linking in v1**, because that means an install-attribution service, i.e. exactly the external runtime dependency ADR-0005's owns-everything rule rejects. Stated rather than papered over. |
| Signed in, zero memberships | **O9**, not an error. |
| Membership revoked while open | the list empties to O9 on next load; queued writes for that station are rejected server-side on receipt (the client cannot know) and surfaced once. |

### 5.3 What a user with no membership sees if they open it

They can install and open the operator app freely — it is a public binary — and
they can sign in, because the realm is shared. They then land on **O9**: an
explanatory card and no action. Nothing is hidden behind a fake error, and no
membership is inferable from the screen: it says the account has no assigned
stations, not that any particular station exists.

### 5.4 There is no mirror card

The operator app gets **no `Open the driver app` card**. The return path is the
platform's (iOS's back-to-app breadcrumb, Android's back stack), the same human
already has the driver app installed by construction, and a mirror card would
be a second cross-app mechanism serving nothing the OS does not already do.

---

## 6. Owner stats (O7) — four metrics, and three absences

Ticket 11 fixes the list and the list is the whole list:

| Metric | Derivable from the model as it stands? |
| --- | --- |
| Station views | **No** — needs an analytics event stream that neither ADR-0005 nor domain-model defines. [RAISE-OA-10] |
| Direction taps | **No** — same. Notable because ADR-0004 keeps *no* route entity, deliberately. |
| Availability reports received | **Yes** — count of `Report` per station per window. |
| Own uptime | **Only with a definition that does not yet exist.** [RAISE-OA-11] |

**EV Guide never observes a charging session.** There is no `Session` entity and
CONTEXT.md marks its absence as deliberate. So the screen shows **no kWh
delivered, no revenue, no session count, no utilisation, no dwell time, no
peak-hour curve** — none of the numbers an operator arrives expecting. Ticket
11's own instruction applies to the screen as well as the ticket: say so
plainly, in one line on the screen, rather than shipping a dashboard whose
shape implies the missing numbers are coming.

**[RAISE-OA-11] restated, because it is the serious one.** "Observed uptime"
computed over a dataset that is ~87% `Unknown` is a number that looks like a
fact and is not one — the same sin ticket 28 rejected, one level up: a
percentage manufactured out of absence. Two honest options: express it as a
**count of declared outages and their duration** (`OutOfService` reports are
durable, 30-day window, and are the only thing here anyone actually asserted),
or do not ship the metric. A percentage denominator built from silence must not
ship. The ticket 07 boundary also holds on this screen: **an owner sees their
own uptime and nobody else's**, and EV Guide publishes current state only,
never per-operator reliability history.

**Assembled from:** `§5.6` settings rows with the value right-aligned at
`type.label` 15 pt Bold and a `type.body` 13 pt line under it carrying the
window. **No chart, no sparkline, no tile grid** — the reference contains no
number display of any kind ([RAISE-OA-12] if charts are wanted).

---

## 7. Web admin

Vite + React SPA in the BWEZE console's shape, deployed as a BWEZE-hosted
static app (ADR-0006). **Internal tooling: the 1:1 reference rule does not
govern it.** It takes file 10 §8.1–§8.4 (colour, type, space, radius — every
row marked **[admin]**) and **none of §8.5**, and **no React Native
components**. Two inherited constraints that a web dashboard will want to break
and must not: the accent is **exactly one value, no tints** (§8.1), and images
stay **rounder than containers** (§8.4 — `radius.image` 10 pt over
`radius.button` 4.5 pt; the inversion is the system's signature).

One genuine friction: **there is no secondary text colour** (file 10 §2.4 — the
"grey" in the reference is ExtraLight anti-aliasing, not a token). A dense
admin table normally leans on a muted tier. Hierarchy here comes from weight
instead (ExtraLight/Regular/Medium/Bold). Since 1:1 does not govern the admin,
adding a muted tier is *available* — but it breaks token kinship with
`packages/ui`, so it is a founder call, not a default. [RAISE-OA-13]

### A1 · Sign in
Same realm, same providers. Access is the **`isStaff`** flag (domain-model
§User), so a non-staff account authenticates successfully and is then refused —
the refusal is authorisation, not authentication, and must read that way.

### A2 · Stations list
Table: `nameShort` · Owner · bays · plugs · photos · **draft/published** ·
`updatedAt`. Filters by owner, publish state, and missing publish
prerequisites. `updatedAt` is already the delta-sync cursor (ADR-0007), so it
is the natural sort.

### A3 · Station create / edit
The authored fields the car surfaces depend on, with the bounds from
domain-model §Amendments 7 enforced **here and nowhere else**:

| Field | Rule |
| --- | --- |
| `name` | ≤ **28** chars, counter, hard stop |
| `nameShort` | ≤ **18** chars — helper text must carry the model's rule: **the place, not the operator** (the operator belongs in `Owner.icon` and `markerLabel`) |
| `geo` | **NOT NULL** — map picker, cannot save without it; a station without coordinates cannot exist |
| `owner_id` | **NOT NULL**, a select over the bounded enumerable Owner set — **never free text** |
| `vehicleClassTag` | nullable; nothing branches on it (ADR-0001) — the field exists so a mixed site can be marked without inventing a concept |
| `updatedAt` | system-set, never authored |

**Every child write must bump the parent's `updatedAt`.** Bays, Connectors,
rates and Photos all hang below Station, but the delta-sync cursor lives on
Station — a connector edit that does not touch it is invisible to every offline
client until something else changes. That is a correctness requirement of the
admin, not a nicety.

The map picker is the admin's only map: MapLibre on the studio's own tiles
(ticket 06 / ADR-0007), so it matches the driver map's palette by construction.

### A4 · Bays and Connectors
Nested under a station: Station → **Bay (≥1 to publish)** → **Connector
(1..N per Bay, ≥1)**.

- `type` — select over the **open OCPI 2.3.0 enum** including `OTHER` and
  `UNKNOWN`. **Never persist a platform integer** (CarPlay/Android taxonomies
  disagree; map at the edge) — so the admin's select writes spellings, not
  indices.
- `powerKw`, `voltage` — numbers.
- `ratePerKwhRwf`, optional `sessionFeeRwf`, `rateConfirmedAt` — admin and
  owner only (ticket 10). Saving a rate stamps the confirmation.
- A **bay label** the operator app can print — see [RAISE-OA-7].
- **Deletion has no defined semantics.** `Report` is append-only and hangs off
  `Connector`; deleting a connector orphans its history. Blocked or soft, not
  hard. [RAISE-OA-14]

### A5 · Owners
Public face, authored here and rendered on surfaces that cannot fetch:

- `displayName`; `shortName` ≤ **17**.
- **`markerLabel` 1–3 chars, `NOT NULL`, with a `CHECK`** — the car platforms'
  one hard character limit. The CHECK is length only; nothing in the model
  constrains case or charset, and the car surfaces render it verbatim.
- **`icon` must be a vector** — CarPlay pin sizes are runtime values, and car
  surfaces cannot take URLs, so it materialises into the bundle.
- The form previews `markerLabel` + `icon` at pin scale, because **the admin is
  the only place they are ever authored and nothing else renders them before a
  driver does**.
- Private side (legal name, contacts) is admin-only and never projected.

### A6 · Memberships
Grant/revoke `(userId, stationId, role)`, unique. Admin creates Owners; Owners
create their own Operators in the operator app (O6); admin retains override.
Same missing-entity problem as O6 — [RAISE-OA-6].

### A7 · Photos
Ordered (drag to reorder — the order *is* the 04 carousel order), **≥1 required
to publish**, **admin/owner-provided only** (no driver submissions, ever — that
is where the moderation problem lives), never shown on car surfaces.

### A8 · The publish gate
Publishable iff **≥1 Bay**, **each Bay ≥1 Connector**, **≥1 Photo** (`geo` and
`owner_id` are non-null by construction). Draft until then. The screen shows
the checklist with the unmet items named. Unpublish is possible.

**Publishing does not reach offline-first users immediately**: the bundled
directory snapshot is cut at release time (ADR-0007), so a station published
between releases is visible only to clients that have synced. Worth stating on
the screen; it is not a bug.

### A9 · Reports (read-only) and admin availability writes
See §8 — this is the screen with the sharpest prohibition on it.

### A10 · Audit
Ticket 11: "Admin can override anything, **with an audit trail**." No audit
entity exists in domain-model. [RAISE-OA-6, third instance]

### A11 · Stats (admin)
Sees everything; same four metrics; same uptime honesty problem. Internal only:
the ticket 07 boundary means EV Guide may hold cross-operator reliability
numbers and **may never publish them** — exporting this screen is out of
bounds, not merely unimplemented.

**Deliberately not in the admin:** owner web access (Owners use the operator
app; ADR-0006 makes the dashboard internal tooling), any driver-facing content
management, any messaging, any payment or billing surface.

---

## 8. What the admin must **not** be able to do

Ticket 28 rejected admin-marked "known-busy patterns" **permanently** —
"[n]ever to be revisited as a 'quick win'". That resolution is a set of
concrete prohibitions on A9, and they are easier to enforce as tests than as
memory:

1. **No availability field on any station, bay or connector form.** ADR-0008's
   star constraint is that **no table carries an availability state**. If a
   form field for availability exists anywhere in the admin, the constraint has
   already been violated. This is the crispest test in the whole document.
2. **No bulk availability write.** No "mark all free", no multi-select over
   stations or connectors, no CSV import of states. Any control that writes >1
   `Report` per human observation is the rejected feature in another costume.
3. **No pattern, schedule, rule or recurrence.** No "busy weekday evenings", no
   simulated occupancy, no default state, no seeded value on station creation.
4. **No authored `capturedAt`.** The admin's write stamps `now`, exactly like
   everyone else's. Back-dating hands the admin control of most-recent-wins
   ordering, which is the model's only conflict rule.
5. **No editing or deleting an existing Report.** Append-only means a
   correction is a new report. There is **no retract verb** in the model: a
   wrong claim is answered by a true one, or by decay. Worth knowing before
   someone asks for a delete button.
6. **No availability written from an inference.** Import, scrape, competitor
   feed (ticket 26 ruled Kabisa's out), telemetry guess, "probably free" —
   none.

**What the admin's availability write is legitimately for**, and it is exactly
two things (ticket 28 §4): the **launch-week survey pass**, where studio staff
stand at a station and file genuine `source = admin` reports; and correcting a
bad report by filing a true one. Both are one human, one observation, one
report — the same discipline §4.4 imposes on operators, with the same reason.

---

## 9. Raised

**[RAISE-OA-1] The operator app is a dark-only design used outdoors.** The
whole system is `#121212`/`#212121`/`#393939` (file 10 §7 — no elevation, no
alternate surface), and the operator's core task is performed standing at a
charger in equatorial daylight. There is no light theme in the reference to
switch to, and inventing one is a deviation. File 10's [RAISE-2] (ExtraLight
body at 13 pt, 1.7 px stem) compounds it — this file uses Regular at
`type.body` for every derived data line, which §8.2 already licenses, but the
ambient-light problem is not solvable inside the measured palette.

**[RAISE-OA-2] The reference has no pressed, disabled, focused, loading, error,
empty or confirmation state.** File 10 §9 records this as unmeasurable from four
stills. A read design can survive that; a write tool cannot — every screen in
§3 and §7 needs at least three of them. This is the largest single gap between
the reference and the operator app, and it is a design decision the founder has
to authorise rather than something to derive.

**[RAISE-OA-3] `Station` has no description field.** The 04 `Description` block
has nothing behind it (domain-model §Entity model). Dropped in O3 and absent
from A3; adding one is a schema change.

**[RAISE-OA-4] No text or numeric input exists in the reference.** O5a (rate)
and every admin form need one. The settings row (§5.6) gives a resting
appearance; the focused/editing appearance has no measured source.

**[RAISE-OA-5] The operator's rate *flag* has no entity.** Ticket 10 grants it;
domain-model has no `RateFlag`. `Report` is availability-only.

**[RAISE-OA-6] Three entities are implied by screens and absent from the
model:** `Invitation` (or a nullable-user `Membership` — an invitee has no
`userId` until they accept), an **audit trail** for admin overrides (ticket 11
requires one by name), and the `RateFlag` above.

**[RAISE-OA-7] `Bay` has no label, name or ordinal.** The write surface must
name bays — an operator standing at the third pedestal has to find its row —
and the model gives it nothing to name them with. Also affects the admin's bay
editor and the operator's mental map of a site.

**[RAISE-OA-8] `capturedLocation` is recorded on operator reports and displayed
nowhere.** Operator writes are deliberately not proximity-gated (§4.4), so the
data exists for an after-the-fact audit that nothing currently performs.
Whether the admin should surface capture distance is a privacy-and-trust
decision, not a screen decision.

**[RAISE-OA-9] `sourceOnline` will be wired to the wrong signal.** It describes
the observed equipment's telemetry link, not the reporter's connectivity;
setting it from the device's network state makes every queued offline operator
report arrive `Unknown` and silently voids the offline queue.

**[RAISE-OA-10] Two of the four Owner stats have no data source.** Station
views and direction taps need an analytics event stream that neither ADR-0005
nor domain-model defines — and ADR-0004 deliberately keeps no route entity.

**[RAISE-OA-11] "Observed uptime" over ~87% `Unknown` data is not a fact.** A
percentage whose denominator is manufactured out of silence is the same
violation ticket 28 rejected. Ship a count of declared outages, or do not ship
the metric.

**[RAISE-OA-12] There is no number, chart or metric display in the reference.**
The stats screens (O7, A11) are built from settings rows with right-aligned
values. Anything richer is invention.

**[RAISE-OA-13] The admin has no secondary text colour.** File 10 §2.4 found no
grey tier anywhere. A dense table normally needs one. Adding it is permitted
(1:1 does not govern the admin) but breaks token kinship with `packages/ui`.

**[RAISE-OA-14] Deletion has no defined semantics.** `Report` is append-only
and hangs off `Connector`; deleting a connector or a bay orphans history. Block
or soft-delete — but the model says nothing.

### Deliberately not specified (to keep this file inside its remit)

A station-scoped deep link from the driver's station detail into O4 (the opaque
stable station id supports it; nothing requires it) · an operator map or
`stationsNear` in the operator app · any messaging surface · operator push
notifications · owner access to the web admin · deferred deep linking after
install · a shared session across the two binaries.

---

## 10. Screen tables

### 10.1 Operator app

| Screen | Components used (file 10) | States | What fixes its content |
| --- | --- | --- | --- |
| **O1 Sign in** | 02 centred column; `§5.9` avatar block; `type.display`; accent link; `§5.1` CTA ×3 (1 accent + 2 `color.surface`) | idle · in-flight · failed · resuming a hand-off | ADR-0003 providers (Google · Apple · magic link, no SMS); Apple compelled by Guideline 4.8 |
| **O2 My stations** | `§5.10` card container + `§5.4` sheet-body composition; `type.title` screen title; `§5.9` 43 pt map avatar; `§5.6` divider | loaded · loading · **no memberships → O9** · offline indicator · queued writes (n) | `Membership` edges (never geography); `nameShort`; bay/plug counts; availability-display §2.2 clause + §2.3 freshness; **sorted stalest-first** |
| **O3 Station detail** | full 04 shell: `§5.2` `×`+`⋯`, `§5.7` carousel + badge, `type.title`/`type.body`, 04 owner row, `§5.5` feature chips, `§5.8` sticky bar | loaded · offline (photos absent) · no derived availability · unpublished (admin-only case) | `Station.name`; `Photo` order; `Owner` public face; connector types from the §2.4 vocabulary; **no description field exists** |
| **O4 Update availability** | `§5.2` `×`; `type.title`/`label`/`body`; `§5.6` row construction + `#3E3E3E` 1 px full-width divider; `§5.1` CTA geometry ×3 as the control row; `§5.8` sticky bar | idle (nothing touched) · touched (n) · saving · saved · queued offline (n) · server-rejected · single bay/plug · `OTHER` plug | `Bay`→`Connector` tree; the three writable `Report` states; per-tap `capturedAt`/`capturedLocation`; derived bay line via availability-display §1.1 |
| **O5a Rate edit** (owner edge) | `§5.6` rows, value right-aligned `type.label` Bold; `§5.1` CTA; plug multi-select | idle · editing · saving · saved | `ratePerKwhRwf`, `sessionFeeRwf`, `rateConfirmedAt` (90 d); `rateCoverage.distinctRates[]` |
| **O5b Rate flag** (operator edge) | `§5.6` rows; `§5.1` CTA | idle · submitted | **no entity exists** — [RAISE-OA-5] |
| **O6 Operators** (owner) | `§5.6` rows; `§5.1` CTA; `§5.10` card | list · empty · inviting · revoke confirm ([RAISE-OA-2]) | `Membership` scoped to owned stations; invitation has no model home |
| **O7 Stats** (owner) | `§5.6` rows, right-aligned `type.label` Bold + `type.body` window line | loaded · metric unavailable · single-station vs aggregated | 4 metrics (views · direction taps · reports received · uptime); **no session, kWh, revenue or count exists**; ticket 07 boundary |
| **O8 Profile** | 02 verbatim minus the quick-action trio; `§5.9` 105.3 pt avatar + 1 pt accent ring; `§5.6` list | loaded · offline · queued writes row | `User`; rows reduced to Personal information · Login & security · queue |
| **O9 No memberships** | `§5.10` card centred on `color.bg` | single state, **not an error** | zero `Membership` edges; no self-serve path exists, so no action is offered |

### 10.2 Web admin (tokens only; 1:1 does not govern)

| Screen | Components used | States | What fixes its content |
| --- | --- | --- | --- |
| **A1 Sign in** | console shell + §8.1/8.2 tokens | idle · authenticated-but-refused (`isStaff` false) · failed | one auth realm (ADR-0005); `User.isStaff` |
| **A2 Stations list** | table (no reference component — admin-native) | loaded · empty · filtered · draft vs published | `Station` rows; `updatedAt` cursor; publish-prerequisite filters |
| **A3 Station create/edit** | form; MapLibre picker on studio tiles | new · editing · invalid (length/NOT NULL) · saved | `name` ≤28 · `nameShort` ≤18 (the *place*) · `geo` NOT NULL · `owner_id` select over the bounded set · `vehicleClassTag` nullable · **every child write bumps `updatedAt`** |
| **A4 Bays & Connectors** | nested editor | ≥1 bay · bay with 1..N connectors · delete blocked ([RAISE-OA-14]) | OCPI 2.3.0 open enum incl. `OTHER`/`UNKNOWN`, **never a platform integer**; `powerKw`/`voltage`; rate fields; bay label ([RAISE-OA-7]) |
| **A5 Owners** | form + pin-scale preview | new · editing · CHECK violation on `markerLabel` · non-vector icon rejected | `displayName` · `shortName` ≤17 · `markerLabel` 1–3 `NOT NULL` CHECK · `icon` **vector** · private legal/contact never projected |
| **A6 Memberships** | table + invite form | active · pending ([RAISE-OA-6]) · revoked | `(userId, stationId, role)` unique; admin creates Owners, override on Operators |
| **A7 Photos** | ordered grid, drag to reorder | 0 photos (blocks publish) · ≥1 · reordering | `Photo` order = carousel order; admin/owner only; never on car surfaces |
| **A8 Publish gate** | checklist | draft (unmet items named) · publishable · published · unpublished | ≥1 Bay · each Bay ≥1 Connector · ≥1 Photo; snapshot caveat (ADR-0007) |
| **A9 Reports + admin write** | read-only table + a **single-observation** write form | list · filtered by station/connector/source · new report | append-only `Report`; `source = admin`; **§8's six prohibitions** |
| **A10 Audit** | table | — | required by ticket 11, **no entity exists** ([RAISE-OA-6]) |
| **A11 Stats (admin)** | table | loaded · metric unavailable | same four metrics, all stations; **internal only** — ticket 07 forbids publishing per-operator history |
