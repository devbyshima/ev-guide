# 03 — Who operates Rwanda's stations, and can any of them be read programmatically?

Type: research
Status: resolved (2026-08-13)
Blocked by: —

## Question

Charting established the operators at headline level: EVP Charger (~95 e-moto,
~20 car), Kabisa (26 public points, 7 at SP fuel stations), Volkswagen Mobility
Solutions Rwanda with Siemens, ~200 public stations in Kigali by Feb 2026, and
EVP's own app shipped July 2026. That was one search. This ticket goes deep.

Establish, per operator: how many stations and bays, where, what connectors and
power, what they charge and in what units, and whether the hardware is
networked at all. Then the decisive question — **is there any programmatic
read**? OCPP backends, OCPI roaming endpoints, a public or partner API, a
scrapeable web map, or nothing. Note what EVP's app exposes about *its own*
station status, since that sets the bar users will compare against.

Also: is anyone else already aggregating across operators in Rwanda, and does
REG or the government publish a station registry?

This ticket is the difference between availability being *read* and availability
being *reported*. Answer accordingly — it unblocks 07, 08 and 10.

## Context pointer

Findings in progress at `.scratch/ev-guide-spec/research/03-operator-landscape-and-data-access.md`.

## Answer

Full findings, 32 sources: [`research/03-operator-landscape-and-data-access.md`](../research/03-operator-landscape-and-data-access.md).

**Verdict: READ — narrowly, and from an operator nobody expected.**

Kabisa Electric serves an **unauthenticated public GeoJSON feed** at
`https://api.gokabisa.com/api/client/chargers-geojson`. No key, no token. Kabisa's own web map consumes it, so
it is public by design — but it carries **no terms and no SLA**.

**Independently verified by the coordinator on 2026-08-13** (single GET, HTTP
200, 514 KB): 742 features globally, **77 inside Rwanda's bounding box**, across
owners `KABISA` (32), `External` (40) and **`EVP` (5)** — EVP's chargers carry
Citrine IDs inside Kabisa's CPMS, which is why a competitor's gun states are
readable at all. Properties include `availability`, `gunStatuses`, `gunsCount`,
`connectorTypes`, `pricePerKwh`, `onlineStatus`, `operationalStatus`,
`liveUpdatedAt`.

Availability is genuinely live: the agent polled two operators over 20 minutes
and saw movement in both directions.

**CPMS is CitrineOS** (`citrineos-core-fork-archive` on github.com/gokabisa);
hardware Winline/BYD/Ruisu on **OCPP 1.6**.

**The bounds, which matter more than the headline:**

- **67 of 77 report `{available: 0, total: 0}`** — that is *unknown*, not full.
  A naive renderer tells users 67 stations are occupied. Confirmed exactly by
  the coordinator's own count.
- Only **3** of the 10 with real numbers are `onlineStatus: ONLINE`. Worse,
  they disagree: `EV Plugin Kacyiru 120kw` reports **3/4 available while
  OFFLINE**. Reading `availability` without `onlineStatus` renders stale data
  as live.
- Freshness is per-record and mostly batched — only **9 distinct**
  `liveUpdatedAt` values across the 77; one record has read `IN_USE` since
  19 February 2026.
- **`pricePerKwh` is populated for 12 of 77, uniformly 600 RWF/kWh.** The
  research did not headline this; it is a real rate signal for ticket 10.
- **No CORS**, so a browser cannot read it but an Expo app can. Proxy through
  EV Guide's own backend regardless.

**Three corrections to the charting assumptions:**

1. **EVP's app does not exist.** The New Times piece (8 June 2026) is *future
   tense*. No listing on either store; EVP's own download buttons are
   `href="#"`. The real incumbent is **Kabisa Charge** — 5+ downloads, no iOS
   build, its own charging flows labelled "(simulated)".
2. **EVP's own API is a stub** — four rows, three test data, one at a car park
   in Pakistan.
3. **The market is bigger than three operators.** **Numa** runs 15 charge
   points including four 240 kW sites — second-largest in Rwanda — with zero
   web presence. Also Connex, PREV, MUJEBA.

**RURA regulation — pursued, and it is a confirmed absence.** Read in full: it
licenses per site, mandates **97% uptime**, requires **1-hour outage reports to
RURA**, fines unlicensed operation FRW 1,000,000. It contains *publish*,
*database*, *website*, *real-time*, *API*, *OCPP* and *OCPI* a combined **zero**
times. **No licence register** exists. **No rate filing** — Art. 27 requires
only that tariffs be displayed *at the facility*. Reporting flows in to RURA
and nothing flows out.

**Surfaced, now ticket 26:** whether EV Guide should build on that feed at all.
