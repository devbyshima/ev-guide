/// The language-native half of the shared suite (ADR-0012): everything the
/// corpus JSON cannot carry.
///
/// Three groups live here:
/// 1. Fixture 4 of docs/availability-display.md section 3, which asserts the
///    absence of a bay-level rate field. No serialisation can carry an
///    absence, so it stays a language-native test on every side.
/// 2. The vocabulary as data: sentinel values of the closed vocabulary and
///    the two forbidden lists, byte-for-byte against the TypeScript
///    reference, because a transcription may not invent (or drift) a word.
/// 3. The section 2.2 law sweeps of packages/domain/test/grammar.test.ts that
///    run exhaustively over every partition of n bays. "For any input" is
///    what the laws say, and an exhaustive loop cannot serialise as fixture
///    data, so the sweeps are transcribed here.
library;

import 'package:ev_guide_domain/ev_guide_domain.dart';
import 'package:test/test.dart';

/// Every partition of n bays into the four states, for n up to 5.
Iterable<GrammarInput> allCounts([int maxN = 5]) sync* {
  for (var n = 0; n <= maxN; n += 1) {
    for (var free = 0; free <= n; free += 1) {
      for (var occupied = 0; occupied <= n - free; occupied += 1) {
        for (
          var outOfService = 0;
          outOfService <= n - free - occupied;
          outOfService += 1
        ) {
          final unknown = n - free - occupied - outOfService;
          yield GrammarInput(
            n: n,
            free: free,
            occupied: occupied,
            outOfService: outOfService,
            unknown: unknown,
          );
        }
      }
    }
  }
}

String _label(GrammarInput c) =>
    'n=${c.n} free=${c.free} occupied=${c.occupied} '
    'outOfService=${c.outOfService} unknown=${c.unknown} '
    'otherBays=${c.otherBays}';

const _verbosities = Verbosity.values;

void main() {
  group('4. rates are per plug, not per bay', () {
    test('a dual-gun bay can carry two distinct rates and a session fee', () {
      const now = 1760000000000;
      const b = Bay(
        id: 'b1',
        stationId: 's1',
        connectors: [
          Connector(
            id: 'c1',
            bayId: 'b1',
            type: ConnectorType.iec62196T2,
            ratePerKwhRwf: 600,
            rateConfirmedAt: now,
          ),
          Connector(
            id: 'c2',
            bayId: 'b1',
            type: ConnectorType.gbtDc,
            ratePerKwhRwf: 400,
            sessionFeeRwf: 500,
            rateConfirmedAt: now,
          ),
        ],
      );
      final rates = b.connectors.map((c) => c.ratePerKwhRwf).toSet();
      expect(rates.length, 2);
      expect(b.connectors.where((c) => c.sessionFeeRwf != null).length, 1);
      // Law 7: rate is denominated in plugs. There is no bay-level rate field
      // to read, which is the structural half of that law: the Bay class
      // declares none, so `b.ratePerKwhRwf` is a compile error here, the
      // Dart counterpart of the TS `not.toHaveProperty` assertion.
    });
  });

  group('the vocabulary is data, byte-for-byte', () {
    test('the closed vocabulary carries the exact reference strings', () {
      expect(words.free, 'free');
      expect(words.busy, 'busy');
      expect(words.outOfService, 'out of service');
      expect(words.unknown, 'unknown');
      expect(words.bay, 'bay');
      expect(words.bays, 'bays');
      // Never "no recent report" (law 8): the offline override yields
      // Unknown from a 30-second-old report.
      expect(words.noConfirmedStatus, 'no confirmed status');
      expect(words.noConfirmedRate, 'no confirmed rate');
      expect(words.all, 'All');
      expect(words.of, 'of');
      expect(words.other, 'other');
      // The operator write-surface control label, the only capitalised form.
      expect(words.busyControlLabel, 'Busy');
    });

    test('the forbidden-substring list is the exact section 2.2b union', () {
      expect(forbiddenSubstrings, [
        'unreported',
        'not reported',
        'no recent report',
        'no report yet',
        'no reports yet',
        'last reported',
        'awaiting a report',
        'unknown rate',
        'rate unavailable',
        'no rate reported',
        'no published rate',
        'real-time',
        'realtime',
        'in use',
      ]);
      expect(
        forbiddenCatchall,
        'any phrasing that asserts a report exists, does not exist, or is old',
      );
    });

    test('the copy-pattern list carries section 2.2b row 3 as words', () {
      // Row 3's second word is enforced here rather than in the list above,
      // because as bare letters `live` fires on `delivered` and fifteen other
      // words in this repository as of 935a9b5. copy_surface_test.dart is
      // what runs these against copy; this pins them as data, the way the
      // substring list is pinned.
      expect(forbiddenCopyPatterns, [r'\blive\b', r'\breal-?time\b']);
    });

    test('connector type-words are the section 2.4 projection', () {
      expect(connectorTypeWord(ConnectorType.iec62196T2), 'Type 2');
      expect(connectorTypeWord(ConnectorType.iec62196T2Combo), 'CCS2');
      expect(connectorTypeWord(ConnectorType.gbtAc), 'GB/T AC');
      expect(connectorTypeWord(ConnectorType.gbtDc), 'GB/T DC');
      expect(connectorTypeWord(ConnectorType.other), 'Other plug');
      expect(connectorTypeWord(ConnectorType.unknown), 'Other plug');
      // The enum is open, and Android can hand us a member we do not know.
      expect(connectorTypeWord(const ConnectorType('SAE_J3400')), 'Other plug');
    });
  });

  group('law 1: "0 of N" is never emitted, for any input', () {
    test('holds across every partition and verbosity', () {
      for (final c in allCounts()) {
        for (final v in _verbosities) {
          final text = grammar(c, v).text;
          expect(
            text,
            isNot(matches(RegExp(r'\b0 of\b'))),
            reason: '${_label(c)} verbosity=$v',
          );
        }
      }
    });
  });

  group('law 2: a total appears only when u = 0', () {
    test('no "of" clause survives while anything is unknown', () {
      for (final c in allCounts()) {
        if (c.unknown == 0) continue;
        for (final v in _verbosities) {
          final text = grammar(c, v).text;
          // A "total" is the "N of M" construction. Note that the bare
          // substring "of" also occurs inside "out of service", which is why
          // this matches the construction and not the word.
          expect(
            text,
            isNot(matches(RegExp(r'\d+ of \d+'))),
            reason: _label(c),
          );
          expect(text, isNot(matches(RegExp(r'\bAll\b'))), reason: _label(c));
        }
      }
    });
  });

  group('law 3: busy quantifies o and nothing else', () {
    test('the number attached to busy is always exactly o', () {
      for (final c in allCounts()) {
        final text = grammar(c).text;
        final m = RegExp(r'(\d+) busy').firstMatch(text);
        if (m != null) {
          expect(int.parse(m.group(1)!), c.occupied, reason: _label(c));
        }
        // And when nothing is occupied the word cannot appear at all.
        if (c.occupied == 0) {
          expect(text, isNot(contains(words.busy)), reason: _label(c));
        }
      }
    });
  });

  group('law 4: OutOfService never folds into occupancy, '
      'and survives the shortest variant', () {
    test(
      'carries its own clause with its own count, never folded into busy',
      () {
        for (final c in allCounts()) {
          if (c.outOfService == 0) continue;
          final text = grammar(c).text;
          // It appears, counted separately...
          expect(
            text,
            contains('${c.outOfService} ${words.outOfService}'),
            reason: _label(c),
          );
          // ...and the busy clause, if any, still quantifies only o. The
          // failure this guards is a roll-up that reports "3 busy" over 2
          // occupied bays and 1 broken one, which sends a driver to wait for a
          // repair.
          final m = RegExp(r'(\d+) busy').firstMatch(text);
          if (m != null) {
            expect(
              int.parse(m.group(1)!),
              isNot(c.occupied + c.outOfService),
              reason: _label(c),
            );
          }
        }
      },
    );

    test('survives to minimal verbosity whenever x > 0', () {
      for (final c in allCounts()) {
        if (c.outOfService == 0) continue;
        final text = grammar(c, Verbosity.minimal).text;
        expect(text, contains(words.outOfService), reason: _label(c));
      }
    });
  });

  group('law 5: never "all" beside "busy" when x > 0', () {
    test('holds across every partition', () {
      for (final c in allCounts()) {
        final text = grammar(c).text;
        if (c.outOfService > 0) {
          expect(text, isNot(contains(words.all)), reason: _label(c));
        }
      }
    });
  });

  group('law 6: singular forms', () {
    test('never emits "1 of 1" or "All 1"', () {
      for (final c in allCounts()) {
        for (final v in _verbosities) {
          final text = grammar(c, v).text;
          expect(text, isNot(contains('1 of 1')));
          expect(text, isNot(contains('All 1')));
        }
      }
    });
  });

  group('law 8: no string asserts report history', () {
    test('no forbidden substring is emitted, for any input or verbosity', () {
      for (final c in allCounts()) {
        for (final v in _verbosities) {
          for (final input in [c, GrammarInput.fromCounts(c, otherBays: 2)]) {
            final text = grammar(input, v).text;
            for (final banned in forbiddenSubstrings) {
              expect(
                text.toLowerCase(),
                isNot(contains(banned)),
                reason: '${_label(input)} / $banned',
              );
            }
          }
        }
      }
    });
  });

  group('the three regimes partition the space', () {
    test('every input falls in exactly one regime, '
        'and regime 1 carries no state word', () {
      final stateWords = [
        words.free,
        words.busy,
        words.outOfService,
        words.unknown,
      ];
      for (final c in allCounts()) {
        final r = regimeOf(c);
        expect([1, 2, 3], contains(r));
        if (r == 1 && c.n > 0) {
          final text = grammar(c).text;
          // Regime 1 is capacity only: never a state word, because "0 free"
          // over unreported bays claims they are not free.
          for (final w in stateWords) {
            expect(text, isNot(contains(w)), reason: _label(c));
          }
          expect(text, contains(words.noConfirmedStatus));
        }
      }
    });
  });
}
