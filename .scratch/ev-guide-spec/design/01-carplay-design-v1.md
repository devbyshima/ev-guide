.

### 8.4 Store C — credentials

The refresh/access token sits in Keychain at `kSecAttrAccessibleAfterFirstUnlock` **[inferred]**, readable while locked after the first unlock since boot. Its only car-surface use is authorising the arm/disarm POST. No car screen reads it, no car screen can trigger a sign-in, and if it is missing or expired the watch action simply does not appear (the facet's `isSignedIn` goes false).

### 8.5 Distance is computed, never fetched

CarPlay shows **great-circle distance only**, computed on device from `Station.geo` and the origin. Not Valhalla's driving distance, and never an ETA.

Four reasons: (i) zero network on the paint path, which the locked-phone rule effectively mandates; (ii) it works offline and while locked, which a routing call does not; (iii) routing 12 POIs on every map pan is neither cheap nor reliable on a Rwandan mobile link; (iv) it sits furthest from the `carplay-maps` boundary — Apple blesses *"distance/bearing text the app computes and puts in `summary` or `detailSubtitle`"* `[hard]`, while ETA is one of the four things that tips an app over `[hard]`.

The phone keeps ADR-0004's Valhalla preview with route line and ETA. **The car and the phone therefore show different numbers for the same station.** Flagged in §10.

### 8.6 Origin selection — including the reviewer

`stationsNear(origin, limit)` takes an **arbitrary origin**, never a hardcoded device location `[settled]`. On CarPlay:

| Condition | Origin |
|---|---|
| Nearby tab, map has been panned | visible region centre (delegate-driven) |
| Device location authorised and within 200 km of any station | device location |
| Device location denied, unavailable, or > 200 km from every station | **Kigali centroid** |

The last row does three jobs at once. It handles a driver who never granted location — which matters because **location permission cannot be granted from CarPlay**, and guideline 2 forbids telling them to grant it on the phone; the map simply opens on Rwanda and works. It handles a driver in Kampala. And it handles **Apple's reviewer in Cupertino**, who would otherwise see an empty screen: Apple states no mock-location requirement for CarPlay (that is Google's rule), so the fallback is the only thing standing between the submission and a blank map. No mock-GPS dependency, no debug flag, no special build.

### 8.7 Refresh strategy

| Trigger | Action | Blocking? |
|---|---|---|
| Scene connect | read cache, compose, paint | **never blocks on network** |
| Scene connect, then ≤ every 5 min while connected | `changedSince(cursor)` delta sync in background | no — failure is silent |
| App foreground on phone | same delta sync | no |
| Every render | re-run ADR-0008 decay over cached `capturedAt` | pure function, no I/O |
| POI region change | re-rank ≤12 to region centre, `setPointsOfInterest` | no I/O |
| Periodic POI refresh | ≤ once / 60 s `[inferred]` | no I/O |
| Any other periodic update | ≤ once / 10 s `[inferred]` | no I/O |
| Watch arm/disarm | optimistic write to Store B, POST queued and retried | UI updates immediately |

Cold sync budget under 1 MB (ADR-0007). Photos are never fetched for a car surface.

**Optimistic arm, silent reconciliation [inferred]:** tapping `Notify me when a bay frees up` writes the armed row to Store B and re-renders at once; the POST retries in the background. If the server ultimately rejects (e.g. a third watch was armed on the phone concurrently), the armed row disappears at the next render with no alert. Nagging a driver about a failed background write is worse than the inconsistency.

---

## 9. Constraint → satisfaction

### 9.1 Entitlement and templates

| Constraint | How this design satisfies it |
|---|---|
| Entitlement `com.apple.developer.carplay-charging`, iOS 14+ `[hard]` | Declared alone. No `carplay-maps`, no fueling combination. |
| Forbidden template = **runtime exception** `[hard]` | `CPMapTemplate`, `CPContactTemplate`, `CPNowPlayingTemplate` are never referenced in the binary. A build-time source check enforces it. |
| Charging apps get no `CPWindow`; no drawing surface `[hard]` | Nothing is drawn. Every pixel is Apple's chrome; EV Guide supplies strings, images, IDs. The visual identity is absent by design and the reference designs are not forced (ticket 18's own instruction). |
| Entitlement is account-level, all-or-nothing `[hard]` | No staged rollout or kill switch is assumed anywhere. |
| Stack depth 5 incl. root `[hard]` | §3: max 5 under the conservative reading, enforced by the depth ≤ 3 invariant on `Other free bays` plus a push wrapper. |
| Tab bar must be root; each tab its own hierarchy `[hard]` | `setRootTemplate` only; never pushed, never presented, never nested. |
| Modals presented, not pushed `[hard]` | Both alerts use `presentTemplate`. |

### 9.2 Point of interest

| Constraint | How this design satisfies it |
|---|---|
| Max 12 POIs `[hard]` | `min(12, ranked)`; the composer cannot emit more. |
| Delegate mandatory; re-rank on every region change `[hard]` | Implemented; `setPointsOfInterest(_:selectedIndex:)` on `didChangeMapRegion`, guarded against loops by a region-delta threshold. |
| *"limited to those most relevant or nearby"* `[hard]` | Ranked to the visible region centre, distance-first. |
| **Do not expose non-EV-charger locations** `[hard]` | The POI array is built from `Station` rows only. No petrol, no parking, no landmarks — and no fueling entitlement is held, so the expansion is foreclosed by design. |
| Exactly two card buttons `[hard]` | `Directions` + `Details`. The third action lives one level deeper on `CPInformationTemplate`. |
| Six plain-`String` slots, no variants `[hard]` | §2.2 fills all six from the settled picker-triple and card-triple projections, each authored to a §2.1 budget. |
| Pin size undocumented `[runtime]` | Pins drawn at runtime from `pinImageSize` / `selectedPinImageSize` and `carTraitCollection.displayScale`; `Owner.icon` is a vector for exactly this reason. |
| No animated images `[hard]` | No animation anywhere on the surface. |

### 9.3 List, grid, tab, alert, search

| Constraint | How this design satisfies it |
|---|---|
| Cars may cut lists to 12; `maximumItemCount` undocumented `[hard/runtime]` | `min(maximumItemCount ?? 12, 12)`; rows independent and ranked so truncation costs only the tail. |
| `CPListItem` = two text slots `[hard]` | `text` = `nameShort`; `detailText` = the whole two-line projection. Nothing else is attempted. |
| `userInfo` is the sanctioned ID carrier `[hard]` | Opaque `Station.id` on every row, every search result. |
| List image size `[runtime]` | Owner glyph rendered to `CPListItem.maximumImageSize`. |
| `emptyView*Variants` — the one variant slot on a list `[hard]` | Three variants each, §2.3. |
| Grid ≤ 8, silent truncation `[hard]` | Five buttons, capped at eight by construction. |
| `CPGridButton.titleVariants` `[hard]` | Two or three variants per button, longest first. |
| Grid icon 40×40 pt / 80 / 120 `[hard]` | Exact sizes, light + dark. |
| Tabs ≤ 5, but query `maximumTabCount` `[hard/runtime]` | Three tabs; queried, with a documented degradation to 2 and 1. |
| Tab bar contains Grid/Information/List/POI only `[hard]` | POI, List, Grid. |
| Tab icon 24×24 pt / 48 / 96 `[hard]` | SF Symbols at the exact sizes; `bolt.fill`-era symbols only, for the iOS 14 floor. |
| `CPAlertTemplate.maximumActionCount` undocumented `[runtime]` | Both alerts authored at two actions, collapsing to one when the car reports a ceiling of one. |
| `titleVariants` on alerts `[hard]` | Three variants each. |
| Search is iOS 27+ for charging `[hard]` | Conditional; absent below iOS 27, and the design's primary path never touches it. |
| Search *"never the primary way"* `[hard]` | §7.2 — four independent reasons; it is a trailing row, not a tab. |
| `limitedUserInterfaces` = `.keyboard`, `.lists` `[hard]` | Keyboard gates the search row's existence; list reduction is handled by ranking. |
| `contentStyle` light/dark `[hard]` | All assets in both; runtime-drawn pins redrawn on change. |
| `CPInformationTemplate` item cap **unknown, unqueryable** `[UNKNOWN]` | ≤ 6 items, ordered by decision value; `Distance` is always last and is the item that falls off when the armed row appears. |
| Information ≤ 3 actions `[hard]` | Never more than three; usually one or two. |
| `CPInformationItem` = title + detail only `[hard]` | Every item is a label/value pair. No image, accessory, or per-item action is attempted. |

### 9.4 Review guidelines

| Guideline | How this design satisfies it |
|---|---|
| 1 — *designed primarily to provide the specified feature* `[hard]` | Launch state is a populated charger map at zero taps; the three tabs are charger discovery, charger listing, and the driver's plug. Nothing else is on the surface. |
| 2 — *never instruct people to pick up their iPhone* `[hard]` | Audited: **no string on any car screen mentions the phone, sign-in, installation, or permissions.** The two alerts state conditions without instruction; account-gated affordances are silently absent (§6). |
| 3 — *all flows must be possible without interacting with iPhone* `[hard]` | Every CarPlay flow — browse, filter by plug, read availability and rate, get directions, arm and disarm a watch — completes on the car screen. Reporting is not a CarPlay flow (§4.5). **One residual risk: §10.10.** |
| 4 — *meaningful to use while driving; no unrelated features* `[hard]` | No settings, no account screen, no about, no help, no photos, no history, no statistics. |
| 5 — no gaming or social networking `[hard]` | N/A. |
| 6 — never show message/text/email content `[hard]` | N/A — no such data exists in the model. |
| 7 — *templates for their intended purpose* `[hard]` | POI template = charger locations; Information template = charging-location detail, Apple's own named example; List = ranked chargers; Grid = a menu of ≤8 choices; Alert = a condition. `CPActionSheetTemplate` is not declared at all. |
| EV 1 — *can't just be a list of EV chargers* `[hard]` | Three functions above the directory: per-bay availability with source and freshness, re-ranked to the viewport on every pan; the directions hand-off; bay-watch arm/disarm resolved by a CarPlay notification. Plus `Other free bays` as a contextual decision aid. **None is documented as sufficient — §10.12.** |
| EV 2 — *no non-charger locations on the map* `[hard]` | §9.2. |

### 9.5 Notifications, hand-off, locked phone

| Constraint | How this design satisfies it |
|---|---|
| Notifications permitted for EV charging `[hard]` | One category, one event type. |
| Requires `.carPlay` option **and** `allowInCarPlay` `[hard]` | Both declared. |
| Users can disable per app; must degrade `[hard]` | Nothing depends on car delivery; the watch still fires on the phone and the armed row clears on completion either way. |
| *"used sparingly … important tasks required while driving"* `[hard]` | One-shot, max 3 armed, 2 h expiry, fires only on a report-driven transition into `Free`. No repeat path exists, so no digest or throttle machinery is needed. |
| *"not read aloud"* `[hard]` | Written to be read: station front-loaded in the title, one clause in the body. |
| Hand-off via the **scene's** `open(_:options:completionHandler:)` `[hard]` | `CPTemplateApplicationScene.open`, never `UIApplication.shared.open`. |
| Receiving app must be a CarPlay app `[hard]` | Google Maps is a CarPlay navigation app. |
| Google Maps scheme declared `[hard]` | `comgooglemaps` in `LSApplicationQueriesSchemes`; URL `comgooglemaps://?daddr=-1.9577,30.1127&directionsmode=driving` — coordinates, never a place name (`[settled]`, ADR-0004). |
| Apple Maps cannot navigate in Rwanda `[settled]` | Not used as a fallback. On failure: the Google Maps universal link, then alert A2. |
| No route, ETA, maneuver, or polyline `[hard]` | No route entity exists in the model; distance is great-circle; **the word "ETA" and any "min away" string are banned from the CarPlay surface by lint.** |
| Locked-phone file classes `[hard]` | Stores A and B at `…CompleteUntilFirstUserAuthentication`; nothing at Class A or B is on any car path. |
| Locked-phone keychain classes `[hard]` | `kSecAttrAccessibleAfterFirstUnlock` for the one credential, used only for arm/disarm. |
| Refresh floors 60 s / 10 s `[inferred]` | Adopted voluntarily; region-change refresh is event-driven and uncapped, as Apple's text allows. |

---

## 10. Where the constraints force an ugly compromise

1. **The POI card has exactly two buttons, so bay-watch costs an extra tap.** `Directions` and `Details` are both indispensable from the map, which pushes the watch — one of the three functions clearing Apple's "not just a list" bar — one level deeper than the action it competes with. The most review-relevant affordance on the surface is the one furthest from the driver's finger.

2. **Availability is invisible on the map.** Pins carry Owner identity only, because a coloured pin is a state claim with nowhere to put its age, and because a mostly-grey map is exactly the failure ADR-0002 forbids. The cost is real: a driver scanning the map cannot see which pin has a free bay without selecting it. Mitigated only by the picker strip being permanently visible.

3. **Source is dropped from the list row.** Two slots cannot carry distance, count, age *and* source. The row keeps state + age (ADR-0002's strict honesty rule); source appears everywhere with three or more slots. This is a narrow relaxation of ticket 11's "source always shown" and I am flagging it rather than quietly taking it — no conflicting claim is ever *resolved* on a row, so the rule's purpose survives, but the letter does not. **Route to 11/19.**

4. **The car and the phone disagree about distance.** CarPlay shows great-circle; the phone shows Valhalla driving distance and an ETA. In Rwanda's terrain the two can diverge sharply. No label can explain it — there is no slot for one — so the driver meets an unexplained discrepancy the moment they tap `Directions`.

5. **There is no Saved tab.** `SavedStation` is user-scoped, and the settled rule is that the locked-readable car cache carries only non-sensitive directory and availability data. "My usual chargers" is the single most obviously-missing feature on this surface, and it is missing for a privacy reason a driver will never see. *(The narrow path, if the founder wants it later: a fourth store holding station IDs only, no user identifier, at the same protection class — the same carve-out §8.3 already makes for armed watches. It is a decision, not an engineering problem.)*

6. **Reporting is not on the car surface at all** (§4.5). A driver parked at a broken charger, phone locked in a pocket, has no way to say so from the screen in front of them. The alternative was fabricating a connector-level claim, which is worse — but this is a real loss and it removes one of the four candidate answers to guideline 1.

7. **`Notify me when a bay frees up` is a 29-character button title with no variants.** `CPTextButton` takes a plain `String` `[hard]`. Ticket 30 specifies this label, so it is used — but it is the single riskiest string on the surface. **Ticket 27 must measure it on hardware**; if it truncates, the fallback is `Notify when free`.

8. **Rate cannot appear on a row.** In a market where a driver may well choose on price, the price is always one tap away and never in the scan.

9. **Search is unusable for most of the addressable base.** iOS 27+ only, and frequently disabled while driving even then. Proximity ranking carries the entire access path. Fine for tens of stations; it would not survive a directory ten times the size.

10. **Whether the Google Maps hand-off lands on the CarPlay screen is unverified by either vendor** `[UNKNOWN — ticket 27]`. If it lands on the phone instead, the primary action completes on a device the driver is not supposed to touch, which brushes guideline 3 (*"All CarPlay flows must be possible without interacting with iPhone"*). The design does not assume it works: the CarPlay screen does not change on tap (no "opening…" state — animation is forbidden anyway), so nothing breaks visually either way. **This is on the critical path and Apple Maps is not a fallback, because it cannot route in Rwanda at all.**

11. **The plug lens relabels but does not filter or reorder.** A GB/T-only driver still sees Type 2-only sites at the top of their list, correctly labelled `no Type 2` but occupying a slot. Filtering would have hidden complete listings and could empty the map; the settled ranking would have had to change. The compromise is that "free for me" is answered by reading, not by the list's shape.

12. **The largest risk is not a layout problem.** Two of the three pillars — availability and bay-watch — are invisible when the data is thin, which in year one is most of the time. A reviewer with a US origin sees the Kigali fallback map (§8.6), tens of stations, and mostly `No recent report`. **That is Apple's own example of what is not sufficient.** Ticket 20's submission must therefore demo against seeded data and walk the reviewer through the availability layer and a live watch; ticket 23's fallback ladder is the answer if it still fails. No layout choice available here changes that.

13. **Choosing a plug does not return the driver to the map** (§7.5), because programmatic tab selection is not assumed. One extra tap on a rare action; noted rather than solved.

---

## 11. Everything I inferred

Do not quote any of these to Apple as a rule.

1. **The tab bar counts as depth level 1.** The conservative reading. The design is proved under it and is safe under the permissive reading too.
2. **The 60 s / 10 s refresh floors**, adopted from Apple's driving-task section, which is not literally binding on a charging app. Carried forward from the research author's own flag.
3. **`NSFileProtectionCompleteUntilFirstUserAuthentication` + `kSecAttrAccessibleAfterFirstUnlock`.** Apple documents what is unreadable while locked, never what to use.
4. **≤ 6 Information items, ordered by decision value**, as the hedge against an undocumented and unqueryable cap.
5. **The §2.1 character budgets.** Entirely mine. CarPlay publishes no character counts anywhere, and the affected slots have no variants — authoring short is the only lever, so a budget is the only enforceable form the lever can take.
6. **Silent omission of account-gated affordances** rather than explaining them. The derived safe reading of guideline 2.
7. **The car-visible account facet** (`isSignedIn`, ≤3 armed watches, mirrored vehicle plugs) as a second store. Forced by ticket 30's armed-state row; an addition to what ticket 19 currently specifies.
8. **Stripping `reporterId` and `capturedLocation` from the cached Report projection.** Not stated anywhere; derived from the locked-phone rule plus constraint 9.
9. **The origin fallback to the Kigali centroid beyond 200 km**, including as the reviewer path. Apple states no mock-location requirement for CarPlay, so this fills a documented void.
10. **The row-set stability rule** (frozen while on top, except on user action or 500 m of movement). A human-factors property, not a platform rule.
11. **Great-circle distance on the car, Valhalla only on the phone.** A deliberate divergence from ADR-0004's preview, justified by latency, offline, locked-phone and boundary distance.
12. **No offline indicator on CarPlay**, diverging from ADR-0007's phone indicator.
13. **`Other free bays`** as a third detail action. Additive to ticket 23's settled three; cuttable with no structural consequence.
14. **The `f`/`u`/`n` string ladder and the never-assert-an-unproven-negative rule.** Derived from ADR-0002's honesty rule, not stated by it.
15. **Optimistic arm with silent reconciliation.**
16. **Alert A2 exists at all** — a small extension of ADR-0004's "no custom fallback UI", justified because guideline 2 explicitly permits stating a condition and a car button that silently does nothing is worse.

**Needs verification on hardware or in the SDK, before this design is built:**

- Whether `comgooglemaps://` launched via the scene's `open(_:options:completionHandler:)` lands on the CarPlay screen. **Critical path — ticket 27.**
- Whether `CPInformationTemplate.items` / `.actions` are mutable at the target OS. If not, the arm/disarm re-render is a pop-then-push replacement — depth-neutral either way, so the design holds.
- The exact `CPInterfaceController` property exposing the live template stack, for the push wrapper's assertion.
- Whether `CPTabBarTemplate` permits programmatic tab selection at the iOS floor (design assumes not).
- Rendered width of `Notify me when a bay frees up` on the smallest available head unit.
- Actual runtime values of `maximumItemCount`, `maximumSectionCount`, `maximumTabCount`, `maximumActionCount`, `pinImageSize`, `selectedPinImageSize`, `maximumImageSize` across test vehicles.
- Whether CarPlay activates at all on Rwandan-region devices `[UNKNOWN — ticket 22]`. Changes who sees these screens, not what they say.

---

## 12. Routed back to ticket 19 before the schema locks

Ticket 18 requires this. Nine items:

1. **Two new projections.** `docs/domain-model.md` names four (one-line, two-line, picker-triple, card-triple). This design needs two more, and they must live in `packages/domain` or three call sites will improvise them: **`detail-pairs`** (the `CPInformationItem` label/value list, ≤6, ordered by decision value, lens-aware) and **`push-line`** (notification title + body).

2. **`bayState(bay, now)` must be a named function in `packages/domain`.** ADR-0008 defines `effective(connector, now)` and mentions propagation; it does not name the bay-level roll-up, and **the Bay is the display unit on every car surface**. Without it the collapse rule lives in the CarPlay layer, which is exactly the improvisation constraint 5 exists to prevent.

3. **Per-type projections** `baysOffering(T)` and `freeBaysOfType(T)`, with the documented caveat that a multi-gun bay is counted in each type it offers, so per-type denominators may exceed the bay count and the aggregate is authoritative.

4. **The aggregate string ladder** (§2.1) belongs in the domain package as a pure function of `(f, u, n, lens)`, including the never-assert-an-unproven-negative rule. Not in the CarPlay layer.

5. **The cached `Report` projection must exclude `reporterId` and `capturedLocation`.** The domain `Report` carries both; the car cache must carry neither. This should be an explicit named projection, not a filter applied at the cache boundary by convention.

6. **A new store: the car-visible account facet** — `isSignedIn`, ≤3 `armedWatches{stationId, connectorTypes[], expiresAt}`, mirrored `vehiclePlugs[]`. Ticket 19 currently says the car reads *only* non-sensitive directory + availability data; ticket 30's armed-state row cannot be rendered under that rule. Either 19 admits this facet explicitly with its exclusion list (push token, email, name, avatar, saved stations, report history, credentials) or ticket 30's car face has to change.

7. **`Owner.icon` must be a vector asset.** CarPlay pin sizes are runtime values, so a fixed raster cannot serve them. Currently the model says "bundled/materialised locally", which a PNG satisfies and this surface does not.

8. **Authored length constraints on the name fields**, enforced in the admin: `nameShort` ≤ 18, `name` ≤ 28. The model already calls these authored; it does not bound them, and there is no truncation control on the slots that consume them.

9. **A note on constraint 13.** "Directions need only a coordinate + display name" is right, and this design adds the negative form: **ETA, duration and any "minutes away" string are forbidden on the CarPlay surface** — not merely unmodelled, but a `carplay-maps` trigger if rendered. Worth stating in the model so a later effort with a Valhalla ETA in hand does not reach for the car row.