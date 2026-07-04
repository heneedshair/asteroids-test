---
title: "Glossary"
description: "Canonical RENAR terminology and mapping to ISO/IEC 29148, BABOK, SAFe, ISTQB, SENAR."
order: 1
lang: en
version: "1.0-reconciled"
---

# RENAR Glossary

> **Purpose:** the single source of canonical RENAR terms with examples and a mapping to industry standards. On a wording conflict, [`standard/04-terms.md`](../../standard/en/04-terms.md) wins **normatively**; this glossary is an informative lookup for the reader and the assessor.

---

<a id="1-authority-chain"></a>

## 1. Authority chain

When a term is disputed, the following order applies:

1. **[`standard/04-terms.md`](../../standard/en/04-terms.md)** — the normative canon: a standard chapter's definitions win on any conflict.
2. **This document** — informative clarifications and mapping to industry standards; does not override `standard/04`.
3. **ISO/IEC/IEEE 29148** — the international requirements-engineering standard.
4. **BABOK Guide v3** — the *Business Analysis Body of Knowledge*.
5. **A change via an amendment proposal to the full RENAR Standard** — when all sources are silent.

**Closed lists:** the master index of the sixteen closed lists is [`standard/01 §1.7.5`](../../standard/en/01-scope.md#1.7.5).

**Not used as a source of terms:** bug-tracker tickets, team chats (slang), outdated slide decks, marketing materials.

---

## 2. Canonical terms

### 2.1 Requirement levels

The v1.0 canon is a closed list (see [`standard/04-terms.md §4.3`](../../standard/en/04-terms.md#4.3)):

| RENAR (canonical) | Full name | RU UI label (reference) | Description |
|---|---|---|---|
| **BR** | Business Requirement | Бизнес-требование | A customer-level business goal: what the organization wants to obtain. |
| **SR** | System Requirement | Системное требование | An engineering requirement for the software; verifiable. One `SR` is one verifiable unit. |
| **TR** | Task Requirement | Требование к задаче | An implementation-level requirement derived from an `SR`; the unit of work planning. |
| **TC** | Test Case | Контрольный пример (TC) | A verifiable artifact that confirms an `SR`/`BR`. Describes behavior, not implementation. |

**Identification rule:** in `frontmatter`, `id` is the canonical RENAR identifier (`BR-01`, `SR-05`). On export to another substrate, a target mapping applies.

Refinements of `SR` (frontmatter fields, not separate artifact types):

- **Module SR** — an `SR` with `level: module` ([`standard/06 §6.7`](../../standard/en/06-requirements-hierarchy.md#6.7)). Formerly the separate label `TM` ([§2.1.1](#211-legacy-labels-deprecated)).
- **Integration SR** — an `SR` with `constrained-by: [SPEC-INT-N]`. Formerly the separate label `INT-SR` ([§2.1.1](#211-legacy-labels-deprecated)).
- **Contract TC** — a `TC` with `tc-type: contract`. Formerly the separate label `INT-TC` ([§2.1.1](#211-legacy-labels-deprecated)).

The `SPEC` family (UX / AI / architecture / integration specifications) — see [§2.5 The `SPEC` family](#25-spec-family-closed-list).

#### 2.1.1 Legacy labels (deprecated)

When migrating from pre-v1.0-draft material, deprecated labels appear. Their replacements in the v1.0 canon ([`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1)):

| Legacy label | v1.0 canonical replacement | Note |
|---|---|---|
| `TM` (Module/Submodule SR) | `SR` with `level: module` | A refinement of `SR`, not a separate artifact type |
| `UIC` (UI Concept) | `SPEC-UI` ([`standard/08 §8.5.6`](../../standard/en/08-specifications.md#8.5.6)) | Part of the `SPEC` family ([§2.5](#25-spec-family-closed-list)) |
| `AIC` (AI Concept) | `SPEC-AI` ([`standard/08 §8.5.7`](../../standard/en/08-specifications.md#8.5.7)) | Part of the `SPEC` family |
| `INT-SR` (Integration SR) | `SR` with `constrained-by: [SPEC-INT-N]` | A subclass of `SR` |
| `INT-TC` (Integration TC) | `TC` with `tc-type: contract` | A subclass of `TC` |
| `TS` (Technical Specification) | `SPEC-ARCH` or `SPEC-OPS`, depending on content | Part of the `SPEC` family |

**Migrating existing artifacts:** the substrate-native binding to a change set MUST automatically recognize deprecated labels and offer the canonical replacements. The canonical legacy → v1.0 mapping table is [`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1).

### 2.2 ADAPT artifact family

| Term | Description |
|---|---|
| **ADAPT** | The Adaptive Document for Articulating a Project's TZ. A two-way engineering adaptation of the TZ: the forward direction (interpretation) and the backward direction (questions). Approved by dual signature. |
| **delta-ADAPT** | An `ADAPT` for a delta-TZ. Chain: ADAPT-001 → ADAPT-001-delta-1 → ADAPT-001-delta-2; applied in order. |
| **errata-ADAPT** | A correction to an approved `ADAPT` (our own interpretation error). It does not alter the frozen document — a separate artifact is added. |
| **Forward (in ADAPT)** | The engineering interpretation of each TZ section: quote → interpretation → elaborated scenarios → coverage. |
| **Backward (in ADAPT)** | The list of problems and questions for the client. Lifecycle: `open` → `asked-to-client` → `answered` → `resolved` → `frozen`. |
| **Term mapping (in ADAPT)** | A "client term → engineering understanding" table. |

### 2.3 Backward categories (closed list)

Every ADAPT backward entry belongs to one of 7 categories. The list is closed; new ones are added only through a change to the full RENAR Standard:

| Category | Description |
|---|---|
| `contradiction` | A contradiction within the TZ. |
| `gap` | A gap — the TZ is silent on this. |
| `hidden-assumption` | A hidden engineering assumption that needs confirmation. |
| `feasibility` | A technically infeasible or expensive requirement. |
| `regulatory` | Touches legislation / compliance. |
| `terminology` | An unclear or conflicting client term. |
| `scope` | A scope-boundary clarification (in / out). |

### 2.4 Quality Gates (closed list, v1.0 canon)

The closed list of RENAR Quality Gates (per [`standard/10-lifecycle-qg.md §10.3–10.4`](../../standard/en/10-lifecycle-qg.md#10.3)):

| Gate | Applies to | Pass condition |
|---|---|---|
| **QG-0** Approval Gate | `BR`/`SR`/`SPEC` transition: `draft` → `approved` | Goal, acceptance criteria, at least one negative scenario, and coverage; for `SR` — the parent `BR` in `approved`+; for an `SR` with `constrained-by` — the `SPEC` in `approved`+. |
| **QG-1** Implementation Gate | `TC` transition: `draft` → `ready` (**only** for `TC`) | The `TC`'s `verifies` field points to an artifact in `approved`+; `requirement-version` matches; implementation coverage and the version pin are recorded. |
| **QG-2** Verification Gate | `SR`/`BR` transition: `approved` → `verified` | All `TC`s from `verified-by` are green; at least one `TC` with `negative: true`; `last-run` has a `requirement-version` matching the current `version`; the spot-check passed. |
| **QG-3** Architecture Gate (*optional*) | `SPEC-ARCH` approval / dual signature | An ADR-style artifact is recorded in the substrate; dual signature (client + Architect). Not REQUIRED for declared RENAR conformance. |
| **QG-4** Acceptance Gate (*optional*) | `BR` transition: `verified` → `accepted` | All `BR`s are covered by verified `SR`s; acceptance `TC`s (`tc-type: acceptance`) are green; client signature. Not REQUIRED for declared RENAR conformance. |

**RENAR conformance:** `QG-0` / `QG-1` / `QG-2` are mandatory for declared conformance ([`standard/13 §13.3`](../../standard/en/13-conformance.md#13.3)). `QG-3` / `QG-4` are optional extensions.

The list is closed; new gate numbers are added only through the formal change procedure of the full RENAR Standard.

#### 2.4.1 Legacy QG names (deprecated)

Before v1.0, RENAR used different gate names. The mapping per [`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1):

| Legacy (pre-v1.0) | v1.0 canonical replacement | Note |
|---|---|---|
| `QG-0 Context Gate` | `QG-0 Approval Gate` | Rename only; meaning preserved |
| `QG-1 Requirements Gate` | `QG-1 Implementation Gate` | **Meaning shift:** formerly `BR`/`SR` approval, now only the `TC` transition `draft` → `ready` |
| `QG-2 Implementation Gate` | `QG-1 Implementation Gate` | Renumbered and merged into a single `QG-1` |
| `QG-3 Verification Gate` | `QG-2 Verification Gate` | Renumbered |
| `QG-4 Acceptance Gate` | `QG-4 Acceptance Gate` | Same name; now **optional** for declared RENAR conformance |

**Migrating existing artifacts:** automation rewrites references per the table above. The canonical legacy QG → v1.0 mapping table is [`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1).

#### 2.4.2 Local ADAPT gates

The `ADAPT` lifecycle ([`standard/07-adapt.md`](../../standard/en/07-adapt.md)) uses local `ADAPT` gates alongside the canonical `QG-N`. These are not a separate `QG` numbering but local lifecycle events of the `ADAPT` artifact:

| Gate | Application | Pass condition |
|---|---|---|
| **QG-ADAPT-draft** | `ADAPT` creation | The Forward section covers every TZ section. |
| **QG-ADAPT-review** | Transition to `review` | All backward entries are `open` or `asked-to-client`; none are `draft`. |
| **QG-ADAPT-client-ready** | Handover to the client | All backward entries are `asked-to-client`; the question package is assembled. |
| **QG-ADAPT-answered** | After the client answers | All backward entries are `answered`. |
| **QG-ADAPT-approve** | `ADAPT` approval | All backward entries are `resolved`; dual signature (client + Architect). |
| **QG-ADAPT-frozen** | After approval | Immutability; generation of `BR`/`SR`/`SPEC` is permitted. |

Local `ADAPT` gates are **not** part of the `QG-0`/`QG-1`/`QG-2` set for declared RENAR conformance. An implementation MAY express `QG-ADAPT-approve` as a local alias for `QG-3` (`Architecture Gate`, where applicable) or store it separately — at the substrate's discretion.

<a id="25-spec-family-closed-list"></a>

### 2.5 The SPEC family (closed list)

| Type | Purpose | Source |
|---|---|---|
| **SPEC-ARCH** | System / subsystem architecture: contexts, containers, components, deployment view, quality attributes | ADAPT Forward section |
| **SPEC-API** | API contracts (REST / GraphQL / gRPC / async events); versioning, error model, rate limits | ADAPT Forward section |
| **SPEC-DATA** | Data model: schema, ER diagram, indexes, migrations, storage, personal-data classification | ADAPT Forward section |
| **SPEC-INT** | Integration: interaction between subsystems and external systems; protocols, contracts, SLAs | ADAPT Forward section |
| **SPEC-PROC** | Process / workflow: business processes, state machines, saga patterns, orchestration and choreography | ADAPT Forward section |
| **SPEC-UI** | UI / UX: screens, navigation, user scenarios, accessibility, localization, baseline images | ADAPT Forward section |
| **SPEC-AI** | AI / ML: model cards, RAG, prompt engineering, evaluation strategy, cost budget | ADAPT Forward section |
| **SPEC-SEC** | Security: authentication / authorization, threat model, secrets management, data classification | ADAPT Forward section, backward regulatory findings |
| **SPEC-OPS** | Operations: deployment, observability, SLO / SLA, runbooks, disaster recovery | ADAPT Forward section |

The list is closed — exactly nine types (canon per [`standard/08 §8.3`](../../standard/en/08-specifications.md#8.3)); new `SPEC` types are added only through a change to the full RENAR Standard.

### 2.6 Lifecycle statuses

| Status | Applies to | Meaning |
|---|---|---|
| `draft` | all artifacts | In progress, not for use by others |
| `review` | all | Under review, changes possible |
| `approved` | ADAPT, SR, SPEC | Approved; immutable after dual signature (for `ADAPT`) or single signature (for `SR`/`SPEC`) |
| `verified` | SR | Confirmed by passing `TC`s and the spot-check |
| `frozen` | ADAPT | Approved and immutable; used as the source for generating `BR`/`SR`/`SPEC` |
| `deprecated` | all | Outdated, not used in new artifacts; the replacement (if any) is given by the `replaced-by` field |
| `obsolete` | research/legacy | Fully withdrawn from circulation |

<a id="27-substrate-capabilities-v1-v6"></a>

### 2.7 Substrate capabilities (V1–V6)

RENAR is not tied to a specific artifact substrate. An artifact MAY reside in any substrate that satisfies the following capabilities.

Normative definition — [`standard/03 §3.3`](../../standard/en/03-substrate-versioning.md#3.3):

| Capability | Description |
|---|---|
| **V1 — immutable history** | Any past state of an artifact can be addressably restored without loss (the revision chain is preserved for audit). |
| **V2 — atomic change unit** | A change to an artifact (or a consistent group) commits as a single transaction: fully succeeds or fully rolls back; intermediate states are not externally visible. |
| **V3 — diff & review** | A proposed change can be presented as a diff against a base version and accepted or rejected before it reaches the approved state (the basis of approval and the `QG` gates). |
| **V4 — branching & change sets** | Work in progress is separated from the approved Source of Truth; several independent changes proceed in parallel without affecting the Source of Truth. |
| **V5 — cross-substrate version pin** | A specific version of an artifact in another substrate can be pinned as a resolvable identifier (the basis of the `verifies[].requirement-version` field). |
| **V6 — author + timestamp** | For each atomic edit, an unambiguous author and timestamp are recorded (the basis of the `ADAPT` signature and the `ai-provenance` block). |

Example substrates: a distributed VCS (`git` with merge-request review), a document-oriented store with a revision chain and signatures, any DBMS with change history and signatures. RENAR does not require `git` — only the **V1–V6** capabilities.

### 2.8 AI provenance (`ai-provenance`, canonical fields)

In the `frontmatter` of any AI-generated artifact:

| Field | Type | Description |
|---|---|---|
| `ai-provenance.generated-by` | string | The model, as `<vendor>-<model>-<version>@<date>`. Example: `anthropic-claude-opus-4-7@2026-05-15`. |
| `ai-provenance.prompt-template` | string | Path to the prompt template and its version. Example: `prompts/adapt-from-tz.md@v2.1`. |
| `ai-provenance.context-tokens` | integer | Token count of the input context. |
| `ai-provenance.output-tokens` | integer | Token count of the model output. |
| `ai-provenance.generation-time-ms` | integer | Generation time in milliseconds. |
| `ai-provenance.human-edits` | boolean | `true` if a human edited the text after generation. **For approved artifacts this field MUST be `true`.** |

### 2.9 Test-case types

A closed list — six types (canon per [`standard/09 §9.5`](../../standard/en/09-test-cases.md#9.5)):

| TC type (`tc-type` field) | ISTQB correspondence | Application |
|---|---|---|
| `acceptance` | Acceptance Testing | Verifies a BR (acceptance). |
| `ux` | usability extension | Verifies a `SPEC-UI` via a VLM judge model / visual comparison against a baseline. |
| `system` | System Testing | Verifies SR, SPEC-PROC, SPEC-ARCH. |
| `contract` | Component Integration Testing | Verifies SPEC-API / SPEC-INT / SPEC-DATA via contract testing (Pact and similar). |
| `eval` | AI-specific | Verifies a `SPEC-AI` via an evaluator LLM and metrics (BLEU, accuracy, hallucination rate). |
| `security` | security extension | Verifies a `SPEC-SEC`: security invariants (STRIDE); normatively negative scenarios only ([`standard/09 §9.6.4`](../../standard/en/09-test-cases.md#9.6.4)). |

### 2.10 Links (frontmatter fields)

| Field | Purpose |
|---|---|
| `parent` | Parent in the hierarchy (BR → SR → TR); a single source. |
| `children` | Child artifacts (auto-derived). |
| `source.adapt` | The `ADAPT` the artifact is derived from (canonical for `BR`/`SR`/`SPEC`). |
| `source.adapt-section` | The `ADAPT` section (Forward §N). |
| `source.tz-section` | The TZ section (for traceability). |
| `verifies` (in `TC`) | The `SR`/`BR` the `TC` covers, with `requirement-version`. |
| `verified-by` (in `SR`) | The `TC`s that confirm the `SR` (auto-derived). |
| `derived-from` | Template and version (if the artifact was created from a template). |
| `replaces` / `replaced-by` | Replacement when status is `deprecated`. |
| `supersedes` (in the new one) | Which requirement is being superseded. |
| `linked-tasks` | Tasks implementing the `SR` (via the runtime environment, not via files). |

### 2.11 File-naming convention (default)

| Type | Pattern | Example |
|---|---|---|
| ADAPT | `adapt/ADAPT-NNN[-delta-N].md` | `adapt/ADAPT-001-main.md`, `adapt/ADAPT-001-delta-1.md` |
| BR | `br/BR-NN-<slug>.md` | `br/BR-01-notification-capture.md` |
| SR | `sr/SR-NN-<slug>.md` | `sr/SR-05-notification-feed.md` |
| Subsystem SR | `sr/<MODULE>-SR-NN.N-<slug>.md` | `sr/WMS-SR-01.2-pick.md` |
| SPEC-UI | `specs/ui/SPEC-UI-NN-<slug>.md` | `specs/ui/SPEC-UI-02-notification-feed.md` |
| SPEC-AI | `specs/ai/SPEC-AI-NN-<slug>.md` | `specs/ai/SPEC-AI-01-rag-strategy.md` |
| SPEC-INT | `specs/int/SPEC-INT-NN-<slug>.md` | `specs/int/SPEC-INT-01-auth-billing.md` |
| SPEC (generic) | `specs/<type>/SPEC-<KIND>-NN-<slug>.md` | `specs/api/SPEC-API-03-orders.md` |
| TC | `tests/TC-NN-<slug>.md` | `tests/TC-01-login-success.md` |
| TZ | `tz/TZ-YYYY-NNN.md` | `tz/TZ-2026-001.md` |
| Delta-TZ | `tz/TZ-YYYY-NNN-delta-N.md` | `tz/TZ-2026-001-delta-1.md` |
| UX baseline | `specs/ui/baselines/SPEC-UI-NN-<scenario>.png` | `specs/ui/baselines/SPEC-UI-02-feed-default.png` |
| Eval dataset | `specs/ai/eval-datasets/SPEC-AI-NN-<slug>.jsonl` | `specs/ai/eval-datasets/SPEC-AI-01-typical-queries.jsonl` |

This is the default convention; substrate-native stores MAY use a different layout, provided identifiers are stable (capability **V3**).

### 2.12 Change-record markers (informative)

In a substrate where atomic changes carry metadata (a commit message in `git`, a change-record description in a document-oriented store), the following markers are permitted:

| Marker | Purpose |
|---|---|
| `[delta:TZ-YYYY-NNN]` | A change driven by a delta-TZ. |
| `[test-spec-change]` | A change to a `TC`'s pass/fail criteria (a separate approval). |
| `[baseline-update]` | An update to a UX baseline or an eval dataset (a separate approval). |
| `[coverage]` | Automatic regeneration of coverage, test-plan, and requirement summaries (a bot). |
| `[reconciliation]` | A change by a reconciliation agent. |
| `[multi-model-disagreement]` | An artifact where AI model outputs disagree — requires manual review. |
| `[AI]` | A prefix for AI-generated changes. |

A substrate-native mechanism MAY express these markers as change-record fields, labels, or tags — the details are not normative.

---

## 3. Mapping to standards

### 3.1 Requirement levels

RENAR v1.0 canonical labels and external standards:

| RENAR | ISO/IEC 29148 | BABOK | SAFe | Document store (example enum) | SENAR (RU) |
|---|---|---|---|---|---|
| BR | Business Requirement | Business Need | Portfolio Epic / Strategic Theme | `BT` | БТ |
| SR | System / Software Requirement | Solution Requirement (Functional) | Feature | `ST` | СТ |
| SR (`level: module`) | (subcomponent scope, extension) | (subcomponent scope) | Story (sometimes) | `TM` (legacy) | СТ модуля |
| SR (`constrained-by: SPEC-INT-N`) | Interface requirement | Interface solution | Cross-feature integration | (related) | INT-СТ (legacy) |
| TR | (no direct class; refinement of a system / system-element requirement) | Detailed solution requirement | Story | `TK` | ТЗ |
| TC | Test Case | Verification | Story acceptance test | `test_case` | ТК |
| TC (`tc-type: contract`) | Interface test | Component Integration Testing | Contract test | (related) | INT-ТК (legacy) |
| SPEC-UI | (between BR/SR — design specification) | Stakeholder requirement (UX fragment) | (design level) | (extension) | UIC (legacy) |
| SPEC-AI | (REQ extension) | (n/a) | Enabler | (extension) | AIC (legacy) |
| SPEC-ARCH / SPEC-OPS | Design description | Solution component | Enabler tech spec | (extension) | ТС (legacy) |

**Note:** the "document store (example enum)" and "SENAR (RU)" columns contain historical labels (`TM`, `UIC`, `AIC`, `INT-СТ`, etc.) for traceability with pre-v1.0 systems. The RENAR canon column holds the v1.0 labels per [§2.1.1](#211-legacy-labels-deprecated). On export to a document store or a SENAR substrate, a target mapping applies.

### 3.2 Quality Gates

A mapping of RENAR v1.0 canonical `QG-N` to external models. Legacy `QG` names ([§2.4.1](#241-legacy-qg-names-deprecated)) are retained in the SENAR column for historical traceability.

| RENAR (v1.0) | SENAR (legacy mapping) | Document store (example) | CMMI activity |
|---|---|---|---|
| **QG-0** Approval Gate | QG-0 (context) | `VK-1` (start) | Requirements review before commitment |
| **QG-1** Implementation Gate | QG-2 (implementation, legacy) | `VK-1` | Implementation baseline (`TC` readiness) |
| **QG-2** Verification Gate | QG-3 (verification, legacy) | `VK-2` | Verification |
| **QG-3** Architecture Gate *(optional)* | (n/a) | `VK-3` (partial) | Architecture-decision approval |
| **QG-4** Acceptance Gate *(optional)* | QG-4 (Acceptance) | `VK-4` | Customer acceptance |

**Note:** before v1.0, `QG-1 Requirements Gate` is effectively split between the canonical `QG-0 Approval Gate` (`BR`/`SR`/`SPEC` approval) and `QG-1 Implementation Gate` (`TC` readiness). See [§2.4.1](#241-legacy-qg-names-deprecated) for the full mapping.

### 3.3 Lifecycle statuses

| RENAR | Document store (example) | ISO/IEC 29148 | CMMI |
|---|---|---|---|
| `draft` | `draft` | proposed | identified |
| `approved` | `approved` | agreed-to / baselined | committed |
| `verified` | `verified` | verified | validated |
| `deprecated` | `obsolete` | retired | obsolete |

### 3.4 Process artifacts

| RENAR | BABOK | SAFe | SENAR |
|---|---|---|---|
| ADAPT (Forward + Backward) | Requirements Analysis Document | Solution Intent (fixed + variable) | (n/a — RENAR extension) |
| Work Order / TZ | Stakeholder commitment artifact | Customer order | (context) |
| delta-TZ | Change Request | (n/a — handled via Solution Intent updates) | (context) |
| Impact Analysis | Impact Analysis (BABOK §8) | (derived) | (context) |
| Spot-check | Random sampling QA | (n/a) | Rule 9.5 |
| Adversarial review | Independent verification | (n/a — REQ extension) | (via ADR metric) |
| Reconciliation | Continuous improvement audit | Inspect & Adapt | Quality Sweep |

<a id="35-multilingual-ui-projection"></a>

### 3.5 User-interface projections

`frontmatter` fields, identifiers, and file names are always canonical (latin). RU labels are permitted in the UI:

| Canonical | UI (RU) |
|---|---|
| Business Requirement | Бизнес-требование |
| System Requirement | Системное требование |
| Test Case | Контрольный пример (`TC`) |
| Quality Gate | Контрольная точка качества |
| Acceptance | Приёмка |
| Verified | Проверено |
| Approved | Утверждено |
| Deprecated | Устарело |
| Frozen | Замороженный |
| Backward finding | Замечание к ТЗ |
| Forward interpretation | Инженерная интерпретация |

A UI projection does not replace the canonical identifiers in the substrate.

---

## 4. Forbidden / deprecated terms

RENAR does not use the following terms (even where they appear in SENAR / industry literature):

| Term | Use instead | Why |
|---|---|---|
| **User Story** as a requirement | SR | A story is a unit of planning, not a requirement. A story MAY implement an SR, but is not itself a requirement. |
| **Use Case** (formally) | SPEC-UI + SR | A use case mixes UX and behavior. RENAR separates SPEC-UI (the UX baseline) and SR (behavior). |
| **Spec** (without a qualifier) | SR / BR / SPEC-API / SPEC-DATA / ... | "Spec" is ambiguous. Use the precise terms. |
| **Business logic** as a requirement | SR | "Business logic" is a code term, not a requirements term. |
| **Functionality** | `SR` / `TR` | Too broad; not unambiguously verifiable. |
| **Feature** (loose use) | Feature (SAFe context) or SR (the canonical RENAR term) | Ambiguous without a frame of reference. |
| **Wish / "nice-to-have"** | (never) | A contractual document is not written this way. |
| **Epic** as a requirement | BR (business level) or Portfolio Epic (SAFe) | An epic is a unit of planning, not a requirement. |
| **"Test it by hand"** | spot-check (Core Rule 5) or a manual TC with `type: acceptance` | Vague; no verifiable evidence. |
| **"To finish later"** (as a status) | `draft` / `review` | Not from the closed lifecycle list. |
| **TODO** in `frontmatter` | a backward entry in the `ADAPT` (if about a requirement) or a task in the tracker (if about implementation) | Open questions live in the right artifact, not in a field comment. |

On such findings in project-local artifacts, raise a substrate-side warning (`pre-commit` in `git`, a validation rule in the document store).

---

## 5. Glossary versioning

The glossary is a standalone document with its own version. A change to a canonical term is a major-version bump (1.0 → 2.0) and a migration scenario for all project artifacts.

**Current version:** 1.0-reconciled (phase-1.5 reconciliation with [`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1)).

<a id="51-open-questions-closed"></a>

### 5.1 Open questions — closed (phase 1.5, 2026-05-16)

Four open questions from the earlier draft were closed by reconciliation with [`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1):

| # | Was an open question | Outcome | Source |
|---|---|---|---|
| 1 | Canonical language: latin (`BR`/`SR`) or Russian (БТ/СТ)? | **Canon is latin**; Russian only in the UI projection ([§3.5](#35-multilingual-ui-projection)) | [`standard/04 §4.13.3`](../../standard/en/04-terms.md#4.13.3) + [`reference/06-ru-style-guide.md §1.3`](../06-ru-style-guide.md#13-bucket-a-technical-identifiers-keep-latin) |
| 2 | `TM` as a separate label or an `SR` refinement? | **`SR` with `level: module`** — a refinement, not a separate artifact type | [`standard/04 §4.14.1`](../../standard/en/04-terms.md#4.14.1) (`TM` deprecated) + [§2.1.1](#211-legacy-labels-deprecated) |
| 3 | AIC ← AAC / AIA / AIC? | **`SPEC-AI`** (v1.0 canon); AIC is a deprecated label | [`standard/04 §4.14.1`](../../standard/en/04-terms.md#4.14.1) + [§2.1.1](#211-legacy-labels-deprecated) |
| 4 | `INT-TC` a separate type or a naming convention? | **`TC` with `tc-type: contract`** — a refinement, not a separate type | [`standard/04 §4.14.1`](../../standard/en/04-terms.md#4.14.1) (`INT-TC` deprecated) + [§2.1.1](#211-legacy-labels-deprecated) |

### 5.2 Reconciliation history

| Date | Version | Change |
|---|---|---|
| 2026-05-16 | 1.0-reconciled | Phase-1.5 reconciliation with [`standard/04-terms.md §4.14.1`](../../standard/en/04-terms.md#4.14.1). Deprecated labels moved from the `§2.1` table to `§2.1.1`; `QG` names aligned with the v1.0 canon in §2.4; deprecated names → `§2.4.1`. Mapping tables §3.1 and §3.2 updated. Four open questions closed ([§5.1](#51-open-questions-closed)). Task: `ru-reconcile-glossary-vs-standard`. |
| (early drafts) | 1.0-draft | Draft fill-in during phase 7; had open questions and divergences from [`standard/04 §4.14.1`](../../standard/en/04-terms.md#4.14.1). Commit history recorded; replaced by the 1.0-reconciled release. |

### 5.3 Cross-references

- **EN Style Guide** ([`reference/en/06-en-style-guide.md`](06-en-style-guide.md)) — EN editorial rules for normative text; §1.9 fixes the canonical term list alongside this glossary. On a conflict, editorial-pass wording priority belongs to the Style Guide.
- **Canonical definitions** ([`standard/04-terms.md`](../../standard/en/04-terms.md)); §4.14.1 — the deprecated → canon mapping.

---

*RENAR Glossary 1.0-reconciled (EN) — part of `reference/`. See also [02-schemas.md](../02-schemas.md), [03-ai-risk-register.md](../03-ai-risk-register.md), [06-en-style-guide.md](06-en-style-guide.md).*
