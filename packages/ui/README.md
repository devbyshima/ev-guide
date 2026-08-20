# @ev-guide/ui

The design system: **tokens and a pure style layer**. No components.

The split was always deliberate, and it is now the whole package. `styles.ts`
imports nothing from React Native and returns plain objects, so every value the
reference pinned can be asserted without a renderer. The 1:1 rule lives in
numbers, and numbers are what drift.

**Where the components went.** `components.tsx` held the shared React Native
components, and it outlived its only consumer: ADR-0012 moved the phone to
Flutter, the Expo driver app was retired once the Flutter app was verified on
the device, and ADR-0006 gives the admin SPA **tokens only, no components**.
What survived the port lives in `packages/dart/ui`, which is what the phone
consumes. Recover the deleted file from git if the history is wanted; it was
last edited in `a19389d`.

Deleting it also closed a live defect rather than merely removing dead code.
The `Button` shipped an opacity ramp (`0.85` pressed, `0.5` disabled) and a
`disabled` prop, which SPEC.md section 5 and section 13 item 11 both forbid,
and it had no test of any kind. The Dart side carries the corrected grammar and
the guard that keeps it: see `pressable_surface.dart` and
`press_grammar_test.dart`. **If a React component is ever needed here again, it
comes back with that guard, not without it.**

**The rule that would outrank the others, kept for whoever adds the first one
back: no component composes an availability string.** Words come from
`@ev-guide/domain`'s grammar, which is the only place the eight display laws
are enforced. `stationCardStyle()` is a style, not a card, and the card that
consumed it took `availabilityText` as an already-composed string precisely so
it could render words without choosing them.

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

`styles.ts`'s own tests guard the same class of thing, one level up: that the
CTA is **not** a pill (a pill on a 45.75 pt button needs r 22.9; it measures
5.5), that the category chip's padding stays **asymmetric** at 86/30 rather
than being centred, that the floating card sits on the **page** colour and so
reads darker than the map around it, and that the five circular-button
diameters are not collapsed into one. These are assertions about the style
layer, so none of them was lost with the components.

`fontWeight` is a four-literal union rather than a template type, so a fifth
weight cannot arrive by typo: the system has exactly 200/400/500/700.
