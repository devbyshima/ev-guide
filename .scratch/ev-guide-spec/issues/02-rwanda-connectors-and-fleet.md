# 02 — Which connector standards actually matter in Rwanda?

Type: research
Status: resolved (2026-08-13)
Blocked by: —

## Question

What connector standards must EV Guide model, and in what proportion?

Rwanda's EV fleet is a mix with genuinely different plugs: imported used
Nissan Leafs (CHAdeMO, Type 1), Chinese imports (GB/T), and newer European
stock (CCS2, Type 2). Which of these are actually on the road and at the
stations determines the whole reference-data taxonomy — and therefore what
"free **for me**" can even mean on the map.

Establish: the connector standards present at Rwandan public stations; the
rough composition of the car fleet by connector; typical power ratings (AC kW
vs DC fast); whether any standard is effectively dead or effectively mandatory;
and whether a standards taxonomy already exists that EV Guide should borrow
rather than invent (OCPI, OpenChargeMap's connector enum).

Answer should name the concrete enum EV Guide ships with.

## Context pointer

Findings in progress at `.scratch/ev-guide-spec/research/02-rwanda-connectors-and-fleet.md`.

## Answer

Full findings, cited: [`research/02-rwanda-connectors-and-fleet.md`](../research/02-rwanda-connectors-and-fleet.md).

**This ticket's own premise was wrong.** It asserted "imported used Nissan
Leafs (CHAdeMO, Type 1)" as a pillar of the fleet. Rwanda **bans right-hand-drive
passenger-car imports** (2002 decree, in force 2005), which structurally closes
the used-JDM channel that made CHAdeMO the default in Kenya, Uganda and
Tanzania. **CHAdeMO has zero documented station support in Rwanda.** The
regional intuition does not transfer across the LHD border.

**A regulation now governs this, and it is new.** RURA Regulation
No 011/ENERGY/RURA/2026, in force **29 June 2026** — Rwanda's first EV charging
regulation, postdating almost all press coverage. Article 2(c) enumerates
permitted connector technologies (CCS I and II, GB/T, CHAdeMO, NACS, Type 1,
Type 2, "and others which may be adopted from time to time"). Annex I sets the
only two binding rules: **at least one DC gun at ≥50 kW**, and **public
infrastructure must support at least the two most prevalent technologies in the
country**. All real specification is deferred to RSB, which has issued none.

**No proportional fleet data exists, and it cannot be derived** — nobody
publishes registrations by make or model. What is traceable: 512 BEV cars
imported 2020–2024, then **1,555 in the nine months to March 2026**. Three
quarters of the fleet is under a year old and overwhelmingly Chinese-branded.

**The open-data finding hardened.** OpenStreetMap holds **7** charging stations
for all of Rwanda; only 4 carry connector tags, all Volkswagen/Siemens Type 2
plus one Type 2 Combo. PlugShare, OpenChargeMap and Chargemap all refuse
programmatic access.

**Recommended enum** — OCPI 2.3.0 spellings, open. Tier 1: `IEC_62196_T2`,
`IEC_62196_T2_COMBO`, `GBT_AC`, `GBT_DC`. Tier 2, near-zero rows but cheap now:
`CHADEMO`, `IEC_62196_T1`, `IEC_62196_T1_COMBO`, `SAE_J3400`. Plus `UNKNOWN`
and a raw-string passthrough.

**Consequence for 09, now regulatory rather than merely practical:** because the
regulator *requires* two incompatible standards per station, "free for me" must
be evaluated per connector. A GB/T driver at a Type 2 + CCS2 site must see it
as incompatible even with a bay standing empty.

**Consequence for 03 and 14:** Kabisa runs **OCPP 1.6, which has no
connector-type field at all**. Even a live integration with Rwanda's largest
network could never tell EV Guide what the plugs are. Connector data is
permanently operator-asserted — the manual-entry model is confirmed, not merely
convenient.

**Surfaced, now ticket 25:** the seed dataset exists and is unpublished.

## Amendment from live data (2026-08-13, while working 08)

02 flagged GB/T at **medium confidence** — "attested as installed by the World
Bank but I could not name one Rwandan station with a GB/T gun". Kabisa's feed
settles it, and more strongly than either study predicted.

Of 77 Rwandan charge points: **55 are GB/T alone**, plus `GBT,CSS2` ×6,
`CSS2,GBT` ×1 — **62 of 77 carry a GB/T gun**. Against that: `Type 2` ×6,
`CSS2` alone ×2, `CCS,chademo` ×1, and three domestic wall sockets
(`Schuko F` ×2, `Schuko G` ×1).

**GB/T is the dominant standard in Rwanda by a wide margin** — not the
co-equal partner MININFRA's Type 2 + GB/T recommendation implies, nor the
junior partner in the World Bank's CCS2 + GB/T. The recommended tier-1 enum
still holds, but the *ordering* should reflect that GB/T is the common case and
Type 2 the exception.

Two smaller confirmations: **CHAdeMO appears exactly once**, corroborating that
the LHD import rule closed that channel; and the feed's own spellings are
inconsistent (`CSS2` is a typo for CCS2, alongside `GBT`, `chademo`, `Schuko F
(German)`), which is a concrete instance of 04's constraint 8 — never persist a
vendor enum, map at every boundary.
