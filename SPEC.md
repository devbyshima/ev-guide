# EV Guide — specification

The single source of truth an implementation effort executes from. Assembled by
ticket 21 from the closed tickets, the eight ADRs, the measured design record
and the domain model. **Nothing here is a proposal.** Where a line records a
genuine trade-off a future reader would find surprising, it cites the ADR that
argued it; the argument lives there, not in this prose.

**Status, 2026-08-14.** Complete for the phone and web surfaces.
[§9 Car integrations](#9-car-integrations--open) is **deliberately unwritten**:
it waits on ticket 27's device test → ticket 24's scoping call → ticket 20's
filings. Every other section is locked. Section 12 carries forward everything
still open; an unresolved question that looks settled in a spec is worse than
one that is visibly open.

**How this is locked.** Decisions in §2 are not relitigated mid-build. If one
must change, it changes here and in its ADR, with the reason written down —
not in a commit message and not in a screen.

---

## 1. The product

EV Guide is a **directory of EV charging stations in Rwanda**. A driver opens
it to find a station, see its rate, connector types and bay count, learn
whether a bay is free, and get directions. Three surfaces: a **driver app**
(Expo, iOS + Android), an **operator app** (Expo), and a **web admin dashboard**
(Vite SPA) the studio runs.

It is **free, with no monetisation anywhere** — no driver payments, no operator
subscription, no paid listings, no billing infrastructure and no plan tiers at
any layer of the architecture.

**Who it serves:** car drivers. Moto riders and battery swap are out of scope —
not deferred ([ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md)).

**The market as measured, not as reported.** Two figures in circulation are
wrong and must not re-enter the spec through a store listing or an onboarding
screen:

- **EVP has no app.** The only shipped competitor is Kabisa Charge (5+
  downloads, no iOS build, flows it labels "(simulated)"). The competitive
  pressure assumed at charting does not exist (ticket 03, ticket 29).
- **~200 stations by Feb 2026 is a government plan target, not a count.**
  Primary sources give 17–19 sites in mid-2024; Kabisa's feed returns **77
  charge points nationally** across 18 brands (verified 2026-08-13). A charge
  point is not a station.

The market is genuinely multi-operator — Kabisa, EVP, Numa, Connex, PREV,
MUJEBA, Volkswagen Mobility Solutions Rwanda — which is what a directory is
for. There is **no dataset to import**: Electromaps lists zero stations for
Rwanda, OSM holds seven, and PlugShare, OpenChargeMap and Chargemap all refuse
programmatic access. **Stations are entered manually by the admin.**

**The regulation that governs the domain:** RURA Regulation
No 011/ENERGY/RURA/2026, in force 29 June 2026. It requires public
infrastructure to support the two most prevalent technologies (Annex I), makes
tariffs a public disclosure (Art. 27(2)), and mandates 97% uptime with fines.
RURA keeps **no licence register and requires no tariff filing** — a confirmed
absence, not a gap in the research.

---

## 2. Locked decisions

| # | Decision | Where it was argued |
| --- | --- | --- |
| 1 | Cars only. Moto and battery swap out of scope, not deferred. `Station` carries a nullable vehicle-class tag nothing branches on. | [ADR-0001](docs/adr/0001-cars-only-swap-out-of-scope.md) |
| 2 | Availability is per **Connector**, four states (`Free`/`Occupied`/`OutOfService`/`Unknown`), freshness a separate axis, decay by source **and** state. `Unknown` is the normal case, designed for, never rendered as failure. | [ADR-0002](docs/adr/0002-availability-model.md) |
| 3 | Availability is **derived, never stored**. No table carries an availability column. Occupancy propagates across a Bay; brokenness does not. | [ADR-0008](docs/adr/0008-availability-derived-bay-propagation.md) |
| 4 | Read anonymously; the gated acts are exactly three — **save, report, profile sync**. Google + Apple + email magic link, **no SMS**. **Directions are ungated everywhere, and so is `My plug`** (a device-local reading aid; only syncing it needs an account). | [ADR-0003](docs/adr/0003-driver-identity-and-gating.md), as amended by ticket 23 and 2026-08-14 |
| 5 | Route **preview** in-app on self-hosted Valhalla; the **drive hands off to Google Maps**, deep-linked by `lat,lng`. No in-app turn-by-turn, therefore no CarPlay navigation entitlement. | [ADR-0004](docs/adr/0004-directions-preview-and-handoff.md) |
| 6 | **MapLibre + self-hosted OSM vector tiles**, custom near-black style authored by EV Guide. Not Google: its ToS forbids the tile caching offline demands. | ticket 06 |
| 7 | **Offline is first-class.** Kigali basemap (5.6 MB) + a directory snapshot ship in the binary; all-Rwanda pack (76 MB) opt-in; the decay derivation runs on device, so a stale green is structurally impossible. | [ADR-0007](docs/adr/0007-offline-model.md) |
| 8 | **No external runtime dependency.** Kabisa's public feed is not built on, at any cost — the studio owns the whole pipeline. | ticket 26 |
| 9 | **Fully self-sufficient positioning.** With zero operator adoption EV Guide is still a complete directory. EV Guide publishes **no per-operator uptime history** — becoming a de facto RURA compliance monitor would starve the operator channel. | ticket 07 |
| 10 | Rate is a **Connector** property, RWF/kWh + optional session fee, 90-day freshness, `Unknown` stated not hidden. Owners and Admin write it; Operators may only flag it. **Displayed, never collected.** | ticket 10 |
| 11 | Role is a **membership edge**, never a user attribute. Owners create their own Operators. Conflicts resolve **most-recent-`capturedAt`-wins regardless of source**, source always shown. No reputation system. | ticket 11 |
| 12 | Operator stats are **four metrics** — views, direction taps, reports received, own uptime. No kWh, revenue or session count exists, because EV Guide never observes a charging session. | ticket 11 |
| 13 | **Backend is BWEZE**, built **frontend-first** behind repository protocols. One auth realm, one user table, all three surfaces. Store reports, derive at read time, poll — no cron, no websockets. | [ADR-0005](docs/adr/0005-backend-bweze-frontend-first.md) |
| 14 | **Two Expo apps + one Vite admin in one pnpm monorepo**; `packages/domain · data · ui`; the mock data implementation is a first-class citizen. | [ADR-0006](docs/adr/0006-codebase-shape.md) |
| 15 | Connector types are an **open enum in OCPI 2.3.0 spellings** (tier 1: `IEC_62196_T2`, `IEC_62196_T2_COMBO`, `GBT_AC`, `GBT_DC`; `OTHER`/`UNKNOWN` always expressible). **Never persist a platform integer** — map at the edge. CHAdeMO is not a Rwandan standard. | ticket 02 |
| 16 | **The reference designs are implemented 1:1.** No deliberate deviations; impossibilities are raised, not improved around. Two knowing deviations are recorded in §12. | founder rule; ticket 17 |
| 17 | **v1 ships the availability layer and claims the directory.** Availability is "live status when reported" — a bonus, never a promise. **`real-time` and `live` are banned** from the UI, the store listing and onboarding alike. | ticket 28 |
| 18 | Seeding is a **launch-week studio survey pass** plus pre-launch recruitment of the 2–3 largest operators. Admin-marked "known-busy patterns" are **permanently rejected** as synthetic data. | ticket 28 |
| 19 | **Bay-watch** is one-shot: only a **report-driven** transition into `Free` fires it, decay never does; 2 h expiry, max 3 armed. The design is the spam control — no rate limiter, no digest. Transport is raw APNs + FCM from BWEZE. | ticket 30 |
| 20 | **Journey planning with charging stops is out of scope** — including the corridor filter and the remaining-charge isochrone. A future effort, not this map widened. | ticket 29 |
| 21 | **Outbound acquisition of every kind happens only after the product is built.** The MININFRA annex request and the Kabisa disclosure are drafted and held. Manual entry stands. | founder rule 2026-08-13; tickets 25, 26 |
| 22 | **Exactly two knowing 1:1 deviations exist**: the `Google` wordmark slot carries `© OpenStreetMap contributors`, and the location puck is redrawn off Google's `#4285F4` into `#FFFFFF` + `#C7FC2F`. Everywhere else the reference wins. | [ADR-0009](docs/adr/0009-reference-fidelity-deviations-and-costs.md) |
| 23 | **Two fidelity costs are carried rather than deviated around**: the hero badge is reproduced at 1.21:1 under a redundancy invariant, and the operator app ships **dark-only**, revisited only on launch-week evidence. | [ADR-0009](docs/adr/0009-reference-fidelity-deviations-and-costs.md) |
| 24 | **The typeface ships as an acceptance band, not a name**, and is chosen **free-first** — a retail licence only if no free face meets the band. Old-style figures are non-negotiable. | [ADR-0010](docs/adr/0010-typeface-acceptance-band.md) |

---

## 3. Domain model

Full model, schema constraints and write boundaries:
**[docs/domain-model.md](docs/domain-model.md)**. Glossary: **[CONTEXT.md](CONTEXT.md)**.
Both are normative; this section states only what an implementer must not get
wrong.

```
Owner 1 ──── N Station 1 ──── N Bay 1 ──── N Connector 1 ──── N Report
                │ 1                                  │
                ├──── N Photo                        └── Rate (fields on Connector)
                └──── N Membership N ──── 1 User ──── N SavedStation
```

Load-bearing constraints:

- **`Station.geo` is NOT NULL** — a station without coordinates cannot exist.
- **A Bay carries 1—N Connectors.** One vehicle holds the position, so
  occupancy propagates across the Bay (decision 3).
- **Owners are a bounded, enumerable set** with a `markerLabel` of 1–3 chars
  (`NOT NULL`, `CHECK`) and a **vector** icon. Never a free-text string on
  Station.
- **`Report` carries `capturedAt` + `capturedLocation`**, distinct from
  `receivedAt` (reports queue offline), plus `sourceOnline`. Append-only:
  **there is no retract verb** — a wrong claim is answered by a true one, or by
  decay.
- **Deliberately absent:** any availability column; any route, maneuver or
  polyline entity; any payment, plan or billing entity; any Session entity.
- Authored length bounds, enforced in the admin: `nameShort ≤ 18`,
  `name ≤ 28`, `Owner.shortName ≤ 17`.
- **Projections return structure, not formatted strings** — `(distanceMeters,
  nameShort)`, never `"~2.4 km · SP Remera"`.
- Primary reads: **`stationsNear(origin, limit)`** (arbitrary origin, never
  "device location" hardcoded; geospatial index before text index) and
  **`changedSince(cursor)`** for delta sync.
- A Station is publishable only with ≥1 Bay, each Bay ≥1 Connector, and ≥1
  Photo.

**Write boundaries**

| What | Admin | Owner | Operator | Driver |
| --- | --- | --- | --- | --- |
| Station / Bay / Connector structure | write | — | — | — |
| Owner entity, memberships | write | creates own Operators | — | — |
| Rate (on Connector) | write | write | **flag only** | — |
| Availability Reports | write | write | write (6 h window) | write (2 h window, proximity-gated, account required) |
| Photos | write | write | — | — |
| SavedStation | — | — | — | own rows |

---

## 4. Availability and the honesty rules

**[docs/availability-display.md](docs/availability-display.md) is the single
specification** of both the derivation and the display grammar. It lives in
`packages/domain` and is executed identically by the server, the phone and (if
§9 proceeds) the two car layers. **No surface declares its own vocabulary or
its own roll-up** — three documents tried during ticket 17 and produced four
lists that were not the same list.

The rule in one line, and it must exist as a test rather than a comment:
**occupancy crosses the type boundary, brokenness does not, and a free sibling
never vouches for an unreported gun.**

Decay windows: driver 2 h · operator 6 h · `OutOfService` 30 d · rate 90 d. A
source declaring itself **offline yields `Unknown` immediately**, regardless of
recency.

**The decay clock.** Deriving at render makes a stale value unrepresentable
*only if a render happens*. Every surface schedules a one-shot recompose at
`nextDecayDeadline(displayed, now)`, buckets deadlines inside one minute, and
recomposes on scene resume.

**The three display regimes** — capacity-only when everything is Unknown,
totals only when nothing is, counts-without-a-total otherwise — and the eight
laws are in that document. The two that catch implementers:

1. **`0 of N` is never emitted, for any input.** At ~87% Unknown it is the
   normal case, and it sends drivers away from stations that may be empty.
2. **No string asserts report history.** `no confirmed status`, never
   `no recent report` — the offline override yields `Unknown` from a
   30-second-old report, which makes the second string false.

**The forbidden-string list has exactly one home**:
[availability-display.md §2.2b](docs/availability-display.md), which since
2026-08-14 genuinely holds the **union** of what the four competing copies
carried. `packages/domain` enforces it with a test that greps the emitted
vocabulary. Adding a string is a change to `packages/domain` and needs a
fixture. *(Amended by ticket 32: this line used to cite a second home — "the
product-wide extension in the design record §11.2" — which was not an extension
but a smaller overlapping variant, missing four items §2.2b now absorbs and
carrying three §2.2b lacked. There is one home and one citation.)*

**One word for `Occupied`: `busy`.** `in use` is deleted product-wide — and so
is the capitalised `In use`, which is the same ban. The mapping is enumerated in
[availability-display.md §2.4](docs/availability-display.md).

---

## 5. Design system

Measured from `refs/01.png`…`04.png` (iPhone 16 Pro @3x), two adversarial
rounds. The pixel-level record is
[`10-design-system-v2.md`](.scratch/ev-guide-spec/design/10-design-system-v2.md);
it is the citation of record for anything not restated here. Lands as
`packages/ui`, shared by both mobile apps. **The admin dashboard takes tokens
only — no React Native components**, and the 1:1 rule does not govern it.

**Colour** — `#121212` page · `#212121` map canvas · `#393939` surface ·
`#3E3E3E` raised/divider · `#C7FC2F` accent (**exactly one value, no tints, no
gradients**) · `#121212` on accent · `#FFFFFF` **the only text colour** ·
`#262626` handle · `#717171` `iconMuted` (the `03` heart and only that) ·
pin `#FFFFFF`/`#F3F3F3`/`#393939` · `#121212` `iconOnLight` (the map avatar's
person glyph) · `#000000` `iconOnLightBlack` (**the locate arrow only** — two
blacks on the accent is an open raise, not a licence to use either freely).

Deliberately absent: any secondary/muted text token, opacity ramp, elevation
colour or accent tint. **There is no grey text tier** — what looked like one is
ExtraLight anti-aliasing. `color.iconMuted` is not a text token.

**Type** — 26 / 22 / 17 / 15 / 13 pt (display · title · heading · label ·
body), body line-height 15 pt, tracking 0 at every size, weights 200/400/500/700.
**Old-style figures (`onum`) are a required feature, not a preference.** One
link style exists: accent, underlined, 0.67 pt, 1 pt below baseline,
`skipInk: false`. **The typeface is not identified and ships as an acceptance
band** — nine measured metrics and a 60-second overlay check, tested free-first
([ADR-0010](docs/adr/0010-typeface-acceptance-band.md)). `packages/ui` must not
pick a family from the design record. Every pt size below inherits ±3% from an
assumed cap-height/em; **the cap heights themselves are exact.**

**Spacing** (px @3x) — pageMargin 64 · cardMargin 38 · cardPadding 39 ·
floatingCardPadding 64 · floatingCardBottomGap 64 · stickyBarPadding 90 ·
chipGap 27 · chipRowGap 26 · chipPaddingH 30 · chipIconGap 18 ·
titleToSubtitle 20 · blockGap 39 · sectionGap 62 · sectionGapLarge 87 ·
settingsRow 176 · iconGrid 72 · iconGridChip 48 · iconStroke 6 · hairline 2.
Named after where they were measured: **there is no grid.**

**Radii** (px) — featureChip 13.4 · card 15.6 · tile 15.2 · **button 16.5** (both CTAs,
one token) · floatingCard 19.5 (all four corners) · image 31.8 · **pill 9999** ·
circle 9999. **There is no `radius.sheet` token and no `radius.buttonSticky`
token, deliberately** — a single radius fits all eight corners of both CTAs with
zero penalty. The **category chip, the hero badge and the drag handle are pills**
(½ integrated height = 38.4 / 35.4 / 6.4), so `radius.nearPill` does not exist.
The images-rounder-than-containers inversion is real — images 10.6 pt against
containers 4.5–6.5 pt — and must not be "fixed".

**Component sizes** (px) — **all published at their integrated extent**
(tickets 34 and 36; see the note below). CTA **898.00 × 137.25 h** (sticky
**513.00 × 131.25**) · floating card **1077.60 × 521.53** · **pin
122.30 × 147.25** · handle **180.00 × 12.75** · feature chip **105.49 h** ·
category chip **254.75 × 76.75** · circular buttons **81.4 / 90.8 / 99.5 /
137.7** · **quickAction 154.8 / 150.3 / 149.9 — three sizes, not one** · avatars
**128.6** map / **315.9** profile / **76.7** owner · thumbnail **≈297.5 ±1.5** ·
statusDot **20.4** · accentRing **3.0** · puck **39.6** disc / **4.0** ring /
**82.0** halo / **puckCone 16 × 19**, 6–7 px clear of the disc.

Three of those need a sentence. **`quickAction` was a single 150 token for three
buttons that measure 154.8 / 150.3 / 149.9** — the design record had them right
as "154 / 149 / 149" and the collapse happened on the way into this document;
`packages/ui` may implement them however it likes but may not lose the
distinction. **The thumbnail carries a band because it cannot be pinned** — it is
photo-filled, three estimators spread 4 px, and all three land under the
published 300, which was a pixels-touched bbox. **The puck's heading cone is a
fourth `#4285F4` surface**, detached from the disc, that the token set never
carried; it is inside ADR-0009's redraw scope along with the other three.

> **On the two conventions, now one.** A component's size reads three ways —
> core, integrated, AA-inclusive — and until 2026-08-16 the design record used
> two of them **without declaring either**, which is how commit `6a5a922` came to
> "correct" the CTA's height *away* from the reference by matching a token. The
> convention is now **integrated**: the element's true extent, independent of the
> sub-pixel phase the capture caught it at
> ([ticket 34](.scratch/ev-guide-spec/issues/34-extent-convention.md)). **Tokens
> carry the fraction and nothing is rounded** — 137.25 px is 45.75 pt, which lays
> out exactly at @3x, and a rounding rule is precisely the undocumented tiebreak
> this closes. The radii above are likewise re-measured: the record's corner-arc
> method stated a false geometric identity and **under-read every radius in the
> system**, by about `√r`
> ([ticket 33](.scratch/ev-guide-spec/issues/33-radius-system-under-read.md), all
> twelve rows re-fitted, harness re-validated against four independent knowns).
> The remaining sizes were swept under
> [ticket 36](.scratch/ev-guide-spec/issues/36-size-line-convention-sweep.md),
> which confirmed the rule's own prediction in both directions: every hard-edged
> element read **identically** under all three conventions and did not move
> (`accentRing` 3.0, the puck ring 4.0 and halo 82.0, the profile avatar 315.9),
> and every element that moved moved **up**, by 0.4–1.5 px — which is what a
> pixels-touched count does against an integrated one.

**Five findings that would each have shipped visibly wrong:**

1. **The CTA is not a pill** — r **16.5** on an **898.00 × 137.25 px** button (a
   pill would be r 69), and not full-width. *The finding is the point and it
   holds with room to spare. The number read 13 until ticket 32 found the radius
   method under-reads, and the size read 899 × 138 until ticket 34 declared the
   convention; both are settled and neither moved the finding.*
2. **There is no grey text.**
3. **The `03` container is a floating card**, not a bottom sheet — 19.5 px on all
   four corners, with **64 px of live map between its bottom edge and the CTA**
   (`space.floatingCardBottomGap`), and 305 px between it and the screen bottom.
   It is never anchored to the screen edge: `packages/ui` names it `StationCard`
   and must not build it on a sheet primitive, whose whole contract is bottom
   anchoring.
4. **The handle is 180 px**, and `#262626`. It is a pill: ½ of its integrated
   height (12.75) is r **6.4**.
5. **The basemap palette across ~85% of the front door was never in the
   record.** Under MapLibre that style is EV Guide's to author (§2.6 of the
   design record is style-JSON ready), and the location puck is redrawn in
   `#FFFFFF` + `#C7FC2F` — Google's `#4285F4` is not ours
   ([ADR-0009](docs/adr/0009-reference-fidelity-deviations-and-costs.md)).

**The governing finding about the reference: it is a read design.** It contains
**no form control of any kind** — no text field, switch, picker, checkbox,
segmented control, empty state, error state, pressed/disabled state, menu,
table, or any persistent chrome. Every write surface in the operator app and
admin composes from what exists: the settings row, the CTA geometry, and one
trailing accent check at 24 pt / 2 pt stroke. **The field is the secondary-control
box** — `color.surface` at `size.ctaHeight` **137.25 px**, `radius.button`
**16.5 px**, `space.chipPaddingH` 30 px inset — **and never the feature chip**, which is
35 pt and which the driver record rules out for controls product-wide. **The
absence of a tab bar is a positive finding** and fixes navigation everywhere:
full-screen surfaces reached by a push (back `←`) or a presentation (close `×`),
plus one floating avatar.

**The states are designed** (ticket 31, two adversarial rounds:
[states](.scratch/ev-guide-spec/design/18-interaction-states-v2.md) ·
[controls](.scratch/ev-guide-spec/design/19-form-controls-v2.md)). Two results
govern everything built on this system:

- **State is carried by the accent or by copy, never by a surface swap alone.**
  The four greys span **1.75:1 end to end** and surface→raised is **1.08:1**, so
  no grey-to-grey swap reaches the 3:1 a non-text signal needs. A press that
  dims, a placeholder that greys, a disabled control that fades — each is
  inventing a channel the measured palette does not have.
- **EV Guide has no disabled state and no disabled token**, tested against 23
  places. A control is **absent**, or it **refuses in words**, or it is
  **transiently inert** — split by who can satisfy the precondition and when.
  This is already the product's grammar: the hosting card is absent without a
  membership, and O9 offers no action because no self-serve path exists.

---

## 6. Driver app

Full screen-by-screen record, with states and domain mapping:
[`11-driver-screens-v2.md`](.scratch/ev-guide-spec/design/11-driver-screens-v2.md).

| Screen | Source | What fixes its content |
| --- | --- | --- |
| **D-01 Map home** | ref `01` | ADR-0002 · ADR-0007 · ticket 06 |
| **D-02 Map + station card** | ref `03` | availability-display §2 · ADR-0004 · ADR-0007 · ticket 10 |
| **D-03 Station detail** | ref `04` | ADR-0002 · ADR-0008 · ADR-0004 · tickets 10, 30 |
| **D-04 Profile** | ref `02` | ADR-0003 · ADR-0006 · tickets 11, 15 |
| **D-05 Personal Information** | ext | ADR-0003 |
| **D-06 Login & Security** | ext | ADR-0003 · Guideline 5.1.1(v) |
| **D-07 Offline & map data** | ext | ADR-0007 · tickets 06, 16 |
| **D-08 Notifications** | ext | ticket 30 · ADR-0003 |
| **D-09 My plug** | ext | ADR-0002 · tickets 12, 19 |
| **D-10 About EV Guide** | ext | attribution · ticket 06 |
| **D-11 Saved** | ext | ADR-0003 |
| **D-12 Alerts** | ext | ticket 30 · ticket 23 — **car-effort package** |
| **S-01 Auth sheet** | ext | ADR-0003 as amended |
| **S-02 Report sheet** | ext | ADR-0002 · ADR-0007 · tickets 09, 11 |
| **S-03 Overflow menu** | ext | platform action sheet |

**The five substitutions the reference forces**, all settled: `Payment &
payouts` → **`Offline & map data`** (there is no payment concept to host);
`Switch to hosting mode` → a **membership-gated cross-app affordance**; the
reference's search/discovery framing → `stationsNear`; the crosshair → the
content datum; and pin availability solved 1:1 by **re-tenanting the
reference's own status dot** at **(+54, −54) px**, tangent to the pin rim.
*(Amended from (+53, −53) by ticket 32. The pin head is a circle fitted to
**r = 61.25 ± 0.15** at 0.12 px rms, so the tangency constraint is
`d ≥ 61.25 + 14.5 = 75.75` and the smallest integer offset meeting it is 54.
At 53 the dot's ring overlaps the rim by 0.80 px — the exact fusion the
placement exists to prevent. The original derivation stated `d ≥ 75.5` and then
divided 74.5 by √2, so it never admitted its own answer.)*

**Attribution and the badge.** D-01's bottom-left mark slot carries
`© OpenStreetMap contributors` in the reference's own type treatment, tapping
through to D-10 — the first of the product's two knowing deviations
([ADR-0009](docs/adr/0009-reference-fidelity-deviations-and-costs.md)). D-03's
hero badge is reproduced at its measured 1.21:1 contrast under the **redundancy
invariant**: any value on the badge is restated in readable form below it, and
it carries peak power or nothing.

**What the pin deliberately does not say.** One additive channel, spent on the
only actionable fact: a free-bay dot or nothing. It does not distinguish
`Occupied` / `OutOfService` / `Unknown`, carries no Owner mark, has no selected
state, and **does not cluster in v1**.

**The route preview lives inside the existing screens** — there is no route
screen in the reference and none is invented. The line goes on the map in D-02;
distance and duration go in the category-chip slot (content-sized). Offline it
degrades to a **labelled straight-line** figure, and **the Google Maps hand-off
is never gated on the preview**. ETAs shown are Valhalla's own and must not
promise Google's numbers.

**The gate** (decision 4): reading, directions and `My plug` are ungated. The
inline auth sheet with auto-resume fires on **save** and **report**.

**Reporting** is per-Connector, proximity-gated on `capturedLocation`, one tap
committing (there is no selected-control state to build a two-step flow from),
queued offline and dropped unsent past its own 2 h decay window.

**Offline surfaces:** a quiet indicator (never an error screen), the
straight-line label, the all-Rwanda pack row in D-07, and a global loading /
empty vocabulary. Cold online start is under 1 MB excluding tiles.

---

## 7. Operator app

Full record: [`12-operator-admin-screens-v2.md`](.scratch/ev-guide-spec/design/12-operator-admin-screens-v2.md).
Separate Expo app, same `packages/ui`, same auth realm. **No tab bar** — push
and present only.

| Screen | Notes |
| --- | --- |
| **O1 Sign in** | Google · Apple · magic link, no SMS |
| **O2 My stations** | scoped by `Membership` edges, never geography; **stalest-first, nulls first** |
| **O3 Station detail** | the `04` shell, re-tenanted; badge is **peak power**, never an availability word |
| **O4 Update availability** | the write surface — §7.1 below |
| **O5a Rate edit** (owner) / **O5b Rate flag** (operator) | the flag has **no entity yet** — §12 |
| **O6 Operators** (owner) | memberships scoped to one station |
| **O7 Station stats** (owner) | the four metrics, station-scoped, no aggregate |
| **O8 Profile** | `02` verbatim minus the quick-action trio |
| **O9 No memberships** | a state, **not an error**; no self-serve path exists, so no action is offered |

**7.1 The availability write surface (O4).** It writes `Report` rows and
nothing else. Four rules stop it fabricating knowledge: one tap is one human
observation; `capturedAt`/`capturedLocation` are stamped per tap; the derived
bay line is rendered unlensed through availability-display §1.1; and the three
writable states are labelled **`Free` · `Busy` · `Out of service`** from the
closed vocabulary. Offline, writes queue and the count is shown.

**7.1a It ships dark-only, and that is a known cost.** O4 is used standing at a
charger in equatorial daylight, and the measured palette has no light theme to
switch to. No light theme, contrast mode or brightness override ships in v1;
the one mitigation the palette permits — Regular rather than ExtraLight on every
derived data line — is already applied. Revisited **only** on launch-week
evidence, when studio staff are using O4 in real sunlight
([ADR-0009](docs/adr/0009-reference-fidelity-deviations-and-costs.md)).

**7.2 Owner stats: four metrics and three absences.** Views, direction taps,
reports received, own uptime. There is no kWh, no revenue and no session count
because no Session entity exists — and per decision 9, **no per-operator
history is ever published**.

---

## 8. Web admin

Internal tooling: BWEZE console shape, **tokens only**, the 1:1 rule does not
govern. Screens A1–A11: sign in (`isStaff`), stations list, station
create/edit with a MapLibre picker on studio tiles, bays & connectors, owners,
memberships, photos, the publish gate, reports (read-only) plus a
single-observation write, audit, and stats.

**What the admin must not be able to do** — six prohibitions, enforced as tests
rather than memory:

1. **No availability field on any station, bay or connector form.** If one
   exists anywhere, ADR-0008 has already been violated. This is the crispest
   test in the product.
2. **No bulk availability write** — no "mark all free", no multi-select, no CSV
   import of states.
3. **No pattern, schedule, rule, recurrence, default or seeded state.**
4. **No authored `capturedAt`** — the admin's write stamps `now`, like
   everyone's.
5. **No editing or deleting an existing Report.**
6. **No availability written from an inference** — import, scrape, competitor
   feed, telemetry guess.

The admin's availability write is legitimately for exactly two things: the
launch-week survey pass, and correcting a bad report by filing a true one. Both
are one human, one observation, one report.

---

## 9. Car integrations — OPEN

**This section is not written, and the omission is deliberate.**

CarPlay and Android Auto are in the brief and were placed in the spec but out
of the first build. Research then established that **neither platform ships in
Rwanda** (ticket 04), that Apple treats country support as a prerequisite while
Google's list is explicitly *marketing rights* (ticket 22), and that the
question is undecidable from documentation.

What already exists and survives whatever is decided:

- Both surfaces are **designed and adversarially reviewed three times**
  (ticket 18). No forbidden template, no breached row cap, no sign-in wall,
  `Directions` unconditional.
- The reviews produced **[docs/availability-display.md](docs/availability-display.md)**
  and the amendments to ADR-0004/0007/0008 — all of which are load-bearing for
  the phone app and are already locked above.
- The **14 car-platform constraints** are honoured by the domain model
  regardless (domain-model.md §"Car-surface constraints honoured"), so nothing
  in §3 changes if the car work is dropped.
- Ticket 23 fixed the three functions that clear Apple's "meaningful
  functionality relevant to driving" bar, and **directions were ungated
  everywhere** as a consequence — a decision that stands on its own.
- **Bay-watch (ticket 30) ships with the car package**, which is why D-12
  Alerts is marked so in §6.

**Blocked on, in order:** ticket 27 (device test on real hardware in Rwanda) →
ticket 24 (does the car work stay in scope, and on what basis) → ticket 20
(file the CarPlay entitlement and open the Android Auto path). When 20 closes,
this section is written from tickets 18, 20, 23 and 30, and this spec is
complete.

---

## 10. Architecture

**Backend: BWEZE** ([ADR-0005](docs/adr/0005-backend-bweze-frontend-first.md)) —
one tenant (Postgres, auth, storage) plus git-deployed containers: the API, the
OSM vector tile server, and Valhalla. No third-party BaaS. One periodic OSM
extract job feeds tiles and routing. Tiles and styles are CDN-cached hard and
purged on refresh; route previews and API reads go to origin.

**One auth realm, one user table** across all three surfaces. Roles are
membership edges; admin is an `isStaff` flag; operators and owners join by
email invitation. If tenant auth cannot serve Google + Apple + magic link, the
API carries Better Auth against the same Postgres — the realm stays single
either way.

**Runtime: store reports, derive at read time, poll.** No decay jobs, no
websockets in v1. Clients refetch on screen focus and map movement.

**Repo shape** ([ADR-0006](docs/adr/0006-codebase-shape.md)) — one pnpm
workspace:

```
apps/driver     Expo, managed CNG + dev-client
apps/operator   Expo
apps/admin      Vite + React SPA, BWEZE-hosted static
packages/domain pure types + the derivation + the closed vocabulary; no platform imports
packages/data   repository protocols; the mock implementation is first-class and carries the seed dataset
packages/ui     the React Native design system, built 1:1 from the reference
```

**Frontend first.** Both apps are built against the mock data layer behind the
repository protocols; the BWEZE implementation lands after, behind the same
seam. Mock and BWEZE implementations must both satisfy the protocols and both
feed the derivation unchanged.

**Platform floor is a rule, not a number:** the latest stable Expo SDK pinned
when the build starts, New Architecture on, SDK-default minimum OS versions
with no hand-raised floors (Rwanda's fleet skews older Android; every raised
floor sheds users for nothing).

**Launch bar, in the spec and not negotiable:** the BWEZE data plane must run
on always-on server infrastructure **before EV Guide serves drivers**. As of
ADR-0005 it is a Lima VM on the founder's Mac behind a Cloudflare tunnel —
a development arrangement, not a serving platform.

---

## 11. Non-goals

- **In-app payment, settlement and payouts of every kind.** No MoMo, Airtel
  Money or IremboPay; no refunds, owner settlement or reconciliation. Rates are
  displayed and never collected. The structured Rate fields are the entire seam
  a future payment effort would build on.
- **Any monetisation** — no subscriptions, no paid listings, no ads.
- **Moto riders and battery swap** (decision 1).
- **Journey planning with charging stops**, corridor filters, and remaining-charge
  isochrones (decision 20).
- **In-app turn-by-turn**, voice guidance, rerouting, and any driving UI.
- **Per-operator uptime history**, published anywhere (decision 9).
- **Any external runtime data dependency**, Kabisa's feed above all (decision 8).
- **A Session entity, a confidence score, a reputation system, and a retract
  verb** — each rejected on its own merits above.
- **Community media and driver-submitted photos** — Photos are admin/owner only.

---

## 12. Still open

Carried forward from the map's *Not yet specified* section and the design
record's raise lists. **None of these is settled by this document.**

**Blocking the spec's completion**

- Tickets **27 → 24 → 20**, then **§9** (see there).

**Founder calls — all five ratified 2026-08-14, and now decisions 4, 22, 23
and 24.** The typeface acceptance band and its free-first selection
([ADR-0010](docs/adr/0010-typeface-acceptance-band.md)); the two knowing
deviations and the two fidelity costs
([ADR-0009](docs/adr/0009-reference-fidelity-deviations-and-costs.md)); and
`My plug` staying ungated ([ADR-0003](docs/adr/0003-driver-identity-and-gating.md)
amendment). They are listed here only so a reader who remembers them as open
finds where they went.

**Conditions that would reopen a ratified call**

- **No free face carries an old-style figure set** at the acceptance band. Then
  the choice is a retail licence or losing the reference's figure character —
  a fresh founder call, not a detail to drop (ADR-0010).
- **Launch-week operators cannot read O4 in sunlight.** A light theme is then a
  commissioned design pass with its own premise, not a token swap (ADR-0009).
- **`Rebero` and `Remera` do not exist in OSM as places** and must be added
  upstream before the basemap can reproduce the reference's own label set — a
  consequence of the attribution decision, and unowned work.

**The states design pass is done, and it left founder calls**

Ticket 31 closed the largest gap: the seven interaction states and the form
controls are specified, each stream adversarially reviewed and revised. What
it could not settle inside the measured palette is a set of **19 founder
calls**, consolidated in the ticket's answer. The ones that change what ships:

- **Pressed has no channel that reaches 3:1.** The recommendation is that
  pressed renders nothing and the result is the feedback — which makes latency
  a specification rather than an implementation detail.
- **O4's 1 px divider is the serious one.** It is the only separator between
  connector rows inside a bay, it sits at 1.75:1, and a wrong-row tap files a
  false report about the wrong bay. No mitigation exists inside the palette.
- **A server-rejected queued write has no surface**, and three of four candidate
  homes fail structurally while the fourth fails for the very case that produces
  it — the membership was revoked, so the station is gone.
- **The selection highlight would be the product's first accent tint**, which
  §10.1 says does not exist.
- **The platform's confirmation dialog brings Apple's and Google's red** into a
  product with no red.

**Corrections owed, and they are not cosmetic** — see ticket 32: the sweep found
**60 stale values** in the two screen inventories, all cited as measured. Fifteen
of sixteen fit calculations survive at corrected values, so nothing designed has
to be redesigned; the sixteenth is an asserted impossibility that is not one.

**Model gaps with no entity behind them**

- **Rate flag** (O5b), **membership invitation** state, and the **audit log**
  ticket 11 requires — all named by a screen, none modelled.
- **`Station.description`** — the reference's description block has no field
  behind it; recommended as nullable, titled `Getting there`.
- **Bare `GB/T`** is not in the closed connector projection; qualified forms
  are used meanwhile.

**In scope, still fog**

- **Notifications beyond bay-watch** (station went offline, operator alerts).
- **Station media and community signal** — photos, reviews, "is it actually
  working" — adjacent to availability, with its moderation problem attached.
- **Admin moderation** of bad reports.
- **Operator onboarding** — how a real operator gets invited, verified and
  bound. First concrete shape: the 2–3 largest operators are recruited
  pre-launch (decision 18).
- **Localisation** — Kinyarwanda, French, English.
- **Data seeding beyond launch week** — stays fog while the MININFRA annex is
  held (decision 21).
- **Distribution** — store listings, Rwanda availability, and what car-platform
  approval needs in a public listing.
- **Analytics** — what the studio measures, squared against a free,
  privacy-respecting product.
- **Onboarding** — none designed; its copy is already constrained by decision 17.

---

## 13. What "built to spec" means

The guarantees below are the ones that decay silently if nobody tests them.
Each is a test, not a review item.

1. **The shared fixture corpus** (availability-display.md §3) passes — all ten
   cases, in every runtime that transcribes the derivation. Every fixture
   exists because a review round found a defect the other fixtures hid.
2. **A grep test over the emitted vocabulary** finds no forbidden string, in
   any surface, fixture or component.
3. **No availability column exists in the schema**, and **no availability field
   exists on any admin form** (§8.1).
4. **`0 of N` is unreachable** for every input, and no string asserts report
   history.
5. **A render across a decay boundary with no cache change** updates the
   screen — the decay clock is scheduled, bucketed, and re-armed on resume.
6. **The device-derived aggregate beats a materialised aggregate** when they
   disagree.
7. **`packages/domain` imports no platform module**, and both data
   implementations satisfy the protocols.
8. **The word `real-time` appears nowhere** — app, store listing, or onboarding.
9. **The chosen typeface passes the nine-metric acceptance band**, re-run
   whenever the face changes (ADR-0010).
10. **The redundancy invariant holds**: no value appears on the hero badge
    without being restated in readable form below it (ADR-0009).
11. **No disabled token exists**, and no bare touchable ships. React Native's
    `activeOpacity` and `android_ripple` deliver the forbidden opacity ramp and
    motion **by default**, so every call site goes through `PressableSurface`
    and a bare touchable fails the build (ticket 31 §12.2).
12. **The forbidden list has exactly one home** — *satisfied 2026-08-14 by
    ticket 32, and the grep is what keeps it satisfied.* The three claimed
    addresses were reduced to citations of availability-display.md §2.2b, but
    only after §2.2b absorbed the four items that lived nowhere else: the
    copies were **not** subsets of it, so collapsing them in the obvious order
    would have dropped live bans.

---

*Assembled 2026-08-14 by ticket 21. Sections 1–8 and 10–13 are locked.
Section 9 awaits tickets 27, 24 and 20.*
