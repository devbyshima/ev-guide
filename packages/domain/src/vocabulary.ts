/**
 * The closed vocabulary. docs/availability-display.md section 2.4: the display
 * words are **data in packages/domain**, not string literals in a Swift file
 * and a Kotlin file. Neither transcription may invent a word.
 */
import type { ConnectorType } from './types';

export const WORDS = {
  free: 'free',
  /** One word for Occupied, every surface, driver and operator alike. */
  busy: 'busy',
  outOfService: 'out of service',
  unknown: 'unknown',
  bay: 'bay',
  bays: 'bays',
  /**
   * Never "no recent report": the offline override yields Unknown from a
   * 30-second-old report, which would make that string false (law 8).
   */
  noConfirmedStatus: 'no confirmed status',
  noConfirmedRate: 'no confirmed rate',
  all: 'All',
  of: 'of',
  other: 'other',
  /** The operator write-surface control label, the only capitalised form. */
  busyControlLabel: 'Busy',
} as const;

/** Connector type-words are one projection (section 2.4). */
export function connectorTypeWord(type: ConnectorType): string {
  switch (type) {
    case 'IEC_62196_T2':
      return 'Type 2';
    case 'IEC_62196_T2_COMBO':
      return 'CCS2';
    case 'GBT_AC':
      return 'GB/T AC';
    case 'GBT_DC':
      return 'GB/T DC';
    default:
      // The enum is open, and Android can return a member we do not know.
      return 'Other plug';
  }
}

/**
 * The forbidden strings, section 2.2b. **This is the one and only home**: the
 * table there is the union merged under ticket 32, because four copies had
 * drifted into four different lists and deleting the wrong one would have
 * dropped live bans.
 *
 * Exported so the test suite can assert that no emitted string contains one,
 * which is the only way a ban stays real.
 */
export const FORBIDDEN_SUBSTRINGS: readonly string[] = [
  // Row 1: asserts report history.
  'unreported',
  'not reported',
  'no recent report',
  'no report yet',
  'no reports yet',
  'last reported',
  'awaiting a report',
  // Row 2: the same, for rates.
  'unknown rate',
  'rate unavailable',
  'no rate reported',
  'no published rate',
  // Row 3: availability claimed as a promise (ticket 28).
  'real-time',
  'realtime',
  // Row 7: a second word for Occupied.
  'in use',
];

/**
 * Row 1 also bans "any phrasing that asserts a report exists, does not exist,
 * or is old", which no substring list can enforce. The literal list above is
 * the mechanical half; the catch-all is a review obligation, recorded here so
 * it is not mistaken for something the tests cover.
 */
export const FORBIDDEN_CATCHALL =
  'any phrasing that asserts a report exists, does not exist, or is old';

/**
 * Section 2.2b row 3 bans two words, `real-time` and `live`, and the list
 * above carries only the first. That asymmetry is deliberate, and until now
 * it was nowhere written down.
 *
 * `FORBIDDEN_SUBSTRINGS` is swept over the text `grammar()` emits, and that
 * text is composed from `WORDS`, integers and the separator alone. Neither
 * word can occur in it, so row 3 is unfalsifiable on that surface: the two
 * entries above guard the closed vocabulary, they do not check copy. Adding
 * `live` beside them would add a third assertion that cannot fail.
 *
 * `live` is not a substring ban in any case. As bare letters it fires on
 * `delivered`, `lives`, `outlive` and thirteen further words, 158 times in
 * this repository as of 935a9b5, including the paragraph above about dropped
 * live bans. So it is expressed as a word, and lives in its own list.
 *
 * `copy-surface.test.ts` and its Dart mirror are what run this list, over the
 * closed vocabulary and over the strings authored in the surface files. They
 * apply `FORBIDDEN_SUBSTRINGS` to those same surfaces at the same time: this
 * list is row 3, not a second home for the rest of the table. Note what that
 * makes it: the first mechanical enforcement SPEC.md section 13 guarantee 8
 * has ever had, because the substring sweep never reached a surface, a
 * fixture or a component.
 *
 * **A ruling is owed on the scope, and this list does not make it.** SPEC.md
 * decision 17 bans `live` flat; section 2.2b qualifies it "(as a promise)".
 * No pattern can read intent, so this one enforces the locked flat text and
 * fails closed. The collision sits inside a single table cell: decision 17
 * defines availability as "live status when reported" one clause before
 * banning the word, so that phrase would fail this check if it were ever
 * shipped as copy. Narrowing to the qualified reading is an edit to this
 * array; making that call is not this array's job.
 */
export const FORBIDDEN_COPY_PATTERNS: readonly string[] = [
  // Row 3 (ticket 28), the words rather than the letters. `real-?time` is the
  // two spellings already banned above, under a word boundary.
  '\\blive\\b',
  '\\breal-?time\\b',
];
