/**
 * The repository protocols. ADR-0005's seam, made concrete.
 *
 * Apps are built frontend-first against these; the mock implementation is a
 * first-class citizen (ADR-0006) and the BWEZE implementation arrives later
 * behind the *same* interfaces. Nothing above this line may know which is
 * installed.
 *
 * Every method that returns availability returns it **derived**, computed by
 * `@ev-guide/domain` from raw reports. No implementation may return a stored
 * availability column, because none exists (ADR-0008).
 */
import type {
  GeoPoint,
  Lens,
  Millis,
  Report,
  ReportedState,
  Station,
  StationDetail,
  TwoLine,
} from '@ev-guide/domain';

/**
 * `stationsNear` is **the** load-bearing query (car constraint 2).
 *
 * The origin is always an argument and never "the device's location": the car
 * surfaces pass a viewport centre, and an App Store reviewer's session passes
 * a mock GPS fix. Hardcoding device location makes the app unreviewable.
 */
export interface NearQuery {
  readonly origin: GeoPoint;
  /** Car floors and caps: design for 6, never exceed 12. */
  readonly limit: number;
  readonly lens?: Lens;
}

/** Bounded and ranked: distance first, then availability. */
export interface StationRepository {
  stationsNear(q: NearQuery, now: Millis): Promise<readonly TwoLine[]>;

  /** Station detail by opaque stable id (car constraint 11). */
  stationDetail(id: string, lens: Lens, now: Millis): Promise<StationDetail | undefined>;

  /** Delta sync on `updatedAt` (ADR-0007); also what the car cache refreshes behind. */
  changedSince(cursor: Millis): Promise<{
    readonly stations: readonly Station[];
    readonly cursor: Millis;
  }>;
}

/**
 * Writing a report. The window and the proximity gate are **policy**, checked
 * here rather than in a screen, so all three surfaces get the same answer.
 */
export interface ReportDraft {
  readonly connectorId: string;
  readonly state: ReportedState;
  readonly capturedAt: Millis;
  readonly capturedLocation?: GeoPoint;
  /** False when the reporting client knows it is offline (amendment 2). */
  readonly sourceOnline: boolean;
}

export type ReportRejection =
  | 'not-signed-in'
  | 'too-far'
  | 'unknown-connector'
  /** `capturedAt <= receivedAt` is a schema invariant, not a suggestion. */
  | 'captured-in-future';

export interface ReportRepository {
  /**
   * Queued when offline, with the captured time and location preserved
   * (ADR-0007). A queued report that outlives its own decay window is dropped
   * rather than sent: posting it would assert a fact about a moment that has
   * already expired.
   */
  submit(draft: ReportDraft): Promise<{ ok: true } | { ok: false; reason: ReportRejection }>;
  latestByConnector(stationId: string): Promise<ReadonlyMap<string, Report>>;
}

export interface SavedStationRepository {
  list(): Promise<readonly string[]>;
  add(stationId: string): Promise<void>;
  remove(stationId: string): Promise<void>;
}

/**
 * The driver's own connector types. **Device-local and ungated**: it is a
 * reading aid, and the read surface is anonymous (ADR-0003 as amended). Only
 * *syncing* it across devices needs an account, which is why there is no
 * `userId` here.
 */
export interface VehicleProfileRepository {
  connectorTypes(): Promise<Lens>;
  setConnectorTypes(types: Lens): Promise<void>;
}

export interface Repositories {
  readonly stations: StationRepository;
  readonly reports: ReportRepository;
  readonly saved: SavedStationRepository;
  readonly vehicle: VehicleProfileRepository;
}
