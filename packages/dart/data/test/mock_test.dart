/// The mock is a first-class citizen, so it is tested like one. These are
/// the behaviours the BWEZE implementation will have to reproduce, which is
/// the point of testing them against the protocol rather than against the
/// mock's internals.
library;

import 'package:ev_guide_data/ev_guide_data.dart';
import 'package:ev_guide_domain/ev_guide_domain.dart';
import 'package:test/test.dart';

const kigali = GeoPoint(lat: -1.9441, lng: 30.0619);

/// A fixed render clock. The seed anchors its ages to whatever `now` the
/// caller passes (ADR-0012), so the value itself is arbitrary.
const Millis t0 = 1800000000000;

MockRepositories seededRepos({Millis now = t0, bool signedIn = false}) =>
    createMockRepositories(
      stations: seedStations(now: now),
      reports: seedReports(now: now),
      signedIn: signedIn,
    );

void main() {
  group('stationsNear', () {
    test(
      'ranks distance first, with availability only as the tie-break',
      () async {
        final repos = seededRepos();
        final rows = await repos.stations.stationsNear(
          const NearQuery(origin: kigali, limit: 6),
          t0,
        );

        final distances = [for (final r in rows) r.distanceMeters];
        expect(distances, [...distances]..sort());

        // The rule that matters: a free bay far away never outranks a nearer
        // station whose bays nobody has reported.
        expect(rows.any((r) => r.stationId == 'st-rubavu'), isFalse);
      },
    );

    test(
      'honours the requested limit and caps it at the car ceiling',
      () async {
        final repos = seededRepos();
        expect(
          await repos.stations.stationsNear(
            const NearQuery(origin: kigali, limit: 3),
            t0,
          ),
          hasLength(3),
        );

        final asked = await repos.stations.stationsNear(
          const NearQuery(origin: kigali, limit: 50),
          t0,
        );
        expect(asked.length, lessThanOrEqualTo(nearLimitMax));
      },
    );

    test(
      'takes an arbitrary origin, never a hardcoded device location',
      () async {
        final repos = seededRepos();
        final fromMusanze = await repos.stations.stationsNear(
          const NearQuery(
            origin: GeoPoint(lat: -1.4995, lng: 29.6349),
            limit: 1,
          ),
          t0,
        );
        // An App Store reviewer's mock GPS has to be able to reach this.
        expect(fromMusanze.first.stationId, 'st-musanze');
      },
    );

    test('returns structure, never a formatted distance string', () async {
      final repos = seededRepos();
      final rows = await repos.stations.stationsNear(
        const NearQuery(origin: kigali, limit: 1),
        t0,
      );
      final row = rows.first;
      expect(row.distanceMeters, isA<double>());
      // TS asserts over the serialised row; here the string-typed fields are
      // the only place a formatted distance could hide.
      expect(
        RegExp(r'\d\s?km').hasMatch('${row.nameShort} ${row.availabilityText}'),
        isFalse,
      );
    });
  });

  group('derivation runs at read time', () {
    test(
      'the same data yields a different answer as the clock moves',
      () async {
        final repos = seededRepos();
        Future<StationDetail> at(Millis now) async =>
            (await repos.stations.stationDetail('st-nyarutarama', null, now))!;

        final fresh = await at(t0);
        expect([
          for (final b in fresh.bays) b.state,
        ], contains(AvailabilityState.free));

        // Six hours on, the operator window has closed and nothing was
        // resynced.
        final later = await at(t0 + 6 * hour + minute);
        expect(
          later.bays.every((b) => b.state == AvailabilityState.unknown),
          isTrue,
        );
      },
    );

    test(
      'an offline source yields Unknown from a 30-second-old report',
      () async {
        final repos = seededRepos();
        final detail = (await repos.stations.stationDetail(
          'st-nyabugogo',
          null,
          t0,
        ))!;
        final bay2 = detail.bays.firstWhere(
          (b) => b.bayId == 'st-nyabugogo-bay-2',
        );
        expect(bay2.state, AvailabilityState.unknown);
      },
    );

    test(
      'exposes per-connector state so a broken gun is visible unlensed',
      () async {
        final repos = seededRepos();
        final detail = (await repos.stations.stationDetail(
          'st-remera',
          null,
          t0,
        ))!;
        final broken = [
          for (final c in detail.connectors)
            if (c.state == AvailabilityState.outOfService) c,
        ];
        expect(broken, hasLength(1));
      },
    );
  });

  group('rateCoverage is denominated in plugs', () {
    test(
      'counts plugs and reports distinct rates on a dual-rate bay',
      () async {
        final repos = seededRepos();
        final detail = (await repos.stations.stationDetail(
          'st-nyabugogo',
          null,
          t0,
        ))!;
        final coverage = detail.rateCoverage;

        expect(coverage.totalPlugs, 4);
        expect(coverage.confirmedPlugs, 4);
        // The dual-gun bay carries 450 and 600; the two DC bays carry 700.
        expect(coverage.distinctRates, [450, 600, 700]);
      },
    );

    test('drops a rate older than its 90-day window', () async {
      final repos = seededRepos();
      final detail = (await repos.stations.stationDetail(
        'st-musanze',
        null,
        t0,
      ))!;
      expect(detail.rateCoverage.confirmedPlugs, 0);
      expect(detail.rateCoverage.totalPlugs, 2);
    });
  });

  group('report policy', () {
    final stations = seedStations(now: t0);
    String connectorOf(String stationId) => stations
        .firstWhere((s) => s.id == stationId)
        .bays
        .first
        .connectors
        .first
        .id;

    Matcher rejectedWith(ReportRejection reason) =>
        isA<SubmitRejected>().having((r) => r.reason, 'reason', reason);

    test(
      'rejects an anonymous report: reading is ungated, acting is not',
      () async {
        final repos = seededRepos();
        final r = await repos.reports.submit(
          ReportDraft(
            connectorId: connectorOf('st-remera'),
            state: ReportedState.free,
            capturedAt: DateTime.now().millisecondsSinceEpoch,
            sourceOnline: true,
          ),
        );
        expect(r, rejectedWith(ReportRejection.notSignedIn));
      },
    );

    test('rejects a report captured too far away', () async {
      final repos = seededRepos(signedIn: true);
      final r = await repos.reports.submit(
        ReportDraft(
          connectorId: connectorOf('st-remera'),
          state: ReportedState.free,
          capturedAt: DateTime.now().millisecondsSinceEpoch,
          capturedLocation: kigali,
          sourceOnline: true,
        ),
      );
      expect(r, rejectedWith(ReportRejection.tooFar));
    });

    test('accepts a report captured within the gate', () async {
      final repos = seededRepos(signedIn: true);
      final station = stations.firstWhere((s) => s.id == 'st-remera');
      final r = await repos.reports.submit(
        ReportDraft(
          connectorId: connectorOf('st-remera'),
          state: ReportedState.free,
          capturedAt: DateTime.now().millisecondsSinceEpoch,
          capturedLocation: station.geo,
          sourceOnline: true,
        ),
      );
      expect(r, isA<SubmitAccepted>());
    });

    test('gates on the CAPTURED location, so an offline report drains later '
        'from elsewhere', () async {
      final repos = seededRepos(signedIn: true);
      final station = stations.firstWhere((s) => s.id == 'st-remera');
      // Captured at the station hours ago; submitted now from across town.
      final r = await repos.reports.submit(
        ReportDraft(
          connectorId: connectorOf('st-remera'),
          state: ReportedState.occupied,
          capturedAt: DateTime.now().millisecondsSinceEpoch - 90 * minute,
          capturedLocation: station.geo,
          sourceOnline: false,
        ),
      );
      expect(r, isA<SubmitAccepted>());
    });

    test('rejects a capturedAt in the future', () async {
      final repos = seededRepos(signedIn: true);
      final r = await repos.reports.submit(
        ReportDraft(
          connectorId: connectorOf('st-remera'),
          state: ReportedState.free,
          capturedAt: DateTime.now().millisecondsSinceEpoch + 10 * minute,
          sourceOnline: true,
        ),
      );
      expect(r, rejectedWith(ReportRejection.capturedInFuture));
    });

    test('the proximity gate is wide enough for a forecourt, tight enough for '
        'the road', () {
      final station = stations.first;
      final acrossTheForecourt = GeoPoint(
        lat: station.geo.lat + 0.0008,
        lng: station.geo.lng,
      );
      final acrossTown = GeoPoint(
        lat: station.geo.lat + 0.02,
        lng: station.geo.lng,
      );
      expect(
        distanceMeters(station.geo, acrossTheForecourt),
        lessThan(reportProximityMeters),
      );
      expect(
        distanceMeters(station.geo, acrossTown),
        greaterThan(reportProximityMeters),
      );
    });
  });

  group('changedSince', () {
    test('returns only rows past the cursor and advances it', () async {
      final repos = seededRepos();
      const cursor = t0 - 10 * 24 * hour;
      final first = await repos.stations.changedSince(cursor);
      expect(first.stations.every((s) => s.updatedAt > cursor), isTrue);
      expect(first.cursor, greaterThan(cursor));

      final second = await repos.stations.changedSince(first.cursor);
      expect(second.stations, isEmpty);
    });
  });

  group('the seed is honest about how little is known', () {
    test('leaves most connectors unreported, because ~87% Unknown is the '
        'normal case', () {
      final connectors = [
        for (final s in seedStations(now: t0))
          for (final b in s.bays) ...b.connectors,
      ];
      final reported = {for (final r in seedReports(now: t0)) r.connectorId};
      expect(reported.length / connectors.length, lessThan(0.5));
    });
  });

  group('the seed anchors to the render clock', () {
    test(
      'derives a non-Unknown state at any now, not only at a dead epoch',
      () async {
        // ADR-0012: the TS seed pinned SEED_NOW to a 2025 instant, so by 2026
        // every report had decayed and every station derived Unknown. Ages
        // anchor to the caller's clock instead, so any render time works.
        final nows = [
          t0,
          DateTime.now().millisecondsSinceEpoch,
          DateTime.utc(2031, 1, 1).millisecondsSinceEpoch,
        ];
        for (final now in nows) {
          final repos = seededRepos(now: now);
          final detail = (await repos.stations.stationDetail(
            'st-remera',
            null,
            now,
          ))!;
          expect(
            detail.bays.any((b) => b.state != AvailabilityState.unknown),
            isTrue,
            reason: 'seed derived all-Unknown at now=$now',
          );
        }
      },
    );
  });
}
