# CarPlay design v2 — adversarial verdict (reviewer + runtime)

Reviewed: `design/01-carplay-design-v2.md` (all 1,340 lines) against `design/00-constraint-sheet.md`,
`docs/domain-model.md`, `CONTEXT.md`, ADR-0002/0003(amended)/0004/0006/0007/0008, tickets 18/23/30, the
v1 verdict `03-carplay-verdict-v1.md`, and `design/02-androidauto-design-v2.md` for cross-surface claims.

---

## FATAL

### F1 — The "free for me" lens asserts an unproven negative: `0 of N free` over bays that are Unknown.

**Rule broken:** the design's **own §5.3 Law 1** — *"The denominator is the **known** set, never `baysTotal`"*
— plus its own §14.14 (*"`0 of 2 free` is never emitted over bays that are Unknown"*), its own §6.4 S2 note
(*"**never** `0 of 2 free`; the bays are Unknown, not empty"*), CONTEXT.md **Unknown** (*"Not to be rendered
as an error or an absence"*) and ADR-0002.

§6.4's grammar has three rows. Row 2 fires only when **every** bay offering `T` is Unknown. Every
partial-Unknown case therefore falls to row 3, whose form is
`<freeBaysOffering(T)> of <baysOffering(T)> bays free`. `baysOffering(T)` is defined in §6.3 as a **capacity**
count (*"# bays carrying ≥1 Connector of type T"*) — it includes Unknown bays. So:

> Station with 2 Type 2 bays: B1 Occupied (operator, 10 min), B2 never reported.
> §6.4 row 3 renders **`0 of 2 Type 2 bays free`**.

That is a positive claim that B2 is not free. It is exactly the assertion §5.3's Law 1 was written to make
impossible, and it is decision-changing in the wrong direction: a GB/T or Type 2 driver is told a station is
full when half of it is simply unreported — at 87 % Unknown, this is the *normal* case under a lens, not an
edge. The non-lens grammar §5.3 is careful here (`1 in use · 1 unreported`); the lens grammar silently drops
that care.

Note the shape of the defect: a table in §6.4 is disproved by a law in §5.3 and by a bullet in §14 — the same
failure mode that produced both fatals last round.

**Fix:** delete §6.4's row-3 form. Apply the §5.3 grammar (which is already total and already honest) to the
lensed **subset**, and describe the remainder as one un-counted side of the partition. Android's §3.6 already
does exactly this (*"Name exactly one side of a binary partition"*, and `2 GB/T bays · up to 60 kW` for the
unknown case) — CarPlay should adopt Android's lens grammar rather than carry a second, weaker one. Then
`freeBaysOffering(T)`'s denominator becomes `knownBaysOffering(T)` and the `0 of N` string is unreachable by
construction.

---

### F2 — The directions ladder cannot detect its own primary failure mode, and §11.4 claims guideline-3 compliance it does not deliver. D2 is re-worded, not fixed.

**Rules broken:** CarPlay review guideline 3 `[hard]` (*"All CarPlay flows must be possible without
interacting with iPhone"*); **ADR-0004 car-screens clause**, verbatim: *"Launching Google Maps onto the
CarPlay/Android Auto display is undocumented and unverified; it is an enhancement pending ticket 27's device
test, and **ticket 18 designs without assuming it**."*

§8.1 rung 1 is `comgooglemaps://…` via the scene's `open(_:options:completionHandler:)`, *"gated on
`canOpenURL` **and** chained on the completion handler's `false`."* Neither gate can see the failure that
matters:

- `canOpenURL` reports only that **some** app claims the scheme.
- the completion handler's `Bool` reports only that the URL **was opened** — never *on which display*.

The constraint sheet flags precisely this as `[UNKNOWN — must be verified on hardware]`: *"Google Maps is
itself a CarPlay navigation app so the scene-`open` route should land it on the car screen, but neither vendor
documents this."* If it lands on the **phone**, rung 1 returns `true`, rung 2 never runs, and the primary
action of the primary category has silently pushed content onto the phone the driver must not touch. That is
D2's guideline-3 hazard, unfixed — v1's §10.10 at least *named* the lands-on-the-phone variant; v2 has deleted
it from the compromise ledger (§12 covers only "Google Maps absent") while strengthening the claim.

Two statements in v2 are therefore false as written:
- §11.4 guideline 3: *"the primary action cannot land on the phone or dead-end."*
- §14: *"**No longer on the critical path** — rung 2 guarantees the flow either way."* Rung 2 is reached only
  on a failure-to-open; it guarantees nothing in the lands-on-phone branch.

Compounding it: the whole D2 remedy rests on Apple Maps *degrading to a visible destination pin* for a Rwandan
`daddr` when it has no directions for the country. Nobody has verified what Apple Maps on CarPlay actually
renders in that case (an error sheet is at least as likely), and **that verification is not on §14's list.**

**Fix (three parts):**
1. Make rung 1 conditional on ticket 27's device test — a build-time or remote-config flag defaulting **off**,
   which is what ADR-0004 already requires of ticket 18. Ship rung 2 as the shipped path until verified.
2. Rewrite §11.4's guideline-3 row and §14's "no longer on the critical path" to state what the ladder can
   actually guarantee, and restore "may land on the phone" to §12 as a named compromise.
3. Add "what Apple Maps renders on the CarPlay screen for a Rwandan `daddr` with no route" to §14 and §15.8 as
   a **blocking** item, since guideline-3 compliance now rests on it.

---

## MAJOR

**M1 — The displayed *age* never rolls over, so `14 min ago` can sit on screen for hours. D4 is half-fixed.**
Rule: ADR-0002 — *"Freshness cannot be a state… carried as a timestamp alongside every displayed value"*;
the design's own §7.2 premise that a value must not be rendered past what the device knows.
§7.2's `nextDecayDeadline` mins over **availability decay, rate 90-day, watch 2 h** only. The age *string* is
not in it. A detail screen opened on `Operator · 14 min ago` has its next deadline at +6 h, so it renders
`14 min ago` for up to five hours and forty-six minutes. The state stays inside its window — but the freshness
axis, which ADR-0002 makes the entire confidence expression, is stale and confident. This is D4's failure
relocated from the state axis to the axis the driver actually reads.
**Fix:** add the next age-label boundary to `nextDecayDeadline` (`just now`→`N min`→`N h`→`N days`
transitions), coalesced to ≥60 s on the POI template and ≥10 s elsewhere so the inferred floors still hold.

**M2 — `canWatch` accepts `.provisional`, which re-opens D1's hole.**
Rule: A15 `[hard]` — CarPlay notifications require `.carPlay` authorisation **and** an `allowInCarPlay`
category, *"either alone is insufficient"*; the design's §11.5 claim that the action is *"gated on the
authorisation actually being granted."*
§8.2 sets `canWatch = isSignedIn && notificationAuthorization ∈ {authorized, **provisional**}`. Provisional
authorisation delivers quietly — no banner, straight to Notification Center. A provisional alert is precisely
the alert a driver will never see while driving, which is the entire content of D1's first hole. The design
also never says *who writes* `canWatch: Bool` into Store B (§10.3), so a mirrored bool can outlive a phone-side
sign-out or a revoked permission.
**Fix:** `canWatch` requires `.authorized`. Re-read live from `UNUserNotificationCenter` at compose time (it
is readable while locked) and treat the facet's bool only as a pre-first-unlock pessimistic default.

**M3 — The max-3-armed ceiling has no rendering, so `Alert requested` becomes a knowable two-hour lie.**
Rule: ticket 30 clause 3/4 (*"Max **3** concurrent watches per user"*); ADR-0002 honesty; the design's own
§8.2 principle that *"the row states exactly what EV Guide knows."*
§3.5 and §11.5 both cite "max 3 armed" as the spam control, but §8.2's three-state table has no fourth state
and §0.5's count invariance forbids hiding the action. A driver with three armed watches taps `Notify when
free` on a fourth station: a `pendingIntent` is written, the item reads `Alert requested · not confirmed yet`,
the server rejects it, and the row sits for two hours asserting a request the device **already knew** would
fail — `armedWatches[]` is right there in Store B. That is D1's shape in a branch D1's fix never considered.
**Fix:** check `|armedWatches| ≥ 3` before writing the intent, and present a third alert **A3**
(`titleVariants: ["You're already watching 3 chargers", "Already watching 3", "3 already"]`, one `OK` action) —
same pattern as A1, count-invariant, and states a condition without instructing phone manipulation.

**M4 — §2's budgets are unreachable given §15.13's authored bounds, and the slot that overflows truncates into a *false number*, not into lost information.**
Rule: A11 `[hard]` — `CPListItem` takes a plain `String`, no variants, **no truncation control**; §11.3's claim
that every string is *"authored to a §2 budget."*
`place-line = <nameShort> · ~<distance>` sits in a slot budgeted at **26** (§2), while §15.13 asks ticket 19 to
bound `nameShort ≤ 18`. 18 + 3 + `~187.2 km` (9) = **30**. The notification title is budgeted at **28**;
18 + 3 + `a bay is free` (13) = **34**. §13.2's defence of keeping distance on the row (*"19 chars — both fit
comfortably"*) is measured on the fixture only.
The consequence is worse than an overflow. §5.4's doctrine is that truncation must *remove* information rather
than manufacture a claim — but here the tail is a **number**: `Nyamirambo Center · ~187.2 km` cuts to
`Nyamirambo Center · ~18`, which reads as a valid, plausible, ten-times-nearer station. A driver picking on
remaining range picks wrong. This is the one slot where the design's own truncation doctrine inverts.
**Fix:** the composer must pre-truncate the *name*, never the number: reserve the distance token, ellipsise
`nameShort` to fit, and drop the decimal above 100 km (`~187 km`). Reconcile §2 and §15.13 so the bound is
`nameShort ≤ 26 − 3 − maxDistanceToken`.

**M5 — Map-tab distances are measured from the map centre while list-tab distances are measured from the driver, and `Chargers in view` does not say so. D9 is unfixed in the panned case.**
Rule: the honesty rule D9 was raised under; A3 `[hard]` re-ranking on region change is mandatory, but computing
*distance* to the region centre is the design's own choice.
§7.3 row 1 sets the Map tab's **origin** to the visible-region centre. §7.4 computes every distance from "the
origin". So a driver in Kigali who pans to Musanze reads `~2.4 km` for a station 90 km away — the exact defect
D9 named — and the same station simultaneously reads `~91 km` on the Nearby tab. `Chargers in view` names the
*filter*, not the *origin*, so the title-based remedy that fixed the Kigali case does not fire here. Panning
is the POI template's core interaction, so this is the frequent case, not the exotic one.
**Fix:** decouple ranking from measurement — rank to the viewport (as `[hard]` requires) but keep the
**driver's** origin for the rendered distance. If the map centre must be the origin, the title must say so
(`Chargers near map centre`) and the divergence from the list tab must be carried in §12.

**M6 — The freshness head is not lens-scoped, so under a lens the source and age date reports about connectors outside the set being quantified.**
Rule: ADR-0002 — *"Confidence as source plus age"*, carried *"alongside every displayed value"*; Part C rule 4
(*"Freshness rides alongside availability as a separate axis"*).
§5.4 defines contributing reports as *"the latest report per Connector … that belongs to a bay counted in
`known`"* — with no lens term. §6.2 then changes the availability clause to a lensed subset. The result:
`Availability  1 of 2 GB/T DC bays free` sitting under `Last report  Driver · 40 min ago`, where the 40-minute
driver report was about a **Type 2** connector. The head no longer dates the claim beside it, and the row form
puts them in the same string.
**Fix:** parameterise the freshness head by the lens — contributing reports are those on bays counted in
`known ∩ offers-T`. Route it to ticket 19 with §15.5.

**M7 — The `Distance` item is simultaneously the only place ADR-0007's straight-line label is spelled out and the item the design designates as expendable.**
Rule: ADR-0007 — straight-line distance *"labeled as such"*; A5 `[UNKNOWN]` — `CPInformationTemplate` has no
documented and no queryable item cap.
§13.2/D10 rests compliance on *"the `Distance` item [which] spells it out on the screen where the driver
commits."* §11.3 then says *"`Distance` is the designed casualty"* and §3.3 puts it last. The design already
learned this lesson for Rate (*"`Rate` is pinned at position 3 and can never be the tail"*) and did not apply
it to the item carrying a settled ADR obligation. The `~` prefix is not a substitute — to a driver `~` reads
as *approximately*, not *crow-flies*.
**Fix:** either fold the label into the value that always survives (`Availability`/`Connectors` row is wrong;
better: make it `Distance  ~2.4 km straight line` pinned at position 4, ahead of `Bay alert`), or carry
`straight line` in the POI `detailSummary` (already 74/90 chars for S1, room exists) so it does not depend on
an unqueryable cap.

**M8 — The two car surfaces speak different words for the same derived state, while both route one shared pure function to ticket 19.**
Rule: `CONTEXT.md` is the ubiquitous language; §15.1.4 routes the grammar as *"a pure function of
(f, o, x, u, total, verbosity, lens) … **Not in the CarPlay layer**"*; the Android v2 design routes the same
function.
§2 declares the vocabulary *"fixed, closed, and the only words on the surface"*, bans **`busy`** by name
(*"The word `busy` does not exist on this surface"*) and bans the literal **`Unknown`**. `02-androidauto-design-v2.md`
§4.0 renders `1 bay free · **1 busy** · 1 out of service · **1 unknown**`. One shared function cannot emit both
vocabularies, and ticket 19 will be handed two contradictory specifications of the same signature.
**Fix:** settle one vocabulary in `CONTEXT.md` before 19 locks, and make both design docs cite it rather than
each declaring its own closed set.

**M9 — The rate grammar counts *bays* for a property that lives on *Connectors*, and the fixture built to catch exactly this class does not exercise it.**
Rule: `CONTEXT.md` **Rate** — *"A property of the **Connector**, not the Station: a 7 kW AC bay and a 120 kW DC
bay at one site do not cost the same"*; the M4 lesson §6.3 encodes for availability.
§5.5 emits `600 RWF/kWh · all 4 bays · 12 days ago` and `600 RWF/kWh · 3 of 4 bays · 1 unpriced`. For a
dual-gun bay whose GB/T is priced and whose Type 2 is not, the design defines neither the numerator, the
denominator, nor the `unpriced` unit. Fixture S4 — introduced precisely because *"the required example has
four single-connector bays, which is exactly the shape in which the double-counting defect is invisible"* —
gives both guns the same 600 RWF/kWh, so it reproduces the blind spot on the rate axis. (Android's fixture does
carry two distinct rates on one bay, 600 and 400, and so would break this grammar immediately.)
**Fix:** state the rate clause over **connectors**, not bays (`600 RWF/kWh · 4 of 5 plugs · 12 days ago`), and
give S4 two distinct rates on the shared pedestal so the corpus tests it. Route with §15.1.6.

**M10 — §5.3's row clauses routinely exceed §2's own 44-character budget, so §11.3's compliance claim is false.**
Rule: §2's budget table and its 20-character protected head; §11.3 (*"each authored to a §2 budget"*).
The head alone reaches **22** (`Operator · 21 days ago`), over its own 20-char reservation. Head + separator +
the row clause for `f=0, o>0, x>0, u>0` is `Operator · 21 days ago · 1 in use · 1 out of service · 2 unreported`
= **67** against a 44 budget. Six of §5.3's ten grammar rows overrun the 24-character residual. §12.2 carries
this as a narrow-head-unit edge case; the arithmetic says it is the typical case for anything but the two
simplest states.
**Fix:** give `availability-line` a third verbosity (`rowCompact`) that fits 22 residual characters, or shorten
the vocabulary (`o/s` for `out of service` is not available — plain `String`, no variants — so the clause set
itself must shrink). Reconcile §2, §5.3 and §12.2 to one number.

---

## MINOR

1. **`selectedPinImage` / `selectedPinImageSize` are iOS 16+** (constraint sheet A3.1) against a declared iOS 14
   deployment floor (§1.1). §3.1 and §11.2 use them unconditionally, and §14's verification list asks for their
   runtime *values* without noting the availability floor. Add the guard and the iOS 14/15 fallback (one pin
   image for both states).
2. **The protected head is 22 characters, not 20.** §2 reserves *"first 20 chars = source + age"*; the longest
   legal head from §2.1's own vocabulary is `EV Guide · 21 days ago` = 22. A unit cutting at 20 yields
   `Operator · 21 days a`.
3. **Decay-deadline clustering can breach the 60 s POI floor the design claims to obey "trivially" (§7.2).**
   Twelve POIs whose operator reports were captured within the same minute produce twelve recompositions inside
   sixty seconds. Coalesce deadlines into a 60 s bucket for the POI template.
4. **No recompose on scene resume.** §10.4's trigger table has "Scene connect" but not "scene became active".
   A one-shot timer missed while the scene was suspended (driver in Maps, then back) restores exactly D4's
   stale screen. Add resume as a recompose trigger and fire any missed deadline immediately.
5. **Store B's pre-first-unlock behaviour is unstated.** §10.1's floor table covers Store A only (and its row 3
   is literally `— | — | —`). Before first unlock `canWatch`, `armedWatches` and `savedStationIds` are all
   unreadable; say explicitly that the surface degrades to `canWatch = false`, no Saved tab, no armed state.
6. **`"No chargers within 200 km"` is a false specific claim wherever it is reachable.** With the Kigali
   centroid fallback (§7.3) and the bundled snapshot floor (§10.1), the only path to the empty state is an
   empty *directory* — for which "no chargers within 200 km" is not the true statement. Reword the longest
   variant.
7. **§5.3's prose under-describes its own table.** The text says *"The row form drops `x` when `f > 0` and
   `u > 0`"*; the table's row 3 also drops `o` (S3 renders `1 free · 1 unreported` for `f=1, o=1, x=1, u=1`).
   Say both, or the rule will be implemented as written.
8. **The freshness head misattributes provenance.** Weakest-source + oldest-age is a lower bound, and it is the
   safe direction — but S3 renders `Driver · 40 min ago · 1 free` where the free bay was an **operator** report
   25 minutes old. Nothing on the surface says the head is a bound rather than the provenance of the adjacent
   fact. Consider binding the head to the report behind the *leading* clause when `f > 0`.
9. **§10.4's 500 m re-rank exception swallows its own rationale, and is misattributed to Android.** The rule
   exists to prevent *"a list reordering under a reaching finger"*; at 60 km/h, 500 m is every 30 seconds of
   driving. And the claim *"on Android the same discipline is additionally a quota requirement"* is wrong:
   `02-androidauto-design-v2.md` latches the origin, never re-anchors mid-instance, and names the host's
   content-refresh listener plus the launcher relaunch as the **only** re-rank paths — it cannot implement a
   500 m re-rank at all. Fix the sentence, and gate the CarPlay re-rank on the vehicle being stationary or on a
   user action.
10. **§3.5 asserts mutability §14 says is unverified.** *"If a detail template is already on top, its content is
    replaced in place"* presumes `CPInformationTemplate.items` is settable; §14 lists that as an open question.
    State the pop-then-push fallback in §3.5, as §14 does elsewhere.
11. **§14.13's "no offline indicator on CarPlay" diverges from ADR-0007** (*"Offline gets a quiet indicator"*)
    but is carried only in the inference ledger. The design routes ADR-0004 and the ADR-0007 distance note as
    amendments (§15.4, §15.5); this divergence deserves the same treatment rather than a bullet.
12. **`~` is asserted as the crow-flies label** (§7.4, §13.2/D10) without the phone surface being shown to use
    the same convention. If the phone renders Valhalla driving distance without `~`, the convention works; say
    so, and route it with §15.5.

---

## What is sound, and should not be relitigated

- **Template selection and the forbidden set.** Five permitted classes, `CPMapTemplate` / `CPContactTemplate` /
  `CPNowPlayingTemplate` / `CPChargingStationConnection` never referenced, enforced by a build-time source check
  rather than review discipline. A0's runtime-exception hazard is fully avoided.
- **Every documented numeric cap is respected**: ≤12 POIs, exactly two POI card buttons, ≤3 Information actions
  (two used), ≤5 tabs (three, with a documented degradation ladder), ≤3-char `markerLabel`, tab icon
  24 pt / 48 @2× / 72 @3× (D17 correctly fixed), alerts `presentTemplate` not `pushTemplate`, tab bar root-only
  and containing only POI/List/List, one action per alert against an unqueryable `maximumActionCount`.
- **The depth proof is structural and correct.** Three push edges, all 2→3, detail is a sink, max depth 3 with
  two levels of headroom. Cutting `Other free bays` genuinely removed D11 and D16 together with the unverified
  stack-introspection API — that is a real fix, not a re-wording.
- **§5.2 `bayState(bay, now)` is total and matches ADR-0008.** The precedence order is right, and the S4/B1,
  S4/B2 and S3/B2 worked cases are all correct.
- **§5.3's non-lens grammar is total over `(f, o, x, u)` and never overstates.** `busy` is genuinely gone,
  `OutOfService` genuinely never folds into occupancy, and the `N of M` shorthand is correctly confined to
  `u = 0`. Android's F2 is fixed here.
- **§10.2 — raw per-Connector reports on device, never the materialised aggregate — is the right load-bearing
  call**, correctly identified as the only construction under which ADR-0008's promise is true on the car, with
  `reporterId` and `capturedLocation` stripped by a named projection.
- **§10.3 — the credential has one home, and the car template layer never authenticates.** Making the
  arm/disarm path a `pendingIntent` write drained out-of-band by `WatchSyncQueue` turns D1's honesty fix into
  an architectural property. The *not-confirmed-yet* third state and the client-side 2 h expiry of a queued arm
  are both correct and both mirror ADR-0007's rule for reports.
- **D3's fix (bundled snapshot as the pre-first-unlock paint floor) is correct, free, and uses a settled asset.**
- **D5's fix is right**: the capacity clause (`3 bays · CCS2 and Type 2`) spends the scarcest slot on what the
  listing knows, and the ban on the literal string `Unknown` is well executed everywhere outside §6.4.
- **No sign-in wall exists anywhere**, `Directions` is unconditional and anonymous on every path, account-gated
  affordances are silently omitted, and §11.4's string-by-string guideline-2 audit is the right discipline.
- **The paint path carries zero network I/O**; no screen's first paint is a loading state; delta sync is
  background and silent; arm/disarm never blocks.
- **D12 (grid lens tab) and D13 (`Notify when free`, 16 chars) are correctly and cheaply resolved**, and D21's
  expression of ticket 30 clause 3 as alert A1 rather than a disappearing button is the better call — count
  invariance (§0.5) is a genuinely good law imported from the Android side.
- **§15's routing to ticket 19 remains the strongest part of the document**: `bayState`, the four named
  projections, the vector `Owner.icon`, the authored length bounds, the dual-gun fixture, the disagreeing-
  aggregate fixture, and the facet-with-exclusion-list resolution of D15 would each otherwise become a bug.

---

**Verdict: does not ship as-is.** Two fatal defects — a lens grammar that asserts bays are not free when the
system only knows they are unreported, disproved by the design's own Law 1; and a directions ladder whose
first rung cannot detect the one failure the constraint sheet flags as undocumented, while §11.4 and §14 claim
the opposite and ADR-0004 forbids assuming it — plus ten major defects, of which M1 (the age string never
rolls over) and M5 (map-centre distances) are cheap to fix and materially change what the driver reads.
