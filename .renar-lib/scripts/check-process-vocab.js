#!/usr/bin/env node
/**
 * check-process-vocab.js — terminology guard for the standard-change / conformance
 * process vocabulary.
 *
 * Decision (session #32, user-approved): the descriptive process lexicon around the
 * formal change procedure (§13.9) and conformance assessment is NOT a canonical
 * identifier and is NOT an accepted loanword (reference/06 §1.9 / §1.10). It reads as
 * macaronic in Russian prose and violates the voice camertone (§2.2 «один автор»).
 * Canonical RU forms are fixed in reference/06 §1.14. Latin survives ONLY in:
 *   - inline backticks (term definitions, code, schema keys),
 *   - fenced code / YAML,
 *   - file names and link targets (`08-conformance-self-assessment.md`),
 *   - HTML anchor ids (`<a id="...self-assessment-checklist...">`),
 *   - bilingual headers «### RU-название (Self-assessment)».
 * After stripping those, ANY remaining latin process-phrase in prose is a leak.
 *
 * Usage:
 *   node scripts/check-process-vocab.js [--quiet] [--baseline] [--root <dir>]
 * Exit 0 — clean (or --baseline). Exit 1 — leaks found.
 */

import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2);
const QUIET = argv.includes("--quiet");
const BASELINE = argv.includes("--baseline");
const rootIdx = argv.indexOf("--root");
const root = rootIdx !== -1 ? argv[rootIdx + 1] : join(__dirname, "..");

const SECTIONS = ["standard", "guide", "reference", "core"];

// EN process-phrase → RU canonical (reference/06 §1.14). Order: longer first.
const RULES = [
  [/\bformal change procedure\b/i, "формальная процедура изменения (стандарта)"],
  [/\bself-assessment checklists?\b/i, "чек-лист самооценки"],
  [/\bloss[- ]of[- ]conformance\b/i, "потеря соответствия"],
  [/\bcorresponding alignment\b/i, "согласующая правка"],
  [/\bmigration guidance\b/i, "руководство по миграции"],
  [/\b(?:minor-|major-)?version bump\b/i, "повышение (minor-/major-)версии"],
  [/\bresearch[- ]draft\b/i, "исследовательский черновик"],
  [/\bpublic review\b/i, "публичное обсуждение"],
  [/\bproject-local\b/i, "локальный для проекта / локально на уровне проекта"],
  // audit trail/log — prose SPACE-form only; identifier `audit-trail` (hyphen, §1.9) stays.
  [/\baudit (?:trail|log)s?\b/i, "журнал аудита (идентификатор audit-trail — оставить)"],
  // baseline — bare prose only; hyphenated identifiers (baseline-dataset, baseline-value) stay.
  [/\bbaseline\b(?!-)/i, "базовый уровень / базовые значения / эталон / опорное состояние (по контексту)"],
  // verdict — bare prose only; carved-out verdict-labels `no findings`/`findings present` live in backticks (masked).
  [/\bverdict\b/i, "вердикт"],
  // supersession family (ADR-007) — RU canonical «дезавуирование»; field names supersedes/superseded-by/
  // supersession-rationale/adapt-supersession live in backticks (masked); status `superseded` likewise.
  [/\bsupersession\b/i, "дезавуирование"],
  [/\bsuperseding\b/i, "дезавуирующий"],
  // re-pointing — prose only; → перенаправление.
  [/\bre-pointing\b/i, "перенаправление"],
  // NB: immutable / approval / findings deliberately NOT gated — they overlap canonical RENAR
  // names (QG-0 «Approval Gate», V1 gloss «immutable history», «Findings» metrics, §7 «backward
  // findings»), so a blocklist gate over-flags. Prose forms are normalized by hand per §1.14 note.
];

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

// Per-line prose mask: blank out frontmatter, fenced code, inline backticks,
// markdown link URLs, and HTML tags so only human-readable prose remains.
function proseLines(text) {
  const raw = text.split(/\r?\n/);
  const out = new Array(raw.length).fill("");
  let inFence = false;
  let i = 0;
  if (raw[0] === "---") {
    i = 1;
    while (i < raw.length && raw[i] !== "---") i++;
    i++; // skip closing ---
  }
  for (; i < raw.length; i++) {
    const line = raw[i];
    if (/^\s*```/.test(line)) { inFence = !inFence; continue; }
    if (inFence) continue;
    let masked = line
      .replace(/`[^`]*`/g, " ")           // inline code / term definitions
      .replace(/\]\([^)]*\)/g, "]")        // markdown link URL
      .replace(/<[^>]+>/g, " ");          // HTML tags (anchors)
    // Bilingual-header carve-out (§1.14): «### RU-название (EN-term)» — strip the
    // trailing EN gloss on heading lines so terminology mappings are not flagged.
    if (/^\s*#{1,6}\s/.test(line)) masked = masked.replace(/\([^)]*\)/g, " ");
    out[i] = masked;
  }
  return out;
}

const problems = [];
const files = SECTIONS.flatMap((s) => listMarkdown(join(root, s)));
let scanned = 0;
for (const file of files) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const raw = readFileSync(file, "utf8");
  // RU-scoped gate: EN translations (`*/en/`, lang:en) use native English process vocab — skip.
  if (/^lang:\s*"?en"?\s*$/m.test(raw.split("---")[1] || "")) continue;
  scanned++;
  const lines = proseLines(raw);
  lines.forEach((line, idx) => {
    if (!line) return;
    for (const [re, ru] of RULES) {
      const m = line.match(re);
      if (m) problems.push(`${rel}:${idx + 1} latin «${m[0]}» in prose → «${ru}» (reference/06 §1.14)`);
    }
  });
}

if (!QUIET) console.log(`# check-process-vocab.js — ${scanned} files scanned (RU-only; ${files.length - scanned} lang:en skipped)`);
if (problems.length === 0) {
  if (!QUIET) console.log("OK   0 process-vocabulary leaks (prose uses RU canonical §1.14)");
  process.exit(0);
}
for (const p of problems) console.log(`FAIL ${p}`);
console.log(`\nSummary: ${problems.length} process-vocabulary leak(s)`);
process.exit(BASELINE ? 0 : 1);
