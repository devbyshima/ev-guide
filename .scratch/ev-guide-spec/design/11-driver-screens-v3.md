# Driver screens, v3: the charger-finder redesign

Supersedes [`11-driver-screens-v2.md`](11-driver-screens-v2.md) for the driver
app, under [ADR-0013](../../../docs/adr/0013-charger-finder-redesign.md).

**v2 remains the citation of record for every measured value.** Nothing measured
changes here. Every surface below is composed from geometry v2 already
established: the secondary-control box, primary-CTA geometry, the settings row,
the floating card, the feature and category chips, the drag handle, and the
trailing accent check. Where a value is a derivation rather than a measurement,
it is marked and listed in §4.

The design system is unchanged: `#121212` page, `#212121` map canvas, `#393939`
surface, `#3E3E3E` raised, one accent `#C7FC2F` with no tints, `#FFFFFF` as the
only text colour. The redesign introduces exactly **two** styling deviations,
both founder calls of 2026-08-20 and both recorded in ADR-0013: the hero badge
label (decision 2) and the accent budget (decision 7).

## 1. The screen set

| Screen | Status | Note |
| --- | --- | --- |
| **D-01 Map home** | reworked | gains a search field, and only that |
| **D-02 Map + station sheet** | reworked | detented; gains a connector line and `Directions` |
| **D-13 Nearby chargers** | **promoted** | v2's second detent becomes the sheet's default, and carries the chip row |
| **D-03 Station detail** | reworked | `Update status` becomes first-class |
| D-09 My plug | kept | the selection now also orders D-13 |
| D-04 Profile | kept | |
| D-05 Personal Information | kept | |
| D-06 Login & Security | kept | |
| D-07 Offline & map data | kept | |
| D-08 Notifications | kept | |
| D-10 About EV Guide | kept | |
| D-11 Saved | kept | |
| D-12 Alerts | kept | car-effort package |
| S-01 Auth sheet | kept | |
| S-02 Report sheet | kept | reached far more often now |
| S-03 Overflow menu | kept | |

**No screen is added and none is dropped.** An earlier draft of this file
carried an `S-04 Filters` sheet; ADR-0013 decision 8 withdrew it before it was
built, because every block in it was a hiding dimension. See §3.

Navigation is unchanged: no tab bar, full-screen surfaces reached by a push
(back) or a presentation (close), plus one floating avatar.

## 2. The reworked screens

### D-01 Map home

**D-01 changes less than any other screen in the redesign.** Its only addition
is the search field; every measured element keeps its measured position,
including the map avatar at `x64, y362`, which an earlier draft had displaced to
make room for a chip row that no longer sits here.

Top to bottom, in the reference's own content column `x64` to `x1141`:

1. **Crosshair rule**, verbatim from v2: 2 px `#FFFFFF` at `y249-250`. Still
   static, still no behaviour. v2 explicitly rejects reading it as a "search
   this area" control, and **that rejection becomes more load-bearing now that a
   real search field sits beneath it.** The two must not fuse.
2. **Search field (new).** The secondary-control box exactly as SPEC §5 fixes
   it: `color.surface`, `size.ctaHeight` 137.25 px, `radius.button` 16.5 px,
   `space.chipPaddingH` 30 px inset. Leading magnifier glyph at 24 pt / 2 pt
   stroke. **No placeholder**: `19-form-controls-v2.md` §7.1 rules placeholders
   unimplementable product-wide, because one needs a dimmed text tier and
   `#FFFFFF` is the only text colour, so a placeholder would be indistinguishable
   from a value. The glyph identifies the box, not text.
3. **Map avatar** 128.6 px `#FFFFFF` at its measured position. No status dot:
   that component is spent on the pin.
4. **Offline chip**, right-aligned on the avatar's line, feature chip geometry.
   Additive, never an error surface.
5. **Map canvas** `#212121`, pins 122.30 × 147.25 px with the lime 2 px rim and
   one uniform charger glyph. Free-bay dot 20.4 px at `(+54, -54)`, tangent to
   the rim, drawn only when `freeBaysOffering(T) > 0`. No clustering. No
   selected-pin treatment: the sheet plus a map recentre is the feedback. **No
   pin ever disappears** (decision 8).
6. **Location puck**, disc 39.6 / ring 4.0 / halo 82.0 / cone 16 × 19, redrawn
   `#FFFFFF` + `#C7FC2F` (ADR-0009 deviation 2).
7. **Attribution mark** bottom-left, tapping through to D-10 (ADR-0009
   deviation 1).
8. **CTA row, unmoved**: primary CTA 898.00 × 137.25 px at `x64` to `x962`,
   40.16 px gap, locate button 137.7 px. Relabelled `Nearby chargers`; it raises
   the sheet to the list detent.

Reads: `stationsNear(origin, limit)` where **origin is the viewport centre**,
never a hardcoded device location; `freeBaysOffering(T)` for the dot;
`nextDecayDeadline()` bucketed inside one minute; `changedSince(cursor)`.

### D-02 Map + station sheet

The floating card gains detents and keeps every measured property. **Its bottom
edge never moves**; it grows upward, so the 64 px
`space.floatingCardBottomGap` and the CTA row survive at every detent.

Contents: drag handle 180.00 × 12.75 px; thumbnail `Photo[0]` at 297.5 px,
`radius.image` 31.8 px; `nameShort` at cap 36 Bold; the availability clause from
`G()` under the lens, **Regime 1 first** (`4 bays · no confirmed status` is the
primary rendering, not the fallback); the **connector line (new)**, carrying the
closed type-word projection plus peak power (`GB/T DC · Type 2 · 60 kW`) and no
availability word; the route chip as a re-tenanted category chip, a label and
not a control, degrading to a labelled straight line offline; `rateShort`
right-aligned, never presenting a per-connector rate as the station's; and the
heart, gated with auto-resume.

**While a station is selected the map CTA re-tenants to `Directions`**, ungated,
deep-linked to Google Maps by `lat,lng`. Drag-up on a selected card opens D-03.

### D-13 Nearby chargers (promoted, not invented)

**v2 already specifies this list.** It exists as D-02's *second* detent, reached
by tapping the CTA, holding repeated station cards in the card's own inner box,
and v2 is explicit that it is a detent and not a screen. Both its properties are
unmeasured (RAISE-D10).

Two changes. It becomes the sheet's **default content** when no station is
selected, rather than something reached by tapping a CTA whose own post-open
behaviour was undefined, which resolves RAISE-D10(b). And it carries the
**connector chip row**, because this is the only surface where a reordering
control has a visible effect (§3).

1. **Connector chip row.** Horizontally scrolling, `space.chipGap` 27 px.
   Members are **controls at primary-CTA geometry** (137.25 px, `radius.button`
   16.5 px), not feature chips (35.16 pt) or category chips (25.58 pt), both of
   which sit under both platform tap floors. Unselected `color.surface` +
   `#FFFFFF`; selected `color.accent` + `color.onAccent` Medium. Members:
   `Type 2`, `CCS2`, `GB/T AC`, `GB/T DC`, and `Other plug` when the directory
   contains one. **The row reorders and marks. It never hides.**
   **Its selection is the D-09 lens, and it holds no persisted state of its
   own.** The row is constructed from the lens every time D-13 is built, so
   exploring another plug type lasts only as long as the driver stays in that
   list and never becomes a setting to remember to undo. With `My plug` unset
   the row opens with nothing selected and the list is plain distance order,
   which is correct rather than degraded. Seeding from the lens is also the
   redesign's answer to `My plug`'s discoverability: the setting becomes visible
   as state on the first screenful rather than staying buried behind an
   unlabelled avatar.
2. **Header line**, cap 27 Regular: the count and the ordering. `19 chargers ·
   nearest first`, or with chips selected, `19 chargers · Type 2 and CCS2
   first`. **The count never changes**, which is the point: it states ordering,
   never scope, and it states **connector scope only, never report scope**. No
   string here may assert that a report exists, does not exist, or is old.
3. **Rows** at the card's inner box 948 px, separated by **1 px** `#3E3E3E`
   dividers (note: there is no divider-thickness token yet, and `space.hairline`
   is 2 px and belongs to a different object, so reaching for it silently
   doubles every divider and still passes every test). Each row carries D-02's
   composition minus the route chip, since a Valhalla call per row for a screen
   being browsed rather than acted on is not worth it. A row whose station takes
   none of the selected plugs is **marked, not removed**, using the lens grammar
   that already exists: `No GB/T DC bay here · 4 bays · Type 2, CCS2`.
4. **No empty state.** Under decision 8 nothing is ever excluded, so the
   excluded-everything state an earlier draft specified cannot occur and is not
   built. A genuinely empty result remains possible only for search, which keeps
   its own no-match line.
5. **Search results** replace the rows in place when the D-01 field carries a
   value. Focusing the field raises the sheet to its full detent.

**The list is unbounded on the phone.** `stationsNear` is specified as bounded
(design for 6, cap at 12), and under a reordering model a bound is hiding by the
back door: anything pushed past it vanishes. The directory's size makes the
removal cheap at 17 to 19 sites nationally. **The car surfaces keep their
bounds**, because a car list has a platform limit that is not EV Guide's to
choose, and there the reorder is exactly what makes the bound land on the right
stations.

### D-03 Station detail

Composition and geometry untouched. The hero badge carries **peak power or is
absent**, never an availability word, now drawn at `color.onAccent` per
ADR-0013 decision 2 and still under the redundancy invariant.

The change is that **reporting becomes first-class**. A new `Update status`
control sits directly under the connector rows at primary-CTA geometry in
`#393939`, opening S-02 through a connector picker when the station carries more
than one type. Away from the station the control is **replaced in place** by
body copy (`Report status when you're at the station`), because the slot always
says something, nothing disappears, and there is no disabled state. Signed out
goes to S-01 with auto-resume.

Ordering is already verdict-first in the research's sense, and it already does
the thing every surveyed app fails at: **it timestamps the claim and names its
source** (`Operator, 14 min ago · 2 of 4 bays free`). Per-connector rows carry
state so a known-broken gun is visible to a driver with no plug profile. The
rate ladder stays denominated in **plugs, never bays**.

### D-09 My plug (unchanged)

**No control on this screen changes, and no copy is added.** An earlier draft
split the selection into a mandatory lens and an optional hiding filter, and
required new copy to explain the two mechanisms. ADR-0013 decision 8 removed the
second mechanism, so there is one job and the screen already describes it.

What grows quietly is the selection's reach: it lenses what `free` means
everywhere, and it now also **seeds D-13's chip row**. Neither is a hiding
behaviour, and the lens still cannot be turned off.

## 3. The IA questions, and both sides

Recorded because ADR-0013 removed the mechanical tiebreak, so these were
judgements rather than measurements.

**Nothing hides: the settled answer, and the one that reshaped this file.**
ADR-0013 decision 8. The consequence chain is worth keeping visible, because
three separate things fell out of one call. **S-04 was withdrawn**, since every
block in it was a hiding dimension and each collapsed on inspection: the plugs
multi-select was always a duplicate of D-09's lens, `Speed` and `Network` become
at most sort keys that one chip row already expresses, `Saved only` hides and
D-11 is already its home, and `Clear filters` has nothing to clear. **D-13's
empty state disappeared**, because nothing can be excluded. And **`My plug`'s
filter half was never built**, so D-09 returns to unchanged.

**The chip row moved off the map, and this is the non-obvious part.** A chip
that reorders acts on a list, and **a map has no order**. Expressing a chip on
D-01 would need a second additive mark on the pin, which is unavailable three
times over: the pin's one additive channel is spent on the free-bay dot, a
second mark collides with that dot's tangency solution at `d >= 75.75`, and
ADR-0002 forbids marking `Unknown` at roughly 87% Unknown. A chip row over the
map would have been a control with no visible effect on its own screen. It sits
at the top of D-13 instead, which is where the category puts a sort control.

**Tab bar: no.** See ADR-0013 decision 6. The counter-argument is real and is
not dismissed: a tab bar is a learned affordance that tells a first-time user in
one glance that a Saved list and a Profile exist, where an unlabelled circular
avatar over a dark map tells them nothing. Discoverability of D-11 is genuinely
poor. D-09's is materially improved by the chip row's seeded selection, which is
one worry retired.

**Search field: ship it.** The component was already owed by S-01 and D-05, the
placeholder problem is answered by the glyph rather than dodged, and the data
cost is near zero because the directory is tens of stations and ships in the
binary. Three costs survive and are stated rather than argued away: a new
protocol method, a keyboard-avoidance behaviour on a screen that needed none,
and the caret-colour call becoming urgent. There is an honest case for shipping
no field at all, since at 19 stations D-13's rows answer the same question.

**List: yes, as the sheet's default.** A drag costs no new control class,
whereas a map/list toggle would be the product's first segmented control. The
cost is that detents are invisible until discovered, and that the same gesture
has two destinations depending on whether a station is selected (more list, or
D-03). That is what Apple Maps and Google Maps do, so it is learnable, but it is
not derivable from anything measured.

**The accent budget: selected chips are lime.** ADR-0013 decision 7. Two
boundaries travel with it and this file is bound by both: the accent gains **no
new role** (it still means selected, the CTA, the pin rim, the free-bay dot and
the link), and **S-01's ruling is untouched**, so two of its three provider
buttons stay `#393939`. Note the exposure shrank after the fact: the budget
argument was about lime sitting over the map competing with pin rims, and the
row now sits on `color.page` inside the sheet where no pin competes.

**D-02: draggable, not a sheet.** What the category treats as universal is the
**gesture**, not the anchoring, and the gesture can be had without the
anchoring. This also fixes a documented category anti-pattern, the preview that
blocks the map and is hard to dismiss, because a detented card with a handle has
an obvious dismissal that a fixed card does not.

## 4. Unmeasured values needing a founder yes

Both blocking calls are answered. **B1** (may a filter hide?) is answered no, as
ADR-0013 decision 8. **B2** (the accent budget) is answered accept, as decision
7. Neither is open. What remains does not block:

1. The three detent heights (peek, mid, full). RAISE-D10 records the list detent
   as unmeasured.
2. Glyph-for-tier on the pin (AC against DC), which deviates from RAISE-D3 and
   additionally needs a station-scope projection that does not exist, since
   power is a Connector property.
3. The re-tenanted CTA, an invented behaviour with no instance in the reference.
4. Caret, selection and focus appearance, all four of which (with placeholder)
   `19-form-controls-v2.md` records as absent with nothing to inherit.
5. The **magnifier glyph as a fourth answer to F18**, which offers only accept
   the mute field, a 2 px border, or a focus treatment that does not answer it.
   A leading glyph inside the box is not in that set.
6. A `search` method on `StationRepository`, which is the "new decision"
   `19-form-controls-v2.md` §1.5 said would be needed.
7. A first-run plug picker, deferred to launch-week evidence.
8. A tab bar, on the same evidence.

## 5. Deliberately not built

Full list and reasoning in ADR-0013. In short: **no filtering that hides
anything**, no reliability score, no check-in feed or ratings or driver photos,
no community-added stations, no journey planning, no in-app navigation, no
nav-app chooser, no availability-coloured pins, no `Available now` chip, no
`Open now` or amenity or access-class or price filters, no clustering, no
segmented control, and no update-cycle claim.

**The `Report` is EV Guide's check-in-with-outcome**, and D-03's new
`Update status` control is what finally gives it a front door.
