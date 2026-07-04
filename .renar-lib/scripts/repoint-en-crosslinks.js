#!/usr/bin/env node
/**
 * repoint-en-crosslinks.js — one-time maintenance utility (en-crosslinks-changelog).
 *
 * EN files were translated with cross-section links pointing to the RU canonical
 * (`../../<section>/<file>`) so that no link was ever dead while the EN corpus was
 * incomplete. Now that every EN counterpart exists, this re-points cross-section
 * links to the EN edition (`../../<section>/en/<file>`) so the EN reading
 * experience is self-contained.
 *
 * Safety:
 *   - Only re-points when the EN target file actually exists (existence-guarded);
 *     links to RU-only files (scripts/, CHANGELOG.md, RENAR-CONFORMANCE.yaml,
 *     research/, *.yaml) are left untouched.
 *   - Special case: reference/06-ru-style-guide.md → reference/en/06-en-style-guide.md.
 *   - Anchors: §-number / latin anchors are preserved (identical in EN, which keeps
 *     the same §-numbers). Cyrillic RU-slug anchors are stripped (they would not
 *     resolve against the English headings) — the link then targets the file top.
 *
 * Idempotent: links already containing `/en/` are skipped. `--dry` reports only.
 */

import { readFileSync, writeFileSync, readdirSync, statSync, existsSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const DRY = process.argv.includes("--dry");
const SECTIONS = ["standard", "reference", "guide", "core"];

function listEnMarkdown(dir, out = []) {
  let entries;
  try { entries = readdirSync(dir); } catch { return out; }
  for (const e of entries) {
    const full = join(dir, e);
    if (statSync(full).isDirectory()) listEnMarkdown(full, out);
    else if (e.endsWith(".md")) out.push(full);
  }
  return out;
}

const enFiles = SECTIONS
  .flatMap((s) => listEnMarkdown(join(root, s, "en")))
  .map((f) => f.replace(/\\/g, "/"));

// Matches a markdown link target of the form ../../<section>/<rest>
const LINK_RE = /\]\(\.\.\/\.\.\/(standard|reference|guide|core)\/([^)]+)\)/g;
const CYRILLIC = /[Ѐ-ӿ]/;

let filesChanged = 0;
let linksRepointed = 0;
let anchorsStripped = 0;

for (const file of enFiles) {
  const raw = readFileSync(file, "utf8");
  let changed = false;

  const next = raw.replace(LINK_RE, (whole, section, rest) => {
    if (rest.startsWith("en/")) return whole; // already EN
    const hashIdx = rest.indexOf("#");
    let filePart = hashIdx === -1 ? rest : rest.slice(0, hashIdx);
    let anchor = hashIdx === -1 ? "" : rest.slice(hashIdx); // includes '#'

    // Special-case the style guide (RU and EN editions have different names).
    let enFilePart;
    if (filePart === "06-ru-style-guide.md") enFilePart = "06-en-style-guide.md";
    else enFilePart = filePart;

    const enAbs = join(root, section, "en", enFilePart);
    if (!existsSync(enAbs)) return whole; // no EN counterpart — leave RU canonical

    // Drop Cyrillic RU-slug anchors (won't resolve against English headings);
    // keep §-number / latin anchors (identical in the EN edition).
    if (anchor && CYRILLIC.test(anchor)) { anchor = ""; anchorsStripped++; }

    changed = true;
    linksRepointed++;
    return `](../../${section}/en/${enFilePart}${anchor})`;
  });

  if (changed) {
    filesChanged++;
    if (!DRY) writeFileSync(file, next);
  }
}

console.log(
  `${DRY ? "[dry] " : ""}re-pointed ${linksRepointed} cross-section link(s) in ${filesChanged} file(s); ` +
  `${anchorsStripped} Cyrillic anchor(s) stripped.`,
);
