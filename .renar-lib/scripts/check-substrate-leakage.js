#!/usr/bin/env node
/**
 * Fail if proprietary / substrate-specific vendor tokens leak into normative standard/.
 *
 * Policy (CLAUDE.md): normative = V1–V6 capabilities only; TAUSIK/KAI/Raven/Finka
 * only in guide/reference (informative). Git primitives in normative — forbidden
 * except allowlisted anti-pattern examples in §3.4 / §3.6 (substrate-versioning).
 */

import { readFileSync, readdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const standardDir = join(root, "standard");

const VENDOR_PATTERN =
  /\b(tausik|kai|raven|finka|cursor|copilot|claude code|windsurf)\b/i;

const GIT_NORMATIVE_PATTERN = null; // evaluated inline below

const ALLOWLIST = [
  { file: "03-substrate-versioning.md", reason: "§3.4 mapping + §3.6 anti-patterns" },
];

function listMdFiles(dir) {
  return readdirSync(dir)
    .filter((f) => f.endsWith(".md"))
    .map((f) => join(dir, f));
}

function isAllowlisted(basename, lineNo, text) {
  if (!ALLOWLIST.some((a) => basename.endsWith(a.file))) return false;
  // §3.6 table: substrate-specific column (right side)
  if (/substrate-specific \(НЕ нормативная\)/.test(text)) return true;
  if (/§3\.4|§3\.6|пример реализации|НЕ нормативная/.test(text)) return true;
  if (lineNo >= 130 && lineNo <= 186 && basename.endsWith("03-substrate-versioning.md"))
    return true;
  return false;
}

const findings = [];

for (const fp of listMdFiles(standardDir)) {
  const basename = fp.split(/[/\\]/).pop();
  const lines = readFileSync(fp, "utf8").split("\n");

  lines.forEach((line, idx) => {
    const lineNo = idx + 1;
    if (isAllowlisted(basename, lineNo, line)) return;

    if (VENDOR_PATTERN.test(line)) {
      findings.push({ file: basename, line: lineNo, kind: "vendor", snippet: line.trim() });
    }
    const gitHit =
      /\b(git commit|pull request|merge request|submodule SHA|force-push)\b/i.test(line) ||
      (/\bcommit\b/i.test(line) &&
        !/Bucket A|committed|submodule SR|Module\/Submodule/i.test(line)) ||
      (/\bPR\b/.test(line) && !/PROC|APR/i.test(line));
    if (gitHit && !isAllowlisted(basename, lineNo, line)) {
      findings.push({ file: basename, line: lineNo, kind: "git-primitive", snippet: line.trim() });
    }
    if (/\.req\//.test(line) && !/\[requirements-substrate\]/.test(line)) {
      findings.push({ file: basename, line: lineNo, kind: "layout-leak", snippet: line.trim() });
    }
  });
}

if (findings.length) {
  console.error(`FAIL: ${findings.length} substrate-leakage finding(s) in standard/\n`);
  for (const f of findings) {
    console.error(`  ${f.file}:${f.line} [${f.kind}] ${f.snippet.slice(0, 100)}`);
  }
  process.exit(1);
}

console.log("OK: standard/ — 0 substrate-leakage findings");
