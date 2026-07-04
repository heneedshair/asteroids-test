---
title: "Knowledge Graph Schema"
description: "Canonical knowledge-graph nodes and edges for RENAR projects."
order: 5
lang: en
version: "1.0-draft"
---

# Knowledge Graph Schema

> **Purpose:** the formal knowledge-graph (KG) schema for RENAR projects — nodes, edges, properties, query patterns. The KG is a **derived view** of RENAR artifacts for semantic queries by AI agents and for reconciliation. Machine-readable edge types — [§3](#3-edge-types-closed-list); the normative link fields — [standard/06 §6.10](../../standard/en/06-requirements-hierarchy.md#6.10), [standard/08](../../standard/en/08-specifications.md).

The KG is **not the Source of Truth**. The Source of Truth is the artifacts (ADAPT / BR / SR / SPEC / TC) on the substrate. The graph is derived from frontmatter and is never edited directly. If the graph contradicts the artifacts → rebuild the graph, do not edit the artifacts.

---

## 1. Use cases

Without the KG, an AI agent has only a flat search (FTS5/RAG + `parent`/`children` direct hops + keyword grep) — a syntactic context. The graph adds a semantic one:

| Query | Without the graph | With the graph |
|---|---|---|
| All BR affecting the Sales Cycle KPI | Grep + parse frontmatter | A single Cypher query |
| When SR-05 changes — which tasks and SPEC are affected | Scan all references | Single graph traversal |
| Which SPEC-AI require high-risk classification under the AI Act | Manually | One query |
| Stakeholder map for a project | Several queries | Single subgraph extraction |
| Cross-project dependencies via SPEC-INT | Federation API calls | Federated graph query |
| Whether requirement SR-12 has started to degrade | Manual analysis | Trend analytic on node properties |
| Stale TC (verifies an SR whose version was updated, last-run on the old one) | Manual check | One query |

---

## 2. Node types (closed list)

| Type | Source | Identity |
|---|---|---|
| `Requirement` | BR / SR / TR artifacts | `<id>` |
| `Specification` | SPEC-* artifacts (9 types) | `<spec-id>` |
| `ADAPT` | ADAPT-NNN artifacts | `<adapt-id>` |
| `BackwardFinding` | B-NNN entries inside an ADAPT | `<adapt-id>:B-NNN` |
| `TestCase` | TC artifacts (incl. `tc-type: contract`) | `<tc-id>` |
| `WorkOrder` | TZ and delta-TZ | `<tz-id>` |
| `Stakeholder` | frontmatter `business-context.stakeholder` | `<stakeholder-id>` |
| `BusinessGoal` | frontmatter `business-context.business-goal` (deduplicated) | `<goal-id>` |
| `KPI` | frontmatter `business-outcome.kpi-name` | `<kpi-id>` |
| `Task` | TR / runtime task store | `<task-id>` |
| `CodeArtifact` | TC `automation.location`, code commits | `<repo>:<path>:<symbol>` |
| `Decision` | Architectural decision records | `<decision-id>` |
| `DeadEnd` | Failed approaches (optional) | `<deadend-id>` |
| `RiskItem` | AI Risk Register entry | `AIR-NN` |
| `Compliance` | Compliance standard reference | `<std>:<control>` |
| `Template` | Requirements library template | `<template-id>` |

The list is closed; new node types — only via an amendment to the full RENAR Standard.

---

## 3. Edge types (closed list)

### 3.1 Hierarchy and derivation

| Edge | From | To | Semantics |
|---|---|---|---|
| `parent` | Requirement | Requirement | A.parent = B → B is parent of A (BR → SR → TR) |
| `derived-from-adapt` | Requirement / Specification | ADAPT | Artifact derived from an approved ADAPT section |
| `derived-from-template` | Requirement / Specification | Template | Template (with a version pin) |
| `replaces` | Requirement / Specification | Requirement / Specification | new replaces old (deprecated) |
| `supersedes` | Requirement / Specification | Requirement / Specification | strictly newer version (post-delta) |
| `parent-adapt` | ADAPT | ADAPT | delta-ADAPT → main ADAPT |

### 3.2 ADAPT specifics

| Edge | From | To | Semantics |
|---|---|---|---|
| `from-tz` | ADAPT | WorkOrder | source-tz pointer |
| `parent-adapt` | ADAPT | ADAPT | delta-ADAPT → root (`parent-adapt`) |
| `supersedes` | ADAPT | ADAPT | superseding ADAPT → superseded one; inverse `superseded-by` (standard/07 §7.6.4); the target moves to `superseded` |
| `contains-backward` | ADAPT | BackwardFinding | B-NNN entry |
| `backward-asks-stakeholder` | BackwardFinding | Stakeholder | who answers |
| `resolved-by-answer` | BackwardFinding | (timestamp + author) | client-answer record |

### 3.3 SPEC graph (parallel axis)

| Edge | From | To | Semantics |
|---|---|---|---|
| `constrained-by` | Requirement | Specification | SR constrained by SPEC-* (typed edge) |
| `implements-spec` | Task | Specification | TR implements SPEC-* |
| `depends-on` | Specification | Specification | SPEC depends on another SPEC (DAG) |
| `referenced-by` | Specification | Requirement / Task | inverse (auto-derived) |

### 3.4 Verification and implementation

| Edge | From | To | Semantics |
|---|---|---|---|
| `verifies` | TestCase | Requirement / Specification | TC verifies artifact |
| `verified-by` | Requirement / Specification | TestCase | inverse (auto-derived) |
| `implements` | Task | Requirement | Task implements requirement |
| `realises-in` | TestCase | CodeArtifact | TC.automation.location |
| `linked-defect` | Requirement | Task (defect type) | Bug on this requirement |

### 3.5 Provenance

| Edge | From | To | Semantics |
|---|---|---|---|
| `from-order` | ADAPT / Requirement | WorkOrder | source.tz-section reference |
| `delta-from` | WorkOrder | WorkOrder | delta-TZ → base TZ |
| `cited-in` | Requirement / Specification | WorkOrder | inline citation pointer to a TZ section |
| `decided` | Requirement / Specification | Decision | Decision during decomposition |
| `deadend` | Requirement / Specification | DeadEnd | Failed approach |

### 3.6 Business / governance

| Edge | From | To | Semantics |
|---|---|---|---|
| `owned-by` | Requirement | Stakeholder | business-context.stakeholder |
| `goal` | Requirement | BusinessGoal | business-context.business-goal |
| `impacts-kpi` | BusinessGoal | KPI | KPI driven by goal |
| `compliance-with` | Requirement / Specification | Compliance | compliance entry |
| `risk-mitigates` | Requirement / Specification | RiskItem | mitigates AIR-NN |
| `risk-introduces` | Requirement / Specification | RiskItem | introduces new risk (warning trigger) |

### 3.7 Cross-project / integration

| Edge | From | To | Semantics |
|---|---|---|---|
| `participates-in` | Specification (SPEC-INT) | Specification (SPEC-INT) | SPEC-INT participants — the parties to the integration contract |
| `cross-deps-on` | Task (project A) | Task (project B) | Cross-project dependency |
| `integrates-via` | Requirement | Specification (SPEC-INT) | Via a SPEC-INT contract |

### 3.8 Edge properties

Edges carry properties (Cypher-style):

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

"Which KPI depend on this code file?" — in a single query.

### 4.6 SPEC dependency cycle detection

```cypher
MATCH path=(s1:Specification)-[:depends-on*]->(s1)
RETURN path
```

Returning rows → a violation of the DAG invariant ([02-schemas.md §9](../02-schemas.md#9-validation-rules-cross-field)).

### 4.7 ADAPT with open backward findings

```cypher
MATCH (a:ADAPT {status:"draft"})-[:contains-backward]->(b:BackwardFinding {status:"open"})
RETURN a.id, count(b) as open_count
ORDER BY open_count DESC
```

> **Note on numbering.** §4.4-§4.7 are used to preserve the cross-refs from [02-schemas.md §9](../02-schemas.md#9-validation-rules-cross-field) to specific queries (Stale TC, SPEC cycle, ADAPT open). Additional queries (BR→KPI, SR-affected tasks, PII→GDPR scope) are derived from the patterns in §4.4-§4.7 plus the node/edge tables in §2-§3.

---

## 5. Derivation rules

The KG is derived from artifact frontmatter. "Direct editing of the graph" does not exist.

| Node type | Source in frontmatter | | Edge | Source |
|---|---|---|---|---|
| `Requirement` | `id`, `type ∈ {BR,SR,TR}` | | `parent` | `parent.id` field |
| `Specification` | `id`, `type ∈ {SPEC-ARCH..SPEC-OPS}` | | `verifies` | `verifies[].id` in a TC |
| `ADAPT` | `id`, `type: ADAPT` | | `constrained-by` | `constrained-by[]` in an SR |
| `BackwardFinding` | ADAPT body parsing | | `depends-on` | `depends-on[]` in a SPEC |
| `TestCase` | `id`, `type: TC`; derived: `last-run.*`, `last_modified` (§7 SQLite schema), `criteria_changed_at` (§6.5) | | `implements-spec` | `implements-spec[]` in a TR |
| `WorkOrder` | TZ-NNN frontmatter | | `owned-by` | `business-context.stakeholder` → Stakeholder |
| `Stakeholder` / `BusinessGoal` / `KPI` | deduplicated from `business-context.*` / `business-outcome.kpi-name` | | `compliance-with` | `compliance[]` array |
| `Compliance` | `compliance.standard` + `compliance.control` | | `derived-from-adapt` / `from-order` / `delta-from` | `source.adapt` / `source.tz-section` / `parent-adapt` |

**Refresh policy.** The graph is **rebuilt** on a change in the `.req` repository / collection (post-commit/post-save hook), on import of TC last-run from the CI bot, and on creation/update of a task. The rebuild is **incremental** (only the affected nodes and edges); a full rebuild — once a week by the reconciliation agent.

---

## 6. Validation queries (reconciliation)

### 6.1 Orphan approved requirements

```cypher
MATCH (r:Requirement {status:"approved"})
WHERE NOT (r)-[:verified-by]->()
RETURN r.id  // approved without a TC — warning
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
RETURN tc.id  // criteria changed recently, yet passing right away — suspicious
```

> Properties of a `TestCase` node: `last_modified` — from the node table (see §7 SQLite schema); `criteria_changed_at` — derived: the timestamp of the last change-record carrying the `[test-spec-change]` marker ([01-glossary.md §2.12](01-glossary.md#2.12)). Both are populated during graph derivation (§5).

### 6.6 SR without constrained-by (missing SPEC links)

```cypher
MATCH (sr:Requirement {type:"SR", status:"approved"})
WHERE NOT (sr)-[:constrained-by]->(:Specification)
RETURN sr.id  // SR approved but not linked to any SPEC — warning
```

> **Additional validation queries** (broken citations, orphan stakeholders, orphan SPEC) — patterns derived from §6.1 + §6.5 plus the node/edge tables in §2-§3.

---

## 7. Substrate-native implementations

The graph is derived from the frontmatter of all `.md` files in `<project>.req/` plus the task store. The recommended implementation for a git substrate is an embedded SQLite with tables `nodes(id, type, properties JSON, last_modified)` and `edges(from_id, to_id, edge_type, properties JSON)`, indexed on `from_id`, `to_id`, `edge_type`. An alternative for large projects: an embedded graph DB (Kuzu, RedisGraph local).

Document substrates use native graph queries via design views / Cypher-like languages — no separate infrastructure is required.

**Schema invariants (substrate-independent):** node types and edge types are fixed (closed list). Properties MAY evolve (minor schema bump). Removing a node/edge type — a major schema bump + migration.

---

## 8. Federated queries (cross-project)

Coordinating multiple projects via KG federation. Example: "which cross-team integrations have version drift."

```cypher
MATCH (s1:Specification {project:"auth", type:"SPEC-INT"})
      -[:participates-in]->(int:Specification)
      <-[:participates-in]-(s2:Specification {project:"billing"})
WHERE int.contract-version <> s1.implemented-version
RETURN s1.id, s2.id, int.id, int.contract-version, s1.implemented-version
```

Federation is a substrate-dependent operation; it is implemented via a convention (a cross-substrate query layer) or a native multi-tenant graph.

---

## 9. Implementation roadmap

| Maturity level | Graph coverage |
|---|---|
| RENAR-1 / Core | KG optional; parsing frontmatter is sufficient. |
| RENAR-2 / Foundation | Basic graph: Requirement, TestCase, WorkOrder, Task; edges parent, verifies, verified-by, implements. Simple pre-built queries. |
| RENAR-3 / Team | + SPEC, ADAPT, BackwardFinding, Stakeholder, BusinessGoal, KPI, Decision. Edges: constrained-by, depends-on, derived-from-adapt, owned-by, goal, impacts-kpi. AI prompts with graph context. |
| RENAR-4 / Enterprise | Full schema + reconciliation queries + federation. Visualization in the UI. |
| RENAR-5 | Trend analytics, cross-substrate federation, embedded graph DB for large repos. |

---

## 10. Cross-references

- Canonical termini for nodes and edges — [01-glossary.md](01-glossary.md).
- Formal frontmatter schemas (the derivation source) — [02-schemas.md](../02-schemas.md).
- AI Risk Register (AIR-10 KG poisoning) — [03-ai-risk-register.md](03-ai-risk-register.md).
- Style guide (the validator uses the KG for cross-reference checks) — [04-ai-style-guide.md](04-ai-style-guide.md).

---

*Knowledge Graph Schema RENAR 1.0-draft — renar.tech*
