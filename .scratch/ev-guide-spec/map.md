# EV Guide — spec map

Label: `wayfinder:map`

## Destination

A **locked `SPEC.md` plus ADR set for EV Guide** — enough that an
implementation effort can build the driver app, the operator app, and the admin
dashboard without relitigating any decision. The map is done when nothing is
left to decide.

Depth is deliberately uneven: full spec for the driver app; for the operator
app and admin dashboard, only what the shared data model forces now — the
owner/operator hierarchy, what stats each tier sees, and who is entitled to
write availability and rates.

## Notes

**Domain.** A directory of EV charging stations in Rwanda. Drivers find a
station, see its rate, connector types and bay count, learn whether a bay is
free, and get directions. Stations are entered manually by the admin — there is
no open dataset to import (Electromaps lists zero stations for Rwanda). The
admin creates station managers beneath it in an owner → operator hierarchy.

**Skills every session should consult:** `/grilling` and `/domain-modeling` by
default; `/research` for the AFK tickets; `/prototype` for the UI tickets.

**Standing preferences for this effort:**

- **Reference designs are implemented 1:1**, no deliberate deviations. The four
  screenshots in `refs/` are the UI source of truth; see
  `refs/design-observations.md`. Raise impossibilities *before* building
  alternatives. **Exactly two deviations exist, both founder-ratified
  2026-08-14** — the `Google` wordmark slot carries the OSM attribution, and the
  location puck is redrawn off Google's blue. Two further calls chose fidelity
  *over* readability (the 1.21:1 hero badge, the dark-only operator app). All
  four in [ADR-0009](../../docs/adr/0009-reference-fidelity-deviations-and-costs.md);
  the typeface ships as an acceptance band, not a name
  ([ADR-0010](../../docs/adr/0010-typeface-acceptance-band.md)).
- **EV Guide is free, with no monetisation anywhere** — no driver payments, no
  operator subscription, no paid listings. No billing infrastructure, no plan
  tiers, anywhere in the architecture.
- Expo, targeting the latest iOS and Android releases, on the New Architecture.
- Plan, don't do. This map produces decisions; the build is a separate effort.

**Primary sources found during research.** **RURA Regulation
No 011/ENERGY/RURA/2026**, in force 29 June 2026, is Rwanda's first EV charging
regulation and postdates almost all press coverage — check it before assuming
anything about connectors, tariffs, licensing or registries. Apple's **CarPlay
Developer Guide (June 2026 PDF)**, not the HTML docs, is the only place the
category→template matrix and review criteria are published.

**Market context — corrected by research, 2026-08-13.** Two figures written at
charting were wrong and are struck here so they do not harden into the spec:

- ~~EVP Charger shipped its own app in July 2026~~ — **EVP has no app.** The
  New Times piece (8 June 2026) is *future tense*; EVP's own download buttons
  are `href="#"` and there is no listing on either store. The only shipped
  competitor is **Kabisa Charge** — 5+ downloads, no iOS build, charging flows
  it labels "(simulated)". The competitive pressure assumed at charting does
  not currently exist.
- ~~~200 public stations in Kigali by Feb 2026~~ — that is a **government plan
  target**, not a count. Primary sources give **17–19 sites** in mid-2024, and
  Kabisa's live feed returns **77 charge points** nationally (verified
  2026-08-13). Charge points are not stations; a site holds several.

What holds: the market is genuinely multi-operator, and **larger than three
operators** — Kabisa, EVP, **Numa** (15 charge points including four 240 kW
sites, second-largest, zero web presence), Connex, PREV, MUJEBA, plus
Volkswagen Mobility Solutions Rwanda with Siemens.

**The fleet fact that most challenges this product's framing.** MININFRA/EU
EVCI Master Plan Table 11, sourced to RRA: March 2024 Rwanda had **363
battery-electric cars** against **4,823 electric motorcycles** — roughly
**13:1**. The "7,000+ EVs" headlines count hybrids and motorcycles together.
EV Guide is currently specced for the smaller side of that split; ticket 08
carries the escalation.

**Settled while charting** (not tickets, recorded here so they aren't reopened):

- Destination is a spec, not a build.
- All three surfaces are in scope, at uneven depth (above).
- CarPlay and Android Auto are **in the spec, out of the first build**. The
  entitlement applications start early because approval latency is the long
  pole and is not under our control.
- Where "native components" and the reference designs conflict, **the designs
  win**. Custom React Native UI; `@expo/ui` only where the OS widget genuinely
  is the right answer.
- No payment anywhere. Rates are displayed only.

## Decisions so far

<!-- one line per closed ticket: gist + link. Zoom the link for detail. -->

- [02 — Which connector standards actually matter in Rwanda?](issues/02-rwanda-connectors-and-fleet.md) — OCPI 2.3.0 spellings, open enum: `IEC_62196_T2`, `IEC_62196_T2_COMBO`, `GBT_AC`, `GBT_DC` in tier 1. **CHAdeMO is not a Rwandan standard** — the LHD-only import rule closes the used-JDM channel, so the regional Nissan Leaf intuition does not transfer. A regulation now governs this: **RURA No 011/ENERGY/RURA/2026**, in force 29 June 2026.
- [03 — Who operates Rwanda's stations, and can any be read?](issues/03-operator-landscape-and-data-access.md) — **READ, narrowly.** Kabisa serves an unauthenticated public GeoJSON feed carrying **77 Rwandan charge points across 18 brands including EVP's**, with live per-gun availability for 10 and `pricePerKwh` for 12 (600 RWF/kWh). Verified independently. **67 of 77 report `{0,0}` = unknown, not full**, and availability disagrees with `onlineStatus`. RURA keeps **no licence register and requires no tariff filing** — a confirmed absence. Whether to build on that feed is ticket 26.
- [06 — Which map provider?](issues/06-map-provider.md) — **MapLibre + self-hosted OSM vector tiles**, near-black custom style, deep-link out. Google's mobile loads are free and unlimited but its ToS **forbids tile caching**, and offline is the discriminator; all of Rwanda is 76 MB. ~~Conditional on 16~~ — 16 made offline first-class, so **MapLibre stands unconditionally**; the wordmark question routed to 17.
- [22 — Are the car platforms usable in Rwanda?](issues/22-car-platform-availability-rwanda.md) — **The vendors differ.** Apple treats country support as a prerequisite; Google's list is explicitly *marketing rights* and neither Google source says the software refuses to run. **Hardware is not the obstacle** — Toyota Rwanda ships CarPlay below the power-windows line. Undecidable from documentation; needs ticket 27's device test.
- [26 — Do we build on Kabisa's unofficial feed?](issues/26-kabisa-feed-dependence.md) — **No.** Founder rule: no external runtime dependency, the studio owns the whole pipeline. Costs 77 geocoded points and the only live availability in the country. Hardens 06 into MapLibre, leans 14 toward BWEZE. Security disclosure to Kabisa **drafted, not sent** — pure disclosure, no ask.
- [07 — Neutral aggregator, or dependent on operators?](issues/07-positioning-aggregator-or-dependent.md) — **Fully self-sufficient.** Two owned channels: the operator app and driver reports. With zero operator adoption EV Guide is still a complete directory — station data is admin-owned and availability is additive, not a precondition. **EV Guide publishes no per-operator uptime history**: RURA mandates 97% uptime with fines, and becoming a de facto compliance monitor would starve the operator channel outright.
- [09 — How does EV Guide know a bay is free?](issues/09-availability-model.md) — **Per connector; four states; `Unknown` by default.** `Free`/`Occupied`/`OutOfService`/`Unknown`, freshness a separate axis, decay a function of source *and* state (driver 2h, operator 6h, `OutOfService` 30d). Confidence is source-plus-age, not a score. Offline overrides recency. Reports are proximity-gated, no reputation system. [ADR-0002](../../docs/adr/0002-availability-model.md). Whether v1 *promises* it is ticket 28.
- [10 — What is a rate, who writes it?](issues/10-rate-model.md) — **Per connector**, RWF per kWh, optional session fee. Reuses ADR-0002's freshness shape with a 90-day decay. **Owners and Admin write it; Operators may only flag it** — operational versus commercial. Unknown is stated, not hidden.
- [11 — Owner, operator, station](issues/11-role-hierarchy-and-stats.md) — Owner→Stations one-to-many; **role is a membership edge, not a user attribute**; **owners create their own operators**. Conflicts: **most recent wins regardless of source**, source always shown. Stats are **four metrics** — views, direction taps, reports received, own uptime — because EV Guide never sees a charging session, so there is no kWh, revenue or session count to report.
- [12 — Do drivers need accounts?](issues/12-driver-identity.md) — **Read anonymously, act with an account.** Directions, saving, reporting and profile sync are gated; the whole read surface is not. Google + Apple + email magic link, **no SMS**. [ADR-0003](../../docs/adr/0003-driver-identity-and-gating.md). Knock-on: the car surfaces now need a signed-in user for their primary action — a 5.1.1(v) review risk routed to 23.
- [08 — Cars only, or e-motos and battery swap too?](issues/08-vehicle-classes.md) — **Cars only**, and the escalation is closed: the destination is unchanged. The 13:1 moto ratio is a March 2024 figure whose car side has since quintupled; the only live availability source is car-only; and closed swap subscriptions give a directory no choice to aggregate. `Station` carries a nullable vehicle-class **tag** that nothing branches on. [ADR-0001](../../docs/adr/0001-cars-only-swap-out-of-scope.md).
- [13 — In-app turn-by-turn, or route preview then hand off?](issues/13-directions.md) — **Preview in-app, hand off the drive to Google Maps** (the only viable target: Apple Maps has no directions in Rwanda). Preview is studio-owned: **self-hosted Valhalla** on the 06 OSM extract — route line, driving distance, ETA; founder direction: mature open-source engines over building or omitting. Deep-link by `lat,lng`, no chooser; inline auth sheet auto-resumes the hand-off; phone hand-off is the car-screen guarantee, display-launch verification routed to 27. [ADR-0004](../../docs/adr/0004-directions-preview-and-handoff.md). Journey planning graduated to 29.
- [17 — Screen inventory and design system from the references](issues/17-screen-inventory-and-design-system.md) — **Measured, not estimated** ([design system](design/10-design-system-v2.md) · [15 driver screens](design/11-driver-screens-v2.md) · [operator + admin](design/12-operator-admin-screens-v2.md), two adversarial rounds). The record was wrong in ways that would each have shipped visibly: **the CTA is not a pill** (r≈13 on a 137 px button, and not full-width), **there is no grey text** (ExtraLight anti-aliasing), the `03` sheet is a **floating card**, the handle is 180 px, the one link is underlined, and the **basemap palette across 85% of the front door was never measured** — under MapLibre that style is ours to author. **The typeface is NOT identified**: old-style figures rule out every geometric candidate, Raleway fell 65%→15% on re-derived metrics, so what ships is an acceptance band. Pin availability solved 1:1 by re-tenanting the reference's own status dot; crosshair = content datum; `Payment & payouts` → `Offline & map data`. 50+ impossibilities raised, incl. **the reference contains no form control of any kind**.
- [01 — Land the reference designs on disk](issues/01-land-reference-designs.md) — `refs/01.png`…`04.png` in the specified order, iPhone 16 Pro @3x. **Measuring the pixels corrected three of five palette rows** the observation record had eyeballed: background is `#121212` not black, card surface `#393939` not `#1A1A1A`, accent exactly `#C7FC2F`. The crosshair rule is confirmed present on both map screens and still unexplained (a 17 decision, not to be improvised), and the map's **"Google" wordmark is confirmed from the pixels** — the 1:1 impossibility against MapLibre is real. **Unblocks 17.**
- [18 — What does EV Guide look like on a car screen?](issues/18-car-template-design.md) — **Both surfaces designed and adversarially reviewed three times** (designs + verdicts in [design/](design/)). No forbidden template, no breached cap, no sign-in wall, `Directions` unconditional. The reviews killed four fatals — a row count that would have let the host **close the app mid-drive**, a grammar that said "all bays busy" over bays nobody reported, a lens that called a bay free while holding a report that the plug was broken, and a hand-off claiming a car-display launch **no API can observe**. Produced **[docs/availability-display.md](../../docs/availability-display.md)**: the derivation + display grammar as ONE spec (the two designs had specified different functions), plus amendments to ADR-0004/0007/**0008 — deriving on read only works if something re-renders at the decay boundary**.
- [32 — Run the corrections owed back into files 11 and 12](issues/32-corrections-owed-to-the-screen-records.md) — **Done, and it found more than it was sent for.** The sixty stale values are re-derived, but **two of the four places the sweep flagged file 10 itself turned out to be file 10's**: the pin is **122 × 147**, not 120 (`120` is the width at which px/3 lands on a round `40.0 pt` — the px was rounded to flatter the pt), and the chip's padding is **86/30**, not 88/29, which reverses a sweep row and leaves file 11 the correct one. Two flags escalated: **§6's radius method is geometrically false and under-reads every radius in the system** (ticket 33 — the button is 16.4, not 13; the card 19.5, not 14; six rows never re-fitted, so *images are rounder than containers* is currently unsupported), and **the extent convention cannot be declared without breaking locked SPEC.md values** (ticket 34 — file 10 published the CTA AA-inclusive and the card core). Radii are **frozen product-wide** rather than half-corrected. Item 5 was under-specified: `availability-display.md` §2.2b was **not** a superset, so collapsing the four forbidden-string homes in the obvious order would have dropped four live bans — the union merged first. `busy` survives the Regime-3 card subtitle after a one-character miscount, and file 12's *"does not fit"* was a **Bold** advance applied to a **Medium** label. Also raised: [35](issues/35-price-string-two-weights.md), the price string is two weights.
- [33 — Every radius in the design system is under-read](issues/33-radius-system-under-read.md) — **The six unfitted rows are fitted, and the harness was re-validated against all four of ticket 32's knowns first** (19.50 / 16.50 / 16.60 / 15.60). Two results change what `packages/ui` *types*, not just which number: the **category chip, hero badge and drag handle are pills** — the badge's free fit lands *above* its own geometric cap — where §6 had said they "measurably fall short" and forbidden `borderRadius: 9999`; and both CTAs remain **one** 16.5 token. The signature finding **holds** (images 10.6 pt against containers 4.5–6.5, narrowed 2.1× → 1.6×), but **two riders on it were false and are struck**: buttons are not the least-rounded thing (the feature chip is, and was in the published table too), and the floating card is not in the buttons' bracket. The **drag handle never carried the bias** — 6.5 came from the "fully rounded" constraint, not the false arc. The **hero image is confirmed [?] for a reason §7.7 never recorded**: its backdrop is a 20 → 32 gradient, not `#121212`, and a fit assuming a dark ground returns a confident, entirely artifactual 45–48.
- [34 — Declare the extent convention](issues/34-extent-convention.md) — **Integrated**, the truthful reading and the most expensive: four locked `SPEC.md` values move and **tokens carry the fraction** (`size.ctaHeight` = 137.25 px = 45.75 pt). No rounding rule, deliberately — an unwritten tiebreak is what produced commit `6a5a922`, which "corrected" the CTA height *away* from the reference by matching a token. `SPEC.md` **amended** rather than left divergent (the founder took the second question the same way). Seven values converted; the rest of the size line was measured before the rule existed and is swept under 36.
- [35 — The price string is two weights](issues/35-price-string-two-weights.md) — **Ship both, as measured**: amount and currency Bold in every slot, the `/day` tail **Regular** on `04`'s sticky bar and **ExtraLight** on the `03` card. Same resolution as [RAISE-4] and [RAISE-11] — 1:1 means shipping the reference's own inconsistency. **No projection change is owed**: the ticket assumed `rateShort` would have to carry an amount/tail split, but amendment 8 already has it returning *numbers*, so the slot composes the string and the boundary was never lost. What was owed is a composition rule, and **the tail's weight is a property of the slot, not of the value**.
- [36 — Sweep the remaining component sizes to the declared convention](issues/36-size-line-convention-sweep.md) — **Ticket 34's rule confirmed in both directions**: every hard-edged element read identically under all three conventions and did not move (`accentRing` 3.0, puck ring 4.0, halo 82.0, profile avatar 315.9), and every element that moved moved **up** by 0.4–1.5 px, which is what a pixels-touched count does against an integrated one. Two findings are not conversions. **`SPEC.md`'s `quickAction 150` was one token for three buttons** that measure 154.8 / 150.3 / 149.9 — file 10 §7.2 had them right as "154 / 149 / 149" and explicitly refused to harmonise them; the collapse happened on the way into `SPEC.md`, and is reversed. **The thumbnail is not 300 and cannot be pinned** — three estimators spread 4 px and all land below it, so it ships as a band (≈297.5 ±1.5); 300 was a pixels-touched bbox, the same over-read §0.1 documents for strokes. Also corrected in passing: **the puck's heading cone is DETACHED, not "projecting from the disc"** — a 6–7 px gap at every row on both map screens — and its "⌀ ≈82 px envelope" was the *halo's* diameter; it measures **16 × 19 px**, has no token, and is a **fourth** surface inside ADR-0009's redraw scope. Measurement note: the locate button's arrow is **filled black**, so a coverage-from-background reading scores the glyph as outside and under-reads the diameter by ~20 px.
- [30 — Bay-watch notifications: scope and mechanics](issues/30-bay-watch-notifications.md) — `watch(station, connectorTypes[])`: armed where the driver thinks, evaluated on Connectors. **Only a report-driven transition into `Free` fires it — decay never notifies**; one-shot, 2h expiry, max 3 armed, so the design *is* the spam control (no rate limiter, no digest). Transport **raw APNs + FCM** from BWEZE (Expo's relay would violate 26); tokens never enter the car cache. Car affordance for signed-in users only. Ships with the car package.
- [23 — What is EV Guide's "meaningful functionality relevant to driving"?](issues/23-driving-functionality-bar.md) — **Three functions clear the bar**: ranked live availability + freshness, one-tap hand-off, and **bay-watch notifications** (fog → ticket 30; car-effort package, not v1 phone launch). **Directions ungated everywhere** — ADR-0003 amended, its own pre-planned relaxation; the auth sheet moves to save/report. One function set for both platforms, framing differs in the 20 submissions. Fallback ladder: resubmit with bay-watch live → ship phone-only and retry; **session control is never built to satisfy review**.
- [28 — Does v1 promise availability at all?](issues/28-v1-availability-promise.md) — **Ships the layer, claims the directory.** Availability is "live status *when reported*" — a bonus, never a promise; "real-time" never appears anywhere. No adoption gate (Unknown is a complete answer). Seeding: launch-week studio survey pass + pre-launch recruitment of the 2–3 largest operators; admin-marked "known-busy patterns" **explicitly rejected** as synthetic data. Unblocks 29.
- [19 — Domain model and schema synthesis](issues/19-domain-model-and-schema.md) — **Model locked**: [docs/domain-model.md](../../docs/domain-model.md) (entities, schema constraints, projections, `stationsNear`/`changedSince`, write boundaries — all 14 car constraints honoured) + CONTEXT.md glossary completed. New calls: **Bay 1—N Connectors with occupancy propagation**, availability **derived never stored** ([ADR-0008](../../docs/adr/0008-availability-derived-bay-propagation.md)); Photos in v1, admin/owner-only; Owner publicly visible with markerLabel + bundled icon. No payment, route, or session entity.
- [16 — What does EV Guide do on a bad connection?](issues/16-offline-and-connectivity.md) — **Offline is first-class** (closes 06's conditional: MapLibre stands). Kigali basemap (5.6 MB) + a directory snapshot ship in the binary; all-Rwanda pack (76 MB) opt-in; **decay derivation runs on device, so a stale green is structurally impossible**; reports queue with captured time+location and expire after their own decay window; route preview degrades to labeled straight-line, hand-off never blocks; cold online start < 1 MB. [ADR-0007](../../docs/adr/0007-offline-model.md).
- [15 — One Expo app or two, and what runs the admin dashboard?](issues/15-codebase-shape.md) — **Two apps; the brief beats the reference**: the mode-switch card becomes a membership-gated cross-app affordance (17 designs it). **One pnpm monorepo**: `apps/driver·operator·admin` + `packages/domain·data·ui`; the mock data implementation is a first-class citizen (ADR-0005's seam); admin is a Vite SPA in the BWEZE console's shape, tokens-only kinship. Platform floor is a rule: latest Expo SDK at build start, New Arch on, SDK-default minimums. No `create-expo-app` during this map. [ADR-0006](../../docs/adr/0006-codebase-shape.md).
- [14 — What does EV Guide run on?](issues/14-backend-platform.md) — **BWEZE, after the frontend is built.** One tenant + git-deployed containers (API, tiles, Valhalla); apps built frontend-first on a mock data layer behind repository protocols (the ZUBA pattern), backend swaps in behind the seam. **Launch bar in the spec: the BWEZE data plane moves off the tunnel-to-Mac before drivers are served.** One auth realm/user table across all three surfaces (Better Auth fallback); availability derived at read time, clients poll — no cron, no websockets; CDN-cached tiles, origin API. [ADR-0005](../../docs/adr/0005-backend-bweze-frontend-first.md).
- [05 — Can Expo carry CarPlay and Android Auto, and at what cost?](issues/05-expo-native-module-viability.md) — **Yes, on managed CNG/prebuild — bare is never mandatory — but no adoptable library exists**: the only maintained one (`@iternio/react-native-auto-play`) lacks the POI templates a charging app is allowed to use, and the one with them is old-arch, npm-stale, and disclaims Expo. Shape: **custom Expo module + owned config plugin**; dev-client from day one, Expo Go never; CarPlay needs one manual portal enablement (absent from EAS capability sync); simulator/DHU testing works pre-grant. Cost lands in the later car effort, not v1.
- [04 — What do CarPlay and Android Auto actually require?](issues/04-carplay-android-auto-requirements.md) — `carplay-charging` confirmed; the harder entitlement is `carplay-maps` and directions hand-off needs none of it; Android's `CHARGING` category is **deprecated**, use `POI`. Fourteen data-model constraints enumerated. **Neither platform ships in Rwanda**, and Apple Maps cannot navigate here at all.

## Not yet specified

In scope, but not yet sharp enough to ticket. Graduates as the frontier advances.

- **Notifications beyond bay-watch** — "this station went offline", operator
  alerts. Bay-watch itself graduated to ticket 30 (23 made it a car-review
  requirement); anything further stays fog.
- **Station media and community signal** — photos, reviews, ratings, "is it
  actually working" reports. Adjacent to availability (09) and may fold into it.
- **Admin moderation** — if availability is crowdsourced, someone arbitrates
  bad reports. Shape depends entirely on 09.
- **Operator onboarding** — how a real operator at EVP or Kabisa gets invited,
  verified, and bound to their stations. Depends on 07 and 11. First concrete
  shape from 28: the 2–3 largest operators are recruited **pre-launch** so the
  busiest sites have an operator writing status from day one.
- **Localisation** — Kinyarwanda, French, English. Sharpens once the screen
  inventory (17) exists.
- **Data seeding** — how entries are kept fresh once entered. The *source*
  question went to ticket 25 and came back: the MININFRA annex request is
  **held until after the build**, so seeding stays fog and manual entry stands.
- **Distribution** — App Store and Play Store listings, Rwanda availability,
  and what the car-integration approvals need in a public listing.
- **Analytics** — what the studio measures, and how that squares with the
  product being free and privacy-respecting.

## Out of scope

Ruled beyond the destination. Does not graduate.

- **In-app payment, settlement, and payouts** — MoMo/Airtel Money, IremboPay,
  refunds, owner settlement, reconciliation. Settled at charting: EV Guide
  displays rates and never collects them. The data model should leave room for
  a future payment effort without building any of it, and the reference's
  `Payment & payouts` settings row has no EV Guide equivalent (see 17).

- **Outbound acquisition and proposals of every kind** — the MININFRA annex
  request ([25](issues/25-obtain-mininfra-station-annex.md), drafted and held),
  and any approach to an operator, ministry, or funder. **Founder rule
  2026-08-13: these happen only after the product is built, never before.**
  Not a permission question — a one-time dataset acquisition was confirmed
  compatible with the no-external-reliance rule — but a sequencing one, so the
  annex cannot be an input to this spec. Manual entry stands unchanged, and
  **data seeding stays fog** rather than graduating.

- **Journey planning with charging stops** — including the corridor filter and
  the "reachable on my remaining charge" isochrone. Ruled out by
  [29](issues/29-journey-planning.md): the brief never asked for it, the
  competitive pressure that spawned it proved nonexistent (EVP has no app),
  and an Unknown-dominant layer makes stop suggestions hollow. Valhalla +
  isochrones already in the stack keep a future effort cheap — a fresh
  effort, not this map widened.

- **Moto riders and battery swap.** Ruled out by
  [ADR-0001](../../docs/adr/0001-cars-only-swap-out-of-scope.md) on
  deliverability, not market size — the only live availability data in Rwanda is
  car-only, and swap holds battery stock rather than occupied bays, so the
  bay/connector model cannot represent it without corruption. **Out of scope,
  not deferred**: serving riders later is a fresh effort with its own premise,
  not this map widened. The nullable vehicle-class tag on Station is the seam
  that keeps that cheap; it is not a commitment to cross it.
