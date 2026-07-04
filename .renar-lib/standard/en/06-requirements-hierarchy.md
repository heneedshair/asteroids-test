---
title: "Requirements hierarchy"
order: 6
lang: en
---
# 06. Requirements hierarchy

> **Part of the RENAR Standard v1.0-draft** · [← Table of contents](README.md)

> **Dense chapter:** before the frontmatter — [guide/00 quickstart](../../guide/en/00-quickstart.md); chapter density — [reference/09](../../reference/en/09-pedagogical-density.md).

## 6.1 Three requirement types and three levels

A requirement has three altitudes, and they must not be conflated. **The business** wants an outcome: "the customer resets their own password to take load off support." **The system** MUST behave so that this outcome becomes possible: "on a request from a confirmed address, the system sends a reset link with a 30-minute lifetime." **The engineer** takes this on as a single task: "implement password reset with a limit of three attempts per hour." Three different questions — why, what, and exactly how — and to each RENAR assigns its own artifact type: **BR**, **SR**, **TR**.

There are exactly three types, the list is closed, and they are linked into a tree: one SR elaborates one BR, one TR elaborates one SR. Layered on top are three scale levels — system, subsystem, module; they determine which of the three types are even appropriate (a module has no business owner of its own — hence no BR). The entire Source-of-Truth hierarchy from [chapter 2 §2.3](02-methodology-positioning.md#2.3) rests on this axis: TZ → [ADAPT](07-adapt.md) → BR / SR / [SPEC](08-specifications.md) → TR → [TC](09-test-cases.md). The structure of the system is described in parallel — by SPEC-* specifications ([chapter 8](08-specifications.md)), which BR / SR / TR reference through typed graph edges.

The clauses of this chapter are normative. The closed lists of types and levels are mandatory clauses ([chapter 13](13-conformance.md)); they can be extended only through the formal change procedure of the standard.

The chapter draws on ISO/IEC/IEEE 29148:2018 "Requirements engineering" for the concepts of business / system / task requirements and the principles of traceability, but it fixes a closed list of exactly three types on the v1.0 requirements axis and deliberately distances itself from the freely extensible set of types characteristic of classical approaches.

---

## 6.2 The closed list of three requirements-axis types

### 6.2.1 Normative formulation

**The RENAR v1.0 requirements axis contains exactly three types: BR, SR, TR. The list is closed. New types are added only through the formal change procedure of the standard ([chapter 13](13-conformance.md)).**

| Type | Expansion | Question | Contains | Does not contain |
|---|---|---|---|---|
| BR | Business Requirement | Who, what, and why? | Business goal, role, value | Technologies, screens, contracts, data fields |
| SR | System Requirement | What does the system do? | System behavior, constraints | Table names, frameworks, concrete structures |
| TR | Task Requirement | What exactly to implement? | Implementation specifics: fields, conditions, errors | Architectural decisions |

### 6.2.2 The tree of parents

```text
BR
 └── SR              # parent = BR (single)
      └── TR         # parent = SR (single)
                ↓
          Goal + Acceptance Criteria
          in the task-management system
```

`SR.parent` is a single BR. `TR.parent` is a single SR. This is a **tree**, not a graph; multiple parents on the requirements axis are prohibited. The link graph runs between requirements and specifications ([§6.10](#610-linking-the-hierarchy-to-adapt-and-spec)).

### 6.2.3 What is not a requirements-axis type

Artifacts historically seen in projects under the names UIC (UI Concept), AIC (AI Concept), INT-SR (integration requirement), TS (technical specification) **are not requirements-axis types in v1.0**. They have been moved to the parallel specifications axis as the corresponding SPEC types (see [§8.3](08-specifications.md#8.3) for the closed list of 9 SPEC types and [§8.7](08-specifications.md#8.7) for migration):

| Legacy artifact | RENAR v1.0 type |
|---|---|
| UIC | SPEC-UI |
| AIC | SPEC-AI |
| INT-SR | SPEC-INT |
| TS (architecture / data / API / process / security / ops) | SPEC-ARCH / SPEC-DATA / SPEC-API / SPEC-PROC / SPEC-SEC / SPEC-OPS |

SPEC-* relates to the requirements axis not as "one more requirement type" but as a parallel axis with typed edges `SR.constrained-by[]` and `TR.implements-spec[]` ([§6.10](#610-linking-the-hierarchy-to-adapt-and-spec)).

Test cases (TC) are a separate class of verification artifacts, governed by [chapter 9](09-test-cases.md). TC are not requirements: they verify the behavior described in BR / SR / SPEC.

---

## 6.3 Systems, subsystems, modules

The levels of organizational decomposition are a closed list of three elements: **system**, **subsystem**, **module**. Each element corresponds to an allowed set of requirement types (see [§6.4](#64-allowed-requirement-types-by-decomposition-level)).

### 6.3.1 System

**A system** is the top level of the hierarchy. A whole product or platform that is delivered and operated as a single unit and for which an organization is accountable.

Indicators of a system:

- a single owner on the business side (Product Owner, director, client);
- delivered and operated as a single unit;
- the client sees and assesses the system as a whole, not its parts separately;
- a single top-level TZ document and one root [ADAPT](07-adapt.md).

Allowed requirement types: **BR, SR, TR**.

### 6.3.2 Subsystem

**A subsystem** is a large, self-contained component of the system that carries its own business value or has a separate business owner.

A subsystem is distinguished if **at least one** of the conditions holds:

| Condition | Example |
|---|---|
| Its own team or technical owner | Frontend team vs AI-pipeline team |
| A separate database or an independently deployable service | An isolated microservice with its own deployment |
| The ability to be replaced independently of the others | The analytics module is replaced without changing the operational loop |
| A different business domain or a separate stakeholder | CFO vs COO |
| Added later as a separate initiative with a separate budget | A partner program |

**The key normative criterion:** is there a separate person on the business side accountable for the value of this part of the system?
- yes → subsystem, BR are justified;
- no → module, SR only.

Allowed requirement types: **BR (if it has its own stakeholder) + SR + TR**.

### 6.3.3 Module

**A module** is a technical division within a subsystem. It implements part of the subsystem's behavior but has no business value of its own.

Indicators of a module:

- no separate business stakeholder;
- it does not exist and is not used apart from its subsystem;
- it is distinguished on a technical basis: functional area, layer, domain;
- it is not mentioned separately in the top-level TZ.

Allowed requirement types: **SR + TR**. No BR is created.

### 6.3.4 Summary table

| | System | Subsystem | Module |
|---|---|---|---|
| Business stakeholder | yes | yes (its own) | no |
| Independent deployment | possible | yes | no |
| Mentioned separately in the TZ | yes | yes | rarely |
| Exists separately | yes | possible | no |
| BR | yes | yes (if its own stakeholder) | no |
| SR | yes | yes | yes |
| TR | yes | yes | yes |

### 6.3.5 The "module → subsystem" evolution

The boundary between a module and a subsystem is not fixed forever. If a module has grown, gained its own team or business owner, it becomes a subsystem and gains a BR. Normatively: **a BR is written at the moment a business owner appears, not in advance**.

The reverse evolution (subsystem → module) is also permitted if the business owner has departed and the business value has become derivative; in that case the subsystem's BR is given status `deprecated` ([§6.5.4](#654-br-statuses)), and its SR are re-parented to the parent system's BR.

---

## 6.4 Allowed requirement types by decomposition level

| Level | BR | SR | TR | Explanation |
|---|---|---|---|---|
| System | mandatory | mandatory | mandatory | The top BR is mandatory (no business goal, no project) |
| Subsystem | optional | mandatory | mandatory | BR only when there is a stakeholder of its own |
| Module | not allowed | mandatory | mandatory | BR is normatively prohibited |

The normative rationale for prohibiting BR at the module level: a business requirement without a business stakeholder and without independent business value leads to false decomposition and breeds "technical BR" indistinguishable from SR. This blurs the Source-of-Truth hierarchy ([chapter 2 §2.3](02-methodology-positioning.md#2.3)).

---

## 6.5 BR — Business Requirement

### 6.5.1 Normative definition

A BR records **what the business needs and why**. It describes the role, the action, and the business value without references to technologies, screens, contracts, or data structures.

### 6.5.2 BR frontmatter (mandatory fields)

```yaml
---
id: BR-NN                            # immutable; NN sequential within scope
title: "<short, descriptive>"
type: BR
slug: "<kebab-case>"                 # auto-derived

# === Scope (mandatory) ===
level: system | subsystem            # BR at the module level is prohibited (§6.4)
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null if level=system

# === Lifecycle (mandatory) ===
status: draft | approved | verified | deprecated
owner: "<role / responsible person>"

# === Source: provenance (conditional, see §7.4.1) ===
# source.adapt — mandatory if an ADAPT exists (a gap was found during TZ → RENAR conversion);
# source.tz-section — always mandatory. At least one source is always present.
source:
  adapt: ADAPT-NNN                   # conditional: present if an ADAPT was created for this TZ
  adapt-section: "Forward §N"        # mandatory if adapt is present
  tz-section: "§N.N"                 # always mandatory — primary provenance
  adversarial-review-ref: "<substrate-native reference>"   # conditional: present if source.adapt is absent — evidence of the "no findings" verdict (§7.4.1.2)

# === Cross-level link from subsystem BR → system BR (see §6.8.2) ===
# Recommended on v1.0; mandatory on v1.1+ when level=subsystem AND the parent system has an approved BR.
# Not a parent edge — a separate link-graph edge type (see §6.8.3).
implements:                          # array; substrate-agnostic
  - id: BR-NN                        # ID of the parent system's BR
    scope:
      system: "<system-id>"          # mandatory for a cross-system reference
    rationale: "<short>"             # optional; reference to ADAPT§ if available

# === Link graph (auto-managed) ===
children: []                         # auto-derived; SR referencing parent.id=<this BR>
implemented-by: []                   # auto-derived; subsystem BR referencing implements[].id=<this BR>
verified-by: []                      # auto-derived; TC verifying through SR

# === AI provenance (mandatory on RENAR-4+; canonical schema — §4.10.1) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  generated-at: "<ISO-8601>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  human-edits: boolean
  # optional on RENAR-4, mandatory on RENAR-5 (see §4.10.1):
  # cost-budget, cost-actual, generation-time-ms

# === Replacement (mandatory if applicable) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"
---
```

The field `source.tz-section` is always mandatory. The field `source.adapt` is conditional: it is present when the TZ → RENAR conversion required an ADAPT ([§7.4.1.1](07-adapt.md#7.4.1)), and is omitted when the adversarial reviewer returned a "no findings, no clarifications" verdict ([§7.4.1.2](07-adapt.md#7.4.1)). If `source.adapt` is omitted, the field `source.adversarial-review-ref` is mandatory: it holds the evidence of that verdict for audit. The lifecycle hooks ([§7.4.1](07-adapt.md#7.4.1), [§10.11.1](10-lifecycle-qg.md#10.11.1)) check both cases: (1) if `source.adapt` is present — that the ADAPT is in status `approved` or higher; (2) if `source.adapt` is omitted — that `source.adversarial-review-ref` is present and the evidence is available to an auditor on request.

The field `parent` is absent in a BR: a BR is the root node of the requirements tree. For the cross-level link between a subsystem tree and a system tree, the separate field `implements[]` is used (see §6.8.2): this is **not** a parent edge but a typed cross-level declaration "this subsystem BR elaborates the listed system BR." The prohibition on multiple parents ([§6.8.3](#683-the-prohibition-on-multiple-parents)) does not apply to `implements[]`.

### 6.5.3 BR body (mandatory sections)

| Section | Obligation | Content |
|---|---|---|
| Need | mandatory | Who (role), what (action), why (business goal). Stated in one sentence. |
| Success criteria | mandatory | Measurable outcomes (3–7 items); each independently verifiable. |
| Context | mandatory | Where the requirement came from (with a reference to an ADAPT section), what alternatives were considered. |
| Constraints | optional | Business constraints (budget, deadlines, regulation), not technical ones. |

Technical detail (UI, API, data model) is prohibited in a BR — the SPEC types ([chapter 8](08-specifications.md)) and SR exist for that.

### 6.5.4 BR statuses

| Status | Meaning | Transition trigger |
|---|---|---|
| `draft` | In progress | Created by the author |
| `approved` | Approved, may be decomposed into SR | After QG-0 ([chapter 10](10-lifecycle-qg.md)) |
| `verified` | All derived SR / TR / TC are complete, the business outcome is confirmed | After QG-2; all `verified-by` TC have `last-run.result = pass` on the current version |
| `deprecated` | Obsolete; superseded by another BR or no longer relevant | By the Architect / Product Owner, mandatorily with `replaced-by` (if there is a replacement) |

A BR in status `deprecated` is **not deleted** — it remains as a historical trace for audit.

---

## 6.6 SR — System Requirement

### 6.6.1 Normative definition

An SR records **what the system does** (at the system, subsystem, or module level). It describes observable behavior and constraints. It does not describe table names, frameworks, or concrete data structures — that is the responsibility of SPEC ([chapter 8](08-specifications.md)).

### 6.6.2 SR frontmatter (mandatory fields)

```yaml
---
id: SR-NN                            # immutable
title: "<short, descriptive>"
type: SR
slug: "<kebab-case>"

# === Scope (mandatory) ===
level: system | subsystem | module
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null if level=system
  module: "<module-id>"              # null if level ≠ module

# === Lifecycle (mandatory) ===
status: draft | approved | verified | deprecated
owner: "<role / responsible person>"

# === Parent (mandatory) ===
parent:
  id: BR-NN                          # single parent

# === Source: provenance (conditional, see §7.4.1) ===
# Same rules as for BR: source.adapt conditional; source.tz-section always mandatory;
# source.adversarial-review-ref mandatory if source.adapt is omitted.
source:
  adapt: ADAPT-NNN                   # conditional
  adapt-section: "Forward §N"        # mandatory if adapt is present
  tz-section: "§N.N"                 # always mandatory
  adversarial-review-ref: "<substrate-native reference>"   # mandatory if adapt is omitted

# === Link graph (mandatory ones + auto-managed) ===
constrained-by:                      # typed edges to SPEC (chapter 8)
  - SPEC-UI-NN
  - SPEC-API-NN
  - SPEC-DATA-NN
children: []                         # auto-derived; TR referencing parent.id=<this SR>
verified-by: []                      # auto-derived; TC verifying the SR

# === AI provenance (mandatory on RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  human-edits: boolean

# === Replacement (mandatory if applicable) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"
---
```

**Key fields.** `parent.id` is a single BR; this is a tree of parents. `constrained-by[]` are typed references to SPEC-*; this is a **graph**, not a tree. An SR may reference any number of SPEC of any types; a SPEC, in turn, may be `referenced-by` many SR ([chapter 8 §8.2](08-specifications.md#8.2)).

### 6.6.3 SR body (mandatory sections)

| Section | Obligation | Content |
|---|---|---|
| Requirement | mandatory | One sentence in normative form: "The system MUST …" (modality per the convention of [§0.5](00-introduction.md#05-minimum-viable-renar-mvr): "MUST" / "SHALL" = mandatory). |
| Behavior | mandatory | A detailed description of observable behavior; functional scenarios. |
| Constraints | mandatory if applicable | Non-functional constraints (performance, security); full constraints live in the `constrained-by[]` SPEC. |
| Link to SPEC | mandatory if `constrained-by[]` is present | A short explanation of which aspects of behavior are governed by which SPEC. |

### 6.6.4 SR statuses

Identical to BR statuses ([§6.5.4](#654-br-statuses)) — `draft → approved → verified → deprecated`. The `approved → verified` transition is after QG-2 ([chapter 10](10-lifecycle-qg.md)); it requires all `verified-by` TC to have `last-run.result = pass` on the current SR version.

---

## 6.7 TR — Task Requirement

### 6.7.1 Normative definition

A TR is the atomic unit of an implementer's work. It records **what exactly to implement** within a single SR. A TR decomposes an SR down to a level fit for direct implementation (one task — one TR).

### 6.7.2 TR frontmatter (mandatory fields)

```yaml
---
id: TR-NN                            # immutable
title: "<short, descriptive>"
type: TR
slug: "<kebab-case>"

# === Scope (mandatory) ===
level: system | subsystem | module   # system — rare, cross-subsystem tasks
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null if level=system
  module: "<module-id>"              # null if level ≠ module

# === Lifecycle (mandatory) ===
status: draft | approved | done | obsolete
owner: "<assignee role / agent>"

# === Parent (mandatory) ===
parent:
  id: SR-NN                          # single parent

# === Source: trace chain (auto-derived from parent SR) ===
# A TR has no source of its own — it inherits from the parent SR (§6.7.5).
# If parent SR.source.adapt is omitted (§7.4.1), that fact is inherited too.
source:
  adapt: ADAPT-NNN                   # auto-derived from parent SR; may be omitted
  sr-version: "<version-ref>"        # pinning to the SR version (substrate capability V5; chapter 3)

# === Link graph ===
implements-spec:                     # typed edges to SPEC
  - SPEC-API-NN
  - SPEC-UI-NN
verified-by: []                      # auto-derived; TC verifying through SR

# === Goal + Acceptance Criteria ===
goal: "<one-sentence outcome>"
acceptance-criteria:
  - "<numbered, falsifiable, unambiguous>"
  - "..."

# === AI provenance (mandatory on RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  human-edits: boolean
---
```

**Key fields.** `parent.id` is a single SR. `implements-spec[]` are typed edges to SPEC; they specify which SPEC must be taken into account when implementing this particular TR (a subset of the parent SR's `constrained-by[]` or its extension with SPEC types not listed directly on the SR). `acceptance-criteria` is a closed, numbered list of falsifiable statements.

### 6.7.3 TR body (mandatory sections)

| Section | Obligation | Content |
|---|---|---|
| Goal | mandatory | One paragraph; the outcome that the TR makes observable. |
| Acceptance Criteria | mandatory | A numbered list; each item falsifiable; covers positive and negative scenarios. |
| Scope | mandatory | What is in / out of the TR (matches SENAR Rule 2). |
| References | mandatory if applicable | To SPEC from `implements-spec[]` and to sections of the parent SR. |

### 6.7.4 TR statuses

| Status | Meaning | Trigger |
|---|---|---|
| `draft` | TR created, AC not yet finalized | Authoring |
| `approved` | AC approved, work may start | QG-0 ([chapter 10](10-lifecycle-qg.md)): goal + AC present |
| `done` | AC verified, TC passing | QG-2; `verified-by` TC `pass` |
| `obsolete` | TR no longer relevant before completion (e.g. the SR changed) | By the Architect, mandatorily with a note |

### 6.7.5 A TR does not reference ADAPT directly

The implementer of a TR works within the SR / SPEC and **does not turn to ADAPT directly** — all the needed interpretations of the TZ are already recorded in the approved ADAPT and threaded into SR / SPEC through `source.adapt` ([chapter 7 §7.7.3](07-adapt.md#7.7)). If the implementer finds an ambiguity in the SR, this is a signal either for a new Backward finding in ADAPT (if the root of the ambiguity is in the TZ) or for a clarification of the SR (if the root is in the decomposition).

---

## 6.8 Extended hierarchy for composite systems

The base scheme `BR → SR → TR` holds for most projects. For composite systems the standard governs two variants of the extended hierarchy.

### 6.8.1 Subsystem as a technical division, not a standalone product

BR pertain to the system as a whole; subsystems are a technical division by teams, components, or other architectural boundaries:

```text
BR (system)
 └── SR (system)         # optional, if there are cross-subsystem SR
      └── SR (subsystem)
           └── TR

SPEC-INT (between subsystems)    # parallel axis; see chapter 8
```

`SPEC-INT` belongs to none of the subsystems — it is a system-level integration specification.

### 6.8.2 Subsystem as a standalone product with its own stakeholder

The subsystem has its own BR with its own business owner:

```text
BR (system)
 └┄┄ BR (subsystem)       # ┄┄ implements-edge (see below), NOT a parent edge
      └── SR (subsystem)
           └── TR
```

`└┄┄` between BR (system) and BR (subsystem) denotes a **typed cross-level `implements` edge** ([§6.5.2](#652-br-frontmatter-mandatory-fields)): the subsystem BR declares which BR of the parent system it elaborates and implements. This is **not a parent edge** of the requirements tree: `BR (subsystem).parent` remains absent, and each such subsystem is the root node of its own tree. `implements` is a separate link-graph edge type, symmetric to the `constrained-by[] ↔ referenced-by[]` pair for SPEC ([§6.10.2](#6102-the-link-graph-with-spec)).

**The normative rule for `implements[]`:**

| Level | Scenario | Rule |
|---|---|---|
| Recommended on v1.0 / mandatory on v1.1+ | `BR.level = subsystem` AND `scope.system` has ≥1 approved BR | `implements[]` MUST contain ≥1 reference to an applicable BR of the parent system |
| Permitted | `BR.level = subsystem` AND the parent system is a container with no BR of its own (organizational-level scope) | `implements[]` is omitted; the rationale is recorded in the `Context` section with a reference to ADAPT§ |
| Prohibited | `BR.level = system` | `implements[]` does not apply (a system BR is the root of the whole scope hierarchy) |

**The lifecycle hooks ([chapter 10 §10.11](10-lifecycle-qg.md#10.11)) MUST:**

- Check that the target BR exists (by `id + scope.system`) when approving a subsystem BR.
- Check that the target BR is in status `approved` or higher; an erroneous draft target is fatal.
- Detect cycles in `implements` chains; a cycle is fatal.
- On deprecating a target BR ([§6.5.4](#654-br-statuses)) — generate a cascade-warning for all `implemented-by[]` (not a cascade-deprecate; the decision on the evolution of the dependent BR rests with the Architect).

**The machine-readable trace chain in §6.8.2** is reconstructed through the `implements` edge ([§6.10.3](#6103-the-full-trace-chain-read-side)) — the asymmetry with §6.8.1 is removed.

The subsystem's link to the system's shared [ADAPT](07-adapt.md) is preserved through `source.adapt` (if applicable); `implements[]` and `source.adapt` are independent fields and may point to different nodes of the graph.

### 6.8.3 The prohibition on multiple parents

The standard does not allow multiple `parent` for an SR or TR. Cross-functional requirements that might look like "children of two SR at once" are governed in one of two ways:

- they are split into several SR, each with a single parent BR;
- they are decomposed into a higher-level SR (the parent subsystem or system) on which these cross-functional scenarios depend.

The field `BR.implements[]` ([§6.5.2](#652-br-frontmatter-mandatory-fields), [§6.8.2](#682-subsystem-as-a-standalone-product-with-its-own-stakeholder)) is **not a parent edge** and is not subject to §6.8.3: a single subsystem BR may elaborate several system BR (cardinality 0..N). This is a deliberate difference in the typing of link-graph edges: parent is single, cross-level declarations are multiple.

---

## 6.9 Evolution of the hierarchy

### 6.9.1 Module → subsystem

The scenario from [§6.3.5](#635-the-module--subsystem-evolution): a module gains a business owner. The normative sequence:

1. The appearance of a business owner is recorded through a Backward finding in ADAPT (category `scope` — a change of work boundaries; [chapter 7 §7.4.4](07-adapt.md#7.4)).
2. After the delta-ADAPT is approved — the module is promoted to subsystem status; a subsystem BR is created with `source.adapt: <delta-ADAPT>`.
3. The module's existing SR are preserved (immutable IDs); the SR `parent` field is updated to the new subsystem BR in an atomic change.
4. TR / TC referencing these SR require no changes (the parent SR is unchanged).

### 6.9.2 The prohibition on anticipatory hierarchy

Creating a subsystem BR "for growth," without an existing business owner, is a violation of the standard. A BR without a stakeholder turns into a "technical BR" that blurs the [Source-of-Truth inversion](02-methodology-positioning.md#2.3) and substitutes for an SR. The lifecycle hooks ([chapter 10](10-lifecycle-qg.md)) MUST block the transition of a BR to `approved` if no identified business owner is recorded in ADAPT.

### 6.9.3 Subsystem → module

The symmetric scenario of [§6.3.5](#635-the-module--subsystem-evolution): the subsystem has lost its business owner or the business value has become derivative of the parent system. The normative sequence:

1. The loss of the business owner / the reassessment of business value is recorded through a Backward finding in ADAPT (category `scope`; [chapter 7 §7.4.4](07-adapt.md#7.4)).
2. After the delta-ADAPT is approved — the subsystem BR is moved to status `deprecated` with the reason given in `Context` (business owner withdrawn / business value absorbed by the system). The BR is not deleted (immutable IDs, V1).
3. The subsystem's SR are preserved (immutable IDs); the SR `parent` field is updated in an atomic change to the parent system's BR (or to another subsystem's BR, if the SR's area belongs to it).
4. The subsystem is renamed to a module at the level of the area and the storage scheme ([§6.11.2](#6112-at-the-subsystem--module-level)); the existing SR / TR IDs remain unchanged.
5. TR / TC referencing these SR require no changes.

If no BR of the parent system covers the behavior of an SR, this is a signal that the subsystem has not in fact lost its independent business value; reverse evolution is impossible in that case, and the subsystem BR remains `approved`.

---

## 6.10 Linking the hierarchy to ADAPT and SPEC

The standard fixes the links between the requirements axis, ADAPT, and the parallel SPEC axis through normative frontmatter fields and typed link-graph edges.

### 6.10.1 Link to ADAPT

`BR.source.adapt`, `SR.source.adapt`, `SPEC-*.source.adapt` are conditional references to the ADAPT from which the artifact was derived ([chapter 7 §7.7.1](07-adapt.md#7.7)): present when an ADAPT was created; on a "no findings" verdict no ADAPT exists, and instead of the reference the field `source.adversarial-review-ref` is mandatory ([§7.4.1](07-adapt.md#7.4.1)). A TR has no direct `source.adapt` — it inherits it through the `parent SR` ([§6.7.5](#675-a-tr-does-not-reference-adapt-directly)).

### 6.10.2 The link graph with SPEC

```text
Requirements tree (behavior axis):       Parallel specifications axis:
BR
 └── SR  ──── constrained-by[] ─────►    SPEC-ARCH  SPEC-API  SPEC-DATA
      └── TR ─── implements-spec[] ──►   SPEC-INT   SPEC-PROC SPEC-UI
                                          SPEC-AI    SPEC-SEC  SPEC-OPS
```

| Edge | Type | Obligation |
|---|---|---|
| `SR.constrained-by[] → SPEC-*` | Graph (multiple) | Optional; present when governing SPEC exist |
| `TR.implements-spec[] → SPEC-*` | Graph (multiple) | Optional; specifies SPEC for the implementer |
| `SPEC-*.referenced-by[] → SR / TR` | Auto-derived inverse | Auto-computed by substrate-native indexing |
| `SPEC-*.depends-on[] → SPEC-*` | Graph between SPEC | See [chapter 8 §8.2](08-specifications.md#8.2) |

The link between the requirements axis and the SPEC axis is normative: an SR with non-trivial UI / API / data behavior MUST NOT remain without `constrained-by[]` (its absence is a signal either to write a SPEC or to justify the absence in the SR's Context).

### 6.10.3 The full trace chain (read-side)

ADAPT is a reactive artifact ([§7.4.1](07-adapt.md#7.4.1)): it is created only when the TZ → RENAR conversion produces a gap between the languages. The trace chain accordingly has **two valid variants**, chosen depending on whether an ADAPT exists for the specific TZ.

**Variant A — when an ADAPT was created** (`source.adapt` present):

```text
TC-NN  →  verifies SR-12 v1.4
              │
              ├─ parent:        BR-03 v2.0     (BR-03 — level: subsystem)
              │                     │
              │                     └─ implements: BR-01 (system), BR-05 (system)
              │                                       (typed cross-level edge §6.8.2)
              ├─ source.adapt:  ADAPT-001 §Forward §3.2
              │     └─ source-tz: TZ-2026-001 §3.4
              ├─ constrained-by: SPEC-UI-04, SPEC-API-02
              └─ children:      TR-101, TR-102, TR-103
                                    └─ implements-spec: SPEC-API-02
                                    └─ verified-by: TC-NN
```

**Variant B — when no ADAPT was created** (`source.adapt` omitted; the adversarial reviewer returned a "no findings" verdict, [§7.4.1.2](07-adapt.md#7.4.1)):

```text
TC-NN  →  verifies SR-12 v1.4
              │
              ├─ parent:        BR-03 v2.0     (BR-03 — level: subsystem)
              │                     │
              │                     ├─ implements: BR-01 (system), BR-05 (system)
              │                     └─ source.tz-section: TZ-2026-001 §3.4
              │                        source.adversarial-review-ref: <verdict evidence ref>
              ├─ source.tz-section: TZ-2026-001 §3.4   (no ADAPT for this TZ)
              │  source.adversarial-review-ref: <verdict evidence ref>
              ├─ constrained-by: SPEC-UI-04, SPEC-API-02
              └─ children:      TR-101, TR-102, TR-103
                                    └─ implements-spec: SPEC-API-02
                                    └─ verified-by: TC-NN
```

Both variants are **machine-readable**. In variant B the path is reconstructed through `source.tz-section` directly; the `adversarial-review-ref` evidence records who declared "no findings" and when (V6 author + timestamp), and is available on an auditor's request ([§13.5](13-conformance.md#13.5)).

For the "subsystem as a standalone product" scenario ([§6.8.2](#682-subsystem-as-a-standalone-product-with-its-own-stakeholder)) the chain in both variants contains the `implements` edge between the subsystem BR and the parent system BR — this reconstructs machine-readable traceability symmetric to the [§6.8.1](#681-subsystem-as-a-technical-division-not-a-standalone-product) scenario.

**A superseded ADAPT in the trace chain.** When an ADAPT moves to `superseded` ([§7.6.4](07-adapt.md#7.6), [§10.8.5](10-lifecycle-qg.md#10.8)), all derived BR / SR / SPEC with `source.adapt` pointing to it MUST be either redirected to the superseding ADAPT or re-derived. A dangling `source.adapt` reference to an ADAPT in status `superseded` makes the trace chain **invalid** (read-side): an audit must not lead to a superseded source of interpretation as if it were in force. The `superseded` ADAPT itself is preserved for audit (V1) and is reachable through the `superseded-by` edge from the superseding ADAPT — but not as the `source.adapt` of an in-force requirement. Enforcement is the `adapt-supersession` validation ([§10.11.1](10-lifecycle-qg.md#10.11.1)).

---

## 6.11 Storage scheme

Requirements are stored in subfolders of the requirements substrate. The substrate-native storage implementation is substrate-specific (see [guide/03](../../guide/en/03-tool-guide-git.md) for distributed VCS; [guide/04](../../guide/en/04-document-store-substrate.md) for a document-oriented store).

### 6.11.1 At the system level

```text
[requirements-substrate]/        # root of the requirements substrate (layout — guide/03 or guide/04)
  br/                            # BR-NN-*.md
  sr/                            # SR-NN-*.md, level=system
  tr/                            # TR-NN-*.md, level=system (rare)
  specs/                         # SPEC-* (chapter 8)
  adapt/                         # ADAPT (chapter 7)
  tz/                            # immutable TZ sources
  REQUIREMENTS.md                # auto-generated index
```

### 6.11.2 At the subsystem / module level

```text
[subsystem-substrate]/           # subsystem scope within the requirements substrate
  br/                            # if the subsystem has its own stakeholder
  sr/
  tr/
  modules/
    [module-substrate]/
      sr/                        # a module has only SR + TR
      tr/
  specs/                         # chapter 8
  adapt/
  REQUIREMENTS.md
```

### 6.11.3 REQUIREMENTS.md — auto-generated index

`REQUIREMENTS.md` is an auto-generated registry of all BR / SR / TR in the area: ID, type, level, title, status, parent, link to file. It is marked with a substrate-native auto-generated flag. Regeneration triggers are every frontmatter change or every approve / verify gate ([chapter 10](10-lifecycle-qg.md)).

---

## 6.12 Quality Gates for the requirements axis

Detailed gate definitions are in [chapter 10](10-lifecycle-qg.md). A brief summary for BR / SR / TR:

| Gate | Applies to | Precondition | Postcondition |
|---|---|---|---|
| QG-0 (Approval) | BR / SR / TR (`draft → approved`) | frontmatter valid, mandatory fields filled, identifier unique (V1); `source.adapt`, if present, points to an approved ADAPT, otherwise `source.adversarial-review-ref` is present (BR / SR); `parent` points to an approved BR / SR (SR); body sections conform to [§6.5.3](#653-br-body-mandatory-sections) / [§6.6.3](#663-sr-body-mandatory-sections); adversarial review performed | The artifact is moved to `approved`; immutable until the next change's version; decomposition into child artifacts is allowed |
| QG-2 (Verification) | BR / SR / TR (`approved → verified` / `done`) | All `verified-by` TC `pass` on the current artifact version | The artifact is `verified` (BR/SR) or `done` (TR); the chain up to the parent BR is updated to verified if all children are verified |

QG-1 (Implementation) **does not apply** to the requirements axis: it is a separate gate for TC only ([§10.3.2](10-lifecycle-qg.md#10.3.2)) — there is no intermediate "QG-1 implementation" for BR / SR / TR; the `approved → verified` / `done` transition is governed by the single QG-2. A TR transitions `draft → approved` through the same QG-0 in a single step (frontmatter + goal + AC). `ready` and similar terms are not requirements-axis statuses and do not appear in the state machine `draft → approved → verified | done | obsolete | deprecated` (see [§6.5.4](#654-br-statuses) / [§6.6.4](#664-sr-statuses) / [§6.7.4](#674-tr-statuses)).

The substrate hooks ([chapter 3 §3.3](03-substrate-versioning.md#3.3)) MUST block transitions that violate the precondition of the corresponding gate.

---

## 6.13 Links to other chapters

| Chapter | Link |
|---|---|
| [02 Positioning in the methodology typology](02-methodology-positioning.md) | The BR / SR / TR hierarchy is the load-bearing structure of the Source-of-Truth inversion (Claim 1); the waterfall form (Claim 2) sets the BR → SR → TR layers |
| [07 ADAPT](07-adapt.md) | `BR.source.adapt`, `SR.source.adapt` are conditional (when there is no ADAPT — `source.adversarial-review-ref`); the requirements axis is derived from an approved ADAPT or directly from the TZ on a "no findings" verdict |
| [08 Specifications](08-specifications.md) | The parallel SPEC axis; `SR.constrained-by[]`, `TR.implements-spec[]` are typed graph edges |
| [09 Test cases](09-test-cases.md) | TC verify BR / SR / TR; `verified-by[]` is an auto-derived inverse |
| [10 Lifecycle and QG](10-lifecycle-qg.md) | The BR / SR / TR state machines; QG-0 / QG-2 for the requirements axis (QG-1 — for TC only) |
| [03 Substrate versioning](03-substrate-versioning.md) | Immutable IDs (V1); atomic change unit on re-parenting (V2); diff & review for approve (V3); versioning without loss of history (V4); pinning SR-version in TR (V5); substrate-native approve signature with author + timestamp (V6) |
| [11 Maturity model](11-maturity-model.md) | RENAR-1: the BR / SR / TR axis is mandatory; RENAR-3+: `constrained-by[]` for all SR where applicable |
| [13 Conformance](13-conformance.md) | The closed list of types (BR / SR / TR) is a v1.0 mandatory clause; the closed list of levels (system / subsystem / module) is a v1.0 mandatory clause |
| [reference/02 — schemas](../../reference/en/02-schemas.md) | The full machine-readable schema of BR / SR / TR frontmatter |
