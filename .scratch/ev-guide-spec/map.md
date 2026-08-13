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
  alternatives.
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
  question has graduated to ticket 25: MININFRA holds an unpublished
  per-station dataset with coordinates, bay counts and connector types.
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

- **Moto riders and battery swap.** Ruled out by
  [ADR-0001](../../docs/adr/0001-cars-only-swap-out-of-scope.md) on
  deliverability, not market size — the only live availability data in Rwanda is
  car-only, and swap holds battery stock rather than occupied bays, so the
  bay/connector model cannot represent it without corruption. **Out of scope,
  not deferred**: serving riders later is a fresh effort with its own premise,
  not this map widened. The nullable vehicle-class tag on Station is the seam
  that keeps that cheap; it is not a commitment to cross it.
