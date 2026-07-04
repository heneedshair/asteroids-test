---
title: "Схема графа знаний"
description: "Канонические узлы и грани knowledge graph для RENAR-проектов."
order: 5
lang: ru
version: "1.0-draft"
---

# Схема графа знаний

> **Назначение:** формальная схема графа знаний (KG) для RENAR-проектов — узлы, грани, properties, query patterns. KG — **derived view** от RENAR-артефактов для семантических запросов AI-агентов и reconciliation. Machine-readable edge types — [§3](#3-edge-types-closed-list); нормативные поля связей — [standard/06 §6.10](../standard/06-requirements-hierarchy.md#6.10), [standard/08](../standard/08-specifications.md).

KG — **не источник правды**. Источник истины — артефакты (ADAPT / BR / SR / SPEC / TC) на носителе. Граф derived from frontmatter и не редактируется напрямую. Если граф противоречит артефактам → rebuild графа, не правка артефактов.

---

## 1. Use cases

Без KG AI-агент имеет плоский поиск (FTS5/RAG + `parent`/`children` direct hops + keyword grep) — синтаксический контекст. Граф добавляет семантический:

| Запрос | Без графа | С графом |
|---|---|---|
| Все BR, влияющие на Sales Cycle KPI | Grep + парсить frontmatter | Один Cypher-запрос |
| При изменении SR-05 — какие задачи и SPEC затронуты | Сканировать все ссылки | Single graph traversal |
| Какие SPEC-AI требуют high-risk classification по AI Act | Вручную | One query |
| Карта заинтересованных сторон для проекта | Несколько запросов | Single subgraph extraction |
| Cross-project dependencies через SPEC-INT | Federation API calls | Federated graph query |
| Стало ли требование SR-12 деградировать | Manual analysis | Trend analytic on node properties |
| Stale TC (verifies SR с обновлённой версией, last-run на старой) | Manual check | One query |

---

## 2. Node types (закрытый список)

| Type | Источник | Identity |
|---|---|---|
| `Requirement` | BR / SR / TR артефакты | `<id>` |
| `Specification` | SPEC-* артефакты (9 типов) | `<spec-id>` |
| `ADAPT` | ADAPT-NNN артефакты | `<adapt-id>` |
| `BackwardFinding` | B-NNN записи внутри ADAPT | `<adapt-id>:B-NNN` |
| `TestCase` | TC артефакты (вкл. `tc-type: contract`) | `<tc-id>` |
| `WorkOrder` | ТЗ и delta-ТЗ | `<tz-id>` |
| `Stakeholder` | frontmatter `business-context.stakeholder` | `<stakeholder-id>` |
| `BusinessGoal` | frontmatter `business-context.business-goal` (deduplicated) | `<goal-id>` |
| `KPI` | frontmatter `business-outcome.kpi-name` | `<kpi-id>` |
| `Task` | TR / runtime task store | `<task-id>` |
| `CodeArtifact` | TC `automation.location`, code commits | `<repo>:<path>:<symbol>` |
| `Decision` | Architectural decision records | `<decision-id>` |
| `DeadEnd` | Failed approaches (опционально) | `<deadend-id>` |
| `RiskItem` | AI Risk Register entry | `AIR-NN` |
| `Compliance` | Compliance standard reference | `<std>:<control>` |
| `Template` | Requirements library template | `<template-id>` |

Список закрыт; новые типы узлов — только через изменение полного RENAR Standard.

---

## 3. Edge types (закрытый список)

### 3.1 Иерархия и derivation

| Edge | From | To | Семантика |
|---|---|---|---|
| `parent` | Requirement | Requirement | A.parent = B → B is parent of A (BR → SR → TR) |
| `derived-from-adapt` | Requirement / Specification | ADAPT | Артефакт выведен из approved ADAPT section |
| `derived-from-template` | Requirement / Specification | Template | Шаблон (с version pin) |
| `replaces` | Requirement / Specification | Requirement / Specification | new replaces old (deprecated) |
| `supersedes` | Requirement / Specification | Requirement / Specification | strictly newer version (post-delta) |
| `parent-adapt` | ADAPT | ADAPT | delta-ADAPT → main ADAPT |

### 3.2 ADAPT specifics

| Edge | From | To | Семантика |
|---|---|---|---|
| `from-tz` | ADAPT | WorkOrder | source-tz pointer |
| `parent-adapt` | ADAPT | ADAPT | delta-ADAPT → корневой (`parent-adapt`) |
| `supersedes` | ADAPT | ADAPT | дезавуирующий ADAPT → дезавуируемый; обратное `superseded-by` (standard/07 §7.6.4); цель переходит в `superseded` |
| `contains-backward` | ADAPT | BackwardFinding | B-NNN запись |
| `backward-asks-stakeholder` | BackwardFinding | Stakeholder | who answers |
| `resolved-by-answer` | BackwardFinding | (timestamp + author) | client-answer record |

### 3.3 SPEC graph (parallel axis)

| Edge | From | To | Семантика |
|---|---|---|---|
| `constrained-by` | Requirement | Specification | SR constrained by SPEC-* (typed edge) |
| `implements-spec` | Task | Specification | TR implements SPEC-* |
| `depends-on` | Specification | Specification | SPEC depends on another SPEC (DAG) |
| `referenced-by` | Specification | Requirement / Task | inverse (auto-derived) |

### 3.4 Verification и реализация

| Edge | From | To | Семантика |
|---|---|---|---|
| `verifies` | TestCase | Requirement / Specification | TC verifies artifact |
| `verified-by` | Requirement / Specification | TestCase | inverse (auto-derived) |
| `implements` | Task | Requirement | Task implements requirement |
| `realises-in` | TestCase | CodeArtifact | TC.automation.location |
| `linked-defect` | Requirement | Task (defect type) | Bug на этом требовании |

### 3.5 Происхождение

| Edge | From | To | Семантика |
|---|---|---|---|
| `from-order` | ADAPT / Requirement | WorkOrder | source.tz-section reference |
| `delta-from` | WorkOrder | WorkOrder | delta-ТЗ → base ТЗ |
| `cited-in` | Requirement / Specification | WorkOrder | inline citation pointer на раздел ТЗ |
| `decided` | Requirement / Specification | Decision | Decision при декомпозиции |
| `deadend` | Requirement / Specification | DeadEnd | Failed approach |

### 3.6 Business / governance

| Edge | From | To | Семантика |
|---|---|---|---|
| `owned-by` | Requirement | Stakeholder | business-context.stakeholder |
| `goal` | Requirement | BusinessGoal | business-context.business-goal |
| `impacts-kpi` | BusinessGoal | KPI | KPI driven by goal |
| `compliance-with` | Requirement / Specification | Compliance | compliance entry |
| `risk-mitigates` | Requirement / Specification | RiskItem | mitigates AIR-NN |
| `risk-introduces` | Requirement / Specification | RiskItem | introduces new risk (warning trigger) |

### 3.7 Cross-project / integration

| Edge | From | To | Семантика |
|---|---|---|---|
| `participates-in` | Specification (SPEC-INT) | Specification (SPEC-INT) | SPEC-INT participants — стороны интеграционного контракта |
| `cross-deps-on` | Task (project A) | Task (project B) | Cross-project dependency |
| `integrates-via` | Requirement | Specification (SPEC-INT) | Через SPEC-INT contract |

### 3.8 Edge properties

Edges имеют properties (Cypher-style):

```cypher
(SR:Requirement)-[v:verifies {requirement-version: "1.2", confidence: "high"}]->(TC:TestCase)
(BR:Requirement)-[c:compliance-with {control: "A.5.34", rationale: "PII protection"}]->(GDPR:Compliance)
(WO:WorkOrder)-[d:delta-from {effective-date: "2026-05-15"}]->(WO-prev:WorkOrder)
(SR:Requirement)-[cb:constrained-by {since-version: "1.0"}]->(SPEC:Specification)
```

---

## 4. Cypher-style query examples

### 4.4 Stale TC (criteria-version drift)

```cypher
MATCH (r:Requirement)<-[:verifies]-(tc:TestCase)
WHERE tc.last-run.requirement-version < r.version
RETURN r.id, tc.id, tc.last-run.requirement-version, r.version
```

### 4.5 Multi-hop: code → test → SR → BR → KPI

```cypher
MATCH (code:CodeArtifact {path:"src/auth/registration.py"})
      <-[:realises-in]-(tc:TestCase)
      -[:verifies]->(sr:Requirement {type:"SR"})
      -[:parent*1..2]->(br:Requirement {type:"BR"})
      -[:goal]->(g:BusinessGoal)
      -[:impacts-kpi]->(k:KPI)
RETURN code.path, sr.id, br.id, g.name, k.name
```

«Какие KPI зависят от этого файла кода?» — за один query.

### 4.6 SPEC dependency cycle detection

```cypher
MATCH path=(s1:Specification)-[:depends-on*]->(s1)
RETURN path
```

Returning rows → нарушение DAG invariant ([02-schemas.md §9](02-schemas.md#9-validation-rules-cross-field)).

### 4.7 ADAPT с open backward findings

```cypher
MATCH (a:ADAPT {status:"draft"})-[:contains-backward]->(b:BackwardFinding {status:"open"})
RETURN a.id, count(b) as open_count
ORDER BY open_count DESC
```

> **Примечание о нумерации.** Используются §4.4-§4.7 для сохранения cross-refs из [02-schemas.md §9](02-schemas.md#9-validation-rules-cross-field) на конкретные queries (Stale TC, SPEC cycle, ADAPT open). Дополнительные queries (BR→KPI, SR-affected tasks, PII→GDPR scope) — derived из patterns §4.4-§4.7 + node/edge таблиц §2-§3.

---

## 5. Derivation rules

KG — derived от frontmatter артефактов. «Прямого редактирования графа» не существует.

| Node type | Источник в frontmatter | | Edge | Источник |
|---|---|---|---|---|
| `Requirement` | `id`, `type ∈ {BR,SR,TR}` | | `parent` | `parent.id` field |
| `Specification` | `id`, `type ∈ {SPEC-ARCH..SPEC-OPS}` | | `verifies` | `verifies[].id` в TC |
| `ADAPT` | `id`, `type: ADAPT` | | `constrained-by` | `constrained-by[]` в SR |
| `BackwardFinding` | ADAPT body parsing | | `depends-on` | `depends-on[]` в SPEC |
| `TestCase` | `id`, `type: TC`; derived: `last-run.*`, `last_modified` (§7 SQLite schema), `criteria_changed_at` (§6.5) | | `implements-spec` | `implements-spec[]` в TR |
| `WorkOrder` | TZ-NNN frontmatter | | `owned-by` | `business-context.stakeholder` → Stakeholder |
| `Stakeholder` / `BusinessGoal` / `KPI` | deduplicated из `business-context.*` / `business-outcome.kpi-name` | | `compliance-with` | `compliance[]` массив |
| `Compliance` | `compliance.standard` + `compliance.control` | | `derived-from-adapt` / `from-order` / `delta-from` | `source.adapt` / `source.tz-section` / `parent-adapt` |

**Refresh policy.** Граф **rebuilt** при изменении в `.req` репозитории / collection (post-commit/post-save hook), import TC last-run от CI бота, создании/обновлении task. Rebuild **incremental** (только затронутые узлы и грани); full rebuild — раз в неделю reconciliation-агентом.

---

## 6. Validation queries (reconciliation)

### 6.1 Orphan approved requirements

```cypher
MATCH (r:Requirement {status:"approved"})
WHERE NOT (r)-[:verified-by]->()
RETURN r.id  // approved без TC — warning
```

### 6.3 Circular parent chain

```cypher
MATCH path=(r1:Requirement)-[:parent*]->(r1)
RETURN path
```

### 6.5 Test fitting suspicious (AIR-06 signal)

```cypher
MATCH (tc:TestCase)
WHERE tc.last_modified < tc.criteria_changed_at
  AND tc.last-run.result = "pass"
RETURN tc.id  // criteria недавно меняли, тут же passing — подозрительно
```

> Свойства узла `TestCase`: `last_modified` — из node-таблицы (см. §7 SQLite schema); `criteria_changed_at` — derived: timestamp последнего change-record с маркером `[test-spec-change]` ([01-glossary.md §2.12](01-glossary.md#2.12)). Оба заполняются при derivation графа (§5).

### 6.6 SR без constrained-by (missing SPEC links)

```cypher
MATCH (sr:Requirement {type:"SR", status:"approved"})
WHERE NOT (sr)-[:constrained-by]->(:Specification)
RETURN sr.id  // SR approved, но не привязан ни к одному SPEC — warning
```

> **Дополнительные validation queries** (broken citations, orphan stakeholders, orphan SPEC) — derived patterns из §6.1 + §6.5 + node/edge таблиц §2-§3.

---

## 7. Нативные для носителя реализации

Граф derived от frontmatter всех `.md` в `<project>.req/` + task store. Рекомендуемая реализация для git-носителя — embedded SQLite c таблицами `nodes(id, type, properties JSON, last_modified)` и `edges(from_id, to_id, edge_type, properties JSON)` с индексами по `from_id`, `to_id`, `edge_type`. Альтернатива для больших проектов: embedded graph DB (Kuzu, RedisGraph local).

Документные носители используют native graph queries через design views / Cypher-like языки — separate infrastructure не требуется.

**Schema invariants (независимо от носителя):** Типы узлов и типы граней — фиксированы (закрытый список). Properties могут эволюционировать (minor schema bump). Удаление типа узла/грани — major schema bump + migration.

---

## 8. Federated queries (cross-project)

Координация нескольких проектов через KG federation. Пример: «какие cross-team integrations имеют version drift».

```cypher
MATCH (s1:Specification {project:"auth", type:"SPEC-INT"})
      -[:participates-in]->(int:Specification)
      <-[:participates-in]-(s2:Specification {project:"billing"})
WHERE int.contract-version <> s1.implemented-version
RETURN s1.id, s2.id, int.id, int.contract-version, s1.implemented-version
```

Federation — зависимая от носителя операция; реализуется через convention (межносительный query layer) или native multi-tenant graph.

---

## 9. Implementation roadmap

| Уровень зрелости | Покрытие графа |
|---|---|
| RENAR-1 / Core | KG опционален; парсинг frontmatter достаточно. |
| RENAR-2 / Foundation | Базовый граф: Requirement, TestCase, WorkOrder, Task; edges parent, verifies, verified-by, implements. Простые pre-built queries. |
| RENAR-3 / Team | + SPEC, ADAPT, BackwardFinding, Stakeholder, BusinessGoal, KPI, Decision. Edges: constrained-by, depends-on, derived-from-adapt, owned-by, goal, impacts-kpi. AI prompts с graph context. |
| RENAR-4 / Enterprise | Полная схема + reconciliation queries + federation. Visualization в UI. |
| RENAR-5 | Trend analytics, межносительная federation, embedded graph DB для больших репо. |

---

## 10. Перекрёстные ссылки

- Каноничные termini узлов и граней — [01-glossary.md](01-glossary.md).
- Формальные frontmatter schemas (источник derivation) — [02-schemas.md](02-schemas.md).
- AI Risk Register (AIR-10 KG poisoning) — [03-ai-risk-register.md](03-ai-risk-register.md).
- Style guide (validator использует KG для cross-reference checks) — [04-ai-style-guide.md](04-ai-style-guide.md).

---

*Knowledge Graph Schema RENAR 1.0-draft — renar.tech*
