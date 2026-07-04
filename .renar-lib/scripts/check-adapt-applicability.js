#!/usr/bin/env node
/**
 * check-adapt-applicability.js — нормативный валидатор реактивной обязательности ADAPT
 * (standard/07 §7.4.1; standard/13 §13.3.3; ADR-006).
 *
 * Правила:
 *   - Для каждого ТЗ должен существовать verdict adversarial review.
 *   - Если verdict = "findings-present" — ADAPT должен существовать в approved+ с двойной подписью;
 *     BR/SR/SPEC производные обязаны иметь source.adapt + source.tz-section.
 *   - Если verdict = "no-findings" — ADAPT отсутствует; BR/SR/SPEC обязаны иметь
 *     source.tz-section + source.adversarial-review-ref (evidence). source.adapt запрещён.
 *   - Запрещено: BR/SR/SPEC без source.adapt И без source.adversarial-review-ref — fatal.
 *   - Запрещено: BR/SR/SPEC без source.tz-section вовсе — fatal.
 *   - Запрещено: ADAPT существует, но verdict = "no-findings" — fatal (противоречие).
 *
 * Режимы:
 *   default: проверяет ТЗ + ADAPT + BR/SR/SPEC под --root (default no-op в corpus)
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
// ──────────────────────────────────────────────────────────────────
function validate(model) {
  const problems = [];

  for (const [tzId, tz] of Object.entries(model.tzs)) {
    if (!tz["adversarial-verdict"]) {
      problems.push(`${tz.file}: TZ ${tzId} без verdict adversarial review (§7.4.1.2)`);
    }
  }

  for (const [tzId, tz] of Object.entries(model.tzs)) {
    if (tz["adversarial-verdict"] === "findings-present") {
      const matchingAdapt = Object.values(model.adapts).find((a) => a["source-tz-id"] === tzId);
      if (!matchingAdapt) {
        problems.push(`${tz.file}: TZ ${tzId} verdict «findings-present», но ADAPT не создан (§7.4.1)`);
        continue;
      }
      if (matchingAdapt.status !== "approved" && matchingAdapt.status !== "frozen") {
        problems.push(`${matchingAdapt.file}: ADAPT для TZ ${tzId} в статусе ${matchingAdapt.status} (требуется approved+)`);
      }
      if (matchingAdapt.status === "approved" && (!matchingAdapt["has-client-sig"] || !matchingAdapt["has-architect-sig"])) {
        problems.push(`${matchingAdapt.file}: ADAPT для TZ ${tzId} approved без двойной подписи (§7.5)`);
      }
    }
  }

  for (const [tzId, tz] of Object.entries(model.tzs)) {
    if (tz["adversarial-verdict"] === "no-findings") {
      const matchingAdapt = Object.values(model.adapts).find((a) => a["source-tz-id"] === tzId);
      if (matchingAdapt) {
        problems.push(`${matchingAdapt.file}: ADAPT существует, но TZ ${tzId} имеет verdict «no-findings» — противоречие (§13.3.3 negative scenario)`);
      }
    }
  }

  for (const d of model.derivatives) {
    if (!d["source-tz-section"]) {
      problems.push(`${d.file}: ${d.type} ${d.id} без source.tz-section (mandatory всегда, §7.4.1)`);
      continue;
    }
    const tzId = d["source-tz-id"];
    const tz = tzId ? model.tzs[tzId] : null;
    if (tz && tz["adversarial-verdict"] === "findings-present") {
      if (!d["source-adapt-id"]) {
        problems.push(`${d.file}: ${d.type} ${d.id} ссылается на TZ ${tzId} (verdict findings-present), но source.adapt omitted (§7.4.1.3)`);
      }
    }
    if (tz && tz["adversarial-verdict"] === "no-findings") {
      if (d["source-adapt-id"]) {
        problems.push(`${d.file}: ${d.type} ${d.id} имеет source.adapt, но TZ ${tzId} verdict «no-findings» (ADAPT не должен существовать)`);
      }
      if (!d["source-adv-ref"]) {
        problems.push(`${d.file}: ${d.type} ${d.id} ссылается на TZ ${tzId} (verdict no-findings), но source.adversarial-review-ref omitted (mandatory evidence §7.4.1.2)`);
      }
    }
    if (!d["source-adapt-id"] && !d["source-adv-ref"]) {
      problems.push(`${d.file}: ${d.type} ${d.id} без source.adapt И без source.adversarial-review-ref — невозможно определить применимость ADAPT (§7.4.1.3)`);
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
      name: "green: TZ findings-present + ADAPT approved + BR с source.adapt",
      shouldFail: false,
      model: {
        tzs: { "TZ-001": { "adversarial-verdict": "findings-present", file: "<test:green1-tz>" } },
        adapts: { "ADAPT-001": { "source-tz-id": "TZ-001", status: "approved", "has-client-sig": true, "has-architect-sig": true, file: "<test:green1-adapt>" } },
        derivatives: [{ type: "BR", id: "BR-01", "source-adapt-id": "ADAPT-001", "source-tz-id": "TZ-001", "source-tz-section": "§1", file: "<test:green1-br>" }],
      },
    },
    {
      name: "green: TZ no-findings + ADAPT не существует + BR с source.tz + adv-ref",
      shouldFail: false,
      model: {
        tzs: { "TZ-001-delta-1": { "adversarial-verdict": "no-findings", file: "<test:green2-tz>" } },
        adapts: {},
        derivatives: [{ type: "BR", id: "BR-01", "source-tz-id": "TZ-001-delta-1", "source-tz-section": "§1", "source-adv-ref": "verdict-ref-123", file: "<test:green2-br>" }],
      },
    },
    {
      name: "red: TZ findings-present но ADAPT не создан",
      shouldFail: true,
      expectErrorContains: "verdict «findings-present», но ADAPT не создан",
      model: {
        tzs: { "TZ-001": { "adversarial-verdict": "findings-present", file: "<test:red1-tz>" } },
        adapts: {},
        derivatives: [],
      },
    },
    {
      name: "red: TZ no-findings но ADAPT существует — противоречие",
      shouldFail: true,
      expectErrorContains: "verdict «no-findings» — противоречие",
      model: {
        tzs: { "TZ-001": { "adversarial-verdict": "no-findings", file: "<test:red2-tz>" } },
        adapts: { "ADAPT-001": { "source-tz-id": "TZ-001", status: "approved", "has-client-sig": true, "has-architect-sig": true, file: "<test:red2-adapt>" } },
        derivatives: [],
      },
    },
    {
      name: "red: ADAPT approved без двойной подписи",
      shouldFail: true,
      expectErrorContains: "approved без двойной подписи",
      model: {
        tzs: { "TZ-001": { "adversarial-verdict": "findings-present", file: "<test:red3-tz>" } },
        adapts: { "ADAPT-001": { "source-tz-id": "TZ-001", status: "approved", "has-client-sig": false, "has-architect-sig": true, file: "<test:red3-adapt>" } },
        derivatives: [],
      },
    },
    {
      name: "red: BR без source.tz-section",
      shouldFail: true,
      expectErrorContains: "без source.tz-section",
      model: {
        tzs: { "TZ-001": { "adversarial-verdict": "findings-present", file: "<test:red4-tz>" } },
        adapts: { "ADAPT-001": { "source-tz-id": "TZ-001", status: "approved", "has-client-sig": true, "has-architect-sig": true, file: "<test:red4-adapt>" } },
        derivatives: [{ type: "BR", id: "BR-01", "source-adapt-id": "ADAPT-001", "source-tz-id": "TZ-001", file: "<test:red4-br>" }],
      },
    },
    {
      name: "red: BR ссылается на TZ no-findings без source.adv-ref",
      shouldFail: true,
      expectErrorContains: "source.adversarial-review-ref omitted",
      model: {
        tzs: { "TZ-001-delta-1": { "adversarial-verdict": "no-findings", file: "<test:red5-tz>" } },
        adapts: {},
        derivatives: [{ type: "BR", id: "BR-01", "source-tz-id": "TZ-001-delta-1", "source-tz-section": "§1", file: "<test:red5-br>" }],
      },
    },
    {
      name: "red: BR имеет source.adapt но TZ verdict no-findings",
      shouldFail: true,
      expectErrorContains: "source.adapt, но TZ",
      model: {
        tzs: { "TZ-001-delta-1": { "adversarial-verdict": "no-findings", file: "<test:red6-tz>" } },
        adapts: {},
        derivatives: [{ type: "BR", id: "BR-01", "source-adapt-id": "ADAPT-fake", "source-tz-id": "TZ-001-delta-1", "source-tz-section": "§1", "source-adv-ref": "ref", file: "<test:red6-br>" }],
      },
    },
    {
      name: "red: ТЗ без verdict вовсе",
      shouldFail: true,
      expectErrorContains: "без verdict adversarial review",
      model: {
        tzs: { "TZ-001": { file: "<test:red7-tz>" } },
        adapts: {},
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
    console.error(`\ncheck-adapt-applicability --self-test: ${failures}/${cases.length} FAIL`);
    process.exit(1);
  }
  if (!QUIET) console.log(`\ncheck-adapt-applicability --self-test: ${cases.length} cases PASS`);
  process.exit(0);
}

// ──────────────────────────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────────────────────────
if (SELF_TEST) {
  runSelfTest();
} else {
  if (!root) {
    if (!QUIET) console.log("check-adapt-applicability: no --root specified — nothing to validate. Use --self-test to run built-in fixtures, or --root <substrate-dir> to validate a real project.");
    process.exit(0);
  }
  if (!existsSync(root)) {
    console.error(`directory does not exist: ${root}`);
    process.exit(1);
  }
  if (!QUIET) console.log(`check-adapt-applicability: --root mode requires substrate-side implementation (see standard/10 §10.11.1). Use --self-test for fixtures.`);
  process.exit(0);
}
