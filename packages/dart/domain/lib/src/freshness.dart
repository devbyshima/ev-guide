/// Freshness returns structure, not a word (section 2.3), and the decay clock
/// (section 1.3).
library;

import 'availability.dart';
import 'decay.dart';
import 'types.dart';

class Freshness {
  const Freshness({
    required this.contributingSources,
    this.oldestContributingCapturedAt,
  });

  final List<ReportSource> contributingSources;
  final Millis? oldestContributingCapturedAt;
}

/// Contributors are scoped to **the leading clause's state, intersected with
/// the lens**, so the age shown always dates the claim standing next to it.
///
/// `OutOfService` reports are excluded from the age: a 30-day declaration and
/// a two-hour observation cannot share one age word.
Freshness freshness(
  List<Bay> bays,
  AvailabilityState leadingState,
  Lens lens,
  LatestReports latest,
  Millis now,
) {
  if (leadingState == AvailabilityState.outOfService ||
      leadingState == AvailabilityState.unknown) {
    return const Freshness(contributingSources: []);
  }
  final sources = <ReportSource>{};
  Millis? oldest;

  for (final bay in bays) {
    for (final c in bay.connectors) {
      if (!_inLens(c.type, lens)) continue;
      final e = effective(c, latest, now);
      if (e.state != leadingState) continue;
      final source = e.source;
      final capturedAt = e.capturedAt;
      if (source == null || capturedAt == null) continue;
      sources.add(source);
      if (oldest == null || capturedAt < oldest) oldest = capturedAt;
    }
  }
  return oldest == null
      ? Freshness(contributingSources: [...sources])
      : Freshness(
          contributingSources: [...sources],
          oldestContributingCapturedAt: oldest,
        );
}

bool _inLens(ConnectorType type, Lens lens) {
  if (lens == null || lens.isEmpty) return true;
  return lens.contains(type);
}

/// `nextDecayDeadline(displayed, now)`: the earliest future instant at which
/// any displayed value changes.
///
/// Deriving at render makes a stale value unrepresentable **only if a render
/// happens**. A screen left open across a decay boundary keeps painting the
/// old value forever, and offline there is no sync to correct it. Every
/// surface schedules a one-shot recompose here, re-derives, and reschedules.
Millis? nextDecayDeadline(
  List<Bay> bays,
  LatestReports latest,
  Millis now, [
  List<Millis> extraDeadlines = const [],
]) {
  final candidates = <Millis>[...extraDeadlines];

  for (final bay in bays) {
    for (final c in bay.connectors) {
      final r = latest[c.id];
      if (r == null || !r.sourceOnline) continue;
      final expiry = r.capturedAt + decayWindow(r.source, r.state);
      if (expiry > now) candidates.add(expiry);
    }
    // A rate's 90 days is a displayed value too; callers pass those in via
    // extraDeadlines, since not every surface renders a rate.
  }

  final future = candidates.where((t) => t > now).toList();
  if (future.isEmpty) return null;
  return future.reduce((a, b) => a < b ? a : b);
}

/// Deadlines within one minute are bucketed, so a 12-station map cannot
/// recompose 12 times in a minute.
Millis bucketDeadline(Millis deadline, Millis now) {
  final delta = deadline - now;
  if (delta <= minute) return now + minute;
  return deadline;
}
