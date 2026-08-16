/**
 * The derivation. docs/availability-display.md section 1 is the spec; this is
 * its only implementation in TypeScript, and the Swift and Kotlin layers are
 * transcriptions of the same function against the same fixture corpus.
 *
 * The rule in words: **occupancy crosses the type boundary, brokenness does
 * not, and a free sibling never vouches for an unreported gun.**
 */
import { decayWindow } from './decay.js';
import type {
  AvailabilityState,
  Bay,
  Connector,
  ConnectorType,
  Lens,
  Millis,
  Report,
} from './types.js';

/** What a derivation carries besides the state: freshness is an axis. */
export interface EffectiveState {
  readonly state: AvailabilityState;
  /** Present only when the state came from a live report. */
  readonly source?: Report['source'];
  readonly capturedAt?: Millis;
}

const UNKNOWN: EffectiveState = { state: 'Unknown' };

/** Latest report per connector, keyed by connector id. */
export type LatestReports = ReadonlyMap<string, Report>;

/**
 * `effective(connector, now)`.
 *
 * Absent, decayed, or from a source declaring itself offline yields
 * `Unknown`. The offline override is checked before recency, which is why a
 * 30-second-old report can be Unknown, and why no string may assert report
 * history (grammar law 8).
 */
export function effective(
  connector: Connector,
  latest: LatestReports,
  now: Millis,
): EffectiveState {
  const r = latest.get(connector.id);
  if (!r) return UNKNOWN;
  if (!r.sourceOnline) return UNKNOWN;
  if (now - r.capturedAt > decayWindow(r.source, r.state)) return UNKNOWN;
  return { state: r.state, source: r.source, capturedAt: r.capturedAt };
}

function inLens(type: ConnectorType, lens: Lens): boolean {
  // T = 0 (undefined or empty) means unlensed, and is not a special case.
  if (lens === undefined || lens.length === 0) return true;
  return lens.includes(type);
}

/**
 * `bayStateUnder(bay, T, now)`.
 *
 * Clause order is load-bearing and each clause was got wrong at least once
 * during review, so the order is asserted by tests, not by this comment:
 *
 *   1. every in-lens gun OutOfService  -> OutOfService  (brokenness wins)
 *   2. ANY connector on the bay Occupied -> Occupied    (crosses the lens)
 *   3. any in-lens gun Free            -> Free
 *   4. otherwise                       -> Unknown
 */
export function bayStateUnder(
  bay: Bay,
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): AvailabilityState {
  const lensed = bay.connectors.filter((c) => inLens(c.type, lens));
  const lensedStates = lensed.map((c) => effective(c, latest, now).state);

  // 1. Brokenness wins, and outranks occupancy: if every gun of your type on
  //    this bay is broken, the bay is useless to you even though someone is
  //    parked there. Folding this into Occupied would send you to wait at a
  //    charger that will never free.
  if (lensedStates.length > 0 && lensedStates.every((s) => s === 'OutOfService')) {
    return 'OutOfService';
  }

  // 2. Occupancy crosses the type boundary: a parked car holds the whole
  //    physical position, whatever gun it is using (ADR-0008).
  const anyOccupied = bay.connectors.some(
    (c) => effective(c, latest, now).state === 'Occupied',
  );
  if (anyOccupied) return 'Occupied';

  // 3. A free sibling never vouches for an unreported gun, so this reads the
  //    lensed set only.
  if (lensedStates.includes('Free')) return 'Free';

  return 'Unknown';
}

/** Bays carrying at least one connector whose type is in the lens. */
export function baysOffering(bays: readonly Bay[], lens: Lens): readonly Bay[] {
  return bays.filter((b) => b.connectors.some((c) => inLens(c.type, lens)));
}

export function freeBaysOffering(
  bays: readonly Bay[],
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): number {
  return baysOffering(bays, lens).filter(
    (b) => bayStateUnder(b, lens, latest, now) === 'Free',
  ).length;
}

/** The counts the display grammar consumes. Each is <= the bay count. */
export interface StateCounts {
  /** n: bays in scope. */
  readonly n: number;
  readonly free: number;
  readonly occupied: number;
  readonly outOfService: number;
  readonly unknown: number;
}

export function countBays(
  bays: readonly Bay[],
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): StateCounts {
  const scope = baysOffering(bays, lens);
  let free = 0;
  let occupied = 0;
  let outOfService = 0;
  let unknown = 0;
  for (const b of scope) {
    switch (bayStateUnder(b, lens, latest, now)) {
      case 'Free':
        free += 1;
        break;
      case 'Occupied':
        occupied += 1;
        break;
      case 'OutOfService':
        outOfService += 1;
        break;
      default:
        unknown += 1;
    }
  }
  return { n: scope.length, free, occupied, outOfService, unknown };
}
