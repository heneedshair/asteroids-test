#!/usr/bin/env node
/**
 * RFC-2119 modal inventory for RENAR RU corpus.
 * Report-only: counts MUST/SHOULD/MAY RU equivalents per file.
 * Exit 0 always (informational). Use in CI as baseline artifact.
 */
import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const SECTIONS = ["standard", "reference", "core"];
// --quiet: one-line totals only (for check:all — keeps the gate output clean
// while still surfacing the RFC-2119 baseline). Full per-file table otherwise.
const QUIET = process.argv.includes("--quiet");

// RU lowercase canonical (Option C, reference/06 §2.2).
// JS `\b` is ASCII-only — it never fires adjacent to a Cyrillic letter (Cyrillic
// is not `\w`), so the previous `\b…\b` RU patterns silently matched ZERO modals
// (the gate reported RU must/should/may = 0 across the whole corpus). Use
// explicit letter-class look-arounds as Unicode-aware word boundaries instead.
const RB = "(?<![А-Яа-яЁёA-Za-z0-9_])"; // left boundary (no preceding word char)
const RA = "(?![А-Яа-яЁёA-Za-z0-9_])"; // right boundary (no following word char)
const MUST = new RegExp(
  RB + "(должен|должна|должно|должны|обязан|обязана|обязано|обязаны|требуется|запрещено|запрещён|не\\s+должен|не\\s+обязан)" + RA,
  "gi"
);
const SHOULD = new RegExp(RB + "(следует|рекомендуется|желательно|не\\s+следует)" + RA, "gi");
const MAY = new RegExp(RB + "(может|можно|допускается|опционально)" + RA, "gi");

// EN UPPERCASE canonical (reference/06 §2.3, EN translation convention).
// Case-sensitive: only UPPERCASE keywords are normative; longer forms first
// so "MUST NOT" counts once. RU carve-out does NOT apply to EN (`*/en/`).
const EN_MUST = /\b(MUST NOT|MUST|SHALL NOT|SHALL|REQUIRED)\b/g;
const EN_SHOULD = /\b(SHOULD NOT|SHOULD|NOT RECOMMENDED|RECOMMENDED)\b/g;
const EN_MAY = /\b(MAY|OPTIONAL)\b/g;

function isEnglish(raw) {
  return /^lang:\s*"?en"?\s*$/m.test(raw.split("---")[1] || "");
}

function walk(dir, acc = []) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p, acc);
    else if (name.endsWith(".md") && name !== "README.md") acc.push(p);
  }
  return acc;
}

function stripProse(raw) {
  let t = raw.replace(/^---[\s\S]*?---\n/, "");
  t = t.replace(/```[\s\S]*?```/g, "");
  t = t.replace(/`[^`]+`/g, "");
  return t;
}

function count(re, text) {
  return (text.match(re) || []).length;
}

const files = SECTIONS.flatMap((s) => walk(join(root, s)));
let ruMust = 0, ruShould = 0, ruMay = 0;
let enMust = 0, enShould = 0, enMay = 0;
const ruRows = [];
const enRows = [];

for (const f of files.sort()) {
  const raw = readFileSync(f, "utf8");
  const prose = stripProse(raw);
  const rel = relative(root, f).replace(/\\/g, "/");
  if (isEnglish(raw)) {
    const m = count(EN_MUST, prose), s = count(EN_SHOULD, prose), y = count(EN_MAY, prose);
    enMust += m; enShould += s; enMay += y;
    if (m + s + y > 0) enRows.push(`${rel}\t${m}\t${s}\t${y}`);
  } else {
    const m = count(MUST, prose), s = count(SHOULD, prose), y = count(MAY, prose);
    ruMust += m; ruShould += s; ruMay += y;
    if (m + s + y > 0) ruRows.push(`${rel}\t${m}\t${s}\t${y}`);
  }
}

if (QUIET) {
  console.log(
    `check-rfc-modals: RU must=${ruMust} should=${ruShould} may=${ruMay} | ` +
      `EN MUST=${enMust} SHOULD=${enShould} MAY=${enMay}`
  );
} else {
  console.log("RFC modal inventory — RU lowercase canonical (prose, stripped fences):\n");
  console.log("file\tmust\tshould\tmay");
  for (const r of ruRows) console.log(r);
  console.log(`\nTOTAL (ru)\t${ruMust}\t${ruShould}\t${ruMay}`);

  console.log("\nRFC modal inventory — EN UPPERCASE canonical (lang:en):\n");
  console.log("file\tMUST\tSHOULD\tMAY");
  for (const r of enRows) console.log(r);
  console.log(`\nTOTAL (en)\t${enMust}\t${enShould}\t${enMay}`);
}
