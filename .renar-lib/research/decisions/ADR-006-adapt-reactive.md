---
adr: 006
title: ADAPT-reactive — revert на буквальную альт. B (партнёрский пушбэк)
status: accepted
date: 2026-05-26
supersedes: ADR-002
context-gap: GAP-02 (GitLab Issue #2, reporter vsoglaev, comment 17:15 UTC)
affects:
  - standard/00-introduction.md §0.5.1 (MVR-3)
  - standard/01-scope.md §1.4.1 (признак 3)
  - standard/06-requirements-hierarchy.md §6.5.2, §6.6.2, §6.7.2, §6.10.3
  - standard/07-adapt.md §7.4.1, §7.4.5, §7.6, §7.8.1, §7.8.2, §7.12
  - standard/08-specifications.md §8.5 (SPEC common)
  - standard/10-lifecycle-qg.md §10.11.1
  - standard/13-conformance.md §13.3.3
  - reference/02-schemas.md §1 (common), §2 (BR), §3 (SR), §5 (SPEC common), §7 (ADAPT)
  - scripts/check-adapt-mode.js → scripts/check-adapt-applicability.js
version-impact: minor-version bump v1.1-draft → v1.2-draft (formal MVR-3 reformulation через §13.9)
implements-tasks:
  - adr-006-adapt-reactive
  - adapt-7-4-1-rewrite
  - adapt-schema-simplify
  - source-fields-conditional
  - trace-chain-two-paths
  - mvr3-13-3-3-1-4-1-rewrite
  - adapt-gate-rewrite
  - adapt-7-12-strengthen
---

# ADR-006: ADAPT-reactive — revert на буквальную альт. B

## Контекст

Партнёр (vsoglaev) в GitLab Issue #2, comment 17:15 UTC, отверг компромисс ADR-002 (альт. C — ADAPT-full vs ADAPT-light):

> *ADAPT в том виде, который сейчас есть требуется обязательного взаимодействия с клиентом по уточнению после подписанного уже ТЗ. Любое взаимодействие с клиентом — это затратная операция. Поэтому лишние взаимодействия не приветствуются.*
>
> *Зачем нам подписание ADAPT, если после конвертации ТЗ в документы RENAR не возникает неясностей?*
>
> *Возьмем инкрементное ТЗ. В котором требуется, например, просто исправить название поля на форме. Для чего при таком ТЗ ещё подписывать ADAPT? Типа: «правильно ли я понял, что нужно исправить название поля на форме?»*

Партнёрский аргумент: ADAPT-light всё равно требует Forward-блока + architect-signature — это >0 overhead на artifact, который не несёт ценности когда конвертация ТЗ→RENAR однозначна.

Контр-аргументы ADR-002 (non-uniform trace chain; «ADAPT как audit-anchor»; принцип uniform structure) — приняты партнёром как **недостаточно весомые** относительно практической ценности отсутствия лишнего artifact.

## Решение

Принимается **буквальная альт. B**: ADAPT создаётся **реактивно** — только когда конвертация ТЗ → RENAR порождает backward findings или требует client согласования (term mapping clarification, scope clarification). В иных случаях ADAPT не создаётся; BR/SR/SPEC выводятся напрямую из ТЗ через mandatory поле `source.tz-section`.

ADR-002 переводится в статус `superseded`.

### Новые нормативные правила

#### 1. Реактивная обязательность ADAPT (§7.4.1)

ADAPT обязателен **тогда и только тогда**, когда хотя бы одно из условий выполнено:

- При конвертации ТЗ → RENAR обнаружена ≥1 backward finding по любой из 7 категорий §7.4.4 (`contradiction`, `gap`, `hidden-assumption`, `feasibility`, `regulatory`, `terminology`, `scope`).
- Конвертация требует term mapping clarification (новые термины, не имеющие однозначной инженерной интерпретации).
- Конвертация требует scope clarification (границы работ неясны из ТЗ).

Если ни одно условие не выполнено — ADAPT не создаётся. BR/SR/SPEC ссылаются на ТЗ напрямую через `source.tz-section`.

#### 2. Уровень enforcement

Adversarial reviewer (§7.10.2, §9.4) — обязательный шаг для каждого ТЗ при импорте, **независимо** от того, создаётся ADAPT или нет. Adversarial reviewer выносит вердикт: «findings обнаружены / не обнаружены». Если обнаружены — ADAPT mandatory; если нет — ADAPT skip permitted.

Hook `adapt-applicability validation` (§10.11.1) проверяет: если BR/SR/SPEC создаётся без `source.adapt`, требуется evidence adversarial review (no-findings verdict).

#### 3. Source field rules

| Артефакт | `source.adapt` | `source.tz-section` |
|---|---|---|
| BR | conditional: mandatory если ADAPT существует, omitted иначе | **mandatory всегда** |
| SR | conditional (наследуется через ADAPT или напрямую от parent BR) | mandatory если SR.parent BR не имеет `source.adapt` |
| SPEC | conditional | mandatory всегда (для traceability) |
| TR | n/a (наследует через parent SR) | n/a |
| TC | n/a (через verifies → SR/SPEC) | n/a |

Hook reference-validation (§10.11.1): запрещён артефакт без любого `source` поля.

#### 4. ADAPT schema упрощение (§7.8.1)

Удаляются:
- `mode: full | light` поле.
- `light-preconditions` блок.

Schema возвращается к pre-GAP-02 форме (как было в v1.0-draft).

#### 5. Trace chain (§6.10.3) — два варианта

```
Вариант A (когда ADAPT создавался):
TC → SR → BR ──source.adapt──► ADAPT-NNN ──source-tz──► TZ §N

Вариант B (когда ADAPT не создавался):
TC → SR ──source.tz-section──► TZ §N
       ├─ parent: BR-NN ──source.tz-section──► TZ §N
```

Оба варианта машиночитаемы (через `source.tz-section` или `source.adapt + ADAPT.source-tz`).

#### 6. MVR-3 reformulation (§0.5.1)

**Было (v1.0-draft):**
> ADAPT per ТЗ: каждое ТЗ обязано иметь ровно один корневой ADAPT...

**Было (v1.1-draft, ADR-002 / superseded):**
> ADAPT per ТЗ: каждое ТЗ обязано иметь ровно один корневой ADAPT. Режим (full или light)...

**Станет (v1.2-draft, ADR-006):**
> **Reactive ADAPT:** ADAPT создаётся для ТЗ, конвертация которого порождает backward findings или требует client согласования (term mapping / scope clarification). В этих случаях ADAPT обязателен в статусе `approved` с двойной подписью. Если конвертация однозначна (adversarial reviewer выносит «no findings» verdict) — ADAPT не создаётся; BR/SR/SPEC выводятся напрямую из ТЗ через mandatory поле `source.tz-section`. Delta-ТЗ следует тому же правилу: delta-ADAPT создаётся реактивно.

### §7.12 «Соотношение ТЗ и RENAR-описания» — усиление

Раздел переориентируется: теперь он — основное **обоснование реактивности** ADAPT. Если язык ТЗ и язык RENAR на конкретном переходе совпадают (тривиальная delta) — мост ADAPT не нужен. Мост появляется только когда возникает gap.

## Альтернативы (rejected при принятии ADR-006)

| Alt | Описание | Почему rejected сейчас |
|---|---|---|
| A | Сохранить ADAPT-always (pre-GAP-02 норма) | Не закрывает партнёрский аргумент о process overhead |
| C (ADR-002, superseded) | ADAPT-full vs ADAPT-light режимы | Партнёр явно отверг как недостаточный |
| D | Auto-determinable: гейт сам решает нужен ли ADAPT | Сложно гарантировать «нет findings» без adversarial review (который сейчас и есть механизм) |

Принят **B** (буквальная партнёрская формулировка с adversarial review как gate).

## Последствия

### Архитектурные

- **MVR-3 формальное изменение** через §13.9 procedure → v1.1-draft → **v1.2-draft**.
- ADAPT schema упрощается обратно к pre-GAP-02 форме.
- `check-adapt-mode.js` переименовывается в `check-adapt-applicability.js` с новой логикой.
- Trace chain получает второй валидный вариант (direct-from-TZ).
- Knowledge Graph (`reference/05`) — добавить ребро `<artifact>.source-tz → TZ-section` как параллель к `source-adapt → ADAPT`.

### Operational

- Pilot-проекты, использующие ADAPT-light (если такие были созданы за время v1.1-draft) — migration: либо upgrade на ADAPT-full при наличии findings post-factum, либо downgrade на direct-from-TZ если no findings.
- Existing ADAPT-full артефакты — без миграции (правило «ADAPT mandatory when findings» сохраняется).

### Не меняется

- TZ остаётся immutable (§7.4.2).
- Двойная подпись ADAPT — когда ADAPT существует, подпись обязательна (§7.5).
- 7 категорий backward findings closed list (§7.4.4).
- AI-роль §0.2.4 — наоборот, **усиливается** как обоснование реактивности (AI способен на однозначную конвертацию, когда язык ТЗ и язык RENAR совпадают).

## Migration guidance

Для существующих v1.1-draft conformant проектов:

1. Все `mode: light` ADAPT-артефакты — переоценить:
   - Если backward findings были de-facto обнаружены в процессе (даже если в schema записаны как 0) — promote в `mode: full` с двойной подписью.
   - Если no findings — артефакт удаляется (не нужен); производные BR/SR/SPEC получают `source.tz-section` в качестве primary provenance.
2. Conformance manifest проекта — re-issue с `renar-version: 1.2-draft`.
3. Self-assessment (§13.5) — повторный прогон с обновлёнными mandatory clauses.

## Implementation tracking

Tasks (8):
- `adr-006-adapt-reactive` (this document)
- `adapt-7-4-1-rewrite` — нормативные правила §7.4.1, §7.4.5, §7.6
- `adapt-schema-simplify` — schema cleanup
- `source-fields-conditional` — BR/SR/SPEC source rules
- `trace-chain-two-paths` — §6.10.3 двойная цепочка
- `mvr3-13-3-3-1-4-1-rewrite` — MVR-3, §13.3.3, §1.4.1
- `adapt-gate-rewrite` — check-adapt-applicability.js
- `adapt-7-12-strengthen` — §7.12 reframe
