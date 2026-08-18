/// The mock implementation. A **first-class citizen** (ADR-0006), not a
/// stub: the apps are built entirely against it, and the BWEZE
/// implementation arrives later behind the same protocols without a screen
/// changing.
///
/// It therefore has to be honest about the things the real backend will be
/// honest about: it derives availability rather than storing it, it enforces
/// the report policy, and it ranks `stationsNear` the way the spec ranks it.
library;

import 'dart:math' as math;

import 'package:ev_guide_domain/ev_guide_domain.dart';
import 'package:ev_guide_domain/ev_guide_domain.dart'
    as domain
    show stationDetail;

import 'protocols.dart';
import 'seed.dart';

/// The proximity gate for driver reports (ticket 09).
///
/// **This radius is not stated anywhere in the spec**: ticket 09 says
/// reports are proximity-gated and never says how near. 150 m is wide enough
/// to cover a forecourt and a parking deck with consumer GPS error, and
/// tight enough that it cannot be satisfied from the road outside. Flagged
/// in ticket 37 with the two decay gaps, since it is the same class of
/// unstated policy constant.
const double reportProximityMeters = 150;

/// Car floors and caps (constraint 3): design for 6, never exceed 12.
const int nearLimitMax = 12;

/// The mutable state behind the mock, shared by the four repositories and
/// the dev handle.
class _MockState {
  _MockState({
    required this.stations,
    required this.reports,
    required this.signedIn,
  });

  final List<Station> stations;
  final List<Report> reports;
  final Set<String> saved = <String>{};
  bool signedIn;
  Lens lens;

  Station? stationById(String id) {
    for (final s in stations) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Most recent `capturedAt` wins regardless of source (ticket 11).
  LatestReports latestFor(Station station) {
    final ids = <String>{
      for (final b in station.bays)
        for (final c in b.connectors) c.id,
    };
    final m = <String, Report>{};
    for (final r in reports) {
      if (!ids.contains(r.connectorId)) continue;
      final prev = m[r.connectorId];
      if (prev == null || r.capturedAt > prev.capturedAt) {
        m[r.connectorId] = r;
      }
    }
    return m;
  }
}

class _MockStationRepository implements StationRepository {
  _MockStationRepository(this._state);

  final _MockState _state;

  @override
  Future<List<TwoLine>> stationsNear(NearQuery q, Millis now) async {
    final limit = math.min(q.limit, nearLimitMax);
    final rows = [
      for (final s in _state.stations)
        (
          row: twoLine(s, q.origin, q.lens, _state.latestFor(s), now),
          counts: countBays(s.bays, q.lens, _state.latestFor(s), now),
          distance: distanceMeters(q.origin, s.geo),
        ),
    ];

    // Ranked **distance first, then availability**. Availability is the
    // tie-break and never the primary key: a free bay 40 km away is not a
    // better answer than an unreported one across the street.
    rows.sort((a, b) {
      if (a.distance != b.distance) return a.distance.compareTo(b.distance);
      return b.counts.free.compareTo(a.counts.free);
    });

    return [for (final r in rows.take(limit)) r.row];
  }

  @override
  Future<StationDetail?> stationDetail(String id, Lens lens, Millis now) async {
    final s = _state.stationById(id);
    if (s == null) return null;
    return domain.stationDetail(s, lens, _state.latestFor(s), now);
  }

  @override
  Future<StationDelta> changedSince(Millis cursor) async {
    final changed = [
      for (final s in _state.stations)
        if (s.updatedAt > cursor) s,
    ];
    var next = cursor;
    for (final s in changed) {
      next = math.max(next, s.updatedAt);
    }
    return StationDelta(stations: changed, cursor: next);
  }
}

class _MockReportRepository implements ReportRepository {
  _MockReportRepository(this._state);

  final _MockState _state;

  @override
  Future<SubmitResult> submit(ReportDraft draft) async {
    // Acting requires an account; reading never does (ADR-0003).
    if (!_state.signedIn) {
      return const SubmitRejected(ReportRejection.notSignedIn);
    }

    Station? station;
    for (final s in _state.stations) {
      if (s.bays.any(
        (b) => b.connectors.any((c) => c.id == draft.connectorId),
      )) {
        station = s;
        break;
      }
    }
    if (station == null) {
      return const SubmitRejected(ReportRejection.unknownConnector);
    }

    // `capturedAt <= receivedAt` is a schema invariant. A client clock ahead
    // of the server would otherwise mint a report that never decays.
    final receivedAt = DateTime.now().millisecondsSinceEpoch;
    if (draft.capturedAt > receivedAt) {
      return const SubmitRejected(ReportRejection.capturedInFuture);
    }

    // Proximity is evaluated against the **captured** location, not the
    // current one: an offline report drains hours later from somewhere else
    // entirely, and gating on where the phone is now would reject it.
    final capturedLocation = draft.capturedLocation;
    if (capturedLocation != null &&
        distanceMeters(capturedLocation, station.geo) > reportProximityMeters) {
      return const SubmitRejected(ReportRejection.tooFar);
    }

    _state.reports.add(
      Report(
        connectorId: draft.connectorId,
        state: draft.state,
        source: ReportSource.driver,
        reporterId: 'mock-user',
        capturedAt: draft.capturedAt,
        receivedAt: receivedAt,
        capturedLocation: draft.capturedLocation,
        sourceOnline: draft.sourceOnline,
      ),
    );
    return const SubmitAccepted();
  }

  @override
  Future<LatestReports> latestByConnector(String stationId) async {
    final s = _state.stationById(stationId);
    return s == null ? <String, Report>{} : _state.latestFor(s);
  }
}

class _MockSavedStationRepository implements SavedStationRepository {
  _MockSavedStationRepository(this._state);

  final _MockState _state;

  @override
  Future<List<String>> list() async => [..._state.saved];

  @override
  Future<void> add(String stationId) async {
    _state.saved.add(stationId);
  }

  @override
  Future<void> remove(String stationId) async {
    _state.saved.remove(stationId);
  }
}

class _MockVehicleProfileRepository implements VehicleProfileRepository {
  _MockVehicleProfileRepository(this._state);

  final _MockState _state;

  @override
  Future<Lens> connectorTypes() async => _state.lens;

  @override
  Future<void> setConnectorTypes(Lens types) async {
    _state.lens = types;
  }
}

/// The dev-only controls behind [MockRepositories.dev].
class MockDevHandle {
  MockDevHandle._(this._state);

  final _MockState _state;

  void setSignedIn(bool value) {
    _state.signedIn = value;
  }

  int reportCount() => _state.reports.length;
}

/// The mock exposes a small [dev] handle beside the protocols. It is a
/// separate property rather than extra methods on the repositories, so a
/// screen holding a [Repositories] cannot reach it and the seam stays
/// honest.
final class MockRepositories implements Repositories {
  MockRepositories._({
    required this.stations,
    required this.reports,
    required this.saved,
    required this.vehicle,
    required this.dev,
  });

  @override
  final StationRepository stations;

  @override
  final ReportRepository reports;

  @override
  final SavedStationRepository saved;

  @override
  final VehicleProfileRepository vehicle;

  final MockDevHandle dev;
}

/// [signedIn] is false by default. Anonymous by default: the whole read
/// surface is ungated (ADR-0003).
///
/// When [stations] or [reports] are omitted, the seed is anchored to the
/// wall clock at creation, so the demo data is alive when rendered
/// (ADR-0012).
MockRepositories createMockRepositories({
  List<Station>? stations,
  List<Report>? reports,
  bool signedIn = false,
}) {
  final seededAt = DateTime.now().millisecondsSinceEpoch;
  final state = _MockState(
    stations: [...(stations ?? seedStations(now: seededAt))],
    reports: [...(reports ?? seedReports(now: seededAt))],
    signedIn: signedIn,
  );
  return MockRepositories._(
    stations: _MockStationRepository(state),
    reports: _MockReportRepository(state),
    saved: _MockSavedStationRepository(state),
    vehicle: _MockVehicleProfileRepository(state),
    dev: MockDevHandle._(state),
  );
}
