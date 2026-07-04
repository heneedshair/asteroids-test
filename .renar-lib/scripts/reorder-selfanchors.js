#!/usr/bin/env node
/**
 * reorder-selfanchors.js — fix stale SAME-FILE numeric anchors in renumbered chapters.
 *
 * The main reorder remapped cross-file anchors (FILE.md#N) but not same-file ones
 * "[§5.3](#5.3)" — the link text got remapped (§2.3) while the bare "(#5.3)" anchor
 * (no filename) was left. A same-file anchor is BY DEFINITION a self-reference, so its
 * leading number must equal the chapter's NEW number. Reliable, unambiguous fix.
 *
 * Usage: node scripts/reorder-selfanchors.js [--dry-run]
 */
import { readFileSync, writeFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const DRY = process.argv.includes("--dry-run");

// renumbered file → [oldChapterNum, newChapterNum]
const FILES = {
  "02-methodology-positioning.md": [5, 2],
  "03-substrate-versioning.md": [11, 3],
  "04-terms.md": [3, 4],
  "05-roles.md": [4, 5],
  "11-maturity-model.md": [12, 11],
  "12-metrics.md": [13, 12],
  "13-conformance.md": [14, 13],
  "14-normative-refs.md": [2, 14],
};

let fixed = 0;
for (const [fname, [oldN, newN]] of Object.entries(FILES)) {
  const fp = join(root, "standard", fname);
  let s = readFileSync(fp, "utf8");
  const before = s;
  // same-file anchors: ](#<oldN>.<...>) → ](#<newN>.<...>)
  const re = new RegExp(`\\]\\(#${oldN}((?:\\.\\d+)+)\\)`, "g");
  s = s.replace(re, (m, rest) => { fixed++; return `](#${newN}${rest})`; });
  if (s !== before && !DRY) writeFileSync(fp, s, "utf8");
  if (s !== before) console.log(`  ${fname}: same-file anchors #${oldN}.x → #${newN}.x`);
}
console.log(`reorder-selfanchors.js ${DRY ? "(DRY)" : "(APPLIED)"} — anchors fixed: ${fixed}`);
