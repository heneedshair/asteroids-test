#!/usr/bin/env node
/**
 * build-llms-full.js — генерирует site/public/llms-full.txt:
 * полнотекстовую конкатенацию RU-корпуса RENAR для AI-агентов
 * (компаньон к рукописному site/public/llms.txt).
 *
 * Источник: core/ + standard/ + reference/ + guide/ (RU primary).
 * Исключаются: подкаталоги /en/, README.md.
 * Каждый файл предваряется заголовком с каноническим /docs/ URL.
 *
 * Идемпотентен: один и тот же ввод → один и тот же вывод.
 * Запуск: node scripts/build-llms-full.js  (npm run build:llms-full)
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const OUT = path.join(ROOT, "site", "public", "llms-full.txt");
const BASE = "https://renar.tech";

// Разделы в порядке чтения. core — мягкое введение, далее нормативка, справка, гайд.
const SECTIONS = ["core", "standard", "reference", "guide"];

const HEADER = `# RENAR — инженерия требований и нормативная адаптивная регуляция (полный текст)

> Полнотекстовая конкатенация RU-корпуса RENAR для AI-агентов. Самостоятельный
> нормативный стандарт инженерии требований для AI-нативной разработки: иерархия
> BR/SR/TR, артефакт ADAPT, 9 типов SPEC (закрытый список), контрольные примеры
> (TC), возможности хранилища V1–V6, уровни зрелости RENAR-1..5. Дополняет SENAR.
>
> Лицензия: CC BY-SA 4.0. Версия: 1.0-draft. Сайт: ${BASE}
> Краткий индекс: ${BASE}/llms.txt
`;

/** Рекурсивно собрать .md файлы раздела, исключив /en/ и README.md. */
function collect(sectionDir) {
  const abs = path.join(ROOT, sectionDir);
  if (!fs.existsSync(abs)) {
    console.warn(`[warn] раздел отсутствует, пропускаю: ${sectionDir}`);
    return [];
  }
  const files = [];
  for (const name of fs.readdirSync(abs).sort()) {
    const full = path.join(abs, name);
    const stat = fs.statSync(full);
    if (stat.isDirectory()) continue; // верхний уровень only — /en/ и прочие подпапки пропускаем
    if (!name.endsWith(".md")) continue;
    if (name.toLowerCase() === "readme.md") continue;
    files.push(path.posix.join(sectionDir, name));
  }
  return files;
}

/** relpath (standard/00-introduction.md) → канонический /docs/ URL. */
function docsUrl(relpath) {
  const noExt = relpath.replace(/\.md$/, "");
  return `${BASE}/docs/${noExt}/`;
}

function main() {
  const parts = [HEADER];
  let count = 0;

  for (const section of SECTIONS) {
    for (const rel of collect(section)) {
      const body = fs.readFileSync(path.join(ROOT, rel), "utf8").trim();
      parts.push(
        `\n\n---\n\n# Источник: ${rel}\n# URL: ${docsUrl(rel)}\n\n${body}`
      );
      count++;
    }
  }

  if (count === 0) {
    console.error("[error] не найдено ни одного исходного файла — вывод не записан");
    process.exit(1);
  }

  // \n завершение для аккуратного diff; LF для кросс-платформенной идемпотентности.
  const out = parts.join("") + "\n";
  fs.writeFileSync(OUT, out, "utf8");
  const kb = (Buffer.byteLength(out, "utf8") / 1024).toFixed(1);
  console.log(`[ok] llms-full.txt: ${count} файлов, ${kb} КБ → ${path.relative(ROOT, OUT)}`);
}

main();
