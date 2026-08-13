# 18 — What does EV Guide look like on a car screen?

Type: prototype
Status: closed (2026-08-13)
Blocked by: 04, 09, 13

## Question

Design the CarPlay and Android Auto experiences concretely enough that the
entitlement applications in 20 can show them and the data model in 19 can serve
them.

The reference designs are irrelevant here and must not be forced: car screens
are assembled from Apple's and Google's fixed template sets, and EV Guide's
visual identity barely appears. Establish what the driver can actually do —
almost certainly a nearby-stations list sorted by distance, a station detail
with rate, connectors and availability, and a directions hand-off consistent
with 13.

Settle: which templates each platform's charging category permits and which EV
Guide uses; how per-connector availability from 09 is expressed in a list row
with severe text limits; how "free for me" works when the car screen may not
know the driver's connector; what happens when availability is unknown or
stale, which will be common; the no-account case from 12; voice and safety
constraints on interaction while driving; and what data must be resident on the
device because the car screen cannot wait on a slow network.

Feed anything this forces back into 19 before the schema locks.

## Constraint routed from 19 (2026-08-13)

The car surface renders from the fixed projections in docs/domain-model.md
(one-line, two-line, picker-triple, card-triple), from an on-device cache at
a locked-phone-readable protection class, containing only non-sensitive
directory + availability data. Marker = Owner icon + ≤3-char markerLabel.
Rate never appears on a row; availability never in a title.

## Constraint routed from 23 (2026-08-13)

The template design must show the three bar-clearing functions: ranked
nearby stations with availability + freshness, **anonymous** one-tap
directions (ADR-0003 as amended — no sign-in wall anywhere on the car
screen), and the bay-watch arm/disarm affordance (ticket 30). These are what
the 20 submissions will demonstrate.

## Constraint routed from 30 (2026-08-13)

Bay-watch specifics for the template design: arm/disarm lives on the station
detail template, label "Notify me when a bay frees up", with an armed-state
row; visible to signed-in users only; the notification deep-links back to
the station detail. One-shot, 2h expiry — no management UI beyond disarm.

## Resolution (2026-08-13)

**Both car surfaces are designed, adversarially reviewed three times, and the
shared function they both needed is now written down once.**

### The design

- **CarPlay** — [design/01-carplay-design-v3.md](../design/01-carplay-design-v3.md)
  (1,629 lines). Five template classes; tabs Map / Nearby / Saved; a
  four-station worked corpus with exact strings in every slot; a **structural**
  depth proof (max 3 of 5, a property of the graph rather than a runtime
  assertion).
- **Android Auto** — [design/02-androidauto-design-v3.md](../design/02-androidauto-design-v3.md)
  (1,238 lines). `PlaceListMapTemplate` + `PaneTemplate` + `MessageTemplate`
  under the POI category; **Invariant A**: no row or action *count* varies with
  availability, freshness or watch state — only with facts latched for the
  screen's life. The 5-template quota proof models a disarm and peaks at 4/5.
- **Constraint sheet** — [design/00-constraint-sheet.md](../design/00-constraint-sheet.md),
  every platform rule marked `[hard]` / `[inferred]` / `[runtime]`.
- Verdicts: [v1 CarPlay](../design/03-carplay-verdict-v1.md) ·
  [v1 Android](../design/04-androidauto-verdict-v1.md) ·
  [v2 CarPlay](../design/05-carplay-verdict-v2.md) ·
  [cross-surface](../design/06-crosssurface-verdict-v1.md).

### The answers ticket 18 asked for

- **Templates**: no forbidden template is referenced on either surface (on
  CarPlay a forbidden template is a *runtime exception*, not a rejection).
  Every documented cap respected: ≤12 POIs, two POI card buttons, ≤3
  Information items, ≤5 tabs, 3-char `markerLabel`, the 6-row place-list floor.
- **Per-connector availability in a row**: expressed through the shared
  grammar's three regimes — never prose, never in a row *title* (a title change
  costs an Android quota step).
- **"Free for me"**: `bayStateUnder(bay, T?, now)` — see below. When the car
  does not know the driver's connector, the unlensed aggregate is shown and
  per-Connector state stays reachable in the detail so a broken gun is visible.
- **Unknown/stale**: the majority case, and never an error — Regime 1 emits a
  capacity clause with no state word at all.
- **No account case**: no sign-in wall exists anywhere on either car surface;
  `Directions` is unconditional for every driver; gated affordances are
  silently omitted rather than explained.
- **Safety**: search is never the primary path; browse-by-proximity is; no
  voice in v1.
- **On-device**: raw per-Connector reports at a locked-phone-readable
  protection class, zero network on the paint path, no screen designed around
  a spinner.

### What the review found, and why it was worth three rounds

Every fatal defect was **a claim in one section disproved by a table in
another** — never a broken rule read wrongly. Four were caught and killed:

1. A row whose *presence* varied with availability would have consumed
   Android's template quota on the very event the surface exists to deliver,
   and **closed the app on a driver mid-drive**.
2. The availability grammar had no clause for mixed known-plus-Unknown — the
   steady state — so it rendered `All 4 bays busy` over bays nobody had
   reported, and folded `OutOfService` into "busy".
3. The lens told a GB/T driver a bay was free while EV Guide held a report
   saying that plug was broken.
4. The directions ladder claimed a car-display hand-off that **no available
   API can observe** — ADR-0004 had already forbidden assuming it.

The cross-surface pass then found the mirror of (3) — `OutOfService` folding
into `Occupied` *under a lens*, i.e. sending a driver to wait at a broken gun —
and the deepest finding of all: **decay runs at render, but nothing was
triggering a render when a decay boundary passed**, so a screen left open kept
painting a stale `Free` indefinitely. That one is a product-wide correction,
not a car one.

### What was produced beyond the designs

- **[docs/availability-display.md](../../../docs/availability-display.md)** —
  the single derivation + grammar spec, owned by neither surface, executed by
  four runtimes, with the laws as required tests and a 10-case shared fixture
  corpus. Written because the two designs had independently specified
  *different* functions and would have handed the schema two incompatible
  specifications of one thing.
- **ADR amendments**: [0008](../../../docs/adr/0008-availability-derived-bay-propagation.md)
  (the decay clock; brokenness does not propagate; four runtimes),
  [0004](../../../docs/adr/0004-directions-preview-and-handoff.md) (the CarPlay
  ladder, the default-off flag, ETA forbidden on car),
  [0007](../../../docs/adr/0007-offline-model.md) (per-surface straight-line
  labelling; no car offline indicator).
- **Eight schema items** added to
  [docs/domain-model.md](../../../docs/domain-model.md), including the car
  cache contract and the car's non-directory field list — a security decision,
  not a derivation.

### Routed

27 (four device tests, three **blocking**) · 20 (three hard submission
dependencies) · 30 (the notification-permission gate and the on-device max-3) ·
15 (`android:process=":car"`) · 12 (the vehicle-profile ruling — recorded as
device-local, **flagged for founder ratification**).

### Residual

The two v3 designs still carry the cross-surface pass's twelve majors as
document-level edits (mostly citation repointing and two string replacements).
They do not change any decision and are **build-effort cleanups**: the shared
spec above is now authoritative wherever a design disagrees with it.
