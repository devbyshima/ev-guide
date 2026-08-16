/**
 * The shared fixture corpus, docs/availability-display.md section 3.
 *
 * One corpus, to be executed by the TypeScript, Swift and Kotlin suites: this
 * is what keeps three transcriptions of the same function honest. Every
 * fixture exists because a review round found a defect the *other* fixtures
 * hid, so none of them may be deleted for being redundant.
 */
import { HOUR, MINUTE } from '../src/decay.js';
import type { Bay, Connector, Report, ReportSource, ReportedState } from '../src/types.js';

export const NOW = 1_760_000_000_000;

let seq = 0;
function nextId(prefix: string): string {
  seq += 1;
  return `${prefix}-${seq}`;
}

export function connector(type: string, over: Partial<Connector> = {}): Connector {
  return { id: nextId('c'), bayId: 'b', type, ...over };
}

export function bay(connectors: Connector[], stationId = 's1'): Bay {
  const id = nextId('b');
  return { id, stationId, connectors: connectors.map((c) => ({ ...c, bayId: id })) };
}

export function report(
  connectorId: string,
  state: ReportedState,
  opts: {
    source?: ReportSource;
    ageMs?: number;
    sourceOnline?: boolean;
    now?: number;
  } = {},
): Report {
  const now = opts.now ?? NOW;
  const capturedAt = now - (opts.ageMs ?? 5 * MINUTE);
  return {
    connectorId,
    state,
    source: opts.source ?? 'driver',
    reporterId: 'u1',
    capturedAt,
    receivedAt: capturedAt,
    sourceOnline: opts.sourceOnline ?? true,
  };
}

export function latest(...reports: Report[]): ReadonlyMap<string, Report> {
  const m = new Map<string, Report>();
  for (const r of reports) {
    const prev = m.get(r.connectorId);
    // Most recent capturedAt wins, regardless of source (ticket 11).
    if (!prev || r.capturedAt > prev.capturedAt) m.set(r.connectorId, r);
  }
  return m;
}

export const T2 = 'IEC_62196_T2';
export const CCS2 = 'IEC_62196_T2_COMBO';
export const GBT_DC = 'GBT_DC';

export const FRESH = 5 * MINUTE;
export const STALE_FOR_DRIVER = 3 * HOUR;
