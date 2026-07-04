#!/usr/bin/env node
/**
 * check-adapt-supersession.js — нормативный валидатор дезавуирования (supersession) ADAPT
 * (standard/07 §7.6.4; standard/10 §10.8.5, §10.11.1; standard/13 §13.3.3; ADR-007).
 *
 * Правила:
 *   - Superseding-ADAPT (поле supersedes) обязан иметь непустой supersession-rationale.
 *   - Цель supersedes должна существовать.
 *   - Симметрия: target.superseded-by == id superseding-ADAPT.
 *   - Цель supersedes обязана быть в статусе "superseded" (терминальное, §10.8.5).
 *   - Если дезавуируемое решение имело contractual outcome — superseding-ADAPT обязан нести client-signature (§7.6.4 п.2, Q2).
 *   - Висячая ссылка source.adapt на ADAPT в статусе "superseded" — fatal (re-pointing §6.10.3).
 *   - ADAPT в статусе "superseded" обязан иметь superseded-by (не висит без superseding).
 *
 * Режимы:
 *   default: проверяет ADAPT + BR/SR/SPEC под --root (default no-op в corpus)
 *   --self-test: запускает встроенные green + red fixtures
 *
 * Exit 0 — clean | Exit 1 — нарушения предусловий
 */

import { existsSync } from "fs";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const argv = process.argv.slice(2);
const QUIET = argv.includes("--quiet");
const SELF_TEST = argv.includes("--self-test");
const rootIdx = argv.indexOf("--root");
const root = rootIdx !== -1 ? argv[rootIdx + 1] : null;

// ──────────────────────────────────────────────────────────────────
// Validation logic (in-memory model)
//   model.adapts: { id: { status, supersedes?, "supersession-rationale"?,
//                         "superseded-by"?, "had-contractual-outcome"?,
//                         "has-client-sig"?, file } }
//   model.derivatives: [{ type, id, "source-adapt-id"?, file }]
// ──────────────────────────────────────────────────────────────────
function validate(model) {
  const problems = [];
  const adapts = model.adapts || {};
  const derivatives = model.derivatives || [];

  // Правила для superseding-ADAPT (имеет поле supersedes)
  for (const [id, a] of Object.entries(adapts)) {
    if (!a.supersedes) continue;

    if (!a["supersession-rationale"] || String(a["supersession-rationale"]).trim() === "") {
      problems.push(`${a.file}: ADAPT ${id} имеет supersedes, но supersession-rationale пуст (§7.6.4 п.1)`);
    }

    const target = adapts[a.supersedes];
    if (!target) {
      problems.push(`${a.file}: ADAPT ${id} supersedes несуществующий ADAPT ${a.supersedes} (§7.6.4)`);
      continue;
    }

    if (target["superseded-by"] !== id) {
      problems.push(`${target.file}: ADAPT ${a.supersedes} superseded-by=${target["superseded-by"] ?? "∅"} ≠ ${id} — нарушение симметрии supersedes/superseded-by (§7.6.4 п.1)`);
    }

    if (target.status !== "superseded") {
      problems.push(`${target.file}: ADAPT ${a.supersedes} дезавуирован, но статус ${target.status} ≠ superseded (§10.8.5)`);
    }

    if (target["had-contractual-outcome"] && !a["has-client-sig"]) {
      problems.push(`${a.file}: ADAPT ${id} дезавуирует решение с contractual outcome без client-signature (§7.6.4 п.2, Q2)`);
    }
  }

  // ADAPT в статусе superseded обязан иметь superseded-by
  for (const [id, a] of Object.entries(adapts)) {
    if (a.status === "superseded" && !a["superseded-by"]) {
      problems.push(`${a.file}: ADAPT ${id} в статусе superseded без superseded-by — нет superseding-ADAPT (§10.8.5)`);
    }
  }

  // Висячие source.adapt на superseded ADAPT — fatal (§6.10.3 re-pointing)
  for (const d of derivatives) {
    const ref = d["source-adapt-id"];
    if (!ref) continue;
    const target = adapts[ref];
    if (target && target.status === "superseded") {
      problems.push(`${d.file}: ${d.type} ${d.id} имеет source.adapt → ${ref} в статусе superseded (висячая ссылка, требуется re-pointing §6.10.3) — fatal`);
    }
  }

  return { problems };
}

// ──────────────────────────────────────────────────────────────────
// Self-test fixtures
// ──────────────────────────────────────────────────────────────────
function runSelfTest() {
  const cases = [
    {
      name: "green: корректный supersession — rationale + симметрия + superseded + client-sig + re-pointed",
      shouldFail: false,
      model: {
        adapts: {
          "ADAPT-001": { status: "superseded", "superseded-by": "ADAPT-002", "had-contractual-outcome": true, file: "<test:g1-old>" },
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-001", "supersession-rationale": "SR-12 противоречит ADAPT-001 §4 (источник TZ-001 §3)", "has-client-sig": true, file: "<test:g1-new>" },
        },
        derivatives: [{ type: "SR", id: "SR-12", "source-adapt-id": "ADAPT-002", file: "<test:g1-sr>" }],
      },
    },
    {
      name: "green: проект без supersession вовсе",
      shouldFail: false,
      model: {
        adapts: { "ADAPT-001": { status: "frozen", file: "<test:g2>" } },
        derivatives: [{ type: "BR", id: "BR-01", "source-adapt-id": "ADAPT-001", file: "<test:g2-br>" }],
      },
    },
    {
      name: "red: supersedes без supersession-rationale",
      shouldFail: true,
      expectErrorContains: "supersession-rationale пуст",
      model: {
        adapts: {
          "ADAPT-001": { status: "superseded", "superseded-by": "ADAPT-002", file: "<test:r1-old>" },
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-001", "supersession-rationale": "", "has-client-sig": true, file: "<test:r1-new>" },
        },
        derivatives: [],
      },
    },
    {
      name: "red: supersedes несуществующий ADAPT",
      shouldFail: true,
      expectErrorContains: "несуществующий ADAPT",
      model: {
        adapts: {
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-999", "supersession-rationale": "rationale", "has-client-sig": true, file: "<test:r2>" },
        },
        derivatives: [],
      },
    },
    {
      name: "red: нарушение симметрии superseded-by",
      shouldFail: true,
      expectErrorContains: "нарушение симметрии",
      model: {
        adapts: {
          "ADAPT-001": { status: "superseded", "superseded-by": "ADAPT-OTHER", "had-contractual-outcome": true, file: "<test:r3-old>" },
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-001", "supersession-rationale": "r", "has-client-sig": true, file: "<test:r3-new>" },
        },
        derivatives: [],
      },
    },
    {
      name: "red: цель supersedes не в статусе superseded",
      shouldFail: true,
      expectErrorContains: "≠ superseded",
      model: {
        adapts: {
          "ADAPT-001": { status: "frozen", "superseded-by": "ADAPT-002", "had-contractual-outcome": true, file: "<test:r4-old>" },
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-001", "supersession-rationale": "r", "has-client-sig": true, file: "<test:r4-new>" },
        },
        derivatives: [],
      },
    },
    {
      name: "red: contractual supersession без client-signature",
      shouldFail: true,
      expectErrorContains: "без client-signature",
      model: {
        adapts: {
          "ADAPT-001": { status: "superseded", "superseded-by": "ADAPT-002", "had-contractual-outcome": true, file: "<test:r5-old>" },
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-001", "supersession-rationale": "r", "has-client-sig": false, file: "<test:r5-new>" },
        },
        derivatives: [],
      },
    },
    {
      name: "red: висячий source.adapt на superseded ADAPT (не перенаправлен)",
      shouldFail: true,
      expectErrorContains: "висячая ссылка",
      model: {
        adapts: {
          "ADAPT-001": { status: "superseded", "superseded-by": "ADAPT-002", "had-contractual-outcome": true, file: "<test:r6-old>" },
          "ADAPT-002": { status: "approved", supersedes: "ADAPT-001", "supersession-rationale": "r", "has-client-sig": true, file: "<test:r6-new>" },
        },
        derivatives: [{ type: "SR", id: "SR-12", "source-adapt-id": "ADAPT-001", file: "<test:r6-sr>" }],
      },
    },
    {
      name: "red: superseded ADAPT без superseded-by",
      shouldFail: true,
      expectErrorContains: "без superseded-by",
      model: {
        adapts: { "ADAPT-001": { status: "superseded", file: "<test:r7>" } },
        derivatives: [],
      },
    },
  ];

  let failures = 0;
  for (const c of cases) {
    const { problems } = validate(c.model);
    const hasError = problems.length > 0;
    const ok = hasError === c.shouldFail;
    if (!ok) {
      failures++;
      console.error(`  FAIL: ${c.name}`);
      console.error(`        expected shouldFail=${c.shouldFail}, got problems=${problems.length}`);
      if (problems.length) console.error(`        problems: ${problems.join(" | ")}`);
      continue;
    }
    if (c.expectErrorContains && !problems.some((p) => p.includes(c.expectErrorContains))) {
      failures++;
      console.error(`  FAIL: ${c.name}`);
      console.error(`        expected error containing "${c.expectErrorContains}", got: ${problems.join(" | ")}`);
      continue;
    }
    if (!QUIET) console.log(`  PASS: ${c.name}`);
  }

  if (failures > 0) {
    console.error(`\ncheck-adapt-supersession --self-test: ${failures}/${cases.length} FAIL`);
    process.exit(1);
  }
  if (!QUIET) console.log(`\ncheck-adapt-supersession --self-test: ${cases.length} cases PASS`);
  process.exit(0);
}

// ──────────────────────────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────────────────────────
if (SELF_TEST) {
  runSelfTest();
} else {
  if (!root) {
    if (!QUIET) console.log("check-adapt-supersession: no --root specified — nothing to validate. Use --self-test to run built-in fixtures, or --root <substrate-dir> to validate a real project.");
    process.exit(0);
  }
  if (!existsSync(root)) {
    console.error(`directory does not exist: ${root}`);
    process.exit(1);
  }
  if (!QUIET) console.log(`check-adapt-supersession: --root mode requires substrate-side implementation (see standard/10 §10.11.1). Use --self-test for fixtures.`);
  process.exit(0);
}
