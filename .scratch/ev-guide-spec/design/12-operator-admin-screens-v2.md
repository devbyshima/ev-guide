# 12 — Operator app and web admin, by extension (v2)

> ## Authority note (added 2026-08-13 when ticket 17 closed — read first)
>
> **1. `10-design-system-v2.md` is the single measurement authority.** Where this
> file states a measurement that disagrees with it, **file 10-v2 wins** and this
> file is wrong. Any clause in this file declaring its own numbers authoritative
> "until file 10 lands" is void — file 10-v2 has landed. The known conflict is
> the floating card's corner radius: this file says r ≈ 16 px, **file 10-v2's
> r ≈ 14 px is correct**.
>
> **2. Citations into file 10 use v1 section numbers, which v2 renumbered.**
> Translate with this table; `§5.4` and `§5.7`–`§5.11` do not exist in v2 at all.
>
> | cited here (v1) | read in 10-v2 |
> | --- | --- |
> | §2.3 line height | §4.3 |
> | §2.4 no grey text | §1.3 |
> | §5.1–§5.11 components | §7.1–§7.11 |
> | §6 icon system | §8 |
> | §7 elevation | §9 |
> | §8.1–§8.5 tokens | §10.1–§10.5 (native-only block = §10.5) |
> | §9 raises | §12 |
>
> **3. The forbidden-string list is NOT held here.** Its one home is
> `docs/availability-display.md` §2.2b. Any table of forbidden strings in this
> file is a stale copy; the canonical list governs.



Ticket 17, screen inventory part 2 of 2. The driver app's inventory is **file
11**; the measured design system both cite is **file 10**, and every token, size
and section reference below (`§5.6`, `space.pageMargin`, `size.ctaHeight`…)
points at it. Citations are by ticket-17 file number and section, so they hold
across revisions of those two files.

**Section-reference convention, since two files number alike:** a section in
`backticks` (`§5.6`, `§5.10`, `§8.1`) is **file 10's**; a plain one (§4.4, §8)
is **this file's**; anything else is named ("file 11 §13",
"availability-display §2.2"). v1's numbering is preserved exactly, so §4.4 and
§8 still address what round 1 cited.

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

**Marking legend** (same as file 10). **[m]** measured from the PNGs and cited
· **[d]** derived by stated reasoning · **[?]** the reference cannot say ·
**[vocab]** the string is closed vocabulary owned by `packages/domain`
(docs/availability-display.md §2.4) and may not be authored in the app ·
**[RAISE-OA-n]** raised, not resolved. **Sixteen are listed in §9.**

---

## 0. What v2 changes, and the rulings it applies

Round 1's verdict (file 13) found five fatals, of which three were this file's.
All five are cross-document contradictions, and the rulings that settle them are
binding on files 10, 11 and 12 alike. They are applied here, not re-argued.

| Ruling | What it settles | Where it lands in this file |
| --- | --- | --- |
| **R1** | The word for `Occupied` in user-facing copy is **`busy`**, everywhere, on every surface, for both drivers and operators. The operator write control reads **`Busy`**. `In use` is deleted product-wide. | §4.2, §4.3 — v1's prohibition on `Busy` **is deleted**, and the word is adopted |
| **R2** | **Availability never appears in the accent badge, on any surface.** The hero badge carries **peak power** or is absent. | §3/O3 — the badge is peak power; availability moves to a measured block that can hold it |
| **R3** | **`unreported` is forbidden product-wide**, with every string asserting report history. The permitted form is **`no confirmed status`** (and `no confirmed rate`). | §4.2 — the connector value slot reads `no confirmed status` |
| **R4** | A **short rate projection** exists for the card / sheet / sticky slots, defined once in `packages/domain`. The long Grammar R ladder stays on the driver's detail screen. | §3/O2 value slot, §3/O3 sticky bar |
| **R5** | Colour tokens are whatever the **pixels** say. A measured grey icon exists, so the "no grey tier" finding is narrowed to **text**. | §7, [RAISE-OA-13] |

And the four review items below fatal that were this file's:

- **M9** — the hosting card's body line count is reconciled against the measured
  card height in §5.1. The card is **tile-fixed at 335 px**; the body slot holds
  **at most 3 lines**; file 11's two-line copy leaves the third unused and the
  card does not move. Neither file was wrong; neither said which was which.
- **M11** — **every screen now has a named entry point** (§3.0, the navigation
  map), the `⋯` menu's contents are specified, and the missing menu *component*
  is raised as [RAISE-OA-15] rather than assumed.
- **m9** — O2's right-aligned value slot no longer carries a ~39-character
  availability clause. It carries R4's short rate projection, and the clause
  moves to the wide subtitle slot where the driver's sheet already puts it.
- Two new raises fall out of the corrections: **[RAISE-OA-15]** (no menu
  component) and **[RAISE-OA-16]** (owners may write Photos and have no surface
  to do it on).

### 0.1 The one place the forbidden strings live

Per **R3** the forbidden list is written **once** and cited from everywhere
else. It is **file 11 §13**, whose scope R3 widens from *the driver app* to
*product-wide*:

> **`real-time`** — ticket 28, never in the listing, onboarding or UI ·
> **any string asserting report history** — *no recent report*, *not reported*,
> **`unreported`** · and, added by R1, **`in use`**.

This file does not restate that list and does not keep a second copy. The
permitted forms are `no confirmed status` and `no confirmed rate` [vocab].

### 0.2 Measured text advances used for every fitting check below

Every "does it fit" claim in this file is arithmetic over a measured advance,
never an eyeball. All four were measured directly off the PNGs for v2:

| Run | Source string | Ink | Chars | Advance |
| --- | --- | --- | --- | --- |
| cap 36 Bold | `135 000 RWF/day`, `04` sticky bar, x 93 → 524 | 432 px | 15 | **28.8 px/char** [m] |
| cap 32 Medium | `Check Availability`, `04` sticky CTA, x 673 → 1045 | 373 px | 18 | **20.7 px/char** [m] |
| cap 27 Bold | `135 000 RWF/day`, `03` sheet price, x 755 → 1075 | 321 px | 15 | **21.4 px/char** [m] |
| cap 27 Regular | `Hybride - Black - 2024`, `03` subtitle (file 11) | 397 px | 22 | **18.0 px/char** [m] |

**Caveat, stated once:** these are mean advances over mixed digit/letter strings
and the face's figures are old-style (file 10 §1.2), so a digit-heavy string and
a letter-heavy string of equal length will not measure equal. They are sizing
checks with ~5% slack, not a typesetting model. Every use below leaves more
margin than that or says it does not.

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
trailing affordance at all** (`§5.6` — no chevrons).

**It also contains no:**

| Missing | Where the operator app or admin needs it |
| --- | --- |
| Sign-in screen | O1, A1 |
| Empty state | O9 (no memberships), every admin list |
| Pressed / disabled / focus state ([?] in file 10 §9) | every control on a write surface |
| Error, retry, or validation state | every write |
| Pending / in-flight state | every write, and the offline queue |
| Destructive confirmation | revoke membership, unpublish, delete a bay |
| **Menu, popover, or action list** | O3's `⋯` — [RAISE-OA-15] |
| Number, chart, or metric display | O7 stats |
| Table, dense row, or column header | the entire admin |
| Light theme | O4 used outdoors — [RAISE-OA-1] |
| Tab bar, nav bar, toolbar, or any persistent chrome | navigation, everywhere |

The last one is a positive finding and it fixes the operator app's navigation:
the reference's whole navigation vocabulary is **full-screen surfaces reached
by a push (back `←`, `§5.2` md, 30.3 pt) or a presentation (close `×`, `§5.2`
sm, 27 pt), plus one floating avatar at `space.pageMargin`**. The operator app
inherits exactly that and **does not get a tab bar** — inventing one would be
the largest single deviation available, and nothing in the data model asks for
it. §3.0 spends that vocabulary on nine screens without adding to it.

**One measured nuance on the missing pressed/disabled state, per R5.** The
reference does contain exactly one grey icon: the `03` sheet's heart, **solid
`#717171`, 517 px, x 1026–1074 / y 1881–1925** [m]. It is *not* evidence of a
disabled or inactive token, because the same heart glyph on `04` measures
`#FFFFFF` with zero pixels of `#717171` in its ink box [m] — one glyph, two
colours, two screens, same presumed state. It is a measured colour with no
measured meaning. See §7 and [RAISE-OA-13].

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
   account". §3.0 makes this structural: both are reached **from the station**,
   so an account-level aggregate has nowhere to live and is not built.
3. **One realm is not one session.** ADR-0005 gives one user table, not shared
   keychain state across two binaries. The user signs into the operator app
   once on its own. Sharing the session (iOS App Group, Android AccountManager)
   is build work nothing here specifies.

**The operator app never applies the driver's connector lens.** Every derived
clause on O2, O3 and O4 is unlensed — `T = ∅` in `bayStateUnder(bay, T, now)`
(availability-display §1.1). The lens answers *free for me*, which is a shopping
question; an operator is reporting the world, not choosing in it. There is no
`My plug` row anywhere in this app.

**Offline.** ADR-0007 is first-class here too: an operator standing in a
basement car park is the *modal* case, not the edge case. The write surface
works fully offline and queues (§4.7). The app has **no map** — the station
list is a membership query, not `stationsNear` — so it carries no basemap and
**no all-Rwanda map pack row**; that settings row is a driver affordance
(ticket 16 → file 11).

---

## 3. Operator app — screens

### 3.0 Navigation map — every screen's entry point

v1 specified nine screens and reached six of them. This section closes that gap
(**M11**) using only the two measured transitions the reference contains.

| # | Screen | Reached from | Transition | Dismiss control |
| --- | --- | --- | --- | --- |
| **O1** | Sign in | cold start, signed out | root | — |
| **O2** | My stations | O1 success, or cold start signed in | **root** | — |
| **O3** | Station detail | O2, tapping a station row | **present** | `×` `§5.2` sm, 27 pt |
| **O4** | Update availability | O3, the `§5.8` sticky CTA `Update availability` | **present** over O3 | `×` `§5.2` sm, 27 pt |
| **O5a/b** | Rate | O3 `⋯` → `Rate` | **push** onto O3 | `←` `§5.2` md, 30.3 pt |
| **O6** | Operators | O3 `⋯` → `Operators` — **`owner` edge on this station only** | **push** onto O3 | `←` `§5.2` md |
| **O7** | Station stats | O3 `⋯` → `Station stats` — **`owner` edge on this station only** | **push** onto O3 | `←` `§5.2` md |
| **O8** | Profile | O2, the `§5.9` 43 pt avatar at `space.pageMargin` | **push** | `←` `§5.2` md |
| **O9** | No memberships | **it is O2's zero-membership state**, never a destination | — | — |

Four things this map is claiming, each of which is checkable:

- **Two presentations may stack, and both carry `×`.** O3 over O2 and O4 over
  O3 are both presentations, because O3 is assembled from the `04` shell and the
  reference's own `04` is a presented screen (`×`, not `←`). Reproducing that
  twice is the reference's vocabulary applied twice, not a new one. The pushes
  off O3 carry `←`, which is `02`'s own button at its own measured 30.3 pt.
- **The `⋯` menu is the operator app's only menu**, and it exists because the
  role-dependent screens must be resolved *at the station* (§2 consequence 1).
  Putting O6/O7 in a profile-level list would contradict that and would need a
  screen the model cannot fill ("all my stations" is O2, a list, not a
  dashboard).
- **The menu's item set is a function of the edge**, resolved live against this
  station's `Membership`:

| Item | Destination | Shown when |
| --- | --- | --- |
| `Rate` | O5a (`owner`) / O5b (`operator`) | always — one of the two surfaces always exists |
| `Operators` | O6 | `role = owner` on **this** station |
| `Station stats` | O7 | `role = owner` on **this** station |

  So an Operator's menu holds **one** item and an Owner's holds **three**. A
  one-item menu still opens as a menu: a per-edge chrome difference would be a
  second navigation vocabulary, which costs more than an odd-looking menu.
- **There is no station-scoped deep link into O4 in v1** (§9, deliberately not
  specified). O4 is reached through O3, always, so the operator always sees the
  current derived state before being offered the chance to change it.

**The component the map needs and the reference does not have is the menu
itself — [RAISE-OA-15].** File 11 resolves the identical problem for the
driver's `04` `⋯` (S-03) by using **the platform's own action sheet** and naming
it as an absence. This file adopts that resolution unchanged so that one product
carries one menu mechanism, and raises it rather than pretending the reference
supplied it.

### O1 · Sign in

**Assembled from:** the 02 centred column (avatar `§5.9` → app mark,
`type.display` 26 pt Bold, accent link at `type.body` Regular `#C7FC2F`) +
`§5.1` primary CTA (46 pt, `radius.button` 4.5 pt) × 3.

Same providers as the driver app, unchanged by ADR-0003's amendment: Google,
Sign in with Apple, email magic link. **No SMS.** Sign in with Apple is
compelled on iOS by Guideline 4.8 here exactly as in the driver app, because
the operator app also offers Google. File 11's [RAISE-D20] (Apple's button
cannot be restyled) and [RAISE-D21] (no text input exists, and the email path
needs one) both apply to this screen unchanged; they are not re-raised here.

**[d]** Three accent CTAs stacked would put three `#C7FC2F` fills on one screen
against a reference that spends the accent on **one** CTA per screen (~3.9% of
map-screen pixels, `refs/design-observations.md`). One provider takes the
accent CTA (platform-primary: Apple on iOS, Google on Android); the other two
take the same 46 pt / 4.5 pt geometry with `color.surface` `#393939` fill and
`color.text` label — a fill the reference uses for every other tappable thing
(`§5.2`). No new value is introduced.

**States:** idle · in-flight ([RAISE-OA-2]) · failed ([RAISE-OA-2]) · resumed
from a cross-app hand-off (§5).

### O2 · My stations

The root. **Content is fixed by `Membership`** — every station where the
signed-in account holds either role — never by geography. (Worded to avoid
"signed-in user": a mechanical grep for the forbidden `in use` matches it, and
a guard test that has to special-case its own document is a guard test nobody
keeps.)

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
| **Subtitle** | **the leading availability clause + freshness**, unlensed | availability-display §2.2 / §2.3 — **verbatim [vocab]**, no operator-app wording |
| **Value slot** (right-aligned) | **R4's short rate projection** — `600 RWF/kWh` · `From 400 RWF/kWh` · `No confirmed rate` | `rateCoverage(station).distinctRates[]` (domain-model §Amendments 6) |
| Role marker | shown only where it differs across the list | `Membership.role` |

**Why the two content slots swapped, and the arithmetic that forced it (m9).**
v1 put the availability clause in the *value* slot. That slot is the `03`
sheet's price slot: measured ink 321 px, right-aligned to x 1075, cap 27 Bold
[m]. A Regime-3 clause runs ~39 characters — **835 px at the measured
21.4 px/char**, which is not merely long for the slot but wider than the sheet's
entire 594 px content column, and it would run back through the thumbnail. The
clause therefore belongs in the **subtitle**, which is the wide slot the
driver's D-02 already gives it, and the value slot takes the short projection R4
defines for exactly this job. The three short forms measure **235 / 342 /
364 px** — the longest, `No confirmed rate`, is 43 px wider than the reference's
own price string and still 230 px inside the column **[d]**.

**`4 bays · 6 plugs` is dropped, not moved.** Regime 1's clause already opens
with the capacity (`4 bays · no confirmed status`), so the structure line
duplicated it in ~87% of rows; plug counts are on O3 and O4, where the operator
acts on them. A named deletion, not an oversight.

**The rate belongs on an operator's row** for a reason beyond slot-filling:
`rateConfirmedAt` decays at 90 days (ticket 10), so `No confirmed rate` on this
screen is an owner's *second* job queue, and O5a is two taps away (§3.0).

**Order: stalest first** — ascending `oldestContributingCapturedAt`
(availability-display §2.3). This is the operator's job queue, and freshness is
the only ordering signal the model carries that means anything to them.

**Null ordering is part of the sort, not an implementation detail.** Under
Regime 1 there are no contributing reports, so `oldestContributingCapturedAt` is
**null for ~87% of rows** — a sort that ignores that does not sort. **Nulls sort
first**: a station nobody has ever reported is staler than any station carrying
a date. Then ascending `capturedAt`. This must exist as a test, not a comment,
because a null-last default in whatever list primitive ships would silently bury
exactly the stations the app exists to get reported. **[d]**

**States:** loaded · loading · **no memberships → O9** · offline (quiet
indicator, ADR-0007; the driver app's `§5.5` feature-chip indicator, reused
unchanged) · queued writes pending (count).

### O3 · Station detail (operator)

**Assembled from:** the whole 04 shell — `§5.2` close `×` 27 pt + overflow `⋯`
33.3 pt on one centre line; `§5.7` hero carousel (`Photo`, ordered, read-only —
see [RAISE-OA-16]); `type.title` 22 pt title; `type.body` subtitle; the 04 owner
row (25.3 pt `size.avatarOwner` + `type.label` 15 pt Bold); the 04
`Description` sub-head + body composition, re-tenanted; `§5.5` feature chips for
connector types; `§5.8` sticky bar.

**Substitutions, slot by slot:**

- **Hero badge (`§5.7`, accent near-pill + lightning glyph) → peak power,
  e.g. `60 kW`, or absent.** This is **R2**, and it is the same content the
  driver's D-03 badge carries, so one component carries one kind of value in
  both apps. Availability may never enter it: an accent chip reading
  `no confirmed status` on ~87% of stations paints the product as an apology,
  which ADR-0002 forbids by name.
  **The measurement that makes the ruling structural rather than aesthetic:**
  the badge's label is `#FFFFFF` on `#C7FC2F` (file 10 `§5.7`), which computes to
  **1.21 : 1** contrast [d, WCAG relative luminance]. Reproducing the badge 1:1
  means reproducing an unreadable label, so the badge may only ever carry a
  value that is **also stated in full below it** — peak power is, in the
  connector chips (`2 × GB/T DC 60 kW`); an availability clause would not be.
  Absent when no Connector carries `powerKw`.
- **The 04 `Description` block has no field behind it** — `Station` carries
  `name`, `nameShort`, `geo`, `vehicleClassTag`, `updatedAt`, Photos and Bays,
  and **no description** (domain-model §Entity model). [RAISE-OA-3] stands: a
  description is a schema change, not a screen decision. **The measured region
  is re-tenanted rather than left empty**: it carries the **`Availability`
  block** — `type.heading` sub-head + `type.body` derived clause at the full
  358.7 pt content width, then **one `§5.6` settings row per Connector type**,
  read-only. This is file 11's D-03 composition, adopted verbatim rather than
  re-derived, and it is where the long clause fits with **no ladder** (the block
  has room for the longest string; the sheet slot does not).
  *The operator's screen must show the state before it offers to change it* —
  which is also why O4 is reachable only through here (§3.0).
- **Feature chips → connector types** from the closed vocabulary (`Type 2`,
  `CCS2`, `GB/T AC`, `GB/T DC`, `Other plug` — availability-display §2.4), with
  the `§6` 24 pt / 2 pt-stroke glyph in the chip's icon slot.
- **Sticky bar left slot → R4's short rate projection**, cap 36 Bold. The
  measured budget is **510 px** — the reference's own price ink starts at x 93
  (`space.stickyBarPadding` 90) and the lime CTA starts at x 603 [m] — and
  `No confirmed rate` is 17 chars × 28.8 = **490 px**, clearing by 20 px [d].
  It is the tightest string in the operator app, exactly as it is in the driver
  app. Availability does **not** go here: the block above carries it at full
  width, and the same 39-character clause would overrun this slot by 60%.
- **Sticky bar CTA → `Update availability` → O4.** 19 characters at the measured
  cap-32 Medium advance is **393 px** inside the 513 px CTA, leaving 60 px each
  side against the reference's own 70 px on an 18-character label [m/d]. It fits
  without changing the component.
- **The 04 owner row's trailing message icon has no equivalent.** EV Guide has
  no messaging entity and never will in v1 (`Messages` is one of the three
  reference quick actions with nothing behind it). The slot goes unused, exactly
  as in file 11's D-03.
- **`⋯` → the platform action sheet**, items per §3.0. [RAISE-OA-15].

**States:** loaded · offline (photos absent, `#3E3E3E` at the hero's exact
geometry — file 11 §9.4) · no derived availability (Regime 1, the normal case,
drawn first) · unpublished (admin-only case).

### O4 · Update availability — **§4 below, in full**

### O5 · Rate

One route, two surfaces, resolved by the membership edge on **this** station.
Entered from O3's `⋯` (§3.0), pushed, back `←` at `§5.2` md.

**O5a · Rate edit (`owner` edge).** Per-Connector `ratePerKwhRwf` + optional
`sessionFeeRwf`; saving stamps `rateConfirmedAt = now` (90-day decay, ticket
10). Assembled from `§5.6` settings rows with the value right-aligned at
`type.label` 15 pt Bold — the composition file 11 raises as **[RAISE-D14]**,
cited here as a dependency rather than assumed. **The reference contains no text
input** — the resting row is measured, the focused/editing row is not.
[RAISE-OA-4]

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

Membership CRUD for **this station**: its operator list, invite by email
(ADR-0005: "operators and owners join by email invitation"), revoke. Entered
from O3's `⋯`, `owner` edge only (§3.0) — which is what keeps it scoped to a
station rather than to an account (§2 consequence 2).

**Assembled from:** `§5.6` settings rows (person glyph + name) + `§5.1` primary
CTA (`Invite operator`) + `§5.10` card for the explanatory block.

**`Membership` cannot express a pending invitation.** It is
`(userId, stationId, role)` unique — and an invitee has no `userId` until they
accept. [RAISE-OA-6] Revoke is destructive and the reference has **no
confirmation pattern** ([RAISE-OA-2]).

### O7 · Station stats (Owner) — §6 below

Entered from O3's `⋯`, `owner` edge only. **Station-scoped, and there is no
aggregate variant** — v1 listed an "aggregated" state; §3.0 removes it, because
§2 consequence 2 says these screens are scoped to stations and never to an
account, and no screen exists that would own an all-stations dashboard.

### O8 · Profile (operator app)

Entered from O2's `§5.9` 43 pt avatar, pushed, back `←`.

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

Rows that survive: `Personal information`, `Login & security`, plus a
**non-interactive** queued-writes row carrying its count in the [RAISE-D14]
value slot when the offline queue is non-empty. It is a readout, not a
destination: the queue drains itself (§4.7), and a control that invited an
operator to "retry" would imply the send order is theirs to change when
`capturedAt` order is the model's only conflict rule.

### O9 · No memberships

An account that authenticates with zero membership edges. **Not an error
screen** — the same ethos ADR-0002 applies to `Unknown`. It is **O2's own
zero-row state**, not a pushed destination (§3.0).

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

Bay A                                                 ← type.label 15 pt Bold [RAISE-OA-7]
Busy · operator · 40 min ago                          ← type.body 13 pt Regular, DERIVED
  ⚡ Type 2 · 22 kW              free · 2 h ago       ← §5.6 row + value slot [RAISE-D14]
  [ Free ] [ Busy ] [ Out of service ]                ← the §4.3 control row
  ────────────────────────────────────────           ← §5.6 divider, #3E3E3E 1 px, full width
  ⚡ CCS2 · 60 kW           no confirmed status
  [ Free ] [ Busy ] [ Out of service ]
  ────────────────────────────────────────
Bay B
  …
─────────────────────────────────────────────         ← §5.8 sticky bar, opaque #121212
3 to save                       [ Save 3 updates ]
```

- **The bay header line is derived and never written.** Showing
  `bayStateUnder(bay, ∅, now)` above the guns is how an operator learns that
  marking one gun `Busy` took the bay's other gun with it
  (availability-display §1.1) — the rule is visible in the surface instead of
  surprising them later. Unlensed, always (§2).
- **`Busy`, not `In use` — R1.** Availability-display law 3 quantifies with
  **`busy`** (*"`busy` quantifies `o` and nothing else"*), so `busy` is the word
  the grammar already owns and `in use` was never more than an example string.
  v1 of this file forbade `Busy` by name; **that prohibition is deleted.**
  Title-cased on the control because each label begins its own string, exactly
  as file 11's driver report sheet (S-02) title-cases the same three words.
- **`no confirmed status`, not `unreported` — R3.** The offline override yields
  `Unknown` from a thirty-second-old report, which makes any string asserting
  report history false. It fits: 19 characters at cap 27 Bold is **407 px**,
  right-aligned to the divider's own right end (x 1167), so it begins at x 760
  against a label column starting at x 196 — **564 px** for a longest label of
  `GB/T DC · 60 kW` (15 chars, ≈300 px), clearing by ~260 px [d].
- **The right-aligned value on a settings row is a composition the reference
  does not contain** — file 11 raises it as **[RAISE-D14]** (rows have no
  trailing affordance; the value treatment is borrowed from the sheet's price).
  O4 depends on that raise being said yes to; it is not re-derived here.
- **Bay naming has nothing behind it.** `Bay` carries no label, name or
  ordinal in domain-model, yet an operator standing at the third pedestal must
  be able to find its row. [RAISE-OA-7]
- Every state word on screen comes from the closed vocabulary in
  availability-display §2.4. The write surface does **not** get its own words:
  no `Broken`, no `Available`, no `In use`. Its three labels are the **same
  three [vocab] report-action strings** the driver's S-02 uses — file 11's
  [RAISE-D23] routes `Free` · `Busy` · `Out of service` into `packages/domain`,
  and this screen is the second consumer of that routing, not a second author.

### 4.3 The control row

**Assembled from:** `§5.1` primary CTA **geometry** (`size.ctaHeight` 46 pt,
`radius.button` 4.5 pt) carrying the **`§5.8` sticky CTA's label size** (cap 32
Medium), with the two fills the reference already distinguishes —
`color.surface` `#393939` + `color.text` label when unselected, `color.accent`
`#C7FC2F` + `color.onAccent` `#121212` Medium label when selected. Full content
width, `space.chipGap` 9 pt between, three up.

| Control | Writes | Renders |
| --- | --- | --- |
| `Free` | `Report.state = Free` | [vocab] |
| **`Busy`** | `Report.state = Occupied` | [vocab] — **R1**, product-wide |
| `Out of service` | `Report.state = OutOfService` | [vocab] |
| *(no fourth control)* | `Unknown` is **unwritable** | derived only |

`In use` appears nowhere: not on this control, not in the derived bay line, not
in the admin (§7/A9), not in a notification body. It is on the forbidden list
held in file 11 §13 (§0.1).

**Why the label size comes from the other CTA, and the arithmetic that forces
it. [d]** Three-up across the 1078 px content column with two 27 px gaps gives
**341 px per button**. At the primary CTA's own cap-37 Medium (≈28 px/char),
`Out of service` is 392 px and **does not fit**. At the sticky CTA's measured
cap-32 Medium (20.7 px/char) it is **290 px**, leaving 25.6 px each side. Both
sizes are measured; file 10 [RAISE-4] already records that the reference ships
two CTA label sizes on two CTA components, so composing height from one and
label size from the other introduces **no unmeasured value** — but it is a
composition, and it is marked as one. 25.6 px (8.5 pt) is the tightest padding
in the operator app and is named rather than smoothed.

Why not the `§5.5` chips, which look like the obvious answer: the feature chip
is **35 pt** tall and the category chip **25.7 pt**, and neither is interactive
in the reference — they are labels. Both are under any tap-target floor. Using
CTA geometry keeps the target at 46 pt. **[d]**, and the accent-as-selection
reading is the reference's own: the 03 category chip marks an active attribute
in accent, the 04 feature chips do not.

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
   invented one. **[d]** `Save 3 updates` is 14 chars = 290 px inside the
   513 px sticky CTA [d] — comfortable at every count the screen can reach.

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
offline (n)** · rejected by the server (membership revoked mid-session, §5.2) ·
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

### 5.1 The driver-app end (the card's face) — and the M9 reconciliation

**File 11 §6 owns this card's face**, including its four states and their exact
copy. This file does not restate them and does not hold a second copy; it
records only the measured fact the two documents disagreed about.

Measured (file 10 `§5.10`, re-verified for v2 off `02.png`):

| Property | Value |
| --- | --- |
| Frame | x 38 → 1167, y 1448 → 1782 = **1130 × 335 px = 376.7 × 111.7 pt** [m] |
| Padding | 39 px all four sides |
| Icon tile | **257 × 257 px** `#3E3E3E`, radius ≈15 px |
| Title ink | y 1522 → 1570, baseline 1558, cap 37 Bold [m] |
| Body ink | y 1592–1620 · 1637–1673 · 1682–1718 — **3 lines, 45 px pitch** [m] |
| Content box | 1487 → 1743 (335 − 2 × 39 = **257 px**) |

**The reconciliation, in one line: the card's height is fixed by the tile, not
by the text.** `39 + 257 + 39 = 335` exactly [m], so the content box is the
tile's own height. The reference's 3-line body ends at y 1718, **25 px clear**
of the content box floor; a 4th line would run to 1763 and **overrun by 20 px**
[d]. Therefore:

- the body slot holds **at most 3 lines** — that is a ceiling, not a
  requirement;
- file 11's EV Guide copy is **2 lines** and leaves the third unused;
- **the card does not resize either way.** v1 of this file said "3 lines" (the
  slot) and file 11 said "2 lines" (the copy). Both were true and neither said
  which it meant. This is the statement that reconciles them.

Everything else about the card is reproduced from file 10 `§5.10` unchanged:
fill `#393939`, `radius.card` 13 px, tile→text 67 px, a **lime** ≈9 px-stroke
glyph (the reference's car-with-arrow → a charger-with-arrow, drawn to the `§6`
rule).

**The copy slot survives; the recruiting semantics do not.** The reference's
card is an upsell to *non*-hosts (`Still not an host ?`). EV Guide's is the
opposite — it appears **only** to people who already hold the role, because
there is no self-serve path into it (§3/O9).

**Consequence:** for the overwhelming majority of drivers the card is **absent
entirely**, and the reference gives no evidence of how 02 lays out without it
**[?]** — the gap between the quick actions and `Settings` (154 + 164 px in
file 10 §3.2) is measured only in the with-card case. File 11 owns that layout
and rules 164 px ([RAISE-D7]); flagged here because this file causes it.

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

Ticket 11 fixes the list and the list is the whole list. **Scoped to the one
station the operator opened it from (§3.0), never aggregated.**

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
`type.label` 15 pt Bold ([RAISE-D14] again) and a `type.body` 13 pt line under
it carrying the window. **No chart, no sparkline, no tile grid** — the reference
contains no number display of any kind ([RAISE-OA-12] if charts are wanted).

---

## 7. Web admin

Vite + React SPA in the BWEZE console's shape, deployed as a BWEZE-hosted
static app (ADR-0006). **Internal tooling: the 1:1 reference rule does not
govern it.** It takes file 10 `§8.1`–`§8.4` (colour, type, space, radius — every
row marked **[admin]**) and **none of `§8.5`**, and **no React Native
components**. Two inherited constraints that a web dashboard will want to break
and must not: the accent is **exactly one value, no tints** (`§8.1`), and images
stay **rounder than containers** (`§8.4` — `radius.image` 10 pt over
`radius.button` 4.5 pt; the inversion is the system's signature).

**One genuine friction, stated precisely per R5: there is no secondary *text*
colour.** File 10 §2.4's finding holds **for text and only for text** — every
text core in all four screens samples `#FFFFFF`, and the grey *appearance* of
body copy is an ExtraLight weight at a ~1.7 px stem anti-aliasing against
`#121212`. It does **not** hold for icons: the `03` sheet's heart is solid
**`#717171`**, 517 px, x 1026–1074 / y 1881–1925 [m], while the same glyph on
`04` is `#FFFFFF` with zero pixels of `#717171` [m].

What that measured grey does and does not license:

- It **is** a measured colour in the reference. The blanket claim "no grey tier
  exists" is false as stated and is narrowed here, per R5, rather than defended.
- It is **not** a text tier. `#717171` on `#121212` computes to **3.84 : 1**
  [d] — below 4.5:1 for body text — and no text run in the reference uses it.
- It is **not** a disabled/inactive token either, because the same glyph is
  white on `04` in the same presumed state. One instance, contradicted by its
  own twin, is a measurement, not a semantic.

A dense admin table normally leans on a muted tier, and hierarchy here comes
from weight instead (ExtraLight/Regular/Medium/Bold). Since 1:1 does not govern
the admin, adding a muted tier is *available* — and it now has one measured
precedent to anchor on — but it breaks token kinship with `packages/ui`, so it
remains a founder call, not a default. [RAISE-OA-13]

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
- `powerKw`, `voltage` — numbers. `powerKw` is what O3's and D-03's hero badge
  render as peak power (R2), so a station with no `powerKw` anywhere loses that
  badge on both apps.
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
  surfaces cannot take URLs, so it materialises into the bundle. It is also O2's
  offline-safe leading-media fallback (§3/O2), so a missing icon degrades two
  surfaces, not one.
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
is where the moderation problem lives), never shown on car surfaces. **The
model gives Owners a Photo write and the product gives them nowhere to do it —
[RAISE-OA-16].**

### A8 · The publish gate
Publishable iff **≥1 Bay**, **each Bay ≥1 Connector**, **≥1 Photo** (`geo` and
`owner_id` are non-null by construction). Draft until then. The screen shows
the checklist with the unmet items named. Unpublish is possible.

**Publishing does not reach offline-first users immediately**: the bundled
directory snapshot is cut at release time (ADR-0007), so a station published
between releases is visible only to clients that have synced. Worth stating on
the screen; it is not a bug.

### A9 · Reports (read-only) and admin availability writes
See §8 — this is the screen with the sharpest prohibition on it. Its write form
carries the **same three [vocab] labels** as O4 and the driver's S-02: `Free` ·
**`Busy`** · `Out of service`. No admin-only fourth word, and `In use` appears
nowhere (R1).

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

Fourteen from v1, unchanged in substance except **[RAISE-OA-13]**, which R5
narrows; two added by v2's corrections.

**[RAISE-OA-1] The operator app is a dark-only design used outdoors.** The
whole system is `#121212`/`#212121`/`#393939` (file 10 §7 — no elevation, no
alternate surface), and the operator's core task is performed standing at a
charger in equatorial daylight. There is no light theme in the reference to
switch to, and inventing one is a deviation. File 10's [RAISE-2] (ExtraLight
body at 13 pt, 1.7 px stem) compounds it — this file uses Regular at
`type.body` for every derived data line, which `§8.2` already licenses, but the
ambient-light problem is not solvable inside the measured palette. The hero
badge's measured **1.21 : 1** label (§3/O3) is the same problem at its worst,
and is why R2 permits only a value that is restated in full below it.

**[RAISE-OA-2] The reference has no pressed, disabled, focused, loading, error,
empty or confirmation state.** File 10 §9 records this as unmeasurable from four
stills. A read design can survive that; a write tool cannot — every screen in
§3 and §7 needs at least three of them. This is the largest single gap between
the reference and the operator app, and it is a design decision the founder has
to authorise rather than something to derive. The one measured grey icon (§7)
does **not** close it.

**[RAISE-OA-3] `Station` has no description field.** The 04 `Description` block
has nothing behind it (domain-model §Entity model). Its measured region is
re-tenanted as O3's `Availability` block; adding a description is a schema
change and remains file 11's [RAISE-D12] to accept or reject.

**[RAISE-OA-4] No text or numeric input exists in the reference.** O5a (rate)
and every admin form need one. The settings row (`§5.6`) gives a resting
appearance; the focused/editing appearance has no measured source. File 11's
[RAISE-D21] proposes building it from the feature-chip surface; this file
consumes that decision and does not make a second one.

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

**[RAISE-OA-13] The admin has no secondary *text* colour — narrowed per R5.**
File 10 §2.4's finding is true of text and false of icons: the `03` heart is a
measured solid `#717171` (517 px) while the same glyph on `04` is `#FFFFFF`
(§7). A dense table normally needs a muted tier; adding one is permitted (1:1
does not govern the admin) and now has a measured precedent, but `#717171` on
`#121212` is 3.84 : 1 and is contradicted by its own twin, so it is not a token
until the founder says it is — and adopting it still breaks kinship with
`packages/ui`.

**[RAISE-OA-14] Deletion has no defined semantics.** `Report` is append-only
and hangs off `Connector`; deleting a connector or a bay orphans history. Block
or soft-delete — but the model says nothing.

**[RAISE-OA-15] There is no menu component anywhere in the reference — new in
v2.** §3.0 gives O5, O6 and O7 their entry point through O3's `⋯`, which the
reference draws (⌀100 px, three white dots) and never opens. No popover, action
list, context menu or dropdown is measurable from four stills. File 11 resolves
the identical gap for the driver's `⋯` (S-03) with **the platform's own action
sheet**; this file adopts that resolution so the product has one menu
mechanism, and raises it here because the operator app depends on it for three
of nine screens rather than for one convenience item. If the answer is "no
platform sheet", the three screens need a different home and §3.0 must be
redrawn.

**[RAISE-OA-16] Owners may write Photos and have no surface on which to do it —
new in v2.** domain-model §Write boundaries gives Photos to **admin and owner**.
The admin is staff-gated by `isStaff` and §7 deliberately excludes owner web
access, while the operator app's carousel is read-only (§3/O3). So the model
grants a write with no home: in practice every photo change becomes a studio
errand, forever. Either add an owner photo surface to the operator app (a
screen, a picker, an upload, a reorder — none of which the reference contains,
so it compounds [RAISE-OA-2] and [RAISE-OA-4]), or narrow the write boundary to
admin only and say so. Not a thing to leave ambiguous in the schema.

### Deliberately not specified (to keep this file inside its remit)

A station-scoped deep link from the driver's station detail into O4 (the opaque
stable station id supports it; nothing requires it, and §3.0 deliberately routes
every path to O4 through O3 so the operator sees the current state first) · an
operator map or `stationsNear` in the operator app · any messaging surface ·
operator push notifications · owner access to the web admin · deferred deep
linking after install · a shared session across the two binaries.

---

## 10. Screen tables

### 10.1 Operator app

| Screen | Entry point | Components used (file 10) | States | What fixes its content |
| --- | --- | --- | --- | --- |
| **O1 Sign in** | cold start, signed out | 02 centred column; `§5.9` avatar block; `type.display`; accent link; `§5.1` CTA ×3 (1 accent + 2 `color.surface`) | idle · in-flight · failed · resuming a hand-off | ADR-0003 providers (Google · Apple · magic link, no SMS); Apple compelled by Guideline 4.8 |
| **O2 My stations** | root | `§5.10` card container + `§5.4` sheet-body composition; `type.title` screen title; `§5.9` 43 pt map avatar; `§5.6` divider | loaded · loading · **no memberships → O9** · offline indicator · queued writes (n) | `Membership` edges (never geography); `nameShort`; **subtitle = availability clause + freshness**; **value slot = R4 short rate**; **stalest-first, nulls first** |
| **O3 Station detail** | **O2 row tap (present, `×`)** | full 04 shell: `§5.2` `×`+`⋯`, `§5.7` carousel + badge, `type.title`/`type.body`, 04 owner row, re-tenanted `Description` region, `§5.5` feature chips, `§5.8` sticky bar | loaded · offline (photos absent) · Regime 1 drawn first · unpublished (admin-only case) | `Station.name`; `Photo` order; `Owner` public face; **badge = peak power (R2)**; the `Availability` block carries the clause; **sticky left = R4 short rate**; **no description field exists** |
| **O4 Update availability** | **O3 sticky CTA `Update availability` (present, `×`)** | `§5.2` `×`; `type.title`/`label`/`body`; `§5.6` row + [RAISE-D14] value slot + `#3E3E3E` 1 px full-width divider; `§5.1` CTA geometry at cap-32 Medium ×3 as the control row; `§5.8` sticky bar | idle (nothing touched) · touched (n) · saving · saved · queued offline (n) · server-rejected · single bay/plug · `OTHER` plug | `Bay`→`Connector` tree; the three writable `Report` states as **`Free` · `Busy` · `Out of service`** [vocab]; per-tap `capturedAt`/`capturedLocation`; derived bay line via availability-display §1.1, unlensed |
| **O5a Rate edit** (owner edge) | **O3 `⋯` → `Rate` (push, `←`)** | `§5.6` rows, value right-aligned `type.label` Bold; `§5.1` CTA; plug multi-select | idle · editing · saving · saved | `ratePerKwhRwf`, `sessionFeeRwf`, `rateConfirmedAt` (90 d); `rateCoverage.distinctRates[]` |
| **O5b Rate flag** (operator edge) | **O3 `⋯` → `Rate` (push, `←`)** | `§5.6` rows; `§5.1` CTA | idle · submitted | **no entity exists** — [RAISE-OA-5] |
| **O6 Operators** (owner) | **O3 `⋯` → `Operators` (push, `←`)** | `§5.6` rows; `§5.1` CTA; `§5.10` card | list · empty · inviting · revoke confirm ([RAISE-OA-2]) | `Membership` scoped to **this station**; invitation has no model home |
| **O7 Station stats** (owner) | **O3 `⋯` → `Station stats` (push, `←`)** | `§5.6` rows, right-aligned `type.label` Bold + `type.body` window line | loaded · metric unavailable | 4 metrics (views · direction taps · reports received · uptime); **station-scoped, no aggregate**; no session, kWh or revenue exists; ticket 07 boundary |
| **O8 Profile** | **O2 avatar (push, `←`)** | 02 verbatim minus the quick-action trio; `§5.9` 105.3 pt avatar + 1 pt accent ring; `§5.6` list | loaded · offline · queued-writes row (non-interactive) | `User`; rows reduced to Personal information · Login & security · queue |
| **O9 No memberships** | **O2's zero-membership state** | `§5.10` card centred on `color.bg` | single state, **not an error** | zero `Membership` edges; no self-serve path exists, so no action is offered |

### 10.2 Web admin (tokens only; 1:1 does not govern)

| Screen | Components used | States | What fixes its content |
| --- | --- | --- | --- |
| **A1 Sign in** | console shell + `§8.1`/`§8.2` tokens | idle · authenticated-but-refused (`isStaff` false) · failed | one auth realm (ADR-0005); `User.isStaff` |
| **A2 Stations list** | table (no reference component — admin-native) | loaded · empty · filtered · draft vs published | `Station` rows; `updatedAt` cursor; publish-prerequisite filters |
| **A3 Station create/edit** | form; MapLibre picker on studio tiles | new · editing · invalid (length/NOT NULL) · saved | `name` ≤28 · `nameShort` ≤18 (the *place*) · `geo` NOT NULL · `owner_id` select over the bounded set · `vehicleClassTag` nullable · **every child write bumps `updatedAt`** |
| **A4 Bays & Connectors** | nested editor | ≥1 bay · bay with 1..N connectors · delete blocked ([RAISE-OA-14]) | OCPI 2.3.0 open enum incl. `OTHER`/`UNKNOWN`, **never a platform integer**; `powerKw` (feeds both hero badges) / `voltage`; rate fields; bay label ([RAISE-OA-7]) |
| **A5 Owners** | form + pin-scale preview | new · editing · CHECK violation on `markerLabel` · non-vector icon rejected | `displayName` · `shortName` ≤17 · `markerLabel` 1–3 `NOT NULL` CHECK · `icon` **vector** (also O2's offline fallback) · private legal/contact never projected |
| **A6 Memberships** | table + invite form | active · pending ([RAISE-OA-6]) · revoked | `(userId, stationId, role)` unique; admin creates Owners, override on Operators |
| **A7 Photos** | ordered grid, drag to reorder | 0 photos (blocks publish) · ≥1 · reordering | `Photo` order = carousel order; admin/owner only ([RAISE-OA-16]); never on car surfaces |
| **A8 Publish gate** | checklist | draft (unmet items named) · publishable · published · unpublished | ≥1 Bay · each Bay ≥1 Connector · ≥1 Photo; snapshot caveat (ADR-0007) |
| **A9 Reports + admin write** | read-only table + a **single-observation** write form | list · filtered by station/connector/source · new report | append-only `Report`; `source = admin`; labels `Free`/**`Busy`**/`Out of service` [vocab]; **§8's six prohibitions** |
| **A10 Audit** | table | — | required by ticket 11, **no entity exists** ([RAISE-OA-6]) |
| **A11 Stats (admin)** | table | loaded · metric unavailable | same four metrics, all stations; **internal only** — ticket 07 forbids publishing per-operator history |

---

## 11. What this file does not decide

The driver app's screens (file 11) · anything in file 10's raise list · the
hosting card's copy and its four states (file 11 §6) · the value-slot
composition [RAISE-D14], the text input [RAISE-D21] and the action-sheet
resolution (S-03), all of which this file **consumes** from file 11 rather than
re-deciding · the `Station.description` schema addition, which is ticket 19's to
accept or reject · and every founder call in §9, which is the point of raising
them.
