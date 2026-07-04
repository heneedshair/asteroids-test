---
title: "Document templates BR / SR / TR / TC"
description: "Copy-paste skeletons for RENAR artifacts (frontmatter + body) — a possible implementation of the normative schemas in chapters 6 and 9."
order: 12
lang: en
version: "1.0-draft"
---

# Document templates BR / SR / TR / TC

> **Status:** informative. This is a **possible implementation** of the normative schemas — organizations may adapt the skeletons to their substrate and editorial conventions. The normative text these templates merely illustrate: [`standard/06`](../../standard/en/06-requirements-hierarchy.md) (BR / SR / TR) and [`standard/09`](../../standard/en/09-test-cases.md) (TC). Where a skeleton and a chapter disagree, **the chapter prevails**.
>
> **The closed list is untouched:** this appendix provides skeletons for already-normative types; new artifact or SPEC types are added only through the formal standard-change procedure ([chapter 13](../../standard/en/13-conformance.md)).

---

## 12.1 Status and how to use it

Each section below carries two skeletons: a `yaml` block with the frontmatter (with per-line comments on field obligation) and a `markdown` block with the body skeleton. To get a ready artifact file, concatenate both parts into a single substrate document: frontmatter on top, body next.

How the skeletons map to the normative schemas:

| Artifact | frontmatter (normative) | Body sections (normative) |
|---|---|---|
| BR | [§6.5.2](../../standard/en/06-requirements-hierarchy.md#6.5.2) | [§6.5.3](../../standard/en/06-requirements-hierarchy.md#6.5.3) |
| SR | [§6.6.2](../../standard/en/06-requirements-hierarchy.md#6.6.2) | [§6.6.3](../../standard/en/06-requirements-hierarchy.md#6.6.3) |
| TR | [§6.7.2](../../standard/en/06-requirements-hierarchy.md#6.7.2) | [§6.7.3](../../standard/en/06-requirements-hierarchy.md#6.7.3) |
| TC | [§9.3](../../standard/en/09-test-cases.md#9.3) | [§9.4](../../standard/en/09-test-cases.md#9.4) |

Conventions used in the skeletons: `<...>` is a placeholder to replace; `NN` is a sequential number within the scope; the comment `# conditional` marks a field whose obligation depends on a condition (explained inline); `# auto` marks a field maintained by the substrate/runner, not filled in by hand.

---

## 12.2 BR template

A BR captures a business need at the system or subsystem level; technical detail is prohibited in a BR ([§6.5.1](../../standard/en/06-requirements-hierarchy.md#6.5.1)). Frontmatter per [§6.5.2](../../standard/en/06-requirements-hierarchy.md#6.5.2); body per [§6.5.3](../../standard/en/06-requirements-hierarchy.md#6.5.3).

```yaml
---
id: BR-NN                            # immutable; NN sequential within the scope
title: "<short, descriptive>"
type: BR
slug: "<kebab-case>"                 # auto-derived

# === Scope (mandatory) ===
level: system | subsystem            # a BR at module level is prohibited (§6.4)
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null if level=system

# === Lifecycle (mandatory) ===
status: draft | approved | verified | deprecated
owner: "<role / responsible person>"

# === Source: provenance (see §7.4.1) ===
source:
  tz-section: "§N.N"                 # always mandatory — primary provenance from the TZ
  adapt: ADAPT-NNN                   # conditional: present if an ADAPT was created
  adapt-section: "Forward §N"        # mandatory if adapt is set
  adversarial-review-ref: "<substrate ref>"  # conditional: if adapt is absent — evidence of the "no findings" verdict (§7.4.1.2)

# === Cross-level link subsystem BR → system BR (see §6.8.2) ===
implements:                          # array; not a parent-edge, a separate edge type
  - id: BR-NN                        # id of the parent system BR
    scope:
      system: "<system-id>"
    rationale: "<short>"             # optional; reference to an ADAPT section if present

# === Relationship graph (substrate-managed) ===
children: []                         # auto: SR whose parent.id = this BR
implemented-by: []                   # auto: subsystem BR referencing it via implements[]
verified-by: []                      # auto: TC verifying through SR

# === AI provenance (mandatory on RENAR-4+; schema — §4.10.1) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  generated-at: "<ISO-8601>"
  human-edits: boolean

# === Replacement (mandatory if applicable) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"
---
```

```markdown
## Need

Who (role), what (action), why (business goal) — one sentence.

## Success criteria

1. <Measurable outcome, independently verifiable.>
2. <…> (3–7 items in total.)

## Context

Where the requirement came from (with a reference to an ADAPT section if present);
what alternatives were considered.

## Constraints

<Optional: business constraints — budget, deadlines, regulation. Technical
constraints do not belong here — the SPEC types and SR exist for those.>
```

The `source.tz-section` field is always present; `source.adapt` is omitted when the adversarial review returns a "no findings" verdict — then `source.adversarial-review-ref` is mandatory ([§7.4.1](../../standard/en/07-adapt.md#7.4.1)).

> **Where the "requirements" live in a BR.** The BR template deliberately has no section with "the system shall …" statements: in RENAR those statements are SR ([§6.6](../../standard/en/06-requirements-hierarchy.md#6.6)), derived from this BR. Mixing them into the BR blurs the "business need ↔ system requirement" boundary and produces "technical BRs" indistinguishable from SR ([§6.4](../../standard/en/06-requirements-hierarchy.md#6.4), [§6.5.1](../../standard/en/06-requirements-hierarchy.md#6.5.1)). The BR's own verifiable, enumerable content is carried by the **Success criteria** section: 3–7 measurable, independently checkable outcomes — these are the business requirements in verifiable form. Decomposing BR → SR turns each criterion into one or more normative SR ("the system shall …" form per [§6.6.3](../../standard/en/06-requirements-hierarchy.md#6.6.3)).

---

## 12.3 SR template

An SR captures what the system does (observable behavior and constraints); table, framework, and data-structure names are the responsibility of SPEC ([§6.6.1](../../standard/en/06-requirements-hierarchy.md#6.6.1)). Frontmatter per [§6.6.2](../../standard/en/06-requirements-hierarchy.md#6.6.2); body per [§6.6.3](../../standard/en/06-requirements-hierarchy.md#6.6.3).

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

# === Source: provenance (see §7.4.1; same rules as BR) ===
source:
  tz-section: "§N.N"                 # always mandatory
  adapt: ADAPT-NNN                   # conditional
  adapt-section: "Forward §N"        # mandatory if adapt is set
  adversarial-review-ref: "<substrate ref>"  # mandatory if adapt is omitted

# === Relationship graph ===
constrained-by:                      # typed edges to SPEC (chapter 8)
  - SPEC-UI-NN
  - SPEC-API-NN
  - SPEC-DATA-NN
children: []                         # auto: TR whose parent.id = this SR
verified-by: []                      # auto: TC verifying the SR

# === AI provenance (mandatory on RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  human-edits: boolean

# === Replacement (mandatory if applicable) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"
---
```

```markdown
## Requirement

One sentence in normative form: "The system MUST …" (modality per the convention
of §0.5).

## Behavior

A detailed description of observable behavior; functional scenarios.

## Constraints

<Mandatory if applicable: non-functional constraints — performance, security.
Full constraints are pushed into SPEC via constrained-by[].>

## Link to SPEC

<Mandatory if constrained-by[] is present: which aspects of behavior are governed
by which SPEC.>
```

`parent.id` is the single BR (a parent tree); `constrained-by[]` is a graph of references to SPEC of any type and in any number ([§6.6.2](../../standard/en/06-requirements-hierarchy.md#6.6.2)).

---

## 12.4 TR template

A TR is the atomic unit of implementer work: exactly what to build within a single SR ([§6.7.1](../../standard/en/06-requirements-hierarchy.md#6.7.1)). Frontmatter per [§6.7.2](../../standard/en/06-requirements-hierarchy.md#6.7.2); body per [§6.7.3](../../standard/en/06-requirements-hierarchy.md#6.7.3).

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

# === Source: traceability chain (inherited from parent SR, §6.7.5) ===
source:
  adapt: ADAPT-NNN                   # auto: inherited from parent SR; may be absent
  sr-version: "<version-ref>"        # pinning to the SR version (substrate capability V5)

# === Relationship graph ===
implements-spec:                     # typed edges to SPEC
  - SPEC-API-NN
  - SPEC-UI-NN
verified-by: []                      # auto: TC verifying through SR

# === Goal and acceptance criteria ===
goal: "<one-sentence outcome>"
acceptance-criteria:
  - "<numbered, falsifiable, unambiguous>"
  - "<…>"

# === AI provenance (mandatory on RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  human-edits: boolean
---
```

```markdown
## Goal

One paragraph; the outcome the TR makes observable.

## Acceptance Criteria

1. <Falsifiable criterion; covers a positive scenario.>
2. <Falsifiable criterion; covers a negative scenario / boundary.>

## Scope

What is in and what is **not** in the TR (per SENAR Rule 2).

## References

<Mandatory if applicable: to the SPEC in implements-spec[] and the sections of the
parent SR.>
```

The section names `Goal`, `Acceptance Criteria`, `Scope` are canonical per [§6.7.3](../../standard/en/06-requirements-hierarchy.md#6.7.3). The TR implementer works within the SR / SPEC and does not reach the ADAPT directly ([§6.7.5](../../standard/en/06-requirements-hierarchy.md#6.7.5)).

---

## 12.5 TC template

A TC verifies a normative assertion of a BR / SR / SPEC; the common frontmatter is per [§9.3](../../standard/en/09-test-cases.md#9.3), the body per [§9.4](../../standard/en/09-test-cases.md#9.4). Type-specific fields (`judge`, `baseline` for `ux` / `eval`) are added on top per [§9.6](../../standard/en/09-test-cases.md#9.6).

```yaml
---
# === Identity (mandatory) ===
id: TC-NN                            # immutable; NN sequential within the scope
title: "<short, descriptive>"
type: TC
slug: "<kebab-case>"

# === Classification (mandatory) ===
tc-type: acceptance | ux | system | contract | eval | security
negative: boolean                    # true for the paired negative TC

# === Scope (mandatory) ===
level: system | subsystem | module
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null if level=system
  module: "<module-id>"              # null if level ≠ module

# === Lifecycle (mandatory) ===
status: draft | ready | passing | failing | obsolete

# === Verification target (mandatory; at least one) ===
verifies:
  - id: SR-NN | BR-NN | SPEC-<TYPE>-NN
    requirement-version: "<version-ref>"   # artifact version pinning (V5)

# === Pair link (mandatory if negative=false and a paired TC exists) ===
paired-with:
  - TC-NN

# === Automation (mandatory) ===
automation:
  status: automated | manual-pending
  location: "<substrate pointer to implementation>"  # mandatory if automated
  manual-pending-until: "<ISO date>"                 # mandatory if manual-pending
  manual-pending-reason: "<text>"                    # mandatory if manual-pending

# === Execution (mandatory for tc-type: ux | eval) ===
judge:
  vendor: "<provider>"               # mandatory; judge isolation — P7
  model: "<model-id>"
baseline:                            # mandatory for ux | eval
  artifact: "<substrate pointer>"
  perceptual-diff-threshold: float   # for ux
  metric-thresholds: {}              # for eval

# === Last run (runner-managed; not filled by the author) ===
last-run:                            # auto
  date: "<ISO-datetime>"
  result: pass | fail | skipped | n/a
  runner-id: "<runner-name@version>"

# === AI provenance (mandatory on RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  human-edits: boolean
---
```

```markdown
## Context

Which clause of the verified artifact the TC references; a quote or paraphrase of
the assertion.

## Preconditions

The system and data state required for the run; provided by the seed mechanism.

## Steps

Runner actions. For tc-type: ux — intentions, not selectors (§9.6.1).

## Pass criterion

Binary, observable, reproducible (§9.11).

## Fail criterion

A list of observable signs of a violation (not the negation of the Pass criterion):
leaks, side effects, race conditions.

## Postconditions

The state expected after the run; the cleanup mechanism.

## Out of scope

What is **deliberately** not checked, naming the paired TC where it is covered.
```

The headings `## Pass criterion` and `## Fail criterion` are fixed: the change-of-criteria control hook detects them ([§10.11.3](../../standard/en/10-lifecycle-qg.md#10.11.3)) — they may not be renamed locally. The "Out of scope" section is mandatory: its absence blocks the TC transition to `ready` ([§9.4](../../standard/en/09-test-cases.md#9.4)).

---

## 12.6 SPEC templates — deferred

Skeletons for the SPEC types ([chapter 8](../../standard/en/08-specifications.md)) are **deliberately not included** in this appendix. The partner review flagged the question of SPEC skeletons as open: the set of mandatory fields differs across SPEC types (UI, API, DATA, AI, SEC, INT) far more than across BR / SR / TR / TC, and fixing a skeleton prematurely risks reading as normative.

Draft sketches of the SPEC skeletons are kept in the repository — `research/17-specification-schema-and-templates.md` (§5; an internal draft, not published to the site) — pending a separate decision. When that decision is made, the SPEC skeletons are added here as a new section — without changing the closed list of SPEC types, which is already normative in [`standard/08 §8.2.2`](../../standard/en/08-specifications.md#8.2.2) and [§8.3](../../standard/en/08-specifications.md#8.3).

---

## 12.7 Filling placeholders and common mistakes

| Placeholder | What to replace it with | Common mistake |
|---|---|---|
| `BR-NN` / `SR-NN` / `TR-NN` / `TC-NN` | A sequential ID within the scope (the substrate assigns it on creation) | Changing the ID after publication — it is immutable |
| `<system-id>` / `<subsystem-id>` / `<module-id>` | Identifiers from the project's system registry | Filling `subsystem` when `level=system` (it must be `null`) |
| `source.tz-section` | The section of the source TZ — always present | Omitting it on the assumption that a reference to the ADAPT is enough |
| `constrained-by[]` / `implements-spec[]` | IDs of existing SPEC | Naming a SPEC type outside the closed list |
| `# auto` fields (`children`, `verified-by`, `last-run`) | Nothing — the substrate / runner maintains them | Filling them by hand and diverging from the relationship graph |

Placeholders like `BR-NN` and empty `<...>` are an unfilled skeleton, not a valid artifact: run such files through checks only after substituting real values, otherwise the substrate validators will rightly reject the template IDs.

---

[← Back to the reference overview](README.md)
