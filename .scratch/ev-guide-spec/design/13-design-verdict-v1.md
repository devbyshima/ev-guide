# Ticket 17 — adversarial verdict, round 1

Verdict: **cannot close.** 5 fatal · 14 major · 10 minor. All pixel claims in
the review were independently re-measured from the PNGs, not taken from the
documents under review.

Full text: see the workflow result for run wf_165b6f22-d8e. Summary of the
fatals, all of which are cross-document contradictions:

- **F1** two words for `Occupied` — file 11 routes `Busy` to the domain
  package; file 12 forbids `Busy` **by name** and uses `In use`.
- **F2** file 12 puts derived availability in the accent hero badge; file 11
  forbids exactly that, by name, citing ADR-0002 (an accent-coloured apology
  on ~87% of stations). The badge also measures 1.21:1 contrast.
- **F3** `unreported` is rendered in file 12 and forbidden product-wide in
  file 11 (law 8: no string asserts report history).
- **F4** the sheet heart measures `#717171` — 517 px of solid grey — which
  falsifies file 10's headline finding that no grey tier exists. Three
  decisions rest on that premise.
- **F5** the card/sheet/sticky rate slot has no short projection, so as
  written it asserts a station-level rate for a per-Connector property.

Majors of note: **M1** drag handle is 180×13 px, not 12×13. **M2** the `03`
sheet is a floating card with **rounded bottom corners**, not a bottom sheet.
**M3** the one link in the system is underlined and no file records it.
**M4** the basemap carries an unmeasured palette and label hierarchy across
85% of the front door's pixels — the only item that is new work, not a fix.
