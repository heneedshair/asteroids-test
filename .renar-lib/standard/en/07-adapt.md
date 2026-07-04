---
title: "ADAPT — two-way TZ adaptation"
order: 7
lang: en
---
# 07. ADAPT — two-way TZ adaptation

> **Part of the RENAR Standard v1.0-draft** · [← Table of contents](README.md)

## 7.1 What ADAPT is and why it exists

The client sends a TZ in their own language — the language of business and of the contract. It is signed and no longer changes: it is a contract. But turning it directly into precise requirements almost never works. Somewhere the TZ is silent about something important ("data export" — in what format? for what retention period?), somewhere it contradicts itself, somewhere the same term means one thing to the client and another to the engineer. Editing the TZ is not allowed — it is a contract. Silently filling in the gaps on the client's behalf is also not allowed: that way someone else's guesses seep into the requirements, and at acceptance the "this is not what we ordered" surfaces.

ADAPT is the bridge across this gap. It has two sides: **forward interpretation** ("we understood §4.2 of the TZ as follows") and **backward findings** ("§4.3 does not set a deadline — please clarify"), which go to the client and come back as answers. When both sides are agreed and signed — by the client and by the Architect — ADAPT freezes **with respect to its subject**, and the affected BR / SR / SPEC are derived from it. This makes the TZ interpretation explicit, recorded, and verifiable, rather than living in the implementer's head.

ADAPT need not precede all derivation. The typical occasion to create it is TZ import, but a question to the client rooted in the TZ may also surface **later** — during the BR → SR → SPEC decomposition, or while developing test cases. A **new** ADAPT then arises, bound to the stage where the finding was discovered, while previously derived artifacts remain valid. ADAPT is not always created: if the conversion of the relevant TZ fragment is unambiguous and there are no questions, it is not needed ([§7.4.1](#7.4.1)).

ADAPT is a consequence of [Statement 2 of §2.4](02-methodology-positioning.md#2.4) (RENAR is a waterfall-form ≠ classical waterfall, because ADAPT provides two-way adaptation instead of "throwing the specification over the wall").

## 7.2 The problem ADAPT regulates

Without a formalized intermediate artifact between the TZ and BR/SR, one of two negative outcomes arises:

| Outcome | What happens |
|---|---|
| **TZ drift** | The TZ is edited after signing → the contract is breached |
| **Hidden interpretation** | Engineering assumptions silently seep into BR/SR/SPEC → the trace chain and provenance break down |

ADAPT eliminates both outcomes: the TZ remains an immutable contractual document, **all** interpretations, clarifications, and backward findings are registered in ADAPT, which itself becomes immutable after the dual signature (§7.5).

---

## 7.3 The two-way adaptation cycle

```text
        ┌───────────────────────────────┐
        │   TZ (immutable, contract)    │
        └───────────────┬───────────────┘
                        │ source
                        ▼
┌──────────────────────────────────────────────┐
│              ADAPT-NNN                        │
│                                              │
│  Forward interpretation (engineer → client)  │
│  ─ by TZ section                             │
│  ─ term mapping                              │
│  ─ filled-in scenarios                       │
│  ─ scope clarification                       │
│                                              │
│  Backward findings (engineer → client)       │
│  ─ 7 categories of records                   │
│  ─ lifecycle: open → asked → answered →      │
│              resolved → frozen               │
│                                              │
│  Status: draft → review → client-ready →     │
│         answered → approved → frozen         │
│  Approval: dual signature client+architect   │
└────────────────────┬─────────────────────────┘
                     │ approved
                     ▼
        ┌───────────────────────────────┐
        │   BR / SR / SPEC              │
        │   reference ADAPT§            │
        │   through source.adapt        │
        └───────────────────────────────┘
```

The TZ is the primary source; ADAPT is the canonical source of interpretation; BR/SR/SPEC reference ADAPT, not the TZ directly.

The "TZ → ADAPT" input shown is the typical one (TZ import), but **not the only one**. The cycle trigger is stage-agnostic: if a question to the client rooted in the TZ surfaces later — at the BR → SR → SPEC decomposition stage or while developing TC — the cycle runs again and produces a **new** ADAPT-NNN, bound to the stage at which the finding was discovered ([§7.4.1.1](#7.4.1)). A single TZ may have several such ADAPTs (MVR-3, [§0.5](00-introduction.md#0.5)).

---

## 7.4 Normative requirements for ADAPT

### 7.4.1 Reactive obligatoriness

ADAPT is a **reactive artifact**: it is created if and only if converting the TZ → RENAR description produces a gap between the client's language and the requirements language ([§7.12](#7.12)). If the conversion is unambiguous, no ADAPT is created; BR / SR / SPEC are derived directly from the TZ through the mandatory `source.tz-section` field.

#### 7.4.1.1 Conditions for ADAPT obligatoriness

ADAPT is REQUIRED **if and only if** at least one of the conditions holds:

1. **A backward finding is discovered.** The adversarial reviewer ([§7.10.2](#7.10.2)) at any stage of the requirements lifecycle (TZ import or BR → SR → SPEC → TC decomposition) has identified ≥ 1 record under at least one of the 7 categories of §7.4.4 (`contradiction`, `gap`, `hidden-assumption`, `feasibility`, `regulatory`, `terminology`, `scope`) rooted in the language or intent of the TZ.
2. **Term mapping is required.** The TZ uses a term that has no unambiguous engineering interpretation (requires a "client → engineer" mapping).
3. **Scope clarification is required.** The scope from the TZ is ambiguous and requires fixing "in / out".

If none of the conditions holds (the adversarial reviewer returned a "no findings, no clarifications" verdict), no ADAPT **is created**. BR / SR / SPEC reference the TZ directly through `source.tz-section` ([§6.5.2](06-requirements-hierarchy.md#6.5.2), [§6.6.2](06-requirements-hierarchy.md#6.6.2), [§8.5](08-specifications.md#8.5)).

#### 7.4.1.2 The adversarial reviewer as a mandatory gate

The adversarial review of the TZ ([§7.10.2](#7.10.2)) is a **mandatory step** for every TZ at import, regardless of whether ADAPT is created or not. The verdict at import is one-time but **not final**: at the derivation stages (BR → SR → SPEC → TC) the adversarial reviewer issues the verdict again as decomposition uncovers new questions about the TZ. A "no findings" verdict at import does not block the appearance of ADAPT later, if a finding rooted in the TZ is discovered at the decomposition stage ([§7.7.3](#7.7.3)). The adversarial reviewer issues a formal verdict in one of two forms:

| Verdict | What is recorded | Consequence |
|---|---|---|
| **"findings present"** | A list of concrete findings across the 7 categories + an indication of TZ sections | ADAPT is REQUIRED; the lifecycle of §7.4.5 starts |
| **"no findings, no clarifications"** | Confirmation by the adversarial reviewer (a different model, §9.4) that the TZ converts to RENAR unambiguously | ADAPT MAY be omitted; the verdict is recorded in substrate evidence (V6 author + timestamp), available for audit |

The hook ([§10.11.1](10-lifecycle-qg.md#10.11.1) `adapt-applicability validation`), when BR / SR / SPEC are created without `source.adapt`, checks for the presence of evidence of a "no findings" verdict for the corresponding TZ. The absence of evidence is fatal: creation is blocked until the adversarial review is passed.

#### 7.4.1.3 Prohibition of silent skipping

Creating BR / SR / SPEC from a TZ **without an adversarial review** (skipping ADAPT without a verdict) is a violation of the standard. This preserves the Source-of-Truth inversion ([§2.3](02-methodology-positioning.md#2.3)): "no findings" is a **recorded assertion** by the adversarial reviewer, not a silent assumption by the Architect. The verdict MUST be recorded by a substrate-native mechanism V6 (author + timestamp) and be available on an auditor's request ([§13.5](13-conformance.md#13.5)).

When a delta-TZ is present, the same rule applies: a delta-ADAPT is created reactively, upon findings during the adversarial review of the delta-TZ ([§7.6](#7.6)).

#### 7.4.1.4 Multiplicity of ADAPTs per single TZ

Since the trigger is stage-agnostic ([§7.4.1.1](#7.4.1)), a single unmodified TZ may have **zero or more** root ADAPTs (cardinality 0..N — a reformulation of MVR-3, [§0.5](00-introduction.md#0.5)):

- **zero** — adversarial review at all stages returned "no findings";
- **one** — a finding was discovered once (typically at import);
- **several** — findings rooted in the TZ arose at different derivation stages (import, then BR → SR decomposition, etc.).

Each ADAPT keeps a stable end-to-end `ADAPT-NNN` and records a `trigger-stage` field — the stage at which it was produced ([§7.8.1](#7.8)). Multiplicity is the **regular** case, not an exception, and it does not weaken provenance: each BR / SR / SPEC still references exactly one ADAPT (through `source.adapt`) or the TZ directly (through `source.tz-section`) from which it is derived.

### 7.4.2 Immutability of the TZ

The TZ is a contractual document. After a TZ is registered in the substrate, its content **is not edited**. If during work it turns out that the TZ has an error / gap / contradiction, this is registered as a backward finding in ADAPT (§7.4.4), the client gives an answer, and the answer becomes part of ADAPT. The TZ remains immutable.

With a large number of edits, or when the scope changes, the client signs a delta-TZ as a new immutable document (§7.6).

### 7.4.3 Forward adaptation of the TZ

For each TZ section, the forward-interpretation section of ADAPT MUST contain:

| Element | Obligatoriness | Purpose |
|---|---|---|
| Exact reference to TZ§N.N | REQUIRED | provenance |
| Quote from the TZ (or a paraphrase with an explicit marker) | REQUIRED | Context |
| Engineering interpretation of the section | REQUIRED | Translation of the client's language → the requirements language |
| Term mapping (client → engineer) | REQUIRED if applicable | Term disambiguation |
| Filled-in scenarios | REQUIRED if the TZ implies them | Explicit recording of implicit cases |
| Scope clarification (in / out) | REQUIRED | Scope |
| References from the forward interpretation to BR/SR/SPEC | auto-derived | Trace chain ([§7.7](#7.7)) |

### 7.4.4 Backward findings and their categories

The backward-findings section of ADAPT records discovered problems across seven normative categories. **The list of categories is closed at v1.0**; adding new categories is done through the formal change procedure of the standard (see [chapter 13](13-conformance.md)). The general closed-list policy and the master index — [§1.7.5](01-scope.md#1.7.5).

| ID | Category | What is recorded |
|---|---|---|
| `contradiction` | Contradiction | Internal contradictions in the TZ (§A vs §B) |
| `gap` | Gap | The TZ is silent about something without which implementation is impossible |
| `hidden-assumption` | Hidden assumption | An engineer's assumption that may be wrong |
| `feasibility` | Feasibility | A technically infeasible or disproportionately expensive requirement |
| `regulatory` | Regulatory | A requirement that touches legislation / compliance |
| `terminology` | Terminology | An unclear TZ term with several possible meanings |
| `scope` | Scope | An unclear scope |

Each backward-finding record has a **stable ID** (`B-NNN`), immutable after creation. The ID is not reused even for withdrawn records (audit log).

### 7.4.5 Lifecycle of a single backward-finding record

```text
open → asked-to-client → answered → resolved → frozen
              ↑                          │
              └────── revised ───────────┘  (if the answer needs clarification)
```

| Status | What it means |
|---|---|
| `open` | The engineer recorded it; not sent to the client |
| `asked-to-client` | The question is sent to the client, an answer is awaited; the date is recorded |
| `answered` | The client answered; the answer is recorded in the document with author + timestamp (substrate capability V6) |
| `resolved` | The engineer integrated the answer into the forward interpretation |
| `revised` | The client's answer is vague; a repeat question. Transition back to `asked-to-client` |
| `frozen` | After ADAPT approval — changes are impossible |

ADAPT approval (§7.5) is prohibited while at least one backward-finding record is in status `open` / `asked-to-client` / `answered` / `revised`. All such records MUST be in `resolved` before approval.

---

## 7.5 ADAPT approval — the dual signature

ADAPT moves from status `answered` to `approved` only after a **dual signature** (an atomic change unit, substrate capabilities V2 + V3 from [§3.3](03-substrate-versioning.md)):

| Signature | Who | What it confirms |
|---|---|---|
| Client signature | The client or a client representative with authority | The forward interpretation of the TZ matches what the customer had in mind; the answers to backward-finding questions are final |
| Architect signature | The Architect on the implementer's side | All backward findings are handled (none unresolved); the forward interpretation is technically feasible |

The substrate-native implementation of the signature is a combination of V3 (diff & review) + V6 (author + timestamp). The concrete mechanism (digital signature / approval process / dual review attestation) is chosen by the implementation and recorded in the conformance manifest ([§3.7](03-substrate-versioning.md#3.7)).

After approval, ADAPT is **immutable** on par with the TZ. Further changes are made only by adding a new artifact with a typed link, through one of three non-overlapping mechanisms: delta-ADAPT for a delta-TZ (§7.6.1), errata for an interpretation error (§7.6.3), or supersession of a previously correct decision (§7.6.4). The frozen ADAPT itself is not edited in any of them.

---

## 7.6 Delta-TZ and delta-ADAPT

### 7.6.1 Workflow

A delta-ADAPT follows the same reactive rule of §7.4.1 as the root ADAPT: it is created upon findings during the adversarial review of the delta-TZ.

When a delta-TZ arrives from the client:

1. The client registers the delta-TZ in the substrate as a new immutable document (`TZ-YYYY-NNN-delta-N`).
2. The client signs the delta-TZ (V6 author + timestamp).
3. The adversarial reviewer ([§7.10.2](#7.10.2)) conducts a review of the delta-TZ and issues a verdict.
4. **If the verdict is "findings present"** — the Architect / AI agent creates a delta-ADAPT (`ADAPT-NNN-delta-N`) with the frontmatter field `parent-adapt: ADAPT-NNN` and `source-tz: TZ-YYYY-NNN-delta-N`. The Forward interpretation covers only the delta-TZ sections. Backward findings are recorded against the delta-TZ. Approval — the dual signature of §7.5.
5. **If the verdict is "no findings, no clarifications"** — no delta-ADAPT is created. The verdict is recorded in the substrate with V6 author + timestamp. BR / SR / SPEC changed as a result of the delta-TZ reference `source.tz-section: TZ-YYYY-NNN-delta-N` directly.

In both cases the evidence of the adversarial review (the verdict) MUST be machine-accessible for audit (hook §10.11.1 reference-validation).

### 7.6.1bis Example: a trivial delta-TZ

Delta-TZ: "rename the 'username' field on the registration form to 'email'".

1. The client signs `TZ-YYYY-NNN-delta-1`.
2. The adversarial reviewer checks: the term is unambiguous (`email` is a standard engineering term), the scope is clear (one field on one form), there are no questions for the client.
3. Verdict: "no findings, no clarifications"; recorded in the substrate.
4. The delta-ADAPT **is not created**.
5. SR-NN with the behavior "POST /auth/sign-up accepts email" receives an update: `source.tz-section: TZ-YYYY-NNN-delta-1 §1`. The SR `parent` BR-NN does not change.

### 7.6.2 Delta-ADAPT chain

```text
ADAPT-001 (from TZ-YYYY-NNN main)
  └─ ADAPT-001-delta-1 (from TZ-YYYY-NNN-delta-1)
        └─ ADAPT-001-delta-2 (from TZ-YYYY-NNN-delta-2)
              └─ ADAPT-001-delta-3 (from TZ-YYYY-NNN-delta-3)
```

The chain is strictly sequential: applying delta-ADAPTs MUST proceed in order (see the cross-substrate version pin V5 in [§3.3.5](03-substrate-versioning.md#3.3.5)). Renumbering or reordering delta-ADAPTs in the chain is prohibited.

### 7.6.3 Errata for an already approved ADAPT

If, a considerable time after approval, it is discovered that the forward interpretation of the TZ in ADAPT-NNN is wrong, or the resolution of a backward finding is recorded incorrectly — two permissible outcomes:

| Outcome | Artifact |
|---|---|
| The TZ contains an ambiguity discovered late | delta-ADAPT with a new backward-finding record and a client answer |
| Wrong interpretation (an engineer's error) | errata-ADAPT-NNN-M as a separate artifact with the client signature (if it changes the contractual outcome) or the Architect signature only (if the fix is cosmetic) |

In both outcomes the **frozen ADAPT is not edited**. Only the addition of new artifacts with an explicit typed link.

### 7.6.4 Supersession of an approved ADAPT

Delta and errata do not cover one case: a previously accepted decision was **correct**, but requirements formed later **contradict** it under a new understanding. This is not an engineer's error (errata) and not a new contract from the client (delta) — it is the cancellation of a previously correct decision. For it, a third mechanism is introduced — **supersession** (`supersession`).

| Mechanism | When | Nature |
|---|---|---|
| **delta-ADAPT** ([§7.6.1](#7.6)) | a delta-TZ arrived from the client | new source: the contract changed |
| **errata-ADAPT** ([§7.6.3](#7.6)) | the former interpretation was **erroneous** | a correction of what was always wrong |
| **superseding ADAPT** (§7.6.4) | the former decision was **correct**, but requirements formed later contradict it | cancellation of a previously correct decision under a new understanding |

Supersession rules:

1. **Superseding artifact.** A new `ADAPT-NNN` is created with the frontmatter field `supersedes: ADAPT-MMM` and a mandatory `supersession-rationale` referencing the concrete contradicting requirement (`BR` / `SR` / `SPEC` ID) and its source. The superseded ADAPT receives an automatically derived back-reference `superseded-by: ADAPT-NNN` ([§7.8.1](#7.8)).
2. **Signature.** If the superseded decision had a **contractual outcome** (was signed by the client — the typical case for an approved ADAPT) — supersession REQUIRES a **new client signature**: a decision agreed with the client cannot be cancelled unilaterally. If, however, the fix is strictly cosmetic and does not touch the contractual outcome, the Architect signature alone is permitted, without the client (by analogy with the errata rule, [§7.6.3](#7.6)). No separate QG is introduced — supersession passes through the same QG-3 (dual signature, [§7.5](#7.5), [§10.8.5](10-lifecycle-qg.md#10.8)).
3. **State.** The superseded `ADAPT-MMM` moves to the dedicated terminal state **`superseded`** — separate from `obsolete` (becoming outdated) and from `frozen`. `superseded` is immutable and is **retained** for audit (immutable history, substrate capability V1); it is not deleted. The transition is regulated in [§10.8.5](10-lifecycle-qg.md#10.8).
4. **Redirection of derivatives.** All `BR` / `SR` / `SPEC` with `source.adapt: ADAPT-MMM` MUST be either redirected to the superseding ADAPT or re-derived. A dangling `source.adapt` reference to an ADAPT in status `superseded` is **fatal**: the gate `check-adapt-supersession.js` blocks it ([§10.11.1](10-lifecycle-qg.md#10.11.1)), by analogy with reference-validation.
5. **Additivity.** Like delta and errata — the superseded ADAPT **is not edited**; only a new artifact and the typed link `supersedes` / `superseded-by` are introduced.

Supersession is an extending capability: a single ADAPT without supersessions remains a valid special case, and migration of existing projects is not required.

---

## 7.7 Relationship of ADAPT to other artifacts

### 7.7.1 BR / SR / SPEC reference ADAPT through `source.adapt`

```yaml
# Frontmatter SR (example)
source:
  adapt: ADAPT-001
  adapt-section: "Forward §3"   # forward interpretation; canonical section identifier — Forward §*
  tz-section: "§3.4"            # for traceability; the primary source remains the TZ
```

The `source.adapt` field is conditional: present when the TZ → RENAR conversion required ADAPT; omitted when the adversarial reviewer returned a "no findings" verdict — then the `source.adversarial-review-ref` field is REQUIRED ([§7.4.1](#7.4.1)). The `source.tz-section` field is REQUIRED always (the dual trace chain).

### 7.7.2 The full trace chain

```text
TC-NN  →  verifies SR-12  →  derived from ADAPT-001 §4 (forward interpretation)
                                  │     │
                                  │     └─ resolves B-007 (was: contradiction,
                                  │            answered by client 2026-03-15)
                                  │
                                  └─ interprets TZ-YYYY-NNN §3.4
```

When verifying from a test case, one can reach: (a) the source TZ section, (b) the forward interpretation of that section, (c) the implementer's questions on backward findings, (d) the client's answers, (e) the derived BR / SR / SPEC.

### 7.7.3 TR does not reference ADAPT directly

A TR (task) references SR / SPEC, and those already reference ADAPT. The task implementer **does not access ADAPT directly** — all necessary interpretations are already contained in SR / SPEC. If the implementer discovers an ambiguity in an SR, the root determines the outcome (Q1, [§7.4.1.1](#7.4.1)):

- **root in decomposition** (not in the TZ — for example, an imprecise SR wording, a missed `constrained-by[]` link) — resolved by clarifying the SR / SPEC **without** ADAPT;
- **root in the language or intent of the TZ** — a backward finding is registered in ADAPT. If an ADAPT for this TZ already exists, a new record is added; if an ADAPT has not yet been created (the verdict at import was "no findings"), a **new** ADAPT is created at the current stage ([§7.4.1.1](#7.4.1)). This is the regular case, not an exceptional one.

---

## 7.8 ADAPT schema

### 7.8.1 frontmatter (mandatory fields)

```yaml
---
id: ADAPT-NNN                       # immutable; NNN sequential per project
title: "TZ adaptation <name>"
type: ADAPT
trigger-stage: import-tz            # stage that produced the ADAPT (§7.4.1.4):
                                    # import-tz | decompose-br | decompose-sr | spec | tc

source-tz:
  id: TZ-YYYY-NNN
  signed-date: "<ISO-date>"
  signed-by-client: "<name + role>"
  document-version-ref: "<substrate-native version identifier>"   # V5 pin (see §3.3.5)

parent-adapt:                       # for delta-ADAPT
  id: ADAPT-NNN
  delta-tz: TZ-YYYY-NNN-delta-N

supersedes: ADAPT-MMM               # only for a superseding ADAPT (§7.6.4); omitted otherwise
superseded-by: ADAPT-NNN            # auto-derived; set on the superseded ADAPT
supersession-rationale: >           # mandatory if supersedes: is present
  "<reference to the contradicting BR/SR/SPEC ID + its source; rationale for cancellation>"

status: draft | review | client-ready | answered | approved | frozen | superseded | obsolete
created: "<ISO-date>"
last-updated: "<ISO-date>"

approval:                            # mandatory for approved
  client-signature:                  # mandatory for approved
    signed-by: "<name>"
    role: "<role>"
    organization: "<client-org>"
    signed-at: "<ISO-datetime>"      # V6 timestamp
    signature-ref: "<substrate-native reference>"
  architect-signature:               # mandatory for approved
    signed-by: "<name>"
    role: architect
    signed-at: "<ISO-datetime>"

generates-requirements: []           # auto-derived; BR/SR from this ADAPT
generates-specs: []                  # auto-derived; SPEC-* from this ADAPT
open-questions-count: integer        # auto-derived; mandatory 0 for approved
resolved-questions-count: integer

ai-provenance:                       # mandatory if the ADAPT draft was AI-generated
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  human-edits: boolean               # mandatory true for approved — the client saw the text
---
```

Note: ADAPT exists in only one mode (dual signature, the full lifecycle of §7.4.5). Reactivity ([§7.4.1](#7.4.1)) is expressed **at the level of creation**: if the adversarial reviewer returned a "no findings, no clarifications" verdict, ADAPT is not created at all, rather than being created in a simplified form.

### 7.8.2 Body structure (mandatory sections)

The mandatory sections of the ADAPT body:

1. **Summary** — 3–5 paragraphs for one-page reading by the client.
2. **Term mapping** — a "client → engineer" table.
3. **Forward interpretation (the Forward section)** — a section for each TZ section with the mandatory elements from §7.4.3.
4. **Backward findings** — all records with the lifecycle from §7.4.5.
5. **Backward-findings summary** — a statistical table by categories and statuses.
6. **Derived-artifacts table** — an auto-derived list of BR / SR / SPEC.
7. **ADAPT change history** — substrate-native, auto-generated.

Optional sections are at the implementation's discretion and are not regulated.

---

## 7.9 Quality Gates for ADAPT

ADAPT has a dedicated state machine. Details in [chapter 10 §10.4](10-lifecycle-qg.md). Brief summary:

| Gate | Precondition | Postcondition |
|---|---|---|
| QG-ADAPT-draft | ADAPT created; frontmatter present | The forward interpretation covers all TZ sections |
| QG-ADAPT-review | Forward interpretation filled in; initial backward findings in `open` | All backward findings in `open` or `asked-to-client` |
| QG-ADAPT-client-ready | All backward findings in `asked-to-client`; the question package is formed | Ready to send to the client |
| QG-ADAPT-answered | All backward findings in `answered`; resolution begun | Ready for finalization |
| QG-ADAPT-approve | All backward findings in `resolved`; the dual signature is ready | ADAPT immutable; generation of BR / SR / SPEC is permitted |
| QG-ADAPT-frozen | `approved` | Further changes — only through delta-ADAPT or errata |

The substrate hooks ([§3.3.3 V3](03-substrate-versioning.md#3.3.3), [§3.3.5 V5](03-substrate-versioning.md#3.3.5)) MUST:

- Block the transition to `approved` when `open-questions-count > 0`.
- Block the creation of BR / SR / SPEC with `source.adapt` on an ADAPT in a status below `approved`.
- Recompute `open-questions-count` / `resolved-questions-count` after each change.

---

## 7.10 ADAPT and AI generation

### 7.10.1 The AI agent creates a draft ADAPT

At TZ import, the AI agent creates a **draft ADAPT** automatically: the forward interpretation by section, an attempt to detect contradictions / gaps / terminology ambiguities, a first version of the term mapping. This draft is a starting point for the Architect, not the final artifact.

### 7.10.2 The adversarial reviewer

Application of the **adversarial review principle** (a separate AI agent-critic with a **different model**; the procedure — [guide/07 §4.5](../../guide/en/07-failure-modes.md)): it looks for what the primary agent missed — missing backward findings. If the adversarial reviewer finds at least three serious new findings, the primary draft is returned for rework.

### 7.10.3 The client does not communicate with the AI directly

Questions on backward findings are aggregated by the Architect into a human format **before being sent to the client**. The Architect MAY remove duplicates, rephrase into the client's language, merge related ones. The client sees a prepared list of questions, not the raw output of the AI agent. The client's answer (in any form: text, video call, letter) is transcribed by the Architect into ADAPT with an indication of the channel and authentication.

---

## 7.11 Storage scheme

ADAPT documents are stored in the `adapt/` subfolder of the requirements substrate:

```text
[project]/
  adapt/
    ADAPT-001-main.md
    ADAPT-001-delta-1.md
    ADAPT-001-delta-2.md
    ADAPT-002-main.md
    errata/
      errata-ADAPT-001-1.md
  tz/
    TZ-YYYY-NNN.md
    TZ-YYYY-NNN-delta-1.md
```

The concrete file structure on a concrete substrate is substrate-specific (see [guide/03](../../guide/en/03-tool-guide-git.md) for distributed VCS; [guide/04](../../guide/en/04-document-store-substrate.md) for a document-oriented store).

---

## 7.12 The relationship of the TZ and the RENAR description

### 7.12.1 Two languages with a variable distance

The TZ and the RENAR description are two different artifacts with different natures:

| Parameter | **TZ** | **RENAR description** |
|---|---|---|
| Target reader | The client (human) | The AI agent ([§0.2.1](00-introduction.md#0.2.1)) and the human verifier |
| Language | The client's language (business domain, contractual vocabulary) | The requirements language (canonical IDs, closed lists, formal frontmatter and graph links) |
| Completeness | Allows defaults, incompleteness, ambiguity of wording | Allows no defaults; completeness is the lower bound of machine-enforceability ([§0.3](00-introduction.md#0.3)) |
| Evolution | Incremental: the first TZ describes the system completely, the subsequent ones — only the delta ([§7.6](#7.6)) | Non-incremental: before changing the system, a new full version of the RENAR description is created, and only then does the AI agent make changes in the implementation |
| Status after signing | An immutable contractual document ([§7.4.2](#7.4.2)) | Evolves through an approved delta-ADAPT or (when no ADAPT is created, §7.4.1) through source.tz-section directly |

The distance between the two languages is **variable**. Sometimes TZ sections are worded unambiguously enough for the AI agent to convert them into BR/SR/SPEC without loss of meaning. Sometimes the reverse: the TZ contains a contractual phrase that has several engineering interpretations, or omits behavior without which implementation is impossible.

### 7.12.2 ADAPT — a reactive bridge between languages

ADAPT exists only when a gap arises between the languages. Its forward interpretation (forward, [§7.4.3](#7.4.3)) is a **translation** of concrete TZ sections from the client's language into the requirements language. The backward findings (backward, [§7.4.4](#7.4.4)) are a formalization of the fact that, during translation, gaps, ambiguities, or contradictions were discovered that require agreement with the client.

Three consequences follow from this nature:

1. **ADAPT is a reactive artifact by design.** The existence of a gap between the languages is a necessary condition for creation ([§7.4.1.1](#7.4.1)); a formal ADAPT without content loses its meaning for audit and devalues the other ADAPTs.
2. **The adversarial reviewer is the only one who declares the absence of a gap.** "ADAPT is not needed" is a recorded verdict by a different model ([§7.10.2](#7.10.2), [§7.4.1.3](#7.4.1)), not a silent assumption by the Architect.
3. **The form of ADAPT is the only one.** It is created in the full form (dual signature §7.5, all body sections [§7.8.2](#7.8.2), the full lifecycle [§7.4.5](#7.4.5)); intermediate "light" forms do not exist.

### 7.12.3 Why the RENAR description is always complete

The RENAR description is non-incremental by design: the AI agent ([§0.2.1](00-introduction.md#0.2.1)) is unable to reliably "fill in" changes relying only on the delta. A full new version of the RENAR description is the only form that guarantees that:

- machine-enforceable invariants (completeness, graph consistency, lifecycle states) are applicable to the description **as a whole**, not to the diff;
- the adversarial reviewer works on the full artifact, not on the delta;
- the subsequent steps (decomposition, TC generation, implementation — `guide/00-quickstart §"The two regular scenarios"`) are performed on the up-to-date full picture of the system.

A delta-TZ is incremental at the **source** level (the contractual side); the full new version of the RENAR description is assembled by the AI agent from the parent RENAR + either the delta-ADAPT (if it was created) or directly accounting for the delta-TZ through `source.tz-section`.

### 7.12.4 Relationship to the Source-of-Truth inversion

The TZ is a contractual artifact but **not** the Source of Truth about system behavior ([§2.3](02-methodology-positioning.md#2.3)). The Source of Truth is the RENAR description (BR / SR / SPEC / TR / TC). The TZ is the source from which the RENAR description is derived **either** through ADAPT (when there is a gap) **or** directly through `source.tz-section` (when there is no gap); code is a derived artifact of the implementation of the RENAR description. ADAPT and §7.12 fix the dual inversion: the contractual source (TZ) → the Source of Truth (RENAR description) → code. ADAPT is embedded in the chain reactively, when the bridge between the languages is needed.

---

## 7.13 Relationship to other chapters

| Chapter | Relationship |
|---|---|
| [02 Methodology positioning](02-methodology-positioning.md) | ADAPT is a consequence of Statement 2 (two-way adaptation instead of "throwing the specification over the wall") |
| [06 Requirements hierarchy](06-requirements-hierarchy.md) | BR / SR reference ADAPT through `source.adapt` |
| [08 Specifications](08-specifications.md) | SPEC-* also reference ADAPT through `source.adapt` |
| [09 Test cases](09-test-cases.md) | TC, through SR / SPEC, returns to ADAPT for the full trace chain |
| [10 Lifecycle and QG](10-lifecycle-qg.md) | the ADAPT state machine + QG-ADAPT-* gates |
| [03 Substrate versioning](03-substrate-versioning.md) | Dual signature (V6) + atomic approval (V2 + V3); immutability after approved (V1); delta-ADAPT through V4 |
| [13 Conformance](13-conformance.md) | ADAPT for each TZ is a mandatory clause |
