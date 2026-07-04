---
title: "RU Style Amendment 001: Bucket A/C fallback resolution"
status: proposed
phase: "Phase 2.x amendment"
epic: ru-normative-pass-v1
task: ru-style-amendment-001-fallback
draft-date: 2026-05-19
target-section: "§1.3.1 + §1.5.1 of reference/06-ru-style-guide.md"
lang: ru
---

# RU Style Amendment 001: Bucket A/C fallback resolution

## Rationale

Style Guide v1.0 классифицирует термин `fallback` в **двух взаимоисключающих bucket'ах** одновременно:

- **§1.5.1 Bucket C** (organisational vocabulary, rewrite в prose): `fallback` → «отступление / запасной вариант».
- **§1.8 Bucket F triage** (anti-pattern table, low-confidence row): `фолбэк` → "Keep `fallback` (Bucket A) — don't translit".

§1.8 явно ссылается на Bucket A, но §1.3.1 Bucket A whitelist термин `fallback` **не содержит**. Phase 5 chapter pass получает противоречивые сигналы.

### Corpus reality (нормативный корпус — `standard/`, `guide/`, `reference/`, `core/`)

Все 5 instances `fallback` — substrate-domain technical usage:

| File | Контекст |
|---|---|
| `standard/12-maturity-model.md:207` | «full-text search — fallback» (search-strategy degradation pattern) |
| `standard/08-specifications.md:226` | «pipeline / orchestration / fallback» (AI-spec architecture) |
| `reference/02-schemas.md:276` | YAML field `fallback: "queue + retry; ..."` (always-latin per §1.5.1 exception) |
| `reference/06-ru-style-guide.md:957` | meta-mention о MVR table semantics |
| `reference/01-glossary.md:147` | «fallback policy» (SPEC-AI glossary entry) |

RU-проекция «отступление / запасной вариант» в нормативном корпусе **0 раз**. Bucket C classification — paper-only, не отражает фактическое использование.

### Substrate-domain критерий

§1.3.2 Cross-bucket extension явно разрешает добавление substrate-domain identifiers в Bucket A. `fallback` — SE / distributed-systems / AI-ops pattern (failure-mode redirect mechanism). Соответствует criterion «substrate / VCS / SE tooling».

## Proposed change

### Delta 1 — §1.3.1 Bucket A whitelist (extend)

Добавить строку в таблицу `#### §1.3.1 Whitelist (closed list)` (после `provenance`):

```diff
 | `substrate` | RENAR | (no UI projection; canonical) |
 | `provenance` | RENAR | происхождение |
+| `fallback` | SE / RENAR ops | запасной вариант |
```

### Delta 2 — §1.5.1 Bucket C table (remove)

Удалить строку `fallback` из таблицы `#### §1.5.1 Replacement table`:

```diff
 | `rollback` | откат | — |
-| `fallback` | отступление / запасной вариант | — |
 | `override` | переопределение | — |
```

### Delta 3 — Frontmatter version bump

```diff
-version: "1.0"
+version: "1.0.1"
```

### Delta 4 — §5 Change history (insert §5.1.1)

Добавить sub-entry под `### §5.1 v1.0` с записью v1.0.1 patch (amendment 001 record).

## Pilot impact

- **Affected chapters (Phase 5 retroactive scan):** 0 — corpus уже использует latin `fallback` во всех 5 instances; Bucket C row была paper-only.
- **Re-pass tasks:** не требуется. §5.3 классифицирует это как **Patch** (clarification, no retroactive Phase 5 scan).

## Migration plan

Не требуется (retroactive scan не применим — corpus уже compliant).
