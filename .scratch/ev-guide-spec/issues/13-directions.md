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
