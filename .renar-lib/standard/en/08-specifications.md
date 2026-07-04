---
title: "Specifications (9 SPEC types)"
order: 8
lang: en
---
# 08. Specifications — 9 SPEC types

> **Part of the RENAR Standard v1.0-draft** · [← Table of contents](README.md)

## 8.1 Why a separate specification axis

Take the requirement "the system creates an order." It says **what** must happen — but it is silent about **how** the system is built to do it: what its API contract is, in which table the order lives, under which access rules, on which screen. Cramming all of that into the requirement itself does not work — it turns into mush. So RENAR splits the description into two axes: **behavior** (BR / SR / TR, [chapter 6](06-requirements-hierarchy.md)) and **structure** — specifications, SPEC.

A specification is not a "more detailed SR" and not its child. A single "create order" requirement typically rests on five to seven specifications at once (architecture, API, data, process, security, screen), so the link between the axes is a graph of typed edges (`constrained-by[]`, `implements-spec[]`), not a tree. There are exactly nine specification types, and the list is closed: `SPEC-ARCH`, `API`, `DATA`, `INT`, `PROC`, `UI`, `AI`, `SEC`, `OPS` — a new type is introduced only through the formal change procedure of the standard ([chapter 13](13-conformance.md)).

---

## 8.2 Architectural decision: SPEC is a parallel axis, not children of SR

### 8.2.1 Two axes of describing the system

Requirements and specifications answer different questions:

| Axis | Artifacts | Question |
|---|---|---|
| Behavioral | BR / SR / TR ([chapter 6](06-requirements-hierarchy.md)) | What the system must do |
| Structural | SPEC-* (9 types) | How the system is structurally built to fulfill those requirements |

### 8.2.2 SPEC as a parallel axis: links through a typed graph

The links between the requirements axis (BR / SR / TR) and the SPEC axis are organized as a **dependency graph**, not a tree of parents. An SR has exactly one parent in the requirements tree (BR), but many typed `constrained-by[]` edges to SPEC. A single SR MUST reference every SPEC that constrains its behavior on the API / data / UI / process / security / ops axes; conversely, one SPEC MAY constrain many SR.

Example: the SR "create order" rests on SPEC-ARCH (where the orders component lives), SPEC-API (the endpoint contract), SPEC-DATA (the table schema), SPEC-PROC (workflow), SPEC-SEC (access rules), SPEC-UI (the form).

Normatively: every `SR.constrained-by[]` and `TR.implements-spec[]` edge MUST reference one of the closed SPEC categories listed in [§8.3](#83-the-closed-list-of-nine-spec-types); ad-hoc categories are not allowed (see [§1.7](01-scope.md#1.7) closed-list policy).

```text
Requirements tree (behavioral axis):       Parallel specification axis:

BR                                          SPEC-ARCH    SPEC-API
 └── SR  ←──── constrained-by[] ────►       SPEC-DATA    SPEC-INT
      └── TR ─── implements-spec[] ────►    SPEC-PROC    SPEC-UI
                                            SPEC-AI      SPEC-SEC
                                            SPEC-OPS

Requirements tree:
  SR.parent              → BR              (single parent)
  TR.parent              → SR              (single parent)

Link graph (typed edges):
  SR.constrained-by[]    → SPEC-*
  TR.implements-spec[]   → SPEC-*
  SPEC-*.depends-on[]    → SPEC-*          (between specifications)
  SPEC-*.referenced-by[] → SR / TR          (auto-derived inverse)
```

### 8.2.3 Rationale

| Argument | Consequence |
|---|---|
| SPEC and SR answer different questions | SPEC does not refine an SR at a deeper level — it is a separate category of description |
| One SR rests on 5–7 SPEC | A "SPEC as parent of SR" tree leads to multiple parenthood |
| Industry standards (arc42, C4, OpenAPI, BPMN, ERD) live in parallel with requirements | RENAR follows this proven practice |
| An AI agent can parallelize SR and SPEC generation | Without one type blocking the other |

---

## 8.3 The closed list of nine SPEC types

| Type | Purpose | Industry reference |
|---|---|---|
| `SPEC-ARCH` | System / subsystem architecture: contexts, containers, components, deployment view, quality attributes | arc42, C4 model (Brown), ISO/IEC/IEEE 42010 |
| `SPEC-API` | API contracts: REST / GraphQL / gRPC / async events; versioning, error model, rate limits | OpenAPI 3.x, AsyncAPI 2.x, gRPC IDL |
| `SPEC-DATA` | Data model: schema, ERD, indices, migrations, retention, PII classification | ISO/IEC 11179, JSON Schema |
| `SPEC-INT` | Integration: interaction between subsystems and external systems; protocols, contracts, SLA | Enterprise Integration Patterns (Hohpe) |
| `SPEC-PROC` | Process / workflow: business processes, state machines, saga, choreography, orchestration | BPMN 2.0, ISO/IEC 19510 |
| `SPEC-UI` | UI / UX: screens, navigation, user journeys, accessibility, i18n, baseline images | Material Design / Apple HIG, WCAG 2.2 |
| `SPEC-AI` | AI / ML: model cards, RAG, prompt engineering, eval strategy, cost budget | ISO/IEC 23894, NIST AI RMF |
| `SPEC-SEC` | Security: authn / authz, threat model, secrets management, data classification | STRIDE, OWASP ASVS, ISO/IEC 27001 |
| `SPEC-OPS` | Operations: deployment, observability, SLO / SLA, runbook, disaster recovery | Google SRE, ITIL v4, ISO/IEC 20000 |

### 8.3.1 What did NOT make it into v1.0 (with rationale)

| Candidate | Decision | Rationale |
|---|---|---|
| `SPEC-EVENT` | Not a separate type | Events / queues — part of SPEC-API (asynchronous APIs) |
| `SPEC-CONFIG` | Not a separate type | Feature flags / env vars / secrets — part of SPEC-OPS |
| `SPEC-PERF` | Not a separate type | Performance / NFR — part of SPEC-ARCH (quality attributes) or SPEC-OPS (SLO) |
| `SPEC-TEST-ENV` | Not a separate type | Test environments — part of SPEC-OPS |
| `SPEC-DOMAIN` | Not a separate type | Domain model — absorbed into SPEC-ARCH (decomposition) + SPEC-DATA (entities) |
| `SPEC-MIGRATION` | Not a separate type | Migration — part of SPEC-DATA (lifecycle) |
| `SPEC-COMPLIANCE` | Not a separate type | Compliance — links between SR/SPEC and regulations through `compliance-refs[]`, not a separate artifact |

Closed-list policy: if subsequent work reveals that one of the excluded types is genuinely needed — it is added through the formal change procedure of the standard with rationale.

---

## 8.4 Common schema (shared frontmatter fields)

All 9 SPEC types share a common set of frontmatter fields. Type-specific fields are added as extensions on top (§8.5). The full machine-readable data model — in [reference/02-schemas.md](../../reference/en/02-schemas.md).

```yaml
---
# === Identity (mandatory) ===
id: SPEC-<TYPE>-NN[.N]              # immutable; TYPE ∈ {ARCH,API,DATA,INT,PROC,UI,AI,SEC,OPS}
title: "<short, descriptive>"
type: SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS
slug: "<kebab-case>"                # auto-derived

# === Scope (mandatory) ===
level: system | subsystem | module
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"       # null if level=system

# === Lifecycle (mandatory) ===
status: draft | review | approved | verified | obsolete
priority: must | should | could     # not all types use; mostly SPEC-SEC / SPEC-OPS

# === Source: provenance (conditional, see chapter 7 §7.4.1) ===
# source.adapt — conditional (present when an ADAPT was created; §7.4.1.1).
# source.tz-section — always mandatory.
# source.adversarial-review-ref — mandatory when source.adapt is omitted.
source:
  adapt: ADAPT-NNN                  # conditional
  adapt-section: "Forward §N"       # mandatory if adapt is present
  tz-section: "§N.N"                # always mandatory
  adversarial-review-ref: "<substrate-native reference>"   # mandatory if adapt is omitted

# === Link graph (auto-managed except mandatory ones) ===
referenced-by: []                   # auto-derived; SR/TR/SPEC referencing here
depends-on: []                      # mandatory if present; SPEC-* this SPEC rests on
verified-by: []                     # auto-derived; list of verifying TC IDs

# === AI provenance (mandatory at RENAR-4+; canonical schema — §4.10.1) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  generated-at: "<ISO-8601>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  human-edits: boolean
  generation-time-ms: integer        # optional; see §4.10.1
  # optional at RENAR-4, mandatory at RENAR-5:
  # cost-budget, cost-actual

# === Replacement (mandatory if applicable) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"

# === Compliance (optional) ===
compliance-refs: []                 # references to ISO/GDPR/AI Act/NIST AI RMF
---
```

### 8.4.1 Mandatory body sections

The body of any SPEC MUST contain:

1. **Purpose** — 1–3 paragraphs.
2. **Scope** — what is in, what is out.
3. **Type-specific sections** — see §8.5.
4. **Link to requirements** — which SR/BR reference it.
5. **Link to other SPEC** — `depends-on[]`.
6. **Verification** — which TC verify this SPEC.

---

## 8.5 Schema extensions by SPEC type

A brief description of type-specific fields and mandatory body sections. The full machine-readable extension schema — in [reference/02-schemas.md](../../reference/en/02-schemas.md). Industry references in detail — in the listed standards.

### 8.5.1 SPEC-ARCH

**Type-specific frontmatter**: `arch-style`, `deployment-model`, `tech-stack`, `quality-attributes`.

**Mandatory body**: system context (C4 L1), containers (C4 L2), components (C4 L3) for critical containers, quality attributes (latency / throughput / availability), ADR log.

**Spec-specific TC** ([chapter 9](09-test-cases.md)): architecture conformance tests (zoning), reference tests of quality attributes.

### 8.5.2 SPEC-API

**Type-specific frontmatter**: `api-style` (rest / graphql / grpc / async-events), `api-version`, `versioning-strategy`, `authentication`, `rate-limits`, `contract-file` (location of machine-readable contract).

**Mandatory body**: endpoints / operations with payload / response / errors, versioning rules (breaking vs non-breaking), error model, authn/authz reference to SPEC-SEC, rate limits, 2–3 example requests per endpoint.

**Spec-specific TC**: contract tests, authentication negative, rate limit tests.

### 8.5.3 SPEC-DATA

**Type-specific frontmatter**: `data-style` (relational / document / graph / columnar), `storage-engine`, `schema-version`, `pii-classification[]`, `retention-policies[]`, `migration-strategy`.

**Mandatory body**: domain entities, ERD (text / Mermaid / link), entity fields (type / constraints / indices / defaults), relationships (FK / cardinality / cascade), PII / sensitive data classification + encryption at-rest + retention, migration approach, index strategy.

**Spec-specific TC**: migration tests, constraint tests (FK / NOT NULL / unique), PII handling tests, data retention tests.

### 8.5.4 SPEC-INT

**Type-specific frontmatter**: `integration-pattern` (request-response / event-driven / message-queue / webhook / file-transfer), `direction`, `counterparty`, `sla`, `idempotency`.

**Mandatory body**: integrated systems, exchange contract, failure modes + retry strategy, idempotency + dedup, security between systems, observability (correlation IDs).

**Spec-specific TC**: contract tests with a counterparty mock, failure injection, idempotency, end-to-end TC `tc-type: contract`.

**Note**: SPEC-INT replaces the existing `INT-SR` ([§8.7](#87-migration-uic--aic--int-sr--ts--spec-) migration).

### 8.5.5 SPEC-PROC

**Type-specific frontmatter**: `process-style` (bpmn / state-machine / saga / choreography / orchestration), `state-count`, `participants[]`, `sla` end-to-end and per step, `compensation` (defined / not-applicable / manual).

**Mandatory body**: process diagram (BPMN-flavor / Mermaid / link), states and transitions (for a state machine), participants and their roles, happy path, alternative scenarios and exceptions, timeouts and compensation (for saga), SLA.

**Spec-specific TC**: happy path E2E, alternative paths, compensation tests (for saga), SLA tests.

### 8.5.6 SPEC-UI

**Type-specific frontmatter**: `ui-platform`, `target-users[]` (with references to ADAPT persona sections), `design-system`, `accessibility-level` (WCAG-A / AA / AAA), `i18n`, `mockup-links[]`, `baseline-images[]` for VLM-judge tests.

**Mandatory body**: overall interface structure, key screens, user journeys without technical details, cross-cutting elements (access rights / notifications / error / empty states), tone and style, accessibility, i18n.

**Spec-specific TC**: VLM-judge against a baseline (judge ≠ production isolation), accessibility (axe-core / Pa11y), i18n (string overflow / RTL), user journey E2E.

**Note**: SPEC-UI replaces the existing `UIC` ([§8.7](#87-migration-uic--aic--int-sr--ts--spec-) migration).

### 8.5.7 SPEC-AI

**Type-specific frontmatter**: `ai-pattern` (rag / fine-tuning / prompt-engineering / tool-use / multi-agent), `production-model` (vendor / model / version), `judge-model` (MUST differ from production), `context-strategy`, `eval-strategy` (metric / threshold / baseline-dataset), `cost-budget`.

**Mandatory body**: AI component architecture (pipeline / orchestration / fallback), model card (capabilities / limits / known failure modes), context strategy, eval strategy with judge ≠ production isolation, cost management, hallucination mitigation, adversarial aspects.

**Spec-specific TC**: eval against a baseline (judge isolated), adversarial (prompt injection as a negative TC), cost regression, hallucination tests.

**Note**: SPEC-AI replaces the existing `AIC`. Isolation judge ≠ production model is a mandatory requirement of the standard for all eval-TC.

### 8.5.8 SPEC-SEC

**Type-specific frontmatter**: `security-domains[]`, `auth-model` (authn / authz strategies), `data-classification[]` (PII-high / PCI / internal), `threat-model-method` (STRIDE / PASTA / OCTAVE), `compliance[]`, `incident-response` reference in SPEC-OPS.

**Mandatory body**: auth model (authn flow / authz rules), data classification with protection, threat model (STRIDE table with a mitigation for each threat), secrets management, audit (what is logged / retention / access), encryption (at-rest / in-transit / key management), compliance mapping (references to specific clauses).

**Spec-specific TC**: authn (pos + neg), authz (RBAC matrix), threat-test (each STRIDE threat → at least 1 negative TC), audit log, secrets leakage.

### 8.5.9 SPEC-OPS

**Type-specific frontmatter**: `deployment-style`, `environments[]` (dev / staging / prod with purpose and scale), `slo`, `observability` (logs / metrics / traces / alerting), `runbook-link`, `disaster-recovery` (rto / rpo / backup-strategy).

**Mandatory body**: environments, deployment process (CI/CD pipeline / gating / rollout strategy), SLO (availability / latency / error budget), observability, alerting (critical alerts / escalation), runbook, capacity planning, disaster recovery.

**Spec-specific TC**: deployment tests (smoke), SLO regression (load testing), failover (DR drills), observability (alerts fire when expected).

---

## 8.6 Link to requirements and tasks

### 8.6.1 SR.constrained-by[]

An SR receives a `constrained-by[]` field in its frontmatter — typed references to SPEC. This is a **graph**, not a tree of parents. The SR's parent in the requirements tree is single (BR).

```yaml
# SR frontmatter (example)
id: SR-05
parent:
  id: BR-02
constrained-by:
  - SPEC-UI-01
  - SPEC-API-02
  - SPEC-DATA-03
  - SPEC-PROC-01
  - SPEC-SEC-01
verified-by:
  - TC-12
  - TC-13
source:
  adapt: ADAPT-001
  adapt-section: "Forward §3"       # see canonical identifier §8.4
```

### 8.6.2 TR.implements-spec[]

A TR (task) references its SR (parent in the tree) + one or more SPEC through `implements-spec[]`:

```yaml
id: TR-42
title: "Implement endpoint POST /orders"
parent:
  id: SR-05
implements-spec:
  - SPEC-API-02
  - SPEC-DATA-03
verified-by:
  - TC-14
```

### 8.6.3 SPEC.depends-on[]

A SPEC MAY rest on another SPEC:

```yaml
id: SPEC-API-02
title: "Orders REST API"
type: SPEC-API
depends-on:
  - SPEC-DATA-03         # stable data schema
  - SPEC-SEC-01          # auth model for endpoints
```

When an upstream SPEC changes (for example SPEC-DATA-03), all downstream artifacts (SPEC-API-02 and the SR linked through it) MUST be reviewed: either `verified` is reconfirmed (the change is compatible), or the downstream artifact passes re-verification through its own state machine ([§10.7](10-lifecycle-qg.md#10.7)) and, until that completes, is not considered `verified` with respect to the new upstream version.

### 8.6.4 Auto-derived inverse edges

`SPEC.referenced-by[]` is recomputed by a substrate hook after each change to SR / TR / SPEC. An orphan SPEC (without `referenced-by[]` and without an active status) is a warning in the quality report.

---

## 8.7 Migration UIC / AIC / INT-SR / TS → SPEC-*

### 8.7.1 Mapping table

| Old type | New type | Migration kind |
|---|---|---|
| `UIC-NN` | `SPEC-UI-NN` | Rename ID + move to `specs/ui/` |
| `AIC-NN` | `SPEC-AI-NN` | Rename ID + move to `specs/ai/` |
| `INT-SR-NN` | `SPEC-INT-NN` | Rename ID + move to `specs/int/` |
| `TS-NN` | `SPEC-<TYPE>-NN` (distribution) | Manual review of each TS; an AI agent classifies the content, the architect approves in one click |

### 8.7.2 Atomic migration

Migration is one atomic change unit ([V2](03-substrate-versioning.md#3.3.2)) at the project level. Parallel existence of the old types (UIC / AIC / INT-SR / TS) and SPEC-* as the source of truth is prohibited.

Procedure (substrate-independent):

1. Preparation: an AI agent classifies each existing TS-NN into one of the 9 SPEC types.
2. The architect approves the classification.
3. Atomic change: rename IDs (UIC→SPEC-UI; AIC→SPEC-AI; INT-SR→SPEC-INT; TS→SPEC-*), move files to `specs/<type>/`, update all references in BR / SR / TR / TC frontmatter (`parent: UIC-NN` → `constrained-by: [SPEC-UI-NN]`).
4. Regeneration of auto-derived files (REQUIREMENTS.md, SPECS.md, inverse edges).
5. CI check: absence of orphan references and old IDs.

### 8.7.3 ID immutability

After migration, SPEC IDs are **immutable** (see [V1, §3.3.1](03-substrate-versioning.md#3.3.1)). Renaming `SPEC-API-02` → `SPEC-API-08` is prohibited. Replacement is through `deprecated` + a new ID with `replaces[]`.

---

## 8.8 Quality gates for SPEC

A SPEC has a dedicated state machine ([chapter 10 §10.3](10-lifecycle-qg.md)):

| State | Transition condition |
|---|---|
| `draft` | Created; mandatory frontmatter fields are being filled |
| `review` | Ready for review; mandatory body sections (§8.4.1) and type-specific ones (§8.5) are present |
| `approved` | The architect confirmed; `depends-on[]` consistency checked |
| `verified` | All mandatory spec-specific TC ([chapter 9 §9.7](09-test-cases.md)) are green |
| `obsolete` | Replaced or no longer relevant; `replaced-by` is mandatory |

Link to QG-0 / QG-2 of SENAR:

- QG-0 (the task has a goal/AC) is extended: for tasks implementing a SPEC, `implements-spec[]` in the TR frontmatter is mandatory.
- QG-2 (a `done` task has evidence) is extended: for tasks implementing a SPEC, a TC of the corresponding spec-specific kind ([chapter 9 §9.7](09-test-cases.md)) is mandatory.

---

## 8.9 Storage layout

### 8.9.1 At the system level

```text
[requirements-substrate]/      # root of the requirements substrate (layout — guide/03 or guide/04)
  br/
  sr/
  specs/
    arch/   SPEC-ARCH-NN-*.md
    api/    SPEC-API-NN-*.md
    data/   SPEC-DATA-NN-*.md
    ui/     SPEC-UI-NN-*.md
    ai/     SPEC-AI-NN-*.md
    int/    SPEC-INT-NN-*.md
    proc/   SPEC-PROC-NN-*.md
    sec/    SPEC-SEC-NN-*.md
    ops/    SPEC-OPS-NN-*.md
  adapt/
  tz/
  SPECS.md                # auto-generated index
```

> All 9 SPEC types ([§8.3](#83-the-closed-list-of-nine-spec-types)) are allowed at any `level`; the `specs/<type>/` subfolders are created as needed — not all are mandatory at the system level.

### 8.9.2 At the subsystem level

```text
[subsystem-substrate]/         # subsystem scope
  br/                     # if it has its own business side
  sr/
  specs/
    arch/   SPEC-ARCH-NN-*.md      # subsystem architecture
    api/    SPEC-API-NN-*.md
    data/   SPEC-DATA-NN-*.md
    ui/     SPEC-UI-NN-*.md
    ai/     SPEC-AI-NN-*.md
    int/    SPEC-INT-NN-*.md
    proc/   SPEC-PROC-NN-*.md
    sec/    SPEC-SEC-NN-*.md
    ops/    SPEC-OPS-NN-*.md
  adapt/
  SPECS.md
```

The substrate-native storage implementation is substrate-specific (see [guide/03](../../guide/en/03-tool-guide-git.md), [guide/04](../../guide/en/04-document-store-substrate.md)).

### 8.9.3 SPECS.md — auto-generated index

`SPECS.md` is an auto-generated registry of all SPEC: ID, type, title, status, link to the verifiable requirement, link to the file. Marked `linguist-generated=true`. Regeneration triggers — every change to SPEC frontmatter or every approve / verify gate.

---

## 8.10 Links to other chapters

| Chapter | Link |
|---|---|
| [02 Methodology positioning](02-methodology-positioning.md) | SPEC as a parallel axis — a consequence of the Source-of-Truth inversion |
| [06 Requirements hierarchy](06-requirements-hierarchy.md) | `SR.constrained-by[]`, `TR.implements-spec[]` |
| [07 ADAPT](07-adapt.md) | SPEC references ADAPT through `source.adapt` |
| [09 Test cases](09-test-cases.md) | Spec-specific TC types (the table of mandatory TC kinds for each SPEC type) |
| [10 Lifecycle and QG](10-lifecycle-qg.md) | SPEC state machine + QG extensions for SPEC |
| [03 Substrate versioning](03-substrate-versioning.md) | SPEC IDs are immutable (V1); migration is atomic (V2) |
| [11 Maturity model](11-maturity-model.md) | RENAR-3+: all 9 SPEC types where applicable |
| [reference/02 — schemas](../../reference/en/02-schemas.md) | Full machine-readable schema for each type-specific extension |
| [reference/05 — knowledge graph schema](../../reference/en/05-knowledge-graph-schema.md) | `constrained-by[]`, `implements-spec[]`, `depends-on[]` as edge types in the graph |
