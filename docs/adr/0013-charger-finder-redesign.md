# ADR-0013 - The reference becomes a styling reference, and the driver app is rebuilt as a charger finder

Date: 2026-08-20 · Status: accepted · Founder decision

Amends: **locked decision 16** (SPEC.md §2). The four screenshots in `refs/`
govern **styling** from here: the palette, the type scale, the radii, the
spacing, the component geometry, and the state grammar. They no longer govern
**layout or information architecture**. Decision 16's own words, "implemented
1:1, no deliberate deviations", now scope to the styling layer alone.

Supersedes: [ADR-0009](0009-reference-fidelity-deviations-and-costs.md) **item 3
only** (the hero badge fidelity cost). Items 1, 2 and 4 stand unchanged.

Amends: SPEC.md §5 finding 3 and the tab-bar finding (both re-read below), §6
in full, §13 item 10's justification, `docs/availability-display.md` §2.2b
row 6, and `refs/README.md`, which asserts the 1:1 rule in its own text.

The screen-by-screen record is
[`11-driver-screens-v3.md`](../../.scratch/ev-guide-spec/design/11-driver-screens-v3.md),
which supersedes v2 for the driver app. v2 remains the citation of record for
every measured value, because **no measured value changes in this ADR**.

## Decision

### 1. The reference governs styling, not information architecture

The reference is a Kigali car-rental app. Its visual system was measured over
two adversarial rounds and it is excellent; its **information architecture was
never about finding a charger**, and every place EV Guide reads as unlike a
modern charger finder traces to that mismatch rather than to a design judgement
anyone made on the merits.

From here: a layout or IA question is answered on its merits for a Rwandan
driver. A styling question is still answered by the reference, and a styling
difference is still a deviation that must be recorded.

**Nothing measured moves.** Every new surface in v3 is composed from geometry
that already exists in `packages/dart/ui`: the secondary-control box, the
primary-CTA geometry, the settings row, the floating card, the feature and
category chips, the drag handle, the trailing accent check.

### 2. The hero badge is drawn legibly

The badge label moves from `color.text` `#FFFFFF` to `color.onAccent`
`#121212` on the `#C7FC2F` fill. Computed under WCAG 2.x relative luminance,
that is **15.52:1**, against **1.21:1** today.

Two notes on the arithmetic, because this project has been bitten by an
eyeballed number before. ADR-0009 estimated the recoloured value at "~14:1";
the computed figure is 15.52:1, so the estimate was low. The method used here
reproduces SPEC §5's own published surface-to-raised figure of 1.08:1 exactly,
which is what validates it.

Because the reference still governs styling, **this is a deviation, not a
correction**. Together with decision 7 below, the counts in SPEC decisions 22
and 23 change:

| | Before | After |
| --- | --- | --- |
| Knowing styling deviations | 2 (wordmark slot, location puck) | **4** (+ the badge label, + the accent budget) |
| Fidelity costs carried | 2 (badge contrast, operator dark-only) | **1** (operator dark-only) |

The badge moves from the cost column to the deviation column, and the accent
budget is added to it.

**The fourth deviation is different in kind from the other three, and the count
should not hide that.** The wordmark slot, the puck and the badge label are each
one element, drawn once, checkable against one reference pixel. The accent
budget is a **systemic** property of a whole screen. It is the first deviation
that cannot be verified by looking at a single component, and the first that a
future change can widen without touching the thing the ADR named.

### 3. The driver app gains four things every surveyed charger app has

Each is composed from existing geometry, and each is justified screen by screen
in v3:

- **A search field** on D-01, as the secondary-control box SPEC §5 already
  fixes, with a leading magnifier glyph and **no placeholder** (there is no
  dimmed text tier to draw one with). Scoped to an on-device substring match
  over `Station.name`, `Station.nameShort` and `Owner.displayName`. **No
  geocoding**, no address search, no server text index.
- **A connector chip row that reorders and marks, and never hides** (see
  decision 8). Members are **controls at primary-CTA geometry**, not chips at
  chip geometry, because the design record rules product-wide that chips are
  labels and interactive controls take CTA geometry. Selected is `color.accent`
  + `color.onAccent`; unselected is `color.surface` + `#FFFFFF`. The row reads
  `baysOffering(T)`, a structural fact. **It never reads availability**, and
  under decision 8 it never removes a station from any surface.
- **D-13 Nearby chargers**, promoted rather than invented. v2 already specifies
  a nearby list, but as D-02's *second* detent behind the CTA, with both its
  properties unmeasured (RAISE-D10). It becomes the **default content of the
  sheet** when no station is selected, which is the only change, and it resolves
  RAISE-D10(b) by keeping the CTA rendered at every detent.
- **`Update status` as a first-class control** on D-03, directly under the
  connector rows, at primary-CTA geometry in `#393939`.

### 4. `My plug` stays a lens, and does not gain a filter half

Founder call, 2026-08-20, answering B1: **nothing hides.** An earlier draft of
this ADR split `My plug` into a mandatory lens and an optional hiding filter.
**That split does not happen.** The lens is what it always was: always on when a
selection exists, and it never removes a station from the map or the list.

The category's "my vehicle" pattern is therefore adopted only in its stronger
half. EV Guide already had that half, and the weaker half is refused.

Two things follow immediately. The **`My plug` chip on D-01 has no job** and is
removed, because its only purpose was to switch the hiding half on. And **D-09
needs no new copy** distinguishing two mechanisms, because there is only one.

### 5. D-02 becomes draggable without becoming a bottom sheet

It gains detents and keeps every measured property of the floating card. **Its
bottom edge never moves**, so `space.floatingCardBottomGap` (64 px) and the
measured CTA row survive at every detent. SPEC §5 finding 3 survives in
substance: this is a floating card, the component is named `StationCard`, and
it is still not built on a sheet primitive. One word of it does not survive:
finding 3 addresses the requirement to `packages/ui`, and ADR-0012 moved the
obligation to `packages/dart/ui` without sweeping the reference. Consequences
carries the correction.

The cost is explicit: Flutter's `DraggableScrollableSheet` and
`showModalBottomSheet` cannot be used, because their contract is bottom
anchoring. The detent physics, velocity handling and scroll-to-drag handoff are
custom code.

### 6. No tab bar

SPEC §5 calls the absence a positive finding, and it survives the redesign on
its own merits rather than by inheritance. A tab bar needs three to five
sibling destinations of comparable weight and EV Guide has one. `Trips` needs a
`Session` entity that CONTEXT.md deliberately does not define; `Recents` needs a
view-history entity nothing carries; `Saved` is account-gated, so for the
anonymous majority one of three tabs would be a permanent sign-in prompt.

There is also a geometric cost and a palette cost. A bar occupies the bottom of
every screen, which is exactly where the measured CTA row and D-03's sticky bar
live, so something measured would have to move for something unmeasured. And a
selected tab needs a channel: the only channel is the single `#C7FC2F` with no
tints, which would paint accent permanently and compete with the pins and the
one CTA.

SPEC §7 gives the operator app the same ruling, so this keeps both apps on one
navigation grammar and one `packages/dart/ui`.

### 7. Selected connector chips are lime, and the accent budget is knowingly exceeded

Founder call, 2026-08-20, taking option (a) of the four below. A selected chip
is `color.accent` + `color.onAccent`, which is what "accent means *selected*"
already fixes, and **D-01 may therefore carry several lime controls at once**
beside the lime CTA and the lime pin rims.

This knowingly overrides "**Only one button may be lime**", a rule stated
product-wide on a measured budget of roughly 3.9% that the reference spends on
the pins plus one CTA, and which ruled two of S-01's three provider buttons down
to `#393939`. The two rules had never collided because the only surface with
CTA-geometry controls, S-02, has no selected state, so nothing there was lime
and the budget survived by construction. The chip row is the first surface that
both selects and persists.

**Why this is the right side to lose on.** The rule's reasoning does not
transfer even though its budget does: S-01's case was three *provider* buttons
competing for primacy, where exactly one should win. Lime on a connector chip
marks **state**, not primacy, and a selection the driver cannot see is worse
than a busy screen. The alternative that preserved the budget could not carry a
count either, because `Badge` is a prohibited component, so it would have bought
quiet at the price of the weakest possible signal.

**What this obliges.** Because the deviation is systemic rather than
per-element, it needs a boundary or it will widen silently. Two follow:

- The accent gains **no new role** from this. It still means selected, the CTA,
  the pin rim, the free-bay dot and the link. Chips are inside the existing
  meaning, not a new one.
- **S-01's ruling is untouched.** Two of three provider buttons stay `#393939`.
  This ADR does not license lime anywhere it was previously ruled down; it
  licenses it on one new control class whose selected state had no other
  channel.

**Decision 8 shrinks this deviation's exposure after the fact.** The budget
argument was about lime controls sitting *over the map*, competing with the pin
rims and the CTA. Under decision 8 the row moves off the map and onto
`color.page` inside the sheet, where no pin competes. The deviation stands as
decided, and it is now smaller than it was when accepted.

### 8. Nothing hides. The chip row reorders and marks, and it lives in the list

Founder call, 2026-08-20, answering B1 with option (a). **No filter, of any
kind, removes a station from the map or the list.** The existing ruling that the
plug lens never hides a station stands, and is now extended to every control the
redesign adds.

**What the row does instead.** Selecting `Type 2` and `CCS2` reorders D-13 so
compatible stations lead, and marks each row with what it offers. Marking costs
nothing new: the lens grammar already emits `No GB/T DC bay here · 4 bays ·
Type 2, CCS2`, and that string exists precisely because the design assumed the
station stays on screen.

**The row holds no persisted state** (founder call, 2026-08-20). It is
constructed from the D-09 lens every time D-13 is built, so an exploration of
another plug type lasts exactly as long as the driver stays in that list and
never becomes a setting they have to remember to undo. With `My plug` unset the
row opens with nothing selected and the list is plain distance order, which is
correct rather than degraded.

This is worth more than it looks. Persisting the row would have created a
**fourth piece of device-local state** beside `My plug`, and device-local state
immediately raises "does it sync", which touches ADR-0003's gating, since
profile sync is one of the three gated acts. Resetting avoids the storage, the
sync question and the gate in one move, and leaves exactly one persistent
expression of what car the driver has.

**Why it moves off the map, which is the part that is not obvious.** A chip that
reorders acts on a *list*, and **a map has no order**. The only way a chip could
express itself on D-01 would be a second additive mark on the pin, and that is
unavailable twice over: the pin's one additive channel is already spent on the
free-bay dot, a second mark collides geometrically with that dot's tangency
solution, and ADR-0002 independently forbids marking `Unknown` at roughly 87%
Unknown. A chip row floating over the map would therefore be **a control with no
visible effect on the screen it sits on**, which is worse than no control.

So the row sits at the top of D-13, inside the sheet, above the rows it
reorders. This is also where the category puts a sort control, and it is the
placement the accent budget prefers.

**S-04 Filters does not survive, and is withdrawn before it is built.** Every
block in it was a hiding dimension, and each collapses on inspection: the plugs
multi-select **is** D-09's lens and was always a duplicate of it; `Speed` and
`Network` become at most sort keys, which one chip row already expresses;
`Saved only` hides, and D-11 is already the saved list's home; and
`Clear filters` has nothing left to clear. A second surface is not needed to
hold one reordering dimension. This is the redesign's largest deletion and it is
a good one: it removes a screen, a control class, and D-13's excluded-everything
empty state in a single decision.

**The bound must not become hiding by the back door.** `stationsNear` is
specified as bounded (car floors and caps: design for 6, cap at 12). If a
reorder pushes incompatible stations past a bound, the reorder hides them in
effect while satisfying this decision in letter. **The phone list is therefore
unbounded**, which the directory's size makes cheap: SPEC §1 gives 17 to 19
sites nationally. The car surfaces keep their bounds, because a car list has a
platform limit that is not EV Guide's to choose, and there the reorder is what
makes the bound land on the right stations.

**What this costs.** This is the redesign declining the category's single most
common interaction, and the cost should not be softened: a driver who wants to
see only CCS2 sites cannot. The judgement is that with under twenty stations
nationally, a directory that can be made to look empty is a worse failure than
one that cannot be narrowed, and that decision 9's promise (a complete directory
at zero operator adoption) is worth more than a tap.

## Why, and what this decision is not

**It is not a repudiation of the reference, and not a finding that the 1:1 rule
was wrong.** The rule bought a fully measured design system across two
adversarial rounds, and that system is what makes this redesign cheap: every
new surface below is composed from geometry that was already measured, which is
why no pixel value changes. A redesign that had to invent its own spacing and
radii would be a different and much larger effort.

**It is not driven by competitive pressure, and must not be sold as such.**
SPEC §1 records that the assumed competition does not exist: the only shipped
competitor is Kabisa Charge, with 5+ downloads, no iOS build, and flows it
labels "(simulated)". This is a product judgement about what a driver needs,
not a response to anyone.

**What is actually lost is the tiebreak.** Under 1:1, a layout question had a
mechanical answer: measure the reference. That acceptance test no longer decides
IA, so every question it used to settle now needs judgement, and each new
control is unmeasured. The specific unmeasured values this creates are listed
below as founder calls rather than buried as implementation detail. This is the
real cost of the decision and it is carried knowingly.

**What the redesign is for.** Two changes carry most of the value. The first is
the filter axis: RURA Annex I requires public infrastructure to support the two
most prevalent technologies, so multi-standard sites are the legal norm in
Rwanda, and a GB/T driver at a Type 2 and CCS2 site is blocked with a bay
standing empty. Connector type is the real compatibility axis and the map did
not expose it. The second is making reporting a first-class act: ADR-0003's own
context says the availability layer depends entirely on drivers choosing to
report, in a market of roughly 2,000 cars, and today the entry point is hidden
behind a connector row or an overflow menu. A hidden entry point starves the one
layer that differentiates the product.

## The badge, and the rule that must not travel with it

`availability-display.md` §2.2b row 6 bans any availability word on the badge,
and gives two reasons: an accent chip reading `no confirmed status` on roughly
87% of stations paints the product as an apology, which ADR-0002 forbids; and
the badge measures 1.21:1 and may carry no value a driver must read.

**The second reason dies with this decision. The ban does not.** It stands on
the first, which was always the stronger one. Row 6's text must be amended so
it stops citing a contrast fact that is no longer true, because a rule that
cites a dead fact is exactly the failure mode this document set is built to
prevent: a claim in one section disproved by a table in another.

**The redundancy invariant survives, on a new justification.** It was written as
the mitigation that made illegibility harmless. That job is gone. It is kept
because the badge carries peak power **or is absent**, so a value whose only
home is the badge is a value that disappears when the badge does. SPEC §13
item 10 keeps its test and changes its reason.

## What the redesign leaves for a founder call

**Nothing blocks any more.** Both blocking calls were answered on 2026-08-20
and are kept here as pointers, so a reader who remembers them as open finds
where they went. The numbered calls below do not block, and each is listed in
v3.

### B1. May a filter hide a station at all? ANSWERED

Answered 2026-08-20: **no.** It is now **decision 8** above. The reasoning that
led there is worth keeping, because it is the reasoning a future request to add
filtering will have to answer.

The existing ruling was that the plug lens never hides a station. It rested
partly on the reference, which decision 16's amendment demotes, and partly on
positioning that is **still locked**: decision 9 says that with zero operator
adoption EV Guide is still a complete directory, and with 77 charge points
nationally a filter that hides is a filter that can empty the map.

Three consequences made this more than a preference. Hiding would render
`Unknown` as failure, which ADR-0002 forbids in terms at roughly 87% Unknown. It
would create the driver app's **first empty map**. And it would make the
anonymous default behave differently from a store reviewer's view, which
ADR-0003's amendment legislated against specifically.

The product's own grammar was the evidence: the lensed card emits `No GB/T DC
bay here · 4 bays · Type 2, CCS2`, and that string exists only because the
design assumed the station **stays on screen**. RURA Annex I makes
multi-standard sites the legal norm, so a station with no compatible plug is the
exception rather than the rule, which is what made hiding expensive and
low-value here.

Rejected alternatives: **(b)** filters hide, opt-in and off by default, which an
earlier draft of this ADR was written on; and **(c)** filters hide but the list
keeps excluded stations in a named tail section. (c) is the one to revisit first
if the directory ever grows past the size that makes (a) comfortable.

### B2. The accent budget against the filter chip row. ANSWERED

Answered 2026-08-20: option (a), accept the deviation. It is now **decision 7**
above and is no longer open. The three rejected options are in "Alternatives
considered".

1. **The three detent heights.** RAISE-D10 records the list detent as
   unmeasured. The three stops are derivations, not measurements.
2. **Glyph-for-tier on the pin.** Encoding AC against DC in the pin glyph is
   available in principle (it is a structural fact from `Connector.type`, not an
   availability claim, and it is the colourblind-safe channel). Three costs:
   it deviates from RAISE-D3's uniform-glyph ruling, it adds a second pin
   drawing with no reference pixel, and **the projection does not exist**.
   Nothing in `packages/dart/domain` projects peak power or has-DC to *station*
   scope, because power is a Connector property, so this needs a new projection
   plus a ruling on whether a pin may assert a station-level fact at all.
   Colour-for-status stays unavailable at any answer, because there is no status
   palette to spend, and a second additive mark would also collide with the
   free-bay dot's tangency solution.
3. **The re-tenanted CTA.** While a station is selected the map CTA reads
   `Directions` instead of `Nearby chargers`. This keeps exactly one
   accent-filled control on screen, which the measured accent budget of roughly
   3.9% wants, but a control that changes label and destination under the user
   is an invented behaviour with no instance in the reference.
4. **Caret, selection and focus appearance**, now urgent rather than theoretical
   because a search field exists. `19-form-controls-v2.md` records all four of
   caret, selection, placeholder and focused appearance as **absent, with
   nothing to inherit**. `#FFFFFF` is disqualified as a selection fill;
   `#121212` invents nothing; the accent needs a yes.
5. **The magnifier glyph, as a fourth answer to F18.** F18 is the open call that
   an empty field and a button are the same box, and it offers three options:
   accept the mute field (recommended), a 2 px border, or a focus treatment that
   does not answer it. A **leading glyph inside the box** is not among them, and
   it is what v3 proposes for this one field, on the ground that a magnifier is
   read as search without inventing a text tier. It genuinely narrows F18 for
   the search field and does not close it elsewhere. It needs a yes, and if it
   gets one, F18's option set should record it.
6. **A `search` method on `StationRepository`.** `protocols.dart` carries
   `stationsNear`, `stationDetail` and `changedSince` and nothing else, so this
   is a new protocol surface for both the mock and BWEZE. Note
   `19-form-controls-v2.md` §1.5 ruled a search field "not required" and said
   that if the list ever outgrows its filters, that is a new decision rather
   than a control that pass could add. This is that decision.
7. **A first-run plug picker**, if launch-week evidence shows drivers never find
   `My plug`. Deferred, not rejected: ADR-0003 is clear that a signup wall before
   anyone has seen value inverts the funnel. Note decision 8 partly retires this
   worry already: seeding the chip row from the lens makes the setting visible as
   state on the first screenful, rather than leaving it buried behind an
   unlabelled avatar.
8. **A tab bar**, on the same evidence, if `Saved` proves undiscoverable behind
   that avatar.

## What the category does that EV Guide still will not do

Recorded so a future reader does not mistake absence for oversight. Full
reasoning in v3.

- **No reliability score.** Decisions 9 and 11 forbid a reputation system, and
  the research independently finds PlugScore opaque and gameable.
- **No check-in feed, ratings, comments or driver-submitted photos.** No entity
  exists for any of them, `Photo` is admin and owner only, and SPEC §12 keeps
  community signal in the fog with its moderation problem attached. **The
  `Report` is EV Guide's check-in-with-outcome, and it survives.**
- **No community-added or community-edited stations** (decision 18).
- **No journey planning, corridor filter or isochrone** (decision 20).
- **No in-app turn-by-turn** (decision 5, ADR-0004), which the research reaches
  independently from the other direction.
- **No nav-app chooser.** The research calls the picker the category standard,
  but ADR-0004 already adjudicated it for a Rwanda-specific reason that is
  stronger than the norm: Apple Maps has no driving directions in Rwanda, so a
  chooser would offer a rung that cannot route.
- **No availability-coloured pins.** There is no token to spend, and at roughly
  87% Unknown it would render the map as broken.
- **No filtering that hides anything, of any kind** (decision 8). This is the
  category's most common interaction and EV Guide declines it outright. The chip
  row reorders and marks instead.
- **No `Available now` chip.** Rejected twice over: decision 8 rules out hiding
  in general, and this one would additionally convert "we do not know" into "not
  available" across most of the directory, which is the grey-means-two-things
  failure the research documents and which grammar law 1 forbids in string form.
- **No `Open now`, amenities, access-class or price filters.** `Station` carries
  no hours, no amenities and no access class, and a station-level price
  predicate would assert a station-level rate that does not exist.
- **No clustering** (RAISE-D4), **no map/list segmented control**, and **no
  freshness claim of the "updates every minute" kind**. The surveyed apps
  publish an update cycle and do not timestamp the status; EV Guide does the
  opposite, and that is the honest trade.

## Consequences

- **`knownContrast.heroBadgeLabel` is deleted** from `packages/ui/src/tokens.ts`
  and `packages/dart/ui/lib/src/tokens.dart`. The block exists so nobody "fixes"
  a deliberate contrast without reading ADR-0009 first; once the badge is
  legible the entry is false. `handle: 1.24` stays, because an invisible drag
  handle is correct.
- **No badge component exists yet** in either UI package, so there is nothing to
  re-draw. This lands as a token deletion plus the v3 record.
- **SPEC edits**: §2 decisions 16, 22 and 23; §5 finding 3 (re-read, not
  deleted) and the tab-bar finding (re-justified, not deleted); §6 replaced;
  §13 item 10's reason. §6 is a locked section and this ADR is what unlocks it.
- **Finding 3's addressee is corrected while it is being re-read**, and the
  correction predates this ADR. It obliges **`packages/ui`** not to build the
  card on a sheet primitive, but ADR-0012 handed the phone to `packages/dart`
  and left `packages/ui` as the admin's token source, which takes tokens only
  and no components. The obligation belongs to **`packages/dart/ui`**, where
  `station_card.dart` actually lives. This is a stale reference ADR-0012 should
  have swept and did not, not a change this redesign makes.

  **Six further SPEC lines are ADR-0012 residue**, swept here so the sweep is
  done once rather than found six more times. Three name `packages/ui`. §5's
  opening (*"Lands as `packages/ui`, shared by both mobile apps"*) and §7's
  operator line (*"Separate Expo app, same `packages/ui`"*) both address the
  mobile surface, which is `packages/dart/ui`; §7's *"Expo"* is ADR-0012's
  residue in the same sentence. §10's repo-shape block calls `packages/ui` *"the
  React Native design system"*, and that block is stale end to end rather than
  in one row: it still lists `apps/driver Expo` and `apps/operator Expo`, and
  carries none of `packages/dart/`, `packages/corpus` or `apps/driver_flutter`.
  Correcting its `packages/ui` row alone would leave a table wrong in four
  others, so the block is replaced rather than edited.

  **The other three name Expo and were found by sweeping for it**, which is how
  a sweep for one symptom should end. §1 still described both mobile apps as
  Expo, in the product's own opening paragraph. Decision 14 still read "two
  **Expo** apps" and named the old package trio. And §10's platform floor still
  resolved to "the latest stable **Expo** SDK", when ADR-0012 killed ADR-0011
  and re-resolved the same rule to Flutter 3.47.0 stable / Dart 3.13.0. The rule
  itself is untouched: pin at build start, upgrade as ordinary maintenance,
  SDK-default minimums, no hand-raised floors.

  **One Expo reference is deliberately left alone**: §13 guarantee 11, which
  names React Native's `activeOpacity` and `android_ripple` as the mechanism
  behind the no-disabled-token rule. Its mechanism is stale and its rule is not,
  and it is being worked in a separate effort alongside `EVGuideButton`, which
  ships the very `disabled` state that guarantee forbids. Sweeping it here would
  collide with that.

  **One clause is this effort's own** rather than ADR-0012's. §5's *"no React
  Native components"* drew a line between the admin and the mobile components;
  with those deleted, nothing in the repo remains on the other side of it, so
  the sentence now describes `packages/ui` instead of restricting it. The
  package is not thereby left ungoverned: §5's ban on naming a typeface and its
  `quickAction` rule still bind it, and both still hold in `tokens.ts`.
- **`refs/README.md`** asserts the 1:1 rule in its own text and must be amended
  to the styling scope.
- **"Only one button may be lime" is amended, not deleted**, in
  `11-driver-screens-v2.md` §S-01, which is where it is stated. It still governs
  S-01 and every surface whose controls compete for primacy. It no longer
  governs a surface whose controls carry selection state, which is the whole of
  the exception decision 7 buys. The `~3.9%` measurement it rests on is a
  measurement and stays true; what changes is what follows from it.
- **`availability-display.md` §2.2b row 6** loses its contrast clause and keeps
  its ban.
- **Two new control classes**, down from four before decision 8 withdrew the
  filter sheet: a **selectable chip row** and a **detented card**. The reference
  contains no instance of either. The text field was already owed by S-01 and
  D-05 (RAISE-D21) and is specified in `19-form-controls-v2.md`, and the
  multi-select row group is D-09's, which already exists.
- **`styles.dart` must gain a `controlBoxStyle()` before any of them is built.**
  SPEC §5 names the secondary-control box as both the field and the control box,
  and every new primitive here composes from it, but `styles.dart` today
  produces only the accent CTA. Without one function, the first builder
  hand-assembles the box and the call sites diverge. A settings-row style, a
  list-divider style and icon metrics for the two grids are owed with it.
- **`tokens.dart` has no divider-thickness token**, and this is a live trap for
  D-13's rows. The measured divider is 1 px (0.33 pt); `space.hairline` is 2 px
  and belongs to a different object (link underline, pin outline, crosshair
  rule). A list-row builder reaching for `hairline` silently doubles every
  divider **and passes every existing test**.
- **Three components the redesign needs are commissioned but unexported**:
  `PressableSurface`, `StateLine` and `Placeholder`. Every empty state, refusal
  and loading surface in v3 is built from the last two, so the redesign cannot
  express its own states today.
- **The prohibited-components assertion does not exist in the Dart package.**
  The interaction-states pass specifies a module-name assertion over the export
  surface covering twelve forbidden components, `Badge` among them. It is absent
  from `packages/dart/ui/test`, so nothing currently stops a redesign adding a
  `Badge` for a filter count or a `Spinner` for the map. It should land with
  this work, because this work is what makes both tempting.
- **`19-form-controls-v2.md` §1.5 is overturned** in one line: it ruled a search
  field "not required" because the driver app had none by ruling. It now has one.
- **The design record's "Deliberately not screens" table is mostly
  *vindicated*, not overturned.** It ruled that "the plug lens (D-09) is a
  reading aid, not a filter, and it never hides a station." Decision 8 keeps the
  second half exactly and softens only the first: the lens is now also a
  reordering key, and a chip row expresses it. **No filter screen is added**, so
  that row of the table stands as written. An earlier draft of this ADR recorded
  it as overturned, which was wrong.
- **S-04 Filters is withdrawn before it was built** (decision 8), taking with it
  a screen, a control class, and D-13's excluded-everything empty state.
- **Nothing in `packages/dart/domain` changes.** Every new surface reads
  projections that already exist: `stationsNear`, `baysOffering(T)`,
  `freeBaysOffering(T)`, `bayStateUnder`, `G()`, `freshness()`,
  `nextDecayDeadline()`. The corpus is untouched, and all ten fixtures still
  govern.
- **SPEC §13's twelve guarantees survive, with one amendment**: item 10 keeps
  the redundancy invariant and changes its justification, as above. The
  banned-word grep, the `0 of N` unreachability, the forbidden-string test and
  the corpus all stand untouched.
- **One pre-existing enforcement gap gets more dangerous here, and is worth
  closing with this work.** Decision 17 bans both `real-time` **and** `live`,
  but §13 guarantee 8 names only `real-time`, and `forbiddenSubstrings` carries
  only `real-time` and `realtime`. `live availability` passes the mechanical
  grep today. The omission is probably deliberate, since a bare substring ban on
  `live` would catch `delivered`, but it is undocumented, and this redesign adds
  filter labels, a list header line and two empty states, which is exactly the
  copy where the category's own vocabulary is most tempting.

## Alternatives considered

**Keep 1:1 and ship the reference's IA.** Rejected by the founder brief. It is
worth recording what it was costing: no way to see which stations take your
plug without opening each one, no list, no search, and the product's own
reporting mechanism hidden behind an overflow menu.

**Adopt the category wholesale, including a tab bar, status-coloured pins and a
bottom sheet.** Rejected: each of the three breaks something measured or
something locked, and the first and second need tokens that do not exist. The
brief was to keep the styling and brand identity, which is what rules this out.

**Recolour the badge label but keep calling it a fidelity cost.** Rejected as
dishonest bookkeeping. Under a styling-governing reference it is a deviation,
and the count moves from two to three.

**Delete the redundancy invariant along with the contrast cost.** Rejected: the
invariant's original justification is gone but its subject is not, because the
badge is still optional. Removing a passing safety test as a side effect of a
styling fix is the kind of silent scope creep this repo's tests exist to catch.

**A separate ADR for the badge.** Rejected: the call only became available once
the 1:1 rule stopped governing layout, and this repo's style is to keep that
causal chain visible in one place.

**Three ways to keep the accent budget intact** (the alternatives to decision 7,
all rejected by the founder on 2026-08-20):

- **Cap the chip row at single-select**, so at most one lime chip plus the CTA.
  Cheapest, but a driver whose car takes both Type 2 and CCS2 is ordinary in
  Rwanda and could not express it, which defeats the row's purpose.
- **Collapse the row to one `Filters` control**, everything behind a filter
  sheet. It preserved the budget almost exactly but **could not carry a count**,
  because `Badge` is one of the twelve prohibited components, the only measured
  badge is a presence dot, and the status dot at 6.8 pt cannot hold a digit. It
  would have shipped the weakest of the four available signals while silently
  narrowing a small directory. Decision 8 made it moot twice over by withdrawing
  the sheet it would have opened.
- **Invent a selected treatment that is not the accent.** Rejected before it was
  offered: surface to raised is 1.08:1 and reaches nothing near the 3:1 a
  non-text signal needs, so this means a new token and a break in the brand
  instruction that produced this ADR.
