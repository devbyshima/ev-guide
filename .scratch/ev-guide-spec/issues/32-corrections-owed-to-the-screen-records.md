# 32 — Run the corrections owed back into files 11 and 12

Type: task
Status: open — raised 2026-08-14 by ticket 31's sweep
Blocked by: —

## Question

Nothing to decide. This is bookkeeping with teeth.

Both of ticket 31's adversarial reviewers, working independently on different
documents, hit the same cross-cutting defect. The sweep that followed
([`20-staleness-sweep.md`](../design/20-staleness-sweep.md)) counted it:

**60 distinct stale values — 40 in file 11 (~90 occurrences), 20 in file 12
(~30) — every one of them cited as if it came from the measured design system.**

**The mechanism, stated precisely so it cannot recur:** file 11 §0.3 lists six
corrections owed **to** `10-design-system-v2.md`. Those were paid. The
corrections owed **back** — the values file 10 changed *under* files 11 and 12
— were never run. Six root causes produce 31 of file 11's 40: the floating-card
frame, the primary CTA, the `04` hero frame, the circular buttons, the pin, and
the hosting card.

The authority notes already in those files are **insufficient**: they name one
conflict (the card radius) while the body contradicts file 10 in 39 other places
in file 11 alone — nine of them being that same radius.

## What must happen

1. **Re-derive against `10-design-system-v2.md`, do not patch.** A patch fixes
   the 60 values that were found; a re-derivation fixes the ones that were not.
2. **Declare an edge convention in file 10 §0.1.** Several of the 60 are a
   core/anti-aliasing split — `899` vs `897`, `1076` vs `1078`, `138` vs `137` —
   where both numbers are defensible and the corpus never said which it meant.
   Until that convention exists, the same class of defect regenerates.
3. **Fix the one fit whose verdict flips.** File 12 §4.3 claims `Out of service`
   at 392 px "does not fit" a 341 px control row, on an **[INVENTED]** constant
   of 28 px/char that no file measures. At the measured Medium advance it is
   297 px; at the pessimistic constant, 328–337 px. **It fits at every
   legitimate constant.** The shipped control row is unaffected — but its
   justification is an asserted impossibility that is not one, which is exactly
   the failure ticket 31's sweep discipline exists to catch.
4. **Fix the Regime-3 ladder miscount** (file 11): rung 2 recounts at **59**
   characters, not the claimed "60, exactly, zero margin", against a 60-char
   budget. `busy` is currently dropped from the card subtitle **solely because
   of a one-character error** — this one changes emitted copy.
5. **Collapse the three forbidden-list homes into citations** of
   `docs/availability-display.md` §2.2b (ticket 31 S-28, sweep F11-40).
6. **Re-check file 10 itself in four places** the sweep flagged: §7.3's pin bbox
   contradicts its own cited x-range; §7.5's 88/29 chip padding does not
   reconcile with the chip's measured extents while file 11's 86/30 does;
   §10.4's `radius.button` collapses a sticky CTA that §6/§7.8 measure at ~14;
   and §11.2's claim to own the forbidden list.
7. **Remove `space.sheetPadding`** — cited as measured in file 11 [RAISE-D31];
   the token does not exist.

## Not in scope

**SPEC.md is already fixed.** The sweep found exactly one substantive error
there — the floating card's anchor, corrected 2026-08-14 in `4407395` — plus two
omitted colour tokens, added in the same commit. SPEC.md otherwise matches file
10 token for token across all four tables, because it was transcribed from file
10 rather than from the screen inventories. That is the whole reason the locked
document escaped: **transcribe from the measurement, never from the summary.**

## Why this is worth doing before the build

Files 11 and 12 are what a build reads for geometry. The sweep's verdict:
*"not trustworthy as dimension sources, trustworthy as design records."*
Fifteen of sixteen fit calculations keep their verdict at corrected values, so
**nothing designed has to be redesigned** — but a build that reads a wrong
number does not know it is reading one, and the citation makes it look checked.

## Answer

*(pending)*
