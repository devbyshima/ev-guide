/// SPEC.md section 13 guarantee 11, as a test rather than a review item:
/// **no disabled token exists, and no bare touchable ships.**
///
/// The guarantee is written for React Native, where the deviation arrives by
/// default: `TouchableOpacity` ships `activeOpacity: 0.2` and `Pressable`
/// ships `android_ripple`, so a bare touchable delivers the forbidden opacity
/// ramp and motion without anyone typing them. Flutter moves the hazard rather
/// than removing it. A raw `GestureDetector` draws nothing, but `InkWell`,
/// `InkResponse`, `CupertinoButton` and the Material buttons each ship a ramp,
/// a splash or both, and `Opacity` is one import away from any widget.
///
/// So the Dart form of the guarantee is a source sweep with a Flutter list:
/// every tap goes through `PressableSurface`, and nothing paints a press or a
/// refusal with opacity. This file is what ticket 31 section 12.2 prohibition
/// 2 calls "the only test in this file that catches a defect arriving by
/// default", and it exists because this package shipped exactly that defect -
/// a `disabled` prop with a 0.5 fade and a 0.85 press ramp - which every other
/// test in the suite passed.
///
/// Scope note: this sweeps the shipped Dart surface, `packages/dart/ui/lib`
/// and `apps/driver_flutter/lib`. Section 12.2 prohibition 1 (the module-name
/// assertion over twelve forbidden component names) is a different guarantee
/// and is still owed; ADR-0013 records it as absent from this package.
library;

import 'dart:io';

import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dart has no `__dirname`, so walk up from the working directory until the
/// repo root appears - the idiom `corpus_json_test.dart` already uses, which
/// covers a runner invoked from the package root, the repo root, or between.
Directory _repoRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    if (Directory('${dir.path}/packages/dart/ui/lib').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('repo root not found from ${Directory.current.path}');
    }
    dir = parent;
  }
}

/// The shipped Dart surface, as (path relative to the repo root, source).
List<(String, String)> _sources() {
  final root = _repoRoot();
  return [
    for (final dir in const ['packages/dart/ui/lib', 'apps/driver_flutter/lib'])
      ...Directory('${root.path}/$dir')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map(
            (f) => (
              f.path.substring(root.path.length + 1),
              f.readAsStringSync(),
            ),
          ),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
}

/// Comments quote the banned names to explain the ban, which is the whole
/// point of the comments. Strip them before matching, or this file's own
/// prose would fail it.
String _code(String source) => source
    .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '')
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');

void main() {
  final sources = _sources();

  test('the sweep sees the files it claims to sweep', () {
    // A path typo would make every assertion below pass over an empty list.
    expect(sources.length, greaterThanOrEqualTo(9));
    expect(
      sources.map((s) => s.$1),
      contains('packages/dart/ui/lib/src/widgets/pressable_surface.dart'),
    );
    expect(
      sources.map((s) => s.$1),
      contains('apps/driver_flutter/lib/main.dart'),
    );
  });

  group('no bare touchable ships', () {
    // Everything that can accept a tap. `PressableSurface` is the one place
    // any of them is allowed to appear.
    //
    // `Listener` carries its bracket because `addListener` is an ordinary and
    // legitimate call; the constructor is what this bans.
    const gestureApis = [
      'GestureDetector',
      'RawGestureDetector',
      'InkWell',
      'InkResponse',
      'Listener(',
      'TapRegion',
    ];

    test('every tap in the package goes through PressableSurface', () {
      for (final (path, source) in sources) {
        if (path.endsWith('widgets/pressable_surface.dart')) continue;
        for (final api in gestureApis) {
          expect(
            _code(source),
            isNot(contains(api)),
            reason:
                '$path reaches for $api directly. Ticket 31 section 12.2 '
                'prohibition 2: every call site goes through '
                'PressableSurface, which is where "pressed renders nothing" '
                'is enforced once.',
          );
        }
      }
    });

    test('PressableSurface itself uses the gesture layer that draws nothing', () {
      final surface = sources.firstWhere(
        (s) => s.$1.endsWith('widgets/pressable_surface.dart'),
      ).$2;
      expect(_code(surface), contains('GestureDetector'));
      // InkWell and InkResponse draw a splash and a highlight; they are the
      // Flutter shape of the default React Native ships.
      expect(_code(surface), isNot(contains('InkWell')));
      expect(_code(surface), isNot(contains('InkResponse')));
    });
  });

  group('no opacity ramp, and no disabled token', () {
    test('no widget paints with opacity', () {
      // Section 4.1 prices opacity as a press channel and rejects it as "an
      // opacity ramp", which the design record lists as deliberately absent
      // (SPEC section 5). Section 12.2 prohibition 4 bans a component from
      // introducing one. Section 5.2 forbids fading a control that cannot act.
      const opacityApis = [
        'Opacity(',
        'AnimatedOpacity',
        'FadeTransition',
        'withOpacity',
        'withValues(alpha',
        'opacity:',
      ];
      for (final (path, source) in sources) {
        for (final api in opacityApis) {
          expect(
            _code(source),
            isNot(contains(api)),
            reason:
                '$path paints with $api. The palette has no opacity ramp: '
                'SPEC section 5 lists one as deliberately absent, and '
                'section 4.1 rejected it as a press channel by name.',
          );
        }
      }
    });

    test('the platform button widgets, each of which ships a ramp, are absent', () {
      // CupertinoButton fades to 0.4 on press; the Material buttons splash.
      // Naming them individually so the failure says which default arrived.
      const platformButtons = [
        'CupertinoButton',
        'MaterialButton',
        'TextButton',
        'ElevatedButton',
        'OutlinedButton',
        'FilledButton',
        'IconButton',
        'FloatingActionButton',
      ];
      for (final (path, source) in sources) {
        for (final widget in platformButtons) {
          expect(
            _code(source),
            isNot(contains(widget)),
            reason: '$path uses $widget, which ships its own press treatment.',
          );
        }
      }
    });

    test('no token is named for a disabled, muted or inactive state', () {
      // SPEC section 13 item 11's first half, read against the token module
      // rather than the widgets: the ramp cannot come back as a value either.
      // iconMuted is the measured `03` heart and is carved out by name in
      // section 12.2 prohibition 3; it is not a state token.
      final stateish = color.asMap.keys
          .where(
            (k) => RegExp(
              'disabled|inactive|muted|faded|dim',
              caseSensitive: false,
            ).hasMatch(k),
          )
          .toList()
        ..sort();
      expect(stateish, ['iconMuted']);
    });

    test('no widget carries a `disabled` prop', () {
      // Section 12.1: the prop is deliberately not called `disabled`, because
      // "a prop named `disabled` invites a `disabledStyle` within a week".
      // The name is the guard, so the name is what is asserted.
      for (final (path, source) in sources) {
        expect(
          _code(source),
          isNot(matches(RegExp(r'\bdisabled\b'))),
          reason:
              '$path names a `disabled` state. EV Guide has none (SPEC '
              'section 5, tested against 23 places). The three answers are '
              'absent, a refusal in words, or `inert`.',
        );
      }
    });
  });
}
