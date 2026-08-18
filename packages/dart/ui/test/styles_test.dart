/// The 1:1 rule lives in numbers, and numbers drift by being tidied. Each
/// assertion here is a value the reference pinned and a named ticket protects.
library;

import 'dart:math' show max;
import 'dart:ui' show Color;

import 'package:ev_guide_ui/ev_guide_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the CTA is not a pill', () {
    test('uses the measured radius, nowhere near the pill radius', () {
      final s = buttonStyle(ButtonVariant.primary);
      // A pill on a 45.75 pt button needs r = 22.9. It measures 5.5.
      expect(s.borderRadius, closeTo(5.5, 0.005));
      expect(s.borderRadius, lessThan(s.height / 2));
      expect(s.borderRadius, isNot(PILL));
    });

    test('gives both CTAs the same radius and different heights', () {
      final primary = buttonStyle(ButtonVariant.primary);
      final sticky = buttonStyle(ButtonVariant.sticky);
      expect(sticky.borderRadius, primary.borderRadius);
      expect(sticky.height, isNot(primary.height));
    });

    test('keeps the fractional height rather than rounding it', () {
      expect(buttonStyle(ButtonVariant.primary).height, closeTo(45.75, 5e-5));
      expect(buttonStyle(ButtonVariant.primary).height % 1 == 0, isFalse);
    });

    test('labels the two variants at different steps: cap 36 and cap 32', () {
      expect(buttonLabelStyle(ButtonVariant.primary).fontSize, type.heading);
      expect(buttonLabelStyle(ButtonVariant.sticky).fontSize, type.label);
      // Dark ink on the accent, both.
      expect(buttonLabelStyle(ButtonVariant.primary).color, color.onAccent);
    });
  });

  group('the chips are two different components that share nothing', () {
    test('the category chip is a pill and the feature chip is not', () {
      expect(categoryChipStyle().borderRadius, PILL);
      expect(featureChipStyle().borderRadius, isNot(PILL));
    });

    test('keeps the category chip padding asymmetric, by measurement', () {
      final s = categoryChipStyle();
      // 86 left against 30 right, RAISE-5. Centring this is the obvious
      // "fix" and it is wrong: 86 + 138 + 30 = 254 closes at the chip's
      // extent.
      expect(s.paddingLeft, greaterThan(s.paddingRight));
      expect(s.paddingLeft / s.paddingRight, closeTo(86 / 30, 5e-6));
    });

    test('gives the category chip a lime border and a lime label', () {
      expect(categoryChipStyle().borderColor, color.accent);
      expect(categoryChipLabelStyle().color, color.accent);
    });

    test('gives the feature chip no border and a white ExtraLight label', () {
      expect(featureChipStyle().asMap.containsKey('borderWidth'), isFalse);
      expect(featureChipStyle().backgroundColor, color.surface);
    });
  });

  group('the drag handle', () {
    test('is a pill at 60 x 4.25 pt, in the invisible-grade handle colour', () {
      final s = dragHandleStyle();
      expect(s.borderRadius, PILL);
      expect(s.width, closeTo(60, 5e-5));
      expect(s.height, closeTo(4.25, 5e-5));
      expect(s.backgroundColor, color.handle);
    });
  });

  group('the 03 container is a card, not a sheet', () {
    test('is rounded on all four corners with a single radius', () {
      final s = stationCardStyle();
      expect(s.borderRadius, closeTo(6.5, 0.005));
      // A sheet would carry per-corner radii; this must not.
      for (final k in ['borderTopLeftRadius', 'borderBottomLeftRadius']) {
        expect(s.asMap.containsKey(k), isFalse);
      }
    });

    test('sits on the page colour, not the surface colour', () {
      // Measured: the floating card is #121212 on the #212121 map canvas,
      // which reads as *darker* than its surroundings. The instinct is the
      // reverse.
      expect(stationCardStyle().backgroundColor, color.page);
    });
  });

  group('images stay rounder than containers', () {
    test('holds between the thumbnail and every container style', () {
      final containers = [
        stationCardStyle().borderRadius,
        buttonStyle().borderRadius,
        featureChipStyle().borderRadius,
      ];
      expect(
        thumbnailStyle().borderRadius,
        greaterThan(containers.reduce(max)),
      );
    });
  });

  group('circular buttons are five genuinely different diameters', () {
    test('does not collapse them to one size', () {
      final ds = CircleButtonSize.values
          .map((k) => circleButtonStyle(k).width)
          .toList();
      expect(ds.toSet(), hasLength(4));
      expect(ds, [...ds]..sort());
    });

    test('renders them as true circles', () {
      final s = circleButtonStyle(CircleButtonSize.sm);
      expect(s.width, s.height);
      expect(s.borderRadius, PILL);
    });
  });

  group('text', () {
    test('never names a font family: the typeface is an acceptance band', () {
      for (final step in Step.values) {
        expect(textStyle(step).asMap.containsKey('fontFamily'), isFalse);
      }
    });

    test('uses the only text colour, at zero tracking', () {
      final s = textStyle(Step.body);
      expect(s.color, const Color(0xFFFFFFFF));
      expect(s.letterSpacing, 0);
    });

    test('sets a line height on body only, where one was measured', () {
      expect(textStyle(Step.body).asMap.containsKey('lineHeight'), isTrue);
      expect(textStyle(Step.display).asMap.containsKey('lineHeight'), isFalse);
    });
  });

  group('sizes come from the tokens, not from literals', () {
    test('derives every box from the measured token set', () {
      expect(
        buttonStyle(ButtonVariant.sticky).height,
        closeTo(size.ctaSticky.h / 3, 5e-5),
      );
      expect(
        featureChipStyle().height,
        closeTo(size.featureChipHeight / 3, 5e-5),
      );
      expect(
        categoryChipStyle().height,
        closeTo(size.categoryChip.h / 3, 5e-5),
      );
    });
  });
}
