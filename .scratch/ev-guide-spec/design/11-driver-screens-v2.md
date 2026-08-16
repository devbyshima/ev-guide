# 11 — Driver app: screen inventory and domain mapping (v2)

> ## Authority note — fully re-derived under ticket 32 (2026-08-14)
>
> *Replaces the note added 2026-08-13 when ticket 17 closed. That note named
> exactly **one** conflict with file 10 — the floating card's corner radius —
> while the body contradicted file 10 in forty places, nine of them being that
> same radius. It was obsolete and, worse, it read as an all-clear. It is
> withdrawn.*
>
> **1. `10-design-system-v2.md` remains the measurement of record, and this file
> was re-derived against it end to end on 2026-08-14 under ticket 32.** Every
> numeric value, every token citation, every section pointer and every fit
> calculation below was checked against file 10 and corrected where it
> disagreed; derived values (inner boxes, fits, residuals, character budgets)
> were **recomputed from file 10's inputs** rather than adjusted at the output.
> Where a correction changes a stated conclusion it is marked
> **[RE-DERIVED, ticket 32]** in place, with a one-line note on what changed and
> why. Where this file's own measurement is the correct one and file 10 has been
> brought into line, that is stated too — it runs both ways.
>
> **Citations into file 10 now use v2 section numbers throughout.** The v1→v2
> translation table the old note carried has been applied to the body and is
> withdrawn with it: `§5.1`–`§5.11` are now `§7.1`–`§7.11`, `§6` is `§8`, `§7` is
> `§9`, `§8.1`–`§8.5` are `§10.1`–`§10.5`, `§9` (raises) is `§12`, `§2.3` (line
> height) is `§4.3`, `§2.4` (no grey text) is `§1.3`.
>
> **2. NO RADIUS IN THIS FILE MAY BE READ BY A BUILD UNTIL TICKET 33 RULES.**
> File 10 §6's measurement method — *"the topmost scanline's fill begins `r` px
> in from the left edge"* — is **geometrically false**: the true inset is
> `r − √(2rd − d²)`, roughly `r − √r`, so **every published radius in file 10 is
> under-read**. Re-measurement by three independent estimators gives primary CTA
> **16.4** (published 13), sticky CTA **16.2** (published ~14), floating card
> **19.5** (published 14), hosting card **15.5** (published 13), category chip
> **38.4** (published 31.5); six further rows — hero badge, hero image, card
> thumbnail, icon tile, feature chip, handle — had not been re-fitted. This was
> **[RAISE-13], routed to ticket 33**, because correcting it moves `radius.*` in
> `packages/ui` *and* the locked radius table in `SPEC.md` §5.
>
> **RELEASED 2026-08-16 — ticket 33 closed.** All six outstanding rows were
> re-fitted and every `[radius frozen]` / `[r-frozen]` marker in this file has
> been replaced by the corrected value: floating card **19.5**, both CTAs
> **16.5** (one token), hosting card **15.6**, icon tile **15.2**, thumbnail and
> hero **31.8**, feature chip **13.4**, and the category chip, hero badge and
> drag handle are **pills** (½ integrated height 38.4 / 35.4 / 6.4). Radii of
> true **circles** were never affected — RAISE-13 is a corner-arc method defect,
> and a circle's radius is half its measured diameter.
>
> Two corrections this file should note. The **drag handle never carried the
> bias**: its 6.5 came from the "fully rounded" constraint, not the false arc, so
> only the height convention moved it (½ of 12.75 is 6.4). And the **category
> chip and hero badge are pills**, where file 10 had said they "measurably fall
> short" of one — `borderRadius: 9999`, the reverse of the old instruction.
>
> **3. Component sizes here are convention-dependent — [RAISE-14], ticket 34.**
> File 10 §0.1 now records that an element's size reads three ways (core /
> integrated / AA-inclusive) and that file 10 itself publishes the primary CTA
> **AA-inclusive** (899 × 138; core 897 × 136, integrated 898.00 × 137.25) and
> the floating card at its **core** (1076 × 521; AA-inclusive 1078 × 522,
> integrated 1077.60 × 521.53). Declaring one convention breaks two, three or
> four values locked in `SPEC.md`, so it is raised, not settled. **This file
> re-derives against what file 10 publishes**, which is the only reading a build
> can act on today: primary CTA **899 × 138**, floating card **1076 × 521**,
> sticky CTA **513 × 131**, map pin **122 × 147**. If ticket 34 declares core or
> integrated, those four figures and everything derived from them move.
>
> **4. The forbidden-string list is NOT held here.** Its one home is
> `docs/availability-display.md` **§2.2b**. §13.1 cites it and holds nothing; the
> four-row restatement §13.1 used to carry was deleted under ticket 32, after its
> unique items were merged into §2.2b so that nothing was lost.



Ticket 17, part 2 of 2. Supersedes `11-driver-screens.md` in full. Part 1 is
**`10-design-system-v2.md`**, which has landed and which supersedes
`10-design-system.md` in full. **[RE-DERIVED, ticket 32]** — this sentence
previously read *"Part 1 is `10-design-system.md`, pending correction as
`10-design-system-v2.md`"*, which was true when the file was written and false
from the day file 10-v2 landed; §0.3's six corrections owed to part 1 have since
been adjudicated (see §0.3) and this file has been re-derived against v2.

Scope: the **driver app** (`apps/driver`). The operator app and the admin
dashboard are out of scope. The design system lands as `packages/ui`, shared by
both mobile apps; admin takes tokens only (ADR-0006).

This revision answers the round-1 adversarial verdict
([`13-design-verdict-v1.md`](13-design-verdict-v1.md)) — 5 fatal, 14 major,
10 minor. Every finding is answered in **§15**, fixed or rebutted, none left
silent.

---

## 0. How to read this file

**The standing rule governs everything below.** Reference designs are
implemented 1:1 with no deliberate deviations. Where the reference cannot be
reproduced, the impossibility is **raised**, not substituted. §16 holds every
raise; nothing is quietly resolved in the body.

### 0.1 Marking legend and units

- **[ref-NN]** — this screen or element exists in reference `NN.png` and is
  reproduced. Geometry is cited from part 1, or measured here and declared in
  §0.3.
- **[ext]** — by extension: no reference screen exists, so the screen is
  *assembled from named reference components* whose geometry is measured. The
  component list is given for every one.
- **[m·11]** — measured from the PNGs **by this file**. Every such value is
  listed in §0.3; there are no undeclared measurements anywhere below.
- **[d]** — derived by stated arithmetic from [m] values.
- **[RAISE-D…]** — a place the reference cannot arbitrate. Raised, with a
  recommendation, never silently decided.
- **[vocab]** — the string is **closed vocabulary owned by `packages/domain`**
  (docs/availability-display.md §2.4). The app may not author it.

**Units.** px is authoritative (captures are 1206 × 2622 = iPhone 16 Pro @3x);
pt = px/3 is given because that is what a build types.

### 0.2 The five settled rulings this file executes

Binding on files 10, 11 and 12 alike. Not re-decided here.

| # | Ruling |
| --- | --- |
| **R1** | The word for `Occupied` in user-facing copy is **`busy`**, everywhere, both apps. The operator write control reads **`Busy`**. **`in use` is deleted product-wide, and its title-cased form is the same ban** — a capitalised spelling is not an exemption, and it was still in circulation in this file and in file 12 until ticket 32. The three-row mapping this ruling summarises (driver-facing · operator-facing · the operator write-surface control label) lives in **`docs/availability-display.md` §2.4**, with the rest of the closed vocabulary; it moved there under ticket 32 from file 10 §11.1, which is now a pointer. Cite §2.4, never file 10 §11.1. |
| **R2** | **Availability never appears in the accent badge, on any surface.** The hero badge carries **peak power** or is absent. It measures 1.21:1 and may never carry a value a driver must read (§15, M12). |
| **R3** | **`unreported` is forbidden product-wide**, with every string asserting report history. The permitted form is **`no confirmed status`** (and `no confirmed rate`). The forbidden list lives in **exactly one place** — **`docs/availability-display.md` §2.2b** — and is cited, never restated. **[RE-DERIVED, ticket 32]** — this row previously claimed the one place was **§13.1 of this file**, which put four documents in circulation as the single home (file 10 §11.2, this file's §13.1, `availability-display.md` §2.2, and §2.2b). §2.2b is the home; §13.1 is now a citation and holds nothing. |
| **R4** | A **short rate projection** exists for the card / sheet / sticky slots, defined once in `packages/domain` (§13.2). The long Grammar R ladder stays on the **detail screen only**. |
| **R5** | Colour tokens are whatever the **pixels** say. The reference contains a grey icon; the "no grey tier" finding narrows to **text** (§0.3). |

### 0.3 Measurement policy, and the corrections owed to part 1

Part 1 says it is the only file that measures. v1 of this file then measured
anyway, silently, in five places, and three of those measurements disagreed
with part 1. That is the defect behind verdict minor **m1**. The policy now:

> **This file cites part 1 for every dimension. Where it measures, it says
> [m·11] and the measurement appears in the table below. Where a [m·11] value
> contradicts part 1, the contradiction is stated here and owed back to
> `10-design-system-v2.md` — it is never resolved by silently preferring one
> number in the body.**

**Corrections owed to `10-design-system-v2.md` — all six adjudicated.**
**[RE-DERIVED, ticket 32]** This table was written when
`10-design-system-v2.md` **did not exist**, and it carried the clause *"until it
lands, the values in the right-hand column are the ones this file builds on, and
part 1's originals are void."* **That clause is void, not the originals.** File
10-v2 landed, adopted **five** of the six (M1, M2's identity, the chip, the grey
heart and the `color.iconMuted` token are all in its §0.2 change log), and
**corrected the sixth in the opposite direction** — the card frame and the CTA
width. The right-hand column below is therefore no longer authoritative over
part 1; it is a record of what was owed and how each was settled. The
**Adjudication** column is the operative one. **The Method column is part 1's own
evidence, preserved verbatim** — ticket 32's first pass overwrote it with the
adjudication, deleting six statements of how each value was obtained (including this
file's own corner evidence for the card frame). That was a regression and is undone.

| # | Part 1 (v1) said | Measured [m·11] | Method [m·11] | Adjudication against 10-v2 |
| --- | --- | --- | --- | --- |
| 1 | Drag handle **12 × 13 px** core, `#262626` | **180 × 13 px**, `#262626`, x 513→692, y 1822→1834 on `03`, fully rounded (r = 6.5 px), centred on the card's own centre x 602.5 | run-length scan of every row 1815–1845 | **Accepted.** 10-v2 §7.4 / `size.handle` = **180 × 13 px = 60.0 × 4.3 pt**, and §5.2 puts the handle's ink top **25 px = 8.3 pt** below the card top — *not* the 26 px this file carried into D-02, S-01 and S-02. Corrected there. |
| 2 | Sheet "bottom corners square (sheet runs under the CTA)" | **False.** It is a **floating card**, rounded on **all four** corners at **19.5 px** [ticket 33] | corner-arc profiling both ends; top row y 1797 spans x 79→1126, bottom row y 2317 spans x 82→1123 — symmetric | **Accepted as to identity, corrected as to frame.** 10-v2 §7.4 measures the frame **x65 → 1140, y1797 → 2317** (AA columns at x64 / x1141, AA row at y1796) and the size **1076 × 521 px = 358.7 × 173.7 pt**; **64 px** of `#212121` map sits below it (rows 2318–2381 inclusive), and the CTA's accent begins at **y2382**. This file's `x 64→1141, y 1796→2317`, `1078 × 522`, `65 px of map` and `CTA at y 2383` were each one step out and are corrected throughout. Radius: **frozen, [RAISE-13]/ticket 33** — see the authority note. |
| 3 | Category chip **256 × 77 px** (v1 of this file said 253 × 75) | **254 × 76 px**, x 480→733, y 2030→2105 | lime-ink bbox | **Accepted.** 10-v2 §7.4 / §7.5 carry 254 × 76 px = 84.7 × 25.3 pt at x480–733, y2030–2105. |
| 4 | Icon colour is `#FFFFFF` except the pin glyph and the hosting tile | **False.** The `03` card heart is **`#717171`** — 517 px of solid core, no white pixel anywhere in its ink box (x 1025→1074, y 1881→1926, 50 × 46 px). The `04` heart and share (**67 × 67 px**, 10-v2 §8.1 row 22) glyphs *are* `#FFFFFF` | colour histogram over the ink box; sub-pixel stroke integration across three perpendicular cuts | **Accepted, with the stroke claim withdrawn.** 10-v2 §1.1 and §10.1 add `color.iconMuted` = `#717171`. But the stroke is **not** "6.0 px, i.e. the 2 pt stroke unchanged": §8.1 row 17 integrates the card heart at **4.8–6.0 px** and §8.2 files it in the **Light** band at **4.8 px = 1.6 pt**, against a nominal 6 px = 2 pt. The `04` heart is **66 × 62 px** (§8.1 row 21), not 68 × 62. Both corrected here and at §15/F4. |
| 5 | Primary CTA **899 × 138 px** | **897 px** of lime core, x 65→961; the locate button occupies x 1003→1139 | run-length scan at y 2450 | **Rejected — part 1 was right and this row was wrong.** 10-v2 §7.1 [m]: frame **x64 → 962**, size **899 × 138 px = 299.7 × 46.0 pt**; §7.2 / `size.circleButton.xl`: locate **139 px = 46.3 pt**; §7.1: **40 px = 13.3 pt** gap. This file's 897 was a mixture — the *core* width against the *AA-inclusive* height (10-v2 §0.1: core 897 × 136, integrated 898.00 × 137.25, AA-inclusive 899 × 138) — and is wrong under every one of the three conventions. **The residual identity is the proof:** `897 + 41 + 137 = 1075`, three short of the 1078 px content column, so this file asserted an *exact* identity from three numbers that do not add up. At 10-v2's figures **`899 + 40 + 139 = 1078` closes exactly.** See the re-derivation below. |
| 6 | — (no advance model) | **Mean ink advance is string-dependent**, so every fit check below states its constant. Measured: cap 27 Regular k = 0.667 (`Hybride - Black - 2024`, 22 ch, 397 px) … 0.730 (`Hybride`, 7 ch, 138 px). cap 32 Medium k = 0.650 (`Check Availability`, 18 ch, 374 px). **cap 36 Medium k = 0.590** (`Let's find a car`, 16 ch, 340 px). **Bold k = 0.80** — two runs agreeing to 0.01 (`135 000 RWF/day` at cap 36, 433 px; at cap 27, 321 px) | ink bbox ÷ (chars × cap px) | **Accepted, with two arithmetic corrections.** (a) The CTA label's cap is **36, not 37** — 10-v2 §4.1 row 5 measures `Let's find a car` at cap 36 Medium, and §4.1's own note says rows measured from a **flat** cap (`L`) *"are exact"*. §4.2 collapses 36/37 into one **step**, which is a statement about the type scale, not a licence to divide by 37. Re-derived: `340 ÷ (16 × 36)` = **0.590**, where this row read 0.574. (b) The **Bold k = 0.80** constant is measured on `135 000 RWF/day`, which 10-v2 §11.3 has since shown is **not one weight** — **[weight unsettled: RAISE-15]**, see the note below. |

**[RE-DERIVED, ticket 32] The residual-width identity, recomputed.** The claim
*"the CTA's width is a residual, not a component property"* is the sole evidence
for §1's *"A width that is not a token"*, for S-01/S-02's button width and for
[RAISE-D31]. **The claim survives — but only on 10-v2's figures, not this
file's:**

| Source | CTA | gap | locate | total | vs the 1078 px content column |
| --- | --- | --- | --- | --- | --- |
| this file, as written | 897 | 41 | 137 | **1075** | **−3 px — does not close** |
| **10-v2 §7.1 / §7.2 / §10.5** | **899** | **40** | **139** | **1078** | **exact** ✓ |

Three numbers that add up exactly to an independently measured column is a
strong check that 10-v2's CTA frame is the right one. Every consumer of the
residual claim below is re-derived on the bottom row.

**[weight unsettled: RAISE-15] The price string is two weights, not one.** Both
runs used above for the Bold constant — `135 000 RWF/day` at cap 36 on `04`'s
sticky bar and at cap 27 on the `03` card — are **mixed-weight runs**. Measured
[m, 10-v2 §11.3, integrated stem coverage]: the **amount is Bold in both**
(`04`: `F` of `RWF` 6.92 px, stem/cap 0.192; `03`: `1` 5.19 px and `F` 5.22 px,
0.192), but the **unit tail is lighter, and lighter by a different amount in
each slot** — `04` sticky `d`/`a`/`y` at 4.36 / 4.21 / 4.37 px (0.121,
**Regular**); `03` card `d`/`a` at 1.65 px (0.061, **ExtraLight**). 10-v2 §4.1
row 15, §7.8 and §11.3 all previously called the whole run Bold and are **not**
corrected — the per-slot assignment is RAISE-15's to settle. The consequence
here is narrow and is stated rather than hidden: **k = 0.80 is the advance of a
run whose tail is set lighter than Bold**, so as a *Bold* constant it is
conservative for the amount and optimistic for a tail. Every fit that uses it
below is re-checked on that basis and none of them turns on it; the constant is
left as measured because re-measuring it needs the two-weight split RAISE-15
owes.

**Consequence of correction 4, and R5.** Part 1 §1.3's headline finding —
*"there is no grey text anywhere; every text core samples `#FFFFFF`"* — is
**still true and still load-bearing**, and this file relies on it. What is
false is the wider claim that the system has no grey tier at all. It has
exactly one grey in the product chrome's icon set, and it is an **icon** colour:

| Token | Value | Where measured | Contrast on `#121212` |
| --- | --- | --- | --- |
| `color.iconMuted` | **`#717171`** | `03` card heart, 517 px solid | **3.84 : 1** — clears the 3:1 floor for a non-text UI component |

**[RE-DERIVED, ticket 32]** 10-v2 §1.3 has since narrowed the claim further than
this file did: **three** greys exist outside text — `#717171` (the card heart),
`#262626` (the drag handle) and the **basemap's own three-tier label ramp**
(`#757575` / `#BDBDBD` / `#FFFFFF`, §2.4). The correct sentence is 10-v2's:
*the product chrome has one text colour; the icon set has four; the basemap has
its own three-tier label ramp.* Nothing in this file rests on the narrower
version — the basemap is routed to ticket 06 (§15/M4) — but the claim is stated
here at its true width.

The three decisions part 1 rested on the no-grey premise survive unchanged,
because all three are about **text**: one text colour (§1.3), no `text.secondary`
token (§10.1), and errors rendered as `#FFFFFF` body copy (§9.4 here). None of
them is disturbed by an icon token.

### 0.4 The advance model, stated once

Every fit check below uses **ink ≈ k × cap_px × nChars**, with k taken from
§0.3 row 6 at its **pessimistic end for the weight in question**: Regular
**0.73**, Medium **0.65**, Bold **0.80**. A fit is only ever asserted when it
holds at that constant. This is an estimate, not a guarantee: the definitive
check is setting the string in the chosen face, which is itself blocked on
part 1's [RAISE-1].

### 0.5 The worked station

Every screen below is drawn with **CarPlay fixture S1**
(`01-carplay-design-v3.md` §3.0) unchanged, so all four runtimes render one
dataset. v1 of this file quietly used 4.1 km against the fixture's 2.4 km;
corrected (verdict **m2**).

| Field | Value | Source |
| --- | --- | --- |
| `Station.name` | `Kabisa – SP Remera` | S1 |
| `Station.nameShort` | `SP Remera` | S1 |
| `Owner.displayName` / `shortName` / `markerLabel` | `Kabisa` / `Kabisa` / `KAB` | S1 |
| Position | −1.9556, 30.1044 | S1 |
| Bays | 4 | S1 |
| Connectors | 2 × `GBT_DC` 60 kW · 2 × `IEC_62196_T2` 22 kW | S1 |
| Rate | 600 RWF/kWh on all 4 plugs, `rateConfirmedAt` = 12 days ago | S1 |
| Reports | operator, −14 min: B1 Free · B2 Occupied · B3 Free · B4 Occupied | S1 |
| Derived at t = 0 | `n=4 f=2 o=2 x=0 u=0` — **Regime 2** | S1 |
| Derived at t = +6 h | `n=4 u=4` — **Regime 1**, by operator decay | ADR-0002 |
| **Straight-line distance** | **2.4 km** — the shared figure, rendered `~2.4 km straight line` on both CarPlay and the phone | S1 |
| Driving distance / duration (phone only) | **2.9 km / 8 min** — *fixture data, not a measurement*; the phone is the only surface that renders it (ADR-0004 forbids duration on car surfaces) | this file |

**Availability is drawn Unknown first, everywhere.** ADR-0002: `Unknown` is the
normal case (~87% of the country), not a failure. Every screen below shows the
**Regime 1** variant as its primary rendering, with the reported variants after.
Any screen whose primary drawing shows a confident green state is drawn wrong.

v1 was criticised internally for drawing Regime 1 while claiming S1 as its
fixture, since S1 carries operator reports. It is the **same station at a
different clock time**: S1 at t = 0 is Regime 2; at t = +6 h its operator
reports decay and S1 *is* Regime 1 with `n=4, u=4`. One fixture, two renders, no
second dataset.

---

## 1. The five substitutions the ticket names

All five are clean. Each keeps the component's every measured property and
changes only its content.

| # | Reference | EV Guide | Component unchanged? |
| --- | --- | --- | --- |
| 1 | car pin (`01`, `03`) | **charger pin** | Yes — 10-v2 §7.3 geometry, colours and stroke identical; only the glyph drawing changes (line-art vehicle → line-art charge point), same `#393939`, same 5–6 px stroke, same ink width inside the inner disc |
| 2 | rental card (the `03` card composition) | **station card** | Yes — 10-v2 §7.4 slots reassigned in §8/D-02; no geometry moves |
| 3 | `135 000 RWF` Bold + `/day` **lighter tail** | **the R4 short rate projection** (§13.2) | Yes — the reference's composition is *amount-and-currency Bold + a lighter slash-unit tail*, and `rateShort` takes it verbatim. cap 27 on the card, cap 36 on the sticky bar. **[weight unsettled: RAISE-15]** — the amount is Bold in both slots (stem/cap 0.192), but the tail measures **Regular** on `04`'s sticky bar (4.36 px stem, 0.121) and **ExtraLight** on the `03` card (1.65 px, 0.061). This row previously said *"Regular"* for both. **Never a per-Connector rate rendered as the station's** — see §13.2 |
| 4 | `Check Availability` (sticky CTA, `04`) | **`Directions`** | Yes — 10-v2 §7.8, **513 × 131 px = 171.0 × 43.7 pt** [m, §7.8; core, and §0.1 records this one reads the same under all three extent conventions], radius **16.5 px** [ticket 33], `#C7FC2F`, label cap 32 **Medium** `#121212`. 10 chars at k = 0.65 → 208 px in a 513 px button ✓ |
| 5 | `Let's find a car` (primary CTA, `01`/`03`) | **`Let's find a charger`** | Yes — 10-v2 §7.1, **899 × 138 px = 299.7 × 46.0 pt** (frame x64 → 962; published AA-inclusive, [RAISE-14]), radius **16.5 px** [ticket 33], label **cap 36** Medium `#121212`. **[RE-DERIVED, ticket 32]** — 20 chars at k = 0.65 → `20 × 0.65 × 36` = **468 px** inside 899 px ✓ (this row read *481 px inside 897 px*, computing the ink at the stale cap 37 against the stale core width; the verdict is unchanged and the margin is wider, not tighter). The reference's own 16-char label measures 340 px [m·11] |

Substitution 4 is the ticket's named mapping and it is worth stating why it is
exactly right rather than merely available: `Check Availability` in the
reference is *the rental's commit action*. In EV Guide the commit action is
going there. Availability is not a thing you tap to check — it is already on the
screen, derived, and there is no server call that would tell you more.

Substitution 5's destination is **not a new screen**: see §8, D-02.

**A width that is not a token.** The **899 px** CTA is *not* a full-width button
and must never be tokenised as one. §0.3 row 5: it is `contentWidth − gap −
locateButton`, and at 10-v2's figures that identity closes exactly —
`1078 − 40 − 139 = 899`. **There is no full-width CTA anywhere in the four
references**, and any screen that stacks 899 px buttons has inherited a number
that means something else (verdict **M6**; fixed in §8, S-01).
**[RE-DERIVED, ticket 32]** — this paragraph said 897 px in both places; the
*claim* is unchanged and is now the stronger for closing on the measurements.

---

## 2. The pin — availability without new visual language

The ticket's headline question. The reference pin affords **one accent-bearing
surface (the 2 px `#C7FC2F` outline) and one glyph slot**. EV Guide has four
states plus freshness, and the majority state is `Unknown`.

### 2.1 What is ruled out, and why

| Channel | Why it cannot carry availability |
| --- | --- |
| **Outline colour** | Four states need four colours. Part 1 §1.1 / §10.1: the accent is *exactly one value, no tints, no gradients* — verified across four screens. Three new colours is three new tokens, i.e. new visual language. Ruled out. |
| **Glyph substitution** | Four glyphs for four states. Also a category error: availability is a property of a **Connector**, never of a Station (ADR-0002), and a pin is a Station. A station-level state glyph asserts something the model forbids. Ruled out. |
| **Pin fill / disc colour** | `#F3F3F3` and `#FFFFFF` are the only two pin surfaces and they are 6 units apart — not a signalling range. Ruled out. |
| **Size, opacity, motion** | No size variation, no opacity ramp and no motion exists anywhere in the reference (part 1 §9: *no shadow, no blur, no border, no scrim on any product surface*). Ruled out. **[RE-DERIVED, ticket 32]** — this cited v1's absolute *"there are none, anywhere"*; 10-v2 §9 narrows it to two **sub-threshold** exceptions (a rendered ±8/±14-level ramp above and below the `04` hero, and a 1-level `#111111` band hugging `02`'s `#393939` surfaces), neither tokenised and neither an opacity, size or motion channel. The ruling-out is unaffected. |

### 2.2 The decision

**The pin carries the reference's own status dot, drawn only when a bay is free
for this driver.** Nothing else about the pin changes, ever.

The status dot is a measured component, not a new one — part 1 §7.9, the mark on
the map avatar: ⌀ **20–21 px = 7.0 pt** (`size.statusDot` = 20 = 7.0 pt), fill
`#C7FC2F`, ring `#FFFFFF` ≈4 px, no shadow. Its ink box measures x 168–187,
y 367–387 on `01` against an avatar at x 64, y 362, ⌀129 — **centre offset
(+49, −49) px** [m, 10-v2 §7.9]. **[RE-DERIVED, ticket 32]** — this file read
the offset off its own ink box as `(+49, −49.5)`; 10-v2 §7.9 measures
**(+49, −49)**, and the half-pixel is exactly the ±0.5 a ⌀20–21 dot leaves free.
Nothing computes from the half-pixel: §2.4's collision arithmetic already uses
`d = 49√2 = 69.3`, which is the (+49, −49) value.

**The rule, in one line:** the dot is drawn when
`f = freeBaysOffering(T) > 0` at render time — lensed by the driver's connector
profile `T` when one is set, unlensed (`T = ∅`) when not — and is absent
otherwise.

```
      Unknown  (THE NORMAL CASE)      Free for me            Busy / OutOfService
           ╭───────╮                      ╭───────╮ ●             ╭───────╮
           │  ⌁▭   │                      │  ⌁▭   │               │  ⌁▭   │
           ╰──╲ ╱──╯                      ╰──╲ ╱──╯               ╰──╲ ╱──╯
              ▽                              ▽                       ▽
      plain pin, complete              plain pin + dot          plain pin, complete
      listing, no apology
```

### 2.3 Why this is the right answer and not merely an available one

- **It is ADR-0002's own instruction, executed literally**: *"availability as an
  additive badge when it exists."* The dot exists or it does not; there is no
  third rendering and no grey.
- **The reference already uses this mark additively, twice** — the map avatar's
  dot and the `Messages` notification dot on `02` are the same construction and
  both mean *there is something here*, drawn only when true. Re-tenanting the
  mark is a content change, not a language change.
- **Freshness needs no channel at all.** `f` is derived under ADR-0002 decay and
  recomputed at `nextDecayDeadline` (docs/availability-display.md §1.3), so the
  dot decays out by construction. Its *existence is* its freshness claim, and a
  stale dot is unrepresentable rather than discouraged.
- **It answers "free for me", not "free"** — the lens rides in `f`, which is the
  domain trap the whole model exists to avoid.
- **It cannot render the map as a field of failure.** At ~87% Unknown, any
  scheme that *marks* Unknown paints the country as broken. This one marks only
  the ~13% that is positively actionable.

### 2.4 The dot's geometry, re-derived — [RAISE-D26]

v1 scaled the avatar's offset onto the pin by axis ratio and got (+46, −46).
Re-derived here from the pin's own measured geometry, that placement **destroys
the mark** (verdict **M13**).

**Measured pin geometry** [m·11], from the isolated pin at x 967–1088,
y 991–1137 on `01`. **10-v2 §7.3 and `size.pin` now agree with this file at
122 × 147** — the correction ran the other way, and file 10 was brought into
line under ticket 32 (its own x-range x961–1082 always spanned 122; the `120`
was the width at which px/3 lands on a round `40.0 pt`, which §0.1 forbids).
**Do not "correct" 122 back to 120.**

| Property | Value |
| --- | --- |
| Outer bbox | **122 × 147 px = 40.7 × 49.0 pt**, w : h ≈ **1 : 1.20** [m·11, and 10-v2 §7.3 / `size.pin`]. AA-inclusive is 124 × 148 ([RAISE-14]); the left and right extremes are **hard edges**, so this was never a core/AA question |
| Head | a circle of **⌀122 px** at its widest, centre (1027.5, 1052) — the widest row is y 1052, 61 px below the top. **Its outer radius is 61 only across the widest band; a cut outside that band reads 120, i.e. radius 60** [m, 10-v2 §7.3: *"The widest rows are y808–817; a cut outside that band reads 120"*] |
| Lime rim | `#C7FC2F`, **2 px = 0.67 pt** (the system's one hairline, 10-v2 §4.4), riding the body's edge — outer extent **61** at the widest rows, **60** elsewhere |
| White body ring | `#FFFFFF`, radius ≈**48.5 → 60** [d] — the annulus between the inner disc and the rim |
| Inner disc | `#F3F3F3`, **⌀ ≈97 px = 32.3 pt** (radius ≈48.5), inset ≈8 px from the body [m, 10-v2 §7.3] |
| Tip | y 1137, 85 px below the head centre |

**[RE-DERIVED, ticket 32]** — two rows moved. The **inner disc** read
*"radius ≈50 (⌀100)"*; 10-v2 §7.3 measures **⌀ ≈97 px = 32.3 pt** over 6 292 px
of `#F3F3F3`, so the disc is radius ≈48.5 and the white body ring runs
≈48.5 → 60, not ≈51 → 59. Nothing in the dot derivation touches the disc — the
dot lands outside the head entirely — so no verdict moves. The **head radius**
is now stated as the two values it actually has, which is what makes the
re-derivation below close.

**The collision, in numbers** [d]. **[RE-DERIVED, ticket 32]** — the column
header read *"(+46, −47)"* while the sentence above it, and v1 of this file,
both say v1's scaled placement was **(+46, −46)**; the arithmetic in the column
was run at (+46, −47). Recomputed at (+46, −46):

| Quantity | Avatar (works) | Pin at v1's (+46, −46) (fails) |
| --- | --- | --- |
| Host radius | 64.5 px | **61 px** (widest band; 60 on the diagonal) |
| Dot centre distance from host centre | 69.3 px (= 1.074 × r) | **65.1 px** (= 1.067 × r) |
| Dot lime ink spans radius | 59.3 → 79.3 | **55.1 → 75.1** |
| Host's lime rim at radius | *none — the avatar has no rim* | **60 – 61** |
| Dot's white ring spans radius | 54.8 → 59.3 | **50.6 → 55.1** |
| What the ring's inner half lands on | `#FFFFFF` avatar — invisible, but harmless | **`#FFFFFF` pin body — invisible, and it is the only thing separating two lime shapes** |

So: **the dot's lime fill crosses the pin's lime rim** (55.1 < 60 < 75.1), and
the white ring that would have separated them lands on the white pin body. The
dot fuses to the rim and stops reading as a mark. The avatar escapes this only
because it has no rim — the proportion is transferable, the *context* is not.
**The verdict is unchanged at either reading of v1's offset**: at (+46, −47) the
lime spanned 55.8 → 75.8 and crossed the rim just as surely.

**Re-derivation, on the corrected pin.** **[RE-DERIVED TWICE, ticket 32 — and
the answer moves by one pixel.]** Two wrong derivations preceded this one, and
they are worth stating because the second was produced *by* this ticket:

1. **v1's arithmetic did not admit its own answer.** It wrote
   `d ≥ 61 + 14.5 = 75.5`, then divided **74.5** by √2 to reach `52.7 → 53`.
   At `d = 53√2 = 74.95` the stated constraint `d ≥ 75.5` **fails**.
2. **Ticket 32's first pass repaired the inconsistency by moving the input.**
   It set `headRadius = 60`, reasoning that 10-v2 §7.3 records the 122 "at the
   widest rows only" and the dot sits off a widest row. **That reasoning is
   geometrically false.** The head is a *circle*: its outer radius is identical
   in every direction, the 45° diagonal included. A horizontal cut 11 px off
   centre spans `2√(61.25² − 11²) = 120.5 px` — that is a **chord**, not a
   radius. Reading a chord as a radius is the same class of error as §6's
   corner-arc method ([RAISE-13]), one axis over.

**Measured, so the input is no longer in doubt [m, ticket 32].** Sub-pixel
boundary points (lime coverage `α = (G − R)/53`, edge at `x_first + (1 − α)` /
`x_last + α`) fitted by least squares over the head:

| Rows fitted | radius | centre | rms residual |
| --- | --- | --- | --- |
| 752–800 | **61.31** | (1022.0, 812.9) | 0.119 px |
| 752–806 | **61.26** | (1022.0, 812.8) | 0.120 px |
| 752–812 | **61.22** | (1022.0, 812.8) | 0.123 px |
| 752–818 | **61.13** | (1022.0, 812.6) | 0.141 px |

Independently, the widest sub-pixel row is **122.49 px at y812 → r = 61.25**.
So `headRadius = **61.25 ± 0.15**`, a circle fitted to 0.12 px. It is not 60,
and it was never 60.

```
d − ringOuterRadius ≥ headRadius
d ≥ 61.25 + 14.5 = 75.75 px        (ring outer radius 14.5 = dot lime r 10 + ring 4.5)
offset = d / √2 ≥ 75.75 / 1.41421 = 53.56   →   54
```

giving **(+54, −54) px = (+18.0, −18.0) pt** along the 45° top-right diagonal.
At that offset `d = 54√2 = 76.37 px`, so the ring's inner edge sits at
`76.37 − 14.5 = 61.87` and **clears the rim by 0.62 px** ✓. At the old
(+53, −53) the ring's inner edge is at **60.45 against a rim at 61.25** — it
**overlaps by 0.80 px**, which is precisely the fusion this whole raise exists
to prevent. The offset is **1.247 × the head radius** against the avatar's
1.074, and **it is a value the reference does not contain**.

> **This changes a locked value.** `SPEC.md` §6 carries *"at (+53, −53) px,
> tangent to the pin rim"*. It is corrected to **(+54, −54)** — the derivation
> is arithmetic on a circle fitted to 0.12 px, not a judgement call, and at 53
> the mark is not tangent to the rim but overlapping it. **[RAISE-D26]** is
> otherwise unchanged.

**The recommendation survives; the number does not.** v1's `d ≥ 75.5` did not
admit its own answer — `53√2 = 74.95 < 75.5` — and the honest consequence of
that inequality was always **(+54, −54)**. The measured head radius of 61.25
confirms it: the constraint is `d ≥ 75.75`, and 54 is the smallest integer
offset that meets it. **The value locked into `SPEC.md` §6 and repeated in
§15/M13, §16/[RAISE-D26], §8/D-01's ASCII and §17's D-01 row is one pixel
short**, and is corrected in all of them. Nothing else about the raise moves:
the design conclusion — that the reference's own proportion fuses the dot to the
rim and a tangent placement is required — is what it always was.

**Recommendation: (+54, −54) px, tangent.** Raised because it is a derived
placement, not a measured one, and because the alternative — reproducing the
proportion literally — produces a mark that cannot be seen. Reproducing an
offset is not reproducing a *mark*; the thing the reference contains is a
legible additive dot, and 1:1 on the pin means preserving that, not the arithmetic
that happened to produce it on a rimless host.

### 2.5 What the pin deliberately does not say — [RAISE-D1]

`Occupied`, `OutOfService` and `Unknown` are **indistinguishable on the pin**. A
driver cannot tell "someone reported it busy" from "nobody knows" without
tapping the pin and reading the card.

That is a knowing cost, not an oversight, and it needs a yes:

- The pin has exactly one additive channel and it is spent on the only
  positively actionable fact.
- The alternative — a second channel for hazard (`OutOfService`) — has no
  reference vocabulary. The nearest candidates (a second dot colour, a struck
  glyph, a desaturated body) all invent language, and `OutOfService` is a
  Connector fact that only rolls up to a station when *every* gun is broken.
- The cost is bounded: one tap surfaces the full grammar.

**Recommendation: accept.**

### 2.6 Three further pin raises

**[RAISE-D2] The dot carries presence, not a count.** CarPlay composites a
filled **numeral** badge carrying `f` onto its pin. The phone's status dot is
7 pt and cannot hold a digit; a disc that could would be a new size and the
numeral itself would be the first numeral-in-a-circle anywhere in the reference.
The cross-surface verdict (§3 item 4) already records pin availability as an
*undeclared* divergence between CarPlay and Android Auto — this **declares** the
phone's. Recommendation: presence-only on the phone; the count is one tap away.

**[RAISE-D3] The pin carries no Owner mark.** CarPlay composites `Owner.icon` +
`markerLabel` (≤3 chars) into its pin so twelve pins from three Owners stay
distinguishable. The phone pin's glyph slot is monochrome `#393939` by
measurement and `Owner.icon` is a colour vector; dropping a colour logo in
breaks the measured pin, and the reference's own seven pins are identical.
Recommendation: one uniform charger glyph on the phone; Owner identity is
carried by the station card and the detail's owner row. This is a **third**
per-surface pin treatment and it is declared, not discovered later.

**[RAISE-D4] There is no selected-pin treatment, and no cluster mark.**
Verified: all seven lime outlines in `03` measure **122 × 147 px** *while a card
is open* — the reference genuinely does not highlight the selected pin. (10-v2
§7.3, `size.pin` and §8.1 row 4 all now carry 122 × 147; this is the third of
this file's three statements of the pin's bbox and all three were already
right.)
Recommendation for selection: none — the card is the feedback, which is 1:1.
Clustering is different: ticket 06 assumed clustered `SymbolLayer` pins, and a
count-bearing cluster bubble cannot be derived from anything in the reference.
Recommendation: **do not cluster in v1** (ADR-0007 puts the directory at tens of
stations); if clustering is ever needed, it is a new component requiring a yes.

---

## 3. The crosshair rule

Part 1 §7.11, left open there as `[RAISE-7]`: a 2 px `#FFFFFF` horizontal rule
at y 249–250 spanning **x 64 → 1141 — exactly the content width** — terminated by
two 3 × 83 px vertical arms inset 29 px from the left end and 34 px from the
right (asymmetric by 5 px). Identical on both map screens. Attached to nothing,
enclosing nothing, moving with nothing.

**Decision: EV Guide reproduces it verbatim, on both map screens, as a static
mark with no behaviour and no state.**

It is the **content-column datum**. That is not a story invented to justify
keeping it — it is what the measurement says, and part 1 §7.11 says it in the
same words: the rule's extent `x 64 → 1141` is *"exactly the content width, same
as the card and the CTA"*, and it matches the CTA's frame left edge (x 64), the
map avatar's left edge (x 64), and the `04` hero's frame (x 64 → 1141). Every
floating element on the map screen aligns to it. It marks the top of the region
in which map chrome sits, below the status bar.

**[RE-DERIVED, ticket 32] — one caveat the extent question adds, and it does not
break the datum.** The floating card's **core** is `x 65 → 1140` (§0.3 row 2);
its **anti-aliased** extent is `x 64 → 1141`. So "identical to the card" is true
at the AA reading and one pixel out at the core reading — which is [RAISE-14],
ticket 34, not a defect in this section. The datum itself is unaffected either
way: the CTA frame, the hero frame, the crosshair and the avatar all read x 64,
and a card inset by the same 64 px margin is the same column whichever edge you
count from.

Three tempting jobs are **explicitly rejected**, because each would be inventing
behaviour a still cannot support:

- It is **not** the offline indicator (§9.1 gives that its own face).
- It is **not** a "search this area" control — the reference has no search
  anywhere.
- It does **not** animate, move, or respond to the card. Part 1 §9 and §12's
  *"Could not be measured"* list record **no motion, transition or gesture
  behaviour anywhere** — four stills cannot show one, and none is invented.

**[RAISE-D5]** The asymmetric arm inset (29 px left / 34 px right) is part 1's
[RAISE-5c] — a reference defect. Reproducing it is the literal reading of 1:1;
correcting it to 29/29 is a deviation. This file does not rule; it inherits the
ruling made on [RAISE-5].

---

## 4. The three profile quick actions

Reference (`02`): three `#393939` circles at **`size.quickAction` ⌀150 px =
50.0 pt** (measured **154 / 149 / 149** — the token rounds the reference's own
defect, part 1 [RAISE-5d]) with white stroke glyphs at **6.0–8.0 px** and cap 27
Bold labels — `Trips`, `Wishlist`, `Messages` — the third carrying a
notification dot. Circles → labels **33 px = 11.0 pt** [m, 10-v2 §5.2].

| Reference | EV Guide | Why |
| --- | --- | --- |
| `Trips` | **removed** | EV Guide never observes a charging session (CONTEXT.md, *deliberately not defined*). There are no bookings, no sessions, no history. Nothing in the model can fill this slot. |
| `Wishlist` | **`Saved`** | Direct 1:1. `SavedStation` is the heart icon; the reference's glyph is already a heart. Account-gated (ADR-0003). |
| `Messages` | **removed** | EV Guide has no messaging entity of any kind, and deliberately so — there is no driver↔operator channel anywhere in the model. The notification dot goes with it. |

That leaves one survivor, so the row must be re-tenanted or dropped. **The row
survives, with three slots:**

| Slot | Label | Glyph | Destination | Gate |
| --- | --- | --- | --- | --- |
| 1 | `Saved` | heart, 2 pt stroke, 24 pt grid | D-11 Saved | account |
| 2 | `My plug` | plug/connector, 2 pt stroke | D-09 My plug | **ungated** — device-local preference |
| 3 | `Alerts` | bell, 2 pt stroke | D-12 Alerts | account + notification permission |

Two of the three are argued, not assumed:

- **`My plug` earns prime real estate.** ADR-0002 makes the vehicle connector
  profile *load-bearing, not a nice-to-have* — it is what turns "free" into
  "free **for me**", which is the product's entire differentiator. The reference
  offers no other home for it above the settings list, and burying the thing the
  map depends on inside settings would be a design error the reference does not
  force.
- **`Alerts` is the armed-`Watch` list** (ticket 30). It is specified now
  because the spec covers the product, and **built with the car effort's
  package** (ticket 23).

**The notification dot is dropped from this row**, and from the map avatar. One
mark may not carry two meanings in one product, and the status-dot component is
spent on the pin (§2.2).

**[RAISE-D6] The row's composition at v1.** If the founder ships the phone app
before ticket 30's package, `Alerts` has no destination and the row is **two
circles**, not three. The reference shows exactly one instance of this row, with
three items, and cannot arbitrate a two-item variant — and it is already a
defective row (part 1 §12 [RAISE-5](d): *"the three profile quick actions are
**not evenly spaced**: circle 1 measures ⌀154 px against ⌀149 px for the other
two, with unequal gaps"* — this file previously quantified the gaps as
**64 px / 81 px**, which part 1 does not state and which is therefore an
undeclared [m·11]; the figures are kept here only as this file's own reading and
the *unevenness*, which is the point, is part 1's). Options: (a) ship two
circles at v1 and three later, (b) ship `Alerts`
from the first release with an empty-state screen, (c) ship two permanently and
reach alerts from settings. **Recommendation: (a).**

---

## 5. `Payment & payouts`

The reference settings list (`02`), measured at 176–177 px pitch with 1 px
`#3E3E3E` dividers at y 2188 / 2364 / 2541: `Personal Information` ·
`Login & Security` · `Payment & payouts` · `Notifications` (clipped by the
capture).

EV Guide has no payments anywhere and never will — there is no payment, plan or
billing entity in the model, and the structured Rate fields are explicitly *the
whole seam a future payment effort would build on* (docs/domain-model.md).

**Decision: `Payment & payouts` → `Offline & map data`.**

| Property | Reference row | EV Guide row |
| --- | --- | --- |
| Pitch | 176–177 px = 58.7–59.0 pt (`size.settingsRow` 176 = 58.7 pt) | unchanged |
| Icon | banknote, **6.2–7.0 px integrated = 2.1–2.3 pt** stroke (token `size.iconStroke` 6 px = 2 pt), 62–68 px ink at x 45–46 | download-arrow, **same stroke, same grid, same x** |
| Label | `Payment & payouts`, x 196, cap 32 Regular `#FFFFFF` | `Offline & map data`, unchanged treatment |
| Divider | `#3E3E3E` **exactly 1 px = 0.33 pt**, **core x 39 → 1166** (AA at x 38 / x 1167), no inset | unchanged (see §5.1) |
| Trailing affordance | none | none |

Three reasons this is a substitution rather than a deletion:

1. **Nothing financial-shaped can ever take the slot**, so the choice is free —
   the only question is what deserves it.
2. **ADR-0007 requires a settings home** for the opt-in all-Rwanda map pack
   (76 MB), and ticket 17 is charged with designing that row.
3. **A driver low on charge outside Kigali is the product's defining user**
   (ADR-0007's own rationale). Offline data is the single most consequential
   setting the driver app has — the same "account plumbing" weight the payment
   row carried in the reference.

**The row-count claim, corrected** (verdict **m3**). v1 said the settings list
*"keeps the reference's row count and pitch exactly."* That is false and
contradicted its own D-04, which lists six rows signed-in. What is true:

> The reference's capture shows **four** rows, the fourth clipped. EV Guide
> keeps **all four 1:1** — three unchanged, one relabelled — and adds **two
> `[ext]` rows below the capture's cut-off** (`My plug`, `About EV Guide`).
> The reference cannot contradict a row count it does not show. **Pitch,
> divider, icon grid, stroke and label treatment are unchanged on every row,
> added or not.**

### 5.1 What "full width, no inset" means — [RAISE-D29]

Part 1 §7.6 records the divider as `#3E3E3E`, exactly 1 px, **core x 39 → 1166
(AA at x 38 / x 1167) — full row width, no inset**. Verdict **M14**: that
x-range belongs to the 38–39 px card-margin family, and this file also uses
§7.6 rows inside 64 px page margins. Stated once, so three containers do not
silently disagree:

> **`full width, no inset` is a relationship to the row's container, not an
> absolute x-range.** The divider spans its container's content box, edge to
> edge, with no additional inset of its own.

| Container | Where | Divider x-range |
| --- | --- | --- |
| Settings-list family (card margin 38–39 px) — **the measured instance** | `02` and D-04 … D-12 | **core x 39 → 1166** (AA at x 38 / x 1167) |
| Page content column (page margin 64 px) | **D-03's connector rows only** | x 64 → 1141 [d] |
| Card inner box (card x 65 → 1140, padding 64) | D-02's list detent, D-11's rows | **x 129 → 1076 = 948 px** [d] |

**[RE-DERIVED, ticket 32]** — two of the three rows moved, and neither
conclusion does. Row 1 quoted the divider's **AA extent** (x 38 → 1167) as its
core; 10-v2 §7.6 measures the core at **x 39 → 1166** with the AA at x 38 and
x 1167, so the file was reading the anti-alias as ink. Row 3 was derived from
the stale card frame (`x 64 → 1141`) and gave `x 128 → 1077 = 950 px`; at
10-v2's frame `x 65 → 1140` with `space.floatingCardPadding` 64 it is
**x 129 → 1076 = 948 px = 316.0 pt**. Every consumer of the 950 — [RAISE-D31],
S-01, S-02 and §17 — is recomputed at 948 below.

**Raised** because the reference contains exactly one container, so the
generalisation is a derivation from a single instance. **Recommendation:
accept** — the alternative is a 39 px-anchored divider floating **25 px**
outside D-03's own content column, which is visibly wrong at 1×.

---

## 6. `Switch to hosting mode` — the cross-app affordance

Reference card (`02`), part 1 §7.10: frame **x 39 → 1166, y 1448 → 1781 =
1128 × 334 px (376.0 × 111.3 pt)**, radius **15.6 px** [ticket 33], fill `#393939`, padding **39 px top and
left, 38 px bottom — not uniform**, icon tile **256 × 257 px = 85.3 × 85.7 pt**
`#3E3E3E` radius **15.2 px** [ticket 33] with a lime
**9.8 px integrated (3.3 pt)** stroke glyph — the heaviest stroke in the system —
tile→text 67 px, title cap 37 Bold, body cap 28 ExtraLight over 3 lines at 45 px
pitch.

**[RE-DERIVED, ticket 32]** — four numbers in that sentence moved and one
description did. The card is **1128 × 334 px**, not 1130 × 335; the tile is
**256 × 257 px**, not 257 × 257, and is **not square**, so it must never be
quoted as one pt figure; and the padding is **39 / 39 / 38**, not "39 px on all
four sides". The card's height closes as **`39 + 257 + 38 = 334`** [d, 10-v2
§7.10] — the identity `39 + 257 + 39 = 335` that `12-operator-admin-screens-v2.md`
§5.1 marks `[m]` is false in both the arithmetic and the marking, and is that
file's to fix. Nothing in this section computes from any of them: the card is
reproduced, not laid out, and §6.5's absent-card gap is measured between its
neighbours. The title's **cap 37 Bold is correct and stays** — 10-v2 §7.10
measures the hosting card's title at cap 37, and it is *not* the cap-36 primary
CTA label corrected in §0.3 row 6.

ADR-0006 makes driver and operator **two apps**, so this is a cross-app
affordance: open-or-install the operator app, **shown only to holders of an
Owner or Operator `Membership`**.

### 6.1 The component is reproduced exactly; only content and visibility change

```
┌──────────────────────────────────────────────────────────────┐  radius 15.6 px [t33]
│  ┌────────┐   Open EV Guide Operator                         │  #393939
│  │  ⌁→    │   You manage 3 stations.                         │  pad 39 top/left,
│  │        │   Update bay status and rates.                   │      38 bottom
│  └────────┘                                                  │  card 1128×334 px
└──────────────────────────────────────────────────────────────┘
   256×257 px      title cap 37 Bold · body cap 28 ExtraLight
   #3E3E3E tile    tile→text 67 px           45 px line pitch
   lime glyph      radius 15.2 px [t33]  9.8 px stroke
```

The tile glyph is the reference's own **car-with-arrow at 9.8 px integrated
stroke (3.3 pt) in `#C7FC2F`** — the only lime glyph in the system, and the
heaviest stroke in it — redrawn as a **charge-point-with-arrow** at the same
stroke and the same tile. Nothing else about the card changes.
**[RE-DERIVED, ticket 32]** — the stroke read *"≈9 px"*; 10-v2 §7.10 and §8.1
row 12 integrate it at **9.8 px**, and §8.2 files it at the top of the **Heavy**
band. The tile is **256 × 257 px**, not 257 × 257.

### 6.2 The four states

| State | Title | Body (2 lines, cap 28 ExtraLight) | Tap |
| --- | --- | --- | --- |
| **Membership + operator app installed** | `Open EV Guide Operator` | `You manage 3 stations.` / `Update bay status and rates.` | universal link `https://evguide.rw/operator` → resolves to the installed app |
| **Membership, app not installed** | `Get EV Guide Operator` | `You manage 3 stations.` / `The operator app updates bay status and rates.` | same universal link → OS falls through to the App Store / Play listing |
| **Membership, install state undeterminable** | `Get EV Guide Operator` | as above | same link. The label degrades to the *weaker* claim, never to a claim the app cannot observe |
| **No membership** (the ~99.9% case) | — | — | **the card is absent** |

### 6.3 Why the no-membership case is an absence and not a teaser

The reference card is a **recruitment pitch**: *"Still not an host? Take
pictures, upload your cars and start earning."* EV Guide cannot make that offer
to anyone. Ticket 11 fixes the path: **Admin creates Owners; Owners create their
own Operators.** An ordinary driver cannot self-serve into a membership by any
route, so a card inviting them to would be a lie, and a *disabled* card would
advertise a door with no handle. Absence is the only honest rendering.

Signed-out drivers hold no membership, so they see no card either — the same
branch, no special case.

Offline: membership is a user-scoped fact carried in the last sync. The card
renders from cache; an unsyncable state falls to *no membership*, i.e. absent.

### 6.4 Two engineering constraints this design creates

- **iOS**: the operator app's scheme must be declared in the driver app's
  `LSApplicationQueriesSchemes` for any install check. Both apps are the
  studio's own, so this is free.
- **Android 11+**: package visibility requires a `<queries>` element naming the
  operator package. Same.
- The **tap target is the universal link in every state**, so a wrong *label*
  can never produce a wrong *destination*. The install check only chooses words.

### 6.5 [RAISE-D7] The gap the absent card leaves

Measured on `02`: quick-action labels → card = **154 px**; card → `Settings`
heading = **164 px**. With the card absent, those two gaps collapse into one and
the reference cannot say which value survives.

**Recommendation: 164 px** — the heading keeps its own approach distance, and
164 is the larger, so nothing crowds.

---

## 7. The route preview, inside the existing screens

ADR-0004 requires a preview — route line, real driving distance, ETA — and the
reference contains **no route screen**. ADR-0004's own consequence section says
so.

**Decision: the preview is split across two slots that already exist.**

### 7.1 The route line goes on the map, in the map + card screen (D-02)

A Valhalla polyline from the driver's position to the selected station, drawn on
the MapLibre map beneath the existing card. Colour **`#C7FC2F`** — the only
accent, and the reference already spends it on the map (pin outlines), so a lime
line adds no colour to the map's budget. Round caps and joins, matching the icon
system's only stated join rule (part 1 §8.4: *rounded caps and joins, no
mitres*).

**[RAISE-D8] The route line's width has no reference value.** The reference's
entire line vocabulary is 2 px (pin outline, crosshair rule, the link's
underline — `size.hairline`), 2.5 px (chip border), 3 px (crosshair arms),
**6.0–6.5 px** (the nominal icon stroke and the mode of the set), and **9.8 px**
(the hosting tile glyph, the heaviest in the system) — none of them a line drawn
*on the map*. **Recommendation: 12 px = 4 pt**, twice the icon stroke, which
reads at map zoom without competing with the pins. This is the **one invented
dimension in the whole driver design** and it needs a yes.
**[RE-DERIVED, ticket 32]** — the tile glyph read *"≈9 px"* (10-v2 §8.1 row 12:
**9.8**) and the icon stroke was quoted as a flat 6 px; 10-v2 §8.2 narrows that
to a **nominal** 6.0–6.5 px against a measured range of **4.2 – 9.8 px**. The
recommendation is unaffected: 12 px is still twice the nominal and still clear
of the heaviest measured stroke.

### 7.2 The distance and duration go in the category-chip slot — re-solved

The `03` chip measures **254 × 76 px = 84.7 × 25.3 pt** [m·11, and 10-v2 §7.5],
x 480–733, y 2030–2105, **a pill** — ½ integrated height 38.4 px [ticket 33],
`#393939` fill, `#C7FC2F` 2.5 px border, label cap 27 Regular `#C7FC2F`. Its
label ink is x 566–703 = 138 px for `Hybride`, giving **86 px of left padding
against 30 px of right** — part 1's [RAISE-5a] defect, measured again here only
because the fit arithmetic needs it.

**86 / 30 is this file's number and it is the correct one.** 10-v2 §7.5 and
§12/[RAISE-5a] carried **88 / 29** until ticket 32 and have been **corrected to
86 / 30 to match this file**. The reconciliation is what settles it:
`566 − 480 = 86`, `733 − 703 = 30`, and **`86 + 138 + 30 = 254` closes exactly
at the edge the 254 is quoted at**, where `88 + 138 + 29 = 255` reconciles with
nothing. The asymmetry — the point [RAISE-5a] makes — is untouched. **Do not
"correct" this back to 88 / 29.**

It carries **`8 min · 2.9 km`**.

This is the correct tenant, for four reasons:

1. In the reference the chip is **redundant** — it repeats `Hybride`, the first
   token of the subtitle directly above it. It is the one slot on the card
   carrying no unique information, so re-tenanting it costs nothing.
2. Accent throughout this system means *actionable, yours, now* — the CTA, the
   link, the active page indicator, the status dot. A route computed for **this
   driver from this position right now** is exactly that.
3. It is **additive**, like every other accent mark: absent until the route
   resolves, absent when there is no location, absent offline. The reference has
   no spinner or skeleton anywhere and none is introduced.
4. Availability must **not** go here, per **R2** — a lime-bordered chip on ~87%
   of stations reading *no confirmed status* is the outcome ADR-0002 forbids by
   name.

**The fit, checked against the chip and not the column** — verdict **M5**. v1
checked `~4.1 km straight line` against the card's *content column* and declared
it fitted. The chip is 254 px. Checked properly, at Regular k = 0.73 (§0.4) and
with the measured 86/30 padding:

| String | chars | label ink [d] | chip width [d] | chip right edge from x 480 |
| --- | --- | --- | --- | --- |
| `Hybride` (reference) | 7 | 138 px [m·11] | **254 px** [m·11] | 733 |
| `8 min · 2.9 km` | 14 | 276 px | **392 px** | **871** |
| `~2.4 km straight line` | 21 | 414 px | **530 px** | **1009** |

Both fit **only if the chip grows with its content.** At a fixed 254 px neither
fits and the placement is impossible.

**[RE-DERIVED, ticket 32] The chip fit is unchanged and [RAISE-D27] stands.**
Recomputed at 10-v2's values in full: the padding is 86 / 30 (10-v2 §7.5, as
corrected to match this file), the label ink is `14 × 0.73 × 27` = **276 px** and
`21 × 0.73 × 27` = **414 px**, and the chip widths are **392** and **530 px**
against a fixed **254 px** — 1.5× and 2.1× over. Two arithmetic slips in the
last column are corrected: the reference row states the chip's right edge
**inclusively** (`480 → 733` is 254 px), so a 392 px chip from x 480 ends at
**x 871** and a 530 px chip at **x 1009**, not 872 and 1010. Neither number is
load-bearing — the verdict turns on the widths, not the edges.

**[RAISE-D27] The category chip's width behaviour cannot be measured.** The
reference contains exactly **one** category chip, so one width. The only chip
whose width behaviour *is* measured is the sibling **feature chip** (`04`), which
part 1 §7.5 records as *"width fits content (**271 / 316 / 387 / 652 px**
measured)"* — **four** instances, four widths, one height. **Recommendation: the
category chip is content-sized**, on the strength of the system's only measured
chip-width rule. That is a citation across components, not an invention, but it
is still a derivation from a single instance and needs a yes. If the answer is
no — if the chip is fixed at 254 px — **the route preview cannot live in the
chip and the placement is an impossibility**, which is the honest alternative and
is recorded as such rather than papered over.
**[RE-DERIVED, ticket 32]** — this cited part 1 for *"271 / 652 px measured"*
and called it *two* instances. 10-v2 §7.5 measures **four** (271 / 316 / 387 /
652). The recommendation is unchanged and its evidence is **stronger**: four
widths at one height is a content-sizing rule observed four times, not twice.

Content-sizing carries the 86 px left padding with it, which will look wrong on
a route string. That padding is part 1's [RAISE-5a] and this file inherits the
ruling; it does not correct it here.

**The chip is a label, not a control** (verdict **M7** — see §12.3).

### 7.3 Offline and failure — what it degrades to

| Condition | Chip | Route line |
| --- | --- | --- |
| Online, location known, route resolved | `8 min · 2.9 km` | drawn |
| Route in flight | **absent** | absent |
| Route failed (server error) | `~2.4 km straight line` | absent |
| **Offline** (ADR-0007) | `~2.4 km straight line` | absent |
| No location permission | **absent** | absent |

`~2.4 km straight line` is exactly ADR-0007's amendment for a marked
straight-line figure, and the `~` + `straight line` form is the wording CarPlay
already ships **with the same number** (§0.5), so one product carries one
phrasing over one fixture.

**The `Directions` CTA is never gated on any of this** (ADR-0007: *"the Google
Maps hand-off button is never gated on the preview"*), and it is never gated on
an account (ADR-0003 as amended, ticket 23).

### 7.4 What the preview must not promise

ADR-0004: ETAs shown are EV Guide's own (Valhalla) and may differ from Google's
after hand-off. The chip therefore says `8 min`, never `arrive 11:14` — a clock
time would be read as a promise about the drive EV Guide does not own.

---

## 8. The screen inventory

Twelve screens, three sheets, six non-screens.

### 8.0 Entry points — every screen, no orphans

Verdict **M11**: v1 gave several screens no way in. Corrected; this table is
exhaustive and is the index for the rest of §8.

| Screen | Entered from | Exit |
| --- | --- | --- |
| **D-01 Map home** | app launch — the root | — |
| **D-02 Map + station card** | tap a pin on D-01 · tap the CTA on D-01 (list detent) | drag the card down, or tap the map → D-01 |
| **D-03 Station detail** | **tap the station card on D-02** · tap a row in D-02's list detent · tap a row on D-11 · tap a row on D-12 | `×` → back to the caller |
| **D-04 Profile** | tap the map avatar on D-01 or D-02 | `←` |
| **D-05 Personal Information** | settings row on D-04 | `←` |
| **D-06 Login & Security** | settings row on D-04 | `←` |
| **D-07 Offline & map data** | settings row on D-04 | `←` |
| **D-08 Notifications** | settings row on D-04 | `←` |
| **D-09 My plug** | `My plug` quick action **or** settings row on D-04 | `←` |
| **D-10 About EV Guide** | settings row on D-04 · **tap the attribution mark on D-01 / D-02** | `←` |
| **D-11 Saved** | `Saved` quick action on D-04 (gated → S-01) | `←` |
| **D-12 Alerts** | `Alerts` quick action on D-04 (gated → S-01) | `←` |
| **S-01 Auth sheet** | any gated tap: heart on D-02 / D-03 / D-11 · a connector row or the bay-alert control on D-03 · `Saved` or `Alerts` on D-04 · `Sign in` row on D-04 | dismiss, or success → auto-resume |
| **S-02 Report sheet** | a connector row on D-03 · `Report availability` in S-03 | one tap commits and dismisses |
| **S-03 Overflow menu** | `⋯` on D-03 | platform dismissal |

---

### D-01 · Map home — [ref-01]

**Purpose.** The app's front door and its primary surface: every station in
Rwanda on a dark map, reachable anonymously with no account, no permission and
no connection.

```
 ┌──────────────────────────────────────────────────────────┐
 │  11:01                                    ▮▮▯ ᯤ  79      │  status bar (OS)
 │                                                          │
 │  ├──────────────────────────────────────────────────┤    │  crosshair rule §7.11
 │                                                          │  y 249–250, x 64→1141
 │   ⬤                                          ▭ Offline   │  avatar ⌀129 x64 y362
 │   avatar                                     feature chip│  offline chip §9.1
 │                                                          │
 │              ◉        ◉●                                 │  pins 122×147 px
 │                                ◉                         │  ● = free-bay dot
 │                    ◉                                     │    at (+54,−54) §2.4
 │                        ◉                                 │
 │                  ◉                                       │
 │                     ⬤ location puck                      │  §11 [RAISE-D25]
 │                                                          │
 │  © OpenStreetMap contributors                            │  attribution §11
 │  ┌──────────────────────────────────┐   ╭──╮             │
 │  │      Let's find a charger        │   │ ➤│             │  CTA 899×138 x64→962
 │  └──────────────────────────────────┘   ╰──╯             │  r 16.5 [t33]
 └──────────────────────────────────────────────────────────┘  locate ⌀139, gap 40
```

**Components:** map canvas `#212121` · crosshair rule (part 1 §7.11) · map
avatar (§7.9, ⌀129 px `#FFFFFF`, x 64, y 362, **no status dot** — §4) · charger
pins (§7.3 + §2.2/§2.4) · primary CTA (§7.1, **899 × 138 px**, frame x 64 → 962)
· locate button (§7.2, ⌀139 px `#FFFFFF` with a 4 px lime ring and the system's
**only filled glyph**, `size.circleButton.xl` = 139 = 46.3 pt, 40 px from the
CTA) · attribution mark (§11) · offline chip (§9.1).

**Behaviour**

| Element | Action |
| --- | --- |
| Avatar | push **D-04** |
| Pin | select → **D-02** (card opens, no screen change) |
| Locate `➤` | recentre on the driver; if permission not granted, request it |
| CTA `Let's find a charger` | expand the card to its list detent — D-02's second detent, **not a new screen** |
| Attribution mark | push **D-10** |
| Crosshair rule | **none** — a static mark, §3 |
| Map pan / zoom | pans; `stationsNear` re-queries on the viewport centre |
| Offline chip | none — a label |

**States**

| State | Rendering |
| --- | --- |
| **Default / first run, no connection** | Fully populated. ADR-0007 ships the Kigali basemap (5.6 MB) and a directory snapshot **inside the binary**, so pins paint immediately with every availability honestly Regime 1. **There is no loading state for the directory, ever.** |
| **Loading** | None exists. Tiles that are neither bundled nor cached leave flat `#212121` — the map colour, not an error surface. |
| **Offline** | The offline chip appears (§9.1). Nothing else changes. Panning outside the bundled Kigali extent without the Rwanda pack shows flat `#212121` with pins still drawn in their true positions. |
| **No location permission** | The puck is absent; the locate button still renders and requests on tap. `stationsNear` uses the **viewport centre** as origin — never a hardcoded "device location". No distances are shown anywhere until a position exists. |
| **Signed out** | Identical. The whole read surface is anonymous (ADR-0003); the avatar takes the measured empty state — see D-04. |
| **Error** | No error state. A failed sync leaves the cached directory; a failed tile leaves `#212121`. |
| **Empty** | Not reachable — the bundled snapshot is never empty. |

**Strings:** `Let's find a charger` · `Offline` (app copy) ·
`© OpenStreetMap contributors` (licence text — **not** app copy, §11).

---

### D-02 · Map + station card — [ref-03]

**Purpose.** Answer, without leaving the map, the four questions a driver has
about a pin: what is it, can I charge there, how far, what does it cost.

**The card is a floating card, not an edge-anchored bottom sheet** — verdict
**M2**, measured in §0.3 row 2. Frame **x 65 → 1140, y 1797 → 2317**
(**1076 × 521 px = 358.7 × 173.7 pt**, `size.floatingCard`; AA columns at x 64 /
x 1141 and an AA row at y 1796), **all four corners at 19.5 px** [ticket 33], fill `#121212` — *the page background*,
on a `#212121` map — no shadow, no scrim, no dimming, **64 px internal padding**
(`space.floatingCardPadding`) on left, right and bottom, and **64 px of visible
map between its bottom edge and the CTA** (`space.floatingCardBottomGap`; rows
2318–2381 inclusive are map, and the CTA's accent begins at **y 2382**). Drag
handle **180 × 13 px = 60.0 × 4.3 pt** `#262626`, fully rounded, centred on the
card's centre x 602.5, **25 px = 8.3 pt below the card's top**.

**[RE-DERIVED, ticket 32]** — five figures in that paragraph moved, all by one
step, and all from the same root: this file read the card's **AA extent** as its
frame. Frame `x 64 → 1141, y 1796 → 2317` → **x 65 → 1140, y 1797 → 2317**; size
`1078 × 522 = 359.3 × 174.0 pt` → **1076 × 521 = 358.7 × 173.7 pt** (10-v2
publishes the floating card at its **core** extent — [RAISE-14], and the
AA-inclusive reading is exactly the 1078 × 522 this file carried, which is why
the two never looked wrong beside each other); `65 px of map` → **64 px**; the
CTA at `y 2383` → **y 2382**; the handle `26 px` below the top → **25 px**. The
card's identity, its four rounded corners, its lack of a scrim and its 64 px
padding are all unchanged.

**Layout — Regime 1, the normal case, drawn first**

```
 ┌──────────────────────────────────────────────────────────┐
 │  ├──────────────────────────────────────────────────┤    │  crosshair (unchanged)
 │   ⬤                                                      │
 │              ◉        ◉●        ═══════╗                 │  lime route line, 12 px
 │                    ◉             (§7.1) ║                │
 │                        ◉════════════════╝                │
 │  ╭────────────────────────────────────────────────────╮  │  floating card, 1076×521
 │  │                   ▭▭▭▭▭▭▭▭▭                        │  │  x65→1140, y1797→2317
 │  │  ┌────────┐  SP Remera                        ♡     │ │  r 19.5 all [t33]
 │  │  │ photo  │  4 bays · no confirmed status           │ │  handle 180×13 #262626
 │  │  │100×100 │  ╭───────────────╮                      │ │  title cap 36 Bold x483
 │  │  │  pt    │  │ 8 min · 2.9 km│                      │ │  subtitle cap 27 Regular
 │  │  └────────┘  ╰───────────────╯                      │ │  heart #717171 [m·11]
 │  │                                      600 RWF/kWh    │ │  rateShort, cap 27
 │  ╰────────────────────────────────────────────────────╯  │  chip = route preview
 │            ← 64 px of map, then →                        │  content-sized, D27
 │  ┌──────────────────────────────────┐   ╭──╮             │
 │  │      Let's find a charger        │   │ ➤│             │  CTA unchanged from D-01
 │  └──────────────────────────────────┘   ╰──╯             │  accent begins y2382
 └──────────────────────────────────────────────────────────┘
```

**Measured slot map** (card frame x 65 → 1140, y 1797 → 2317; 64 px padding, so
the inner box is **x 129 → 1076 = 948 px = 316.0 pt** [d]):

| Reference slot | Measured | EV Guide content |
| --- | --- | --- |
| Drag handle | **180 × 13 px = 60.0 × 4.3 pt** `#262626`, **a pill** — ½ integrated height **6.4** [ticket 33] (a pill; ticket 33 re-fitted it and found it **never carried the bias** — 6.5 came from the constraint, not the false arc), centred on x 602.5, **25 px** below the card top [m, 10-v2 §7.4 / §5.2] | unchanged |
| Thumbnail | 300 × 300 px = 100 × 100 pt, radius **31.8 px** [ticket 33], x 128, y 1873 | `Photo[0]` |
| Title | cap 36 Bold, x 483, baseline 1921 | **`nameShort`** — `SP Remera` |
| Subtitle | cap 27 Regular, x 483, 19 px below title | **the availability clause** |
| Category chip | 254 × 76 px = 84.7 × 25.3 pt [m·11, and 10-v2 §7.5], x 480, y 2030, **a pill** — ½ integrated height 38.4 [ticket 33], lime 2.5 px border, **content-sized** [RAISE-D27] | **the route preview** (§7.2) |
| Price | cap 27, right-aligned, ink right edge **x 1075** (65 px inside the card's right edge) | **`rateShort`** (§13.2) — **[weight unsettled: RAISE-15]**: amount Bold (stem/cap 0.192), unit tail **ExtraLight** in this slot (1.65 px stem, 0.061), Regular in `04`'s sticky slot |
| Heart | ink 50 × 46 px = 16.7 × 15.3 pt, x 1025–1074, y 1881–1926, **`#717171`**, stroke **4.8–6.0 px** (10-v2 §8.2 files it in the **Light** band at 4.8 px = 1.6 pt) [m·11 + 10-v2 §7.4 / §8.1 row 17] | `SavedStation` toggle |

**Behaviour** — verdict **M11**: v1 had no behaviour table on this screen at
all, so the single most-taken action in the app (card → detail) was never
written down.

| Element | Action |
| --- | --- |
| **The station card, anywhere but the heart** | **push D-03 Station detail** |
| Thumbnail | same as the card — push D-03. There is no photo viewer anywhere in the app (§8, *deliberately not screens*) |
| Heart | toggle `SavedStation`. Signed out → **S-01**, auto-resume the save |
| Route chip | **none — it is a label** (§12.3) |
| Drag handle / card drag | up → the list detent · down → dismiss to D-01 |
| Another pin | reselect; the card's content swaps in place, the card does not close |
| Map pan / zoom | the card stays, the route line stays |
| CTA `Let's find a charger` | expand to the list detent |
| Locate `➤` | recentre |
| Avatar | push D-04 |
| Attribution mark | push D-10 |
| A row in the list detent | **push D-03** |

**Why the title is `nameShort` and not `Kabisa – SP Remera`.** Ticket 19's
routed constraint is explicit: `nameShort` is *the place, not the operator*, and
the operator belongs in icon and marker. The CarPlay **card** composes
`Kabisa – SP Remera` because that card is the last thing many drivers see; the
phone card has a detail one tap away carrying a dedicated owner row with
`Owner.icon`. `nameShort ≤ 18` characters at cap 36 Bold, k = 0.80, is
`18 × 0.80 × 36` = **≤ 518 px** inside the **542 px** column left of the heart
(x 483 → 1024; the heart's ink begins at x 1025 [m, 10-v2 §7.4]) — **it fits by
construction, for every station in the directory.** Declared as a per-surface
difference rather than left to be discovered.
**[RE-DERIVED, ticket 32]** — the column read 543 px; at the heart's measured
ink edge it is 542. The fit is unchanged: 518 ≤ 542, 24 px spare. Both numbers
are absolute x-coordinates on `03`, so the card-frame correction does not touch
them.

**The subtitle and the variant ladder.** The content column is **x 483 → 1075 =
593 px** [d] — the price slot's measured right-align edge, 65 px inside the
card's right edge at x 1140 (10-v2 §7.4 / §11.3). At cap 27 Regular and the
pessimistic k = 0.73 (§0.4) that is **30 characters per line**; at the
optimistic k = 0.667 it is 33. **The ladder is run against 30**, so it never
depends on the friendlier constant.

**[RE-DERIVED, ticket 32] — and there are two defensible right edges, 1 px
apart, so the anchor is now named.** The column was stated as
`x 483 → 1077 = 594 px`, an inner-box right edge derived from the **stale** card
frame. Two edges survive the correction:

| Anchor | Right edge | Column, inclusive | Source |
| --- | --- | --- | --- |
| The card's **inner box** | x 1076 | **594 px** | `1140 − 64` [d, 10-v2 §7.4 + `space.floatingCardPadding`] |
| The price slot's **measured ink** | x 1075 | **593 px** | [m, 10-v2 §7.4 / §11.3] — 65 px inside the card edge |

**This file runs the ladder against 593**, the measured edge, because the
subtitle shares the slot with the price and it is the ink that constrains it.
Counting is **inclusive** throughout, the same convention that makes the inner
box `1076 − 129 + 1 = 948`. `593 ÷ (27 × 0.73) = 30.09` → **30 characters per
line, unchanged** (it was 30.14 at the stale 594). **No rung of the ladder and
no variant verdict moves**, and the 60-character budget stands at either edge —
which is why the 1 px was never worth a fight, only a label.

The availability clause runs the shared drop order
(docs/availability-display.md; `02-androidauto-design-v3.md` §3.4 — drop `ago`,
then the source word, then the `busy` clause, then plural nouns; **`free`,
`out of service` and `unknown` counts are never dropped**) until it fits **two
lines** at the measured 45 px pitch — a 60-character budget.

**[RAISE-D9] Two-line subtitle.** The reference's card subtitle is one line, and
part 1 §4.3 says *no line height but body's is measurable — do not invent them*.
The 45 px pitch is measured over ten consecutive lines at cap 27–28 and is a
function of size, not weight, so applying it to a two-line cap-27 Regular run is
a **derivation**; the card's measured **521 px** height is then the one-line case
and a second line adds exactly 45 px, giving 566 px. Needs a yes, because it
makes the card content-sized. **[RE-DERIVED, ticket 32]** — the height read
522 px (the AA-inclusive extent); `size.floatingCard` is **1076 × 521**. The
raise is unaffected — what needs a yes is *that the card grows*, not by how much
from what. Regime 3's worst string cannot fit one line at any rung of the
ladder — the alternative is breaking the ladder's law, which is worse.

**Every availability variant, drawn** — all [vocab], all `busy` per **R1**, all
qualified per **M10**:

| Regime | Data | Subtitle as emitted | chars |
| --- | --- | --- | --- |
| **1 — the normal case** | `n=4, u=4` | `4 bays · no confirmed status` | 28 ✓ one line |
| **2** | `n=4, f=2, o=2`, operator −14 min | `Operator, 14 min ago · 2 of 4 bays free` | 39 ✓ two lines |
| **3** | `n=4, f=1, o=1, x=1, u=1` | ladder, see below | 59 ✓ two lines |
| **Lensed, GB/T DC** | `n_T=2, f=1, u=1` | `14 min · 1 GB/T DC bay free · 1 unknown ·` / `2 other bays` | 54 ✓ |
| **Lensed, no compatible plug** | `n_T=0` | `No GB/T DC bay here · 4 bays · Type 2, CCS2` | 43 ✓ |

**The Regime 3 ladder, run** — v1 drew this variant at 73 characters over two
lines, i.e. 37 per line, above even the optimistic budget. Corrected:

| Rung | String | chars | fits 60? |
| --- | --- | --- | --- |
| 0 (full) | `Operator, 14 min ago · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 73 | no |
| 1 — drop `ago` | `Operator, 14 min · 1 bay free · 1 busy · 1 out of service · 1 unknown` | 69 | no |
| **2 — drop the source word** | `14 min · 1 bay free · 1 busy · 1 out of service · 1 unknown` | **59** | **yes, 1 char spare** |
| 3 — drop the `busy` clause | `14 min · 1 bay free · 1 out of service · 1 unknown` | 50 | yes, but not reached |

**Rung 2 fits, so the composer stops there and `busy` survives in the card
subtitle.** [RE-DERIVED, ticket 32] Every count in this table was previously one
character high — the ladder read 74/70/60/51 against the true 73/69/59/50 — and
at the inflated count rung 2 appeared to land *exactly* on the 60-character
budget with zero margin, which is what sent the composer to rung 3. It does not:
it lands at 59. Greedy wrap at the pessimistic 30 characters per line breaks it
as `14 min · 1 bay free · 1 busy ·` (30) / `1 out of service · 1 unknown` (28),
so it is a genuine two-line fit and not a fit that only closes in the total.
**`free`, `out of service` and `unknown` all survive, as the law requires, and so
now does `busy`** — the drop order is never invoked, so no clause is lost and no
false arithmetic is possible.

The same off-by-one ran through the neighbouring table above, in the other
direction: `Operator, 14 min ago · 2 of 4 bays free` is **39** characters, not
38; `No GB/T DC bay here · 4 bays · Type 2, CCS2` is **43**, not 42; the lensed
GB/T DC string is **54**, not 53. None of those verdicts change — every one of
them fits with room — which is exactly why the error survived: it was
conservative everywhere except the one rung where it was decisive.

(The 60-character budget itself is unaffected by either correction: at the
corrected content column, `593 px ÷ (27 × 0.73) = 30.09` → **30 characters per
line**, exactly as it did before the frame correction. **Two lines × 30 = 60**,
and the budget stands.)

**Freshness leads the clause**, matching the car surfaces, and for the same
reason: a line that can truncate must truncate to something honest.
`2 of 4 bays free` surviving alone is a live claim; `Operator, 14 min ago`
surviving alone is merely less informative. Regime 1 emits **no freshness head**
— there is no state to date.

**The rate slot takes `rateShort`, never a Connector's rate** (§13.2, **R4**).
S1 has one confirmed rate, so it renders `600 RWF` **Bold** + `/kWh` in the
lighter tail weight — **[weight unsettled: RAISE-15]**, and in *this* slot the
tail measures **ExtraLight** (1.65 px stem, stem/cap 0.061), not the Regular
this file previously assigned to all four consuming slots; `04`'s sticky slot
measures **Regular** (4.36 px, 0.121). Had its GB/T guns been priced 600 and its
Type 2 guns 400, this slot would read `From 400 RWF/kWh` — **not**
`600 RWF/kWh`, which is what v1's unqualified composition would have produced:
one plug's price presented as the station's.

**The list detent.** Tapping `Let's find a charger` expands the same card to a
taller detent holding the nearby list: repeated station cards in the card's own
composition, separated by 1 px `#3E3E3E` dividers at the card's inner width
(**x 129 → 1076 = 948 px**, §5.1). **This is a detent, not a screen** — the drag handle
implies detents in the reference itself. Ordering is `stationsNear(origin, …)`
distance-first then availability. No search field: the reference contains no
search component, and a directory of tens of stations sorted by distance needs
none.

**[RAISE-D10] The list detent has two unmeasured properties.** (a) Its height —
recommendation: **~70% of screen height**, leaving the map and the crosshair
visible, since the reference's card always leaves the map visible. (b) What the
CTA does once the detent is open, since the reference shows no expanded state —
recommendation: **the CTA stays rendered and unchanged, and tapping it collapses
back to the card detent.** Both need a yes.

**States**

| State | Rendering |
| --- | --- |
| **Loading** | Card content is instant (cached directory). An uncached `Photo` renders as a **`#3E3E3E` block at the thumbnail's exact geometry** — the reference's own measured empty state. No spinner, no shimmer, no broken-image glyph: none exists in the reference. |
| **Offline** | Offline chip on the map; the route chip degrades to `~2.4 km straight line`; no route line; photos that are not cached stay `#3E3E3E`. Everything else is identical, because everything else is cached. |
| **Error** | Route failure → the straight-line form. There is no other failure: nothing else on this card requires the network. |
| **Signed out** | Identical, except the heart. Tapping it opens **S-01** and auto-resumes the save. |
| **Saved** | The heart fills `#C7FC2F`. **[RAISE-D11]** — see below. |
| **Empty** | Not reachable. |

**[RAISE-D11] The heart's two states, re-based on the measured default.** v1
assumed a white outline heart and recommended filling it lime. The measured
default is **`#717171`** (§0.3 row 4), so the progression is *muted grey outline
→ accent fill*, which is better founded: the reference already de-emphasises the
unsaved heart, and the accent already means *yours* everywhere else in the
system. **Recommendation: `#717171` outline unsaved, `#C7FC2F` fill saved.**
Still a raise, because the reference shows only the unsaved state.

---

### D-03 · Station detail — [ref-04]

**Purpose.** Everything a driver needs before committing to a drive, and the one
place per-Connector truth is reachable — so a known-broken gun is visible even
to a driver with no plug profile set (domain-model amendment 8).

**Layout — Regime 1 first**

```
 ┌──────────────────────────────────────────────────────────┐
 │  ╭─╮                                            ╭───╮     │  × ⌀80  ⋯ ⌀98
 │  │×│                                            │ ⋯ │     │  same centre y 269.5
 │  ╰─╯                                            ╰───╯     │
 │  ┌────────────────────────────────────────────────────┐  │  hero 1078×612 px
 │  │                  Photo 1 of 3                       │ │  x64→1141, y354→965
 │  │                                        ╭─────────╮  │ │  radius 31.8 px [t33]
 │  │                ▬▬  ·  ·  ·             │ ⚡ 60 kW │  │ │  badge lime near-pill
 │  │                indicator §7.7          ╰─────────╯  │ │  cap 27 Regular #FFF
 │  └────────────────────────────────────────────────────┘  │  1.21:1 — [RAISE-D28]
 │  Kabisa – SP Remera                           ♡    ↗     │  cap 47 Bold + heart/share
 │  4 bays · GB/T DC · Type 2                               │  cap 27 Regular
 │  ⬤ Kabisa                                                │  owner icon ⌀76 + cap 32 Bold
 │                                                          │
 │  Availability                                            │  cap 32 Bold
 │  4 bays · no confirmed status                            │  cap 28 ExtraLight, 45 px
 │    ⌁  GB/T DC · 60 kW · 2 plugs                          │  settings-row §7.6
 │    ⌁  Type 2 · 22 kW · 2 plugs                           │  divider x 64→1141 §5.1
 │  ┌─────────────────────────────────────────────────────┐ │
 │  │        Notify me when a bay frees up                │ │  CTA geometry, §12.3
 │  └─────────────────────────────────────────────────────┘ │  46 pt, r 5.5 [t33]
 │                                                          │  #393939
 │  Connectors                                              │  cap 32 Bold
 │  ┌──────────────────┐ ┌──────────────────┐               │  feature chips §7.5
 │  │ ⌁ 2 × GB/T DC 60 kW│ │ ⌁ 2 × Type 2 22 kW│            │  105 px tall
 │  └──────────────────┘ └──────────────────┘               │  r 13.4 px [t33]
 │  600 RWF/kWh · All 4 plugs · confirmed 12 days ago       │  #393939, cap 32 ExtraLight
 │                                                          │  Grammar R, §13.3
 │  Getting there                                           │  cap 32 Bold  [RAISE-D12]
 │  Inside the SP forecourt, entrance from KG 11 Ave.       │  cap 28 ExtraLight
 │  Chargers are behind the shop, on the left.              │  45 px line pitch
 ├──────────────────────────────────────────────────────────┤
 │  600 RWF/kWh              ┌────────────────────────┐     │  sticky bar §7.8
 │  = rateShort              │      Directions        │     │  opaque #121212
 └───────────────────────────└────────────────────────┘─────┘  513×131, r 16.5 [t33]
```

**Slot map**

| Reference | Measured | EV Guide |
| --- | --- | --- |
| Close `×` | **⌀80 px = 26.7 pt** `#393939` (x 65–144, y 230–309), `#FFFFFF` glyph at **≈3.8 px perpendicular** (the **Light** stroke band), left edge on the 64 px content margin, centre y 269.5 | dismiss |
| Overflow `⋯` | **⌀98 px = 32.7 pt** (x 1043–1140, y 221–318), 3 white dots **⌀7.6 px**, right edge on the content margin, **same centre y** | S-03 |
| Hero | **1078 × 612 px = 359.3 × 204.0 pt (1.762 : 1)**, frame x 64 → 1141, y 354 → 965, radius **31.8 px** [ticket 33] | `Photo[i]`, paginated |
| Page indicator | active **95 × 16 px = 31.7 × 5.3 pt** lime (x 512–606, y 924–939), inactive 3 × ⌀15–16 px `#3E3E3E`, gap 13–15 px, group centred on the hero's centre x 602.5, **26 px (8.7 pt) above the hero's bottom** | `Photo` count |
| Hero badge | **248 × 70 px = 82.7 × 23.3 pt** (frame x 850 → 1097, y 866 → 935; 250 × 72 with AA), **a pill** — ½ integrated height 35.4 px [ticket 33], `#C7FC2F`, **stroked lightning at ≈4.2 px** (ink 34 × 37 px) + cap 27 Regular `#FFFFFF`, 44 px inside the hero's right edge and 30 px above its bottom | **peak power** — `60 kW`, per **R2**. Absent when no Connector carries `powerKw`. **[RAISE-D28]** |
| Title | cap 47 Bold | **`Station.name`** — `Kabisa – SP Remera` |
| Heart + share | ink **66 × 62** / ~67 × 67 px, 31 px apart, both **`#FFFFFF`** [m, 10-v2 §8.1 rows 21–22] | save · share |
| Subtitle | cap 27 Regular, 20 px below title | `4 bays · GB/T DC · Type 2` |
| Owner row | avatar 76 × 76 px + cap 32 Bold, 29 px gap, 39 px below subtitle | `Owner.icon` + `Owner.displayName` |
| Owner row trailing icon | message glyph | **dropped** — see below |
| `Description` | **cap 32 Bold** + cap 28 ExtraLight, 45 px pitch | **`Getting there`** — [RAISE-D12] |
| `Basics and features` | cap 32 Bold + feature chips | **`Connectors`** |
| Sticky bar | y 2337 → 2622 = 285 px = 95.0 pt, opaque `#121212`, ≈89–90 px padding (`space.stickyBarPadding` 90 = 30.0 pt) | `rateShort` + `Directions` |

**[RE-DERIVED, ticket 32] — eleven values in that slot map moved, and one is a
drawing instruction, not a dimension.** Grouped by root:

- **The circular buttons were read AA-inclusive.** Close `×` ⌀81 → **⌀80**
  (`size.circleButton.sm` = 80 = 26.7 pt); overflow `⋯` ⌀100 → **⌀98**
  (`size.circleButton.lg` = 98 = 32.7 pt); the overflow dots ⌀6 → **⌀7.6 px**;
  and the close glyph's *"6 px white stroke"* → **≈3.8 px** — 10-v2 §8.2 files it
  in the **Light** band, and §0.1 explains the 6: v1 counted pixels touched,
  which over-reads a stroke by 1–2 px, where v2 integrates coverage. Nothing on
  this screen computes from any of them, but a build types all four.
- **The hero frame was v1's.** `1076 × 620 px` → **1078 × 612 px**, verified at
  five columns and two rows (10-v2 §0.2 row 12 / §7.7). Everything anchored to
  the hero's **bottom edge** moves with it, which is the point: the page
  indicator's *"34 px above hero bottom"* was measured to the v1 bottom at
  y 973 and is **26 px** to the measured y 965 — an **8 px placement error**, the
  largest single mis-placement this file carried. The active indicator is
  **95 × 16**, not 96 × 16.
- **The hero badge is neither figure this file had.** `249 × 71` is neither the
  core (**248 × 70**) nor the AA extent (250 × 72); it was read at a mixed
  threshold. Corrected to the core, with the AA extent named.
- **The bolt is stroked, not filled.** This is the one entry that would have
  changed the *drawing*: 10-v2 §0.2 m4, §7.7 and §8.3 show the bolt's interior
  samples **lime**, in a 15 px channel between its two limbs, and the limbs
  integrate to ≈4.2 px. **Exactly one filled icon exists in the whole system and
  it is the locate arrow.** A build following the old row would have painted a
  solid bolt and broken the icon rule.
- **The `04` heart is 66 × 62 px**, not 68 × 62 (10-v2 §8.1 row 21; §12
  [RAISE-11] gives 66–67 × 62 across the two white instances).
- **`Description` is cap 32 Bold**, not cap 31 — 10-v2 §4.1 row 10 measures 32
  from a flat `D`, and **no cap-31 run exists anywhere in §4.1**. It is a
  `type.label` sub-head exactly like `Basics and features` in the row below,
  which this file already had at 32.

**Behaviour**

| Element | Action |
| --- | --- |
| `×` | dismiss, back to the caller (D-02, D-11 or D-12) |
| `⋯` | open **S-03** |
| Hero | swipe paginates `Photo[i]`. **No tap target** — there is no full-screen viewer |
| Page indicator | none — a mark |
| Hero badge | none — a label, and per **R2** never a data value a driver must read |
| Heart | toggle `SavedStation`; signed out → **S-01**, auto-resume |
| Share `↗` | platform share sheet with the station's universal link |
| Owner row | **none.** There is no Owner screen anywhere in the app and none is invented |
| Connector row | open **S-02** for that Connector. Not at the station → non-interactive, §12.1 |
| Bay-alert control | arm / disarm; gated → **S-01**, then OS permission, then auto-resume, §12.2 |
| Feature chips | none — labels |
| `Directions` | Google Maps deep link by `lat,lng` (ADR-0004). **Ungated, always** |
| Sticky rate | none — a label |

**The owner row's message icon is dropped and nothing replaces it.** EV Guide
has no driver↔operator channel, deliberately: there is no messaging entity
anywhere in the model and no ticket creates one. This is a named content
deviation; the row's geometry, avatar size and label treatment are unchanged.

**[RAISE-D12] `Description` has no field behind it.** `Station` carries `name`,
`nameShort`, `geo`, `vehicleClassTag`, `updatedAt`, `owner_id`, Photos and Bays
— **no prose field**. Options: (a) drop the block — loses a measured region of
the reference; (b) add a nullable authored `Station.description`, admin-entered
like everything else about a station, and title the block **`Getting there`**;
(c) synthesise text from structured fields, which the model forbids
(*availability strings are derived from structured fields, never prose*).
**Recommendation: (b).** A charge point inside a petrol forecourt is the normal
Rwandan case, and *where exactly, and how do I get in* is precisely what
coordinates cannot say. Routed to ticket 19 as a schema addition. When null, the
whole block is absent.

**[RAISE-D28] The hero badge measures 1.21:1 and the reference put text in it.**
Measured: `#FFFFFF` label on `#C7FC2F` fill = **1.21 : 1** [m·11, and 10-v2 §1.2
computes the identical ratio from the same two measured hexes — the two
calculations agree to the decimal] — against
WCAG 1.4.3's 4.5:1 for text, this is not a marginal failure, it is the worst
contrast in the system by a wide margin (`#121212` on the same fill measures
15.52:1). The reference itself is unreadable here; `Hybride` is legible only
because the reader already knows the word.

**R2 already removes the danger**: availability never enters this badge, and the
badge carries peak power. This file adds the invariant that makes that safe:

> **Nothing may appear in the hero badge that is not also rendered in `#FFFFFF`
> text elsewhere on the same screen.** `60 kW` appears in the `Connectors`
> feature chips (cap 32 ExtraLight `#FFFFFF` on `#393939` = 11.55:1), so the
> badge is redundant by construction and a driver who cannot read it loses
> nothing.

**Recommendation: reproduce at 1.21:1 under the 1:1 rule, with the redundancy
invariant as the guarantee.** The one-token alternative, if the founder prefers
legibility over fidelity, is the label in `color.onAccent` `#121212` — the value
the CTA already uses on the same fill. **Raised, not chosen.**

**The `⋯` overflow.** Two items: `Share station` and `Report availability` (the
same proximity-gated flow as the connector rows — §12.1). **[RAISE-D13]** nothing
in the domain models a *non-availability* correction channel for drivers (ticket
11 gives operators a rate **flag**; drivers get nothing). If the founder wants
"report a wrong rate / wrong location / permanently closed", that is a new entity
and a new ticket, not a menu item this file may add.

**Availability block content**, in full, per regime — sub-head cap 32 Bold, body
cap 28 ExtraLight at 45 px pitch, **full 1078 px = 359.3 pt content width**, **no
ladder** (the block has room for the longest string). All [vocab], all `busy`
per **R1**. **[RE-DERIVED, ticket 32]** — this read *"358.7 pt"*, which is
`size.floatingCard`'s **width** on a different screen, not `04`'s content
column. The `04` content column is `x 64 → 1141` = **1078 px = 359.3 pt**
[d, 10-v2 §5.1 + §7.7 + §7.11 — the hero, the crosshair rule and the chips all
span it]. The block gets **2 px wider**, so *"room for the longest string"* is
if anything better founded; nothing else computes from it:

| Regime | Body |
| --- | --- |
| **1 — drawn first** | `4 bays · no confirmed status` |
| 2 | `Operator, 14 min ago · 2 of 4 bays free` |
| 3 | `Operator, 14 min ago · 1 bay free · 1 busy · 1 out of service · 1 unknown` |
| Lensed GB/T DC | `Operator, 14 min ago · 1 of 2 GB/T DC bays free · 2 other bays` |
| All broken | `All 4 bays out of service` |
| Single-bay site | `The bay is free` / `The bay is busy` / `The bay is out of service` |

Below it, **one settings-row per Connector type** (part 1 §7.6 geometry exactly:
176 px pitch, 1 px `#3E3E3E` divider **at x 64 → 1141** per §5.1, 24 pt icon at
2 pt stroke, **label at x 222**, cap 32 Regular, no trailing affordance), so
per-Connector state is reachable:

```
   ⌁   GB/T DC · 60 kW · 2 plugs · 1 out of service
   ⌁   Type 2 · 22 kW · 2 plugs
```

**[RE-DERIVED, ticket 32] The label was left behind when the divider moved.**
This row previously read *"divider at x 64 → 1141 … label x 196"*. **x 196 is
the label position in the 38–39 px settings container** — 10-v2 §5.2 measures
the relationship as *"settings row: left edge → label **158 px**"*, and
`38 + 158 = 196`. These rows sit in the **64 px page column** (that is why their
divider was moved to `x 64 → 1141` in the first place, §5.1), so the label
belongs at `64 + 158` = **x 222** [d]. As written the file moved the row's
container and left its label anchored to the old one — it contradicted its own
§5.1 ruling two sections later, and would have drawn a 26 px-narrow icon gutter
against a full-width divider. The icon's own left inset (7 px from the row's
left edge, 10-v2 §5.2) moves with the container in the same way.

**Rate line — Grammar R, quoted verbatim.** Verdict **m10**: v1 paraphrased it
and drifted (`all 4 plugs` for `All 5 plugs`, a bay-shaped `0 of 4 plugs` for
`0 of 5 plugs confirmed`). The source is `02-androidauto-design-v3.md` §3.5,
reproduced here exactly:

> | Condition | text 1 | text 2 |
> |---|---|---|
> | `c = 0` | `No confirmed rate` | `0 of 5 plugs confirmed` |
> | one distinct rate among the confirmed | `600 RWF/kWh` | `All 5 plugs · confirmed 12 days ago` **or** `3 of 5 plugs · 2 unknown · 12 days ago` |
> | two distinct rates | `600 RWF/kWh GB/T · 400 RWF/kWh Type 2` | as above |
> | ≥3 distinct rates | `From 400 RWF/kWh · 3 rates` | as above |
>
> Three deliberate choices. **`No confirmed rate`, not "no published rate"** —
> the first states EV Guide's knowledge, the second would assert a licensee is
> out of compliance with RURA Art. 27(2). **The denominator is plugs, not bays**
> — a dual-gun bay can carry two different rates, so a bay denominator is a
> category error. **`From` asserts a floor over the confirmed set only**, and the
> unknown remainder is stated in the same breath.
>
> An optional `sessionFeeRwf` appends to text 1 when present and the string
> still fits: `600 RWF/kWh + 500 RWF session`.

Grammar R is a **two-slot** grammar (Android's pane row has a title and a
subtitle). The phone's detail has one line, so **the phone's rendering rule is
`text 1 · text 2`**, joined by the system's own `·` separator. Stated once here;
not a new grammar. On fixture S1, `m = 4`, `c = 4`, one rate:

```
600 RWF/kWh · All 4 plugs · confirmed 12 days ago
```

Grammar R's own two-rate example carries a bare `GB/T`, which is not in the
closed projection — see **[RAISE-D32]**, §13.4. This file does not close it by
adopting it.

**Sticky bar.** Left slot at cap 36, amount **Bold**: **`rateShort`** (§13.2),
*not* Grammar R — the long ladder stays in the block above (**R4**).
**[weight unsettled: RAISE-15]** — the reference's run in this slot is Bold in
the amount (stem/cap 0.192) and **Regular** in the unit tail (4.36 px stem,
0.121), against **ExtraLight** in the `03` card's slot; 10-v2 §4.1 row 15 and
§7.8 still call the whole run Bold and are not corrected. `Directions` CTA
right, **513 × 131 px = 171.0 × 43.7 pt** (frame x 603 → 1115, y 2363 → 2493;
`size.ctaHeightSticky` 131 = 43.7 pt, and §0.1 records that this element's
edges are hard, so it reads the same under all three extent conventions),
radius **16.5 px** [ticket 33], label cap 32 Medium
`#121212`. Bar region y 2337 → 2622 = 285 px; bar padding **≈89–90 px**
(`space.stickyBarPadding` 90 = 30.0 pt; part 1 [RAISE-6] — the bar ignores the
content margin and that is reproduced). Bottom offset 128 px = 42.7 pt.

The tightest string in the system, checked at Bold k = 0.80 (§0.4):

| Left-slot string | chars | ink [d] | starts | ends | CTA starts at x 603 [m, 10-v2 §7.8] |
| --- | --- | --- | --- | --- | --- |
| `600 RWF/kWh` | 11 | 317 px | 90 | 407 | 196 px clear |
| `From 400 RWF/kWh` | 16 | 461 px | 90 | 551 | 52 px clear |
| **`No confirmed rate`** | 17 | **490 px** | 90 | **580** | **23 px clear** — the tightest string in the system |
| reference `135 000 RWF/day` | 15 | 433 px [m·11] | 93 | 525 | 78 px clear |

**[RE-DERIVED, ticket 32] Every row of that table survives at 10-v2's inputs,
and all four inputs are 10-v2's own.** `x 603` is §7.8's measured CTA frame
start, not a [m·11]; the padding is `space.stickyBarPadding` 90; the label cap
is 36 (§4.1 row 7); the ink figures are `k = 0.80 × 36 × nChars` — 317, 461 and
490 px, unchanged. The **23 px clear** on `No confirmed rate` is the binding
number in the whole file and it does not move. One caveat is now on the record
rather than hidden: **k = 0.80 was measured on `135 000 RWF/day`, which is a
mixed-weight run** (§0.3, [RAISE-15]), so it is slightly conservative for a
run that is Bold throughout — which is the safe direction for a fit check, and
the reason the verdict holds regardless. *(File 12 computes this same slot as a
510 px budget with 20 px clear, against this file's 513 / 23. Two budgets, one
slot, 3 px apart — that is file 12's row to reconcile, not this file's, and the
verdict is the same either way.)*

**States**

| State | Rendering |
| --- | --- |
| **Loading** | Everything but photos is cached and instant. Uncached hero → `#3E3E3E` block at the hero's exact **1078 × 612 px**, radius **31.8 px** [ticket 33]. |
| **Offline** | Offline chip under the top button row, right-aligned. `Directions` still works — the hand-off is a deep link and Google Maps owns its own offline story (ADR-0004). |
| **Error** | No error surface. There is no request this screen makes that can fail visibly. |
| **Signed out** | Identical, except the heart and the bay-alert control, which open S-01 and auto-resume. `Directions` is **ungated** (ADR-0003 as amended). |
| **Empty** | Not reachable: a Station is publishable only with ≥1 Bay and ≥1 Photo. |
| **Not at the station** | The connector rows are non-interactive and the block carries one line: `Report status when you're at the station` — §12.1. |

---

### D-04 · Profile — [ref-02]

**Purpose.** The driver's account, their three quick actions, the operator
cross-app affordance, and the settings list.

```
 ┌──────────────────────────────────────────────────────────┐
 │  ╭─╮                                                      │  back ⌀90 #393939
 │  │←│                                                      │  x39–128, y225–314
 │  ╰─╯                              82 px                   │
 │                    ╭───────────╮                          │  avatar ⌀316 outer
 │                    │           │                          │  lime ring 3 px
 │                    │  #3E3E3E  │                          │  fill #3E3E3E when no image
 │                    ╰───────────╯                          │
 │                    Shima Serein                           │  cap 55 Bold (display)
 │                Show and edit my profile                   │  cap 27 Regular #C7FC2F
 │                                                           │
 │        ⬤          ⬤          ⬤                            │  ⌀150 #393939, 6 px glyphs
 │      Saved      My plug     Alerts                        │  cap 27 Bold labels
 │                                                           │
 │  ┌─────────────────────────────────────────────────────┐  │  hosting card §6
 │  │ ┌────┐  Open EV Guide Operator                      │  │  only with a Membership
 │  │ │ ⌁→ │  You manage 3 stations.                      │  │
 │  │ └────┘  Update bay status and rates.                 │  │
 │  └─────────────────────────────────────────────────────┘  │
 │                                                           │
 │  Settings                                                 │  cap 36 Bold x40
 │   👤  Personal Information                                │  176 px pitch
 │  ────────────────────────────────────────────────────     │  1 px #3E3E3E x39→1166
 │   🛡  Login & Security                                     │
 │  ────────────────────────────────────────────────────     │
 │   ⭳  Offline & map data                                   │  ← replaces Payment & payouts
 │  ────────────────────────────────────────────────────     │
 │   🔔  Notifications                                        │  ← last row in the capture
 │  ────────────────────────────────────────────────────     │
 │   ⌁  My plug                                              │  [ext] — below the cut-off
 │  ────────────────────────────────────────────────────     │
 │   ⓘ  About EV Guide                                       │  [ext] — below the cut-off
 └──────────────────────────────────────────────────────────┘
```

**[RE-DERIVED, ticket 32] — three annotations in that drawing moved.**

- **Back `←` is ⌀90 px = 30.0 pt**, not ⌀91: 10-v2 §7.2 measures it at
  x 39–128, y 225–314, and `size.circleButton.md` = 90. ⌀91 was the AA-inclusive
  read, the same defect as the `04` close and overflow buttons. Its left edge is
  the **38–39 px card margin** (10-v2 §5.1), which the old annotation had right.
- **The `Settings` heading is cap 36 Bold**, not cap 37. 10-v2 §7.6 measures the
  section heading at **cap 36 px Bold, x 40**. §4.1 row 3 does carry 37, but with
  the asterisk that §4.1's own note explains: `Settings` begins with a **round**
  `S`, whose bowl overshoots and reads 1–2 px taller than a flat cap at the same
  size — §3.3 measures the same run at **35–36** from a flat glyph. §4.2 folds
  36/37 into one `heading` step for exactly this reason. Corrected here, at D-05
  and at D-11. **Note what is *not* corrected here: the hosting card's title
  (§6), which 10-v2 §7.10 publishes as cap 37 Bold.** A find-and-replace on
  "cap 37" would have changed it too, and the two runs must be decided
  separately.

  **But it is not safe either, and this file said something false about it.**
  [RE-DERIVED, ticket 32] An earlier pass justified keeping 37 by claiming it was
  *"measured from a flat `O` in `Open EV Guide Operator`'s reference original"*.
  Every part of that is wrong: `Open EV Guide Operator` is **EV Guide's
  replacement copy, invented in §6 of this file** — the reference original is
  **`Switch to hosting mode`** (10-v2 §4.1 row 4), which contains no `O` at all.
  Worse, 10-v2's own §3.3 lists *"`S` in `Switch to hosting mode`"* as one of its
  named **round-cap over-reads** — the identical asterisk being applied to
  `Settings` two paragraphs above.
  Measured [m·11, ticket 32]: the glyph runs of `Switch to hosting mode` are
  `S` 37 · `w` 27 · `i` 37 · `t` 35 · `c` 27 · `h` 37 · … — **the only capital
  in the string is the round `S`**, and every other 37 px glyph is a lowercase
  **ascender**, not a cap. There is no flat capital anywhere in the run, so
  **cap 37 cannot have been measured from one**, and the true cap is very likely
  35–36 as it is for `Settings`. Left at 37 because it is 10-v2's published
  value and changing it is 10-v2's call, not this file's — **flagged to
  [RAISE-13]'s ticket as a second measurement owed**.
- **The divider's core is x 39 → 1166**, with the anti-alias at x 38 and x 1167
  (§5.1).

**Settings list, both auth states**

| Row | Signed in | Signed out | Destination | Ref? |
| --- | --- | --- | --- | --- |
| `Personal Information` | ✓ | — | D-05 | [ref-02] |
| `Login & Security` | ✓ | — | D-06 | [ref-02] |
| `Sign in` | — | ✓ | S-01 | [ext] |
| `Offline & map data` | ✓ | ✓ | D-07 | [ref-02] (relabelled, §5) |
| `Notifications` | ✓ | ✓ | D-08 | [ref-02] |
| `My plug` | ✓ | ✓ | D-09 | [ext] |
| `About EV Guide` | ✓ | ✓ | D-10 | [ext] |

The last two are **below the reference's cut-off** and are `[ext]` rows built
from the measured row component with no change to pitch, divider, icon grid,
stroke or label treatment (§5, corrected row-count claim).

**Behaviour**

| Element | Action |
| --- | --- |
| Back `←` | pop to D-01 / D-02 |
| Avatar | **none.** Editing the photo lives on D-05; the reference gives the avatar no affordance and none is added |
| `Show and edit my profile` link | push **D-05** |
| `Saved` quick action | push **D-11**; signed out → S-01, auto-resume |
| `My plug` quick action | push **D-09** — always, no gate |
| `Alerts` quick action | push **D-12**; signed out → S-01, auto-resume |
| Hosting card | universal link `https://evguide.rw/operator` (§6.2), every state |
| Any settings row | push its destination, per the table above |

**States**

| State | Rendering |
| --- | --- |
| **Signed in** | As drawn. `Shima Serein` cap 55 Bold; lime link `Show and edit my profile`. |
| **Signed out** | Avatar renders its measured empty state — ⌀316 px, `#3E3E3E` fill, 3 px `#C7FC2F` ring — **unchanged**, because that is exactly what the reference captured. Display line: `Not signed in`. Lime link: `Sign in to save and report`. Quick actions all present; `Saved` and `Alerts` open S-01 and auto-resume; `My plug` opens directly. Hosting card absent. |
| **No membership** | Hosting card absent; the labels→`Settings` gap is 164 px [RAISE-D7]. |
| **Loading** | None — every field is local. |
| **Offline** | Offline chip under the back button, right-aligned. Rows that need the network on tap (`Personal Information`, `Login & Security`) still open and show their cached values. |
| **Error** | None on this screen. |

---

### D-05 · Personal Information — [ext]

**Assembled from:** back button (part 1 §7.2, **⌀90 px = 30.0 pt**) · section
heading (**cap 36 Bold**, x 40) · settings rows (§7.6, divider core
**x 39 → 1166**) · profile avatar (§7.9).

**Purpose.** View and edit the account's name, email and photo.

**Layout:** back button · heading `Personal Information` · avatar ⌀316 centred
with its lime ring · rows `Name` / `Email` / `Photo`.

**Behaviour:** back `←` pops to D-04 · each row opens its edit affordance in
place, using the [RAISE-D21] text input · `Photo` opens the platform picker.

**[RAISE-D14] Settings rows carry no value slot.** Part 1 §7.6 is explicit: *no
chevron, no trailing affordance*. A settings screen that shows `Name` without
showing the name is useless. Recommendation: **compose the row with the card's
right-aligned price treatment** — value at cap 27 Bold `#FFFFFF`, right edge at
**the divider's own right end, which is its container's right edge**: **x 1166**
in the 38–39 px settings container, x 1141 in a 64 px page column (§5.1). Both
halves are measured components; the composition is not. Used by D-05, D-06,
D-07, D-10 and D-12. Needs a yes. **[RE-DERIVED, ticket 32]** — this said
*"x 1167"*, the divider's **anti-aliased** right column; 10-v2 §7.6 puts the
core at x 1166. Right-aligning ink to an AA column would set every value one
pixel proud of the rule it is meant to align with.

**States.** Signed-in only (unreachable otherwise). Offline: values render from
cache, edits queue or are refused with `You're offline. Try again when you're
back on.`. No loading state — the account is local. Error: the body line is
replaced in place; there is **no error colour in the token set**, so every error
string is `#FFFFFF` body copy where it belongs.

**Strings:** `Personal Information` · `Name` · `Email` · `Photo` ·
`You're offline. Try again when you're back on.`

---

### D-06 · Login & Security — [ext]

**Assembled from:** back button · heading · settings rows with the [RAISE-D14]
value slot.

**Purpose.** Show which providers are connected, sign out, delete the account.

**Rows:** `Apple` / `Connected` · `Google` / `Not connected` · `Email` /
`shima@…` · `Sign out` · `Delete account`.

**Behaviour:** back `←` pops to D-04 · a provider row starts or unlinks that
provider · `Sign out` signs out locally and pops to D-04 · `Delete account`
opens the platform confirmation, then deletes.

`Delete account` is not optional: App Store Guideline 5.1.1(v) requires in-app
account deletion for any app offering account creation. Deleting removes
`SavedStation`, `Watch` and profile rows; **`Report` rows are append-only and are
retained with the reporter detached** — availability the driver contributed does
not vanish and re-break the map. Say so on the confirmation.

**[RAISE-D15] There is no destructive treatment in the reference.** One text
colour, one accent, no red anywhere. `Delete account` therefore renders as an
ordinary row. Recommendation: accept, and carry the weight in the confirmation
copy rather than in colour.

**States.** Signed-in only. Offline: rows render; `Sign out` works (local);
`Delete account` refuses with the offline line. Error: in-place body copy.

**Strings:** `Login & Security` · `Apple` · `Google` · `Email` · `Connected` ·
`Not connected` · `Sign out` · `Delete account` ·
`Delete your account? Saved stations and alerts go with it. Availability you reported stays, without your name.` ·
`You're offline. Try again when you're back on.`

---

### D-07 · Offline & map data — [ext]

**Assembled from:** back button · heading · settings rows + the [RAISE-D14]
value slot.

**Purpose.** ADR-0007's settings home. This screen is why `Payment & payouts`
had to become something (§5).

**Rows**

| Label | Value | Tap |
| --- | --- | --- |
| `Kigali map` | `Built in` | — (non-interactive) |
| `All of Rwanda` | `76 MB` | download |
| `Station directory` | `Synced 2 min ago` | sync now |
| `Delete downloaded maps` | `76 MB` | delete, with a platform confirmation |

**Behaviour:** back `←` pops to D-04; each row acts per the table; no row
navigates anywhere.

**`All of Rwanda` row states**

| State | Value slot |
| --- | --- |
| Not downloaded | `76 MB` |
| Downloading | `42%` |
| Downloaded | `Downloaded · 76 MB` |
| Update available | `Update · 76 MB` |
| Offline, not downloaded | `76 MB · needs a connection` (row non-interactive) |
| Failed | `Download didn't finish. Tap to try again.` |

**[RAISE-D16] There is no progress component.** No bar, no ring, no spinner
anywhere in the reference; the hero's active page indicator (**95 × 16 px** lime,
10-v2 §7.7) is a pagination mark, not a meter, and pressing it into service would
be inventing.
Recommendation: **a text percentage in the value slot and nothing else** — the
minimum possible invention for a 76 MB download.

**`Station directory` values:** `Synced 2 min ago` · `Synced 3 h ago` ·
`Not synced` (fresh install, offline — the bundled snapshot is still serving).
Never *out of date*: the snapshot is a complete listing, and availability
honesty is structural (ADR-0007), not a function of sync age.

**Strings:** `Offline & map data` · `Kigali map` · `Built in` ·
`All of Rwanda` · `76 MB` · `Downloaded` · `Update` · `needs a connection` ·
`Download didn't finish. Tap to try again.` · `Station directory` ·
`Synced 2 min ago` · `Not synced` · `Delete downloaded maps` ·
`EV Guide works offline. Kigali's map is built in; download the rest of Rwanda for trips outside the city.`

---

### D-08 · Notifications — [ext]

**Assembled from:** back button · heading · settings rows + the [RAISE-D17]
trailing check.

**Purpose.** Control bay alerts. This is the only notification EV Guide sends —
ticket 30 permits exactly one event type, product-wide.

**Rows:** `Bay alerts` (toggle) · `System settings` (opens the OS sheet when
permission is denied).

**Behaviour:** back `←` pops to D-04 · `Bay alerts` toggles, arming/disarming
nothing by itself — it is the master switch · `System settings` leaves the app.

**[RAISE-D17] The reference contains no switch, checkbox, radio or toggle of any
kind.** A global gap, not a D-08 gap: it also blocks D-09. Options: (a) the
platform's native switch — conventional, and a visible foreign object in a
system with no other platform control; (b) **a trailing `#C7FC2F` check at the
icon system's measured 24 pt grid and 2 pt stroke, present when on and absent
when off** — built entirely from measured icon metrics plus the one accent, and
consistent with the additive-mark rule the whole design runs on; (c) a lime dot
reusing §7.9's status dot. **Recommendation: (b).** It is the single component the system must
add, and it should be added once and used everywhere rather than twice in two
shapes.

**States.** Permission granted → the row toggles. Permission denied → the row is
non-interactive and a body line reads
`Turn on notifications for EV Guide in system settings to use bay alerts.` with
the `System settings` row beneath it. Signed out → the row is present and
non-interactive with `Sign in to use bay alerts.` (a `Watch` is inherently
account-based). Offline → unchanged; permission is local.

`canWatch = isSignedIn && notificationsPermitted`, read **live** — never from a
mirrored bool that can outlive a sign-out, and `.authorized` only, never
provisional (ticket 30's amendment from 18).

**Strings:** `Notifications` · `Bay alerts` ·
`One alert when a bay frees up at a station you're watching. Nothing else.` ·
`Turn on notifications for EV Guide in system settings to use bay alerts.` ·
`System settings` · `Sign in to use bay alerts.`

---

### D-09 · My plug — [ext]

**Assembled from:** back button · heading · settings rows + the [RAISE-D17]
trailing check · one body paragraph.

**Purpose.** Set the driver's connector types. This is what makes the pin dot,
the card and the detail answer *free for me* rather than *free* — ADR-0002 calls
the vehicle profile load-bearing.

**Rows** (the closed type-word projection, docs/availability-display.md §2.4):
`Type 2` · `CCS2` · `GB/T AC` · `GB/T DC` · `Other plug`. Multi-select; the
trailing lime check marks each selection.

**Behaviour:** back `←` pops to D-04 · each row toggles its own type · selection
takes effect immediately on every screen; there is no Save.

**Gating. Ungated.** Setting your own connector type is a device-local
preference and a reading aid, and the read surface is anonymous (ADR-0003 as
amended). Only **syncing it across devices** needs an account. The domain model
flags this for founder ratification and this file restates the flag rather than
settling it: **[RAISE-D18]** — gating it would make the unlensed aggregate the
normal case for every driver and every store reviewer.

**States.** Nothing selected (the default) → every screen renders unlensed,
which is correct and complete, not degraded. Signed in → the selection syncs.
Signed out → it stays on the device; a body line says so. Offline → unchanged.

**Strings:** `My plug` ·
`Pick the plugs your car takes. EV Guide then shows what's free for your car.` ·
`Type 2` · `CCS2` · `GB/T AC` · `GB/T DC` · `Other plug` [all vocab] ·
`Stored on this device. Sign in to keep it across devices.`

---

### D-10 · About EV Guide — [ext]

**Assembled from:** back button · heading · settings rows + value slot · body
copy.

**Purpose.** Version, legal, and — load-bearing, not decorative — the map data
attribution the reference's `Google` wordmark used to carry (§11).

**Rows:** `Version` / `1.0.0 (1)` · `Map data` / `OpenStreetMap` ·
`Open source licences` · `Privacy` · `Terms`.

**Behaviour:** back `←` pops to its caller — **D-04 or the map attribution mark
on D-01 / D-02**, which is this screen's second entry point · `Open source
licences`, `Privacy` and `Terms` push their own text · `Version` and `Map data`
are non-interactive.

`Open source licences` lists MapLibre, the OpenMapTiles-derived style, Valhalla
(MPL-2.0), and the OSM data licence (ODbL). None of this is optional and none of
it is design.

**Strings:** `About EV Guide` · `Version` · `Map data` · `OpenStreetMap` ·
`Open source licences` · `Privacy` · `Terms` ·
`Map data © OpenStreetMap contributors` ·
`EV Guide is free. It takes no payments and never will.`

---

### D-11 · Saved — [ext]

**Assembled from:** back button (⌀90 px) · heading (**cap 36 Bold**) · repeated
**station cards** (D-02's card composition) · 1 px `#3E3E3E` dividers at the
list's own container width (§5.1).

**Purpose.** The driver's `SavedStation` list.

**Layout.** Back button · `Saved` heading · one card per saved station, each
carrying thumbnail 100 pt / `nameShort` cap 36 Bold / availability clause cap 27
Regular / `rateShort` right-aligned at cap 27, amount Bold and the unit tail
lighter (**[weight unsettled: RAISE-15]** — the `03` card slot this composition
copies measures the tail **ExtraLight**, 1.65 px stem) / heart `#717171`. **No route
chip** — the list is not tied to a position and computing a route per row would
be a burst of Valhalla calls for a screen the driver is browsing, not acting on.

**Behaviour**

| Element | Action |
| --- | --- |
| Back `←` | pop to D-04 |
| A card | **push D-03** |
| A card's heart | un-save, in place; the row leaves the list |

**States**

| State | Rendering |
| --- | --- |
| **Populated** | As above, ordered by distance when a position exists, else by save time. |
| **Empty** | Heading + one line: `Stations you save appear here. Tap the heart on any station.` No illustration and no button — the reference has neither, anywhere. |
| **Offline** | Fully functional; every field is cached. Uncached thumbnails → `#3E3E3E`. |
| **Signed out** | Unreachable — the quick action opens S-01 first. |
| **Loading / error** | None. |

**Strings:** `Saved` ·
`Stations you save appear here. Tap the heart on any station.`

---

### D-12 · Alerts — [ext] · **car-effort package**

**Assembled from:** back button · heading · settings rows + value slot.

**Purpose.** The armed `Watch` list — max 3, one-shot, auto-expiring 2 h.

**Rows:** `SP Remera` / value `until 15:12`.

**Behaviour**

| Element | Action |
| --- | --- |
| Back `←` | pop to D-04 |
| A row's label | **push D-03** for that station |
| A row's value slot | disarm that watch |

**States**

| State | Rendering |
| --- | --- |
| Armed | one row per watch, value `until 15:12` |
| Empty | `No alerts set.` + `Open a station and tap "Notify me when a bay frees up". One alert, next 2 hours.` |
| At the ceiling | body line `3 alerts set. That's the most at once.` |
| Signed out / no permission | unreachable — the quick action gates first (§4) |
| Offline | rows render; a disarm queues |

**[RAISE-D19] The watch vocabulary is contradictory across surfaces.** The
cross-surface verdict (§3 item 1) records `one alert, next 2 h` vs
`One alert, next 2 hours`, `Watching until 15:12` vs `Watching · until 14:05`,
`not confirmed yet` vs `Waiting for confirmation`, and CarPlay's `Notify when
free` vs Android's `Bay alert` vs the phone's `Notify me when a bay frees up`.
Android's set is declared **closed**, so these are defects by a rule CarPlay says
it adopted. This file uses the Android forms and the phone's own long label, and
routes the reconciliation to ticket 30 — it must not be settled three times.

---

### S-01 · Auth sheet — [ext]

**Assembled from:** the **floating card** (§0.3 row 2: **1076 px wide at x 65**,
all four corners **19.5 px** [ticket 33], `#121212`, 64 px
padding, drag handle **180 × 13 px** `#262626` **25 px** below the top) ·
primary CTA geometry (**138 px tall**, r **16.5 px** [ticket 33]) · hosting-card fill (`#393939`) for the
secondary buttons · body copy.

**Purpose.** ADR-0003 as amended (ticket 23): the gate fires on **save and
report**, never on directions. It overlays the screen the driver is on and
**auto-resumes** the action, so the driver never loses their station.

```
 ╭─────────────────────────────────────────────────────╮  r 19.5 all [t33]
 │                   ▭▭▭▭▭▭▭▭▭                         │  handle 180×13, 25 px down
 │  Sign in to save stations                           │  cap 36 Bold
 │  Reading EV Guide never needs an account.           │  cap 28 ExtraLight
 │                                                      │
 │  ┌────────────────────────────────────────────────┐ │  Apple's own button
 │  │            Sign in with Apple                  │ │  [RAISE-D20]
 │  └────────────────────────────────────────────────┘ │  948 px × 138 px
 │  ┌────────────────────────────────────────────────┐ │  #393939, 138 px
 │  │            Continue with Google                │ │  r 16.5 [t33]
 │  └────────────────────────────────────────────────┘ │  cap 36 Medium #FFFFFF
 │  ┌────────────────────────────────────────────────┐ │  27 px between
 │  │            Continue with email                 │ │
 │  └────────────────────────────────────────────────┘ │
 ╰─────────────────────────────────────────────────────╯  bottom edge 103 px
                                                          above the screen bottom
```

**[RAISE-D31] The button width — the 899 px number was the wrong one.** Verdict
**M6**: v1 stacked three buttons at "899 px", which is the *residual* width of a
CTA sharing its row with the locate button (§0.3 row 5), not a component
property. **There is no full-width button anywhere in the reference.**

> The correct width is the **card's own inner box**: card **x 65 → 1140** less
> **`space.floatingCardPadding`** 64 px each side = **x 129 → 1076 = 948 px =
> 316.0 pt.** That is a layout consequence of two measured values (the card
> frame, 10-v2 §7.4, and `space.floatingCardPadding`, §10.3), not an invented
> button size. Height 138 px is measured (`size.ctaHeight`) and radius **16.5 px**
> is corrected [ticket 33].

Raised because the reference never stacks buttons, so the *stack* — three
buttons at the card's inner width with a gap between them — has no measured
precedent. **Recommendation: 948 px wide, `space.chipGap` 27 px between**, the
only measured vertical gap between sibling controls in the system.

**[RE-DERIVED, ticket 32] This raise was computing from a token that does not
exist, and from an inner box two pixels too wide.** Both inputs are corrected
and **the recommendation stands at 948 px**:

1. **`space.sheetPadding` is a phantom.** 10-v2 §10.3 defines
   **`space.floatingCardPadding` = 64 px = 21.3 pt**, and §10.4 is explicit that
   *"there is no `radius.sheet` token either — **there is no sheet**"*. The
   whole point of M2 is that this element is a card; naming its padding after a
   sheet re-imported the identity the correction removed. A build searching the
   token set for `space.sheetPadding` finds nothing and invents a number.
2. **The inner box is 948 px, not 950.** It was derived from the stale frame
   `x 64 → 1141` (the card's AA extent). At 10-v2's `x 65 → 1140`:
   `65 + 64 = 129`, `1140 − 64 = 1076`, `1076 − 129 + 1` = **948 px = 316.0 pt**.
3. **The residual-width claim this raise rests on survives — but only on
   10-v2's figures.** The claim is that the CTA's 899 px is
   `contentWidth − gap − locateButton` and therefore not a button size worth
   copying. On this file's own numbers that identity read
   `897 + 41 + 137 = 1075`, **three pixels short of the 1078 px content column,
   so it did not hold** — the raise was arguing from an identity that failed.
   At 10-v2's `899 + 40 + 139 = 1078` it closes **exactly**. Say so plainly: the
   argument is sound, and it was sound for a reason this file did not have.

**[RAISE-D34] The card's bottom offset when nothing sits below it.** On `03` the
card's bottom edge is **64 px** above the CTA (`space.floatingCardBottomGap`;
rows 2318–2381 inclusive are map), which is itself 103 px above the screen
bottom. S-01 and S-02 have no CTA beneath them, so that 64 px measures nothing.
**Recommendation: 103 px = 34.3 pt above the screen bottom** — the measured
resting height of the lowest floating element in the system.
**[RE-DERIVED, ticket 32]** — the gap read 65 px; 10-v2 §7.4 and §5.2 both give
**64**, and it is a named token. The recommendation is unaffected: it is the
103 px that carries it, and the 64 is the number being set aside.

**Title is trigger-specific**, because a sheet that names the act it will resume
is a sheet the driver can decide about: `Sign in to save stations` ·
`Sign in to report status` · `Sign in to set an alert`.

**Only one button may be lime.** The accent budget is measured at ~3.9% of the
map screens and the reference spends it on pins plus **one** CTA. Three lime
buttons would be the largest accent deviation in the design. So: the platform's
native provider takes the accent slot; the other two use the hosting card's
`#393939` fill at the CTA's measured height and radius.

**[RAISE-D20] Sign in with Apple cannot be reproduced 1:1.** Apple's guidelines
fix that button's appearance — black / white / white-outline, its own logo
lockup and type — and it cannot be restyled to `#C7FC2F` with a `#121212` label.
It is also **compelled**: Guideline 4.8 requires it once Google sign-in is
offered on iOS (ADR-0003). Options: (a) ship Apple's native button, setting only
its `cornerRadius` to the measured **16.5 px** [ticket 33] — the one property the API exposes;
(b) draw a custom button, a common rejection cause. **Recommendation: (a).** This
is the second provably-impossible element in the driver app, after the `Google`
wordmark (§11). *(The `cornerRadius` value is the one number in this
recommendation ticket 33 will move; the recommendation does not depend on it.)*

**Behaviour**

| Element | Action |
| --- | --- |
| Drag handle / drag down | dismiss; the pending action is dropped, silently |
| Tap outside the card | dismiss, same |
| Any provider button | start that flow; on success dismiss and **fire the original action without a second tap** |

**States**

| State | Rendering |
| --- | --- |
| Idle | as drawn |
| In flight | **no spinner** (none exists). The buttons become non-interactive; nothing else changes. |
| Success | card dismisses; the original action fires — heart fills, or S-02 opens |
| Cancelled | card dismisses; nothing is lost; no message |
| Failed | body line replaced in place: `Sign-in didn't finish. Try again.` — `#FFFFFF` body copy, because **the token set has no error colour** |
| Offline | the card still opens; body line reads `You're offline. Sign-in needs a connection.`; buttons non-interactive |
| Email path | the body becomes an email field + `Send me a link`, then `Check your email. The link signs you in.` |

**[RAISE-D21] There is no text input anywhere in the reference.** No field, no
caret, no placeholder, no keyboard-adjacent chrome. The email path and D-05's
edits both need one. Recommendation: build it from the measured feature-chip
surface (`#393939`, radius **13.4 px** [ticket 33], height
105 px = 35.0 pt, `size.chipHeight`) with a cap-32 Regular `#FFFFFF` value — the
closest measured container — and name it as an addition to `packages/ui`.

**Strings:** `Sign in to save stations` · `Sign in to report status` ·
`Sign in to set an alert` · `Reading EV Guide never needs an account.` ·
`Sign in with Apple` · `Continue with Google` · `Continue with email` ·
`Send me a link` · `Check your email. The link signs you in.` ·
`Sign-in didn't finish. Try again.` · `You're offline. Sign-in needs a connection.`

---

### S-02 · Report sheet — [ext]

**Assembled from:** the floating card (§0.3 row 2, handle 180 × 13 px) ·
**primary CTA geometry for the three controls** (§12.3, *not* chips) · body copy.

**Purpose.** File a `Report` — a claim about one **Connector's** availability.
Proximity-gated on the captured location, account-required, offline-queueing.

```
 ╭─────────────────────────────────────────────────────╮  r 19.5 all [t33]
 │                   ▭▭▭▭▭▭▭▭▭                         │  handle 180×13 #262626
 │  GB/T DC · 60 kW                                    │  cap 36 Bold
 │  What's happening at this plug?                     │  cap 28 ExtraLight
 │                                                      │
 │  ┌────────────────────────────────────────────────┐ │  948 px × 138 px
 │  │                  Free                          │ │  #393939 + #FFFFFF
 │  └────────────────────────────────────────────────┘ │  cap 32 Medium
 │  ┌────────────────────────────────────────────────┐ │  27 px gap
 │  │                  Busy                          │ │  r 16.5 [t33]
 │  └────────────────────────────────────────────────┘ │
 │  ┌────────────────────────────────────────────────┐ │
 │  │             Out of service                     │ │
 │  └────────────────────────────────────────────────┘ │
 ╰─────────────────────────────────────────────────────╯
```

**Why the controls stack instead of going three-up** — the one place this file
diverges from `12-operator-admin-screens-v2.md` §4.3, stated rather than
discovered. The component is identical; the **container width** differs:

| Surface | Container | Three-up button width [d] | `Out of service` at cap 32 Medium, k = 0.65 | Verdict |
| --- | --- | --- | --- | --- |
| Operator write surface (file 12 §4.3) | page content column, **1078 px** | (1078 − 54) / 3 = **341 px** | 291 px ink | fits, **25 px** side clearance |
| **S-02** | **card inner box, 948 px** | (948 − 54) / 3 = **298 px** | 291 px ink | **fails — 3.5 px side clearance** |

So the driver's sheet stacks, at the card's inner width (**948 px**), 27 px
apart. One component, one reason, arithmetic shown. *(Routed to file 12: at the
conservative constant its own three-up leaves 25 px of side padding, which is
tight; that is file 12's call, not this file's.)*

**[RE-DERIVED, ticket 32] The verdict survives, and the sheet still stacks.**
Recomputed at the corrected inner box: `(948 − 54) / 3 = 298 px` per button
against **291 px** of ink (`14 × 0.65 × 32`), leaving `(298 − 291) / 2` =
**3.5 px** each side, where the stale 950 px gave 299 px and 4 px. It fails at
both, and it fails harder at the true width — a control with 3.5 px of side
padding is not a control. **The operator half of the table is correct at every
input**: 1078 px *is* the `04` content column (10-v2 §7.7 / §7.11), and
`(1078 − 54)/3 = 341.3` with 25.2 px of clearance. This is the one place in the
file where the two container widths are compared directly, so it is worth saying
that only one of them moved: the page column was always right, the card's inner
box was two pixels wide.

**One tap commits.** The reference contains **no selected/unselected control
pair**, so there is no way to show a pending choice without inventing a state.
Tapping a control files the report and dismisses the card. This suits the actual
user — a driver standing at a charge point, one-handed — and mis-taps are cheap:
reports are append-only and most-recent-wins, so the correction is another tap.
**[RAISE-D22]** named, because it is a consequence of a missing state rather than
a UX preference. It is *also* why no accent fill appears here: file 12 spends the
accent on **selected**, and S-02 has no selected state to render.

**The three labels reuse the closed state words exactly** — `free`, **`busy`**
(R1), `out of service` — so the report sheet introduces **zero new state
vocabulary**. Title-cased because each begins its own string
(`01-carplay-design-v3.md` §2.x capitalisation rule). **[RAISE-D23]** the closed
vocabulary in `packages/domain` currently covers state words, capacity clauses,
watch strings and notification bodies; **report action labels are not listed**
and must be added there rather than authored in the app.

**States**

| State | Rendering |
| --- | --- |
| **Signed out** | The card does not open. S-01 opens instead and auto-resumes into this one. |
| **Not at the station** | The card does not open. The connector rows on D-03 are non-interactive and the availability block carries `Report status when you're at the station`. |
| **Offline** | Files normally. `capturedAt` and `capturedLocation` are recorded at tap time and queued (ADR-0007). **The confirmation is the report's own effect**: the card dismisses and the connector row re-renders with the new state immediately, because the derivation runs on device over cached reports including this one. No toast, no snackbar — the reference has neither. |
| **Queued report expired** | Dropped client-side past its 2 h decay window; the row simply re-derives. Nothing is shown, because nothing is true. |
| **Loading / error** | None. A report is a local write. |

**Strings:** `GB/T DC · 60 kW` [vocab] · `What's happening at this plug?` ·
`Free` · `Busy` · `Out of service` [vocab] ·
`Report status when you're at the station`

---

### S-03 · Overflow menu — [ext, from `04`'s `⋯`]

Two items: `Share station` · `Report availability`. The platform's own action
sheet; the reference gives no menu component and none is invented.

**Behaviour:** `Share station` → the platform share sheet · `Report
availability` → a connector picker first when the station carries more than one
type, then **S-02**. See [RAISE-D13] for what is deliberately absent from it.

---

### Deliberately **not** screens

| Not built | Why |
| --- | --- |
| **Route / navigation screen** | ADR-0004 forbids inventing one; the preview lives in D-02 (§7). |
| **Search screen** | The reference has no search component; a directory of tens of stations sorted by distance needs none. Recorded as an accepted reduction, not an oversight. |
| **Full-screen photo viewer** | The hero carousel is the whole photo surface. No ticket asks for more, and a viewer would be the only full-bleed modal in the app. |
| **Owner screen** | The owner row is identity, not navigation. Nothing in the model has an Owner-scoped read for drivers. |
| **Onboarding** | No reference, no ticket. Ticket 28 fixes what the *listing and onboarding claim* (`real-time` never appears anywhere) but does not commission screens. **[RAISE-D24]** — if onboarding ships, it is a new design pass, and its copy is already constrained. |
| **Filters** | Nothing in the model is a filter dimension on the phone; the plug lens (D-09) is a reading aid, not a filter, and it never hides a station. |
| **Operator anything** | Different app (ADR-0006). |

---

## 9. The offline surfaces

### 9.1 The quiet offline indicator

**It is a feature chip** (part 1 §7.5, the `04` variant): height 105 px =
35.0 pt (`size.chipHeight`), radius **13.4 px = 4.5 pt** [ticket 33], fill `#393939`, **no border**, a
**43 × 48 px stroke icon at 4.2 px perpendicular = 1.4 pt on the 16 pt chip grid**
(`size.iconGridChip` 48 px = 16.0 pt), 30 px left padding
(`space.chipPaddingH`), 18 px icon→label (`space.chipIconGap`), 26 px right
padding, label cap 32 **ExtraLight** `#FFFFFF`, width fits content (271 / 316 /
387 / 652 px measured across four instances).

**[RE-DERIVED, ticket 32]** — the icon was specified as *"a 2 pt stroke icon on
the 24 pt grid"*, which is the **chrome** icon spec, not the chip's. 10-v2 §7.5
measures the feature chip's icon at **43 × 48 px with a 4.2 px perpendicular
stroke**; §10.3 carries **two** grid tokens — `size.iconGrid` 72 px = 24.0 pt for
chrome and **`size.iconGridChip` 48 px = 16.0 pt** for chips — and §8.2 files
chip icons in the **Light** band at **1.4 pt**, not the nominal 2 pt. A 24 pt
glyph at a 2 pt stroke in a 35 pt-tall chip would be half again too big and
noticeably heavier than every chip icon in the reference. **This makes the
argument below stronger, not weaker**: the chip is even quieter than this file
claimed.

That component is the quietest labelled object in the entire reference: dark
surface, no accent, no border, the lightest weight in the system **and the
lightest stroke band in the icon set**. It is the correct face for a state
ADR-0007 insists is **normal, not an error**.

| Screen | Placement |
| --- | --- |
| D-01, D-02 | right-aligned to the content column (right edge x 1141), vertically centred on the map avatar (avatar y 362, ⌀129 → centre y 426.5) |
| D-03, D-04, and all `[ext]` screens | directly under the top button row, right-aligned to the content margin |

**It is additive** — absent when online, exactly like every other mark in this
system. Label: `Offline`. It never says *No connection*, *Error*, *Offline
mode*, or anything that reads as a failure, and it never asserts anything about
the *data* — the governing law is `docs/availability-display.md` **§2.2b** (cited
at §13.1): no string may claim report history, and `Offline` describes the
device.

**It is a label, not a control** (§12.3), and it is explicitly not the crosshair
rule (§3).

### 9.2 The straight-line label

§7.3. `~2.4 km straight line`, in the card's chip slot, with the same number the
CarPlay surface ships (§0.5). The phone shows **unmarked** driving distance when
online, which is what makes the marker meaningful (ADR-0007's amendment).

### 9.3 The all-Rwanda map pack row

D-07, `All of Rwanda` / `76 MB`. Six states, one raise about progress
([RAISE-D16]).

### 9.4 The global loading and empty vocabulary

**The reference contains exactly one empty state, and it is measured**: the
profile avatar on `02` with no image — a `#3E3E3E` fill inside the lime ring.
That single fact settles loading and placeholder behaviour product-wide, with no
invention:

| Situation | Rendering |
| --- | --- |
| Content not yet available (photo, hero, thumbnail) | **`#3E3E3E` block at the target's exact geometry and radius** |
| Additive marks not yet resolved (route chip, free-bay dot, offline chip) | **absent**, then present |
| Structural content | never absent — the bundled snapshot means the directory always paints |
| Empty list | section heading + one line of cap-28 ExtraLight body copy. No illustration, no button, no icon. |
| Any error | body copy replaced in place, `#FFFFFF`. **There is no error colour in the token set** and adding one would be a deviation. |
| Progress | text only ([RAISE-D16]) |
| Motion | **none, anywhere** — part 1 §9 finds no shadow, blur, border or scrim on any product surface, and §12 records that **no motion, transition or gesture behaviour is measurable from four stills**; no shimmer or skeleton animation is introduced. *(10-v2 §9 narrows the absolute to two sub-threshold exceptions — an 8–14/255 ramp above and below the `04` hero and a 1-level band on `02` — neither tokenised, and §9 is explicit that neither licenses a shadow, blur or elevation ramp anywhere.)* |

---

## 10. The inline auth sheet — summary of the gate

| Action | Gate | On tap when signed out |
| --- | --- | --- |
| Browse map, open a station, read rate / connectors / bays / availability | **none** | — |
| **Directions** | **none** (ADR-0003 amended, ticket 23) | fires |
| Save (heart) | account | S-01 → auto-resume the save |
| Report availability | account | S-01 → auto-resume into S-02 |
| Arm a bay alert | account + notification permission | S-01 → permission → auto-resume the arm |
| Set `My plug` | **none** (device-local) | opens directly |
| Sync `My plug` across devices | account | — |

The card overlays the screen the driver is on and never navigates. On success it
dismisses and the original action fires **without a second tap** — ADR-0004's
auto-resume pattern, which survived the ticket-23 amendment intact and simply
changed which taps trigger it.

---

## 11. The `Google` wordmark — a genuine 1:1 impossibility

Measured on `01`: the wordmark's ink box is **x 73 → 232, y 2256 → 2306**
(159 × 50 px = 53 × 16.7 pt), sitting **76 px (25.3 pt)** above the CTA's top
edge at **y 2382**, with the map label `Ntarama` beside it at x 253 → 412.
**[RE-DERIVED, ticket 32]** — the gap read *77 px (25.7 pt)* against a CTA top
of y 2383; the CTA's accent begins at **y 2382** (10-v2 §7.1 frame
`y2382 → 2519`, and §7.4's below-the-card scan: rows 2318–2381 inclusive are
map). `2382 − 2306` = **76 px = 25.3 pt**. Nothing computes from it — the
attribution slot is placed by its own left edge and the CTA's top, both
measured — but a build types it.

Ticket 06, hardened by ticket 26's no-external-runtime-dependency rule, fixes
**MapLibre with self-hosted OSM tiles**. Under any non-Google provider that pixel
**cannot be reproduced under any circumstance.** It is the only provably
impossible element in the four reference screens.

**A second Google-provenance element sits on the same screens:** the location
puck. Sampled at `x 583–642, y 1291–1331` on `01`, its fill is **`#4285F4`** —
Google's brand blue, drawn by the Google Maps SDK's own location UI. Part 1 §2.5
now measures the whole component: **disc ⌀40 px = 13.3 pt**, **`#FFFFFF` ring
4 px = 1.3 pt**, **accuracy halo `#4285F4` at ≈19 % over `#212121`, ⌀82 px =
27.3 pt**, a heading cone in the same blue, centred at x 603.5, y 1311 on `01`
(`map.puck.*`, §2.6). It is not in the `color.*` token set, it is not EV Guide's
to use, and under MapLibre the puck is ours to draw. **[RAISE-D25]** — it needs
either a measured reproduction (which reproduces a Google brand colour) or a
token decision. Recommendation: draw the puck at the measured geometry in
`#FFFFFF` with a `#C7FC2F` core, which uses only existing tokens; flagged
because it changes a visible reference element.
**[RE-DERIVED, ticket 32] — one objection to that recommendation is now on the
record.** Part 1's own **[RAISE-10]** raises the same question and names a cost
this file did not: *"the lime one collides with the pin outline, which is the
same colour."* On a map whose only two saturated families are `#C7FC2F` and
`#4285F4`, a lime-cored puck and a lime-outlined pin become the same mark at
map zoom, and the puck is the one thing on the screen that is **not** a station.
The recommendation is left standing because a white-with-lime puck is still the
only reading that uses existing tokens — but it is now recorded as a **contested**
recommendation, with part 1's collision as the reason the founder might say no,
and a neutral all-`#FFFFFF` puck as the alternative part 1 also names.

### Options for the wordmark slot, and the recommendation

| # | Option | Cost |
| --- | --- | --- |
| **a** | **Replace the wordmark with the required OSM attribution in the same slot** — same position (x ≈ 64–73, above the CTA), the reference's own type (cap 27 Regular `#FFFFFF`), reading `© OpenStreetMap contributors`, tapping through to D-10 | The *word* differs and there is no logo lockup. The slot, its position, its treatment and its role all survive. |
| b | Drop the slot and put attribution only in D-10 | Empties a measured region of the reference, and OSMF's guidance expects the credit in the corner of a browsable map, permitting a reduced form only where screen space is genuinely limited — not obviously true of a full-bleed map. |
| c | Use Google Maps and keep the pixel exactly | Contradicts ADR-0007 (offline tiles are required and Google's ToS §3.2.3(a) forbids caching), contradicts ticket 26's rule, and runs into Google's ToS §3.2.3(d)(iii) barring use "in a listings or directory service" — EV Guide's own one-line description. Named only because it is the sole path that reproduces the reference. |

**Recommendation: (a).** Attribution is a licence obligation rather than a design
choice, so the slot must carry *something*; the reference's own bottom-left mark
slot is exactly where it belongs, and using the reference's own type treatment
keeps the deviation to the smallest possible unit — one word replaced by a credit
that is legally required.

**Record it as a knowing, founder-approved deviation.** Two further consequences
travel with it: the neighbourhood labels **Rebero** and **Remera**, visible in the
reference, **do not exist in OSM as places** and must be added upstream before the
basemap can reproduce the reference's own label set.

---

## 12. The report flow and the bay-watch affordance

### 12.1 Report — proximity-gated, per-Connector

Three entry points, all leading to S-02:

1. **A connector row in D-03's availability block**, tapped — the primary path,
   because it names the exact Connector the report is about.
2. **`Report availability` in S-03** — opens a connector picker first when the
   station has more than one type.
3. Nothing on D-01 or D-02. Reporting requires being at the station and knowing
   which plug; neither is true from the map.

**The gate.** Proximity is evaluated on the **captured** location (ADR-0007), so
a report filed at the charger and synced from the car park an hour later is still
valid. Not-at-the-station is a **non-interactive row plus a line of body copy**,
never a hidden control — the same discipline ticket 30 forced on the watch
affordance, for the same reason: a control that disappears teaches the driver
nothing.

**Anti-abuse is the gate itself.** ADR-0002: proximity gating *doubles as the
primary anti-abuse measure. No reputation system in v1.* Nothing in this design
adds a second mechanism.

### 12.2 Bay watch — arm and disarm

**Component: primary CTA geometry** (§12.3), 138 px tall (`size.ctaHeight` =
138 = 46.0 pt), radius **16.5 px** [ticket 33], `#393939`
fill, cap 32 Medium `#FFFFFF` label, **the full 1078 px = 359.3 pt content
width**, placed directly under D-03's availability block at the content margin.

| Condition | Slot renders | Tap |
| --- | --- | --- |
| Can arm, not armed | **control**: `Notify me when a bay frees up` | arm |
| Armed | **control**: `Watching · until 15:12` | disarm |
| Signed out | **control**: `Notify me when a bay frees up` | S-01 → auto-resume |
| No notification permission | **control**: `Notify me when a bay frees up` | OS permission → auto-resume |
| Offline | **control**: `Notify me when a bay frees up` | queues; dropped past `armedAt + 2h` |
| Already free | **body line**, cap 28 ExtraLight: `A bay is free now` | — |
| At the ceiling | **body line**: `3 alerts set. That's the most at once.` | — |

The slot **always says something**; nothing disappears. Where the action is
impossible, the reason replaces the control in place — which is exactly ticket
30's amendment (*"a refusal with a reason in the row's text, never a disappearing
control"*) rather than a departure from it. A control that is permanently
untappable is a lie about a tap target; a sentence is not.

Fires **only** on a report-driven transition into `Free`. Decay never fires it —
ceasing to know is not an event. One-shot; expires silently after 2 h.

**Ships with the car effort's package** (tickets 23 / 30). Specified here so the
detail screen's composition is settled once.

### 12.3 No chip in the driver app is a tap target — [resolves M7]

v1 made the category chip a control twice: once for arm/disarm, once for the
three report actions. `12-operator-admin-screens-v2.md` §4.3 had already rejected
exactly that, with reasons this file accepts in full rather than re-arguing:

> *the feature chip is **35 pt** tall and the category chip **25.7 pt**, and
> neither is interactive in the reference — they are labels. Both are under any
> tap-target floor. Using CTA geometry keeps the target at 46 pt and introduces
> no value that was not measured.*

**[RE-DERIVED, ticket 32]** — the quotation is left as file 12 wrote it, but one
figure in it is wrong and the correction runs the safe way. The category chip is
**76 px = 25.3 pt**, not 25.7 (10-v2 §7.5 / §7.4: `254 × 76 px = 84.7 × 25.3 pt`;
`76 / 3 = 25.33`). The feature chip's **35.0 pt** is exact (105 px). Both are
*further* under any tap-target floor than the quotation claims, so the ruling
this file adopts is unaffected and slightly better supported. The 25.7 is file
12's to fix.

**One answer, adopted product-wide:**

| Rule | Consequence in this file |
| --- | --- |
| **Chips are labels.** Both variants, both apps. | The route-preview chip (§7.2), the connector feature chips (D-03), and the offline chip (§9.1) are all non-interactive, and every behaviour table above says so. |
| **Interactive controls take primary-CTA geometry**: 138 px tall (46 pt), radius **16.5 px** [ticket 33], `#393939` + `#FFFFFF` label unselected, `#C7FC2F` + `#121212` Medium label selected. **Label cap: 36 in S-01 (the primary CTA's own measured label size, 10-v2 §4.1 row 5), 32 in S-02 and §12.2** — a per-surface difference this file already carried and which the cap-37 → cap-36 correction does not create. | S-02's three report controls (§8, S-02) and D-03's bay-watch control (§12.2). |
| **Accent means *selected*.** | S-02 has no selected state (one tap commits), so nothing there is lime — which is also why the accent budget survives. |
| Layout may differ where the **container width** differs, with the arithmetic shown. | S-02 stacks where file 12 goes three-up (§8, S-02). |

The one thing this file adds to file 12's ruling is the **fallback for an
impossible action**: a body line, not a dead button (§12.2).

---

## 13. Vocabulary, strings and the closed sets

### 13.1 The forbidden list — cited, not held

> **The list lives in `docs/availability-display.md` §2.2b —
> *"The forbidden strings — the one and only home"* — and nowhere else.**
> This file cites it and holds nothing. So do `10-design-system-v2.md` (whose
> §11.2 is now a pointer) and `12-operator-admin-screens-v2.md`.

**[RE-DERIVED, ticket 32] The four-row restatement this section used to carry
has been deleted, and its heading corrected.** Three things were wrong with it:

1. **The pointer was wrong.** It read *"Canonical location:
   `docs/availability-display.md` §2.2, law 8"*. **Law 8 covers one of the
   list's rows** — the report-history ban — and none of the others; the list is
   **§2.2b**, a section of its own with that exact title.
2. **The restatement made this file a fourth claimant.** Four documents were in
   circulation as *the* single home: file 10 §0.3/R3 (*"§11.2 of this file and
   nowhere else"*), this file's §0.2/R3 (*"§13.1"*), this section
   (*"§2.2, law 8"*), and the ticket plus both authority notes (*"§2.2b"*). A
   list whose whole purpose is to be normative cannot have four homes, and the
   clause *"quoted once here so this file is readable"* is exactly how the
   fourth one was created. Readability is not a reason to fork a normative list.
3. **Deleting it could have dropped live bans, so it was merged first.** The
   copies were **not** subsets of one another. File 10 §11.2 uniquely carried
   `last reported`, `awaiting a report`, `no reports yet` and the catch-all
   clause *"or any phrasing that asserts a report exists, does not exist, or is
   old"*; those four were merged into §2.2b on 2026-08-14 **before** either
   restatement was withdrawn. Nothing was lost by the deletion.

**One item this file must state, because it is a live defect rather than a copy
of the list:** the **title-cased spelling of `in use`** is the same ban (R1) and
was still in circulation in this file and in file 12. It is lower-cased or
removed at every occurrence here (§15/F1); file 12's occurrences are file 12's.

**Three corrections owed to `docs/availability-display.md` itself**, routed with
the list and **not** restatements of it:

1. §2.1's Regime 3 example reads `1 free · 1 in use · 1 out of service ·
   1 unreported` — **two forbidden words in one example**, in the document that
   forbids them. Corrected form: `1 free · 1 busy · 1 out of service ·
   1 unknown`.
2. Law 8's own permitted form reads `No confirmed bay status`; **R3** fixes the
   product on `no confirmed status`. Align law 8's wording.
3. Grammar R's two-rate example carries a bare `GB/T` — see §13.4.

Adding a string to the list is a change to `packages/domain`, and every addition
needs a fixture in the shared corpus (`availability-display.md` §3).

### 13.2 `rateShort` — the R4 short projection

Defined **once**, in `packages/domain`, and consumed by every slot too small for
Grammar R. It returns **structure, not a formatted string** (domain-model
amendment 8); the closed vocabulary supplies the words.

```
rateShort(station) →
  { kind: 'single', rwfPerKwh }        -- exactly one distinct confirmed rate
  { kind: 'from',   floorRwfPerKwh }   -- two or more distinct confirmed rates
  { kind: 'none'   }                   -- no confirmed, in-window rate on any plug
```

| kind | Rendered | Composition — **[weight unsettled: RAISE-15]** |
| --- | --- | --- |
| `single` | `600 RWF/kWh` | `600 RWF` **Bold** + `/kWh` **in the slot's lighter tail weight** |
| `from` | `From 400 RWF/kWh` | `From 400 RWF` **Bold** + `/kWh` **in the slot's lighter tail weight** |
| `none` | `No confirmed rate` | **[RAISE-D33]** |

**[weight unsettled: RAISE-15] — this table said `Regular` for every slot, and
the two slots do not agree.** This file was **right that the run is two
weights** — 10-v2 §11.3 has been brought into line and now carries the
structural signature this section defines, and §12 raises the weight question
as **[RAISE-15]** — but it was wrong to assign one lighter weight to all four
consuming slots. Measured [m, 10-v2 §11.3, integrated stem coverage]:

| Slot | cap | amount | unit tail |
| --- | --- | --- | --- |
| `04` sticky bar (D-03) | 36 | **Bold** — `F` of `RWF` 6.92 px, stem/cap **0.192** | **Regular** — `d`/`a`/`y` 4.36 / 4.21 / 4.37 px, **0.121** |
| `03` card price (D-02) | 27 | **Bold** — `1` 5.19 px, `F` 5.22 px, **0.192** | **ExtraLight** — `d`/`a` 1.65 px, **0.061** |

Two slots, two different tail weights, both measured. **Neither is adopted here
and no assignment is invented**: 10-v2 §4.1 row 15 and §7.8 still describe the
whole run as Bold and are deliberately **not** corrected, because per-slot
assignment is RAISE-15's to settle and a build must not type either version
until it does. What this file states is the fact both slots share — **the amount
is Bold and the tail is lighter** — and the two measurements, so whoever settles
RAISE-15 has them.

**Where it is used:** the D-02 card's price slot · the D-02 list detent · D-11's
rows · D-03's **sticky bar**. **Where it is not used:** D-03's rate line under
the connector chips, which is the full Grammar R ladder and the only place the
long form appears (**R4**).

**The structural signature stands, and part 1 has adopted it.**
**[RE-DERIVED, ticket 32]** — 10-v2 §11.3's rate table previously presented the
*rendered strings* as the projection, which violated `docs/domain-model.md`
amendment 8. It now returns `{kind:'single', rwfPerKwh}` /
`{kind:'from', floorRwfPerKwh}` / `{kind:'none'}` and names §13.2 of this file
as the structural signature. This is the second place in the sweep where the
correction ran from this file **into** part 1 rather than the other way (the
category chip's 86/30 padding is the first).

**Why this is a fatal-class fix, not a tidy-up** (verdict **F5**). Rate is a
**Connector** property. A card slot that renders `600 RWF/kWh` for a station
whose GB/T guns cost 600 and whose Type 2 guns cost 400 has asserted a
station-level rate that does not exist, and the driver plugs in at the wrong
price. `From 400 RWF/kWh` is the only honest short form, and `From` asserts a
floor over the **confirmed set only** — Grammar R's own rule, inherited whole.

**[RAISE-D33] The price slot's weight composition when there is no amount.** The
reference's composition is *amount-and-currency Bold + a lighter slash-unit
tail*. `No confirmed rate` has neither an amount nor a unit, so the reference
cannot say which weight it takes. **Recommendation: Regular at the same cap
height** — the Bold run in the reference is the *number*, and there is no number.
Needs a yes. **[RE-DERIVED, ticket 32]** — the premise sentence said the tail is
*Regular*; it is Regular in one slot and **ExtraLight** in the other
([RAISE-15], above). That makes this raise **wider than it was written**: on the
`03` card the choice is now between three weights, not two, and "the tail's
weight" is not a single answer to inherit. The recommendation is left standing
because it rests on the *absence of a number*, not on the tail — but the founder
answering it should know the tail is unsettled.

### 13.3 Grammar R stays on the detail

Quoted verbatim at D-03, with the phone's one-line join rule (`text 1 · text 2`)
stated there. Not restated here.

### 13.4 [RAISE-D32] Bare `GB/T` is not in the closed projection — routed, open

docs/availability-display.md §2.4 defines the type-word projection exactly:

```
IEC_62196_T2 → Type 2 · IEC_62196_T2_COMBO → CCS2 · GBT_AC → GB/T AC
GBT_DC → GB/T DC · OTHER / UNKNOWN → Other plug
```

**`GB/T` alone is not a member.** v1 of this file used it in the
no-compatible-plug variant (`No GB/T bay here …`), and Grammar R uses it in its
own two-rate example (`600 RWF/kWh GB/T · 400 RWF/kWh Type 2`). Two documents
have now reached for a word the closed set does not contain, which is what a
closed set exists to catch.

**This file uses the qualified forms everywhere** — `No GB/T DC bay here`,
`1 GB/T DC bay free`, `1 of 2 GB/T DC bays free`, `2 × GB/T DC 60 kW` — and does
**not** close the question by adoption. What is open:

- Is the collapsed form **legal at all**, given that GB/T AC and GB/T DC are
  physically different plugs a driver cannot substitute? Collapsing them in a
  string that tells a driver what is *free for them* would be the same class of
  error the lens exists to prevent.
- If it is legal in some contexts (e.g. Grammar R, where the word disambiguates
  two *rates* rather than two *plugs*), it must be a **named member of the closed
  set** with its own rule, not an ad-hoc contraction.
- What the no-compatible-plug clause says when the lens has **two or more**
  members — `No GB/T AC or GB/T DC bay here` is 30 characters of plug names in a
  30-character line.

**Routed to ticket 18** (which owns §2.4) and to `02-androidauto-design-v3.md`
§3.5 (which shipped the bare form). Not settled here, and not settled twice.

### 13.5 App copy, by screen

Strings marked [vocab] are **data in `packages/domain`** and may not be authored
in the app. Availability, capacity, freshness, rate and type words are all
[vocab], defined in docs/availability-display.md §2 and enumerated in
`02-androidauto-design-v3.md` §3.8; not restated here, because that table is the
source. **The phone adds no state vocabulary at all** — four runtimes, one
grammar.

**New [vocab] members this design requires** (routed to `packages/domain`):

| String | Why |
| --- | --- |
| `Free` · **`Busy`** · `Out of service` | report action labels — the closed set covers state words but not report actions [RAISE-D23] |
| `No confirmed rate` (short form) | `rateShort`'s `none` case, §13.2 |

| Screen | Strings |
| --- | --- |
| D-01 | `Let's find a charger` · `Offline` |
| D-02 | — (all content is [vocab] or data) |
| D-03 | `Availability` · `Connectors` · `Getting there` · `Directions` · `Share station` · `Report availability` · `Report status when you're at the station` · `Notify me when a bay frees up` · `Watching · until 15:12` · `A bay is free now` · `3 alerts set. That's the most at once.` |
| D-04 | `Show and edit my profile` · `Not signed in` · `Sign in to save and report` · `Saved` · `My plug` · `Alerts` · `Open EV Guide Operator` · `Get EV Guide Operator` · `You manage 3 stations.` · `Update bay status and rates.` · `The operator app updates bay status and rates.` · `Settings` · `Personal Information` · `Login & Security` · `Sign in` · `Offline & map data` · `Notifications` · `About EV Guide` |
| D-05 | `Name` · `Email` · `Photo` · `You're offline. Try again when you're back on.` |
| D-06 | `Apple` · `Google` · `Email` · `Connected` · `Not connected` · `Sign out` · `Delete account` · `Delete your account? Saved stations and alerts go with it. Availability you reported stays, without your name.` |
| D-07 | `Kigali map` · `Built in` · `All of Rwanda` · `76 MB` · `Downloaded` · `Update` · `needs a connection` · `Download didn't finish. Tap to try again.` · `Station directory` · `Synced 2 min ago` · `Not synced` · `Delete downloaded maps` · `EV Guide works offline. Kigali's map is built in; download the rest of Rwanda for trips outside the city.` |
| D-08 | `Bay alerts` · `One alert when a bay frees up at a station you're watching. Nothing else.` · `Turn on notifications for EV Guide in system settings to use bay alerts.` · `System settings` · `Sign in to use bay alerts.` |
| D-09 | `Pick the plugs your car takes. EV Guide then shows what's free for your car.` · `Stored on this device. Sign in to keep it across devices.` |
| D-10 | `Version` · `Map data` · `OpenStreetMap` · `Open source licences` · `Privacy` · `Terms` · `Map data © OpenStreetMap contributors` · `EV Guide is free. It takes no payments and never will.` |
| D-11 | `Saved` · `Stations you save appear here. Tap the heart on any station.` |
| D-12 | `No alerts set.` · `Open a station and tap "Notify me when a bay frees up". One alert, next 2 hours.` |
| S-01 | `Sign in to save stations` · `Sign in to report status` · `Sign in to set an alert` · `Reading EV Guide never needs an account.` · `Sign in with Apple` · `Continue with Google` · `Continue with email` · `Send me a link` · `Check your email. The link signs you in.` · `Sign-in didn't finish. Try again.` · `You're offline. Sign-in needs a connection.` |
| S-02 | `What's happening at this plug?` |

Forbidden words: **`docs/availability-display.md` §2.2b**, cited at §13.1 and
restated nowhere.

---

## 14. What each screen owes the domain

| Screen | Projection consumed |
| --- | --- |
| D-01 | `stationsNear(origin, …)` → `geo` + `f = freeBaysOffering(T)` per station |
| D-02 card | **two-line** — `nameShort` / availability clause; plus **`rateShort`**, `Photo[0]`, route |
| D-02 list detent | repeated two-line + `rateShort` |
| D-03 | station detail by opaque stable id; **per-Connector state reachable** (amendment 8); `rateCoverage(station)` denominated in **plugs** (amendment 6); Grammar R; `rateShort` for the sticky bar |
| D-11 | two-line + `rateShort` over `SavedStation` |
| D-12 | `Watch` rows with `armedAt` |

Every one of them returns **structure, not formatted strings** (amendment 8) —
`(distanceMeters, nameShort)`, never `"~2.4 km · SP Remera"`. The phone formats
at the edge, exactly as Android must.

**One declared divergence from the car projections.** domain-model §Projections
says the two-line has no rate because *"rate has no room on a car row."* The
phone's card slot exists because the reference has one, and it is filled by
`rateShort` — a projection the car surfaces do not consume. Declared, not
discovered.

---

## 15. Answers to the verdict

Every finding from `13-design-verdict-v1.md`, answered. **Fixed** = the document
changed. **Rebutted** = the document did not change, with the reason.

### The five fatals

| # | Finding | Answer |
| --- | --- | --- |
| **F1** | Two words for `Occupied` | **Fixed by R1.** `busy` everywhere in this file: §2.2's pin diagram, D-02's variant table, D-03's regime table, S-02's control labels, §13.5's new-vocab table. Neither `in use` **nor its title-cased spelling** appears anywhere as product copy. Routed to `availability-display.md` §2.2b (the list's one home) and to its §2.1, whose own example carries the word. **[RE-DERIVED, ticket 32]** — this cell used to assert the string's absence *while spelling it out in its title-cased form*, which R1 bans equally; the sentence is rewritten so the file no longer carries the string it forbids. The claim itself was, and is, true. |
| **F2** | Availability in the accent badge | **Fixed by R2**, which this file already agreed with. The badge carries peak power only (D-03 slot map). Additionally: the 1.21:1 measurement is now raised as [RAISE-D28] with a redundancy invariant, so nothing a driver must read sits there — see M12. |
| **F3** | `unreported` rendered / forbidden | **Fixed by R3.** The forbidden list lives in exactly one place — **`docs/availability-display.md` §2.2b** — and every other document, this one included, cites it and restates nothing. `no confirmed status` is the only permitted form and is what every regime table emits. Law 8's own wording and §2.1's example are routed for correction. **[RE-DERIVED, ticket 32]** — this cell named **§13.1** as the one place, which is what made this file the fourth claimant; §13.1 is now a citation and its restated table is deleted (§13.1). |
| **F4** | The card heart is `#717171`; "no grey tier" is false | **Fixed, and re-measured** — §0.3 row 4, 517 px of solid `#717171`, no white pixel in the ink box. The `04` heart and share (**67 × 67 px**, 10-v2 §8.1 row 22) glyphs *are* `#FFFFFF`, so the reference draws one icon in two colours: **[RAISE-D30]**, which part 1 now carries as its own **[RAISE-11]**. Per **R5** the no-grey claim narrows to **text**, where it is still true and still load-bearing; `color.iconMuted` **has landed** in 10-v2 §1.1 / §10.1. [RAISE-D11] is re-based on the measured default. **[RE-DERIVED, ticket 32] — two things in this cell were wrong.** (a) The stroke is **not** *"6.0 px unchanged"*: 10-v2 §8.1 row 17 integrates the card heart at **4.8–6.0 px** and §8.2 files it in the **Light** band at **4.8 px = 1.6 pt**, against the nominal 6 px = 2 pt — so the heart is lighter *as well as* greyer, and the claim that only the colour differs does not hold. That matters for [RAISE-D30]/[RAISE-11]: the two hearts differ in **three** ways (size, colour, stroke band), not two. (b) The closing dependency — *"`10-design-system-v2.md` did not exist when this file was written; until it does, §0.3 is the citation"* — is spent: v2 landed, and §0.3 now records how each of the six corrections was adjudicated. |
| **F5** | No short rate projection | **Fixed by R4**, §13.2. `rateShort` is defined once in `packages/domain`, returns structure not strings, and is consumed by the card, the list detent, D-11's rows and the sticky bar. Grammar R stays on the detail only, and is now quoted verbatim there. A per-Connector rate is never rendered as the station's. |

### The fourteen majors

| # | Finding | Answer |
| --- | --- | --- |
| **M1** | Drag handle is 180 × 13 px | **Fixed.** Re-measured (§0.3 row 1) and corrected in D-02, S-01 and S-02. Owed back to part 1. |
| **M2** | The `03` sheet is a floating card with rounded bottom corners | **Fixed.** Re-measured (§0.3 row 2): all four corners at **19.5 px** [ticket 33], bottom edge y 2317, **64 px** of map below it. Corrected in D-02 (including the list detent), S-01 and S-02, with [RAISE-D34] for the bottom offset when no CTA sits below. **[RE-DERIVED, ticket 32]** — the *identity* correction was right and part 1 adopted it (10-v2 §0.2 M2, `StationCard` not `BottomSheet`, no `radius.sheet` token); the *frame* was not. The card is **x 65 → 1140, y 1797 → 2317 = 1076 × 521 px**, the map below it is **64 px** (this cell said 65), and the radius is **frozen under [RAISE-13]/ticket 33** rather than settled at either file's number. |
| **M3** | The one link in the system is underlined and no file records it | **Acknowledged, routed — and part 1 has landed it.** The link is `Show and edit my profile` (`02`, cap 27 Regular `#C7FC2F`). Underline is a **type property**, not a screen decision, so it belongs in part 1 beside the weight and colour, not here. **[RE-DERIVED, ticket 32]** — 10-v2 §4.4 now measures the whole decoration (rule x 380 → 825 = 446 px, **2.00 px = 0.67 pt** integrated, 3 px below the baseline, **no descender skip**) and §10.2 ships it as **`type.link`** with `skipInk: false` stated explicitly. The routing is discharged; the old pointer to *"§2/§8.2"* is replaced by **§4.4 / §10.2**. |
| **M4** | The basemap's palette and label hierarchy are unmeasured | **Rebutted as out of scope, and routed.** The basemap is the map *provider's* style (ticket 06, MapLibre + a self-hosted OpenMapTiles-derived style), not a `packages/ui` component; it is the only new work in the verdict and it is a style-JSON deliverable. Routed to ticket 06 with the note that it governs ~85% of the front door's pixels and that two of the reference's own labels (Rebero, Remera) do not exist in OSM (§11). |
| **M5** | The route string does not fit the chip | **Fixed by re-solving.** §7.2 checks the fit against the **chip** (254 px measured, 86/30 padding measured) rather than the column, with a stated advance constant (§0.4). The placement survives **only** if the chip is content-sized, which the reference cannot prove from one instance — **[RAISE-D27]**, recommending content-sizing on the strength of the feature chip's measured **four**-width behaviour, and naming the impossibility that follows if the answer is no. **[RE-DERIVED, ticket 32]** — the padding 86/30 is confirmed and part 1 has been corrected **to** it from 88/29; the feature chip's measured widths are **271 / 316 / 387 / 652** (four instances, not the two this file cited), which strengthens the recommendation. Verdict unchanged. |
| **M6** | There is no full-width CTA anywhere | **Fixed.** §0.3 row 5: the CTA is **899 px** because the locate button takes the right end; the width is a residual and is never tokenised. S-01's stack is re-derived to the card's own inner box, **948 px** — **[RAISE-D31]**. **[RE-DERIVED, ticket 32]** — this cell said *897 px* and *950 px*. The finding is unchanged and its evidence is now sound: on 10-v2's figures the residual identity closes exactly (`899 + 40 + 139 = 1078`), where this file's `897 + 41 + 137 = 1075` was three pixels short and did not hold. |
| **M7** | Chips made interactive; file 12 rejected the same idea | **Fixed, one answer.** §12.3 adopts file 12 §4.3's ruling verbatim and applies it product-wide: chips are labels; controls take CTA geometry. S-02's controls and D-03's bay-watch control are rebuilt on it. The only divergence from file 12 is layout (stacked vs three-up), stated with the container arithmetic that forces it — recomputed under ticket 32 at the corrected card inner box of **948 px**, where the three-up leaves **3.5 px** each side and still fails. One figure inside the adopted quotation is wrong and is annotated rather than silently edited: the category chip is **25.3 pt**, not 25.7 (§12.3). |
| **M8–M9** | *(not enumerated in the verdict summary; if they carry findings, they are unanswered here and this file says so rather than pretending otherwise)* | **Open.** |
| **M10** | Bare `GB/T` is not in the closed projection | **Fixed and routed, not closed.** Every string in this file uses the qualified forms. **[RAISE-D32]** (§13.4) states the three open questions — legality, membership, multi-member lenses — and routes them to ticket 18 and to `02-androidauto-design-v3.md` §3.5, which shipped the bare form in Grammar R. |
| **M11** | D-02 has no behaviour table; screens have no entry points | **Fixed twice.** §8.0 is an exhaustive entry-point table for all fifteen surfaces. D-02 now has a behaviour table whose first row is *the station card pushes D-03*, and every other screen and sheet gained one. |
| **M12** | `#FFFFFF` on `#C7FC2F` is 1.21:1 | **Raised.** [RAISE-D28], with the contrast recomputed here (1.21:1 against 15.52:1 for `color.onAccent`) and a redundancy invariant that makes R2's peak-power badge safe: nothing may appear in the badge that is not also in `#FFFFFF` text on the same screen. The 1:1 reproduction is recommended; the one-token alternative is named, not chosen. |
| **M13** | The free-bay dot straddles the lime outline; its ring lands on white | **Fixed by re-derivation.** §2.4 measures the pin (bbox **122 × 147**, head circle fitted to **r = 61.25 ± 0.15** at 0.12 px rms, inner disc **⌀ ≈97** so the white body runs to r ≈60) and shows the collision in numbers: at v1's (+46, −46) the dot's lime spans r **55.1–75.1**, crossing the rim, and its ring lands on the white body. The avatar escapes only because it has no rim. New offset **(+54, −54) px**, tangent to the rim — **[RAISE-D26]**, with the argument that 1:1 on a *mark* means preserving legibility, not the arithmetic that produced it on a rimless host. **[RE-DERIVED TWICE, ticket 32] — the answer moved by one pixel.** The pin's 122 × 147 was this file's number and part 1 has been corrected to it, from 120 × 147 — do not reverse that. But the tangent constraint is `d ≥ 61.25 + 14.5 = 75.75`, so the offset is **54**, not 53: v1's own `d ≥ 75.5` never admitted 53 (`53√2 = 74.95`), and ticket 32's first pass rescued 53 only by setting the head radius to 60 on the false premise that a circle is narrower along its diagonal. At 53 the ring's inner edge sits at 60.45 against a rim at 61.25 and **overlaps by 0.80 px**. `SPEC.md` §6's locked `(+53, −53)` is **corrected to (+54, −54)**. |
| **M14** | "Full width, no inset" across three margin families | **Fixed.** §5.1 defines it once as a relationship to the row's container, tabulates all three containers, and raises the generalisation from a single measured instance — **[RAISE-D29]**. **[RE-DERIVED, ticket 32]** — two of the three container rows were wrong (the measured divider's core is **x 39 → 1166**, not its AA extent x 38 → 1167; the card inner box is **x 129 → 1076 = 948 px**, not x 128 → 1077 = 950), and the file then **broke its own ruling two sections later**: D-03's connector rows moved their divider to the 64 px page column and left the label at **x 196**, which is the label's position in the *38 px* container. Corrected to **x 222** (`64 + 158`, 10-v2 §5.2). That is the one place the M14 defect had actually survived into a drawn screen. |

### The minors named in the brief

| # | Finding | Answer |
| --- | --- | --- |
| **m1** | Silent re-measuring | **Fixed.** §0.3 is a measurement policy plus a complete, declared list of every [m·11] value, with the method for each and an explicit statement of what it contradicts in part 1. §0.4 fixes the advance model, so no fit check anywhere below uses an unstated constant. |
| **m2** | The worked station disagrees with CarPlay S1 | **Fixed.** §0.5 adopts S1 unchanged, **2.4 km**, and reconciles the Regime-1-first rule with S1's operator reports as *the same station at t = +6 h* rather than a second dataset. The driving pair (2.9 km / 8 min) is labelled fixture data, phone-only, because ADR-0004 forbids duration on car surfaces. |
| **m3** | Row-count contradiction | **Fixed.** §5's "keeps the reference's row count exactly" is retracted in place and replaced with what is true: four reference rows kept 1:1, two `[ext]` rows added below the capture's cut-off, pitch and treatment unchanged throughout. D-04's table now marks each row [ref-02] or [ext]. |
| **m10** | Grammar R paraphrased | **Fixed.** Quoted verbatim at D-03, including its three deliberate choices and the session-fee rule, plus the phone's one-line join rule stated once. v1's drifted forms (`all 4 plugs`, `0 of 4 plugs`) are gone. |

---

## 16. Raised — impossibilities, gaps and questions

Per the standing rule these are raised, not resolved. **Two are genuine
impossibilities** ([RAISE-D20], §11); the rest are values or components the
reference cannot supply. D1–D25 keep their v1 numbers so earlier correspondence
still resolves; D26–D34 are new in this revision.

| # | What | Recommendation |
| --- | --- | --- |
| **D1** | The pin cannot distinguish Occupied / OutOfService / Unknown | accept — one additive channel, spent on the only actionable fact |
| **D2** | Phone pin dot carries presence; CarPlay's carries a numeral | declare the divergence; presence-only on the phone |
| **D3** | Phone pin carries no Owner mark; CarPlay's does | uniform charger glyph; owner on the card and detail |
| **D4** | No selected-pin treatment; no cluster mark | no selection treatment (1:1); **do not cluster** in v1 |
| **D5** | Crosshair arm insets are asymmetric (29 / 34 px) | inherits part 1's [RAISE-5] ruling |
| **D6** | Quick-action row is two circles until ticket 30 ships | ship two, then three |
| **D7** | The gap left by an absent hosting card (154 vs 164 px) | 164 px |
| **D8** | **Route line width has no reference value** — the only invented dimension | 12 px = 4 pt, round caps |
| **D9** | Two-line card subtitle; 45 px pitch derived, not measured | accept; card becomes content-sized (one-line case **521 px**, two-line 566 px) |
| **D10** | List detent: height unmeasured, **and** the CTA's behaviour once expanded | ~70% of screen; CTA stays and collapses the detent |
| **D11** | Heart states, re-based on the measured `#717171` default | `#717171` unsaved → `#C7FC2F` filled saved |
| **D12** | **`Description` has no field behind it** | add nullable `Station.description`; title the block `Getting there`; route to 19 |
| **D13** | No driver channel for non-availability corrections | new ticket if wanted; not a menu item |
| **D14** | Settings rows have no value slot | compose with the card's right-aligned price treatment, right edge at the divider's **core** end (x 1166 in the settings container) |
| **D15** | No destructive treatment exists | `Delete account` is an ordinary row; weight goes in the copy |
| **D16** | No progress component exists | text percentage only |
| **D17** | **No switch / checkbox / toggle exists anywhere** | one trailing `#C7FC2F` check at the chrome icon metrics — `size.iconGrid` 24 pt, `size.iconStroke` 2 pt — used everywhere |
| **D18** | `My plug` ungated — flagged for founder ratification by the domain model | keep ungated |
| **D19** | Watch vocabulary contradicts across three surfaces | route to 30; do not settle it a fourth time here |
| **D20** | **Sign in with Apple cannot be restyled — impossible 1:1, and compelled by Guideline 4.8** | Apple's native button with `cornerRadius` **16.5 px** [ticket 33] |
| **D21** | **No text input exists anywhere in the reference** | build from the feature-chip surface; add to `packages/ui` |
| **D22** | No selected-control state → the report sheet commits on one tap | accept; reports are append-only |
| **D23** | Report action labels are not in the closed vocabulary | add `Free` / **`Busy`** / `Out of service` to `packages/domain` |
| **D24** | No onboarding designed | new pass if commissioned; copy already constrained by 28 |
| **D25** | The location puck is Google's `#4285F4` | redraw at part 1 §2.5's measured geometry (disc ⌀40, ring 4 px, halo ⌀82 @19 %) in `#FFFFFF` + `#C7FC2F` — **contested**: part 1's own [RAISE-10] notes the lime collides with the pin outline (§11) |
| **D26** | **The free-bay dot fuses to the pin's lime rim at the measured proportion** (§2.4) | offset **(+54, −54) px**, tangent to the rim — re-derived at the measured head radius **61.25**, `d ≥ 75.75`; SPEC.md's (+53, −53) corrected |
| **D27** | **The category chip's width behaviour is unmeasurable** — one instance (§7.2) | content-sized, per the feature chip's measured **four**-width rule; **if no, the route preview cannot live in the chip** |
| **D28** | **The hero badge's `#FFFFFF` label measures 1.21 : 1** (D-03) | reproduce 1:1 + the redundancy invariant; `color.onAccent` named as the alternative |
| **D29** | **"Full width, no inset" is generalised from one container** (§5.1) | accept the container-relative rule |
| **D30** | **The same heart icon is `#717171` on `03` and `#FFFFFF` on `04`** (§0.3) | reproduce both; `color.iconMuted` **has landed** in part 1 §10.1, which raises the same question as its **[RAISE-11]**. Note the two hearts differ in **three** ways — 50 × 46 vs 66 × 62, `#717171` vs `#FFFFFF`, and **4.8 px vs 7.0–8.0 px** stroke |
| **D31** | **No full-width button exists; S-01/S-02's width had to be derived** (S-01) | **948 px** = the card's inner box (`x 129 → 1076`, from the §7.4 frame and `space.floatingCardPadding`); 27 px between |
| **D32** | **Bare `GB/T` is not in the closed projection** (§13.4) | **open — routed to 18 and to Grammar R**; qualified forms used meanwhile |
| **D33** | **The price slot's weight composition when there is no amount** (§13.2) | `No confirmed rate` renders Regular at the same cap height — but see **[RAISE-15]**: the tail weight it is being compared against is itself unsettled (Regular on `04`, ExtraLight on `03`) |
| **D34** | **The card's bottom offset when nothing sits below it** (S-01) | 103 px = 34.3 pt above the screen bottom (the `03` gap it replaces is **64 px**, not 65) |
| **§11** | **The `Google` wordmark is unreproducible** | replace with `© OpenStreetMap contributors` in the same slot; record as a knowing deviation |

Inherited from part 1 and unresolved here because they are not this file's to
settle: **[RAISE-1]** the typeface and its old-style figures — which also blocks
every fit check in §0.4 from becoming a guarantee; **[RAISE-2]** ExtraLight body
at 13 pt; **[RAISE-3]** normalise the spacing or not; **[RAISE-4]** two different
CTA sizes; **[RAISE-5]** four alignment defects — including [5a], the chip
padding §7.2 inherits, now corrected in part 1 **to this file's 86 / 30**;
**[RAISE-6]** the sticky bar's 90 px padding; **[RAISE-8]** two blacks on the
accent; **[RAISE-9]** five circular-button diameters; **[RAISE-10]** the puck's
Google blue (D25 above); **[RAISE-11]** the two hearts (D30 above);
**[RAISE-12]** the basemap's minor label tier at 3.49 : 1, which belongs to the
style JSON routed to ticket 06 (§15/M4).

**Three raises added to part 1 by ticket 32, which govern values in this file
and are not this file's to settle:**

| # | What | Effect here |
| --- | --- | --- |
| **[RAISE-13]** → **ticket 33, CLOSED 2026-08-16** | Part 1 §6's radius method stated a false geometric identity, so **every published radius was under-read** by about `√r` | **Released.** All six outstanding rows re-fitted; every frozen marker in this file replaced by its corrected value. Two findings changed what gets typed: the **category chip, hero badge and drag handle are pills**, and both CTAs share **one** 16.5 token. See the authority note. |
| **[RAISE-14]** → **ticket 34** | The extent convention (core / integrated / AA-inclusive) is undeclared, and part 1 uses two of them — the primary CTA published AA-inclusive, the floating card at core | This file re-derives against **what part 1 publishes** (CTA 899 × 138, card 1076 × 521, sticky CTA 513 × 131, pin 122 × 147). If ticket 34 declares core or integrated, those four and everything derived from them move. |
| **[RAISE-15]** | The price string `135 000 RWF/day` is **two weights**, and part 1 §4.1 row 15, §7.8 and §11.3 all call it one | §13.2's four consuming slots are marked **[weight unsettled]** with both measurements stated; no per-slot assignment is invented here, and the Bold advance constant k = 0.80 (§0.3 row 6) is flagged as measured on a mixed-weight run. |

---

## 17. The inventory table

| Screen | Ref or ext | Components used | States | What fixes its content |
| --- | --- | --- | --- | --- |
| **D-01 Map home** | **[ref-01]** | map canvas · crosshair rule §7.11 · map avatar §7.9 (no dot) · charger pin §7.3 (**122 × 147**) + status dot §7.9 at (+54,−54) · primary CTA §7.1 (**899 × 138**) · locate button §7.2 (**⌀139**, 40 px gap) · feature chip §7.5 (offline) · attribution mark | default · offline · no-permission · signed-out · (no loading, no empty, no error) | ADR-0002 · ADR-0007 · ticket 06 · ticket 19 |
| **D-02 Map + station card** | **[ref-03]** | **floating card** §7.4 (**1076 × 521**, x 65 → 1140, y 1797 → 2317; r **19.5** all corners [ticket 33]) · drag handle **180 × 13**, 25 px down · thumbnail · category chip §7.5 (route, content-sized) · `rateShort` price composition (**[weight unsettled: RAISE-15]**) · heart `#717171` · route line (new width, D8) · divider §5.1 at the **948 px** inner box (list detent) | Regime 1 / 2 / 3 / lensed / no-compatible-plug · route-in-flight · route-failed · offline · signed-out · saved · uncached-photo | availability-display §2 · ADR-0004 · ADR-0007 · ticket 10 · ticket 19 |
| **D-03 Station detail** | **[ref-04]** | circular buttons §7.2 (**⌀80, ⌀98**) · hero carousel **1078 × 612** + indicator (**95 × 16**, 26 px above the hero bottom) + badge **248 × 70** with a **stroked** bolt §7.7 (peak power, D28) · title/subtitle · owner row · settings rows §7.6 (connectors, divider x 64→1141, **label x 222**) · feature chips §7.5 · **CTA-geometry bay-alert control** §12.2 · sticky bar §7.8 (**513 × 131**) with `rateShort` | all availability regimes · Grammar R's five rate cases + session fee · offline · signed-out · not-at-station · uncached-hero | ADR-0002 · ADR-0008 · ADR-0004 · ticket 10 · ticket 30 · **D12 (schema)** |
| **D-04 Profile** | **[ref-02]** | back button §7.2 (**⌀90**) · profile avatar §7.9 · quick actions §7.2 (`size.quickAction` ⌀150) · hosting card §7.10 (**1128 × 334**, tile **256 × 257**) · settings rows §7.6 (4 [ref] + 2 [ext], divider core **x 39 → 1166**) | signed-in · signed-out · membership / no-membership · app-installed / not / undeterminable · offline | ADR-0003 · ADR-0006 · ticket 11 · ticket 15 |
| **D-05 Personal Information** | [ext] | back (**⌀90**) · heading (**cap 36 Bold**) · settings rows + value slot (D14) · text input (D21) | signed-in only · offline · error-in-place | ADR-0003 |
| **D-06 Login & Security** | [ext] | back · heading · settings rows + value slot | providers connected / not · sign-out · delete-account confirm · offline | ADR-0003 · Guideline 5.1.1(v) |
| **D-07 Offline & map data** | [ext] | back · heading · settings rows + value slot | not-downloaded · downloading · downloaded · update · offline · failed · synced / not-synced | **ADR-0007** · ticket 06 · ticket 16 |
| **D-08 Notifications** | [ext] | back · heading · settings rows + trailing check (D17) | granted · denied · signed-out | ticket 30 · ADR-0003 |
| **D-09 My plug** | [ext] | back · heading · settings rows + trailing check · body copy | none-selected (default) · selected · signed-in (syncs) · signed-out (local) | ADR-0002 · ticket 12 · ticket 19 · **D18** |
| **D-10 About EV Guide** | [ext] | back · heading · settings rows + value slot · body copy | static | **§11 attribution** · ticket 06 |
| **D-11 Saved** | [ext] | back · heading (**cap 36 Bold**) · station cards (D-02 composition, `rateShort`) · dividers §5.1 | populated · empty · offline | ADR-0003 · ticket 19 |
| **D-12 Alerts** | [ext] | back · heading · settings rows + value slot | armed · empty · at-ceiling · offline | **ticket 30** · ticket 23 |
| **S-01 Auth sheet** | [ext] | floating card (**1076 px** wide, handle 180 × 13 at 25 px, r **19.5** all corners [ticket 33]) · CTA geometry at **948 px** (D31) · hosting-card fill §7.10 · Apple's native button (**D20**) · text input (**D21**) | idle · in-flight · success (auto-resume) · cancelled · failed · offline · email path | **ADR-0003 as amended** · ADR-0004 · ticket 23 |
| **S-02 Report sheet** | [ext] | floating card · **three CTA-geometry controls, stacked** (§12.3) | signed-out · not-at-station · offline (queues) · expired | ADR-0002 · ADR-0007 · ticket 09 · ticket 11 |
| **S-03 Overflow menu** | [ext] | platform action sheet | — | **D13** |

---

## 18. What this file does not decide

The operator app's screens (a separate app, ADR-0006) · the admin dashboard
(tokens only, and the 1:1 rule does not govern it) · anything in part 1's raise
list · the basemap style (verdict M4, routed to ticket 06) · ticket 30's
watch-vocabulary reconciliation · the `Station.description` schema addition,
which is ticket 19's to accept or reject · the legality of a bare `GB/T` (D32,
routed to ticket 18) · and every founder call in §16, which is the point of
raising them.

**Three of part 1's questions now govern numbers printed in this file, and none
of them is this file's to answer** (§16): **[RAISE-13]** every radius, routed to
**ticket 33** — closed 2026-08-16; every radius here is released and corrected;
**[RAISE-14]** the extent convention, routed to **ticket 34** — the four
published sizes this file re-derives against will move if core or integrated is
declared; **[RAISE-15]** the price string's two weights — §13.2's four consuming
slots carry both measurements and no assignment.

**The dependency this section used to name is discharged.**
**[RE-DERIVED, ticket 32]** — it read *"`10-design-system-v2.md` does not exist
yet … until it lands, §0.3 is the citation of record for those six values and
part 1's originals are void."* File 10-v2 has landed, all six corrections are
adjudicated in §0.3 (five accepted, one — the CTA width — rejected in this
file's disfavour), `color.iconMuted` `#717171` is in part 1 §10.1, and **part 1
is the citation of record again**. Two corrections went the other way and are
recorded as such rather than reversed: the **map pin at 122 × 147** (§2.4) and
the **category chip's 86 / 30 padding** (§7.2) are this file's measurements, and
part 1 has been brought into line with both. A later pass must not "restore"
120 × 147 or 88 / 29.

**Corrections this file owes to documents it may not edit**, found by the
ticket-32 re-derivation and stated here rather than applied:

| Document | What is wrong |
| --- | --- |
| `12-operator-admin-screens-v2.md` §5.1 | `39 + 257 + 39 = 335 exactly [m]` — false in the arithmetic and in the marking. The hosting card closes as **`39 + 257 + 38 = 334`** (part 1 §7.10: padding is 39 top and left, **38 bottom**). Its M9 reconciliation survives unchanged (3-line body ends y 1718, tile floor y 1743, clearance 25 px; a 4th line reaches y 1763, overrun 20 px). |
| `12-operator-admin-screens-v2.md` §4.3 | The category chip is **25.3 pt**, not 25.7 (§12.3 here quotes the sentence and annotates it). |
| `12-operator-admin-screens-v2.md` §4.3 | *"`Out of service` … does not fit"* is computed at an advance constant no file measures. At every legitimate constant it fits three-up in the 1078 px column. That is file 12's fit, not this file's, and it is the one fit in either inventory that passes only at the wrong number. |
| `docs/availability-display.md` | The three corrections at §13.1, unchanged. |
