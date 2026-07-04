#!/usr/bin/env node
/**
 * check-implements-edge.js — нормативный валидатор поля BR.implements[] (см. ADR-001).
 *
 * Нормирует:
 *   - target BR с указанным `id + scope.system` существует
 *   - target BR в статусе `approved` или выше на момент approve данного BR
 *   - цепочка implements не образует циклов
 *   - implements — массив (не parent-edge); §6.8.3 неприменим к BR
 *   - deprecated target → warning (не fatal); cascade-warning
 *
 * Режимы:
 *   - default: валидирует все *.md с `type: BR` в frontmatter под --br-dir (или .)
 *   - --self-test: запускает встроенные green + red test fixtures (для check:all)
 *
 * Usage:
 *   node scripts/check-implements-edge.js [--quiet] [--br-dir <dir>]
 *   node scripts/check-implements-edge.js --self-test
 *
 * Exit 0 — clean (default mode) или все expectations passed (self-test).
 * Exit 1 — leaks (default mode) или expectation failed (self-test).
 */

import { readFileSync, readdirSync, statSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2);
const QUIET = argv.includes("--quiet");
const SELF_TEST = argv.includes("--self-test");
const brDirIdx = argv.indexOf("--br-dir");
const brDir = brDirIdx !== -1 ? argv[brDirIdx + 1] : null;

// ──────────────────────────────────────────────────────────────────
// YAML frontmatter parser (минимальный — только nesting + arrays нужного формата)
// ──────────────────────────────────────────────────────────────────
function parseFrontmatter(text) {
  const lines = text.split(/\r?\n/);
  if (lines[0] !== "---") return null;
  const closeIdx = lines.indexOf("---", 1);
  if (closeIdx === -1) return null;
  const fm = {};
  let i = 1;
  while (i < closeIdx) {
    const line = lines[i];
    // top-level key: value
    let m = line.match(/^([a-z_][a-z0-9_-]*):\s*(.*)$/i);
    if (m) {
      const key = m[1];
      const rawVal = m[2].trim();
      if (rawVal === "" || rawVal === null) {
        // possible array or nested object — read indented children
        const children = [];
        let j = i + 1;
        let nestedObj = null;
        while (j < closeIdx) {
          const child = lines[j];
          if (/^[a-z_]/i.test(child)) break;          // back to top-level
          if (/^\s{2}-\s/.test(child)) {              // array item: "  - "
            const item = {};
            // parse "  - id: BR-NN"
            const headMatch = child.match(/^\s{2}-\s+([a-z_][a-z0-9_-]*):\s*(.*)$/i);
            if (headMatch) item[headMatch[1]] = stripQuotes(headMatch[2].trim());
            // continuation lines: "    key: val" until next "  - " or unindent
            let k = j + 1;
            while (k < closeIdx) {
              const cont = lines[k];
              if (/^\s{2}-\s/.test(cont)) break;
              if (/^\s{4,}[a-z_]/i.test(cont)) {
                const contM = cont.match(/^\s+([a-z_][a-z0-9_-]*):\s*(.*)$/i);
                if (contM) item[contM[1]] = stripQuotes(contM[2].trim());
                k++;
              } else if (/^\s{6,}[a-z_]/i.test(cont)) {
                k++;
              } else {
                break;
              }
            }
            children.push(item);
            j = k;
            continue;
          }
          if (/^\s{2}[a-z_]/i.test(child)) {
            if (!nestedObj) nestedObj = {};
            const objM = child.match(/^\s{2}([a-z_][a-z0-9_-]*):\s*(.*)$/i);
            if (objM) nestedObj[objM[1]] = stripQuotes(objM[2].trim());
            j++;
            continue;
          }
          j++;
        }
        fm[key] = children.length > 0 ? children : (nestedObj || rawVal);
        i = j;
        continue;
      }
      fm[key] = stripQuotes(rawVal);
    }
    i++;
  }
  return fm;
}

function stripQuotes(s) {
  if (!s) return s;
  return s.replace(/^["'](.*)["']$/, "$1");
}

// ──────────────────────────────────────────────────────────────────
// Validation rules
// ──────────────────────────────────────────────────────────────────
function validate(brIndex) {
  // brIndex: { "<system>/<id>": {id, status, level, scope, implements: [{id, system}], file} }
  const problems = [];
  const warnings = [];

  for (const [key, br] of Object.entries(brIndex)) {
    if (!Array.isArray(br.implements) || br.implements.length === 0) continue;

    // Rule: implements not allowed on level=system (only subsystem BR ссылается на system BR)
    if (br.level === "system" && br.implements.length > 0) {
      problems.push(`${br.file}: BR ${br.id} (level=system) не может иметь implements[]; implements допустим только для level=subsystem`);
    }

    // Rule: each target exists
    for (const target of br.implements) {
      const targetSystem = (target.scope && target.scope.system) || target.system;
      if (!target.id) {
        problems.push(`${br.file}: BR ${br.id} implements[] item без id`);
        continue;
      }
      if (!targetSystem) {
        problems.push(`${br.file}: BR ${br.id} implements[] item ${target.id} без scope.system`);
        continue;
      }
      const targetKey = `${targetSystem}/${target.id}`;
      const targetBR = brIndex[targetKey];
      if (!targetBR) {
        problems.push(`${br.file}: BR ${br.id} implements[] ссылается на несуществующий ${targetKey}`);
        continue;
      }
      // Rule: target должен быть approved+ если этот BR approved+. Deprecated — warning, не fatal.
      const approvedStatuses = ["approved", "verified"];
      const isThisApproved = approvedStatuses.includes(br.status);
      if (targetBR.status === "deprecated") {
        warnings.push(`${br.file}: BR ${br.id} implements deprecated target ${targetKey}`);
      } else if (isThisApproved && !approvedStatuses.includes(targetBR.status)) {
        problems.push(`${br.file}: BR ${br.id} (${br.status}) implements target ${targetKey} в статусе ${targetBR.status} (требуется approved+)`);
      }
    }
  }

  // Rule: cycle detection (DFS)
  const visited = new Set();
  const inStack = new Set();
  function dfs(key, path) {
    if (inStack.has(key)) {
      problems.push(`cycle detected: ${[...path, key].join(" → ")}`);
      return;
    }
    if (visited.has(key)) return;
    visited.add(key);
    inStack.add(key);
    const br = brIndex[key];
    if (br && Array.isArray(br.implements)) {
      for (const t of br.implements) {
        const ts = (t.scope && t.scope.system) || t.system;
        if (!ts || !t.id) continue;
        dfs(`${ts}/${t.id}`, [...path, key]);
      }
    }
    inStack.delete(key);
  }
  for (const key of Object.keys(brIndex)) dfs(key, []);

  return { problems, warnings };
}

// ──────────────────────────────────────────────────────────────────
// File discovery (default mode)
// ──────────────────────────────────────────────────────────────────
function listBRFiles(dir) {
  const out = [];
  let entries;
  try { entries = readdirSync(dir); } catch { return out; }
  for (const entry of entries) {
    const full = join(dir, entry);
    let stat;
    try { stat = statSync(full); } catch { continue; }
    if (stat.isDirectory()) {
      if (entry.startsWith(".") || entry === "node_modules") continue;
      out.push(...listBRFiles(full));
    } else if (entry.endsWith(".md")) {
      const text = readFileSync(full, "utf8");
      if (/^type:\s*BR\s*$/m.test(text.split("---")[1] || "")) {
        out.push(full);
      }
    }
  }
  return out;
}

function buildIndexFromFiles(files) {
  const idx = {};
  for (const f of files) {
    const fm = parseFrontmatter(readFileSync(f, "utf8"));
    if (!fm || fm.type !== "BR") continue;
    const sys = fm.scope && fm.scope.system;
    if (!sys || !fm.id) continue;
    idx[`${sys}/${fm.id}`] = {
      id: fm.id,
      status: fm.status,
      level: fm.level,
      scope: fm.scope,
      implements: Array.isArray(fm.implements) ? fm.implements : [],
      file: f,
    };
  }
  return idx;
}

// ──────────────────────────────────────────────────────────────────
// Self-test fixtures (green + red)
// ──────────────────────────────────────────────────────────────────
function runSelfTest() {
  const cases = [
    {
      name: "green: subsystem implements approved system BR",
      shouldFail: false,
      brs: {
        "acme/BR-01": { id: "BR-01", status: "approved", level: "system", scope: { system: "acme" }, implements: [], file: "<test:green-1-system>" },
        "acme.notify/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "acme", subsystem: "acme.notify" }, implements: [{ id: "BR-01", scope: { system: "acme" } }], file: "<test:green-1-subsystem>" },
      },
    },
    {
      name: "green: subsystem implements multiple system BRs",
      shouldFail: false,
      brs: {
        "sys/BR-01": { id: "BR-01", status: "approved", level: "system", scope: { system: "sys" }, implements: [], file: "<test:green-2-s1>" },
        "sys/BR-05": { id: "BR-05", status: "approved", level: "system", scope: { system: "sys" }, implements: [], file: "<test:green-2-s2>" },
        "sys.store/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "sys", subsystem: "sys.store" }, implements: [{ id: "BR-01", scope: { system: "sys" } }, { id: "BR-05", scope: { system: "sys" } }], file: "<test:green-2-sub>" },
      },
    },
    {
      name: "red: orphan implements (target не существует)",
      shouldFail: true,
      expectErrorContains: "несуществующий",
      brs: {
        "sys.notify/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "sys", subsystem: "sys.notify" }, implements: [{ id: "BR-99", scope: { system: "sys" } }], file: "<test:red-orphan>" },
      },
    },
    {
      name: "red: cycle BR-A.implements=BR-B AND BR-B.implements=BR-A",
      shouldFail: true,
      expectErrorContains: "cycle",
      brs: {
        "x.a/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "x", subsystem: "x.a" }, implements: [{ id: "BR-01", scope: { system: "x.b" } }], file: "<test:red-cycle-a>" },
        "x.b/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "x.b", subsystem: "x.b" }, implements: [{ id: "BR-01", scope: { system: "x.a" } }], file: "<test:red-cycle-b>" },
      },
    },
    {
      name: "red: target в draft (требуется approved+)",
      shouldFail: true,
      expectErrorContains: "draft",
      brs: {
        "sys/BR-01": { id: "BR-01", status: "draft", level: "system", scope: { system: "sys" }, implements: [], file: "<test:red-draft-target>" },
        "sys.x/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "sys", subsystem: "sys.x" }, implements: [{ id: "BR-01", scope: { system: "sys" } }], file: "<test:red-draft-subsystem>" },
      },
    },
    {
      name: "warning (not fatal): deprecated target",
      shouldFail: false,
      expectWarningContains: "deprecated",
      brs: {
        "sys/BR-01": { id: "BR-01", status: "deprecated", level: "system", scope: { system: "sys" }, implements: [], file: "<test:warn-dep-target>" },
        "sys.x/BR-01": { id: "BR-01", status: "approved", level: "subsystem", scope: { system: "sys", subsystem: "sys.x" }, implements: [{ id: "BR-01", scope: { system: "sys" } }], file: "<test:warn-dep-subsystem>" },
      },
    },
    {
      name: "red: implements на level=system (только subsystem допустим)",
      shouldFail: true,
      expectErrorContains: "level=system",
      brs: {
        "a/BR-01": { id: "BR-01", status: "approved", level: "system", scope: { system: "a" }, implements: [], file: "<test:a>" },
        "b/BR-01": { id: "BR-01", status: "approved", level: "system", scope: { system: "b" }, implements: [{ id: "BR-01", scope: { system: "a" } }], file: "<test:red-system-implements>" },
      },
    },
  ];

  let failures = 0;
  for (const c of cases) {
    const { problems, warnings } = validate(c.brs);
    const hasError = problems.length > 0;
    const ok = hasError === c.shouldFail;
    if (!ok) {
      failures++;
      console.error(`  FAIL: ${c.name}`);
      console.error(`        expected shouldFail=${c.shouldFail}, got problems=${problems.length} warnings=${warnings.length}`);
      if (problems.length) console.error(`        problems: ${problems.join(" | ")}`);
      continue;
    }
    if (c.expectErrorContains && !problems.some((p) => p.includes(c.expectErrorContains))) {
      failures++;
      console.error(`  FAIL: ${c.name}`);
      console.error(`        expected error containing "${c.expectErrorContains}", got: ${problems.join(" | ")}`);
      continue;
    }
    if (c.expectWarningContains && !warnings.some((w) => w.includes(c.expectWarningContains))) {
      failures++;
      console.error(`  FAIL: ${c.name}`);
      console.error(`        expected warning containing "${c.expectWarningContains}", got: ${warnings.join(" | ")}`);
      continue;
    }
    if (!QUIET) console.log(`  PASS: ${c.name}`);
  }

  if (failures > 0) {
    console.error(`\ncheck-implements-edge --self-test: ${failures}/${cases.length} FAIL`);
    process.exit(1);
  }
  if (!QUIET) console.log(`\ncheck-implements-edge --self-test: ${cases.length} cases PASS`);
  process.exit(0);
}

// ──────────────────────────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────────────────────────
if (SELF_TEST) {
  runSelfTest();
} else {
  const root = brDir || join(__dirname, "..");
  if (!existsSync(root)) {
    console.error(`directory does not exist: ${root}`);
    process.exit(1);
  }
  const files = listBRFiles(root);
  if (files.length === 0) {
    if (!QUIET) console.log("check-implements-edge: no BR files (type: BR) found — nothing to validate. Use --self-test to run built-in fixtures.");
    process.exit(0);
  }
  const idx = buildIndexFromFiles(files);
  const { problems, warnings } = validate(idx);
  if (warnings.length && !QUIET) {
    console.warn(`check-implements-edge: ${warnings.length} warnings:`);
    for (const w of warnings) console.warn(`  ${w}`);
  }
  if (problems.length) {
    console.error(`check-implements-edge: ${problems.length} problems:`);
    for (const p of problems) console.error(`  ${p}`);
    process.exit(1);
  }
  if (!QUIET) console.log(`check-implements-edge: ${files.length} BR files checked, 0 problems`);
  process.exit(0);
}
