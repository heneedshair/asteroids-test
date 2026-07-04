#!/usr/bin/env node
/**
 * Style Guide automated checks for RENAR chapter .md files.
 *
 * Implements 6 Phase 5 chapter-pass checks listed in
 * reference/06-ru-style-guide.md §4.3:
 *
 *   1. bucket-a       — Bucket A whitelist case-consistency (§1.13.1.1)
 *   2. bucket-e       — Bucket E rewrite-target presence (§1.13.1.5)
 *   3. legacy         — Legacy labels / QG names (§1.13.1.7-8)
 *   4. en-uppercase   — RFC-2119 EN keywords in RU prose (§2.10.1.1)
 *   5. fence-lang     — Code-fences without lang tag (§3.10.1.2)
 *   6. ascii-quote    — ASCII `"..."` in RU prose (§3.10.1.6)
 *
 * Scanning model: walk standard/ guide/ reference/ core/ recursively,
 * exclude README.md. For prose-only checks (Bucket A/E, legacy, EN
 * UPPERCASE, ASCII-quote) strip YAML frontmatter + fenced code blocks
 * + inline backticks so code examples and config snippets do not raise
 * false positives. Fence-lang scan operates on raw text.
 *
 * Language gate: chapters with `lang: en` skip the prose RU-targeted
 * checks (en-uppercase, ascii-quote) per §2.2.5 EN translation
 * convention. Bucket E / legacy / Bucket A apply substrate-wide.
 *
 * Usage:
 *   node scripts/style-guide-check.js              # all checks
 *   node scripts/style-guide-check.js --quiet      # findings only
 *   node scripts/style-guide-check.js --check=<n>  # one check
 *
 * Exit 0 — clean. Exit 1 — findings emitted.
 *
 * Substrate stance: this is enforcement tooling, not normative spec.
 * Bucket lists embedded here must mirror reference/06; on Style Guide
 * version bump, manually re-sync the closed lists below and bump
 * SCRIPT_VERSION.
 */

import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const SECTIONS = ["standard", "guide", "reference", "core"];

const SCRIPT_VERSION = "0.2.3";
const STYLE_GUIDE_TARGET = "reference/06-ru-style-guide.md v1.3 (anglicism-label check: **Label:** form)";

// Files where EN RFC-2119 keywords appear in descriptive context and
// are exempt from the en-uppercase prose check:
//   - reference/04-ai-style-guide.md — §2.7.2 explicit carve-out.
//   - reference/06-ru-style-guide.md — the style guide itself
//     describes the keywords throughout §2.
// All other RU files: flag.
const EN_UPPERCASE_DESCRIPTIVE_FILES = new Set([
  "reference/04-ai-style-guide.md",
  "reference/06-ru-style-guide.md",
]);

// ---------- closed lists (mirror reference/06) ----------

// §1.3.1 Bucket A whitelist — canonical lowercase latin.
// NB: `substrate` removed in v0.2.1 — canonical RU term is «носитель» (session #27
// decision). Latin `substrate` survives only in field names (`substrate-capabilities`),
// code/YAML, and file names — none of which this prose check inspects.
const BUCKET_A = [
  "commit", "merge", "diff", "branch", "push", "pull", "hook", "patch",
  "frontmatter", "manifest", "slug", "hash", "trigger", "runner", "pipeline",
  "release", "deploy", "build", "workflow", "linter", "parser", "compiler",
  "tooling", "tracker", "provenance", "fallback",
];

// §1.7.1 Bucket E rewrite кальки — flag in prose.
// Word-stem patterns capture inflected forms.
const BUCKET_E = [
  { stem: "имплементаци", note: "→ реализация / исполнение" },
  { stem: "конформаци",   note: "→ соответствие (за вычетом ISO 29148 substrate context)" },
  { stem: "эссенциальн",  note: "→ существенный / обязательный" },
  { stem: "дрифт",        note: "→ дрейф / расхождение (translit form only; latin `drift` OK per §3.11)" },
  { stem: "трейс",        note: "→ трасс* / отслеживание (calque form only; latin `traceability` OK)" },
  { stem: "регуляци",     note: "→ регулирование" },
];

// §1.13.1.7-8 Legacy labels / QG names. QG entries are FULL prefixed
// legacy strings — bare `Verification Gate` / `Implementation Gate`
// without QG-N prefix are canonical post-amendment 003 (§1.9.4).
const LEGACY_LABELS = [
  "UIC", "AIC", "INT-SR", "INT-TC", "TM", "TS",
  "QG-0 Context Gate", "QG-1 Requirements Gate",
  "QG-2 Implementation Gate", "QG-3 Verification Gate",
];

// §1.13.1.8 (amendment 004): legacy labels are flagged ONLY when used as
// a current term. Legitimate citations are NOT flagged — mirrors
// amendment 003's QG-name narrowing. A label occurrence is a citation if:
//   (a) the line carries a deprecation/migration marker word, or
//   (b) the line is a legacy→canonical mapping row (legacy label paired
//       with its canonical replacement token), or
//   (c) the enclosing section heading marks migration/legacy context.
const LEGACY_CITATION_MARKER =
  /устаревш|историческ|historical|legacy|deprecated|reconcil|реконсил|миграц|migration|замен|pre-v1\.0|traceabilit|removed|стар(ых|ые|ой|ого|ым|ом|ое)/iu;
const LEGACY_SECTION_MARKER =
  /миграц|migration|legacy|устаревш|deprecated|reconcil|реконсил/iu;
// Canonical replacement token per short legacy label — presence on the
// same line marks a mapping row (citation, not misuse).
const LEGACY_CANONICAL = {
  "UIC": /SPEC-UI/,
  "AIC": /SPEC-AI/,
  "INT-SR": /SPEC-INT/,
  "INT-TC": /tc-type|SPEC-INT/,
  "TM": /level:\s*module/,
  "TS": /SPEC-ARCH|SPEC-OPS|SPEC-DATA|SPEC-API|SPEC-PROC|SPEC-SEC|SPEC-<TYPE>/,
};

// §2.10.1.1 RFC-2119 EN keywords (RU corpus must not use).
const RFC2119_EN = [
  "MUST NOT", "MUST", "SHALL NOT", "SHALL",
  "SHOULD NOT", "SHOULD", "MAY", "RECOMMENDED",
  "NOT RECOMMENDED", "REQUIRED", "OPTIONAL",
];

// §1.13 Compression anglicism creep — bold-label paragraph headers
// in mid-prose `**English Word:**` that aren't in the canonical
// closed lists. Style guide v1.3+ flags these as compression-failure
// signals. Allowed EN bold-labels: canonical RENAR terms from §1.9
// (ADAPT, SoT, V1-V6) + accepted technical loanwords from §1.10
// (state machine, atomic change unit, etc) + RFC-2119 EN keywords
// in descriptive context.
//
// Pattern: line starts with optional list/blockquote markers, then
// `**Word:**` or `**Word Word:**` where Word starts with [A-Z][a-z]+.
// Whitelisted: canonical RENAR terms + accepted loanwords below.
const ANGLICISM_LABEL_WHITELIST = new Set([
  // §1.9 canonical RENAR terms (also acts as section identifiers).
  "ADAPT", "BR", "SR", "SPEC", "TR", "TC", "TZ", "MVR", "RENAR", "SENAR",
  "QG", "SoT", "SoA",
  // §1.10 accepted technical loanwords.
  "Adversarial", "Provenance", "Traceability", "Backward", "Forward",
  "Closed", "Schema", "Frontmatter",
  // §1.10+ RENAR-canonical structural section labels (pre-existing in
  // standard/08 SPEC type extensions and reference/04 AI style guide).
  "Type-specific", "Mandatory", "Body",
  // Accepted structural labels + proper nouns.
  "Notes", "Note", "Example", "Pattern", "Anti-pattern", "GDPR",
]);
// Matches a bold paragraph-label at line start in BOTH conventions:
//   `**Label:**` (colon inside the bold — the corpus convention) and
//   `**Label**:` (colon after). Capture group is the label without colon.
const ANGLICISM_LABEL_RE =
  /^(?:\s*[-*>]\s+)?\*\*([A-Z][A-Za-z][A-Za-z\-/ ]{0,40}?)(?::\*\*|\*\*[:.])/;

// ---------- CLI ----------

const ARGS = process.argv.slice(2);
const QUIET = ARGS.includes("--quiet");
const CHECK_FILTER = (() => {
  const arg = ARGS.find((a) => a.startsWith("--check="));
  return arg ? arg.slice("--check=".length) : null;
})();
const ALL_CHECKS = ["bucket-a", "bucket-e", "legacy", "en-uppercase", "fence-lang", "ascii-quote", "anglicism-label"];
const ACTIVE_CHECKS = CHECK_FILTER ? new Set([CHECK_FILTER]) : new Set(ALL_CHECKS);

if (CHECK_FILTER && !ALL_CHECKS.includes(CHECK_FILTER)) {
  console.error(`Unknown check: ${CHECK_FILTER}`);
  console.error(`Available: ${ALL_CHECKS.join(", ")}`);
  process.exit(2);
}

// ---------- walking ----------

function listMarkdown(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      out.push(...listMarkdown(full));
    } else if (entry.endsWith(".md") && entry !== "README.md") {
      out.push(full);
    }
  }
  return out;
}

// ---------- frontmatter + prose stripping ----------

const FRONTMATTER_RE = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/;

function detectLang(text) {
  const m = FRONTMATTER_RE.exec(text);
  if (!m) return null;
  const mm = /^\s*lang:\s*"?([a-z]{2})"?\s*$/m.exec(m[1]);
  return mm ? mm[1] : null;
}

// Build a parallel "prose mask" array: prose[i] is the original text's
// character at line i+1 with code-fences, frontmatter, and inline
// backticks blanked out. This way line numbers stay aligned with the
// source file when reporting findings.
function buildProseLines(text) {
  const rawLines = text.split(/\r?\n/);
  const out = new Array(rawLines.length);
  let inFrontmatter = false;
  let inFence = false;
  let lineIdx = 0;

  if (rawLines[0] === "---") {
    inFrontmatter = true;
    out[0] = "";
    lineIdx = 1;
    while (lineIdx < rawLines.length) {
      out[lineIdx] = "";
      if (rawLines[lineIdx] === "---") {
        lineIdx++;
        inFrontmatter = false;
        break;
      }
      lineIdx++;
    }
  }

  for (; lineIdx < rawLines.length; lineIdx++) {
    const line = rawLines[lineIdx];
    if (/^\s*```/.test(line)) {
      out[lineIdx] = "";
      inFence = !inFence;
      continue;
    }
    if (inFence || inFrontmatter) {
      out[lineIdx] = "";
      continue;
    }
    // Strip inline backtick content (preserve length-ish; replace with spaces).
    out[lineIdx] = line.replace(/`[^`]*`/g, (m) => " ".repeat(m.length));
  }

  return out;
}

// ---------- checks ----------

function checkBucketA(proseLines, findings) {
  // Flag whitelisted Bucket A terms in mid-sentence Capitalized form
  // (likely paste-error). Sentence-start capitalization is RU
  // orthographic norm and is NOT flagged — §1.3 mandates "stays
  // latin", not "stays lowercase". The strict-lowercase rule in
  // §1.4.2 applies to Bucket B status vocabulary, not Bucket A.
  //
  // Heuristic for sentence-start: preceding non-whitespace char
  // on the line is `.`, `!`, `?`, `:`, `—`, or term is at line
  // start (after optional list/heading/quote markdown markers).
  const wrong = BUCKET_A.map((t) => new RegExp(`\\b${t.charAt(0).toUpperCase() + t.slice(1)}\\b`, "g"));
  const SENTENCE_BREAK_RE = /[.!?:—]\s*$/;
  const LINE_START_RE = /^[\s>*\-#|]*$/;
  for (let i = 0; i < proseLines.length; i++) {
    const line = proseLines[i];
    if (!line) continue;
    for (let j = 0; j < wrong.length; j++) {
      const re = wrong[j];
      re.lastIndex = 0;
      let m;
      while ((m = re.exec(line))) {
        const prefix = line.slice(0, m.index);
        if (LINE_START_RE.test(prefix) || SENTENCE_BREAK_RE.test(prefix)) continue;
        findings.push({
          line: i + 1,
          check: "bucket-a",
          message: `mid-sentence capitalized Bucket A term \`${m[0]}\` — canonical lowercase \`${BUCKET_A[j]}\` per §1.3`,
        });
      }
    }
  }
}

function checkBucketE(proseLines, findings) {
  for (let i = 0; i < proseLines.length; i++) {
    const line = proseLines[i];
    if (!line) continue;
    for (const { stem, note } of BUCKET_E) {
      const re = new RegExp(`\\b${stem}\\p{L}*`, "giu");
      let m;
      while ((m = re.exec(line))) {
        findings.push({
          line: i + 1,
          check: "bucket-e",
          message: `Bucket E rewrite target \`${m[0]}\` ${note} (§1.7.1)`,
        });
      }
    }
  }
}

function checkLegacy(proseLines, findings) {
  const escaped = LEGACY_LABELS.map((l) => l.replace(/[-]/g, "\\-"));
  const re = new RegExp(`\\b(${escaped.join("|")})\\b`, "g");
  // §1.13.1.8 amendment 004: a heading marking migration/legacy starts a
  // citation context that persists through its subsections (deeper
  // headings) until a same-or-shallower heading ends it.
  let citationLevel = null;
  for (let i = 0; i < proseLines.length; i++) {
    const line = proseLines[i];
    if (!line) continue;
    const h = /^\s{0,3}(#{1,6})\s/.exec(line);
    if (h) {
      const level = h[1].length;
      if (LEGACY_SECTION_MARKER.test(line)) citationLevel = level;
      else if (citationLevel !== null && level <= citationLevel) citationLevel = null;
      continue;
    }
    if (citationLevel !== null) continue;
    // Line-level citation marker (deprecation/migration prose).
    if (LEGACY_CITATION_MARKER.test(line)) continue;
    re.lastIndex = 0;
    let m;
    while ((m = re.exec(line))) {
      const label = m[0];
      // legacy→canonical mapping row → citation, not misuse.
      const canon = LEGACY_CANONICAL[label];
      if (canon && canon.test(line)) continue;
      findings.push({
        line: i + 1,
        check: "legacy",
        message: `legacy label \`${label}\` — see §1.13.1.7-8 for canonical replacement`,
      });
    }
  }
}

function checkEnUppercase(proseLines, findings) {
  // Sort longer keywords first so "MUST NOT" matches before "MUST".
  const sorted = [...RFC2119_EN].sort((a, b) => b.length - a.length);
  const escaped = sorted.map((k) => k.replace(/ /g, "\\s+"));
  const re = new RegExp(`\\b(${escaped.join("|")})\\b`, "g");
  for (let i = 0; i < proseLines.length; i++) {
    const line = proseLines[i];
    if (!line) continue;
    re.lastIndex = 0;
    let m;
    while ((m = re.exec(line))) {
      findings.push({
        line: i + 1,
        check: "en-uppercase",
        message: `EN RFC-2119 keyword \`${m[0]}\` in RU prose — use RU canonical per §2.3 (or wrap in backticks for descriptive mention per §2.7)`,
      });
    }
  }
}

function checkFenceLang(rawLines, findings) {
  // Operates on raw text (not stripped prose). Look for ``` lines
  // that open a fence and lack a lang tag.
  let inFence = false;
  for (let i = 0; i < rawLines.length; i++) {
    const line = rawLines[i];
    const m = /^(\s*)```(.*)$/.exec(line);
    if (!m) continue;
    if (inFence) {
      // Closing fence — closing must be bare ``` per CommonMark.
      inFence = false;
      continue;
    }
    inFence = true;
    const tag = m[2].trim();
    if (!tag) {
      findings.push({
        line: i + 1,
        check: "fence-lang",
        message: "code fence without lang tag — add lang per §3.3.2 (e.g. ```yaml, ```bash, ```text)",
      });
    }
  }
}

function checkAnglicismLabel(proseLines, findings) {
  // §1.13 Compression anglicism creep guard. Flag mid-prose bold-label
  // paragraph headers `**English Word:**` not in the canonical closed
  // lists. These typically appear when an LLM compresses bullet lists
  // into inline paragraphs but keeps English structural labels
  // ("**Actor:**", "**Default:**", "**Override:**").
  for (let i = 0; i < proseLines.length; i++) {
    const line = proseLines[i];
    if (!line) continue;
    const m = ANGLICISM_LABEL_RE.exec(line);
    if (!m) continue;
    const label = m[1].trim();
    // First word is the keyword we judge against the whitelist.
    // Hyphenated compounds (Type-specific, Anti-pattern) are kept whole.
    const head = label.split(/\s+/)[0];
    if (ANGLICISM_LABEL_WHITELIST.has(head)) continue;
    // Skip multi-word labels containing canonical RENAR token anywhere.
    if (/\b(ADAPT|BR|SR|SPEC|TR|TC|TZ|MVR|QG|SoT|RENAR)\b/.test(label)) continue;
    findings.push({
      line: i + 1,
      check: "anglicism-label",
      message: "English bold-label `**" + label + ":**` mid-prose — translate to RU per §1.13 synonym map (Actor→Участник, Default→По умолчанию, Override→Переопределение, Cadence→Периодичность, Evidence→Доказательная база, Result→Итог, Denial→Отказ)",
    });
  }
}

function checkAsciiQuote(proseLines, findings) {
  // Flag `"..."` in RU prose. Skips:
  //   - URL-context (heuristic: `=` or `/` adjacent).
  //   - EN citations within RU prose: quoted inner content has no
  //     Cyrillic and ≥3 latin chars — permitted EN-citation form
  //     per §3.8.1 carve-out («Per RFC 2119, "the use of …"»).
  const re = /"[^"\n]+"/g;
  const CYR_RE = /[Ѐ-ӿ]/;
  const LAT_RE = /[A-Za-z]/g;
  for (let i = 0; i < proseLines.length; i++) {
    const line = proseLines[i];
    if (!line) continue;
    re.lastIndex = 0;
    let m;
    while ((m = re.exec(line))) {
      const ctx = line.slice(Math.max(0, m.index - 1), m.index + m[0].length + 1);
      if (/[=/]/.test(ctx[0]) || /[=/]/.test(ctx[ctx.length - 1])) continue;
      const inner = m[0].slice(1, -1);
      if (!CYR_RE.test(inner)) {
        const latCount = (inner.match(LAT_RE) || []).length;
        if (latCount >= 3) continue; // EN-citation carve-out per §3.8.1
      }
      findings.push({
        line: i + 1,
        check: "ascii-quote",
        message: `ASCII double-quote \`${m[0].slice(0, 40)}${m[0].length > 40 ? "…" : ""}\` — use \`«»\` per §3.10.1.6`,
      });
    }
  }
}

// ---------- main ----------

function runFile(file, rel) {
  const text = readFileSync(file, "utf8");
  const lang = detectLang(text);
  const proseLines = buildProseLines(text);
  const rawLines = text.split(/\r?\n/);
  const findings = [];

  // bucket-a (Capitalized-latin paste-error) and bucket-e (Cyrillic кальки)
  // are RU-corpus prose checks — irrelevant to EN translations and prone to
  // false positives on capitalized English in tables. Skip for lang:en.
  if (ACTIVE_CHECKS.has("bucket-a") && lang !== "en")   checkBucketA(proseLines, findings);
  if (ACTIVE_CHECKS.has("bucket-e") && lang !== "en")   checkBucketE(proseLines, findings);
  if (ACTIVE_CHECKS.has("legacy"))     checkLegacy(proseLines, findings);
  // EN UPPERCASE + ASCII-quote target RU corpus per §2.2.5.
  // EN UPPERCASE additionally exempts files marked descriptive (§2.7).
  if (
    ACTIVE_CHECKS.has("en-uppercase")
    && lang !== "en"
    && !EN_UPPERCASE_DESCRIPTIVE_FILES.has(rel)
  ) {
    checkEnUppercase(proseLines, findings);
  }
  if (ACTIVE_CHECKS.has("fence-lang")) checkFenceLang(rawLines, findings);
  if (ACTIVE_CHECKS.has("ascii-quote") && lang !== "en")  checkAsciiQuote(proseLines, findings);
  // anglicism-label targets RU corpus; EN translations are skipped.
  // The style guide itself describes such labels in §1.13 — exempt.
  if (
    ACTIVE_CHECKS.has("anglicism-label")
    && lang !== "en"
    && rel !== "reference/06-ru-style-guide.md"
  ) {
    checkAnglicismLabel(proseLines, findings);
  }

  return findings;
}

const perCheck = Object.fromEntries(ALL_CHECKS.map((c) => [c, 0]));
let totalFindings = 0;
let totalFiles = 0;

console.error(`# style-guide-check.js v${SCRIPT_VERSION} — target ${STYLE_GUIDE_TARGET}`);
if (CHECK_FILTER) console.error(`# active check: ${CHECK_FILTER}`);

for (const section of SECTIONS) {
  const dir = join(root, section);
  let files;
  try {
    files = listMarkdown(dir);
  } catch (e) {
    if (e.code === "ENOENT") continue;
    throw e;
  }
  for (const file of files) {
    totalFiles++;
    const rel = relative(root, file).replace(/\\/g, "/");
    const findings = runFile(file, rel);
    if (findings.length === 0) {
      if (!QUIET) console.log(`OK   ${rel}`);
      continue;
    }
    console.log(`FAIL ${rel} (${findings.length})`);
    for (const f of findings) {
      console.log(`  ${rel}:${f.line} [${f.check}] ${f.message}`);
      perCheck[f.check]++;
      totalFindings++;
    }
  }
}

console.log("");
console.log(`Summary: ${totalFiles} files checked, ${totalFindings} findings.`);
for (const c of ALL_CHECKS) {
  if (!ACTIVE_CHECKS.has(c)) continue;
  console.log(`  ${c.padEnd(13)} ${perCheck[c]}`);
}

process.exit(totalFindings === 0 ? 0 : 1);
