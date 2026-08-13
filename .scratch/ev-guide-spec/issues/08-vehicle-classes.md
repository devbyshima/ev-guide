# 08 — Cars only, or e-motos and battery swap too?

Type: grilling
Status: closed (2026-08-13)
Blocked by: 02, 03

## Question

Rwanda's EV fleet is dominated by two-wheelers, and that's where the station
count is — EVP alone runs ~95 moto stations against ~20 for cars. But moto
energy is frequently **battery swap**, not charging, and a swap station has
*battery stock*, not occupied bays. Folding swap into a bay-availability model
would corrupt both concepts.

Meanwhile the product has already been committed to car drivers by taking on
CarPlay and Android Auto, which are car-cockpit surfaces with no moto analogue.

Settle: whether v1 covers cars only; whether stations carry a vehicle-class tag
from day one so motos can land later without a migration; whether battery swap
is a separate concept in the glossary or out of scope entirely; and what
happens to a mixed site that serves both.

Decide the term for this in `CONTEXT.md` — "Vehicle Class" is a placeholder.

## Finding routed from 02 (2026-08-13)

Fleet framing corrected: Rwanda's LHD-only import rule closes the used-JDM
channel, so the CHAdeMO/Leaf assumption does not hold here. The car fleet is
young — 1,555 BEVs in the nine months to March 2026 against 512 across
2020–2024 — and overwhelmingly Chinese-branded, which points at GB/T alongside
Type 2 and CCS2.

This sharpens rather than settles the moto question: EVP's ~95 e-moto stations
still dwarf the ~20 car sites, and RURA Regulation No 011/ENERGY/RURA/2026 is
the place to check whether two- and three-wheelers and battery swapping are
regulated as the same category as car charging. If the regulator treats them
separately, that is a strong argument for EV Guide doing the same.

## Finding routed from 04 follow-up (2026-08-13) — challenges this ticket's default

Primary data, MININFRA/EU EVCI Master Plan Table 11, sourced to RRA: in March
2024 Rwanda had **363 battery-electric cars** against **4,823 electric
motorcycles**. Motorcycles outnumber electric cars roughly **13:1**. The widely
cited "7,000+ EVs" headlines count hybrids and motorcycles together.

The charting recommendation was "cars only for v1". On this evidence that
recommendation builds for the smaller side of a 13:1 split, and the reason for
it — that CarPlay and Android Auto commit the product to car drivers — is itself
now in doubt (22, 24). **Escalate: this may be a destination-level question
about which surface EV Guide builds first, not a scoping detail.**

## Answer

**EV Guide serves car drivers. Moto riders and battery swap are out of scope.
Station carries a nullable vehicle-class tag from day one.**

Recorded as [ADR-0001](../../../docs/adr/0001-cars-only-swap-out-of-scope.md).

**Cars only (Q1).** Three independent reasons converge, and they outweigh the
13:1 fleet ratio that prompted the escalation:

- **The ratio is stale and closing.** It is a March 2024 figure. Car imports ran
  512 across 2020–2024 and then 1,555 in the nine months to March 2026 — the car
  side roughly quintupled, with no comparable moto growth figure available. The
  gap is materially narrower than 13:1 today.
- **The only live availability data in Rwanda is car-only.** Kabisa's feed
  carries 77 charge points and zero moto or swap records. EV Guide's core
  promise is undeliverable for riders — a rider-facing app would be a static
  list, which is exactly what the product is trying not to be.
- **Swap networks are closed loops.** An Ampersand rider swaps at Ampersand
  stations on an Ampersand subscription. There is no cross-network choice to
  inform, and informing choice among alternatives is the whole value of a
  directory. Car charging shows 18 brands in a single feed; moto energy has
  captive subscribers.

**Swap is out of scope, not deferred (Q2).** It does not fit the model: a swap
station holds **battery stock**, not occupied bays, so `Bay`, `Connector` and
per-connector availability are all meaningless for it. Carrying both concepts in
one schema would corrupt the one that works. Swap is a different domain that
happens to share a customer — if it is ever built it is a fresh effort with its
own premise, not this map widened.

**Vehicle class is a tag, not a dimension (Q3).** One nullable enum on Station.
It costs a column now against a migration later, and it lets the admin mark the
handful of mixed sites without inventing a concept mid-build. **Nothing branches
on it in v1.** Note that connector type already discriminates moto-adjacent
hardware well on its own, with GB/T at 62 of 77 points — the tag is insurance,
not a filter.

**Escalation closed.** This ticket carried a flag that it might be a
destination-level question about which surface ships first. It is not: cars only
confirms the existing framing, and the destination is unchanged.
