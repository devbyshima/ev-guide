# 17 — Adversarial verdict on `15-form-controls-v1.md` (design stream 2)

Verdict: **REJECT.** 3 fatal · 8 major · 10 minor.

Read in full against the document: ticket 31, `10-design-system-v2.md`,
`11-driver-screens-v2.md`, `12-operator-admin-screens-v2.md`,
`13-design-verdict-v2.md`, `SPEC.md`, `docs/domain-model.md`,
`docs/availability-display.md`, ADR-0007, ADR-0009, ADR-0010.

**Every pixel claim below was re-measured from `refs/01.png`–`04.png` by this
review**, not taken from the document. The document's own six `[m·15]`
measurements were re-run first; all six reproduce (§1 says so plainly, because
that is what makes the one fabricated measurement findable).

The hunted failure shape — *a claim in one section disproved by a table in
another* — recurs **seven times**. Three of them ship a visible defect.

---

## 1. FABRICATED MEASUREMENT

### The six `[m·15]` measurements are real — re-derived here

| # | Document claims | Re-measured this review | Verdict |
| --- | --- | --- | --- |
| 1 | chip widths `270 / 316 / 387 / 652 / 397 / 371` at y2065 / y2196 / y2330 | `#393939` runs: y2065 → 270, 316, 387 · y2196 → 652 · y2330 → 397, 371 | **exact** |
| 2 | chip gaps 27 h / 26 v | x334→362, x677→705, x461→489 = 27; rows 2160→2187, 2291→2318 = 26 | **exact** |
| 3 | dividers y2188/2364/2541, x39→1166 = 1128 px `#3E3E3E` | identical, 1128 px per row | **exact** |
| 4 | row-1 icon ink y2241–2311 (71), x45–108 (64) | identical | **exact** (but see MINOR-2) |
| 5 | icon centre y2276.0 vs row centre | ink centre (2241+2311)/2 = 2276.0; band centre 2276.0 | **exact** |
| 6 | label ink ends x535 / x598; 568 px of empty row | row 1 white ink x197–535; row 2 x197–598; 1166−598 = 568 | **exact** |

That makes the next finding worse, not better: the file measures honestly when
it measures, so a reader will not audit the one place it did not.

### FATAL-1 · §3.3(a) reads a table of digit **heights** as digit **widths**, and the consequence it derives is wrong by 3.5×

> *"**(a) The figures are proportional, not tabular — measured.** File 10 §4.1
> row 7: in `135 000 RWF` at cap 36, the `1` is **29 px** and the `0` is
> **31 px** [m]. A 2 px per-digit difference at cap 36 is a proportional set."*
>
> *"`600` and `111` right-aligned differ at their left edge by ≈6 px = 2 pt [d]."*

**Disproved by `10-design-system-v2.md` §3.2**, which is where those two numbers
actually live (§4.1 row 7 is `| 7 | Detail price 135 000 RWF | 04 | 36 | 27 |
6.83 | 0.190 | Bold |` — it contains no digit figure at all). §3.2's columns are
`Baseline · Cap · x-height · Digits · Descending`, and its own prose says what
the `Digits` column is: *"Digits sit at x-height + ~2 px (the round-figure
overshoot)"*. `1` 29 · `0` 31 are **ink heights above the baseline** — 29 for the
flat-topped `1`, 31 for the overshooting round `0`, against an x-height of 27.
The companion row proves it: at cap 27 the same column reads `2` 22 · `0` 23
against an x-height of 20. Nothing in the corpus measures a digit's width.

**Re-measured from `04.png`** (sticky price, baseline 2446): ink heights `1` = 29,
`0` = 30 — the document's cited numbers, confirmed as *heights*. The **advances**
are `1` → 24 px, `0` → 31.5 px (x93→117, x188→220→251). So:

- the per-digit difference is **7.5 px, not 2 px**;
- `600` vs `111` right-aligned differ at their left edge by **≈22.5 px = 7.5 pt**,
  not *"≈6 px = 2 pt"*.

**Why fatal.** The 2 pt figure is what F5's recommendation is calibrated on —
*"otherwise **accept the jitter** — the columns are 1–5 rows long and the amounts
are read individually"*. A 2 pt wobble is acceptable; a **7.5 pt** wobble in a
column of rates on O5a and A4 is a visible defect, and the document proposes to
amend a ratified ADR (0010) on the strength of the small number. It is also the
document's only [m]-tagged value whose cited source does not contain it.

**Must say instead:** cite `10-design-system-v2.md` §3.2 for the *descenders*
only; state that no digit **advance** is measured in the corpus and mark the
proportionality finding `[m·15]` with its own measurement (`1` 24 px / `0` 31.5 px
advance at cap 36, `04.png` x93–276), or mark it `[?]`. Restate the column
consequence at 7.5 pt and re-decide F5 against that number.

### Other values, checked one by one

Correctly cited, with the token named, and numerically right: `color.surface`
`#393939`, `color.accent` `#C7FC2F` (15.52 : 1 on `color.bg`, 9.57 : 1 on the
field), `color.text` (11.55 : 1), `size.ctaHeight` 138 px = 46.0 pt,
`radius.button` 13 px = 4.3 pt, `radius.chip` 10 px, `size.chipHeight` 105 px =
35.0 pt, `space.chipPaddingH` 30 px = 10 pt, `space.chipGap` 27 px,
`space.chipRowGap` 26 px, `size.settingsRow` 176 px = 58.7 pt, `size.iconGrid`
72 px = 24.0 pt, `size.iconStroke` 6 px = 2.0 pt, `size.hairline` 2 px = 0.67 pt,
`space.floatingCardBottomGap` 64 px, the 103 px / 34.3 pt resting offset, the
874 pt screen, cap 32 Regular from §4.1 row 12, the 0.28–0.33 descender band from
§3.5, the 53 px cap-box offset and its check against §7.1's 50/51 px optical
centring, the 950 px card inner box ([RAISE-D31]), 890 px inner / 38 chars,
479 px inner / 20 chars. **§0.3's authority table is accurate** against
`13-design-verdict-v2.md` on all six rows (MAJOR-4, FATAL-2, MINOR-2, MINOR-8).

Three values are wrong or unsourced — see MAJOR-1 (cap 37), MAJOR-2 (S-01's
cap 32), MINOR-1 (1.08 : 1).

---

## 2. SILENT PALETTE GROWTH

Checked token by token against `10-design-system-v2.md` §10.1. No new colour
token, no elevation, no shadow, no border, no second accent, no grey text tier.
§7.1's refusal of the placeholder is the strongest argument in the file and it is
argued from the absent token rather than from taste. §9.2 correctly refuses a
per-field error mark and correctly routes the admin error colour to a founder
call beside [RAISE-OA-13]. [C3] names the accent's fifth and sixth meanings
rather than spending them quietly.

**MAJOR-3 · §7.3 ships a translucent accent and books the cost to the platform.**

> *"What saves it is that the platform draws the highlight **translucent**, not
> opaque: at 20–30% over `#393939` the white text holds **6.74 : 1 to 5.13 : 1**
> [d]. That alpha is the platform's value, not this design's"*

The arithmetic is right (re-derived: 6.74 and 5.17). The classification is not.
`10-design-system-v2.md` §10.1: *"`color.accent` … **exactly one value, no tints,
no gradients**"*, and *"Deliberately absent: any `text.secondary`, `text.muted`,
**opacity ramp**, elevation colour, or **accent tint**."* Choosing
`selectionColor = color.accent` is choosing to put a 20–30 % accent composite on
screen; that the OS mixes it does not make it not a tint. Ticket 31: *"A state
that needs a new token is a founder call, not a design decision."*

**Must say instead:** raise it — *"the selection highlight is the product's first
tinted accent; §10.1 says there are none. Founder call: accept the platform's
composite, or use `color.bg` `#121212` at 1.62 : 1 and lose the convention."*
F12 currently raises only the device check.

---

## 3. COVERAGE HOLES

Checked exhaustively against `11-driver-screens-v2.md` §17 and
`12-operator-admin-screens-v2.md` §10.1/§10.2. Every state that needs a *control*
is served except the following. (States needing only a *treatment* — pressed,
disabled, in-flight, empty, confirmation — are stream 1's and are correctly
deferred.)

**MAJOR-6 · A9's availability write control is specified by nobody.**
12 §10.2 A9: *"read-only table + a **single-observation** write form … labels
`Free`/**`Busy`**/`Out of service` [vocab]"*. The document's §1.3 gives A9
*"station/connector selects + the three [vocab] labels"* — but §10.1's
admin-native list (`<input>` · `<textarea>` · `<input type="number">` ·
`<select>` … *"every A2/A9 **filter**"* · the filter checkbox · tables · the
photo grid · the geo picker · the checklist · the audit table) **does not contain
it**, and the CTA-geometry control is a `packages/ui` React Native component
which 12 §7 forbids the admin. So the one control in the admin that writes the
thing the product exists to tell the truth about has no home in either list.
**Must say instead:** name it in §10.1 as three admin-native buttons at the
`[admin]` tokens, with 12 §8's six prohibitions attached — it is the form that
rule 1 (*"No availability field on any station, bay or connector form"*) exists
to keep honest.

**MINOR-6 · O6 is both specified and refused.** §1.2: *"**O6** | invite by email;
revoke | **text field** ×1 (email) + CTA + destructive confirmation"*, and §12's
inventory ships O6 in the text-field row. §10.5: *"A form whose target entity does
not exist **cannot be specified** … Raised, not designed. Same for O6."* Pick one:
the *box* can be specified and the *form* cannot — say that.

**MINOR-7 · A9's `source` filter is dropped.** 12 §10.2 A9 states *"filtered by
station/connector/**source**"*; §1.3 lists only station/connector.

**MINOR-8 · D-05's offline behaviour is an open fork nobody closes.** 11 D-05:
*"edits queue **or** are refused with `You're offline. Try again when you're back
on.`"* — a text field's commit semantics are this file's subject matter, and the
fork is neither closed nor raised.

Not holes, checked and confirmed served: D-02/D-11 hearts · D-12's value-slot
disarm · D-03's bay-watch control (11 §12.2) · D-06's platform confirmation ·
D-07's six download states · D-08 granted/denied/signed-out · D-09's five rows ·
S-01's email path and its in-flight/failed/offline variants · S-02's three
controls · S-03's picker (raised) · O1 · O4's control row and Save · O5a · O5b
(refused, correctly) · O7/O8/O9 readouts · A1–A8, A10, A11. Screens absent from
§1.1/§1.2 (D-01, D-04, O2, O3, O7, O9) write nothing; say so in one line rather
than leaving the omission to be checked.

---

## 4. INTERNAL CONTRADICTION

### FATAL-2 · The field the file exists to design is invisible until you have already tapped it

Four decisions, each defensible alone, compose into a control with no
affordance, and no section notices:

| Section | Decision |
| --- | --- |
| §2.3 | *"Border · shadow · blur \| **none**"*, fill `color.surface` `#393939` |
| §7.1 | *"**Recommendation: no placeholders, product-wide.** … **Cost: none.**"* |
| §7.4 | *"**Recommendation: the caret is the focus indicator, and nothing else.** No ring, no border, no fill change."* |
| §2.2 / §5.1 | *"That is one box, used three times"* … *"O4's unselected control and §2.3's field box are the same box. … **No contradiction.**"* |

An **empty** field is therefore: a `#393939` rounded rectangle at **1.62 : 1**
against `color.bg` (the document derives that exact ratio in §7.3 for a different
question), with no border, no label inside it, no placeholder, no focus
treatment, and geometry, fill, radius and label size **identical to the system's
buttons**. It contains nothing and looks exactly like a control you press. The
first signal that it is typable is a 0.67 pt caret that appears *after* the tap.
§5.1 presents this collision as proof of consistency.

*"**Cost: none**"* is the false statement. The cost is the affordance, and
ADR-0009 §4 compounds it (dark-only, read *"standing at a charger in equatorial
daylight"*, no light theme, no contrast mode).

**Must say instead:** raise it as the file's own finding — *"a field and a button
are one box; with no placeholder and no focus ring an empty field is
unidentifiable, and at 1.62 : 1 the box edge is the only signal. Options: (a) the
persistent label sits immediately left/above and the empty field is accepted as
mute; (b) a `size.hairline` 2 px `color.surfaceRaised` border, [INVENTED];
(c) stream 1's focus treatment carries it. Founder call."* Note that (b) is a new
border token, so (a) or (c).

### FATAL-3 · The numeric unit suffix is specified twice, differently, and drops the one property it cites as its source

> §3.4: *"**Composed from the reference's own price treatment** [m §4.1 rows
> 7/15, file 11 §1 substitution 3]: *amount Bold + slash-unit Regular*. In a
> field the amount is cap 32 Regular (§2.3) and the unit is a **static suffix at
> the same cap height, Regular `#FFFFFF`**, right of the value, inside the
> field's 30 px trailing inset."*

Two defects, one table apart:

1. **The cited composition is a weight contrast, and the spec deletes it.**
   `10-design-system-v2.md` §4.1 rows 7/15 and file 11 §1 substitution 3 give
   *amount **Bold** + slash-unit **Regular***. The spec renders both at cap 32
   **Regular** `#FFFFFF`. §3.4's own opening sentence says why that fails: *"a
   unit inside the editable string is a unit the user deletes"* — with identical
   cap, weight and colour, `600 RWF/kWh` gives the operator no way to see which
   characters are theirs. The provenance it claims supplies exactly the missing
   signal.
2. **The position contradicts §2.3.** §2.3: *"Value alignment \| **left** for
   text; **right** for numeric"*. §3.4 puts a static suffix *"right of the value,
   inside the field's 30 px trailing inset"* — but `RWF/kWh` at cap 32 Regular is
   ≈164 px and the trailing inset is 30 px, so the suffix cannot live in it, and
   a value with something to its right is not right-aligned to the field. The two
   sections specify one control differently and a build cannot satisfy both.

**Must say instead:** the suffix is `type.label` cap 32 **Regular** and the value
is cap 32 **Bold**, per the cited composition (and note that this makes the
numeric field's value weight differ from the text field's — say it); the value's
right edge sits at the suffix's left edge less `space.chipIconGap` 18 px [m], and
the suffix's right edge sits at the field's 30 px trailing inset. Then §2.3's
alignment row must read *"right-aligned to the unit suffix (§3.4)"*.

### MAJOR-1 · [C1]/F17 corrects a bad number with a number computed at a cap the file's own §0.3 declares void

§0.3, this file's authority table: *"CTA label cap \| **36 px** \| 10-v2 §4.1 row
5; verdict MAJOR-4"*. Verdict MAJOR-4 lists *"CTA label cap 36 vs 37 px"* among
the values where *"10-v2 is the token authority; delete the competing numbers"*.

§5.2 then computes three of its four rows at **cap 37**:

> *"\| **21.25 px/char — cap-37 Medium, measured** \| … \| k = 0.65 at cap 37 —
> §0.4's pessimistic Medium \| 336.7 px \| 2.3 px each side \|"*
>
> F17: *"record that the margin is 4.6 px, not 51 px, for whoever revisits it"*

At the authorised cap 36: 0.65 × 36 × 14 = **327.6 px** in 341.3 px → **13.7 px
total, 6.85 px each side** — three times the margin the file instructs the corpus
to write down. The catch itself is excellent and correctly sourced (12 §0.2 row 1
is indeed the cap-36 **Bold** price advance, 28.8 px/char, misapplied by 12 §4.3
to a Medium letter label); the correction reintroduces the same class of error.

**Must say instead:** recompute the table at cap 36 and record **13.7 px**, and
note that 21.25 px/char is cap-independent so that row is unaffected.

### MAJOR-2 · §2.2's "one box, used three times" fails on its own first row

> *"\| S-01's two secondary provider buttons \| `#393939`, **138 px**, radius
> 13 px, **label cap 32** \| file 11 S-01 \|"* … *"That is one box, used three
> times: `color.surface` fill + `size.ctaHeight` 138 px + `radius.button` 13 px
> + **a cap-32 label**."*

`11-driver-screens-v2.md` S-01 draws those buttons as *"`#393939`, 138 px, r 13.5
… **cap 37 Medium `#FFFFFF`**"*. The cited source says 37, not 32. Two of the
three rows (S-02, O4) are cap 32; the third is not, so "one box used three times"
is one box used twice plus a mis-citation. The field's own cap-32 Regular value
survives — it rests on §4.1 row 12, not on this table — but the argument for it
does not.

**Must say instead:** row 1 reads *"label cap 37 Medium (file 11 S-01; cap 36 per
§0.3's authority)"*, and the conclusion becomes *"one box at two label sizes —
the same [RAISE-4] split the reference itself ships"*.

### MAJOR-4 · F5's `tnum` row instructs the build to do what the same paragraph forbids

> *"**Recommendation.** Add one row to the acceptance band: *if the face carries a
> `tnum` set, it is enabled in the numeric field and its value column and nowhere
> else.*"* … *"**Do not** substitute lining figures locally: two figure sets in
> one product is a visible break the reference does not contain."*

The document states the trap two sentences earlier — *"most faces pair `tnum`
with lining figures"* — and then writes the band row without it. On a face where
`tnum` is the lining tabular set (the normal case), enabling `tnum` in the
numeric field **is** substituting lining figures locally, and ADR-0010's band
makes old-style-by-default *"non-negotiable"*.

**Must say instead:** *"if the face carries an **old-style tabular** set
(`onum` + `tnum` together), it is enabled in the numeric field and its value
column and nowhere else; a lining `tnum` set is not a substitute and must not be
enabled."*

### MAJOR-5 · F7's recommended resolution needs a container the corpus does not have

> *"\| (a) The multi-select is a **separate step** — a `Bulk apply` CTA opens a
> plug list with checks, then one field \| One extra step; uses the platform
> sheet already adopted for `⋯` \|"*

The mechanism adopted by 11 S-03 and 12 [RAISE-OA-15] is *"the platform's own
action sheet"* — a list of **actions**. It cannot host a multi-select list with
trailing checks plus a numeric field. As written, option (a) invents a modal form
surface, which ticket 31 forbids (*"Navigation vocabulary is fixed and this pass
may not extend it"*).

**Must say instead:** *"`Bulk apply` **pushes a full-screen surface** (`←`) —
measured navigation vocabulary, one screen added — carrying the plug rows with
the trailing check and one numeric field."* Then F7's cost is "one extra screen",
not "one extra step", and it stops depending on [RAISE-OA-15].

### MAJOR-7 · F1 declares "Cost: None" for a redirect that contradicts the ratified spec

F1's cost column: *"None. Removes a contradiction and introduces no value."*
`SPEC.md` §12, under *Still owed by the design record*: *"**No text or numeric
input exists**, and `packages/ui` must build one **from the feature-chip
surface** for O5a and every admin form."* File 11 [RAISE-D21] recommends the same
surface; file 12 [RAISE-OA-4] *"consumes that decision and does not make a second
one"*. The redirect is right — §2.1's height argument is the best passage in the
file — but three documents carry the sentence it invalidates and the document
names none of them for amendment.

**Must say instead:** cost = *"three edits: `SPEC.md` §12, file 11 [RAISE-D21]'s
recommendation, and file 12 [RAISE-OA-4]'s consumption clause. Until they land,
a build reading SPEC ships a 35 pt tap target."*

### MAJOR-8 · A product-wide motion rule is invented in a form-controls pass and never raised as one

> §7.3: *"That gives the rule §8 also needs: **the product authors no motion; it
> may follow motion the platform authors.**"*

File 11 §9.4 states *"Motion: **none, anywhere**"* and 10-v2 §12 lists motion
among what could not be measured. The new rule governs every surface in both
apps, not just a keyboard translation. F13 raises the keyboard avoidance; the
*rule* is adopted in prose.

**Must say instead:** raise the rule itself, once, as a founder call, with the
caret and the keyboard as its two instances and file 11 §9.4 named as the
sentence it amends.

### Copy and the one-home rule — clean

The document authors no availability copy, restates no forbidden list, and a grep
for `unreported` · `no recent report` · `not reported` · `real-time` · `in use` ·
`0 of` returns **nothing**. §1.5's refusal of the date control (12 §8 rule 4) and
of the toast (11 S-02) are correctly cited. One gap: it never cites
`docs/availability-display.md` at all, while §6.1 reproduces the five closed
type-words — see MINOR-9.

---

## 5. OFFLINE AND HONESTY

Sound, with one omission already counted (MINOR-8). Nothing renders a normal
offline state as an error: §1.5 keeps the toast refused, O8's queue row stays a
readout, §9.1's unpreventable set (`geo` unset, empty `markerLabel`, a non-vector
icon, a duplicate invite, a server rejection, a revoked membership) contains no
offline case, and no queued write is presented as a failure or a failure as a
success. ADR-0007 is not breached anywhere in the file.

---

## 6. DAYLIGHT

Flagged by the document, correctly: §7.4's focus cost (*"a 2 px blinking bar —
thin, and under [RAISE-OA-1]'s equatorial sunlight possibly invisible"*), §4.5's
dependence on an ExtraLight body line ([RAISE-2]), §7.3's selected-text contrast
marked [?] until a device check.

**Missed — counted under FATAL-2:** the field box itself. Its entire boundary is
`#393939` on `#121212` = **1.62 : 1**, a value the document computes in §7.3 and
never applies here, and §2.3 removes the border. ADR-0009 §4 rules dark-only *as
a cost*, with the mitigation already spent (Regular for data lines). A new
control whose only signal is a 1.62 : 1 surface step is exactly the impossibility
ADR-0009 says must be raised rather than absorbed.

No other state in the file is signalled by a grey-on-grey value difference: the
trailing check is 15.52 : 1 accent, the value type is 11.55 : 1 white, the
absent-when-off rule needs no contrast at all.

---

## 7. SCOPE CREEP

No tab bar, nav bar, toolbar, popover or persistent chrome is proposed. §1.5's
seven refusals are argued from named screens and the date-control refusal
(*"**A date control anywhere in the product is a defect**"*) is a better outcome
than a design. §2.6 refuses the multi-line variant. §10.4 refuses to make the
publish checklist a control. §5 checks O4 rather than redesigning it.

Two exceptions: **MAJOR-5** (the action sheet that must become a pushed screen)
and **MAJOR-8** (the motion rule). Build-effort material is marked as such
(§3.2's keyboard row: *"build note, not a design value"*), and §7.3's React
Native constraint is load-bearing on a design choice rather than smuggled in —
except for MINOR-3.

---

## 8. Minors

1. **§2.3: *"`color.surface` on `color.surface` is **1.08 : 1** [d] — invisible."*** Identical colours are **1.00 : 1**. 1.08 : 1 is `#3E3E3E` on `#393939`, which is §7.3's own second row. The rule that follows is right and stronger than stated.
2. **§0.3 #4 calls a 71 px ink height *"consistent with §7.6's 62–68 px band"***. It is outside it. Under file 11 §0.3's policy a `[m·n]` value that contradicts part 1 must be stated as a contradiction and owed back.
3. **§7.3 specifies a caret width (`size.hairline` 2 px) the API it just cited does not expose.** React Native gives `selectionColor` / `cursorColor` (Android) — no caret width. The value will silently default to the platform's. Mark it `[?]` or drop it.
4. **`[m·15]` #5 and #6 are new measurements the authority does not hold**, and #1 finds **six** feature chips where 10-v2 §1.3/§8.1 count four (verified: six chip boxes, two clipped by the sticky bar and unlabelled). Both are owed back to `10-design-system-v2.md` per file 11 §0.3; neither is registered.
5. **§8's card sum is 341.6 pt, stated as 341.9**, and its `8.3 pt` term is 10-v2 §5.2's *card-top → handle-top* gap used as *handle → content*, where the measured value is **13.0 pt**. The fit conclusion survives at either figure.
6. **§1.2 / §10.5 / §12 disagree on whether O6 has a specifiable control** (see §3 above).
7. **§1.3 drops A9's `source` filter** (see §3 above).
8. **§9 / D-05 offline fork left open** (see §3 above).
9. **The closed vocabulary is used without citing its home.** §6.1 reproduces `Type 2 · CCS2 · GB/T AC · GB/T DC · Other plug`; `docs/availability-display.md` §2.4 owns the projection and §2.2b owns the forbidden list. One citation line, per the one-home rule.
10. **§12's CTA-geometry row assigns `#393939`/`#C7FC2F` to *"O4, S-02, D-03"***. File 11 §12.3: *"S-02 has no selected state (one tap commits), so nothing there is lime"*, and D-03's bay-watch control is `#393939` only. Write *"accent fill on O4 only"*. The same row omits O3's sticky CTA.

---

## 9. What is sound — said once, without praise inflation

§7.1 (the placeholder is unimplementable because the palette has no dimmed tier,
so the answer costs nothing) is the file's best passage and should survive
verbatim. §4.1's trailing check is fully sourced and every value re-measures.
§0.3's authority table is accurate against the verdict on all six rows. [C2]
(accent-as-selected has one instance and no contrast pair, and 11 [RAISE-D22]
says so) and [C4] (a zero-touch CTA is a disabled control, against 11 §12.2) are
real catches, correctly quoted and correctly routed. §4.4's refusal to make one
check carry three semantics, and §1.5's refusal of five controls, are the right
shape of answer. §2.1's height argument kills [RAISE-D21] correctly.

---

## 10. Verdict

**REJECT — 3 fatal, 8 major, 10 minor.**

FATAL-1 and FATAL-3 are corrections to two paragraphs and one table. FATAL-2 is a
raise the file must add and a founder call it must ask for. None of the three
needs new measurement; two of them need the document to believe its own tables.
