/// The display grammar, docs/availability-display.md section 2.
///
/// `G(n, f, o, x, u, verbosity, lens) -> clauses`, with one fixed drop order.
/// Three regimes partition the space and they are the whole grammar.
///
/// Every law in section 2.2 is enforced here and asserted by the shared
/// corpus (`packages/corpus/corpus.json`) plus test/structural_test.dart. The
/// laws are not comments: a law without a test is a suggestion.
library;

import 'availability.dart';
import 'vocabulary.dart';

enum Verbosity { full, short, minimal }

/// 1, 2 or 3; see [regimeOf].
typedef Regime = int;

class GrammarInput extends StateCounts {
  const GrammarInput({
    required super.n,
    required super.free,
    required super.occupied,
    required super.outOfService,
    required super.unknown,
    this.otherBays = 0,
  });

  GrammarInput.fromCounts(StateCounts c, {int otherBays = 0})
    : this(
        n: c.n,
        free: c.free,
        occupied: c.occupied,
        outOfService: c.outOfService,
        unknown: c.unknown,
        otherBays: otherBays,
      );

  /// Bays outside the lens. Named **once, uncounted** on one side of the
  /// partition ("2 other bays"), never folded into the counts.
  final int otherBays;
}

class GrammarResult {
  const GrammarResult({
    required this.regime,
    required this.clauses,
    required this.text,
  });

  final Regime regime;
  final List<String> clauses;

  /// The clauses joined with the separator every surface uses.
  final String text;
}

const _sep = ' · ';

String _pluralBays(int k) => '$k ${k == 1 ? words.bay : words.bays}';

Regime regimeOf(StateCounts c) {
  if (c.free == 0 && c.occupied == 0 && c.outOfService == 0) return 1;
  if (c.unknown == 0) return 2;
  return 3;
}

/// The drop order, applied when verbosity is reduced. Section 2.1 requires
/// "one fixed drop order" without enumerating it; this is that enumeration,
/// and it is constrained by **law 4** (OutOfService survives to the shortest
/// variant of every string), which is why `outOfService` is last to go.
///
/// Dropped first -> last: unknown, occupied, free, outOfService.
const _dropOrder = [
  _ClauseKey.unknown,
  _ClauseKey.occupied,
  _ClauseKey.free,
  _ClauseKey.outOfService,
];

enum _ClauseKey { unknown, occupied, free, outOfService }

const Map<Verbosity, int> _keepByVerbosity = {
  Verbosity.full: 4,
  Verbosity.short: 2,
  Verbosity.minimal: 1,
};

GrammarResult grammar(
  GrammarInput input, [
  Verbosity verbosity = Verbosity.full,
]) {
  final regime = regimeOf(input);
  final clauses = switch (regime) {
    1 => _regime1(input),
    2 => _regime2(input, verbosity),
    _ => _regime3(input, verbosity),
  };

  final withRemainder = _appendRemainder(clauses, input);
  return GrammarResult(
    regime: regime,
    clauses: withRemainder,
    text: withRemainder.join(_sep),
  );
}

/// Regime 1: everything in scope is Unknown. Capacity clause only, and
/// **never a state word**: saying "0 free" over bays nobody has reported
/// claims they are not free, and at ~87% Unknown that is the normal case.
List<String> _regime1(GrammarInput c) {
  if (c.n == 0) return [];
  return [_pluralBays(c.n), words.noConfirmedStatus];
}

/// Regime 2: nothing is Unknown, so the denominator **is** the known set by
/// construction and a total is permitted (law 2).
List<String> _regime2(GrammarInput c, Verbosity verbosity) {
  // Law 5: never "all" beside "busy" when x > 0, because "all" would be
  // quantifying a set that contains out-of-service bays.
  if (c.free == c.n && c.n > 1 && c.outOfService == 0) {
    return ['${words.all} ${c.n} ${words.bays} ${words.free}'];
  }

  final parts = <String>[];
  if (c.free > 0) {
    // Law 6: no "1 of 1". Law 1: "0 of N" is unreachable here anyway, since a
    // zero free count simply emits no free clause.
    parts.add(
      c.n == 1
          ? '${_pluralBays(1)} ${words.free}'
          : '${c.free} ${words.of} ${_pluralBays(c.n)} ${words.free}',
    );
  }
  // Law 3: busy quantifies o and nothing else. Law 4: out of service never
  // folds into occupancy at any count.
  if (c.occupied > 0) parts.add('${c.occupied} ${words.busy}');
  if (c.outOfService > 0) parts.add('${c.outOfService} ${words.outOfService}');

  if (parts.isEmpty) return [_pluralBays(c.n)];
  return _trim(parts, c, verbosity);
}

/// Regime 3: mixed. Counts **without** a total, because a denominator here
/// would be counting bays whose state nobody knows (law 1, law 2).
List<String> _regime3(GrammarInput c, Verbosity verbosity) {
  final parts = <String>[];
  if (c.free > 0) parts.add('${c.free} ${words.free}');
  if (c.occupied > 0) parts.add('${c.occupied} ${words.busy}');
  if (c.outOfService > 0) parts.add('${c.outOfService} ${words.outOfService}');
  if (c.unknown > 0) parts.add('${c.unknown} ${words.unknown}');
  return _trim(parts, c, verbosity);
}

/// Apply the fixed drop order. Out-of-service is preserved even at `minimal`,
/// per law 4, so a shortened string can carry it alone.
List<String> _trim(List<String> parts, GrammarInput c, Verbosity verbosity) {
  final keep = _keepByVerbosity[verbosity]!;
  if (parts.length <= keep) return parts;

  final survivors = [for (final text in parts) (text: text, key: _keyOf(text))];
  for (final dropKey in _dropOrder) {
    if (survivors.length <= keep) break;
    // Law 4: out of service is never dropped while anything else remains.
    if (dropKey == _ClauseKey.outOfService &&
        c.outOfService > 0 &&
        survivors.length > 1) {
      continue;
    }
    final i = survivors.indexWhere((p) => p.key == dropKey);
    if (i >= 0) survivors.removeAt(i);
  }
  return [for (final p in survivors) p.text];
}

_ClauseKey _keyOf(String text) {
  if (text.contains(words.outOfService)) return _ClauseKey.outOfService;
  if (text.contains(words.busy)) return _ClauseKey.occupied;
  if (text.contains(words.unknown)) return _ClauseKey.unknown;
  return _ClauseKey.free;
}

/// Under a lens the remainder is named **once, uncounted**, on one side of
/// the partition. It is never broken down by state: doing so would re-import
/// the unlensed aggregate the lens exists to avoid.
List<String> _appendRemainder(List<String> clauses, GrammarInput c) {
  final other = c.otherBays;
  if (other <= 0) return [...clauses];
  return [
    ...clauses,
    '$other ${words.other} ${other == 1 ? words.bay : words.bays}',
  ];
}
