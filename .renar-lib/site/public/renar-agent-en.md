# RENAR — Operational Standard for the AI Agent

**Version 1.3-draft** | Authors: Vadim Soglaev, Andrey Yumashev | [renar.tech](https://renar.tech) | CC BY-SA 4.0

> **What this file is.** This is a **self-sufficient** working edition of the RENAR standard for an AI agent. It collects everything the agent needs to do requirements engineering by RENAR at 100% — without consulting any other document. Download this file, place it beside the agent, and say: "study this standard and work by it."
>
> Chapters the agent does not need at work (history, maturity metrics, comparisons with other methodologies, substrate details) are omitted; the needed ones are reworked and compressed to an operational minimum. For a formal dispute over the exact wording of "MUST / SHOULD / MAY", the primary source is the full normative corpus at [renar.tech](https://renar.tech); but for everyday work this file is enough.

---

## 0. How to use this file

1. Read sections 1–2: the principle and the artifact map. This is the coordinate system.
2. When you receive a TZ from the client, follow the workflow (section 4).
3. Do not break the hard rules (section 12) or the closed lists (section 11) — they are not subject to local extension.
4. Take the recording forms (frontmatter) from section 13 — they are normative.

You are an **executing agent**: you produce and maintain artifacts, but you do not own them and you do not sign. The owner and signatory is a human (section 10).

---

## 1. The core principle: the source of truth is the requirements, not the code

RENAR inverts the usual order: **the source of truth (SoT) about system behavior is the requirements hierarchy**, while code is a derived implementation artifact. Requirements define behavior → the agent produces the implementation from the requirements → tests verify the implementation against the requirements. Not the other way around.

It is **forbidden** to reconstruct the meaning of a requirement from finished code and retroactively fit `SR`/`SPEC` to the implementation (source-of-truth inversion). The exception is a justified bug-fix, where the code is repaired to match the requirement, not the requirement to match the code.

From this follows a **double inversion**: the contractual source (TZ) → SoT (the RENAR description of `BR`/`SR`/`SPEC`/`TR`/`TC`) → code.

---

## 2. Artifacts and hierarchy

```text
client TZ ──► ADAPT ──► BR ──► SR ──► SPEC ──► TC ──► QG ──► release
(immutable) (as needed)  └──────► TR ─────┘   (tests)
```

| Artifact | What it is | Key point |
|---|---|---|
| **TZ** | The client's contractual input in business language | **Immutable** after registration |
| **ADAPT** | A two-way bridge TZ ↔ requirements | Created **reactively** (section 5), 0..N per TZ |
| **BR** | Business Requirement: who, what, **why** (business goal) | Has a lifecycle and provenance |
| **SR** | System Requirement: what the system does | `parent` — exactly one BR |
| **TR** | Task Requirement: an implementation task (Goal + acceptance criteria) | Lives in the tracker, not a separate file; references SR/SPEC |
| **SPEC** | Specification — an axis parallel to the requirements | **9 types, closed list** (section 7) |
| **TC** | Test Case as a standalone artifact | A pos/neg pair is mandatory (section 8) |

**Provenance is mandatory.** Every `BR`/`SR`/`SPEC` has a `source`: either through ADAPT (`source.adapt` + `source.adapt-section`) or directly (`source.tz-section` + `source.adversarial-review-ref`). The `source.tz-section` field is **always** mandatory. An artifact without a source is forbidden.

**A RENAR description is always complete, never incremental.** Before changing the system, a new complete version of the RENAR description is created, and only then does the agent change the implementation. Only the TZ is incremental (delta-TZ); the full picture is reassembled by the agent in whole.

---

## 3. Minimum Viable RENAR (MVR) — seven mandatory statements

An implementation that breaks even one of them **does not conform** to RENAR. The list is closed.

1. **MVR-1 — SoT inversion.** Requirements are the source of truth; reverse-engineering behavior from code into SR without a bug-fix is forbidden (section 1).
2. **MVR-2 — substrate V1–V6.** The substrate MUST provide: immutable history (V1), atomic change unit (V2), diff & review (V3), branching/change-set (V4), cross-substrate version pin (V5), author + timestamp (V6).
3. **MVR-3 — reactive stage-independent ADAPT (0..N per TZ).** ADAPT is created if and only if converting the TZ → requirements at any stage produces a gap between the client's language and the language of the requirements (section 5).
4. **MVR-4 — 9 SPEC types, closed list** (section 7).
5. **MVR-5 — pos/neg TC pairing** for every normative statement (section 8).
6. **MVR-6 — closed list of Quality Gates** QG-0..QG-2 as `required`; QG-3/QG-4 — `declared` or `absent` (section 9).
7. **MVR-7 — conformance manifest** with simultaneous `renar-version` + `senar-version` + `level` + confirmation of the mandatory clauses (section 14).

---

## 4. Workflow

### 4.1 Initial TZ

1. **Import the TZ.** Register the TZ as an immutable document (`TZ-YYYY-NNN`), capture the client's signature (author + timestamp).
2. **Adversarial review of the TZ — always mandatory.** A reviewer (a separate agent on a **different model**) issues a formal verdict: "findings present" or "no findings, no clarifications." Silent skipping is forbidden; the verdict is recorded as evidence.
3. **ADAPT — per the review result** (section 5). Findings present → an ADAPT is created and approved by dual signature. No findings → no ADAPT is created.
4. **Decomposition:** ADAPT/TZ → `BR` (business goal) → `SR` (system behavior). Each requirement states its `source`.
5. **Specifications:** `SR` → `SPEC-<TYPE>` with `constrained-by[]` links.
6. **Tasks:** `SR`/`SPEC` → `TR` (Goal + acceptance criteria) in the tracker.
7. **Tests:** for every normative statement — a `TC` pair (positive + negative).
8. **Gates:** run `QG-0 → QG-1 → QG-2` (section 9).

At stages 4–7 the adversarial review MAY fire **again**: if decomposition surfaces a question rooted in the TZ, a **new** ADAPT is created at that stage (stage independence, section 5).

### 4.2 Delta-TZ (incremental change)

1. The client registers and signs a delta-TZ (`TZ-YYYY-NNN-delta-N`) as a new immutable document.
2. Adversarial review of the delta-TZ → verdict.
3. Findings present → a delta-ADAPT (`ADAPT-NNN-delta-N`, `parent-adapt`), dual signature. No findings → no delta-ADAPT is created.
4. Reassemble a complete new version of the RENAR description of the affected area; make the changes in the implementation.

**Example of a trivial delta** (rename the field `username` → `email` on a form): the term is unambiguous, the scope is clear, there are no questions for the client → verdict "no findings" → no delta-ADAPT is created; the affected `SR` gets `source.tz-section: TZ-...-delta-1 §1`, the `parent` BR is unchanged.

### 4.3 Points of human approval (delegation to the agent)

The agent performs most steps itself, but **does not approve** — delegation has fixed points where a human is required:

| Step | What the agent does | What the human approves |
|---|---|---|
| Adversarial review | A critic agent (a different model) issues the verdict | The Architect records the verdict as evidence |
| ADAPT | The agent prepares a draft (forward interpretation + findings) | **Dual signature:** client + Architect (QG-3) |
| QG-0 Approval | The agent creates `BR`/`SR`/`SPEC` with provenance | The Architect approves the transition to `approved` |
| QG-4 Acceptance | The agent presents the result | The Stakeholder accepts the business outcome |

The agent never signs and never declares itself the owner of an artifact (section 10). If human approval is not obtained, the artifact stays in `draft` and transitions are blocked by the substrate.

---

## 5. ADAPT in full

### 5.1 Why

A TZ is written in business language and signed as a contract — it cannot be edited. Turning it into precise requirements directly often does not work out: the TZ is silent about something important, contradicts itself, or uses a term with a double meaning. Silently filling in for the client is also not allowed — that is the leakage of someone else's guesswork into the requirements. ADAPT is the bridge across this gap: a **forward interpretation** ("we understood section §4.2 of the TZ this way") and **backward findings** ("§4.3 sets no deadline — please clarify") that go to the client and come back with answers.

### 5.2 When to create one and when not (reactivity)

An ADAPT is created **if and only if** at least one holds:

- a **backward finding** in one of the 7 categories is discovered (section 5.3);
- a **term** needs clarification (no unambiguous engineering reading);
- the **scope** of work needs clarification.

If the review verdict is "no findings, no clarifications", no ADAPT is created: `BR`/`SR`/`SPEC` reference the TZ directly via `source.tz-section`, and the verdict is recorded as evidence (`source.adversarial-review-ref`).

### 5.3 The seven backward-finding categories (closed list)

| ID | Category | What is recorded |
|---|---|---|
| `contradiction` | Contradiction | Internal contradictions of the TZ (§A vs §B) |
| `gap` | Gap | The TZ is silent about something without which implementation is impossible |
| `hidden-assumption` | Hidden assumption | An engineer's assumption that may be wrong |
| `feasibility` | Feasibility | Technically infeasible or disproportionately expensive |
| `regulatory` | Regulatory | Touches legislation / compliance |
| `terminology` | Terminology | An unclear term with several meanings |
| `scope` | Scope | An unclear boundary of work |

Each entry has a stable `B-NNN`, immutable after creation.

### 5.4 Stage independence and multiplicity (0..N)

The ADAPT trigger is **not tied to TZ import**. A question for the client rooted in the TZ may surface later — during `BR → SR → SPEC` decomposition or `TC` development. Then a **new** ADAPT is created at that stage (the `trigger-stage` field). A single TZ has **zero or more** root ADAPTs — this is the normal case.

If the uncertainty is rooted **in the decomposition** (and not in the TZ), it is resolved by clarifying `SR`/`SPEC` **without** an ADAPT. An ADAPT arises only when the root is in the language or intent of the TZ.

### 5.5 Entry lifecycle and approval

Every backward finding goes through: `open → asked-to-client → answered → resolved → frozen` (with a possible return `revised → asked-to-client`). Approval of an ADAPT (QG-3) is forbidden while there is any entry in `open`/`asked-to-client`/`answered`/`revised` — all MUST be `resolved`.

An ADAPT is approved by **dual signature**: the client (the forward interpretation matches the intent; answers are final) + the Architect (findings are worked through; the interpretation is feasible). After approval an ADAPT is **immutable**.

### 5.6 Changes to an approved ADAPT — three mechanisms

A frozen ADAPT is not edited. Changes happen only by adding a new artifact via one of three paths:

| Mechanism | When | Signature |
|---|---|---|
| **delta-ADAPT** | a delta-TZ arrived (the contract changed) | dual |
| **errata-ADAPT** | the prior interpretation was **wrong** | client (if it changes a contractual outcome) or Architect only (if cosmetic) |
| **superseding ADAPT** | the prior decision was **correct** but later refuted by new requirements | the client's signature is **always** required for a contractual outcome |

**Supersession.** A new `ADAPT-NNN` with the field `supersedes: ADAPT-MMM` and a mandatory `supersession-rationale` (a reference to the conflicting `BR`/`SR`/`SPEC` and its source). The superseded ADAPT moves to the terminal state **`superseded`** (distinct from `obsolete`), stays immutable, and is kept for audit; it gets `superseded-by: ADAPT-NNN`. All derivatives with `source.adapt: ADAPT-MMM` MUST be repointed to the superseding ADAPT or re-derived — a **dangling reference to a `superseded` is forbidden**. There is no separate gate — it goes through the same QG-3.

### 5.7 AI and adversarial review

The agent creates an ADAPT **draft** automatically (forward interpretation by section, an attempt to find contradictions/gaps/unclear terms, an initial term mapping). This is a starting point, not the final. A separate critic agent on a **different model** looks for what was missed. The client **does not talk to the AI directly**: the Architect aggregates and rephrases the questions; he transcribes the client's answer into the ADAPT, noting the channel.

---

## 6. Requirements hierarchy and provenance

- **BR (Business Requirement)** — captures the business goal of a group of related SR: who, what, **why**. When an SR changes, the link to the business need is visible.
- **SR (System Requirement)** — what the system does; `parent` — exactly one BR (multiple parents are forbidden).
- **TR (Task Requirement)** — an implementation task in the tracker: Goal + acceptance criteria. References `SR`/`SPEC`, **not** ADAPT directly — all interpretations are already in SR/SPEC.

### 6.1 System levels and references to higher requirements

Every artifact carries a `scope` with a level. There are three levels:

| Level | What it is | Who can be at the level |
|---|---|---|
| `system` | The information system as a whole | `BR`, `SR`, `TR` |
| `subsystem` | A technical division: a component, service, team | `BR` (if the subsystem is a standalone product), `SR`, `TR` |
| `module` | A part of a subsystem fit for one task | `SR`, `TR` (but **not** `BR` — a business goal is not formulated at the module level) |

The base decomposition `BR → SR → TR` works within a single level. For composite systems the levels link **upward**:

- **A subsystem as a technical division** (not a standalone product): has no `BR` of its own — it inherits the system's business goal; the subsystem's `SR` has `parent` = the system's `BR`.
- **A subsystem as a standalone product** (its own business owner): has its own root `BR`. That `BR` **MUST** declare `implements[]` — a reference to the parent system's `BR` that it elaborates. Without it the link between the subsystem tree and the system tree is lost, and the traceability of "why this subsystem exists" becomes irrecoverable.

The obligation to reference upward lies on the subsystem's `BR` (via `implements[]`), not on the parent: the system does not know in advance which subsystems will implement it — they declare their affiliation. The `implemented-by[]` field on the parent `BR` is assembled by the substrate automatically from the back-references.

**implements-edge (subsystem → system).** `implements[]` is an array of `id + scope.system` pointing at the parent system's `BR`. It is a typed cross-level edge (**not** a parent): cardinality 0..N, acyclic, target in status `approved`+. One subsystem `BR` may elaborate several system `BR`. The ban on multiple `parent`s does **not** apply to this edge — it is of a separate type.

### 6.2 Artifact storage layout (informative, substrate-dependent)

> This section is **informative**: RENAR does not normalize the file layout — the substrate may be a file system, a database, a tracker, or a combination. Below is an **example** layout on a file-based substrate; an organization is free to arrange storage differently, as long as the `parent` / `source` / `implements[]` / `constrained-by[]` links and the machine-readability of the graph are preserved.

A convenient reference point for a file-based substrate is a layout by systems and levels, with TC next to the verified artifact:

```text
<requirements-root>/
├── tz/                          # immutable TZ and delta-TZ
│   ├── TZ-2026-001.md
│   └── TZ-2026-001-delta-1.md
├── adapt/                       # ADAPT (0..N per TZ), immutable after frozen
│   └── ADAPT-001.md
├── <system>/
│   ├── br/                      # BR at the system level
│   │   └── BR-01.md
│   ├── sr/
│   │   └── SR-01.md
│   ├── spec/                    # SPEC of all 9 types
│   │   ├── SPEC-API-01.md
│   │   └── SPEC-DATA-01.md
│   ├── tc/                      # TC next to its scope; pos/neg pairs together
│   │   ├── TC-01.md
│   │   └── TC-01-neg.md
│   └── <subsystem>/             # a standalone product — its own tree
│       ├── br/                  # subsystem BR with implements[] to system BR
│       │   └── BR-01.md
│       ├── sr/
│       └── tc/
└── RENAR-CONFORMANCE.yaml       # conformance manifest (section 14)
```

There is no TR here: a TR lives in the task tracker, not as a separate file (section 2). File names = the artifact `id` — this gives a stable reference that survives a title rename.

**Trace chain** (read-side) has two valid variants: through ADAPT (`source.adapt`) or directly from the TZ (`source.tz-section` + `source.adversarial-review-ref`). Both are machine-readable. A dangling reference to a `superseded` ADAPT makes the chain invalid.

---

## 7. Specifications (SPEC) — nine types, closed list

A SPEC type MUST belong to the list of nine. Creating new types locally is forbidden.

| Type | Purpose |
|---|---|
| `SPEC-ARCH` | Architecture: components, boundaries, decisions |
| `SPEC-API` | Interface contracts (endpoints, methods, formats) |
| `SPEC-DATA` | Data models, schemas, migrations, classification |
| `SPEC-INT` | Integrations with external systems |
| `SPEC-PROC` | Processes, workflow, orchestration |
| `SPEC-UI` | User interface, screens, behavior |
| `SPEC-AI` | AI components: model, risk class, judge isolation |
| `SPEC-SEC` | Security: threats, controls, requirements |
| `SPEC-OPS` | Operations: deployment, monitoring, SLO |

A SPEC is an axis parallel to the requirements. The link to a requirement is a typed `constrained-by[]` edge (an SR is constrained by specifications). The `depends-on` graph between SPECs MUST be acyclic (a DAG).

---

## 8. Test cases (TC)

A TC is a standalone artifact with its own lifecycle, not a line in code. For every normative statement of a verified artifact that is covered by at least one TC, a paired **negative** TC **MUST** exist. The exception is a statement that itself describes a negative invariant.

- `verifies[]` points at the verified artifact and its version; the reverse link `verified-by` is symmetric.
- `requirement-version` is pinned: when the requirement version increments, the TC moves to the appropriate state (staleness detection).
- An automated TC (`automation.status: automated`) MUST have a non-empty `automation.location`.
- For `SPEC-AI`: the judge model MUST differ in vendor from the production model (evaluation isolation).

TC states: `draft → ready → passing | failing`. Only the runner-actor writes `last-run`.

---

## 9. Lifecycle and quality gates (QG)

Requirement states: `draft → approved → verified → deprecated → obsolete`.
ADAPT states: `draft → review → client-ready → answered → approved → frozen`, plus the terminal `superseded` on supersession.

| Gate | What it checks | Who runs it | Level |
|---|---|---|---|
| **QG-0** Approval | The schema is valid, there is a link to a parent, the source is stated | Architect / authorized | required |
| **QG-1** Implementation | A `TR` is linked to a `SPEC`, the implementation substrate is pinned | Engineer + runner | required |
| **QG-2** Verification | All `TC` pass, a pos/neg pair, versions match | Automated runner | required |
| **QG-3** Architecture | Dual signature of the ADAPT (client + Architect); supersession too | client + Architect | declared / absent |
| **QG-4** Acceptance | The business outcome is accepted | Stakeholder | declared / absent |

QG-0..QG-2 are mandatory (`required`). QG-3/QG-4 are `declared` or `absent`. Creating new gate types locally is forbidden.

**Substrate-independent enforcement.** The substrate MUST automatically block transitions when preconditions are unmet: promote-transition (V3/V4), approve-transition (V6), reference-validation (V1/V5), `implements`-edge validation, `adapt-applicability` validation, `adapt-supersession` validation (a dangling `source.adapt` to a `superseded` — fatal).

---

## 10. Roles and signatures

**The agent (AI) is a first-class executor**: the primary generator of `BR`/`SR`/`SPEC`/`TC`/draft-ADAPT drafts and the adversarial critic. But the agent is **not the owner** of an artifact and **does not sign**.

**The human** is the owner, verifier, and approver. The ADAPT signatories are the client (on one side) and the **Architect** (the role name for Architect / Tech Lead on the executor side) on the other. By RACI: `R` (Responsible) = AI, `A` (Accountable) = the Architect. An attempt to declare the AI agent Accountable is non-conformant.

AI provenance is recorded in `ai-provenance` (model, prompt template, tokens, the fact of a human edit). The client signs only the **TZ** and the **ADAPT**.

---

## 11. Closed lists (cannot be extended locally)

- **9 SPEC types:** `ARCH / API / DATA / INT / PROC / UI / AI / SEC / OPS`.
- **7 finding categories:** `contradiction / gap / hidden-assumption / feasibility / regulatory / terminology / scope`.
- **Quality Gates:** `QG-0 / QG-1 / QG-2 / QG-3 / QG-4`.
- **V1–V6** substrate capabilities: immutable history, atomic change unit, diff & review, branching, version pin, author + timestamp.
- **ADAPT states:** including the terminal `superseded`.

Extending any list is possible only by a formal amendment to the standard (research draft → discussion → minor-version bump → migration guide).

---

## 12. Hard rules (cannot be broken)

- **A TZ and an approved ADAPT are immutable** — only the addition of new artifacts with an explicit typed link.
- **Do not reconstruct `SR`/`SPEC` from code** without a bug-fix justification (source-of-truth inversion).
- **Do not fit tests** to the implementation; a change to verified behavior is tagged `[test-spec-change]`.
- **Provenance is mandatory** for every `BR`/`SR`/`SPEC` (`source.tz-section` always; `source.adapt` or `source.adversarial-review-ref`).
- **A TC pair** (positive + negative) for every normative statement.
- **Adversarial review of the TZ is always mandatory**; "no ADAPT needed" is a recorded verdict of a different model, not a silent assumption.
- **Do not invent closed lists** (section 11).
- **A dangling reference to a `superseded` ADAPT** is forbidden — repoint or re-derive the derivatives.

---

## 13. Minimal recording forms (frontmatter)

### TZ
```yaml
id: TZ-YYYY-NNN
type: TZ
status: registered            # immutable after registration
signed-by-client: "<name + role>"
signed-date: "<ISO-date>"
document-version-ref: "<substrate version identifier>"
```

### ADAPT
```yaml
id: ADAPT-NNN
type: ADAPT
trigger-stage: import-tz       # import-tz | decompose-br | decompose-sr | spec | tc
source-tz: { id: TZ-YYYY-NNN, signed-date: "<ISO>", signed-by-client: "<name+role>" }
parent-adapt: { id: ADAPT-NNN, delta-tz: TZ-YYYY-NNN-delta-N }   # for a delta-ADAPT
supersedes: ADAPT-MMM          # only for a superseding ADAPT
superseded-by: ADAPT-NNN       # auto-derived on the superseded one
supersession-rationale: "<conflicting BR/SR/SPEC + source>"   # mandatory if supersedes
status: draft | review | client-ready | answered | approved | frozen | superseded | obsolete
approval:
  client-signature: { signed-by: "<name>", role: "<role>", organization: "<org>", signed-at: "<ISO>" }
  architect-signature: { signed-by: "<name>", role: architect, signed-at: "<ISO>" }
open-questions-count: 0        # MUST be 0 for approved
```

### BR
```yaml
id: BR-NN
type: BR
status: draft                  # draft → approved → verified → deprecated → obsolete
level: system | subsystem
implements: [{ id: BR-MM, scope.system: "<system>" }]   # for a subsystem (0..N)
source:
  adapt: ADAPT-NNN             # if an ADAPT exists
  tz-section: "§N.N"           # always mandatory
  adversarial-review-ref: "<verdict>"   # if source.adapt is omitted
```
Body (mandatory sections):
```markdown
## Need
Who (role), what (action), why (business goal) — one sentence.
## Success criteria
Measurable outcomes, 3–7 items; each independently verifiable.
## Context
Where the requirement came from (reference to an ADAPT section if present); what alternatives.
## Constraints
Optional: business constraints (budget, deadlines, regulation). No technical ones.
```

### SR
```yaml
id: SR-NN
type: SR
status: draft
parent: BR-NN                  # exactly one
source:
  adapt: ADAPT-NNN
  adapt-section: "Forward §3"
  tz-section: "§3.4"           # always mandatory
constrained-by: [SPEC-API-02, SPEC-UI-04]
verified-by: [TC-NN, TC-NN-neg]
```
Body (mandatory sections):
```markdown
## Requirement
One sentence in normative form: "The system MUST …".
## Behavior
Detailed observable behavior; functional scenarios.
## Constraints
If applicable: non-functional (performance, security). Full ones — in SPEC.
## Link to SPEC
If constrained-by[] is present: which aspects of behavior are governed by which SPEC.
```

### SPEC
```yaml
id: SPEC-API-NN
type: SPEC-API                 # one of the 9 closed types
status: draft
source: { adapt: ADAPT-NNN, tz-section: "§N.N" }
depends-on: [SPEC-DATA-NN]     # DAG, no cycles
```

### TR (in the tracker, not a file)
```yaml
id: TR-NNN
type: TR
goal: "<what to do>"
acceptance-criteria: ["<criterion 1>", "<criterion 2>"]
implements-spec: SPEC-API-NN
parent-sr: SR-NN
```
Body (mandatory sections; the names `Goal`/`Acceptance Criteria`/`Scope` are canonical):
```markdown
## Goal
One paragraph; the outcome the TR makes observable.
## Acceptance Criteria
A numbered list of falsifiable criteria; covers positive and negative scenarios.
## Scope
What is in and what is **not** in the TR.
## References
If applicable: to the SPEC in implements-spec[] and the sections of the parent SR.
```

### TC
```yaml
id: TC-NN
type: TC
tc-type: acceptance           # acceptance | ux | system | contract | eval | security
negative: false               # the paired TC-NN-neg is mandatory (negative: true)
verifies: [{ id: SR-NN, requirement-version: "1.4" }]
status: draft                 # draft → ready → passing | failing
automation: { status: automated, location: "<path/identifier>" }
```
Body (mandatory sections; `## Pass criterion` and `## Fail criterion` are fixed names):
```markdown
## Context
Which clause of the verified artifact the TC references; a quote or paraphrase.
## Preconditions
The system and data state for the run; the seed mechanism.
## Steps
Runner actions. For tc-type: ux — intentions, not selectors.
## Pass criterion
Binary, observable, reproducible.
## Fail criterion
Observable signs of a violation (not the negation of Pass): leaks, side effects, races.
## Postconditions
The expected state after the run; cleanup.
## Out of scope
What is deliberately not checked, naming the paired TC.
```

---

## 14. Conformance minimum

A project declares conformance through a **manifest** (immutable, V1) with mandatory fields:

```yaml
renar-version: 1.3-draft
senar-version: "<version>"
level: RENAR-1                 # RENAR-1 (ad-hoc) … RENAR-5 (optimizing)
mandatory-clauses:
  sot-inversion: true
  substrate-v1-v6: { v1: true, v2: true, v3: true, v4: true, v5: true, v6: true }
  adapt-reactive: true
  spec-types-closed-list: true
  tc-pos-neg-pairing: true
  quality-gates-closed-list: true
  conformance-manifest: true
```

An implementation MAY **tighten** the requirements (`declared-stricter`: QG-3/QG-4 as `required`, and so on), but MUST NOT **weaken** them: it cannot declare ADAPT optional, allow a single TC for a normative statement, or omit `senar-version`/`level`. The levels `RENAR-1..RENAR-5` reflect process maturity, not the volume of documentation.

---

## 15. Glossary of key terms

- **TZ** — the technical assignment: the client's contractual input, immutable.
- **ADAPT** — the two-way adaptation TZ → requirements; reactive, 0..N per TZ.
- **Forward interpretation (Forward)** — the translation of a TZ section into the language of requirements.
- **Backward finding** — a recorded question/problem in one of the 7 categories.
- **Adversarial review** — a review by a separate agent on a different model; issues a verdict.
- **Provenance / source** — the machine-readable origin of an artifact.
- **implements-edge** — a typed edge "subsystem BR implements system BR".
- **Supersession** — the cancellation of a previously correct but refuted ADAPT; the state `superseded`.
- **QG (Quality Gate)** — a lifecycle-transition gate.
- **SoT inversion** — requirements (not code) are the source of truth about behavior.
- **MVR** — Minimum Viable RENAR: the seven mandatory statements.
- **Architect** — the role name for Architect / Tech Lead; the owner and signatory on the executor side.

---

*RENAR 1.3-draft — the operational edition for the agent. Full normative corpus: [renar.tech](https://renar.tech). © 2026 Vadim Soglaev, Andrey Yumashev. CC BY-SA 4.0.*
