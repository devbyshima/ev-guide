/**
 * The closed vocabulary. docs/availability-display.md section 2.4: the display
 * words are **data in packages/domain**, not string literals in a Swift file
 * and a Kotlin file. Neither transcription may invent a word.
 */
import type { ConnectorType } from './types.js';

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
