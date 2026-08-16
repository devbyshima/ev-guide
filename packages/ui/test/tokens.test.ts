/**
 * These tests guard the findings, not the numbers.
 *
 * A token file drifts by someone "tidying" it: rounding a fraction, adding a
 * muted grey, regularising the spacing onto an 8pt grid, turning the pills
 * back into explicit radii. Each of those was specifically ruled out by a
 * ticket, so each gets an assertion that names the ticket.
 */
import { describe, expect, it } from 'vitest';
import { PILL, color, pt, radius, size, space, type, typeMeta } from '../src/tokens.js';

describe('the palette is closed', () => {
  it('has no grey text tier: what looked like one is ExtraLight anti-aliasing', () => {
    const textish = Object.entries(color).filter(([k]) => /text|muted|secondary/i.test(k));
    // iconMuted exists but is explicitly not a text token.
    expect(textish.map(([k]) => k).sort()).toEqual(['iconMuted', 'text']);
    expect(color.text).toBe('#FFFFFF');
  });

  it('carries exactly one accent value, with no tints', () => {
    const accents = Object.values(color).filter((v) => v === color.accent);
    expect(accents).toHaveLength(1);
    const nearAccents = Object.values(color).filter(
      (v) => v.toUpperCase().startsWith('#C7') && v !== color.accent,
    );
    expect(nearAccents).toHaveLength(0);
  });
});

describe('radii, re-fitted under ticket 33', () => {
  it('the CTA is not a pill, and both CTAs share one token', () => {
    // The finding survives the correction with room to spare: a pill on a
    // 137.25 px button needs r = 69, and it measures 16.5.
    expect(radius.button).toBeLessThan(69);
    expect(radius.button).toBeCloseTo(16.5, 2);
    expect(radius).not.toHaveProperty('buttonSticky');
  });

  it('the category chip, hero badge and handle are pills', () => {
    // Ticket 33 reversed the record here: it had said they "measurably fall
    // short" of a pill and forbidden borderRadius: 9999.
    expect(radius.pill).toBe(PILL);
  });

  it('keeps images rounder than containers', () => {
    // The system's signature move, narrowed from 2.1x to 1.6x by the re-fit
    // but nowhere near inverting.
    const containers = [radius.featureChip, radius.card, radius.tile, radius.button, radius.floatingCard];
    expect(radius.image).toBeGreaterThan(Math.max(...containers));
    expect(radius.image / radius.floatingCard).toBeGreaterThan(1.5);
  });

  it('has no sheet token: the 03 container is a card, not a bottom sheet', () => {
    expect(radius).not.toHaveProperty('sheet');
  });
});

describe('sizes carry the integrated extent, unrounded (ticket 34)', () => {
  it('keeps the fraction on the CTA height', () => {
    expect(size.cta.h).toBe(137.25);
    expect(pt(size.cta.h)).toBeCloseTo(45.75, 4);
  });

  it('does not round any measured size to an integer for tidiness', () => {
    const fractional = [size.cta.h, size.ctaSticky.h, size.floatingCard.w, size.handle.h];
    for (const v of fractional) expect(Number.isInteger(v)).toBe(false);
  });

  it('keeps the three quick actions as three sizes (ticket 36)', () => {
    // SPEC.md once collapsed these into one `quickAction 150` token; the
    // design record had them right and refused to harmonise them.
    expect(size.quickAction).toHaveLength(3);
    expect(new Set(size.quickAction).size).toBe(3);
    expect(size.quickAction[0] - size.quickAction[2]).toBeGreaterThan(4);
  });

  it('carries the puck heading cone, which had no token before ticket 36', () => {
    expect(size.puckCone.w).toBe(16);
    // Detached, not projecting: the gap is the white ring plus its AA.
    expect(size.puckCone.gapFromDisc).toBeGreaterThan(0);
  });

  it('states the thumbnail as a band, because it cannot be pinned', () => {
    expect(size.thumbnail).toBeLessThan(300);
    expect(size.thumbnailTolerance).toBeGreaterThan(0);
  });
});

describe('spacing is measured, not derived', () => {
  it('does not sit on a grid, and must not be regularised onto one', () => {
    const values = Object.values(space);
    const onEight = values.filter((v) => v % 8 === 0).length;
    // If someone "fixes" these onto an 8pt grid this ratio jumps to 1.
    expect(onEight / values.length).toBeLessThan(0.6);
  });
});

describe('type', () => {
  it('is a five-step scale with zero tracking at every size', () => {
    expect(Object.keys(type)).toHaveLength(5);
    expect(typeMeta.tracking).toBe(0);
  });

  it('requires old-style figures', () => {
    expect(typeMeta.fontFeatures).toContain('onum');
  });

  it('names no font family: the typeface ships as an acceptance band', () => {
    const serialised = JSON.stringify({ type, typeMeta });
    for (const family of ['Raleway', 'Inter', 'Poppins', 'SF Pro', 'Roboto']) {
      expect(serialised).not.toContain(family);
    }
  });
});
