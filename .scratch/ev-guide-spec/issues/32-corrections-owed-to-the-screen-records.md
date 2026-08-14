# 32 — Run the corrections owed back into files 11 and 12

Type: task
Status: **closed (2026-08-14)** — files 10, 11 and 12 re-derived; three flags
corrected, two escalated to tickets 33 and 34, one new defect raised as 35
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

**Resolved 2026-08-14.** Files 11 and 12 were re-derived end to end against
file 10, and file 10 was itself corrected first — but the flag pass the ticket
asked for in item 6 did not come back with four small corrections. **Two of the
four flags were larger than the sweep could see from the documents**, and they
are now tickets of their own rather than silent fixes.

### The three flags that resolved as corrections

**The pin — file 11 was right, file 10 was wrong.** `size.pin` and §7.3 are now
**122 × 147 px = 40.7 × 49.0 pt**, ratio 1 : 1.20. This is not a core/AA
question: at the pin's widest row the left and right extremes are **hard edges**
(x960 pure map → x961 pure `#C7FC2F`; x1082 pure lime → x1083 pure map), so 120
matched no convention at all. The root cause is worth keeping, because it will
recur: **120 px is exactly the width at which px/3 lands on a round 40.0 pt.**
The px was rounded to make the pt come out nice — the one thing §0.1 explicitly
forbids. Corrected in **three** places; the sweep knew about two, and the third
(§8.1's icon table row) would have survived the correction.

**The category chip — file 11 was right again.** §7.5 and [RAISE-5a] now read
**86 / 30**, not 88 / 29. The label ink is x566–703 = 138 px (isolated from the
2.5 px lime border by connected-component labelling) against a chip of x480–733
= 254 px, so `86 + 138 + 30 = 254` closes exactly at the edge the 254 is quoted
at. `88 + 138 + 29 = 255` closes against nothing. **Sweep row F11-34 reverses**:
file 11's chip fit was correct as written and [RAISE-D27] is untouched.

**The hosting card.** §7.10's *"39 px all four sides"* is **39 top and left, 38
bottom**. The height closes as `39 + 257 + 38 = 334`, which is why file 12's
`39 + 257 + 39 = 335 exactly [m]` could never have been exact.

### The two flags that became tickets

**[Ticket 33] Every radius in the system is under-read**, because §6's method
sentence states a false geometric identity. It read the first scanline's inset
as `r`; that inset is `r − √(2rd − d²)`, roughly `r − √r`. Re-measured by three
independent estimators — including a **threshold-free** corner-area check —
and confirmed by hand on a fourth: primary CTA **16.4** (published 13), sticky
CTA **16.2** (~14), floating card **19.5** (14), hosting card **15.5** (13),
category chip **38.4** (31.5). File 10's own corner evidence already contradicted
it: §7.4 records the card's first card-coloured pixel 14.5 px in, where a 14 px
radius predicts 8.8. **Six rows were never re-fitted**, so §6's signature finding
— *images are rounder than containers* — is currently unsupported in either
direction. The values are left unchanged under a warning banner, and **every
radius in files 11 and 12 is frozen and marked** rather than corrected to numbers
that are themselves wrong.
*One thing it settles:* `radius.button`'s *"both CTAs"* is **correct** — a single
radius fits all eight corners with zero penalty — so radius is **not** a fourth
[RAISE-4] difference and no `radius.buttonSticky` should exist.

**[Ticket 34] The extent convention could not be declared** (item 2), because
every candidate breaks values locked in SPEC.md — core 2, AA-inclusive 3,
integrated 4. File 10 was publishing the primary CTA at its **AA-inclusive**
extent (899 × 138) and the floating card at its **core** extent (1076 × 521),
with nothing declaring either. Files 11 and 12 were therefore re-derived against
**what file 10 publishes**, which is this ticket's actual instruction, with the
dependency noted in each file. The ambiguity has already cost something: commit
`6a5a922` moved SPEC.md's CTA height from 137 to 138 to match the token, and the
true integrated height is **137.25** — the "correction" moved the locked document
away from the reference.

### Item 5 was under-specified, and following it literally would have lost content

The ticket said to collapse the three homes into citations of
`availability-display.md` §2.2b. **§2.2b was not a superset.** File 10 §11.2
uniquely held `last reported`, `awaiting a report`, `no reports yet` and the
catch-all *"or any phrasing that asserts a report exists, does not exist, or is
old"*; §2.2b held five the design record lacked. Neither contained the other, so
the obvious order — delete the copies, keep the home — would have **dropped four
live bans**. The union was merged into §2.2b first; only then were the copies
reduced to pointers. Two self-violations inside §2.2b's own document were fixed
in passing: §2.1's Regime-3 example was emitting `1 in use · 1 unreported`, both
forbidden, and law 8's permitted form said `No confirmed bay status` where §2.2b
says `no confirmed status`.

The same pass moved file 10 §11.1's `Occupied` mapping to availability-display
§2.4 (it was the *only* enumeration of it, sitting under a preamble that forbade
holding copies) and corrected §11.3's rate table, which presented rendered
strings as the projection in violation of the binding `domain-model.md`
amendment 8 (*projections return structure, not formatted strings*).

### Item 4 changed emitted copy, as predicted

Every rung of the Regime-3 ladder was **one character high** (true 73 / 69 / 59 /
50). Rung 2 fits at **59** against the 60-character budget and greedy-wraps as
30 + 28, so the composer stops there and **`busy` survives in the card
subtitle** — it was being dropped solely because of a one-character error. The
neighbouring table was one character *low* in the other direction (39 / 43 / 54,
and the lensed GB/T DC string at 54 was a seventh miscount the sweep missed).
No verdict but rung 2's changes.

### Item 3, the fit whose verdict flips

File 12 §4.3 is re-derived. `Out of service` is 14 characters; at the primary
CTA's **measured** advance (`Let's find a car`, 340 px ink / 16 ch / **cap 36** —
the `L` is flat-topped, so its 36 px extent *is* the cap height) that is
**297.5 px** against a 341.3 px three-up budget, fitting with 21.9 px each side;
at file 11 §0.4's deliberately pessimistic constant, 327.6 px, fitting with 6.9.
The invented 28 px/char was a **Bold** advance applied to a **Medium** label.
The shipped control row is unchanged — the smaller label is still prudent — but
it is now justified on prudence rather than on an impossibility that is not one.

### Item 7

`space.sheetPadding` is gone; the raise that cited it is re-derived on
`space.floatingCardPadding` and the corrected 948 px inner box.

### One thing found that was not in scope, and is now ticket 35

**The price string is two weights.** The amount is Bold and the unit tail is
lighter — **Regular** on the `04` sticky bar (stem 4.36 px, stem/cap 0.121),
**ExtraLight** on the `03` card (1.65 px, 0.061). Three places in file 10 call
the whole run Bold. It surfaced because §11.3 was one of the sections this ticket
was about to propagate.

### And a correction recorded as applied was not applied

Ticket 17's closing note claimed the forbidden list *"now lives once, as the
union, in §2.2b, cited by the others and copied by none."* **All three clauses
were false** when written. That is this ticket's own mechanism, one layer up:
file 11 §0.3 paid the corrections owed *to* file 10 and never ran the ones owed
*back*, and ticket 17 recorded a merge that never happened. Both have now been
run; ticket 17's note is corrected in place rather than deleted, so the failure
mode stays visible.

### What a build may now read

Files 11 and 12 are trustworthy as dimension sources again **except for radii**,
which are frozen product-wide until ticket 33, and the four convention-dependent
sizes flagged by ticket 34. SPEC.md carries the pin correction, the collapsed
citations, and a banner over its radius line.
