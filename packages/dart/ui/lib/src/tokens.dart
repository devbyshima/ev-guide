/// The design tokens. SPEC.md section 5 is the source; the pixel-level record
/// is `.scratch/ev-guide-spec/design/10-design-system-v2.md`. This file is the
/// Dart transcription of `packages/ui/src/tokens.ts` (ADR-0012): same values,
/// same findings, and the same tests guarding both sides.
///
/// **Units.** `px` is authoritative and is the @3x measurement. `pt = px / 3`
/// is what a build types, given to two decimals where the division is not
/// exact, and **never rounded to a nicer number** (ticket 34: an unwritten
/// rounding rule is exactly the ambiguity that produced a wrong "correction"
/// to a locked value).
///
/// The admin dashboard takes **tokens only**, no components, and the 1:1
/// reference rule does not govern it.
library;

import 'dart:ui' show Color;

/// px -> pt at @3x. Exported so nothing re-derives the ratio by hand.
double pt(double px) => px / 3;

/// The single accent value, shared with [LinkTokens.color] so the link colour
/// is the accent by construction, never a re-typed literal.
const Color _accent = Color(0xFFC7FC2F);

/// Backing type for [color].
class ColorTokens {
  const ColorTokens._();

  final Color page = const Color(0xFF121212);
  final Color mapCanvas = const Color(0xFF212121);
  final Color surface = const Color(0xFF393939);
  final Color raised = const Color(0xFF3E3E3E);
  final Color divider = const Color(0xFF3E3E3E);
  final Color accent = _accent;
  final Color onAccent = const Color(0xFF121212);

  /// The only text colour in the system.
  final Color text = const Color(0xFFFFFFFF);

  final Color handle = const Color(0xFF262626);

  /// The `03` heart, and only that.
  final Color iconMuted = const Color(0xFF717171);

  /// The map avatar's person glyph.
  final Color iconOnLight = const Color(0xFF121212);

  /// The locate arrow only. Two blacks on the accent is an open raise, not a
  /// licence to use either freely.
  final Color iconOnLightBlack = const Color(0xFF000000);

  final Color pinBody = const Color(0xFFFFFFFF);
  final Color pinDisc = const Color(0xFFF3F3F3);
  final Color pinGlyph = const Color(0xFF393939);

  /// The palette as key/value pairs, for the tests that assert it is closed.
  /// Built from the fields, so the values live in exactly one place.
  Map<String, Color> get asMap => {
    'page': page,
    'mapCanvas': mapCanvas,
    'surface': surface,
    'raised': raised,
    'divider': divider,
    'accent': accent,
    'onAccent': onAccent,
    'text': text,
    'handle': handle,
    'iconMuted': iconMuted,
    'iconOnLight': iconOnLight,
    'iconOnLightBlack': iconOnLightBlack,
    'pinBody': pinBody,
    'pinDisc': pinDisc,
    'pinGlyph': pinGlyph,
  };
}

/// Exactly the measured palette. **There is no grey text tier**: what looked
/// like one is ExtraLight anti-aliasing, and `iconMuted` is not a text token.
///
/// Deliberately absent: any secondary/muted text colour, opacity ramp,
/// elevation colour, or accent tint. The accent is one value, with no tints
/// and no gradients.
const ColorTokens color = ColorTokens._();

/// Backing type for [type].
class TypeScale {
  const TypeScale._();

  final double display = 26;
  final double title = 22;
  final double heading = 17;
  final double label = 15;
  final double body = 13;

  /// The scale as key/value pairs, for the tests that assert it is closed.
  Map<String, double> get asMap => {
    'display': display,
    'title': title,
    'heading': heading,
    'label': label,
    'body': body,
  };
}

/// The type scale, in pt. Every size inherits +/-3% from an assumed
/// cap-height/em ratio; **the cap heights themselves are exact**.
///
/// This package must not pick a font family from the design record: the
/// typeface is not identified and ships as an acceptance band (ADR-0010).
const TypeScale type = TypeScale._();

/// Backing type for [typeMeta].
class TypeMeta {
  const TypeMeta._();

  final double bodyLineHeight = 15;

  /// Tracking is 0 at every size. Not "near zero": zero.
  final double tracking = 0;

  final ({int extraLight, int regular, int medium, int bold}) weights = (
    extraLight: 200,
    regular: 400,
    medium: 500,
    bold: 700,
  );

  /// Old-style figures are a required feature, not a preference.
  final List<String> fontFeatures = const ['onum'];

  /// The table as key/value pairs, for the tests that assert it names
  /// nothing beyond what was measured.
  Map<String, Object> get asMap => {
    'bodyLineHeight': bodyLineHeight,
    'tracking': tracking,
    'weights': {
      'extraLight': weights.extraLight,
      'regular': weights.regular,
      'medium': weights.medium,
      'bold': weights.bold,
    },
    'fontFeatures': fontFeatures,
  };
}

const TypeMeta typeMeta = TypeMeta._();

/// Backing type for [link].
class LinkTokens {
  const LinkTokens._();

  final Color color = _accent;
  final double underlineThicknessPt = 0.67;
  final double underlineOffsetPt = 1;
  final bool skipInk = false;
}

/// The one link style that exists.
const LinkTokens link = LinkTokens._();

/// Backing type for [space].
class SpaceTokens {
  const SpaceTokens._();

  final double pageMargin = 64;
  final double cardMargin = 38;
  final double cardPadding = 39;
  final double floatingCardPadding = 64;
  final double floatingCardBottomGap = 64;
  final double stickyBarPadding = 90;
  final double chipGap = 27;
  final double chipRowGap = 26;
  final double chipPaddingH = 30;
  final double chipIconGap = 18;
  final double titleToSubtitle = 20;
  final double blockGap = 39;
  final double sectionGap = 62;
  final double sectionGapLarge = 87;
  final double settingsRow = 176;
  final double iconGrid = 72;
  final double iconGridChip = 48;
  final double iconStroke = 6;
  final double hairline = 2;

  /// The table as key/value pairs, for the test that asserts there is no
  /// grid to regularise onto.
  Map<String, double> get asMap => {
    'pageMargin': pageMargin,
    'cardMargin': cardMargin,
    'cardPadding': cardPadding,
    'floatingCardPadding': floatingCardPadding,
    'floatingCardBottomGap': floatingCardBottomGap,
    'stickyBarPadding': stickyBarPadding,
    'chipGap': chipGap,
    'chipRowGap': chipRowGap,
    'chipPaddingH': chipPaddingH,
    'chipIconGap': chipIconGap,
    'titleToSubtitle': titleToSubtitle,
    'blockGap': blockGap,
    'sectionGap': sectionGap,
    'sectionGapLarge': sectionGapLarge,
    'settingsRow': settingsRow,
    'iconGrid': iconGrid,
    'iconGridChip': iconGridChip,
    'iconStroke': iconStroke,
    'hairline': hairline,
  };
}

/// Spacing, in px @3x. **Named after where they were measured: there is no
/// grid.** Do not infer a base unit from these and do not "regularise" them.
const SpaceTokens space = SpaceTokens._();

/// The pill radius. The category chip, the hero badge and the drag handle are
/// **pills** (half their integrated height), so their radius token is this
/// sentinel rather than an explicit number (ticket 33).
const double PILL = 9999;

/// Backing type for [radius].
class RadiusTokens {
  const RadiusTokens._();

  final double featureChip = 13.4;
  final double card = 15.6;
  final double tile = 15.2;

  /// Both CTAs, one token.
  final double button = 16.5;

  final double floatingCard = 19.5;
  final double image = 31.8;

  /// Category chip, hero badge, drag handle, and every true circle.
  final double pill = PILL;
  final double circle = PILL;

  /// The table as key/value pairs, for the tests that assert the tokens that
  /// deliberately do not exist (`sheet`, `buttonSticky`) stay absent.
  Map<String, double> get asMap => {
    'featureChip': featureChip,
    'card': card,
    'tile': tile,
    'button': button,
    'floatingCard': floatingCard,
    'image': image,
    'pill': pill,
    'circle': circle,
  };
}

/// Radii, in px. Re-fitted under **ticket 33** after the design record's
/// corner-arc method was found to state a false geometric identity and to
/// under-read every radius by about sqrt(r).
///
/// `PILL` is a real token here: the category chip, the hero badge and the
/// drag handle are **pills** (half their integrated height), which is the
/// reverse of what the record said before ticket 33. There is deliberately no
/// `radius.sheet` and no `radius.buttonSticky`: a single radius fits all
/// eight corners of both CTAs with zero penalty.
const RadiusTokens radius = RadiusTokens._();

/// The circular-button diameter keys, as [SizeTokens.circleButton] keys them.
enum CircleButtonSize { sm, md, lg, xl }

/// Backing type for [size].
class SizeTokens {
  const SizeTokens._();

  final ({double w, double h}) cta = const (w: 898.0, h: 137.25);
  final ({double w, double h}) ctaSticky = const (w: 513.0, h: 131.25);
  final ({double w, double h}) floatingCard = const (w: 1077.6, h: 521.53);
  final ({double w, double h}) pin = const (w: 122.3, h: 147.25);
  final ({double w, double h}) handle = const (w: 180.0, h: 12.75);
  final double featureChipHeight = 105.49;
  final ({double w, double h}) categoryChip = const (w: 254.75, h: 76.75);
  final ({double sm, double md, double lg, double xl}) circleButton = const (
    sm: 81.4,
    md: 90.8,
    lg: 99.5,
    xl: 137.7,
  );

  /// Three buttons, three sizes. This is not one token (ticket 36).
  final List<double> quickAction = const [154.8, 150.3, 149.9];

  final ({double map, double profile, double owner}) avatar = const (
    map: 128.6,
    profile: 315.9,
    owner: 76.7,
  );

  /// Photo-limited: three estimators spread 4 px and all land below 300.
  final double thumbnail = 297.5;
  final double thumbnailTolerance = 1.5;

  final double statusDot = 20.4;
  final double accentRing = 3.0;
  final ({double disc, double ring, double halo}) puck = const (
    disc: 39.6,
    ring: 4.0,
    halo: 82.0,
  );

  /// The heading cone is a **fourth** `#4285F4` surface, detached from the
  /// disc by 6-7 px. It had no token until ticket 36, so a build sizing the
  /// puck from tokens alone drew a plain dot and lost the heading indicator.
  final ({double w, double h, double gapFromDisc}) puckCone = const (
    w: 16,
    h: 19,
    gapFromDisc: 6.5,
  );
}

/// Component sizes, in px, **at their integrated extent** (ticket 34).
///
/// Integrated means the element's true extent, independent of the sub-pixel
/// phase the capture happened to catch its edges at. Tokens carry the
/// fraction and nothing is rounded.
const SizeTokens size = SizeTokens._();

/// Backing type for [knownContrast].
class ContrastTokens {
  const ContrastTokens._();

  /// The hero badge label. Fidelity was chosen over readability.
  final double heroBadgeLabel = 1.21;

  /// The drag handle. Invisible-grade, and correct.
  final double handle = 1.24;
}

/// Contrast facts that are deliberately shipped as-is, so nobody "fixes"
/// them without reading ADR-0009 first.
const ContrastTokens knownContrast = ContrastTokens._();
