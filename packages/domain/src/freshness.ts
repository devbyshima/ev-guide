/**
 * Freshness returns structure, not a word (section 2.3), and the decay clock
 * (section 1.3).
 */
import { effective, type LatestReports } from './availability';
import { decayWindow, MINUTE } from './decay';
import type { AvailabilityState, Bay, ConnectorType, Lens, Millis, ReportSource } from './types';

export interface Freshness {
  readonly contributingSources: readonly ReportSource[];
  readonly oldestContributingCapturedAt?: Millis;
}

/**
 * Contributors are scoped to **the leading clause's state, intersected with
 * the lens**, so the age shown always dates the claim standing next to it.
 *
 * `OutOfService` reports are excluded from the age: a 30-day declaration and a
 * two-hour observation cannot share one age word.
 */
export function freshness(
  bays: readonly Bay[],
  leadingState: AvailabilityState,
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): Freshness {
  if (leadingState === 'OutOfService' || leadingState === 'Unknown') {
    return { contributingSources: [] };
  }
  const sources = new Set<ReportSource>();
  let oldest: Millis | undefined;

  for (const bay of bays) {
    for (const c of bay.connectors) {
      if (!inLens(c.type, lens)) continue;
      const e = effective(c, latest, now);
      if (e.state !== leadingState) continue;
      if (e.source === undefined || e.capturedAt === undefined) continue;
      sources.add(e.source);
      if (oldest === undefined || e.capturedAt < oldest) oldest = e.capturedAt;
    }
  }
  return oldest === undefined
    ? { contributingSources: [...sources] }
    : { contributingSources: [...sources], oldestContributingCapturedAt: oldest };
}

function inLens(type: ConnectorType, lens: Lens): boolean {
  if (lens === undefined || lens.length === 0) return true;
  return lens.includes(type);
}

/**
 * `nextDecayDeadline(displayed, now)`: the earliest future instant at which
 * any displayed value changes.
 *
 * Deriving at render makes a stale value unrepresentable **only if a render
 * happens**. A screen left open across a decay boundary keeps painting the old
 * value forever, and offline there is no sync to correct it. Every surface
 * schedules a one-shot recompose here, re-derives, and reschedules.
 */
export function nextDecayDeadline(
  bays: readonly Bay[],
  latest: LatestReports,
  now: Millis,
  extraDeadlines: readonly Millis[] = [],
): Millis | undefined {
  const candidates: Millis[] = [...extraDeadlines];

  for (const bay of bays) {
    for (const c of bay.connectors) {
      const r = latest.get(c.id);
      if (!r || !r.sourceOnline) continue;
      const expiry = r.capturedAt + decayWindow(r.source, r.state);
      if (expiry > now) candidates.push(expiry);
    }
    // A rate's 90 days is a displayed value too; callers pass those in via
    // extraDeadlines, since not every surface renders a rate.
  }

  const future = candidates.filter((t) => t > now);
  if (future.length === 0) return undefined;
  return Math.min(...future);
}

/**
 * Deadlines within one minute are bucketed, so a 12-station map cannot
 * recompose 12 times in a minute.
 */
export function bucketDeadline(deadline: Millis, now: Millis): Millis {
  const delta = deadline - now;
  if (delta <= MINUTE) return now + MINUTE;
  return deadline;
}
