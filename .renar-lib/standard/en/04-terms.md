---
title: "Terms and Definitions"
order: 4
lang: en
---
# 04. Terms and Definitions

> **Part of the RENAR Standard v1.0-draft** · [← Table of contents](README.md)

## 4.1 Why a single vocabulary of terms

The same word often means different things to two teams: for one a "spec" is an SR, for another a screen mock-up, for a third a whole API contract. As long as terms float, traceability collapses and any conversation about conformance stalls. This chapter removes the ambiguity: a reference of phrasings read when aligning artifacts, checking the substrate, and preparing a conformance assessment. It fixes one name per concept and so quenches terminological drift between teams and tools. After the table of contents, go to §4.3–§4.5 for artifact types, §4.6–§4.7 for statuses and gates, §4.8–§4.10 for substrate and provenance, §4.11/§4.14 for drift classes and forbidden terms; the index of closed lists — [§1.7.5](01-scope.md#1.7.5).

The chapter normalizes the **canonical terminology of RENAR**: one definition per concept; a single source of truth for the other chapters, implementation substrates, and conformance-checking tools. Terminological drift ([§4.11](#411-drift-classes-closed-list)) is a distinct class of conformance violations ([§13.3.1](13-conformance.md#13.3.1) indirectly).

The chapter does **not** duplicate [reference/01-glossary.md](../../reference/en/01-glossary.md): this chapter contains the **canonical normative** short-form definitions; `reference/01` provides expanded explanations with anti-patterns, history, and industry context (informational material).

---

## 4.2 The "canonical only" principle

RENAR picks **one canonical term** per concept. Inside the substrate (frontmatter, IDs, normative body paragraphs, scripts, CI hooks) **only the canonical term** is used. The mapping to related standards (§4.13) is for documentation, migration, and integration with external systems; inside the substrate, replacing the canonical term with an equivalent from the mapping table **does not happen**.

When a non-canonical term (per §4.14) is detected in a normative artifact, the substrate-native hook ([§10.11.1](10-lifecycle-qg.md#10.11.1)) MUST raise a warning on the change-set; for RENAR-4+ ([§11.7](11-maturity-model.md#11.7)) — a blocking error.

Multilingual projects MAY display the canonical terminology in the UI in the client's language (§4.13.3); this is a **UI translation**, not a canonical replacement.

---

## 4.3 Requirement artifacts

### 4.3.1 TZ — source requirements artifact

**TZ** (`TZ-YYYY-NNN`) is an **immutable** ([§7.4.2](07-adapt.md#7.4.2)) contractual artifact recording the obligations between the client and the engineering team. Once registered in the substrate it is not edited. Changes go through a delta-TZ as a new immutable artifact ([§7.6](07-adapt.md#7.6)).

### 4.3.2 ADAPT — bridge artifact

**ADAPT** (`ADAPT-NNN`) is a mandatory bridge artifact ([§7.4.1](07-adapt.md#7.4.1)) between the TZ and the requirements hierarchy. It contains Forward (the engineering interpretation) + Backward (questions to the client) sections. Each TZ MUST have exactly one root ADAPT in status `approved` ([§13.3.3](13-conformance.md#13.3.3)). Lifecycle: §4.6.4.

### 4.3.3 BR — Business Requirement

**BR** (`BR-NN`) is a business-level artifact. It describes an observable business effect (`business-outcome`), not the way of achieving it. It decomposes into SR. Frontmatter — [§6.5.2](06-requirements-hierarchy.md#6.5.2). Lifecycle: §4.6.1.

### 4.3.4 SR — System Requirement

**SR** (`SR-NN`) is a system-level artifact. It describes the mandatory behavior of the system within a single business effect. It has a parent BR (`parent: BR-N`) or a parent SR (when `level: subsystem` or `level: module` — [§6.7](06-requirements-hierarchy.md#6.7)). Frontmatter — [§6.6.2](06-requirements-hierarchy.md#6.6.2). Lifecycle: §4.6.1.

### 4.3.5 TR — Task Requirement

**TR** (`TR-NN`) is an implementer task-level artifact. It describes a practically executable piece of work with goal + AC. It has an implementation chain `implements: SR-N` (or BR for trivial tasks). Frontmatter — [§6.7.2](06-requirements-hierarchy.md#6.7.2). Lifecycle: §4.6.2.

### 4.3.6 Hierarchy

The requirements hierarchy:

```text
TZ → ADAPT → BR → SR → TR → implementation
                  │
                  └── SPEC-* (parallel axis, §4.4)
```

An SR MAY implement a SPEC through `implements-spec[]` ([§8.6.2](08-specifications.md#8.6.2)) — this is a **link**, not a parent edge.

---

## 4.4 SPEC artifacts

**SPEC** is an artifact of the structural description of the system as a parallel axis to the requirements ([§8.2](08-specifications.md#8.2)). It is not a parent edge with SR; it is linked through `constrained-by[]` / `implements-spec[]` ([§8.6](08-specifications.md#8.6)). Lifecycle: §4.6.3.

### 4.4.1 Closed list of the 9 SPEC types

Closed list ([§8.3](08-specifications.md#8.3)):

| Type | Purpose |
|---|---|
| `SPEC-ARCH` | System architecture (contexts, containers, components, deployment view, quality attributes) |
| `SPEC-API` | API contracts (REST / GraphQL / gRPC / async events) |
| `SPEC-DATA` | Data model (schema, ERD, migrations, retention, PII classification) |
| `SPEC-INT` | Integration (interaction between subsystems and external systems) |
| `SPEC-PROC` | Process / workflow (business processes, state machines, saga) |
| `SPEC-UI` | UI / UX (screens, navigation, accessibility, baselines) |
| `SPEC-AI` | AI / ML (model cards, RAG, prompt engineering, eval strategy) |
| `SPEC-SEC` | Security (authn / authz, threat model, secrets management) |
| `SPEC-OPS` | Operations (deployment, observability, SLO/SLA, runbook) |

A project MUST NOT create new SPEC types locally ([§13.3.4](13-conformance.md#13.3.4)).

---

## 4.5 Testing artifacts

### 4.5.1 TC — Test Case

**TC** (`TC-NN`) is an artifact of a verifiable criterion. It covers the normative assertions of BR / SR / SPEC (through `verifies[]` with a version pin, [§9.4](09-test-cases.md#9.4)). Lifecycle: §4.6.5.

### 4.5.2 Closed list of TC types (`tc-type`)

Closed list ([§9.5](09-test-cases.md#9.5)):

| `tc-type` | Purpose |
|---|---|
| `acceptance` | E2E tests of the business goal for BR ([§9.5](09-test-cases.md#9.5)); runner-family: E2E + AI validator |
| `ux` | UX tests with a VLM judge ([§9.6.1](09-test-cases.md#9.6.1)) for SPEC-UI |
| `system` | General-purpose system tests for SR / SPEC-PROC / SPEC-ARCH ([§9.5](09-test-cases.md#9.5)) |
| `contract` | Contract tests ([§9.6.3](09-test-cases.md#9.6.3)) for SPEC-API / SPEC-INT / SPEC-DATA |
| `eval` | Eval tests for SPEC-AI with an LLM judge ([§9.6.2](09-test-cases.md#9.6.2)); the judge model MUST differ from the implementation model |
| `security` | Security tests ([§9.6.4](09-test-cases.md#9.6.4)) for SPEC-SEC by STRIDE categories |

### 4.5.3 Pos / neg pairing

Normative requirement ([§9.7](09-test-cases.md#9.7)): every normative assertion is covered by a **pair** of TC (positive scenario + negative scenario). Single-TC coverage is permitted only for invariant assertions (security STRIDE).

---

## 4.6 Lifecycle statuses

### 4.6.1 BR / SR

Closed list ([§10.5](10-lifecycle-qg.md#10.5)): `draft → approved → verified → accepted → deprecated`. `accepted` is a terminal non-degradable status ([§10.4.2](10-lifecycle-qg.md#10.4.2), optional); `deprecated` is terminal.

### 4.6.2 TR

Closed list ([§10.6](10-lifecycle-qg.md#10.6)): `draft → approved → done`; `obsolete` is the alternative terminal status.

### 4.6.3 SPEC

Closed list ([§10.7](10-lifecycle-qg.md#10.7)): `draft → review → approved → verified`; `obsolete` is terminal.

### 4.6.4 ADAPT

Closed list ([§10.8](10-lifecycle-qg.md#10.8)): `draft → review → client-ready → answered → approved → frozen`. `frozen` is a terminal immutable status; changes are made only through a delta-ADAPT or errata.

### 4.6.5 TC

Closed list ([§10.9](10-lifecycle-qg.md#10.9)): `draft → ready → passing / failing → obsolete`. `passing ↔ failing` are runner-managed transitions ([§10.9.3](10-lifecycle-qg.md#10.9.3)), not gate-passages.

### 4.6.6 Backward findings (sub-state in ADAPT)

Closed list ([§7.4.5](07-adapt.md#7.4.5)): `open → asked-to-client → answered → resolved → frozen`; `revised` is a return to `asked-to-client`.

### 4.6.7 Lifecycle closed lists are not locally extensible at the project level

Any status outside the closed list for the corresponding artifact type is a conformance violation ([§10.10.2](10-lifecycle-qg.md#10.10.2)).

---

## 4.7 Quality Gates

The canonical list from [§10.3](10-lifecycle-qg.md#10.3) + [§10.4](10-lifecycle-qg.md#10.4). A project MUST NOT create new gate types locally ([§10.10.2](10-lifecycle-qg.md#10.10.2), [§13.3.6](13-conformance.md#13.3.6)).

| Gate | Purpose | Conformance status |
|---|---|---|
| `QG-0` — Approval ([§10.3.1](10-lifecycle-qg.md#10.3.1)) | Approval of an artifact for development / implementation | **Required** |
| `QG-1` — Implementation ([§10.3.2](10-lifecycle-qg.md#10.3.2)) | Implementation valid (TC `draft → ready` only) | **Required** |
| `QG-2` — Verification ([§10.3.3](10-lifecycle-qg.md#10.3.3)) | Promote an artifact to `verified` | **Required** |
| `QG-3` — Architecture ([§10.4.1](10-lifecycle-qg.md#10.4.1)) | Approval of ADAPT (dual signature) / SPEC-ARCH | Optional (`declared` or `absent`) |
| `QG-4` — Acceptance ([§10.4.2](10-lifecycle-qg.md#10.4.2)) | Acceptance of a BR into `accepted` | Optional |

Runner-managed transitions (`ready → passing`, `passing → failing`, and others) are **not** Quality Gates ([§10.9.3](10-lifecycle-qg.md#10.9.3)).

---

## 4.8 Substrate terms

### 4.8.1 Substrate

**Substrate** (in fields and code — `substrate`) is the system for storing and versioning RENAR artifacts. RENAR is substrate-independent: it normalizes capabilities (§4.8.2), not tools.

### 4.8.2 Capabilities V1–V6

The closed list from [§3.3](03-substrate-versioning.md#3.3). All six are absolutely mandatory for conformance ([§13.3.2](13-conformance.md#13.3.2)):

| Capability | Semantics |
|---|---|
| `V1` — Immutable history | Any past state of an artifact is recoverable |
| `V2` — Atomic change unit | Changes are committed as "all or nothing" |
| `V3` — Diff & review | A proposed change is representable as a diff against a baseline state and passes approval before integration into the source of truth |
| `V4` — Branching / change-set | Drafts are separable from approved truth; parallel changes are independent |
| `V5` — Cross-substrate version pin | A link between substrates pins a specific version of an artifact |
| `V6` — Author and timestamp | Every atomic change unit has an identifiable author and a timestamp of ≥ second-level precision |

### 4.8.3 Atomic change unit

A substrate change (V2) satisfying the "all or nothing" property — a substrate-native transaction; intermediate inconsistent states are not observable from the outside. The concrete implementation (an atomic write in a distributed VCS, a transaction in a document store, another mechanism) is substrate-specific; the description of the forms is deferred to [`guide/`](../../guide/en/README.md).

### 4.8.4 Version pin

A substrate-native mechanism (V5) that pins a specific version of an artifact in one substrate from another through the pair `(artifact-id, version-id)`.

### 4.8.5 Audit trail

A substrate-native append-only collection of gate-passage and transition events ([§10.13](10-lifecycle-qg.md#10.13)). Each event contains a timestamp, artifact-id, artifact-version, from-status, to-status, gate-id, actor, evidence-refs. Deletion is not permitted (V1 retention, [§10.13.3](10-lifecycle-qg.md#10.13.3)).

---

## 4.9 System hierarchy

Closed list of levels ([§6.7](06-requirements-hierarchy.md#6.7), [§6.8](06-requirements-hierarchy.md#6.8)):

| Level | Purpose |
|---|---|
| `system` | The entire product as a whole; the top level; rarely used (cross-subsystem tasks) |
| `subsystem` | A subsystem (for example, a separate service, a frontend application) |
| `module` | A module within a subsystem |

The `level` field is recorded in the artifact frontmatter (BR / SR / TR). The hierarchy MAY be extended downward through subsystem → module evolution ([§6.9.1](06-requirements-hierarchy.md#6.9.1)) or back upward ([§6.9.3](06-requirements-hierarchy.md#6.9.3)).

---

## 4.10 Provenance terms

### 4.10.1 ai-provenance — canonical schema

A frontmatter block ([§11.7.1](11-maturity-model.md#11.7.1), mandatory at RENAR-4) recording the provenance of an AI-generated artifact. This section is the **single canonical source** of the schema; the chapter-level YAML examples in [§6.5.2](06-requirements-hierarchy.md#6.5.2), [§6.6.2](06-requirements-hierarchy.md#6.6.2), [§8.5](08-specifications.md#8.5), [§9.3](09-test-cases.md#9.3) refer here and do **not** define independent fields.

| Field | Mandatory? | Semantics |
|---|---|---|
| `ai-provenance.generated-by` | mandatory | Model identifier (`<vendor>-<model>-<version>@<date>`) |
| `ai-provenance.generated-at` | mandatory | UTC timestamp of generation (ISO-8601) |
| `ai-provenance.prompt-template` | mandatory | Substrate-native pointer to a prompt template (`<path>@<version>`) |
| `ai-provenance.context-tokens` | mandatory | Input context size (integer) |
| `ai-provenance.output-tokens` | mandatory | Output size (integer); source for the metrics in [§12.3](12-metrics.md#12.3) |
| `ai-provenance.human-edits` | mandatory | Boolean — whether manual edits were made after generation (informational field; see §4.10.1.1) |
| `ai-provenance.generation-time-ms` | optional | Generation latency in milliseconds; RECOMMENDED at RENAR-5 for cost/latency budget monitoring ([§11.8.1](11-maturity-model.md#11.8.1)) |
| `ai-provenance.cost-budget` | optional at RENAR-4, mandatory at RENAR-5 | Planned generation cost budget |
| `ai-provenance.cost-actual` | optional at RENAR-4, mandatory at RENAR-5 | Actual cost; source for [§12.3.9](12-metrics.md#12.3.9) Cost per Approved Requirement |

Adding new fields to the schema is done only through the formal change procedure of the standard ([§13.9](13-conformance.md#13.9)). Locally defined ai-provenance.* fields by an implementing project are a `declared-stricter` extension ([§10.10.2](10-lifecycle-qg.md#10.10.2)) and do not violate conformance, but are not considered canonical.

#### 4.10.1.1 Semantics of `human-edits`

`human-edits` is an **informational** field for traceability and observability, not a gating flag. The value `human-edits: true` means the artifact was edited manually after the initial AI generation; it does **not** trigger auto-rejection. The normative rule P3 ([§9.2](09-test-cases.md#9.2)) — "the engineer does not write TC by hand" — normalizes **provenance**, not subsequent edits. A substrate implementation MAY (`declared-stricter`) additionally require a review for artifacts with `human-edits: true`; this is a local tightening, not part of the base RENAR-N conformance.

### 4.10.2 Source citation

An inline pointer in the artifact body (mandatory at RENAR-4, [§11.7.1](11-maturity-model.md#11.7.1)) to the source of a specific normative assertion. The format is substrate-specific; typical patterns: `[TZ-XXX §Y line Z]`, `[ADAPT-NNN §A.B]`, a `derived` marker with a pointer to the parent artifact.

### 4.10.3 Traceability chain

The chain of artifacts from the TZ to a TC run, recording the provenance of each assertion:

```text
TZ → ADAPT → BR → SR → TR / SPEC → TC.last-run
```

Each link is connected through canonical frontmatter fields (§4.12). The trace chain is the source of truth for the conformance review ([§12.5.3](12-metrics.md#12.5.3)).

---

## 4.11 Drift classes (closed list)

A closed list of eight classes of violations of the requirements infrastructure. Changing the list is a formal change procedure of the standard ([§13.9.3](13-conformance.md#13.9.3)). The substrate-native hook ([§10.11.1](10-lifecycle-qg.md#10.11.1)) MUST detect each class at the corresponding enforcement point.

| # | Class | What is violated | Enforcement point |
|---|---|---|---|
| 4.11.1 | Schema drift | An artifact's frontmatter does not conform to the mandatory schema [ch. 06](06-requirements-hierarchy.md)/[08](08-specifications.md)/[09](09-test-cases.md) | Substrate hook on the change-set; RENAR-3+ — blocking ([§11.6.1](11-maturity-model.md#11.6.1)) |
| 4.11.2 | Lifecycle drift | An artifact is outside the closed list of statuses (§4.6) or has gone through a forbidden transition ([§10.12](10-lifecycle-qg.md#10.12)) | Substrate hook on the promote-transition |
| 4.11.3 | Source-of-truth drift | Implementation code / a derived artifact diverges from the SR / SPEC it references through `verifies[].version` (V5) | Reconciliation hook RENAR-4+; registered as a backward finding in a delta-ADAPT |
| 4.11.4 | Implementation drift | The implementation substrate has stopped referencing the current `version` of the requirements substrate (the V5 pin is stale) | Auto-invalidate `verified` ([§10.5.4](10-lifecycle-qg.md#10.5.4)) |
| 4.11.5 | Terminological drift | Use of a non-canonical term (§4.14) in a normative artifact | Substrate hook on the change-set; RENAR-4+ — blocking |
| 4.11.6 | Order / provenance drift | An artifact references a source in a lower status than the [§10.3.1](10-lifecycle-qg.md#10.3.1) reference-validation requires | Substrate hook ([§10.11.1](10-lifecycle-qg.md#10.11.1)) blocks the change-set |
| 4.11.7 | TC ↔ requirement provenance drift | A TC has lost its `verifies[]` reference or `last-run.requirement-version` does not match the current `version` | Runner-managed: the TC is moved to `failing` ([§10.9.3](10-lifecycle-qg.md#10.9.3)) until a re-run |
| 4.11.8 | Test-fitting drift | A TC's Pass / Fail criteria are changed simultaneously with the implementation code so that a failing TC becomes passing without addressing the root cause ([§9.13](09-test-cases.md#9.13)) | Substrate hook via the `[test-spec-change]` marker; a single person cannot approve both change-sets ([§10.11.3](10-lifecycle-qg.md#10.11.3)) |

---

## 4.12 Connection field terms (frontmatter)

Canonical names of the fields recording links between artifacts:

| Field | Source artifact | Semantics |
|---|---|---|
| `parent` | BR / SR | A single parent in the hierarchy (BR-NN or SR-NN) |
| `children[]` | BR / SR | Auto-derived reverse edge ([§6.x](06-requirements-hierarchy.md)) |
| `implements` | TR | Implementation chain (`SR-N` or `BR-N`) |
| `implements-spec[]` | TR | Implementation of SPEC-* specifications ([§8.6.2](08-specifications.md#8.6.2)) |
| `constrained-by[]` | SR | Constraints from SPEC-* ([§8.6.1](08-specifications.md#8.6.1)) |
| `depends-on[]` | SPEC | Dependency graph between SPECs ([§8.6.3](08-specifications.md#8.6.3)) |
| `verifies[]` | TC | Closed list of verifiable artifacts with `version` ([§9.4](09-test-cases.md#9.4)) |
| `verified-by[]` | BR / SR / SPEC | Auto-derived reverse edge from `verifies[]` |
| `source.adapt` | BR / SR / SPEC | The ADAPT from which the artifact was derived |
| `replaces` / `replaced-by` | Any | Replacement on deprecation ([§10.5.3](10-lifecycle-qg.md#10.5.3)) |
| `supersedes` | A new version of an artifact | Which artifact is being replaced (in lieu of "reviving" an obsolete one) |
| `last-run` | TC | Result of the last runner run ([§9.12](09-test-cases.md#9.12)); bot-managed only |

The full schema of each artifact — in [reference/02-schemas.md](../../reference/en/02-schemas.md).

---

## 4.13 Mapping to related standards

### 4.13.1 Requirement artifacts

| RENAR canonical | SENAR (RU) | ISO/IEC 29148 | BABOK v3 | SAFe |
|---|---|---|---|---|
| `BR` (Business Requirement) | БТ (Бизнес-требование) | Business Requirement | Business Need | Portfolio Epic / Strategic Theme |
| `SR` (System Requirement) | СТ (Системное требование) | System Requirement / Software Requirement | Solution Requirement (Functional) | Feature |
| `TR` (Task Requirement) | ТЗ (Требование к задаче) | (no direct class; detailing of a system / system-element requirement) | Solution Requirement (detailed) | Story |
| `ADAPT` | (RENAR-extension) | (n/a — formalised bridge artefact) | Stakeholder Requirement workshop output | (n/a) |
| `TC` (Test Case) | ТК | Test Case (verifiable item) | Verification artefact | Story acceptance test |
| `SPEC-*` (9 types) | (RENAR-extension) | Design Description (subset) | Solution Component (subset) | Enabler tech spec (subset) |

### 4.13.2 Lifecycle statuses

| RENAR canonical | ISO/IEC 29148 | CMMI |
|---|---|---|
| `draft` | proposed | identified |
| `approved` | agreed-to / baselined | committed |
| `verified` | verified | validated |
| `accepted` | accepted | accepted |
| `deprecated` / `obsolete` | retired / superseded | obsolete / superseded |

### 4.13.3 Multilingual UI

Multilingual projects MAY display the canonical terminology in the UI in the client's language (RU example):

| English (canonical) | Russian (UI translation) |
|---|---|
| Business Requirement | Бизнес-требование |
| System Requirement | Системное требование |
| Test Case | Тест-кейс |
| Quality Gate | Контрольная точка качества |
| Acceptance | Приёмка |
| Verified | Проверено |
| Approved | Утверждено |
| Deprecated | Устарело |

This is **a UI translation only**. Frontmatter, IDs, file names, and normative body paragraphs are always canonical latin / the canonical RU from this chapter.

---

## 4.14 Forbidden / deprecated terms

A closed list of non-canonical terms; the RENAR-4+ substrate hook is blocking on detection in a normative artifact ([§4.2](#42-the-canonical-only-principle)).

| Forbidden term | Canonical replacement | Why |
|---|---|---|
| "User Story" as a requirement | `SR` | A story is a unit of planning, not a requirement; a story MAY implement an SR through `implements` |
| "Use Case" (formally, as an artifact) | `SPEC-UI` + `SR` | A use case mixes UX and behavior; RENAR separates SPEC-UI (UX) and SR (behavior) |
| "Spec" (as a generic term) | A concrete `SPEC-*` or `requirement` / `SR` | "Spec" is ambiguous; we use precise terms |
| "Business logic" | `SR` | A code term, not a requirements term |
| "Functionality" | `SR` / `TR` | Too broad |
| "Feature" (as a requirement) | `BR` (business level) or `Feature` in a SAFe context (not RENAR canonical) | Ambiguous; RENAR uses BR |
| "Wish-list item" | (never) | A contractual document is not written this way |
| "Epic" (as a requirement) | `BR` (business level) | An epic is a unit of planning, not a requirement |

### 4.14.1 Deprecated RENAR-specific labels

When migrating from pre-v1.0 draft material, deprecated labels are encountered:

| Deprecated label | Canonical v1.0 replacement |
|---|---|
| `UIC` (UI Concept) | `SPEC-UI` ([§8.5.6](08-specifications.md#8.5.6)) |
| `AIC` (AI Concept) | `SPEC-AI` ([§8.5.7](08-specifications.md#8.5.7)) |
| `TS` (Technical Specification) | `SPEC-ARCH` or `SPEC-OPS` depending on the content |
| `INT-SR` (Integration SR) | `SR` with `constrained-by: [SPEC-INT-N]` |
| `INT-TC` (Integration TC) | `TC` with `tc-type: contract` |
| `TM` (Module/Submodule SR) | `SR` with `level: module` ([§6.7](06-requirements-hierarchy.md#6.7)) |
| `QG-0 Context Gate` (old) | `QG-0 Approval Gate` (canonical v1.0, [§10.3.1](10-lifecycle-qg.md#10.3.1)) |
| `QG-1 Requirements Gate` (old) | `QG-1 Implementation Gate` (canonical v1.0, [§10.3.2](10-lifecycle-qg.md#10.3.2)) — semantic shift: previously approval of BR/SR, now only TC `draft → ready` |
| `QG-2 Implementation Gate` (old) | `QG-1 Implementation Gate` (canonical v1.0, [§10.3.2](10-lifecycle-qg.md#10.3.2)) |
| `QG-3 Verification Gate` (old) | `QG-2 Verification Gate` (canonical v1.0, [§10.3.3](10-lifecycle-qg.md#10.3.3)) |

Migrating an existing requirements substrate with old labels is a separate one-off process; the substrate-native hook on the change-set MUST auto-detect deprecated labels and propose canonical replacements.

---

## 4.15 Order of dispute resolution (Authority)

When there is a disagreement over a term, the order of recourse is:

1. **This chapter (§4)** — canonical for the RENAR Standard.
2. **The corresponding chapter of the standard** (06–14) — for artifact-specific semantics (for example, ADAPT specifics — in [§7](07-adapt.md)).
3. **SENAR §3** (terminology of the parent standard).
4. **ISO/IEC 29148:2018** — for general-engineering requirements terminology.
5. **BABOK v3** — for business-analysis terms.
6. **Fixing it through the formal change procedure** of the standard ([§13.9.3](13-conformance.md#13.9.3)) — if all of the above are silent.

**Do not use** as a source of terminology:

- Tickets in ticket systems (often contradictory).
- Team chats (slang ≠ canonical).
- Presentations and old draft material.
- Marketing material.

---

## 4.16 Relationship to other chapters

| Chapter | Relationship |
|---|---|
| [02 Methodology positioning](02-methodology-positioning.md) | [§2.3](02-methodology-positioning.md#2.3) Source-of-Truth inversion + [§2.5](02-methodology-positioning.md#2.5) substrate-independent versioning — the foundation for §4.8 substrate terms |
| [06 Requirements hierarchy](06-requirements-hierarchy.md) | BR / SR / TR artifact frontmatter — §4.3, §4.9, §4.12 links |
| [07 ADAPT](07-adapt.md) | ADAPT specifics — §4.3.2, §4.6.4, §4.6.6 backward sub-states |
| [08 Specifications](08-specifications.md) | SPEC-* types — §4.4, §4.6.3 SPEC lifecycle |
| [09 Test cases](09-test-cases.md) | TC — §4.5, §4.6.5; pos/neg pairing — §4.5.3 |
| [10 Lifecycle and QG](10-lifecycle-qg.md) | Canonical Quality Gates — §4.7; state machines by type — §4.6; closed-list policy — [§10.10](10-lifecycle-qg.md#10.10) in parallel with §4.11 / §4.14 |
| [03 Substrate versioning](03-substrate-versioning.md) | V1–V6 definitions — §4.8.2 |
| [11 Maturity model](11-maturity-model.md) | ai-provenance mandatory at RENAR-4+ — §4.10 (criterion source — [§11.7.1](11-maturity-model.md#11.7.1)) |
| [12 Metrics](12-metrics.md) | Drift classes §4.11 — source for metrics such as Reconciliation Findings ([§12.3.10](12-metrics.md#12.3.10)) |
| [13 Conformance](13-conformance.md) | [§13.3](13-conformance.md#13.3) mandatory clauses reference the canonical terminology of this chapter |
| [reference/01-glossary.md](../../reference/en/01-glossary.md) | Expanded explanations, anti-patterns, history — non-normative |

