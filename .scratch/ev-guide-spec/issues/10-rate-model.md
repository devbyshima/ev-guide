
## Round 1 settled (2026-08-13) — interim, ticket not yet resolved

- **Rate attaches to the Connector, not the Station.** A station-level price is
  a lie at a mixed site, and the AC/DC mix is real (45 DC / 32 AC nationally).
- Unit **RWF per kWh**, with an optional session or connection fee. Every
  populated record observed was `pricePerKwh` at a uniform 600 RWF/kWh.
- Reuses ADR-0002's shape: `rate` + `rateConfirmedAt` + an `Unknown` case,
  decaying at **90 days** — prices move on a different timescale than bays.
- When unknown, say so rather than hiding the field: RURA Art. 27 requires the
  tariff be displayed at the facility, so the driver finds out on arrival.

Still open: **who may write it** (Round 2).

## Answer

**Rate is a property of the Connector, in RWF per kWh, written by Owners and
Admin only.**

- **Per connector, not per station.** A station-level price is a lie at a mixed
  site, and the AC/DC mix is real — 45 DC against 32 AC nationally. A 7 kW AC bay
  and a 120 kW DC bay at the same site do not cost the same.
- **RWF per kWh**, with an optional session or connection fee. Every populated
  record observed used `pricePerKwh`, uniformly 600 RWF/kWh.
- **Freshness reuses ADR-0002 wholesale**: `rate` + `rateConfirmedAt` + an
  `Unknown` case, decaying at **90 days**. Prices move on a different timescale
  than bays, so the decay constant differs while the shape does not.
- **Unknown is stated, not hidden.** RURA Art. 27 requires the tariff be
  displayed at the facility, so the driver finds out on arrival regardless —
  an empty field is less honest than "rate not confirmed".
- **Write permission: Owners and Admin only.** Operators write availability but
  not rates. The split is operational versus commercial: the person on site is
  best placed to say a bay is busy, while a price belongs to whoever sets
  prices, and a mistyped rate misleads every driver until someone notices.
  Operators may **flag** a rate as wrong without changing it.

No regulatory source exists to cross-check against — RURA requires no tariff
filing (03). The uniform 600 RWF/kWh remains market intelligence for sanity
checks, not an input.
