# Availability: derivation and display grammar

The single specification of how EV Guide turns Reports into words. Written by
ticket 18 (2026-08-13) after three adversarial review rounds found that the
CarPlay and Android Auto designs had independently specified *different*
functions for the same job.

**This document is owned by neither surface.** It lives in `packages/domain`
(ADR-0006) and is executed identically by the server (TypeScript), the phone
(TypeScript), the CarPlay layer (Swift) and the Android Auto layer (Kotlin).
Every screen on every surface cites this file; no surface declares its own
vocabulary or its own roll-up.

Companion to [docs/domain-model.md](domain-model.md), which owns the entities.

## 1. The derivation

### 1.1 One function, lensed or not

```
effective(connector, now)            -- ADR-0002: latest Report, decayed by source+state
                                     -- driver 2h · operator 6h · OutOfService 30d
                                     -- absent or decayed → Unknown
                                     -- a source declaring itself offline → Unknown immediately

bayStateUnder(bay, T?, now):         -- T = the driver's connector types; T = ∅ means unlensed
  s_T ← { effective(c, now) : c ∈ bay.connectors, T = ∅ or type(c) ∈ T }
  1. if s_T ⊆ {OutOfService}                → OutOfService   -- brokenness wins: go elsewhere
  2. if any c ∈ bay.connectors is Occupied  → Occupied       -- physical: crosses the type boundary
  3. if Free ∈ s_T                          → Free
  4. otherwise                              → Unknown
```

**The rule in words, and it must exist as a test rather than a comment:**
*occupancy crosses the type boundary, brokenness does not, and a free sibling
never vouches for an unreported gun.*

Why each clause, since every one of them was got wrong at least once during
review:

- **Occupancy crosses types** because a parked car holds the whole physical
  position — no gun on that pedestal is usable, whatever its type (ADR-0008).
- **Brokenness does not cross types**, because a working Type 2 gun says
  nothing about the GB/T gun beside it. Inheriting the bay's state here told a
  GB/T driver a bay was free while EV Guide held a report saying that plug was
  broken.
- **Broken outranks occupied under a lens** (clause 1 before clause 2): if
  every gun of *your* type on that bay is broken, the bay is useless to you
  even though someone is parked there. Folding it into `Occupied` would send
  you to wait at a charger that will never free — the precise failure
  ADR-0002's fourth state exists to prevent.
- **Unlensed is not a special case** — it is `T = ∅`, so there is exactly one
  function to test, and `{Occupied, OutOfService}` still yields `Occupied`
  unlensed, which is correct: a driver of *some* plug can wait.

### 1.2 Per-type projections

```
baysOffering(T)      = { b : b carries ≥1 Connector whose type ∈ T }
freeBaysOffering(T)  = #{ b ∈ baysOffering(T) : bayStateUnder(b, T) = Free }
```

Each per-type count is **≤ n** (the station's bay count); only the **sum
across types** may exceed n, because a dual-gun bay belongs to two types.
There is no `knownBaysOffering` — the grammar below never needs it.

### 1.3 The decay clock

Deriving at render makes a stale value unrepresentable **only if a render
happens.** A screen left open across a decay boundary keeps painting the old
value forever, and offline there is no sync to correct it.

```
nextDecayDeadline(displayed, now)  -- earliest future instant at which any displayed
                                   -- value changes: an availability window closing,
                                   -- an age word ticking over, a rate's 90 days,
                                   -- a watch's 2h expiry
```

Every surface schedules a one-shot recompose at that instant, re-derives, and
reschedules. Deadlines within one minute are bucketed so a 12-station map
cannot recompose 12 times in a minute. Also recompose on scene resume, since a
deadline missed while suspended is a stale screen restored.

## 2. The display grammar

### 2.1 Signature

```
G(n, f, o, x, u, verbosity, lens) → clauses, with one fixed drop order
   n = bays in scope   f = Free   o = Occupied   x = OutOfService   u = Unknown
```

Three regimes partition the space, and they are the whole grammar:

| Regime | When | Shape | Example |
|---|---|---|---|
| 1 | `f = o = x = 0` (all Unknown) | capacity clause only — never a state word | `4 bays · no confirmed status` |
| 2 | `u = 0` (nothing unknown) | totals permitted | `2 of 4 bays free` |
| 3 | otherwise (mixed) | counts **without** a total | `1 free · 1 busy · 1 out of service · 1 unknown` |

Under a lens, all three regimes apply to the lensed subset, and the remainder
is named **once, uncounted**, on one side of the partition: `2 other bays`.

### 2.2 Laws — each one is a required test

1. **`0 of N` is never emitted, for any input.** A denominator may appear only
   in Regime 2, where `u = 0`, so the denominator *is* the known set by
   construction. Saying `0 of 2 free` over bays nobody has reported claims
   they are not free; at ~87% Unknown that is the normal case, and it sends
   drivers away from stations that may be empty.
2. **A total appears only when `u = 0`.**
3. **`busy` quantifies `o` and nothing else.** It may never touch a bay that is
   `Unknown` or `OutOfService`.
4. **`OutOfService` never folds into occupancy at any count**, and survives to
   the shortest variant of every string.
5. **Never *all* beside *busy* when `x > 0`.**
6. **Singular forms**: no `1 of 1`, no `All 1`.
7. **Rate is denominated in plugs, never bays** — it is a Connector property,
   and a dual-gun pedestal can carry two different rates.
8. **No string asserts report history.** `no confirmed status`, never `no
   recent report` — because the offline override yields `Unknown` from a
   30-second-old report, which would make the second string false. *(The
   permitted form read `No confirmed bay status` here until ticket 32; §2.2b
   says `no confirmed status`, and one home means one string.)*

### 2.2b The forbidden strings — the one and only home

Every surface cites this list. **No other document may hold a copy**, because
three of them tried during ticket 17 and produced four lists that were not the
same list.

**This table is the union, as of ticket 32 (2026-08-14).** It had *not* been the
union before: the design record's own copy held three literals and a catch-all
clause this table lacked (`last reported`, `awaiting a report`, `no reports yet`,
and "any phrasing that asserts a report exists, does not exist, or is old"),
while this table held five the design record lacked. Neither was a superset of
the other, so the four copies were not merely redundant — **deleting the wrong
one would have dropped live bans.** They are merged into row 1 and row 2 above,
and the copies are now pointers. Adding a string here is a change to
`packages/domain` and needs a fixture in the shared corpus (§3).

| Forbidden | Why | Say instead |
| --- | --- | --- |
| `unreported`, `not reported`, `no recent report`, `no report yet`, `no reports yet`, `last reported`, `awaiting a report`, **or any phrasing that asserts a report exists, does not exist, or is old** | Asserts report history. The offline override yields `Unknown` from a 30-second-old report, so these are false. | `no confirmed status` |
| `unknown rate`, `rate unavailable`, `no rate reported`, `no published rate` | Same, for rates. `no published rate` carries a second harm: it asserts a licensee is out of compliance with **RURA Art. 27(2)**. | `no confirmed rate` |
| `real-time`, `live` (as a promise) | Ticket 28: availability is claimed as a bonus, never a promise. Banned in the UI, the store listing and onboarding alike. | say nothing; show freshness |
| `0 of N free` | Grammar law 1 — a denominator may only appear when `u = 0`. | Regime 3 counts, no total |
| `busy` applied to any bay that is `Unknown` or `OutOfService` | Law 3. | the state's own word |
| any availability word on the accent/hero badge | An accent chip reading "no confirmed status" on ~87% of stations paints the product as an apology, which ADR-0002 forbids. *(This row carried a second reason until 2026-08-20: that the badge measured 1.21:1 and could carry no value a driver must read. [ADR-0013](adr/0013-charger-finder-redesign.md) decision 2 made the badge legible at 15.52:1, so that reason is gone and the row now stands on the apology ground alone, which was always the stronger of the two. The ban itself is unchanged.)* | badge carries peak power, or is absent |
| `in use` | A second word for `Occupied`. One word, one state. | `busy` |

### 2.3 Freshness returns structure, not a word

```
freshness(scope) → (contributingSources: Set<Source>, oldestContributingCapturedAt)
```

Contributors are scoped to **the leading clause's state ∩ the lens**, so the
age shown always dates the claim standing next to it. `OutOfService` reports
are excluded from the age, because a 30-day declaration and a two-hour
observation cannot share one age word. Whether the surface renders a mixed
set as `mixed` or collapses to the weakest source is a per-surface rendering
choice; the structure is shared.

### 2.4 The closed vocabulary

The display words are **data in `packages/domain`**, not string literals in a
Swift file and a Kotlin file. Neither transcription may invent a word. This
covers the state words, the capacity clauses, the watch strings, and the
notification bodies (which must take the source as a parameter rather than
hardcoding `operator report`).

Connector type-words are one projection: `IEC_62196_T2` → `Type 2`,
`IEC_62196_T2_COMBO` → `CCS2`, `GBT_AC` → `GB/T AC`, `GBT_DC` → `GB/T DC`,
`OTHER`/`UNKNOWN` → `Other plug`.

**The one word for `Occupied` (R1).** Moved here from the design record by
ticket 32, where it was the only enumeration of the mapping and sat in a section
whose own preamble forbade holding copies:

| Context | String |
| --- | --- |
| Driver-facing, every surface | **`busy`** |
| Operator-facing, every surface | **`busy`** |
| The operator write-surface control label | **`Busy`** |

`busy` quantifies `o` and nothing else (§2.2 law 3). **`in use` is deleted
product-wide** — including the capitalised `In use`, which is in circulation in
four places and is the same ban. It was only ever an example string in §2.1.

## 3. The shared fixture corpus

One corpus, executed by the TypeScript, Swift and Kotlin suites — this is what
keeps three transcriptions of the same function honest. Every fixture below
exists because a review round found a defect that the *other* fixtures hid.

**Amendment (ADR-0012).** The corpus now lives as data:
`packages/corpus/corpus.json`, and the executors are server (TypeScript),
phone (Dart), CarPlay (Swift) and Android Auto (Kotlin). Each language-native
suite executes the JSON rather than re-transcribing the fixtures, and
`packages/domain/test/corpus-json.test.ts` holds the TypeScript reference
implementation to the same file, so the corpus and the implementation cannot
drift apart silently. Fixture 4 stays language-native on every side: it
asserts the absence of a bay-level rate field, which no serialisation can
carry.

1. Dual-gun bay, **`Occupied` + `OutOfService`**, asserted under both lenses.
2. Dual-gun bay, **`Occupied` + never-reported**, both lenses.
3. Dual-gun bay, one gun `OutOfService`, one `Free`, both lenses and unlensed.
4. Dual-gun bay carrying **two distinct rates**; another with a session fee.
5. **One-bay** and one-plug-per-type stations (`n = 1`), all regimes.
6. A station where **`f = o = 0`** and `x > 0` — the empty-contributor case.
7. A **`|T| ≥ 2`** lens.
8. **Offline override with a 30-second-old report** — asserts `Unknown`, and
   asserts that no emitted string mentions report recency.
9. **Each decay boundary at ±1 minute**, and **a render across a boundary with
   no cache change**.
10. A case where the materialised aggregate and the device-derived aggregate
    deliberately **disagree** — the device must win.

## 4. Why this document exists

Three rounds of adversarial review produced the same lesson twice: the
dangerous defects were not broken rules but **a claim in one section disproved
by a table in another**. Two surfaces each holding their own copy of this
grammar reproduced that failure across documents instead of within one — the
CarPlay and Android designs reached opposite renderings for identical station
data, and would have handed the schema two incompatible specifications of one
function. One spec, cited everywhere, is the fix.
