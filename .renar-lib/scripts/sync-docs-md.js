#!/usr/bin/env node
/**
 * sync-docs-md.js — зеркалит RU-корпус в site/public/md/ для content-negotiation.
 *
 * Для каждой главы <section>/<slug>.md создаётся site/public/md/<section>/<slug>.md.
 * Astro копирует public/ в dist as-is, поэтому файлы доступны по /md/<section>/<slug>.md.
 * nginx отдаёт их на /docs/<section>/<slug>/, когда клиент шлёт Accept: text/markdown.
 *
 * Источник: standard/ + guide/ + reference/ + core/ (RU primary).
 * Исключаются: подкаталоги /en/, README.md.
 * Идемпотентен (фиксированный набор файлов, перезапись).
 * Запуск: node scripts/sync-docs-md.js  (npm run build:docs-md)
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const OUT_DIR = path.join(ROOT, "site", "public", "md");
const SECTIONS = ["standard", "guide", "reference", "core"];

/** Собрать .md верхнего уровня раздела, исключив README.md. */
function collect(section) {
  const abs = path.join(ROOT, section);
  if (!fs.existsSync(abs)) {
    console.warn(`[warn] раздел отсутствует, пропускаю: ${section}`);
    return [];
  }
  return fs
    .readdirSync(abs)
    .filter((n) => n.endsWith(".md") && n.toLowerCase() !== "readme.md")
    .filter((n) => fs.statSync(path.join(abs, n)).isFile())
    .sort();
}

function main() {
  let count = 0;
  for (const section of SECTIONS) {
    const files = collect(section);
    if (files.length === 0) continue;
    const destSection = path.join(OUT_DIR, section);
    fs.mkdirSync(destSection, { recursive: true });
    for (const name of files) {
      fs.copyFileSync(
        path.join(ROOT, section, name),
        path.join(destSection, name)
      );
      count++;
    }
  }
  if (count === 0) {
    console.error("[error] не скопировано ни одного файла");
    process.exit(1);
  }
  console.log(`[ok] sync-docs-md: ${count} файлов → ${path.relative(ROOT, OUT_DIR)}/<section>/`);
}

main();
