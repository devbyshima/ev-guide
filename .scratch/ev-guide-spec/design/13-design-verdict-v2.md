# Ticket 17 — adversarial verdict, round 2

Verdict: **cannot close.** 3 fatal · 8 major · 8 minor.

Every pixel claim relied on below was **re-measured from `refs/01.png`–`04.png`
by this review**, not taken from the documents under review. ~120 individual
figures were checked; the two files' disagreements were adjudicated against the
pixels rather than against each other.

Documents reviewed in full: `10-design-system-v2.md`, `11-driver-screens-v2.md`,
`12-operator-admin-screens-v2.md`, against `13-design-verdict-v1.md`.

---

## 0. The headline

**All five round-1 fatals are dead in substance.** The design work is sound and
in several places excellent. What blocks the close is not a design defect — it
is that **three documents no longer agree on which of them is authoritative**,
and the two inventory files are written against a version of the design system
that has been superseded. The corpus cannot be built from as it stands.

Round 1's failure shape — *a rule asserted in one document and broken by a table
in another* — has not recurred in the **rulings**. It has recurred in the
**numbers and the citations**.

---

## 1. Are the five fatals actually dead?

Checked as fixes, not as wording.

### F1 — one word for `Occupied` · **DEAD**

`busy` (lowercase in copy, `Busy` on the operator write control) is used
uniformly across all three files. A mechanical grep for `in use` returns 3 / 5 /
10 hits in files 10 / 11 / 12 — **every one of them a prohibition context**
(forbidden-list rows, "`in use` is deleted product-wide", "no `Broken`, no
`Available`, no `In use`"). File 12 §4.2 explicitly deletes v1's ban on `Busy`
rather than leaving two rules standing. File 12 §3/O2 even notices that its own
prose phrase "signed-in user" would trip a grep guard and rewords it — that is
the fix being taken seriously.

### F2 — availability in the accent badge · **DEAD, and this is the best fix of the five**

No availability string reaches the hero badge on any surface. Both detail
screens (11 D-03, 12 O3) carry **peak power** from `Connector.powerKw`, absent
when no connector carries it — and file 12 A4 closes the loop by noting that a
station with no `powerKw` loses the badge on **both** apps. File 11 D-03 adds
the invariant that makes a 1.21:1 surface safe rather than merely permitted:

> Nothing may appear in the hero badge that is not also rendered in `#FFFFFF`
> text elsewhere on the same screen.

`60 kW` satisfies it via the connector chips at 11.55:1. Verified: badge lime
core x850–1097 × y866–935 (248 × 70 px), label `#FFFFFF`, contrast **1.21 : 1**
exactly.

### F3 — `unreported` product-wide · **DEAD as a rendered string; NOT dead as a rule** (see FATAL-1)

`unreported` appears 2 / 4 / 3 times across the three files, all in prohibition
contexts. Every regime table in files 11 and 12 emits `no confirmed status`. The
word is gone. What is not fixed is *where the prohibition lives* — three files
name three different single homes and hold three different lists.

### F4 — the grey-icon finding · **DEAD, and correctly narrowed per R5**

Independently confirmed:

| Claim | Measured |
| --- | --- |
| `03` card heart is solid `#717171` | core bbox x1026–1074, y1881–1925, **517 px exact**, AA ramp `#414141 / #595959 / #2A2A2A` |
| contrast on `#121212` | **3.84 : 1** |
| the narrowing to **text** is correct | every product text run cores to `#FFFFFF` — title, subtitle, body, prices, settings labels, **all four feature-chip labels** (`Airbags`, `Bluetooth`, `Front Airbags`, `Forward Collision Warning`), and **`/day`**, which merely *looks* grey at a Regular stem |
| the basemap does have a grey ramp | `Kigali` `#FFFFFF` · `Butamwa`/`Ntarama`/`NYACYONGA` `#BDBDBD` (8.57:1) · `KABUYE`/`CYIVUGIZA` `#757575` (**3.49:1**) |
| drag handle | `#262626`, **1.24 : 1** |

`color.iconMuted` is a measured icon token and is explicitly barred from text
use. The three decisions that rested on the old premise are all text decisions
and all survive. Correct.

### F5 — the short rate projection · **DEAD**

`rateShort` is defined once in `packages/domain`, returns **structure not a
formatted string**, and the three forms are byte-identical in all three files:

```
single → 600 RWF/kWh   ·   from → From 400 RWF/kWh   ·   none → No confirmed rate
```

Used in every short slot (11: D-02 card, list detent, D-11 rows, D-03 sticky
bar; 12: O2 value slot, O3 sticky left). Grammar R is quoted **verbatim** at
D-03 and confined there. File 11 §13.2 states the failure it prevents in the
right terms: a station whose GB/T guns cost 600 and Type 2 guns cost 400 must
not render `600 RWF/kWh`. `From` asserts a floor over the confirmed set only.

---

## 2. Are M1–M4 corrected?

| # | Status |
| --- | --- |
| **M1** drag handle | **Corrected.** Both files carry 180 × 13 px. Verified: row y1828 runs `#262626` unbroken x513→692, tapering symmetrically (y1823: 516–689; y1834: 518–687) — a fully-rounded pill, centred (handle centre x602.5 = card centre x602.5), 2 121 px, 1.24 : 1. |
| **M2** floating card | **Identity corrected; frame not.** Both files call it a floating card with rounded bottom corners, and file 10 draws the right consequences (name it `StationCard`, no sheet primitive, no scrim, `radius.sheet` deleted, ADR-0004's "in the sheet" re-read as a fixed 173.7 pt box). But the two files give **different radii and frames** — see FATAL-2. Verified: card core x65–1140, y1797–2317; rows 2318–2381 = **exactly 64** rows of `#212121`; top-left arc reaches x65 at y1810 and row 1797 starts at x79 → **r ≈ 14**, matched at the bottom-left. |
| **M3** the underlined link | **Corrected, well.** 10-v2 §4.4 delivers it to sub-pixel coverage. Verified: rule x380–825 (446 px), rows y964 (0.25 coverage) / y965 (1.00) / y966 (0.75) → 2.00 px, colour `#C7FC2F` identical to the ink, **unbroken through the `y` descender of `my` at x686–716** — hence `skipInk: false`, which the token calls out explicitly. |
| **M4** basemap | **Corrected.** 10-v2 §2 delivers ground, water line + polygon, three road tiers with perpendicular core widths, the two-part admin boundary, a three-tier label ramp with cap heights, the puck, and a style-JSON-ready `map.*` namespace. Independently verified: `#212121` 2 680 014 px (84.75 %), `#3C3C3C` 34 239, `#373737` 15 093, `#272727` 15 227, `#181818` 1 233, `#6E6E6E` 970; a saturation scan of `01` returns **exactly two families**, `#C7FC2F` (122 595 px, 3.88 %) and `#4285F4` (1 295 px) — no green anywhere. **But file 11 still tells the reader M4 was rebutted and routed away** (MAJOR-8). |

---

## 3. FATAL — three, all cross-document

### FATAL-1 · R3 is violated by all three documents at once

**Rule broken.** R3: *"Add it to the forbidden list in exactly one place and cite
that place from the others."*

Four different answers are in force:

| File | Claims the single home is | Rows held |
| --- | --- | --- |
| 10-v2 §0.3 + §11.2 | *"§11.2 of this file and nowhere else"* | 6 |
| 11-v2 §0.2 | *"exactly one place — §13.1"* | — |
| 11-v2 §13.1 | *"Canonical location: `docs/availability-display.md` §2.2, law 8"* | 4 |
| 12-v2 §0.1 | *"It is **file 11 §13**"* … then restates 3 members four lines after saying it *"does not keep a second copy"* | 3 |

The three lists are **not** the same list, and none is a superset:

- `real-time` — in 11 and 12, **absent from 10**, which claims to be the only place.
- `0 of N free` (grammar law 1) and *"any string placing an availability word on the hero badge"* (R2) — **only in 10**.
- `no published rate` — **only in 11**.
- `unknown rate` / `rate unavailable` / `no rate reported` — **only in 10**.

This is F3's exact failure shape reproduced one level up: the word was removed,
the rule that removes it was not landed.

**Fix.** Land the list **once** in `docs/availability-display.md §2.2` beside law
8, as the union of all three (10's six rows + `real-time` + `no published rate`).
Delete the tables in 10 §11.2 and 11 §13.1; leave one citation line in each of
10, 11, 12. Ticket 18 owns the edit. Until it lands, F3 is not closed.

### FATAL-2 · File 11 is written against a superseded file 10 and declares its own numbers authoritative

**Rule broken.** 1:1 discipline and single-source measurement. `11-v2` §0.3:
*"`10-design-system-v2.md` **did not exist when this file was written**; until it
lands, the values in the right-hand column are the ones this file builds on, and
part 1's originals are void."* §18 repeats: *"One hard dependency.
`10-design-system-v2.md` does not exist yet."*

Both statements are false — `10-design-system-v2.md` is on disk and was written
**after** `11-driver-screens-v2.md`. The consequence is that eight measured
values have two live authorities and no tie-break. Adjudicated against the
pixels:

| Value | 10-v2 | 11-v2 | Measured | Right |
| --- | --- | --- | --- | --- |
| **`03` card radius, all four corners** | **14 px** | **16 px** (5 places) | row 1797 starts x79 (14 in from x65); col x65 starts y1810 (13 down from y1797); same at the bottom | **10** |
| `03` card size | 1076 × 521 | 1078 × 522 | core x65–1140, y1797–2317 | 10 (11 is AA-inclusive) |
| map below the card | 64 px | 65 px | rows 2318–2381 = **64** | 10 |
| **`04` hero frame** | **1078 × 612** | **1076 × 620** | x64–1141, y354–965, verified at 5 columns | **10** |
| **page indicator** | 95 × 16, **26 px** above hero bottom | 96 × 16, **34 px** above | lime bbox x512–606 × y924–939; 965 − 939 = **26** | **10** |
| hero badge | 248 × 70 | 249 × 71 | lime core x850–1097 × y866–935 | 10 |
| close / overflow / back ⌀ | 80 / 98 / 90 | 81 / 100 / 91 | `#393939` cores 80 / 98 / 90 | 10 |
| **map pin outer** | **120 × 147** (`size.pin`) | **122 × 147** | accent bbox x961–1082 = **122**, on both isolated pins — and 10's *own cited x-range* proves 122 | **11** |
| **category chip padding** | 88 / 29 | 86 / 30 | label ink x566–703 inside a chip at x480–733 → **86 / 30** | **11** |

The radius is the one that bites. `radius.floatingCard` is a **token**, 11-v2
repeats `r 16 px` in D-02, S-01, S-02, §0.3 and the §17 inventory table, and a
build reading the inventory paints every sheet corner wrong. 10-v2 explicitly
warns that *"the v1 token painted three of the four corners wrong"* — and 11-v2
carries a fourth wrong value for the fourth corner.

`1076 × 620` is worse than a drift: it is the *pre-correction* hero value that
10-v2's change log names and replaces. 11-v2 carries the corrected-away number.

**Fix.** Delete 11-v2 §0.3's right-hand column and §18's dependency clause;
replace with: *"`10-design-system-v2.md` is the measurement of record. The two
values it must adopt from this file are `size.pin` 122 × 147 and the category
chip's 86 / 30 padding."* Then correct, wherever they appear in 11: r16→r14,
1078 × 522→1076 × 521, 65→64, 1076 × 620→1078 × 612, 96 × 16 / 34→95 × 16 / 26,
249 × 71→248 × 70, ⌀81 / 100 / 91→⌀80 / 98 / 90.

### FATAL-3 · Every cross-reference from files 11 and 12 into file 10 resolves to the wrong section

**Rule broken.** 12-v2's own section-reference convention: *"Citations are by
ticket-17 file number and section, **so they hold across revisions of those two
files**."* They do not. 10-v2 renumbers wholesale:

| v1 (what 11 and 12 cite) | v2 (what is there now) |
| --- | --- |
| §2.3 line height · §2.4 no grey text | §4.3 · §1.3 |
| §5.1–§5.11 components | §7.1–§7.11 |
| §6 icons · §7 elevation | §8 · §9 |
| §8.1–§8.5 tokens | §10.1–§10.5 |
| §9 raises | §12 |

`§5.4`, `§5.7`–`§5.11`, `§8.5` **do not exist in 10-v2 at all**. Worked damage:

- **12 §7** — *"takes file 10 `§8.1`–`§8.4` (colour, type, space, radius — every
  row marked [admin]) and **none of `§8.5`**"*. Resolves to the **icon system**;
  the token set is §10.1–§10.5 and the native-only block is §10.5. The admin's
  entire token-inheritance rule points at the wrong sections, and `§8.5` at
  nothing.
- **12 §7 and [RAISE-OA-13]**, and **11 §0.3** — *"File 10 §2.4's finding [there
  is no grey text anywhere]"*. 10-v2 §2.4 is the **basemap label hierarchy**,
  which documents a three-tier grey ramp. The citation now points at the
  strongest counter-evidence to the sentence it supports.
- **12 [RAISE-OA-1]** — *"file 10 §7 — no elevation"* → §7 is Components;
  *"`§8.2` already licenses"* Regular body → §8.2 is icon stroke weight.
- **12 §1** — *"[?] in file 10 §9"* for pressed/disabled → §9 is Elevation; the
  actual home is §12 "Could not be measured".
- **11 §17**, the inventory table that indexes the whole file, cites §5.1, §5.2,
  §5.3, §5.5, §5.6, §5.7, §5.8, §5.9, §5.10, §5.11 on every row — all dangling.

**Fix.** One mechanical remap pass over 11 and 12. Delete 12's "they hold across
revisions" claim — that sentence is what let the rot pass unnoticed.

---

## 4. MAJOR — eight

**MAJOR-1 · File 12's O2 subtitle overflows by the file's own arithmetic.**
Rule broken: 12 §0.2, *"Every 'does it fit' claim in this file is arithmetic over
a measured advance, never an eyeball."* §3/O2 rejects the value slot because a
Regime-3 clause is ~39 chars = 835 px at cap 27 Bold, then moves it to the
subtitle *"which is the wide slot the driver's D-02 already gives it"* — with no
fit check. At the file's own cap-27 Regular constant (18.0 px/char) 39 chars =
**702 px**; the O2 row's text column is ≈655 px (hosting-card frame 1128 − 39
padding − 300 media − ~56 gap − 39 padding). It overflows on one line. D-02's
slot only works because file 11 runs a **two-line ladder** ([RAISE-D9]) that
file 12 neither adopts nor mentions. *m9 moved the overflow rather than solving
it.* **Fix:** state O2's line budget and adopt file 11's drop order, or raise it.

**MAJOR-2 · The `Description` region has two incompatible tenants, both routed to
ticket 19 with opposite recommendations.** File 11 D-03 [RAISE-D12] recommends
**adding** a nullable `Station.description` and titling the block `Getting
there`. File 12 §3/O3 + [RAISE-OA-3] re-tenants the same measured region as the
**`Availability` block** and declines the schema change — while claiming it
adopts *"file 11's D-03 composition … verbatim"*. It does not: in file 11,
`Availability` is a **new** block and `Getting there` occupies `Description`'s
slot. If ticket 19 says yes to D12, O3 has a field with nowhere to put it.
**Fix:** one recommendation, in one file, cited by the other.

**MAJOR-3 · RAISE-7 is open in file 10 and silently closed in file 11.**
10-v2 [RAISE-7]: the crosshair *"cannot be inferred from two stills; it needs the
founder or the source app … EV Guide has to decide whether it carries over at
all — and if it does, what it means — **before the map screen can be
specified**."* File 11 §3 specifies the map screen and decides: *"EV Guide
reproduces it verbatim … It **is** the content-column datum."* The measurement
supports the **extent** coincidence (verified: rule x64→1141, exactly the card's
and the CTA's left edge), not the **purpose**. File 11 §16's inherited list names
RAISE-1, 2, 3, 4, 5, 6, 8, 9 and **skips 7** with no note. **Fix:** carry RAISE-7
forward as open (reproducing the geometry while the meaning stays raised — which
is what file 11 actually does), or record in 10 that 17 closed it.

**MAJOR-4 · `radius.button` has two values in the corpus.** 10-v2 §10.4 sets it
to **13 px = 4.3 pt**; file 11 uses **13.5 px** in five places and file 12 uses
**`radius.button` 4.5 pt** throughout. 10-v2 §6 gives the CTA as "13 ±2", so 13.5
is inside the band — but a token cannot hold two values. Same shape, smaller
stakes: back button 30.0 vs 30.3 pt · close 26.7 vs 27 pt · overflow 32.7 vs
33.3 pt · locate ⌀137–139 vs ⌀139 · CTA label cap 36 vs 37 px. **Fix:** 10-v2 is
the token authority; delete the competing numbers.

**MAJOR-5 · Files 10 and 11 give opposite steers on the puck.** 10-v2
[RAISE-10] raises the choice without recommending, and records a concrete
objection to the lime option: *"the lime one collides with the pin outline, which
is the same colour."* File 11 [RAISE-D25] **recommends** exactly that —
`#FFFFFF` with a `#C7FC2F` core — without answering the collision. A founder
reading both raise lists gets a recommendation and an unanswered objection to it.
**Fix:** answer the collision in 11, or downgrade D25 to open.

**MAJOR-6 · The word `badge` carries two opposite instructions inside file 11.**
§0.2 R2: *"Availability never appears in the accent **badge**, on any surface."*
§2.3, three pages later: the pin dot *"is ADR-0002's own instruction, executed
literally: **availability as an additive badge when it exists**."* Same word,
same file, one forbidding and one mandating. The components differ (hero badge vs
status dot) and the design is right, but this is precisely the collision an
implementer resolves wrongly. **Fix:** name it `heroBadge` in R2's wording
everywhere, and amend ADR-0002's consequence sentence to match.

**MAJOR-7 · S-01/S-02 use the floating card as a modal and no file says what is
behind it.** 10-v2 §7.4 ¶3: *"The card sits in the map layer, not above a scrim
… Any implementation that reaches for a modal backdrop is a **deviation**."*
File 11 places the same card over **D-03 and D-04** — not over a map — with *"tap
outside the card → dismiss"*. Modal dismissal with no scrim, over a scrolling
settings list, is a screen archetype the reference does not contain, and neither
file raises it. **Fix:** raise it (scrim / no scrim / a different container)
rather than leaving it to the build.

**MAJOR-8 · File 11 tells the reader the basemap is unmeasured; file 10 measured
it.** 11 §15 M4: *"**Rebutted as out of scope**, and routed … it is the only new
work in the verdict"*; §18 repeats it. 10-v2 §2 delivers the full style and calls
itself *"the style JSON's source of truth"*, and every count in it reproduces
exactly. M4 **is** corrected — in file 10 — and file 11 says it is not.
**Fix:** retract the rebuttal in 11 §15 and §18.

---

## 5. MINOR — eight

1. **10-v2 §1.3 and §8.1 both say the icon set has "four values" and then list
   six** (`#FFFFFF`, `#C7FC2F`, `#393939`, `#121212`, `#000000`, `#717171`).
   §8.1's header reads *"The true icon colour set is four values, not two:"* over
   a six-row table. Wrong count inside the finding R5 governs.
2. **`size.pin` = 120 × 147 (10-v2 §10.5) is falsified by §7.3's own cited
   coordinates** (x961–1082 = 122). Measured 122 × 147 on both isolated pins.
   File 11's [RAISE-D26] dot derivation uses head radius 61 (from ⌀122) and is
   internally sound — d ≥ 61 + 14.5 = 75.5, /√2 → (+53, −53) — but the token it
   would be built against is not.
3. **The hosting card's padding is 39 top / 38 bottom, not "39 all four sides"**
   (10-v2 §7.10). Cores: card y1448–1781, tile y1487–1743, tile 256 × 257 px.
   File 12 §5.1's M9 reconciliation states *"39 + 257 + 39 = 335 exactly [m]"*;
   the cores give 39 + 257 + 38 = 334. The **conclusion** (content box = tile
   height; body slot ≤ 3 lines; the card does not resize) survives — the stated
   arithmetic does not reproduce.
4. **`docs/availability-display.md` is unamended.** §2.1's Regime 3 example still
   reads `1 free · 1 in use · 1 out of service · 1 unreported` — *two forbidden
   words in the document that forbids them* — and law 8's permitted form is still
   `No confirmed bay status` against R3's `no confirmed status`. All three design
   files route the correction to ticket 18; none has landed. The design documents
   are clean; the document four runtimes execute is not.
5. **The connector picker is named twice and specified nowhere.** File 11 §8.0
   (S-03 → *"a connector picker first when the station carries more than one
   type"*) and §12.1 — no row in the entry-point table, no component, no raise.
   The one dead end in an otherwise exhaustive navigation map.
6. **Settings-divider extent quoted three ways.** 10-v2 §7.6 *"core x39 → 1166
   (AA at x38 / x1167)"*; 11 §5.1 and D-04 *"x 38 → 1167"*; 12 *"full width"*.
   Measured core: x39–1166, 1128 px, `#3E3E3E`, 1 px, at y2188 / 2364 / 2541.
7. **12 §0.1 says it *"does not restate that list and does not keep a second
   copy"*, then restates three of its members in the blockquote four lines
   below.**
8. **The `03` heart's ink box is quoted 50 × 46 (files 10, 11) and 49 × 45 (file
   12).** Measured: core 49 × 45 (x1026–1074, y1881–1925); ink-inclusive 50 × 46.
   All three agree on 517 px and `#717171`, so the finding is safe; the box is
   not. This is the same ±1 core-vs-AA convention split that drives FATAL-2 —
   **the corpus needs one stated convention.**

---

## 6. What is sound — said plainly

**File 10 v2 is measurement-sound, and unusually so.** Independently re-derived
and matching to the digit: the palette with pixel counts (`#212121` 2 680 014 =
84.75 % of `01`; `#121212` 80.5 % of `02`, 64.3 % of `04`; `#C7FC2F` 122 595 =
3.88 %; `#F3F3F3` 37 935; road tiers 34 239 / 15 093 / 15 227; water 1 233);
**every** contrast row (18.73 · 15.52 · 11.55 · 9.57 · 3.84 · 1.75 · 1.24 ·
**1.21**, and the basemap's 16.1 · 8.57 · **3.49**); the label tiers and their
cap heights; the saturation scan; the crosshair (rule y249–250 x64→1141, arms
x92–94 / x1106–1108, insets 29 / 34 — the asymmetry is real); the primary CTA
(x64→962, y2382→2519); the sticky CTA (513 × 131 at x603, label ink 373 px); the
thumbnail (300 × 300 at x128, y1873); the profile avatar (`#3E3E3E` x449–756,
y402–709); the quick-action circles (**154 / 149 / 149** — [RAISE-5d] is real);
the drag handle; the underline; and the old-style figures (the `3` in
`135 000 RWF` descending 7 px below the 2446 baseline). **Two wrong numbers in
~120 checked.**

**The rulings were executed, not paraphrased.** R1 through R5 each land as a
mechanism rather than a form of words: R1 as a grep-able single string, R2 as a
redundancy invariant, R4 as a structure-returning projection with three named
kinds, R5 as a narrowing that names what the claim now covers and what it does
not.

**The raise discipline is genuinely good** — 12 + 34 + 16 = 62 raises, none
substituted, and the strongest of them are the ones that refuse a convenient
answer:

- **[RAISE-D27]** states that if the category chip is *not* content-sized then
  *"the route preview cannot live in the chip and the placement is an
  impossibility"* — naming the failure instead of papering it.
- **[RAISE-D26]** shows the dot/rim collision in numbers before proposing the
  departure, and argues that 1:1 on a *mark* means preserving legibility rather
  than the arithmetic that produced it on a rimless host.
- **[RAISE-OA-11]** refuses to ship an uptime percentage whose denominator is
  manufactured out of 87 % silence.
- **[RAISE-OA-9]** catches `sourceOnline` being wired to the reporter's signal
  bars instead of the equipment's telemetry link — a trap that would have
  silently voided the entire offline queue.
- **12 §8** turns ticket 28's rejection into six testable prohibitions, of which
  *"if a form field for availability exists anywhere in the admin, ADR-0008 has
  already been violated"* is the crispest test in the corpus.
- Both genuine impossibilities — the `Google` wordmark and Sign in with Apple —
  are named as impossibilities, not resolved.

**Coverage is complete.** Every routed constraint has a home: 06 (wordmark,
Rebero/Remera, basemap) · 13 (route preview inside existing screens, auth sheet)
· 15 (cross-app card, `packages/ui`, admin tokens-only) · 16 (offline chip,
straight-line label, Rwanda-pack row) · 19 (name/nameShort/markerLabel, derived
strings, per-Connector rate, model-backed carousel/owner/heart) · 23 (directions
ungated, gate on save and report). Both of the ticket's named divergences are
answered (`Payment & payouts` → `Offline & map data`; the hosting card → a
cross-app affordance with four states and an *absent* no-membership case, argued
from the fact that no self-serve path into a membership exists). Every screen has
an entry point (11 §8.0, 12 §3.0) and an empty state. One dead end, MINOR-5.

---

## 7. Consolidated routing

### To ticket 19 — schema and `packages/domain`

- `Station.description` nullable — accept or reject. **MAJOR-2 must be settled
  first**: files 11 and 12 route opposite recommendations for the same region.
- `Bay` label / name / ordinal ([RAISE-OA-7]) — the write surface must name bays
  and the model gives it nothing.
- `RateFlag` entity ([RAISE-OA-5]) — ticket 10 grants operators a flag with
  nowhere to write it.
- `Invitation` (or nullable-user `Membership`) and an **audit trail** entity that
  ticket 11 requires by name ([RAISE-OA-6]).
- Photo write boundary ([RAISE-OA-16]) — Owners hold the write and have no
  surface; add one or narrow the boundary to admin.
- Deletion semantics for Bay / Connector against append-only Reports
  ([RAISE-OA-14]).
- Land `rateShort` returning structure (11 §13.2), and add the report-action
  labels `Free` / `Busy` / `Out of service` to the closed vocabulary
  ([RAISE-D23]).
- Ratify the ungated device-local `My plug` ([RAISE-D18]) — the model already
  flags it.

### To ticket 21 — `packages/ui` and the build

- The token set is **10-v2 §10.1–§10.5**, corrected by MINOR-2 (`size.pin`
  122 × 147) and FATAL-2 (`radius.floatingCard` 14 px; card 1076 × 521; hero
  1078 × 612; indicator 95 × 16 at 26 px).
- One value for `radius.button` (MAJOR-4).
- `StationCard`, not `BottomSheet`; no sheet primitive; no scrim.
- The five components the reference lacks, each already raised: trailing check
  ([D17]), text input ([D21]), platform action sheet ([D13] / [OA-15]), settings
  value slot ([D14]), route line ([D8]).
- The typeface **acceptance test** (10-v2 §3.5) gates the family choice — do not
  pick a family from the document ([RAISE-1]).
- `map.*` (§2.6) goes to the MapLibre style JSON, never to the RN theme.
- Adopt one **core-vs-anti-alias measurement convention** and restate every
  dimension against it (MINOR-8).

### To ticket 18 — `docs/availability-display.md` (blocks FATAL-1 and MINOR-4)

- Fix §2.1's Regime 3 example (`in use`, `unreported`).
- Align law 8's permitted form to `no confirmed status`.
- Host the **single** forbidden list, as the union of the three current lists.
- Settle bare `GB/T` ([RAISE-D32]) and reconcile the watch vocabulary across
  three surfaces ([RAISE-D19]).

### To ticket 06

Rebero and Remera upstream into OSM; label ranking, generalisation and the zoom
stop functions outside the two captured zooms (all `[?]` in 10-v2 §2).

### To the ADRs

| ADR | Owed |
| --- | --- |
| **0002** | Amend the consequence sentence *"availability as an additive badge when it exists"* to exclude the **hero badge** by name, so MAJOR-6 cannot recur. Record R2's redundancy invariant as a consequence. |
| **0004** | Record 10-v2 §7.4 ¶5: *"route preview in the sheet"* is now a fixed **173.7 pt floating card with no detents** — materially tighter than the ADR assumed. |
| **0007** | Record that the quiet offline indicator is the `04` feature chip and the straight-line marker is `~2.4 km straight line`, matching CarPlay's wording on one fixture. |
| **0008** / availability-display | The ticket-18 edits above. |
| **0003** | **Nothing owed** — the ticket-23 amendment is executed correctly in both files: directions ungated everywhere, the gate fires on save and report, auto-resume intact. |
| **New / amend 0006** | The **modal-sheet archetype** (MAJOR-7): the floating card used over non-map screens with tap-outside dismissal and no scrim. |

---

## 8. Verdict

**Ticket 17 cannot close.** The design work is sound and all five round-1 fatals
are dead; what remains is that three documents disagree about which of them is
authoritative — and until file 11's stale-dependency clause, the r16/r14 split
and the citation rot are fixed, the corpus cannot be built from.

FATAL-1, FATAL-2 and FATAL-3 are all mechanical. None requires a design
decision. A single editing pass over files 11 and 12, plus the ticket-18 edit
that gives the forbidden list one home, closes this ticket.
