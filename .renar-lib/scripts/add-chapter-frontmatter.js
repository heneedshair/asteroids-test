#!/usr/bin/env node
/**
 * Idempotently prepend YAML frontmatter to RENAR chapter .md files.
 *
 * For each .md in standard/, guide/, reference/, core/:
 *   - If file already starts with `---\n`, skip (idempotent).
 *   - Parse first H1 (`# NN. Title` or `# Title`) for title + order.
 *   - Prepend frontmatter: title, order, lang: ru, draft (for README).
 *
 * Run: node scripts/add-chapter-frontmatter.js [--dry-run]
 *
 * Files where H1 can't be parsed are listed at the end as "needs manual review".
 */

import { readFileSync, writeFileSync, readdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const sections = ["standard", "guide", "reference", "core"];
const DRY = process.argv.includes("--dry-run");

const H1_RE = /^#\s*(?:(\d{1,3})\.\s+)?(.+?)\s*$/;
const FRONTMATTER_RE = /^---\s*\n/;

function buildFrontmatter({ title, order, draft }) {
  const lines = ["---"];
  lines.push(`title: ${JSON.stringify(title)}`);
  if (typeof order === "number") lines.push(`order: ${order}`);
  lines.push(`lang: ru`);
  if (draft) lines.push(`draft: true`);
  lines.push("---", "");
  return lines.join("\n");
}

const stats = { processed: 0, skipped: 0, manual: [] };

for (const section of sections) {
  const dir = join(root, section);
  for (const fname of readdirSync(dir)) {
    if (!fname.endsWith(".md")) continue;
    const full = join(dir, fname);
    const original = readFileSync(full, "utf8");

    if (FRONTMATTER_RE.test(original)) {
      stats.skipped++;
      continue;
    }

    const firstLine = original.split(/\r?\n/, 1)[0] || "";
    const m = H1_RE.exec(firstLine);

    let title, order;
    const isReadme = fname.toLowerCase() === "readme.md";
    const draft = isReadme;

    if (m) {
      const num = m[1] !== undefined ? parseInt(m[1], 10) : null;
      title = m[2];
      if (num !== null) order = num;
      else {
        // Fallback: derive order from filename leading digits (e.g. 00-foo.md → 0)
        const fm = /^(\d{1,3})/.exec(fname);
        if (fm) order = parseInt(fm[1], 10);
        else if (isReadme) order = 999;
        // else leave undefined
      }
    } else {
      stats.manual.push(`${section}/${fname}`);
      continue;
    }

    const fm = buildFrontmatter({ title, order, draft });
    const newContent = fm + original;

    if (!DRY) writeFileSync(full, newContent, "utf8");
    stats.processed++;
    process.stdout.write(
      `${DRY ? "[dry] " : ""}${section}/${fname} → title=${JSON.stringify(title)}, order=${order ?? "—"}${draft ? ", draft" : ""}\n`
    );
  }
}

console.log("");
console.log(
  `Summary: processed ${stats.processed}, skipped (already had frontmatter) ${stats.skipped}, manual review ${stats.manual.length}`
);
if (stats.manual.length) {
  console.log("Needs manual review:");
  for (const f of stats.manual) console.log(`  - ${f}`);
}
