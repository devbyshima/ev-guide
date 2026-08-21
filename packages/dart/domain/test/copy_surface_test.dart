/// The second instrument for docs/availability-display.md section 2.2b: the
/// bans, checked against **authored copy** rather than against emitted grammar.
///
/// Dart mirror of `packages/domain/test/copy-surface.test.ts`. The assertions
/// correspond one for one; the extraction does not, because TypeScript's
/// parser is a dev dependency this package already has and Dart's ships as
/// `package:analyzer`, which this package does not carry.
///
/// Why a second instrument exists at all. [forbiddenSubstrings] is swept in
/// structural_test.dart and corpus_json_test.dart, and both sweeps run over the
/// text `grammar()` returns. That text is composed from [words], integers and
/// the separator alone, so a whole class of banned strings cannot occur in it
/// and those assertions cannot fail. `real-time` is one; `live`, which row 3
/// also bans, was never in the list at all. Neither omission was a decision to
/// stop enforcing the row: it was that the only sweep in the repository pointed
/// at a surface where the row is unfalsifiable.
///
/// This suite points at the surfaces where a copy author actually types, which
/// are the two the ban names: the closed vocabulary, and the string literals in
/// the files that render. It is the first mechanical enforcement SPEC.md
/// section 13 guarantee 8 has ever had.
///
/// **The scanner is hand-rolled, so its failures are pinned.** An adversarial
/// pass broke the first version of it four ways, and each is a test below: a
/// `\n` inside banned copy read as the letter `n`, which welded two words
/// together and erased the boundary row 3 matches on; copy nested inside a
/// `${...}` hole skipped entirely; a nested block comment, which Dart allows
/// and TypeScript does not, resuming mid-comment; and a raw string scanned for
/// interpolation it cannot have.
///
/// **What this does not reach, stated so it is not mistaken for cover.** A
/// store listing and an onboarding flow are also named by guarantee 8 and
/// neither is in this repository. [forbiddenCatchall] remains a review
/// obligation, and so does row 3 read in section 2.2b's qualified sense, since
/// no pattern can tell a promise from a description. Row 6, the ban on any
/// availability word on the accent badge, is a layout rule no string check can
/// express. And if copy ever moves into a resource format (ARB, or a Swift or
/// Kotlin surface that does not exist yet) the scan will keep passing over an
/// empty surface, which the coverage guard below exists to catch.
library;

import 'dart:io';

import 'package:ev_guide_domain/ev_guide_domain.dart';
import 'package:test/test.dart';

/// The workspace root. Dart has no `__dirname`, so resolve by walking up from
/// the working directory until `packages/corpus/corpus.json` appears, exactly
/// as corpus_json_test.dart does: `dart test` runs from the package root, and
/// the walk also covers a runner invoked from the repo root or between.
Directory _repoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    final marker = File('${dir.path}/packages/corpus/corpus.json');
    if (marker.existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'workspace root not found walking up from ${Directory.current.path}',
      );
    }
    dir = parent;
  }
}

/// The copy-bearing source roots. `packages/dart/domain/lib/src/vocabulary.dart`
/// is excluded by name because it is where the bans are written down: its
/// literals are the patterns themselves, and the closed vocabulary it exports
/// is checked directly below instead, which is the stronger check.
const _surfaceRoots = [
  'apps/driver_flutter/lib',
  'packages/dart/ui/lib',
  'packages/dart/data/lib',
  'packages/dart/domain/lib',
];
const _excluded = ['packages/dart/domain/lib/src/vocabulary.dart'];

List<String> _sourceFiles(String root) {
  final base = _repoRoot().path;
  final dir = Directory('$base/$root');
  if (!dir.existsSync()) return const [];
  final found = <String>[];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relative = entity.path.substring(base.length + 1);
    if (_excluded.contains(relative)) continue;
    found.add(relative);
  }
  found.sort();
  return found;
}

/// Every authored string in a Dart source, with comments skipped.
///
/// Comments are skipped rather than searched because ordinary domain prose
/// uses the banned words descriptively: `unreported` appears in four comments
/// in the roots this suite scans, stating the derivation law and describing a
/// fixture, and not one of them is copy. A scanner that read comments would
/// report the domain's own prose as a violation of the domain's own ban.
List<String> stringLiterals(String source) =>
    (_Scanner(source)..code()).literals;

bool _isIdentifierChar(String c) {
  final unit = c.codeUnitAt(0);
  return (unit >= 0x61 && unit <= 0x7A) || // a-z
      (unit >= 0x41 && unit <= 0x5A) || // A-Z
      (unit >= 0x30 && unit <= 0x39) || // 0-9
      c == '_';
}

class _Scanner {
  _Scanner(this.src);

  final String src;
  final List<String> literals = [];
  int i = 0;

  /// Walk code, collecting literals. Inside an interpolation hole [stop] is
  /// `}`, so the hole's own literals are collected rather than skipped and the
  /// walk hands the closing brace back to the string it came from.
  void code({String? stop}) {
    while (i < src.length) {
      if (_lineComment() || _blockComment()) continue;
      if (stop != null && src.startsWith(stop, i)) return;
      final ch = src[i];
      if (ch == "'" || ch == '"') {
        _string();
      } else if (stop != null && ch == '{') {
        i += 1;
        code(stop: '}');
        if (i < src.length) i += 1;
      } else {
        i += 1;
      }
    }
  }

  bool _lineComment() {
    if (!src.startsWith('//', i)) return false;
    while (i < src.length && src[i] != '\n') {
      i += 1;
    }
    return true;
  }

  /// Dart block comments nest, unlike TypeScript's, so the depth is counted.
  /// Stopping at the first `*/` would resume reading a still-commented body as
  /// code, which fails the build on copy the compiler never sees.
  bool _blockComment() {
    if (!src.startsWith('/*', i)) return false;
    var depth = 0;
    while (i < src.length) {
      if (src.startsWith('/*', i)) {
        depth += 1;
        i += 2;
      } else if (src.startsWith('*/', i)) {
        depth -= 1;
        i += 2;
        if (depth == 0) return true;
      } else {
        i += 1;
      }
    }
    return true;
  }

  void _string() {
    final quote = src[i];
    // A raw string suppresses escapes and interpolation alike, and its `r`
    // sits against the quote.
    final raw = i > 0 && src[i - 1] == 'r';
    final delimiter = src.startsWith(quote * 3, i) ? quote * 3 : quote;
    i += delimiter.length;
    final buffer = StringBuffer();
    while (i < src.length) {
      if (src.startsWith(delimiter, i)) {
        i += delimiter.length;
        break;
      }
      final c = src[i];
      if (!raw && c == r'\' && i + 1 < src.length) {
        // An escape stands for one character. Which one matters only for the
        // quote-like escapes; every other becomes a space, because a `\n` read
        // as the letter `n` welds two words into one and erases the boundary
        // the row 3 patterns match on.
        final next = src[i + 1];
        buffer.write(
          next == r'\' || next == "'" || next == '"' || next == r'$'
              ? next
              : ' ',
        );
        i += 2;
      } else if (!raw && c == r'$') {
        // The hole is code, not copy. A braced hole is walked so its own
        // literals are collected; a bare `$name` is stepped over. Either way a
        // space stands in, so the words on each side stay separate.
        buffer.write(' ');
        i += 1;
        if (i < src.length && src[i] == '{') {
          i += 1;
          code(stop: '}');
          if (i < src.length) i += 1;
        } else {
          while (i < src.length && _isIdentifierChar(src[i])) {
            i += 1;
          }
        }
      } else {
        buffer.write(c);
        i += 1;
      }
    }
    literals.add(buffer.toString());
  }
}

final _patterns = [
  for (final source in forbiddenCopyPatterns)
    (source: source, regex: RegExp(source, caseSensitive: false)),
];

/// Every ban section 2.2b can express mechanically, applied to one string.
///
/// Both lists are applied: the literals of rows 1, 2 and 7 and the row 3
/// patterns. The literals are matched as substrings here exactly as they are
/// over grammar text, which on a surface is a slightly wider net than on the
/// closed vocabulary (`in use` is inside "sign in user"). A hit is a review
/// prompt, and no phrase in the repository trips one.
List<String> offences(String text) {
  final lower = text.toLowerCase();
  return [
    for (final banned in forbiddenSubstrings)
      if (lower.contains(banned)) banned,
    for (final pattern in _patterns)
      if (pattern.regex.hasMatch(text)) pattern.source,
  ];
}

void main() {
  group('the closed vocabulary carries no banned word', () {
    test('holds for every display word and every connector projection', () {
      final emitted = [
        words.free,
        words.busy,
        words.outOfService,
        words.unknown,
        words.bay,
        words.bays,
        words.noConfirmedStatus,
        words.noConfirmedRate,
        words.all,
        words.of,
        words.other,
        words.busyControlLabel,
        for (final type in [
          ConnectorType.iec62196T2,
          ConnectorType.iec62196T2Combo,
          ConnectorType.gbtAc,
          ConnectorType.gbtDc,
          ConnectorType.other,
          ConnectorType.unknown,
        ])
          connectorTypeWord(type),
      ];
      for (final word in emitted) {
        expect(offences(word), isEmpty, reason: 'vocabulary word: $word');
      }
    });
  });

  group('no authored literal on a surface carries a banned word', () {
    final base = _repoRoot().path;
    final files = [for (final root in _surfaceRoots) ..._sourceFiles(root)];

    test('holds for every string literal in every surface file', () {
      for (final file in files) {
        for (final literal in stringLiterals(
          File('$base/$file').readAsStringSync(),
        )) {
          expect(
            offences(literal),
            isEmpty,
            reason: '$file: ${literal.replaceAll('\n', ' ')}',
          );
        }
      }
    });

    test('actually scanned the surfaces, rather than passing over nothing', () {
      // A green scan of an empty set is the one failure a green test cannot
      // report, so the floors are asserted. Today: 4 roots, 21 files, 240
      // literals. The floors sit below those and above zero, so ordinary
      // edits do not move them but a surface going dark does.
      for (final root in _surfaceRoots) {
        expect(_sourceFiles(root), isNotEmpty, reason: 'no files under $root');
      }
      expect(files.length, greaterThanOrEqualTo(15));
      final literals = [
        for (final file in files)
          ...stringLiterals(File('$base/$file').readAsStringSync()),
      ];
      expect(literals.length, greaterThanOrEqualTo(150));
    });

    test('reads authored strings and not comments', () {
      // The guard on the guard. `unreported` is banned by row 1 and occurs in
      // availability.dart only inside comments, where it states the derivation
      // law rather than any ban. The scan must not report the prose of the
      // domain as a violation of it.
      final source = File(
        '$base/packages/dart/domain/lib/src/availability.dart',
      ).readAsStringSync();
      expect(source, contains('unreported'));
      expect(stringLiterals(source).join(' '), isNot(contains('unreported')));
    });
  });

  group('the scanner survives the ways copy can hide', () {
    // Each case broke the first version of the scanner above. The TypeScript
    // reference clears the same bar through `ts.createSourceFile`.
    List<String> banned(String source) => [
      for (final literal in stringLiterals(source))
        if (offences(literal).isNotEmpty) literal,
    ];

    test('sees copy split across two lines by an escape', () {
      expect(banned(r"const label = 'Live\nstatus';"), ['Live status']);
    });

    test('sees copy nested inside an interpolation hole', () {
      expect(
        banned(r"final s = '${empty ? 'Live availability' : 'free'} now';"),
        ['Live availability'],
      );
    });

    test('steps over a bare interpolation, so an identifier is not copy', () {
      expect(stringLiterals(r"final s = 'Bay $live now';"), ['Bay   now']);
    });

    test('keeps a nested block comment commented', () {
      const source = '''
/* outer
   /* inner */
   const gone = 'Live availability';
*/
final kept = 'free';
''';
      expect(stringLiterals(source), ['free']);
    });

    test('keeps a raw string whole, holes and escapes alike', () {
      expect(stringLiterals(r"const s = r'${x}\nlive';"), [r'${x}\nlive']);
    });
  });

  group('the copy patterns ban the word and not the letters', () {
    test('catches the promise phrasings the category invites', () {
      for (final copy in [
        'live availability',
        'Live status',
        'Live',
        'See live bay status',
        'real-time availability',
        'Realtime bays',
        'REAL-TIME',
      ]) {
        expect(offences(copy), isNotEmpty, reason: 'should be banned: $copy');
      }
    });

    test('spares the words that merely contain those letters', () {
      // The first ten are what a bare substring ban on `live` would flag. All
      // ten occur in this repository, and sixteen such words occur in all,
      // 158 times between them as of 935a9b5. `olive` closes the list because
      // it is the standard counter-example, not because it occurs here.
      for (final innocent in [
        'delivered',
        'delivery',
        'deliverable',
        'undeliverable',
        'deliverability',
        'lives',
        'lived',
        'outlive',
        'alive',
        'liveness',
        'olive',
      ]) {
        expect(
          offences(innocent),
          isEmpty,
          reason: 'should be allowed: $innocent',
        );
      }
    });
  });
}
