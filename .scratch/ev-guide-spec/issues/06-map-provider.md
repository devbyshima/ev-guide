# 06 — Which map provider?

Type: research
Status: closed (2026-08-13)
Blocked by: —

## Question

The map is the app's primary surface — the reference's home screen is a
full-bleed dark map — so this choice is load-bearing for both look and cost.

Compare Google Maps, Mapbox, and Apple Maps / MapLibre with OSM on: **map data
quality in Rwanda specifically** (road coverage, place names, freshness — this
is where providers diverge most and where European benchmarks mislead); dark
theming, and whether each can be styled to match the reference's near-black
treatment; custom marker support for the lime-outlined pins; clustering at ~200
stations; React Native and Expo support quality; offline or cached tiles;
pricing at realistic volumes for a free product with no revenue; and
attribution requirements (the reference shows a "Google" mark bottom-left).

Note that the reference screenshots are themselves Google Maps — matching them
1:1 may constrain this more than it first appears. Flag that tension explicitly.

## Context pointer

Findings in progress at `.scratch/ev-guide-spec/research/06-map-provider.md`.

## Answer

Full findings: [`research/06-map-provider.md`](../research/06-map-provider.md).

**Recommendation: MapLibre Native via `@maplibre/maplibre-react-native`,
rendering OSM vector tiles EV Guide hosts itself, custom near-black style,
clustered `SymbolLayer` pins, deep-link out for the drive.** Fallback if the
studio will not own a tile pipeline: Mapbox — genuinely reversible, since both
consume GL style JSON.

**Cost is not the constraint this ticket assumed.** Google mobile map loads are
**free and unlimited** (SKU `6DE1-4D9C-5B67`). At 5,000 MAU every option is $0.
The trap: adding a Map ID for cloud styling flips you to Dynamic Maps —
**$210/month** at that volume. Use `customMapStyle`, never `googleMapId`.

**Offline is what discriminates, and Google is excluded by contract.** ToS
§3.2.3(a) forbids pre-fetching, storing, resharing and bulk-downloading tiles;
there is also no SDK API for it. Measured alternative: **Kigali metro as an
offline vector basemap is 5.6 MB; all of Rwanda is 76 MB** — inside Cloudflare
R2's free tier.

**Rwanda data quality did not decide it.** Mapbox *is* OSM by its own
documentation, collapsing the field to Google vs Apple vs OSM. Geofabrik's
Rwanda extract yields 1,909 distinct KG/KN/KK street names and working OSRM
routing with correct named turns; Rwanda has the highest OSM edit density in
East Africa, 4.4× Uganda's. Two honest counterweights: the published
completeness estimate (Barrington-Leigh & Millard-Ball 2017) puts Rwanda at
**47%**, below Burundi and Kenya — stale 2016 data, but on the record; and
**Rebero and Remera do not exist in OSM as places at all**, two of the
neighbourhood labels visible in the reference screenshots. Fixable upstream in
an afternoon, which is itself an argument for OSM.

**Apple is disqualified twice** — no Android SDK, and Rwanda appears in only 2
of Apple's 21 `Maps:` feature sections.

**Conditional on ticket 16.** If offline tiles turn out not to be required,
Google becomes the strongest option and this must be revisited.

**Two open items, both founder calls, not implementer calls:**

- Google's ToS **§3.2.3(d)(iii) bars use "in a listings or directory service"**
  — and EV Guide's own one-line description is "a directory of EV charging
  stations in Rwanda". The clause probably targets reselling Google's *place*
  data, and EV Guide's stations are admin-entered, but the drafting is broad.
  Only binds if the founder overrides toward Google.
- **The "Google" wordmark bottom-left cannot be reproduced under any non-Google
  choice.** A strict 1:1 reading of the reference points at Google for exactly
  that one pixel. Routed to ticket 17.

## Constraint routed from 26 (2026-08-13)

The founder's no-external-runtime-dependency rule **hardens this ticket's
recommendation into the only consistent choice**: MapLibre with self-hosted OSM
vector tiles. Google Maps is precisely the third-party runtime service being
ruled out, so the two open items in the answer above — the ToS "directory
service" clause and the Google wordmark — are settled by the rule rather than
by argument. The wordmark 1:1 conflict still needs recording in 17 as a
knowing, founder-approved deviation from the reference.

## Conditional resolved (2026-08-13)

Ticket 16 made offline a first-class requirement (bundled Kigali basemap,
opt-in Rwanda pack — [ADR-0007](../../docs/adr/0007-offline-model.md)), which
is the case this ticket's recommendation was conditioned on. **MapLibre +
self-hosted OSM tiles stands unconditionally.** The two founder calls noted
here (Google directory-service clause; the "Google" wordmark in the
reference) are moot for provider choice but the wordmark question remains
routed to 17.
