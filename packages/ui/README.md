# @ev-guide/ui

The design system. Today this is **tokens only**; the React Native components
land with the two Expo apps, since they need the RN peer.

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
