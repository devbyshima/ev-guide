# 02 — Which connector standards actually matter in Rwanda?

Research for ticket `02-rwanda-connectors-and-fleet`. Resolved 2026-08-13.

**Headline.** Rwanda has a **regulator-defined connector vocabulary but no national
connector standard**. RURA's Regulation No 011/ENERGY/RURA/2026 (in force 29 June
2026) names six technologies but delegates the actual specification to the Rwanda
Standards Board, which has not issued one. The only binding rules are "support at
least two most prevalent charging technologies" and "at least one DC gun ≥ 50 kW".
Two independent government-commissioned studies both recommend a **dual standard**:
the EU/MININFRA master plan says **Type 2 + GB/T**, the World Bank says **CCS2 +
GB/T**. On the ground, the only station-level connector data that exists in the open
is four OpenStreetMap nodes, all **Type 2 / Type 2 Combo (CCS2)**. GB/T is attested at
the policy level as installed but I could not name a single Rwandan station with a
GB/T gun.

**The ticket's premise about used Nissan Leafs is probably wrong.** Rwanda bans
right-hand-drive imports, which closes the used-JDM channel that put CHAdeMO into
Kenya, Uganda and Tanzania. See §2.

---

## 1. What is physically at Rwandan public stations

### 1.1 The regulator's own list (primary, binding document)

[RURA Regulation No 011/ENERGY/RURA/2026 of 29/06/2026 governing Electric Vehicle
Charging Infrastructure and Battery Swapping Stations](https://www.rura.rw/fileadmin/user_upload/RURA/Documents/Sectors/Energy/Regulatory_Instruments/Energy_Regulations_and_Guidelines/Regulations_Governing_Electric_Vehicle_charging_Infrastructures_in_Rwanda.pdf),
Article 2(c), verbatim:

> "Electric Charging Technologies" refers to the EV charging technologies, including
> Combined Charging System (CCS) I and II, GB/T, CHAdeMO, NACS (North American
> Charging Standard), Type 1 / Type 2 AC chargers and others which may be adopted from
> time to time;

Signed by Dr Carpophore Ntagungira, Chairperson of the Regulatory Board, Kigali,
29/6/2026. This is the closest thing Rwanda has to an official connector enum. Note
that it is explicitly **open-ended** ("and others which may be adopted from time to
time") — it is a definitional list, not a whitelist, and it says nothing about
prevalence.

Annex I of the same regulation, under "Charging Technologies", verbatim:

> - Public EV charging stations shall include at least one DC fast charging system
>   with a minimum rated output of 50 kW per charging gun.
> - Public Charging infrastructure shall support at least two most prevalent charging
>   technologies in the country.
> - All technical specifications, including connectors, communication protocols, and
>   interoperability requirements, shall be in accordance with standards adopted by
>   Rwanda Standards Board.

The second bullet is the load-bearing one for EV Guide: **the regulator's own position
is that at least two mutually incompatible standards coexist in Rwanda and neither
covers the fleet.** A station model that assumes one connector per station is wrong by
regulation.

### 1.2 The only open station-level connector data that exists

I queried the [OpenStreetMap Overpass API](https://overpass-api.de/api/interpreter)
for `amenity=charging_station` inside Rwanda (`ISO3166-1=RW`). **Seven objects total**,
of which four carry socket tags — all Volkswagen, all Siemens hardware:

| OSM node | lat, lon | operator | manufacturer | sockets |
|---|---|---|---|---|
| `8816058906` | −1.9561663, 30.0919582 | Volkswagen | Siemens | `socket:type2=1`, `socket:type2:output=22 kW` |
| `8816058907` | −1.9562391, 30.0920180 | Volkswagen | Siemens | `socket:type2=1`, `socket:type2:output=22 kW` |
| `8816068253` | −1.9563063, 30.0920785 | Volkswagen | Siemens | `socket:type2_combo=1`, `power=150kWh` |
| `8816112276` | −1.9559235, 30.1601375 | Volkswagen | Siemens | `socket:type2=1`, `power=11 kWh` |
| `10792575194` | −1.8936977, 30.4697850 | — (`name=KABISA`) | — | none; `access=yes`, `capacity=1`, `fee=no` |
| `11658397436` | −1.9612678, 30.1197780 | Ampersand Rwanda | — | none; motorcycle battery swap (Giporoso) |
| way `1254199644` | — | — | — | none |

`socket:type2_combo` is OSM's tag for CCS2. The `power=150kWh` / `11 kWh` tags are
mistagged units — they mean 150 kW and 11 kW. So: **Type 2 AC at 11 and 22 kW, and
CCS2 DC at 150 kW, at Volkswagen/Siemens sites.** No GB/T, no CHAdeMO, no Type 1
anywhere in OSM Rwanda.

This is a four-station sample. It is not a fleet-wide picture. It is, however, the
only machine-readable connector data for Rwanda I could find anywhere.

**Corroborating the "no dataset" finding in `map.md`:** Electromaps' country index lists
746,584 stations worldwide across ~120 countries and **Rwanda does not appear at all** —
I fetched [electromaps.com/en/charging-stations/rwanda](https://www.electromaps.com/en/charging-stations/rwanda)
and the string "Rwanda" occurs zero times in the rendered country list (Somalia 27,
Ethiopia 15, Nigeria 10, Burkina Faso 6 all appear; Rwanda does not). [Chargemap's
Kigali page](https://chargemap.com/cities/kigali-RW) is paywalled (HTTP 402).
[evchargingstops.com/rwanda/kigali](https://www.evchargingstops.com/rwanda/kigali),
which mirrors PlugShare, states: *"No pins on the map? Unfortunately, Plugshare users
haven't reported any charging stations."* The PlugShare and OpenChargeMap APIs both
require registered keys (HTTP 401 / 403 respectively) and I could not read them.

### 1.3 What the operators themselves publish

**Kabisa** — largest car-charging network. Fetching [kabisa.africa](https://www.kabisa.africa/)
and reading the embedded station array gives their live Rwandan sites and ratings:

| Station | Coords | Power |
|---|---|---|
| Kigali Hub | −1.95, 30.06 | 240 kW DC |
| SP Kanombe | −1.95, 30.13 | 240 kW DC |
| IZI Nyarutarama | −1.94, 30.09 | 120 kW DC |
| SP Musanze | −1.48, 29.63 | 60 kW DC |

Same page: *"DC Fast Charging (60–240 kW)"*, *"OCPP 1.6 Protocol"*, *"60–240 kW
stations deployed at corridor waypoints and urban hubs"*, planned stations *"120 kW
DC"*. **Kabisa publishes no connector types at all.** The OCPP 1.6 detail matters —
see §5.4.

**EVP Charger** — largest station count. Their site's charger finder
([web.evpcharger.com](https://web.evpcharger.com/), fetched directly) offers exactly
these filter values:

- `Charger power`: Level 1, Level 2, Fast Charger
- `Connector Type`: Type 1, Type 2, CCS

No GB/T, no CHAdeMO. **Caveat that cuts against reading much into this:** the "map"
next to that filter is a static Google Maps iframe of the whole of Rwanda, and the
page contains no station records. The filter is an unimplemented template, so this is
EVP's *vocabulary*, not their *inventory*.

**Volkswagen Mobility Solutions Rwanda** — the [Siemens press
release](https://press.siemens.com/za/en/pressrelease/first-africa-volkswagen-and-siemens-launch-joint-electric-mobility-pilot-project)
and the [Volkswagen
newsroom](https://www.volkswagen-newsroom.com/en/press-releases/first-for-africa-volkswagen-and-siemens-launch-joint-electric-mobility-pilot-project-in-rwanda-5510)
(Oct 2019) announce e-Golfs and Siemens charging infrastructure but specify **no
connector types or kW**. The e-Golf's European spec is Type 2 AC + CCS2 DC, which
matches the OSM tags in §1.2.

### 1.4 What the studies say is installed

[World Bank, *Exploring Enabling Energy Frameworks for Electric Mobility in Rwanda*,
June 2025](https://documents1.worldbank.org/curated/en/099741407092528476/txt/IDU-89dfbbe7-c5a1-4343-98dc-99ea1f05fcb3.txt),
verbatim:

> RURA has not implemented standards for charging points and interoperability and
> technologies imported comply with both Chinese and European standards.

> …the RSB is responsible for the implementation of standards, testing, product
> certification, accreditation, labelling, marking, and technical regulations, and
> E-Mobility service providers have provided and installed EVCI based on standards
> used in China (GB/T standards) and in Europe (IEC/ISO-based standards).

That is the strongest evidence that **GB/T hardware is physically deployed in Rwanda**.
It is a World Bank field study rather than an inventory, and it names no station.

[Automag.rw, "Rwanda EV Charging Gaps: Key Challenges", 12 Feb
2025](https://automag.rw/2025/02/12/rwanda-ev-charging-gaps-key-challenges/), verbatim:

> Charging compatibility is another roadblock. Different standards – such as GB/T,
> CCS, and Type2 connectors – make it difficult for EV operators to use the network
> seamlessly.

and *"Vehicles imported by companies like Auto24.RW often need adapters to connect to
local chargers."* Secondary trade press, unattributed. **Medium-low confidence**, but
it is directionally consistent with the World Bank.

**A direct contradiction worth recording.** [EV24.africa, "Charging an Electric Car in
Kigali: What Owners Experience", 7 Mar
2026](https://www.ev24.africa/charging-an-electric-car-in-kigali-what-owners-experience/)
states: *"All stations in Kigali use the Combined Charging System (CCS2), ensuring
compatibility for cross-border travelers."* This flatly contradicts the World Bank and
Automag. EV24.africa is an EV-import vendor's content marketing, aggregated from
studies and press releases rather than fieldwork (it acknowledges as much), so I weight
it **low**. But I cannot rule out that Rwanda's *public car-charging* estate has
converged on CCS2 while GB/T sits behind private fleet depots. Both stories fit the
evidence I could gather.

### 1.5 Verdict on physical presence

| Standard | Present in Rwanda? | Best evidence | Confidence |
|---|---|---|---|
| **Type 2 (IEC 62196-2) AC** | **Yes** | 3 OSM nodes at 11 & 22 kW; EVP's own filter; every policy doc | High |
| **CCS2 (Type 2 Combo) DC** | **Yes** | OSM node at 150 kW; EVP's filter; all DC recommendations | High |
| **GB/T (AC and/or DC)** | **Probably yes** | World Bank June 2025 says installed; Automag says causes adapter problems | Medium |
| **CHAdeMO** | **No positive evidence** | Only in RURA's definitional list and the master plan's global-context annex | Low presence |
| **Type 1 / J1772** | **No positive evidence** | In RURA's list and EVP's filter template only | Low presence |
| **NACS / SAE J3400** | **No evidence** | RURA's definitional list only | Very low |
| **Tesla proprietary** | **No evidence** | — | Very low |

---

## 2. Fleet composition by connector

### 2.1 The actual import numbers (best available attribution)

The only figures I could trace to a named government official come from Alfred
Byiringiro, **Senior Technical Advisor for Transport at the Ministry of
Infrastructure**, quoted in *The New Times* (Kigali), 29 April 2026, by Michel
Nkurunziza — [syndicated at
allAfrica](https://allafrica.com/stories/202604300014.html):

- **2020–2024: 512 fully electric cars imported** — 2020: 19, 2021: 38, 2022: 134,
  2023: 103, 2024: 218
- **July 2025 – end March 2026: 1,555 fully electric cars imported**
- **"So far, there are 71 electric car charging stations"**

The 2020–2024 annual series and the hybrid series are also reported by [IGIHE, 5 Oct
2024](https://en.igihe.com/news/article/rwanda-s-electric-vehicles-surpass-7-000) —
hybrids 2020: 0, 2021: 28, 2022: 520, 2023: 2,386, 2024: 3,726, cumulative **6,660
hybrids**, giving "over 7,000" EVs and hybrids combined. IGIHE attributes only one
figure (a RWF 4.6bn tax forgone number, to the Rwanda Revenue Authority's 2022/23
report) and leaves the rest unattributed.

**So: roughly 2,000+ battery-electric cars in Rwanda by early 2026, of which about
three quarters arrived in the nine months to March 2026.** Any connector model built
around the pre-2025 fleet is modelling a quarter of the cars.

Note the master plan's own baseline for scale: [as of 3 July 2020 there were 264,524
registered vehicles countrywide, 173,000 of them
motorcycles](https://www.mininfra.gov.rw/fileadmin/user_upload/Mininfra/Publications/Policies/Transport/Final_Report_EVCI_Master_Plan.pdf)
(Table 10, citing MININFRA's 2021 *Strategic Paper on Electric Mobility Adaptation in
Rwanda*). BEVs are a rounding error on the national fleet and a fast-growing one.

### 2.2 The structural fact the ticket's premise misses: Rwanda is left-hand-drive only

Rwanda drives on the right and **banned right-hand-drive vehicle imports** by
presidential decree of September 2002, in force from 2005; only LHD vehicles may be
permanently imported and registered. A later presidential order relaxed this **only**
for 20-tonne-and-above cargo trucks, cross-border public-transport buses and road
tractors — [The EastAfrican, "Right-hand-drive vehicles return on Rwandan
roads"](https://www.theeastafrican.co.ke/rwanda/Business/Right-hand-drive-vehicles-return-on-Rwandan-roads-/1433224-2652722-btn100z/index.html);
see also [JapaneseCarTrade's Rwanda import
rules](https://blog.japanesecartrade.com/57-rwanda-import-regulation-for-japan-used-cars/)
and [Automag's import
guide](https://automag.rw/2025/05/29/rwandas-car-import-rules-explained-documents-fees-and-tips/),
which additionally report an RRA age cap of 10 years on imported vehicles.

**Consequence.** Japan is right-hand-drive. The used-JDM pipeline through Mombasa that
made CHAdeMO the default DC standard in Kenya, Uganda and Tanzania is **structurally
closed to Rwanda for passenger cars**. The ticket's framing — "imported used Nissan
Leafs (CHAdeMO, Type 1)" — is a correct description of the East African market
*generally* and a poor description of Rwanda *specifically*.

CHAdeMO is not impossible: a left-hand-drive European-market Nissan Leaf has Type 2 AC
+ CHAdeMO DC, and a US-market Leaf has J1772 + CHAdeMO. The Leaf is named as a popular
model in Rwanda by [Automag, 20 Mar
2025](https://automag.rw/2025/03/20/what-you-need-to-know-before-buying-an-electric-car-in-rwanda/)
("Popular models include the Nissan Leaf, BMW i3, and Hyundai Kona Electric"), which
does not say where they are sourced. But CHAdeMO has no channel volume and no station
support I could find.

### 2.3 Who is actually selling cars in Rwanda in 2025–26

The 2025–26 wave is overwhelmingly Chinese. From the same New Times / allAfrica piece:

- **Longtai Auto Rwanda** — began operations June 2025; 6 cars in June 2025, 49 across
  Jul–Dec 2025, **80 in April 2026 alone**. [Ecobank offers up to 100% financing on
  Longtai EVs](https://allafrica.com/stories/202506270170.html).
- **Kason Motor Ltd** (Kigali Special Economic Zone) — launched March 2026; 20 cars in
  March, 50+ in April 2026.

Model lineups, from the dealers' own sites:

- **[China Electric Vehicle Rwanda (cevr.rw)](https://cevr.rw/vehicles)**: BYD Tang L
  EV, BYD Tai 3, BYD Yuan Up, Geely EX2, Geely EX5, Geely Riddara RD6, Farizon F3E van,
  Farizon V8E cargo van.
- **[BYD Rwanda official (byd.com/rw)](https://www.byd.com/rw)**: SHARK 6 DMO, SONG
  PLUS DM-i, SEAGULL, DOLPHIN, YUAN UP, YUAN PLUS, TANG L, SONG PLUS EV, BAO 5, BAO 8.
  CFAO Mobility opened East Africa's first BYD showroom in Kigali.
- Kabisa's ultrafast hub serves *"Wuling Hongguang and Baojun Yeps mini EVs, BYD
  Seagulls, Geely electric pickups, Farizon electric trucks, and electric buses"* —
  [CleanTechnica, 15 Feb
  2025](https://cleantechnica.com/2025/02/15/kabisa-enables-commercial-ev-adoption-in-east-africa-by-launching-1st-ultrafast-charging-hub-in-kigali/).

**An inference, clearly marked as such.** Those are largely *Chinese-domestic*
nameplates (Yuan Up, Yuan Plus, Song Plus, Tang L, Bao 5/8, Seagull, Tai 3) rather than
the export nameplates BYD uses for CCS2 markets (Atto 3, Dolphin Surf, Seal U). That
pattern is consistent with China-spec cars carrying **GB/T** ports. **I could not
confirm this.** I fetched the BYD Rwanda model pages (e.g.
[byd.com/rw/car/seagull](https://www.byd.com/rw/car/seagull)) and the CEVR vehicle
pages and **neither publishes a charging port type, AC kW, or DC kW for any model.**
Treat "the new Chinese wave is GB/T" as a well-supported hypothesis, not a fact.

### 2.4 Honest answer on proportion

**No published dataset breaks Rwanda's EV fleet down by connector, and none breaks it
down by make and model either.** MININFRA publishes an aggregate import count; RRA
publishes tax-forgone figures; NISR and RURA publish nothing I could find on EV
registrations by fuel type or model. What can be said with sources:

- ~2,000+ BEV cars total, ~75% of them arriving Jul 2025 – Mar 2026.
- The pre-2025 stock is a mix — VW e-Golf fleet (Type 2 + CCS2), and Leaf / i3 / Kona
  named as popular (Type 2 or J1772 AC; CHAdeMO or CCS2 DC depending on source market).
- The 2025–26 stock is overwhelmingly Chinese-branded and plausibly GB/T.
- Buses are a separate population: the World Bank counts **9 operational e-buses in
  Kigali with 4 fast-charging stations**, operators BasiGo, IZI Electric, Jali
  Transport, Volcano Express.

**A connector-proportion number for Rwanda does not exist and cannot be responsibly
estimated from what is public.** EV Guide should not encode one.

---

## 3. Typical power ratings in-market

### 3.1 Regulatory floor and grid envelope (primary)

From [RURA Regulation 011/2026 Annex
I](https://www.rura.rw/fileadmin/user_upload/RURA/Documents/Sectors/Energy/Regulatory_Instruments/Energy_Regulations_and_Guidelines/Regulations_Governing_Electric_Vehicle_charging_Infrastructures_in_Rwanda.pdf),
binding on public stations:

- **≥ 1 DC fast charging system, minimum rated output 50 kW per charging gun**
- DC systems may share a power cabinet across multiple outlets if total capacity
  supports simultaneous operation and dynamic load management is fitted
- Grid: MV 15 kV or 30 kV ±10%; **LV 400 V three-phase / 230 V single-phase ±10%; 50 Hz
  ±1%**, per the Rwanda Grid Code
- Power factor ≥ 0.9 at point of connection; THD < 3%
- Parking bay 2.5 m × 5 m

### 3.2 Observed AC ratings

- **11 kW and 22 kW** Type 2 at the Volkswagen/Siemens sites (OSM, §1.2)
- **7.43 kW to 22 kW** — *"most of the existing charging stations in Kigali averaging
  7.43 kW to 22 kW"*, [CleanTechnica, 15 Feb
  2025](https://cleantechnica.com/2025/02/15/kabisa-enables-commercial-ev-adoption-in-east-africa-by-launching-1st-ultrafast-charging-hub-in-kigali/)
- **7.3 kW** — Kabisa's standard Level 2 offering (same source)
- Home charging advice in Rwanda: *"a charger with at least 7 kW"*, [Automag, 20 Mar
  2025](https://automag.rw/2025/03/20/what-you-need-to-know-before-buying-an-electric-car-in-rwanda/)

### 3.3 Observed DC ratings

| kW | Where | Source |
|---|---|---|
| 50 | regulatory minimum per gun | RURA Reg 011/2026 Annex I |
| 60 | SP Musanze (Kabisa) | [kabisa.africa](https://www.kabisa.africa/) |
| 100 | EVPLUGIN EPL 100 unit | [EV24.africa](https://www.ev24.africa/charging-an-electric-car-in-kigali-what-owners-experience/) (low confidence) |
| 120 | IZI Nyarutarama; Kabisa's planned stations | [kabisa.africa](https://www.kabisa.africa/); [World Bank blog](https://blogs.worldbank.org/en/energy/rwanda-electric-mobility) |
| 150 | Volkswagen/Siemens CCS2 node | OSM `8816068253` |
| 160 | Remera and Nyabugogo e-bus chargers | [World Bank report](https://documents1.worldbank.org/curated/en/099741407092528476/txt/IDU-89dfbbe7-c5a1-4343-98dc-99ea1f05fcb3.txt) |
| 240 | SP Kanombe, Kigali Hub (Kabisa) | [kabisa.africa](https://www.kabisa.africa/) |

Kabisa's SP Kanombe hub is Rwanda's fastest: **240 kW, six bays**, charging in *"15–25
minutes"* versus *"more than one hour"* at standard stations ([CleanTechnica, 15 Feb
2025](https://cleantechnica.com/2025/02/15/kabisa-enables-commercial-ev-adoption-in-east-africa-by-launching-1st-ultrafast-charging-hub-in-kigali/)).
The World Bank's blog ([Tarek Keskes, ESMAP, 2 Oct
2025](https://blogs.worldbank.org/en/energy/rwanda-electric-mobility)) describes
current Rwandan fast chargers as *"120 to 160 kW units capable of powering fleets
overnight"* and a planned Nyabugogo hub with *"18 chargers, an 800-kW rooftop solar
photovoltaic system"* at $7.7m.

The EVCI master plan's own costing bands are `AC 2 wheeler` / `AC 4 wheeler` / `30 kW`
/ `CCS-60 kW`, which is a reasonable read of what the consultants expected Rwanda to
buy in 2024.

**Design implication.** The in-market spread is roughly **7.4 / 11 / 22 kW AC** and
**50 / 60 / 120 / 150 / 240 kW DC**, with a hard regulatory floor of 50 kW for any new
public DC gun. Free-text kW is fine; a fixed set of power tiers is not.

### 3.4 Station counts, for context

Inconsistent across sources, all recent:

- **71 electric car charging stations** — MININFRA's Byiringiro, April 2026 ([The New
  Times / allAfrica](https://allafrica.com/stories/202604300014.html))
- **~200 in Kigali** (35 car, 165 motorbike) — [MobilityX
  Africa](https://mobilityx.africa/ecosystem-mapping-database/country-analysis/country-analysis/rwanda)
  and [EV24.africa, Mar 2026](https://www.ev24.africa/charging-an-electric-car-in-kigali-what-owners-experience/)
- **EVP Charger: ~95 e-motorcycle + ~20 e-car stations**, 12,000+ car charging
  transactions/month, planning 30 moto + 25 car stations in 2026 — [The New Times, 8
  June 2026](https://www.newtimes.co.rw/article/36361/news/featured/how-evp-charger-is-powering-rwandas-ev-transition/amp)
- **Kabisa: 26 public charging points, 7 at SP fuel stations** (Feb 2025, CleanTechnica)
- Master plan baseline, **June 2024**: 17 existing car-charging stations in Kigali
  (BasiGo 1, EVP 6, Volkswagen 2, Kabisa 8) plus 5 outside Kigali, and 28 battery-swap
  stations (Ampersand 15, Spiro 12, REM 1) — [EVCI Master Plan Tables
  12–14](https://www.mininfra.gov.rw/fileadmin/user_upload/Mininfra/Publications/Policies/Transport/Final_Report_EVCI_Master_Plan.pdf)

The gap between "71" and "~200" is almost certainly cars-only versus cars+motorcycles.

---

## 4. Dead, or mandatory? And is a national standard coming?

### 4.1 Nothing is mandatory today

[EVCI Master Plan, Oct 2024](https://www.mininfra.gov.rw/fileadmin/user_upload/Mininfra/Publications/Policies/Transport/Final_Report_EVCI_Master_Plan.pdf),
Table 16 "Current Practices and development on eMobility in Rwanda", verbatim:

> The Rwanda Standards Board (RSB) is the main authority responsible for issuing
> technical standards, quality testing, metrology, and certification. Current standards
> in Rwanda are benchmarked against international standards, including those adopted by
> other African countries. **No specific standards for EVs and charging infrastructures
> have been issued in Rwanda.**

[World Bank, June
2025](https://documents1.worldbank.org/curated/en/099741407092528476/txt/IDU-89dfbbe7-c5a1-4343-98dc-99ea1f05fcb3.txt),
verbatim: *"While RSB has yet to establish specific standards for EVs, this presents an
opportunity to develop a framework that aligns with international best practices."*

I searched the [RSB standards store, Electrical Engineering
category](https://portal.rsb.gov.rw/webstore.php?is=MTUyRkJrTndaM0EzcA&ist=dGF2ZXJyYXZ0YXIgeW5wdmVncHJ5UkZCa053WjNBM3A)
(128 items). The only EV-adjacent standard visible is **RS ISO 5474-4:2025**,
*Electrically propelled road vehicles — … Part 4: Magnetic field wireless power
transfer* — wireless charging, not connectors. **No RS adoption of IEC 62196 or IEC
61851 is visible in the catalogue.** (Caveat: the store paginates 20 at a time and I
could not enumerate all 128 entries; absence here is suggestive, not conclusive.)

**So Rwanda now has a regulation that points at a standard that does not exist.** RURA
Reg 011/2026 Article 24 makes RSB responsible for *"Developing and periodically
updating standards for EV charging infrastructure, battery systems, charging
connectors, interoperability, electrical safety…"* — future tense.

### 4.2 What is mandatory

Only two things bear on connectors:

1. **"Public Charging infrastructure shall support at least two most prevalent charging
   technologies in the country."** (Annex I) — a *pluralism* mandate, not a
   *standardisation* one. It is deliberately relative ("most prevalent"), so it moves
   with the market.
2. **≥ 1 DC gun at ≥ 50 kW** per public station.

Existing operators have **twelve months** from 29 June 2026 to comply (Article 37).
Note that secondary coverage of this regulation is unreliable — several outlets report
a *two-year* transition; the regulation itself says *"a period not exceeding twelve
(12) months from the effective date"*.

Separately, **battery swapping for motorcycles IS mandated interoperable** (Article
22) — the widely reported "Africa's first universal battery-swap mandate". This is
out of scope for a car-connector enum but is the one place Rwanda has actually forced
a standard.

### 4.3 Two official recommendations, both dual-standard, and they disagree slightly

**MININFRA / EU EDF Programme, EVCI Master Plan, Final Report Oct 2024** (produced by
Consortium SOFRECO – IBC Group, published on mininfra.gov.rw), §6.9.2, verbatim:

> Standardize hardware requirements for public and semi-public charging infrastructure,
> adopting a hybrid approach mandating the use of **Type 2 and GBT connectors as
> national standards**. …
> ▪ **Type 2 Connector**: … Making Type 2 connectors mandatory in Rwanda's public EV
> charging infrastructure will ensure alignment with international standards …
> ▪ **GBT Connector**: As Rwanda has seen an influx of Chinese-manufactured EVs, the
> GBT connector standard should also be adopted … **GBT is one of the predominant
> standards in Rwanda.**
>
> For public recharging infrastructure equipped with at least two charging stations or
> two charging points, **both Type 2 and GBT connectors should be installed**. In cases
> where a charging station has only one charging point and one connector, one of these
> standards should be installed based on the owner's/market's preference.

§5.6.3 clarifies the DC side: *"The Type 2 connector (for AC charging and CCS for DC
charging) is the official standard in Europe…"* — so the master plan's "Type 2" means
**Type 2 AC + CCS2 DC**. §6.9.3 explicitly permits an **optional third standard**
"based on market preferences in cases where both standards are already installed",
market-driven only.

**World Bank, June 2025**, verbatim:

> Regarding the choice of charging standards, it is advisable for the RSB to formally
> adopt **both CCS2 and GB/T standards**. These two standards, while originating from
> different regions, are comparable in terms of safety and performance.

Its recommendation matrix assigns this to *"(MININFRA, Rwanda Standards Board (RSB),
RURA, REG/EUCL, Cities; Short-term)"*. Reiterated in the [ESMAP blog, 2 Oct
2025](https://blogs.worldbank.org/en/energy/rwanda-electric-mobility).

Both also recommend the software layer: the master plan says *"Rwanda should adopt
OCPP, OCPI, ISO 15118-20, and IEC 61851"* and *"Mandate the use of the Open Charge
Point Interface (OCPI) for communication between charging stations and service
providers. OCPI enables EV drivers to easily find and use charging stations."* **That
is a direct endorsement, in a Rwandan government publication, of the taxonomy EV Guide
should borrow.**

### 4.4 Regional layer: nothing to inherit

I found **no East African Community harmonised standard for EV charging or connectors**.
The EAC harmonised low-sulfur diesel fuel standards in 2015 and vehicle standards in
2022, with nothing on charging
([EV24.africa](https://www.ev24.africa/african-countries-push-for-harmonized-ev-standards-across-east-africa/),
which itself notes the gap rather than documenting an achievement). Regional
harmonisation is aspiration, not instrument.

### 4.5 Effectively dead / effectively required

- **Effectively required: CCS2.** Every documented DC connector in Rwanda is CCS2. It
  is in both official recommendations. Nothing else has a documented DC installation.
- **Effectively required: Type 2 AC.** Every documented AC connector in Rwanda is Type
  2. The master plan wants it mandatory.
- **Live but undocumented: GB/T.** The World Bank says it is installed; the master plan
  calls it *"one of the predominant standards in Rwanda"*; the import mix points that
  way. Model it.
- **Effectively dead: Type 1 / J1772.** LHD-only imports plus no US used-car channel
  plus the master plan describing Type 1 as the standard NACS is replacing in the US.
  It survives only in EVP's unimplemented site filter and RURA's definitional list.
- **Effectively dead: NACS / SAE J3400 and Tesla proprietary.** No Rwandan presence at
  all. RURA lists NACS defensively, presumably because the master plan flagged the US
  transition.
- **Marginal: CHAdeMO.** Structurally disadvantaged by the RHD ban (§2.2), globally in
  decline, and with zero documented Rwandan station support. Not zero-probability —
  LHD European Leafs exist — but not worth building a charging-compatibility promise
  around.

---

## 5. Should EV Guide borrow a taxonomy? Yes — OCPI's.

Three candidates were evaluated against their specs. The exact values follow, because
paraphrases are what cause enum drift.

### 5.1 OCPI `ConnectorType`

The current published release is **OCPI 2.3.0** ([ocpi/ocpi
README](https://github.com/ocpi/ocpi/blob/master/README.md)); OCPI 3.0 development
happens in a contributors-only repo and is not public.

**OCPI 2.2.1 `ConnectorType` — 40 values**, from
[mod_locations.asciidoc @ 2.2.1](https://github.com/ocpi/ocpi/blob/2.2.1/mod_locations.asciidoc):

```
CHADEMO                  CHAOJI                   DOMESTIC_A
DOMESTIC_B               DOMESTIC_C               DOMESTIC_D
DOMESTIC_E               DOMESTIC_F               DOMESTIC_G
DOMESTIC_H               DOMESTIC_I               DOMESTIC_J
DOMESTIC_K               DOMESTIC_L               DOMESTIC_M
DOMESTIC_N               DOMESTIC_O               GBT_AC
GBT_DC                   IEC_60309_2_single_16    IEC_60309_2_three_16
IEC_60309_2_three_32     IEC_60309_2_three_64     IEC_62196_T1
IEC_62196_T1_COMBO       IEC_62196_T2             IEC_62196_T2_COMBO
IEC_62196_T3A            IEC_62196_T3C            NEMA_5_20
NEMA_6_30                NEMA_6_50                NEMA_10_30
NEMA_10_50               NEMA_14_30               NEMA_14_50
PANTOGRAPH_BOTTOM_UP     PANTOGRAPH_TOP_DOWN      TESLA_R
TESLA_S
```

**OCPI 2.3.0 adds two and removes none** ([mod_locations.asciidoc @
2.3.0/release/core](https://github.com/ocpi/ocpi/blob/2.3.0/release/core/mod_locations.asciidoc)):

- `MCS` — *"The MegaWatt Charging System (MCS) connector as developed by CharIN"*
- `SAE_J3400` — *"SAE J3400, also known as North American Charging Standard (NACS),
  developed by Tesla, Inc in 2021."*

The value is spelled `SAE_J3400`, **not** `NACS`. In 2.3.0 the heading changed from
`ConnectorType _enum_` to `ConnectorType _OpenEnum_` — receivers must tolerate unknown
values, so this must not be a closed enum that throws on decode.

Note the exact spellings that trip people up: there is **no `CCS2` value** — CCS2 is
`IEC_62196_T2_COMBO` and CCS1 is `IEC_62196_T1_COMBO`. GB/T is split into `GBT_AC`
(GB/T 20234.2) and `GBT_DC` (GB/T 20234.3). The IEC 60309 values use lowercase
suffixes while everything else is SCREAMING_SNAKE — that inconsistency is in the spec,
not a transcription error.

**`ConnectorFormat`** (2 values, unchanged across versions):

```
SOCKET   The connector is a socket; the EV user needs to bring a fitting plug.
CABLE    The connector is an attached cable; the EV users car needs to have a fitting inlet.
```

**`PowerType`** (5 values, unchanged):

```
AC_1_PHASE         AC single phase.
AC_2_PHASE         AC two phases, only two of the three available phases connected.
AC_2_PHASE_SPLIT   AC two phases using split phase system.
AC_3_PHASE         AC three phases.
DC                 Direct Current.
```

**`Connector` object fields** — 2.2.1 has 10, 2.3.0 has 11: `id` (CiString(36), req),
`standard` (ConnectorType, req), `format` (ConnectorFormat, req), `power_type`
(PowerType, req), `max_voltage` (int, req), `max_amperage` (int, req),
`max_electric_power` (int, opt), `tariff_ids` (CiString(36), list),
`terms_and_conditions` (URL, opt), `capabilities` (ConnectorCapability, list — **new in
2.3.0**), `last_updated` (DateTime, req).

Two field semantics matter for EV Guide:

- `id` is *"Identifier of the Connector within the EVSE. Two Connectors may have the
  same id as long as they do not belong to the same EVSE object."* → **connector IDs
  are only unique within their EVSE.** The primary key is (location, evse, connector).
- `max_voltage` is *"Maximum voltage of the connector (line to neutral for AC_3_PHASE),
  in volt [V]."* → for three-phase this is **phase-to-neutral** (230 V in Rwanda, not
  400 V). Getting this wrong triples any computed kW.

**Licence caveat.** OCPI is published under **CC BY-ND 4.0**, not BY or BY-SA
([copyright.asciidoc](https://github.com/ocpi/ocpi/blob/v2.3.0/copyright.asciidoc)).
Copying the value *identifiers* into code is ordinary interoperation practice — every
OCPI client does it. Copying the spec's *description text* verbatim into user-facing UI
is reproducing the document, and ND forbids distributing modified versions. Write EV
Guide's own display labels; attribute the EVRoaming Foundation. Worth a lawyer's five
minutes if the app ever ships commercially — flagging, not clearing.

### 5.2 OpenChargeMap `ConnectionTypes`

The [OCM reference-data API](https://api.openchargemap.io/v3/referencedata/) is
hard key-gated (403 without a registered key; `?key=test` returns *"Invalid API
key."*). The list below comes from
[map.openchargemap.io/assets/data/CoreReferenceData.json](https://map.openchargemap.io/assets/data/CoreReferenceData.json)
— the bundle OCM's own production web app ships, byte-identical to
[CoreReferenceData.json in ocm-app](https://github.com/openchargemap/ocm-app/blob/master/src/assets/data/CoreReferenceData.json)
(last commit 2023-08-24). **It is a 2023 snapshot, not a live read** — notably it has
no MCS entry. IDs are stable; verify against the live API before freezing anything.

42 entries, `ID | Title | FormalName`:

```
   0 | Unknown                                         | Not Specified
   1 | Type 1 (J1772)                                  | SAE J1772-2009
   2 | CHAdeMO                                         | IEC 62196-3 Configuration AA
   3 | BS1363 3 Pin 13 Amp                             | BS1363 / Type G
   4 | Blue Commando (2P+E)                            | —
   5 | LP Inductive                                    | Large Paddle Inductive      [obsolete]
   6 | SP Inductive                                    | Small Paddle Inductive      [obsolete]
   7 | Avcon Connector                                 | Avcon SAE J1772-2001        [discontinued]
   8 | Tesla (Roadster)                                | Tesla Connector             [discontinued]
   9 | NEMA 5-20R                                      | —
  10 | NEMA 14-30                                      | —
  11 | NEMA 14-50                                      | —
  13 | Europlug 2-Pin (CEE 7/16)                       | Europlug 2-Pin (CEE 7/16)
  14 | NEMA 6-20                                       | —
  15 | NEMA 6-15                                       | —
  16 | CEE 3 Pin                                       | —
  17 | CEE 5 Pin                                       | —
  18 | CEE+ 7 Pin                                      | —
  21 | XLR Plug (4 pin)                                | —
  22 | NEMA 5-15R                                      | NEMA 5-15R
  23 | CEE 7/5                                         | —
  24 | Wireless Charging                               | —
  25 | Type 2 (Socket Only)                            | IEC 62196-2 Type 2
  26 | SCAME Type 3C (Schneider-Legrand)               | IEC 62196-2 Type 3
  27 | NACS / Tesla Supercharger                       | NACS
  28 | CEE 7/4 - Schuko - Type F                       | CEE 7/4
  29 | Type I (AS 3112)                                | Type I/AS 3112/CPCS-CCC
  30 | Tesla (Model S/X)                               | —
  31 | Tesla Battery Swap                              | Tesla Battery Swap Station
  32 | CCS (Type 1)                                    | IEC 62196-3 Configuration EE
  33 | CCS (Type 2)                                    | IEC 62196-3 Configuration FF
  34 | IEC 60309 3-pin                                 | IEC 60309 3-pin
  35 | IEC 60309 5-pin                                 | IEC 60309 5-pin
  36 | SCAME Type 3A (Low Power)                       | —
1036 | Type 2 (Tethered Connector)                     | IEC 62196-2
1037 | T13 - SEC1011 ( Swiss domestic 3-pin ) - Type J | T13/ IEC Type J
1038 | GB-T AC - GB/T 20234.2 (Socket)                 | GB-T AC - GB/T 20234.2 (Socket)
1039 | GB-T AC - GB/T 20234.2 (Tethered Cable)         | GB-T AC - GB/T 20234.2 (Tethered Cable)
1040 | GB-T DC - GB/T 20234.3                          | GB-T DC - GB/T 20234.3
1041 | Three Phase 5-Pin (AS/NZ 3123)                  | AS/NZS 3123 Three Phase
1042 | NEMA TT-30R                                     | —
1043 | Type M                                          | IEC Type M (SANS 164-1, IS 1293:2005)
```

Gotchas: IDs 12, 19, 20 do not exist (don't assume contiguity); ID 1036's Title has a
**trailing space**; `IsDiscontinued`/`IsObsolete` are `null` rather than `false` for
IDs 0–8. Tesla is spread across four overlapping IDs (8, 27, 30, 31) and OCM never
added a distinct `SAE J3400` row — it renamed 27 instead.

**OCM's model differs structurally from OCPI's**: OCM splits "connector shape"
(`ConnectionTypes`) and "AC vs DC" (`CurrentTypes`) into two reference lists, whereas
OCPI puts `power_type` on the connector itself. OCM therefore needs *two* fields to
say what OCPI says in one.

**Licence.** Per [openchargemap.org/about/terms](https://www.openchargemap.org/about/terms)
(updated 01/04/2022): user-contributed data is **CC BY 4.0**, but *"Data imported from
3rd party Data Providers is copyright the original Data Provider in each case and is
not provided under the same terms"*, and *"Use of our API or data in an application or
service requires that the appropriate Data Provider attribution (including license
terms) be provided in a way which is visible the end user."* → the *reference data*
(the list above) is freely reusable with attribution; the *POI data* is mixed-licence
**per location** and would require per-station attribution in the UI. Since EV Guide
enters stations manually (per `map.md`), only the reference list is relevant, and it is
safe to use.

### 5.3 OCPP connector modelling

**OCPP 1.6 has no connector-type concept at all.** I confirmed this against the OCA's
own *OCPP 1.6 Edition 2* PDF (obtained via the
[mobilityhouse/ocpp docs mirror](https://github.com/mobilityhouse/ocpp/blob/master/docs/v16/ocpp-1.6%20edition%202.pdf),
which carries the authentic OCA running headers; the OCA distributes behind a
registration wall at
[openchargealliance.org](https://openchargealliance.org/protocols/open-charge-point-protocol/)).
A case-insensitive search for `connectortype` / `ConnectorEnum` returns **zero hits**.
§4.2 "Connector numbering" defines connectors as bare sequential integers starting at
1, with `connectorId 0` reserved for the whole Charge Point.

**OCPP 2.0.1 `ConnectorEnumType`** (§3.22, *"Allowed values of ConnectorCode"*, used by
`ReserveNowRequest`) — 22 values:

```
cCCS1   cCCS2   cG105   cTesla   cType1   cType2
s309-1P-16A   s309-1P-32A   s309-3P-16A   s309-3P-32A
sBS1361   sCEE-7-7   sType2   sType3
Other1PhMax16A   Other1PhOver16A   Other3Ph
Pan   wInductive   wResonant   Undetermined   Unknown
```

Prefixes: `c` = captive cabled, `s` = socket, `w` = wireless. Two real spec quirks:
the value is `sBS1361` (BS 1361 is the *fuse* standard; the plug is BS 1363 — an OCA
error, but `sBS1361` is what goes on the wire), and `sType3`'s description wrongly says
"Type 2 socket a.k.a. Scame". **`cGBT` and `cChaoJi` are NOT in this enum** — they exist
only as extra permitted strings for the device-model *variable* `ConnectorType`. Popular
client libraries (e.g. `mobilityhouse/ocpp`'s `v201/enums.py`) publish 25 values by
folding those in; that is a superset the 2.0.1 wire protocol will not accept.

**OCPP 2.1 renamed it `ConnectorEnumStringType`** and, verbatim from the Appendices
(v2.0, 2025-01-23): *"Before OCPP 2.1 this used to be an enumeration. This has been
changed to a predefined set of strings for more flexibility."* 31 values — the 2.0.1
list plus `cChaoJi`, `cGBT-DC`, `cLECCS`, `cMCS`, `cNACS`, `cNACS-CCS1`, `cCCS1-NACS`,
`cUltraChaoJi`, `sType1`. Note **`cGBT-DC`** (hyphenated, DC-only) rather than the bare
`cGBT` the 2.0.1 appendix allowed.

**Topology.** OCPI is Location → EVSE → Connector; OCPP 2.x is ChargingStation → EVSE →
Connector. They look the same and are not: OCPI's top tier is a **place** (address,
coordinates, opening hours), OCPP's is a **communicating device** (one modem, one
WebSocket). OCPP 2.0.1 Part 1 §2 notes explicitly that *"a charging plaza with 20 EVSEs
and Connectors which communicates via 1 modem as 1 Charging Station to the CSMS is seen
by OCPP as 1 Charging Station."* One OCPI Location routinely spans several OCPP Charging
Stations, and vice versa. Only the EVSE tier lines up.

### 5.4 The Rwanda-specific reason this matters

**Kabisa — Rwanda's largest car-charging network — states on its own site that it runs
OCPP 1.6** ([kabisa.africa](https://www.kabisa.africa/)). Per §5.3, OCPP 1.6 *cannot
report a connector type*. So even in a hypothetical future where EV Guide integrates
live with Rwanda's biggest operator, connector data would come from Kabisa's internal
inventory, never from the charger.

That closes the question the ticket is really asking. **Connector type in EV Guide is
operator-asserted reference data, entered by hand and versioned by the admin — not
something the network can ever tell us.** Which is exactly the manual-entry model
`map.md` already assumes, and it means the enum has to be *editable by humans under
pressure*: short, unambiguous, and forgiving of the unknown.

Meanwhile Rwanda's own master plan tells operators to
[*"Mandate the use of the Open Charge Point Interface (OCPI)"*](https://www.mininfra.gov.rw/fileadmin/user_upload/Mininfra/Publications/Policies/Transport/Final_Report_EVCI_Master_Plan.pdf).
Borrowing OCPI's vocabulary aligns EV Guide with the taxonomy Rwanda's own policy is
steering operators toward — the cheapest possible future-proofing.

---

## Recommended enum

**Adopt OCPI 2.3.0 `ConnectorType` spellings, ship a Rwanda subset, and treat it as an
open enum.** Rationale: it is the only one of the three candidates that is
place-oriented (like a directory), keeps AC/DC as an orthogonal axis rather than baking
it into the connector name, already contains both `GBT_AC` and `GBT_DC` as distinct
values, and is the standard Rwanda's own master plan tells operators to use.

### Tier 1 — ship, model fully, expect real rows

| Value | Means | Evidence in Rwanda |
|---|---|---|
| `IEC_62196_T2` | Type 2 AC (Mennekes) | 3 OSM nodes @ 11 & 22 kW; EVP filter; master plan wants it mandatory |
| `IEC_62196_T2_COMBO` | CCS2 DC | 1 OSM node @ 150 kW; both official recommendations; all DC installs |
| `GBT_AC` | GB/T 20234.2 AC | World Bank: Chinese-standard EVCI installed; master plan calls GB/T "predominant" |
| `GBT_DC` | GB/T 20234.3 DC | as above |

These four are exactly the dual-standard pair both government-commissioned studies
recommend, split across AC and DC. A station-edit form that offers only these four
would cover every Rwandan station whose connectors I could document.

### Tier 2 — ship in the enum, expect near-zero rows

Cheap to include now, expensive to retrofit into a live schema and a released app.

| Value | Means | Why include |
|---|---|---|
| `CHADEMO` | CHAdeMO DC | Named in RURA Reg 011/2026 Art 2(c); LHD European Leafs exist |
| `IEC_62196_T1` | Type 1 / J1772 AC | Named in RURA Art 2(c) and EVP's own filter |
| `IEC_62196_T1_COMBO` | CCS1 DC | Named in RURA Art 2(c) ("CCS I") |
| `SAE_J3400` | NACS | Named in RURA Art 2(c); OCPI 2.3.0 spelling |

### Tier 3 — the escape hatch, non-negotiable

| Value | Means |
|---|---|
| `UNKNOWN` *(EV Guide's own, not OCPI)* | Admin knows a bay exists but not its plug |
| open-enum passthrough | Any OCPI value not in tiers 1–2, stored as a raw string |

RURA's own definition ends *"and others which may be adopted from time to time"*, and
OCPI 2.3.0 is formally an **OpenEnum**. Both say the same thing: do not build a closed
enum that rejects on decode. `UNKNOWN` is not optional either — the admin will be
entering ~200 stations from photographs and phone calls, and a schema that forbids "I
don't know yet" will get lied to.

### Deliberately excluded

`CHAOJI`, `MCS`, `TESLA_R`, `TESLA_S`, all `PANTOGRAPH_*`, all `NEMA_*`, all
`IEC_60309_*`, all `DOMESTIC_*`, `IEC_62196_T3A`, `IEC_62196_T3C`. None has any Rwandan
presence, and the open-enum passthrough catches them if one appears. The domestic
sockets are the closest call — "granny cable" charging at guesthouses is real — but
`map.md` scopes EV Guide to *public charging stations*, where a wall socket is not a
listing. Revisit if the scope widens. (I could not establish Rwanda's domestic socket
type from a primary source; travel-adapter sites contradict each other on C/J versus
C/E/F/G, so I am not encoding a guess. RURA Reg 011/2026 Annex I does give the grid
envelope authoritatively: **230 V single-phase / 400 V three-phase, 50 Hz**.)

### Fields to carry alongside `standard`

Copy OCPI's decomposition rather than flattening it:

- **`format`** — `SOCKET` | `CABLE`. Whether the driver needs to bring a cable is a
  real, visible difference at a Rwandan Type 2 AC post.
- **`power_type`** — `AC_1_PHASE` | `AC_3_PHASE` | `DC`. (`AC_2_PHASE` and
  `AC_2_PHASE_SPLIT` exist in OCPI but have no plausible Rwandan use; include them or
  not, but do not invent alternatives.)
- **`max_electric_power`** in watts, free numeric. In-market values cluster at 7.4 /
  11 / 22 kW AC and 50 / 60 / 120 / 150 / 240 kW DC, with a **regulatory floor of 50 kW
  per DC gun** for any new public station. Do not enumerate power tiers — the floor
  moves and the ceiling is rising.
- If storing `max_voltage`, follow OCPI: for `AC_3_PHASE` it is **line-to-neutral**
  (230 V in Rwanda), not 400 V.

### One structural rule that falls out of the regulation

RURA Annex I requires public stations to *"support at least two most prevalent charging
technologies in the country"*. **A station must be able to hold multiple connectors of
different standards, and "free for me" must be evaluated per connector, not per
station.** A driver in a GB/T car looking at a Type 2 + CCS2 site should see it as
incompatible even if a bay is free. That is the single most important consequence of
this research for the availability model in ticket 09.

### Licensing note for whoever implements this

Copy OCPI's **identifiers**, write EV Guide's **own display labels**. OCPI is CC BY-ND
4.0, so reproducing its description text in the UI is reproducing the document. Credit
the EVRoaming Foundation somewhere in the app's acknowledgements. OCM's reference list
(if used for an ID cross-walk) is CC BY 4.0 and safe with attribution.

---

## Confidence and gaps

**High confidence**

- RURA Reg 011/2026 exists, is in force from 29/06/2026, enumerates six connector
  technologies in Article 2(c), requires ≥1 DC gun ≥50 kW and support for ≥2 prevalent
  technologies, and defers all connector specification to RSB. Read from the
  regulation's own PDF on rura.rw.
- Neither RSB nor RURA has issued an EV connector standard. Stated in two independent
  government-commissioned reports (MININFRA/EU Oct 2024; World Bank Jun 2025) and
  consistent with the RSB catalogue.
- Both official studies recommend a dual standard; they differ only in whether the
  European half is written "Type 2 (+ CCS for DC)" or "CCS2".
- Type 2 AC and CCS2 DC are physically installed in Rwanda.
- Rwanda permits only left-hand-drive passenger-car imports, which closes the used-JDM
  channel.
- The OCPI / OCM / OCPP enum values quoted in §5 are verbatim from the specs (OCPI from
  the ocpi/ocpi repo; OCM from the bundle OCM's production app serves; OCPP from the
  OCA PDFs via the mobilityhouse mirror, whose running headers confirm provenance).
- Kabisa's own site states OCPP 1.6, and OCPP 1.6 has no connector-type field.

**Medium confidence**

- **GB/T is physically installed in Rwanda.** The World Bank states it plainly and the
  master plan calls it "predominant", but **I could not name one Rwandan station with a
  GB/T gun**, and no operator publishes a GB/T connector. It is possible GB/T is
  concentrated in private fleet depots and buses rather than public car charging.
- The 2025–26 Chinese import wave being GB/T-ported. Strongly suggested by the use of
  China-domestic nameplates (Yuan Up, Tang L, Bao 5/8, Tai 3, Seagull) rather than
  export nameplates. **Not confirmed** — neither BYD Rwanda, CEVR nor Longtai publishes
  a charging-port spec for any model.
- Station counts. "71 car stations" (MININFRA, Apr 2026) versus "~200 in Kigali"
  (35 car / 165 moto) versus operator self-reports that sum differently. Probably a
  cars-versus-cars+motos definition mismatch, but I could not reconcile them.

**Low confidence / could not establish**

- **No proportional breakdown of Rwanda's EV fleet by connector exists.** MININFRA
  publishes aggregate import counts; nobody publishes registrations by make, model, or
  charging port. Any percentage split in the spec would be invented. The ticket asks
  for proportion; the honest answer is that the data does not exist.
- **The most valuable dataset for this project exists and is not published.** The EVCI
  Master Plan's *"Annex No. 2 Existing charging stations in Rwanda"* is described in
  the report as containing *"the station name, location, owner, latitude and longitude,
  the number of parking bays, power (kW), and connector type"* — exactly EV Guide's
  seed data. Every annex in the PDF is marked **"(Attached)"** and the attachments are
  not in the published file. **Recommendation: request the annexes directly from
  MININFRA's Energy Directorate / the EU Delegation.** That single email is worth more
  than any further desk research.
- **Whether CHAdeMO exists anywhere in Rwanda.** No positive evidence either way. It is
  in RURA's definitional list, which may be aspirational boilerplate.
- **The RSB catalogue is only partially enumerated.** The Electrical Engineering
  category has 128 entries and paginates 20 at a time; I saw the first page plus
  targeted search. RS ISO 5474-4:2025 (wireless power transfer) is the only EV standard
  I found. I cannot prove no IEC 62196/61851 adoption exists.
- **Rwanda's domestic socket type.** Consumer travel-adapter sites contradict each
  other (C/J versus C/E/F/G with Type G claimed as the EAC-harmonised standard). No
  primary source found. Not encoded above.
- **Live per-station connector data.** PlugShare (HTTP 401) and OpenChargeMap (HTTP 403)
  both key-gate their APIs; Chargemap paywalls Kigali (HTTP 402); Electromaps has zero
  Rwandan stations. **OpenStreetMap's 7 nodes are the entire open station-level record
  for Rwanda**, and only 4 carry connector tags. This independently reconfirms
  `map.md`'s finding that no open station dataset exists — and adds that the tiny
  amount which does exist is all Volkswagen/Siemens Type 2.
- **A direct contradiction I could not resolve.** EV24.africa (Mar 2026) claims *"All
  stations in Kigali use the Combined Charging System (CCS2)"*; the World Bank (Jun
  2025) and Automag (Feb 2025) both describe a fragmented GB/T-versus-European estate
  requiring adapters. I weight the World Bank highest and EV24 lowest, but the
  disagreement is real and the Tier-1 enum above is deliberately built to be right
  under either story.
- **OCM's reference list is a 2023 snapshot**, not a live API read (no MCS entry).
  Verify against the live API with a registered key before freezing any ID cross-walk.
