---
title: "ISO/IEC 29148 — матрица трассировки"
description: "Mapping атрибутов ISO/IEC/IEEE 29148:2018 на поля frontmatter RENAR (BR/SR/TR/SPEC/TC)."
order: 7
lang: ru
version: "1.0-draft"
---

# ISO/IEC 29148 — матрица трассировки

> **Назначение:** проверяемое соответствие заявления соответствия к ISO/IEC/IEEE 29148:2018 ([standard/14 §14.4.2](../standard/14-normative-refs.md#14.4.2)). Нормативные определения полей — в [standard/06](../standard/06-requirements-hierarchy.md), [standard/08](../standard/08-specifications.md), [standard/09](../standard/09-test-cases.md), [02-schemas.md](02-schemas.md).

RENAR упрощает набор обязательных атрибутов 29148 (18 → 7–8 на артефакт) и добавляет TC как полноценный артефакт, ADAPT и SPEC-ось. Таблица ниже — **полная** трассировка для оценщика соответствия и для заполнения `external-claims[]` в манифесте.

---

## 1. Классы требований (29148 §5)

| ISO/IEC 29148 класс | RENAR артефакт | Нормативный источник |
|---|---|---|
| Stakeholder requirement | `BR` | [§6.5](../standard/06-requirements-hierarchy.md#6.5) |
| System requirement | `SR` (level: system / subsystem / module) | [§6.6](../standard/06-requirements-hierarchy.md#6.6) |
| Software requirement (implementation unit) | `TR` | [§6.7](../standard/06-requirements-hierarchy.md#6.7) |
| Interface / design specification | `SPEC-*` (9 типов) | [§8](../standard/08-specifications.md) |
| Verification item | `TC` | [§9](../standard/09-test-cases.md) |
| Requirements validation (client interpretation) | `ADAPT` | [§7](../standard/07-adapt.md) |

---

## 2. Атрибуты требования (29148 Table B.1 → RENAR)

| # | ISO/IEC 29148 атрибут | RENAR поле / механизм | Обязательность | Примечание |
|---|---|---|---|---|
| 1 | Unique ID | `id` (immutable) | обязательно | V1; см. [§3.3.1](../standard/03-substrate-versioning.md#3.3.1) |
| 2 | Requirement statement | body (Потребность / Поведение / …) | обязательно | EARS-шаблон для SR: [§6.6.3](../standard/06-requirements-hierarchy.md#6.6.3) |
| 3 | Rationale | body «Контекст» + `source.adapt-section` | обязательно (BR/SR) | Прослеживаемость к ADAPT |
| 4 | Source | `source.adapt`, `source.tz-section`, `source.document-ref` | обязательно | V5 pinning через `document-ref` |
| 5 | Fit criterion | body «Критерии успеха» (BR) / Pass-критерии TC | обязательно | Измеримость через 25022/25023: [§14.4.4](../standard/14-normative-refs.md#14.4.4) |
| 6 | Priority | `priority` (MoSCoW) | обязательно | WSJF — informative в SAFe mapping |
| 7 | Owner | `owner` (BR/SR) / `business-context.stakeholder` | обязательно | [§6.5.2](../standard/06-requirements-hierarchy.md#6.5.2) |
| 8 | Status | `status` (enum жизненного цикла) | обязательно | Машины состояний: [§10](../standard/10-lifecycle-qg.md) |
| 9 | Verification method | `verified-by[]` → `TC` + `tc-type` | обязательно для verify | TC как полноценный артефакт — расширение 29148 |
| 10 | Parent / child | `parent.id`, auto `children[]` | обязательно (SR/TR) | Иерархия BR→SR→TR |
| 11 | Traceability (derived) | `verified-by`, `constrained-by[]`, `implements-spec[]`, KG edges | derived | [reference/05 §4](05-knowledge-graph-schema.md#3-edge-types-closed-list) |
| 12 | Version | нативная для носителя версия + `requirement-version` в TC | обязательно (V5) | [§3.3.5](../standard/03-substrate-versioning.md#3.3.5) |
| 13 | Author | V6 author + `ai-provenance` | обязательно (RENAR-4+ AI) | [§4.10.1](../standard/04-terms.md#4.10.1) |
| 14 | Date created / modified | timestamps записи изменений носителя | derived (V6) | Журнал аудита: [§10.13](../standard/10-lifecycle-qg.md#10.13) |
| 15 | Risk | `compliance[]`, AIR register link | optional / domain | [03-ai-risk-register.md](03-ai-risk-register.md) |
| 16 | Assumption | ADAPT backward findings `type: assumption` | через ADAPT | [§7.4.4](../standard/07-adapt.md#7.4.4) |
| 17 | Dependency | `depends-on[]` (SPEC), `constrained-by[]` (SR) | обязательно где применимо | DAG invariant: [02 §9](02-schemas.md#9-validation-rules-cross-field) |
| 18 | Approval authority | QG-0 / QG-2 + ADAPT dual signature | обязательно | Замена formal walkthrough: [§14.4.2](../standard/14-normative-refs.md#14.4.2) |

**Не принято из 29148:** review meetings и inspection-only verification без доказательной базы TC — см. [§14.7](../standard/14-normative-refs.md#14.7).

---

## 3. Verification methods (29148 §6.4)

| 29148 method | RENAR реализация |
|---|---|
| Test | `TC` с `tc-type: system \| acceptance \| contract \| …` |
| Demonstration | `tc-type: acceptance` + client sign-off (QG-4 optional) |
| Inspection | `[test-spec-change]` workflow + состязательный обзор ([§9.13](../standard/09-test-cases.md#9.13)) |
| Analysis | SR с `quality-characteristic` + eval-TC (`tc-type: eval`) для SPEC-AI |

---

## 4. Процессы жизненного цикла (29148 §6)

| 29148 process | RENAR глава | Gate |
|---|---|---|
| Requirements elicitation | ADAPT backward + ТЗ | QG-0 (ADAPT approve) |
| Requirements analysis | BR/SR decomposition | QG-0 (BR/SR approve) |
| Requirements specification | SPEC axis | QG-3 Architecture (optional/required) |
| Requirements verification | TC + QG-2 | QG-2 Verification |
| Requirements validation | ADAPT client signature + QG-4 | QG-4 Acceptance (optional) |
| Requirements management | жизненный цикл §10 + носитель V1–V6 | Continuous |

---

## 5. Использование при оценке соответствия

1. Для каждого заявления `ISO/IEC/IEEE 29148:2018` в манифесте — пройти строки §2–§5.
2. Выборочно (≥10% артефактов или все BR/SR уровня system) проверить наличие обязательных полей и трассировку `source.adapt`.
3. Несоответствие любой **обязательной** строки §14 — частичное заявление недопустимо ([§14.6.2](../standard/14-normative-refs.md#14.6.2)).

---

*Reference RENAR 1.0-draft — renar.tech*
