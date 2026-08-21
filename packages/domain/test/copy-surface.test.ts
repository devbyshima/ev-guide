/**
 * The second instrument for docs/availability-display.md section 2.2b: the
 * bans, checked against **authored copy** rather than against emitted grammar.
 *
 * Why a second instrument exists at all. `FORBIDDEN_SUBSTRINGS` is swept in
 * grammar.test.ts and corpus-json.test.ts, and both sweeps run over the text
 * `grammar()` returns. That text is composed from `WORDS`, integers and the
 * separator alone, so a whole class of banned strings cannot occur in it and
 * those assertions cannot fail. `real-time` is one; `live`, which row 3 also
 * bans, was never in the list at all. Neither omission was a decision to stop
 * enforcing the row: it was that the only sweep in the repository pointed at
 * a surface where the row is unfalsifiable.
 *
 * This suite points at the surfaces where a copy author actually types, which
 * are the two the ban names: the closed vocabulary, and the string literals in
 * the files that render. It is the first mechanical enforcement SPEC.md
 * section 13 guarantee 8 has ever had.
 *
 * **Literals come from the TypeScript compiler, not from a regex.** A
 * hand-rolled scanner was written first and an adversarial pass broke it four
 * ways: a regex literal containing a quote inverted quote parity for the rest
 * of the file, an apostrophe in JSX text did the same, `'Live\nstatus'` lost
 * its word boundary because the escape was read as the letter `n`, and copy
 * nested in a `${...}` hole was skipped entirely. `ts.createSourceFile` has
 * none of those failure modes, gives cooked literal values, and reaches JSX
 * text as well. The Dart mirror cannot borrow it and carries a hand scanner
 * with those four cases pinned as tests.
 *
 * **What this does not reach, stated so it is not mistaken for cover.** A
 * store listing and an onboarding flow are also named by guarantee 8 and
 * neither is in this repository. `FORBIDDEN_CATCHALL` remains a review
 * obligation, and so does row 3 read in section 2.2b's qualified sense, since
 * no pattern can tell a promise from a description. Row 6, the ban on any
 * availability word on the accent badge, is a layout rule no string check can
 * express. And if copy ever moves into a resource format the scan will keep
 * passing over an empty surface, which the coverage guard below exists to
 * catch.
 */
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import ts from 'typescript';
import { describe, expect, it } from 'vitest';
import {
  connectorTypeWord,
  FORBIDDEN_CATCHALL,
  FORBIDDEN_COPY_PATTERNS,
  FORBIDDEN_SUBSTRINGS,
  WORDS,
} from '../src/vocabulary';
import type { ConnectorType } from '../src/types';

const ROOT = fileURLToPath(new URL('../../..', import.meta.url));

/**
 * The copy-bearing source roots. `packages/domain/src/vocabulary.ts` is
 * excluded by name because it is where the bans are written down: its literals
 * are the patterns themselves, and the closed vocabulary it exports is checked
 * directly below instead, which is the stronger check.
 */
const SURFACE_ROOTS = ['packages/ui/src', 'packages/data/src', 'packages/domain/src'];
const EXCLUDED = ['packages/domain/src/vocabulary.ts'];

function sourceFiles(root: string): string[] {
  const found: string[] = [];
  const walk = (rel: string) => {
    for (const entry of readdirSync(`${ROOT}${rel}`).sort()) {
      const child = `${rel}/${entry}`;
      if (statSync(`${ROOT}${child}`).isDirectory()) {
        walk(child);
      } else if (/\.tsx?$/.test(entry) && !EXCLUDED.includes(child)) {
        found.push(child);
      }
    }
  };
  walk(root);
  return found;
}

/**
 * Every authored string in a TypeScript source: string literals, each span of
 * a template, and JSX text. Comments are not nodes of these kinds and so are
 * skipped for free, which matters because ordinary domain prose uses the
 * banned words descriptively: `unreported` appears in four comments in the
 * roots this suite scans, stating the derivation law and describing a
 * fixture, and in four more in the Dart mirror. Values are cooked, so `\n` is
 * a newline rather than the letter `n`.
 */
function stringLiterals(source: string, fileName = 'surface.tsx'): string[] {
  const tree = ts.createSourceFile(
    fileName,
    source,
    ts.ScriptTarget.Latest,
    true,
    fileName.endsWith('.tsx') ? ts.ScriptKind.TSX : ts.ScriptKind.TS,
  );
  const found: string[] = [];
  const visit = (node: ts.Node): void => {
    if (
      ts.isStringLiteralLike(node) ||
      ts.isTemplateHead(node) ||
      ts.isTemplateMiddle(node) ||
      ts.isTemplateTail(node) ||
      ts.isJsxText(node)
    ) {
      found.push(node.text);
    }
    ts.forEachChild(node, visit);
  };
  visit(tree);
  return found;
}

const patterns = FORBIDDEN_COPY_PATTERNS.map((source) => ({
  source,
  regex: new RegExp(source, 'i'),
}));

/**
 * Every ban section 2.2b can express mechanically, applied to one string.
 *
 * Both lists are applied: the literals of rows 1, 2 and 7 and the row 3
 * patterns. The literals are matched as substrings here exactly as they are
 * over grammar text, which on a surface is a slightly wider net than on the
 * closed vocabulary (`in use` is inside "sign in user"). A hit is a review
 * prompt, and no phrase in the repository trips one.
 */
function offences(text: string): string[] {
  const lower = text.toLowerCase();
  return [
    ...FORBIDDEN_SUBSTRINGS.filter((banned) => lower.includes(banned)),
    ...patterns.filter((p) => p.regex.test(text)).map((p) => p.source),
  ];
}

describe('the closed vocabulary carries no banned word', () => {
  it('holds for every display word and every connector projection', () => {
    const types: ConnectorType[] = [
      'IEC_62196_T2',
      'IEC_62196_T2_COMBO',
      'GBT_AC',
      'GBT_DC',
      'OTHER',
      'UNKNOWN',
    ];
    const emitted = [...Object.values(WORDS), ...types.map(connectorTypeWord)];
    for (const word of emitted) {
      expect(offences(word), `vocabulary word: ${word}`).toEqual([]);
    }
  });
});

describe('no authored literal on a surface carries a banned word', () => {
  const files = SURFACE_ROOTS.flatMap(sourceFiles);

  it('holds for every string literal in every surface file', () => {
    for (const file of files) {
      for (const literal of stringLiterals(readFileSync(`${ROOT}${file}`, 'utf8'), file)) {
        expect(offences(literal), `${file}: ${JSON.stringify(literal)}`).toEqual([]);
      }
    }
  });

  it('actually scanned the surfaces, rather than passing over nothing', () => {
    // A green scan of an empty set is the one failure a green test cannot
    // report, so the floors are asserted. Today: 3 roots, 15 files, 324
    // literals. The floors sit below those and above zero, so ordinary edits
    // do not move them but a surface going dark does.
    for (const root of SURFACE_ROOTS) {
      expect(sourceFiles(root).length, `no files under ${root}`).toBeGreaterThan(0);
    }
    expect(files.length).toBeGreaterThanOrEqual(10);
    const literals = files.flatMap((f) => stringLiterals(readFileSync(`${ROOT}${f}`, 'utf8'), f));
    expect(literals.length).toBeGreaterThanOrEqual(150);
  });

  it('reads authored strings and not comments', () => {
    // The guard on the guard. `unreported` is banned by row 1 and occurs in
    // availability.ts only inside comments, where it states the derivation
    // law rather than any ban. The scan must not report the prose of the
    // domain as a violation of it.
    const source = readFileSync(`${ROOT}packages/domain/src/availability.ts`, 'utf8');
    expect(source).toContain('unreported');
    expect(stringLiterals(source, 'availability.ts').join(' ')).not.toContain('unreported');
  });
});

describe('the scanner survives the ways copy can hide', () => {
  // Each case broke the hand-rolled scanner this suite started with. They are
  // pinned because the Dart mirror still hand-rolls, and because a future
  // change of extraction must clear the same bar.
  const banned = (source: string, fileName?: string) =>
    stringLiterals(source, fileName).filter((t) => offences(t).length > 0);

  it('sees copy split across two lines by an escape', () => {
    expect(banned("const label = 'Live\\nstatus';")).toEqual(['Live\nstatus']);
  });

  it('sees copy nested inside an interpolation hole', () => {
    expect(banned('const label = `${empty ? `Live availability` : `free`} now`;')).toEqual([
      'Live availability',
    ]);
  });

  it('is not desynchronised by a regex literal holding a quote', () => {
    const source = "const smart = /['’]/g;\nconst label = 'Live availability';";
    expect(banned(source)).toEqual(['Live availability']);
  });

  it('reads JSX text, and an apostrophe in it hides nothing', () => {
    const source = "const a = <T>Don't miss a bay</T>;\nconst b = <T>Live availability</T>;";
    expect(banned(source, 'surface.tsx')).toEqual(['Live availability']);
  });
});

describe('the copy patterns ban the word and not the letters', () => {
  it('catches the promise phrasings the category invites', () => {
    for (const copy of [
      'live availability',
      'Live status',
      'Live',
      'See live bay status',
      'real-time availability',
      'Realtime bays',
      'REAL-TIME',
    ]) {
      expect(offences(copy), `should be banned: ${copy}`).not.toEqual([]);
    }
  });

  it('spares the words that merely contain those letters', () => {
    // The first ten are what a bare substring ban on `live` would flag. All
    // ten occur in this repository, and sixteen such words occur in all,
    // 158 times between them as of 935a9b5. `olive` closes the list because
    // it is the standard counter-example, not because it occurs here.
    for (const innocent of [
      'delivered',
      'delivery',
      'deliverable',
      'undeliverable',
      'deliverability',
      'lives',
      'lived',
      'outlive',
      'alive',
      'liveness',
      'olive',
    ]) {
      expect(offences(innocent), `should be allowed: ${innocent}`).toEqual([]);
    }
  });
});

describe('the forbidden lists are the exact section 2.2b union', () => {
  // The Dart transcription pins these in structural_test.dart; without the
  // same pin here the reference could be shortened and only the copy would
  // notice. A ban is data, and data that only one port asserts has drifted
  // once already (ticket 32).
  it('the substring list carries the fourteen literals, in order', () => {
    expect(FORBIDDEN_SUBSTRINGS).toEqual([
      'unreported',
      'not reported',
      'no recent report',
      'no report yet',
      'no reports yet',
      'last reported',
      'awaiting a report',
      'unknown rate',
      'rate unavailable',
      'no rate reported',
      'no published rate',
      'real-time',
      'realtime',
      'in use',
    ]);
    expect(FORBIDDEN_CATCHALL).toBe(
      'any phrasing that asserts a report exists, does not exist, or is old',
    );
  });

  it('the copy-pattern list carries row 3 as words', () => {
    expect(FORBIDDEN_COPY_PATTERNS).toEqual(['\\blive\\b', '\\breal-?time\\b']);
  });
});
