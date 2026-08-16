/**
 * The fixed set of station projections (docs/domain-model.md, "Projections",
 * car constraint 5). They live here so three call sites cannot improvise three
 * different answers.
 *
 * **Projections return structure, not formatted strings** (amendment 8):
 * `(distanceMeters, nameShort)`, never `"~2.4 km · SP Remera"`. Android must
 * hand the host a `DistanceSpan` and may author no distance literal, so a
 * projection that pre-formatted its distance would make the Android surface
 * unimplementable.
 */
import { bayStateUnder, countBays, effective, type LatestReports } from './availability';
import { RATE_WINDOW } from './decay';
import { grammar, type Verbosity } from './grammar';
import type {
  AvailabilityState,
  Connector,
  GeoPoint,
  Lens,
  Millis,
  Station,
} from './types';

const EARTH_RADIUS_M = 6_371_000;

/** Great-circle distance. Rwanda is small; the spherical model is ample. */
export function distanceMeters(a: GeoPoint, b: GeoPoint): number {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * EARTH_RADIUS_M * Math.asin(Math.sqrt(h));
}

/** one-line: `nameShort` and nothing else. */
export interface OneLine {
  readonly stationId: string;
  readonly nameShort: string;
}

/**
 * two-line: `nameShort` / `distance · availability`.
 *
 * Rate has **no room on a car row** and is a detail-screen field, so it is
 * deliberately absent here rather than optional.
 */
export interface TwoLine extends OneLine {
  readonly distanceMeters: number;
  readonly availabilityText: string;
  /**
   * Kept structured beside the text so a surface can style or re-render the
   * parts without parsing the string back apart.
   */
  readonly availability: {
    readonly free: number;
    readonly occupied: number;
    readonly outOfService: number;
    readonly unknown: number;
    readonly baysInScope: number;
  };
}

/** The six CarPlay POI strings, as two triples. */
export interface Triple {
  readonly stationId: string;
  readonly title: string;
  readonly subtitle: string;
  readonly detail: string;
}

export function oneLine(station: Station): OneLine {
  return { stationId: station.id, nameShort: station.nameShort };
}

export function twoLine(
  station: Station,
  origin: GeoPoint,
  lens: Lens,
  latest: LatestReports,
  now: Millis,
  verbosity: Verbosity = 'short',
): TwoLine {
  const counts = countBays(station.bays, lens, latest, now);
  return {
    stationId: station.id,
    nameShort: station.nameShort,
    distanceMeters: distanceMeters(origin, station.geo),
    availabilityText: grammar(counts, verbosity).text,
    availability: {
      free: counts.free,
      occupied: counts.occupied,
      outOfService: counts.outOfService,
      unknown: counts.unknown,
      baysInScope: counts.n,
    },
  };
}

/**
 * picker-triple and card-triple.
 *
 * The availability string never goes in a row **title**: title changes burn
 * Android's template quota, so the volatile value must sit in a line the host
 * lets us update cheaply.
 */
export function pickerTriple(
  station: Station,
  origin: GeoPoint,
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): Triple {
  const t = twoLine(station, origin, lens, latest, now, 'short');
  return {
    stationId: station.id,
    title: station.nameShort,
    subtitle: t.availabilityText,
    detail: station.name,
  };
}

export function cardTriple(
  station: Station,
  origin: GeoPoint,
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): Triple {
  const t = twoLine(station, origin, lens, latest, now, 'full');
  return {
    stationId: station.id,
    title: station.name,
    subtitle: t.availabilityText,
    detail: station.nameShort,
  };
}

/** Per-connector state, reachable in the detail projection (amendment 8). */
export interface ConnectorDetail {
  readonly connectorId: string;
  readonly bayId: string;
  readonly type: Connector['type'];
  readonly state: AvailabilityState;
  readonly powerKw?: number;
  readonly ratePerKwhRwf?: number;
  readonly sessionFeeRwf?: number;
  readonly rateConfirmed: boolean;
}

export interface StationDetail {
  readonly stationId: string;
  readonly name: string;
  readonly nameShort: string;
  readonly geo: GeoPoint;
  readonly bays: readonly { readonly bayId: string; readonly state: AvailabilityState }[];
  /**
   * Per-connector state must be reachable so a known-broken gun is visible to
   * a driver **with no profile set** - the unlensed view must not hide it.
   */
  readonly connectors: readonly ConnectorDetail[];
  readonly rateCoverage: RateCoverage;
}

/**
 * `rateCoverage(station)` is denominated in **plugs, not bays** (amendment 6),
 * because rate is a Connector property and a dual-gun pedestal can carry two
 * different rates.
 */
export interface RateCoverage {
  readonly confirmedPlugs: number;
  readonly totalPlugs: number;
  readonly distinctRates: readonly number[];
  readonly oldestConfirmedAt?: Millis;
  readonly sessionFeeRwf?: number;
}

export function rateCoverage(station: Station, now: Millis): RateCoverage {
  const connectors = station.bays.flatMap((b) => b.connectors);
  const rates = new Set<number>();
  let confirmed = 0;
  let oldest: Millis | undefined;
  let sessionFee: number | undefined;

  for (const c of connectors) {
    const fresh =
      c.ratePerKwhRwf !== undefined &&
      c.rateConfirmedAt !== undefined &&
      now - c.rateConfirmedAt <= RATE_WINDOW;
    if (!fresh) continue;
    confirmed += 1;
    rates.add(c.ratePerKwhRwf as number);
    const at = c.rateConfirmedAt as Millis;
    if (oldest === undefined || at < oldest) oldest = at;
    if (c.sessionFeeRwf !== undefined) sessionFee = c.sessionFeeRwf;
  }

  const base = {
    confirmedPlugs: confirmed,
    totalPlugs: connectors.length,
    distinctRates: [...rates].sort((a, b) => a - b),
  };
  return {
    ...base,
    ...(oldest === undefined ? {} : { oldestConfirmedAt: oldest }),
    ...(sessionFee === undefined ? {} : { sessionFeeRwf: sessionFee }),
  };
}

export function stationDetail(
  station: Station,
  lens: Lens,
  latest: LatestReports,
  now: Millis,
): StationDetail {
  return {
    stationId: station.id,
    name: station.name,
    nameShort: station.nameShort,
    geo: station.geo,
    bays: station.bays.map((b) => ({
      bayId: b.id,
      state: bayStateUnder(b, lens, latest, now),
    })),
    connectors: station.bays.flatMap((b) =>
      b.connectors.map((c): ConnectorDetail => {
        const rateConfirmed =
          c.ratePerKwhRwf !== undefined &&
          c.rateConfirmedAt !== undefined &&
          now - c.rateConfirmedAt <= RATE_WINDOW;
        return {
          connectorId: c.id,
          bayId: b.id,
          type: c.type,
          // Unlensed on purpose: the detail screen shows every gun's own
          // state, so a broken plug is visible to a driver with no profile.
          state: effective(c, latest, now).state,
          ...(c.powerKw === undefined ? {} : { powerKw: c.powerKw }),
          ...(c.ratePerKwhRwf === undefined ? {} : { ratePerKwhRwf: c.ratePerKwhRwf }),
          ...(c.sessionFeeRwf === undefined ? {} : { sessionFeeRwf: c.sessionFeeRwf }),
          rateConfirmed,
        };
      }),
    ),
    rateCoverage: rateCoverage(station, now),
  };
}
