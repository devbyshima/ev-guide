/**
 * The display grammar, docs/availability-display.md section 2.
 *
 * `G(n, f, o, x, u, verbosity, lens) -> clauses`, with one fixed drop order.
 * Three regimes partition the space and they are the whole grammar.
 *
 * Every law in section 2.2 is enforced here and asserted in test/grammar.test.ts.
 * The laws are not comments: a law without a test is a suggestion.
 */
import type { StateCounts } from './availability';
import { WORDS } from './vocabulary';

export type Verbosity = 'full' | 'short' | 'minimal';

export type Regime = 1 | 2 | 3;

export interface GrammarInput extends StateCounts {
  /**
   * Bays outside the lens. Named **once, uncounted** on one side of the
   * partition ("2 other bays"), never folded into the counts.
   */
  readonly otherBays?: number;
}

export interface GrammarResult {
  readonly regime: Regime;
  readonly clauses: readonly string[];
  /** The clauses joined with the separator every surface uses. */
  readonly text: string;
}

const SEP = ' · ';

function pluralBays(k: number): string {
  return `${k} ${k === 1 ? WORDS.bay : WORDS.bays}`;
}

export function regimeOf(c: StateCounts): Regime {
  if (c.free === 0 && c.occupied === 0 && c.outOfService === 0) return 1;
  if (c.unknown === 0) return 2;
  return 3;
}

/**
 * The drop order, applied when verbosity is reduced. Section 2.1 requires
 * "one fixed drop order" without enumerating it; this is that enumeration,
 * and it is constrained by **law 4** (OutOfService survives to the shortest
 * variant of every string), which is why `outOfService` is last to go.
 *
 * Dropped first -> last: unknown, occupied, free, outOfService.
 */
const DROP_ORDER = ['unknown', 'occupied', 'free', 'outOfService'] as const;

const KEEP_BY_VERBOSITY: Record<Verbosity, number> = {
  full: 4,
  short: 2,
  minimal: 1,
};

export function grammar(
  input: GrammarInput,
  verbosity: Verbosity = 'full',
): GrammarResult {
  const regime = regimeOf(input);
  const clauses =
    regime === 1
      ? regime1(input)
      : regime === 2
        ? regime2(input, verbosity)
        : regime3(input, verbosity);

  const withRemainder = appendRemainder(clauses, input);
  return { regime, clauses: withRemainder, text: withRemainder.join(SEP) };
}

/**
 * Regime 1: everything in scope is Unknown. Capacity clause only, and **never
 * a state word** - saying "0 free" over bays nobody has reported claims they
 * are not free, and at ~87% Unknown that is the normal case.
 */
function regime1(c: GrammarInput): string[] {
  if (c.n === 0) return [];
  return [pluralBays(c.n), WORDS.noConfirmedStatus];
}

/**
 * Regime 2: nothing is Unknown, so the denominator **is** the known set by
 * construction and a total is permitted (law 2).
 */
function regime2(c: GrammarInput, verbosity: Verbosity): string[] {
  // Law 5: never "all" beside "busy" when x > 0, because "all" would be
  // quantifying a set that contains out-of-service bays.
  if (c.free === c.n && c.n > 1 && c.outOfService === 0) {
    return [`${WORDS.all} ${c.n} ${WORDS.bays} ${WORDS.free}`];
  }

  const parts: string[] = [];
  if (c.free > 0) {
    // Law 6: no "1 of 1". Law 1: "0 of N" is unreachable here anyway, since a
    // zero free count simply emits no free clause.
    parts.push(
      c.n === 1
        ? `${pluralBays(1)} ${WORDS.free}`
        : `${c.free} ${WORDS.of} ${pluralBays(c.n)} ${WORDS.free}`,
    );
  }
  // Law 3: busy quantifies o and nothing else. Law 4: out of service never
  // folds into occupancy at any count.
  if (c.occupied > 0) parts.push(`${c.occupied} ${WORDS.busy}`);
  if (c.outOfService > 0) parts.push(`${c.outOfService} ${WORDS.outOfService}`);

  if (parts.length === 0) return [pluralBays(c.n)];
  return trim(parts, c, verbosity);
}

/**
 * Regime 3: mixed. Counts **without** a total, because a denominator here
 * would be counting bays whose state nobody knows (law 1, law 2).
 */
function regime3(c: GrammarInput, verbosity: Verbosity): string[] {
  const parts: string[] = [];
  if (c.free > 0) parts.push(`${c.free} ${WORDS.free}`);
  if (c.occupied > 0) parts.push(`${c.occupied} ${WORDS.busy}`);
  if (c.outOfService > 0) parts.push(`${c.outOfService} ${WORDS.outOfService}`);
  if (c.unknown > 0) parts.push(`${c.unknown} ${WORDS.unknown}`);
  return trim(parts, c, verbosity);
}

/**
 * Apply the fixed drop order. Out-of-service is preserved even at `minimal`,
 * per law 4, so a shortened string can carry it alone.
 */
function trim(parts: string[], c: GrammarInput, verbosity: Verbosity): string[] {
  const keep = KEEP_BY_VERBOSITY[verbosity];
  if (parts.length <= keep) return parts;

  const labelled = parts.map((text) => ({ text, key: keyOf(text) }));
  const survivors = [...labelled];
  for (const dropKey of DROP_ORDER) {
    if (survivors.length <= keep) break;
    // Law 4: out of service is never dropped while anything else remains.
    if (dropKey === 'outOfService' && c.outOfService > 0 && survivors.length > 1) {
      continue;
    }
    const i = survivors.findIndex((p) => p.key === dropKey);
    if (i >= 0) survivors.splice(i, 1);
  }
  return survivors.map((p) => p.text);
}

function keyOf(text: string): (typeof DROP_ORDER)[number] | 'free' {
  if (text.includes(WORDS.outOfService)) return 'outOfService';
  if (text.includes(WORDS.busy)) return 'occupied';
  if (text.includes(WORDS.unknown)) return 'unknown';
  return 'free';
}

/**
 * Under a lens the remainder is named **once, uncounted**, on one side of the
 * partition. It is never broken down by state: doing so would re-import the
 * unlensed aggregate the lens exists to avoid.
 */
function appendRemainder(clauses: readonly string[], c: GrammarInput): string[] {
  const other = c.otherBays ?? 0;
  if (other <= 0) return [...clauses];
  return [...clauses, `${other} ${WORDS.other} ${other === 1 ? WORDS.bay : WORDS.bays}`];
}
