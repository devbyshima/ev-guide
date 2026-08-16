/**
 * The eight laws of docs/availability-display.md section 2.2. Each law says
 * "each one is a required test", so each one is a test here.
 *
 * Several are asserted exhaustively over the whole small input space rather
 * than by example, because "for any input" is what the law says.
 */
import { describe, expect, it } from 'vitest';
import { grammar, regimeOf, type GrammarInput, type Verbosity } from '../src/grammar';
import { FORBIDDEN_SUBSTRINGS, WORDS } from '../src/vocabulary';

/** Every partition of n bays into the four states, for n up to 5. */
function* allCounts(maxN = 5): Generator<GrammarInput> {
  for (let n = 0; n <= maxN; n += 1) {
    for (let free = 0; free <= n; free += 1) {
      for (let occupied = 0; occupied <= n - free; occupied += 1) {
        for (let outOfService = 0; outOfService <= n - free - occupied; outOfService += 1) {
          const unknown = n - free - occupied - outOfService;
          yield { n, free, occupied, outOfService, unknown };
        }
      }
    }
  }
}

const VERBOSITIES: Verbosity[] = ['full', 'short', 'minimal'];

describe('law 1: "0 of N" is never emitted, for any input', () => {
  it('holds across every partition and verbosity', () => {
    for (const c of allCounts()) {
      for (const v of VERBOSITIES) {
        const { text } = grammar(c, v);
        expect(text, `counts=${JSON.stringify(c)} verbosity=${v}`).not.toMatch(/\b0 of\b/);
      }
    }
  });
});

describe('law 2: a total appears only when u = 0', () => {
  it('no "of" clause survives while anything is unknown', () => {
    for (const c of allCounts()) {
      if (c.unknown === 0) continue;
      for (const v of VERBOSITIES) {
        const { text } = grammar(c, v);
        // A "total" is the "N of M" construction. Note that the bare
        // substring "of" also occurs inside "out of service", which is why
        // this matches the construction and not the word.
        expect(text, JSON.stringify(c)).not.toMatch(/\d+ of \d+/);
        expect(text, JSON.stringify(c)).not.toMatch(/\bAll\b/);
      }
    }
  });
});

describe('law 3: busy quantifies o and nothing else', () => {
  it('the number attached to busy is always exactly o', () => {
    for (const c of allCounts()) {
      const { text } = grammar(c);
      const m = text.match(/(\d+) busy/);
      if (m) expect(Number(m[1]), JSON.stringify(c)).toBe(c.occupied);
      // And when nothing is occupied the word cannot appear at all.
      if (c.occupied === 0) expect(text, JSON.stringify(c)).not.toContain(WORDS.busy);
    }
  });
});

describe('law 4: OutOfService never folds into occupancy, and survives the shortest variant', () => {
  it('carries its own clause with its own count, never folded into busy', () => {
    for (const c of allCounts()) {
      if (c.outOfService === 0) continue;
      const { text } = grammar(c);
      // It appears, counted separately...
      expect(text, JSON.stringify(c)).toContain(`${c.outOfService} ${WORDS.outOfService}`);
      // ...and the busy clause, if any, still quantifies only o. The failure
      // this guards is a roll-up that reports "3 busy" over 2 occupied bays
      // and 1 broken one, which sends a driver to wait for a repair.
      const m = text.match(/(\d+) busy/);
      if (m) expect(Number(m[1]), JSON.stringify(c)).not.toBe(c.occupied + c.outOfService);
    }
  });

  it('survives to minimal verbosity whenever x > 0', () => {
    for (const c of allCounts()) {
      if (c.outOfService === 0) continue;
      const { text } = grammar(c, 'minimal');
      expect(text, JSON.stringify(c)).toContain(WORDS.outOfService);
    }
  });
});

describe('law 5: never "all" beside "busy" when x > 0', () => {
  it('holds across every partition', () => {
    for (const c of allCounts()) {
      const { text } = grammar(c);
      if (c.outOfService > 0) expect(text, JSON.stringify(c)).not.toContain(WORDS.all);
    }
  });
});

describe('law 6: singular forms', () => {
  it('never emits "1 of 1" or "All 1"', () => {
    for (const c of allCounts()) {
      for (const v of VERBOSITIES) {
        const { text } = grammar(c, v);
        expect(text).not.toContain('1 of 1');
        expect(text).not.toContain('All 1');
      }
    }
  });

  it('uses "bay" not "bays" at n = 1', () => {
    const { text } = grammar({ n: 1, free: 0, occupied: 0, outOfService: 0, unknown: 1 });
    expect(text).toBe('1 bay · no confirmed status');
  });
});

describe('law 8: no string asserts report history', () => {
  it('no forbidden substring is emitted, for any input or verbosity', () => {
    for (const c of allCounts()) {
      for (const v of VERBOSITIES) {
        for (const input of [c, { ...c, otherBays: 2 }]) {
          const { text } = grammar(input, v);
          for (const banned of FORBIDDEN_SUBSTRINGS) {
            expect(text.toLowerCase(), `${JSON.stringify(input)} / ${banned}`).not.toContain(
              banned,
            );
          }
        }
      }
    }
  });
});

describe('the three regimes partition the space', () => {
  it('every input falls in exactly one regime, and regime 1 carries no state word', () => {
    const stateWords = [WORDS.free, WORDS.busy, WORDS.outOfService, WORDS.unknown];
    for (const c of allCounts()) {
      const r = regimeOf(c);
      expect([1, 2, 3]).toContain(r);
      if (r === 1 && c.n > 0) {
        const { text } = grammar(c);
        // Regime 1 is capacity only: never a state word, because "0 free"
        // over unreported bays claims they are not free.
        for (const w of stateWords) expect(text, JSON.stringify(c)).not.toContain(w);
        expect(text).toContain(WORDS.noConfirmedStatus);
      }
    }
  });

  it('regime 2 permits a total', () => {
    const { regime, text } = grammar({ n: 4, free: 2, occupied: 2, outOfService: 0, unknown: 0 });
    expect(regime).toBe(2);
    expect(text).toBe('2 of 4 bays free · 2 busy');
  });

  it('regime 3 emits counts without a total', () => {
    const { regime, text } = grammar({ n: 4, free: 1, occupied: 1, outOfService: 1, unknown: 1 });
    expect(regime).toBe(3);
    expect(text).toBe('1 free · 1 busy · 1 out of service · 1 unknown');
  });
});
