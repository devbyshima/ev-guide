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

**Market context found while charting.** Rwanda's charging market is genuinely
multi-operator — EVP Charger (~95 e-moto + ~20 car stations), Kabisa (26 public
points, 7 at SP fuel stations), Volkswagen Mobility Solutions Rwanda with
Siemens — and reached ~200 public stations in Kigali by Feb 2026. **EVP Charger
shipped its own app in July 2026** (locator, journey planning, cashless
payments, "Tap & Charge" card), but it covers EVP's network only. EV Guide's
opening is being the one map across all operators.

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
- [04 — What do CarPlay and Android Auto actually require?](issues/04-carplay-android-auto-requirements.md) — `carplay-charging` confirmed; the harder entitlement is `carplay-maps` and directions hand-off needs none of it; Android's `CHARGING` category is **deprecated**, use `POI`. Fourteen data-model constraints enumerated. **Neither platform ships in Rwanda**, and Apple Maps cannot navigate here at all.

## Not yet specified

In scope, but not yet sharp enough to ticket. Graduates as the frontier advances.

- **Notifications** — "tell me when a bay frees up", "this station went
  offline". Not in the brief; plausible once the availability model exists.
- **Journey planning with charging stops** — EVP's app does this. Whether EV
  Guide competes there depends on the directions decision (13).
- **Station media and community signal** — photos, reviews, ratings, "is it
  actually working" reports. Adjacent to availability (09) and may fold into it.
- **Admin moderation** — if availability is crowdsourced, someone arbitrates
  bad reports. Shape depends entirely on 09.
- **Operator onboarding** — how a real operator at EVP or Kabisa gets invited,
  verified, and bound to their stations. Depends on 07 and 11.
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
