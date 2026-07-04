#!/usr/bin/env node
/**
 * reorder-slug-anchors.js — fix slug-anchors that embed a stale section number.
 *
 * Cross-refs use two anchor styles: numeric ("#3.11", handled by reorder-chapters)
 * and full text-slug ("#311-drift-классы-closed-list"). The slug embeds the section
 * number with dots removed; after renumbering, the embedded number is stale and the
 * link breaks on the rendered site (no gate validated these).
 *
 * Strategy: the TITLE part of the slug is invariant. Match it against the target
 * chapter's current headings, recompute the number-prefix. Only touches anchors
 * pointing at the 8 RENUMBERED chapters — stable-chapter anchors (incl. ch0 leading
 * zero quirks like "#64-…") are left alone.
 *
 * Usage: node scripts/reorder-slug-anchors.js [--dry-run]
 */

import { readFileSync, writeFileSync, readdirSync, statSync } from "fs";
import { join, dirname, basename } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const DRY = process.argv.includes("--dry-run");
const SECTIONS = ["standard", "guide", "reference", "core"];

// the 8 renumbered chapters by their NEW filename
const RENUMBERED = new Set([
  "02-methodology-positioning.md", "03-substrate-versioning.md",
  "04-terms.md", "05-roles.md", "11-maturity-model.md",
  "12-metrics.md", "13-conformance.md", "14-normative-refs.md",
]);

const slugifyTitle = (t) =>
  t.toLowerCase().replace(/[^a-zа-яё0-9]+/g, "-").replace(/^-+|-+$/g, "");
const numPart = (num) => num.replace(/\./g, ""); // renumbered chapters ≥2: no leading-zero quirk

// index renumbered chapters: filename → { slug→numberpart }
const index = {};
for (const f of readdirSync(join(root, "standard"))) {
  if (!RENUMBERED.has(f)) continue;
  const bySlug = {};
  for (const line of readFileSync(join(root, "standard", f), "utf8").split(/\r?\n/)) {
    const m = line.match(/^#{2,6}\s+(\d+(?:\.\d+)*)\s+(.+?)\s*$/);
    if (m) bySlug[slugifyTitle(m[2])] = numPart(m[1]);
  }
  index[f] = bySlug;
}

let changed = 0, fixed = 0;
const unresolved = [];
const report = [];

for (const file of SECTIONS.flatMap((s) => listMd(join(root, s)))) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const self = basename(file);
  let s = readFileSync(file, "utf8");
  const before = s;

  // cross-file slug-anchors to a renumbered chapter
  s = s.replace(/(\d{2}-[a-z0-9-]+\.md)#(\d+)-([^\s)]+)/g, (m, fname, num, rest) => {
    if (!index[fname]) return m;
    const np = index[fname][rest];
    if (np === undefined) { unresolved.push(`${rel}: ${fname}#${num}-${rest}`); return m; }
    if (np === num) return m;
    fixed++;
    return `${fname}#${np}-${rest}`;
  });

  // same-file slug-anchors inside a renumbered standard chapter
  if (RENUMBERED.has(self)) {
    s = s.replace(/\(#(\d+)-([^\s)]+)\)/g, (m, num, rest) => {
      const np = index[self][rest];
      if (np === undefined) { unresolved.push(`${rel}: (#${num}-${rest}) [same-file]`); return m; }
      if (np === num) return m;
      fixed++;
      return `(#${np}-${rest})`;
    });
  }

  if (s !== before) { changed++; report.push(`  ${rel}`); if (!DRY) writeFileSync(file, s, "utf8"); }
}

function listMd(dir) {
  const out = [];
  for (const e of readdirSync(dir)) {
    const f = join(dir, e);
    if (statSync(f).isDirectory()) out.push(...listMd(f));
    else if (e.endsWith(".md")) out.push(f);
  }
  return out;
}

console.log(`reorder-slug-anchors.js ${DRY ? "(DRY)" : "(APPLIED)"} — files changed: ${changed}, anchors fixed: ${fixed}`);
console.log(report.join("\n"));
if (unresolved.length) {
  console.log(`\nUNRESOLVED (title not matched — check manually): ${unresolved.length}`);
  for (const u of unresolved) console.log(`  ${u}`);
}
