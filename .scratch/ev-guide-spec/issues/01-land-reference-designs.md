# 01 — Land the reference designs on disk

Type: task
Status: closed (2026-08-13)
Blocked by: —

## Question

Nothing to decide. The four reference screenshots were shared in conversation
during charting and have been described in `refs/design-observations.md`, but
the **image files themselves are not on disk**. Under the 1:1 rule the
implementation effort needs the actual pixels — for colour sampling, spacing
measurement, and font identification — not a written description of them.

Done when `refs/01.png` … `refs/04.png` exist, in the order originally shared:

1. Map home with pins and the `Let's find a car` CTA
2. Profile with the hosting-mode card and settings list
3. Map with the Forthing T5 bottom sheet
4. Forthing T5 detail screen

Record in the answer anything the stills couldn't show — an interaction, a
transition, the purpose of the crosshair rule across the top of the map screen.

## Resolution (2026-08-13)

The four screenshots are on disk as `refs/01.png` … `refs/04.png`, in the
order this ticket specified — verified by looking at each rather than trusting
filename order:

1. `01.png` — map home, seven car pins, `Let's find a car` CTA
2. `02.png` — profile: avatar, Trips/Wishlist/Messages, hosting-mode card, Settings
3. `03.png` — map with the Forthing T5 bottom sheet
4. `04.png` — Forthing T5 detail

Captured at **1206 × 2622 px = iPhone 16 Pro @3x (402 × 874 pt)**; divide by 3
for point measurements.

### What the pixels corrected

`refs/design-observations.md` had been written from memory of the screens and
its palette was **wrong in three of five rows** — most importantly the
background, recorded as pure black when it is `#121212` (true black is 0.34%
of screen 01), and the card surface, recorded as `#1A1A1A` when it is
`#393939`. The accent is exactly **`#C7FC2F`**, identical in all four screens
with no tints or gradients. The table is now measured, not eyeballed. Under
the 1:1 rule this mattered: 17 would have built the entire design system on
three wrong values.

### What the stills still cannot show

- **The crosshair rule.** Now visible in detail: a hairline white rule spanning
  the full width just below the status bar, terminated by a `+` cross at each
  end, present on **both** map screens (`01`, `03`) and on neither of the
  others. It sits above all map content and is unaffected by the bottom sheet.
  It reads as a viewfinder/registration-mark motif — decoration, not a
  control — but a still cannot prove it isn't a drag affordance or a
  reveal handle. **A decision for 17**, not something to improvise.
- **Every transition**: how the sheet in `03` enters, whether tapping a pin
  animates the map, whether `04` is a push or a sheet expansion.
- **The hero carousel's behaviour** — `04` shows a lime elongated indicator
  plus three grey dots, so there are four images, but not how they advance.
- Pressed, disabled, loading and empty states for every control.

### One thing the stills settled that was previously open

The map screens carry the **"Google" wordmark** bottom-left (`01`, `03`), so
the reference is Google Maps. EV Guide is MapLibre (ticket 06), which cannot
reproduce that mark — the 1:1 impossibility already routed to 17, now
confirmed from the pixels rather than inferred.

**Unblocks 17.**
