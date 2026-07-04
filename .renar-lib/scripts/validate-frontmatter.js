#!/usr/bin/env node
/**
 * Validate YAML frontmatter for RENAR chapter .md files.
 *
 * Scans standard/, guide/, reference/, core/ for .md files (excluding README.md)
 * and verifies each has well-formed frontmatter with required fields:
 *   - title       — non-empty string
 *   - order       — integer (chapter sort order)
 *   - lang        — "ru" | "en"
 *
 * Optional fields are accepted but not validated for structure.
 *
 * Usage:
 *   node scripts/validate-frontmatter.js            # validate all
 *   node scripts/validate-frontmatter.js --quiet    # only show errors
 *
 * Exit code 0 — all files valid. Exit code 1 — any file failed.
 *
 * Complements scripts/add-chapter-frontmatter.js (writer) — same minimal
 * schema, no external deps. See reference/02-schemas.md for the canonical
 * frontmatter contract.
 */

import { readFileSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const SECTIONS = ["standard", "guide", "reference", "core"];
const QUIET = process.argv.includes("--quiet");
const ALLOWED_LANG = new Set(["ru", "en"]);
const FRONTMATTER_RE = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/;

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

function parseFrontmatter(text) {
  const m = FRONTMATTER_RE.exec(text);
  if (!m) return null;
  const fields = {};
  for (const line of m[1].split(/\r?\n/)) {
    const eq = line.indexOf(":");
    if (eq < 0) continue;
    const key = line.slice(0, eq).trim();
    let val = line.slice(eq + 1).trim();
    if (!key) continue;
    if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
      val = val.slice(1, -1);
    }
    fields[key] = val;
  }
  return fields;
}

function validate(path, fields) {
  const errors = [];
  if (!fields) {
    errors.push("no frontmatter block (file must start with `---`)");
    return errors;
  }
  if (!fields.title || fields.title.length === 0) {
    errors.push("missing or empty `title`");
  }
  if (fields.order === undefined) {
    errors.push("missing `order`");
  } else if (!/^\d+$/.test(fields.order)) {
    errors.push(`\`order\` not an integer: "${fields.order}"`);
  }
  if (!fields.lang) {
    errors.push("missing `lang`");
  } else if (!ALLOWED_LANG.has(fields.lang)) {
    errors.push(`\`lang\` not in {ru, en}: "${fields.lang}"`);
  }
  return errors;
}

let failed = 0;
let checked = 0;

for (const section of SECTIONS) {
  const dir = join(root, section);
  let files;
  try {
    files = listMarkdown(dir);
  } catch (e) {
    if (e.code === "ENOENT") continue;
    throw e;
  }
  for (const file of files) {
    checked++;
    const text = readFileSync(file, "utf8");
    const fields = parseFrontmatter(text);
    const errors = validate(file, fields);
    const rel = relative(root, file).replace(/\\/g, "/");
    if (errors.length === 0) {
      if (!QUIET) console.log(`OK   ${rel}`);
    } else {
      failed++;
      console.log(`FAIL ${rel}`);
      for (const err of errors) console.log(`     - ${err}`);
    }
  }
}

console.log(`\n${checked} files checked, ${failed} failed.`);
process.exit(failed === 0 ? 0 : 1);
