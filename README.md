# EV Guide

Find EV charging stations in Rwanda: where they are, what they cost, what
connectors they have, and whether a bay is actually free right now.

A FullTime Studio product. Free, with no monetisation anywhere.

## Surfaces

| Surface | Audience | Platform |
| --- | --- | --- |
| Driver app | EV drivers | Flutter (iOS + Android), plus CarPlay and Android Auto |
| Operator app | Station operators | Flutter (iOS + Android) |
| Admin dashboard | Studio admin, station owners | Web |

Stations are entered manually by the admin: there is no open dataset for Rwanda
to import from. The admin creates station managers beneath it, in an
owner to operator hierarchy.

## Status

**The spec is locked and the build is under way, in Flutter.** The mobile apps
moved from Expo to Flutter on 2026-08-18
([ADR-0012](docs/adr/0012-flutter-migration.md), a founder decision taken with
the device-crash diagnosis in hand). The `/wayfinder` map that produced the
spec is closed apart from the car cluster.

| | State |
| --- | --- |
| Spec + ADRs | **Locked**, except section 9 (car), which waits on the device test |
| `packages/domain`, `data`, `ui` (TypeScript) | **Server reference + admin tokens.** 137 tests |
| `packages/corpus` | The shared fixture corpus as committed JSON |
| `packages/dart/domain`, `data`, `ui` | **The phone implementation.** 124 tests |
| `apps/driver_flutter` | First vertical slice; **verified on a physical iPhone** |
| `apps/operator`, `apps/admin` | Not started |
| CarPlay / Android Auto | In the spec, out of the first build; ticket 05 void under Flutter |

```bash
pnpm install && pnpm -r test        # the TypeScript reference: 137 tests
cd packages/dart/domain && dart test    # 68, of which 43 execute the corpus
cd packages/dart/data   && dart test    # 18
cd packages/dart/ui     && flutter test # 38
cd apps/driver_flutter  && flutter test
```

## One derivation, four executors

Availability is **derived, never stored**
([ADR-0008](docs/adr/0008-availability-derived-bay-propagation.md)): no table
carries a state column, and a stale green is impossible by construction. The
derivation and its display grammar run as four implementations: server
(TypeScript, `packages/domain`), phone (Dart, `packages/dart/domain`), and
later CarPlay (Swift) and Android Auto (Kotlin).

What keeps four transcriptions honest is
[`packages/corpus/corpus.json`](packages/corpus/corpus.json): the fixture
corpus of `docs/availability-display.md` section 3 as committed data. The
TypeScript suite executes it as the drift guard on the reference; every other
implementation executes the same file, so a transcription is proven
equivalent, not assumed.

Apps are built **frontend-first against the mock**
([ADR-0005](docs/adr/0005-backend-bweze-frontend-first.md)); the BWEZE
implementation arrives later behind the same protocols, in TypeScript, which
is why the TS packages remain the reference. Every station in the seed is
**fictional** and says so in the file.

## Repository layout

```
packages/domain      TypeScript reference: types + derivation + display grammar
packages/data        TypeScript reference: repository protocols + mock + seed
packages/ui          design tokens (also feeds the future admin SPA)
packages/corpus      the shared fixture corpus, as data
packages/dart/       the Dart ports the phone ships: domain, data, ui
apps/driver_flutter  the driver app (Flutter 3.47, iOS runner committed)
```

## The documents

- **The spec: [`SPEC.md`](SPEC.md)**, locked for the phone and web surfaces.
  Its car-integration section is deliberately unwritten, pending the device
  test (ticket 27), the scoping call (24) and the platform filings (20).
- The decisions: [`docs/adr/`](docs/adr/) · the model:
  [`docs/domain-model.md`](docs/domain-model.md) · the availability grammar:
  [`docs/availability-display.md`](docs/availability-display.md)
- The map: [`.scratch/ev-guide-spec/map.md`](.scratch/ev-guide-spec/map.md) ·
  the tickets: [`.scratch/ev-guide-spec/issues/`](.scratch/ev-guide-spec/issues/)

The platform floor is pinned by
[ADR-0012](docs/adr/0012-flutter-migration.md): **Flutter 3.47.0 stable, Dart
3.13.0**, resolved once on the day the migration started. (ADR-0011's Expo
floor is superseded; its lesson, take the version from the scaffold rather
than the registry, carried over.)

## Open

**[Ticket 37](.scratch/ev-guide-spec/issues/37-decay-window-gaps.md)** is the
one open item that affects shipped behaviour. Implementing the decay table
forced three policy constants the record never states, most importantly the
window on a **driver-reported `OutOfService`**, which currently suppresses a
connector for 30 days. Each lives in exactly one place per implementation and
is marked as an assumption rather than passed off as a decision.

The car cluster (tickets 20, 22, 24, 27) is blocked on an in-car device test
in Rwanda, which is why `SPEC.md` section 9 is unwritten. Under Flutter it
additionally needs the CarPlay/Android Auto viability research redone:
ticket 05's conclusion was Expo-specific and is void (ADR-0012).

## Not in this repository

Two things are deliberately kept out and are not missing by accident:

- **Outbound correspondence.** Drafted letters are unsent, and unsent letters
  do not live in a public repository.
- **The operator research notes.** They characterise a third party's API
  surface in detail, and are withheld until that operator has been notified of
  what they describe. Every conclusion the spec depends on is restated in
  tickets 03 and 26 without the specifics.
