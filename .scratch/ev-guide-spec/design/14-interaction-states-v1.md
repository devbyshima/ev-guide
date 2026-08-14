# 14 — The seven interaction states (v1)

Ticket 31, **design stream 1 of 2**. Stream 2 is the form controls; the two are
reviewed separately by an adversary briefed to reject and then merged into one
v2 record. This file specifies **states**; where a control's *appearance* is
stream 2's (the text input, the numeric input, the multi-select), this file
specifies only what its states do and says so.

> ## Authority and citation notes — read first
>
> **1. `10-design-system-v2.md` is the single measurement authority**, and this
> file cites it by **v2 section numbers** (§1 colour · §4 type · §5 spacing ·
> §6 radii · §7 components · §8 icons · §9 elevation · §10 tokens · §12 raises).
> Files 11 and 12 cite file 10 by v1 numbers behind a translation table; this
> file does not propagate that. A citation like `10 §7.6` means file 10-v2's
> §7.6, always.
>
> **2. The forbidden-string list is cited, never restated.** Its one home is
> `docs/availability-display.md` **§2.2b**. Every string this file proposes is
> tested against it in §8.4 by citation.
>
> **3. Dark-only ships** ([ADR-0009](../../../docs/adr/0009-reference-fidelity-deviations-and-costs.md)
> §4). No light theme, no contrast mode, no brightness override. Two knowing
> deviations exist (the wordmark, the puck) and neither is a licence for a
> third.
>
> **4. The navigation vocabulary is fixed and this pass does not extend it.**
> Full-screen surfaces reached by a push (`←`) or a presentation (`×`), plus one
> floating avatar. The two OS-drawn surfaces already adopted — the platform
> action sheet (11 S-03, [RAISE-OA-15]) and Apple's own sign-in button
> ([RAISE-D20]) — are the precedent this file extends by exactly one (§9).

---

## 0. Method, and what the reference can and cannot say

### 0.1 Marking legend

- **[m]** — measured, with the file-10 section that measured it. This file
  measures nothing itself; it has no `[m·14]` class and no undeclared numbers.
- **[d]** — derived from [m] values by arithmetic stated in place.
- **[?]** — the reference cannot say. The reason is given.
- **[INVENTED]** — a value or relationship with **no measured source**. Every
  one has an entry in §12 with a recommendation and a cost. There is no fourth
  category, and a value that looks measured but is not is the defect this pass
  exists to prevent.

### 0.2 What four stills of a read design can supply

The premise, restated from 12 §1 because it is the whole reason this ticket
exists: **the reference contains no interaction state of any kind.** No pressed,
disabled, focused, loading, in-flight, error, retry, validation, empty or
destructive-confirmation state appears in `refs/01.png`–`04.png`. File 10 §12
records this under *Could not be measured*, and adds the sharpest version of it:

> *"The record's 'accent shade `#9EC52B`' is anti-aliasing on pin outlines,
> **not** a pressed state; there is no evidence of a second accent value
> anywhere."*

So the honest statement of what the four stills give this pass:

| Available | Not available |
| --- | --- |
| Every **resting** appearance — a chip's fill, a row's pitch, a CTA's radius, a divider's colour, the accent's single value | Any **changed** appearance of the same element |
| The **set of channels** the system uses to distinguish things at rest (§1) | Which of those channels the system would spend on a state |
| **Two precedents for absence** — the no-membership hosting card (11 §6.3) and O9's no-action screen (12 §3/O9) | Any precedent for a de-emphasised-but-present control |
| One measured grey, `#717171`, on one glyph | Its meaning — [RAISE-OA-13]: the same glyph is `#FFFFFF` on `04` in the same presumed state |

**`#717171` is used nowhere in this document as a disabled, inactive or muted
token.** One instance contradicted by its own twin is a measurement, not a
semantic, and adopting it as a state colour would be exactly the silent
invention the ticket forbids.

### 0.3 The one rule, applied

Every value below either names a token from 10 §10 or a measurement from
10 §1–§9, or carries **[INVENTED]** and a §12 entry. Contrast ratios computed
here are **[d]** by WCAG 2.x relative luminance over the measured hexes; where
file 10 §1.2 already publishes a pair, its figure is used verbatim and this
file's independent computation agreeing to ±0.01 is noted rather than
substituted.

### 0.4 Three stale geometries inherited from file 11, corrected here

File 11 was written **before `10-design-system-v2.md` existed** and says so
(11 §18: *"One hard dependency"*). Three of its numbers are pre-v2 and this
file's first drafts propagated all three while citing file 10 for them — which
is precisely the failure mode the ticket names, caught by checking rather than
by care. Recorded so the merged v2 fixes them at the source.

| # | File 11 says | **10-v2 measures** | Where it bites in this file |
| --- | --- | --- | --- |
| 1 | Hero **1076 × 620 px** (11 §8/D-03, §17) | **1078 × 612 px**, verified at five columns and two rows (10 §7.7; v2's change log withdraws the old figure by name) | the `Placeholder` frame for an uncached hero — §3.1, §6.2 |
| 2 | CTA radius **13.5 px** (11 S-01, S-02, §12.2, §12.3) | **13 px = 4.3 pt**, `radius.button` (10 §6, §10.4) | every CTA-geometry control this file specifies — §4.3, §9.1 |
| 3 | Card inner box **950 px** (11 [RAISE-D31]) | the card is **1076 px** wide (10 §7.4, §10.5), so the inner box is **1076 − 2 × 64 = 948 px** [d]. 11's 950 derives from its own superseded 1078 px frame | the confirmation card's button width — §9.1 |

None of the three changes a decision below; all three would have shipped as
wrong pixels. **Corrections owed to file 11**, [RAISE-S-23].

---

## 1. The palette's expressive capacity — the interesting part of the problem

Before any state can be designed, the honest inventory of what the measured
system can and cannot express.

### 1.1 Every channel the measured system affords

| Channel | Values | Source |
| --- | --- | --- |
| **Surface swap** | `color.bg` `#121212` · `color.map` `#212121` · `color.surface` `#393939` · `color.surfaceRaised` `#3E3E3E` | 10 §10.1 [m] |
| **The accent** | `color.accent` `#C7FC2F` — **exactly one value, no tints, no gradients**, verified across four screens | 10 §1.1, §10.1 [m] |
| **On-accent label** | `color.onAccent` `#121212` | 10 §10.1 [m] |
| **Weight** | four classes — ExtraLight ≈200 · Regular ≈400 · Medium ≈500 · Bold ≈700 | 10 §4.5 [m] |
| **Size** | five steps — 26 / 22 / 17 / 15 / 13 pt | 10 §4.2 [m] |
| **Geometry** | eight radii, sixteen component sizes, presence and absence | 10 §10.4, §10.5 [m] |
| **The one hairline** | 2 px = 0.67 pt — link underline, pin outline, crosshair rule | 10 §4.4 [m] |
| **The one divider** | `#3E3E3E`, **exactly 1 px = 0.33 pt**, container-width | 10 §7.6 [m] |
| **Underline** | `type.link` — accent, 0.67 pt, 1 pt below baseline, `skipInk: false` | 10 §4.4, §10.2 [m] |
| **Additive marks** | status dot ⌀20–21 px `#C7FC2F` with a `#FFFFFF` ≈4 px ring | 10 §7.9 [m] |
| **The trailing check** | one `#C7FC2F` check at 24 pt grid / 2 pt stroke | 11 [RAISE-D17], ruled |
| **Absence** | the element is not drawn | 11 §6.3, 12 §3/O9 — **used twice by the product already** |

### 1.2 Every channel the measured system does not have

Each of these is *deliberately* absent, and each is what a conventional state
design reaches for first.

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

Relative luminance of the measured surfaces, and the contrast between every pair
a state could use. Method: WCAG 2.x, computed on the hexes in 10 §1.1.

| Pair | Ratio | Published by 10 §1.2? |
| --- | --- | --- |
| `#FFFFFF` on `#121212` | **18.73 : 1** | yes |
| `#C7FC2F` on `#121212` | **15.52 : 1** | yes |
| `#FFFFFF` on `#393939` | **11.55 : 1** | yes |
| `#FFFFFF` on `#3E3E3E` | **10.69 : 1** | no — [d], new here |
| `#C7FC2F` on `#393939` | **9.57 : 1** | yes (this file computes 9.56; theirs is used) |
| `#C7FC2F` on `#3E3E3E` | **8.86 : 1** | no — [d], new here |
| `#717171` on `#121212` | **3.84 : 1** | yes |
| `#717171` on `#393939` | **2.37 : 1** | no — [d], new here |
| **`#3E3E3E` on `#121212`** | **1.75 : 1** | yes |
| **`#393939` on `#121212`** | **1.62 : 1** | no — [d], new here |
| `#3E3E3E` on `#212121` | **1.51 : 1** | no — [d] |
| `#393939` on `#212121` | **1.39 : 1** | no — [d] |
| `#393939` on `#262626` | **1.31 : 1** | no — [d] |
| `#262626` on `#121212` | **1.24 : 1** | yes |
| `#212121` on `#121212` | **1.16 : 1** | no — [d] |
| **`#3E3E3E` on `#393939`** | **1.08 : 1** | no — [d] |

**The finding that decides this document. [d]**

> **The four surface greys span 1.75 : 1 end to end.** No swap between any two of
> them reaches WCAG 1.4.11's **3 : 1 for identifying a user-interface component
> or its state**. The largest available swap — page to surface — is 1.62 : 1.
> The swap a designer will actually reach for — surface to raised — is
> **1.08 : 1**, which is below the level at which a display's own gamma
> variation is reliable.

Two consequences, and everything in §3–§9 follows from them:

1. **State cannot be carried by a surface swap.** Not because it is ugly, but
   because it is arithmetically sub-threshold and therefore, in the specific
   condition ADR-0009 §4 names — a charger forecourt at midday, 2° south — it
   is not there at all.
2. **The accent is the only channel that survives.** `#C7FC2F` against either
   dark surface is 8.86–15.52 : 1. It is already spent on *selected*
   (11 §12.3), on *yours* (the saved heart, the status dot), and on *the primary
   action*. A state design may add to that load or it may use copy. There is no
   third robust channel.

**A precision, so this is not read as a claim that the reference is broken.**
The reference's own controls also fail 1.4.11 as *boundaries* — a `#393939`
circular button on `#121212` is 1.62 : 1. What makes them legible is their
**content**: `#FFFFFF` glyphs and labels at 11.55 : 1, which is 1.4.3's
territory and passes comfortably. The reference is a read design and reads
fine. It is the *state* channel specifically that has nothing left in it, and
that is a fact about what four stills contain, not a defect in what they show.

---

## 2. The three kinds of state, separated once

The inventory tables in 11 §17 and 12 §10.1/10.2 mix three different things
under one column head. Separating them is what makes the coverage matrix
honest, because two of the three are not this pass's to design and pretending
otherwise would let a real hole hide behind a full-looking table.

| Kind | Definition | Rendered by | Owned by |
| --- | --- | --- | --- |
| **C — content** | The screen's data binding has a different value. Availability regimes, Grammar R's rate cases, membership / no-membership, provider connected / not, draft / published, single-bay, `OTHER` plug. | The screen's own slots | files 11 and 12, already |
| **N — connectivity** | ADR-0007's normal mode. Offline, queued. **Never an error.** | The offline chip (11 §9.1) and the queue count (12 §4.7) | ADR-0007 + file 11, already; extended in §7.1 |
| **I — interaction** | The control's own condition changed because of, or pending, a human action. | **This file** | this file |

**Nothing in kind C or N is redesigned here.** Where the matrix in §3 marks a
state C or N, this file's claim is only that it is covered *somewhere* and
names where — which is the ticket's requirement that no screen name a state
this pass does not account for.

---

## 3. Coverage — every state named by every screen

The point of this section is exhaustiveness, so it enumerates the state columns
of **11 §17** and **12 §10.1/10.2** verbatim, including states this file does
not define. Three of those exist and are declared in §3.3.

### 3.1 Driver app — 11 §17

| Screen | State as named | Kind | Rendered by | § |
| --- | --- | --- | --- | --- |
| **D-01** | default | C | data | — |
| | offline | N | offline chip, 11 §9.1 | §7.1 |
| | no-permission | C | puck absent, locate still requests | — |
| | signed-out | C | avatar's measured empty state | — |
| | *(no loading, no empty, no error)* | — | bundled snapshot, ADR-0007 | §6.4 |
| **D-02** | Regime 1 / 2 / 3 / lensed / no-compatible-plug | C | availability-display §2 | — |
| | route-in-flight | **I** | **the chip is absent**, 11 §7.3 | §6.3 |
| | route-failed | **I** | straight-line form, 11 §7.3 | §7.2 |
| | offline | N | chip + straight-line form | §7.1 |
| | signed-out | C | heart opens S-01 | — |
| | saved | C | heart fills accent, [RAISE-D11] | — |
| | uncached-photo | **I** | **Placeholder**, 11 §9.4 row 1 | §6.2 |
| **D-03** | all availability regimes | C | the availability block | — |
| | Grammar R's five rate cases + session fee | C | 11 §13.3 | — |
| | offline | N | offline chip | §7.1 |
| | signed-out | C | heart / bay-alert open S-01 | — |
| | not-at-station | **I** | **inert rows + StateLine**, 11 §12.1 | §4.4 |
| | uncached-hero | **I** | **Placeholder** at **1078 × 612 px** (10 §7.7, not file 11's stale 1076 × 620 — §0.4) | §6.2 |
| **D-04** | signed-in / signed-out | C | data | — |
| | membership / no-membership | C | **the card is absent**, 11 §6.3 | §4.2 |
| | app-installed / not / undeterminable | C | card copy, 11 §6.2 | — |
| | offline | N | offline chip | §7.1 |
| **D-05** | signed-in only | C | unreachable otherwise | — |
| | offline | N | values from cache | §7.1 |
| | error-in-place | **I** | **StateLine**, 11 §9.4 | §7.3 |
| **D-06** | providers connected / not | C | value slot [RAISE-D14] | — |
| | sign-out | — | an action | — |
| | **delete-account confirm** | **I** | **§9 — the OS alert** | §9 |
| | offline | N | refusal line, 11 D-06 | §4.4 |
| **D-07** | not-downloaded · downloaded · update | C | value slot | — |
| | **downloading** | **I** | **text percentage only**, [RAISE-D16] | §6.3 |
| | offline (not downloaded) | N | `needs a connection`, row inert | §4.4 |
| | **failed** | **I** | **StateLine + the row is the retry** | §7.3 |
| | synced / not-synced | C | value slot | — |
| **D-08** | granted | C | the row toggles | — |
| | denied | **I** | **inert row + StateLine**, 11 D-08 | §4.4 |
| | signed-out | **I** | **inert row + StateLine** | §4.4 |
| **D-09** | none-selected (default) / selected | C | the trailing check, [RAISE-D17] | — |
| | signed-in (syncs) / signed-out (local) | C | StateLine | §7.3 |
| **D-10** | static | — | — | — |
| **D-11** | populated | C | cards | — |
| | **empty** | **I** | **heading + one StateLine**, 11 §9.4 | §8 |
| | offline | N | cached; Placeholder thumbnails | §6.2 |
| **D-12** | armed | C | rows | — |
| | **empty** | **I** | heading + StateLine | §8 |
| | at-ceiling | **I** | **StateLine replaces the control**, 11 §12.2 | §4.4 |
| | offline | N | a disarm queues | §7.1 |
| **S-01** | idle | — | as drawn | — |
| | **in-flight** | **I** | **buttons inert, nothing else changes** | §6.3 |
| | success (auto-resume) | — | the card dismisses; the action fires | §6.5 |
| | **cancelled** | **I** | **nothing is rendered, deliberately** | §6.5 |
| | **failed** | **I** | **StateLine; the buttons are the retry** | §7.3 |
| | offline | N | StateLine + buttons inert | §4.4 |
| | email path | C | body becomes a field + a StateLine | §6.3 |
| **S-02** | signed-out | C | S-01 opens instead | — |
| | not-at-station | C | the card does not open | — |
| | offline (queues) | **N** | **queued is success**, 11 S-02 | §7.1 |
| | **expired** | **I** | **nothing is shown, "because nothing is true"** | §8.3 |
| **S-03** | — | — | platform action sheet | §9.2 |

### 3.2 Operator app and admin — 12 §10.1 / §10.2

| Screen | State as named | Kind | Rendered by | § |
| --- | --- | --- | --- | --- |
| **O1** | idle | — | as drawn | — |
| | in-flight · failed | **I** | as S-01 | §6.3, §7.3 |
| | resuming a hand-off | C | `pendingIntents[]` | — |
| **O2** | loaded | C | rows | — |
| | **loading** | **I** | **§6.4 — the hole, and its recommendation** | §6.4 |
| | no memberships → O9 | C | **but see §6.4's sequencing rule** | §6.4, §8.2 |
| | offline indicator | N | offline chip, **Regular not ExtraLight** | §7.1, §10 |
| | queued writes (n) | **N** | **queued is success** | §7.1 |
| **O3** | loaded | C | slots | — |
| | offline (photos absent) | N | Placeholder at the hero's geometry | §6.2 |
| | Regime 1 drawn first | C | availability block | — |
| | unpublished (admin-only case) | C | data | — |
| **O4** | idle (nothing touched) | **I** | **inert Save, §4.3** | §4.3 |
| | touched (n) | C | accent fill on the tapped control, 12 §4.3 | — |
| | **saving** | **I** | **§6.6 — recommended deleted; correction owed to file 12** | §6.6 |
| | saved | **I** | **the screen re-derives; that is the confirmation** | §6.6 |
| | queued offline (n) | **N** | count in the sticky bar's left slot | §7.1 |
| | **server-rejected** | **I** | **§7.4 — the hole, and its recommendation** | §7.4 |
| | single bay / plug | C | availability-display law 6 | — |
| | `OTHER` plug | C | `Other plug` projection | — |
| **O5a** | idle | — | as drawn | — |
| | **editing** | **I** | **§5.3 — the focused row** | §5.3 |
| | saving · saved | **I** | as O4 — §6.6 | §6.6 |
| **O5b** | idle | — | as drawn | — |
| | **submitted** | **I** | **§3.3 — unbuildable; no entity, [RAISE-OA-5]** | §3.3 |
| **O6** | list | C | rows | — |
| | **empty** | **I** | heading + StateLine, CTA stays | §8.2 |
| | **inviting** | **I** | **§3.3 — blocked on [RAISE-OA-6]** | §3.3 |
| | **revoke confirm** | **I** | **§9 — the OS alert** | §9 |
| **O7** | loaded | C | rows | — |
| | **metric unavailable** | **I** | **StateLine, not an empty state** | §8.5 |
| **O8** | loaded · offline | C / N | rows / chip | §7.1 |
| | queued-writes row (non-interactive) | **N** | a readout; **queued is success** | §7.1 |
| **O9** | single state, not an error | **I** | **the one card-shaped empty state** | §8.2 |
| **A1** | idle · failed | **I** | as S-01 | §6.3, §7.3 |
| | authenticated-but-refused (`isStaff` false) | **I** | **StateLine; authorisation, not authentication** | §7.5 |
| **A2** | loaded · filtered · draft vs published | C | table | — |
| | **empty** | **I** | heading + StateLine | §8.2 |
| **A3** | new · editing · saved | **I** | §5.4, §6.6 | §5.4 |
| | **invalid (length / NOT NULL)** | **I** | **§7.6 — prevention first, then a naming line** | §7.6 |
| **A4** | ≥1 bay · bay with 1..N connectors | C | nested editor | — |
| | **delete blocked** | **I** | **terminal refusal — but the reason cannot be written until [RAISE-OA-14]** | §4.4, §12 |
| **A5** | new · editing | **I** | §5.4 | §5.4 |
| | **CHECK violation · non-vector icon rejected** | **I** | **§7.6** | §7.6 |
| **A6** | active · revoked | C | table | — |
| | **pending** | C | **blocked on [RAISE-OA-6]** | §3.3 |
| **A7** | 0 photos (blocks publish) | **I** | empty + the A8 checklist names it | §8.2 |
| | ≥1 | C | grid | — |
| | **reordering** | **I** | **§3.3 — an eighth state; not designed here** | §3.3 |
| **A8** | draft (unmet items named) | **I** | **the checklist *is* the terminal refusal** | §4.4 |
| | publishable · published · unpublished | C | data | — |
| | **unpublish confirm** | **I** | **§9, with the snapshot caveat in the copy** | §9.4 |
| **A9** | list · filtered · new report | C / I | table / the write form | §7.6 |
| **A10** | — | — | **no entity ([RAISE-OA-6])** | §3.3 |
| **A11** | loaded · metric unavailable | C / I | as O7 | §8.5 |

### 3.3 The three states this pass does not define — declared, not hidden

The ticket's rule is that no screen may name a state this pass does not define.
Three do, and in every case the reason is upstream of design:

| Named by | State | Why it is not defined here |
| --- | --- | --- |
| **A7** | `reordering` | Drag-in-progress is an **eighth** interaction state. The reference contains no reorder handle and no drag affordance of any kind (12 §1). It exists on **one admin screen**, the admin is not governed by 1:1 (12 §7), and designing a drag state for the phone apps on the strength of one web screen would put an unmeasured interaction into `packages/ui` that nothing native consumes. **Recommendation: A7 uses whatever the console's own grid ships; declared as an admin-native behaviour, not a token.** [RAISE-S-22] |
| **O5b** | `submitted` | A screen cannot render *submitted* against a store that cannot record it. `Report` is availability-only and there is no `RateFlag` — **[RAISE-OA-5]**. Any state design here would be designing the feedback for a write that does not happen. |
| **O6 / A6** | `inviting`, `pending` | `Membership` is `(userId, stationId, role)` and an invitee has no `userId` — **[RAISE-OA-6]**. The in-flight and pending appearances are specifiable the moment `Invitation` exists and not before; §6.3's rule applies to them unchanged when it does. |

**A10 (Audit)** names no state and has no entity; noted for completeness.

---

## 4. Disabled — the honest answer is that EV Guide has none

The hardest of the seven, and the one that deserves the most words, because in
a palette with one text colour, no opacity ramp and a 1.75 : 1 surface range,
a de-emphasised-but-present control has **literally nothing to say with**.

### 4.1 The proof that absence is already the product's grammar

Five places where the product, before this ticket, already answered an
impossible action without greying anything:

| # | Where | What it does | Cited |
| --- | --- | --- | --- |
| 1 | The hosting card, no membership | **absent entirely** — *"a **disabled** card would advertise a door with no handle. Absence is the only honest rendering."* | 11 §6.3 |
| 2 | O9, no memberships | **offers no action, deliberately** — no self-serve path exists, so a button would lie | 12 §3/O9 |
| 3 | The bay-watch slot, action impossible | **the reason replaces the control in place** — ticket 30's own amendment: *"a refusal with a reason in the row's text, never a disappearing control"* | 11 §12.2 |
| 4 | A connector row, not at the station | **non-interactive row plus a line of body copy**, never a hidden control | 11 §12.1 |
| 5 | The publish gate | **the checklist with the unmet items named** — the reason, not a greyed button | 12 §A8 |

And one structural fact that makes all five cheap: **the settings row carries no
trailing affordance at all** (10 §7.6 — no chevron, no disclosure). A row that
does nothing is *visually indistinguishable* from a row that does. Removing a
row's interactivity therefore costs nothing visually, which is precisely why
the product can afford to do it five times without anyone noticing a missing
state.

### 4.2 The rule

> **There is no disabled state and no disabled token. Nothing is greyed, ever,
> because there is no grey to grey it with.** An action that cannot be
> performed takes exactly one of three answers, chosen by **who can satisfy the
> precondition and when**:
>
> **(a) Absent.** No path exists for this account or role, ever. The element is
> not drawn. *(hosting card without a membership; O6 and O7 without an `owner`
> edge; O9's action.)*
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
> running.)*

**Why (b) splits by component, and it is a derivation not a preference. [d]**
A settings row is a **label first and an affordance second** — 10 §7.6 gives it
no trailing mark, so its interactivity was never visible. A CTA-geometry
control is 46 pt of fill and **nothing but an affordance**; there is no reading
of it in which it is a label. So a row that cannot act is still a true
statement, and a 46 pt slab that cannot act is a lie about a tap target — which
is 11 §12.2's own sentence, now with the reason it is true.

### 4.3 The two places absence does not work, named

**O4's `Save` at zero touches.** 12 §4.4 rule 4 already rules it: *"At zero
touches the CTA renders in `color.surface` and does nothing; at ≥1 it takes
`color.accent`."* This file adopts that unchanged and supplies the
justification it lacked — the operator's **next tap on this screen** enables it,
so it is case (c) and not a lie. Absence fails here for two concrete reasons:
the sticky bar would **reflow on the first tap**, moving the target the operator
is aiming at; and the label is the operator's readout of the size of the claim
they are about to make (`Save 3 updates`), which is a safety feature of the
screen, not decoration.

**One collision this creates, which 12 §4.4 does not name. [d]** On O4,
`color.surface` `#393939` already means *an unselected but fully tappable
control* — it is the resting fill of all three buttons in the control row
(12 §4.3). The inert Save is the same fill on the same screen. **The fill
cannot carry the distinction, so the label must.**

| O4 Save | Fill | Label |
| --- | --- | --- |
| Zero touches (inert) | `color.surface` `#393939` [m, 10 §10.1] | **`Save`** — no count [INVENTED, §12/S-5] |
| ≥1 touch | `color.accent` `#C7FC2F` [m] | `Save 3 updates` [12 §4.4] |

The `Save`/`Save N updates` pair is a derivation from 12 §4.4's own count rule,
not a new string family, but the zero-touch word itself is invented and is
routed to `packages/domain` alongside [RAISE-D23].

**S-01's provider buttons while a flow is running.** 11 S-01 already rules it:
*"The buttons become non-interactive; nothing else changes."* Absence fails
because removing them mid-flow empties the card. Adopted; see §6.3 for why
"nothing else changes" is the right answer rather than a gap.

### 4.4 Every screen tested against the rule

| Would conventionally be disabled | Rule | Answer | Already ruled? |
| --- | --- | --- | --- |
| Hosting card, no membership | (a) | absent | 11 §6.3 ✓ |
| O6 / O7 in a non-owner's `⋯` menu | (a) | the item is not in the menu | 12 §3.0 ✓ |
| O9's "request access" | (a) | no action offered | 12 §3/O9 ✓ |
| Bay-watch at the ceiling / already free | (b) CTA | StateLine replaces the control | 11 §12.2 ✓ |
| Connector row, not at the station | (b) row | inert row + StateLine | 11 §12.1 ✓ |
| `Bay alerts`, permission denied | (b) row | inert row + StateLine + `System settings` row | 11 D-08 ✓ |
| `Bay alerts`, signed out | (b) row | inert row + StateLine | 11 D-08 ✓ |
| `All of Rwanda`, offline | (b) row | `76 MB · needs a connection`, row inert | 11 D-07 ✓ |
| `Delete account`, offline | (b) row | refusal line | 11 D-06 ✓ |
| A8 `Publish` before prerequisites | (b) | the checklist names the unmet items | 12 §A8 ✓ |
| A4 delete a bay / connector | (b) | **the reason cannot be written yet** — [RAISE-OA-14] | **no — §12/S-19** |
| O4 `Save`, zero touches | (c) | inert, label without count | 12 §4.4 ✓ + §4.3 here |
| O5a `Save`, no edits | (c) | inert, unchanged | **new here** |
| S-01 / O1 providers, in flight | (c) | inert, unchanged | 11 S-01 ✓ |
| S-01 / O1 providers, offline | (b) + (c) | StateLine **and** inert — the reason is not satisfiable here, but the buttons stay because the card would otherwise be empty | 11 S-01 ✓ |
| O6 `Invite operator`, offline | (b) or queue | **unspecified, and unspecifiable** until `Invitation` exists — [RAISE-OA-6] | **no — §12/S-11** |
| The heart, signed out | none | **fully live** — it opens S-01 and auto-resumes | 11 §10 ✓ |
| `Directions`, any state | none | **never gated, ever** | ADR-0003 amended ✓ |
| `My plug` rows | none | always live; ungated | ADR-0003 amended ✓ |

Two rows in that table are **not** answered, and both are blocked on a model
gap rather than on a design decision. That is the honest result of the test.

### 4.5 What this costs

- **A control that has left the screen has no discoverability.** A driver who
  never sees a bay-alert control cannot learn that bay alerts exist. Mitigated
  by (b) being the default for anything the driver could plausibly reach —
  absence (a) is reserved for roles the human cannot obtain by any route.
- **Rule (c) produces a control that looks live and is not.** For up to one tap.
  This is the smallest amount of dishonesty available, and it is bounded because
  the enabling action is on the same screen.
- **The rule spends copy where other systems spend colour.** Every (b) case is a
  string, every string is [vocab]-adjacent, and §8.4's discipline applies to all
  of them.

---

## 5. Focused — very nearly a non-state, and one place where it is not

### 5.1 What focus means in this product

| Surface | Focus concept | Verdict |
| --- | --- | --- |
| Driver app, operator app | Which text field is being edited. There is at most one, and it lives in a card or a pushed screen. There is no keyboard navigation, no pointer, no hover. | **Focus = the caret and nothing else** |
| Accessibility focus (VoiceOver / TalkBack) | The OS draws its own focus indicator over the app's pixels | **Not EV Guide's to style, and must not be suppressed** |
| Web admin | The browser draws `:focus-visible` on every focusable element by default; keyboard traversal of a form is a real workflow (A3, A5) | **Keep the default. Do not restyle it.** |

### 5.2 The native rule

> **A focused input is identical to an unfocused input except for its caret.**
> The only channel the palette could add is a surface swap at 1.08 : 1 (§1.3),
> which is not a state, and the accent is spent on selection (11 §12.3).
>
> **The caret takes `color.accent`** — `selectionColor` on Android,
> `tintColor` on iOS. [d] — a measured token (10 §10.1) applied to a platform
> property, which introduces no new value.

Stream 2 owns the input's resting appearance ([RAISE-D21]: built from the
feature-chip surface, `#393939`, radius 10 px, height 105 px). This file adds
only the caret colour and the statement that the container does not change.

### 5.3 The one place this is not good enough — O5a

O5a is the **only native screen with more than one field**: one rate per
Connector, and `rateCoverage` is denominated in plugs, so eight identical rows
is a normal site (12 §3/O5). A caret in one of eight identical rows, with the
keyboard covering the lower half of the screen, is not enough to say which rate
is being edited.

**Recommendation — the edited row takes `color.surface` `#393939` as a
full-row fill, at the row's own measured box (176 px pitch, divider to divider,
10 §7.6).** [d] from two measured values; **[INVENTED]** as a relationship —
the reference has no focused row. Contrast **1.62 : 1** (§1.3), which is the
largest swap in the system and still below 3 : 1.

**Why 1.62 : 1 is acceptable here and nowhere else, stated rather than assumed.**
12 §3/O5 rules that *"a rate is a **declaration about policy** — the owner knows
it without looking at anything"*, which is why bulk apply is correct on O5a and
forbidden on O4. The same sentence settles the light: **O5a is the one write
screen in the product that is not performed standing at a charger.** A weak
value channel is survivable at a desk and is not survivable in §10's condition.
This is the only place in this document where a sub-threshold swap is
recommended, and it is recommended because of a property of the task, not a
property of the palette.

### 5.4 The web admin

- **Do not suppress the browser's focus ring.** It is drawn by the platform,
  costs nothing, and 1:1 does not govern the admin (12 §7).
- **If it is restyled, `size.hairline` is a trap.** 10 §10.3 gives it as
  **2 px = 0.67 pt** — a value measured on a **@3× capture**. Porting `2` into
  CSS pixels yields a ring three times heavier than the reference's hairline.
  The correct port is 0.67 pt ≈ 1 CSS px. [d] — named because the whole token
  table is @3× px and the admin is the one consumer that is not.
- **The admin will grow a hover state by default**, from whatever component
  library the BWEZE console shell ships. It has no measured source and 1:1 does
  not govern it. Named so it is a decision rather than a default. [RAISE-S-12]

---

## 6. Loading and in-flight — extending 11 §9.4, not restarting it

### 6.1 What §9.4 already fixes

11 §9.4 is the global vocabulary and it is settled by one measured fact — the
`02` profile avatar's `#3E3E3E` empty fill inside its lime ring. This file does
not restate the table; the rows it consumes are: **media not yet available →
`#3E3E3E` block at the target's exact geometry and radius** · **additive marks
→ absent then present** · **structural content → never absent** · **empty list →
heading + one line of body copy** · **error → body copy in place, `#FFFFFF`** ·
**progress → text only** · **motion → none, anywhere**.

Everything below is what §9.4 does **not** cover.

### 6.2 `Placeholder` — the component §9.4 implies but does not name

| Property | Value | Source |
| --- | --- | --- |
| Fill | `color.surfaceRaised` `#3E3E3E` | 10 §10.1 [m] |
| Geometry | **the target's exact frame** — hero **1078 × 612 px**, thumbnail 300 × 300 px, avatar ⌀316 px | 10 §7.7, §10.5 [m] — **not** file 11's 1076 × 620, see §0.4 |
| Radius | **the target's own** — `radius.image` 30 px for media, `radius.circle` for avatars | 10 §10.4 [m] |
| Motion | **none.** No shimmer, no pulse, no cross-fade | 10 §9, §12; 11 §9.4 |
| Duration | **indefinite.** A photo that never loads stays a block | 11 §9.4 [held] |

**The last row is a decision, not an omission.** A placeholder that eventually
becomes an error implies a retry the driver cannot perform on a photo, and
photos are ADR-0007 lazy-loads whose absence costs nothing. Contrast **1.75 : 1**
against `color.bg` — see §10.

### 6.3 In-flight — the rule, and how small the set actually is

> **An in-flight write renders nothing. The control keeps its appearance and
> stops accepting taps (§4.2 case (c)). There is no spinner, no progress ring,
> no skeleton animation and no toast, because none exists in the reference and
> 11 §9.4 forbids introducing one.**
>
> **Where an action has latency the human must wait through, the *copy* carries
> it and nothing else does** — extending [RAISE-D16]'s text-only ruling from
> D-07's download to every waiting state in the product.

The set of genuinely in-flight actions, enumerated honestly:

| Action | In-flight rendering | Basis |
| --- | --- | --- |
| Provider auth (S-01, O1, A1) | **none** — the OS takes the whole screen; the buttons are inert behind it | 11 S-01 ✓ |
| Magic-link email | **the body copy is the state**: `Send me a link` → `Check your email. The link signs you in.` | 11 S-01 ✓ |
| `All of Rwanda` download | **text percentage in the value slot**, `42%` | 11 D-07, [RAISE-D16] ✓ |
| Route resolution (D-02) | **the chip is absent** until resolved | 11 §7.3 ✓ |
| Any report or availability write | **§6.6 — there is no in-flight state, because the write is local** | new here |
| O2's first membership fetch | **§6.4 — the hole** | new here |
| O6 invite | blocked on [RAISE-OA-6] | §3.3 |
| Admin form submits | web; 1:1 does not govern; §6.7 | new here |

That list is the product's complete set of waits, and four of the eight rows
were already ruled. The design work is the two marked *new*.

### 6.4 The hole: O2 has a cold-start loading state the driver app cannot have

**The finding.** ADR-0007 makes the driver app architecturally immune to a
first-paint loading state — a bundled directory snapshot ships inside the
binary, so *"pins paint immediately"* and *"There is no loading state for the
directory, ever"* (11 D-01). **The operator app inherits none of that.** 12 §2:
the app has no map and *"the station list is a **membership query**"*. There is
no bundled membership snapshot and there cannot be one — memberships are
user-scoped and the binary is public.

So **O2, the operator app's root, has a real cold-start period with nothing to
draw**, and 12 §10.1 names the state (`loading`) without specifying it.

**Why it is worse than an ordinary loading state. [d]** O2's zero-row state is
**O9** — an explanatory hosting card saying the account has no assigned stations
(12 §3/O9). A loading O2 and a permanent-no-access O9 are two screens with the
same content: nothing. On a slow link the operator is shown a confident,
explanatory statement that they hold no memberships, before the query that
would contradict it has returned.

**Recommendation, in two parts. The second part is the important one and it
costs nothing.**

| # | Rule | Class |
| --- | --- | --- |
| **1** | O2 paints **`Placeholder` rows at the row container's exact frame** — the `§7.10` hosting-card geometry O2 uses as its row container (1128 × 334 px, `radius.card` 13 px), filled `color.surfaceRaised` `#3E3E3E`, static | [d] from 10 §7.10 + §10.1; **the use is [INVENTED]** — §9.4 applies `#3E3E3E` to *media*, and extending it to a whole row is this file's step |
| **2** | **Row count = the last known membership count**, persisted from the previous session; **1 on a true first run** | the count is data, not a dimension; the `1` is **[INVENTED]** |
| **3** | **O9 may not be drawn until the membership query has actually returned zero.** A cache miss, a pending request and a failed request all render (1), never O9 | a sequencing rule — **no pixels, no tokens, no invention** |

Rule 3 is the one that matters. It is free, it is testable, and without it the
operator app tells a new owner they have no stations for as long as the network
takes.

**Cost of rule 1.** At 1.75 : 1 the placeholder rows are nearly invisible in
sunlight (§10), which means outdoors, **loading and empty look the same anyway**
— rule 3 is doing the real work and rule 1 is doing very little. Stated rather
than smoothed. [RAISE-S-8]

### 6.5 Two states that render nothing, deliberately

Both are already ruled and are restated here only because a coverage matrix
that silently skipped them would look like a hole:

- **S-01 `cancelled`** — *"card dismisses; nothing is lost; no message"*
  (11 S-01). A driver who backed out of a sign-in is not told they backed out.
- **S-02 `expired`** — a queued report past its 2 h window is dropped and
  *"Nothing is shown, **because nothing is true**"* (11 S-02).

Both are correct and both are the same principle: **a state with no true
statement behind it renders nothing.** That principle is what §8.4 enforces on
empty copy.

### 6.6 `saving` should not exist — a correction owed to file 12

12 §4.5 and §10.1 list **`saving`** and **`saved`** as distinct O4 states, and
12 §10.1 repeats the pair for O5a. Under ADR-0007 they cannot be distinguished
by the operator and must not be:

1. The write is **local**. 12 §4.7: the surface is *"fully functional offline"*
   and reports queue with their original `capturedAt`.
2. `capturedAt` and `capturedLocation` are stamped **at the connector's tap**,
   not at Save (12 §4.4 rule 3), so Save has no timestamp work to do.
3. An operator in a basement car park is **the modal case, not the edge case**
   (12 §2). A `saving` state that waits on the server is, for that operator, a
   wait that never ends — and the reference has no spinner to draw it with
   anyway.

> **Recommendation: delete `saving` from 12 §4.5 and §10.1, and from O5a.** Save
> is a local commit. The confirmation is **the screen re-deriving** — exactly
> S-02's already-ruled pattern: *"The confirmation is the report's own effect…
> No toast, no snackbar — the reference has neither"* (11 S-02).
>
> `saved` therefore collapses into **idle with the derived lines changed**,
> which also satisfies 12 §4.4 rule 1 (nothing is preselected, on every open).
> `queued offline (n)` becomes the only post-save state, **online and off
> alike** — which is honest, because online and off differ only in how long the
> queue is non-empty.

**One thing this does not decide.** Whether O4 dismisses on Save or stays open
is a *navigation* question 12 does not answer, and this pass may not extend the
navigation vocabulary (§0). Both readings work under the rule: dismissing makes
O3's availability block the confirmation; staying makes O4's own derived bay
header lines the confirmation. **Routed to file 12, not decided here.**

### 6.7 The admin

The admin is a web SPA and 1:1 does not govern it (12 §7). It inherits the
*rule* — in-flight renders nothing, latency is carried by copy — because the
alternative is a spinner in the console that no native surface has. But the
console shell's own submit affordances are web-native and this file does not
tokenise them. Named so the divergence is a choice.

---

## 7. Errors, retry and validation — and the three things that are not errors

### 7.1 The distinction ADR-0007 forbids getting wrong

| Condition | What it is | Rendering | Never |
| --- | --- | --- | --- |
| **Offline** | **a normal mode** | the offline chip — feature-chip geometry, `#393939`, no border, 11 §9.1 | an error screen, a banner, a modal, a red anything, or any string reading `No connection` / `Error` / `Offline mode` |
| **Queued** | **success** | a count — O4's sticky-bar left slot, O8's non-interactive row (12 §4.7, §O8) | a warning, a badge, a retry button, or a control implying the send order is the operator's to change |
| **Failed** | **the only error** | §7.3's StateLine, plus a retry that is always the original control | a colour |

ADR-0007: *"Offline gets a quiet indicator; it is a normal mode, never an error
screen."* This is the one place where getting the state design wrong turns a
routine Rwandan connectivity dip into a failure surface, and the whole point of
separating the three columns above is that **two of them look like problems and
are not**.

### 7.2 Three failures that are not errors, restated so nobody adds one

- **Route resolution fails** → the chip degrades to `~2.4 km straight line`
  (11 §7.3). Not an error; a less precise true statement.
- **The directory has not synced** → `Not synced`, and *"Never *out of date*:
  the snapshot is a complete listing"* (11 D-07).
- **A photo does not load** → a `Placeholder`, indefinitely (§6.2).

### 7.3 `StateLine` — the error component, which is one line of body copy

11 §9.4: *"Any error → body copy replaced in place, `#FFFFFF`. **There is no
error colour in the token set** and adding one would be a deviation."* That is
the whole component:

| Property | Value | Source |
| --- | --- | --- |
| Type | `type.body` 13 pt · cap 27–28 px · line-height 15 pt | 10 §4.2, §4.3 [m] |
| Weight | **Regular** in the operator app, **ExtraLight** in the driver app | 10 §4.5 [m]; ADR-0009 §4's own mitigation, extended in §10 |
| Colour | `color.text` `#FFFFFF` | 10 §10.1 [m] |
| Width | the container's content width | 10 §5.1 [m] |
| **Placement** | **replaces the body copy of the block it belongs to**, or is inserted **directly above the control it refers to at `space.blockGap` 39 px = 13 pt** | 10 §10.3 [m]; **the placement rule is [d]** |
| Icon, colour, border, background | **none** | 10 §9, 11 §9.4 |

**Retry is always the original control, never a new one.** D-07's failed
download reads `Download didn't finish. Tap to try again.` and *the row is the
retry* (11 D-07); S-01's failure leaves the provider buttons in place and *they
are the retry* (11 S-01). Generalised:

> **No `Retry` component exists in `packages/ui`.** Where the original control
> is still on screen, it is the retry. **Where it is not, there is no retry
> path** — which is not a gap to fill with a button but a fact that identifies
> exactly one case, §7.4.

### 7.4 The hole: a server-rejected queued write has no surface

12 §4.5 names `server-rejected` and 12 §5.2 gives it its concrete cause:
*"Membership revoked while open… queued writes for that station are rejected
server-side on receipt (the client cannot know) and surfaced once."* **Nothing
specifies how they are surfaced**, and it is the one place in the product where
a human must be told that something they did did not happen.

Four candidate homes, and why three fail:

| Home | Fails because |
| --- | --- |
| Silent drop | The operator believes a claim they made is on the map. This is the one dishonesty the product cannot absorb. |
| A push notification | *"Nothing pushes to an operator in v1"* (12 §O8). |
| O8's queued-writes row | It is *"a readout, not a destination"* by design (12 §O8); giving it a destination contradicts the reason it exists. |
| **In place on O3/O4 for that station** | **Fails for exactly the case that produces it** — the membership was revoked, so the station is gone from O2 and there is no station surface left to carry the message. |

> **Recommendation: one `StateLine` above O2's rows, shown once, cleared by any
> interaction.** O2 is the only screen that survives the revocation, and it is
> the screen the operator lands on.
>
> **Copy: `3 updates for SP Remera were not accepted.`** [INVENTED] — routed to
> `packages/domain` with [RAISE-D23]'s report-action labels, not authored in the
> app.
>
> **Two copy constraints that are not optional.** It must **not assert a reason
> it cannot know** (the client genuinely cannot know whether the cause was a
> revocation, a clock, or a schema rejection), and it must clear
> `docs/availability-display.md` **§2.2b** — in particular it may not say
> anything about what was or was not *reported*.

This is the single riskiest recommendation in the document: it is one invented
string on a screen nobody has drawn, telling a human their work was discarded.
It deserves the founder's eye rather than a design decision. [RAISE-S-9]

### 7.5 A1's refusal is authorisation, not authentication

12 §A1: a non-staff account *"authenticates successfully and is then refused —
the refusal is authorisation, not authentication, and must read that way."*
Under §7.3 that is a `StateLine`, and the copy discipline is that it must not
imply the credentials were wrong. Named because the default string every auth
library ships says exactly the wrong thing.

### 7.6 Validation

**Rule 1 — prevention before correction, wherever the input can enforce it.**
The admin already does this: 12 §A3 gives `name` a *"counter, hard stop"* at 28
characters. Generalised: a field that cannot accept an invalid value cannot
produce an invalid state, and every prevented error is one that needs no
channel to render.

| Constraint | Preventable? | How |
| --- | --- | --- |
| `name` ≤ 28, `nameShort` ≤ 18, `shortName` ≤ 17 | **yes** | counter + hard stop, 12 §A3 |
| `markerLabel` 1–3 `CHECK` | **yes** | hard stop at 3 |
| `ratePerKwhRwf`, `powerKw`, `voltage` | **yes** | numeric input accepts no letters (stream 2) |
| `type` — OCPI open enum | **yes** | a select, never free text, 12 §A4 |
| `owner_id` NOT NULL | **yes** | a select over the bounded Owner set, 12 §A3 |
| `geo` NOT NULL | **no** | a map pick is an act, not a keystroke |
| `icon` must be a vector | **no** | known only after the file is chosen |
| An email's shape | **no** | — |
| A8's publish prerequisites | **no** | they are about children, not fields |

**Rule 2 — where prevention is impossible, the error is a `StateLine` placed by
§7.3, and the submit control is not disabled.** It stays (§4.2 case (c)) and the
line says what is missing. This is A8's checklist pattern applied to fields,
which is the admin's own already-ruled behaviour rather than a new one.

**Rule 3 — no inline red, no field outline, no icon, no per-field mark.** There
is no error colour (11 §9.4) and the input has **no border** to colour — it is
built from the feature-chip surface, which 10 §7.5 measures as `#393939` with
**border: none**.

**The cost, stated plainly: a field in error is pixel-identical to a field not
in error.** Only the line says otherwise. On a six-field admin form that is a
scan, not a glance.

**The mitigation available inside the measured system is copy, and it is
mandatory: the line names the field.** `Owner is required.` — never
`Required.`, never `Please fix the errors below.` A generic line in a system
with no per-field mark is unactionable. [RAISE-S-10]

---

## 8. Empty

### 8.1 The rule §9.4 already sets

11 §9.4: *"Empty list → section heading + one line of cap-28 ExtraLight body
copy. **No illustration, no button, no icon.**"* Adopted unchanged. The
component is `StateLine` (§7.3) under the screen's existing heading — **empty
and error are the same component doing two jobs**, which is why the token set
needs neither an `EmptyState` nor an `ErrorText`.

### 8.2 The one exception, and why it must not be generalised

**O9 uses the hosting card**, not a line — an 85.7 pt `#3E3E3E` tile, a lime
glyph, a 17 pt Bold title and 13 pt body, centred on `color.bg` (12 §3/O9).
Every other empty state gets a line.

> **The rule that distinguishes them: an empty *list* gets a line. An empty
> *app* gets the card.** [d]
>
> O9 is not a list with no rows — it is the terminal state of the whole
> operator app for that account, reached by a human who installed a binary and
> signed in and will see nothing else. **Only O9 qualifies**, and the rule
> exists so that nobody puts a card on D-11, D-12, O6 or A2.

| Empty state | Rendering | Ruled where |
| --- | --- | --- |
| D-11 Saved | heading + StateLine: `Stations you save appear here. Tap the heart on any station.` | 11 D-11 ✓ |
| D-12 Alerts | heading + StateLine: `No alerts set.` + the instruction line | 11 D-12 ✓ |
| **O9** | **the hosting card** — the one exception | 12 §3/O9 ✓ |
| O2 while loading | **not empty** — §6.4 rule 3 | new here |
| O6, no operators | heading + StateLine; **`Invite operator` stays** — it is the screen's whole purpose | **new here**, copy [INVENTED] |
| A2, no stations / A7, no photos | heading + StateLine; A7's absence is also named by A8's checklist | **new here** |

### 8.3 An empty state that renders nothing

S-02's `expired` (§6.5). Cited again here because it is the cleanest statement
of the principle §8.4 formalises: *"Nothing is shown, **because nothing is
true**."*

### 8.4 The copy discipline — the one rule, and the test

> **An empty state describes what the list holds. It may never describe what
> has or has not happened.**

`Stations you save appear here.` is a statement about the list. `No alerts set.`
is a statement about state. **Any string asserting that something has or has not
been reported is a statement about history**, is false under the offline
override — which yields `Unknown` from a thirty-second-old report — and is
forbidden. The exact strings are enumerated in one place and this file does not
reproduce even an example of one, because a document that quotes the list to
explain the list is how four copies of it came to exist during ticket 17.

**The forbidden list is not restated here, not paraphrased here, and not
sampled here. It lives in exactly one place:
`docs/availability-display.md` §2.2b.** Every string this file proposes —
§4.3's `Save`, §7.4's rejection line, §8.2's O6 and A2 lines — is subject to it,
and the enforcement is already specified as a test: SPEC.md §13 guarantee 2, *"a
grep test over the emitted vocabulary finds no forbidden string, in any surface,
fixture or component."* This file adds no second list and no second home.

### 8.5 `metric unavailable` is not an empty state

O7 and A11 name it. It is a metric with **no data source** — [RAISE-OA-10] for
views and direction taps, [RAISE-OA-11] for uptime. Ticket 11's instruction is
to *"say so plainly, in one line on the screen"*, which is a `StateLine` in the
row's own place, not an empty list. The distinction matters: an empty list
implies data will arrive; a missing metric implies nothing, and 12 §6 is
emphatic that the screen must not imply the missing numbers are coming.

---

## 9. Destructive confirmation

### 9.1 The problem the palette creates

The real destructive acts are: **delete account** (D-06), **revoke a
membership** (O6, A6), **unpublish a station** (A8), **delete a bay or
connector** (A4, blocked on [RAISE-OA-14]).

There is **no destructive treatment in the reference and no red anywhere in the
palette**, and [RAISE-D15] already recommends carrying the weight in the copy.
Suppose the confirmation is built on the floating card. Its measured geometry
is available:

| Property | Value | Source |
| --- | --- | --- |
| Frame | inset `space.pageMargin` 64 px left and right; **width 1076 px = 358.7 pt** | 10 §7.4, §10.5 [m] |
| Radius | **14 px = 4.7 pt, all four corners** | 10 §7.4, §10.4 [m] |
| Fill | `#121212` — the page background | 10 §7.4 [m] |
| Shadow / blur / scrim | **none**, all four sides | 10 §9 [m] |
| Padding | 64 px = 21.3 pt | 10 §10.3 [m] |
| Drag handle | 180 × 13 px `#262626`, r 6.5, centred, 25 px below the top | 10 §7.4 [m] |
| Button width | **948 px = the card's inner box** — 1076 − 2 × 64 | [d] from 10 §7.4 + §10.3; **file 11's 950 is stale, §0.4** |
| Button geometry | 138 px tall, **r 13 px**, 27 px apart | 10 §7.1, §10.4, §10.3 [m] — **file 11's 13.5 is stale, §0.4** |
| Bottom offset | 103 px = 34.3 pt above the screen bottom | 11 [RAISE-D34], recommended |

**And then it fails.** The destructive button cannot be `color.accent` — the
accent means *go*, *selected*, *yours*, and it is the fill of `Let's find a
charger`. It cannot be red. So it is `color.surface` `#393939` with a
`color.text` label. **`Cancel` is also `#393939` with a `#FFFFFF` label.** The
result is two identical 950 × 138 px slabs, one of which deletes the account,
distinguished by nothing but their words. In §10's daylight, by nothing at all.

### 9.2 The resolution, which is not this file's invention

**The product already delegates destruction to the platform, in two places, and
menus in two more:**

| Surface | Delegated to the OS | Cited |
| --- | --- | --- |
| `Delete account` | *"opens the platform confirmation, then deletes"* | 11 D-06 |
| `Delete downloaded maps` | *"delete, with a platform confirmation"* | 11 D-07 |
| D-03's `⋯` | the platform's own action sheet | 11 S-03 |
| O3's `⋯` | the same, adopted so one product has one menu mechanism | 12 [RAISE-OA-15] |

> **Recommendation: every destructive confirmation in both native apps is the
> platform's own alert** — `UIAlertController` with
> `UIAlertAction.Style.destructive` on iOS, the equivalent Material dialog on
> Android. This is not a new mechanism; it is the mechanism files 11 and 12
> already chose for the two deletes that exist and for both menus, applied to
> the two that were unspecified (revoke, unpublish).

**Three consequences, all declared rather than discovered:**

1. **This is the third OS-drawn surface in the product**, after the action sheet
   ([RAISE-OA-15]) and Apple's sign-in button ([RAISE-D20], a named 1:1
   impossibility). Three is the honest total, and a build that adds a fourth
   should have to say so.
2. **The alert is a visible foreign object** — Apple's and Google's type,
   spacing and button colours, not `packages/ui`'s. That cost is identical in
   kind to the two already accepted.
3. **The only red in EV Guide is the platform's**, drawn by the OS, in exactly
   the place red belongs. The palette's missing destructive colour turns out to
   be a problem only for a component the product does not build.

**It does not extend the navigation vocabulary** (§0 note 4): an alert is
presented by the OS over the current surface, exactly as the action sheet
already is.

### 9.3 The copy discipline — the part that *is* this file's

11 D-06 already carries the model string, and it is the whole rule in one
sentence: `Delete your account? Saved stations and alerts go with it.
Availability you reported stays, without your name.`

> **Title: the question, naming the object.**
> **Body: what goes, and what stays.**
> **The destructive button's label is the verb** — `Delete`, `Revoke`,
> `Unpublish`. Never `OK`, never `Yes`, never `Confirm`.
> **Never a typed confirmation.** There is no text input in the reference
> ([RAISE-D21] is unresolved) and a typed gate would be the only one in the
> product.

**What stays is not decoration — it is the honesty guarantee.** `Report` is
append-only (12 §4.1, §8.5): deleting an account does not delete the
availability that account contributed, and revoking a membership does not
retract the reports made under it. A confirmation that implies otherwise is
false about the model. The strings:

| Act | Body must state | Status |
| --- | --- | --- |
| Delete account | saved stations and alerts go; reports stay, detached | 11 D-06 ✓ |
| **Revoke a membership** | **the operator loses access; the availability they reported stays** | **[INVENTED]** — §12/S-14 |
| **Unpublish a station** | **§9.4** | **[INVENTED]** — §12/S-15 |
| Delete a bay / connector | blocked on [RAISE-OA-14] — deletion has no semantics to describe | — |

### 9.4 Unpublish cannot promise removal

12 §A8: *"Publishing does not reach offline-first users immediately: the bundled
directory snapshot is cut at release time (ADR-0007), so a station published
between releases is visible only to clients that have synced."*

**The same fact runs backwards and nothing has said so.** An **unpublished**
station remains in every client's bundled snapshot until the next release, and
in the cache of every client that has not synced since. A confirmation reading
*this station will no longer be visible to drivers* would be **false for exactly
the offline-first users the product is built for**.

> **The copy must state the delay.** Recommendation: the body says the station
> stops being published now and stays visible to drivers who have not synced
> until they do. [INVENTED] string, [d] fact — routed with the rest.

### 9.5 The admin

`window.confirm` is a foreign object of a worse kind than a platform alert, so
the admin builds the confirmation into the console shell. **A destructive colour
is *available* to the admin** — 1:1 does not govern it (12 §7) — and the
recommendation is nonetheless **not to add one**, for the same reason
[RAISE-OA-13] gives about a muted text tier: a red button in the admin and no
red anywhere in the apps breaks token kinship with `packages/ui` for the sake
of one screen. Named as available and as a founder call, not taken silently
either way.

---

## 10. Outdoor legibility — every state that vanishes in sunlight

ADR-0009 §4 ships dark-only as a **cost, not a deviation**, and names the exact
condition: O4, standing at a charger, equatorial daylight, 2° south. This
section flags every state above whose distinction rests on a value difference
between two dark surfaces. Contrasts are §1.3's.

| State | Channel | Contrast | Verdict |
| --- | --- | --- | --- |
| **Selected vs unselected control** (O4's row) | accent vs surface | **9.57 : 1** | **survives** |
| **Live vs inert Save** (O4) | accent vs surface | **9.57 : 1** + the label | **survives** |
| Saved vs unsaved heart | accent vs `#717171` | 15.52 vs 3.84 on `bg` | **survives** |
| The trailing check (D17) | accent on `bg` | **15.52 : 1** | **survives** |
| The free-bay dot | accent + white ring on the map | 15.52 / 18.73 | **survives** |
| A `StateLine` | `#FFFFFF` on `#121212` | **18.73 : 1** colour — but see the weight note below | **survives, conditionally** |
| **Pressed, on a `#393939` control** | `#393939` → `#3E3E3E` | **1.08 : 1** | **vanishes — indoors too** |
| **Pressed, on a settings row** | `bg` → `#393939` | 1.62 : 1 | **vanishes outdoors** |
| **Focused row** (O5a) | `bg` → `#393939` | 1.62 : 1 | **vanishes outdoors — accepted, §5.3, because O5a is a desk task** |
| **`Placeholder`** | `#3E3E3E` on `#121212` | **1.75 : 1** | **vanishes — so loading and empty look identical outdoors** |
| **The 1 px divider** | `#3E3E3E` on `#121212`, **one pixel** | **1.75 : 1** | **vanishes — §10.2, the serious one** |
| The offline chip | `#FFFFFF` on `#393939` | 11.55 : 1 colour, **ExtraLight at a ~1.7 px stem** | **at risk — §10.1** |

### 10.1 The weight problem, and the mitigation the ADR already licenses

Colour contrast is not the whole story below a certain stroke. 10 §4.5 measures
the ExtraLight class at a **1.68–2.12 px stem** and [RAISE-2] names it as a real
legibility question. ADR-0009 §4 already applies the one mitigation the palette
permits: *"every derived data line uses Regular rather than ExtraLight at
`type.body`."*

> **Recommendation: extend that mitigation from derived data lines to the
> operator app's `StateLine` and to its offline chip.** 11 §9.1 specifies the
> chip's label as cap 32 **ExtraLight** — the quietest labelled object in the
> reference, which is exactly right for the driver app and is the wrong weight
> for the label that tells an operator in a basement that their writes are
> queued.
>
> **Driver app: ExtraLight, unchanged. Operator app: Regular.** [d] — both
> weights are measured (10 §4.5) and the extension is the ADR's own reasoning
> applied to two more runs. Needs a yes. [RAISE-S-17]

### 10.2 The divider is the serious one

O4's structure is bays and connectors separated by **`#3E3E3E`, exactly 1 px**,
full container width (10 §7.6). At **1.75 : 1 and one pixel**, that divider is
the only thing telling the operator which control row belongs to which
connector, and in direct sunlight it is not visible.

**This is not an aesthetic complaint.** An operator who cannot see the row
boundaries taps `Busy` under the wrong connector, and the product's entire
honesty guarantee is that a report describes the gun it names. **A legibility
failure here is a data-integrity failure**, and it is the only one in this
document with that property.

**There is no mitigation inside the measured palette.** There is one divider
colour, one divider weight, and no second surface between `#3E3E3E` and
`#717171` that is not an icon token contradicted by its own twin
([RAISE-OA-13]). The options are all deviations: a heavier rule, a lighter
rule, a surface swap per bay group, or whitespace bought from
`space.settingsRow`. **Raised, not chosen.** [RAISE-S-16]

This lands exactly where ADR-0009 §4 said the evidence would come from: *"The
launch-week survey pass puts studio staff at real chargers using O4 in real
sunlight. That is the evidence a light theme should be commissioned on."* This
file's contribution is to name **what to look at** during that pass — the
dividers first, the placeholders second, press feedback not at all, because
press feedback was never visible anywhere.

### 10.3 The design law that falls out

> **State is carried by the accent, or by copy. Never by a surface swap alone.**

Every row in the top half of §10's table is accent or text. Every row in the
bottom half is a grey-to-grey swap. The law is not a preference; it is §1.3's
arithmetic restated, and it is the single most useful sentence this pass
produces.

---

## 11. What this adds to `packages/ui`

Deliberately small. Three components, three prohibitions, three declarations.

### 11.1 Components

| Component | Props | Behaviour | Values |
| --- | --- | --- | --- |
| **`StateLine`** | `text`, `placement: 'inBlock' \| 'aboveControl'` | Renders one `type.body` line in `color.text`. Serves **error, refusal, empty, metric-unavailable, offline-reason** — five jobs, one component | 10 §4.2/§4.3/§10.1 [m]; `space.blockGap` 39 px for `aboveControl` [m]; **the placement rule is [d]** |
| **`Placeholder`** | `width`, `height`, `radius` | A static `color.surfaceRaised` block at the target's exact frame. **No animation, no timeout, no error transition** | 10 §10.1, §10.4 [m]; **its use on rows is [INVENTED], §6.4** |
| **`PressableSurface`** | `variant: 'surface' \| 'accent' \| 'row'` | Applies §3's press rule **and explicitly disables the platform default** (§11.2) | 10 §10.1 [m]; **the swap itself is [INVENTED], §12/S-1** |

### 11.2 The prohibitions, which are build disciplines and should be tests

1. **No `Spinner`, `ProgressBar`, `ActivityIndicator`, animated `Skeleton`,
   `Toast`, `Snackbar`, `Badge`, `ErrorText`, `DisabledStyle` or `Retry`
   component is built.** Each of the nine either introduces motion (10 §9,
   §12), a colour the token set does not have (11 §9.4), or a component the
   reference does not contain (12 §1).
2. **The platform's default press feedback must be turned off explicitly at
   every call site.** React Native's `TouchableOpacity` ships `activeOpacity`
   `0.2` — **an opacity ramp**, which 10 §10.1 lists as deliberately absent —
   and `Pressable` on Android ships `android_ripple`, which is **motion**, which
   10 §12 found nowhere in the reference. **Doing nothing ships both.** This is
   the single most likely silent deviation in the whole state design, because it
   arrives by default and is invisible in a code review. [RAISE-S-3]
3. **`color.iconMuted` `#717171` may not be used as a disabled, inactive or
   muted token anywhere** ([RAISE-OA-13]). It has one instance and one
   permitted use.

### 11.3 The three OS-drawn surfaces, declared

The platform action sheet (11 S-03, 12 [RAISE-OA-15]) · Apple's Sign in with
Apple button (11 [RAISE-D20]) · **the destructive alert (§9, new here)**. Each
is a visible foreign object and each is exempt from the 1:1 acceptance test by
name, exactly as ADR-0009 exempts the puck and the attribution mark.

---

## 12. Raised

Per the standing rule these are raised, not resolved. Numbered `S-n` so they do
not collide with file 10's `RAISE-n`, file 11's `RAISE-Dn` or file 12's
`RAISE-OA-n`.

**[RAISE-S-1] There is no pressed state and no channel can carry one at
3 : 1.** §1.3: the four surface greys span 1.75 : 1 end to end; the swap a
designer reaches for is 1.08 : 1. The accent cannot be dimmed (no tint), no
opacity ramp exists, and no motion exists.
**Recommendation:** `#393939` controls swap to `#3E3E3E` while pressed; settings
rows take a `#393939` full-row fill; **accent controls get no press treatment at
all**, because the palette has no second accent value and swapping the primary
CTA to `#393939` would make it read as secondary for the duration of a touch.
**Cost:** press feedback is decorative everywhere and absent on the most-tapped
control in the product. **The real feedback is the result of the press**, which
makes latency a design constraint rather than an engineering one: any action
that cannot produce its result within a frame or two needs §6.3's rule, not a
press state.

**[RAISE-S-2] The press swap itself is [INVENTED].** Both tokens are measured;
the *relationship* is not. Nothing in the reference says a pressed surface
becomes the raised surface. **Cost:** one unmeasured relationship, reversible in
one line, and sub-threshold either way.

**[RAISE-S-3] The platform default press feedback is an opacity ramp and a
ripple, and it ships unless it is switched off.** **Recommendation:** a
`PressableSurface` wrapper that no screen bypasses, plus a lint or a test that
fails on a bare `TouchableOpacity`. **Cost:** a build discipline that is
invisible in review and permanent if missed.

**[RAISE-S-4] EV Guide has no disabled state.** §4 proves it against 19 places
and finds two exceptions and two model-blocked gaps.
**Recommendation:** adopt §4.2's three answers — absent, terminal refusal,
transient inert. **Cost:** a control that is absent is a control that cannot be
discovered; mitigated by reserving absence for roles no human can obtain.

**[RAISE-S-5] The inert Save's fill collides with the unselected-control fill on
the same screen (O4).** **Recommendation:** the label carries the state —
`Save` at zero touches, `Save N updates` at ≥1. The zero-touch word is
[INVENTED] and routed to `packages/domain` with [RAISE-D23]. **Cost:** one
string; and an operator who reads fills rather than words sees two `#393939`
slabs meaning different things.

**[RAISE-S-6 — CONTRADICTION] File 12 §4.4's inert Save contradicts file 11
§12.2.** 11 §12.2: *"A control that is permanently untappable is a lie about a
tap target."* 12 §4.4 ships exactly such a control. **They are reconciled by the
word *permanently*** — §4.2's transient/terminal split — but that reconciliation
is this file's and needs a yes. If it is refused, 12 §4.4 rule 4 must change and
O4's sticky bar must reflow on first touch.

**[RAISE-S-7 — CORRECTION OWED TO FILE 12] `saving` should not be a visible
state.** §6.6: the write is local, `capturedAt` is stamped at the connector tap,
and the modal operator is offline. A `saving` state is a wait that, for the
product's own modal user, never ends.
**Recommendation:** delete `saving` from 12 §4.5, 12 §10.1 (O4 and O5a). `saved`
collapses into idle-with-new-derivation, matching S-02's already-ruled
confirmation-is-the-effect pattern. **Cost:** none that this file can find,
which is itself worth a second reader.

**[RAISE-S-8 — HOLE] O2 has a cold-start loading state with nothing to draw, and
it is pixel-identical to O9.** The driver app is immune by ADR-0007's bundled
snapshot; the operator app's root is a membership query with no snapshot.
**Recommendation:** `Placeholder` rows at the row container's measured frame,
count = last known membership count (1 on a true first run, [INVENTED]), **and
the sequencing rule that O9 may not paint until the query returns zero.**
**Cost:** the placeholder is 1.75 : 1 and nearly invisible outdoors, so the
sequencing rule is doing the real work; and `1` is an invented count.

**[RAISE-S-9 — HOLE, and the riskiest call here] A server-rejected queued write
has no surface, and three of the four candidate homes fail for structural
reasons.** The fourth fails for exactly the case that produces it.
**Recommendation:** one `StateLine` above O2's rows, once, cleared by any
interaction; copy names the count and the station and **asserts no reason**.
**Cost:** one invented string on an undrawn screen, and it is the only place the
product tells a human that work they did was discarded. Founder call.

**[RAISE-S-10] Validation has no visual channel: a field in error is
pixel-identical to a field that is not.** No error colour, no field border to
colour (the input's source surface has `border: none`).
**Recommendation:** prevention first (counters, hard stops, numeric inputs,
selects — most constraints are preventable); then a `StateLine` that **names the
field**; the submit control stays live. **Cost:** on a multi-field form the
human scans rather than glances.

**[RAISE-S-11] O6's `Invite operator` has no offline behaviour and cannot have
one until `Invitation` exists** ([RAISE-OA-6]). Whether an invitation queues
like a report or refuses like a sign-in is a model question, not a design one.

**[RAISE-S-12] The web admin will grow hover and focus styles by default**, from
the console shell. 1:1 does not govern the admin, so this is permitted — but it
is a default, not a decision. **Recommendation:** keep the browser's
`:focus-visible` ring unstyled; name any hover treatment explicitly.

**[RAISE-S-13] `size.hairline` is a @3× value and the admin is not a @3×
surface.** 2 px at @3× is 0.67 pt ≈ 1 CSS px. Porting the integer would triple
every hairline in the console. A units trap, not a design question, flagged
because the whole token table shares it.

**[RAISE-S-14] The revoke-membership confirmation copy is [INVENTED].** It must
say the operator loses access **and that the availability they reported stays**,
because `Report` is append-only. Routed to `packages/domain`.

**[RAISE-S-15] The unpublish confirmation cannot promise removal.** An
unpublished station stays in every bundled snapshot until the next release and
in every unsynced cache. A confirmation saying drivers will no longer see it is
**false for exactly the offline-first users the product exists for**. Copy
[INVENTED], the underlying fact [d] from 12 §A8 + ADR-0007.

**[RAISE-S-16 — SUNLIGHT, the serious one] O4's 1 px `#3E3E3E` divider at
1.75 : 1 is its only connector separator and is not visible in direct
sunlight.** The consequence is a wrong-row tap, i.e. a false report — a
data-integrity failure, not an aesthetic one. **No mitigation exists inside the
measured palette**; every option (heavier rule, lighter rule, per-bay surface
swap, bought whitespace) is a deviation. **Raised, not chosen**, and named as
the first thing to look at in ADR-0009's launch-week survey.

**[RAISE-S-17] The operator app's `StateLine` and offline chip should take
Regular, not ExtraLight.** ADR-0009 §4 already applies exactly this mitigation
to derived data lines; extending it to two more runs is small and consistent.
**Cost:** the operator app's quiet indicator becomes marginally less quiet than
the driver app's, which is a deliberate asymmetry and should be said out loud.

**[RAISE-S-18] Loading and empty are indistinguishable outdoors.** Both resolve
to `#3E3E3E`-or-nothing on `#121212` at 1.75 : 1. This is why [RAISE-S-8]'s
sequencing rule is the load-bearing half of that recommendation.

**[RAISE-S-19] A4's `delete blocked` state cannot be written.** §4.2 says a
terminal refusal is *the reason in place of the control* — and the reason does
not exist, because deletion has no defined semantics ([RAISE-OA-14]). The state
is designed; its string is blocked upstream.

**[RAISE-S-20] The destructive alert is the product's third OS-drawn surface.**
Declared, with its cost: Apple's and Google's type and colour, including their
red, appearing inside a product with no red. **Recommendation: accept** — it is
the mechanism files 11 and 12 already chose for two deletes and both menus, and
the alternative (two identical `#393939` slabs, one of which deletes an account)
is worse in every light and unusable in §10's.

**[RAISE-S-21] `StateLine`'s placement rule is [d], not [m].** *Replaces the
body copy of its block, or sits `space.blockGap` 39 px above the control it
refers to.* Both halves cite measured values; the rule that chooses between them
is this file's.

**[RAISE-S-22] `reordering` (A7) is an eighth interaction state and is not
designed here.** Drag has no reference vocabulary of any kind, it exists on one
web screen, and 1:1 does not govern the admin. **Recommendation:** A7 uses the
console grid's own behaviour, declared as admin-native and not tokenised.

**[RAISE-S-23 — CORRECTIONS OWED TO FILE 11] Three geometries in file 11 are
pre-`10-v2` and are wrong.** §0.4: the hero is **1078 × 612 px** not 1076 × 620,
`radius.button` is **13 px** not 13.5, and the floating card's inner box is
**948 px** not 950. File 11 was written before the measurement authority existed
and declares that dependency; nothing has swept it since.
**Recommendation:** fix at the source in the merged v2, and re-run the sweep —
this file caught three by checking every number it cited, which implies others
survive in the places nobody has re-cited.

### 12.1 Inherited and depended upon, not re-raised here

[RAISE-OA-2] (this file is its answer, not its restatement) · [RAISE-OA-4] /
[RAISE-D21] (the input's appearance — stream 2) · [RAISE-OA-13] (`#717171` is
not a disabled token; relied on throughout) · [RAISE-D14] (the value slot, which
every settings-row state here composes with) · [RAISE-D15] (no destructive
treatment; §9 executes its recommendation) · [RAISE-D16] (text-only progress;
§6.3 generalises it) · [RAISE-D17] (the trailing check) · [RAISE-D23] (report
action labels, which §4.3's and §7.4's strings join) · [RAISE-OA-5], [RAISE-OA-6],
[RAISE-OA-14] (three model gaps that block three states outright) · [RAISE-2]
(ExtraLight at 13 pt, which §10.1 partially mitigates) · ADR-0009 §4 (dark-only,
which §10 costs).

---

## 13. What this file does not decide

The **appearance** of the text input, the numeric input and the multi-select —
stream 2 · whether O4 dismisses on Save (a navigation question, routed to file
12, §6.6) · the exact wording of the six [INVENTED] strings, which are routed to
`packages/domain` and are subject to `docs/availability-display.md` §2.2b rather
than to this file · A7's reorder behaviour (§3.3) · whether the admin adopts a
destructive colour or a muted text tier, both of which 1:1 permits it and token
kinship argues against ([RAISE-OA-13], §9.5) · every founder call in §12, which
is the point of raising them · and the light theme, which ADR-0009 makes
revisitable **on evidence and only on evidence** — §10.2 names what evidence to
collect.
