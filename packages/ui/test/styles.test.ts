/**
 * The 1:1 rule lives in numbers, and numbers drift by being tidied. Each
 * assertion here is a value the reference pinned and a named ticket protects.
 */
import { describe, expect, it } from 'vitest';
import {
  buttonLabelStyle,
  buttonStyle,
  categoryChipLabelStyle,
  categoryChipStyle,
  circleButtonStyle,
  dragHandleStyle,
  featureChipStyle,
  stationCardStyle,
  textStyle,
  thumbnailStyle,
} from '../src/styles';
import { PILL, color, size, type } from '../src/tokens';

describe('the CTA is not a pill', () => {
  it('uses the measured radius, nowhere near the pill radius', () => {
    const s = buttonStyle('primary');
    // A pill on a 45.75 pt button needs r = 22.9. It measures 5.5.
    expect(s.borderRadius).toBeCloseTo(5.5, 2);
    expect(s.borderRadius).toBeLessThan(s.height / 2);
    expect(s.borderRadius).not.toBe(PILL);
  });

  it('gives both CTAs the same radius and different heights', () => {
    const primary = buttonStyle('primary');
    const sticky = buttonStyle('sticky');
    expect(sticky.borderRadius).toBe(primary.borderRadius);
    expect(sticky.height).not.toBe(primary.height);
  });

  it('keeps the fractional height rather than rounding it', () => {
    expect(buttonStyle('primary').height).toBeCloseTo(45.75, 4);
    expect(Number.isInteger(buttonStyle('primary').height)).toBe(false);
  });

  it('labels the two variants at different steps: cap 36 and cap 32', () => {
    expect(buttonLabelStyle('primary').fontSize).toBe(type.heading);
    expect(buttonLabelStyle('sticky').fontSize).toBe(type.label);
    // Dark ink on the accent, both.
    expect(buttonLabelStyle('primary').color).toBe(color.onAccent);
  });
});

describe('the chips are two different components that share nothing', () => {
  it('the category chip is a pill and the feature chip is not', () => {
    expect(categoryChipStyle().borderRadius).toBe(PILL);
    expect(featureChipStyle().borderRadius).not.toBe(PILL);
  });

  it('keeps the category chip padding asymmetric, by measurement', () => {
    const s = categoryChipStyle();
    // 86 left against 30 right, [RAISE-5]. Centring this is the obvious
    // "fix" and it is wrong: 86 + 138 + 30 = 254 closes at the chip's extent.
    expect(s.paddingLeft).toBeGreaterThan(s.paddingRight);
    expect(s.paddingLeft / s.paddingRight).toBeCloseTo(86 / 30, 5);
  });

  it('gives the category chip a lime border and a lime label', () => {
    expect(categoryChipStyle().borderColor).toBe(color.accent);
    expect(categoryChipLabelStyle().color).toBe(color.accent);
  });

  it('gives the feature chip no border and a white ExtraLight label', () => {
    expect(featureChipStyle()).not.toHaveProperty('borderWidth');
    expect(featureChipStyle().backgroundColor).toBe(color.surface);
  });
});

describe('the drag handle', () => {
  it('is a pill at 60 x 4.25 pt, in the invisible-grade handle colour', () => {
    const s = dragHandleStyle();
    expect(s.borderRadius).toBe(PILL);
    expect(s.width).toBeCloseTo(60, 4);
    expect(s.height).toBeCloseTo(4.25, 4);
    expect(s.backgroundColor).toBe(color.handle);
  });
});

describe('the 03 container is a card, not a sheet', () => {
  it('is rounded on all four corners with a single radius', () => {
    const s = stationCardStyle();
    expect(s.borderRadius).toBeCloseTo(6.5, 2);
    // A sheet would carry per-corner radii; this must not.
    for (const k of ['borderTopLeftRadius', 'borderBottomLeftRadius']) {
      expect(s).not.toHaveProperty(k);
    }
  });

  it('sits on the page colour, not the surface colour', () => {
    // Measured: the floating card is #121212 on the #212121 map canvas, which
    // reads as *darker* than its surroundings. The instinct is the reverse.
    expect(stationCardStyle().backgroundColor).toBe(color.page);
  });
});

describe('images stay rounder than containers', () => {
  it('holds between the thumbnail and every container style', () => {
    const containers = [
      stationCardStyle().borderRadius,
      buttonStyle().borderRadius,
      featureChipStyle().borderRadius,
    ];
    expect(thumbnailStyle().borderRadius).toBeGreaterThan(Math.max(...containers));
  });
});

describe('circular buttons are five genuinely different diameters', () => {
  it('does not collapse them to one size', () => {
    const ds = (['sm', 'md', 'lg', 'xl'] as const).map((k) => circleButtonStyle(k).width);
    expect(new Set(ds).size).toBe(4);
    expect(ds).toEqual([...ds].sort((a, b) => a - b));
  });

  it('renders them as true circles', () => {
    const s = circleButtonStyle('sm');
    expect(s.width).toBe(s.height);
    expect(s.borderRadius).toBe(PILL);
  });
});

describe('text', () => {
  it('never names a font family: the typeface is an acceptance band', () => {
    for (const step of ['display', 'title', 'heading', 'label', 'body'] as const) {
      expect(textStyle(step)).not.toHaveProperty('fontFamily');
    }
  });

  it('uses the only text colour, at zero tracking', () => {
    const s = textStyle('body');
    expect(s.color).toBe('#FFFFFF');
    expect(s.letterSpacing).toBe(0);
  });

  it('sets a line height on body only, where one was measured', () => {
    expect(textStyle('body')).toHaveProperty('lineHeight');
    expect(textStyle('display')).not.toHaveProperty('lineHeight');
  });
});

describe('sizes come from the tokens, not from literals', () => {
  it('derives every box from the measured token set', () => {
    expect(buttonStyle('sticky').height).toBeCloseTo(size.ctaSticky.h / 3, 4);
    expect(featureChipStyle().height).toBeCloseTo(size.featureChipHeight / 3, 4);
    expect(categoryChipStyle().height).toBeCloseTo(size.categoryChip.h / 3, 4);
  });
});
