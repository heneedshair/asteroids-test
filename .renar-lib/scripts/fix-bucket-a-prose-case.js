#!/usr/bin/env node
/**
 * Fix mid-sentence capitalized Bucket A terms in RU prose (reference/06 §1.3).
 * Mirrors style-guide-check.js heuristics: sentence-start caps are preserved.
 */
import { readFileSync, writeFileSync, readdirSync, statSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const SECTIONS = ["standard", "guide", "reference", "core"];

const BUCKET_A = [
  "commit", "merge", "diff", "branch", "push", "pull", "hook", "patch",
  "frontmatter", "manifest", "slug", "hash", "trigger", "runner", "pipeline",
  "release", "deploy", "build", "workflow", "linter", "parser", "compiler",
  "tooling", "tracker", "substrate", "provenance", "fallback",
];

const FRONTMATTER_RE = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/;
const SENTENCE_BREAK_RE = /[.!?:—]\s*$/;
const LINE_START_RE = /^[\s>*\-#|]*$/;

function listMarkdown(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) out.push(...listMarkdown(full));
    else if (entry.endsWith(".md") && entry !== "README.md") out.push(full);
  }
  return out;
}

function fixLine(line) {
  let changed = false;
  let out = line;
  for (const term of BUCKET_A) {
    const cap = term.charAt(0).toUpperCase() + term.slice(1);
    const re = new RegExp(`\\b${cap}\\b`, "g");
    out = out.replace(re, (match, offset, str) => {
      const prefix = str.slice(0, offset);
      if (LINE_START_RE.test(prefix) || SENTENCE_BREAK_RE.test(prefix)) return match;
      changed = true;
      return term;
    });
  }
  return { line: out, changed };
}

function processFile(path) {
  const text = readFileSync(path, "utf8");
  const rawLines = text.split(/\r?\n/);
  let inFrontmatter = false;
  let inFence = false;
  let fixes = 0;
  const outLines = [];

  for (let i = 0; i < rawLines.length; i++) {
    let line = rawLines[i];
    if (i === 0 && line === "---") {
      inFrontmatter = true;
      outLines.push(line);
      continue;
    }
    if (inFrontmatter) {
      outLines.push(line);
      if (line === "---") inFrontmatter = false;
      continue;
    }
    if (/^\s*```/.test(line)) {
      outLines.push(line);
      inFence = !inFence;
      continue;
    }
    if (inFence) {
      outLines.push(line);
      continue;
    }
    const { line: fixed, changed } = fixLine(line);
    if (changed) fixes++;
    outLines.push(fixed);
  }

  if (fixes > 0) {
    writeFileSync(path, outLines.join("\n") + (text.endsWith("\n") ? "\n" : ""), "utf8");
  }
  return fixes;
}

let total = 0;
for (const section of SECTIONS) {
  const dir = join(root, section);
  for (const file of listMarkdown(dir)) {
    const n = processFile(file);
    if (n > 0) {
      console.log(`${section}/${file.split(/[/\\]/).slice(-1)[0]}: ${n} lines`);
      total += n;
    }
  }
}
console.log(`Total lines fixed: ${total}`);
