#!/usr/bin/env node
/**
 * reorder-chapters.js — one-shot RENAR chapter renumber (reorder variant A).
 *
 * Map (old → new):  05→02 11→03 03→04 04→05  12→11 13→12 14→13  02→14
 * Stable:           00 01 06 07 08 09 10
 *
 * Transforms across standard/ guide/ reference/ core/:
 *   1. file-link slugs        (NN-slug → NN'-slug)               [8 unique slugs]
 *   2. anchors in std links   (NN-slug.md#A → #A')               [leading num remap]
 *   3. bare §-refs            (§A → §A')   skip ISO/self ctx + reference/06
 *   4. chapter mentions       (Глава/глава N → N')
 *   5. headings (standard)    (# NN. / ## N.M → remapped)        [per-chapter own num]
 *   6. order: frontmatter (standard)
 * Then physically renames the 8 files.
 *
 * Number remap uses single-pass .replace callbacks reading the ORIGINAL value,
 * so overlapping ranges (5→2 and 3→4 and 4→5) never cascade.
 *
 * Usage: node scripts/reorder-chapters.js [--dry-run]
 */

import { readFileSync, writeFileSync, readdirSync, statSync, renameSync, existsSync } from "fs";
import { join, dirname, basename } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const DRY = process.argv.includes("--dry-run");
const SECTIONS = ["standard", "guide", "reference", "core"];

// old chapter number → new chapter number
const MAP = { 2: 14, 3: 4, 4: 5, 5: 2, 11: 3, 12: 11, 13: 12, 14: 13 };
const remap = (n) => (MAP[n] !== undefined ? MAP[n] : n);
const pad2 = (n) => String(n).padStart(2, "0");

// full-slug renames (without .md) — unique strings, order-independent
const RENAMES = [
  ["05-methodology-positioning", "02-methodology-positioning"],
  ["11-substrate-versioning", "03-substrate-versioning"],
  ["03-terms", "04-terms"],
  ["04-roles", "05-roles"],
  ["12-maturity-model", "11-maturity-model"],
  ["13-metrics", "12-metrics"],
  ["14-conformance", "13-conformance"],
  ["02-normative-refs", "14-normative-refs"],
];

// set of NEW standard chapter filenames (.md) — for anchor scoping
const STD_NEW_FILES = new Set([
  "00-introduction.md", "01-scope.md", "02-methodology-positioning.md",
  "03-substrate-versioning.md", "04-terms.md", "05-roles.md",
  "06-requirements-hierarchy.md", "07-adapt.md", "08-specifications.md",
  "09-test-cases.md", "10-lifecycle-qg.md", "11-maturity-model.md",
  "12-metrics.md", "13-conformance.md", "14-normative-refs.md",
]);

// §-numbers belonging to OTHER documents (skip in bare-§ remap):
//  external standards (ISO/IEEE/…), SENAR's own sections, client-ТЗ/Forward refs,
//  Style/BABOK Guide. These are NOT RENAR chapter §-refs and must stay put.
const FOREIGN_CTX = /(ISO|IEC|IEEE|BABOK|CMMI|NIST|SAFe|SENAR|29148|25010|5338|23894|42001|RFC[\s-]?2119|\d{4}:|Style[\s-]?Guide|Forward|ТЗ|TZ|стил|глоссар|Глоссар)/i;

function listMarkdown(dir) {
  const out = [];
  for (const e of readdirSync(dir)) {
    const f = join(dir, e);
    if (statSync(f).isDirectory()) out.push(...listMarkdown(f));
    else if (e.endsWith(".md")) out.push(f);
  }
  return out;
}

const remapLeading = (numStr) => {
  const parts = numStr.split(".");
  parts[0] = String(remap(parseInt(parts[0], 10)));
  return parts.join(".");
};

let changedFiles = 0;
let totalSubs = 0;
const report = [];

for (const file of SECTIONS.flatMap((s) => listMarkdown(join(root, s)))) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const isStd = rel.startsWith("standard/");
  const isStyleGuide = /reference\/06-ru-style-guide/.test(rel);
  let s = readFileSync(file, "utf8");
  const before = s;
  let subs = 0;
  const bump = (n) => { subs += n; };

  // 1. file-link slugs
  for (const [oldS, newS] of RENAMES) {
    if (s.includes(oldS)) { const c = s.split(oldS).length - 1; s = s.split(oldS).join(newS); bump(c); }
  }

  // 2. anchors in standard-chapter links (filenames already new after step 1)
  s = s.replace(/(\d{2}-[a-z0-9-]+\.md)#(\d+(?:\.\d+)*)/g, (m, fname, anc) => {
    if (!STD_NEW_FILES.has(fname)) return m;
    const na = remapLeading(anc);
    if (na !== anc) bump(1);
    return `${fname}#${na}`;
  });

  // 3. bare §-refs (skip foreign/self contexts; skip the style-guide file entirely)
  if (!isStyleGuide) {
    s = s.replace(/§(\s?)(\d+(?:\.\d+)*)/g, (m, sp, num, off, str) => {
      const ctx = str.slice(Math.max(0, off - 40), off);
      if (FOREIGN_CTX.test(ctx)) return m;
      const nn = remapLeading(num);
      if (nn !== num) bump(1);
      return `§${sp}${nn}`;
    });
  }

  // 4. chapter mentions: Глава/глава/главе/главы/главу/главой N
  s = s.replace(/([Гг]лав(?:а|е|ы|у|ой))(\s+)(\d+)/g, (m, w, sp, n) => {
    const nn = remap(parseInt(n, 10));
    if (nn !== parseInt(n, 10)) bump(1);
    return `${w}${sp}${nn}`;
  });

  // 5 & 6. headings + order: — standard files only
  if (isStd) {
    // H1: "# NN. Title" → zero-padded
    s = s.replace(/^#(?!#)([ \t]+)(\d+)\./gm, (m, sp, n) => {
      const nn = remap(parseInt(n, 10));
      if (nn !== parseInt(n, 10)) bump(1);
      return `#${sp}${pad2(nn)}.`;
    });
    // sub-headings: "## N.M[.K] ..." → leading remap (no pad)
    s = s.replace(/^(#{2,6})([ \t]+)(\d+)((?:\.\d+)+)/gm, (m, h, sp, n, rest) => {
      const nn = remap(parseInt(n, 10));
      if (nn !== parseInt(n, 10)) bump(1);
      return `${h}${sp}${nn}${rest}`;
    });
    // order: frontmatter
    s = s.replace(/^order:([ \t]*)(\d+)([ \t]*)$/m, (m, a, n, b) => {
      const nn = remap(parseInt(n, 10));
      if (nn !== parseInt(n, 10)) bump(1);
      return `order:${a}${nn}${b}`;
    });
  }

  if (s !== before) {
    changedFiles++;
    totalSubs += subs;
    report.push(`  ${rel}  (${subs} subs)`);
    if (!DRY) writeFileSync(file, s, "utf8");
  }
}

// physical renames
const renamePlan = [];
for (const [oldS, newS] of RENAMES) {
  const oldP = join(root, "standard", `${oldS}.md`);
  const newP = join(root, "standard", `${newS}.md`);
  if (existsSync(oldP)) {
    renamePlan.push(`  ${oldS}.md → ${newS}.md`);
    if (!DRY) renameSync(oldP, newP);
  } else {
    renamePlan.push(`  !! MISSING ${oldS}.md`);
  }
}

console.log(`reorder-chapters.js ${DRY ? "(DRY RUN — no writes)" : "(APPLIED)"}`);
console.log(`\nFiles changed: ${changedFiles}, total number-substitutions: ${totalSubs}`);
console.log(`\nRename plan (8):`);
console.log(renamePlan.join("\n"));
console.log(`\nChanged files:`);
console.log(report.join("\n"));
