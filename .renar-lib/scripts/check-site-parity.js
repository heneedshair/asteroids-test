#!/usr/bin/env node
/**
 * Smoke check: site marketing copy matches corpus inventory (guide/reference counts).
 *
 * Usage: node scripts/check-site-parity.js [--quiet]
 * Exit 0 — parity OK. Exit 1 — mismatch.
 */

import { readFileSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const QUIET = process.argv.includes("--quiet");

function countNavEntries(mkdocsPath) {
  const text = readFileSync(join(root, mkdocsPath), "utf8");
  const navBlock = text.match(/nav:\s*\n([\s\S]*?)(?:\n\S|$)/)?.[1] ?? "";
  return navBlock
    .split("\n")
    .filter((l) => l.trim().startsWith("- ") && l.includes(".md") && !l.includes("README.md"))
    .length;
}

const expected = {
  guides: countNavEntries("guide/mkdocs.yml"),
  reference: countNavEntries("reference/mkdocs.yml"),
};

const indexPath = join(root, "site/src/pages/ru/index.astro");
const index = readFileSync(indexPath, "utf8");
const guideMatch = index.match(/(\d+)\s+практических\s+руководств/);
const refMatch = index.match(/(\d+)\s+справочников/);

const failures = [];

if (!guideMatch || Number(guideMatch[1]) !== expected.guides) {
  failures.push({
    check: "hero guide count",
    expected: expected.guides,
    actual: guideMatch ? guideMatch[1] : "missing",
    file: "site/src/pages/ru/index.astro",
  });
}
if (!refMatch || Number(refMatch[1]) !== expected.reference) {
  failures.push({
    check: "hero reference count",
    expected: expected.reference,
    actual: refMatch ? refMatch[1] : "missing",
    file: "site/src/pages/ru/index.astro",
  });
}

const llms = readFileSync(join(root, "site/public/llms.txt"), "utf8");
for (const slug of ["07-iso29148", "08-conformance", "09-pedagogical"]) {
  if (!llms.includes(slug) && !llms.toLowerCase().includes(slug.replace(/-/g, " "))) {
    // soft: at least mention trace matrix / conformance / density
  }
}
if (!/trace matrix|ISO 29148/i.test(llms)) {
  failures.push({ check: "llms.txt ISO trace", expected: "mention", actual: "missing" });
}
if (!/conformance kit|self-assessment/i.test(llms)) {
  failures.push({ check: "llms.txt conformance", expected: "mention", actual: "missing" });
}

if (!QUIET) {
  console.log("# check-site-parity.js");
  console.log(`Expected from mkdocs: guides=${expected.guides}, reference=${expected.reference}`);
}

if (failures.length === 0) {
  if (!QUIET) console.log("OK   site parity");
  process.exit(0);
}

for (const f of failures) {
  console.log(`FAIL ${f.check}: expected ${f.expected}, got ${f.actual}${f.file ? ` (${f.file})` : ""}`);
}
process.exit(1);
