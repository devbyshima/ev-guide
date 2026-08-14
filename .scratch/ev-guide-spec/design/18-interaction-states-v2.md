# 18 — The seven interaction states (v2)

Ticket 31, **design stream 1 of 2**. Revises `14-interaction-states-v1.md`, which
`16-interaction-states-verdict-v1.md` **rejected** — 3 fatal, 15 major, 16 minor
(the verdict's own header says 15 minor; it lists 16). Every finding is answered
in **§16**, fixed, rejected with the source that disproves it, or accepted and
raised. Stream 2 is the form controls; where a control's *appearance* is stream
2's, this file specifies only what its states do and says so.

> ## Authority and citation notes — read first
>
> **1. `10-design-system-v2.md` is the single measurement authority**, cited by
> **v2 section numbers** (§1 colour · §4 type · §5 spacing · §6 radii · §7
> components · §8 icons · §9 elevation · §10 tokens · §12 raises). Files 11 and
> 12 cite file 10 by v1 numbers behind a translation table; this file does not
> propagate that. `10 §7.6` means file 10-v2's §7.6, always. **Where 11 or 12
> disagrees with 10-v2, 10-v2 wins** — their own authority notes say so, and §0.4
> records every disagreement this file walked into.
>
> **2. The forbidden-string list is cited, never restated, never sampled.** Its
> one home is `docs/availability-display.md` **§2.2b**. §9.4 tests every string
> this file proposes against it by citation. **Three documents currently claim to
> be that one home** and their three lists are not the same length — named and
> routed in §0.4 and [RAISE-S-28], without reproducing any entry from any of them.
>
> **3. Dark-only ships** ([ADR-0009](../../../docs/adr/0009-reference-fidelity-deviations-and-costs.md)
> §4). No light theme, no contrast mode, no brightness override. Two knowing
> deviations exist (the wordmark, the puck) and neither is a licence for a third.
>
> **4. No typeface family is named, and every pt size carries ±3 %**
> ([ADR-0010](../../../docs/adr/0010-typeface-acceptance-band.md)). The cap
> heights are exact. Where this file specifies type it leads with the **cap
> height** and gives the pt step second, because ADR-0010's consequence is that
> no layout may depend on the pt figure where the cap figure exists.
>
> **5. The navigation vocabulary is fixed and this pass does not extend it.**
> Full-screen surfaces reached by a push (`←`) or a presentation (`×`), plus one
> floating avatar. §12.3 enumerates the OS-drawn surfaces the product already
> depends on — there are **five**, not the three v1 claimed — and this pass adds
> none.

---

## 0. Method, and what the reference can and cannot say

### 0.1 Marking legend

- **[m]** — measured, with the file-10 section that measured it. This file
  measures nothing itself; it has no `[m·18]` class and no undeclared numbers.
- **[d]** — derived from [m] values by arithmetic **stated in place**. A value
  with no arithmetic is not [d], whatever its provenance.
- **[?]** — the reference cannot say. The reason is given.
- **[INVENTED]** — a value or a **relationship** with no measured source. Every
  one has an entry in §13 with a recommendation and a cost, **and a row in §14's
  register**, which exists so the count can never drift again. There is no fifth
  category.

### 0.2 What four stills of a read design can supply

The premise, restated from 12 §1 because it is the whole reason this ticket
exists: **the reference contains no interaction state of any kind.** No pressed,
disabled, focused, loading, in-flight, error, retry, validation, empty or
destructive-confirmation state appears in `refs/01.png`–`04.png`. File 10 §12
records this under *Could not be measured*, and adds the sharpest version of it:

> *"The record's 'accent shade `#9EC52B`' is anti-aliasing on pin outlines,
> **not** a pressed state; there is no evidence of a second accent value
> anywhere."*

| Available | Not available |
| --- | --- |
| Every **resting** appearance — a chip's fill, a row's pitch, a CTA's radius, a divider's colour, the accent's single value | Any **changed** appearance of the same element |
| The **set of channels** the system uses to distinguish things at rest (§1) | Which of those channels the system would spend on a state |
| **Two precedents for absence** — the no-membership hosting card (11 §6.3) and O9's no-action screen (12 §3/O9) | Any precedent for a de-emphasised-but-present control |
| **One measured placeholder** — the `02` profile avatar, `#3E3E3E` fill inside a `#C7FC2F` ≈3 px ring (10 §7.9) | Any placeholder without an accent mark on it — see §7.2 |
| One measured grey, `#717171`, on one glyph | Its meaning — 10 [RAISE-11]: the same glyph is `#FFFFFF` on `04` in the same presumed state |

**On `#717171`, stated precisely rather than absolutely.** v1 wrote *"`#717171`
is used nowhere in this document as a disabled, inactive or muted token"* and
then booked it in §10's table as one half of a surviving state channel. Both
halves cannot stand. The precise statement:

> **This file assigns `#717171` no meaning.** Where it appears — the `03` card
> heart's resting colour, 10 §8.1 row 17, `color.iconMuted` — it is the
> reference's own measured value, open under 10 [RAISE-11] (*"either the card's
> heart is deliberately de-emphasised … or it is drift"*) and carried by 11
> [RAISE-D11] as a **recommendation inside a raise**, which the standing rule
> says is not a resolution. This file closes neither, and §12.2's prohibition
> carves the card heart out **by name** so the prohibition and the reproduction
> stop contradicting each other. [RAISE-S-30]

### 0.3 The one rule, applied

Every value below either names a token from 10 §10 or a measurement from
10 §1–§9, or carries **[INVENTED]** with a §13 entry and a §14 register row.
Contrast ratios are **[d]** by WCAG 2.x relative luminance over the measured
hexes; **all sixteen of v1's §1.3 ratios were independently recomputed for this
revision and all sixteen hold to ±0.01**, so §1.3's table is carried unchanged.
What did not hold was the sentence underneath it — §1.3.

### 0.4 Corrections owed to files 11 and 12 — and the sweep is not three items

File 11 was written **before `10-design-system-v2.md` existed** and says so
(11 §18); file 12 says the same (12 §0). v1 found three stale geometries, called
the sweep done, and then re-shipped one of them twelve lines later. The sweep is
not done, and **this revision withdraws any count**: what follows is what this
file walked into while re-deriving every number it cites, not an inventory.

**Two different defects are mixed together in the record, and separating them is
the useful part.**

**(a) Stale values — superseded by 10-v2, wrong to ship.**

| # | Says | **10-v2 measures** | Lives in |
| --- | --- | --- | --- |
| 1 | Hero **1076 × 620 px** | **1078 × 612 px**, verified at five columns and two rows (10 §7.7; v2's change log withdraws the old figure by name) | 11 D-03, 11 §17 |
| 2 | CTA radius **13.5 px** | **13 px = 4.3 pt**, `radius.button` (10 §6, §10.4) | 11 §1 sub-5, 11 S-01, 11 §12.2, 11 §12.3, 11 [RAISE-D20] |
| 3 | `radius.button` **4.5 pt** | **4.3 pt = 13 px** — the same defect as (2) in the other file, expressed in pt | 12 §3/O1, 12 §4.3, 12 §7 |
| 4 | Floating card radius **16 px** | **14 px = 4.7 pt, all four corners**, `radius.floatingCard` (10 §6, §7.4, §10.4) | 11 §0.3 row 2, 11 D-02, 11 S-01, 11 S-02, 11 §17 (twice) |
| 5 | Overflow `⋯` **⌀100 px / 33.3 pt** · close `×` **⌀81 px / 27 pt** · back `←` **30.3 pt** | **98 px = 32.7 pt** · **80 px = 26.7 pt** · **90 px = 30.0 pt** (10 §7.2, §10.5) | 11 D-03 diagram, 11 §17; 12 §3.0 and every O5–O8 row |
| 6 | Active page indicator **96 × 16 px** | **95 × 16 px** (10 §7.7) | 11 [RAISE-D16] |
| 7 | Category chip **25.7 pt** tall | **25.3 pt = 76 px** (10 §7.5) | 12 §4.3, quoted forward into 11 §12.3 |

**(b) Edge conventions — not stale, and more dangerous, because the numbers are
both correct and they change arithmetic.** Files 11 and 12 measure several
elements **AA-inclusive**; 10-v2 measures the **core** and names the AA
row/column it excluded. Neither is wrong. The authority rule settles which one a
build types, and 10-v2 wins.

| Element | 11/12 (AA-inclusive) | **10-v2 (core)** | What it changes |
| --- | --- | --- | --- |
| Floating card frame | x64→1141, y1796→2317 = **1078 × 522 px** (11 §0.3 row 2) | **x65→1140, y1797→2317 = 1076 × 521 px**, `size.floatingCard` (10 §7.4, §10.5) | the card's inner box, below |
| Card inner box | **950 px** (11 [RAISE-D31], and v1 of this file re-shipped it in §9.1) | **948 px = 316.0 pt** — `size.floatingCard`.w 1076 − 2 × `space.floatingCardPadding` 64 **[d]** (10 §7.4, §10.3, §10.5) | S-01's and S-02's stacked button width, §10.1 |
| Map below the card | **65 px** (11 §0.3 row 2, D-02) | **64 px = `space.floatingCardBottomGap`** — rows 2318–2381, *"exactly 64 rows"* (10 §5.2, §7.4, §10.3) | nothing here; recorded so the pair is complete |
| Handle offset | **26 px** below the card top (11 D-02, S-01) | **25 px = 8.3 pt** (10 §5.2, §7.4) | nothing here |
| Primary CTA | **897 px** of lime core (11 §0.3 row 5, which *declares* the 899 figure as AA-inclusive) | **899 × 138 px**, x64→962 (10 §7.1) | **nothing — this one is not a defect.** The verdict lumped it with the stale values; 11 §0.3 reconciles it in place |
| Hosting card | **1130 × 335 px**, tile **257 × 257 px** (11 §6, 12 §5.1) | **1128 × 334 px**, tile **256 × 257 px** (10 §7.10) | **12 §5.1's M9 reconciliation.** Its load-bearing arithmetic is *"39 + 257 + 39 = 335 exactly [m], so the content box is the tile's own height."* On 10-v2's core numbers that is 335 against a **334** px card — **off by one**, and the conclusion it carries (the body slot holds at most 3 lines) rests on it |

**Consequence for this file.** §7.4's O2 placeholder uses **1128 × 334 px**
(10 §7.10), not 12 §5.1's 1130 × 335. §10.1's confirmation-card buttons are
**948 px**, not 950. Nothing else below changes, and all of it would have shipped
as wrong pixels.

**(c) One collision that is not a geometry.** Three documents each assert
exclusive ownership of the forbidden-string list, at three different addresses:
`docs/availability-display.md` §2.2b (*"the one and only home … No other document
may hold a copy"*), 10 §0.3 R3 (*"the forbidden list lives in §11.2 of this file
and nowhere else"*), and 11 §13.1 (*"Canonical location: `docs/availability-display.md`
§2.2, law 8"*), with 12 §0.1 naming a fourth address (file 11 §13). The authority
notes at the head of 11 and 12 already point at §2.2b; **their bodies were never
updated, and 10 — the measurement authority — was never corrected at all.**
Counting rows without reproducing one: §2.2b holds **seven**, 10 §11.2 holds
**six**, 11 §13.1 holds **four**, and no two are the same set in either
direction. The ticket points at §2.2b and this file cites §2.2b; the other three
must become citations. **[RAISE-S-28]** — a correction owed, exactly like (a).

**All corrections owed: [RAISE-S-23].** The recommendation is no longer "fix
three at the source" but "re-derive every number in 11 and 12 against 10-v2, and
declare an edge convention in 10 §0.1 so (b) cannot recur."

---

## 1. The palette's expressive capacity — the interesting part of the problem

### 1.1 Every channel the measured system affords

| Channel | Values | Source |
| --- | --- | --- |
| **Surface swap** | `color.bg` `#121212` · `color.map` `#212121` · `color.surface` `#393939` · `color.surfaceRaised` `#3E3E3E` | 10 §10.1 [m] |
| **The accent** | `color.accent` `#C7FC2F` — **exactly one value, no tints, no gradients**, verified across four screens | 10 §1.1, §10.1 [m] |
| **On-accent label** | `color.onAccent` `#121212` | 10 §10.1 [m] |
| **Weight** | four classes — ExtraLight ≈200 · Regular ≈400 · Medium ≈500 · Bold ≈700 | 10 §4.5 [m] |
| **Size** | five steps — cap 55 / 47 / 36–37 / 32 / 27–28 px, i.e. 26 / 22 / 17 / 15 / 13 pt ±3 % | 10 §4.2 [m]; ADR-0010 |
| **Geometry** | **eight** radii (10 §10.4) and **eighteen** component-size rows — fifteen distinct components if the four `size.circleButton.*` collapse to one (10 §10.5) — plus presence and absence | 10 §10.4, §10.5 [m] |
| **The one hairline** | 2 px = 0.67 pt — link underline, pin outline, crosshair rule | 10 §4.4 [m] |
| **The one divider** | `color.divider` `#3E3E3E`, **exactly 1 px = 0.33 pt**, container-width, no inset | 10 §7.6 [m] |
| **Underline** | `type.link` — accent, 0.67 pt, 1 pt below baseline, `skipInk: false` | 10 §4.4, §10.2 [m] |
| **Additive marks** | status dot ⌀20–21 px `#C7FC2F` with a `#FFFFFF` ≈4 px ring | 10 §7.9 [m] |
| **The accent ring** | `size.accentRing` 3 px = 1.0 pt, `#C7FC2F` — the profile avatar's, and **the only reason the reference's one placeholder is visible** (§7.2) | 10 §7.9, §10.5 [m] |
| **The trailing check** | one `#C7FC2F` check at the 24 pt icon grid / 2 pt stroke | 11 [RAISE-D17], ruled |
| **Absence** | the element is not drawn | 11 §6.3, 12 §3/O9 — **used twice by the product already** |

### 1.2 Every channel the measured system does not have

Each is *deliberately* absent, and each is what a conventional state design
reaches for first.

| Absent | Cited |
| --- | --- |
| **Any opacity ramp** | 10 §10.1 — "Deliberately absent: any `text.secondary`, `text.muted`, **opacity ramp**, elevation colour, or accent tint" |
| **Any elevation, shadow, blur, border or scrim** | 10 §9 — every component re-scanned for v2; "**No halo, no ramp, no border**" |
| **Any accent tint or second accent value** | 10 §1.1, §12 |
| **Any secondary text colour** | 10 §1.3 — "the product chrome has one text colour" |
| **Any error colour** | 11 §9.4 — "There is no error colour in the token set and adding one would be a deviation" |
| **Any motion, transition or gesture behaviour** | 10 §12 — "four stills" |
| **Any progress component** | 11 [RAISE-D16] — no bar, no ring, no spinner |
| **Any light theme** | ADR-0009 §4 |

### 1.3 The arithmetic that governs every decision below — [d]

WCAG 2.x relative luminance over the hexes in 10 §1.1. Recomputed independently
for this revision; where 10 §1.2 publishes a pair, its figure is used and the
agreement is noted rather than substituted.

| Pair | Ratio | Published by 10 §1.2? |
| --- | --- | --- |
| `#FFFFFF` on `#121212` | **18.73 : 1** | yes |
| `#FFFFFF` on `#212121` | **16.10 : 1** | no — [d] |
| `#C7FC2F` on `#121212` | **15.52 : 1** | yes |
| `#C7FC2F` on `#212121` | **13.34 : 1** | no — [d] |
| `#FFFFFF` on `#393939` | **11.55 : 1** | yes |
| `#FFFFFF` on `#3E3E3E` | **10.69 : 1** | no — [d] |
| `#C7FC2F` on `#393939` | **9.57 : 1** | yes (this file computes 9.566; theirs is used) |
| `#C7FC2F` on `#3E3E3E` | **8.86 : 1** | no — [d] |
| `#C7FC2F` on `#717171` | **4.04 : 1** | no — [d] |
| `#717171` on `#121212` | **3.84 : 1** | yes |
| `#717171` on `#393939` | **2.37 : 1** | no — [d] |
| **`#3E3E3E` on `#121212`** | **1.75 : 1** | yes |
| **`#393939` on `#121212`** | **1.62 : 1** | no — [d] |
| `#3E3E3E` on `#212121` | **1.51 : 1** | no — [d] |
| `#3E3E3E` on `#262626` | **1.41 : 1** | no — [d] |
| `#393939` on `#212121` | **1.39 : 1** | no — [d] |
| `#393939` on `#262626` | **1.31 : 1** | no — [d] |
| `#262626` on `#121212` | **1.24 : 1** | yes |
| `#212121` on `#121212` | **1.16 : 1** | no — [d] |
| **`#3E3E3E` on `#393939`** | **1.08 : 1** | no — [d] |

**The finding that decides this document, corrected. [d]**

v1's blockquote said *"the four surface greys span 1.75 : 1 end to end"* and then
*"the largest available swap — page to surface — is 1.62 : 1"* in the next
sentence. Those cannot both be true, and the table settles it: the end-to-end
span and the largest swap are **the same pair**, because `color.bg` and
`color.surfaceRaised` are the extremes of the set.

> **The four product surfaces are `#121212`, `#212121`, `#393939`, `#3E3E3E`.**
> The **largest swap between any two of them is `color.bg` → `color.surfaceRaised`
> = 1.75 : 1.** Page → surface is **1.62 : 1**. The swap a designer reaches for
> on a control — surface → raised — is **1.08 : 1**, below the level at which a
> display's own gamma variation is reliable.
>
> **None of the three reaches WCAG 1.4.11's 3 : 1** for identifying a
> user-interface component or its state. That is the whole of what the argument
> needs; the *maximum* matters only because v1 justified its one sub-threshold
> recommendation by calling 1.62 the maximum when it is not (§6.3).

Two consequences, and everything in §4–§10 follows from them:

1. **State cannot be carried by a surface swap.** Not because it is ugly, but
   because it is arithmetically sub-threshold and therefore, in the condition
   ADR-0009 §4 names — *"standing at a charger in equatorial daylight"* — it is
   not there at all.
2. **The accent is the only channel that survives.** `#C7FC2F` against either
   dark surface is 8.86–15.52 : 1. It is already spent on *selected*
   (12 §4.3), on *yours* (the saved heart, the status dot), and on *the primary
   action*. A state design may add to that load or it may use copy. There is no
   third robust channel.

**A precision, so this is not read as a claim that the reference is broken.**
The reference's own controls also fail 1.4.11 as *boundaries* — a `#393939`
circular button on `#121212` is 1.62 : 1. What makes them legible is their
**content**: `#FFFFFF` glyphs and labels at 11.55 : 1, which is 1.4.3's
territory and passes comfortably. The reference is a read design and reads fine.
It is the *state* channel specifically that has nothing in it, and that is a fact
about what four stills contain, not a defect in what they show.

---

## 2. The three kinds of state, separated once — definitions corrected

The inventory tables in 11 §17 and 12 §10.1/10.2 mix three different things under
one column head. Separating them is what makes the coverage matrix honest,
because two of the three are not this pass's to design.

| Kind | Definition | Rendered by | Owned by |
| --- | --- | --- | --- |
| **C — content** | The screen's data binding has a different value **and files 11 or 12 already specify the rendering.** Availability regimes, Grammar R's rate cases, membership / no-membership, provider connected / not, draft / published, single-bay, `OTHER` plug. | The screen's own slots | files 11 and 12, already |
| **N — connectivity** | ADR-0007's normal mode. Offline, queued. **Never an error.** | The offline chip (11 §9.1) and the queue count (12 §4.7) | ADR-0007 + file 11, already; extended in §8.1 |
| **I — interaction** | The surface's condition changed because of, or pending, **a human action or a request in flight** — *or* it is a zero-row binding whose **rendering** this pass specifies. | **This file** | this file |

**Two corrections to v1's marks, both from the definitions above.**

- **An uncached photo is I, everywhere.** v1 marked it **I** on D-02 and D-03 and
  **N** on D-11 for the identical condition. A fetch in flight is a request in
  flight; it is I. D-11's row splits into two: *offline* is N, *uncached
  thumbnail* is I.
- **O9 is I by rendering, C by origin, and the definition now says so.** A
  zero-membership binding is content; the *empty state* is one of the seven this
  ticket commissions. Marking it C would have hidden it from the matrix; marking
  it I without a definition that permits it was v1's inconsistency. The
  definition above carries the case explicitly, and the same reading covers
  D-11's, D-12's, O6's, A2's and A7's empty states.

**Nothing in kind C or N is redesigned here.** Where §3 marks a state C or N,
this file's claim is only that it is covered *somewhere* and names where.

---

## 3. Coverage — every state named by every screen

This section enumerates the state columns of **11 §17** and **12 §10.1/10.2**
verbatim, including states this file does not define. Four of those exist and are
declared in §3.3.

**Two of the seven appear in no row of either inventory**, and that is not a
hole: **pressed** and **focused** are conditions of *controls*, not of screens,
so no screen names them. §4 and §6 are therefore global sections that apply to
every interactive element in both tables, and §4.3 enumerates the controls
individually rather than the screens.

### 3.1 Driver app — 11 §17

| Screen | State as named | Kind | Rendered by | § |
| --- | --- | --- | --- | --- |
| **D-01** | default | C | data | — |
| | offline | N | offline chip, 11 §9.1 | §8.1 |
| | no-permission | C | puck absent, locate still requests | — |
| | signed-out | C | avatar's measured empty state | — |
| | *(no loading, no empty, no error)* | — | bundled snapshot, ADR-0007 | §7.4 |
| **D-02** | Regime 1 / 2 / 3 / lensed / no-compatible-plug | C | availability-display §2 | — |
| | route-in-flight | **I** | **the chip is absent**, 11 §7.3 | §7.3 |
| | route-failed | **I** | straight-line form, 11 §7.3 | §8.2 |
| | offline | N | chip + straight-line form | §8.1 |
| | signed-out | C | heart opens S-01 | — |
| | saved | C | heart fills accent, 11 [RAISE-D11] | §11 |
| | uncached-photo | **I** | **`Placeholder`**, 11 §9.4 row 1 | §7.2 |
| **D-03** | all availability regimes | C | the availability block | — |
| | Grammar R's five rate cases + session fee | C | 11 §13.3 | — |
| | offline | N | offline chip | §8.1 |
| | signed-out | C | heart / bay-alert open S-01 | — |
| | not-at-station | **I** | **inert rows + `StateLine`**, 11 §12.1 | §5.4 |
| | uncached-hero | **I** | **`Placeholder`** at **1078 × 612 px** (10 §7.7, not 11's stale 1076 × 620 — §0.4a) | §7.2 |
| **D-04** | signed-in / signed-out | C | data | — |
| | membership / no-membership | C | **the card is absent**, 11 §6.3 | §5.2 |
| | app-installed / not / undeterminable | C | card copy, 11 §6.2 | — |
| | offline | N | offline chip | §8.1 |
| **D-05** | signed-in only | C | unreachable otherwise | — |
| | offline | N | values from cache | §8.1 |
| | error-in-place | **I** | **`StateLine`**, 11 §9.4 | §8.3 |
| **D-06** | providers connected / not | C | value slot, 11 [RAISE-D14] | — |
| | sign-out | — | an action | — |
| | **delete-account confirm** | **I** | **§10 — the platform confirmation, already in use here** | §10 |
| | offline | N | refusal line, 11 D-06 | §5.4 |
| **D-07** | not-downloaded · downloaded · update | C | value slot | — |
| | **downloading** | **I** | **text percentage in the value slot**, 11 [RAISE-D16] | §7.3 |
| | offline (not downloaded) | N | `needs a connection` in the value slot, row inert | §5.4 |
| | **failed** | **I** | **value-slot `StateLine`; the row is the retry** | §8.3 |
| | synced / not-synced | C | value slot | — |
| | *(directory sync in flight — named by no inventory, found by §4.3)* | **I** | **no string exists** — [RAISE-S-29] | §4.3 |
| **D-08** | granted | C | the row toggles | — |
| | denied | **I** | **inert row + `StateLine`**, 11 D-08 | §5.4 |
| | signed-out | **I** | **inert row + `StateLine`** | §5.4 |
| **D-09** | none-selected (default) / selected | C | the trailing check, 11 [RAISE-D17] | — |
| | signed-in (syncs) / signed-out (local) | C | `StateLine` | §8.3 |
| **D-10** | static | — | — | — |
| **D-11** | populated | C | cards | — |
| | **empty** | **I** | **heading + one `StateLine`**, 11 §9.4 | §9 |
| | offline | N | cached | §8.1 |
| | **uncached thumbnail** | **I** | `Placeholder` — split from the offline row, §2 | §7.2 |
| **D-12** | armed | C | rows | — |
| | **empty** | **I** | heading + **two `StateLine`s**, §9.1 | §9 |
| | at-ceiling | **I** | **`StateLine` in the control's slot**, 11 §12.2 | §5.4 |
| | offline | N | a disarm queues | §8.1 |
| **S-01** | idle | — | as drawn | — |
| | **in-flight** | **I** | **buttons inert, nothing else changes** | §7.3 |
| | success (auto-resume) | — | the card dismisses; the action fires | §7.5 |
| | **cancelled** | **I** | **nothing is rendered, deliberately** | §7.5 |
| | **failed** | **I** | **`StateLine`; the buttons are the retry** | §8.3 |
| | offline | N | `StateLine` + buttons inert | §5.4 |
| | email path | C | body becomes a field + a `StateLine` | §7.3 |
| **S-02** | signed-out | C | S-01 opens instead | — |
| | not-at-station | C | the card does not open | — |
| | offline (queues) | **N** | **queued is success**, 11 S-02 | §8.1 |
| | **expired** | **I** | **nothing is shown, "because nothing is true"** | §9.3 |
| **S-03** | — | — | platform action sheet | §10.2 |

### 3.2 Operator app and admin — 12 §10.1 / §10.2

| Screen | State as named | Kind | Rendered by | § |
| --- | --- | --- | --- | --- |
| **O1** | idle | — | as drawn | — |
| | in-flight · failed | **I** | as S-01 | §7.3, §8.3 |
| | resuming a hand-off | C | `pendingIntents[]` | — |
| **O2** | loaded | C | rows | — |
| | **loading** | **I** | **§7.4 — the hole, and its recommendation** | §7.4 |
| | no memberships → O9 | C | **but see §7.4's sequencing rule** | §7.4, §9.2 |
| | offline indicator | N | offline chip | §8.1 |
| | queued writes (n) | **N** | **queued is success** | §8.1 |
| **O3** | loaded | C | slots | — |
| | offline (photos absent) | N + I | `Placeholder` at the hero's exact geometry | §7.2 |
| | Regime 1 drawn first | C | availability block | — |
| | unpublished (admin-only case) | C | data | — |
| **O4** | idle (nothing touched) | **I** | **inert Save, §5.3** | §5.3 |
| | touched (n) | C | accent fill on the tapped control, 12 §4.3 | — |
| | **saving** | **I** | **§7.6 — recommended deleted; correction owed to file 12, operator app only** | §7.6 |
| | saved | **I** | **the screen re-derives; that is the confirmation** | §7.6 |
| | queued offline (n) | **N** | count in the sticky bar's left slot | §8.1 |
| | **server-rejected** | **I** | **§8.4 — the hole, and its recommendation** | §8.4 |
| | single bay / plug | C | availability-display law 6 | — |
| | `OTHER` plug | C | `Other plug` projection | — |
| **O5a** | idle | — | as drawn | — |
| | **editing** | **I** | **§6.3 — the focused row** | §6.3 |
| | saving · saved | **I** | as O4 — §7.6 | §7.6 |
| | *(Save at zero edits — named by no inventory, found by §5.4)* | **I** | **§5.3 — `Save` / `Save N updates`** | §5.3 |
| **O5b** | idle | — | as drawn | — |
| | **submitted** | **I** | **§3.3 — unbuildable; no entity, 12 [RAISE-OA-5]** | §3.3 |
| **O6** | list | C | rows | — |
| | **empty** | **I** | heading + `StateLine`; **the screen's own CTA is not removed**, §9.1 | §9.2 |
| | **inviting** | **I** | **§3.3 — blocked on 12 [RAISE-OA-6]** | §3.3 |
| | **revoke confirm** | **I** | **§10 — the platform confirmation** | §10 |
| **O7** | loaded | C | rows | — |
| | **metric unavailable** | **I** | **`StateLine` in the row's own window line, not an empty state** | §9.5 |
| **O8** | loaded · offline | C / N | rows / chip | §8.1 |
| | queued-writes row (non-interactive) | **N** | a readout; **queued is success** | §8.1 |
| **O9** | single state, not an error | **I** | **the one card-shaped empty state** | §9.2 |
| **A1** | idle · failed | **I** | as S-01 | §7.3, §8.3 |
| | authenticated-but-refused (`isStaff` false) | **I** | **`StateLine`; authorisation, not authentication** | §8.5 |
| **A2** | loaded · filtered · draft vs published | C | table | — |
| | **empty** | **I** | heading + `StateLine` | §9.2 |
| **A3** | new · editing · saved | **I** | §6.4, **§7.7 — the admin's save is a real round trip** | §7.7 |
| | **invalid (length / NOT NULL)** | **I** | **§8.6 — prevention first, then a naming line** | §8.6 |
| **A4** | ≥1 bay · bay with 1..N connectors | C | nested editor | — |
| | **delete blocked** | **I** | **terminal refusal — but the reason cannot be written until 12 [RAISE-OA-14]** | §5.4, §13 |
| **A5** | new · editing | **I** | §6.4, §7.7 | §7.7 |
| | **CHECK violation · non-vector icon rejected** | **I** | **§8.6** | §8.6 |
| **A6** | active · revoked | C | table | — |
| | **pending** | C | **blocked on 12 [RAISE-OA-6]** | §3.3 |
| **A7** | 0 photos (blocks publish) | **I** | empty + the A8 checklist names it; **the upload control is not removed**, §9.1 | §9.2 |
| | ≥1 | C | grid | — |
| | **reordering** | **I** | **§3.3 — an eighth state; not designed here** | §3.3 |
| **A8** | draft (unmet items named) | **I** | **the checklist *is* the terminal refusal** | §5.4 |
| | publishable · published · unpublished | C | data | — |
| | **unpublish confirm** | **I** | **§10, with the snapshot caveat in the copy** | §10.4 |
| **A9** | list · filtered · new report | C / I | table / the write form | §8.6 |
| **A10** | — | — | **no entity (12 [RAISE-OA-6])** | §3.3 |
| **A11** | loaded · metric unavailable | C / I | as O7 | §9.5 |

### 3.3 The four states this pass does not define — three rows, declared not hidden

v1's heading said *"the three states"* over four named states. There are **four
states in three rows**, because `inviting` and `pending` are one gap seen from
two screens. In every case the reason is upstream of design:

| Named by | State | Why it is not defined here |
| --- | --- | --- |
| **A7** | `reordering` | Drag-in-progress is an **eighth** interaction state. The reference contains no reorder handle and no drag affordance of any kind (12 §1). It exists on **one admin screen**, the admin is not governed by 1:1 (12 §7), and designing a drag state for the phone apps on the strength of one web screen would put an unmeasured interaction into `packages/ui` that nothing native consumes. **Recommendation: A7 uses whatever the console's own grid ships; declared as an admin-native behaviour, not a token.** [RAISE-S-22] |
| **O5b** | `submitted` | A screen cannot render *submitted* against a store that cannot record it. `Report` is availability-only and there is no `RateFlag` — **12 [RAISE-OA-5]**. Any state design here would be designing the feedback for a write that does not happen. |
| **O6 / A6** | `inviting`, `pending` | `Membership` is `(userId, stationId, role)` and an invitee has no `userId` — **12 [RAISE-OA-6]**. The in-flight and pending appearances are specifiable the moment `Invitation` exists and not before; §7.3's rule applies to them unchanged when it does. |

**A10 (Audit)** names no state and has no entity; noted for completeness.

---

## 4. Pressed — the state the palette has least for, specified anyway

The ticket commissions seven states. v1 specified six and left this one inside a
raise's recommendation, while §11.2 required the platform's own press feedback to
be switched off — which ships **every control in both apps with no touch feedback
of any kind** and no rule saying that was the intent. This section is the rule.

### 4.1 The four channels a press could use, and what each is worth — [d]

Press is not a data change. It has one job — tell the finger the tap landed — and
one budget: whatever §1.1 affords minus whatever §1.2 forbids.

| Channel | Concretely | Ratio | Verdict |
| --- | --- | --- | --- |
| **Surface swap, control** | `color.surface` `#393939` → `color.surfaceRaised` `#3E3E3E` | **1.08 : 1** | the instinctive move; below display gamma variation. Also collides twice — §4.5 |
| **Surface swap, control, maximum** | `#393939` → `color.bg` `#121212` | **1.62 : 1** | the largest available on a control, and it makes the control read as a **hole in the page** for the duration of a touch |
| **Surface swap, row** | `color.bg` `#121212` → `color.surface` `#393939` | **1.62 : 1** | visible indoors; gone outdoors (§11) |
| **Surface swap, row, maximum** | `#121212` → `#3E3E3E` | **1.75 : 1** | the largest swap in the system (§1.3) — and `#3E3E3E` is simultaneously `color.divider` and this file's `Placeholder` fill. §4.5 |
| **The accent** | any control → `#C7FC2F` | 8.86–15.52 : 1 | **the only channel that survives daylight — and it is forbidden here.** §4.5 |
| **Geometry** | a scale, an inset, a radius change over time | — | **motion.** 10 §12 found none in the reference; 11 §9.4 forbids introducing any |
| **Opacity** | — | — | **an opacity ramp.** 10 §10.1 lists it as deliberately absent |
| **The platform's own** | `activeOpacity` · `android_ripple` | — | **both banned channels wearing a platform's name** — §4.2 |

**The ceiling, stated once: 1.75 : 1 on a row, 1.62 : 1 on a control, and neither
reaches 1.4.11's 3 : 1.** Press is the one of the seven where the palette has
nothing that both uses measured values and is visible.

### 4.2 Why the platform's own is not the answer, though the product delegates elsewhere

React Native ships press feedback by default. `TouchableOpacity` applies
`activeOpacity: 0.2` — **an opacity ramp**, which 10 §10.1 names as deliberately
absent. `Pressable` on Android applies `android_ripple` — **motion**, which 10
§12 found nowhere in the reference. **Doing nothing ships both**, invisibly to a
code review.

The obvious rebuttal is that the product already accepts five OS-drawn surfaces
(§12.3), so why not a sixth. **Because they are not the same category.** An
action sheet, a platform alert, a share sheet, Apple's sign-in button and the
keyboard each **replace** a region of the screen with the platform's own surface,
drawn by the platform, in the platform's language. `activeOpacity` and
`android_ripple` **restyle EV Guide's own components** with two values the design
system names as absent. The exemption in §12.3 is for foreign surfaces, not for
foreign paint on ours, and stretching it would make 10 §10.1's "deliberately
absent" unenforceable by construction.

### 4.3 The rule, and the requirement that pays for it

> **Pressed renders nothing.** `PressableSurface` (§12.1) switches the platform
> default off at every call site and draws no press treatment of its own.
>
> **The feedback for a press is the press's result.** That makes result latency a
> *specification* rather than an engineering detail: **a control whose result is
> not on screen within a frame is not covered by this rule and takes §7.3's
> in-flight rule instead.**

The requirement is only honest if the enumeration is done, so here it is — every
interactive element in §3, and what its press produces.

| Control | Its result | Within a frame? |
| --- | --- | --- |
| O4's `Free` / `Busy` / `Out of service` | the control takes `color.accent`; the derived bay header line re-derives (12 §4.2, §4.3) | **yes** — the write is local (§7.6) |
| O4's `Save` | the screen re-derives; the queue count appears in the sticky bar's left slot (12 §4.7) | yes |
| S-02's three controls | the card dismisses and the connector row re-renders (11 S-02) | yes |
| D-09's rows, D-08's `Bay alerts` | the trailing check appears or goes (11 [RAISE-D17]); D-09 re-lenses every screen | yes |
| D-03's bay-watch control | the label becomes `Watching · until 15:12` (11 §12.2) | yes |
| The heart (D-02, D-03, D-11) | fills accent, or S-01 opens | yes |
| Any settings row that pushes; any O2 card | a full-screen push — **the transition is the feedback** | yes |
| D-02's card, pins, the locate button | the card swaps, the map recentres | yes |
| `Directions` | Google Maps takes the screen | the OS's own transition |
| D-07's `All of Rwanda` | the value slot goes `76 MB` → `42%` (11 [RAISE-D16]) | yes, once the download starts |
| **S-01 / O1 / A1 provider buttons** | the OS's own auth surface appears | **no** — §7.3, and the latency is the OS's |
| **D-07's `Station directory`, sync now** | the value slot's string changes when the delta lands | **no — and no in-flight string exists** |

**Two holes, and only the second is this file's to close.** The provider buttons'
latency belongs to the OS surface they summon; the product cannot improve it and
does not try — 11 S-01's *"the buttons become non-interactive; nothing else
changes"* is adopted, and §7.3 records that non-interactivity is invisible, which
is the cost.

`Station directory` is different: it is EV Guide's own request, in EV Guide's own
value slot, with a measured mechanism already in place for exactly this job —
D-07's download row carries its state as a **value-slot string**. So the in-flight
rendering is a value-slot string, and the string itself does not exist.
**[INVENTED]**, routed to `packages/domain` with 11 [RAISE-D23], **[RAISE-S-29]**.
A percentage is not available: a delta sync on an `updatedAt` cursor has no
denominator.

### 4.4 The three treatments, if the founder wants a visible press

Named with their costs so the call is a choice and not a blank. Each is
**[INVENTED]** as a relationship — both tokens in each pair are measured; nothing
in the reference says a pressed surface becomes any other surface.

| # | Treatment | Ratio | Cost |
| --- | --- | --- | --- |
| **1** | `#393939` controls swap to `#3E3E3E` while pressed | 1.08 : 1 | invisible indoors as well as out; collides with `Placeholder` and `color.divider` (§4.5) |
| **2** | settings rows take a `#393939` full-row fill at `size.settingsRow` 176 px (10 §10.3) | 1.62 : 1 | visible indoors, gone outdoors; **pixel-identical to §6.3's focused row on O5a** (§4.5) |
| **3** | accent controls get **no** press treatment | — | the primary CTA and every selected control in the product are the least-feedback-bearing things in it |

**Recommendation: adopt all three, i.e. treatments 1 and 2 for their components
and 3 as the exclusion.** Cost: press feedback is decorative on rows, absent on
accent controls, and sub-threshold everywhere. The rule in §4.3 is what ships if
the answer is no, and it is a complete specification either way.
**[RAISE-S-1]** (that there is no pressed state) and **[RAISE-S-2]** (that the
swap is invented) carry the call.

### 4.5 The three collisions the treatments create — the reason 3 is an exclusion

1. **Accent-on-press against accent-as-selected, on O4.** 12 §4.3 spends
   `color.accent` on *selected*, and a selected control on O4 means *a report has
   been staged for that connector*. A press that flashed accent would make a
   touched-but-unwritten control indistinguishable from a written one on the one
   screen in the product where that difference is a **false report**. This is not
   a preference and not a raise: **the accent may not carry press, anywhere.**
2. **`#3E3E3E`-on-press against `Placeholder` and `color.divider`.** `#3E3E3E`
   is `color.divider` (10 §7.6, §10.1) and is this file's `Placeholder` fill
   (§7.2). A pressed control painted in the placeholder colour reads as *not yet
   loaded*. Treatment 1 costs that ambiguity for 1.08 : 1 of signal.
3. **Row-press against row-focus, on O5a.** Treatment 2 fills a pressed row
   `#393939`; §6.3 recommends filling the **focused** row `#393939`. On O5a —
   eight identical rate rows — a pressed row and the edited row would be
   pixel-identical, and the transition from *touching* to *editing* would have no
   visual event at all. Whichever of the two the founder keeps, **they cannot
   both be `#393939` on O5a**, and this file does not have a third fill to offer.

### 4.6 The admin

Web, and 1:1 does not govern it (12 §7). The browser and the console shell ship
`:active` and `:hover` by default; both are permitted and neither has a measured
source. **Named so it is a decision rather than a default** — [RAISE-S-12].
§12.2's prohibition on building press treatments applies to `packages/ui`, not to
the console shell.

---

## 5. Disabled — the honest answer is that EV Guide has none

The hardest of the seven after pressed, and the one that deserves the most words,
because in a palette with one text colour, no opacity ramp and a 1.75 : 1 surface
range, a de-emphasised-but-present control has **literally nothing to say with**.

### 5.1 The proof that absence is already the product's grammar

Five places where the product, before this ticket, already answered an impossible
action without greying anything:

| # | Where | What it does | Cited |
| --- | --- | --- | --- |
| 1 | The hosting card, no membership | **absent entirely** — *"a **disabled** card would advertise a door with no handle. Absence is the only honest rendering."* | 11 §6.3 |
| 2 | O9, no memberships | **offers no action, deliberately** — no self-serve path exists, so a button would lie | 12 §3/O9 |
| 3 | The bay-watch slot, action impossible | **the reason replaces the control in place** — ticket 30's own amendment: *"a refusal with a reason in the row's text, never a disappearing control"* | 11 §12.2 |
| 4 | A connector row, not at the station | **non-interactive row plus a line of body copy**, never a hidden control | 11 §12.1 |
| 5 | The publish gate | **the checklist with the unmet items named** — the reason, not a greyed button | 12 §A8 |

And one structural fact that makes all five cheap: **the settings row carries no
trailing affordance at all** (10 §7.6 — *"Chevron / disclosure: none"*). A row
that does nothing is *visually indistinguishable* from a row that does. Removing
a row's interactivity therefore costs nothing visually, which is precisely why
the product can afford to do it five times without anyone noticing a missing
state.

### 5.2 The rule

> **There is no disabled state and no disabled token. Nothing is greyed, ever,
> because there is no grey to grey it with.** An action that cannot be performed
> takes exactly one of three answers, chosen by **who can satisfy the
> precondition and when**:
>
> **(a) Absent — the action has no referent.** Either no path exists for this
> account or role, ever *(hosting card without a membership; O6 and O7 without an
> `owner` edge; O9's action)*, or **the object the verb acts on does not exist**
> *(`Delete downloaded maps` with nothing downloaded)*. In both readings drawing
> the control would name a thing that is not there.
>
> **(b) Terminal refusal — the reason takes the control's place, or joins it.**
> A precondition exists that the human cannot satisfy on this screen.
> **CTA-geometry controls are replaced by the reason. Rows stay and gain the
> reason.** *(bay-watch at the ceiling; a connector row when not at the station;
> `Bay alerts` with permission denied; `All of Rwanda` offline; `Delete account`
> offline; A8's unmet checklist.)*
>
> **(c) Transient inert — the control keeps its appearance and stops accepting
> taps.** The precondition is one the human's very next action *on this screen*
> satisfies, or a flow they have already started. *(O4's Save at zero touches;
> O5a's Save with no edits; S-01's provider buttons while a provider flow is
> running; O2's `Placeholder` rows while the membership query is out.)*

**Why (b) splits by component, and it is a derivation not a preference. [d]**
A settings row is a **label first and an affordance second** — 10 §7.6 gives it
no trailing mark, so its interactivity was never visible. A CTA-geometry control
is `size.ctaHeight` 138 px = 46.0 pt of fill (10 §10.5) and **nothing but an
affordance**; there is no reading of it in which it is a label. So a row that
cannot act is still a true statement, and a 46 pt slab that cannot act is a lie
about a tap target — which is 11 §12.2's own sentence, now with the reason it is
true.

**Why (a) was widened.** v1 defined (a) as *"no path exists for this account or
role, ever"*, which left `Delete downloaded maps` with nothing downloaded
unanswerable — the driver **can** satisfy that precondition, one row above. The
widened form covers it without a fourth answer: the verb has no object, so there
is nothing to disable and nothing to explain. It is the only case in the product
where absence is used for a precondition the human can reach, and it is safe
because the row that grants the precondition is adjacent and visible.

### 5.3 The three places absence does not work, named

**O4's `Save` at zero touches.** 12 §4.4 rule 4 already rules it: *"At zero
touches the CTA renders in `color.surface` and does nothing; at ≥1 it takes
`color.accent`."* Adopted unchanged, with the justification it lacked — the
operator's **next tap on this screen** enables it, so it is case (c) and not a
lie. Absence fails here for two concrete reasons: the sticky bar would **reflow
on the first tap**, moving the target the operator is aiming at; and the label is
the operator's readout of the size of the claim they are about to make
(`Save 3 updates`), which is a safety feature of the screen, not decoration.

**One collision this creates, which 12 §4.4 does not name. [d]** On O4,
`color.surface` `#393939` already means *an unselected but fully tappable
control* — it is the resting fill of all three buttons in the control row
(12 §4.3). The inert Save is the same fill on the same screen. **The fill cannot
carry the distinction, so the label must.**

| O4 Save | Fill | Label |
| --- | --- | --- |
| Zero touches (inert) | `color.surface` `#393939` [m, 10 §10.1] | **`Save`** — no count [INVENTED, §14/1] |
| ≥1 touch | `color.accent` `#C7FC2F` [m] | `Save 3 updates` [12 §4.4] |

**O5a's `Save` with no edits — new here, and v1 answered it with one word.**
v1's coverage table wrote *"inert, unchanged"* and stopped, which is exactly the
answer §5.3 had just proved insufficient for O4. Worked properly:

- **The same collision applies.** O5a carries a plug multi-select (12 §3/O5). If
  that control uses O4's measured accent-for-selected pattern — which is stream
  2's to specify — then `#393939` again means *tappable but unselected* on the
  same screen, and again the fill cannot carry it. **Stated as a dependency, not
  assumed**: if stream 2 gives the multi-select a different resting fill, this
  paragraph is unnecessary and the fill answer returns.
- **The label carries it, in the same family.** `rateCoverage` is denominated in
  plugs and a bulk apply writes one rate across N of them (12 §3/O5,
  availability-display law 7), so O5a has a count exactly as O4 does. The label
  is **`Save` at zero edits, `Save N updates` at ≥1** — the same string family,
  one component, one rule product-wide, already routed to `packages/domain` with
  11 [RAISE-D23]. The noun stays `updates` rather than becoming `rates` or
  `plugs`, because one component with two nouns is two components.
- **Without it the operator gets nothing.** With no press treatment (§4.3), no
  in-flight rendering (§7.3) and no fill change, an O5a operator tapping Save at
  zero edits receives **zero signal of any kind**. That is what the label
  prevents. **[RAISE-S-26]**

**S-01's provider buttons while a flow is running.** 11 S-01 already rules it:
*"The buttons become non-interactive; nothing else changes."* Absence fails
because removing them mid-flow empties the card. Adopted; §7.3 records why
"nothing else changes" is the right answer rather than a gap, and §4.3 records
its cost.

### 5.4 Every screen in §3 tested against the rule

v1 called this table *"every screen"* over nineteen rows and missed at least
four. It is now twenty-three rows and the claim is narrower: **every case in §3
where a conventional design would grey something.**

| Would conventionally be disabled | Rule | Answer | Already ruled? |
| --- | --- | --- | --- |
| Hosting card, no membership | (a) | absent | 11 §6.3 ✓ |
| O6 / O7 in a non-owner's `⋯` menu | (a) | the item is not in the menu | 12 §3.0 ✓ |
| O9's "request access" | (a) | no action offered | 12 §3/O9 ✓ |
| **D-07 `Delete downloaded maps`, nothing downloaded** | (a) | **the row is absent — the verb has no object** | **new here** |
| Bay-watch at the ceiling / already free | (b) CTA | `StateLine` in the control's slot | 11 §12.2 ✓ |
| Connector row, not at the station | (b) row | inert row + `StateLine` | 11 §12.1 ✓ |
| `Bay alerts`, permission denied | (b) row | inert row + `StateLine` + `System settings` row | 11 D-08 ✓ |
| `Bay alerts`, signed out | (b) row | inert row + `StateLine` | 11 D-08 ✓ |
| `All of Rwanda`, offline | (b) row | `76 MB · needs a connection` in the **value slot**, row inert | 11 D-07 ✓ |
| `Delete account`, offline | (b) row | refusal line | 11 D-06 ✓ |
| A8 `Publish` before prerequisites | (b) | the checklist names the unmet items | 12 §A8 ✓ |
| A4 delete a bay / connector | (b) | **the reason cannot be written yet** — 12 [RAISE-OA-14] | **no — [RAISE-S-19]** |
| O4 `Save`, zero touches | (c) | inert, label without count | 12 §4.4 ✓ + §5.3 here |
| **O4 `Save`, zero touches, queue non-empty** | (c) | **unchanged — the queue is not a touch.** The count lives in the sticky bar's left slot (12 §4.7); Save's label counts *this screen's* touches only | **new here** |
| O5a `Save`, no edits | (c) | inert, `Save` / `Save N updates` | **new here — §5.3, [RAISE-S-26]** |
| **O2's `Placeholder` rows while the query is out** | (c) | **inert.** A tappable placeholder navigates to nothing | **new here** |
| S-01 / O1 / A1 providers, in flight | (c) | inert, unchanged | 11 S-01 ✓ |
| S-01 / O1 providers, offline | (b) + (c) | `StateLine` **and** inert — the reason is not satisfiable here, but the buttons stay because the card would otherwise be empty | 11 S-01 ✓ |
| **A3 / A5 submit with invalid fields** | none | **the submit stays live** — §8.6 rule 2. It is not a disabled case at all, and it is in this table because every form library makes it one | **new here** |
| O6 `Invite operator`, offline | (b) or queue | **unspecified, and unspecifiable** until `Invitation` exists — 12 [RAISE-OA-6] | **no — [RAISE-S-11]** |
| The heart, signed out | none | **fully live** — it opens S-01 and auto-resumes | 11 §10 ✓ |
| `Directions`, any state | none | **never gated, ever** | ADR-0003 amended, SPEC §6 ✓ |
| `My plug` rows | none | always live; ungated | ADR-0003 amended, SPEC §6 ✓ |

Two rows are **not** answered, and both are blocked on a model gap rather than on
a design decision. That is the honest result of the test.

### 5.5 What this costs

- **A control that has left the screen has no discoverability.** A driver who
  never sees a bay-alert control cannot learn that bay alerts exist. Mitigated by
  (b) being the default for anything the driver could plausibly reach — absence
  (a) is reserved for roles the human cannot obtain by any route, and for verbs
  with no object.
- **Rule (c) produces a control that looks live and is not.** For up to one tap.
  This is the smallest amount of dishonesty available, and it is bounded because
  the enabling action is on the same screen. §4.3 is what makes it survivable:
  the result of a tap is the feedback, so a tap that produces nothing is the only
  case the human has to absorb.
- **The rule spends copy where other systems spend colour.** Every (b) case is a
  string, every string is closed-vocabulary-adjacent, and §9.4's discipline
  applies to all of them.

---

## 6. Focused — very nearly a non-state, and one place where it is not

### 6.1 What focus means in this product

| Surface | Focus concept | Verdict |
| --- | --- | --- |
| Driver app, operator app | Which text field is being edited. There is at most one, and it lives in a card or a pushed screen. There is no keyboard navigation, no pointer, no hover. | **Focus = the caret and nothing else** |
| Accessibility focus (VoiceOver / TalkBack) | The OS draws its own focus indicator over the app's pixels | **Not EV Guide's to style, and must not be suppressed** |
| Web admin | The browser draws `:focus-visible` on every focusable element by default; keyboard traversal of a form is a real workflow (A3, A5) | **Keep the default. Do not restyle it.** |

### 6.2 The native rule

> **A focused input is identical to an unfocused input except for its caret.**
> The only channel the palette could add is a surface swap at 1.08 : 1 or
> 1.62 : 1 (§1.3), neither of which is a state, and the accent is spent on
> selection (12 §4.3).
>
> **The caret takes `color.accent`** — `selectionColor` on Android, `tintColor`
> on iOS.

**The classification, corrected.** v1 marked this **[d]** on the grounds that a
measured token applied to a platform property introduces no new value. §0.1
defines [d] as *derived by arithmetic stated in place*, and there is no
arithmetic: "caret = accent" is a **relationship**, which is precisely the class
[RAISE-S-2] calls invented. **[INVENTED]**, §14/8, **[RAISE-S-24]**.

The cost is small and the alternative is worse, which is why the raise carries a
firm recommendation: the platform default caret is iOS's system blue or
Material's primary, i.e. **a foreign brand colour inside a product with exactly
one accent** — the same objection ADR-0009 §2 sustained against Google's puck
blue. Accept.

Stream 2 owns the input's resting appearance (11 [RAISE-D21]: built from the
feature-chip surface, `#393939`, `radius.chip` 10 px, `size.chipHeight` 105 px —
10 §7.5, §10.4, §10.5). This file adds only the caret colour and the statement
that the container does not change.

### 6.3 The one place this is not good enough — O5a

O5a is the **only native screen with more than one field**: one rate per
Connector, and `rateCoverage` is denominated in plugs, so eight identical rows is
a normal site (12 §3/O5). A caret in one of eight identical rows, with the
keyboard covering the lower half of the screen, is not enough to say which rate
is being edited.

**Recommendation — the edited row takes `color.surface` `#393939` as a full-row
fill at `size.settingsRow` 176 px = 58.7 pt** (10 §10.3; 10 §7.6 gives the
measured range 176–177 and §10.3 is where the single token value lives).
**[INVENTED]** as a relationship — the reference has no focused row. §14/9,
**[RAISE-S-25]**.

**Three things v1 got wrong here, corrected together.**

1. **It is not the largest swap in the system.** v1: *"Contrast 1.62 : 1 (§1.3),
   which is the largest swap in the system."* §1.3 says the largest is
   **1.75 : 1** (`color.bg` → `color.surfaceRaised`). The recommendation is for
   the **smaller** of the two available fills.
2. **The reason to take the smaller one is a token-role collision, not
   contrast.** `#3E3E3E` is `color.divider` (10 §7.6, §10.1) *and* this file's
   `Placeholder` fill (§7.2). A focused row painted in the placeholder colour
   reads as *not yet loaded*, on the one screen where the operator is waiting to
   type into it. The cost of choosing on role rather than on contrast is
   **0.13 of ratio**, which at these levels is itself below any perceptual
   threshold — so nothing is lost that could have been seen.
3. **The premise that made it acceptable is withdrawn.** v1: *"O5a is the one
   write screen in the product that is not performed standing at a charger,"*
   attributed to 12 §3/O5. **12 §3/O5 does not say that.** It says a rate is
   *"a declaration about policy — the owner knows it without looking at
   anything"*, which is an argument about **what** the owner knows, not **where**
   they are standing; and 12 §3.0 reaches O5a from O3's `⋯` **inside the operator
   app**, i.e. plausibly at the station. With the premise gone, the acceptance
   goes with it: at 1.62 : 1 the focused row **vanishes outdoors like every other
   grey-to-grey swap in §11**, and what is left is the caret.

**And it collides with §4.4's treatment 2** — a pressed row and the focused row
would both be `#393939` on the same screen (§4.5, collision 3).

**This is a founder call, not an acceptance**, and it is stated as one:
[RAISE-S-25] carries the invention, the 1.62 : 1 cost, the withdrawn premise and
the press collision. If the answer is no, O5a ships with the caret alone and the
row that is being edited is identified by nothing else.

### 6.4 The web admin

- **Do not suppress the browser's focus ring.** It is drawn by the platform,
  costs nothing, and 1:1 does not govern the admin (12 §7).
- **If it is restyled, `size.hairline` is a trap.** 10 §10.3 gives it as
  **2 px = 0.67 pt** — a value measured on a **@3× capture** (10 §0.1). Porting
  the integer `2` into CSS pixels yields a ring three times heavier than the
  reference's hairline. The correct port is 0.67 pt ≈ 1 CSS px. [d] — named
  because the whole token table shares the trap and the admin is the one consumer
  that is not @3×. [RAISE-S-13]
- **The admin will grow hover and focus styles by default**, from whatever
  component library the BWEZE console shell ships. They have no measured source
  and 1:1 does not govern them. Named so it is a decision rather than a default.
  [RAISE-S-12]

---

## 7. Loading and in-flight — extending 11 §9.4, not restarting it

### 7.1 What §9.4 already fixes

11 §9.4 is the global vocabulary and it is settled by one measured fact — the
`02` profile avatar's `#3E3E3E` empty fill inside its lime ring. This file does
not restate the table; the rows it consumes are: **media not yet available →
`#3E3E3E` block at the target's exact geometry and radius** · **additive marks →
absent then present** · **structural content → never absent** · **empty list →
heading + one line of cap-28 ExtraLight body copy** · **error → body copy in
place, `#FFFFFF`** · **progress → text only** · **motion → none, anywhere**.

Everything below is what §9.4 does **not** cover.

### 7.2 `Placeholder` — the component §9.4 implies but does not name

| Property | Value | Source |
| --- | --- | --- |
| Fill | `color.surfaceRaised` `#3E3E3E` | 10 §10.1 [m] |
| Geometry | **the target's exact frame** — hero **1078 × 612 px** (not 11's stale 1076 × 620, §0.4a), thumbnail `size.thumbnail` 300 × 300 px, profile avatar ⌀316 px, O2 row **1128 × 334 px** (not 12 §5.1's 1130 × 335, §0.4b) | 10 §7.7, §7.9, §7.10, §10.5 [m] |
| Radius | **the target's own** — `radius.image` 30 px for media, `radius.card` 13 px for the O2 row, `radius.circle` for avatars | 10 §10.4 [m] |
| Motion | **none.** No shimmer, no pulse, no cross-fade | 10 §9, §12; 11 §9.4 |
| Duration | **indefinite.** A photo that never loads stays a block | 11 §9.4 [held] |
| **Interactivity** | **inert** — §5.2 case (c). A tappable placeholder navigates to nothing | **new here** |

**The indefinite duration is a decision, not an omission.** A placeholder that
eventually becomes an error implies a retry the driver cannot perform on a photo,
and photos are ADR-0007 lazy-loads whose absence costs nothing.

**Two contrast figures, because the component is asked two different questions.
[d]** v1 published one and §11 repeated it, which is the defect D-1 names.

| Question | Comparison | Ratio |
| --- | --- | --- |
| *Is there a block here at all?* | `#3E3E3E` on `color.bg` `#121212` | **1.75 : 1** |
| *Has it loaded yet?* — where the loaded target is a `color.surface` container | `#3E3E3E` against `#393939` | **1.08 : 1** |
| *Has it loaded yet?* — where the loaded target is a photograph | — | **[?]** — photographs are not a measured value |

The second row is the one v1 never asked and it applies wherever a `Placeholder`
replaces a `color.surface` container rather than an image — which on O2 is every
row (§7.4).

**And the one placeholder the reference actually contains has an accent mark on
it.** 10 §7.9: the `02` profile avatar is a `#3E3E3E` fill **inside a `#C7FC2F`
≈3 px ring** (`size.accentRing`, 10 §10.5). Its ring is 15.52 : 1 against the
page. **Every placeholder this file specifies is ringless**, because none of
their targets carries a ring, and so none of them inherits the one thing that
makes the measured example visible. Stated because it is the strongest available
argument that placeholders in this product carry very little — §11 and
[RAISE-S-18].

### 7.3 In-flight — the rule, and how small the set actually is

> **An in-flight write renders nothing. The control keeps its appearance and
> stops accepting taps (§5.2 case (c)). There is no spinner, no progress ring, no
> skeleton animation and no toast, because none exists in the reference and
> 11 §9.4 forbids introducing one.**
>
> **Where an action has latency the human must wait through, the *copy* carries
> it and nothing else does** — extending 11 [RAISE-D16]'s text-only ruling from
> D-07's download to every waiting state in the product.

**The cost, stated because §4.3 makes it sharper than v1 could:** with press
rendering nothing and in-flight rendering nothing, a control whose result is
neither immediate nor copy-bearing gives the human **no signal at all**. §4.3
enumerates which controls those are; there are two, and one of them is
[RAISE-S-29].

The set of genuinely in-flight actions, enumerated honestly:

| Action | In-flight rendering | Basis |
| --- | --- | --- |
| Provider auth (S-01, O1, A1) | **none** — the OS takes the whole screen; the buttons are inert behind it, invisibly (§4.3) | 11 S-01 ✓ |
| Magic-link email | **the body copy is the state**: `Send me a link` → `Check your email. The link signs you in.` | 11 S-01 ✓ |
| `All of Rwanda` download | **text percentage in the value slot**, `42%` | 11 D-07, [RAISE-D16] ✓ |
| **`Station directory` sync** | **a value-slot string that does not exist** — [RAISE-S-29] | **new here, §4.3** |
| Route resolution (D-02) | **the chip is absent** until resolved | 11 §7.3 ✓ |
| Any report or availability write | **§7.6 — there is no in-flight state, because the write is local** | new here |
| O2's first membership fetch | **§7.4 — the hole** | new here |
| O6 invite | blocked on 12 [RAISE-OA-6] | §3.3 |
| **Admin form submits** | **§7.7 — a real round trip, and the rule above does not govern it** | new here |

### 7.4 The hole: O2 has a cold-start loading state the driver app cannot have

**The finding.** ADR-0007 makes the driver app architecturally immune to a
first-paint loading state — a bundled directory snapshot ships inside the binary,
so *"pins paint immediately"* and *"There is no loading state for the directory,
ever"* (11 D-01). **The operator app inherits none of that.** 12 §2: the app has
no map and *"the station list is a **membership query**"*. There is no bundled
membership snapshot and there cannot be one — memberships are user-scoped and the
binary is public.

So **O2, the operator app's root, has a real cold-start period with nothing to
draw**, and 12 §10.1 names the state (`loading`) without specifying it.

**Why it is worse than an ordinary loading state. [d]** O2's zero-row state is
**O9** — an explanatory hosting card saying the account has no assigned stations
(12 §3/O9). On a slow link the operator is shown a confident, explanatory
statement that they hold no memberships, before the query that would contradict
it has returned.

| # | Rule | Class |
| --- | --- | --- |
| **1** | O2 paints **`Placeholder` rows at the row container's exact frame** — the 10 §7.10 hosting-card geometry O2 uses as its row container (**1128 × 334 px**, `radius.card` 13 px), filled `color.surfaceRaised` `#3E3E3E`, static, **inert** | [d] from 10 §7.10 + §10.1 + §10.4; **the use is [INVENTED]**, §14/2 — 11 §9.4 applies `#3E3E3E` to *media*, and extending it to a whole row is this file's step |
| **2** | **Row count = the last known membership count**, persisted from the previous session; **1 on a true first run** | the count is data, not a dimension; the `1` is **[INVENTED]**, §14/3. **The persistence is a build dependency, not a token** — no value in §10 expresses it |
| **3** | **O9 may not be drawn until the membership query has actually returned zero.** A cache miss, a pending request and a failed request all render (1), never O9 | a sequencing rule — **no pixels, no tokens, no invention** |

Rule 3 is the one that matters. It is free, it is testable, and without it the
operator app tells a new owner they have no stations for as long as the network
takes.

**The cost of rule 1, recomputed — and the verdict's version of it is wrong.**
The reviewer's finding is that *"the loading→loaded and loading→empty
distinctions are `#3E3E3E` against `#393939` = 1.08 : 1"*. Half of that is right
and half of it is not, and the half that is not makes rule 1 look better than it
is:

| Discrimination | What actually carries it | Ratio |
| --- | --- | --- |
| Is a block present at all? | the placeholder's fill against the page | **1.75 : 1** — the figure v1 published |
| Placeholder vs the **fill** it becomes | `#3E3E3E` against `#393939` (10 §7.10) | **1.08 : 1** — the figure v1 owed and D-1 correctly demands |
| Loading vs **loaded** | **not the fill.** A loaded O2 row carries a 100 pt photo, a `type.heading` 17 pt Bold title, a `type.body` subtitle and a value slot, all `#FFFFFF` on `#393939` | **11.55 : 1** |
| Loading vs **O9** | **not the fill.** O9's card carries an 85.7 pt `#3E3E3E` tile with a lime glyph, a 17 pt Bold title and 13 pt body (12 §3/O9) | **8.86 : 1** (glyph on the tile) and **11.55 : 1** (title on the card) |

So: the two distinctions the operator actually makes are carried by **content at
8.86–11.55 : 1**, not by the fill at 1.08 : 1, and they survive §11's daylight
comfortably. What does *not* survive is the placeholder itself: at 1.75 : 1,
ringless (§7.2), it is nearly invisible outdoors, which means **the placeholder
rows carry no information in either condition — they exist only to stop the
screen being blank while the query runs, and outdoors they do not even do that.**

**Rule 1 therefore does very little and rule 3 does all the work.** v1 reached
that conclusion from a figure that did not support it; it is now reached from
figures that do. `#3E3E3E` is nonetheless kept over `#393939` for the block,
because against the page it is the **larger** of the two (1.75 vs 1.62 : 1) —
the only place in this document where `#3E3E3E`'s extra 0.13 is spent rather than
declined. [RAISE-S-8], [RAISE-S-18]

### 7.5 Two states that render nothing, deliberately

Both are already ruled and are restated only because a coverage matrix that
silently skipped them would look like a hole:

- **S-01 `cancelled`** — *"card dismisses; nothing is lost; no message"*
  (11 S-01). A driver who backed out of a sign-in is not told they backed out.
- **S-02 `expired`** — a queued report past its 2 h window is dropped and
  *"Nothing is shown, **because nothing is true**"* (11 S-02).

Both are the same principle: **a state with no true statement behind it renders
nothing.** That principle is what §9.4 enforces on empty copy.

### 7.6 `saving` should not exist — a correction owed to file 12, **operator app only**

12 §4.5 and §10.1 list **`saving`** and **`saved`** as distinct O4 states, and
12 §10.1 repeats the pair for O5a. Under ADR-0007 they cannot be distinguished by
the operator and must not be:

1. The write is **local**. 12 §4.7: the surface is *"fully functional offline"*
   and reports queue with their original `capturedAt`.
2. `capturedAt` and `capturedLocation` are stamped **at the connector's tap**,
   not at Save (12 §4.4 rule 3), so Save has no timestamp work to do.
3. An operator in a basement car park is **the modal case, not the edge case**
   (12 §2). A `saving` state that waits on the server is, for that operator, a
   wait that never ends — and the reference has no spinner to draw it with.

> **Recommendation: delete `saving` from 12 §4.5 and 12 §10.1's O4 and O5a
> rows.** Save is a local commit. The confirmation is **the screen re-deriving** —
> exactly S-02's already-ruled pattern: *"The confirmation is the report's own
> effect… No toast, no snackbar — the reference has neither"* (11 S-02).
>
> `saved` therefore collapses into **idle with the derived lines changed**, which
> also satisfies 12 §4.4 rule 1 (nothing is preselected, on every open).
> `queued offline (n)` becomes the only post-save state, **online and off alike**
> — honest, because online and off differ only in how long the queue is
> non-empty.

**The scope, corrected.** v1's coverage table routed **A3's `saved`** here too,
and all three grounds above are false for the admin: A3 and A5 are forms in a web
SPA writing to a server over the network, where a save genuinely has a round trip
and genuinely fails. **This recommendation reaches O4 and O5a and stops there.**
12 §10.2's A3 and A5 keep `saved`, and their in-flight rendering is §7.7's.
[RAISE-S-7], scope corrected.

**One thing this does not decide.** Whether O4 dismisses on Save or stays open is
a *navigation* question 12 does not answer, and this pass may not extend the
navigation vocabulary (§0 note 5). Both readings work under the rule: dismissing
makes O3's availability block the confirmation; staying makes O4's own derived
bay header lines the confirmation. **Routed to file 12, not decided here.**

### 7.7 The admin, and what its submits do while in flight

The admin is a web SPA and 1:1 does not govern it (12 §7). v1 made it inherit
*"in-flight renders nothing"* on the grounds that the alternative is a spinner no
native surface has. **That is wrong for the admin and §7.6 is why**: an A3 or A5
submit is a real network write with a real failure mode, and a form that renders
nothing during it invites the double submit that append-only tables punish.

> **The admin's submit affordance is the console shell's own** — whatever
> in-flight treatment the BWEZE console ships, unmodified and untokenised.
> §12.2's prohibition on building a `Spinner` governs `packages/ui`, **not** the
> console shell, and this sentence is the carve-out.

Named so the divergence is a choice. The rule the admin *does* inherit is the
copy discipline (§9.4) and the no-error-colour rule (§8.3), because those are
about honesty rather than about pixels.

---

## 8. Errors, retry and validation — and the three things that are not errors

### 8.1 The distinction ADR-0007 forbids getting wrong

| Condition | What it is | Rendering | Never |
| --- | --- | --- | --- |
| **Offline** | **a normal mode** | the offline chip — feature-chip geometry, `#393939`, no border, `size.chipHeight` 105 px (11 §9.1; 10 §7.5) | an error screen, a banner, a modal, a red anything, **or any of the strings 11 §9.1 already forbids** |
| **Queued** | **success** | a count — O4's sticky-bar left slot, O8's non-interactive row (12 §4.7, §O8) | a warning, a badge, a retry button, or a control implying the send order is the operator's to change |
| **Failed** | **the only error** | §8.3's `StateLine`, plus a retry that is always the original control | a colour |

ADR-0007: *"Offline gets a quiet indicator; it is a normal mode, never an error
screen."* This is the one place where getting the state design wrong turns a
routine Rwandan connectivity dip into a failure surface, and the whole point of
separating the three columns is that **two of them look like problems and are
not**.

**The `Never` column cites and does not copy.** v1 spelled out three banned
strings there; 11 §9.1 already holds that list, and §9.4 of this file claims to
add no second list. A copy is a copy even when it is a copy of a different list.
**Cited: 11 §9.1.**

### 8.2 Three failures that are not errors, restated so nobody adds one

- **Route resolution fails** → the chip degrades to `~2.4 km straight line`
  (11 §7.3). Not an error; a less precise true statement.
- **The directory has not synced** → `Not synced`, and *"Never *out of date*:
  the snapshot is a complete listing"* (11 D-07).
- **A photo does not load** → a `Placeholder`, indefinitely (§7.2).

### 8.3 `StateLine` — one line of body copy, doing five jobs

v1 titled this *"the error component"* and then §11.1 listed five jobs for it.
The title is what makes someone build the `ErrorText` §12.2 bans, so it is gone.
`StateLine` is **the product's one line of state copy**, and error is one of its
jobs.

11 §9.4: *"Any error → body copy replaced in place, `#FFFFFF`. **There is no
error colour in the token set** and adding one would be a deviation."* That is the
whole component:

| Property | Value | Source |
| --- | --- | --- |
| Type | **cap 27–28 px** — `type.body`, 13 pt ±3 % (ADR-0010); line pitch **45 px = 15 pt** where it wraps | 10 §4.2, §4.3 [m] |
| Weight | **ExtraLight** in the driver app; **Regular** in the operator app — §11.1 | 10 §4.5 [m]; ADR-0009 §4's own mitigation, extended |
| Colour | `color.text` `#FFFFFF` | 10 §10.1 [m] |
| Width | the container's content width | 10 §5.1 [m] |
| **Slot** | one of **three**, §8.3.1 | slot geometry [m]; **the assignment rule is [d]**, [RAISE-S-21] |
| Icon, colour, border, background | **none** | 10 §9, 11 §9.4 |

#### 8.3.1 Three slots, not two — and the source v1 cited uses all three

v1 gave `placement: 'inBlock' | 'aboveControl'`. 11 D-07 renders
`Download didn't finish. Tap to try again.` and `76 MB · needs a connection` in
the settings row's **value slot** (11 D-07's own state table is headed *"Value
slot"*), and 11 §12.2 renders `3 alerts set. That's the most at once.` **in the
place the bay-watch control would occupy**. Neither is a block line and neither
sits above a control.

| Slot | Where | Geometry | Cases |
| --- | --- | --- | --- |
| **`bodyBlock`** | in the flow, at `space.blockGap` 39 px = 13.0 pt from whatever precedes it | 10 §10.3 [m] | every empty state · D-03 not-at-station · D-08's two refusals · O7/A11's window line · §8.4's O2 rejection line · §8.6's validation lines (which are `bodyBlock` immediately preceding a control — v1's `aboveControl` is this slot, not a fourth) |
| **`valueSlot`** | the settings row's right-aligned value, 11 [RAISE-D14] | the `03` card's price treatment, 10 §11.3 [m] | D-07's `76 MB · needs a connection` and `Download didn't finish. Tap to try again.` · [RAISE-S-29]'s sync string |
| **`controlSlot`** | in place of a CTA-geometry control, at `size.ctaHeight` 138 px | 10 §10.5 [m] | §5.2 case (b) on CTA-geometry controls — bay-watch at the ceiling, bay-watch already free |

**And one `StateLine` per statement.** 11 §9.4's *"one line"* is about a
paragraph, not about a screen. D-11 ships one statement in two sentences
(`Stations you save appear here. Tap the heart on any station.`) → **one**
`StateLine`, wrapping at the measured 45 px pitch. D-12 ships two statements with
two jobs — the list's state, and how to fill it → **two** `StateLine`s at
`space.blockGap`. The component permits stacking; the rule that decides is *one
statement, one line*, and D-12 is the only place in the product that needs two.
11 §9.4's "one line" is **amended by name** to mean one paragraph per statement.

#### 8.3.2 Retry is always the original control

D-07's failed download reads `Download didn't finish. Tap to try again.` and *the
row is the retry* (11 D-07); S-01's failure leaves the provider buttons in place
and *they are the retry* (11 S-01). Generalised:

> **No `Retry` component exists in `packages/ui`.** Where the original control is
> still on screen, it is the retry. **Where it is not, there is no retry path** —
> which is not a gap to fill with a button but a fact that identifies exactly one
> case, §8.4.

### 8.4 The hole: a server-rejected queued write has no surface

12 §4.5 names `server-rejected` and 12 §5.2 gives its concrete cause:
*"Membership revoked while open… queued writes for that station are rejected
server-side on receipt (the client cannot know) and surfaced once."* **Nothing
specifies how they are surfaced**, and it is the one place in the product where a
human must be told that something they did did not happen.

| Home | Fails because |
| --- | --- |
| Silent drop | The operator believes a claim they made is on the map. This is the one dishonesty the product cannot absorb. |
| A push notification | *"Nothing pushes to an operator in v1"* (12 §O8). |
| O8's queued-writes row | It is *"a readout, not a destination"* by design (12 §O8); giving it a destination contradicts the reason it exists. |
| **In place on O3/O4 for that station** | **Fails for exactly the case that produces it** — the membership was revoked, so the station is gone from O2 and there is no station surface left to carry the message. |

> **Recommendation: one `StateLine` in `bodyBlock` above O2's rows, shown once,
> cleared by any interaction.** O2 is the only screen that survives the
> revocation, and it is the screen the operator lands on.
>
> **Copy: `3 updates for SP Remera were not accepted.`** [INVENTED], §14/4 —
> routed to `packages/domain` with 11 [RAISE-D23]'s report-action labels, not
> authored in the app.
>
> **Two copy constraints that are not optional.** It must **not assert a reason
> it cannot know** (the client genuinely cannot know whether the cause was a
> revocation, a clock, or a schema rejection), and it must clear
> `docs/availability-display.md` **§2.2b** — in particular it may not say anything
> about what was or was not *reported*.

This is the single riskiest recommendation in the document: one invented string on
a screen nobody has drawn, telling a human their work was discarded. It deserves
the founder's eye rather than a design decision. [RAISE-S-9]

### 8.5 A1's refusal is authorisation, not authentication

12 §A1: a non-staff account *"authenticates successfully and is then refused —
the refusal is authorisation, not authentication, and must read that way."* Under
§8.3 that is a `StateLine` in `bodyBlock`, and the copy discipline is that it must
not imply the credentials were wrong. Named because the default string every auth
library ships says exactly the wrong thing.

### 8.6 Validation

**Rule 1 — prevention before correction, wherever the input can enforce it.**
12 §A3 gives `name` a *"counter, hard stop"* at 28 characters. Generalised: a
field that cannot accept an invalid value cannot produce an invalid state, and
every prevented error is one that needs no channel to render.

| Constraint | Prevented? | How |
| --- | --- | --- |
| `name` ≤ 28, `nameShort` ≤ 18 | **at keystroke** | counter + hard stop, 12 §A3 |
| `shortName` ≤ 17 | **at keystroke** | same — **12 §A5** (Owners), not §A3 |
| `markerLabel` 1–3 `CHECK` | **at keystroke** | hard stop at 3, 12 §A5 |
| `ratePerKwhRwf`, `powerKw`, `voltage` | **at keystroke** | numeric input accepts no letters (stream 2) |
| `type` — OCPI open enum | **at keystroke** | a select, never free text, 12 §A4 |
| `owner_id` NOT NULL | **at keystroke** | a select over the bounded Owner set, 12 §A3 |
| **`geo` NOT NULL** | **at submit** | 12 §A3: *"map picker, **cannot save without it**"*. A map pick is an act rather than a keystroke, so the keyboard cannot prevent it — but the submit does, and its refusal takes rule 2. v1 marked this unpreventable against a source that prevents it |
| `icon` must be a vector | **no** | known only after the file is chosen |
| An email's shape | **no** | — |
| A8's publish prerequisites | **no** | they are about children, not fields |

**Rule 2 — where prevention is impossible or deferred to submit, the error is a
`StateLine` in `bodyBlock` immediately above the submit control, and the submit
control is not disabled.** It stays (§5.2 — it is not a disabled case at all) and
the line says what is missing. This is A8's checklist pattern applied to fields,
which is the admin's own already-ruled behaviour rather than a new one.

**Rule 3 — no inline red, no field outline, no icon, no per-field mark.** There is
no error colour (11 §9.4) and the input has **no border** to colour — it is built
from the feature-chip surface, which 10 §7.5 measures as `#393939` with
**border: none**.

**The cost, stated plainly: a field in error is pixel-identical to a field not in
error.** Only the line says otherwise. On a six-field admin form that is a scan,
not a glance.

**The mitigation available inside the measured system is copy, and it is
mandatory: the line names the field.** `Owner is required.` — never `Required.`,
never `Please fix the errors below.` A generic line in a system with no per-field
mark is unactionable. The **form** of the line is [INVENTED], §14/7.
[RAISE-S-10]

<!--CHUNK5-->



