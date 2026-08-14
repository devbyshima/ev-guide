# 16 — Adversarial verdict on `14-interaction-states-v1.md` (v1)

Ticket 31, design stream 1 (states). Reviewed against
`31-missing-states-design-pass.md`, `10-design-system-v2.md`,
`11-driver-screens-v2.md`, `12-operator-admin-screens-v2.md`, `SPEC.md`,
`docs/adr/0007-offline-model.md`, `docs/adr/0009-…`, and
`docs/availability-display.md`.

**Verdict: REJECT. 3 fatal, 15 major, 15 minor.**

The document is strong where it is arithmetic and weak exactly where the last
three review rounds said it would be: **a claim in one section disproved by a
table in another.** Eight of the eighteen fatal/major findings below are that
shape, including the sentence the file itself calls *"the finding that decides
this document"*.

---

## 1. FABRICATED MEASUREMENT

Method: every value carrying a `10 §…` citation or an `[m]`/`[d]` mark was
looked up in `10-design-system-v2.md`. All sixteen contrast ratios in §1.3 were
independently recomputed (WCAG 2.x relative luminance).

**Genuinely sound, stated once and not repeated below:** §1.3's sixteen ratios
are all correct to ±0.01 (`#3E3E3E`/`#121212` 1.752, `#393939`/`#121212` 1.622,
`#3E3E3E`/`#393939` 1.080, `#717171`/`#393939` 2.366, `#212121`/`#121212`
1.163 …), and the *"Published by 10 §1.2?"* column is right on all sixteen
rows. §0.4's three corrections against file 11 are all correct and all
correctly cited (hero 1078 × 612 at 10 §7.7; `radius.button` 13 px at 10 §6 /
§10.4; card inner box 1076 − 2 × 64 = 948 at 10 §7.4 / §10.3). §6.2's
`Placeholder`, §6.4's row container, §7.3's `StateLine` type/space rows, §8.2's
O9 card and §9.1's card frame/radius/fill/padding/handle all trace correctly.

### F-1 — MAJOR. A vertical gap presented as measured, taken from a horizontal one, and off by 1 px

> §9.1: `| Button geometry | 138 px tall, **r 13 px**, 27 px apart | 10 §7.1, §10.4, §10.3 [m] |`

`10 §10.3` contains no button-to-button gap. Its 27 px is `space.chipGap`,
which `10 §5.2` measures as **`chip → chip (horizontal)` = 27 px**. The measured
**vertical** gap between siblings is `space.chipRowGap` = **26 px**
(`chip row → chip row`, 10 §5.2 and §10.3). The confirmation card stacks its
buttons vertically, so the cited token is the wrong axis and the right token
gives a different number.

The source of the error is 11 [RAISE-D31] — *"27 px between, the only measured
vertical gap between sibling controls in the system"* — which is false against
10 §5.2. §0.4 claims to have caught file 11's stale geometries "by checking
rather than by care"; this is a fourth one, cited in this file, unchecked.

**Must say:** either `space.chipRowGap` 26 px [m], or 27 px marked **[d]/
[INVENTED]** with the note that it is a horizontal chip gap repurposed as a
vertical control gap, and routed with [RAISE-S-23].

### F-2 — MAJOR. The stale 950 px is re-shipped 900 lines after being killed

> §0.4 row 3: *"11's 950 derives from its own superseded 1078 px frame"* → **948 px**
> §9.1, twelve lines later: *"The result is two identical **950 × 138 px** slabs"*

§0.4 and [RAISE-S-23] exist for precisely this defect and the file commits it
itself. **Must say:** 948 × 138 px.

### F-3 — MAJOR. The sweep §0.4 claims to have run is incomplete in two more places

[RAISE-S-23] asserts *"Three geometries in file 11 are pre-`10-v2` and are
wrong."* At least two more are:

| Stale value | Where it lives | 10-v2 measures |
| --- | --- | --- |
| Floating card **r 16 px** | 11 §0.3 row 2, 11 §17 D-02, 11 §17 S-01, 11 S-01/S-02 diagrams | **14 px** all four corners, `radius.floatingCard` (10 §6, §7.4, §10.4) |
| `radius.button` **4.5 pt** | **12** §4.3 and **12** §7 | **4.3 pt** = 13 px (10 §10.4) |

The second is the *same defect as §0.4 row 2*, in the other consumed file,
expressed in pt instead of px — and this file adopts 12 §4.4 wholesale in §4.3
without noticing. **Must say:** [RAISE-S-23] covers file 11 **and** file 12, and
names r 16 → 14 and 4.5 pt → 4.3 pt. (11 §0.3 also disagrees with 10 §7.1 on the
CTA width, 897 vs 899 px; worth a line in the same raise.)

### F-4 — MAJOR. A stem measurement applied to the wrong run, and a founder call rests on it

> §10 table: `| The offline chip | #FFFFFF on #393939 | 11.55 : 1 colour, **ExtraLight at a ~1.7 px stem** | at risk — §10.1 |`

11 §9.1 sets the chip label at **cap 32 ExtraLight**. `10 §4.1` row 13 (feature
chip label, cap 32 ExtraLight) measures its stem at **2.12 px**. The 1.68 px
stem is *body copy* at cap 27–28 (rows 20, 21). §10.1 quotes the range
correctly ("1.68–2.12 px") and then the table applies its thin end to the thick
run. [RAISE-S-17] asks the founder to change a weight on that number.

**Must say:** 2.12 px for the chip; 1.68 px for `StateLine` body copy; and
re-state S-17's case at the correct figures.

### F-5 — MINOR. A count cited to a token table that does not contain it

> §1.1: `| Geometry | eight radii, **sixteen** component sizes … | 10 §10.4, §10.5 [m] |`

10 §10.4 has eight radii ✓. 10 §10.5 has **18 rows** (15 if the four
`size.circleButton.*` collapse to one). Sixteen is neither.

### F-6 — MINOR. §10.1 cites 10 §4.5 for values that live in 10 §4.1

§4.5 publishes stem/cap ratios (0.060–0.066), not px stems. The px stems are in
§4.1.

### F-7 — MINOR. Two mis-citations in §7.6's preventability table

`shortName ≤ 17` is **12 §A5** (Owners), not 12 §A3. And §5.3 cites 10 §7.6 for
"176 px pitch" where 10 §7.6 gives the range 176–177; the single value is
`size.settingsRow` in 10 §10.3.

### F-8 — MINOR. `#717171` contrast rows use a different method from the rest of §10

Every other row of §10 compares the **two states to each other**
(`#393939 → #3E3E3E`, 1.08). The heart row compares each state to the
background ("15.52 vs 3.84 on `bg`"). State-to-state is **4.04 : 1**, which
still passes; the row should say so rather than change method mid-table. Same
issue on the free-bay dot row, which scores the accent at 15.52 (on
`color.bg`) although the dot sits on the map — accent on `#212121` is
**13.34 : 1**.

---

## 2. SILENT PALETTE GROWTH

Checked token by token against 10 §10.1's *"Deliberately absent: any
`text.secondary`, `text.muted`, opacity ramp, elevation colour, or accent
tint."*

**Sound, and the best work in the document:** no new colour token, no opacity
ramp, no elevation/shadow/blur/border/scrim, no second accent, no accent tint,
no error colour, no grey *text* tier is introduced anywhere. §11.2 prohibition 2
— that React Native's `activeOpacity: 0.2` **is** the forbidden opacity ramp and
`android_ripple` **is** the forbidden motion, and that both ship unless
explicitly disabled — is correct, is not in any source, and is the single most
valuable sentence in the file. Prohibition 1's nine banned components are each
correctly grounded (10 §9/§12, 11 §9.4, 12 §1).

### P-1 — MAJOR. `#717171` is adopted as a state colour by the same document that forbids it

> §0.2: *"**`#717171` is used nowhere in this document as a disabled, inactive or muted token.**"*
> §11.2 prohibition 3: *"`color.iconMuted` `#717171` may not be used as a disabled, inactive or muted token anywhere ([RAISE-OA-13])."*
> §10 table: `| Saved vs unsaved heart | **accent vs `#717171`** | 15.52 vs 3.84 on `bg` | **survives** |`

The unsaved heart is the resting/inactive rendering of the save control. §10 is
the table that judges which state channels survive daylight, and it books
`#717171` as one of them. That is the token carrying a state semantic in the one
place it most matters, inside a file that twice says it does not.

The upstream position is that this is **open**, not settled: 10 [RAISE-11] (*"Either the
card's heart is deliberately de-emphasised … or it is drift"*), 12 [RAISE-OA-13]
(*"not a token until the founder says it is"*), and the ticket itself
(*"`#717171` is not a disabled token"*). 11 [RAISE-D11] *recommends*
`#717171` unsaved → `#C7FC2F` saved — a recommendation inside a raise, which the
standing rule says is not a resolution.

**Must say:** either withdraw the §10 row, or state explicitly that the heart's
unsaved colour is 11 [RAISE-D11]'s open recommendation, carve it out of §11.2
prohibition 3 by name, and mark it as depending on a founder call — and then
strike §0.2's absolute sentence, which is false as written.

### P-2 — MAJOR. An [INVENTED] relationship with no §12 entry, and it is the one sub-threshold swap the file recommends

> §0.1: *"**[INVENTED]** — a value or relationship with no measured source. **Every one has an entry in §12** with a recommendation and a cost."*
> §5.3: *"the edited row takes `color.surface` `#393939` as a full-row fill … **[INVENTED]** as a relationship — the reference has no focused row."*

There is no `[RAISE-S-n]` for it. S-1…S-23 contains nothing on O5a's focused
row. The document accepts it in §10 (*"vanishes outdoors — **accepted**, §5.3"*)
rather than raising it, on the strength of a claim no source makes: *"O5a is the
one write screen in the product that is not performed standing at a charger."*
12 §3/O5 says a rate is *"a declaration about policy — the owner knows it
without looking at anything"*; it says nothing about **where** the owner is
standing, and O5a is reached from O3's `⋯` inside the operator app, i.e. plausibly
at the station.

**Must say:** a new `[RAISE-S-n]` carrying the invention, the 1.62 : 1 cost, and
the unsourced premise about where O5a is used — a founder call, not an
acceptance.

### P-3 — MAJOR. The caret rule is marked [d] where the identical construction elsewhere is marked [INVENTED]

> §5.2: *"**The caret takes `color.accent`** … **[d]** — a measured token (10 §10.1) applied to a platform property, which introduces no new value."*
> [RAISE-S-2]: *"The press swap itself is [INVENTED]. Both tokens are measured; the **relationship** is not."*

§0.1 defines [d] as *"derived from [m] values by **arithmetic stated in
place**"*. There is no arithmetic. "Accent = caret" is exactly the class
[RAISE-S-2] calls invented. **Must say:** [INVENTED], with a §12 entry (the cost
is small — it is the same accent already spent on *selected* — but the
classification is the ticket's one rule).

### P-4 — MINOR. §11.1's `PressableSurface` carries a `variant: 'accent'` with no defined behaviour

[RAISE-S-1] rules that *"accent controls get no press treatment at all"*. A
variant that does nothing is a prop inviting someone to fill it in.

---

## 3. COVERAGE HOLES

I walked every state cell of **11 §17** (15 rows) and **12 §10.1/10.2** (21
rows) against §3.1/§3.2.

**Sound:** the enumeration is genuinely exhaustive. Every state named in either
inventory appears in §3, including the ones the file does not define, and the
four it cannot define (`reordering`, `submitted`, `inviting`, `pending`) are
declared in §3.3 with an upstream reason each. I found no omitted cell. This is
the tedious part and it was done.

### C-1 — **FATAL**. Pressed is one of the seven states, and it is not specified anywhere

The ticket: *"**The seven interaction states** — pressed, disabled, focused,
loading / in-flight, error / retry / validation, empty, and destructive
confirmation — **specified as components in `packages/ui`**."* The file's own
title is *"The seven interaction states"*. §4 is disabled, §5 focused, §6
loading, §7 error, §8 empty, §9 destructive. **There is no pressed section.**

Worse, the component that implements it points at a section that does not
contain it:

> §11.1: `| **`PressableSurface`** | `variant: 'surface' \| 'accent' \| 'row'` | **Applies §3's press rule** and explicitly disables the platform default (§11.2) | … |`

§3 is *"Coverage — every state named by every screen"*. It contains no press
rule. The only press specification in the document is inside
**[RAISE-S-1]'s `Recommendation:` line**, and §12's own preamble says *"Per the
standing rule these are raised, not resolved."*

The consequence is not academic. §11.2 prohibition 2 **requires** the platform
default press feedback to be turned off at every call site. A build that obeys
§11.2 and finds no press rule to obey ships **every control in both apps with no
touch feedback of any kind** — which is a visible defect on the most-tapped
surface in the product (O4's control row, S-02's three controls, every settings
row).

**Must say:** a numbered section specifying pressed — the `#393939 → #3E3E3E`
surface swap, the `#393939` full-row fill on settings rows, and *no press
treatment on accent controls* — with each marked [INVENTED] and each already
routed to S-1/S-2; §11.1 then cites that section instead of §3. Alternatively,
state in §0 that pressed is deliberately deferred to a founder call and that
`PressableSurface` is not specified — but that leaves the ticket's requirement
unmet and must be said out loud, not left as a dangling cross-reference.

### C-2 — MINOR. Placeholder rows' tappability is unspecified

§6.4 paints O2's rows as `Placeholder` blocks. Nothing says whether they accept
a tap. A tappable placeholder navigates to nothing; an inert one is §4.2 case
(c) and should say so.

### C-3 — MINOR. §4.4 claims "Every screen tested against the rule" and omits several

A3/A5's submit with invalid fields (routed to §7.6 rule 2 but absent from the
table), D-07's `Delete downloaded maps` with nothing downloaded, O4's Save with
a non-empty queue. The 19-row table is a good test; the word *every* is wrong.

---

## 4. INTERNAL CONTRADICTION

### I-1 — **FATAL**. "The largest available swap is 1.62 : 1" is disproved by the table directly above it

> §1.3, in the blockquote the file calls **"The finding that decides this document"**:
> *"**The four surface greys span 1.75 : 1 end to end.** No swap between any two of them reaches WCAG 1.4.11's 3 : 1 … **The largest available swap — page to surface — is 1.62 : 1.**"*

Its own table, eight rows above, gives `#3E3E3E` on `#121212` = **1.75 : 1** —
a swap between two of the four surfaces, and larger. The two sentences
contradict each other inside one blockquote. It is not a slip of scope, because
the file **uses** the 1.75 swap twice: §6.2's `Placeholder` (`color.surfaceRaised`
on `color.bg`) and §10's `Placeholder` row, both scored at 1.75.

It then propagates into a design recommendation:

> §5.3: *"Contrast **1.62 : 1** (§1.3), which is **the largest swap in the system** and still below 3 : 1."*

So the one sub-threshold swap the document recommends is justified by a false
maximum. (`#393939` may still be the right fill for the O5a row — `#3E3E3E` is
the divider colour and a full-row `#3E3E3E` fill would swallow the row's own
dividers — but that is the reason, and the document does not give it.)

**Must say:** the largest surface-to-surface swap is **1.75 : 1** (`color.bg` →
`color.surfaceRaised`); page-to-surface is 1.62 : 1; both are below 3 : 1, which
is what the argument actually needs. §5.3 must justify `#393939` on the divider
collision, not on a maximum.

### I-2 — **FATAL**. §8.1 adopts "no button" unchanged; §8.2 ships a button

> §8.1: *11 §9.4: "Empty list → section heading + one line of cap-28 ExtraLight body copy. **No illustration, no button, no icon.**" **Adopted unchanged.***
> §8.2 table: `| O6, no operators | heading + StateLine; **`Invite operator` stays** — it is the screen's whole purpose | **new here** |`
> §3.2: `| O6 | **empty** | I | heading + StateLine, **CTA stays** | §8.2 |`

A rule quoted, declared adopted unchanged, and then contradicted by the table
four paragraphs later — the exact shape this effort's three previous rounds
existed to catch. There is a defensible distinction available (11 §9.4 forbids
an empty state *adding* a button; `Invite operator` is the screen's pre-existing
CTA merely not removed), and the document does not draw it, so a build has two
rules and no tie-breaker.

**Must say:** state the distinction explicitly — *an empty state adds no
control; a control the screen already owns is not removed by emptiness* — mark
it as an extension of 11 §9.4 rather than an adoption of it, and check it
against D-11 and D-12, where no CTA exists and none appears.

### I-3 — MAJOR. `StateLine` is defined as one line and §8.2 needs two

> §11.1: *"Renders **one** `type.body` line in `color.text`"*, props `text`, `placement`.
> §8.2: `| D-12 Alerts | heading + StateLine: `No alerts set.` **+ the instruction line** |`

11 D-12 ships both strings (`No alerts set.` and `Open a station and tap "Notify
me when a bay frees up". One alert, next 2 hours.`), and 11 §9.4's rule is *one*
line. §3.1 lists D-11 as *"heading + **one** StateLine"* and D-12 as *"heading +
StateLine"* — the file itself notices the difference in wording and never
resolves it. **Must say:** either `StateLine` takes a second optional line (and
11 §9.4's "one line" rule is amended by name), or D-12 renders two `StateLine`s
and the component contract says stacking is permitted.

### I-4 — MAJOR. `StateLine` has two placements; the source it cites uses a third

§7.3 and §11.1 give `placement: 'inBlock' | 'aboveControl'`. But:

> §7.3: *"D-07's failed download reads `Download didn't finish. Tap to try again.` and *the row is the retry* (11 D-07)"*
> §3.1: `| D-07 | **failed** | I | **StateLine + the row is the retry** |`

11 D-07 renders that string **in the row's [RAISE-D14] value slot**, not as a
line in a block and not above a control. The same is true of `76 MB · needs a
connection` (11 D-07) which §4.4 correctly reports as a value-slot string while
§4.2 case (b) says rows *"stay and gain the reason"* — three different
components for one rule. **Must say:** add `'valueSlot'` to the placement union
and say which of the three each (b)-case takes, or state that D-07's two strings
are value-slot content and not `StateLine`s at all.

### I-5 — MAJOR. The destructive alert is counted as the product's third OS-drawn surface, against the file's own table

> §9.2 table: *"**The product already delegates destruction to the platform, in two places**, and menus in two more"* — `Delete account` (11 D-06), `Delete downloaded maps` (11 D-07), D-03's `⋯`, O3's `⋯`.
> §9.2 consequence 1: *"**This is the third OS-drawn surface in the product**, after the action sheet ([RAISE-OA-15]) and Apple's sign-in button ([RAISE-D20])."*
> §11.3: *"the destructive alert (§9, **new here**)"*

If the platform confirmation is already delegated in two places, it was already
an OS-drawn surface before this file, and the alert is not new and not third.
Either the count is wrong or the "not a new mechanism" argument is. The
discipline attached to the number — *"a build that adds a fourth should have to
say so"* — makes the count load-bearing. **Must say:** the platform
confirmation is already the product's third OS-drawn surface (11 D-06/D-07);
§9 extends its *use* to revoke and unpublish and adds nothing new, so the total
stays at three and the alert is not one of them separately.

### I-6 — MAJOR. §8.4's copy rule is disproved by its own worked example

> §8.4: *"**An empty state describes what the list holds. It may never describe what has or has not happened.**"*
> immediately after: *"`Stations you save appear here.` is a statement about the list. **`No alerts set.` is a statement about state.**"*
> §8.2 ships `No alerts set.` (11 D-12 ✓).

`No alerts set.` describes something that has not happened. The rule as written
forbids the string the table ships, and the following sentence labels it
"a statement about state" without amending the rule or saying whether that is
permitted. The substance is fine — the client knows with certainty whether the
user set an alert, which is exactly why availability-display §2.2b's ban is
about *report* history and not about all history — but the rule must say that.
**Must say:** *"An empty state may state a fact the client knows with certainty
about its own list. It may never assert anything about reports —
`docs/availability-display.md` §2.2b."*

### I-7 — MAJOR. §3.2 routes A3's `saved` to §6.6, whose three reasons are all false for the admin

§6.6 deletes `saving` on three grounds: *"The write is **local**"*,
*"`capturedAt` … stamped at the connector's tap"*, *"An operator in a basement
car park is the modal case"*. None holds for A3/A5, which are forms in a web SPA
writing to a server over the network, where a save genuinely has a round trip
and genuinely fails. §6.7 then makes the admin inherit *"in-flight renders
nothing"* — so an admin form submit shows nothing at all during a real network
write. **Must say:** §6.6's conclusion is operator-app-only; A3/A5's `saved` is
§6.7's problem, and §6.7 must say what an admin submit does while in flight
(the console shell's own affordance, named as such).

### I-8 — MAJOR. §4.4's O5a row invents a state, specifies no rendering, and raises nothing

> §4.4: `| O5a `Save`, no edits | (c) | inert, unchanged | **new here** |`

For O4, §4.3 proves that "inert, unchanged" is not enough — `color.surface`
already means *tappable-but-unselected* on that screen, so the **label** must
carry it (`Save` / `Save 3 updates`), and that gets [RAISE-S-5]. O5a gets the
same answer with no equivalent analysis, no statement of the control's fill, and
no §12 entry. With no press feedback ([RAISE-S-1]) and no in-flight rendering
(§6.3), an O5a operator tapping Save with no edits gets **zero signal of any
kind**. **Must say:** what O5a's Save renders at zero edits, and raise it.

### I-9 — MAJOR. Two claimants for the "one home" of the forbidden list, unreconciled

> §0 note 2: *"The forbidden-string list is cited, never restated. **Its one home is `docs/availability-display.md` §2.2b.**"*
> 10 §0.3 R3: *"**The forbidden list lives in §11.2 of this file and nowhere else**; files 11 and 12 cite it and must not restate it."*

`availability-display.md` §2.2b says the same of itself (*"the one and only
home … No other document may hold a copy"*), and 11 §13.1 names a third address
(*"Canonical location: `docs/availability-display.md` §2.2, law 8"*). Three
files each assert exclusivity for a different address. The ticket points at
§2.2b, so this file's choice is right — but a file whose §0 opens by asserting
one home must notice that its own measurement authority asserts another.
**Must say:** name the collision and route it (10 §11.2 becomes a citation of
availability-display §2.2b, or vice versa) — it is a correction owed, exactly
like §0.4's.

### I-10 — MINOR. The kind column classifies the same state two ways

`uncached-photo`/`uncached-hero` are **I** on D-02 and D-03; the identical
condition on D-11 (*"offline | N | cached; Placeholder thumbnails"*) is **N**.
O9 is marked **I** although it is a zero-row data binding (kind C by §2's own
definition — no human action changed a control's condition).

### I-11 — MINOR. §11.1 cites the wrong raise for the press swap

*"the swap itself is [INVENTED], **§12/S-1**"* — S-1 is *"there is no pressed
state"*; the swap is **S-2**.

### I-12 — MINOR. Counts that do not reconcile

§3.3's heading says *"The three states this pass does not define"* over four
named states (`reordering`, `submitted`, `inviting`, `pending`) in three rows.
§13 says *"the six [INVENTED] strings"*; five are marked `[INVENTED]` (§4.3's
`Save`, §7.4's rejection line, §8.2's O6 line, §9.3's revoke body, §9.4's
unpublish body) and §8.2 adds two more unmarked (A2, A7).

### I-13 — MINOR. `StateLine` is titled "the error component" and does five jobs

§7.3's heading (*"`StateLine` — the error component"*) against §11.1's *"Serves
error, refusal, empty, metric-unavailable, offline-reason — five jobs, one
component"*. §11.2 bans an `ErrorText`; the §7.3 heading is what makes someone
build one.

---

## 5. OFFLINE AND HONESTY

**Sound, and correctly grounded:** §7.1's three-column separation (offline = a
normal mode, queued = success, failed = the only error) matches ADR-0007
verbatim, including the ban on *"an error screen, a banner, a modal, a red
anything"*. §7.2's three not-errors are right (11 §7.3's straight-line
degradation, 11 D-07's `Not synced` with *"Never out of date"*, §6.2's
indefinite placeholder). §6.5's two render-nothing states are quoted accurately
from 11 S-01 and S-02. §6.6's collapse of `saved` into *idle with the derived
lines changed* matches 11 S-02's already-ruled *"the confirmation is the
report's own effect"*. §7.4's copy constraints — no asserted reason, and nothing
about what was or was not *reported* — are exactly right, and §7.4 correctly
refuses three of four candidate homes for the reason each is refused in 12.
No queued write is presented as a failure anywhere; no failure is presented as a
success.

### O-1 — MINOR. §7.1 reproduces 11 §9.1's prohibition list without citing it

> §7.1 `Never` column: *"or any string reading `No connection` / `Error` / `Offline mode`"*

11 §9.1 already holds that list (*"It never says No connection, Error, Offline
mode, or anything that reads as a failure"*). §8.4 claims *"This file adds no
second list and no second home."* A copy is a copy even when it is a copy of a
different list. **Must say:** cite 11 §9.1 in that cell rather than restating it.

### O-2 — MINOR. §7.6 calls `geo` unpreventable against a source that prevents it

12 §A3: *"`geo` — **NOT NULL** — map picker, **cannot save without it**"*. §7.6's
table marks it `Preventable? **no**`. The distinction intended (a map pick is an
act, not a keystroke) is real but the answer is still *prevented, at submit*.

---

## 6. DAYLIGHT (ADR-0009)

**Sound:** §10's table is the right instrument and most of it is right —
pressed on `#393939` (1.08, *"vanishes — indoors too"*), pressed on a settings
row (1.62), the O5a focused row (1.62), and above all §10.2's divider finding
(`#3E3E3E`, 1 px, 1.75 : 1, *"a legibility failure here is a data-integrity
failure"*), which is correct against 10 §7.6 and is properly raised and not
chosen ([RAISE-S-16]). §10.3's law — *state is carried by the accent, or by
copy, never by a surface swap alone* — is the correct conclusion from §1.3.

### D-1 — MAJOR. The one loading state the file designs is scored against the wrong background

> §6.4 rule 1: O2 paints `Placeholder` rows *"filled `color.surfaceRaised` `#3E3E3E`"* at the hosting-card frame.
> §6.4 cost: *"At **1.75 : 1** the placeholder rows are nearly invisible in sunlight"*
> §10 table: `| **`Placeholder`** | `#3E3E3E` on `#121212` | **1.75 : 1** | vanishes |`

O2's **loaded** row is a hosting card, and 10 §7.10 fills it `#393939`. O9's
card is `#393939` too (12 §3/O9). So on the one screen where this placeholder is
used, the loading→loaded and loading→empty distinctions are
**`#3E3E3E` against `#393939` = 1.08 : 1** — the very swap §1.3 calls *"below
the level at which a display's own gamma variation is reliable"*. Both §6.4 and
§10 report 1.75, the contrast against the page, which is not the comparison the
operator is making.

The document was told to flag these and this is the one it missed. It does reach
the right conclusion by another route (*"loading and empty look the same
anyway"*), which makes the 1.08 figure free to state and stronger than the
argument it already makes.

**Must say:** `Placeholder` on `color.bg` is 1.75 : 1; **`Placeholder` over a
`color.surface` container is 1.08 : 1**, and on O2 that is the loading↔loaded
and loading↔O9 distinction. [RAISE-S-8] and [RAISE-S-18] both strengthen.

### D-2 — MINOR. §10 and §1.3 attribute a condition to ADR-0009 that ADR-0009 does not state

> §10: *"ADR-0009 §4 … names the exact condition: O4, standing at a charger, equatorial daylight, **2° south**."*
> §1.3: *"the specific condition ADR-0009 §4 names — a charger forecourt at **midday**, 2° south"*

ADR-0009 §4 says *"standing at a charger in equatorial daylight"*. "Midday, 2°
south" is 12 §4.3's phrasing. Cite 12 §4.3 for it.

---

## 7. SCOPE CREEP

**Sound:** no tab bar, nav bar, toolbar, popover or persistent chrome is
introduced — checked against 12 §1's forbidden list and the ticket. §9.2's
argument that an OS alert does not extend the navigation vocabulary (*"presented
by the OS over the current surface, exactly as the action sheet already is"*) is
correct. §11.1 adds three components and §11.2 bans nine, which is the right
ratio for this ticket. Nothing here belongs to stream 2: the input's appearance
is correctly deferred to [RAISE-D21] in §5.2 and §13. §6.6's recommendation to
delete a state from file 12 is a correction owed, correctly raised (S-7) rather
than applied.

### S-1 — MINOR. §6.4 rule 2 specifies persistence, which is build work

*"Row count = the last known membership count, **persisted from the previous
session**"* is a storage decision, not a state design. It is raised (S-8) and
costs one invented `1`, so it survives — but say that the persistence is a build
dependency, not a token.

### S-2 — MINOR. §8.2's A7 empty state leaves the admin without an upload affordance

*"A2, no stations / A7, no photos | heading + StateLine"*. A7 is the only place
Photos are authored (12 §A7, [RAISE-OA-16]); an empty A7 with a line and no
control is the same problem as I-2, on a screen 1:1 does not govern.

---

## Verdict

**REJECT — 3 fatal, 15 major.**

The fatals are C-1 (pressed, one of the seven, is specified nowhere and its
component cites a section that does not contain it), I-1 (the file's own
governing finding is contradicted by its own table, and a recommendation rests
on the false half), and I-2 (a rule quoted and "adopted unchanged" is
contradicted by a table four paragraphs later).

None of the three is a broken rule. All three are a claim in one section
disproved by a table in another — which is the failure this effort has now
found in four consecutive rounds, and which no amount of care has ever caught.
Only checking has.
