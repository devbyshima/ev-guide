/**
 * The drift guard for the corpus-as-data mechanism (ADR-0012).
 *
 * `packages/corpus/corpus.json` is the language-neutral serialisation of the
 * shared fixture corpus, docs/availability-display.md section 3. Four
 * executors run it: server (TypeScript), phone (Dart), CarPlay (Swift),
 * Android Auto (Kotlin). This suite is the TypeScript executor. It runs every
 * case and every check against the reference implementation, so if
 * corpus.json and packages/domain ever disagree, this file fails and the
 * drift is caught before a transcription inherits it. A transcription of the
 * derivation is proven equivalent or it does not ship.
 *
 * Fixture 4 (rates are per plug, not per bay) is structural: it asserts the
 * absence of a bay-level rate field, which no serialisation can carry. It
 * stays a language-native test in corpus.test.ts, and on every other side.
 */
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import {
  bayStateUnder,
  countBays,
  effective,
  type LatestReports,
} from '../src/availability';
import { grammar, type Verbosity } from '../src/grammar';
import { nextDecayDeadline } from '../src/freshness';
import { FORBIDDEN_SUBSTRINGS } from '../src/vocabulary';
import type {
  Bay,
  Connector,
  Lens,
  Millis,
  Report,
  ReportSource,
  ReportedState,
} from '../src/types';

/*
 * The JSON's shape, typed locally: the corpus is data, not an exported API.
 * The executors in the other three languages carry their own reading of the
 * same schema, which is the point.
 */

interface CorpusConnector {
  readonly id: string;
  readonly type: string;
}

interface CorpusBay {
  readonly id: string;
  readonly connectors: readonly CorpusConnector[];
}

/** `capturedAt` is defined as `now - ageMs`; latest per connector wins. */
interface CorpusReport {
  readonly connectorId: string;
  readonly state: ReportedState;
  readonly source: ReportSource;
  readonly ageMs: number;
  readonly sourceOnline: boolean;
}

interface CountsExpectation {
  readonly n: number;
  readonly free: number;
  readonly occupied: number;
  readonly outOfService: number;
  readonly unknown: number;
}

/** `null` means unlensed, which the domain spells `undefined` (T = 0). */
type CorpusLens = readonly string[] | null;

type CorpusCheck =
  | {
      readonly kind: 'bayState';
      readonly bayId: string;
      readonly lens: CorpusLens;
      readonly nowOffsetMs: number;
      readonly expect: string;
    }
  | {
      readonly kind: 'effective';
      readonly connectorId: string;
      readonly nowOffsetMs: number;
      readonly expect: string;
    }
  | {
      readonly kind: 'counts';
      readonly lens: CorpusLens;
      readonly expect: CountsExpectation;
    }
  | {
      readonly kind: 'grammar';
      readonly lens: CorpusLens;
      readonly otherBays: number;
      readonly verbosity: Verbosity;
      readonly expectRegime: number;
      readonly expectText: string | null;
      readonly notContains: readonly string[];
    }
  | {
      readonly kind: 'deadline';
      readonly expect: number | null;
    };

interface CorpusCase {
  readonly id: string;
  readonly title: string;
  readonly bays: readonly CorpusBay[];
  readonly reports: readonly CorpusReport[];
  readonly checks: readonly CorpusCheck[];
}

interface GrammarCase {
  readonly id: string;
  readonly title: string;
  readonly counts: CountsExpectation;
  readonly otherBays: number;
  readonly verbosity: Verbosity;
  readonly expectRegime: number;
  readonly expectText: string | null;
  readonly notContains: readonly string[];
  readonly forbiddenSweep: boolean;
}

interface CorpusFile {
  readonly now: Millis;
  readonly cases: readonly CorpusCase[];
  readonly grammarCases: readonly GrammarCase[];
}

const corpus: CorpusFile = JSON.parse(
  readFileSync(new URL('../../corpus/corpus.json', import.meta.url), 'utf8'),
);

function toLens(lens: CorpusLens): Lens {
  return lens === null ? undefined : lens;
}

function materialiseBays(c: CorpusCase): readonly Bay[] {
  return c.bays.map((b) => ({
    id: b.id,
    stationId: 's1',
    connectors: b.connectors.map((conn) => ({
      id: conn.id,
      bayId: b.id,
      type: conn.type,
    })),
  }));
}

/** Latest-wins per connector by capturedAt, exactly as fixtures.ts does. */
function materialiseReports(c: CorpusCase, now: Millis): LatestReports {
  const m = new Map<string, Report>();
  for (const r of c.reports) {
    const capturedAt = now - r.ageMs;
    const report: Report = {
      connectorId: r.connectorId,
      state: r.state,
      source: r.source,
      reporterId: 'corpus',
      capturedAt,
      receivedAt: capturedAt,
      sourceOnline: r.sourceOnline,
    };
    const prev = m.get(r.connectorId);
    if (!prev || report.capturedAt > prev.capturedAt) m.set(r.connectorId, report);
  }
  return m;
}

function findBay(bays: readonly Bay[], id: string): Bay {
  const b = bays.find((candidate) => candidate.id === id);
  if (!b) throw new Error(`corpus check names unknown bay: ${id}`);
  return b;
}

function findConnector(bays: readonly Bay[], id: string): Connector {
  for (const b of bays) {
    const c = b.connectors.find((candidate) => candidate.id === id);
    if (c) return c;
  }
  throw new Error(`corpus check names unknown connector: ${id}`);
}

function lensLabel(lens: CorpusLens): string {
  return lens === null ? 'unlensed' : `lens=[${lens.join(', ')}]`;
}

function checkLabel(check: CorpusCheck): string {
  switch (check.kind) {
    case 'bayState':
      return `bayState(${check.bayId}, ${lensLabel(check.lens)}, +${check.nowOffsetMs}ms) is ${check.expect}`;
    case 'effective':
      return `effective(${check.connectorId}, +${check.nowOffsetMs}ms) is ${check.expect}`;
    case 'counts':
      return `counts under ${lensLabel(check.lens)}`;
    case 'grammar':
      return `grammar under ${lensLabel(check.lens)} at ${check.verbosity} is regime ${check.expectRegime}`;
    case 'deadline':
      return `nextDecayDeadline is ${check.expect === null ? 'undefined' : check.expect}`;
  }
}

function runCheck(check: CorpusCheck, c: CorpusCase): void {
  const bays = materialiseBays(c);
  const latest = materialiseReports(c, corpus.now);

  switch (check.kind) {
    case 'bayState': {
      const state = bayStateUnder(
        findBay(bays, check.bayId),
        toLens(check.lens),
        latest,
        corpus.now + check.nowOffsetMs,
      );
      expect(state).toBe(check.expect);
      return;
    }
    case 'effective': {
      const e = effective(
        findConnector(bays, check.connectorId),
        latest,
        corpus.now + check.nowOffsetMs,
      );
      expect(e.state).toBe(check.expect);
      return;
    }
    case 'counts': {
      const counts = countBays(bays, toLens(check.lens), latest, corpus.now);
      expect(counts).toEqual(check.expect);
      return;
    }
    case 'grammar': {
      // Counts are derived from the fixture, then fed to the grammar: the
      // corpus never carries a count the derivation did not produce.
      const counts = countBays(bays, toLens(check.lens), latest, corpus.now);
      const g = grammar({ ...counts, otherBays: check.otherBays }, check.verbosity);
      expect(g.regime).toBe(check.expectRegime);
      if (check.expectText !== null) expect(g.text).toBe(check.expectText);
      for (const banned of check.notContains) {
        expect(g.text, `banned: ${banned}`).not.toContain(banned);
      }
      return;
    }
    case 'deadline': {
      const deadline = nextDecayDeadline(bays, latest, corpus.now);
      expect(deadline).toBe(check.expect === null ? undefined : check.expect);
      return;
    }
    default: {
      // A check kind this executor does not know is a corpus change that
      // must fail loudly, never pass vacuously.
      const unknown: never = check;
      throw new Error(`unknown check kind: ${JSON.stringify(unknown)}`);
    }
  }
}

describe('corpus.json: the derivation fixtures execute against the TS implementation', () => {
  for (const c of corpus.cases) {
    for (const check of c.checks) {
      it(`${c.id} (${c.title}): ${checkLabel(check)}`, () => {
        runCheck(check, c);
      });
    }
  }
});

describe('corpus.json: the grammar law cases execute against the TS implementation', () => {
  for (const g of corpus.grammarCases) {
    it(`${g.id} (${g.title})`, () => {
      const result = grammar({ ...g.counts, otherBays: g.otherBays }, g.verbosity);
      expect(result.regime).toBe(g.expectRegime);
      if (g.expectText !== null) expect(result.text).toBe(g.expectText);
      for (const banned of g.notContains) {
        expect(result.text, `banned: ${banned}`).not.toContain(banned);
      }
      if (g.forbiddenSweep) {
        // Law 8's mechanical half, exactly as grammar.test.ts sweeps it: no
        // forbidden substring may survive into any emitted string.
        for (const banned of FORBIDDEN_SUBSTRINGS) {
          expect(result.text.toLowerCase(), `forbidden: ${banned}`).not.toContain(banned);
        }
      }
    });
  }
});
