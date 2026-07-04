#!/usr/bin/env node
/**
 * check-en-parity.js — EN↔RU структурный паритет (полный гейт).
 *
 * Назначение: гарантировать, что EN-перевод (`<section>/en/<name>.md`) и
 * RU-оригинал (`<section>/<name>.md`) структурно совпадают:
 *   1. Coverage (двусторонний): у каждого RU .md есть EN-аналог и наоборот.
 *   2. Structural parity: множество §-номеров заголовков совпадает (нет
 *      пропущенных/лишних секций). Для файлов без нумерации (core/, plain
 *      guide/) — сравнение числа заголовков H2/H3 в пределах допуска.
 *
 * Конвенция директории (en-dir-frontmatter, reference/06 §0.3):
 *   standard/en/00-introduction.md  ↔  standard/00-introduction.md
 *   reference/en/01-glossary.md     ↔  reference/01-glossary.md
 *
 * Канон-идентификаторы (BR/SR/SPEC-<TYPE>/QG/§-номера) латиницей в обоих
 * языках, поэтому сравнение §-номеров язык-агностично.
 *
 * Exempt: руководства по стилю (reference/06-ru-style-guide ↔
 * reference/en/06-en-style-guide) — это параллельные языковые документы с
 * инвертированной полярностью, НЕ зеркальные переводы; из паритета исключены.
 *
 * Режимы:
 *   default      : сканирует корпус (coverage + structural). Нет EN-файлов → PASS.
 *   --self-test  : встроенные green + red фикстуры.
 *   --quiet      : подавить OK-вывод (для check:all).
 *   --root <dir> : корень корпуса (для тестов).
 *
 * Exit 0 — паритет соблюдён | Exit 1 — расхождение.
 */

import { readFileSync, readdirSync, statSync, existsSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2);
const QUIET = argv.includes("--quiet");
const SELF_TEST = argv.includes("--self-test");
const rootIdx = argv.indexOf("--root");
const root = rootIdx !== -1 ? argv[rootIdx + 1] : join(__dirname, "..");

const SECTIONS = ["standard", "reference", "guide", "core"];
// Style guides: language-specific parallel docs (06-en-style-guide ↔
// 06-ru-style-guide, inverted polarity), NOT name-mirrored translations.
const PARITY_EXEMPT = [
  /(^|\/)[0-9]*-?[a-z]*-?style-guide\.md$/, // 06-ru-style-guide.md / 06-en-style-guide.md
];
// Допуск числа заголовков для безномерных файлов (core/, plain guide/):
// билингв-заголовки могут схлопывать «### RU (EN)» в один.
const HEADING_TOLERANCE = 2;

// ── helpers ──────────────────────────────────────────────────────────
function isExempt(rel) {
  return PARITY_EXEMPT.some((re) => re.test(rel));
}

// Тело файла вне фронтматтера и код-фенсов, построчно.
function bodyLines(raw) {
  const lines = raw.split(/\r?\n/);
  const out = [];
  let inFence = false;
  let i = 0;
  if (lines[0] === "---") { i = 1; while (i < lines.length && lines[i] !== "---") i++; i++; }
  for (; i < lines.length; i++) {
    if (/^\s*```/.test(lines[i])) { inFence = !inFence; continue; }
    if (inFence) continue;
    out.push(lines[i]);
  }
  return out;
}

// Множество §-номеров заголовков (любой уровень): «## 3.5 …», «### §1.5 …».
function headingNums(raw) {
  const nums = [];
  for (const line of bodyLines(raw)) {
    const m = line.match(/^#{1,6}\s+§?\s?(\d+(?:\.\d+)+)\b/);
    if (m) nums.push(m[1]);
  }
  return nums;
}

// Число заголовков H2/H3 (для безномерных файлов).
function countHeadings(raw) {
  let n = 0;
  for (const line of bodyLines(raw)) if (/^#{2,3}\s/.test(line)) n++;
  return n;
}

function listMarkdown(dir) {
  const out = [];
  let entries;
  try { entries = readdirSync(dir); } catch { return out; }
  for (const entry of entries) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) out.push(...listMarkdown(full));
    else if (entry.endsWith(".md")) out.push(full);
  }
  return out;
}

const toRel = (f) => relative(root, f).replace(/\\/g, "/");
// EN `<section>/en/<name>.md` → RU `<section>/<name>.md`.
const ruCounterpart = (enRel) => enRel.replace(/\/en\//, "/");
// RU `<section>/<name>.md` → EN `<section>/en/<name>.md`.
const enCounterpart = (ruRel) => ruRel.replace(/^([^/]+)\//, "$1/en/");

// ── validation core (pure, testable) ─────────────────────────────────
// coverageItems: [{ rel, side: "ru"|"en", counterpartExists }]
// structItems:   [{ rel, ruNums:[], enNums:[], ruCount, enCount }]
function validateCoverage(items) {
  const problems = [];
  for (const it of items) {
    if (it.counterpartExists) continue;
    if (it.side === "ru") problems.push(`${it.rel}: missing EN counterpart ${enCounterpart(it.rel)}`);
    else problems.push(`${it.rel}: orphan EN file, missing RU counterpart ${ruCounterpart(it.rel)}`);
  }
  return problems;
}

function validateStructural(items) {
  const problems = [];
  for (const it of items) {
    const ruSet = new Set(it.ruNums);
    const enSet = new Set(it.enNums);
    if (ruSet.size > 0 || enSet.size > 0) {
      const missing = [...ruSet].filter((n) => !enSet.has(n));
      const extra = [...enSet].filter((n) => !ruSet.has(n));
      if (missing.length) problems.push(`${it.rel}: EN missing §-section(s) present in RU: ${missing.join(", ")}`);
      if (extra.length) problems.push(`${it.rel}: EN has extra §-section(s) absent in RU: ${extra.join(", ")}`);
    } else {
      const delta = Math.abs((it.enCount ?? 0) - (it.ruCount ?? 0));
      if (delta > HEADING_TOLERANCE) {
        problems.push(`${it.rel}: heading-count mismatch EN=${it.enCount} RU=${it.ruCount} (Δ=${delta} > ${HEADING_TOLERANCE})`);
      }
    }
  }
  return problems;
}

// ── self-test ────────────────────────────────────────────────────────
function selfTest() {
  const fails = [];
  const eq = (got, want, label) => { if (got !== want) fails.push(`${label}: expected ${want}, got ${got}`); };

  // coverage
  eq(validateCoverage([{ rel: "standard/en/00.md", side: "en", counterpartExists: true }]).length, 0, "cov/green-en");
  eq(validateCoverage([{ rel: "standard/00.md", side: "ru", counterpartExists: true }]).length, 0, "cov/green-ru");
  eq(validateCoverage([{ rel: "standard/00.md", side: "ru", counterpartExists: false }]).length, 1, "cov/red-missing-en");
  eq(validateCoverage([{ rel: "standard/en/99.md", side: "en", counterpartExists: false }]).length, 1, "cov/red-orphan");

  // structural — §-number sets
  eq(validateStructural([{ rel: "a", ruNums: ["1.1", "1.2"], enNums: ["1.1", "1.2"] }]).length, 0, "struct/green-equal");
  eq(validateStructural([{ rel: "a", ruNums: ["1.1", "1.2"], enNums: ["1.1"] }]).length, 1, "struct/red-missing");
  eq(validateStructural([{ rel: "a", ruNums: ["1.1"], enNums: ["1.1", "9.9"] }]).length, 1, "struct/red-extra");
  // structural — fallback heading count (no numbers)
  eq(validateStructural([{ rel: "b", ruNums: [], enNums: [], ruCount: 10, enCount: 10 }]).length, 0, "struct/green-count");
  eq(validateStructural([{ rel: "b", ruNums: [], enNums: [], ruCount: 10, enCount: 5 }]).length, 1, "struct/red-count");

  if (fails.length) {
    for (const f of fails) console.error(`SELF-TEST FAIL: ${f}`);
    console.error(`\ncheck-en-parity self-test: ${fails.length} failure(s)`);
    process.exit(1);
  }
  if (!QUIET) console.log("check-en-parity self-test: PASS (9 fixtures)");
  process.exit(0);
}

// ── main ─────────────────────────────────────────────────────────────
if (SELF_TEST) selfTest();

const allFiles = SECTIONS.flatMap((s) => listMarkdown(join(root, s))).map(toRel);
const ruFiles = allFiles.filter((r) => !/\/en\//.test(r) && !isExempt(r));
const enFiles = allFiles.filter((r) => /\/en\//.test(r) && !isExempt(r));

// Coverage (both directions).
const coverageItems = [
  ...ruFiles.map((rel) => ({ rel, side: "ru", counterpartExists: existsSync(join(root, enCounterpart(rel))) })),
  ...enFiles.map((rel) => ({ rel, side: "en", counterpartExists: existsSync(join(root, ruCounterpart(rel))) })),
];

// Structural (only for EN files whose RU counterpart exists).
const structItems = enFiles
  .filter((rel) => existsSync(join(root, ruCounterpart(rel))))
  .map((rel) => {
    const enRaw = readFileSync(join(root, rel), "utf8");
    const ruRaw = readFileSync(join(root, ruCounterpart(rel)), "utf8");
    return {
      rel,
      ruNums: headingNums(ruRaw),
      enNums: headingNums(enRaw),
      ruCount: countHeadings(ruRaw),
      enCount: countHeadings(enRaw),
    };
  });

const problems = [...validateCoverage(coverageItems), ...validateStructural(structItems)];

if (!QUIET) {
  console.log(`# check-en-parity.js — ${ruFiles.length} RU / ${enFiles.length} EN files (style guides exempt)`);
}
if (problems.length === 0) {
  if (!QUIET) console.log("OK   0 EN↔RU parity issues");
  process.exit(0);
}
for (const p of problems) console.log(`FAIL ${p}`);
console.log(`\nSummary: ${problems.length} EN↔RU parity issue(s)`);
process.exit(1);
