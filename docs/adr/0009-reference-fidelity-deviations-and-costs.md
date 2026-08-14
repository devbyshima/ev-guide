# ADR-0009 — Reference fidelity: two knowing deviations, two costs carried

Date: 2026-08-14 · Status: accepted · Founder calls from SPEC.md §12

## Context

EV Guide's standing rule is that the four reference screenshots in `refs/` are
implemented **1:1, with no deliberate deviations**; impossibilities are raised
before alternatives are built, never improved around. Tickets 17 and 18 measured
the references and raised 50+ items against that rule.

Four of them could not be resolved by measurement, because each is a case where
reproducing the reference exactly is either impossible, unlawful, or harmful.
They were carried openly in SPEC.md §12 until the founder ruled on them
(2026-08-14). This ADR records all four in one place, because a future reader
who notices any one of them will ask the same question: *was this an accident?*

It was not. Two are deviations. Two are costs the product carries in order
**not** to deviate.

## Decision

### 1. The `Google` wordmark is replaced by the OSM attribution — a deviation

The wordmark measures 159 × 50 px at x73–232, y2256–2306 on `01`. Under
MapLibre with self-hosted tiles (ticket 06, hardened by ticket 26) that pixel
cannot be reproduced under any circumstance — the only provably impossible
element in the four screens.

The slot carries **`© OpenStreetMap contributors`** instead: same position, the
reference's own type treatment (cap 27 Regular `#FFFFFF`), tapping through to
D-10. The word differs; the slot, its position, its treatment and its role all
survive.

### 2. The location puck is redrawn off Google's blue — a deviation

The puck samples `#4285F4` at x583–642, y1291–1331 on `01` — Google's brand
blue, drawn by the Google Maps SDK's own location UI. Under MapLibre the puck is
ours to draw. It is redrawn at the **measured geometry** (40 px disc, 82 px
halo) in **`#FFFFFF` with a `#C7FC2F` core**, using only existing tokens.

### 3. The hero badge is reproduced at 1.21:1 — a cost, not a deviation

The badge label is `#FFFFFF` on `#C7FC2F` at **1.21 : 1** — the least readable
surface in the product by a factor of ten. It is reproduced exactly as measured,
under a **redundancy invariant enforced as a test**: any value shown on the
badge must be restated in readable form below it. The badge carries peak power
(`60 kW`) or is absent, and **no availability word may ever appear there**
(availability-display.md §2.2b).

### 4. The operator app ships dark-only — a cost, not a deviation

The whole system is `#121212`/`#212121`/`#393939` with no elevation and no
alternate surface, and the operator's core task (O4, updating availability) is
performed standing at a charger in equatorial daylight. **No light theme, no
contrast mode, no brightness override ships in v1.** The one mitigation the
measured palette permits is already applied: every derived data line uses
Regular rather than ExtraLight at `type.body`.

## Rationale

**Attribution is a licence obligation, not a design choice**, so the wordmark
slot must carry *something* — which makes emptying it (option b) the weaker
deviation, not the smaller one. Keeping Google Maps to preserve the pixel
(option c) contradicts ADR-0007's offline requirement (Google's ToS forbids the
tile caching), contradicts ticket 26's rule, and runs into a ToS clause barring
use "in a listings or directory service" — EV Guide's own one-line description.

**The puck is a brand colour EV Guide has no right to use**, and reproducing it
inside a map that is no longer Google's is the weakest legal position available
while also being the strictest reading of 1:1. The two rules point in opposite
directions here; the licence wins.

**The badge is reproduced because the redundancy invariant makes its
illegibility harmless.** Recolouring the label to `color.onAccent` would take it
to ~14:1, and would be a visible break of 1:1 on a component appearing on every
station detail screen — paying a permanent fidelity cost to fix a problem a test
can neutralise. This is also why R2 exists: an accent chip reading `no confirmed
status` on ~87% of stations would be both an apology ADR-0002 forbids *and* an
apology nobody can read.

**The daylight problem is real and is not solvable inside the measured
palette.** It is ruled this way because the alternatives all invent a surface
the reference does not contain — a second palette to keep in step with
`packages/ui` forever, or a state with no measured source — on a hunch. The
**launch-week survey pass** (ticket 28) puts studio staff at real chargers using
O4 in real sunlight. That is the evidence a light theme should be commissioned
on.

## Consequences

- `packages/ui` ships the puck and the attribution mark as EV Guide components;
  neither has a reference pixel to check against, and both are exempt from the
  1:1 acceptance test by name.
- **Two OSM data gaps travel with the attribution decision**: the neighbourhood
  labels `Rebero` and `Remera`, visible in the reference, **do not exist in OSM
  as places** and must be added upstream before the basemap can reproduce the
  reference's own label set.
- The redundancy invariant is a test in `packages/ui`, not a review item. Adding
  a value to the badge without restating it below is a failing build.
- Dark-only is **revisitable on evidence, and only on evidence**. If launch-week
  operators cannot read O4 in sunlight, a light theme is a commissioned design
  pass with its own premise — not a token swap.
- Every other raise in tickets 17 and 18 stands resolved by measurement. These
  four are the complete list of places where the 1:1 rule did not decide the
  outcome by itself.

## Alternatives considered

Recorded above per item: emptying the wordmark slot; keeping Google Maps;
reproducing `#4285F4`; a white-only puck; recolouring the badge label; dropping
the badge label; a commissioned light theme; an operator-only high-contrast
mode; and a max-brightness override on O4. Each was rejected for the reason
given in the rationale.
