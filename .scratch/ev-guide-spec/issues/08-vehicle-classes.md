# 08 — Cars only, or e-motos and battery swap too?

Type: grilling
Status: open
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
