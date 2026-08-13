# 06 — Which map provider should EV Guide use?

Research findings. Ticket: `.scratch/ev-guide-spec/issues/06-map-provider.md`.
Researched 2026-08-13. All prices in USD, current as published on the dates the
sources were fetched.

## The shape of the answer

"Map provider" is three separable decisions that this ticket has been treating
as one. Separating them is most of the work:

1. **Renderer** — the native SDK that draws tiles and markers on screen
   (Google Maps SDK, MapKit, Mapbox Maps SDK, MapLibre Native).
2. **Basemap data and tiles** — whose cartography, refreshed by whom, served
   from where (Google's, Apple's, Mapbox's OSM derivative, or OSM tiles EV
   Guide builds and hosts itself).
3. **Routing** — who computes the route, and whether EV Guide draws it or hands
   the driver to a navigation app.

Google and Apple fuse all three; you take the renderer, the data and the terms
as one bundle. Mapbox fuses 1 and 2 and lets you choose 3. MapLibre unbundles
all three — it is *only* a renderer, and supplies no tiles at all.

That unbundling is what makes the offline requirement (ticket 16) and the
free-forever constraint tractable, and it is the spine of the recommendation.

---

## 1. Map data quality in Rwanda

This is the axis where European benchmarks mislead, and it is the axis I
weighted most heavily. I ran my own measurements rather than relying on vendor
marketing.

### 1.1 The single most important fact: Mapbox *is* OSM

Mapbox's own data-sources documentation states plainly:

> "The foundation of Mapbox's map data comes from OpenStreetMap (OSM), a
> collaborative global mapping project where millions of volunteers contribute
> geographic information."

— <https://docs.mapbox.com/help/dive-deeper/mapbox-data-sources/>

So the four-way comparison collapses to a three-way one on data: **Google's
data**, **Apple's data**, and **OSM** (which is what both Mapbox and
MapLibre-with-OSM-tiles render). A finding about OSM in Rwanda is a finding
about Mapbox in Rwanda.

### 1.2 OSM's Rwanda coverage, measured

**Raw data volume and growth.** Geofabrik publishes a Rwanda country extract
and keeps a dated archive, which gives a clean growth series
(<https://download.geofabrik.de/africa/rwanda.html>, sizes read from the
directory index on 2026-08-13):

| Snapshot | `rwanda-latest.osm.pbf` |
| --- | --- |
| 2017-01-01 | 6.2 MB |
| 2019-01-01 | 13.5 MB |
| 2021-01-01 | 29.3 MB |
| 2023-01-01 | 38.4 MB |
| 2025-01-01 | 53.5 MB |
| 2026-01-01 | 60.1 MB |
| 2026-08-12 | 66.4 MB |

A **10.7× increase in nine and a half years**, still growing ~0.5 MB/month, and
the extract is rebuilt daily (66,344,205 bytes on 11 Aug → 66,359,632 bytes on
12 Aug — Rwanda is edited every day).

**Density against its neighbours.** Extract size is a proxy for object count, so
normalising by land area gives a rough completeness signal. Sizes fetched from
`download.geofabrik.de/africa/` on 2026-08-13:

| Country | Extract | kB of OSM data per km² |
| --- | --- | --- |
| **Rwanda** | 66.4 MB | **2.52** |
| Burundi | 46.2 MB | 1.66 |
| Uganda | 370.7 MB | 1.54 |
| Malawi | 154.5 MB | 1.30 |
| Togo | 62.2 MB | 1.10 |
| Tanzania | 705.5 MB | 0.74 |
| Kenya | 349.1 MB | 0.60 |
| Ghana | 115.2 MB | 0.48 |
| Benin | 48.1 MB | 0.42 |
| Zambia | 251.6 MB | 0.33 |
| Ethiopia | 139.2 MB | 0.13 |

Rwanda is the densest in the sample, 52% ahead of Burundi — its near-twin in
area (27,834 km² vs 26,338 km²) and population density. **This is a proxy for
object count, not a completeness measure**, and it is inflated by Rwanda's
1.39 million mapped building footprints. §1.3 gives the published completeness
figure, which points the other way; both are in the record because neither
alone is honest.

**Does OSM have the exact labels the reference design shows?** This is the
concrete acceptance test, so I tested it directly rather than arguing about it.
I downloaded Geofabrik's Rwanda Shortbread vector-tile package
(`rwanda-shortbread-1.0.mbtiles`, 83,812,352 bytes, ODbL, authored
"OpenStreetMap contributors, Geofabrik GmbH", from
<https://download.geofabrik.de/africa/rwanda.html>) and searched the actual
tiles that would ship in the app.

Present as named places at **zoom 12**: Kimihurura · Kacyiru · Gasabo ·
Kicukiro · Nyarugenge · Nyamirambo · Kimironko · Gisozi · Kanombe · Gitega ·
Kagarama · Kibagabaga · Kigali. Appearing by **zoom 13–14**: Nyarutarama ·
Niboye · Kiyovu · Gacuriro · Rugando.

So **four of the five labels the ticket names — Kimihurura, Kacyiru, Gasabo,
Kicukiro — render from OSM with no vendor involved.**

**But two do not, and this is a real finding rather than a rounding error.**
Cross-checked against Overpass over the City of Kigali relation (1708283):

- **Rebero** — no place feature of any kind exists. The only objects containing
  the string are *Rebero Genocide Memorial* (way 617191747), *CanalOlympia
  Rebero* (way 910517229) and two clinics. Nominatim for "Rebero, Kigali"
  returns a cinema.
- **Remera** — no Kigali place feature either, despite being one of Kigali's
  best-known neighbourhoods. Overpass over Kigali finds exactly two objects
  named "Remera": a fuel station and a residential building. Nominatim's
  "Remera" relations are in Musanze, Ngoma and Gatsibo — the wrong districts
  entirely. My own tile scan found only *Remera Bus Station*, a POI, which is
  why Remera is absent from the zoom-12 list above.

The tiles do carry Kinyarwanda strings (`Kumurenge wa Gisozi`, `Kumurenge wa
Kicukiro` — "in the sector of…"), which matters for the localisation item in the
map's "Not yet specified" list.

Tagging is also inconsistent in ways a zoom-dependent label rule will trip on:
Kimihurura is simultaneously a `place=neighbourhood` node and a `place=city`
way; Kicukiro the *sector* is tagged `place=village`; Gasabo the *district* is
tagged `place=town`.

Rwanda's administrative hierarchy is Province → District → Sector → Cell →
Village. Note that the reference mixes levels: **Gasabo, Kicukiro and
Nyarugenge are the three districts of Kigali**, whereas **Kimihurura, Kacyiru
and Remera are sectors** inside them. OSM carries both, which is why both
appear.

**Street names.** Rwanda has no conventional street addresses; Kigali instead
uses a coded street grid — `KG`/`KN`/`KK` (Gasabo / Nyarugenge / Kicukiro) plus
a number plus Street/Avenue/Road, introduced by the City of Kigali's street
addressing programme
(<https://proceedings.esri.com/library/userconf/proc14/papers/665_131.pdf>).
**That grid is in OSM at scale.** Two independent measurements agree:

- My scan of all zoom-14 tiles in the Rwanda package: **1,909 distinct coded
  street names** (KK 831, KG 727, KN 351).
- Overpass over the City of Kigali relation: **3,404 named `highway` ways,
  1,948 unique names, of which 1,917 (97.6%) match `^(KG|KN|KK)\s?\d`.** Only
  ~31 unique non-coded street names exist in all of Kigali.

Nominatim resolves the coded form correctly — `KG 7 Avenue, Kigali, Rwanda` →
way 25796207, `KG 7 Avenue, Gasabo District, City of Kigali, Rwanda`. **Any
provider whose geocoder does not know the KG/KN/KK grid is unusable in Rwanda.**
The Shortbread schema's `street_labels` layer carries `name`, `name_en` and
`name_de` (<https://shortbread-tiles.org/schema/1.0/>), and the package contains
an `addresses` layer.

**Routing over that network works.** I routed against the public OSRM demo
server, which runs the stock car profile on raw OSM data — no vendor
enrichment:

- Kigali Convention Centre → Kigali International Airport: `code: Ok`,
  7,119 m / 800 s, 18 turn-by-turn steps, with named instructions —
  `KG 644 Street`, `KG 624 Street`, `KG 6 Avenue`, `KN 5 Road`, including
  correct roundabout enter/exit maneuvers.
- Kigali → Musanze: `code: Ok`, 93.8 km / 74 min.

(`https://router.project-osrm.org/route/v1/driving/...`, queried 2026-08-13.
The 74-minute figure is free-flow and optimistic — OSRM has no traffic model.)

### 1.3 Where OSM in Rwanda is thin — stated plainly

Three counter-findings a fair reading has to carry, and one datapoint that cuts
the other way:

**The one published completeness estimate puts Rwanda low, not high.**
Barrington-Leigh & Millard-Ball, *"The world's user-generated road map is more
than 80% complete"*, PLOS ONE 2017
(<https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0180698>;
per-country table at
<https://sprawl.research.mcgill.ca/publications/PLOS2017roads/figures_2017_update/countries-table.html>).
Rwanda's row: 32,000 km of OSM road, **fraction complete 0.47 (95% CI
0.45–0.50)**. Its neighbours: Tanzania 1.00, Burundi 0.99, Kenya 0.89, Uganda
0.70. **This directly contradicts "Rwanda is one of the best-mapped countries in
Africa" and it should be recorded as such.**

The mitigation is real but partial: that snapshot is ~2016 data, and Rwanda's
OSM road network has since grown from 32,000 km to **109,030 km** (HeiGIT
ohsomeNow, all-time) — 3.4×, matching the extract-size series in §1.2, which
shows Rwanda at 6.2 MB in 2017. **Nobody has published an updated per-country
figure**, so the honest position is that the only published number is stale and
the denominator has been substantially closed, not that Rwanda is now complete.

**Road attributes are sparse, which is a routing risk, not a rendering one.**
From HOT's own HDX export report for Rwanda, refreshed 2026-08-07
(<https://data.humdata.org/dataset/hotosm_rwa_roads>): 172,739 road features,
with `name` populated on **2.49%**, `oneway` on **0.73%**, `lanes` on **0.19%**.
Nearly half the "road" network is `path` (43,691) and `footway` (40,730). Only
**3,876 named highways exist nationwide, 88% of them inside Kigali** — outside
Kigali, roads are essentially unnamed. Buildings: 1,385,602 features, `name` on
**0.10%**. Address points: **3,282 nationwide.**

This matters for one decision and one only: **whether EV Guide computes its own
turn-by-turn.** A car router working from 0.73% one-way coverage will
occasionally send a driver the wrong way up a street. It does not matter for
drawing a map, and it does not matter if the drive is handed off (§8.2).

**Kigali's sector boundaries are almost entirely absent.** OSM has all 5
provinces and all 30 districts as `admin_level` relations, and 386 of 416
sectors — but the mapped sectors are overwhelmingly rural. Of the City of
Kigali's 35 sectors, essentially none exist as boundary relations; Kimihurura,
Kacyiru, Remera, Nyamirambo and the rest exist only as loose `place=*` nodes.
Any design that wanted to shade or clip by neighbourhood cannot, from OSM, in
Kigali.

**Finally, the datapoint that validates the product's premise:** OSM contains
exactly **7 `amenity=charging_station` objects in all of Rwanda** (4 Volkswagen,
1 KABISA, 1 Ampersand, 1 unnamed). The charting note that "there is no open
dataset to import" is confirmed from a second direction. EV Guide's ~200
stations will be its own data under every option here — and contributing them
back to OSM would be a cheap, reciprocal moat.

### 1.4 The Rwandan OSM community — why the gaps above are fixable

The ticket asked whether Rwanda's unusually active OSM community is real. **It
is, and it is the strongest single argument for an OSM-based choice**, because
it means the two missing labels in §1.2 are a pull request, not a vendor ticket.

Measured contribution volume, HeiGIT ohsomeNow stats
(<https://stats.now.ohsome.org/api/stats>), 2025-08-13 → 2026-08-13:

| Country | Contributors | Edits | **Edits per 1,000 km²** |
| --- | --- | --- | --- |
| **Rwanda** | 1,147 | 493,685 | **18,744** |
| Uganda | 1,995 | 1,034,152 | 4,290 |
| Kenya | 1,836 | 1,374,369 | 2,368 |
| Ghana | 1,211 | 559,075 | 2,344 |
| Burundi | 148 | 38,879 | 1,397 |
| Senegal | 596 | 112,849 | 574 |
| Tanzania | 1,042 | 300,148 | 317 |

**Rwanda's edit density is 4.4× Uganda's and 7.9× Kenya's**, and ~87
contributors per million people against Kenya's ~33 and Tanzania's ~16. Rwanda
gained 305,555 buildings and 4,726 km of road in the last twelve months alone.
Sustained, not a one-off: 2023 was the peak year, and 2026 is already at 1,023
contributors year-to-date.

The institutional backing behind that:

- **EcoMappers Rwanda**, the national OSM community, founded 2016, partnered
  with HOT and the Open Mapping Hub Eastern & Southern Africa
  (<https://eco-mappers.org/>); marked ten years in June 2025 with 200+ active
  volunteers.
- A **YouthMappers chapter at the University of Rwanda**
  (<https://wiki.openstreetmap.org/wiki/YouthMappers>).
- **State of the Map Rwanda 2024**, held 29–30 November 2024 at the University
  of Rwanda, Nyarugenge Campus
  (<https://wiki.openstreetmap.org/wiki/State_of_the_Map_Rwanda_2024>).
- **14 HOT Tasking Manager projects** in Rwanda, including sector-level work in
  Kacyiru by Rwanda YouthMappers.
- **TomTom is actively sponsoring Rwandan mapping.** Its 2025 Africa campaigns
  produced 18.13 million edits across 20 countries, Rwanda explicitly among them
  (<https://www.tomtom.com/newsroom/partner-stories/25-million-edits-in-90-days-osm-and-tomtom-mapping-africa/>).
  `#tomtom` is the second-most-common hashtag on recent Rwanda changesets.
- **Apple's own OSM data team lists Rwanda** among the countries it improves
  (<https://wiki.openstreetmap.org/wiki/Organised_Editing/Activities/Apple>) —
  which is a quiet admission about the provenance of Apple's Rwanda basemap.

Two caveats. There is **no HOT country page for Rwanda** (`hotosm.org/countries/rwanda/`
404s), and HOT's own *State of OpenStreetMap in Africa* survey does not rank
Rwanda at all (<https://www.hotosm.org/en/news/the-state-of-openstreetmap-in-africa/>)
— so the "most mapped in Africa" folklore has no institutional source behind it.
And contribution is concentrated: one contributor accounted for roughly half of
sampled daily changesets.

### 1.5 Google's Rwanda coverage

Google publishes a per-country feature matrix
(<https://developers.google.com/maps/coverage>). Rwanda's row (`RW`):

| Feature | Rwanda |
| --- | --- |
| Map Tiles 2D / 3D | ✅ 2D · ❌ 3D |
| Maps JavaScript 3D | ❌ |
| Geocoding | ✅ |
| Traffic Layer | ✅ |
| Driving Directions / Snap to Roads | ✅ |
| Biking Directions | ❌ |
| Walking Directions | ✅ |
| Speed Limits | ❌ |

Google's genuine Rwanda advantages over OSM are **live traffic** (Rwanda is a
"✅" in the Traffic Layer column; Mapbox says only that "the availability of
traffic varies by country" — <https://docs.mapbox.com/help/dive-deeper/directions/>)
and commercial POI density, which Google has invested in globally and OSM has
not.

There is a third, quieter Google advantage: **Street View has covered Kigali
since October 2022** — roughly 300,000 images, launched with Rwanda's Ministry
of ICT and Innovation, and extended in December 2023 to Huye, an area north of
Kigali and near the DRC border
(<https://www.newtimes.co.rw/article/1829/news/technology/google-street-view-comes-to-rwandas-streets>,
<https://virtualstreets.org/index.php/2023/12/15/n/>). For a charging app that
is genuinely useful — chargers sit behind a specific gate or in a specific hotel
forecourt, and a photo of the entrance is the difference between arriving and
circling. Nothing else has an equivalent in Rwanda: Apple has no Look Around
there (§1.6). Note, though, that Street View is billed under Dynamic Street View
(a Pro SKU, 5,000 free/month) and is a separate integration, not a property of
the basemap choice.

Otherwise, neither Google advantage is load-bearing. The product's POIs are *its
own* — stations are entered manually by the admin because no open dataset exists
(confirmed independently in §1.3: OSM has 7 charging stations in the entire
country). And traffic only affects ETA accuracy, which matters if and only if
ticket 13 decides EV Guide computes its own ETA rather than handing off.

**One Mapbox-specific gap belongs here.** Mapbox's *Data coverage and quality*
page (<https://docs.mapbox.com/help/dive-deeper/mapbox-data/>) carries a
per-country quality table for the Geocoding and Search APIs. **Rwanda does not
appear in it** — nor do Kenya, Uganda, Tanzania, Nigeria, Ghana, Egypt, Morocco
or Senegal. South Africa is the only African country listed. Mapbox notes that
"some data are available at a city level and do not appear in this list", so
absence is not a declared "unsupported" — but Mapbox declines to make any
coverage claim for Rwanda, where Google declares full geocoding quality. If EV
Guide ever needs a search box that resolves "KG 7 Avenue", do not assume Mapbox
Geocoding; Nominatim/Photon over OSM demonstrably handles it (§1.2) and costs
nothing.

### 1.6 Apple's Rwanda coverage

Apple publishes a per-country feature matrix with 21 separate `Maps:` sections
(<https://www.apple.com/ios/feature-availability/>). Rwanda appears in exactly
**two** of them. Counting the country list under each section, and comparing
against African neighbours to check this is Rwanda-specific rather than
continent-wide:

| Apple Maps feature | Countries listed | Rwanda | Kenya | South Africa | Nigeria |
| --- | --- | --- | --- | --- | --- |
| Maps: Standard | 228 | ✅ | ✅ | ✅ | ✅ |
| Maps: Satellite | — | ✅ | ✅ | ✅ | ✅ |
| Maps: Turn-by-Turn Navigation | 112 | ❌ | ❌ | ✅ | ❌ |
| Maps: Traffic | 111 | ❌ | ✅ | ✅ | ✅ |
| Maps: Look Around | 88 | ❌ | ❌ | ❌ | ❌ |
| Maps: Detailed City Experience | 36 | ❌ | ❌ | ❌ | ❌ |

**Apple Maps offers no turn-by-turn navigation and no traffic in Rwanda at
all** — while it does in South Africa, and offers traffic in Kenya and Nigeria.
So this is a Rwanda-specific hole, not a general African one. Apple gives you a
basemap and nothing else.

That is on top of the structural reason Apple cannot be *the* provider anyway:
**MapKit does not exist on Android.** It can only ever be the iOS half of a
split implementation, doubling the cost of the app's primary surface. Its
styling limits (§2.1) compound the same conclusion. Apple Maps remains useful to
EV Guide in exactly one role: as a **deep-link target** for iOS users who prefer
it (§8.2) — though given the absence of Rwandan turn-by-turn, Google Maps is the
better default handoff even on iOS.

### 1.7 Verdict on axis 1

**Apple is disqualified on data. Google and OSM both clear the bar, for
different reasons, and the gap between them is narrower than the ticket
feared.**

The honest summary of OSM in Rwanda is *not* "it's excellent". It is:

- **Strong exactly where EV Guide's map needs it** — a routable Kigali road
  network with correct geometry and turn restrictions, 97.6% of the official
  KG/KN/KK street grid, most of the neighbourhood labels the design shows, daily
  edits, and the highest contribution density in East Africa by 4×.
- **Thin exactly where EV Guide doesn't need it** — house numbers, building
  names, `oneway`/`lanes` attributes, named rural roads, Kigali sector
  boundaries. The only one of these that would bite is road attributes, and only
  if EV Guide routes in-app.
- **Missing two specific things it does need** — the *Rebero* and *Remera* place
  labels — which are fixable by anyone with an OSM account in an afternoon, and
  which no vendor could fix for you on any other platform.

Google is good in Rwanda and better on traffic, commercial POIs and Street View.
None of those three is consumed by EV Guide's map as specified.

So axis 1 does not decide the ticket. That frees it to be decided on licensing,
offline and cost — which is where the options actually diverge.

---

## 2. Dark theming — and the reference-design tension

### 2.1 What each can do

**Google.** JSON styling (`MapStyleOptions` on the native SDKs, `customMapStyle`
in `react-native-maps`) exposes a `color` styler taking an arbitrary
`#RRGGBB` — "an RGB hex string of format `#RRGGBB`… sets the color of the
feature" — across feature types `all`, `administrative` (incl.
`administrative.neighborhood`), `landscape`, `poi`, `road`, `transit`, `water`,
and element types `geometry` (fill/stroke) and `labels`
(icon/text/text.fill/text.stroke).
<https://developers.google.com/maps/documentation/android-sdk/style-reference>
So `#000000` land with lime-tinted roads is reachable. What you cannot restyle
is Google's label typography, label placement, road-hierarchy geometry, or the
Google wordmark.

**There is a cost trap here.** Google's cloud-based styling (the Map ID route,
exposed in `react-native-maps` as the `googleMapId` prop) is billed differently
from embedded JSON:

> "**Paid feature:** Features accessed by adding a map ID triggers a map load
> charged against the **Dynamic Maps SKU** for Android and iOS."

— <https://developers.google.com/maps/documentation/android-sdk/cloud-customization/overview>

Dynamic Maps is $7.00 per 1,000 loads after 10,000 free/month (§6). Embedded
JSON styling is on the free Maps SDK SKU. **For EV Guide, use `customMapStyle`,
never `googleMapId`** — the two are mutually exclusive anyway. Legacy *cloud*
styles were migrated out in March 2025
(<https://developers.google.com/maps/documentation/javascript/cbms-release-notes>);
embedded JSON styling for the mobile SDKs is not on
<https://developers.google.com/maps/deprecations>.

**Mapbox.** Total control. `styleURL="mapbox://styles/mapbox/dark-v11"`
(<https://docs.mapbox.com/map-styles/reference/dark/>) or a `styleJSON` you
author in Mapbox Studio or by hand. Note Mapbox now labels `dark-v11` a
*classic* style that is no longer actively maintained and steers new projects to
Mapbox Standard, which does dark via a `lightPreset` config (`dusk`/`night`)
rather than a separate style.

**MapLibre.** Total control, and the only option with **no vendor style at
all**: `mapStyle` takes a URL *or* an inline `StyleSpecification` object
conforming to <https://maplibre.org/maplibre-style-spec/>, which you can build
and mutate in JS. Protomaps ships five ready-made flavours — `light`, `dark`,
`white`, `grayscale`, **`black`** — and they are overridable per-property
(`{...namedFlavor("light"), buildings: "red"}`), under BSD + ODbL
(<https://docs.protomaps.com/basemaps/themes>). A `black` flavour with the lime
accent applied to the road casing is a few lines.

**Apple.** Effectively none. `MKStandardMapConfiguration` exposes exactly four
knobs — `elevationStyle`, `emphasisStyle` (`.default` / `.muted`),
`pointOfInterestFilter`, `showsTraffic`
(<https://developer.apple.com/documentation/mapkit/mkstandardmapconfiguration>).
There is no colour API. Apple staff have confirmed on the developer forums that
"full custom styling isn't currently supported"
(<https://developer.apple.com/forums/thread/112876>). Apple's dark map is
Apple's dark map: a desaturated navy-grey, not `#000000`, with no way to reach
the reference's palette. `expo-maps` and `react-native-maps` both expose only a
light/dark switch on iOS.

### 2.2 The tension the ticket asked me to flag

**The reference screenshots are Google Maps in a dark style.** Under the
studio's standing rule — reference designs implemented 1:1, no deliberate
deviations, impossibilities raised *before* alternatives are built — that is a
real constraint, and it deserves to be stated exactly rather than waved away.

Three things are true at once:

1. **The chrome is provider-independent.** Pins, bottom sheet, lime pill CTA,
   circular icon buttons, crosshair rule — all EV Guide's own React Native
   views drawn *over* the map. Nothing in the reference's UI layer is Google.
   These are 1:1 under every option.

2. **The basemap rendering is matchable, not identical.** A MapLibre or Mapbox
   style can reproduce the reference's *palette* exactly — arguably more exactly
   than Google's styler, because you control label fonts, halos, casing widths
   and layer order, which Google's JSON schema does not expose. What will not
   be pixel-identical is Google's specific label placement and road-hierarchy
   generalisation. A designer comparing screenshots side by side will see a
   different map that reads the same.

3. **One element cannot be reproduced under any non-Google choice: the "Google"
   wordmark bottom-left.** It is a vendor attribution mark. Reproducing it over
   a non-Google basemap would be trademark misuse, and both Google's terms
   (§7) and OSM's attribution guidelines forbid the arrangement from opposite
   directions.

So a strict, literal reading of "implement the reference 1:1" points at Google,
and it points there for exactly one pixel-level reason. **This is the decision's
only forced deviation and it needs the founder's explicit sign-off, not an
implementer's judgement call.** The question to put is narrow: *is the
bottom-left mark reading "© OpenStreetMap" instead of "Google" an acceptable
deviation from the reference?* If yes, the rest of this document applies. If no,
Google is the answer and §5 becomes a hard product limitation to accept.

---

## 3. Custom markers and clustering at ~200 stations

The reference pin is a teardrop, light fill, lime outline, black glyph inside —
i.e. a **static image**, identical for every station bar the glyph. That is the
easy case for every renderer *if* it is rendered as an image, and the hard case
if it is rendered as a React view tree.

**`react-native-maps` — the weak spot.** Custom markers are React children, and
the library warns about it in three places. README: *"Note: This has performance
implications, if you wish for a simpler solution go with a custom image (save
your self the headache)."* `docs/marker.md`: *"Displaying a large number of
custom markers can have a negative performance impact when tracking changes to
the marker content… consider disabling the `tracksViewChanges` option"* — which
defaults to `true`. Issue #4968 quantifies it: *"FPS drop from 120 down to 10 by
the time you get to about 16 markers."*
(<https://github.com/react-native-maps/react-native-maps/blob/master/docs/marker.md>,
<https://github.com/react-native-maps/react-native-maps/issues/4968>)

Worse, marker rendering under the New Architecture is currently unstable. Open
issues as of this week include #5971 (2026-08-07, "Custom `<Marker>` children
are invisible on iOS with the New Architecture"), #5973 (2026-08-11,
"[iOS][Google Maps][Fabric] Markers never render on RN 0.86"), #5964, #5953,
#5909. iOS Fabric marker support landed only six weeks ago
(`feat(ios): ios fabric support (GoogleMaps Marker, Polygon) (#5944)`,
2026-06-28) and the reports are its aftermath.
<https://github.com/react-native-maps/react-native-maps/issues?q=is%3Aissue+is%3Aopen+fabric>

There is **no built-in clustering**. The de-facto library
`react-native-map-clustering` has 748 stars, **82 open issues**, last commit
2025-07-23, and renders each cluster bubble as exactly the custom-children
pattern that is broken under Fabric today
(<https://github.com/tomekvenits/react-native-map-clustering>).
`react-native-maps-super-cluster` is dead (last publish 2019-08-09).

**Mapbox and MapLibre — the strong case.** Both expose the same three-tier
model, documented with an explicit performance hierarchy:

| | SymbolLayer | PointAnnotation | MarkerView / ViewAnnotation |
| --- | --- | --- | --- |
| Image markers | ✅ | | |
| RN views as children | iOS: static | static (rasterised) | interactive |
| **Clustering** | **✅** | ❌ | ❌ |
| Style expressions | ✅ | | ✅ / ❌ |

(<https://github.com/rnmapbox/maps/blob/main/docs/Annotations.md>,
<https://github.com/maplibre/maplibre-react-native/blob/main/docs/content/guides/annotations.md>)

Mapbox's own guidance: *"Mapbox suggests using this component for a maximum of
around 100 views displayed at one time"* for `MarkerView`
(<https://github.com/rnmapbox/maps/blob/main/docs/MarkerView.md>). So 200
*view* markers exceeds Mapbox's guidance — but 200 *SymbolLayer* points fed from
a clustered `ShapeSource`/`GeoJSONSource` is trivial, because both the
clustering and the rendering happen in the native GL renderer, not in JS.

**`expo-maps` — cannot do it.** Markers take an icon loaded via `useImage`; you
cannot pass React children. And clustering is absent entirely — I had the
library agent grep all four of its type files (`shared.types.ts`, `index.ts`,
`apple/AppleMaps.types.ts`, `google/GoogleMaps.types.ts`) for `cluster`: **zero
hits**, and nothing in the docs.

**Is clustering even needed at 200?** Algorithmically, no —
supercluster's README advertises *"Clustering 6 million points in Leaflet"*
(<https://github.com/mapbox/supercluster>). It becomes a *performance*
necessity only on `react-native-maps` with view markers, where the cliff is
around sixteen. On Mapbox/MapLibre it is purely a visual-density choice —
which, at ~200 stations mostly concentrated in Kigali, it probably is.

---

## 4. React Native and Expo support

EV Guide is on the New Architecture targeting latest iOS/Android, and ticket 05
already assumes a prebuild/bare workflow for CarPlay and Android Auto. So
"needs prebuild" costs nothing here — every option below except
`react-native-maps` requires it, and `react-native-maps` will require it anyway
for a Google-provider store build.

Hard numbers, GitHub REST API + npm registry, 2026-08-13:

| Package | Latest | Published | Downloads/mo | Stars | Open issues | Commits/52w |
| --- | --- | --- | --- | --- | --- | --- |
| `react-native-maps` | 1.29.0 | 2026-06-28 | 4,549,054 | 15,988 | 51 | 75 |
| `@rnmapbox/maps` | 10.3.5 | 2026-07-22 | 691,436 | 2,894 | 100 | 188 |
| `@maplibre/maplibre-react-native` | 11.3.6 | 2026-06-25 | 391,392 | 651 | **16** | 409 |
| `expo-maps` | 57.0.1 | 2026-07-15 | 434,968 | — | — | — |

**`react-native-maps`.** Apple Maps default on iOS, Google via
`provider={PROVIDER_GOOGLE}`. First-party Expo config plugin, requires
react-native-maps ≥ 1.22 and Expo SDK ≥ 53
(<https://github.com/react-native-maps/react-native-maps/blob/master/docs/installation.md>).
Uniquely, it still works in Expo Go — *"No additional setup is required when
testing your project using Expo Go"*
(<https://docs.expo.dev/versions/latest/sdk/map-view/>). Fabric is nominally
supported from 1.26.1 (RN ≥ 0.81.1) per the README compatibility table, but see
§3 for the state of that. Maintenance is thin: the README says only *"This
project is being maintained by a small group of people"*; no named maintainer or
funding could be found; zero commits in the six weeks before 2026-08-13.

**`expo-maps`.** Wraps Google Maps Compose on Android
(`maps-compose:6.10.0`) and SwiftUI MapKit on iOS
(`AppleMapsView.swift`, `AppleMapsViewiOS17.swift`, `AppleMapsViewiOS18.swift`).
**Apple Maps is the only iOS option — there is no Google provider on iOS.**
Still labelled alpha at 57.x: *"This library is currently in alpha and will
frequently experience breaking changes"*
(<https://docs.expo.dev/versions/latest/sdk/maps/>). It is being promoted to
stable for SDK 58 (expo/expo#47338, merged 2026-08-05), and the unversioned
docs already carry no warning. Also: *"Contributions are not encouraged at this
time."* No custom marker views, no clustering. **Rules itself out on §3
grounds regardless of its stability.**

**`@rnmapbox/maps`.** The most consistent human commit cadence. New Architecture
is **mandatory** — the podspec hard-fails on the old architecture as of 10.3.0
(2026-03-22). Expo config plugin exists and handles the Podfile hooks and the
Android maven repo
(<https://github.com/rnmapbox/maps/blob/main/plugin/install.md>). Two caveats:
the README's headline item is a red *"Call for additional maintainers"*
(<https://github.com/rnmapbox/maps/discussions/1551>), and nearly every
non-bot commit is by one person. One helpful correction to the folklore: the
secret `MAPBOX_DOWNLOADS_TOKEN` is **no longer required** — `android/install.md`
states *"mapbox lifted auth requirement from downloads so
MAPBOX_DOWNLOADS_TOKEN is no longer needed"*, the podspec marks
`$RNMapboxMapsDownloadToken` deprecated, and Mapbox's own Android install guide
now documents only the public `pk.` token. (No first-party Mapbox announcement
dating this change was found — verify on a real EAS build before relying on it.)

**`@maplibre/maplibre-react-native`.** Maintained by the MapLibre organisation
rather than an individual, and has the smallest backlog of the four by a wide
margin (16 open issues). v11 is a real rewrite: *"MapLibre React Native v11 is
the first release to only support the new architecture. As this required
significant changes to the implementation, the APIs were also improved and are
based upon MapLibre GL JS"*
(<https://github.com/maplibre/maplibre-react-native/blob/main/docs/content/setup/migrations/v11.md>).
Requirements are a hard gate: **React Native ≥ 0.80.0, Expo SDK ≥ 54, Android
API ≥ 23, new architecture only.** Expo config plugin exists
(`"plugins": ["@maplibre/maplibre-react-native"]`), adds `$MLRN.post_install` to
the Podfile, and takes typed props to pin native versions and pick
`nativeVariant: "opengl" | "vulkan"`. Not usable in Expo Go.

One regression versus `@rnmapbox/maps` worth knowing: `ViewAnnotation` children
are **static on Android** where rnmapbox's `MarkerView` is interactive on both.
Irrelevant if pins are `SymbolLayer` images, which they should be.

---

## 5. Offline and cached tiles

This is where the options genuinely diverge, and it is the axis most likely to
decide the ticket, because a driver low on charge on a metered connection is
the product's defining moment.

### 5.1 Google forbids it — the clause, verbatim

Google Maps Platform Terms of Service, **§3.2.3 Restrictions Against Misusing
the Services** (<https://cloud.google.com/maps-platform/terms>):

> **(a) No Scraping.** Customer will not export, extract, or otherwise scrape
> Google Maps Content for use outside the Services. For example, Customer will
> not: (i) pre-fetch, index, store, reshare, or rehost Google Maps Content
> outside the services; (ii) bulk download Google Maps tiles, Street View
> images, geocodes, directions, distance matrix results, roads information,
> places information, elevation values, and time zone details; (iii) copy and
> save business names, addresses, or user reviews; or (iv) use Google Maps
> Content with text-to-speech services.
>
> **(b) No Caching.** Customer will not cache Google Maps Content except as
> expressly permitted under the Maps Service Specific Terms.

The Maps Service Specific Terms permit essentially nothing relevant. Section
A.3, the only general caching allowance, is IDs only:

> **3. Google ID Caching.** Customer may cache the Google ID values from the
> Services that return such field and allow caching, in accordance with its
> Documentation. For example, Customer may cache (a) `place_id` from Places
> API, Directions API, Geolocation API and Routes API, (b) `pano_ID`, from
> Street View Static API, and (c) `video_ID` from Aerial View API.

— <https://cloud.google.com/maps-platform/terms/maps-service-terms>

The only other caching tables in those terms are Address Validation API fields,
capped at *"30 consecutive calendar days"*. Place IDs may be stored
indefinitely, confirmed in the SDK policies: *"the place ID… is exempt from the
caching restrictions. You can therefore store place ID values indefinitely."*
(<https://developers.google.com/maps/documentation/android-sdk/policies>)

There is also no technical route: the Maps SDK for Android and iOS expose no
offline download API. The consumer Google Maps app has offline maps; the SDK
does not.

**Two further Google clauses that bear on EV Guide specifically**, from the same
§3.2.3:

> **(d) No Re-Creating Google Products or Features.** … For example, Customer
> will not: … (iii) use the Google Maps Core Services **in a listings or
> directory service** or to create or augment an advertising product;

> **(e) No Use With Non-Google Maps.** To avoid quality issues and/or brand
> confusion, Customer will not use the Google Maps Core Services with or near a
> non-Google Map in a Customer Application. For example, Customer will not (i)
> display or use Places content on a non-Google Map…

EV Guide is, in its own words, "a directory of EV charging stations in Rwanda."
I could not find Google guidance clarifying (d)(iii), and the practice of
plotting your own locations on a Google map is universal and explicitly
supported by Google's own Locator Plus solution
(<https://developers.google.com/maps/solutions/store-locator/best-practices>),
which strongly suggests the clause targets *reselling Google's* place data as a
directory rather than *displaying your own* on Google's map. EV Guide's station
data is admin-entered and owes nothing to Places, which puts it on the safe side
of the likely reading. **But the clause as drafted is broad, EV Guide's own
one-line self-description matches its words, and that is a risk a free product
with no legal budget carries for free.** Flagging, not concluding — this is a
question for the founder, not for me.

Clause (e) matters architecturally: it forecloses the hybrid "Mapbox basemap +
Google Directions" design.

### 5.2 Mapbox permits it, with a ceiling

Two documented APIs in `@rnmapbox/maps`: `offlineManager.createPack({name,
styleURL, minZoom, maxZoom, bounds})`
(<https://github.com/rnmapbox/maps/blob/main/docs/OfflineManager.md>) and the
v11 `tileStore`
(<https://github.com/rnmapbox/maps/blob/main/docs/tileStore.md>).

The documented ceiling, from Mapbox's own offline guide
(<https://docs.mapbox.com/ios/maps/guides/offline/>):

> **Tile pack limit:** The cumulative number of unique tile packs cannot exceed
> 750.

Tile packs are bucketed by zoom band (0–5 global, 6–10 regional, 11–14 local,
15–16 street detail), so 750 packs is a generous but real ceiling for a
country-scale download. Mapbox also prohibits redistribution: *"Terms of service
do not allow developers or end users to redistribute offline maps downloaded
from Mapbox servers"* — meaning you can download to a device but cannot ship a
prebuilt Mapbox tile bundle inside the app binary.

### 5.3 OSM's own tile server forbids it — read this before assuming "OSM is free"

The OSM Foundation's tile usage policy is unambiguous
(<https://operations.osmfoundation.org/policies/tiles/>):

> **4. Prohibited: bulk downloading ("scraping") and offline use**
> Bulk downloading is any pre-emptive fetching of tiles other than those a user
> is actively viewing… **Offline use is not permitted on
> tile.openstreetmap.org.** Features such as "Download city/country for offline
> use" or "Save area for later" rely on prefetch/bulk downloading and are
> therefore prohibited.
>
> Note: If you require offline maps, use self-hosted tiles or a provider that
> explicitly allows offline/prefetching. Vector tiles are often more suitable
> for this use-case.

`tile.openstreetmap.org` is not a production tile source for any app, offline or
not. "Use OSM" means "use OSM *data*", not "use OSMF's servers".

### 5.4 Self-hosted OSM tiles — measured, not estimated

This is the option that dominates on offline, and the numbers are small enough
to change the argument. From the Geofabrik Rwanda Shortbread package I
downloaded and queried directly:

| Extent | Zooms | Tiles | Size |
| --- | --- | --- | --- |
| **All of Rwanda** | z0–z14 | 10,505 | **76.4 MB** |
| All of Rwanda | z0–z13 | 2,755 | 18.6 MB |
| All of Rwanda | z0–z12 | 741 | 9.9 MB |
| **Kigali only** (29.98–30.22 E, −2.06 to −1.86 N) | z0–z14 | 165 | **5.6 MB** |
| Kigali only | z0–z13 | 45 | 1.1 MB |

**The entire Kigali metro as a full-detail offline vector basemap is 5.6 MB.**
That is smaller than a single app screenshot carousel. The whole country is
76 MB. Vector tiles restyle client-side, so one download serves both the
near-black theme and any future light theme.

Licence: ODbL, attribution "OpenStreetMap contributors, Geofabrik GmbH" (read
from the package's own `metadata` table). Protomaps publishes free daily planet
builds under the same terms with a `pmtiles extract` CLI for regional cuts
(<https://docs.protomaps.com/basemaps/downloads>).

MapLibre Native reads PMTiles archives natively on both platforms —
*"Starting MapLibre Android 11.7.0, PMTiles archives are supported as tile
sources. Prefix any tile source URL with `pmtiles://`… `pmtiles://file://` —
read a file from device storage"*
(<https://maplibre.org/maplibre-native/android/examples/data/PMTiles/>; iOS
support landed in the same core PR, maplibre-native#2882, with an ambient cache
for PMTiles sources added in iOS 6.27.0 / the matching Android release). Note
the docs' caveat: *"PMTiles sources do not support offline pack downloads or
caching"* — which is a non-issue when the archive *is* the offline artefact, but
means you manage the file yourself rather than through `OfflineManager`.

MapLibre RN also offers `OfflineManager.createPack()` with the same shape as
Mapbox's, plus two things Mapbox does not have: `mergeOfflineRegions(path)` to
sideload a prebuilt database shipped with the app, and
`setTileCountLimit(limit)` — *"Sets the maximum number of tiles that may be
downloaded and stored on the current device. Consult the Terms of Service for
your map tile host before changing this value."*
(<https://github.com/maplibre/maplibre-react-native/blob/main/docs/content/modules/offline-manager.md>)
**The limit is yours to set, because the tile host is you.**

**Hosting cost.** Cloudflare R2: $0.015/GB-month storage, $0.36 per million
Class B (read) operations, **free egress**, with a monthly free tier of 10
GB-month storage, 1M Class A and 10M Class B operations
(<https://developers.cloudflare.com/r2/pricing/>). A 76 MB archive and a few
million range reads a month sit inside the free tier.

### 5.5 Hosted OSM tile vendors, if self-hosting is refused

Both mainstream ones exclude EV Guide's likely posture on their free plans:

- **MapTiler Cloud** free: 5,000 map sessions/month, 100,000 API requests, but
  *"suitable for testing, personal or non-commercial use"* and the MapTiler logo
  is not removable. Flex is $30/month for 25,000 sessions.
  <https://www.maptiler.com/cloud/pricing/>
- **Stadia Maps** free: 200,000 credits/month, *"Commercial use not allowed."*
  Starter is $20/month for 1M credits. <https://stadiamaps.com/pricing/>

Whether a free, unmonetised app by a commercial studio counts as "commercial
use" is exactly the kind of ambiguity a no-revenue product should not be
carrying. Self-hosting removes the question.

---

## 6. Pricing at 5,000 monthly active users

### 6.1 The March 2025 Google change — it applies, and it helps here

Google replaced the $200 monthly credit with per-SKU free thresholds, effective
**1 March 2025**
(<https://developers.google.com/maps/billing-and-pricing/march-2025>):

> Google replaced "the USD $200 monthly recurring credit with a free monthly
> usage threshold for each Core Services SKU."

Free calls per SKU per month: **Essentials 10,000 · Pro 5,000 · Enterprise
1,000** (<https://mapsplatform.google.com/pricing/>). Free usage no longer pools
across APIs. Places API, Directions API and Distance Matrix API became Legacy,
and *"Effective March 1, 2025, you can no longer enable Legacy services"* — so a
new EV Guide project must use **Routes API** and **Places API (New)**, not the
classic ones.

### 6.2 The finding that reframes the cost question

**Google's mobile map loads are free and unlimited.** From the SKU table at
<https://developers.google.com/maps/billing-and-pricing/pricing>:

| SKU | SKU ID | Free usage cap | Cap–100k | 100k–500k | 500k–1M | 1M–5M | 5M+ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Maps SDK** | 6DE1-4D9C-5B67 | **Unlimited** | — | — | — | — | — |
| Dynamic Maps | FAF4-3B2D-51B2 | 10,000 | $7.00 | $5.60 | $4.20 | $2.10 | $0.53 |
| Static Maps | 3C2D-B525-2E5F | 10,000 | $2.00 | $1.60 | $1.20 | $0.60 | $0.15 |
| Routes: Compute Routes Essentials | 9EFF-679A-9B16 | 10,000 | $5.00 | $4.00 | $3.00 | $1.50 | $0.38 |
| Geocoding | BAC8-4E68-E261 | 10,000 | $5.00 | $4.00 | $3.00 | $1.50 | $0.38 |
| Directions *(Legacy)* | 28A8-3EB4-4595 | 10,000 | $5.00 | $4.00 | — | — | — |

Corroborated in the SDK docs: *"All mobile usage of the Maps SDK for Android is
unlimited"* (<https://developers.google.com/maps/documentation/android-sdk/usage-and-billing>)
and the same sentence for iOS
(<https://developers.google.com/maps/documentation/ios-sdk/usage-and-billing>).

So the intuition that motivated this ticket — *"the product is free, we can't
fund per-map-load pricing"* — **does not bite on Google's native mobile SDKs at
all**, provided you stay off the Map ID path (§2.1). It bites on the web admin
dashboard, which uses Dynamic Maps.

### 6.3 The model

Assumptions, stated so they can be argued with: 5,000 MAU; 8 app opens per user
per month; one map instantiation per open → **40,000 map loads/month**; 2
directions requests per user per month → **10,000 routing requests/month**; a
web admin dashboard used by ~5 admins at ~200 map loads/month → **1,000 web map
loads**. Zero geocoding (stations are admin-entered with coordinates).

| Provider | Mobile map | Routing | Web dashboard | **Monthly total** |
| --- | --- | --- | --- | --- |
| **Google** (JSON styling) | $0 — Maps SDK SKU unlimited | $0 — 10,000 ≤ free cap | $0 — 1,000 ≤ 10,000 free | **$0** |
| **Google** (Map ID / cloud styling) | 40,000 − 10,000 = 30,000 × $7/1k = **$210** | $0 | $0 | **$210** |
| **Mapbox** | $0 — 5,000 ≤ 25,000 free MAU | $0 — 10,000 ≤ 100,000 free | $0 — 1,000 ≤ 50,000 free | **$0** |
| **Apple** (iOS only) | $0 | $0 | MapKit JS free tier | **$0** |
| **MapLibre + self-hosted** | $0 renderer; tiles on R2 free tier | $0 (own OSRM/Valhalla) or deep-link | $0 | **~$0** |

Mapbox rates, from <https://www.mapbox.com/pricing>: Mobile Maps SDK **25,000
MAU free**, then $4.00/1,000 MAU (25,001–125,000), $3.20 (125,001–250,000),
$2.40 (250,001+). Mapbox GL JS **50,000 map loads free**, then $5.00/1,000.
Directions API **100,000 requests free**, then $2.00/1,000. MAU definition:
*"MAUs are users that accessed Mapbox services within your applications during a
given month"* (<https://docs.mapbox.com/accounts/guides/pricing/>). No separate
offline-download SKU is listed.

**Everything is $0 at 5,000 MAU.** Cost does not decide this ticket at the
stated volume. What differs is the **shape of the cliff**:

| Provider | Where the first dollar appears |
| --- | --- |
| Google (JSON styling) | Never, for mobile map loads. Routing above 10,000/mo at $5/1,000. |
| Mapbox | 25,001st MAU. At 50,000 MAU: 25,000 × $4/1k = **$100/mo**. At 125,000 MAU: **$400/mo**. |
| MapLibre self-hosted | Never in any meaningful sense — R2 free tier, then $0.36 per million reads. |

For a product that has ruled out monetisation *permanently and architecturally*,
"never" is a materially different property from "at 25,001 users". Rwanda's EV
fleet makes 25,000 MAU unlikely soon — but the studio would be choosing a
provider whose bill grows with the product's success and whose revenue never
does.

Finally, an operational note on Google: *"To use the Maps SDK for Android, you
must enable billing on each of your projects"* — a $0 bill still requires an
active Cloud billing account with a payment instrument attached.

---

## 7. Attribution requirements

| Provider | What is mandated |
| --- | --- |
| **Google** | ToS §3.2.2(b): *"Customer will display all attribution that (i) Google provides through the Services (including branding, logos, and copyright and trademark notices)… Customer will not modify, obscure, or delete such attribution."* Policies page: *"Never remove, hide, obscure, or modify it."* Logo height **min 16dp, max 19dp**; clear space **10dp left/right/top, 5dp bottom**; accessibility label "Google Maps". New implementations should use "Google Maps" rather than "Google". |
| **Mapbox** | *"we require the Mapbox logo to appear on our maps"* — movable between corners, but *"You may not style the Mapbox logo."* Plus text attribution with three links: **© Mapbox**, **© OpenStreetMap**, **Improve this map**. The SDKs ship an info button; if you replace it you must render those links yourself **and** *"provide a telemetry opt-out option elsewhere in your application"*. |
| **Apple** | The Apple Maps logo and legal link are drawn by `MKMapView` and are not removable. |
| **OSM / MapLibre** | ODbL. Attribution must be to "OpenStreetMap" and make the ODbL clear, typically by linking the word to `openstreetmap.org/copyright`. For interactive maps: *"the credit should typically appear in a corner of the map. While the lower right corner is traditional, any corner of the map is acceptable."* It may be collapsed on interaction, on dismiss, or **automatically after five seconds**, provided the licence remains findable (e.g. an "(i)" button or an About menu item). *"© OpenStreetMap contributors"* is explicitly acceptable. |

Sources: <https://cloud.google.com/maps-platform/terms> ·
<https://developers.google.com/maps/documentation/android-sdk/policies> ·
<https://docs.mapbox.com/help/dive-deeper/attribution/> ·
<https://osmfoundation.org/wiki/Licence/Attribution_Guidelines>

**Relevant to the 1:1 rule:** OSM's guideline is the *least* intrusive of the
four. It permits a corner credit that auto-collapses after five seconds and
allows the attribution to live behind an "(i)" affordance thereafter — closer to
the reference's clean full-bleed map than Google's permanently-visible 16–19dp
wordmark, or Mapbox's permanent logo plus three links plus a telemetry opt-out.

---

## 8. Directions and routing in Rwanda

### 8.1 Routing quality

- **Google.** Driving Directions and Snap to Roads: supported in Rwanda.
  Walking: supported. Biking and Speed Limits: not.
  <https://developers.google.com/maps/coverage>. Live traffic is available, which
  is a real ETA advantage in Kigali.
- **Mapbox.** *"The Mapbox Directions and Map Matching APIs are powered by the
  OSRM and Valhalla routing engines"* over OSM, and travel times come from *"the
  speed stored in the `maxspeed` tag in OpenStreetMap"*. The
  `mapbox/driving-traffic` profile *"is available globally, but the availability
  of traffic varies by country"* — Mapbox does not list Rwanda as covered, so
  expect typical/free-flow speeds, not observed ones.
  <https://docs.mapbox.com/help/dive-deeper/directions/>
- **OSM/open engines.** Empirically good in Rwanda, per §1.2 — correct
  geometry, correct named instructions, correct roundabout handling, plausible
  distances. Free-flow ETAs only. **The caveat from §1.3 lands here and nowhere
  else:** `oneway` is tagged on 0.73% of Rwandan roads and `lanes` on 0.19%, so
  an in-app router will eventually send a driver the wrong way up a one-way
  street. Google's data models one-ways; OSM's, in Rwanda, largely does not.
- **Apple.** Nothing. Rwanda is absent from *Maps: Turn-by-Turn Navigation* and
  *Maps: Traffic* (§1.6). Apple cannot route a Rwandan driver at all.

So Google wins on *ETA accuracy and one-way correctness in Kigali*; OSM-based
engines tie with it on geometry and instructions; Apple is not in the race.
**This is the single strongest argument for handing the drive off rather than
owning it** — and it is an argument about routing, not about the basemap.

### 8.2 Deep-linking out — the finding that defuses the whole axis

**Handing off to a navigation app costs nothing and is independent of the map
provider.** Google's Maps URLs:

> "Using Maps URLs, you can build a universal, cross-platform URL to launch
> Google Maps and perform searches, get directions and navigation, and display
> map views… The URL syntax is the same regardless of the platform in use.
> **You don't need a Google API key to use Maps URLs.**"

— <https://developers.google.com/maps/documentation/urls/get-started>

`https://www.google.com/maps/dir/?api=1&destination=…&travelmode=driving`
launches the Google Maps app on Android and iOS if installed and the web app
otherwise. Apple has the equivalent `maps://` / `maps.apple.com` scheme, and
Waze has its own. None require a key, an SDK, a billing account, or acceptance
of the Maps Platform terms — no-key URL launches are not "use of the Services".

This matters for ticket 13. **The recommendation put to the founder during
charting — preview in-app, hand off for the drive — is also the cheapest option
and the one that makes the map-provider decision independent of routing
quality.** If EV Guide never computes a route, Google's traffic advantage is
consumed by Google Maps at the moment of handoff, for free, on both platforms,
whatever renders EV Guide's own map. It also avoids the CarPlay navigation
entitlement problem flagged in ticket 04.

The one thing to note: clause 3.2.3(e) ("No Use With Non-Google Maps") governs
*Google Maps Core Services*, i.e. keyed API use. A keyless deep link that leaves
the app is a different act from displaying Google content on a non-Google map. I
am confident about the distinction in substance and flag it as legally
unadjudicated in §"Confidence and gaps".

---

## Comparison table

| | **Google Maps** | **Mapbox** | **Apple MapKit** | **MapLibre + OSM (self-hosted)** |
| --- | --- | --- | --- | --- |
| **Rwanda data** | Own data. 2D tiles, geocoding, traffic, driving + walking directions all ✅. Street View since 2022. Best commercial POIs. | OSM. 4 of 5 reference labels present (**Rebero, Remera missing**); 1,917 coded Kigali streets; 4× the region's edit density. Geocoding coverage **unlisted** by Mapbox. | ❌ **Basemap + satellite only.** No directions, no traffic, no Look Around in Rwanda. | Identical OSM data to Mapbox, and you can fix its gaps yourself. |
| **Near-black theming** | ✅ arbitrary hex via JSON styling — but only via the *free* `customMapStyle`, not `googleMapId`. | ✅ total control (`styleURL` / `styleJSON`). | ❌ four knobs, no colour API. | ✅ total control; Protomaps ships a `black` flavour, per-property overridable. |
| **Custom pins** | ⚠️ React-children markers; documented FPS cliff at ~16; open Fabric rendering bugs (Aug 2026). | ✅ `SymbolLayer` image pins; `MarkerView` guidance ≤100 views. | ❌ icon-only via `expo-maps`; RN path is `react-native-maps`. | ✅ same as Mapbox; `ViewAnnotation` static on Android. |
| **Clustering @200** | ❌ none built in; only lib is 13 months stale w/ 82 open issues. | ✅ native, in-renderer. | ❌ none. | ✅ native, in-renderer. |
| **RN / Expo** | `react-native-maps` 1.29.0 — 4.5M dl/mo, works in Expo Go, but thin maintenance + Fabric marker bugs. | `@rnmapbox/maps` 10.3.5 — healthy cadence, new-arch mandatory, config plugin, bus-factor 1. | `expo-maps` 57.0.1 — **alpha**, no custom markers, no clustering. | `@maplibre/maplibre-react-native` 11.3.6 — org-maintained, 16 open issues, needs **Expo SDK ≥ 54 / RN ≥ 0.80**. |
| **Offline** | ❌ **Contractually prohibited** (ToS 3.2.3 a/b) and no SDK API. Place IDs only. | ✅ offline packs; **750 tile-pack ceiling**; no redistribution of downloaded tiles. | ❌ | ✅ **Unrestricted.** Kigali z0–14 = **5.6 MB**; whole of Rwanda = **76 MB**. Ship it in the bundle. |
| **Cost @5,000 MAU** | **$0** (Maps SDK SKU unlimited) — or **$210/mo** if you use a Map ID. | **$0** (≤25,000 free MAU). | $0, iOS only. | **~$0** (R2 free tier). |
| **First dollar** | Never for mobile loads; routing >10k/mo. | MAU 25,001 → $100/mo at 50k MAU. | n/a | Effectively never. |
| **Attribution** | Google Maps logo, 16–19dp, never obscured. | Mapbox logo (unstylable) + 3 links + telemetry opt-out. | Apple logo + Legal link, not removable. | "© OpenStreetMap" in a corner; may auto-collapse after 5s. |
| **Cross-platform** | ✅ iOS + Android + web | ✅ iOS + Android + web | ❌ **iOS only** | ✅ iOS + Android + web |
| **Legal risk flags** | 3.2.3(d)(iii) "listings or **directory service**"; 3.2.3(e) no mixing with non-Google maps. | Mandatory telemetry unless you build an opt-out. | — | ODbL attribution; you own tile freshness. |

---

## Recommendation

**Use MapLibre Native via `@maplibre/maplibre-react-native`, rendering
OpenStreetMap vector tiles that EV Guide builds and hosts itself, with a custom
near-black style; render station pins as a clustered `SymbolLayer`; and
deep-link out to Google Maps or Apple Maps for the actual drive.**

Concretely: a Rwanda PMTiles archive cut from Protomaps' free daily planet
builds (or Geofabrik's Shortbread package), served from Cloudflare R2 via
`pmtiles://https://…`, with the Kigali extent — **5.6 MB** — downloaded on first
run and read via `pmtiles://file://` so the map works with no connection at all.
Regenerate monthly from a scheduled job.

The reasoning, in the order the evidence forced it:

1. **The Rwanda data worry resolves narrowly enough not to decide the ticket.**
   OSM gives Kigali a routable network with correct turn instructions, 97.6% of
   the official KG/KN/KK street grid, and four of the reference's five
   neighbourhood labels. It is thin on house numbers, road attributes and rural
   road names — none of which this app consumes if the drive is handed off. Two
   labels are genuinely missing (*Rebero*, *Remera*), and on an OSM basemap that
   is a defect the studio can fix itself, in an afternoon, permanently, for
   everyone — against the most active mapping community in East Africa. On
   Google or Apple the same defect would be a support ticket into a black box.
   The axis the ticket weighted highest turns out not to discriminate, which
   frees the decision to be made on the axes that do.

2. **Offline is the axis that discriminates, and Google is excluded on it by
   contract, not by engineering.** §3.2.3(a) and (b) are not ambiguous, and the
   Service Specific Terms permit only ID caching. A charging-station app whose
   map goes blank on a bad connection has failed at the moment it exists for.
   Ticket 16 has not yet decided how much must work offline — but choosing
   Google *decides it for us*, permanently, and in the worst direction.

3. **Nothing else costs money at this volume, so cost selects on shape, not
   level.** All four are $0 at 5,000 MAU. Only two are $0 at every volume, and
   only one of those works on Android. For a product where "no monetisation
   anywhere" is an architectural commitment rather than a launch decision,
   matching that with a map whose bill cannot grow is the coherent choice.

4. **The pins and clustering the design needs are the native case for a GL
   renderer and the broken case for `react-native-maps` right now.** A teardrop
   image pin in a clustered `SymbolLayer` is the happy path; the same pin as
   React children on `react-native-maps` under Fabric is, this month, an open
   bug list.

5. **Self-hosting is a smaller commitment than it sounds.** One 76 MB file, one
   scheduled regeneration, one R2 bucket inside the free tier. The studio
   already runs Cloudflare infrastructure. And it converts every recurring
   licensing question — commercial-use ambiguity on MapTiler and Stadia free
   plans, Mapbox's telemetry opt-out, Mapbox's 750-pack ceiling, Google's
   directory-service clause — into a question that simply does not arise.

**Fallback, if the studio decides it will not own a tile pipeline:** take
**Mapbox** (`@rnmapbox/maps`). Same OSM data, same style-spec lineage, same
marker and clustering model, offline built in, $0 at this volume, and a more
consistently maintained RN binding than MapLibre's. The migration cost between
MapLibre and Mapbox is genuinely small — both consume GL style JSON — so this is
a reversible choice, which is a reason to make it quickly. Its price is a
permanent MAU meter, a mandatory unstylable logo, and a telemetry opt-out you
must build.

### The strongest counter-argument to this recommendation

**The reference screenshots are Google Maps, the studio's standing rule is that
reference designs are implemented 1:1 with no deliberate deviations, and
Google's mobile SDK is free, unlimited, zero-ops and already matches the design
by construction.** Choosing MapLibre means:

- accepting the one deviation the reference cannot survive — the bottom-left
  mark stops saying "Google";
- accepting a basemap that *reads* the same but is not pixel-identical in label
  placement and road generalisation;
- and trading a solved, vendor-operated problem for a pipeline the studio must
  build, host and keep fresh — on a free product, at a studio already carrying
  BWEZE's infrastructure, where an unrefreshed tile archive silently rots into a
  stale map and nobody gets paged.

That is a serious argument and I do not think it is wrong on its own terms. It
loses only because of §5.1: Google's terms forbid the offline capability the
product's core scenario requires, and no amount of design fidelity compensates
for a map that cannot draw itself when the driver most needs it. **If ticket 16
resolves that offline map tiles are *not* required — that a cached station list
with no basemap is an acceptable degraded state — then this recommendation
should be revisited and Google becomes the strongest option.** That dependency
should be recorded explicitly rather than left implicit.

### What this ticket hands to other tickets

- **13 (directions):** deep-linking is free, keyless and provider-independent
  (§8.2). The charting recommendation — preview in-app, hand off for the drive —
  is confirmed as the cheapest and least entangling option; it removes Google's
  traffic advantage as a reason to pick Google, and it side-steps OSM's
  one-way-tagging gap, which is the only routing risk this research found.
- **16 (offline):** the numbers are now known. Kigali z0–14 = 5.6 MB, Rwanda =
  76 MB, hostable inside Cloudflare R2's free tier. Ticket 16's answer now
  determines whether this recommendation stands.
- **17 (design system):** the map pin must be authored as a **static image
  sprite**, not a React view tree, under every option worth choosing. Also: two
  of the reference's neighbourhood labels (*Rebero*, *Remera*) do not exist in
  OSM, so a screenshot comparison will differ until they are added upstream.
- **05 (Expo viability):** MapLibre RN v11 requires **Expo SDK ≥ 54 and RN ≥
  0.80**, new architecture only, prebuild mandatory. Consistent with 05's
  working assumption, but it is now a hard floor rather than a preference.
- **Data seeding** (map §"Not yet specified"): OSM contains **7** charging
  stations in all of Rwanda, so the ~200 stations are EV Guide's own data under
  every option. On an OSM basemap there is a cheap reciprocal move available —
  contribute them back as `amenity=charging_station`, which costs the studio
  nothing it has not already paid for and buys standing with the Rwandan mapping
  community whose data the app depends on.

Two small, cheap actions this research generates, neither of which needs a
ticket: add `place` nodes for **Rebero** and **Remera** to OSM, and spot-check
those same eight labels in the Google Maps and Apple Maps apps so the comparison
in §1.2 is symmetrical.

---

## Confidence and gaps

**High confidence**

- Google's caching prohibition and the absence of any permitted tile-caching
  carve-out. Quoted verbatim from two primary documents.
- Google's mobile map loads being free and unlimited, and the Map ID path being
  billable. Two independent primary sources each.
- Mapbox's pricing bands, MAU definition and 750-tile-pack ceiling.
- MapKit's inability to accept a custom colour palette. Its entire public
  configuration surface is four properties.
- All offline size figures in §5.4 and all Rwanda place-name and street-name
  findings in §1.2 — I downloaded the tile package and queried it directly
  rather than citing anyone, and the street-name count was independently
  reproduced via Overpass (1,909 vs 1,917 unique coded names).
- **Rebero and Remera being absent from OSM as places.** Confirmed three ways:
  my tile scan, an Overpass query over the City of Kigali relation, and
  Nominatim.
- **Apple's Rwanda feature gaps.** Parsed from Apple's own availability page,
  twice, independently. Rwanda appears under *Maps: Standard* and *Maps:
  Satellite* and no other Maps section.
- The library figures in §4 (versions, dates, download counts, open-issue
  counts) — pulled from the GitHub and npm APIs on 2026-08-13.

**Medium confidence**

- **The `react-native-maps` Fabric marker situation.** Multiple open issues from
  the past five weeks all describe the same failure, and the iOS Fabric marker
  commit is six weeks old — a consistent picture, but a fast-moving one. It may
  be fixed by the time anyone implements. Re-check before building on it.
- **Mapbox's removal of the secret download-token requirement.** Three rnmapbox
  sources plus Mapbox's credential-free install guide agree, but no first-party
  Mapbox announcement dating the change was found. Verify on a real EAS build.
- **Rwanda's OSM road completeness *today*.** The two measurements in §1.2 and
  §1.3 point in opposite directions and neither settles it. Extract size per km²
  is a proxy inflated by building footprints; the published 47% figure is ~2016
  data against a road network that has since tripled. The defensible claim is
  the narrow one in §1.7 — strong in Kigali, thin in attributes and rural naming
  — not a headline completeness percentage in either direction.
- **The concentration of Rwandan OSM contribution.** One contributor accounted
  for roughly half of the changesets sampled on several days in August 2026, and
  TomTom is the dominant sponsor. The community is real and measurably the
  region's most active, but it is not broad-based, and a sponsor's campaign
  ending would show up in the numbers.

**Gaps — things I could not settle**

- **Google's "listings or directory service" clause.** I could not find Google
  guidance interpreting §3.2.3(d)(iii), and the universal practice of plotting
  own-locations on Google maps (plus Google's own Locator Plus solution) points
  the other way. But EV Guide's self-description matches the clause's words. If
  the founder ever seriously considers Google, this warrants a direct question
  to Google rather than an inference from me.
- **Whether Google and Apple actually render the eight reference labels.** Both
  need an API key or interactive use, and neither publishes a gazetteer, so the
  §1.2 comparison is currently one-sided: I know precisely what OSM has and only
  infer the rest. A five-minute manual spot-check in both apps would close it,
  and should happen before the founder signs off — particularly for Rebero and
  Remera, where a Google screenshot showing them would sharpen the trade-off.
  Note that Apple's Rwanda basemap is likely OSM-derived (Apple's attribution
  credits OpenStreetMap and Apple's data team lists Rwanda as a country it
  edits), so Apple probably inherits the same two gaps.
- **POI density comparison.** OSM has 3,427 `amenity` nodes nationwide; I have
  no comparable Google Places or Apple figure, and neither publishes one.
- **The reference screenshots themselves are not in `refs/`** — ticket 01 is
  still open. Everything I say about the reference comes from
  `refs/design-observations.md`, including the claim that the map is Google in
  dark style with a "Google" mark bottom-left. If that observation is wrong, §2.2
  changes.
- **Whether a keyless Google Maps deep link is entirely outside the Maps
  Platform terms.** I believe it plainly is — no key, no SDK, no Service — but I
  found no clause that says so in as many words.
- **MapLibre RN's default `setTileCountLimit` value** is undocumented. Irrelevant
  under the PMTiles-file approach, which does not use offline packs.
- **`expo-maps`' iOS deployment target.** Three first-party sources give three
  answers: podspec says 16.4, unversioned docs say 17, README says 18.0. Moot
  given the recommendation, but noted in case `expo-maps` is reconsidered after
  it stabilises in SDK 58.
</content>
