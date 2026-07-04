#!/usr/bin/env node
/**
 * Validate YAML frontmatter examples in RENAR public corpus against reference/02 rules.
 *
 * Scans ```yaml fences in standard/, guide/, reference/, core/ (excludes README.md).
 * Flags deprecated artifact types and TC anti-patterns documented in guide/10-migration-v1.md.
 *
 * Usage: node scripts/validate-schema-examples.js [--quiet]
 * Exit 0 — no violations. Exit 1 — any violation.
 */

import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const SECTIONS = ["standard", "guide", "reference", "core"];
const QUIET = process.argv.includes("--quiet");

const DEPRECATED_TYPES = new Set(["INT-SR", "INT-TC", "AIC", "UIC", "TS", "TM"]);
const VALID_TC_TYPES = new Set([
  "acceptance",
  "ux",
  "system",
  "contract",
  "eval",
  "security",
]);
const VALID_ARTIFACT_TYPES = new Set([
  "BR",
  "SR",
  "TR",
  "ADAPT",
  "TC",
  "SPEC-ARCH",
  "SPEC-API",
  "SPEC-DATA",
  "SPEC-INT",
  "SPEC-PROC",
  "SPEC-UI",
  "SPEC-AI",
  "SPEC-SEC",
  "SPEC-OPS",
]);

const YAML_FENCE_RE = /```yaml\r?\n([\s\S]*?)```/g;
const TYPE_RE = /^type:\s*(.+)$/m;

function listMarkdown(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      out.push(...listMarkdown(full));
    } else if (entry.endsWith(".md") && entry !== "README.md") {
      out.push(full);
    }
  }
  return out;
}

function lineOf(block, indexInBlock) {
  return block.slice(0, indexInBlock).split(/\r?\n/).length;
}

function checkYamlBlock(file, block, blockIndex) {
  const findings = [];
  const rel = relative(root, file);

  const typeMatch = block.match(/^type:\s*(.+)$/m);
  if (!typeMatch) return findings;

  const rawType = typeMatch[1].split("#")[0].trim();
  const typeToken = rawType.split("|")[0].trim();

  if (DEPRECATED_TYPES.has(typeToken)) {
    findings.push({
      file: rel,
      block: blockIndex,
      rule: "deprecated-type",
      message: `type: ${typeToken} — use canonical type per guide/10-migration-v1.md`,
    });
  }

  if (typeToken === "system") {
    findings.push({
      file: rel,
      block: blockIndex,
      rule: "tc-type-as-artifact-type",
      message: "type: system — use type: TC + tc-type: system",
    });
  }

  if (
    typeToken !== "TC" &&
    ["acceptance", "ux", "system", "contract", "eval", "security"].includes(typeToken)
  ) {
    findings.push({
      file: rel,
      block: blockIndex,
      rule: "tc-type-as-artifact-type",
      message: `type: ${typeToken} — tc-type belongs under type: TC`,
    });
  }

  if (typeToken === "TC" || rawType.includes("TC")) {
    const tcTypeMatch = block.match(/^tc-type:\s*(.+)$/m);
    if (!tcTypeMatch) {
      findings.push({
        file: rel,
        block: blockIndex,
        rule: "tc-missing-tc-type",
        message: "type: TC without tc-type",
      });
    } else {
      const tcRaw = tcTypeMatch[1].split("#")[0].trim();
      if (tcRaw.includes("|")) {
        // schema doc enum line — skip
      } else if (!VALID_TC_TYPES.has(tcRaw)) {
        findings.push({
          file: rel,
          block: blockIndex,
          rule: "invalid-tc-type",
          message: `tc-type: ${tcRaw} not in closed list`,
        });
      }
    }
  }

  if (
    typeToken.startsWith("SPEC-") ||
    (rawType.includes("SPEC-") && !rawType.includes("|"))
  ) {
    const specType = typeToken.startsWith("SPEC-")
      ? typeToken
      : rawType.match(/SPEC-[A-Z]+/)?.[0];
    if (specType && !VALID_ARTIFACT_TYPES.has(specType)) {
      findings.push({
        file: rel,
        block: blockIndex,
        rule: "invalid-spec-type",
        message: `unknown SPEC type: ${specType}`,
      });
    }
  }

  if (/^type:\s*BR\b/m.test(block) || /^type:\s*SR\b/m.test(block)) {
    if (!/^status:\s/m.test(block) && !block.includes("status:")) {
      // soft warn only in examples with partial frontmatter — skip if clearly fragment
    }
  }

  // verifies[].version without requirement-version (deprecated field name in examples)
  if (/verifies:\s*\n[\s\S]*?\bversion:/m.test(block) && !/requirement-version:/m.test(block)) {
    findings.push({
      file: rel,
      block: blockIndex,
      rule: "verifies-legacy-version",
      message: "verifies[] uses `version:` — canonical field is requirement-version",
    });
  }

  return findings;
}

const files = SECTIONS.flatMap((s) => listMarkdown(join(root, s)));
const allFindings = [];

for (const file of files) {
  const content = readFileSync(file, "utf8");
  let m;
  let blockIndex = 0;
  YAML_FENCE_RE.lastIndex = 0;
  while ((m = YAML_FENCE_RE.exec(content)) !== null) {
    blockIndex += 1;
    allFindings.push(...checkYamlBlock(file, m[1], blockIndex));
  }
}

if (!QUIET) {
  console.log(`# validate-schema-examples.js — ${files.length} files, YAML fences scanned`);
}

if (allFindings.length === 0) {
  if (!QUIET) console.log("OK   0 schema example violations");
  process.exit(0);
}

for (const f of allFindings) {
  console.log(`FAIL ${f.file} [block ${f.block}] ${f.rule}: ${f.message}`);
}
console.log(`\nSummary: ${allFindings.length} violation(s)`);
process.exit(1);
