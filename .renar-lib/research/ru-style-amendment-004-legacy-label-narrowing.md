---
title: "RU Style Amendment 004: legacy-label checker citation narrowing"
status: proposed
phase: "Phase 2.x amendment"
epic: ru-normative-pass-v1
task: ru-legacy-label-sweep-amendment-004
draft-date: 2026-05-20
target-section: "§1.13.1.7 + §4.3 of reference/06-ru-style-guide.md"
lang: ru
---

# RU Style Amendment 004: legacy-label checker citation narrowing

## Rationale

§1.13.1.7 (Legacy labels F1) предписывает grep `UIC|AIC|INT-SR|INT-TC|TM|TS` с «flag every occurrence». `scripts/style-guide-check.js` v0.1.0 реализовал это буквально и производил **57 legacy findings**. Классификация всех 57 (task `ru-legacy-label-sweep-amendment-004`, Session #23):

- **~39 legitimate citations** — false positives. Корпус *обязан* называть legacy labels, чтобы документировать миграцию:
  - `standard/06 §6.2.3` — «не являются типами оси требований в v1.0» + legacy→canonical mapping table.
  - `standard/08 §8.7` — целая глава «Migration UIC / AIC / INT-SR / TS → SPEC-*».
  - legacy→canonical mapping rows (legacy label + canonical replacement на одной строке).
  - deprecation prose в `guide/05` («устаревший термин, заменён»), `reference/05` («заменено SPEC-INT»), `glossary §5.1/§5.2` («deprecated», «removed»), `glossary §3.x` («(legacy)» column).
- **~18 genuine misuse** — incomplete Phase 1.5 glossary reconciliation. `reference/01-glossary.md §5.2` заявил, что §2.1 canonical table очищена, но §2.5 (source col), §2.9 (TC «Проверка UIC/AIC/INT-SR»), §2.10 (`BR → SR → TM`), §2.11 (file-naming rows для UIC/AIC/INT-SR/INT-TC) всё ещё несли legacy labels как current types. Плюс `standard/08`, `standard/09`, `reference/05` точечно.

Это тот же класс проблемы, что amendment 003 решил для QG names: grep слишком широк и ловит canonical mapping/citation контексты как нарушения.

## Proposed change

### Delta 1 — §1.13.1.7 narrowing rule

Legacy-label check flags occurrence **только как current-term misuse**. Citation contexts НЕ flagged:

1. **mapping row** — legacy label + его canonical replacement на одной строке (`UIC`+`SPEC-UI`, `AIC`+`SPEC-AI`, `INT-SR`+`SPEC-INT`, `INT-TC`+`tc-type`, `TM`+`level: module`, `TS`+`SPEC-ARCH|OPS|DATA|…`).
2. **deprecation/migration marker** на строке — `устаревш|историческ|legacy|deprecated|reconcil|миграц|migration|замен|pre-v1.0|traceabilit|removed|стар*`.
3. **section heading** с migration/legacy marker — suppresses до следующего same-or-shallower heading (level-inheritance: subsections наследуют контекст родителя, e.g. `§8.7.1 Mapping таблица` под `§8.7 Migration`).

Backticked IDs (`` `UIC-NN` ``) уже stripped как inline code (pre-existing behaviour).

### Delta 2 — scripts/style-guide-check.js v0.1.0 → v0.2.0

`checkLegacy` rewritten citation-aware: `LEGACY_CITATION_MARKER`, `LEGACY_SECTION_MARKER`, `LEGACY_CANONICAL` (mapping-row map), heading-level inheritance.

**Over-suppression guard:** temp probe с 6 bare legacy labels (no marker, no canonical pairing, non-citation heading) → все 6 flagged. Narrowing подавляет citations, не genuine misuse.

### Delta 3 — corpus genuine-misuse sweep

`reference/01-glossary.md` §2.5/§2.9/§2.10/§2.11/§4 (§2.11 file-naming → canonical SPEC-UI `specs/ui/`, SPEC-AI `specs/ai/`, SPEC-INT `specs/int/`; INT-TC row removed — covered by generic TC), `standard/08` §8.x spec-TC, `standard/09` verify table, `reference/05` KG queries/nodes. Decision (user, Session #23): «Convert to canonical per §8.7».

### Delta 4 — ascii-quote

`guide/08-developer-guide.md` — `"зачем…"` → `«зачем…»` (§3.10.1.6).

## Impact

- legacy findings **57 → 0**; ascii-quote **1 → 0**.
- style-guide-check baseline теперь bucket-a advisory only (115, pending §1.3 case-policy).
- Frontmatter `version: "1.1.1"` → `"1.1.2"` (patch).

## Out of scope

- bucket-a 115 advisory findings — отдельный §1.3 case-policy вопрос.
- §2.11 generic SPEC row uses flat `specs/SPEC-<KIND>-NN` while §8.7 + converted rows use `specs/<type>/` subdirs — pre-existing inconsistency, отдельный cleanup.
