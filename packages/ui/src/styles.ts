/**
 * The style layer: **pure objects derived from tokens, no React Native
 * import**. Components consume these; tests assert them.
 *
 * Splitting it this way is deliberate. The 1:1 reference rule lives in
 * numbers, and numbers are what drift. A style object can be asserted against
 * the measured record without an RN renderer, so every value the reference
 * pinned gets a test that fails when someone rounds it.
 *
 * Cap heights map to the five pt steps as `10-design-system-v2.md` section 4.2
 * maps them: cap 55 -> display, 47 -> title, 36/37 -> heading, 32 -> label,
 * 27/28 -> body. Build against cap heights where you can; these are the
 * rounded pt values, which is the only place that record rounded.
 */
import { PILL, color, pt, radius, size, space, type, typeMeta } from './tokens';

export type Weight = keyof typeof typeMeta.weights;
export type Step = keyof typeof type;

/**
 * The four weights, as the string literals React Native's `TextStyle` accepts.
 * Kept as a narrow union rather than `\`${number}\`` so a fifth weight cannot
 * be introduced by a typo: the system has exactly these four (200/400/500/700)
 * and the design record has no others.
 */
const WEIGHT_LITERAL = {
  extraLight: '200',
  regular: '400',
  medium: '500',
  bold: '700',
} as const satisfies Record<Weight, '200' | '400' | '500' | '700'>;

/**
 * **No `fontFamily`, ever.** The typeface is not identified and ships as an
 * acceptance band (ADR-0010); `packages/ui` must not pick a family from the
 * design record. The app injects one after it passes the band, which is why
 * this returns everything *except* the family.
 */
export function textStyle(step: Step, weight: Weight = 'regular') {
  return {
    fontSize: type[step],
    fontWeight: WEIGHT_LITERAL[weight],
    color: color.text,
    letterSpacing: typeMeta.tracking,
    ...(step === 'body' ? { lineHeight: typeMeta.bodyLineHeight } : {}),
  } as const;
}

/**
 * The primary CTA (`01`, `03`) and the sticky CTA (`04`).
 *
 * **Not a pill.** A pill on a 137.25 px button needs r = 69; it measures 16.5.
 * This is the single most likely 1:1 failure in the system, because "lime
 * pill" is what the record used to say and what the shape reads like.
 *
 * Both variants share `radius.button`: one value fits all eight corners of
 * both with zero penalty (ticket 33), so there is no `buttonSticky` radius.
 */
export function buttonStyle(variant: 'primary' | 'sticky' = 'primary') {
  const box = variant === 'primary' ? size.cta : size.ctaSticky;
  return {
    height: pt(box.h),
    borderRadius: pt(radius.button),
    backgroundColor: color.accent,
    alignItems: 'center',
    justifyContent: 'center',
  } as const;
}

export function buttonLabelStyle(variant: 'primary' | 'sticky' = 'primary') {
  // Primary label is cap 36 (heading); sticky is cap 32 (label). Both Medium.
  return {
    ...textStyle(variant === 'primary' ? 'heading' : 'label', 'medium'),
    color: color.onAccent,
  } as const;
}

/**
 * The `04` feature chip. Height is fixed; **width fits content**.
 * No border. Padding is left 30 / icon-to-label 18 / right 26.
 */
export function featureChipStyle() {
  return {
    height: pt(size.featureChipHeight),
    borderRadius: pt(radius.featureChip),
    backgroundColor: color.surface,
    paddingLeft: pt(space.chipPaddingH),
    paddingRight: pt(26),
    flexDirection: 'row',
    alignItems: 'center',
    gap: pt(space.chipIconGap),
  } as const;
}

export function featureChipLabelStyle() {
  return textStyle('label', 'extraLight');
}

/**
 * The `03` category chip. A **pill** (ticket 33 reversed the record here), with
 * a 2.5 px lime border and a lime label.
 *
 * **The padding is asymmetric on purpose: 86 left against 30 right.** That is
 * measured, it is [RAISE-5] in the design record, and it is not a mistake to
 * centre. `86 + 138 + 30 = 254` closes exactly at the chip's own lime extent.
 */
export function categoryChipStyle() {
  return {
    height: pt(size.categoryChip.h),
    borderRadius: PILL,
    backgroundColor: color.surface,
    borderWidth: pt(2.5),
    borderColor: color.accent,
    paddingLeft: pt(86),
    paddingRight: pt(30),
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
  } as const;
}

export function categoryChipLabelStyle() {
  return { ...textStyle('body', 'regular'), color: color.accent } as const;
}

/**
 * The `03` drag handle. A pill at half its integrated height, and
 * **`#262626` on `#121212` is 1.24:1** - invisible-grade, measured, and
 * correct. Do not "fix" the contrast.
 */
export function dragHandleStyle() {
  return {
    width: pt(size.handle.w),
    height: pt(size.handle.h),
    borderRadius: PILL,
    backgroundColor: color.handle,
    alignSelf: 'center',
  } as const;
}

/**
 * The `03` floating card. **Not a bottom sheet**: it is rounded on all four
 * corners and is never anchored to the screen edge, with 64 px of live map
 * between its bottom edge and the CTA.
 *
 * `packages/ui` names it `StationCard` and must not build it on a sheet
 * primitive, whose whole contract is bottom anchoring.
 */
export function stationCardStyle() {
  return {
    borderRadius: pt(radius.floatingCard),
    backgroundColor: color.page,
    padding: pt(space.floatingCardPadding),
  } as const;
}

export function thumbnailStyle() {
  return {
    width: pt(size.thumbnail),
    height: pt(size.thumbnail),
    borderRadius: pt(radius.image),
  } as const;
}

/** The `02` hosting card and its icon tile. */
export function hostingCardStyle() {
  return {
    borderRadius: pt(radius.card),
    backgroundColor: color.surface,
    padding: pt(space.cardPadding),
  } as const;
}

export function iconTileStyle() {
  return {
    borderRadius: pt(radius.tile),
    backgroundColor: color.raised,
  } as const;
}

/** Circular buttons. Five diameters, and they are genuinely all different. */
export function circleButtonStyle(which: keyof typeof size.circleButton) {
  const d = pt(size.circleButton[which]);
  return {
    width: d,
    height: d,
    borderRadius: PILL,
    backgroundColor: color.surface,
    alignItems: 'center',
    justifyContent: 'center',
  } as const;
}

/** The page. There is exactly one text colour, and this is its ground. */
export function pageStyle() {
  return {
    flex: 1,
    backgroundColor: color.page,
    paddingHorizontal: pt(space.pageMargin),
  } as const;
}
