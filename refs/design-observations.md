# Reference design — observations

Captured from the four screenshots shared during charting. This is an
**observation record**, not a decision: it exists so the visual detail isn't
lost between sessions. Ticket 17 turns it into the actual design system.

The reference is a Kigali car-rental app. EV Guide adopts its UI 1:1.

## The four screens

1. **Map home** — full-bleed dark map, floating avatar, pins, primary CTA
2. **Profile** — avatar, quick actions, mode-switch card, settings list
3. **Map + preview sheet** — same map with a bottom sheet for the selected item
4. **Detail** — hero carousel, title block, owner row, description, feature chips, sticky price bar

## Palette — MEASURED (2026-08-13, ticket 01)

Sampled by histogram from the source PNGs now on disk. **The earlier table was
eyeballed and materially wrong in three rows** — it is replaced, not annotated,
because under the 1:1 rule a wrong hex is worse than no hex.

| Role | Measured | Where | Earlier guess |
| --- | --- | --- | --- |
| Page background | **`#121212`** | 80% of `02`, 64% of `04` | ~~`#000000`~~ — pure black is 0.34% of `01` |
| Map canvas | **`#212121`** | 85% of `01`, 68% of `03` | not distinguished from background |
| Surface / card | **`#393939`** | hosting card, quick-action circles | ~~`#1A1A1A`–`#1C1C1C`~~ |
| Surface raised | **`#3C3C3C`** / `#3E3E3E` | pin-adjacent chrome, pressed states | ~~`#2A2A2A`–`#3A3A3A`~~ |
| Accent (lime) | **`#C7FC2F`** | identical in all four screens | ~~`#C7F531`~~ |
| Accent shade (pressed/edge) | `#9EC52B`, `#9AC128` | anti-aliased pin outlines | — |
| Text primary / pin glyph | `#FFFFFF` | — | correct |
| Pin fill | `#F3F3F3` | teardrop body | — |

The accent is exactly one value across every screen — no tints, no gradients.
Its share of the map screens (~3.9%) is a useful budget: the reference spends
lime on pin outlines, one CTA, and nothing else.

**Capture geometry:** 1206 × 2622 px = iPhone 16 Pro at @3x (402 × 874 pt).
Divide by 3 for point measurements.

The accent carries a heavy load: primary button fills (with **black** label
text), avatar rings, active page indicator, link text, notification dots,
badge chips, map-pin outlines, and the icon inside the mode-switch card.

## Components

- **Primary button** — full-width lime pill, black bold label, tall (~56–60pt). Paired with a circular white icon button to its right on map screens.
- **Circular icon buttons** — dark grey filled circles, white outline icons. Used for back, close, overflow, and the profile quick actions.
- **Map pin** — teardrop, light fill, lime outline, black glyph inside.
- **Bottom sheet** — dark surface, top corner radius ~20, grey drag handle pill, square thumbnail left, title/subtitle, chip, price bottom-right, heart top-right.
- **Chips** — two variants: outlined lime pill with lime text (category), and filled dark rounded rect with white outline icon + grey text (features).
- **Settings list** — white outline icon + white label rows, thin dark dividers, bold section header above.
- **Hero carousel** — rounded image, lime elongated active indicator + grey dots, lime badge pill bottom-right with a lightning glyph.
- **Crosshair rule** — a thin white horizontal line spanning the map screen's top, terminated by a `+` cross at each end. Distinctive; purpose unclear from a still.

## Typography

Geometric sans, heavy weight for titles and prices, regular for body. Likely
Poppins or a close relative — **identify precisely in ticket 17**, do not guess
at implementation time.

## Mapping notes for EV Guide

Direct substitutions are mostly clean: car pins become charger pins, the rental
card becomes a station card, `135 000 RWF/day` becomes the charging rate,
`Check Availability` becomes the directions CTA.

Two places where the reference and EV Guide's domain genuinely diverge, both
for ticket 17 to resolve rather than for anyone to improvise:

- **`Payment & payouts`** in the settings list. EV Guide has no payments at
  all, so this row cannot exist. What (if anything) takes its place is a
  decision, not a deletion.
- **`Switch to hosting mode`** card. The reference makes host mode a *mode
  switch inside one app*. The brief specifies a **separate** operator app.
  Whether this card becomes a cross-app handoff, an invitation, or is dropped
  affects both apps.
