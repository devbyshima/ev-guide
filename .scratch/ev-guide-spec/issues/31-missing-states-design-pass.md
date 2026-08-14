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

**Delivered 2026-08-14.** Two design streams, each adversarially reviewed and
revised against its verdict; both v1s were **rejected** (3 fatal + 15 major, and
3 fatal + 8 major). ~6,500 lines across six documents:

| | v1 | verdict | v2 |
| --- | --- | --- | --- |
| Interaction states | [14](../design/14-interaction-states-v1.md) | [16](../design/16-interaction-states-verdict-v1.md) | **[18](../design/18-interaction-states-v2.md)** |
| Form controls | [15](../design/15-form-controls-v1.md) | [17](../design/17-form-controls-verdict-v1.md) | **[19](../design/19-form-controls-v2.md)** |

Plus [20 — the staleness sweep](../design/20-staleness-sweep.md), which the
review round forced into existence and which became ticket 32.

### The two results that govern everything else

**1. State is carried by the accent or by copy, never by a surface swap alone.**
The four surface greys span **1.75 : 1** end to end; `surface`→`surfaceRaised`
is **1.08 : 1**. No grey-to-grey swap reaches the 3 : 1 a non-text signal needs.
Every instinct a designer brings to this problem — dim on press, grey out when
disabled, a paler placeholder — is inventing a channel the measured palette does
not have. This one line of arithmetic decided both documents.

**2. EV Guide has no disabled state and no disabled token**, proved against 23
places. A control is **absent**, or it **refuses in words**, or it is
**transiently inert** — split by *who can satisfy the precondition, and when*.
This is already the product's grammar (the hosting card is absent without a
membership; O9 offers no action because no self-serve path exists), and it is
derived from the reference rather than invented: a settings row has no trailing
affordance, so a dead row is still a true statement, while a 46 pt accent slab
is not.

### What the pass produced

- **Seven states as five components**, not seven: `StateLine` (one body line
  doing five jobs, in three measured slots), `Placeholder`, `PressableSurface`,
  the confirmation surface, and the empty-state composition.
- **Ten controls**, each justified by a named screen — text field, numeric field,
  trailing check, CTA-geometry control, native and admin selects, A9's
  admin-native availability buttons, file upload, ordered grid, caret/selection
  — and **eight controls refused**: placeholder, radio, date, stepper, slider,
  search, segmented, toast. A control no screen needs is not designed.
- **`packages/ui` prohibitions as build failures**, the sharpest being that React
  Native ships the forbidden opacity ramp and motion **by default**: a bare
  touchable must fail the build.
- **Five OS-drawn surfaces declared**, up from the three the corpus believed.

### Corrections this pass owes the corpus

- **`saving` should not exist** in the operator app — the write is local, and a
  spinner for an operator in a basement never resolves. **A3/A5 keep it**: all
  three grounds are false for a web SPA.
- **`[RAISE-D21] points at the wrong surface.** The field is the
  secondary-control box, not the 35 pt feature chip. Four documents needed
  amending, **including ratified SPEC.md §12** — until fixed, a build reading
  the spec ships a 35 pt tap target. **Fixed in SPEC.md the same day.**
- **60 stale values** across files 11 and 12 → **ticket 32**.
- **Three documents each claim to own the forbidden list**, at three addresses,
  with three different row counts.

### Two holes found that no screen had

- **O2's cold start is pixel-identical to O9** — a slow link tells a brand-new
  owner that they hold no stations. The free half of the fix ships regardless:
  O9 may not paint until the membership query has returned zero.
- **A server-rejected queued write has no surface**, and the obvious home fails
  for exactly the case that produces it — the membership was revoked, so the
  station is gone.

### Still open

**19 founder calls**, listed in [18 §13](../design/18-interaction-states-v2.md)
(11) and [19 §11](../design/19-form-controls-v2.md) (8), and summarised in
SPEC.md §12. The load-bearing ones: pressed rendering nothing; O4's 1 px divider
at 1.75 : 1, where a wrong-row tap files a false report about the wrong bay and
no mitigation exists inside the palette; the server-rejection surface; the
selection highlight as the product's first accent tint; and accepting the
platform dialog's red into a product that has none.

**One live contradiction between the streams**, deliberately not resolved by
either: O4's zero-touch `Save`. [19 F11] proposes replacing the dead button with
a refusal line; [18 §5.3] declines, because the sticky bar would reflow under
the operator's aim on the first tap and the label is their readout of the size
of the claim. Recorded as **S-6** — a founder call, not a merge conflict.
