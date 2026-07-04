#!/usr/bin/env node
/**
 * check-section-refs.js — RENAR §-reference (anchor) integrity gate.
 *
 * check-md-links.js validates that linked FILES exist, but explicitly NOT anchors.
 * Chapter renumbering (reorder) changes §-numbers; a stale "§5.3" that should be
 * "§2.3" would pass every existing gate silently. This gate closes that hole.
 *
 * It validates:
 *  1. Anchored links to standard chapters — [text](NN-slug.md#A.B.C):
 *       - chapter NN exists,
 *       - anchor's leading number == NN (catches link/anchor mismatch),
 *       - heading "A.B.C" exists in that chapter.
 *  2. Bare "§A.B.C" refs across the corpus — standard/ + reference/ + guide/ + core/
 *     (excluding the normative-refs chapter and ISO/IEC/IEEE citation contexts, which
 *     carry foreign §-numbers):
 *       - chapter A exists and heading "A.B.C" exists.
 *     This is what catches reference/08's "§14.3.3" (ch14 has no such §) — a class of
 *     dangling display ref that check-md-links cannot see (plain text, not a link).
 *     False-positive guards: single-level "§N" is skipped (docs number their own sections
 *     "## N." and cite them "§N", colliding with chapter-N H1s); a ref matching one of the
 *     file's OWN headings is a self-reference (reference/06 has its own §1.x scale;
 *     reference/08 uses "### §13.3.x" headings); and a ref in foreign context — ISO/IEEE/
 *     SAFe/style-guide/glossary in the 40 chars before, on the same line, or in the
 *     enclosing section heading — is that external standard's clause (e.g. an
 *     "## ISO/IEC 23894" mapping table), not a RENAR §.
 *  3. Display-number consistency — for any link [text](NN-slug.md…) whose target is
 *     a real standard chapter, every chapter/§-number named in the VISIBLE text must
 *     equal NN. A reorder updates anchors but leaves stale labels like
 *     "[05 Roles](02-…)" or "[§3](04-terms.md)" that resolve fine yet mislead the
 *     reader. Anchors (rule 1) are blind to display text; this rule closes that hole.
 *
 * Usage:
 *   node scripts/check-section-refs.js [--quiet] [--baseline] [--root <dir>]
 *   --baseline : report only, always exit 0 (for snapshotting current state).
 *   --root     : scan a different repo root (used for self-test fixtures).
 *
 * Exit 0 — no unresolved refs (or --baseline). Exit 1 — unresolved refs found.
 */

import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, basename } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2);
const QUIET = argv.includes("--quiet");
const BASELINE = argv.includes("--baseline");
const rootIdx = argv.indexOf("--root");
const root = rootIdx !== -1 ? argv[rootIdx + 1] : join(__dirname, "..");

const SECTIONS = ["standard", "guide", "reference", "core"];
// Foreign-§ contexts: §-numbers that belong to another document, not a RENAR chapter.
//  - external standards (ISO/IEEE/…) carry their own clause numbers;
//  - "Style Guide §" / "глоссарий §" point into reference/, not standard/ chapters.
const FOREIGN_CTX = /(ISO|IEC|IEEE|BABOK|CMMI|NIST|SAFe|SENAR|29148|25010|5338|23894|42001|RFC[\s-]?2119|\d{4}:|Style[\s-]?Guide|glossary|Forward|ТЗ|TZ|стил|глоссар|Глоссар)/i;

function listMarkdown(dir) {
  const out = [];
  let entries;
  try {
    entries = readdirSync(dir);
  } catch {
    return out;
  }
  for (const entry of entries) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) out.push(...listMarkdown(full));
    else if (entry.endsWith(".md")) out.push(full);
  }
  return out;
}

function stripCode(s) {
  // Replace code with a SPACE (not ""), so digits on either side of an inline span
  // are not glued into a phantom number (e.g. "§1.7`note`01" → a bogus "§1.701").
  return s.replace(/```[\s\S]*?```/g, " ").replace(/`[^`]+`/g, " ");
}

// Normalize a dotted section number: strip leading zeros on each component.
function norm(n) {
  return n.split(".").map((p) => String(parseInt(p, 10))).join(".");
}

// --- Build chapter index from standard/ ---
const stdDir = join(root, "standard");
const chapters = new Map(); // chapterNum(int) -> { file, sections:Set<string normalized> }

for (const file of listMarkdown(stdDir)) {
  const base = basename(file);
  const m = base.match(/^(\d{2})-/);
  if (!m) continue; // skip README.md etc.
  const chNum = parseInt(m[1], 10);
  const sections = new Set();
  const content = readFileSync(file, "utf8");
  for (const line of content.split(/\r?\n/)) {
    const h = line.match(/^#{1,6}\s+(\d+(?:\.\d+)*)\b/);
    if (h) sections.add(norm(h[1]));
  }
  chapters.set(chNum, { file: base, sections });
}

// --- Scan corpus for refs ---
const ANCHORED = /\]\((?:\.\.\/)?(?:standard\/)?((\d{2})-[a-z0-9-]+\.md)#(\d[\d.]*)\)/g;
const BARE = /§\s?(\d+(?:\.\d+)*)/g;
// Full link incl. display text — for rule 3 (display-number consistency).
const LINK = /\[([^\]]+)\]\((?:\.\.\/)*(?:standard\/)?((\d{2})-[a-z0-9-]+\.md)(?:#[\d.]+)?\)/g;
// A display chapter token: leading "NN" or "глава N" naming the target chapter.
const DISP_CHAP = /^\s*(?:глава\s+)?(\d{1,2})\b/i;
const DISP_SEC = /§\s?(\d{1,2})(?:\.\d+)*/g;
// A chapter citation anywhere in display: "NN. Title" (zero-padded chapter number +
// dot + space). Catches nav-footer drift like "Следующая: 05. Methodology →" where
// the number is not the leading token (DISP_CHAP misses it).
const DISP_CHAP_CITE = /\b(\d{2})\.\s+\S/g;

const problems = [];   // blocking (exit 1)
const files = SECTIONS.flatMap((s) => listMarkdown(join(root, s)));

for (const file of files) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const raw = readFileSync(file, "utf8");
  const text = stripCode(raw);

  // 1. Anchored links to standard chapters
  let m;
  ANCHORED.lastIndex = 0;
  while ((m = ANCHORED.exec(text)) !== null) {
    const fname = m[1];
    const chNum = parseInt(m[2], 10);
    const anchor = norm(m[3]);
    const ch = chapters.get(chNum);
    // Only validate links that point at the actual standard chapter file.
    // Reference/guide files reuse NN- prefixes (02-schemas.md ≠ 02-normative-refs.md).
    if (!ch || ch.file !== fname) continue;
    const anchorLead = parseInt(anchor.split(".")[0], 10);
    if (anchorLead !== chNum) {
      problems.push(`${rel}: anchor/chapter mismatch — ${fname}#${m[3]} (anchor points to ch ${anchorLead})`);
      continue;
    }
    if (!ch.sections.has(anchor)) {
      problems.push(`${rel}: unresolved anchor #${m[3]} in ${fname}`);
    }
  }

  // 2. Bare §-refs across the corpus (standard/ + reference/ + guide/ + core/), blocking.
  if (!/normative-refs/.test(rel)) {
    // Own headings of THIS file (number after #..., with optional leading §) — used to
    // skip self-references like reference/06 "§1.10" or reference/08 "### §13.3.1".
    const ownSections = new Set();
    for (const line of raw.split(/\r?\n/)) {
      const h = line.match(/^#{1,6}\s+§?\s?(\d+(?:\.\d+)*)\b/);
      if (h) ownSections.add(norm(h[1]));
    }
    // Heading positions (in stripped `text`, so offsets align with BARE matches) for the
    // foreign-section guard: a §-ref under "## 7. ISO/IEC 23894:2023" is that ISO's clause.
    const headings = [];
    const HEAD = /^#{1,6}\s[^\n]*/gm;
    let hm;
    while ((hm = HEAD.exec(text)) !== null) headings.push({ pos: hm.index, text: hm[0] });
    BARE.lastIndex = 0;
    while ((m = BARE.exec(text)) !== null) {
      if (!m[1].includes(".")) continue; // skip single-level §N (own-section refs)
      // Foreign context (ISO/IEEE/SAFe/style-guide/glossary…) makes the §-number an
      // external standard's clause, not a RENAR §. Check the 40 chars before, the whole
      // line (foreign marker may follow the §, e.g. "§6.4.1 Risk identification"), and the
      // enclosing section heading (e.g. an "## ISO/IEC 23894" mapping table).
      const before = text.slice(Math.max(0, m.index - 40), m.index);
      const lineStart = text.lastIndexOf("\n", m.index) + 1;
      let lineEnd = text.indexOf("\n", m.index);
      if (lineEnd < 0) lineEnd = text.length;
      const line = text.slice(lineStart, lineEnd);
      let heading = "";
      for (const h of headings) { if (h.pos <= m.index) heading = h.text; else break; }
      if (FOREIGN_CTX.test(before) || FOREIGN_CTX.test(line) || FOREIGN_CTX.test(heading)) continue;
      const sec = norm(m[1]);
      if (ownSections.has(sec)) continue; // self-reference to this file's own §-scale
      const lead = parseInt(sec.split(".")[0], 10);
      const ch = chapters.get(lead);
      if (!ch) {
        problems.push(`${rel}: bare §${m[1]} → chapter ${lead} does not exist`);
      } else if (!ch.sections.has(sec)) {
        problems.push(`${rel}: bare §${m[1]} → no heading ${sec} in chapter ${lead} (${ch.file})`);
      }
    }
  }

  // 3. Display-number consistency for links to real standard chapters.
  LINK.lastIndex = 0;
  while ((m = LINK.exec(text)) !== null) {
    const disp = m[1];
    const fname = m[2];
    const chNum = parseInt(m[3], 10);
    const ch = chapters.get(chNum);
    if (!ch || ch.file !== fname) continue; // only true standard-chapter targets
    const snip = disp.length > 42 ? disp.slice(0, 42) + "…" : disp;
    const dm = disp.match(DISP_CHAP);
    if (dm && parseInt(dm[1], 10) !== chNum) {
      problems.push(`${rel}: display chapter "${dm[1]}" ≠ target ch ${chNum} (${fname}) — "${snip}"`);
    }
    let cm;
    DISP_CHAP_CITE.lastIndex = 0;
    while ((cm = DISP_CHAP_CITE.exec(disp)) !== null) {
      if (parseInt(cm[1], 10) !== chNum) {
        problems.push(`${rel}: display chapter-cite "${cm[1]}." ≠ target ch ${chNum} (${fname}) — "${snip}"`);
      }
    }
    let sm;
    DISP_SEC.lastIndex = 0;
    while ((sm = DISP_SEC.exec(disp)) !== null) {
      if (parseInt(sm[1], 10) !== chNum) {
        problems.push(`${rel}: display ${sm[0].trim()} ≠ target ch ${chNum} (${fname}) — "${snip}"`);
      }
    }
  }
}

// --- Report ---
if (!QUIET) {
  console.log(`# check-section-refs.js — ${chapters.size} chapters indexed, ${files.length} files scanned`);
}
if (problems.length === 0) {
  if (!QUIET) console.log("OK   0 unresolved §-refs / anchors");
  process.exit(0);
}
for (const p of problems) console.log(`FAIL ${p}`);
console.log(`\nSummary: ${problems.length} unresolved §-ref(s)/anchor(s)`);
process.exit(BASELINE ? 0 : 1);
