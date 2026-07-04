#!/usr/bin/env node
/**
 * reorder-selfrefs.js — fix stale SELF §-refs left by the main reorder's
 * (too-loose) foreign-context filter.
 *
 * The 40-char foreign lookback skipped RENAR self-refs that merely sat NEAR a
 * "SENAR §9"/"BABOK …" mention (e.g. metrics "(§13.2)" near "SENAR §9"). Those
 * self-refs kept the chapter's OLD number.
 *
 * Precise rule per renumbered file — remap "§<old>.<...>" → "§<new>.<...>" UNLESS:
 *   - it is a markdown link to another doc:  "...](" follows  → leave (already correct);
 *   - a foreign standard marker is the IMMEDIATE predecessor (marker [vN] right before §)
 *     → leave (it is that document's section, e.g. "BABOK Guide v3 §5.3", "SENAR §4").
 * Bare "§<old>" without a sub-number (e.g. "SENAR §4") is never matched.
 *
 * Usage: node scripts/reorder-selfrefs.js [--dry-run]
 */
import { readFileSync, writeFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const DRY = process.argv.includes("--dry-run");

const FILES = {
  "02-methodology-positioning.md": [5, 2],
  "03-substrate-versioning.md": [11, 3],
  "04-terms.md": [3, 4],
  "05-roles.md": [4, 5],
  "11-maturity-model.md": [12, 11],
  "12-metrics.md": [13, 12],
  // 13-conformance.md excluded: its bare §14.x all reference normative-refs (now §14), not self.
  "14-normative-refs.md": [2, 14],
};

// verified cross-refs that collide with a file's OLD self-number — must NOT be remapped
const SKIP = {
  "12-metrics.md": new Set(["13.6"]), // §13.6 = conformance Third-party (not metrics §12.6)
};

// foreign standard whose §-numbers must stay (marker as IMMEDIATE predecessor of §)
const FOREIGN_IMMED = /(SENAR|ISO|IEC|IEEE|BABOK|CMMI|NIST|PMBOK|SAFe|RFC|Guide|29148|25010|5338|23894|42001)\s*(?:v?\d+\.?\d*)?\s*$/i;

let fixed = 0;
const log = [];
for (const [fname, [oldN, newN]] of Object.entries(FILES)) {
  const fp = join(root, "standard", fname);
  let s = readFileSync(fp, "utf8");
  const before = s;
  const re = new RegExp(`§(${oldN})((?:\\.\\d+)+)`, "g");
  const skip = SKIP[fname] || new Set();
  s = s.replace(re, (m, o, rest, off, str) => {
    if (skip.has(o + rest)) return m; // verified cross-ref colliding with old self-number
    if (str.slice(off + m.length, off + m.length + 2) === "](") return m; // link → leave
    if (FOREIGN_IMMED.test(str.slice(Math.max(0, off - 16), off))) return m; // foreign-owned
    fixed++;
    log.push(`  ${fname}: §${oldN}${rest} → §${newN}${rest}`);
    return `§${newN}${rest}`;
  });
  if (s !== before && !DRY) writeFileSync(fp, s, "utf8");
}
console.log(`reorder-selfrefs.js ${DRY ? "(DRY)" : "(APPLIED)"} — self-refs fixed: ${fixed}`);
console.log(log.join("\n"));
