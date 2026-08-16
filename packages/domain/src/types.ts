/**
 * Entity types. Source of truth: docs/domain-model.md.
 *
 * Pure types only, no platform imports (ADR-0006). Nothing here carries an
 * availability column: availability is derived, never stored (ADR-0008).
 */

/**
 * Connector type, ticket 02's **open** OCPI 2.3.0 enum.
 *
 * Tier 1 is enumerated; the type stays open because Android can hand us a
 * value we do not know, and RURA Art. 3(c) enumerates families with an open
 * clause. Never persist a platform integer: map at the edge.
 */
export const CONNECTOR_TYPES_TIER_1 = [
  'IEC_62196_T2',
  'IEC_62196_T2_COMBO',
  'GBT_AC',
  'GBT_DC',
] as const;

export type ConnectorTypeTier1 = (typeof CONNECTOR_TYPES_TIER_1)[number];

/** `OTHER`/`UNKNOWN` are always present; a raw string models the open tail. */
export type ConnectorType = ConnectorTypeTier1 | 'OTHER' | 'UNKNOWN' | (string & {});

/** A report's claim. `Unknown` is never reported, only derived. */
export type ReportedState = 'Free' | 'Occupied' | 'OutOfService';

/** What a derivation yields. `Unknown` is the normal case (~87%). */
export type AvailabilityState = ReportedState | 'Unknown';

export type ReportSource = 'driver' | 'operator' | 'admin';

/** Epoch milliseconds. The domain never holds a Date: it must be serialisable. */
export type Millis = number;

export interface Report {
  readonly connectorId: string;
  readonly state: ReportedState;
  readonly source: ReportSource;
  readonly reporterId: string;
  /**
   * When the observation happened, not when we received it (ADR-0007).
   * Proximity gating evaluates `capturedLocation`; `capturedAt <= receivedAt`.
   */
  readonly capturedAt: Millis;
  readonly receivedAt: Millis;
  readonly capturedLocation?: GeoPoint;
  /**
   * Amendment 2 (ticket 18): a source declaring itself offline yields
   * `Unknown` immediately, regardless of recency.
   */
  readonly sourceOnline: boolean;
}

/**
 * The car cache holds raw per-Connector latest reports, never a materialised
 * aggregate (amendment 3). This projection strips the two sensitive fields.
 */
export type CachedReport = Omit<Report, 'reporterId' | 'capturedLocation'>;

export interface GeoPoint {
  readonly lat: number;
  readonly lng: number;
}

export interface Connector {
  readonly id: string;
  readonly bayId: string;
  readonly type: ConnectorType;
  readonly powerKw?: number;
  readonly voltage?: number;
  /** Rate lives on the Connector (ticket 10), with its own 90-day freshness. */
  readonly ratePerKwhRwf?: number;
  readonly sessionFeeRwf?: number;
  readonly rateConfirmedAt?: Millis;
}

/** One parking position. One vehicle charges at a time; hence propagation. */
export interface Bay {
  readonly id: string;
  readonly stationId: string;
  /** 1..N, at least one required. */
  readonly connectors: readonly Connector[];
}

export interface Owner {
  readonly id: string;
  readonly displayName: string;
  /** <= 17 chars (amendment 7). */
  readonly shortName: string;
  /** 1-3 chars, NOT NULL: the car platforms' one hard character limit. */
  readonly markerLabel: string;
  /** Must be a vector; CarPlay pin sizes are runtime values. */
  readonly iconRef: string;
}

export interface Station {
  readonly id: string;
  readonly ownerId: string;
  /** NOT NULL: a station without coordinates cannot exist (car constraint 1). */
  readonly geo: GeoPoint;
  /** <= 28 chars (amendment 7). */
  readonly name: string;
  /** <= 18 chars. The *place*; the operator belongs in icon and marker. */
  readonly nameShort: string;
  readonly bays: readonly Bay[];
  /** ADR-0001: nothing branches on this. */
  readonly vehicleClassTag?: string;
  /** Delta-sync cursor (ADR-0007). */
  readonly updatedAt: Millis;
}

/**
 * The driver's connector types. `undefined` or empty means unlensed (T = 0),
 * which is not a special case: it is the same function with an empty set.
 */
export type Lens = readonly ConnectorType[] | undefined;
