# 17 — Screen inventory and design system from the references

Type: prototype
Status: open
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
