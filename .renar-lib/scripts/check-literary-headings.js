#!/usr/bin/env node
/**
 * Literary headings gate:
 * - H1: numbered chapter titles (standard/, guide/) must not have EN parenthetical suffix
 * - H1: reference/02,04,05 document title must contain Cyrillic
 * - H2/H3: English-only headings in standard/ (legacy gate)
 */
import { readFileSync, readdirSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const standardDir = join(root, "standard");
const guideDir = join(root, "guide");
const referenceDir = join(root, "reference");

const REFERENCE_H1_FILES = new Set([
  "02-schemas.md",
  "04-ai-style-guide.md",
  "05-knowledge-graph-schema.md",
]);

const DENY = [
  /^Conformance position statement$/i,
  /^Informative references$/i,
  /^Immediate re-assessment triggers$/i,
  /^Normative references$/i,
  /^Business Requirement$/i,
  /^System Requirement$/i,
  /^Task Requirement$/i,
  /^Source of Truth$/i,
  /^Closed list policy$/i,
  /^Negative scope$/i,
  /^Primary scope$/i,
];

const CYRILLIC = /[а-яА-ЯёЁ]/;
const CHAPTER_H1_EN_SUFFIX = /^#\s+\d{2}\.\s+.+\([A-Za-z][^)]*\)\s*$/;

let findings = 0;

function report(path, lineNo, text, kind) {
  console.log(
    `${relative(root, path).replace(/\\/g, "/")}:${lineNo}: [${kind}] ${text}`,
  );
  findings++;
}

function scanLines(path, lines, { chapterH1, referenceH1, h2h3 }) {
  let inFence = false;
  let fenceMarker = "";
  let frontmatterDashes = 0;
  let pastFrontmatter = false;
  let referenceH1Checked = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (line.trim() === "---") {
      frontmatterDashes++;
      if (frontmatterDashes >= 2) pastFrontmatter = true;
    }

    const fence = line.match(/^(`{3,}|~{3,})(.*)/);
    if (fence) {
      if (!inFence) {
        inFence = true;
        fenceMarker = fence[1];
      } else if (line.startsWith(fenceMarker)) {
        inFence = false;
        fenceMarker = "";
      }
      continue;
    }
    if (inFence) continue;

    if (chapterH1 && CHAPTER_H1_EN_SUFFIX.test(line)) {
      report(path, i + 1, line.replace(/^#\s+/, ""), "H1 EN suffix");
      continue;
    }

    if (referenceH1 && pastFrontmatter && !referenceH1Checked && /^#\s+/.test(line)) {
      referenceH1Checked = true;
      if (!CYRILLIC.test(line)) {
        report(path, i + 1, line.replace(/^#\s+/, ""), "H1 no Cyrillic");
      }
      continue;
    }

    if (!h2h3) continue;
    const m = line.match(/^(#{2,3})\s+(.+?)\s*$/);
    if (!m) continue;
    const title = m[2].replace(/\*\*/g, "").replace(/\(.*\)/, "").trim();
    if (CYRILLIC.test(title)) continue;
    if (/^[\d§]/.test(title)) continue;
    if (title.includes("ISO/IEC") || title.includes("IEEE")) continue;
    if (
      DENY.some((re) => re.test(title)) ||
      /^[A-Za-z][A-Za-z\s/&-]{8,}$/.test(title)
    ) {
      report(path, i + 1, m[2], "H2/H3 EN");
    }
  }
}

for (const name of readdirSync(standardDir).filter(
  (n) => n.endsWith(".md") && n !== "README.md",
)) {
  const path = join(standardDir, name);
  scanLines(path, readFileSync(path, "utf8").split("\n"), {
    chapterH1: true,
    referenceH1: false,
    h2h3: true,
  });
}

for (const name of readdirSync(guideDir).filter(
  (n) => n.endsWith(".md") && n !== "README.md",
)) {
  const path = join(guideDir, name);
  scanLines(path, readFileSync(path, "utf8").split("\n"), {
    chapterH1: true,
    referenceH1: false,
    h2h3: false,
  });
}

for (const name of readdirSync(referenceDir).filter((n) =>
  REFERENCE_H1_FILES.has(n),
)) {
  const path = join(referenceDir, name);
  scanLines(path, readFileSync(path, "utf8").split("\n"), {
    chapterH1: false,
    referenceH1: true,
    h2h3: false,
  });
}

if (findings) {
  console.error(`\n${findings} literary heading issue(s)`);
  process.exit(1);
}
console.log("check-literary-headings: PASS");
