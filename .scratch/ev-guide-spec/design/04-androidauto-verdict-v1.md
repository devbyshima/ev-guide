Read: research 04 in full (1972 lines), `docs/domain-model.md`, `CONTEXT.md`, ticket 18, plus tickets 09/12/23/27/30 and ADR-0002/0003/0004/0007/0008 to check the design against what is actually settled.

---

# DEFECTS

## FATAL

**F1 — A background availability change mutates the pane's row count, which is a new template, not a refresh. At 4/5 or 5/5 the host closes the app while the driver is driving.**
*Rule:* `PaneTemplate` counts as a refresh only when "title unchanged **and** row count and row titles unchanged" (research §2.5). Exceeding 5 templates: *"the host displays an error message and closes the app."*
*Where:* §6.2's visibility table makes row 4's **presence** depend on availability — "signed in, watched set already Free → row 4 absent" (and ticket 30 §3: "Arming is only offered when the watched set is not already Free"). Also "signed in, 3 watches already armed → present" flips on a watch firing elsewhere. So a report landing on the open detail screen — the single event this whole surface exists to deliver — changes the pane from 4 rows to 3. §3.4's claim that "a report arriving repaints both screens at **zero quota cost, indefinitely**" is contradicted by §6.2 in the same document. §3.6's TemplateLedger rule 1 does not catch it: it omits the *action*, and the trigger here is not a tap.
*Fix:* row 4 is **always present for a signed-in user**, and only its *text* varies (`Not watching` / `Watching · until 14:05` / `Bays are free right now` / `3 alerts already running`). Make it a written invariant of the design: **no row count on any template may vary with availability, freshness, or watch state — only with sign-in state, and sign-in cannot change while the pane is on screen.** Same audit applies to the Rate row collapsing and to the anonymous 3-row/signed-in 4-row split.

**F2 — The availability grammar is not total, and its gaps assert exactly what the product cannot know. `Unknown` bays render as "busy"; `OutOfService` bays render as "busy".**
*Rule:* settled — availability is four-state per Connector, `Unknown` is the normal case and "not to be rendered as an error or an absence" (CONTEXT.md); ADR-0002 keeps `OutOfService` a distinct state precisely because *"occupied means wait, broken means go elsewhere"*.
*Where:* §2.1's grammar table has five rows: some free / none free / mixed-with-OOS / all OOS / all Unknown. It has **no clause for the overwhelmingly common mixed known-and-Unknown case**. Decay windows differ per source and state (driver 2 h, operator 6 h, OOS 30 d), so bays at one station decay at different moments — partial-Unknown is not an edge case, it is the steady state. Under the table as written:
- 2 Occupied + 2 Unknown → falls into "none free" → **`All 4 bays busy · driver, 35 min ago`**. That asserts Occupied for two bays whose state EV Guide does not hold. This is the confident-stale failure ADR-0008 says is "unrepresentable".
- 2 Occupied + 2 OutOfService → also "none free" → **`All 4 bays busy`** — sends the driver to wait at chargers that will never free, the exact failure the fourth state exists to prevent.
- 2 Free + 2 Unknown → `2 of 4 bays free`, which reads as "and the other two are taken".
*Fix:* make the denominator the *known* set, never `baysTotal`, and surface the unknown remainder: `2 of 4 bays free · operator, 14 min` only when all 4 are known; otherwise `2 free of 2 known · 2 unknown · operator, 14 min` (short variant `2 free · 2 unknown`). Never emit the word "busy" over a bay that is `Unknown`, and never fold `OutOfService` into "busy" at any count. Route the total grammar (a clause per point in the 4-state × N-bay space) to ticket 19 alongside the projection typing.

---

## MAJOR

**M3 — The aggregate carries a single `source` word, but a station's bays routinely have different sources. Showing one mislabels the others.**
*Rule:* ticket 11 / ADR-0002 — "source always shown"; confidence is *source plus age*, and the two decay differently (driver 2 h vs operator 6 h).
*Where:* every row and pane string is `… · operator, 14 min ago` — one source, one age. §5 defines `lastReportedAt` as the **oldest** contributing report but leaves `source` undefined. A station with three operator reports and one driver report renders as "operator", promoting a driver claim to operator provenance — which is the entire confidence axis.
*Fix:* define the aggregate's source in ticket 19 as the **weakest contributing source** (driver < operator < admin), and pair it with the oldest contributing `capturedAt` so age and source describe the same reading. When sources genuinely differ, `· mixed, 14 min ago` is honest and fits.

**M4 — "Free for me" bay counts double-count multi-gun bays and invent capacity.**
*Rule:* ADR-0008 / CONTEXT.md — a Bay carries **1..N Connectors**, and one vehicle on any of them makes the siblings unavailable. Modelling one connector per bay "would either undercount plugs or double-count capacity."
*Where:* §4.2's wording `1 of 2 GB/T bays free · Also 2 Type 2 bays` at a 4-bay station. If two of those bays are dual-gun (GB/T DC + Type 2 on one pedestal — Kabisa's real shape per ADR-0008), the per-type counts sum to more than `baysTotal`, and "**Also** 2 Type 2 bays" reads as two *additional* parking positions that do not exist. The §2.0 worked example has four single-connector bays, which is exactly why the defect is invisible in it.
*Fix:* per-type counts must be over **bays that carry that type**, stated non-additively: `1 of 2 GB/T-capable bays free` / `2 more bays, Type 2 only`. Add a dual-gun station to the shared fixture corpus (§7.4) — the corpus as described tests decay and propagation but not the counting.

**M5 — Two of the three `PF-1` functions are invisible to the reviewer who applies `PF-1`.**
*Rule:* `PF-1` — POI apps "must provide meaningful functionality relevant to driving"; Apple's parallel "your app can't just be a list of EV chargers". Ticket 23 settled that the bar is cleared by three functions, one of which is bay-watch.
*Where:* §6.2 makes bay-watch **invisible to anonymous users, with no explanation** (compromise 9). A Play reviewer, working from the US on a mock GPS with no account, taps `Show stations in Kigali` and sees: a static host map, six rows of name + distance + "No recent report" (the bundled snapshot is all-`Unknown` by ADR-0007, and nothing in a US session will have live Rwandan reports), and one `Directions` button. That is **precisely** "a list of EV chargers plus a nav hand-off" — the shape both clauses name. The design's own inference 5 calls this "the largest open risk" and then removes two of its three answers from the reviewer's view.
*Fix:* two cheap, non-structural moves, both compatible with "no sign-in wall on a car screen": (a) supply a signed-in demo account in Play Console → App access and in Apple's review notes, with a script that signs in **on the phone** before connecting (the car screen never shows a wall — the state is simply already true); (b) seed the demo/mock path with reports so the availability layer is *populated* rather than uniformly `Unknown` when reviewed from outside Rwanda. Route both to ticket 20 as a hard submission dependency, not a nicety.

**M6 — The entire Android bay-watch delivery path rests on an API research 04 never examined, and Android Auto notification eligibility for a POI app is unestablished.**
*Rule:* research 04 documents notifications for **CarPlay** EV-charging apps by name (Developer Guide p.27). For Android it documents only `IN-1` and `NA-1` — it says nothing about `CarAppExtender`, `CarNotificationManager`, or whether a POI app's notification is surfaced on the car screen at all.
*Where:* §2.6 and the design's own inference 9. `IMPORTANCE_HIGH` is specified, which on Android Auto is the heads-up path — historically reserved to messaging and navigation categories. If a POI app's notification is filtered, bay-watch on Android delivers to the phone only, and one of the three `PF-1` functions does not exist on the surface being reviewed.
*Fix:* promote this to a **blocking** ticket-27 DHU item, above the current #1 (`ACTION_NAVIGATE`), because it decides whether ticket 23's three-function answer holds on Android at all. If POI notifications are not surfaced, the Android `PF-1` case reduces to two functions and ticket 23's resolution needs revisiting — do not discover that at submission.

**M7 — The car surface performs an authenticated network write, and the design never says where the credential lives.**
*Rule:* car constraint 9 — the car cache holds "only non-sensitive directory + availability data"; ticket 30 §5 — push tokens are user-scoped and "never enter the car cache".
*Where:* §7.2's `WatchClient` arm/disarm POST. Arming a watch is user-scoped, so the request needs a session or bearer token readable by the Kotlin car layer with the app possibly backgrounded. §6.3 carefully extends the cache by `isSignedIn` and `armedWatches` and flags it — and then omits the one item that is actually a secret. On the iOS twin (which §0 and §10.1 say shares this design) that credential must sit at `kSecAttrAccessibleAfterFirstUnlock` to be readable while the phone is locked, which is a real security decision, not an oversight to inherit.
*Fix:* state the credential explicitly and route it to 19 with the other two fields: either (a) the car layer never authenticates — it writes an intent record into the shared store and the phone process performs the authenticated POST when next resumed (loses `DR-1`-visible confirmation, which the async row-text pattern already tolerates), or (b) a narrow, watch-scoped token at first-unlock accessibility, named as an amendment to car constraint 9. (a) is preferable and keeps constraint 9 intact.

**M8 — "A stale green is impossible by construction" only holds if the car cache carries per-Connector raw reports. The domain model says the payload carries materialised aggregates.**
*Rule:* ADR-0008 — `baysFree` and `lastReportedAt` are "computed projections **materialised into sync payloads**"; the honesty guarantee comes from re-running the derivation at render time.
*Where:* §7.1/§7.4 say `AvailabilityKt` derives over "the local snapshot" but never state the cache's shape. If the snapshot holds the materialised aggregate, the Kotlin layer cannot re-apply decay (it has no `capturedAt` per connector), cannot re-run bay propagation (it has no sibling grouping), and cannot produce §4.2's per-type wording — and a `baysFree: 2` written at sync time renders confidently hours later. This is the one place the design's central safety claim is unbacked.
*Fix:* specify the car cache schema in §7 and route it to 19: per-Connector `{bayId, type, powerKw, ratePerKwhRwf, rateConfirmedAt, latestReport{state, source, capturedAt}}`. The materialised aggregate may ride along as a server-side convenience but **must not be the car's render input**. Add a fixture whose materialised aggregate and device-derived aggregate deliberately disagree.

**M9 — `stationsNear`'s reserved compatibility slot contradicts the design's own rule and the settled ranking.**
*Rule:* domain-model — `stationsNear` is "ranked **distance-first** then availability". §4.2's own rule: "The profile changes the wording of the row, **never its presence** and never its order."
*Where:* §4.2's last paragraph reserves the final slot for the nearest compatible station, which displaces the 6th-nearest — a presence change, driven by the profile, breaking a total order at exactly the point where the six-row floor bites.
*Fix:* either drop the reservation and keep the ranking total (the incompatibility wording already tells the driver why the six nearest are useless), or make it an explicit, named second ranking key in ticket 19 and delete the "never its presence" claim. Do not keep both sentences.

**M10 — `setCurrentLocationEnabled(true)` is called unconditionally; the permission arrives on the phone and may never be granted.**
*Rule:* research §2.4 — `setCurrentLocationEnabled(true)` requires `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION`; §2.7 — on Android Auto the runtime-permission dialog appears **on the phone**.
*Where:* §2.1's template-call table lists it with no guard, while §2.5 handles only the *origin* being absent. The reviewer's first run and every pre-grant run hit this.
*Fix:* guard the call on `checkSelfPermission`, and make the S2 → S0 transition explicit in the §3.2 cost table (it is a `MessageTemplate` → `PlaceListMapTemplate` swap, **+1**, and it can fire repeatedly if permission is toggled — cap it).

**M11 — Six brand logos on the map plus one on the pane is an `IU-1` exposure, and `TYPE_IMAGE` forecloses the only theming lever.**
*Rule:* `IU-1` — "**No images except**: a single static context image, nav-drawer icons, images that aid driving decisions, lane/junction guidance." `setColor()` is illegal with `PlaceMarker.TYPE_IMAGE`.
*Where:* §8 uses `TYPE_IMAGE` Owner logos on every marker (up to 6) **and** `Pane.setImage` for the same logo. §9 claims `IU-1` is satisfied by "one Owner mark per station as the pane image" — which quietly omits the six markers. Choosing `TYPE_IMAGE` also removes `setColor`, which is why §8 then needs inference 8 (`-night` qualifier resolution) to survive `VD-1`/`TH-1` at all.
*Fix:* markers become `TYPE_ICON` (64×64 dp, tintable) or label-only; the single Owner brand image stays on the pane, where it is defensibly the sanctioned context image. This also **deletes inference 8**: Android Auto uses a black ground in day *and* night (research §2.7), so one light-on-black monochrome mark is correct in both modes and no `-night` variant or host-resolution assumption is needed.

**M12 — `DR-2` is asserted, not designed for: the car service shares the app process with React Native.**
*Rule:* `DR-2` — app launches in ≤ 10 s.
*Where:* §7.4 claims the car layer runs "with no React Native runtime attached". `CarAppService` starts in the app's normal process; if `MainApplication.onCreate()` initialises the RN host (the default in every Expo/RN template), the car service pays Hermes + bundle load before `onGetTemplate` returns, on a cold connect, on a mid-range Android phone.
*Fix:* either declare `android:process=":car"` on the service (SQLite across processes is fine with the right journal mode — state it), or gate RN initialisation on a non-car entry point. Route to ticket 15 / ADR-0006 as a build-shape constraint, since it is a claim about the *codebase*, not the car layer.

**M13 — `OriginProvider`'s "hard 1.5 s budget" sits on `Screen.onGetTemplate()`, which must return synchronously.**
*Rule:* `onGetTemplate` is a synchronous main-thread call; `DR-2`/`DR-3` and ANR both bite.
*Where:* §7.3. "Budget" implies waiting. `getLastKnownLocation` returns immediately or returns null — there is nothing to wait 1.5 s for except a fresh fix, which §7.3 also forbids.
*Fix:* delete the budget. `onGetTemplate` reads last-known synchronously and returns either the list or the `MessageTemplate` on the same tick; if a fix arrives later, apply it on `onResume` — and price the resulting template swap (M10).

---

## MINOR

**m14 — §9's compliance claim "longest authored string is 43 characters" is false.** `1 of 4 free · 1 out of service · operator, 14 min` is 49; `All 4 bays out of service · operator, 3 days ago` is 48; `Open EV Guide again from the car screen to keep browsing.` is 57; and §2.5's VI-1 body — `Location isn't available yet. Android Auto asks for location permission on your phone. Check it only when it's safe to do so.` — is ~125, over the 120-character glanceability guidance the same table claims to honour. *Fix:* recount, and split the VI-1 message into message + a shorter second line, keeping "look at your phone only when it's safe" intact since `VI-1` mandates it.

**m15 — `Rate` strings assert coverage they may not have.** `600 RWF/kWh · all bays` is false when one Connector's rate is `Unknown` or past its 90-day window; `From 600 RWF/kWh · 3 rates` asserts a floor over a set that may include Unknowns. Rate carries its own `Unknown` (CONTEXT.md). *Fix:* `600 RWF/kWh · 3 of 4 bays` / `From 600 RWF/kWh · 1 rate unknown`. Same total-grammar discipline as F2.

**m16 — The one-tap arm never says what `connectorTypes[]` it sends.** Ticket 30 binds `watch(stationId, connectorTypes[])`, defaulting to all types, settable to "my plug" — and §4.2 introduces a device-local profile the server has never seen. Arming with `[]` alerts a GB/T driver for a freed Type 2 bay; arming with the local profile silently changes what fires when the driver changes cars. *Fix:* state it — the POST carries the local profile's types when one exists, empty otherwise, and row 4's second line says which (`One alert, next 2 hours · GB/T only`).

**m17 — `QuotaGuard` is a dead end reached by pressing Back.** If the pop refund does not clear 4/5, the driver gets a `MessageTemplate` reading "Open EV Guide again from the car screen" with (as specified) no action on it. *Fix:* give it one action — `Directions` to the last-viewed station, the one affordance that leaves the app usefully — and confirm on the DHU that this branch is unreachable (open question 2).

**m18 — No re-rank path on a host below the content-refresh API.** §2.1's ⟳ is the *only* mechanism that changes the row set (compromise 8), it is guarded, and the design carries no ActionStrip. On a host where the guard fails closed, the list is frozen for the whole connection with no exit but relaunch. The design also guesses `@RequiresCarApi(3)`; verify the real level before writing the guard against it. *Fix:* when the listener is unavailable, seed the row set from a wider radius and say so, or add a single ActionStrip action as the fallback re-rank (§11's open question 8 already asks whether the strip allows 2 or 4 — it allows at least 2).

**m19 — The `geo:` hand-off drops the destination name.** §6.1 sends bare `geo:lat,lng`, so Google Maps shows an unnamed pin and the driver cannot confirm they are routing to the right station. The constraint sheet's own conclusion is "**a destination coordinate and a display name**". *Fix:* verify on the DHU whether `geo:0,0?q=<lat>,<lng>(<nameShort>)` is accepted by `startCarApp` (the javadoc lists three forms and this is a fourth) — if not, keep bare coordinates and record why, rather than leaving it unexplained.

**m20 — Ticket 18 asks the design to settle "voice and safety constraints on interaction while driving"; the Android half addresses safety and is silent on voice.** `VC-1` does not apply to POI, but the POI guide demonstrates *"Hey Google, find nearby charging stations on ExampleApp"*, and a one-line decision (out of v1, with the reason) is owed. *Fix:* add it beside the `SearchTemplate` refusal in §1.3.

**m21 — `CONTEXT.md` still gates directions behind an account.** Line 44: "needs an account to act — **directions**, saving, reporting, profile sync (ADR-0003)". ADR-0003's amendment and ticket 23 removed that; the glossary was not updated. The design leans on the amendment throughout and does not route the correction. *Fix:* add to §11's routed list — glossary edit, one line.

**m22 — The anonymous "free for me" story rests on reading ticket 12 narrowly.** Ticket 12's answer lists "sync the vehicle profile that powers 'free for me'" as account-gated, but its *question* lists "setting your own connector type" among the things requiring sign-in. Inference 10 is flagged, but the consequence is not stated: if the founder reads it the other way, §4.2's entire wording layer only ever appears for signed-in drivers, and the anonymous reviewer of M5 sees the generic aggregate. *Fix:* get the one-line ruling from 12 before 19 locks, and note the fallback wording.

**m23 — Verify `PlaceListMapTemplate` is not itself deprecated at 1.7.x.** Google deprecated `CHARGING`, `MapTemplate`, `PlaceListNavigationTemplate` and `RoutePreviewNavigationTemplate` quietly, and now positions `SectionedItemTemplate` as the successor to List and Grid. The research read the template-overview page on one date. The whole design hangs on this template; a `@Deprecated` annotation would not break it but would change §0's calculus about declining `MapWithContentTemplate`. *Fix:* one grep of the pinned artifact before the design is called final.

---

# WHAT IS ACTUALLY SOUND

Said plainly, because most of it is: **no forbidden template is used** — `PlaceListMapTemplate` (POI-exclusive), `PaneTemplate` and `MessageTemplate` are all legal for `androidx.car.app.category.POI`, and `NavigationTemplate`/`MediaPlaybackTemplate` never appear. **No hard numeric limit is breached**: 6-row place-list floor honoured, 4-row pane floor met exactly, 2 text lines per row respected everywhere, `PlaceMarker.MAX_LABEL_LENGTH = 3` defended in three layers with no derived labels, `FULL_LIST`'s zero row actions honoured, and the 5-screen stack used to a depth of 2. **§3.4 is the strongest section in the document** — putting distance in a `DistanceSpan` (excluded from the refresh diff), availability in text and never in a title, and making every pane row title a constant label is exactly the right reading of the refresh rules, and it earns the live layer for free. The `SignInTemplate` refusal and the total absence of a car-screen sign-in wall are correct and close the 5.1.1(v) risk ticket 12 routed. Declining `MapWithContentTemplate` (§0) is well-argued and buys four real removals. The §3.3 quota proof is honest — it costs every undocumented point against itself — and it fails only because §6.2 introduces a template-consuming path the proof does not model (F1).

**Verdict: does not ship as-is — F1 will close the app on a driver mid-drive and F2 tells that driver a bay is busy when EV Guide does not know, but both are local fixes inside a fundamentally correct template strategy; fix F1, F2, M3–M8 and re-run the §3.3 proof, and this is submittable.**