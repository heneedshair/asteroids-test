#!/usr/bin/env node
/**
 * check-capability-names.js — closed-list guard for the V1–V6 substrate capability
 * names.
 *
 * The six capabilities are a CLOSED LIST fixed normatively in standard/03 §3.3 and
 * standard/00 MVR-2:
 *   V1 — неизменяемая история            (immutable history)
 *   V2 — атомарная единица изменения      (atomic change unit)
 *   V3 — сравнение различий и рецензирование (diff & review)
 *   V4 — ветвление / набор изменений       (branching / change-set)
 *   V5 — сквозная фиксация версии          (cross-substrate version pin)
 *   V6 — автор и отметка времени           (author + timestamp)
 *
 * Drift detection / reconciliation, schema validation, reference integrity, coverage
 * reporting and lifecycle-state enforcement are RENAR *enforcement mechanisms* layered
 * on top of the capabilities — they are NOT themselves V1–V6. Earlier guide drafts
 * mislabelled the capability table (most severely guide/03 §3 and the «V6 = drift
 * detection» / «V6 = перехваты и события» prose); this gate locks the fixes in.
 *
 * It is a curated blocklist of the exact mislabel constructions (label `V6 — …`,
 * paren `capability V6 (drift…)`, etc.), so false-positive risk is low and the
 * corrective note «… reconciliation / drift detection … а не сами V1–V6» is NOT flagged.
 *
 * Usage:
 *   node scripts/check-capability-names.js [--quiet] [--baseline] [--root <dir>]
 * Exit 0 — clean (or --baseline). Exit 1 — capability mislabels found.
 */

import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2);
const QUIET = argv.includes("--quiet");
const BASELINE = argv.includes("--baseline");
const rootIdx = argv.indexOf("--root");
const root = rootIdx !== -1 ? argv[rootIdx + 1] : join(__dirname, "..");

const SECTIONS = ["standard", "guide", "reference", "core"];

// Known mislabel construction → canonical capability name (standard/03 §3.3).
const RULES = [
  [/\bV1\s*[—–-]\s*Versioned content addressing/i, "V1 — неизменяемая история"],
  [/адресуемость версионированного содержимого/i, "V1 — неизменяемая история (не «адресуемость содержимого»)"],
  [/\bV2\s*[—–-]\s*Schema validation/i, "V2 — атомарная единица изменения (валидация схемы — enforcement, не V2)"],
  [/\bV3\s*[—–-]\s*Lifecycle state enforcement/i, "V3 — сравнение различий и рецензирование (контроль статусов — enforcement, не V3)"],
  [/\bV4\s*[—–-]\s*Reporting/i, "V4 — ветвление / набор изменений (отчёты — enforcement, не V4)"],
  [/\bV5\s*[—–-]\s*Reference integrity/i, "V5 — сквозная фиксация версии (целостность ссылок — enforcement, не V5)"],
  [/\bV6\s*[—–-]\s*Drift detection/i, "V6 — автор и отметка времени (drift detection — enforcement, не V6)"],
  [/\bV6\s*[—–-]\s*перехват/i, "V6 — автор и отметка времени (перехваты/события — enforcement, не V6)"],
  [/capability\s+V6\s*\(\s*drift/i, "V6 — автор и отметка времени; drift detection — reconciliation hook (§4.11)"],
  [/\bV6\s*\(\s*drift/i, "V6 — автор и отметка времени; drift detection — reconciliation hook (§4.11)"],
  [/Drift detection\s*\(\s*V6/i, "drift detection — reconciliation, не возможность V6"],
  [/Reconciliation hook\s*\(\s*V6\s*\)/i, "reconciliation hook опирается на V5 (version pin), не V6"],
  [/Hook носителя\s*\(\s*V6\s*\)/i, "hook носителя — enforcement; V6 = автор и отметка времени"],
  [/\(\s*capability\s+V6\s*\)/i, "проверь привязку: V6 = автор и отметка времени, не drift/reconciliation"],
];

function listMarkdown(dir) {
  const out = [];
  let entries;
  try { entries = readdirSync(dir); } catch { return out; }
  for (const entry of entries) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) out.push(...listMarkdown(full));
    else if (entry.endsWith(".md")) out.push(full);
  }
  return out;
}

const problems = [];
const files = SECTIONS.flatMap((s) => listMarkdown(join(root, s)));
for (const file of files) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const lines = readFileSync(file, "utf8").split(/\r?\n/);
  lines.forEach((line, idx) => {
    for (const [re, fix] of RULES) {
      const m = line.match(re);
      if (m) problems.push(`${rel}:${idx + 1} mislabel «${m[0].trim()}» → ${fix} (standard/03 §3.3)`);
    }
  });
}

if (!QUIET) console.log(`# check-capability-names.js — ${files.length} files scanned`);
if (problems.length === 0) {
  if (!QUIET) console.log("OK   0 V1–V6 capability mislabels (names per standard/03 §3.3)");
  process.exit(0);
}
for (const p of problems) console.log(`FAIL ${p}`);
console.log(`\nSummary: ${problems.length} capability mislabel(s)`);
process.exit(BASELINE ? 0 : 1);
