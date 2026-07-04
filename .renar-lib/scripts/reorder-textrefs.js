#!/usr/bin/env node
/**
 * reorder-textrefs.js — follow-up to reorder-chapters.js.
 *
 * The main reorder remapped file-link slugs (NN-slug) but NOT number-only textual
 * citations like "standard/03 §3.3.3" (no slug, so untouched). Also reference/06
 * (style guide) was excluded from §-remap to protect its OWN §1/§2/§3 — but its
 * "standard/NN §M.x" citations DO point at standard chapters and went stale.
 *
 * This pass fixes those textual "standard/NN" labels:
 *   - reference/06: combined "standard/NN [§M.x]" — remap BOTH (reads original NN;
 *     in these citations the §-leading equals NN). Bare self-§ (no "standard/" prefix) untouched.
 *   - all other files: standalone "standard/NN" number only (the §M.x was already
 *     remapped by the main run).
 * URLs ("standard/13-conformance.md") are skipped via the (?![-\d]) lookahead.
 *
 * Usage: node scripts/reorder-textrefs.js [--dry-run]
 */

import { readFileSync, writeFileSync, readdirSync, statSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const DRY = process.argv.includes("--dry-run");
const SECTIONS = ["standard", "guide", "reference", "core"];

const MAP = { 2: 14, 3: 4, 4: 5, 5: 2, 11: 3, 12: 11, 13: 12, 14: 13 };
const remap = (n) => (MAP[n] !== undefined ? MAP[n] : n);
const pad2 = (n) => String(n).padStart(2, "0");
const remapLeading = (s) => {
  const p = s.split(".");
  p[0] = String(remap(parseInt(p[0], 10)));
  return p.join(".");
};

function listMarkdown(dir) {
  const out = [];
  for (const e of readdirSync(dir)) {
    const f = join(dir, e);
    if (statSync(f).isDirectory()) out.push(...listMarkdown(f));
    else if (e.endsWith(".md")) out.push(f);
  }
  return out;
}

let changed = 0, subs = 0;
const report = [];

for (const file of SECTIONS.flatMap((s) => listMarkdown(join(root, s)))) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const isStyleGuide = /reference\/06-ru-style-guide/.test(rel);
  let s = readFileSync(file, "utf8");
  const before = s;

  if (isStyleGuide) {
    s = s.replace(/standard\/(\d{2})(?![-\d])( §(\d+(?:\.\d+)*))?/g, (m, nn, gp, num) => {
      const newN = remap(parseInt(nn, 10));
      let out = `standard/${pad2(newN)}`;
      if (gp !== undefined) out += ` §${remapLeading(num)}`;
      if (out !== m) subs++;
      return out;
    });
  } else {
    s = s.replace(/standard\/(\d{2})(?![-\d])/g, (m, nn) => {
      const newN = remap(parseInt(nn, 10));
      if (newN !== parseInt(nn, 10)) subs++;
      return `standard/${pad2(newN)}`;
    });
  }

  if (s !== before) {
    changed++;
    report.push(`  ${rel}`);
    if (!DRY) writeFileSync(file, s, "utf8");
  }
}

console.log(`reorder-textrefs.js ${DRY ? "(DRY)" : "(APPLIED)"} — files changed: ${changed}, subs: ${subs}`);
console.log(report.join("\n"));
