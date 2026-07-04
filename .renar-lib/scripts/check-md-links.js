#!/usr/bin/env node
/**
 * Check internal markdown links in RENAR corpus (standard/, guide/, reference/, core/).
 * Skips http(s) URLs. Reports missing file targets (anchors not verified).
 *
 * Usage: node scripts/check-md-links.js [--quiet]
 * Exit 0 — no broken file links. Exit 1 — any broken.
 */

import { readFileSync, readdirSync, statSync, existsSync } from "fs";
import { join, dirname, resolve, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const SECTIONS = ["standard", "guide", "reference", "core"];
const QUIET = process.argv.includes("--quiet");
const LINK_RE = /\[([^\]]*)\]\(([^)]+)\)/g;
const SKIP_PREFIX = /^(https?:|mailto:|#)/;

function listMarkdown(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      out.push(...listMarkdown(full));
    } else if (entry.endsWith(".md")) {
      out.push(full);
    }
  }
  return out;
}

function resolveLink(fromFile, href) {
  const [pathPart] = href.split("#");
  if (!pathPart || SKIP_PREFIX.test(pathPart)) return null;
  const base = dirname(fromFile);
  let target = resolve(base, pathPart);
  if (existsSync(target) && statSync(target).isDirectory()) {
    target = join(target, "README.md");
  }
  if (!existsSync(target) && !pathPart.endsWith(".md")) {
    const withMd = target + ".md";
    if (existsSync(withMd)) target = withMd;
  }
  return target;
}

const files = SECTIONS.flatMap((s) => listMarkdown(join(root, s)));
const broken = [];

for (const file of files) {
  let content = readFileSync(file, "utf8");
  content = content.replace(/```[\s\S]*?```/g, "");
  content = content.replace(/`[^`]+`/g, "");
  let m;
  while ((m = LINK_RE.exec(content)) !== null) {
    const href = m[2].trim();
    if (SKIP_PREFIX.test(href)) continue;
    const pathPart = href.split("#")[0];
    if (pathPart === "path" || /(^|\/)file\.md$/i.test(pathPart)) continue;
    const target = resolveLink(file, href);
    if (target && !existsSync(target)) {
      broken.push({
        from: relative(root, file),
        href,
        target: relative(root, target),
      });
    }
  }
}

if (!QUIET) {
  console.log(`# check-md-links.js — ${files.length} files scanned`);
}

if (broken.length === 0) {
  if (!QUIET) console.log(`OK   0 broken internal file links`);
  process.exit(0);
}

for (const b of broken) {
  console.log(`FAIL ${b.from} → ${b.href} (missing: ${b.target})`);
}
console.log(`\nSummary: ${broken.length} broken link(s)`);
process.exit(1);
