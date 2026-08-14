# 31 — The missing states: interaction states and form controls

Type: design
Status: open — commissioned 2026-08-14
Blocked by: — (17 and 18 are closed; this consumes them)

## Question

Commissioned by the founder on 2026-08-14, out of SPEC.md §12's last two
unratified items. It is the largest remaining gap between the reference and the
product, and unlike the five calls closed the same day it cannot be settled by a
ruling — it needs designing.

**The reference is a read design with one button per screen.** Ticket 12's
governing finding, restated because it is the whole premise of this ticket: the
four screenshots contain **no form control of any kind** — no text field, no
numeric input, no switch, toggle, segmented control, stepper, picker, checkbox,
radio, slider, date control, search field, reorder handle or multi-select. They
also contain **no pressed, disabled, focused, loading, error, retry, validation,
in-flight, empty or destructive-confirmation state**, no menu or popover, no
table, and no persistent chrome.

A read design survives that. A write tool cannot: every screen in the operator
app (O1–O9) and every admin form needs at least three of them, and the driver
app needs most of them too — S-01's four in-flight states, S-02's queue and
expiry, D-07's six download states, D-11's empty.

Two raises name this and neither settles it: **[RAISE-OA-2]** (no state exists
in the reference) and **[RAISE-OA-4]** / **[RAISE-D21]** (no input exists;
building one from the feature-chip surface is a *proposal*).

## What this ticket must produce

1. **The seven interaction states** — pressed, disabled, focused, loading /
   in-flight, error / retry / validation, empty, and destructive confirmation —
   specified as components in `packages/ui`, covering **every state named in the
   inventory tables** of files 11 §17 and 12 §10.1/10.2. No screen may name a
   state this pass does not define.
2. **The form controls the model actually requires**, and no more: text input,
   numeric input, the already-ruled trailing check (**[RAISE-D17]**: one
   `#C7FC2F` check at 24 pt / 2 pt stroke), multi-select for connector types,
   and whatever O4's control row and the admin's editors force. Each control
   justified by a named screen; a control no screen needs is not designed.
3. **A raise list** in the house style, separating what was *derived* from a
   measured surface from what was *invented*, with a recommendation on each.

## The disciplines that govern it

- **1:1 still governs.** Every value either cites a measured token from
  `10-design-system-v2.md`, or is marked as invented and raised. There is no
  third category, and silent invention is the failure mode this ticket exists
  to avoid.
- **The palette has no room to grow quietly:** no elevation, no opacity ramp,
  no grey text tier, no accent tints — one accent value. A state that needs a
  new token is a founder call, not a design decision.
- **`#717171` is not a disabled token.** It is one measured colour with no
  measured meaning — the same heart glyph is `#FFFFFF` on `04` and `#717171` on
  `03`, same presumed state ([RAISE-OA-13]).
- **Dark-only, used outdoors** ([ADR-0009](../../../docs/adr/0009-reference-fidelity-deviations-and-costs.md)).
  No light theme, no contrast mode, no brightness override — states must be
  legible inside the measured palette or the impossibility gets raised.
- **The closed vocabulary has one home.** Error and empty copy may not restate
  the forbidden list; it cites
  [availability-display.md §2.2b](../../../docs/availability-display.md).
  An empty state that says `no recent report` is the exact defect that list
  exists to stop.
- **Navigation vocabulary is fixed** and this pass may not extend it: full-screen
  surfaces reached by a push (`←`) or a presentation (`×`), plus one floating
  avatar. No tab bar, no nav bar, no toolbar.

## Method

The effort's established shape: design → adversarial review → merged v2. Two
design streams (states, controls) each reviewed by an adversary briefed to
reject, then synthesised into one record.

## Answer

*(pending)*
