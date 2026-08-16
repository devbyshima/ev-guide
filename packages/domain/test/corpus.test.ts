/**
 * The ten fixtures of docs/availability-display.md section 3, one describe
 * block each, numbered as the spec numbers them.
 */
import { describe, expect, it } from 'vitest';
import { bayStateUnder, countBays, effective } from '../src/availability.js';
import { DAY, HOUR, MINUTE } from '../src/decay.js';
import { grammar } from '../src/grammar.js';
import { nextDecayDeadline } from '../src/freshness.js';
import { CCS2, GBT_DC, NOW, T2, bay, connector, latest, report } from './fixtures.js';

describe('1. dual-gun bay, Occupied + OutOfService, under both lenses', () => {
  const t2 = connector(T2);
  const gbt = connector(GBT_DC);
  const b = bay([t2, gbt]);
  const reports = latest(
    report(b.connectors[0]!.id, 'Occupied', { source: 'operator' }),
    report(b.connectors[1]!.id, 'OutOfService', { source: 'operator' }),
  );

  it('is Occupied for the Type 2 driver: occupancy is physical', () => {
    expect(bayStateUnder(b, [T2], reports, NOW)).toBe('Occupied');
  });

  it('is OutOfService for the GB/T driver: every gun of their type is broken', () => {
    // Clause 1 outranks clause 2. Folding this into Occupied would send the
    // driver to wait at a charger that will never free.
    expect(bayStateUnder(b, [GBT_DC], reports, NOW)).toBe('OutOfService');
  });

  it('is Occupied unlensed, because a driver of some plug can wait', () => {
    expect(bayStateUnder(b, undefined, reports, NOW)).toBe('Occupied');
  });
});

describe('2. dual-gun bay, Occupied + never-reported', () => {
  const b = bay([connector(T2), connector(GBT_DC)]);
  const reports = latest(report(b.connectors[0]!.id, 'Occupied'));

  it('is Occupied under either lens: the position is held', () => {
    expect(bayStateUnder(b, [T2], reports, NOW)).toBe('Occupied');
    expect(bayStateUnder(b, [GBT_DC], reports, NOW)).toBe('Occupied');
  });
});

describe('3. dual-gun bay, one OutOfService and one Free', () => {
  const b = bay([connector(T2), connector(GBT_DC)]);
  const reports = latest(
    report(b.connectors[0]!.id, 'Free'),
    report(b.connectors[1]!.id, 'OutOfService', { source: 'operator' }),
  );

  it('is Free for the Type 2 driver', () => {
    expect(bayStateUnder(b, [T2], reports, NOW)).toBe('Free');
  });

  it('is OutOfService for the GB/T driver: a free sibling never vouches', () => {
    expect(bayStateUnder(b, [GBT_DC], reports, NOW)).toBe('OutOfService');
  });

  it('is Free unlensed', () => {
    expect(bayStateUnder(b, undefined, reports, NOW)).toBe('Free');
  });
});

describe('4. rates are per plug, not per bay', () => {
  it('a dual-gun bay can carry two distinct rates and a session fee', () => {
    const b = bay([
      connector(T2, { ratePerKwhRwf: 600, rateConfirmedAt: NOW }),
      connector(GBT_DC, { ratePerKwhRwf: 400, sessionFeeRwf: 500, rateConfirmedAt: NOW }),
    ]);
    const rates = b.connectors.map((c) => c.ratePerKwhRwf);
    expect(new Set(rates).size).toBe(2);
    // Law 7: rate is denominated in plugs. There is no bay-level rate field
    // to read, which is the structural half of that law.
    expect(b).not.toHaveProperty('ratePerKwhRwf');
  });
});

describe('5. single-bay and one-plug-per-type stations', () => {
  it('never emits "1 of 1" (law 6)', () => {
    const b = bay([connector(T2)]);
    const reports = latest(report(b.connectors[0]!.id, 'Free'));
    const counts = countBays([b], undefined, reports, NOW);
    const g = grammar(counts);
    expect(g.text).not.toContain('1 of 1');
    expect(g.text).toBe('1 bay free');
  });

  it('never emits "All 1" (law 6)', () => {
    const b = bay([connector(T2)]);
    const reports = latest(report(b.connectors[0]!.id, 'Free'));
    expect(grammar(countBays([b], undefined, reports, NOW)).text).not.toContain('All 1');
  });
});

describe('6. f = o = 0 with x > 0: the empty-contributor case', () => {
  const b1 = bay([connector(T2)]);
  const b2 = bay([connector(T2)]);
  const reports = latest(
    report(b1.connectors[0]!.id, 'OutOfService', { source: 'operator' }),
    report(b2.connectors[0]!.id, 'OutOfService', { source: 'operator' }),
  );

  it('is Regime 2, and says out of service without inventing a total free', () => {
    const counts = countBays([b1, b2], undefined, reports, NOW);
    expect(counts).toMatchObject({ n: 2, free: 0, occupied: 0, outOfService: 2, unknown: 0 });
    const g = grammar(counts);
    expect(g.regime).toBe(2);
    expect(g.text).toBe('2 out of service');
    expect(g.text).not.toContain('0 of');
  });
});

describe('7. a lens of two or more types', () => {
  it('counts only bays offering a lensed type, and names the rest once', () => {
    const lensed = bay([connector(T2)]);
    const alsoLensed = bay([connector(CCS2)]);
    const other = bay([connector(GBT_DC)]);
    const reports = latest(report(lensed.connectors[0]!.id, 'Free'));

    const counts = countBays([lensed, alsoLensed, other], [T2, CCS2], reports, NOW);
    expect(counts.n).toBe(2);

    const g = grammar({ ...counts, otherBays: 1 });
    expect(g.text).toContain('1 other bay');
    // The remainder is named once and uncounted: never broken down by state.
    expect(g.text).not.toContain('1 other bay unknown');
  });
});

describe('8. offline override with a 30-second-old report', () => {
  const c = connector(T2);
  const b = bay([c]);
  const reports = latest(
    report(b.connectors[0]!.id, 'Free', { ageMs: 30_000, sourceOnline: false }),
  );

  it('yields Unknown despite the report being 30 seconds old', () => {
    expect(effective(b.connectors[0]!, reports, NOW).state).toBe('Unknown');
  });

  it('emits no string mentioning report recency (law 8)', () => {
    const g = grammar(countBays([b], undefined, reports, NOW));
    expect(g.text).toBe('1 bay · no confirmed status');
    for (const banned of ['no recent report', 'unreported', 'last reported']) {
      expect(g.text).not.toContain(banned);
    }
  });
});

describe('9. each decay boundary at +/- 1 minute', () => {
  const cases = [
    { source: 'driver' as const, state: 'Free' as const, window: 2 * HOUR },
    { source: 'operator' as const, state: 'Free' as const, window: 6 * HOUR },
    { source: 'operator' as const, state: 'OutOfService' as const, window: 30 * DAY },
  ];

  for (const { source, state, window } of cases) {
    it(`${source} ${state} holds at window - 1min and is Unknown at window + 1min`, () => {
      const b = bay([connector(T2)]);
      const c = b.connectors[0]!;

      const justInside = latest(report(c.id, state, { source, ageMs: window - MINUTE }));
      expect(effective(c, justInside, NOW).state).toBe(state);

      const justOutside = latest(report(c.id, state, { source, ageMs: window + MINUTE }));
      expect(effective(c, justOutside, NOW).state).toBe('Unknown');
    });
  }

  it('a render across a boundary changes the answer with no cache change', () => {
    const b = bay([connector(T2)]);
    const c = b.connectors[0]!;
    const reports = latest(report(c.id, 'Free', { source: 'driver', ageMs: 2 * HOUR - MINUTE }));

    // Same map, two render times: this is the whole reason the decay clock exists.
    expect(effective(c, reports, NOW).state).toBe('Free');
    expect(effective(c, reports, NOW + 2 * MINUTE).state).toBe('Unknown');
  });

  it('nextDecayDeadline lands exactly on the boundary', () => {
    const b = bay([connector(T2)]);
    const c = b.connectors[0]!;
    const capturedAgo = 30 * MINUTE;
    const reports = latest(report(c.id, 'Free', { source: 'driver', ageMs: capturedAgo }));
    const deadline = nextDecayDeadline([b], reports, NOW);
    expect(deadline).toBe(NOW - capturedAgo + 2 * HOUR);
  });
});

describe('10. materialised aggregate vs device-derived: the device wins', () => {
  it('the derived count contradicts a stale server aggregate', () => {
    const b = bay([connector(T2)]);
    const c = b.connectors[0]!;
    // The server materialised "1 free" when the report was fresh.
    const serverAggregateFree = 1;
    // The device re-derives past the boundary and disagrees.
    const reports = latest(report(c.id, 'Free', { source: 'driver', ageMs: 3 * HOUR }));
    const derived = countBays([b], undefined, reports, NOW);

    expect(serverAggregateFree).toBe(1);
    expect(derived.free).toBe(0);
    expect(derived.unknown).toBe(1);
    // A stale green is impossible by construction, and this is the assertion
    // that says so.
    expect(grammar(derived).text).toBe('1 bay · no confirmed status');
  });
});
