# @ev-guide/ui

The design system: **tokens, a pure style layer, and the shared React Native
components**.

The split is deliberate. `styles.ts` imports nothing from React Native and
returns plain objects, so every value the reference pinned can be asserted
without an RN renderer. `components.tsx` is the thin part on top. The 1:1 rule
lives in numbers, and numbers are what drift.

**The rule that outranks the others: no component composes an availability
string.** Words come from `@ev-guide/domain`'s grammar, which is the only place
the eight display laws are enforced. `StationCard` takes `availabilityText` as
an already-composed string precisely so it can render words without choosing
them.

The admin dashboard takes **tokens only, no components**, and the 1:1
reference rule does not govern it (ADR-0006).

## What the tests are for

They guard the **findings**, not the numbers. A token file drifts by someone
tidying it, and every plausible tidy here was specifically ruled out:

- rounding a fractional size -> ticket 34 (tokens carry the fraction; an
  unwritten rounding rule is what produced a wrong "correction" to a locked
  value)
- adding a muted grey text tier -> there is none; it was ExtraLight AA
- regularising spacing onto an 8pt grid -> the values are named after where
  they were measured, and there is no grid
- turning the pills back into explicit radii -> ticket 33 reversed that; the
  category chip, hero badge and drag handle **are** pills
- collapsing the three quick-action sizes into one -> ticket 36 reversed that
- naming a font family -> the typeface is an acceptance band (ADR-0010)

`radius.image > every container radius` is asserted because "images are
rounder than containers" is the system's signature move and every instinct
will be to do the opposite.

The component tests guard the same class of thing: that the CTA is **not** a
pill (a pill on a 45.75 pt button needs r 22.9; it measures 5.5), that the
category chip's padding stays **asymmetric** at 86/30 rather than being
centred, that the floating card sits on the **page** colour and so reads
darker than the map around it, and that the five circular-button diameters are
not collapsed into one.

`fontWeight` is a four-literal union rather than a template type, so a fifth
weight cannot arrive by typo: the system has exactly 200/400/500/700.
