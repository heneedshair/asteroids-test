#!/usr/bin/env node
/**
 * Denylist English prose fragments in site/src/pages/ru/
 */
import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const dir = join(__dirname, "..", "site", "src", "pages", "ru");

const DENY = [
  "substrate-agnostic",
  "first-class",
  "peer-to-peer",
  "document-oriented store",
  "end-to-end",
  "Quality Gates",
  "Business Requirement",
  "System Requirement",
  "Task Requirement",
  "Source of Truth",
  "Closed list policy",
  "AI-aware design",
  "Substrate independence",
  "Trace перед speed",
  "Conformance self-assessment",
  "Versioned identity",
  "Atomic change unit",
  "Requirements Engineering &",
];

function walk(d, acc = []) {
  for (const n of readdirSync(d)) {
    const p = join(d, n);
    if (statSync(p).isDirectory()) walk(p, acc);
    else if (/\.(astro|md)$/.test(n)) acc.push(p);
  }
  return acc;
}

let findings = 0;

for (const f of walk(dir)) {
  const lines = readFileSync(f, "utf8").split("\n");
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.includes("lang=\"en\"")) continue;
    for (const term of DENY) {
      if (line.includes(term)) {
        console.log(`${relative(join(__dirname, ".."), f).replace(/\\/g, "/")}:${i + 1}: "${term}"`);
        findings++;
      }
    }
  }
}

const llms = join(__dirname, "..", "site", "public", "llms.txt");
if (statSync(llms).isFile()) {
  const lines = readFileSync(llms, "utf8").split("\n");
  for (let i = 0; i < lines.length; i++) {
    for (const term of ["first-class", "substrate-agnostic", "TC first-class"]) {
      if (lines[i].includes(term)) {
        console.log(`site/public/llms.txt:${i + 1}: "${term}"`);
        findings++;
      }
    }
  }
}

if (findings) {
  console.error(`\n${findings} site prose violation(s)`);
  process.exit(1);
}
console.log("check-site-russian-prose: PASS");
