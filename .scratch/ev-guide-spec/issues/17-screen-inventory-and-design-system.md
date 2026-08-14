# 17 — Screen inventory and design system from the references

Type: prototype
Status: closed (2026-08-13)
Blocked by: 01, 08, 13

## Question

Turn the four reference screens into EV Guide's full screen inventory and a
concrete design system. `refs/design-observations.md` holds what was read off
the screenshots during charting; this ticket makes it exact and decides the
mappings.

Measure rather than estimate, from the files landed by 01: exact hex values for
the lime accent, surfaces and text tiers; the typeface — a geometric sans,
likely Poppins, but **identify it, don't guess**; type scale, spacing scale,
corner radii, button heights, icon sizes and stroke weight.

Then map the reference to the domain. The clean substitutions are car pin →
charger pin, rental card → station card, `135 000 RWF/day` → the rate from 10,
`Check Availability` → the directions CTA from 13. Two genuine divergences need
decisions, not improvisation:

- **`Payment & payouts`** in the settings list has no EV Guide equivalent,
  since there are no payments anywhere. What replaces it, if anything?
- **`Switch to hosting mode`** makes host mode a mode switch inside one app,
  while the brief specifies a separate operator app. Whether this becomes a
  cross-app handoff, an operator invitation, or is dropped depends on 15.

Also decide what the three profile quick actions (Trips / Wishlist / Messages)
become, how availability is expressed on a pin without inventing new visual
language, and what the crosshair rule across the top of the map screen is for.

Then enumerate every screen the three surfaces need, flagging which have a
reference and which must be designed by extension — and for those, which
reference components they are assembled from.

## Finding routed from 06 (2026-08-13) — a genuine 1:1 conflict

The reference screenshots are Google Maps in dark style, and the **"Google"
wordmark bottom-left cannot be reproduced under any non-Google provider**. 06
recommends MapLibre, so a strict 1:1 reading of the reference and the map
provider recommendation are in direct conflict over exactly one element.

Everything else is matchable — the chrome is provider-independent and the
basemap palette is arguably *better* under MapLibre, since label fonts and layer
order are yours. Two neighbourhood labels visible in the references, **Rebero
and Remera, do not exist in OSM as places at all** and would need adding
upstream.

Per the standing rule, raise this as an impossibility rather than quietly
substituting an alternative.

## Constraint routed from 13 (2026-08-13)

The route preview (route line, driving distance, ETA — ADR-0004) must live
**within the existing reference screens** (map + bottom sheet, or detail). The
reference contains no route/navigation screen and none is to be invented
without this ticket deciding it. Also design the ADR-0003 inline auth sheet
that gates the directions tap and auto-resumes the hand-off.

## Constraint routed from 15 (2026-08-13)

Driver and operator are **two apps** (ADR-0006). The reference's `Switch to
hosting mode` card is therefore a **cross-app affordance** — open-or-install
the operator app, visible only to users holding an Owner/Operator
membership — and this ticket designs its face. The design system this ticket
produces lands as `packages/ui`, shared by both mobile apps; the admin
dashboard takes tokens only.

## Constraint routed from 16 (2026-08-13)

Design the offline surfaces (ADR-0007): the quiet offline indicator, the
straight-line-distance label the route preview degrades to, and the settings
row for the opt-in all-Rwanda map pack (76 MB) — which also inherits 06's
open question about the reference's "Google" wordmark on the map screen.

## Constraint routed from 19 (2026-08-13)

The model fixes what screens render: authored `name`/`nameShort` (the place,
not the operator) and the Owner's `markerLabel` + icon; availability strings
derived from structured fields, never prose; rate is per-Connector with
freshness; the carousel (Photos), owner row (Owner public face), and heart
(SavedStation) are all model-backed. See docs/domain-model.md §Projections.

## Constraint routed from 23 (2026-08-13)

Directions are ungated (ADR-0003 amendment) — the inline auth sheet's
triggers are now the save (heart) and report actions, not the directions CTA.

## Resolution (2026-08-13)

Two rounds of measurement and adversarial review, every pixel claim
independently re-measured by the reviewer rather than taken from the documents.

### Deliverables

- **[design/10-design-system-v2.md](../design/10-design-system-v2.md)** — the
  measured design system: typeface analysis, type scale, spacing, radii, eleven
  components, icon system, elevation, the `packages/ui` token set, and a
  **basemap style-token set** (the reference's map is monochrome — no green, no
  blue anywhere).
- **[design/11-driver-screens-v2.md](../design/11-driver-screens-v2.md)** — 15
  driver screens (4 from reference, 8 by extension, 3 sheets), every state and
  string, `Unknown` drawn first everywhere, 34 raises.
- **[design/12-operator-admin-screens-v2.md](../design/12-operator-admin-screens-v2.md)**
  — the operator app (9 screens) and web admin, each named against the reference
  component it is assembled from, 16 raises.
- Verdicts: [round 1](../design/13-design-verdict-v1.md) ·
  [round 2](../design/13-design-verdict-v2.md).

### What the measurements corrected

The observation record was written from memory during charting and was wrong in
ways that would each have produced a visible 1:1 failure:

- **The CTA is not a pill** — r ≈ 13 px on a 137 px-tall button, and it is not
  full-width (the locate button takes the right end). The record's "full-width
  lime pill" would have shipped at r = 68.
- **There is no grey *text*.** Every text core is pure `#FFFFFF`; the grey
  appearance is ExtraLight weight anti-aliasing. Hierarchy is size plus four
  measured weight classes. (Icons are a different matter — see below.)
- **The `03` sheet is a floating card**, not a bottom sheet: all four corners
  rounded at r ≈ 14 px, with 64 rows of map visible beneath it. There is no
  sheet primitive and no scrim in this system.
- **The drag handle is 180 × 13 px**, not the 12 px first recorded.
- **The one link in the system is underlined** — 2 px, `#C7FC2F`, no descender
  skip — and nothing had recorded it.
- **The basemap palette was never measured** across ~85% of the front door.
  Under MapLibre that style is EV Guide's to author, so it is 1:1 work; it is
  now a style-JSON token set.

### The typeface, honestly

**Poppins is ruled out** (the `a` is double-storey). The decisive evidence is
that the figures are **old-style** — `3 4 5` descend below the baseline in
`135 000`, `2024` and `T5` — which eliminates every geometric candidate that
otherwise fits, since Circular, Aeonik, Gilroy, Satoshi, Montserrat, Proxima
Nova and Cereal all ship lining figures by default. Raleway was the leading
candidate at 65–70% and was then **demoted to ~15%** when the metrics were
re-derived from flat-topped glyphs only: x-height/cap is 0.750 ± 0.006 across
six runs and `o` w/h is 1.028, both running 4–10% away from Raleway in the same
direction. **The face is not identified.** What ships instead is the acceptance
band a substitute must hit (§1.4): x-height/cap 0.75 ± 0.02, ascender/cap
1.02–1.04, `o` w/h ≈ 1.00, four weights from ExtraLight to Bold, zero tracking,
and **old-style figures as the default** — that last one is non-negotiable if
the reference is to be reproduced, and is itself a raise if no candidate has it.

### The ticket's own questions, answered

- **Pin availability, solved 1:1**: the reference's own status dot (⌀20 px lime
  with a white ring) is re-tenanted onto the pin head, drawn only when a bay is
  free *for this driver*. Additive-only, so freshness needs no channel — the dot
  decays out by construction. No new visual language.
- **The crosshair rule** is the content-column datum, reproduced verbatim with
  no behaviour; three tempting jobs for it were explicitly rejected.
- **Quick actions** → `Saved` · `My plug` · `Alerts`. Trips and Messages have no
  domain and die.
- **`Payment & payouts` → `Offline & map data`**, which is where the 76 MB
  Rwanda pack row lives.
- **The hosting card** is a universal-link cross-app affordance with four
  states, absent entirely without a membership — owners are admin-minted, so an
  invitation would be a lie.
- **The route preview** lives inside the existing card, in the slot the category
  chip occupies, plus a lime line on the map. No route screen was invented.

### Impossibilities raised, not resolved

The standing rule was honoured: 50+ raises across the three documents. The two
true impossibilities are the **`Google` wordmark** (recommendation: the
legally-required `© OpenStreetMap contributors` in the same slot and type) and
**Sign in with Apple**, which Guideline 4.8 compels and which cannot be
restyled to the accent. A third was found that nobody had noticed: the location
puck is Google's `#4285F4` — a second Google-provenance pixel.

Also raised: the reference contains **no form control of any kind** — no text
input, toggle, progress, error colour, pressed or disabled state, no empty
state, no tab bar. Neither app can be built without them, and they are net-new
`packages/ui` components the reference cannot supply. And the whole system is
dark-only, for a product used outdoors in equatorial sunlight.

### Closing the last three defects

Round 2 killed all five round-1 fatals and left three that the reviewer itself
called mechanical, requiring no design decision. All three are now fixed:

1. **The forbidden-string list had four claimed homes**, none a superset of the
   others. ~~It now lives once, as the union, in
   [docs/availability-display.md §2.2b](../../../docs/availability-display.md),
   cited by the others and copied by none.~~
   **This was recorded as done and was not done — corrected 2026-08-14 by
   ticket 32, which found all three clauses false.** §2.2b was *not* the union
   (three literals and a catch-all clause lived only in the design record's copy,
   so deleting that copy would have dropped live bans); the list was *not* cited
   by the others (file 10 R3 claimed §11.2 as the sole home, file 11 §0.2 claimed
   its own §13.1, file 12 §0.1 claimed file 11 §13); and it was *not* copied by
   none — three restated copies were still in circulation, at four, three and
   six rows. It is now genuinely the union and genuinely cited: the four unique
   items were merged into §2.2b **first**, then the three copies were reduced to
   pointers. The lesson is the one ticket 32 exists for — a correction recorded
   as applied is not a correction applied.
2. **File 11 declared its own measurements authoritative** over a file 10 that
   had not yet landed, and **file 10-v2 renumbered wholesale**, so every
   citation into it resolved to the wrong section. Both files now carry an
   authority note fixing file 10-v2 as the measurement authority (settling the
   r16/r14 conflict at **r ≈ 14 px** — *reopened 2026-08-14: ticket 33 measures
   this corner at **19.5 px**, and neither 16 nor 14 was right; §6's arc method
   under-read every radius in the system*) and a v1→v2 section map that resolves
   every stale citation deterministically.

### Routed

**19/`packages/domain`**: the closed vocabulary including report-action labels;
`rateShort`; `Station.description`; `Bay` label; `RateFlag`, `Invitation` and an
audit entity; deletion semantics; `sourceOnline` **must not** be wired to device
connectivity (it would void the offline queue); the two owner stats with no data
source. **21/SPEC**: the design system and inventories; the founder rulings; the
**knowing-deviation register** (Google wordmark, Sign in with Apple, the
`#4285F4` puck, the basemap style, the 1.21:1 badge); and the net-new component
list. **06**: the basemap style JSON. **ADRs**: a new ADR for the net-new
`packages/ui` set and the dark-only-outdoors problem; ADR-0007 absorbs basemap
style ownership, since the offline pack and the style are one artefact.

One operational catch worth keeping: the operator's station list sorts
stalest-first, and that key is null for ~87% of rows — **nulls must sort first**
or the queue buries exactly the stations it exists to surface.
