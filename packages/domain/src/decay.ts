/**
 * The decay windows, in one place, because changing them is a product
 * decision and must be a one-line change.
 *
 * ADR-0002: decay is a function of source AND state. Driver Free/Occupied
 * decays in 2h, operator Free/Occupied in 6h, OutOfService in 30d.
 */
import type { ReportSource, ReportedState, Millis } from './types';

export const MINUTE = 60_000;
export const HOUR = 60 * MINUTE;
export const DAY = 24 * HOUR;

/**
 * Two rows here are **assumptions, not quotations**, and are flagged so they
 * can be ruled on rather than inherited:
 *
 * - `driver` + `OutOfService`. ADR-0002 names only *operator* OutOfService at
 *   30d; docs/domain-model.md's synthesis states a flat "OutOfService 30d".
 *   The flat reading is taken here, so a driver's brokenness claim persists
 *   for 30 days. That is a large claim from the lowest-trust source, and the
 *   opposite reading (driver OutOfService decays at the driver window) is
 *   equally defensible from the two documents.
 * - `admin`. Neither document gives admin a window. Treated as operator,
 *   since both are trusted write sources under the ticket 11 boundaries.
 */
export const DECAY_WINDOWS: Readonly<
  Record<ReportSource, Readonly<Record<ReportedState, Millis>>>
> = {
  driver: { Free: 2 * HOUR, Occupied: 2 * HOUR, OutOfService: 30 * DAY },
  operator: { Free: 6 * HOUR, Occupied: 6 * HOUR, OutOfService: 30 * DAY },
  admin: { Free: 6 * HOUR, Occupied: 6 * HOUR, OutOfService: 30 * DAY },
};

export function decayWindow(source: ReportSource, state: ReportedState): Millis {
  return DECAY_WINDOWS[source][state];
}

/** The rate's own freshness axis (ticket 10). */
export const RATE_WINDOW: Millis = 90 * DAY;

/** A watch is one-shot and expires 2h after arming (ticket 30). */
export const WATCH_WINDOW: Millis = 2 * HOUR;
