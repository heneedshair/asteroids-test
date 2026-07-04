# Knowledge Graph Schema для REQ

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: формализация knowledge graph как central source для AI-запросов о требованиях. Узлы, грани, properties, query patterns. Реализует [02-agent-driven-principles.md Принцип 6](02-agent-driven-principles.md).
>
> Финальная нормативная форма — после реализации MVP графа на pilot-проекте.

---

## 1. Не дублирует SENAR

SENAR упоминает graph-memory в контексте Raven (architecture diagrams), но не нормирует **формальную схему** требовательного графа.

REQ specifies node types, edge types, properties, и query patterns специфичные для requirements management. Граф — derived view от REQ-артефактов, не самостоятельное хранилище.

---

## 2. Зачем граф

### 2.1 Проблема, которую он решает

Без графа AI-агент при генерации/анализе требования имеет flat search через:
- FTS5 по `.md` файлам.
- Frontmatter `parent`/`children` (только direct hops).
- Keyword grep в коде.

Это даёт **синтаксический** контекст. Но AI часто нужен **семантический**: «дай все BR, влияющие на KPI X», «какие требования имеют data-residency RU», «какие SR верифицированы tests, чьи last-run на устаревшей requirement-version».

Граф выполняет такие запросы за один проход (Cypher-подобные queries), не за N запросов через файлы.

### 2.2 Use cases

| Запрос | Без графа | С графом |
|---|---|---|
| «Все BR, влияющие на Sales Cycle KPI» | Grep по всем `.md`, парсить frontmatter | Один Cypher-запрос |
| «При изменении SR-05 — какие задачи затронуты» | Прочитать все `linked_tasks` файлы и tasks | Single graph traversal |
| «Какие AIC требуют high-risk classification по AI Act» | Вручную | One query |
| «Stakeholder map для проекта» | Несколько query | Single subgraph extraction |
| «Cross-project dependencies через INT-SR» | Federation API calls | Federated graph query |
| «Стало ли требование SR-12 деградировать» (achievement % падает) | Manual analysis | Trend analytic on node properties |

---

## 3. Node types

| Type | Источник | Identity |
|---|---|---|
| `Requirement` | REQ-артефакт (BR/SR/UIC/AIC/INT-SR/TS) | `<id>` |
| `TestCase` | TC-артефакт | `<tc-id>` |
| `WorkOrder` | TZ | `<tz-id>` |
| `Stakeholder` | Frontmatter `business-context.stakeholder` | `<stakeholder-id>` |
| `BusinessGoal` | Frontmatter `business-context.business-goal` (deduplicated) | `<goal-id>` |
| `KPI` | Frontmatter `business-outcome.kpi-name` | `<kpi-id>` |
| `Task` | TAUSIK DB / Raven `task` | `<task-id>` |
| `CodeArtifact` | TC `automation.location`, code commits | `<repo>:<path>:<symbol>` |
| `Decision` | KAI / Raven `decision` doc-type | `<decision-id>` |
| `DeadEnd` | KAI / Raven dead-end записи | `<deadend-id>` |
| `RiskItem` | AI Risk Register entry | `AIR-NN` |
| `Compliance` | Compliance standard reference | `<std>:<control>` |
| `Template` | Requirements library template | `<template-id>` |

---

## 4. Edge types

### 4.1 Иерархия и декомпозиция

| Edge | From | To | Семантика |
|---|---|---|---|
| `parent` | Requirement | Requirement | A.parent = B → B is parent of A |
| `derived-from-uic` | SR | UIC | SR derived from UIC during decomposition |
| `derived-from-aic` | SR | AIC | SR derived from AIC |
| `derived-from-template` | Requirement | Template | Used template (with version pin) |
| `replaces` | Requirement | Requirement | new replaces old (deprecated) |
| `supersedes` | Requirement | Requirement | strictly newer version (post-delta-TZ) |

### 4.2 Verification и реализация

| Edge | From | To | Семантика |
|---|---|---|---|
| `verifies` | TestCase | Requirement | TC verifies requirement |
| `verified-by` | Requirement | TestCase | inverse of verifies (auto-derived) |
| `implements` | Task | Requirement | Task implements requirement |
| `implemented-by` | Requirement | Task | inverse |
| `realises-in` | TestCase | CodeArtifact | TC.automation.location |
| `linked-defect` | Requirement | Task (defect type) | Bug на этом требовании |

### 4.3 Provenance

| Edge | From | To | Семантика |
|---|---|---|---|
| `from-order` | Requirement | WorkOrder | source.document |
| `delta-from` | WorkOrder | WorkOrder | delta-ТЗ имеет base |
| `cited-in` | Assertion | WorkOrder | inline citation pointer |
| `decided` | Requirement | Decision | Решение, принятое при декомпозиции |
| `deadend` | Requirement | DeadEnd | Тупик, обнаруженный при декомпозиции |

### 4.4 Business / governance

| Edge | From | To | Семантика |
|---|---|---|---|
| `owned-by` | Requirement | Stakeholder | business-context.stakeholder |
| `goal` | Requirement | BusinessGoal | business-context.business-goal |
| `impacts-kpi` | BusinessGoal | KPI | KPI driven by business goal |
| `compliance-with` | Requirement | Compliance | compliance frontmatter entry |
| `risk-mitigates` | Requirement | RiskItem | requirement mitigates AIR-NN |
| `risk-introduces` | Requirement | RiskItem | requirement introduces new risk |

### 4.5 Cross-project / integration

| Edge | From | To | Семантика |
|---|---|---|---|
| `integrates-via` | Requirement | Requirement | через INT-SR (oriented) |
| `cross-deps-on` | Task (project A) | Task (project B) | KAI cross-deps |
| `participates-in` | Requirement | Requirement (INT-SR) | INT-SR participants |

### 4.6 Properties on edges

Edges имеют properties (Cypher-style):

```
(SR:Requirement)-[v:verifies {requirement-version: "1.2", confidence: "high"}]->(TC:TestCase)
(BR:Requirement)-[c:compliance-with {control: "A.5.34", rationale: "PII protection"}]->(GDPR:Compliance)
(WO:WorkOrder)-[d:delta-from {effective-date: "2026-05-15"}]->(WO-prev:WorkOrder)
```

---

## 5. Cypher-style query examples

### 5.1 Найти все BR, влияющие на KPI X

```cypher
MATCH (br:Requirement {type:"BR"})-[:goal]->(g:BusinessGoal)-[:impacts-kpi]->(k:KPI {name:"Sales Cycle Time"})
RETURN br.id, br.title, br.status
```

### 5.2 Затронутые задачи при изменении SR-05

```cypher
MATCH (sr:Requirement {id:"SR-05"})<-[:implements]-(t:Task)
WHERE t.status NOT IN ["done", "cancelled"]
RETURN t.id, t.title, t.assignee
```

### 5.3 Все требования высокого риска по compliance

```cypher
MATCH (r:Requirement)-[:compliance-with]->(c:Compliance)
WHERE c.standard IN ["GDPR", "ФЗ-152"] AND r.data-classification.contains-pii = true
RETURN r.id, r.title, collect(c.control) as compliance_controls
```

### 5.4 Stakeholder map для проекта

```cypher
MATCH (s:Stakeholder)<-[:owned-by]-(br:Requirement {type:"BR"})
RETURN s.name, count(br) as br_count, collect(br.status) as statuses
```

### 5.5 Stale TCs (обновили требование, не перепрогнали тест)

```cypher
MATCH (r:Requirement)-[v:verified-by]->(tc:TestCase)
WHERE v.requirement-version < r.version
RETURN r.id, tc.id, v.requirement-version, r.version
```

### 5.6 Cross-project integrations status

```cypher
MATCH (sr1:Requirement)-[:participates-in]->(int:Requirement {type:"INT-SR"})<-[:participates-in]-(sr2:Requirement)
WHERE sr1.repo <> sr2.repo
RETURN int.id, sr1.id, sr1.repo, sr2.id, sr2.repo, int.status
```

### 5.7 Multi-hop: code → test → SR → BR → KPI

```cypher
MATCH (code:CodeArtifact {path:"acmecorp-login.src/src/auth/registration.py"})<-[:realises-in]-(tc:TestCase)
      -[:verifies]->(sr:Requirement {type:"SR"})
      -[:parent*1..2]->(br:Requirement {type:"BR"})
      -[:goal]->(g:BusinessGoal)
      -[:impacts-kpi]->(k:KPI)
RETURN code.path, sr.id, br.id, g.name, k.name
```

«Какие KPI зависят от этого файла кода?» — за один query.

---

## 6. Storage

### 6.1 На git-substrate

**Граф derived от frontmatter всех `.md` файлов** в `.req` репо + TAUSIK DB tasks.

Реализация:

```
<project>.req/.tausik/graph.db    ← SQLite c graph schema
```

Таблицы:

```sql
CREATE TABLE nodes (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    properties JSON,
    last-modified TIMESTAMP
);

CREATE TABLE edges (
    from_id TEXT,
    to_id TEXT,
    edge_type TEXT,
    properties JSON,
    PRIMARY KEY (from_id, to_id, edge_type)
);

CREATE INDEX idx_edges_from ON edges(from_id);
CREATE INDEX idx_edges_to ON edges(to_id);
CREATE INDEX idx_edges_type ON edges(edge_type);
```

Использование Cypher через Apache AGE? Слишком тяжело для git-substrate. Для MVP — собственный простой query-language или Python query-builder (не полный Cypher, но subset).

### 6.2 На Raven-substrate

Raven уже имеет graph-memory. Нативный CouchDB graph через design views. Не требует separate инфра.

При миграции git → Raven граф автоматически воссоздаётся из mapped fields.

### 6.3 Refresh policy

Граф **rebuilt** при:

- Любой commit в `.req` (post-commit hook).
- Импорт TC last-run от бота.
- Создание/обновление task в TAUSIK DB.

Rebuild — incremental (только затронутые узлы и грани), не full rebuild каждый раз.

---

## 7. AI prompt access pattern

### 7.1 Без графа

Промпт AI содержит:
```
Контекст: [полное содержимое нескольких .md файлов]
Задача: ...
```

Проблемы: токены, релевантность, hallucinations.

### 7.2 С графом

Промпт AI содержит:
```
Граф-контекст: [результат semantic query]
Задача: ...
```

Граф предоставляет structured context, не raw text. Sample:

```yaml
# Граф-context для генерации SR
target-br: BR-05
parent: 
  id: BR-05
  business-goal: "Reduce sales cycle"
  stakeholder: "Sales Director"
  data-classification: { contains-pii: true, residency: ["RU"] }
  compliance: ["ФЗ-152 ст.13.1"]
sibling-srs:                          # other SRs of same BR (for consistency)
  - { id: SR-12, status: verified, scope: "lead intake" }
  - { id: SR-13, status: approved, scope: "lead qualification" }
related-int-srs:                      # if SR будет иметь cross-project integration
  - INT-SR-03 (Princess → CRM external)
similar-templates:
  - SR-CRM-LEAD-001@1.2 (verified, used in 2 projects)
related-decisions:
  - DEC-2026-04-15: "В этом проекте RLS на уровне БД, не applevel"
```

AI генерирует SR с этим контекстом — больше шансов consistency, less hallucination.

---

## 8. Validation queries (для reconciliation)

Reconciliation-агент (Принцип 7) запускает graph queries для finding inconsistency:

### 8.1 Orphan requirements

```cypher
MATCH (r:Requirement {status:"approved"})
WHERE NOT (r)-[:verified-by]->()
RETURN r.id  // approved без TC
```

### 8.2 Broken citations

```cypher
MATCH (r:Requirement)-[:cited-in]->(wo:WorkOrder)
WHERE wo.status = "obsolete"
RETURN r.id, wo.id  // citation указывает на obsolete TZ
```

### 8.3 Circular dependencies

```cypher
MATCH path=(r1:Requirement)-[:parent*]->(r1)
RETURN path  // circular parent chain
```

### 8.4 Stakeholder без owned BR

```cypher
MATCH (s:Stakeholder)
WHERE NOT (s)<-[:owned-by]-()
RETURN s.id  // stakeholder в графе но nothing assigned
```

### 8.5 Test fitting suspicious

```cypher
MATCH (tc:TestCase)
WHERE tc.last_modified < tc.criteria_changed_at
   AND tc.last_run.result = "pass"
RETURN tc.id  // criteria недавно меняли, тут же passing — подозрительно
```

---

## 9. Federated queries (cross-project)

В Andersen Stack через Raven federation:

```python
# через KAI MCP
kai_graph_query(
    cypher="""
    MATCH (sr:Requirement {project:"princess"})-[:participates-in]->(int:Requirement {type:"INT-SR"})
          <-[:participates-in]-(sr2:Requirement {project:"gerda"})
    WHERE int.contract-version <> sr.implemented-version
    RETURN sr.id, sr2.id, int.id, int.contract-version, sr.implemented-version
    """,
    scope="federation"
)
```

Это даёт RTE (Finka) ответ «какие cross-team integrations имеют version drift».

---

## 10. Implementation roadmap

### MVP (RENAR-3 проектов)

- Graph derived from frontmatter, в SQLite.
- Поддержка node types: Requirement, TestCase, WorkOrder, Task.
- Поддержка edges: parent, verifies, verified-by, from-order, implements.
- Простые query patterns (5-10 рецептов как функции в `tausik req graph query <name> --params ...`).
- Refresh: post-commit hook.

### Расширение (RENAR-4)

- Добавить node types: Stakeholder, BusinessGoal, KPI, Decision, DeadEnd.
- Добавить edges: owned-by, goal, impacts-kpi, compliance-with.
- AI promt template `req-prompts/with-graph-context.md`.
- Reconciliation-агент использует graph queries.

### Полный (RENAR-5)

- Cypher-like query language через лёгкую DSL.
- Federation queries через Raven (когда Raven готов).
- Visualisation в Hub UI.
- Trend analytics on node properties.

---

## 11. Open questions

- [ ] Cypher-engine для git-substrate: реализовывать самим (subset) или подключить embeddable graph DB? Например, Kuzu — embedded graph DB.
- [ ] Refresh-стратегия: incremental vs full. Для маленьких проектов — full proще; для больших — incremental обязательно.
- [ ] Privacy: некоторые edges (например, stakeholders) могут иметь sensitive info. Permissions на graph?
- [ ] Federated queries: какой transport между Raven instances в multi-tenant сценарии?
- [ ] Visualization: какой engine? Mermaid (statics)? D3.js? Cytoscape.js? Hub UI выбор.
- [ ] Schema evolution graph schema: как мигрировать когда добавили node types? Versioning подобно requirement-schema (см. 14).
- [ ] Performance: 10K nodes — нет проблем; 100K — нужны индексы; 1M — embedded graph DB обязательна. Сейчас разрабатывать на 10K, проектировать на 100K.
- [ ] Какие queries должны быть **первоклассными** командами в `tausik req graph` (top-10 рецептов)?
