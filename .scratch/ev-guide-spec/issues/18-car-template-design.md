# 18 — What does EV Guide look like on a car screen?

Type: prototype
Status: open
Blocked by: 04, 09, 13

## Question

Design the CarPlay and Android Auto experiences concretely enough that the
entitlement applications in 20 can show them and the data model in 19 can serve
them.

The reference designs are irrelevant here and must not be forced: car screens
are assembled from Apple's and Google's fixed template sets, and EV Guide's
visual identity barely appears. Establish what the driver can actually do —
almost certainly a nearby-stations list sorted by distance, a station detail
with rate, connectors and availability, and a directions hand-off consistent
with 13.

Settle: which templates each platform's charging category permits and which EV
Guide uses; how per-connector availability from 09 is expressed in a list row
with severe text limits; how "free for me" works when the car screen may not
know the driver's connector; what happens when availability is unknown or
stale, which will be common; the no-account case from 12; voice and safety
constraints on interaction while driving; and what data must be resident on the
device because the car screen cannot wait on a slow network.

Feed anything this forces back into 19 before the schema locks.
