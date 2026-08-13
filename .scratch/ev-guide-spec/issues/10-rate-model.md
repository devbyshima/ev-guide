
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
