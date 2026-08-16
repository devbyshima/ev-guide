# EV Guide

Find EV charging stations in Rwanda: where they are, what they cost, what
connectors they have, and whether a bay is actually free right now.

A FullTime Studio product. Free, with no monetisation anywhere.

## Surfaces

| Surface | Audience | Platform |
| --- | --- | --- |
| Driver app | EV drivers | Expo (iOS + Android), plus CarPlay and Android Auto |
| Operator app | Station operators | Expo (iOS + Android) |
| Admin dashboard | Studio admin, station owners | Web |

Stations are entered manually by the admin: there is no open dataset for Rwanda
to import from. The admin creates station managers beneath it, in an
owner to operator hierarchy.

## Status

**The spec is locked and the build has started.** The `/wayfinder` map that
produced the spec is closed apart from the car cluster; the code below is the
implementation effort executing from it.

| | State |
| --- | --- |
| Spec + ADRs | **Locked**, except section 9 (car), which waits on the device test |
| `packages/domain`, `data`, `ui` | **Building.** 64 tests, typechecking |
| `apps/driver` | **Scaffolded** on Expo SDK 57, bundling against the workspace |
| `apps/operator`, `apps/admin` | Not started |
| CarPlay / Android Auto | In the spec, out of the first build |

## Repository layout

```
packages/domain    pure types + the availability derivation and display grammar
packages/data      repository protocols + the mock implementation and seed
packages/ui        design tokens (components land with the apps)
apps/driver        Expo SDK 57
```

```bash
pnpm install
pnpm -r test        # 64 tests
pnpm -r typecheck
```

**`packages/domain` has no platform imports**, so the same derivation runs on
the server, the phone, and (as transcriptions) the CarPlay and Android Auto
layers, against one shared fixture corpus. Availability is **derived, never
stored** ([ADR-0008](docs/adr/0008-availability-derived-bay-propagation.md)):
no table carries a state column, and a stale green is impossible by
construction.

Apps are built **frontend-first against the mock**
([ADR-0005](docs/adr/0005-backend-bweze-frontend-first.md)); the BWEZE
implementation arrives later behind the same protocols. Every station in the
seed is **fictional** and says so in the file.

## The documents

- **The spec: [`SPEC.md`](SPEC.md)**, locked for the phone and web surfaces.
  Its car-integration section is deliberately unwritten, pending the device
  test (ticket 27), the scoping call (24) and the platform filings (20).
- The decisions: [`docs/adr/`](docs/adr/) · the model:
  [`docs/domain-model.md`](docs/domain-model.md) · the availability grammar:
  [`docs/availability-display.md`](docs/availability-display.md)
- The map: [`.scratch/ev-guide-spec/map.md`](.scratch/ev-guide-spec/map.md) ·
  the tickets: [`.scratch/ev-guide-spec/issues/`](.scratch/ev-guide-spec/issues/)

The platform floor was a rule rather than a number until the build started, and
resolved once, on the day it started, in
[ADR-0011](docs/adr/0011-platform-floor-pinned.md): **Expo SDK 57, React Native
0.86.2, New Architecture on, SDK-default minimums.**

## Open

**[Ticket 37](.scratch/ev-guide-spec/issues/37-decay-window-gaps.md)** is the
one open item that affects shipped behaviour. Implementing the decay table
forced three policy constants the record never states, most importantly the
window on a **driver-reported `OutOfService`**, which currently suppresses a
connector for 30 days. Each lives in exactly one place in the code and is
marked as an assumption rather than passed off as a decision.

The car cluster (tickets 20, 22, 24, 27) is blocked on an in-car device test in
Rwanda, which is why `SPEC.md` section 9 is unwritten.

## Not in this repository

Two things are deliberately kept out and are not missing by accident:

- **Outbound correspondence.** Drafted letters are unsent, and unsent letters
  do not live in a public repository.
- **The operator research notes.** They characterise a third party's API
  surface in detail, and are withheld until that operator has been notified of
  what they describe. Every conclusion the spec depends on is restated in
  tickets 03 and 26 without the specifics.
