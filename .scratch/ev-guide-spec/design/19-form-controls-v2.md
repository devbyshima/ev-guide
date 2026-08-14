# 19 — The form controls (design stream 2, v2)

Ticket 31, design stream 2 of 2. Supersedes `15-form-controls-v1.md`, which
`17-form-controls-verdict-v1.md` rejected on three fatals, eight majors and ten
minors. This is a standalone document, not a diff; §14 answers every finding.

Stream 1 owns **the seven interaction states** (pressed, disabled, focused,
loading/in-flight, error/retry/validation, empty, destructive confirmation).
This file owns **the controls**: what the write screens require, what
`packages/ui` must build, and what the reference cannot supply.

The premise is file 12 §1, restated because it governs every line below: **the
reference is a read design with one button per screen.** It contains no field,
no switch, no checkbox, no radio, no stepper, no picker, no slider, no date
control, no search field, no reorder handle and no multi-select. Every control
below is therefore assembled from measured surfaces or marked invented. There is
no third category, and silent invention is the defect this pass exists to catch
— three rounds have now caught it five times, twice in v1 of this file.

---

## 0. How to read this file

### 0.1 Scope, and the seam with stream 1

| This file decides | Stream 1 decides |
| --- | --- |
| Which controls exist, and which are refused | Whether a pressed state exists, and what it looks like |
| Each control's box, fill, radius, type treatment, insets | Whether a focus ring exists product-wide |
| Where a control's value, label and unit sit | The disabled, loading, empty and confirmation treatments |
| Caret, selection, placeholder, keyboard avoidance, validation position | Error *appearance*; this file fixes error *position* only where a control forces it |

Four places the seam is load-bearing, named so neither stream assumes the other
closed them:

1. **A field with no focus treatment is a field the user cannot find.** §7.4
   recommends caret-only focus and states the cost; whether a focus ring exists
   at all is stream 1's.
2. **A disabled field and a read-only value slot must not render identically.**
   §2.5 and §4.5 both hit this; the resolution is stream 1's to supply.
3. **O4's Save CTA at zero touches** is specified by file 12 §4.4 rule 4 as
   `color.surface` — a disabled treatment already chosen. §5.2 [C4] checks it.
4. **An *empty* field and a button are the same box** (§2.6). Stream 1's focus
   treatment cannot fix that, because focus is post-tap and the problem is
   pre-tap. Named so stream 1 is not credited with closing it.

### 0.2 Marking legend

- **[m]** — measured from `refs/01.png`–`04.png` by `10-design-system-v2.md`,
  cited by token or section.
- **[m·15]** — measured from the PNGs by v1 of this file. All six were re-run
  for this revision and all six reproduce; they are carried verbatim.
- **[m·19]** — measured from the PNGs **by this revision**. Every one is listed
  in §0.3 with its method; there are no undeclared measurements below.
- **[d]** — derived by stated arithmetic from [m] values.
- **[?]** — cannot be measured; the reason is given.
- **[INVENTED]** — no measured source. Every one appears in §11 with a
  recommendation and a cost.

**One clarification the "no third category" rule needs, stated once.** A
*component* with no measured precedent is marked **[INVENTED]** even when every
*value* inside it cites a token. The caret is the clean case: its colour is
`color.accent` [m], and the caret itself does not exist anywhere in the
reference. The raise then records what was invented — **the object, not the
number** — which is the honest statement and a stricter one than either
extreme. Where a table row is [INVENTED] but built wholly of tokens, the tokens
are named in the same row.

**The closed vocabulary is cited, never restated.** The forbidden strings live
in `docs/availability-display.md` **§2.2b** and nowhere else; the connector
type-word projection and the state words live in **§2.4** of the same file. This
document names neither list. Where a count is needed (D-09's five rows) the
count is given and the strings are not.

### 0.3 Measurement authority, convention, and this file's own measurements

**`10-design-system-v2.md` is the measurement authority**, corrected by
`13-design-verdict-v2.md`. This file uses the corrected values without
re-arguing them. *(The verdict re-checked this table against
`13-design-verdict-v2.md` and found it accurate on all six rows; it is carried
unchanged.)*

| Value | Used here | Source |
| --- | --- | --- |
| `radius.button` | **13 px = 4.3 pt** | 10-v2 §10.4; verdict MAJOR-4 (files 11/12's 13.5 px / 4.5 pt are void) |
| `radius.floatingCard` | **14 px = 4.7 pt**, all four corners | 10-v2 §6; verdict FATAL-2 |
| CTA label cap | **36 px** | 10-v2 §4.1 row 5; verdict MAJOR-4 |
| Circular buttons | **⌀80 / 90 / 98 px** | 10-v2 §7.2; verdict MAJOR-4 |
| `size.pin` | **122 × 147 px** | verdict MINOR-2 (file 11 wins) |
| Category chip padding | **86 / 30 px** | verdict FATAL-2 (file 11 wins) |

**Row 3 is binding on this file's own arithmetic, and v1 broke it.** *Every*
fit check below that involves a CTA label is computed at **cap 36**. v1's §5.2
computed three of four rows at cap 37 — a value its own authority table declares
void — and then instructed the corpus to write down the resulting margin. §5.2
recomputes it.

**Convention (verdict MINOR-8 of 13-v2).** Every dimension below is a **core**
measurement — the run of the exact colour, anti-alias columns excluded. Where a
figure differs from a document quoting an AA-inclusive number, the difference is
1 px and is not a disagreement.

**v1's six measurements, re-run and carried verbatim [m·15]:**

| # | What | Measured | Method | Re-run |
| --- | --- | --- | --- | --- |
| 1 | Feature-chip widths, `04` | **270 / 316 / 387 / 652 / 397 / 371 px** — six distinct widths on one screen (rows y2056–2160, y2187–2291, y2318–2336 clipped) | `#393939` run-length scan at y2065 / y2196 / y2330 | exact |
| 2 | Chip gaps | horizontal **27 px**, vertical **26 px** | same scan | exact |
| 3 | Settings dividers, `02` | y2188 / y2364 / y2541, core **x39 → x1166 = 1128 px**, `#3E3E3E`, 1 px | full-row colour count | exact |
| 4 | Settings row 1 icon ink | y2241–2311, x45–108 | white-ink bbox | exact — **and see [m·19] #5** |
| 5 | Settings row vertical centring | icon ink centre against row centre — centred within **0.5 px** | (divider + divider)/2 vs ink bbox centre | exact |
| 6 | The settings row's empty trailing region | label ink ends x535 (row 1) / **x598** (row 2); divider ends x1166 → **568 px = 189.3 pt of empty row** | white-ink bbox per band | exact |

**This revision's own measurements [m·19].** All from `refs/04.png` / `02.png`,
integrated coverage against `#121212`→`#FFFFFF`, columns/rows counted at ≥0.5 px
of ink.

| # | What | Measured | Method | Against file 10 |
| --- | --- | --- | --- | --- |
| **1** | **Digit *advances*, cap 36** (`04` sticky price, baseline 2446) | `0` = **32 px exactly** — two same-glyph pitches, ink starts x187 → x219 → x251. `1`→`3` start-to-start **25 px** (x92→x117); `3`→`5` **29 px** (x117→x146) | column runs at ≥0.5 px coverage | **new.** 10-v2 measures **no digit advance anywhere.** The `0` figure is exact (identical glyphs, sidebearings cancel); the `1` and `3` figures are start-to-start proxies and carry the two glyphs' sidebearing difference |
| **2** | **Digit ink *heights*, cap 36** | `1` y2417→2446 = **29 px above the baseline**; `0` y2416→2447 = **30 above, 1 below**; `3`/`5` descend to y2454 | same | **confirms 10-v2 §3.2's `1` 29 · `0` 31 are heights**, not widths. `R`/`F` cap y2410→2446 = 36 ✓ |
| **3** | **The unit's weight**, cap 36 | `F` stem **6.92 px** (0.192 stem/cap → **Bold**); `d` **8.84 px across two stems = 4.42 each** (0.123 → **Regular**); `1` **6.76 px** (0.188 → Bold) | flat-plateau row integrals over the x-height band | **confirms** *amount Bold + slash-unit Regular* (file 11 §1 substitution 3). **Contradicts 10-v2 §4.1 row 15's run name**, which folds `/day` into a Bold row |
| **4** | **The amount→unit gap**, cap 36 | `F` ink ends x407, `/` ink starts x411 → **3 px** | same | **new.** The reference sets amount and unit **solid, as one run** — there is no layout gap to inherit |
| **5** | **Settings row 1 icon ink height** | **71–72 px** (y2240–2311 at coverage ≥0.5), width 64 px (x45–108) | white-ink bbox | **contradicts 10-v2 §7.6's "icon ink 62–68 px"**, which holds for the *width* and not the *height*. 72 px is exactly `size.iconGrid` |
| **6** | **Feature-chip boxes on `04`** | **six** `#393939` boxes — 3 + 1 + 2 across three rows; the third row is clipped at y2336 by the sticky bar (y2337) and carries no visible label | `#393939` run-length scan | 10-v2 §7.5 lists **four** widths (271/316/387/652). Its §1.3 "four chip labels" is **right** — the two clipped boxes have none |

**Owed back to `10-design-system-v2.md`** (per file 11 §0.3's policy: a `[m·n]`
value that contradicts part 1 is stated as a contradiction, never resolved by
silently preferring one number):

1. **§3.2's `Digits` column needs a header note.** `1` 29 · `0` 31 are ink
   heights above the baseline. v1 of this file read them as widths, and nothing
   in §3.2 stops the next reader doing the same. Add: *"heights, not advances;
   no digit advance is measured in this document."*
2. **§4.1 row 15's run name over-reaches.** The row is titled
   `Card price 135 000 RWF/day` and reports one stem (5.05, Bold). [m·19] #3
   measures the `/day` half at Regular. The *stem* is right; the *run* it names
   is the amount only. Same for row 7, whose name (`135 000 RWF`) is already
   correct.
3. **§7.6's "icon ink 62–68 px"** does not hold vertically ([m·19] #5).
4. **§7.5's chip width list is four of six** ([m·19] #6).

Measurement [m·15] #6 is the one the rest of this file leans on: it is the only
uncommitted horizontal space in the settings-row family, and **three
propositions want it** — the value slot ([RAISE-D14]), the trailing check
([RAISE-D17]) and the in-row edit field ([RAISE-D21] as consumed by D-05).
§4.2 and §2.4 settle the collisions.

### 0.4 The advance model

Inherited unchanged from file 11 §0.4: **ink ≈ k × cap_px × nChars**, k at the
pessimistic end for the weight — Regular **0.73**, Medium **0.65**, Bold
**0.80**. A fit is asserted only when it holds at that constant.

**One gap named rather than papered over:** the corpus has **no measured
cap-32 Regular advance**. The 0.73 constant was measured at cap 27 (file 11
§0.3 row 6). Every capacity figure below applies it at cap 32, which is the
policy §0.4 mandates and is conservative in the safe direction — a capacity
claim computed at a pessimistic advance is a **lower bound**, so "this does not
fit" is safe and "this fits" carries the constant's error.

### 0.5 What changed from v1

| # | v1 said | v2 says | Where |
| --- | --- | --- | --- |
| **1** | digits `1` 29 px / `0` 31 px are **widths**, cited to §4.1 row 7; column jitter ≈2 pt | they are **heights** (§3.2); measured advances are `0` 32 / `1` ≈25 at cap 36; column jitter **≈6.2 pt at cap 32** | §3.3 |
| **2** | the field box and the CTA-geometry button are one box — *"No contradiction"* | they are one box, and **that is the finding**: an empty field has no affordance. Raised as a founder call | §2.6, §5.1 |
| **3** | unit suffix at cap 32 **Regular**, "inside the field's 30 px trailing inset" | value cap 32 **Bold**, suffix cap 32 **Regular**, suffix pinned with its right edge at the trailing inset, value right-aligned to it and set solid (3 px, [m·19] #4) | §3.4, §2.3 |
| **4** | control-row margin *"4.6 px"*, computed at cap 37 | **13.7 px**, computed at the authorised cap 36 | §5.2 [C1] |
| **5** | *"one box, used three times… a cap-32 label"* | **one box at two label sizes** — S-01's provider buttons are cap 36 Medium, not 32 | §2.2 |
| **6** | the 20–30 % accent selection composite is *"the platform's value, not this design's"* | it is an **accent tint**, which §10.1 says does not exist. Founder call | §7.3, F19 |
| **7** | `tnum` in the numeric field if the face carries it | **`onum` + `tnum` together**; a lining `tnum` set is not a substitute | §3.3, F5 |
| **8** | `Bulk apply` opens a platform action sheet | `Bulk apply` **pushes a full-screen surface** — an action sheet cannot host checks plus a field | §4.2, F7 |
| **9** | F1 cost *"None"* | **four documents carry the sentence the redirect invalidates**, and all four are named | §2.2, F1 |
| **10** | A9's admin availability write control absent from both inventories | named, as three **admin-native** buttons | §10.1, F21 |
| **11** | *"the product authors no motion"* stated in prose | raised as the product-wide rule it is | §7.5, F20 |
| **12** | D-05 in-row field holds 20 characters | **32**, because the field column is set by *that screen's* widest label. The recommendation does not depend on the number | §2.4, §2.5 |
| **13** | S-01 card height 341.9 pt | **254.6 pt** idle / **364.6 pt** worst case; three of v1's terms were wrong | §8 |

---

## 1. The enumeration — every screen that writes, and what it writes

The ticket's instruction: start here, and design nothing a named screen does
not require. Assembled from file 11 §8/§17 and file 12 §3/§4/§7/§10.

### 1.1 Driver app

| Screen | Writes | Control required |
| --- | --- | --- |
| D-02 | `SavedStation` toggle | heart glyph tap — **not a form control** |
| D-03 | `SavedStation`; `Watch` arm/disarm; opens S-02 | heart; CTA-geometry control (§12.2); settings row as tap target |
| **D-05** | `User.name`; profile photo | **text field** ×1 (see §2.5 on `Email`); platform photo picker |
| D-06 | provider link/unlink; sign out; delete account | row taps + platform confirmation — **no form control** |
| D-07 | download / sync / delete map data | row taps — **no form control** |
| **D-08** | `Bay alerts` master switch | **trailing check**, boolean |
| **D-09** | `vehicleConnectorTypes[]` | **trailing check**, multi-select ×5 rows |
| D-11 | un-save | heart tap |
| D-12 | disarm a `Watch` | value-slot tap |
| **S-01** | auth; **the email path** | **text field** ×1 (email) + one CTA |
| S-02 | `Report` | three CTA-geometry controls, one tap commits |
| **S-03** | — | **connector picker** when >1 connector — *named twice in the corpus, specified nowhere* (§6.3) |

### 1.2 Operator app

| Screen | Writes | Control required |
| --- | --- | --- |
| O1 | auth; the email path | **text field** ×1 (email) + one CTA — inherits S-01 |
| **O4** | `Report` per Connector | **the control row** — three CTA-geometry controls ×N connectors + Save CTA (§5) |
| **O5a** | `ratePerKwhRwf`, `sessionFeeRwf` | **numeric field** ×2 per connector + CTA |
| **O5c** | the plug multi-select behind `Bulk apply` | **new pushed surface** (§4.2) — **trailing check** ×N + one numeric field + CTA |
| O5b | rate flag | **no entity exists** ([RAISE-OA-5]) — **no surface may be specified** |
| **O6** | invite by email; revoke | **text field** ×1 (email) + CTA + destructive confirmation — *box specifiable, form not* (§10.5) |
| O8 | — | readouts only; the queue row is explicitly non-interactive |

### 1.3 Web admin — tokens only, no React Native components, 1:1 does not govern

| Screen | Writes | Control required |
| --- | --- | --- |
| A1 | auth | native web |
| A2 | — (filters) | **selects over bounded sets** — owner, publish state, prerequisite. **No search** (§1.5) |
| **A3** | `name` ≤28, `nameShort` ≤18, `geo`, `owner_id`, `vehicleClassTag` | text ×2 + counter + **map picker** + select over the bounded Owner set + nullable select |
| **A4** | `type`, `powerKw`, `voltage`, rate fields, bay label | **select over the open OCPI enum** + numeric ×4 + text; **nested Bay→Connector editor** |
| **A5** | `displayName`, `shortName` ≤17, `markerLabel` 1–3, `icon` | text ×3 + **vector file upload** + **pin-scale preview** |
| A6 | membership grant/revoke; invite | text (email) + role select — **into an entity that does not exist** ([RAISE-OA-6]) |
| **A7** | `Photo` order, upload | file upload + **ordered grid, drag to reorder** |
| A8 | publish / unpublish | **the checklist is a read display, not a control** (§10.4) |
| **A9** | `Report`, `source = admin` | station / connector / **source** selects + **three admin-native availability buttons** (§10.1) |
| A10 / A11 | — | tables; A10's entity does not exist |

### 1.4 The control set that falls out

Seven, and no more:

1. **Text field** — D-05, S-01/O1, O6, and every admin text bound.
2. **Numeric field** — O5a, O5c, A4. A specialisation of (1) with a pinned unit
   suffix, not a separate box.
3. **The trailing check** — D-08, D-09, O5c.
4. **The CTA-geometry control** — already specified (file 11 §12.3, file 12
   §4.3). Checked here (§5), not redesigned.
5. **Select / picker** — the OCPI enum (A4), the Owner set (A3), roles (A6),
   filters (A2), A9's three selects — **all admin-native**; plus the one
   native-app case, the connector picker (§6.3).
6. **File upload** — `Owner.icon`, `Photo`, D-05's photo — **platform picker or
   native web**, never a `packages/ui` component.
7. **Ordered grid with reorder** — A7 only, **admin-native**.

Plus one control that is *not* a `packages/ui` component and needed naming
anyway: **A9's three admin-native availability buttons** (§10.1, F21).

### 1.5 The controls no screen needs — not designed, and why

| Control | Verdict |
| --- | --- |
| **Search field** | **Not required.** A2 filters over bounded sets; the driver app has none by ruling (file 11 §8, *deliberately not screens*). The brief's likely-set names "admin search"; **no named screen requires it**. If the station list ever outgrows its filters that is a new decision, not a control this pass may add. |
| **Date / time control** | **Forbidden, not merely unneeded.** `capturedAt` is stamped at tap (file 12 §4.4 rule 3) and authoring it is prohibited by name (file 12 §8 rule 4); `rateConfirmedAt`, `armedAt` and `updatedAt` are system-set. **A date control anywhere in the product is a defect**, and that is a cheaper test than a design. |
| **Stepper** | Not required. The brief names "bay counts": **there is no bay-count field.** Bays are rows created and deleted in A4; `3 bays · 5 plugs` is derived. `powerKw` / `voltage` are free numerics with no natural increment. |
| **Slider** | Nothing in the model is a continuous bounded range. |
| **Segmented control** | O4's control row is three CTA-geometry buttons in a row, not a segmented control — it has no shared track, no shared border, and its members are individually addressable. Naming it a segmented control would import a component the reference does not contain. |
| **Radio group** | See §4.4 — the honest finding is that single-select does not occur in `packages/ui`. |
| **Toast / snackbar** | Refused by file 11 S-02 by name. Confirmation is the write's own effect. |
| **Progress bar / spinner** | Refused by [RAISE-D16]; text percentage only. |
| **Multi-line text field** | **Conditional.** The only multi-line authored field in the model is `Station.description`, which is unratified and contested — file 11 [RAISE-D12] recommends adding it, file 12 [RAISE-OA-3] declines and re-tenants the region (13-v2 MAJOR-2). **Not designed here.** If ticket 19 accepts it, §2.7 states the one thing that would have to be settled. |

### 1.6 The screens that write nothing — stated, not left to be checked

**D-01** (map home), **D-04** (profile), **D-10** (About), **O2** (my stations),
**O3** (station detail), **O7** (station stats), **O9** (no memberships),
**A10** (audit) and **A11** (stats) carry **no form control of any kind**. Their
taps navigate or toggle a glyph; none writes a field. O8 carries one
non-interactive readout row. That is the complete complement of files 11 §17 and
12 §10.1/§10.2 — every screen in the corpus is either in §1.1–§1.3 or in this
paragraph.

---

## 2. The field box

### 2.1 Testing [RAISE-D21]'s proposal properly

[RAISE-D21] recommends building the text input from the **feature-chip
surface**: `#393939`, radius 10 px, height 105 px, cap-32 value. Tested clause
by clause rather than adopted:

| Chip property | Measured | Survives into a field? |
| --- | --- | --- |
| Fill `color.surface` `#393939` | [m] §7.5 | **Yes.** It is the reference's container for a labelled object on `#121212`, and the fill of every tappable thing in the system. |
| Radius `radius.chip` 10 px = 3.3 pt | [m] §6 | **No** — the box that survives (§2.2) carries `radius.button` 13 px. |
| **Height 105 px = 35.0 pt** | [m] `size.chipHeight` | **No.** See below. |
| Left padding 30 px = 10 pt | [m] `space.chipPaddingH` | **Yes**, as the field's text inset. |
| **Content-sized width** | [m·15] #1 — **six** widths on one screen: 270 / 316 / 387 / 652 / 397 / 371 px | **No.** A field's content is unknown at layout time and changes per keystroke; a content-sized field resizes while you type. Field width comes from its slot. |
| Label cap 32 **ExtraLight** `#FFFFFF` | [m] §4.1 row 13 | **No.** A 2.1 px stem on a value the user must proof-read is [RAISE-2] at its worst, and ADR-0009's one permitted mitigation is already *Regular instead of ExtraLight for data lines*. |
| Icon slot, 43 × 48 px at 4.2 px stroke | [m] §7.5 | **Not required.** No named field carries a leading icon. |
| Caret · selection · placeholder · focused appearance | **absent** [m] | **Nothing to inherit.** §7 designs these from elsewhere or invents them. |

**The height is the finding.** File 12 §4.3 rejected chip geometry for
*controls*, and file 11 §12.3 adopted that ruling **product-wide**:

> *the feature chip is **35 pt** tall and the category chip **25.7 pt**, and
> neither is interactive in the reference — they are labels. Both are under any
> tap-target floor.*

A text field is an interactive control. Taken literally — "height 105 px" —
[RAISE-D21] proposes a 35 pt tap target and **contradicts the rule the same
corpus adopted product-wide.** 35 pt is below both platform floors (44 pt iOS,
48 dp Android).

### 2.2 Where the box actually comes from

The corpus already derived the box this problem needs, three times, for the same
reason, and did not notice it also answers [RAISE-D21]:

| Surface | Box | Label | Source |
| --- | --- | --- | --- |
| S-01 / O1's two secondary provider buttons | `#393939`, **138 px**, radius 13 px | **cap 36 Medium** | file 11 S-01 (which writes *cap 37*; **cap 36 per §0.3 row 3**) |
| S-02's three report controls | `#393939`, **138 px**, radius 13 px | cap 32 Medium | file 11 §12.3 |
| O4's three unselected controls | `#393939`, `size.ctaHeight`, `radius.button` | cap 32 Medium | file 12 §4.3 |
| D-03's bay-watch control | `#393939`, 138 px, radius 13 px | cap 32 Medium | file 11 §12.2 |

**One box at two label sizes**, not one box at one. The *box* —
`color.surface` fill + `size.ctaHeight` 138 px + `radius.button` 13 px — is
identical in all four; the *label* is cap 36 on S-01 (which borrows the primary
CTA's own label size) and cap 32 on the other three (which borrow the sticky
CTA's, for the arithmetic reason file 12 §4.3 gives and §5.2 [C1] corrects).
That split is not drift in this file: it is **10-v2 [RAISE-4]**, the reference's
own two CTA label sizes, showing up in a derived component. Every value in the
box is a measured token.

*(v1 wrote "one box, used three times… a cap-32 label" and cited file 11 S-01
for a cap-32 label it does not contain. Corrected. The field's own cap-32
Regular **value** is unaffected — it rests on 10-v2 §4.1 row 12, the settings
row label, not on this table.)*

**Recommendation: redirect [RAISE-D21] from the feature chip to this box.** The
chip contributes the fill and the text inset — both of which this box already
shares — and contributes nothing else a field can use. The redirect removes the
§12.3 contradiction outright.

**It does not cost nothing.** Four documents carry the sentence it invalidates
and every one of them needs an amendment:

| Document | Sentence |
| --- | --- |
| **`SPEC.md` §12**, *Still owed by the design record* — **ratified** | *"**No text or numeric input exists**, and `packages/ui` must build one **from the feature-chip surface** for O5a and every admin form."* |
| **file 11, S-01**, the [RAISE-D21] paragraph | *"Recommendation: build it from the measured feature-chip surface (`#393939`, radius 10 px, height 105 px)…"* |
| **file 11 §16**, the D21 row | *"build from the feature-chip surface; add to `packages/ui`"* |
| **file 12 [RAISE-OA-4]** | *"File 11's [RAISE-D21] proposes building it from the feature-chip surface; this file **consumes that decision** and does not make a second one."* |

**Until all four land, a build reading SPEC.md ships a 35 pt tap target.** That
is the cost, and it is the reason F1 is a raise rather than a footnote.

### 2.3 The field box, specified

| Property | Value | Provenance |
| --- | --- | --- |
| Fill | `color.surface` `#393939` | [m] |
| Height | `size.ctaHeight` **138 px = 46.0 pt** | [m] |
| Radius | `radius.button` **13 px = 4.3 pt** | [m], 13-v2 MAJOR-4 |
| Border · shadow · blur | **none** | [m] §9 — no product surface has one |
| Width | the container's content box (§2.4) | [d] |
| Text inset, left and right | `space.chipPaddingH` **30 px = 10 pt** | [m] |
| **Text value type** | **cap 32 Regular `#FFFFFF`** — the settings-row label's own measured treatment (§4.1 row 12), 11.55 : 1 on the fill | [m] |
| **Numeric value type** | **cap 32 Bold `#FFFFFF`** — the price treatment (§4.1 rows 7/15, [m·19] #3), because a numeric carries a unit suffix and the weight contrast **is** the signal (§3.4) | [m] |
| Value alignment | **left** for text; for numerics, **right-aligned to the unit suffix's left edge** where a suffix exists, and to the field's trailing inset where none does (§3.4) | [d] |
| Cap-box top offset | **(138 − 32) / 2 = 53 px = 17.7 pt** | [d] |
| Descender clearance | 53 px below the baseline against a descender of 0.28–0.33 × cap = 9.0–10.6 px at cap 32 | [d] from ADR-0010's band |
| Caret | §7.3 | [INVENTED] |
| Selection | §7.3 | [INVENTED] |
| Placeholder | **none exists** — §7.1 | [m], refused |
| Focused appearance | §7.4 | stream 1 |
| **Empty appearance** | **§2.6 — a founder call, not a value** | raised |

**The derived cap-box offset reproduces the reference.** The primary CTA's
label is measured "optically centred, 50 px above cap, 51 px below baseline" in
a 138 px box at cap 36 [m §7.1]. Arithmetic centring predicts
(138 − 36) / 2 = **51** on both sides. The measurement and the arithmetic agree
within 1 px, so the system's "optical" centring **is** cap-box centring, and
§2.3's 53 px is a derivation rather than a guess.

**Two placement constraints.**

1. `color.surface` on `color.surface` is **1.00 : 1** — identical colours.
   **A field may never be placed on a `#393939` container.** No named screen
   does; the rule exists so no later one does. *(v1 wrote 1.08 : 1, which is
   `#3E3E3E` on `#393939` — §7.3's own second row. The correct figure makes the
   rule stronger, not weaker.)*
2. **A 138 px field inside a 176 px settings row leaves 19 px above and below**
   [d: (176 − 138)/2]. It fits, and it is the **tightest vertical clearance in
   the product** — the row's own measured content padding is 51–53 px [m §5.2].
   Named, not smoothed. An in-row field visibly thickens the row's rhythm and
   that is a consequence of using the only measured interactive height, not a
   choice available to be made differently.

### 2.4 Capacity, measured

The field's **left edge in a settings row is a column, not a per-row value**:
one column per screen, set at that screen's **widest label ink + `space.chipPaddingH`
30 px**. A per-row left edge would give one screen a ragged column of fields,
which is the same defect §2.1 rejects for content-sized chips.

| Placement | Field box | Inner width | Characters at cap 32 Regular, k = 0.73 |
| --- | --- | --- | --- |
| **S-01 / O1 card inner box** | **950 px** [d, RAISE-D31] | 890 px | **38** |
| **D-05 in-row** — widest label `Email` / `Photo`, 5 chars ≈ 117 px, so the column starts at x196 + 117 + 30 = **x343** | x343 → x1166 = **823 px** [d] | 763 px | **32** |
| **O5a in-row** — widest label `GB/T DC · 60 kW`, 15 chars ≈ 350 px → column at **x576** | x576 → x1166 = **590 px** [d] | 530 px | numeric; see §3.4 |
| **The floor** — a screen whose longest label matches the reference's own longest measured settings label (ink to x598) | x628 → x1166 = **539 px** [m·15 #6] | 479 px | **20** |
| **O6 invite** | the settings container, 1128 px [m·15 #3] | 1068 px | 45 |
| Admin | web layout — not this file's | — | — |

**O5a's numeric capacity, since it is the one place the suffix competes.**
Inner 530 px, less the `RWF/kWh` suffix at cap 32 Regular (7 chars × 0.73 × 32
= 163.5 px) = **366 px** for the value, at cap 32 Bold (0.80 × 32 = 25.6
px/digit) = **14 digits** [d]. RWF rates are three to four digits. **Never
width-bound.**

*(v1 quoted 20 characters for D-05 by applying the reference's own longest
settings label — measured on `02`, a different screen — to D-05's short row set.
The floor row above preserves that figure where it belongs: as the worst case
for a long-labelled screen.)*

### 2.5 The consequence: `Email` on D-05

Thirty-two characters at the mandated constant. `shima@example.com` is 17;
most real addresses fit. **The capacity argument v1 built here does not hold and
is withdrawn** — but the recommendation survives on grounds that never depended
on it:

| Option | Cost |
| --- | --- |
| (a) **`Email` on D-05 is a readout, not a field.** D-05's only editable row is `Name`; the account email is an **authentication identity** — it re-keys the magic-link login (ADR-0003) — so changing it is an auth operation on D-06, not a profile edit. D-06 already owns provider identity, and D-06 already renders the email row as a value (`shima@…`) | Requires saying so; D-05 and D-06 both currently list `Email`, which is a corpus overlap this file did not create |
| (b) Label above, field at the container's full content width | **The reference never stacks a label above a settings row.** [INVENTED] — a second field variant with no measured precedent |
| (c) The row pushes to its own full-screen surface (`←`) | Uses only measured navigation vocabulary and invents nothing, but contradicts D-05's own word, *"in place"*, and adds one screen per field |

**Recommendation: (a).** It is the only option that neither invents a variant
nor adds a screen, and it is the right *model* answer regardless of geometry.

**A second-order finding falls out, and it does still bind.** `User.name` has
**no length bound** in domain-model — amendment 7 bounds `Station.name`,
`nameShort`, `Owner.shortName` and `markerLabel`, and nothing else. So the one
field D-05 keeps is unbounded against a 32-character editing surface. Owed to
ticket 19: **`User.name` needs a bound.** [RAISE-F3]

**One structural payoff worth naming, because it is the only part of §2.6 the
measured palette answers by itself.** On a settings screen the value slot
([RAISE-D14]: unboxed, right-aligned, cap 27 Bold) and the field (boxed,
`color.surface`, left-aligned, cap 32 Regular) appear side by side. **The box is
the discriminator: a box means editable, no box means read-only.** That works on
D-05 (one boxed row among unboxed ones), D-06, D-07, D-10 and D-12. It does
**not** work where every row is editable (O5a) or where a field stands alone in
a card beside buttons of identical geometry (S-01, O1, O6, the admin) — which is
exactly the residue §2.6 raises.

### 2.6 An empty field and a button are the same box — raised, not designed around

Four decisions, each defensible alone, compose into a control with no
affordance. v1 made all four and then presented the collision as proof of
consistency (*"No contradiction"*). It is a contradiction:

| Section | Decision |
| --- | --- |
| §2.3 | *Border · shadow · blur* — **none**; fill `color.surface` `#393939` |
| §7.1 | **No placeholders, product-wide** |
| §7.4 | The caret is the focus indicator and nothing else — no ring, no border, no fill change |
| §2.2 / §5.1 | The field box and the CTA-geometry control are **the same box** |

**So an empty field is:** a `#393939` rounded rectangle at **1.62 : 1** against
`color.bg` [d, and the same ratio §7.3 derives for a different question], with
no border, no placeholder, nothing inside it, and geometry, fill, radius and
label size identical to the system's buttons. **The first signal that it is
typable arrives after the tap.** ADR-0009 §4 compounds it: dark-only, no light
theme, no contrast mode, read *standing at a charger in equatorial daylight*.

**How narrow the problem actually is.** Fields that open pre-filled are not
affected — D-05's `Name`, O5a's rates where a rate exists, and every admin edit
form render a value at rest. The genuinely empty fields are **S-01/O1's email
field, O6's invite field, and the admin's create forms (A3, A5)**. That is the
whole exposure.

**Options, with costs:**

| # | Option | Cost |
| --- | --- | --- |
| **(a)** | **Accept the mute empty field.** The persistent label carries identification — left of the row on a settings screen, above the block as a `type.heading` sub-head on S-01/O1/O6 and in the admin (the reference's own `Description` / `Basics and features` composition [m §5.2]). The affordance is learned on first tap | Invents nothing. **An empty field is a 1.62 : 1 box that looks like a button**, and in equatorial sun it may not be findable at all. A label above a block is not evidence of typability — the same composition sits above read-only body copy on `04` |
| (b) | **A `size.hairline` 2 px border.** [INVENTED] object; no new token | `color.surfaceRaised` `#3E3E3E` is **1.08 : 1** on the fill — useless. `color.text` `#FFFFFF` is 11.55 : 1 — legible, and would be the loudest object on the screen; **no white border exists anywhere** in the reference. `color.accent` collides with the category chip (a `#393939` near-pill with a 2.5 px lime rule) and spends a seventh accent meaning. 10-v2 §9: no product surface carries a border |
| (c) | Stream 1's focus treatment | **Does not answer the question.** Focus is post-tap; the defect is pre-tap. Named because the verdict offered it as an option and it is not one |
| (d) | A different height for fields | No second measured interactive height exists. `size.settingsRow` 176 px is a *row*, not a control, and borrowing it would not remove the fill/radius identity anyway |

**Recommendation: (a), and record it as an impossibility rather than a
preference.** ADR-0009 §4's own instruction applies verbatim — the daylight
problem *"is not solvable inside the measured palette"*, and the evidence path is
the **launch-week survey pass**, where studio staff use these surfaces at real
chargers in real sunlight. If an empty field cannot be found there, a mitigation
is a commissioned pass with its own premise, not a token swap.

**Founder call.** [RAISE-F18]

### 2.7 The multi-line variant, if ticket 19 ever accepts `Station.description`

Not designed (§1.5). One thing would have to be settled first, recorded so it is
not discovered late: **the corpus has one measured line height, 45 px = 15 pt,
and it was measured at cap 27–28 body copy** [m §4.3]. A cap-32 field value has
**no measured line height** [?], and file 10 §4.3 says in terms: *do not invent
them.* A multi-line field is therefore blocked on either a body-sized value
(cap 27–28, which contradicts §2.3's cap-32) or an invented line height.

---

## 3. Numeric input

### 3.1 The fields — and two the brief names that do not exist

| Field | Screen | Type | Bound |
| --- | --- | --- | --- |
| `ratePerKwhRwf` | O5a, O5c, A4 | integer | ≥ 0 |
| `sessionFeeRwf` | O5a, A4 | integer, optional | ≥ 0 |
| `powerKw` | A4 | **decimal** — 7.4 kW is a real rating | > 0 |
| `voltage` | A4 | integer | > 0 |
| ~~bay count~~ | — | **does not exist** — bays are rows in A4; `3 bays · 5 plugs` is derived | — |
| ~~`capturedAt`~~ | — | **prohibited** — file 12 §8 rule 4 | — |

### 3.2 RWF has no minor unit

Every amount in the reference and in the corpus is an integer:
`135 000 RWF/day`, `600 RWF/kWh`, `400 RWF/kWh` [m].

| Rule | Provenance |
| --- | --- |
| **Money fields accept integers only.** No decimal separator, no minor unit, no rounding | RWF has no circulating subdivision; [m] every amount in the corpus |
| **Group separator is a space**, not a comma or a point | [m] — the reference's own `135 000` |
| **Grouping is applied on display, never while editing** | [d] — a field that reformats mid-entry moves the caret. Cost: the displayed and the editing string differ by one character class, and their widths differ |
| Keyboard | `number-pad` for money, `decimal-pad` for `powerKw` | build note, not a design value |
| **`powerKw`'s decimal separator** | **[?]** — the reference contains no decimal anywhere. Locale, not design; route to localisation (SPEC §12) |

### 3.3 Old-style figures against a right-aligned numeric field — re-measured

ADR-0010 makes old-style figures **non-negotiable**. Two consequences that a
right-aligned numeric field and a column of amounts both hit. v1 read a table of
digit *heights* as digit *widths* and under-stated the first by 3.5×; this
section is re-derived from the pixels.

**(a) The figures are proportional, not tabular — measured here, because the
corpus does not measure it anywhere.**

`10-design-system-v2.md` **§3.2** — not §4.1 row 7, which contains no digit
figure — reports `1` 29 · `0` 31 in a column headed `Digits`, beside
`Baseline · Cap · x-height · Descending`, under the prose *"Digits sit at
x-height + ~2 px (the round-figure overshoot)"*. **Those are ink heights above
the baseline**, confirmed [m·19] #2: at cap 36 the `1` runs y2417→2446 (29 px)
and the `0` y2416→2447 (30 above, 1 below, against an x-height of 27). The
companion row proves it independently — at cap 27 the same column reads `2` 22 ·
`0` 23 against an x-height of 20.

The **advances** measure [m·19] #1, at cap 36 on `04.png`:

| Digit | Advance | How |
| --- | --- | --- |
| `0` | **32 px** | **exact** — two same-glyph pitches, ink starts x187 → x219 → x251. Identical glyphs, so sidebearings cancel |
| `1` | **≈25 px** | start-to-start against the following `3` (x92 → x117). Carries the two glyphs' sidebearing difference; a proxy, not an exact advance |
| `3` | **≈29 px** | start-to-start against `5` (x117 → x146), same caveat |

A **tabular** set has one advance for every digit. This one measures 32 for `0`
against ≈25 for `1` at the same cap: **spread ≈ 7 px = 2.3 pt per digit at cap
36**, and the whole `135 000` run measures ~10 px narrower than a tabular set
would predict. The set is **proportional**. So:

- A right-aligned amount **shifts as its digits change**, even at constant
  length. `600` vs `111`, right-aligned, differ at their left edge by
  **≈21 px = 7.0 pt at cap 36** and **≈19 px = 6.2 pt at the field's cap 32**
  [d, assuming adv(`6`) ≈ adv(`0`) — both round-bodied; adv(`6`) is not
  measured]. **Not the ≈6 px = 2 pt v1 asserted.**
- A **column** of right-aligned rates does not form a place-value column. Old-style
  figures were designed to sit in running prose, and a numeric column is the one
  place they do not work.

**(b) The digits descend.** `3` and `5` descend 7–8 px at cap 36; `4` descends
5 px at cap 27; `5` descends 9 px at cap 47 [m §3.2, re-confirmed [m·19] #2].
Any box sized to the cap height alone **clips** — and `345 RWF/kWh` is the
string that demonstrates it. §2.3's box does not clip (53 px of clearance
against ≤10.6 px of descender), but a value slot sized tightly would.

**The collision, re-decided at the correct magnitude.** ADR-0010's acceptance
band has no row for a tabular set, and `onum` + `tnum` together are rare. **The
trap v1 wrote into its own recommendation:** on most faces `tnum` *selects the
lining tabular set*, so "enable `tnum` in the numeric field" **is** substituting
lining figures locally — which the same paragraph forbids and which ADR-0010
makes non-negotiable.

**Recommendation, in three parts:**

1. **The band row, correctly worded.** *If a candidate carries an **old-style
   tabular** set — `onum` and `tnum` together — it is enabled in the numeric
   field and its value column and nowhere else. A **lining** `tnum` set is not a
   substitute and must not be enabled.* Expect most candidates to fail this row;
   it is a **tie-breaker between otherwise-equal faces**, not a requirement, and
   ADR-0010's free-first order is unchanged.
2. **Native (`packages/ui`): accept the jitter**, at the stated cost of **≈19 px
   = 6.2 pt** of left-edge and place-value drift at cap 32. Three things make it
   survivable and they should be checked rather than assumed: §3.4's pinned
   suffix fixes the *right* edge and the suffix column, so the ragged edge is
   the value's left; O5a's normal case is **one rate across every plug** (file 12
   §3/O5), i.e. identical strings that align exactly; and the columns are 1–5
   rows, read individually, never summed.
3. **The admin.** A lining `tnum` in the admin's numeric tables is *available* —
   1:1 does not govern the dashboard (file 12 §7) — on exactly the same terms as
   [RAISE-OA-13]'s muted tier: it ships **two figure sets in one product** and
   breaks token kinship with `packages/ui`. **Founder call, decided beside
   OA-13. Recommendation: no.**

**Do not** substitute lining figures locally in the native apps under any
reading. [RAISE-F5]

### 3.4 The unit suffix

`RWF/kWh`, `kW`, `V` must be visible and must not be editable — a unit inside
the editable string is a unit the user deletes. **That sentence is the
requirement, and v1's own spec deleted the only signal that satisfies it.**

**The reference's price composition, measured [m·19] #3 and #4:**

| Part | Measured | Consequence for the field |
| --- | --- | --- |
| The amount `135 000 RWF` | cap 36, stem **6.92 px** (`F`), 0.192 stem/cap → **Bold** | the **value** is cap 32 **Bold** |
| The unit `/day` | cap 36, **4.42 px per stem** (`d`), 0.123 → **Regular** | the **suffix** is cap 32 **Regular** |
| The gap between them | **3 px** — `F` ink ends x407, `/` ink starts x411 | **there is none.** The reference sets amount and unit **solid, as one run**. No layout gap exists to inherit and none is invented |
| Colour | `#FFFFFF` both | `color.text` is the only text colour; **weight is the only channel available** |

**The specification:**

| Property | Value | Provenance |
| --- | --- | --- |
| Suffix type | cap 32 **Regular** `#FFFFFF` | [m] §4.1 row 12's weight at the field's cap; [m·19] #3 for the composition |
| Value type | cap 32 **Bold** `#FFFFFF` | [m] §4.1 rows 7/15; [m·19] #3 |
| Suffix position | **right edge at the field's 30 px trailing inset**, pinned — it never moves as the value changes | [d] |
| Value position | **right-aligned to the suffix's left edge, set solid** — no layout gap, per [m·19] #4 | [d] |
| Editability | the suffix is **not** in the editable string; the caret can never enter it | [d] |
| Caret at rest in an empty numeric field | immediately left of the suffix, not at the left inset | [d] — the conventional position for a right-aligned numeric |

`RWF/kWh` at cap 32 Regular is **163.5 px** at k = 0.73 [d]. **It cannot live
"inside the field's 30 px trailing inset"** — v1's phrase, which is unbuildable
as written; the inset is where its right *edge* sits. And a value with something
to its right is not right-aligned to the field, which is why §2.3's alignment row
now reads *right-aligned to the unit suffix*.

**Two costs, stated:**

1. **The numeric field's value weight differs from the text field's** — Bold
   against Regular. That is deliberate and it is the reference's own split
   (prices are Bold everywhere; settings labels are Regular everywhere), but it
   means `packages/ui` ships one field box with two value treatments.
2. **Weight is a weaker ownership signal than colour**, and the palette has no
   second text colour to spend (§7.1). Under ADR-0009 §4's daylight it may not
   read at all. The alternative — putting the suffix **outside** the box on
   `color.bg`, where "inside the box is yours" is unambiguous — breaks the
   amount/unit lockup the reference ships across a box edge and has no
   precedent of its own. **Recommendation: the reference composition; the
   outside-the-box variant is named, not chosen.**

**Marked [INVENTED] as an object**: the reference composes an amount and a unit
in a *read* slot, never inside a control. Every value is a token; the placement
is new. [RAISE-F6]

---

## 4. The trailing check

### 4.1 The component, specified once

Ruled by [RAISE-D17] and adopted here without re-argument. It is the
**best-founded control in this pass** — every property is a measured token, and
its drawing is bespoke in exactly the way §8.4 says every icon in the system
already is (*"Feather/Lucide-compatible metrics, bespoke drawings"*).

| Property | Value | Provenance |
| --- | --- | --- |
| Colour | `color.accent` `#C7FC2F` — 15.52 : 1 on `color.bg` | [m] |
| Ink box | `size.iconGrid` **72 px = 24.0 pt** | [m] |
| Stroke | `size.iconStroke` **6 px = 2.0 pt** | [m] — the mode of the measured set, and the settings-row family's own band (6.2–7.0 px) |
| Caps / joins | rounded, no mitres | [m, visual] §8.4 |
| Horizontal position | right edge of the ink at the **container content box's right edge** | [d], per [RAISE-D29]'s container-relative rule |
| Vertical position | centred on the row — the reference's own icons centre within **0.5 px** of the row centre | **[m·15 #5]** |
| On | present | additive-mark rule |
| Off | **absent** | additive-mark rule — file 11 §9.4 |
| Tap target | the whole row, `size.settingsRow` **176 px = 58.7 pt** | [m] |

*(One supporting measurement lands here: the settings icon's ink is **71–72 px
tall** [m·19] #5 — exactly `size.iconGrid` 72 px. The check's 72 px ink box is
therefore the row family's own vertical ink extent, not a borrowed number.
10-v2 §7.6's "62–68 px" describes the horizontal extent only; owed back, §0.3.)*

### 4.2 Multi-select — D-09, O5c

D-09 renders five rows (the closed type-word projection,
`docs/availability-display.md` §2.4) and marks each selection. This is the
check's native semantic: an independent per-row flag. **Honest.**

**O5a collides, and the corpus does not notice.** File 12 §10.1 gives O5a
*"`§5.6` rows, value right-aligned `type.label` Bold"* **and** *"plug
multi-select"*. Both claim the row's trailing region [m·15 #6], and once the
value becomes an editable field there is no measured gap for a check and a
field to share it. Two readings:

| Reading | Cost |
| --- | --- |
| (a) The multi-select is a **separate surface**: a `Bulk apply` CTA on O5a **pushes a full-screen surface** (`←`) carrying the plug rows with the trailing check and one numeric field | **One extra screen (O5c).** Uses only the fixed navigation vocabulary the ticket permits — a push. Invents no container |
| (b) Check and value coexist in one row, check outboard of the value | **[INVENTED]** — the gap between them has no measured source, and the row would then carry a label, a value, a check and an editable field: four trailing behaviours |
| ~~(c) A platform action sheet~~ | **Withdrawn.** The mechanism adopted by file 11 S-03 and [RAISE-OA-15] is *the platform's own action sheet* — **a list of actions**. It cannot host a multi-select with trailing checks plus a numeric field, and specifying it as if it could invents a modal form surface. Ticket 31: *"Navigation vocabulary is fixed and this pass may not extend it."* |

**Recommendation: (a).** Cost: one extra screen. It **no longer depends on
[RAISE-OA-15]** — a push is measured vocabulary and the action sheet is not
involved. [RAISE-F7]

*(The distinction that separates this from §6.3, stated once so it is not
re-litigated: an action sheet can host a **single-select over a handful of
labelled rows**, which is its native semantic; it cannot host **checks plus a
field**. That is why the connector picker may use one and `Bulk apply` may not.)*

### 4.3 Boolean — D-08

One row, `Bay alerts`. A check that appears and disappears on tap **is a
checkbox**, which is a legitimate boolean control, and the reference has no
switch to be a foreign object beside. **Honest.**

What is lost, stated: a switch shows both states simultaneously (the track is
visible when off); an additive check shows only the on state. §4.5 is where that
bites.

### 4.4 Single-select — the honest answer is that it does not occur

The brief names D-09 as the single-select case. **That is a mis-reading of the
corpus and the correction matters:** file 11 D-09 says *"Multi-select; the
trailing lime check marks each selection."* A driver may take several plugs;
`vehicleConnectorTypes[]` is an array in domain-model amendment 4.

So: **where is a genuine radio required?**

| Candidate | Verdict |
| --- | --- |
| A3 `owner_id`, A4 `type`, A6 role, A2 and A9 filters | single-select, but **admin-native web** — a `<select>` has the semantic built in and draws no check (§10) |
| O5c plug multi-select, D-09 | multi |
| D-08 | boolean |
| **S-03 / §12.1's connector picker** | **the only single-select in `packages/ui`** — and it is unspecified (§6.3) |

**So one glyph does not have to carry three semantics, because the third does
not arise.** That is the strongest available answer and it is better than making
the glyph work harder.

**And it must not be made to.** A check cannot honestly serve a radio group: a
mark that may be on for several rows tells the user nothing about mutual
exclusion, and the user cannot distinguish a radio from a checkbox until they
tap a second row and watch the first clear. That is a real defect, and the
correct response is to refuse rather than to draw a second glyph state.

**Recommendation for the connector picker: the platform's own action sheet** —
the mechanism the product already adopted for S-03 and O3's `⋯`
([RAISE-D13] / [RAISE-OA-15]). Single-selection is the platform's semantic
there, and no check is drawn. **Cost:** it inherits [RAISE-OA-15]'s open branch
— *"if the answer is 'no platform sheet', the three screens need a different
home"* — and the connector picker becomes a fourth dependent. [RAISE-F8]

### 4.5 Two states that render identically — a defect, raised

Because *off* is **absent**, an off row and a **non-interactive** row are
pixel-identical: both are a bare settings row, and the reference's settings rows
carry **no trailing affordance at all** [m §7.6]. So on D-08 a permission-denied
row and a permission-granted-but-off row look the same, and on D-09 an
unselected option looks like a navigation row.

**The corpus already answers this, consistently, and it is worth naming as a
pattern rather than a patch:** file 11 §12.2, executing ticket 30's amendment —
*"a refusal with a reason in the row's text, never a disappearing control."*
D-08 already carries `Turn on notifications for EV Guide in system settings to
use bay alerts.` and D-09 already carries `Pick the plugs your car takes…`.

**Recommendation: accept, and make the copy load-bearing rather than
explanatory.** **Cost:** the disambiguation depends on the user reading one
line, and a body line at `type.body` ExtraLight is [RAISE-2]'s weakest surface.
The alternative — an outline check for *off* — is a second glyph state with no
measured source and breaks the additive-mark rule the whole system runs on.
[RAISE-F9]

---

## 5. O4's control row — checked against the vocabulary, not redesigned

File 12 §4.3 specifies it and this file does not touch it. What follows is the
check the ticket asked for.

### 5.1 Restated against the token authority

| Property | File 12 §4.3 | This file |
| --- | --- | --- |
| Height | `size.ctaHeight` 46 pt | ✓ same |
| Radius | `radius.button` **4.5 pt** | **4.3 pt** — 10-v2 §10.4 is the token authority (13-v2 MAJOR-4). A restatement, not a change |
| Fill, unselected | `color.surface` + `color.text` | ✓ — **and identical to §2.3's field box** |
| Fill, selected | `color.accent` + `color.onAccent`, Medium | ✓ |
| Gap | `space.chipGap` 9 pt = 27 px | ✓ |
| Width, three-up | (1078 − 54) / 3 = **341.3 px** | ✓ |
| Label | cap 32 Medium | ✓ — see [C1] |

**O4's unselected control and §2.3's field box are one `#393939` interactive
object at 46 pt, used for both.** That is not a consistency result; it is the
collision §2.6 raises. A screen that carries both — the admin's forms, and
S-01/O1 where a field sits in a stack of buttons — offers the user no way to
tell them apart before tapping. Named here rather than presented as proof that
nothing is wrong.

### 5.2 Four contradictions found

**[C1] The arithmetic that forces the label size does not reproduce.** File 12
§4.3 rejects the primary CTA's own label size with:

> *At the primary CTA's own cap-37 Medium (≈28 px/char), `Out of service` is
> 392 px and does not fit.*

**28.8 px/char is file 12 §0.2 row 1** — the measured advance of `135 000
RWF/day`, a **cap-36 Bold digit-heavy price**. The primary CTA's own **Medium**
label measures **21.25 px/char** (`Let's find a car`, 16 chars, 340 px ink, file
11 §0.3 row 6). **Every row below is computed at cap 36**, the authorised CTA
label cap (§0.3 row 3); v1 computed three of four at cap 37, a value its own
authority table declares void.

| Constant | `Out of service`, 14 chars | In 341.3 px | Verdict |
| --- | --- | --- | --- |
| **≈28 px/char** — §0.2 row 1's cap-36 **Bold price** advance (28.8), rounded (what §4.3 used) | 392 px | overflows by 51 px | rejects |
| **21.25 px/char — the primary CTA's own measured Medium ink** (340 px ÷ 16 ch; **cap-independent as an absolute advance**, so unaffected by the 36/37 question) | **297.5 px** | 21.9 px each side | **fits** |
| **k = 0.65 at cap 36** — §0.4's pessimistic Medium at the authorised cap | **327.6 px** | **6.85 px each side** | rejects, by **13.7 px total** |
| k = 0.65 at cap 32 — what shipped | 291.2 px | 25.05 px each side | fits ✓ |

The **conclusion survives** under §0.4's mandated pessimistic constant, which is
the policy. The **stated reason does not**: it applies a Bold price advance to a
Medium letter-only label and overstates the width by 32 %. §0.2 promises
*"arithmetic over a measured advance, never an eyeball"* and its own caveat
warns that digit-heavy and letter-heavy strings of equal length do not measure
equal — which is precisely the substitution made.

This is the corpus's most-cited piece of control arithmetic and every other
control leans on it. **Recommendation: restate §4.3 at the Medium constant and
re-declare the composition as a choice** (a 46 pt control with a cap-32 label
has real optical breathing room) **rather than an arithmetic necessity** — and
record that the margin at the authorised cap is **13.7 px, not 51 px and not
4.6 px**, for whoever revisits it. Carried as **[RAISE-F17]**.

**[C2] "Accent means selected" is presented as measured and is not.** §4.3:
*"the accent-as-selection reading is the reference's own: the 03 category chip
marks an active attribute in accent, the 04 feature chips do not."*

There is **exactly one category chip in four screens** and nothing in an
unselected state to contrast it with. `Hybride` is a category tag — the same
word the `04` hero badge carries — not a selection. The **fills** are measured;
the **semantic** is an interpretation of a single instance, and file 11
[RAISE-D22] says as much for the driver's sheet: *"The reference contains **no
selected/unselected control pair**."*

So the same missing state is **raised on one surface and consumed silently on
the other**. **Recommendation:** mark accent-as-selected [INVENTED] in file 12
§4.3 and let it inherit [RAISE-D22] rather than claiming its own precedent. The
design is right; the provenance claim is not. [RAISE-F10]

**[C3] The accent carries two meanings on O4 simultaneously.** With three
connectors touched, the operator sees N accent controls meaning *selected* and
one accent Save CTA meaning *tap me* — on one screen, at one time. Elsewhere the
accent also means *yours* (saved heart, avatar ring), *presence* (the free-bay
dot) and *link*.

**Recommendation: accept.** It is disambiguated by position (a sticky bar) and
by grammar (a verb against a state word), and the only alternative is a second
accent value, which §10.1 forbids in terms. **But name it**, because §7.3 is
about to ask the accent to carry a sixth meaning **and a tint** (F19), and the
budget should be spent knowingly.

**[C4] The Save CTA's zero-touch state is a disabled state by another name.**
§4.4 rule 4: *"At zero touches the CTA renders in `color.surface` and does
nothing"*, justified as *"built from two measured fills rather than an invented
one."* The fills are measured; **a control that renders as a control and does
nothing is a disabled control**, and file 11 §12.2 rules against exactly that
shape — *"A control that is permanently untappable is a lie about a tap target;
a sentence is not."* The two rulings point in opposite directions on the same
question.

**Recommendation: route to stream 1**, which owns the disabled treatment.
Cheapest resolution consistent with both: at zero touches the sticky bar carries
a `type.body` refusal line in place of the dead button, and the CTA appears at
the first touch. Additive, and it is the rule the driver app already follows.
*(The line's wording belongs with the rest of O4's copy, not in this file.)*
[RAISE-F11]

---

## 6. Select, picker, and the OCPI enum

### 6.1 Two different sets, and conflating them would be a defect

| Set | Members | Where |
| --- | --- | --- |
| **The open OCPI 2.3.0 enum** | the four tier-1 spellings, every other RURA Art. 3(c) family, plus `OTHER` and `UNKNOWN` | **A4's select writes this** |
| **The closed display projection** | the **five type-words** owned by `docs/availability-display.md` **§2.4** — cited, not restated | D-09's rows, chips, O4's labels |

**The admin's select must be over the enum, not the projection.** Its option
labels are therefore **not** the closed vocabulary. A select offering the five
projection words would collapse every non-tier-1 family into one bucket and make
them **unauthorable** — the admin could never record what is actually installed.
Worth a test: the projection is a read-side function and must not appear as an
option list.

### 6.2 `OTHER` / `UNKNOWN`

Both persist as enum members and both project to the same bucket word
(availability-display §2.4). O4 states it already: a connector of that type is
**still writable** (file 12 §4.5). Nothing special is needed on any control.

**One consequence, routed not settled:** a driver whose car takes a family that
projects to the bucket selects a **bucket** on D-09, and the lens then treats
their plug as interchangeable with every other unmapped family. That is a
modelling consequence of the projection, not a control decision — routed to
ticket 18 alongside [RAISE-D32]'s bare `GB/T`.

### 6.3 The connector picker — named twice, specified nowhere

13-v2 MINOR-5, restated because it is a control and therefore mine: file 11
§8.0 and §12.1 both send `Report availability` through *"a connector picker
first when the station carries more than one type"*, and the picker has **no row
in the entry-point table, no component and no raise.** It is the one dead end in
an otherwise exhaustive navigation map, and it is the only single-select in the
native apps (§4.4).

**A second defect inside the same sentence, found here.** S-02 files a report
about **one Connector** (file 12 §4.1: writes are per-Connector). A picker over
*types* cannot name a Connector: a station with two `GB/T DC` guns has one type
and two targets, and the report would have no subject. **The picker must be over
Connectors, not type-words**, and its row count is then the station's connector
count — 4 on the worked fixture S1, which an action sheet holds comfortably.

**Recommendation: the platform action sheet, over Connectors.** **Cost:** a
fourth screen depends on [RAISE-OA-15]; and file 11 §8.0/§12.1's wording needs
correcting from *type* to *Connector*. [RAISE-F8]

---

## 7. Label, placeholder, caret, selection, focus

### 7.1 The placeholder is not a preference — it is unimplementable

*(Carried verbatim from v1. The verdict records it as the file's strongest
passage and it survives unchanged.)*

The reference's settings rows carry **a label and nothing else** [m §7.6]; the
value slot is itself a proposal ([RAISE-D14]). There is no placeholder anywhere.

The finding is stronger than "prefer labels":

> **A placeholder requires a dimmed text tier, and §10.1 deliberately has
> none.** `color.text` `#FFFFFF` is *"the only text colour"*; there is no
> `text.secondary`, no `text.muted` and no opacity ramp, and §1.3 says adding
> one *"would be a deviation."* `color.iconMuted` `#717171` is barred from text
> use by name. So a placeholder can only render in `#FFFFFF` — **identical to a
> real value** — which is not a weak placeholder, it is a defect: the user
> cannot tell an empty field from a filled one.

**Recommendation: no placeholders, product-wide.** The label is persistent,
outside the field, and carries the whole job. **Cost: none.** This is the one
question in this pass that the measured palette answers by itself.

*(One consequence v1 did not draw: with no placeholder, an empty field contains
nothing at all. That is §2.6's raise, and it is a cost of the composition, not
of this refusal — a `#FFFFFF` placeholder would be strictly worse.)*

### 7.2 Label

Composed with [RAISE-D14]'s value slot, which this file **consumes** rather than
re-decides: label left at cap 32 Regular `#FFFFFF` (§4.1 row 12), the field
occupying the trailing region [m·15 #6] at the per-screen column of §2.4. On
S-01 / O1 / O6 and in the admin the label sits above its own block as a
`type.heading` sub-head — the reference's own `Description` / `Basics and
features` composition [m §5.2].

**Dependency named:** if [RAISE-D14] is refused, D-05, D-06, D-07, D-10, D-12,
O5a, O7 and O8 all lose their value slot and this file's in-row field placement
goes with it. §2.5 option (c) is then the fallback.

### 7.3 Caret and selection are one value on iOS — this decides it

The platform constraint comes first because it removes the choice:

> React Native's `TextInput` exposes **`selectionColor`** on both platforms; on
> iOS it maps to `tintColor`, which drives the **caret, the selection highlight
> and the selection handles together**. Android can separate `cursorColor` from
> `selectionColor` (API 29+). Designing two colours ships two different
> appearances across two platforms.

So: **one value**, and it must work as a caret *and* as a fill behind text.

| Candidate | As a caret | As a selection fill | Verdict |
| --- | --- | --- | --- |
| `color.text` `#FFFFFF` | 11.55 : 1 on the field [m] ✓ | **white behind `#FFFFFF` text** — unreadable | **disqualified by the platform constraint** |
| `color.surfaceRaised` `#3E3E3E` | 1.08 : 1 on the field [d] | 1.08 : 1 — invisible | disqualified |
| `color.bg` `#121212` | 1.62 : 1 [d] — visible but weak | white on `#121212` = **18.73 : 1** [m] — the most readable selected text available | **the only candidate that invents nothing** |
| `color.accent` `#C7FC2F` | **9.57 : 1** on the field [m] ✓ | see below — **and it is a tint** | **needs a founder call** |

**The accent as a selection fill, honestly.** Drawn opaque with `#FFFFFF` text
it is **1.21 : 1** — the hero-badge failure, in a field where the user is
proof-reading what they typed, and there is **no API to restyle selected-text
colour** in a `TextInput`. What makes it usable is that the platform draws the
highlight **translucent**: at 20–30 % over `#393939` the white text holds
**6.74 : 1 to 5.17 : 1** [d].

**And that is a tint, which the palette does not have.** `10-design-system-v2.md`
§10.1: *"`color.accent` … **exactly one value, no tints, no gradients**"*, and
*"Deliberately absent: any `text.secondary`, `text.muted`, **opacity ramp**,
elevation colour, or **accent tint**."* Choosing `selectionColor = color.accent`
is choosing to put a 20–30 % accent composite on screen; **that the OS mixes it
does not make it not a tint**, and booking the cost to the platform is exactly
the silent palette growth ticket 31 exists to prevent — *"A state that needs a
new token is a founder call, not a design decision."*

**Founder call, with both options costed:**

| Option | Cost |
| --- | --- |
| **(a) `selectionColor = color.accent`** | The product's **first tinted accent**. §10.1's *"no tints"* becomes false and must be amended in the same breath. Selected-text contrast is the platform's alpha, 6.74 : 1 to 5.17 : 1 [d] and **[?] until measured on device**. The accent takes a **sixth meaning** — see [C3] |
| **(b) `selectionColor = color.bg` `#121212`** | Invents nothing; **no tint, no new token**. Selected text reads at 18.73 : 1, the best available. But the highlight itself is 1.62 : 1 against the field — a dark block where every convention says a bright one — and under ADR-0009 §4's daylight the selection may be invisible even where the text is not |

**Recommendation: (a), and raise it.** The selection is transient and modal, no
accent-as-selected control is on screen inside a field, and a highlight nobody
can see is a worse control than a tint nobody has authorised. But it is the
founder's to authorise. [RAISE-F19]

**The caret's width is the platform's, not ours. [?]** `size.hairline` 2 px =
0.67 pt is the value the product would use, and **React Native exposes no caret
width on either platform** — the API just cited gives `selectionColor` and
Android's `cursorColor`, and nothing else. iOS fixes the caret in UIKit; Android
needs a native cursor drawable. Recorded as the intent; the rendered width is
the OS's. *(v1 specified 2 px against an API it had itself described.)*

**The caret blinks, and the reference contains no motion anywhere** [m §9, file
11 §9.4 *"Motion: none, anywhere"*]. That is §7.5's subject.

### 7.4 Focus

**Recommendation: the caret is the focus indicator, and nothing else.** No ring,
no border, no fill change.

**Grounds, restated correctly.** The system has **four** measured accent rings
and borders, not two: the category chip's 2.5 px rule [m §7.5], the pin's 2 px
outline [m §7.3], the profile avatar's `size.accentRing` 3 px [m §7.9] and the
locate button's 4 px ring [m §7.2] — the last of which **is on an interactive
object**, which v1's version of this argument missed. What none of them is, is a
**state**: all four are permanent component properties. A 2 px accent ring on a
focused field would therefore reuse a measured value for an invented role, give
the accent a seventh meaning, and render a field indistinguishable from a
category chip. The keyboard's own appearance is itself a strong focus signal on
a phone.

**Cost:** on a screen with two fields (O5a: rate and session fee) the only focus
indicator is a blinking bar of platform-determined width — thin, and under
[RAISE-OA-1]'s equatorial sunlight possibly invisible. **Whether a focus ring
exists product-wide is stream 1's**; this file states what it recommends and
what it costs. And focus does **not** answer §2.6: a focus treatment cannot
identify a field the user has not yet tapped.

### 7.5 Motion — a product-wide rule, raised rather than adopted

Two objects in this file move: **the caret**, because the OS blinks it (§7.3),
and **the card under a keyboard** (§8). Neither is authored by the product. The
rule that licenses them is:

> **The product authors no motion; it may follow motion the platform authors.**

**That rule governs every surface in both apps, and this is a form-controls
pass.** It amends file 11 §9.4 (*"Motion: **none, anywhere**"*) and closes a
line 10-v2 §12 lists among what could not be measured. It is not a small
amendment: it also retroactively licenses the push and present transitions that
files 11 §8.0 and 12 §3.0 already spend as their entire navigation vocabulary,
and the platform action sheet's own presentation (S-03, [RAISE-OA-15]) — **all
of which animate today, which means file 11 §9.4's sentence is already false as
the corpus is written.** The rule does not add behaviour; it makes existing
behaviour honest.

**Recommendation: adopt it, once, as a founder call**, with the caret and the
keyboard translation as its two named instances and file 11 §9.4 as the sentence
it amends. **Refused under any reading:** authored transitions, shimmer,
skeletons, spinners ([RAISE-D16]), and any easing curve the product chooses for
itself. [RAISE-F20]

---

## 8. Keyboard avoidance for the floating card

**First, a correction to the framing.** The 64 px figure is
`space.floatingCardBottomGap` — the gap between the `03` card's bottom and the
CTA's top [m §7.4]. For S-01 / S-02, with nothing below them, [RAISE-D34] rules
**103 px = 34.3 pt** above the screen bottom. That is the number keyboard
avoidance works against.

**Where it bites:** S-01 and O1's email path, and nowhere else. **O4 — the
product's most state-heavy screen — has no field at all**, so the operator app's
core task never meets a keyboard.

**The geometry.** To preserve the card's measured resting gap above whatever is
beneath it, the card's bottom must sit `keyboardHeight + 34.3 pt` above the
screen bottom, i.e. **translate up by exactly the keyboard's height** [d]. The
34.3 pt is measured and merely applied to a new edge; the *translation* is
[INVENTED].

**Does it fit?** Two of the three terms are the OS's and both are **[?]**: the
safe-area top (≈59 pt on iPhone 16 Pro) and the keyboard height (≈336 pt, iOS
portrait English with the predictive bar — **it varies by locale and by bar, and
no layout may hold it as a constant**). Against the measured 874 pt screen
[m §0.1], the card's height must satisfy `h + 336 + 34.3 ≤ 874 − 59`, i.e.
**h ≤ 444.7 pt** [d].

**S-01's card height, composed [d].** Every term is cited; the composition is
not measured, because **the reference has no stacked-button card** [?]:

| Term | pt | Source |
| --- | --- | --- |
| card top → handle top | 8.3 | [m] §5.2 (`03`, 25 px) |
| handle | 4.3 | [m] `size.handle` 180 × 13 |
| handle bottom → first content | 13.0 | [m] §5.2 (`03`, 39 px) |
| title line | 17.0 | `type.heading` font size — **its line height is [?]**, so the font size is used as a conservative floor |
| title → subtitle | 6.7 | [m] `space.titleToSubtitle` 20 px |
| one body line | 15.0 | [m] §4.3 line pitch 45 px |
| body → button block | 13.0 | [m] `space.blockGap` 39 px |
| 3 × `size.ctaHeight` | 138.0 | [m] |
| 2 × `space.chipGap` | 18.0 | [m] |
| bottom padding | 21.3 | [m] `space.floatingCardPadding` 64 px |
| **Total, idle** | **254.6** | [d] |

**Fits, with 190 pt of headroom.** *(v1 summed 341.9 pt against a list that adds
to 341.6, used §5.2's card-top→handle-top gap as the handle→content gap, and
applied a 64 pt top padding the card does not have — 10-v2 §7.4 gives internal
padding *"on left, right and bottom"*, and the top measures 25 px to the handle.
Three errors; the conclusion survived all three, which is why they were not
found.)*

**The email variant, both readings, because file 11 leaves it ambiguous.** S-01's
states table says *"the body becomes an email field + `Send me a link`"* without
saying whether the three provider buttons remain. Worst case — they do, giving
five stacked 46 pt elements and four gaps: 254.6 − 138 − 18 + 230 + 36 =
**364.6 pt**. Still ≤ 444.7 pt, **80 pt of headroom** [d]. The ambiguity is
file 11's to close; **the fit conclusion holds either way**, which is why it is
named here rather than designed.

**Three options, with costs:**

| Option | Cost |
| --- | --- |
| **(a) Translate the card up by the keyboard's height, preserving 34.3 pt** | Introduces the product's **first layout motion**. Licensed only by §7.5's rule, which is itself raised |
| (b) Resize the card | Rejected — the height is content-derived; shrinking clips the buttons |
| (c) Push the email path to its own full-screen surface | Invents nothing and uses measured navigation vocabulary, but **breaks S-01's contract**: it *"overlays the screen the driver is on and never navigates"* (file 11 §10), and the driver would lose their station — the exact failure S-01 exists to prevent |

**Recommendation: (a), following the keyboard's own curve and duration**, which
both platforms publish with the frame change. Under §7.5's rule the translation
is the keyboard's motion, not an authored animation. Jumping instantly is the
alternative and reads as a glitch. [RAISE-F13]

**A second consequence, and it is a real ambiguity.** With the keyboard up,
S-01's *"tap outside the card → dismiss"* (file 11 S-01) collides with the
universal gesture for dismissing a keyboard: **one gesture, two dismissals.**
13-v2 MAJOR-7 already raised that the modal-card-with-no-scrim archetype is
unspecified; this is its second consequence.

**Recommendation: the first tap outside dismisses the keyboard; the second
dismisses the card.** **Cost:** a driver who wants out taps twice. The
alternative — dismissing both at once — silently drops the pending action, which
S-01's contract says happens on dismissal. [RAISE-F14]

---

## 9. Validation messaging

**The corpus's rule** (file 11 §9.4, D-05, S-01): *"Any error → body copy
replaced in place, `#FFFFFF`. There is no error colour in the token set and
adding one would be a deviation."*

**The gap:** a settings row is a label and a value. It **has no body copy to
replace**. So "in place" has no referent for D-05's rows, O5a's rate rows or
A3's fields — the corpus's rule does not reach field-level validation.

### 9.1 Prefer prevention; then validation has almost nothing to do

Every authored bound in the model is a length or type bound: `name ≤ 28`,
`nameShort ≤ 18`, `shortName ≤ 17`, `markerLabel` 1–3 with a `CHECK`, numerics
≥ 0. File 12 A3 already rules **"counter, hard stop"**.

> **A hard stop makes the invalid state unreachable**, and an unreachable state
> needs no message, no colour and no position.

What survives as genuinely unpreventable is **submit-time**, not keystroke-time:
`geo` unset, `markerLabel` empty, a non-vector icon, a duplicate invite, a
server rejection, a membership revoked mid-session (file 12 §5.2).

### 9.2 Position

| Kind | Position | Provenance |
| --- | --- | --- |
| **Surface-level refusal** | one `type.body` `#FFFFFF` line in the block that owns the action | **[m]-founded pattern** — D-08's permission line, D-09's paragraph, D-12's ceiling line, S-02's `Report status when you're at the station`, §12.2's refusal rule |
| **Which field caused it** | **name the field in the message** — `Marker label is required` | **[d]** — zero invention, and it removes the need for any per-field error mark |
| Per-field inline message under a row | **[INVENTED]** — the reference has no line under a row, and inserting one reflows the list | not recommended |
| A per-field error mark (colour, border, icon) | **[INVENTED]** and **impossible inside the palette** — there is no error colour, and a 2 px accent border would give the accent a seventh meaning *and* look like a category chip | refused |

**Recommendation: prevention at the keystroke, one named-field body line at
submit.** **Cost:** on a long admin form, prose that names the field is worse
than an inline marker — the user must map a sentence to a control.

**The admin has an escape hatch and the native apps do not.** File 12 §7: the
1:1 rule does not govern the dashboard. So an admin-only error colour is
*available* — on the same terms as [RAISE-OA-13]'s muted tier and §3.3's `tnum`
question: it breaks token kinship with `packages/ui`, so it is a founder call,
not a default. Naming it here so all three are decided together rather than six
months apart. [RAISE-F15]

### 9.3 D-05's commit semantics offline — an open fork, closed

File 11 D-05 leaves it open: *"edits queue **or** are refused with `You're
offline. Try again when you're back on.`"* A text field's commit semantics are
this file's subject matter, so it is settled here rather than left.

**The deciding fact is a model gap, not a UI preference.** `Report` has an
explicit conflict rule — most-recent-`capturedAt` wins, regardless of source
(file 12 §4.1) — which is what makes a queued report safe. **`User` has no
conflict rule at all.** A queued name edit that lands after a change made on
another device has no defined winner.

**Recommendation: D-05 refuses offline**, using file 11's own string, until
ticket 19 defines a conflict rule for `User` fields. **Cost:** D-05 becomes the
one driver screen that refuses where every other queues, which cuts against
ADR-0007's grain and must be stated in D-05's copy rather than discovered.
[RAISE-F22]

---

## 10. The admin's harder controls — what is native-web and out of `packages/ui`

File 12 §7: the admin takes file 10 §10.1–§10.4 (**tokens only**) and **no React
Native components**, and the 1:1 rule does not govern it. 10-v2 §10.5 is
explicit that component *sizes* are **native only** — so the admin may not use
`size.ctaHeight`, `size.settingsRow` or any other §10.5 row. It inherits colour,
type, spacing and radius, and nothing else.

### 10.1 Out of `packages/ui` entirely

`<input type="text">` · `<textarea>` · `<input type="number">` · `<select>`
(Owner, connector type, role, every A2/A9 filter — **including A9's `source`
filter**, which file 12 §10.2 names and v1 dropped) · the checkbox on a filter
facet · every table · A7's ordered photo grid and its drag-to-reorder ·
`Owner.icon` and `Photo` file upload · A3's MapLibre `geo` picker · A8's
checklist · A10's audit table — **and A9's three availability buttons**, below.

**A9's availability write control, named because nobody names it.** File 12
§10.2 gives A9 *"a **single-observation** write form"* whose labels are the same
three [vocab] report-action strings as O4 and S-02. Neither inventory in v1
contained it: §1.3 named the labels but not the control, §10.1's native-web list
omitted it, and the CTA-geometry control is a `packages/ui` React Native
component the admin may not have. **So the one control in the admin that writes
the thing the product exists to tell the truth about had no home in either
list.**

| Property | Value |
| --- | --- |
| What | **three admin-native buttons**, one per writable `Report` state, labels [vocab] per `docs/availability-display.md` §2.4 |
| Tokens | `color.surface` unselected + `color.text`; `color.accent` + `color.onAccent` when selected; `radius.button` 4.3 pt; `type.label` 15 pt Medium — all **[admin]** rows |
| Geometry | **the web layout's**, not `size.ctaHeight` — §10.5 is native-only |
| Attached | **file 12 §8's six prohibitions**, in full. This is the form rule 1 (*"No availability field on any station, bay or connector form"*) exists to keep honest, and rule 2 forbids any bulk or multi-select shape on it |

[RAISE-F21]

**They must** use the `[admin]` token rows, keep the accent at exactly one value
with no tints, and keep images rounder than containers (`radius.image` 10 pt over
`radius.button` 4.3 pt — the system's signature inversion). **They must not**
invent a second visual language, use `color.iconMuted` as a text tier, or import
a native component's geometry back into `packages/ui`.

### 10.2 A4's nested Bay → Connector editor — one control the model forbids

Structure: Station → Bay (≥1 to publish) → Connector (1..N, ≥1).

**The editor may not offer a delete control**, because **[RAISE-OA-14]** says
deletion has no defined semantics — `Report` is append-only and hangs off
`Connector`, so deleting one orphans its history. Until that is ruled, the
editor creates and edits and does not destroy. **A control the model forbids is
not designed**; it is raised.

### 10.3 A5's pin-scale preview — a cross-medium dependency nobody has costed

A5 previews `markerLabel` + `icon` **at pin scale**, because the admin is the
only place they are authored. The pin is a `packages/ui` React Native component,
and the admin takes **no React Native components**.

So the pin must be **drawn twice** (an RN component and a web SVG, kept in
step forever) or **authored once as a shared SVG** that both consume. The second
is obviously right and it is a `packages/ui` packaging decision nobody has made.
[RAISE-F16]

### 10.4 A8's publish checklist is not a control

The gate is computed — ≥1 Bay, each Bay ≥1 Connector, ≥1 Photo. The checklist
**displays** the unmet items. The only controls on A8 are `Publish` and
`Unpublish`, the second of which is destructive (stream 1's confirmation
pattern). **No new control is required**, and saying so is the point.

### 10.5 A6's and O6's invite — the box is specifiable, the form is not

`Membership` is `(userId, stationId, role)` unique, and an invitee has **no
`userId` until they accept** ([RAISE-OA-6]).

Two different statements, which v1 ran together and contradicted itself over:

- **The control** is specifiable and is specified: O6 takes §2.3's field box at
  the settings container's 1128 px [m·15 #3] with a `type.heading` label above,
  plus a primary CTA. A6 takes a native `<input type="email">` plus a role
  `<select>`. Both appear in §12's inventory.
- **The form** is not. Its validation, its pending state, its duplicate rule and
  what a submitted invite *becomes* all depend on an entity ticket 19 has not
  chosen. **Raised, not designed** — for A6 and O6 alike.

---

## 11. Raised

Twenty-two. **Derived** = assembled from measured surfaces by stated arithmetic.
**Invented** = no measured source for the object. **Found** = a contradiction in
the existing corpus.

| # | What | Class | Recommendation | Cost |
| --- | --- | --- | --- | --- |
| **F1** | **[RAISE-D21] points at the wrong surface.** The feature chip is 35 pt and file 11 §12.3 rules chip geometry out for controls product-wide | **Found** | Redirect to the existing secondary-control box: `color.surface` + `size.ctaHeight` 138 px + `radius.button` 13 px + `space.chipPaddingH` 30 px | **Four amendments**: `SPEC.md` §12 (**ratified**), file 11 S-01's [RAISE-D21] paragraph, file 11 §16's D21 row, file 12 [RAISE-OA-4]'s consumption clause. **Until they land, a build reading SPEC ships a 35 pt tap target** |
| **F2** | **A field is not content-sized**; the chip is [m·15 — six widths on one screen] | Derived | Field width = the container's content box; in a settings row, one column per screen at that screen's widest label + 30 px | Ragged left edges if the rule is applied per row instead of per screen |
| **F3** | **`User.name` has no bound**; its editing surface holds 32 characters [d] | **Found** | D-05's `Email` becomes a readout (an auth identity, owned by D-06); bound `User.name` in ticket 19 | A schema addition. **The capacity argument v1 used here is withdrawn** — the recommendation never depended on it |
| **F4** | The reference has **no numeric field**; money and power fields are specialisations of F1's box | Derived | Integer-only for RWF, space group separator [m], grouping applied on display only | Editing and display strings differ in width |
| **F5** | **Old-style figures are proportional** — adv(`0`) **32 px** vs adv(`1`) ≈**25 px** at cap 36 [m·19 #1] — so a right-aligned column drifts ≈**19 px = 6.2 pt** at cap 32, and ADR-0010's band has no tabular row | **Found** | Band row: **`onum` + `tnum` together**, in the numeric field and its value column only; a **lining** `tnum` is not a substitute. Native: accept the drift. Admin: a lining `tnum` is a founder call beside [RAISE-OA-13] — recommendation **no** | A band row most free faces will fail, or a column that does not align. **Never two figure sets in one product** |
| **F6** | The **unit suffix inside a field** has no precedent — the reference composes amount + unit in a read slot only | Invented (object; all values are tokens) | Value cap 32 **Bold**, suffix cap 32 **Regular**; suffix pinned with its right edge at the 30 px trailing inset; value right-aligned to it and **set solid**, per the reference's own 3 px letter-fit [m·19 #4] | The numeric field's value weight differs from the text field's; weight is a weaker ownership signal than colour, and the palette has no second colour to spend |
| **F7** | **O5a's row is over-claimed**: file 12 gives it a right-aligned value *and* a plug multi-select, and both want the same 568 px [m·15] | **Found** | `Bulk apply` **pushes a full-screen surface** (O5c) carrying the plug rows, their checks and one numeric field | **One extra screen.** No longer depends on [RAISE-OA-15] — a push is measured navigation vocabulary; an action sheet cannot host checks plus a field |
| **F8** | **The connector picker is named twice and specified nowhere** (13-v2 MINOR-5) — and file 11 specifies it over **types**, which cannot name the Connector a report needs | **Found** | Platform action sheet, **over Connectors**, as S-03 and O3's `⋯` already are | A fourth screen depends on [RAISE-OA-15]; file 11 §8.0/§12.1's wording needs correcting |
| **F9** | **Off and non-interactive render identically** — the check is additive and settings rows have no trailing affordance [m] | Derived | Accept; the refusal copy carries the distinction, per §12.2's rule | Depends on the user reading one ExtraLight body line ([RAISE-2]) |
| **F10** | **"Accent means selected" is presented as the reference's own** on the strength of one category chip with nothing to contrast it against; file 11 [RAISE-D22] says the opposite | **Found** | Mark it [INVENTED] in file 12 §4.3 and inherit [RAISE-D22] | None — the design is right, only the provenance claim moves |
| **F11** | **O4's zero-touch Save is a disabled control**, which file 11 §12.2 rules against by name | **Found** | Route to stream 1; cheapest fit is the §12.2 body line until the first touch | Stream 1 must rule; the fix is additive |
| **F12** | **Caret and selection are one value on iOS**; white is disqualified (white behind white text) | Invented (object) | `selectionColor` per F19; **caret width is [?] — React Native exposes none on either platform**, so `size.hairline` 2 px records the intent and the OS renders its own | The stated caret width will silently not apply |
| **F13** | **Keyboard avoidance is a layout translation**, in a reference with no motion | Invented (object); the 34.3 pt gap is [m] | Translate by the keyboard's height, following the OS's own curve — licensed only by F20's rule | S-01's card height is **composed, not measured** [?]: 254.6 pt idle / 364.6 pt worst case against a 444.7 pt ceiling [d]. The keyboard height is [?] and varies by locale |
| **F14** | With the keyboard up, **tap-outside means two things** (13-v2 MAJOR-7's second consequence) | **Found** | First tap dismisses the keyboard, second the card | A driver leaving taps twice |
| **F15** | **Field-level validation has no measured home**, and the palette has no error colour | Invented (position) | Prevent at the keystroke (hard stop); one named-field `type.body` line at submit. The admin's error-colour escape hatch is a founder call, decided with [RAISE-OA-13] and F5 | Prose that names a field is worse than an inline marker on a long admin form |
| **F16** | **A5's pin preview needs the pin in a web-renderable form**, and the admin takes no RN components | **Found** | Author the pin once as a shared SVG both consume | A `packages/ui` packaging decision nobody has made |
| **F17** | **[C1] — file 12 §4.3's control-row arithmetic applies a cap-36 Bold *price* advance to a Medium *letter* label**, overstating it by 32 % | **Found** | Restate §4.3 at the Medium constant and re-declare cap 32 as a **choice**, not an arithmetic necessity; record the margin as **13.7 px at the authorised cap 36** | None to the design. v1's own correction computed at **cap 37**, a value §0.3 declares void, and told the corpus to write down 4.6 px |
| **F18** | **An empty field and a button are the same box** — same fill, radius, height and label size; no border, no placeholder, no pre-tap focus signal; the box edge is 1.62 : 1 [d] in a dark-only app read in equatorial sun (ADR-0009 §4) | **Found** | **Founder call.** (a) accept the mute field, carried by the persistent label; (b) a 2 px border — only `color.text` is legible, and no white border exists anywhere; (c) stream 1's focus treatment, which **does not answer it**. Recommendation **(a)**, recorded as an impossibility, with the launch-week survey pass as the evidence path ADR-0009 §4 already names | Exposure is narrow — only S-01/O1's email, O6's invite and the admin's create forms are genuinely empty. Where a value slot sits beside a field, the box is the discriminator |
| **F19** | **The selection highlight is the product's first tinted accent.** §10.1: *"exactly one value, no tints"* and *"Deliberately absent: … opacity ramp … accent tint"* | **Invented** (a tint the palette says does not exist) | **Founder call.** (a) accept the platform's 20–30 % composite — white text at **6.74 : 1 to 5.17 : 1** [d] — and amend §10.1 in the same breath; (b) `color.bg` `#121212`, which invents nothing and reads at 18.73 : 1 but gives a 1.62 : 1 highlight. Recommendation **(a)** | (a) grows the palette and gives the accent a sixth meaning; (b) may be invisible in sunlight. Either way the rendered result is **[?] until a device check** |
| **F20** | **A product-wide motion rule was adopted in prose**: *the product authors no motion; it may follow motion the platform authors* | **Invented** (a rule, not a value) | **Founder call.** Adopt once, with the caret and the keyboard as its instances, naming file 11 §9.4 (*"Motion: none, anywhere"*) as the sentence it amends | The corpus's push/present transitions and the platform action sheet already animate, so §9.4 is **already false as written**. The rule makes existing behaviour honest rather than adding any |
| **F21** | **A9's admin availability write control appears in no inventory** — file 12 §10.2 specifies the form, the CTA-geometry control is a native component the admin may not have, and §10.5 is native-only | **Found** | Three **admin-native** buttons at the `[admin]` tokens with web geometry, carrying file 12 §8's six prohibitions | None to the design. Unnamed, it would have been built from `size.ctaHeight` — a native-only token — or not at all |
| **F22** | **D-05's offline commit is an open fork** in file 11 (*"edits queue **or** are refused"*) | **Found** | **Refuse offline**, using file 11's own string, until ticket 19 gives `User` fields a conflict rule; `Report` has one and that is what makes queuing safe there | D-05 becomes the one driver screen that refuses where the rest queue — stated in copy, not discovered |

**Refused rather than raised** — a placeholder (§7.1: unimplementable inside the
measured palette, because it would need the `text.secondary` token §10.1
deliberately omits); a radio glyph (§4.4: the semantic does not occur, and a
check cannot honestly carry it); a date control (§1.5: prohibited by file 12 §8
rule 4); a per-field error mark (§9.2); a second figure set (§3.3).

---

## 12. The control inventory

| Control | Screens | Box | Provenance | Open |
| --- | --- | --- | --- | --- |
| **Text field** | D-05, S-01, O1, O6 | `#393939` · 138 px · r13 · 30 px inset · value **cap 32 Regular**, left | **[d]** from `color.surface`, `size.ctaHeight`, `radius.button`, `space.chipPaddingH`, §4.1 row 12 | F1 · F3 · F18 · F19 · F13 · F15 · F22 |
| **Numeric field** | O5a, O5c, A4 | as above; value **cap 32 Bold**, right-aligned to a pinned **cap 32 Regular** unit suffix | **[d]** + **[INVENTED]** suffix placement | F4 · F5 · F6 · F18 |
| **Trailing check** | D-08, D-09, **O5c** | `#C7FC2F` · 72 px ink · 6 px stroke · row-centred · right of the content box | **[m]** throughout — `color.accent`, `size.iconGrid`, `size.iconStroke`, [m·15 #5], [m·19 #5] | F7 · F9 |
| **CTA-geometry control** | O4, S-02, D-03, S-01/O1 | `#393939` · 138 px · r13 · label **cap 32 Medium** (S-02, O4, D-03) or **cap 36 Medium** (S-01/O1) | **[m]** — specified by file 12 §4.3 and file 11 §12.2/§12.3, checked here | C1 · F10 · F11 · F17 · F18 |
| — *accent fill* | **O4 only** | `#C7FC2F` + `#121212` Medium when selected | file 11 §12.3: *"S-02 has no selected state… so nothing there is lime"*; D-03's bay-watch control is `#393939` only | F10 |
| **Primary / sticky CTA** | D-01/D-02, D-03, O3, O4's Save, O5a, O6 | 138 px / cap 36 and 131 px / cap 32 — **two components** | **[m]** 10-v2 §7.1 / §7.8; **not this file's** — see 10-v2 [RAISE-4] | — |
| **Select / picker (native)** | S-03 / §12.1 only | platform action sheet, **over Connectors** | adopted from [RAISE-D13] / [RAISE-OA-15] | F8 |
| **Select (admin)** | A2, A3, A4, A6, A9 (station · connector · **source**) | native `<select>` over the **enum**, not the projection | out of `packages/ui` | §6.1 |
| **Availability buttons (admin)** | **A9** | three admin-native buttons at the `[admin]` tokens, web geometry | out of `packages/ui`; **§10.5 is native-only** | F21 |
| **File upload** | D-05, A5, A7 | platform picker / native web | out of `packages/ui` | — |
| **Ordered grid + reorder** | A7 | native web | out of `packages/ui` | — |
| Caret · selection | every field | `color.accent` (F19); **caret width [?] — no API** | **[INVENTED]** object, measured values | F12 · F19 |
| Placeholder | — | **does not exist** | refused, §7.1 | — |
| Date · stepper · slider · search · segmented · radio · toast · progress | — | **not designed** | §1.5 | — |

---

## 13. What this file does not decide

The seven interaction states (stream 1) · [RAISE-D14]'s value slot, which this
file **consumes** and whose refusal would take §2.4's placement with it ·
[RAISE-D17]'s ruling, adopted unchanged · O4's control row, checked but not
redesigned · the typeface, which blocks every capacity figure here from becoming
a guarantee ([RAISE-1], ADR-0010) · `Station.description` and therefore the
multi-line variant (ticket 19, and 13-v2 MAJOR-2 first) · the `Invitation`,
`RateFlag` and audit entities, without which O5b, O6 and A6 cannot be specified
at all · a conflict rule for `User` fields (F22) · whether S-01's email variant
keeps the provider buttons (file 11) · the admin's own layout, which is a web
problem file 10 does not solve · and every founder call in §11, which is the
point of raising them.

---

## 14. Answers to the verdict

Every finding in `17-form-controls-verdict-v1.md`, answered. **FIXED** = the
document changed, with how. **REJECTED** = it did not, with the source that
disproves the finding. **ACCEPTED-AND-RAISED** = the honest answer is that it
cannot be resolved inside the measured palette, so it becomes a founder call.

### The three fatals

| # | Finding | Answer |
| --- | --- | --- |
| **FATAL-1** | §3.3(a) reads digit **heights** as **widths** and mis-cites §4.1 row 7 | **FIXED, and re-measured from the pixels.** The citation moves to `10-design-system-v2.md` **§3.2**, and [m·19] #2 confirms both figures are ink heights above the baseline (`1` y2417→2446 = 29; `0` y2416→2447 = 30 + 1 below; `R`/`F` cap y2410→2446 = 36). The corpus measures **no digit advance anywhere**, so §3.3 now carries its own: [m·19] #1 gives adv(`0`) = **32 px exactly** from two same-glyph pitches (x187→x219→x251), adv(`1`) ≈ **25 px** and adv(`3`) ≈ **29 px** as start-to-start proxies, both marked as proxies. The consequence is restated at **≈21 px = 7.0 pt at cap 36 and ≈19 px = 6.2 pt at the field's cap 32**, not 2 pt, and F5 is re-decided against that number. *(The verdict computed 22.5 px = 7.5 pt from adv(`1`) = 24; my own runs put the `1`→`3` pitch at 25 px under the file's core convention. The 1 px difference does not move any conclusion and both figures are ~3.5× v1's.)* |
| **FATAL-2** | A field and a button are one box; the empty field has no affordance, and §5.1 calls it *"No contradiction"* | **ACCEPTED-AND-RAISED.** §5.1's sentence is deleted and replaced with the collision stated as a finding. New **§2.6** raises it as **[RAISE-F18]** with three options and their costs, ADR-0009 §4 named as the compounding cost and its own launch-week evidence path adopted. Two refinements the verdict did not have: the exposure is **narrow** — only S-01/O1's email, O6's invite and the admin's create forms are genuinely empty, since every other field opens pre-filled — and where a [RAISE-D14] value slot sits beside a field on one screen, **the box itself is the discriminator** (§2.5). One option the verdict offered is rejected inside the raise: **(c) stream 1's focus treatment cannot carry it**, because focus is post-tap and the defect is pre-tap. |
| **FATAL-3** | The unit suffix is specified twice, differently; the cited weight contrast is deleted; ≈164 px cannot sit inside a 30 px inset; §2.3's alignment rule is contradicted | **FIXED, with the composition re-measured rather than assumed.** [m·19] #3 measures the reference's own price at cap 36: `F` stem **6.92 px** (0.192 → Bold) against `d` **4.42 px per stem** (0.123 → Regular). So *amount Bold + slash-unit Regular* is measured, not merely asserted, and §3.4 now renders the value **cap 32 Bold** and the suffix **cap 32 Regular**. The suffix is **pinned with its right edge at the 30 px trailing inset** and the value is right-aligned to it; §2.3's alignment row is rewritten to match. **One departure from the verdict's prescribed fix:** it specifies `space.chipIconGap` 18 px between value and suffix; [m·19] #4 measures the reference's own gap at **3 px — normal letter-fit, not a layout gap** (`F` ink ends x407, `/` starts x411). The composition is therefore **set solid**, which invents nothing where the verdict's fix would have imported a chip token into a text run. The consequence the verdict asked to be stated is stated: the numeric field's value weight differs from the text field's. |

### The eight majors

| # | Finding | Answer |
| --- | --- | --- |
| **MAJOR-1** | [C1]/F17 recomputes at cap 37, which §0.3 declares void; at cap 36 the margin is 13.7 px | **FIXED.** §5.2's table is recomputed at cap 36 throughout: k = 0.65 × 36 × 14 = **327.6 px** in 341.3 px → **13.7 px total, 6.85 px each side**. F17's instruction to the corpus now records 13.7 px. The verdict's second point is adopted and stated in the table: **21.25 px/char is an absolute measured ink advance (340 px ÷ 16 ch) and is cap-independent**, so that row is unaffected by the 36/37 question. §0.3 gains an explicit clause binding every CTA-label fit check in this file to cap 36. |
| **MAJOR-2** | §2.2's "one box, used three times" mis-cites file 11 S-01, which draws cap 37 Medium | **FIXED.** Verified in file 11 S-01's own drawing (*`cap 37 Medium #FFFFFF`*). §2.2's table now carries four rows with their label sizes explicit, row 1 reading **cap 36 Medium** (file 11's 37, corrected by §0.3 row 3), and the conclusion becomes **"one box at two label sizes"** — attributed to 10-v2 [RAISE-4], the reference's own two CTA label sizes, exactly as the verdict proposed. The field's cap-32 Regular **value** is untouched, because it rests on §4.1 row 12 and never rested on this table; §2.2 now says so. |
| **MAJOR-3** | §7.3 ships a 20–30 % accent composite and books it to the platform; §10.1 names accent tints and opacity ramps as deliberately absent | **ACCEPTED-AND-RAISED** as **[RAISE-F19]**. The classification is the reviewer's and it is correct: choosing `selectionColor = color.accent` is choosing to put an accent tint on screen. §7.3 now presents it as a founder call with both options costed — (a) accept the composite and amend §10.1 in the same breath, white text at **6.74 : 1 to 5.17 : 1** [d, re-derived; v1's 5.13 was 0.04 off]; (b) `color.bg` `#121212`, which invents nothing, gives 18.73 : 1 selected text and a 1.62 : 1 highlight. Recommendation (a), because a highlight nobody can see is a worse control than a tint nobody has authorised — but it is the founder's to authorise. |
| **MAJOR-4** | F5's `tnum` row instructs the build to do what the same paragraph forbids | **FIXED, in the verdict's own words.** The band row now reads: *if a candidate carries an **old-style tabular** set — `onum` and `tnum` together — it is enabled in the numeric field and its value column and nowhere else; a **lining** `tnum` set is not a substitute and must not be enabled.* Two additions: the row is declared a **tie-breaker between otherwise-equal faces**, not a requirement, so ADR-0010's free-first order is undisturbed; and the admin's separate case (a lining `tnum` in web tables) is routed to the founder beside [RAISE-OA-13] and F15, with the recommendation **no**. |
| **MAJOR-5** | F7's `Bulk apply` needs a container the corpus does not have; an action sheet is a list of actions | **FIXED.** §4.2's option (a) is rewritten: `Bulk apply` **pushes a full-screen surface** (O5c), which is inside the fixed navigation vocabulary ticket 31 permits. The cost changes from "one extra step" to **"one extra screen"**, and the dependency on [RAISE-OA-15] is removed. §4.2 also states the distinction the corpus needs once, so it is not re-litigated: an action sheet **can** host a single-select over a handful of labelled rows (§6.3's picker) and **cannot** host checks plus a field (§4.2's bulk apply). O5c is added to §1.2's enumeration and §12's inventory. |
| **MAJOR-6** | A9's availability write control appears in neither inventory | **FIXED**, and the finding is strengthened. §10.1 now specifies it as **three admin-native buttons** at the `[admin]` token rows with file 12 §8's six prohibitions attached, and it is raised as **[RAISE-F21]** because unnamed it would have been built wrong. The strengthening: 10-v2 §10.5 says component sizes are *"Native only — the admin dashboard inherits none of §10.5"*, so the admin may not use `size.ctaHeight` **as a token**, not merely as a component. §10's preamble now states that. §1.3 and §12 both carry the control, and MINOR-7's `source` filter lands in the same rows. |
| **MAJOR-7** | F1's "Cost: None" is false; three documents carry the sentence the redirect invalidates | **FIXED, and the count is four, not three.** §2.2 tabulates every sentence to be amended: **`SPEC.md` §12** (ratified), **file 11 S-01's [RAISE-D21] paragraph**, **file 11 §16's D21 row** — which the verdict missed, and which is the one a reader of the raise list would hit — and **file 12 [RAISE-OA-4]'s consumption clause**. F1's cost column now reads *four amendments*, with the verdict's own consequence attached: **until they land, a build reading SPEC ships a 35 pt tap target.** |
| **MAJOR-8** | A product-wide motion rule is invented in a form-controls pass and never raised | **ACCEPTED-AND-RAISED** as **[RAISE-F20]**, in its own section (§7.5) rather than in a parenthesis. One addition beyond the verdict: the rule does not merely license the caret and the keyboard — the corpus's **push and present transitions** (files 11 §8.0, 12 §3.0) and **the platform action sheet** already animate, so file 11 §9.4's *"Motion: none, anywhere"* **is already false as the corpus is written**. The rule adds no behaviour; it makes existing behaviour honest. File 11 §9.4 is named as the sentence it amends. |

### The ten minors

| # | Finding | Answer |
| --- | --- | --- |
| **1** | `color.surface` on `color.surface` is 1.00 : 1, not 1.08 : 1 | **FIXED.** Recomputed: identical colours are **1.00 : 1**; 1.08 : 1 is `#3E3E3E` on `#393939` [d], which is §7.3's own second row and is now labelled as such. The rule that follows is stated at the stronger figure. |
| **2** | §0.3 #4's 71 px ink height is outside §7.6's 62–68 px band and is not owed back | **FIXED, and sharpened.** [m·19] #5 re-measures the row-1 icon at **64 px wide × 71–72 px tall**: §7.6's band holds for the **width** and not the **height**, and 72 px is exactly `size.iconGrid`. §0.3 gains an **owed back to 10-v2** block carrying this and three other contradictions, per file 11 §0.3's policy. The correction also supports §4.1: the check's 72 px ink box is the settings-row family's own vertical extent, not a borrowed number. |
| **3** | §7.3 specifies a caret width the cited API does not expose | **FIXED, with a different remedy than "drop it".** §7.3 now marks the rendered width **[?] — the platform's, not ours**, states that React Native exposes `selectionColor` / `cursorColor` and no caret width on either platform, and keeps `size.hairline` 2 px as the recorded intent rather than deleting a measured value. F12's cost column says the stated width will silently not apply. |
| **4** | [m·15] #5 and #6 are unregistered new measurements, and #1 finds six chips where 10-v2 counts four | **FIXED, and adjudicated more precisely than the finding.** §0.3's owed-back block registers them. On the chip count the verdict conflates two claims: 10-v2 **§1.3's "four chip labels" is correct** — [m·19] #6 confirms the two extra boxes are clipped at y2336 by the sticky bar and carry no visible label — while **§7.5's width list is four of six** and is what is owed back. |
| **5** | §8's card sum is 341.6 pt, stated as 341.9, and its 8.3 pt term is the wrong gap | **FIXED, and a third error found.** §8's composition is rebuilt term by term with each cited: card-top→handle **8.3** [m], handle **4.3** [m], handle→content **13.0** [m], and so on to **254.6 pt**. Beyond the verdict's two points: v1 also applied a **64 pt top padding the card does not have** — 10-v2 §7.4 gives internal padding *"on left, right and bottom"* and the top measures 25 px to the handle. The fit conclusion survives all three, which is why they went unfound; headroom is **190 pt**, not ~103. The email variant is now computed at its **worst permissible composition, 364.6 pt**, and file 11's ambiguity about the provider buttons is named rather than resolved. |
| **6** | O6 is both specified and refused | **FIXED.** §10.5 separates the two claims explicitly: **the control** is specifiable and is specified (field box at the settings container's 1128 px with a `type.heading` label; A6 takes a native `<input>` + `<select>`), and **the form** is not, because its validation, pending state and duplicate rule depend on an entity ticket 19 has not chosen. §1.2 and §12 carry the box; §10.5 refuses the form, for A6 and O6 alike. |
| **7** | §1.3 drops A9's `source` filter | **FIXED.** §1.3's A9 row and §12's admin-select row both read *station · connector · **source***, per file 12 §10.2. |
| **8** | D-05's offline fork is neither closed nor raised | **FIXED, and closed.** New **§9.3**. The deciding fact is a model gap, not a preference: `Report` has an explicit conflict rule (most-recent-`capturedAt` wins) and **`User` has none**, so a queued name edit has no defined winner. Recommendation: **refuse offline**, using file 11's own string, until ticket 19 supplies one. Raised as **[RAISE-F22]** with the cost stated — D-05 becomes the one driver screen that refuses where the rest queue. |
| **9** | The closed vocabulary is used without citing its home | **FIXED.** §0.2 states the one-home rule for this document: forbidden strings live in `docs/availability-display.md` **§2.2b**, the type-word projection and state words in **§2.4**, and this file names neither list. §6.1 now cites §2.4 and gives the projection's **count** instead of re-tabulating the five words; §4.2, §6.2 and §10.1 cite the same section. |
| **10** | §12's CTA-geometry row assigns the accent to O4, S-02 and D-03, and omits O3's sticky CTA | **FIXED, in two rows rather than one.** The CTA-geometry row now lists O4, S-02, D-03 **and S-01/O1** with their two label sizes, and a sub-row reads **accent fill on O4 only**, citing file 11 §12.3 (*"S-02 has no selected state… so nothing there is lime"*) and §12.2 (D-03 is `#393939` only). On the omission: O3's sticky CTA is **not** a CTA-geometry control — it is `size.ctaHeightSticky` 131 px at cap 32, a separate measured component under 10-v2 [RAISE-4] — so folding it into that row would have been a second error. It gets its own inventory row, marked *not this file's*. |

### What v1 got right and this revision keeps

Carried verbatim because the verdict re-derived them and they hold: all six
**[m·15]** measurements (re-run again here; all six reproduce), **§0.3's
authority table** (accurate against `13-design-verdict-v2.md` on all six rows),
**§7.1**'s placeholder refusal, **§4.1**'s trailing check, and the **[C2]** and
**[C4]** corrections. Carried in substance: the write-first enumeration across
every screen, the seven refused controls of §1.5, §2.1's height argument against
[RAISE-D21], §4.4's refusal to make one glyph carry three semantics, and the
native-versus-admin split.
