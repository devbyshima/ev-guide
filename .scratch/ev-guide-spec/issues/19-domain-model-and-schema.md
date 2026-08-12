# 19 — Domain model and schema synthesis

Type: grilling
Status: open
Blocked by: 08, 09, 10, 11, 12

## Question

Bring every resolved decision together into one coherent domain model, and
finish `CONTEXT.md`.

Station, Bay, Connector, Rate, Driver and Admin are provisionally settled.
Availability, Report, Confidence, Staleness, Operator, Owner, Vehicle Class and
Session were deliberately left undefined so their tickets could define them
rather than have this one guess.

Produce: the complete glossary, with every term earning its place and no
synonyms left ambiguous; the entity model with cardinalities, including the
awkward ones — a bay's connector set, an operator spanning stations, a station
with no known availability at all; the schema, with the constraints that make
illegal states unrepresentable; and the write boundaries, since "who may write
this" was answered separately in 09, 10 and 11 and must now be consistent.

Explicitly leave room for the out-of-scope payment effort without building any
of it, and check the model against 18's car-template needs before locking.

Offer ADRs only where the domain-modeling bar is met: hard to reverse,
surprising without context, and the result of a real trade-off.
