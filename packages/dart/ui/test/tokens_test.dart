/// These tests guard the findings, not the numbers.
///
/// A token file drifts by someone "tidying" it: rounding a fraction, adding a
/// muted grey, regularising the spacing onto an 8pt grid, turning the pills
/// back into explicit radii. Each of those was specifically ruled out by a
/// ticket, so each gets an assertion that names the ticket.
library;

import 'dart:math' show max;
import 'dart:ui' show Color;

import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the palette is closed', () {
    test('has no grey text tier: what looked like one is ExtraLight '
        'anti-aliasing', () {
      final textish =
          color.asMap.keys
              .where(
                (k) => RegExp(
                  'text|muted|secondary',
                  caseSensitive: false,
                ).hasMatch(k),
              )
              .toList()
            ..sort();
      // iconMuted exists but is explicitly not a text token.
      expect(textish, ['iconMuted', 'text']);
      expect(color.text, const Color(0xFFFFFFFF));
    });

    test('carries exactly one accent value, with no tints', () {
      final accents = color.asMap.values.where((v) => v == color.accent);
      expect(accents, hasLength(1));
      // The TS suite checks for hex strings starting "#C7"; the same check on
      // a Color is the red channel.
      final nearAccents = color.asMap.values.where(
        (v) => ((v.toARGB32() >> 16) & 0xFF) == 0xC7 && v != color.accent,
      );
      expect(nearAccents, isEmpty);
    });
  });

  group('radii, re-fitted under ticket 33', () {
    test('the CTA is not a pill, and both CTAs share one token', () {
      // The finding survives the correction with room to spare: a pill on a
      // 137.25 px button needs r = 69, and it measures 16.5.
      expect(radius.button, lessThan(69));
      expect(radius.button, closeTo(16.5, 0.005));
      expect(radius.asMap.containsKey('buttonSticky'), isFalse);
    });

    test('the category chip, hero badge and handle are pills', () {
      // Ticket 33 reversed the record here: it had said they "measurably fall
      // short" of a pill and forbidden borderRadius: 9999.
      expect(radius.pill, PILL);
    });

    test('keeps images rounder than containers', () {
      // The system's signature move, narrowed from 2.1x to 1.6x by the re-fit
      // but nowhere near inverting.
      final containers = [
        radius.featureChip,
        radius.card,
        radius.tile,
        radius.button,
        radius.floatingCard,
      ];
      expect(radius.image, greaterThan(containers.reduce(max)));
      expect(radius.image / radius.floatingCard, greaterThan(1.5));
    });

    test(
      'has no sheet token: the 03 container is a card, not a bottom sheet',
      () {
        expect(radius.asMap.containsKey('sheet'), isFalse);
      },
    );
  });

  group('sizes carry the integrated extent, unrounded (ticket 34)', () {
    test('keeps the fraction on the CTA height', () {
      expect(size.cta.h, 137.25);
      expect(pt(size.cta.h), closeTo(45.75, 5e-5));
    });

    test('does not round any measured size to an integer for tidiness', () {
      final fractional = [
        size.cta.h,
        size.ctaSticky.h,
        size.floatingCard.w,
        size.handle.h,
      ];
      for (final v in fractional) {
        expect(v % 1 == 0, isFalse);
      }
    });

    test('keeps the three quick actions as three sizes (ticket 36)', () {
      // SPEC.md once collapsed these into one `quickAction 150` token; the
      // design record had them right and refused to harmonise them.
      expect(size.quickAction, hasLength(3));
      expect(size.quickAction.toSet(), hasLength(3));
      expect(size.quickAction[0] - size.quickAction[2], greaterThan(4));
    });

    test(
      'carries the puck heading cone, which had no token before ticket 36',
      () {
        expect(size.puckCone.w, 16);
        // Detached, not projecting: the gap is the white ring plus its AA.
        expect(size.puckCone.gapFromDisc, greaterThan(0));
      },
    );

    test('states the thumbnail as a band, because it cannot be pinned', () {
      expect(size.thumbnail, lessThan(300));
      expect(size.thumbnailTolerance, greaterThan(0));
    });
  });

  group('spacing is measured, not derived', () {
    test('does not sit on a grid, and must not be regularised onto one', () {
      final values = space.asMap.values.toList();
      final onEight = values.where((v) => v % 8 == 0).length;
      // If someone "fixes" these onto an 8pt grid this ratio jumps to 1.
      expect(onEight / values.length, lessThan(0.6));
    });
  });

  group('type', () {
    test('is a five-step scale with zero tracking at every size', () {
      expect(type.asMap.keys, hasLength(5));
      expect(typeMeta.tracking, 0);
    });

    test('requires old-style figures', () {
      expect(typeMeta.fontFeatures, contains('onum'));
    });

    test('names no font family: the typeface ships as an acceptance band', () {
      final serialised = '${type.asMap} ${typeMeta.asMap}';
      for (final family in [
        'Raleway',
        'Inter',
        'Poppins',
        'SF Pro',
        'Roboto',
      ]) {
        expect(serialised.contains(family), isFalse);
      }
    });
  });
}
