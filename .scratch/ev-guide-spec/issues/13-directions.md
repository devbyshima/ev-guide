# 13 — In-app turn-by-turn, or route preview then hand off?

Type: grilling
Status: open
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
