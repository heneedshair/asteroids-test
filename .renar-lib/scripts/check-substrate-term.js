#!/usr/bin/env node
/**
 * check-substrate-term.js — terminology guard for the substrate→«носитель» decision.
 *
 * Session #27 decision (camertone §7, reference/06 §1.3.1 note): the prose term for
 * the artifact-storage concept is **«носитель»**. Latin `substrate` survives ONLY in:
 *   - field / schema keys (`substrate-capabilities`, `substrate-v1-v6`, `substrate:`),
 *   - code / YAML blocks,
 *   - file names and link targets (`03-substrate-versioning.md`),
 *   - HTML anchor ids (`#27-substrate-capabilities-v1-v6`),
 *   - first-mention glosses in backticks («Носитель (`substrate`)»).
 * All of those are either inside inline-backticks, fenced code, link URLs, or HTML
 * tags. So after stripping those, ANY remaining latin `substrate` in prose is a leak.
 *
 * The check also flags the abandoned second translation «среда хранения» (it was
 * unified into «носитель»), so the dual-vocabulary drift cannot return.
 *
 * Usage:
 *   node scripts/check-substrate-term.js [--quiet] [--baseline] [--root <dir>]
 * Exit 0 — clean (or --baseline). Exit 1 — leaks found.
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
const SUBSTRATE = /\bsubstrate\b/i;
const SREDA = /сред[аеуыойю]\s+хранения/i;

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

// Per-line prose mask: blank out frontmatter, fenced code, inline backticks,
// markdown link URLs, and HTML tags so only human-readable prose remains.
function proseLines(text) {
  const raw = text.split(/\r?\n/);
  const out = new Array(raw.length).fill("");
  let inFence = false;
  let i = 0;
  if (raw[0] === "---") {
    i = 1;
    while (i < raw.length && raw[i] !== "---") i++;
    i++; // skip closing ---
  }
  for (; i < raw.length; i++) {
    const line = raw[i];
    if (/^\s*```/.test(line)) { inFence = !inFence; continue; }
    if (inFence) continue;
    out[i] = line
      .replace(/`[^`]*`/g, " ")                              // inline code
      .replace(/\]\([^)]*\)/g, "]")                          // markdown link URL
      .replace(/<[^>]+>/g, " ")                              // HTML tags (anchors)
      .replace(/\d{2}-[a-z0-9-]*substrate[a-z0-9-]*/gi, " ") // file stems (03-substrate-versioning, 04-document-store-substrate)
      .replace(/cross-substrate/gi, " ");                    // V5 capability gloss «Cross-substrate version pin»
  }
  return out;
}

const problems = [];
const files = SECTIONS.flatMap((s) => listMarkdown(join(root, s)));
let scanned = 0;
for (const file of files) {
  const rel = file.slice(root.length + 1).replace(/\\/g, "/");
  const raw = readFileSync(file, "utf8");
  // RU-scoped gate: EN translations (`*/en/`, lang:en) use native «substrate» — skip.
  if (/^lang:\s*"?en"?\s*$/m.test(raw.split("---")[1] || "")) continue;
  scanned++;
  const lines = proseLines(raw);
  lines.forEach((line, idx) => {
    if (!line) return;
    if (SUBSTRATE.test(line)) problems.push(`${rel}:${idx + 1} latin \`substrate\` in prose → «носитель»`);
    if (SREDA.test(line)) problems.push(`${rel}:${idx + 1} «среда хранения» → «носитель» (unified, session #27)`);
  });
}

if (!QUIET) console.log(`# check-substrate-term.js — ${scanned} files scanned (RU-only; ${files.length - scanned} lang:en skipped)`);
if (problems.length === 0) {
  if (!QUIET) console.log("OK   0 substrate-term leaks (prose uses «носитель»)");
  process.exit(0);
}
for (const p of problems) console.log(`FAIL ${p}`);
console.log(`\nSummary: ${problems.length} substrate-term leak(s)`);
process.exit(BASELINE ? 0 : 1);
