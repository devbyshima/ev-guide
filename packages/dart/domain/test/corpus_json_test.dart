/// The drift guard for the corpus-as-data mechanism (ADR-0012).
///
/// `packages/corpus/corpus.json` is the language-neutral serialisation of the
/// shared fixture corpus, docs/availability-display.md section 3. Four
/// executors run it: server (TypeScript), phone (Dart), CarPlay (Swift),
/// Android Auto (Kotlin). This suite is the Dart executor, mirroring the
/// TypeScript reference runner (`packages/domain/test/corpus-json.test.ts`)
/// check for check. It runs every case and every check against this
/// transcription, so if corpus.json and this package ever disagree, this file
/// fails and the drift is caught before it ships. A transcription of the
/// derivation is proven equivalent or it does not ship.
///
/// Fixture 4 (rates are per plug, not per bay) is structural: it asserts the
/// absence of a bay-level rate field, which no serialisation can carry. It
/// stays a language-native test in structural_test.dart, and on every other
/// side.
library;

import 'dart:convert';
import 'dart:io';

import 'package:ev_guide_domain/ev_guide_domain.dart';
import 'package:test/test.dart';

/*
 * The JSON's shape, read locally: the corpus is data, not an exported API.
 * The executors in the other three languages carry their own reading of the
 * same schema, which is the point.
 */

/// The corpus lives at ../../../corpus/corpus.json relative to this test
/// file. Dart has no __dirname, so resolve by walking up from the working
/// directory until `packages/corpus/corpus.json` appears: `dart test` runs
/// from the package root (packages/dart/domain), and the walk also covers a
/// runner invoked from the repo root or anywhere between.
File _corpusFile() {
  var dir = Directory.current.absolute;
  while (true) {
    final candidate = File('${dir.path}/packages/corpus/corpus.json');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'packages/corpus/corpus.json not found walking up from '
        '${Directory.current.path}',
      );
    }
    dir = parent;
  }
}

ReportedState _reportedState(String wire) => switch (wire) {
  'Free' => ReportedState.free,
  'Occupied' => ReportedState.occupied,
  'OutOfService' => ReportedState.outOfService,
  _ => throw StateError('corpus names unknown reported state: $wire'),
};

AvailabilityState _availabilityState(String wire) => switch (wire) {
  'Free' => AvailabilityState.free,
  'Occupied' => AvailabilityState.occupied,
  'OutOfService' => AvailabilityState.outOfService,
  'Unknown' => AvailabilityState.unknown,
  _ => throw StateError('corpus names unknown availability state: $wire'),
};

/// `null` means unlensed, which the domain spells `null` too (T = 0).
Lens _toLens(Object? lens) => lens == null
    ? null
    : [for (final t in lens as List<Object?>) ConnectorType(t! as String)];

List<Bay> _materialiseBays(Map<String, Object?> c) => [
  for (final b in c['bays']! as List<Object?>)
    Bay(
      id: (b! as Map<String, Object?>)['id']! as String,
      stationId: 's1',
      connectors: [
        for (final conn
            in (b as Map<String, Object?>)['connectors']! as List<Object?>)
          Connector(
            id: (conn! as Map<String, Object?>)['id']! as String,
            bayId: b['id']! as String,
            type: ConnectorType(
              (conn as Map<String, Object?>)['type']! as String,
            ),
          ),
      ],
    ),
];

/// `capturedAt` is defined as `now - ageMs`; latest per connector wins, by
/// capturedAt, exactly as the TypeScript runner materialises it.
LatestReports _materialiseReports(Map<String, Object?> c, Millis now) {
  final m = <String, Report>{};
  for (final entry in c['reports']! as List<Object?>) {
    final r = entry! as Map<String, Object?>;
    final capturedAt = now - (r['ageMs']! as int);
    final report = Report(
      connectorId: r['connectorId']! as String,
      state: _reportedState(r['state']! as String),
      source: ReportSource.values.byName(r['source']! as String),
      reporterId: 'corpus',
      capturedAt: capturedAt,
      receivedAt: capturedAt,
      sourceOnline: r['sourceOnline']! as bool,
    );
    final prev = m[report.connectorId];
    if (prev == null || report.capturedAt > prev.capturedAt) {
      m[report.connectorId] = report;
    }
  }
  return m;
}

Bay _findBay(List<Bay> bays, String id) => bays.firstWhere(
  (b) => b.id == id,
  orElse: () => throw StateError('corpus check names unknown bay: $id'),
);

Connector _findConnector(List<Bay> bays, String id) {
  for (final b in bays) {
    for (final c in b.connectors) {
      if (c.id == id) return c;
    }
  }
  throw StateError('corpus check names unknown connector: $id');
}

String _lensLabel(Object? lens) =>
    lens == null ? 'unlensed' : 'lens=[${(lens as List<Object?>).join(', ')}]';

String _checkLabel(Map<String, Object?> check) {
  final kind = check['kind']! as String;
  switch (kind) {
    case 'bayState':
      return 'bayState(${check['bayId']}, ${_lensLabel(check['lens'])}, '
          '+${check['nowOffsetMs']}ms) is ${check['expect']}';
    case 'effective':
      return 'effective(${check['connectorId']}, +${check['nowOffsetMs']}ms) '
          'is ${check['expect']}';
    case 'counts':
      return 'counts under ${_lensLabel(check['lens'])}';
    case 'grammar':
      return 'grammar under ${_lensLabel(check['lens'])} at '
          '${check['verbosity']} is regime ${check['expectRegime']}';
    case 'deadline':
      return 'nextDecayDeadline is ${check['expect'] ?? 'null'}';
    default:
      return kind;
  }
}

void _runCheck(Map<String, Object?> check, Map<String, Object?> c, Millis now) {
  final bays = _materialiseBays(c);
  final latest = _materialiseReports(c, now);

  switch (check['kind']! as String) {
    case 'bayState':
      final state = bayStateUnder(
        _findBay(bays, check['bayId']! as String),
        _toLens(check['lens']),
        latest,
        now + (check['nowOffsetMs']! as int),
      );
      expect(state, _availabilityState(check['expect']! as String));
    case 'effective':
      final e = effective(
        _findConnector(bays, check['connectorId']! as String),
        latest,
        now + (check['nowOffsetMs']! as int),
      );
      expect(e.state, _availabilityState(check['expect']! as String));
    case 'counts':
      final counts = countBays(bays, _toLens(check['lens']), latest, now);
      final expected = check['expect']! as Map<String, Object?>;
      expect(counts.n, expected['n']);
      expect(counts.free, expected['free']);
      expect(counts.occupied, expected['occupied']);
      expect(counts.outOfService, expected['outOfService']);
      expect(counts.unknown, expected['unknown']);
    case 'grammar':
      // Counts are derived from the fixture, then fed to the grammar: the
      // corpus never carries a count the derivation did not produce.
      final counts = countBays(bays, _toLens(check['lens']), latest, now);
      final g = grammar(
        GrammarInput.fromCounts(counts, otherBays: check['otherBays']! as int),
        Verbosity.values.byName(check['verbosity']! as String),
      );
      expect(g.regime, check['expectRegime']);
      final expectText = check['expectText'];
      if (expectText != null) expect(g.text, expectText);
      for (final banned in check['notContains']! as List<Object?>) {
        expect(g.text, isNot(contains(banned)), reason: 'banned: $banned');
      }
    case 'deadline':
      final deadline = nextDecayDeadline(bays, latest, now);
      expect(deadline, check['expect']);
    default:
      // A check kind this executor does not know is a corpus change that
      // must fail loudly, never pass vacuously.
      throw StateError('unknown check kind: ${jsonEncode(check)}');
  }
}

void main() {
  final corpus =
      jsonDecode(_corpusFile().readAsStringSync()) as Map<String, Object?>;
  final now = corpus['now']! as Millis;

  group(
    'corpus.json: the derivation fixtures execute against the Dart port',
    () {
      for (final entry in corpus['cases']! as List<Object?>) {
        final c = entry! as Map<String, Object?>;
        for (final checkEntry in c['checks']! as List<Object?>) {
          final check = checkEntry! as Map<String, Object?>;
          test('${c['id']} (${c['title']}): ${_checkLabel(check)}', () {
            _runCheck(check, c, now);
          });
        }
      }
    },
  );

  group('corpus.json: the grammar law cases execute against the Dart port', () {
    for (final entry in corpus['grammarCases']! as List<Object?>) {
      final g = entry! as Map<String, Object?>;
      test('${g['id']} (${g['title']})', () {
        final counts = g['counts']! as Map<String, Object?>;
        final result = grammar(
          GrammarInput(
            n: counts['n']! as int,
            free: counts['free']! as int,
            occupied: counts['occupied']! as int,
            outOfService: counts['outOfService']! as int,
            unknown: counts['unknown']! as int,
            otherBays: g['otherBays']! as int,
          ),
          Verbosity.values.byName(g['verbosity']! as String),
        );
        expect(result.regime, g['expectRegime']);
        final expectText = g['expectText'];
        if (expectText != null) expect(result.text, expectText);
        for (final banned in g['notContains']! as List<Object?>) {
          expect(
            result.text,
            isNot(contains(banned)),
            reason: 'banned: $banned',
          );
        }
        if (g['forbiddenSweep']! as bool) {
          // Law 8's mechanical half, exactly as the TS runner sweeps it: no
          // forbidden substring may survive into any emitted string.
          for (final banned in forbiddenSubstrings) {
            expect(
              result.text.toLowerCase(),
              isNot(contains(banned)),
              reason: 'forbidden: $banned',
            );
          }
        }
      });
    }
  });
}
