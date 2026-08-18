/// The derivation. docs/availability-display.md section 1 is the spec; this
/// is its only implementation in Dart, a transcription of the TypeScript
/// reference (`packages/domain/src/availability.ts`) proven equivalent by the
/// shared corpus (`packages/corpus/corpus.json`, ADR-0012). The Swift and
/// Kotlin layers are transcriptions of the same function against the same
/// corpus.
///
/// The rule in words: **occupancy crosses the type boundary, brokenness does
/// not, and a free sibling never vouches for an unreported gun.**
library;

import 'decay.dart';
import 'types.dart';

/// What a derivation carries besides the state: freshness is an axis.
class EffectiveState {
  const EffectiveState({required this.state, this.source, this.capturedAt});

  final AvailabilityState state;

  /// Present only when the state came from a live report.
  final ReportSource? source;
  final Millis? capturedAt;
}

const _unknown = EffectiveState(state: AvailabilityState.unknown);

/// Latest report per connector, keyed by connector id.
typedef LatestReports = Map<String, Report>;

/// `effective(connector, now)`.
///
/// Absent, decayed, or from a source declaring itself offline yields
/// `Unknown`. The offline override is checked before recency, which is why a
/// 30-second-old report can be Unknown, and why no string may assert report
/// history (grammar law 8).
EffectiveState effective(
  Connector connector,
  LatestReports latest,
  Millis now,
) {
  final r = latest[connector.id];
  if (r == null) return _unknown;
  if (!r.sourceOnline) return _unknown;
  if (now - r.capturedAt > decayWindow(r.source, r.state)) return _unknown;
  return EffectiveState(
    state: r.state.asAvailability,
    source: r.source,
    capturedAt: r.capturedAt,
  );
}

bool _inLens(ConnectorType type, Lens lens) {
  // T = 0 (null or empty) means unlensed, and is not a special case.
  if (lens == null || lens.isEmpty) return true;
  return lens.contains(type);
}

/// `bayStateUnder(bay, T, now)`.
///
/// Clause order is load-bearing and each clause was got wrong at least once
/// during review, so the order is asserted by tests, not by this comment:
///
///   1. every in-lens gun OutOfService  -> OutOfService  (brokenness wins)
///   2. ANY connector on the bay Occupied -> Occupied    (crosses the lens)
///   3. any in-lens gun Free            -> Free
///   4. otherwise                       -> Unknown
AvailabilityState bayStateUnder(
  Bay bay,
  Lens lens,
  LatestReports latest,
  Millis now,
) {
  final lensed = bay.connectors.where((c) => _inLens(c.type, lens)).toList();
  final lensedStates = lensed
      .map((c) => effective(c, latest, now).state)
      .toList();

  // 1. Brokenness wins, and outranks occupancy: if every gun of your type on
  //    this bay is broken, the bay is useless to you even though someone is
  //    parked there. Folding this into Occupied would send you to wait at a
  //    charger that will never free.
  if (lensedStates.isNotEmpty &&
      lensedStates.every((s) => s == AvailabilityState.outOfService)) {
    return AvailabilityState.outOfService;
  }

  // 2. Occupancy crosses the type boundary: a parked car holds the whole
  //    physical position, whatever gun it is using (ADR-0008).
  final anyOccupied = bay.connectors.any(
    (c) => effective(c, latest, now).state == AvailabilityState.occupied,
  );
  if (anyOccupied) return AvailabilityState.occupied;

  // 3. A free sibling never vouches for an unreported gun, so this reads the
  //    lensed set only.
  if (lensedStates.contains(AvailabilityState.free)) {
    return AvailabilityState.free;
  }

  return AvailabilityState.unknown;
}

/// Bays carrying at least one connector whose type is in the lens.
List<Bay> baysOffering(List<Bay> bays, Lens lens) =>
    bays.where((b) => b.connectors.any((c) => _inLens(c.type, lens))).toList();

int freeBaysOffering(
  List<Bay> bays,
  Lens lens,
  LatestReports latest,
  Millis now,
) => baysOffering(bays, lens)
    .where((b) => bayStateUnder(b, lens, latest, now) == AvailabilityState.free)
    .length;

/// The counts the display grammar consumes. Each is <= the bay count.
class StateCounts {
  const StateCounts({
    required this.n,
    required this.free,
    required this.occupied,
    required this.outOfService,
    required this.unknown,
  });

  /// n: bays in scope.
  final int n;
  final int free;
  final int occupied;
  final int outOfService;
  final int unknown;
}

StateCounts countBays(
  List<Bay> bays,
  Lens lens,
  LatestReports latest,
  Millis now,
) {
  final scope = baysOffering(bays, lens);
  var free = 0;
  var occupied = 0;
  var outOfService = 0;
  var unknown = 0;
  for (final b in scope) {
    switch (bayStateUnder(b, lens, latest, now)) {
      case AvailabilityState.free:
        free += 1;
      case AvailabilityState.occupied:
        occupied += 1;
      case AvailabilityState.outOfService:
        outOfService += 1;
      case AvailabilityState.unknown:
        unknown += 1;
    }
  }
  return StateCounts(
    n: scope.length,
    free: free,
    occupied: occupied,
    outOfService: outOfService,
    unknown: unknown,
  );
}
