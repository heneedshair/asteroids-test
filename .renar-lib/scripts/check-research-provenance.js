#!/usr/bin/env node
/**
 * Fails CI when public RU corpus leaks internal research/ provenance.
 * Scope: standard/, guide/, reference/01-05 (excludes meta reference/06).
 */
import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");

const REFERENCE_ALLOW = new Set(["reference/06-ru-style-guide.md"]);

function collectMdFiles(dirRel) {
  const abs = join(root, dirRel);
  const out = [];
  for (const name of readdirSync(abs)) {
    const p = join(abs, name);
    const rel = `${dirRel}/${name}`.replace(/\\/g, "/");
    if (statSync(p).isDirectory()) continue;
    if (!name.endsWith(".md") || name === "README.md") continue;
    out.push(rel);
  }
  return out;
}

// Provenance scope for reference/: only the public RU appendices 01-05 (06 is
// the meta style-guide; 07-11 are out of provenance scope by current policy).
// Discovered by real glob — a new reference/0[1-5]-*.md is auto-covered, so a
// future appendix can't silently escape the gate. (Was a dead
// `.map(...).flatMap(() => [])` that evaluated to [] and left only a hardcoded
// list — any unlisted 01-05 file slipped through.)
//
// Scope policy (explicit): files matching reference/0[1-5]-*.md are
// auto-included; reference/06+ require a deliberate policy decision to add.
// EN sub-directories (standard/en/, guide/en/) are intentionally OUT of scope —
// this gate guards the RU corpus only (collectMdFiles + the guide filter below
// are non-recursive, so */en/ is never walked).
const REFERENCE_PROVENANCE_RE = /^0[1-5]-.*\.md$/;
const files = [
  ...collectMdFiles("standard"),
  ...readdirSync(join(root, "guide"))
    .filter((n) => n.endsWith(".md") && n !== "README.md")
    .map((n) => `guide/${n}`),
  ...readdirSync(join(root, "reference"))
    .filter((n) => REFERENCE_PROVENANCE_RE.test(n))
    .map((n) => `reference/${n}`),
];

const RESEARCH = /research\//;
const PROVENANCE_BLOCK = /^\s*>\s*\*\*Источник/i;
const PROVENANCE_SOURCES = /\*\*Источники:\*\*/i;
const DRAFT_LINE = /исследовательский draft/i;

function allowedLine(line) {
  if (line.includes("вне публикации")) return true;
  if (line.includes("research/legacy")) return true;
  if (/^\|\s*`research\/`\s*\|/.test(line)) return true;
  return false;
}

let findings = 0;

for (const rel of files) {
  if (REFERENCE_ALLOW.has(rel)) continue;
  const lines = readFileSync(join(root, rel), "utf8").split("\n");
  const headerLimit = rel.startsWith("reference/") ? 25 : lines.length;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const inHeader = rel.startsWith("reference/") && i < headerLimit;

    if (RESEARCH.test(line) && !allowedLine(line)) {
      console.log(`${rel}:${i + 1}: research/ leak — ${line.trim().slice(0, 100)}`);
      findings++;
      continue;
    }
    if (PROVENANCE_BLOCK.test(line) || PROVENANCE_SOURCES.test(line)) {
      console.log(`${rel}:${i + 1}: provenance blockquote — ${line.trim().slice(0, 100)}`);
      findings++;
      continue;
    }
    if (DRAFT_LINE.test(line)) {
      console.log(`${rel}:${i + 1}: draft wording — ${line.trim().slice(0, 100)}`);
      findings++;
    }
  }
}

if (findings) {
  console.error(`\ncheck-research-provenance: ${findings} finding(s)`);
  process.exit(1);
}
console.log("check-research-provenance: PASS");
