/// The repository protocols. ADR-0005's seam, made concrete.
///
/// Apps are built frontend-first against these; the mock implementation is a
/// first-class citizen (ADR-0006) and the BWEZE implementation arrives later
/// behind the *same* interfaces. Nothing above this line may know which is
/// installed.
///
/// Every method that returns availability returns it **derived**, computed by
/// `ev_guide_domain` from raw reports. No implementation may return a stored
/// availability column, because none exists (ADR-0008).
///
/// Dart transcription of `packages/data/src/protocols.ts` (ADR-0012). Same
/// seam, same reasoning; async methods return [Future].
library;

import 'package:ev_guide_domain/ev_guide_domain.dart';

/// `stationsNear` is **the** load-bearing query (car constraint 2).
///
/// The origin is always an argument and never "the device's location": the
/// car surfaces pass a viewport centre, and an App Store reviewer's session
/// passes a mock GPS fix. Hardcoding device location makes the app
/// unreviewable.
class NearQuery {
  const NearQuery({required this.origin, required this.limit, this.lens});

  final GeoPoint origin;

  /// Car floors and caps: design for 6, never exceed 12.
  final int limit;
  final Lens lens;
}

/// The result of [StationRepository.changedSince]: the rows past the cursor
/// plus the advanced cursor (ADR-0007). TypeScript spells this as an
/// anonymous object; Dart needs the class.
class StationDelta {
  const StationDelta({required this.stations, required this.cursor});

  final List<Station> stations;
  final Millis cursor;
}

/// Bounded and ranked: distance first, then availability.
abstract interface class StationRepository {
  Future<List<TwoLine>> stationsNear(NearQuery q, Millis now);

  /// Station detail by opaque stable id (car constraint 11).
  Future<StationDetail?> stationDetail(String id, Lens lens, Millis now);

  /// Delta sync on `updatedAt` (ADR-0007); also what the car cache refreshes
  /// behind.
  Future<StationDelta> changedSince(Millis cursor);
}

/// Writing a report. The window and the proximity gate are **policy**,
/// checked here rather than in a screen, so all three surfaces get the same
/// answer.
class ReportDraft {
  const ReportDraft({
    required this.connectorId,
    required this.state,
    required this.capturedAt,
    this.capturedLocation,
    required this.sourceOnline,
  });

  final String connectorId;
  final ReportedState state;
  final Millis capturedAt;
  final GeoPoint? capturedLocation;

  /// False when the reporting client knows it is offline (amendment 2).
  final bool sourceOnline;
}

enum ReportRejection {
  notSignedIn,
  tooFar,
  unknownConnector,

  /// `capturedAt <= receivedAt` is a schema invariant, not a suggestion.
  capturedInFuture,
}

/// TypeScript spells [ReportRepository.submit]'s result as
/// `{ ok: true } | { ok: false, reason }`; Dart spells the same closed union
/// as a sealed class, so a `switch` over it is exhaustive.
sealed class SubmitResult {
  const SubmitResult();
}

final class SubmitAccepted extends SubmitResult {
  const SubmitAccepted();
}

final class SubmitRejected extends SubmitResult {
  const SubmitRejected(this.reason);

  final ReportRejection reason;
}

abstract interface class ReportRepository {
  /// Queued when offline, with the captured time and location preserved
  /// (ADR-0007). A queued report that outlives its own decay window is
  /// dropped rather than sent: posting it would assert a fact about a moment
  /// that has already expired.
  Future<SubmitResult> submit(ReportDraft draft);

  Future<LatestReports> latestByConnector(String stationId);
}

abstract interface class SavedStationRepository {
  Future<List<String>> list();
  Future<void> add(String stationId);
  Future<void> remove(String stationId);
}

/// The driver's own connector types. **Device-local and ungated**: it is a
/// reading aid, and the read surface is anonymous (ADR-0003 as amended).
/// Only *syncing* it across devices needs an account, which is why there is
/// no `userId` here.
abstract interface class VehicleProfileRepository {
  Future<Lens> connectorTypes();
  Future<void> setConnectorTypes(Lens types);
}

abstract interface class Repositories {
  StationRepository get stations;
  ReportRepository get reports;
  SavedStationRepository get saved;
  VehicleProfileRepository get vehicle;
}
