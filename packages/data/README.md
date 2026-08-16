# @ev-guide/data

The repository protocols (ADR-0005's seam) and the **mock implementation**,
which ADR-0006 makes a first-class citizen rather than a stub: the apps are
built entirely against it, and the BWEZE implementation arrives later behind
the same interfaces without a screen changing.

- `protocols.ts` - the interfaces. Nothing above this line may know which
  implementation is installed.
- `seed.ts` - the dataset. **Every station is fictional.** It is shaped like
  Kigali but asserts nothing about a real charger, because ticket 26 ruled out
  depending on anyone's feed and ticket 28 puts real data behind a launch-week
  survey. `FICTIONAL` is exported so a build can assert it never ships.
- `mock.ts` - derives availability at read time, enforces the report policy,
  and ranks `stationsNear` distance-first.

The tests assert **protocol behaviour, not mock internals**, because they are
the behaviours the BWEZE implementation has to reproduce.

Two things the seed does deliberately: it leaves most connectors unreported
(~87% Unknown is the honest normal case, ticket 28), and it includes an
already-decayed report and an offline-source report so the boundary cases are
exercised by the default fixture rather than only by tests.
