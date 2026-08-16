# @ev-guide/domain

Pure types and derivations. **No platform imports** (ADR-0006), so this runs
identically on the server, the phone, and (as transcriptions) the CarPlay and
Android Auto layers.

| File | Owns | Spec |
| --- | --- | --- |
| `types.ts` | the entity model | `docs/domain-model.md` |
| `decay.ts` | the decay windows, in one table | ADR-0002, **ticket 37 open** |
| `availability.ts` | `effective`, `bayStateUnder`, the counts | `docs/availability-display.md` §1 |
| `grammar.ts` | the three regimes and the eight laws | `docs/availability-display.md` §2 |
| `vocabulary.ts` | the closed word list and the forbidden strings | §2.2b, §2.4 |
| `freshness.ts` | freshness structure and the decay clock | §2.3, §1.3 |

**Availability is derived, never stored** (ADR-0008). Nothing here has a state
column, and `test/corpus.test.ts` is the ten-fixture corpus of
`docs/availability-display.md` §3 - the corpus that keeps the TypeScript, Swift
and Kotlin transcriptions honest. Every fixture exists because a review round
found a defect the *other* fixtures hid, so none may be deleted as redundant.

The eight display laws are asserted **exhaustively over every partition of up
to 5 bays**, not by example, because "for any input" is what the laws say.

```
pnpm -C packages/domain test
pnpm -C packages/domain typecheck
```
