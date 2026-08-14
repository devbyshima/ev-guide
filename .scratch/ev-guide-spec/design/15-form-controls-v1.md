# 15 — The form controls (design stream 2, v1)

Ticket 31, design stream 2 of 2. Stream 1 owns **the seven interaction states**
(pressed, disabled, focused, loading/in-flight, error/retry/validation, empty,
destructive confirmation). This file owns **the controls**: what the write
screens require, what `packages/ui` must build, and what the reference cannot
supply.

The premise is file 12 §1, restated because it governs every line below: **the
reference is a read design with one button per screen.** It contains no field,
no switch, no checkbox, no radio, no stepper, no picker, no slider, no date
control, no search field, no reorder handle and no multi-select. Every control
below is therefore assembled from measured surfaces or marked invented. There is
no third category, and silent invention is the defect this pass exists to catch
— the two rounds before it caught exactly that three times.

---

## 0. How to read this file

### 0.1 Scope, and the seam with stream 1

| This file decides | Stream 1 decides |
| --- | --- |
| Which controls exist, and which are refused | Whether a pressed state exists, and what it looks like |
| Each control's box, fill, radius, type treatment, insets | Whether a focus ring exists product-wide |
| Where a control's value, label and unit sit | The disabled, loading, empty and confirmation treatments |
| Caret, selection, placeholder, keyboard avoidance, validation position | Error *appearance*; this file fixes error *position* only where a control forces it |

Three places the seam is load-bearing, named so neither stream assumes the
other closed them:

1. **A field with no focus treatment is a field the user cannot find.** §7.4
   recommends caret-only focus and states the cost; whether a focus ring exists
   at all is stream 1's.
2. **A disabled field and a read-only value slot must not render identically.**
   §2.5 and §4.5 both hit this; the resolution is stream 1's to supply.
3. **O4's Save CTA at zero touches** is specified by file 12 §4.4 rule 4 as
   `color.surface` — a disabled treatment already chosen. §5.2 checks it.

### 0.2 Marking legend

- **[m]** measured from `refs/01.png`–`04.png` by file 10-v2, cited by token or
  section.
- **[m·15]** measured from the PNGs **by this file**. Every one is listed in
  §0.3 with its method; there are no undeclared measurements below.
- **[d]** derived by stated arithmetic from [m] values.
- **[?]** cannot be measured; the reason is given.
- **[INVENTED]** no measured source. Every one appears in §11 with a
  recommendation and a cost.

**One clarification the "no third category" rule needs, stated once.** A
*component* with no measured precedent is marked **[INVENTED]** even when every
*value* inside it cites a token. The caret is the clean case: its width is
`size.hairline` [m] and its colour is `color.accent` [m], and the caret itself
still does not exist anywhere in the reference. The raise then records what was
invented — **the object, not the number** — which is the honest statement and a
stricter one than either extreme. Where a table row is [INVENTED] but built
wholly of tokens, the tokens are named in the same row.

### 0.3 Measurement authority, convention, and this file's own measurements

**`10-design-system-v2.md` is the measurement authority**, corrected by
`13-design-verdict-v2.md`. This file uses the corrected values without
re-arguing them:

| Value | Used here | Source |
| --- | --- | --- |
| `radius.button` | **13 px = 4.3 pt** | 10-v2 §10.4; verdict MAJOR-4 (files 11/12's 13.5 px / 4.5 pt are void) |
| `radius.floatingCard` | **14 px = 4.7 pt**, all four corners | 10-v2 §6; verdict FATAL-2 |
| CTA label cap | **36 px** | 10-v2 §4.1 row 5; verdict MAJOR-4 |
| Circular buttons | **⌀80 / 90 / 98 px** | 10-v2 §7.2; verdict MAJOR-4 |
| `size.pin` | **122 × 147 px** | verdict MINOR-2 (file 11 wins) |
| Category chip padding | **86 / 30 px** | verdict FATAL-2 (file 11 wins) |

**Convention (verdict MINOR-8).** Every dimension below is a **core**
measurement — the run of the exact colour, anti-alias columns excluded. Where a
figure differs from a document quoting an AA-inclusive number, the difference is
1 px and is not a disagreement.

**This file's own measurements**, all re-derived from the PNGs:

| # | What | Measured [m·15] | Method | Against file 10 |
| --- | --- | --- | --- | --- |
| 1 | Feature-chip widths, `04` | **270 / 316 / 387 / 652 / 397 / 371 px** — six distinct widths on one screen (rows at y2056–2160, y2187–2291, y2318–2336 clipped) | `#393939` run-length scan at y2065 / y2196 / y2330, i.e. inside the corner arc | §7.5 gives 271 / 316 / 387 / 652 — agreement within 1 px, and two more instances found |
| 2 | Chip gaps | horizontal **27 px** (x334→x362), vertical **26 px** (y2161→y2186) | same scan | confirms `space.chipGap` 27, `space.chipRowGap` 26 |
| 3 | Settings dividers, `02` | y2188 / y2364 / y2541, core **x39 → x1166 = 1128 px**, `#3E3E3E`, 1 px | full-row colour count | confirms §7.6 and verdict MINOR-6 |
| 4 | Settings row 1 icon ink | y2241–2311 (71 px), x45–108 (64 px) | white-ink bbox | consistent with §7.6's 62–68 px band |
| 5 | **Settings row vertical centring** | icon ink centre **y2276.0** against a row centre of **y2276.5** — centred within 0.5 px | (divider + divider)/2 vs ink bbox centre | new; §7.6 said "optically centred" without a figure |
| 6 | **The settings row's empty trailing region** | label ink ends x535 (row 1) / **x598** (row 2); divider ends x1166 → **568 px = 189.3 pt of empty row** | white-ink bbox per band | new; this is the region [RAISE-D14] and the trailing check both claim |

Measurement 6 is the one the rest of this file leans on: it is the only
uncommitted horizontal space in the settings-row family, and **three
propositions want it** — the value slot ([RAISE-D14]), the trailing check
([RAISE-D17]) and the in-row edit field ([RAISE-D21] as consumed by D-05).
§4.5 and §2.5 settle the collisions.

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
| **S-03** | — | **connector picker** when >1 type — *named twice in the corpus, specified nowhere* (§6.3) |

### 1.2 Operator app

| Screen | Writes | Control required |
| --- | --- | --- |
| O1 | auth; the email path | **text field** ×1 (email) + one CTA — inherits S-01 |
| **O4** | `Report` per Connector | **the control row** — three CTA-geometry controls ×N connectors + Save CTA (§5) |
| **O5a** | `ratePerKwhRwf`, `sessionFeeRwf`; plug multi-select | **numeric field** ×2 per connector + **trailing check** + CTA |
| O5b | rate flag | **no entity exists** ([RAISE-OA-5]) — **no surface may be specified** |
| **O6** | invite by email; revoke | **text field** ×1 (email) + CTA + destructive confirmation |
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
| A9 | `Report`, `source = admin` | station/connector selects + the three [vocab] labels |
| A10 / A11 | — | tables; A10's entity does not exist |

### 1.4 The control set that falls out

Seven, and no more:

1. **Text field** — D-05, S-01/O1, O6, and every admin text bound.
2. **Numeric field** — O5a, A4. A specialisation of (1), not a separate box.
3. **The trailing check** — D-08, D-09, O5a.
4. **The CTA-geometry control** — already specified (file 11 §12.3, file 12
   §4.3). Checked here (§5), not redesigned.
5. **Select / picker** — the OCPI enum (A4), the Owner set (A3), roles (A6),
   filters (A2) — **all admin-native**; plus the one native-app case, the
   connector picker (§6.3).
6. **File upload** — `Owner.icon`, `Photo`, D-05's photo — **platform picker or
   native web**, never a `packages/ui` component.
7. **Ordered grid with reorder** — A7 only, **admin-native**.

### 1.5 The controls no screen needs — not designed, and why

| Control | Verdict |
| --- | --- |
| **Search field** | **Not required.** A2 filters over bounded sets; the driver app has none by ruling (file 11 §8, *deliberately not screens*). The brief's likely-set names "admin search"; **no named screen requires it**. If the station list ever outgrows its filters that is a new decision, not a control this pass may add. |
| **Date / time control** | **Forbidden, not merely unneeded.** `capturedAt` is stamped at tap (file 12 §4.4 rule 3) and authoring it is prohibited by name (§8 rule 4); `rateConfirmedAt`, `armedAt` and `updatedAt` are system-set. **A date control anywhere in the product is a defect**, and that is a cheaper test than a design. |
| **Stepper** | Not required. The brief names "bay counts": **there is no bay-count field.** Bays are rows created and deleted in A4; `3 bays · 5 plugs` is derived. `powerKw` / `voltage` are free numerics with no natural increment. |
| **Slider** | Nothing in the model is a continuous bounded range. |
| **Segmented control** | O4's control row is three CTA-geometry buttons in a row, not a segmented control — it has no shared track, no shared border, and its members are individually addressable. Naming it a segmented control would import a component the reference does not contain. |
| **Radio group** | See §4.4 — the honest finding is that single-select does not occur in `packages/ui`. |
| **Toast / snackbar** | Refused by file 11 S-02 by name. Confirmation is the write's own effect. |
| **Progress bar / spinner** | Refused by [RAISE-D16]; text percentage only. |
| **Multi-line text field** | **Conditional.** The only multi-line authored field in the model is `Station.description`, which is unratified and contested — file 11 [RAISE-D12] recommends adding it, file 12 [RAISE-OA-3] declines and re-tenants the region (verdict MAJOR-2). **Not designed here.** If ticket 19 accepts it, §2.6 states the one thing that would have to be settled. |

---

## 2. The field box

### 2.1 Testing [RAISE-D21]'s proposal properly

[RAISE-D21] recommends building the text input from the **feature-chip
surface**: `#393939`, radius 10 px, height 105 px, cap-32 value. Tested clause
by clause rather than adopted:

| Chip property | Measured | Survives into a field? |
| --- | --- | --- |
| Fill `color.surface` `#393939` | [m] §7.5 | **Yes.** It is the reference's container for a labelled object on `#121212`, and the fill of every tappable thing in the system. |
| Radius `radius.chip` 10 px = 3.3 pt | [m] §6 | **Conditionally** — see the box collision below. |
| **Height 105 px = 35.0 pt** | [m] `size.chipHeight` | **No.** See below. |
| Left padding 30 px = 10 pt | [m] `space.chipPaddingH` | **Yes**, as the field's text inset. |
| **Content-sized width** | [m·15] — six widths on one screen: 270 / 316 / 387 / 652 / 397 / 371 px | **No.** A field's content is unknown at layout time and changes per keystroke; a content-sized field resizes while you type. Field width comes from its slot. |
| Label cap 32 **ExtraLight** `#FFFFFF` | [m] §4.1 row 13 | **No.** A 2.1 px stem on a value the user must proof-read is [RAISE-2] at its worst, and ADR-0009's one permitted mitigation is already *Regular instead of ExtraLight for data lines*. |
| Icon slot, 43 × 48 px at 4.2 px stroke | [m] §7.5 | **Not required.** No named field carries a leading icon. |
| Caret · selection colour · placeholder · focused appearance | **absent** [m] | **Nothing to inherit.** §7 designs these from elsewhere or invents them. |

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

The corpus already derived the box this problem needs, twice, for the same
reason, and did not notice it also answers [RAISE-D21]:

| Surface | Box | Source |
| --- | --- | --- |
| S-01's two secondary provider buttons | `#393939`, **138 px**, radius 13 px, label cap 32 | file 11 S-01 |
| S-02's three report controls | `#393939`, **138 px**, radius 13 px, label cap 32 Medium | file 11 §12.3 |
| O4's three unselected controls | `#393939`, `size.ctaHeight`, `radius.button`, cap 32 Medium | file 12 §4.3 |

That is one box, used three times: **`color.surface` fill + `size.ctaHeight`
138 px + `radius.button` 13 px + a cap-32 label.** It is the system's
*interactive `#393939` object at 46 pt*. Every value in it is a measured token.

**Recommendation: redirect [RAISE-D21] from the feature chip to this box.** The
chip contributes the fill and the text inset — both of which this box already
shares — and contributes nothing else a field can use. The redirect costs
nothing and removes the §12.3 contradiction outright.

### 2.3 The field box, specified

| Property | Value | Provenance |
| --- | --- | --- |
| Fill | `color.surface` `#393939` | [m] |
| Height | `size.ctaHeight` **138 px = 46.0 pt** | [m] |
| Radius | `radius.button` **13 px = 4.3 pt** | [m], verdict MAJOR-4 |
| Border · shadow · blur | **none** | [m] §9 — no product surface has one |
| Width | the container's content box (§2.4) | [d] |
| Text inset, left and right | `space.chipPaddingH` **30 px = 10 pt** | [m] |
| Value type | **cap 32 Regular `#FFFFFF`** — the settings-row label's own measured treatment (§4.1 row 12), 11.55 : 1 on the fill | [m] |
| Value alignment | **left** for text; **right** for numeric (§3.3) | [d] |
| Cap-box top offset | **(138 − 32) / 2 = 53 px = 17.7 pt** | [d] |
| Descender clearance | 53 px below the baseline against a descender of 0.28–0.33 × cap ≈ 9–11 px | [d] from §3.5 |
| Caret | §7.3 | [INVENTED] |
| Selection | §7.3 | [INVENTED] |
| Placeholder | **none exists** — §7.1 | [m], refused |
| Focused appearance | §7.4 | stream 1 |

**The derived cap-box offset reproduces the reference.** The primary CTA's
label is measured "optically centred, 50 px above cap, 51 px below baseline" in
a 138 px box at cap 36 [m §7.1]. Arithmetic centring predicts
(138 − 36) / 2 = **51** on both sides. The measurement and the arithmetic agree
within 1 px, so the system's "optical" centring **is** cap-box centring, and
§2.3's 53 px is a derivation rather than a guess.

**One placement constraint.** `color.surface` on `color.surface` is **1.08 : 1**
[d] — invisible. **A field may never be placed on a `#393939` container.** No
named screen does; the rule exists so no later one does.

### 2.4 Capacity, measured

| Placement | Box width | Inner width | Characters at cap 32 Regular, k = 0.73 |
| --- | --- | --- | --- |
| **S-01 / O1 card inner box** | **950 px** [d, RAISE-D31] | 890 px | **38** |
| **D-05 in-row** (§2.5) | 539 px [d] | 479 px | **20** |
| O5a numeric value | numerics are 1–5 characters; never width-bound | — | — |
| Admin | web layout — not this file's | — | — |

**The in-row derivation.** The row's trailing free region is x599 → x1166
[m·15 #6]. With the longest measured label ink ending at x598 and a 30 px gap
(`space.chipPaddingH` — the only measured horizontal padding on a control), the
field runs x628 → x1166 = **539 px**, inner 479 px, **20 characters**.

### 2.5 The consequence: an email does not fit in a settings row

Twenty characters at the mandated constant. `shima@example.com` is 17 and fits;
most real addresses do not. **The corpus already concedes this without noticing
it** — file 11 D-06 writes the email row's value as `shima@…`, truncated, in
the very slot D-05 would edit in.

Three readings, with costs:

| Option | Cost |
| --- | --- |
| (a) **`Email` on D-05 is a readout, not a field.** D-05's only editable row is `Name`; the account email is an authentication identity shown on D-06, and changing it is an auth operation, not a profile edit | Requires saying so; D-05 and D-06 both currently list `Email`, which is a corpus overlap this file did not create |
| (b) Label above, field at the container's full content width | **The reference never stacks a label above anything.** [INVENTED] — a second field variant with no measured precedent |
| (c) The row pushes to its own full-screen surface (`←`) | Uses only measured navigation vocabulary and invents nothing, but contradicts D-05's own word, *"in place"*, and adds one screen per field |

**Recommendation: (a).** It is the only option that neither invents a variant
nor adds a screen, and it is consistent with D-06 already owning provider
identity.

**A second-order finding falls out.** `User.name` has **no length bound** in
domain-model — amendment 7 bounds `Station.name`, `nameShort`, `Owner.shortName`
and `markerLabel`, and nothing else. So the one field D-05 keeps is unbounded
and its only editing surface holds 20 characters. Owed to ticket 19:
**`User.name` needs a bound, or D-05 needs option (b).** [RAISE-F3]

### 2.6 The multi-line variant, if ticket 19 ever accepts `Station.description`

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
| `ratePerKwhRwf` | O5a, A4 | integer | ≥ 0 |
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

### 3.3 Old-style figures against a right-aligned numeric field — the real cost

ADR-0010 makes old-style figures **non-negotiable**. Two measured consequences
that a right-aligned numeric field and a column of amounts both hit:

**(a) The figures are proportional, not tabular — measured.** File 10 §4.1
row 7: in `135 000 RWF` at cap 36, the `1` is **29 px** and the `0` is **31 px**
[m]. A 2 px per-digit difference at cap 36 is a proportional set. So:

- A right-aligned amount **shifts horizontally as its digits change**, even at
  constant length: `600` and `111` right-aligned differ at their left edge by
  ≈6 px = 2 pt [d].
- A **column** of right-aligned rates — O5a's per-connector rows, A4's editor —
  does not form a digit column. Old-style figures were designed to sit in
  running prose, and a numeric column is the one place they do not work.

**(b) The digits descend.** `3` and `5` descend 7 px at cap 36; `4` descends
5 px at cap 27; `5` descends 9 px at cap 47 [m §3.2]. Any box sized to the cap
height alone **clips** — and `345 RWF/kWh` is the string that demonstrates it.
§2.3's box does not clip (53 px of clearance against ≈10 px of descender), but a
value slot sized tightly would.

**The collision.** ADR-0010's acceptance band has **no row for a tabular set**,
and `onum` + `tnum` together are rare — most faces pair `tnum` with lining
figures, which the band forbids as the default. So the product may be unable to
have both.

**Recommendation.** Add one row to the acceptance band: *if the face carries a
`tnum` set, it is enabled in the numeric field and its value column and nowhere
else.* If no candidate carries both, **accept the jitter** — the columns are
1–5 rows long and the amounts are read individually, not summed. **Do not**
substitute lining figures locally: two figure sets in one product is a visible
break the reference does not contain. [RAISE-F5]

**Cost either way:** a band row that a free face may fail, or a numeric column
that does not align. Both are cheap; neither is invisible.

### 3.4 The unit suffix

`RWF/kWh`, `kW`, `V` must be visible and must not be editable — a unit inside
the editable string is a unit the user deletes.

**Composed from the reference's own price treatment** [m §4.1 rows 7/15, file
11 §1 substitution 3]: *amount Bold + slash-unit Regular*. In a field the amount
is cap 32 Regular (§2.3) and the unit is a **static suffix at the same cap
height, Regular `#FFFFFF`**, right of the value, inside the field's 30 px
trailing inset.

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

### 4.2 Multi-select — D-09, O5a

D-09 renders five rows (the closed type-word projection) and marks each
selection. This is the check's native semantic: an independent per-row flag.
**Honest.**

**O5a collides, and the corpus does not notice.** File 12 §10.1 gives O5a
*"`§5.6` rows, value right-aligned `type.label` Bold"* **and** *"plug
multi-select"*. Both claim the row's trailing region [m·15 #6], and there is no
measured gap for a value and a check to share it. Two readings:

| Reading | Cost |
| --- | --- |
| (a) The multi-select is a **separate step** — a `Bulk apply` CTA opens a plug list with checks, then one field | One extra step; uses the platform sheet already adopted for `⋯` |
| (b) Check and value coexist in one row, check outboard of the value | **[INVENTED]** — the gap between them has no measured source, and the row would then carry a label, a value, a check and an editable field: four trailing behaviours |

**Recommendation: (a).** [RAISE-F7]

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
| A3 `owner_id`, A4 `type`, A6 role, A2 filters | single-select, but **admin-native web** — a `<select>` has the semantic built in and draws no check (§10) |
| O5a plug multi-select, D-09 | multi |
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
| Radius | `radius.button` **4.5 pt** | **4.3 pt** — 10-v2 §10.4 is the token authority (verdict MAJOR-4). A restatement, not a change |
| Fill, unselected | `color.surface` + `color.text` | ✓ — and identical to §2.3's field box |
| Fill, selected | `color.accent` + `color.onAccent`, Medium | ✓ |
| Gap | `space.chipGap` 9 pt = 27 px | ✓ |
| Width, three-up | (1078 − 54) / 3 = **341.3 px** | ✓ |
| Label | cap 32 Medium | ✓ — see [C1] |

**Consistent with everything else here:** O4's unselected control and §2.3's
field box are the same box. One `#393939` interactive object at 46 pt, three
uses. No contradiction.

### 5.2 Four contradictions found

**[C1] The arithmetic that forces the label size does not reproduce.** §4.3
rejects the primary CTA's own label size with:

> *At the primary CTA's own cap-37 Medium (≈28 px/char), `Out of service` is
> 392 px and does not fit.*

**28.8 px/char is file 12 §0.2 row 1** — the measured advance of `135 000
RWF/day`, a **cap-36 Bold digit-heavy price**. The primary CTA's own **Medium**
label measures **21.25 px/char** (`Let's find a car`, 16 chars, 340 px, file 11
§0.3 row 6). At the correct measured advance:

| Constant | `Out of service`, 14 chars | In 341.3 px | Verdict |
| --- | --- | --- | --- |
| **≈28 px/char** — §0.2 row 1's cap-36 **Bold** price advance (28.8), rounded (what §4.3 used) | 392 px | overflows by 51 px | rejects |
| **21.25 px/char — cap-37 Medium, measured** | **297.5 px** | 21.9 px each side | **fits** |
| k = 0.65 at cap 37 — §0.4's pessimistic Medium | 336.7 px | 2.3 px each side | rejects, by 4.6 px total |
| k = 0.65 at cap 32 — what shipped | 291.2 px | 25.1 px each side | fits ✓ |

The **conclusion survives** under §0.4's mandated pessimistic constant, which is
the policy. The **stated reason does not**: it applies a Bold price advance to a
Medium letter-only label and overstates the width by 32%. §0.2 promises
*"arithmetic over a measured advance, never an eyeball"* and its own caveat
warns that digit-heavy and letter-heavy strings of equal length do not measure
equal — which is precisely the substitution made.

This is the corpus's most-cited piece of control arithmetic and every other
control leans on it. **Recommendation: restate §4.3 at the Medium constant and
re-declare the composition as a choice** (a 46 pt control with a cap-32 label
has real optical breathing room) **rather than an arithmetic necessity** — and
record that the margin is 4.6 px, not 51 px, for whoever revisits it. Carried
in the raise list as **[RAISE-F17]**.

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
about to ask the accent to carry a sixth meaning and the budget should be
spent knowingly.

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
| **The open OCPI 2.3.0 enum** | `IEC_62196_T2`, `IEC_62196_T2_COMBO`, `GBT_AC`, `GBT_DC` (tier 1), every other RURA Art. 3(c) family, plus `OTHER` and `UNKNOWN` | **A4's select writes this** |
| **The closed display projection** | `Type 2` · `CCS2` · `GB/T AC` · `GB/T DC` · `Other plug` — five words | D-09's rows, chips, O4's labels |

**The admin's select must be over the enum, not the projection.** Its option
labels are therefore **not** the closed vocabulary. A select offering the five
projection words would collapse every non-tier-1 family into `Other plug` and
make them **unauthorable** — the admin could never record what is actually
installed. Worth a test: the projection is a read-side function and must not
appear as an option list.

### 6.2 `OTHER` / `UNKNOWN`

Both persist as enum members and both render `Other plug` [vocab]. O4 states it
already: a connector of that type is **still writable** (file 12 §4.5). Nothing
special is needed on any control.

**One consequence, routed not settled:** a driver whose car takes a family that
projects to `Other plug` selects a **bucket** on D-09, and the lens then treats
their plug as interchangeable with every other unmapped family. That is a
modelling consequence of the projection, not a control decision — routed to
ticket 18 alongside [RAISE-D32]'s bare `GB/T`.

### 6.3 The connector picker — named twice, specified nowhere

Verdict MINOR-5, restated because it is a control and therefore mine: file 11
§8.0 and §12.1 both send `Report availability` through *"a connector picker
first when the station carries more than one type"*, and the picker has **no row
in the entry-point table, no component and no raise.** It is the one dead end in
an otherwise exhaustive navigation map, and it is the only single-select in the
native apps (§4.4).

**Recommendation: the platform action sheet**, per §4.4. **Cost:** a fourth
screen depends on [RAISE-OA-15]. [RAISE-F8]

---

## 7. Label, placeholder, caret, selection, focus

### 7.1 The placeholder is not a preference — it is unimplementable

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

### 7.2 Label

Composed with [RAISE-D14]'s value slot, which this file **consumes** rather than
re-decides: label left at cap 32 Regular `#FFFFFF` (§4.1 row 12), the field
occupying the trailing region [m·15 #6]. On S-01 / O1 and in the admin the label
sits above its own block as a `type.heading` sub-head — the reference's own
`Description` / `Basics and features` composition [m §5.2].

**Dependency named:** if [RAISE-D14] is refused, D-05, D-06, D-07, D-10, D-12,
O5a, O7 and O8 all lose their value slot and this file's in-row field placement
goes with it. §2.5 option (c) is then the fallback.

### 7.3 Caret and selection are **one value** on iOS — this decides it

The platform constraint comes first because it removes the choice:

> React Native's `TextInput` exposes **`selectionColor`** on both platforms; on
> iOS it maps to `tintColor`, which drives the **caret, the selection highlight
> and the selection handles together**. Android can separate `cursorColor` from
> `selectionColor` (API 29+). Designing two colours ships two different
> appearances across two platforms.

So: **one value**, and it must work as a 2 px caret *and* as a fill behind text.

| Candidate | As a caret | As a selection fill | Verdict |
| --- | --- | --- | --- |
| `color.text` `#FFFFFF` | 11.55 : 1 on the field [m] ✓ | **white behind `#FFFFFF` text** — unreadable | **disqualified by the platform constraint** |
| `color.surfaceRaised` `#3E3E3E` | — | **1.08 : 1** on the field [d] — invisible | disqualified |
| `color.bg` `#121212` | — | 1.62 : 1 [d] — visible but inverts the convention | weak |
| **`color.accent` `#C7FC2F`** | **9.57 : 1** on the field [m] ✓ | see below | **the only candidate** |

**The accent as a selection fill, honestly.** Drawn opaque with `#FFFFFF` text
it is **1.21 : 1** — the hero-badge failure, in a field where the user is
proof-reading what they typed, and there is **no API to restyle selected-text
colour** in a `TextInput`. What saves it is that the platform draws the
highlight **translucent**, not opaque: at 20–30% over `#393939` the white text
holds **6.74 : 1 to 5.13 : 1** [d]. That alpha is the platform's value, not this
design's, and the rendered result is **[?] until measured on device**.

**Recommendation: `selectionColor = color.accent #C7FC2F`, caret width
`size.hairline` 2 px = 0.67 pt.** Both values are measured tokens; the object is
[INVENTED].

**Costs, stated plainly:**

- The accent takes a **sixth meaning** (after primary action, selected, yours,
  presence, link) — see [C3]. Mitigated by the fact that a selection is
  transient and modal, and no accent-as-selected control is on screen inside a
  field.
- **The legibility of selected text is the platform's, not ours**, and the 1.21
  : 1 opaque case is what would render if any platform ever drew it opaque. A
  device check belongs in the build's acceptance pass. [RAISE-F12]
- **The caret blinks, and the reference contains no motion anywhere** [m §9,
  file 11 §9.4 *"Motion: none, anywhere"*]. This is worth naming rather than
  absorbing: the caret is **the first moving object in the product**, and it
  moves because the OS moves it.

That gives the rule §8 also needs: **the product authors no motion; it may
follow motion the platform authors.**

### 7.4 Focus

**Recommendation: the caret is the focus indicator, and nothing else.** No ring,
no border, no fill change.

Grounds: the system has no border token except the category chip's 2.5 px lime
[m] and the pin's 2 px outline [m]; a 2 px accent ring on a focused field would
reuse measured values for an invented role **and** would render a field
indistinguishable from a category chip. The keyboard's own appearance is itself
a strong focus signal on a phone.

**Cost:** on a screen with two fields (O5a: rate and session fee) the only focus
indicator is a 2 px blinking bar — thin, and under [RAISE-OA-1]'s equatorial
sunlight possibly invisible. **Whether a focus ring exists product-wide is
stream 1's**; this file states what it recommends and what it costs.

---

## 8. Keyboard avoidance for the floating card

**First, a correction to the framing.** The 64 px figure is
`space.floatingCardBottomGap` — the gap between the `03` card's bottom and the
CTA's top [m §7.4]. The card's own bottom sits **305 px = 101.7 pt** above the
screen bottom on `03`, and for S-01 / S-02 (nothing below them) [RAISE-D34]
rules **103 px = 34.3 pt**. That is the number keyboard avoidance works against.

**Where it bites:** S-01 and O1's email path, and nowhere else. **O4 — the
product's most state-heavy screen — has no field at all**, so the operator app's
core task never meets a keyboard.

**The geometry.** To preserve the card's measured resting gap above whatever is
beneath it, the card's bottom must sit `keyboardHeight + 34.3 pt` above the
screen bottom, i.e. **translate up by exactly the keyboard's height** [d]. The
34.3 pt is measured and merely applied to a new edge; the *translation* is
[INVENTED].

**Does it fit?** Two of the three terms are the OS's, not this design's, and
both are **[?]**: the safe-area top (≈59 pt on iPhone 16 Pro) and the keyboard
height (≈336 pt, iOS portrait English with the predictive bar — **it varies by
locale and by bar, and no layout may hold it as a constant**). Against the
measured 874 pt screen [m §0.1], the card's height must satisfy
`h + 336 + 34.3 ≤ 874 − 59`, i.e. **h ≤ 444.7 pt** [d].

S-01's idle card estimates at **≈342 pt** [d]: 64 (padding) + 4.3 (handle) +
8.3 (handle→content) + 17 (`type.heading`) + 15 (`type.body`) + 13
(`space.blockGap`) + 138 (3 × 46 pt buttons) + 18 (2 × `space.chipGap`) + 64
(padding) = **341.9 pt**. The email variant replaces two provider buttons with
one field and one CTA and is **no taller**. So it fits with ≈103 pt of headroom.
Marked [d] with its unmeasured term named: **S-01's card height is composed,
never measured** [?] — the reference has no stacked-button card.

**Three options, with costs:**

| Option | Cost |
| --- | --- |
| **(a) Translate the card up by the keyboard's height, preserving 34.3 pt** | Introduces the product's **first authored layout motion**. Recommended below with the mitigation |
| (b) Resize the card | Rejected — the height is content-derived; shrinking clips the buttons |
| (c) Push the email path to its own full-screen surface | Invents nothing and uses measured navigation vocabulary, but **breaks S-01's contract**: it *"overlays the screen the driver is on and never navigates"* (file 11 §10), and the driver would lose their station — the exact failure S-01 exists to prevent |

**Recommendation: (a), following the keyboard's own curve and duration**, which
both platforms publish with the frame change. Under §7.3's rule — *the product
authors no motion; it may follow motion the platform authors* — the translation
is the keyboard's motion, not an authored animation. Jumping instantly is the
alternative and reads as a glitch. [RAISE-F13]

**A second consequence, and it is a real ambiguity.** With the keyboard up,
S-01's *"tap outside the card → dismiss"* (file 11 S-01) collides with the
universal gesture for dismissing a keyboard: **one gesture, two dismissals.**
Verdict MAJOR-7 already raised that the modal-card-with-no-scrim archetype is
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
*available* — on the same terms as [RAISE-OA-13]'s muted tier: it breaks token
kinship with `packages/ui`, so it is a founder call, not a default. Naming it
here so the two questions are decided together rather than six months apart.
[RAISE-F15]

---

## 10. The admin's harder controls — what is native-web and out of `packages/ui`

File 12 §7: the admin takes file 10 §10.1–§10.4 (**tokens only**) and **no React
Native components**, and the 1:1 rule does not govern it.

### 10.1 Out of `packages/ui` entirely

`<input type="text">` · `<textarea>` · `<input type="number">` · `<select>`
(Owner, connector type, role, every A2/A9 filter) · the checkbox on a filter
facet · every table · A7's ordered photo grid and its drag-to-reorder ·
`Owner.icon` and `Photo` file upload · A3's MapLibre `geo` picker · A8's
checklist · A10's audit table.

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

### 10.5 A6's invite form writes into an entity that does not exist

`Membership` is `(userId, stationId, role)` unique, and an invitee has **no
`userId` until they accept** ([RAISE-OA-6]). A form whose target entity does not
exist **cannot be specified** — its fields, its validation and its pending state
all depend on a shape ticket 19 has not chosen. Raised, not designed. Same for
O6, which is the same write from the operator app.

---

## 11. Raised

Sixteen. **Derived** = assembled from measured surfaces by stated arithmetic.
**Invented** = no measured source for the object. **Found** = a contradiction in
the existing corpus.

| # | What | Class | Recommendation | Cost |
| --- | --- | --- | --- | --- |
| **F1** | **[RAISE-D21] points at the wrong surface.** The feature chip is 35 pt and file 11 §12.3 rules chip geometry out for controls product-wide | **Found** | Redirect to the existing secondary-control box: `color.surface` + `size.ctaHeight` 138 px + `radius.button` 13 px + `space.chipPaddingH` 30 px, value cap 32 Regular | None. Removes a contradiction and introduces no value |
| **F2** | **A field is not content-sized**; the chip is [m·15 — six widths on one screen] | Derived | Field width = the container's content box | The "built from the feature chip" description survives only for the *fill* and the *inset* |
| **F3** | **`User.name` has no bound and its only editing surface holds 20 characters** [d]; an email does not fit at all, and D-06 already truncates it | **Found** | D-05's `Email` becomes a readout; bound `User.name` in ticket 19, or accept the invented label-above variant | A schema addition, or one invented field variant |
| **F4** | The reference has **no numeric field**; money and power fields are specialisations of F1's box | Derived | Integer-only for RWF, space group separator [m], grouping applied on display only | Editing and display strings differ in width |
| **F5** | **Old-style figures are proportional** — `1` 29 px vs `0` 31 px at cap 36 [m] — so a right-aligned numeric column does not align, and ADR-0010's band has no `tnum` row | **Found** | Add one band row: `tnum` in the numeric field and its value column only, if the face carries it; otherwise accept the jitter | A band row a free face may fail, or a column that does not align. Never two figure sets in one product |
| **F6** | The **unit suffix inside a field** has no precedent — the reference composes amount + unit in a read slot only | Invented (object; all values are tokens) | Static suffix, same cap height, Regular, inside the trailing 30 px inset | One composition to document |
| **F7** | **O5a's row is over-claimed**: file 12 gives it a right-aligned value *and* a plug multi-select, and both want the same 568 px [m·15] | **Found** | Bulk apply becomes a separate step behind the platform sheet | One extra step |
| **F8** | **The connector picker is named twice and specified nowhere** (verdict MINOR-5) — and it is the only single-select in `packages/ui` | **Found** | Platform action sheet, as S-03 and O3's `⋯` already are | A fourth screen depends on [RAISE-OA-15]'s open branch |
| **F9** | **Off and non-interactive render identically** — the check is additive and settings rows have no trailing affordance [m] | Derived | Accept; the refusal copy carries the distinction, per §12.2's rule | Depends on the user reading one ExtraLight body line ([RAISE-2]) |
| **F10** | **"Accent means selected" is presented as the reference's own** on the strength of one category chip with nothing to contrast it against; file 11 [RAISE-D22] says the opposite | **Found** | Mark it [INVENTED] in file 12 §4.3 and inherit [RAISE-D22] | None — the design is right, only the provenance claim moves |
| **F11** | **O4's zero-touch Save is a disabled control**, which file 11 §12.2 rules against by name | **Found** | Route to stream 1; cheapest fit is the §12.2 body line until the first touch | Stream 1 must rule; the fix is additive |
| **F12** | **Caret and selection are one value on iOS**; white is disqualified (white behind white text) and only the accent is legible on `#393939` | Invented (object) | `selectionColor = color.accent`, caret at `size.hairline` 2 px | The accent takes a sixth meaning; selected-text contrast is the platform's alpha and is **[?] until a device check** |
| **F13** | **Keyboard avoidance is the product's first layout motion**, in a reference with none anywhere | Invented (object); the 34.3 pt gap is [m] | Translate by the keyboard's height, following the OS's own curve — *the product authors no motion; it may follow the platform's* | S-01's card height is composed, not measured [?]; the fit has ≈100 pt headroom on the stated estimate |
| **F14** | With the keyboard up, **tap-outside means two things** (verdict MAJOR-7's second consequence) | **Found** | First tap dismisses the keyboard, second the card | A driver leaving taps twice |
| **F15** | **Field-level validation has no measured home**, and the palette has no error colour | Invented (position) | Prevent at the keystroke (hard stop); one named-field `type.body` line at submit. The admin's error-colour escape hatch is a founder call, decided with [RAISE-OA-13] | Prose that names a field is worse than an inline marker on a long admin form |
| **F16** | **A5's pin preview needs the pin in a web-renderable form**, and the admin takes no RN components | **Found** | Author the pin once as a shared SVG both consume | A `packages/ui` packaging decision nobody has made |
| **F17** | **[C1] — file 12 §4.3's control-row arithmetic applies a cap-36 Bold *price* advance to a cap-37 Medium *letter* label**, overstating it by 32%. The conclusion survives on §0.4's pessimistic constant; the stated reason does not. This is the corpus's most-cited control arithmetic and every control in this file leans on it | **Found** | Restate §4.3 at the Medium constant and re-declare cap 32 as a **choice**, not an arithmetic necessity; record that the margin is 4.6 px, not 51 px | None to the design. The cost of *not* fixing it is that the next control derived from this precedent inherits a constant that does not apply to it |

**Refused rather than raised** — a placeholder (§7.1: unimplementable inside the
measured palette, because it would need the `text.secondary` token §10.1
deliberately omits); a radio glyph (§4.4: the semantic does not occur, and a
check cannot honestly carry it); a date control (§1.5: prohibited by file 12 §8
rule 4); a per-field error mark (§9.2).

---

## 12. The control inventory

| Control | Screens | Box | Provenance | Open |
| --- | --- | --- | --- | --- |
| **Text field** | D-05, S-01, O1, O6 | `#393939` · 138 px · r13 · 30 px inset · cap 32 Regular | **[d]** from `color.surface`, `size.ctaHeight`, `radius.button`, `space.chipPaddingH`, §4.1 row 12 | F1 · F3 · F12 · F13 · F15 |
| **Numeric field** | O5a, A4 | as above, value right-aligned, static unit suffix | **[d]** + **[INVENTED]** suffix placement | F4 · F5 · F6 |
| **Trailing check** | D-08, D-09, O5a | `#C7FC2F` · 72 px ink · 6 px stroke · row-centred · right of the content box | **[m]** throughout — `color.accent`, `size.iconGrid`, `size.iconStroke`, [m·15 #5] | F7 · F9 |
| **CTA-geometry control** | O4, S-02, D-03 | `#393939`/`#C7FC2F` · 138 px · r13 · cap 32 Medium | **[m]** — specified by file 12 §4.3, checked here | C1 · F10 · F11 |
| **Select / picker (native)** | S-03 / §12.1 only | platform action sheet | adopted from [RAISE-D13] / [RAISE-OA-15] | F8 |
| **Select (admin)** | A2, A3, A4, A6, A9 | native `<select>` over the **enum**, not the projection | out of `packages/ui` | §6.1 |
| **File upload** | D-05, A5, A7 | platform picker / native web | out of `packages/ui` | — |
| **Ordered grid + reorder** | A7 | native web | out of `packages/ui` | — |
| Caret · selection | every field | `size.hairline` 2 px · `color.accent` | **[INVENTED]** object, measured values | F12 |
| Placeholder | — | **does not exist** | refused, §7.1 | — |
| Date · stepper · slider · search · segmented · radio · toast · progress | — | **not designed** | §1.5 | — |

---

## 13. What this file does not decide

The seven interaction states (stream 1) · [RAISE-D14]'s value slot, which this
file **consumes** and whose refusal would take §2.5's placement with it ·
[RAISE-D17]'s ruling, adopted unchanged · O4's control row, checked but not
redesigned · the typeface, which blocks every capacity figure here from becoming
a guarantee ([RAISE-1], ADR-0010) · `Station.description` and therefore the
multi-line variant (ticket 19, and verdict MAJOR-2 first) · the `Invitation`,
`RateFlag` and audit entities, without which O5b, O6 and A6 cannot be specified
at all · the admin's own layout, which is a web problem file 10 does not solve ·
and every founder call in §11, which is the point of raising them.
