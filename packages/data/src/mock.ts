/**
 * The mock implementation. A **first-class citizen** (ADR-0006), not a stub:
 * the apps are built entirely against it, and the BWEZE implementation
 * arrives later behind the same protocols without a screen changing.
 *
 * It therefore has to be honest about the things the real backend will be
 * honest about: it derives availability rather than storing it, it enforces
 * the report policy, and it ranks `stationsNear` the way the spec ranks it.
 */
import {
  countBays,
  distanceMeters,
  stationDetail as buildDetail,
  twoLine,
  type Lens,
  type Millis,
  type Report,
  type Station,
  type StationDetail,
  type TwoLine,
} from '@ev-guide/domain';
import type {
  NearQuery,
  ReportDraft,
  ReportRejection,
  ReportRepository,
  Repositories,
  SavedStationRepository,
  StationRepository,
  VehicleProfileRepository,
} from './protocols.js';
import { REPORTS, STATIONS } from './seed.js';

/**
 * The proximity gate for driver reports (ticket 09).
 *
 * **This radius is not stated anywhere in the spec** - ticket 09 says reports
 * are proximity-gated and never says how near. 150 m is wide enough to cover a
 * forecourt and a parking deck with consumer GPS error, and tight enough that
 * it cannot be satisfied from the road outside. Flagged in ticket 37 with the
 * two decay gaps, since it is the same class of unstated policy constant.
 */
export const REPORT_PROXIMITY_METERS = 150;

/** Car floors and caps (constraint 3): design for 6, never exceed 12. */
export const NEAR_LIMIT_MAX = 12;

export interface MockOptions {
  readonly stations?: readonly Station[];
  readonly reports?: readonly Report[];
  /** Anonymous by default: the whole read surface is ungated (ADR-0003). */
  readonly signedIn?: boolean;
}

/**
 * The mock exposes a small `dev` handle beside the protocols. It is a separate
 * property rather than extra methods on the repositories, so a screen holding
 * a `Repositories` cannot reach it and the seam stays honest.
 */
export interface MockRepositories extends Repositories {
  readonly dev: {
    setSignedIn(value: boolean): void;
    reportCount(): number;
  };
}

export function createMockRepositories(options: MockOptions = {}): MockRepositories {
  const stations = [...(options.stations ?? STATIONS)];
  const reports = [...(options.reports ?? REPORTS)];
  const saved = new Set<string>();
  let signedIn = options.signedIn ?? false;
  let lens: Lens;

  /** Most recent `capturedAt` wins regardless of source (ticket 11). */
  function latestFor(station: Station): ReadonlyMap<string, Report> {
    const ids = new Set(station.bays.flatMap((b) => b.connectors.map((c) => c.id)));
    const m = new Map<string, Report>();
    for (const r of reports) {
      if (!ids.has(r.connectorId)) continue;
      const prev = m.get(r.connectorId);
      if (!prev || r.capturedAt > prev.capturedAt) m.set(r.connectorId, r);
    }
    return m;
  }

  const stationRepo: StationRepository = {
    async stationsNear(q: NearQuery, now: Millis): Promise<readonly TwoLine[]> {
      const limit = Math.min(q.limit, NEAR_LIMIT_MAX);
      const rows = stations.map((s) => {
        const latest = latestFor(s);
        return {
          row: twoLine(s, q.origin, q.lens, latest, now),
          counts: countBays(s.bays, q.lens, latest, now),
          distance: distanceMeters(q.origin, s.geo),
        };
      });

      // Ranked **distance first, then availability**. Availability is the
      // tie-break and never the primary key: a free bay 40 km away is not a
      // better answer than an unreported one across the street.
      rows.sort((a, b) => {
        if (a.distance !== b.distance) return a.distance - b.distance;
        return b.counts.free - a.counts.free;
      });

      return rows.slice(0, limit).map((r) => r.row);
    },

    async stationDetail(id, lensArg, now): Promise<StationDetail | undefined> {
      const s = stations.find((x) => x.id === id);
      if (!s) return undefined;
      return buildDetail(s, lensArg, latestFor(s), now);
    },

    async changedSince(cursor: Millis) {
      const changed = stations.filter((s) => s.updatedAt > cursor);
      const next = changed.reduce((max, s) => Math.max(max, s.updatedAt), cursor);
      return { stations: changed, cursor: next };
    },
  };

  const reportRepo: ReportRepository = {
    async submit(draft: ReportDraft) {
      const fail = (reason: ReportRejection) => ({ ok: false as const, reason });

      // Acting requires an account; reading never does (ADR-0003).
      if (!signedIn) return fail('not-signed-in');

      const station = stations.find((s) =>
        s.bays.some((b) => b.connectors.some((c) => c.id === draft.connectorId)),
      );
      if (!station) return fail('unknown-connector');

      // `capturedAt <= receivedAt` is a schema invariant. A client clock ahead
      // of the server would otherwise mint a report that never decays.
      const receivedAt = Date.now();
      if (draft.capturedAt > receivedAt) return fail('captured-in-future');

      // Proximity is evaluated against the **captured** location, not the
      // current one: an offline report drains hours later from somewhere else
      // entirely, and gating on where the phone is now would reject it.
      if (
        draft.capturedLocation !== undefined &&
        distanceMeters(draft.capturedLocation, station.geo) > REPORT_PROXIMITY_METERS
      ) {
        return fail('too-far');
      }

      reports.push({
        connectorId: draft.connectorId,
        state: draft.state,
        source: 'driver',
        reporterId: 'mock-user',
        capturedAt: draft.capturedAt,
        receivedAt,
        sourceOnline: draft.sourceOnline,
        ...(draft.capturedLocation === undefined
          ? {}
          : { capturedLocation: draft.capturedLocation }),
      });
      return { ok: true as const };
    },

    async latestByConnector(stationId: string) {
      const s = stations.find((x) => x.id === stationId);
      return s ? latestFor(s) : new Map<string, Report>();
    },
  };

  const savedRepo: SavedStationRepository = {
    async list() {
      return [...saved];
    },
    async add(id) {
      saved.add(id);
    },
    async remove(id) {
      saved.delete(id);
    },
  };

  const vehicleRepo: VehicleProfileRepository = {
    async connectorTypes() {
      return lens;
    },
    async setConnectorTypes(types) {
      lens = types;
    },
  };

  return {
    stations: stationRepo,
    reports: reportRepo,
    saved: savedRepo,
    vehicle: vehicleRepo,
    dev: {
      setSignedIn(value: boolean) {
        signedIn = value;
      },
      reportCount() {
        return reports.length;
      },
    },
  };
}
