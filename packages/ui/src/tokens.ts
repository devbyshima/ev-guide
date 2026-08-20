/**
 * The design tokens. SPEC.md section 5 is the source; the pixel-level record
 * is `.scratch/ev-guide-spec/design/10-design-system-v2.md`.
 *
 * **Units.** `px` is authoritative and is the @3x measurement. `pt = px / 3`
 * is what a build types, given to two decimals where the division is not
 * exact, and **never rounded to a nicer number** (ticket 34: an unwritten
 * rounding rule is exactly the ambiguity that produced a wrong "correction"
 * to a locked value).
 *
 * The admin dashboard takes **tokens only**, no React Native components, and
 * the 1:1 reference rule does not govern it.
 */

/** px -> pt at @3x. Exported so nothing re-derives the ratio by hand. */
export const pt = (px: number): number => px / 3;

/**
 * Exactly the measured palette. **There is no grey text tier**: what looked
 * like one is ExtraLight anti-aliasing, and `iconMuted` is not a text token.
 *
 * Deliberately absent: any secondary/muted text colour, opacity ramp,
 * elevation colour, or accent tint. The accent is one value, with no tints and
 * no gradients.
 */
export const color = {
  page: '#121212',
  mapCanvas: '#212121',
  surface: '#393939',
  raised: '#3E3E3E',
  divider: '#3E3E3E',
  accent: '#C7FC2F',
  onAccent: '#121212',
  /** The only text colour in the system. */
  text: '#FFFFFF',
  handle: '#262626',
  /** The `03` heart, and only that. */
  iconMuted: '#717171',
  /** The map avatar's person glyph. */
  iconOnLight: '#121212',
  /**
   * The locate arrow only. Two blacks on the accent is an open raise, not a
   * licence to use either freely.
   */
  iconOnLightBlack: '#000000',
  pinBody: '#FFFFFF',
  pinDisc: '#F3F3F3',
  pinGlyph: '#393939',
} as const;

/**
 * The type scale, in pt. Every size inherits +/-3% from an assumed
 * cap-height/em ratio; **the cap heights themselves are exact**.
 *
 * `packages/ui` must not pick a font family from the design record: the
 * typeface is not identified and ships as an acceptance band (ADR-0010).
 */
export const type = {
  display: 26,
  title: 22,
  heading: 17,
  label: 15,
  body: 13,
} as const;

export const typeMeta = {
  bodyLineHeight: 15,
  /** Tracking is 0 at every size. Not "near zero": zero. */
  tracking: 0,
  weights: { extraLight: 200, regular: 400, medium: 500, bold: 700 },
  /** Old-style figures are a required feature, not a preference. */
  fontFeatures: ['onum'],
} as const;

/** The one link style that exists. */
export const link = {
  color: color.accent,
  underlineThicknessPt: 0.67,
  underlineOffsetPt: 1,
  skipInk: false,
} as const;

/**
 * Spacing, in px @3x. **Named after where they were measured: there is no
 * grid.** Do not infer a base unit from these and do not "regularise" them.
 */
export const space = {
  pageMargin: 64,
  cardMargin: 38,
  cardPadding: 39,
  floatingCardPadding: 64,
  floatingCardBottomGap: 64,
  stickyBarPadding: 90,
  chipGap: 27,
  chipRowGap: 26,
  chipPaddingH: 30,
  chipIconGap: 18,
  titleToSubtitle: 20,
  blockGap: 39,
  sectionGap: 62,
  sectionGapLarge: 87,
  settingsRow: 176,
  iconGrid: 72,
  iconGridChip: 48,
  iconStroke: 6,
  hairline: 2,
} as const;

/**
 * Radii, in px. Re-fitted under **ticket 33** after the design record's
 * corner-arc method was found to state a false geometric identity and to
 * under-read every radius by about sqrt(r).
 *
 * `PILL` is a real token here: the category chip, the hero badge and the drag
 * handle are **pills** (half their integrated height), which is the reverse of
 * what the record said before ticket 33. There is deliberately no
 * `radius.sheet` and no `radius.buttonSticky`: a single radius fits all eight
 * corners of both CTAs with zero penalty.
 */
export const PILL = 9999;

export const radius = {
  featureChip: 13.4,
  card: 15.6,
  tile: 15.2,
  /** Both CTAs, one token. */
  button: 16.5,
  floatingCard: 19.5,
  image: 31.8,
  /** Category chip, hero badge, drag handle, and every true circle. */
  pill: PILL,
  circle: PILL,
} as const;

/**
 * Component sizes, in px, **at their integrated extent** (ticket 34).
 *
 * Integrated means the element's true extent, independent of the sub-pixel
 * phase the capture happened to catch its edges at. Tokens carry the fraction
 * and nothing is rounded.
 */
export const size = {
  cta: { w: 898.0, h: 137.25 },
  ctaSticky: { w: 513.0, h: 131.25 },
  floatingCard: { w: 1077.6, h: 521.53 },
  pin: { w: 122.3, h: 147.25 },
  handle: { w: 180.0, h: 12.75 },
  featureChipHeight: 105.49,
  categoryChip: { w: 254.75, h: 76.75 },
  circleButton: { sm: 81.4, md: 90.8, lg: 99.5, xl: 137.7 },
  /** Three buttons, three sizes. This is not one token (ticket 36). */
  quickAction: [154.8, 150.3, 149.9] as const,
  avatar: { map: 128.6, profile: 315.9, owner: 76.7 },
  /** Photo-limited: three estimators spread 4 px and all land below 300. */
  thumbnail: 297.5,
  thumbnailTolerance: 1.5,
  statusDot: 20.4,
  accentRing: 3.0,
  puck: { disc: 39.6, ring: 4.0, halo: 82.0 },
  /**
   * The heading cone is a **fourth** `#4285F4` surface, detached from the disc
   * by 6-7 px. It had no token until ticket 36, so a build sizing the puck
   * from tokens alone drew a plain dot and lost the heading indicator.
   */
  puckCone: { w: 16, h: 19, gapFromDisc: 6.5 },
} as const;

/**
 * Contrast facts that are deliberately shipped as-is, so nobody "fixes" them
 * without reading ADR-0009 first.
 *
 * `heroBadgeLabel` lived here at 1.21 until ADR-0013. The badge label is now
 * `color.onAccent` on the accent fill, which computes to 15.52:1, so there is
 * no deliberate-illegibility fact left to guard.
 */
export const knownContrast = {
  /** The drag handle. Invisible-grade, and correct. */
  handle: 1.24,
} as const;
