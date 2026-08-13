# 13 — In-app turn-by-turn, or route preview then hand off?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 04, 06

## Question

The brief asks for directions "inside the app". That phrase spans two very
different products.

There is a hard constraint from 04 to weigh: CarPlay's **navigation**
entitlement is a materially harder ask than the **charging** entitlement, and
an app drawing its own turn-by-turn on the car screen needs it. Building own
navigation risks the CarPlay approval the product actually wants.

Settle: whether "inside the app" means an embedded map with route line,
distance and ETA — then handing off to Google Maps or Apple Maps for the drive
— or genuine in-app turn-by-turn; if handoff, which app and how the choice is
made or remembered; what the CarPlay and Android Auto experience is under each
option; and how much routing-quality risk the studio wants to own in a country
whose map data is thinner than Europe's.

The recommendation put to the founder during charting — preview in-app, hand
off for the drive — was not answered.

## Finding routed from 04 (2026-08-13)

**Apple Maps has neither Directions nor Turn-by-Turn Navigation in Rwanda** —
Rwanda appears only under Maps: Standard and Maps: Satellite on Apple's feature
availability page. An Apple Maps hand-off therefore **fails for the entire user
base**, on the phone as well as in the car. Google Maps is the only viable
hand-off target.

Google's Navigation SDK coverage table marks Rwanda as available with good data
quality for Driving Directions, Walking Directions, Traffic Layer and
Two-Wheeled Vehicle.

This collapses the "which app do we hand off to, and how is it chosen" half of
this ticket. What remains genuinely open is preview-vs-turn-by-turn, and 04
also weakens the constraint that motivated the recommendation: the hand-off is
a *documented* CarPlay pattern needing no maps entitlement.

Unverified and worth confirming on hardware before this is specified: whether
Google Maps is a guaranteed `ACTION_NAVIGATE` receiver on Android Auto, and
whether it can be launched onto the CarPlay screen via `comgooglemaps://`.
Both are strongly implied by the docs; neither is documented.

## Constraint routed from 12 (2026-08-13)

Directions now **require an account** (ADR-0003). Whatever this ticket decides
about preview-versus-handoff, the flow begins with a sign-in gate for anonymous
users — at the moment of highest intent, which converts well, but also when the
driver is in a hurry. Factor it into the interaction design rather than treating
auth as a separate concern.

## Resolution (2026-08-13)

**Preview in-app, hand off for the drive** — with the preview upgraded from the
charting recommendation: EV Guide computes its own routes.

1. **Hand-off for the drive.** EV Guide never draws turn-by-turn guidance in
   v1. The drive belongs to Google Maps — the only viable target, since Apple
   Maps has no directions in Rwanda at all (routed from 04). Turn-by-turn is a
   cleanly separable future effort: the engine below supplies maneuver data, so
   adding it later is UI work (voice, rerouting, driving UI, the harder CarPlay
   navigation entitlement), not infrastructure work.
2. **Self-hosted routing engine: Valhalla** (MPL-2.0), consuming the same OSM
   extract as the 06 tile pipeline. Founder direction: use mature open-source
   engines rather than building or omitting. Chosen over OSRM for two open
   doors at equal hosting cost: turn-by-turn maneuver narratives, and
   isochrones for a future "stations reachable on my charge" feature. The
   preview shows a route line on the MapLibre map, real driving distance, and
   ETA — all from studio-owned infrastructure, consistent with 26's rule.
3. **Hand-off mechanics: hard-coded Google Maps, no chooser in v1.** Deep-link
   by `lat,lng`, never by place name (station names are not in Google's index;
   coordinates always resolve). Not-installed falls back to the platform's
   universal-link behaviour (browser/store); no custom fallback UI.
4. **Sign-in gate (ADR-0003) at the directions tap: inline auth sheet,
   auto-resume.** The sheet overlays the screen the driver is on; Apple/Google
   one-tap is the fast path, magic link the slow one; on completion the
   hand-off fires without re-tapping. The driver never loses their station.
5. **Car screens: the phone hand-off is the guarantee.** Whether Google Maps
   can be launched onto the CarPlay/Android Auto display via URL scheme is
   undocumented — verification routed to 27; ticket 18 designs within the
   guarantee, treating a car-display launch as an unguaranteed enhancement.

Recorded as [ADR-0004](../../../docs/adr/0004-directions-preview-and-handoff.md).

**Knock-ons routed:** 14 now hosts Valhalla beside the tile server; 16 must
decide route-preview behaviour offline; 17 must place the route preview within
the existing reference screens (the reference has no route screen — no new
screen is to be invented without 17 deciding it); 27 gains the two hardware
verification items; the journey-planning fog patch graduates to ticket 29.
