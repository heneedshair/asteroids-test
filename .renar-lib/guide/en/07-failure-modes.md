---
title: "Failure modes"
description: "8 drift classes, 14 AI risks, organizational failure patterns. For each: symptom, detection, prevention, recovery."
order: 7
lang: en
version: "1.0-draft"
---

# 07. Failure modes

> A systematic survey of every known way a RENAR project can break down: technical drift between artifacts and implementation, AI-specific risks, and (most importantly) organizational patterns where the process exists on paper but does not work. Drift classes are normalized in [standard/00 §0.3](../../standard/en/00-introduction.md#0.3); AI risks — in [reference/03](../../reference/en/03-ai-risk-register.md). For each failure mode — symptom, how to detect, how to prevent, how to recover.
>
> **Prerequisites:** [RENAR Core](../../core/en/renar-core.md), [reference/03-ai-risk-register.md](../../reference/en/03-ai-risk-register.md).

---

## 1. Map of failure modes

Three classes of problem:

| Class | Where it lives | How it surfaces |
|---|---|---|
| **Drift** | A mismatch between different representations of the same entity (frontmatter ↔ DB, requirement ↔ code, TC ↔ requirement) | Reconciliation hook (drift detection, [§4.11](../../standard/en/04-terms.md#4.11)) |
| **AI risks** | Properties of AI generation (hallucination, bias, injection, model drift) | Adversarial review + eval tests + AI risk register ([reference/03](../../reference/en/03-ai-risk-register.md)) |
| **Organizational** | A mismatch between the formal process and the team's real practices | Behavioral signals: the approval pattern, the frequency of disputes, the frequency of bypass |

Drift and AI risks are caught by substrate mechanisms. Organizational failures are caught by no substrate; they require human-level process reviews. This chapter covers all three.

---

## 2. The 8 drift classes

For each: symptom (how it looks from the outside), detection (how to catch it automatically), prevention (how to avoid it), recovery (what to do once it has happened).

### 2.1 Schema drift

**Symptom:** The fields in an artifact's frontmatter diverge from what the substrate expects / supports.

**Detection:** On every change to an artifact, the substrate validates the frontmatter against the schema ([reference/02-schemas.md](../../reference/en/02-schemas.md)). On a divergence, integration is blocked (QG-0 fails).

**Prevention:** The schema is the single source of truth (closed list); it is not edited within the project. Schema changes happen only through a change to the full RENAR Standard.

**Recovery:** Roll the frontmatter back to a schema-valid state; if the change is genuinely needed, open an RFC for a standard change.

### 2.2 Lifecycle drift

**Symptom:** Statuses (`proposed` / `approved` / `verified` / `obsolete`) and quality-gate names are understood differently across subsystems or across teams.

**Detection:** Compare the status transitions in the audit trail against the normative state machine ([standard/10-lifecycle-qg](../../standard/en/10-lifecycle-qg.md)). Anomalies (a transition without the corresponding pre-conditions) are flagged.

**Prevention:** Transitions are performed by the substrate mechanism, not by manual frontmatter edits. Capability V3 (state-machine enforcement).

**Recovery:** Roll back the illegitimate transition; re-run QG-0 / QG-2 through the correct mechanism.

### 2.3 Source-of-truth drift

**Symptom:** The same entity is edited in two places (for example, both in the `.req` directory and in the Jira tracker). The versions diverge.

**Detection:** Periodic reconciliation between the substrate and the tracker; the diff reveals the divergences.

**Prevention:** At any moment in time, **exactly one SSoT substrate is chosen** for the project. The tracker is a derived view, not the Source of Truth. The substrate hook blocks tracker-only changes to requirements.

**Recovery:** Declare one substrate the winner; merge the second into the first; stop editing in the second until migration.

### 2.4 Implementation drift

**Symptom:** Code in the implementation references an SR that no longer exists (deprecated, removed, renamed). Or: the SR exists, but the implementation has drifted away from it (the behavior does not conform).

**Detection:** Reconciliation hook (drift detection):
- Forward: walk from a requirement → find the implementing code → run the TC.
- Backward: walk from the code → find references to SR / TC → check that they exist and are `verified`.

**Prevention:** Requirement IDs are **immutable** — renaming is forbidden. Deprecated requirements stay in the repository with status `obsolete`; they are not deleted.

**Recovery:** Open a delta-TZ that explicitly adopts the current implementation (or, conversely, requires the code be rolled back into conformance with the requirement).

### 2.5 Terminological drift

**Symptom:** "Verified", "implemented", "approved" mean different things to different people / teams.

**Detection:** Code-review checklist: "a term not from the glossary was used?" — a flag. Likewise, the substrate validator checks that the values of enum frontmatter fields come only from the closed list.

**Prevention:** The glossary is the single source of terms ([reference/01-glossary](../../reference/en/01-glossary.md)). Each term = exactly one lifecycle state.

**Recovery:** Audit all project artifacts for the use of out-of-glossary terms; replace them or file an RFC to extend the glossary.

### 2.6 Order / provenance drift

**Symptom:** Delta-TZ #2 references an SR that was created in Delta-TZ #1, but application happened in reverse order — the SR did not exist at the moment #2 was applied.

**Detection:** Delta-TZs are numbered and applied strictly in number order. The substrate hook checks that the upstream delta has already been applied.

**Prevention:** Delta-TZs cannot be renumbered. Each artifact stores `created-by-order` (the delta-TZ of creation) and `last-modified-by-order` (the last update).

**Recovery:** Roll back the out-of-order application; re-apply in the correct order.

### 2.7 TC ↔ requirement provenance drift

**Symptom:** A TC verifies a requirement, but the requirement has already changed — `last-run.requirement-version` is lower than the requirement's current `version`. The test is green, but it checks outdated behavior.

**Detection:** The coverage report shows a "Stale" category — TCs with an outdated `last-run.requirement-version`. Reconciliation catches this automatically (via the V5 version pin).

**Prevention:** A TC has the mandatory field `verifies[].requirement-version` — a pinned version. QG-2 forbids moving a requirement to `verified` if at least one TC in `verified-by` has a stale `last-run`.

**Recovery:** Re-run the stale TC against the current requirement version; update it if the TC itself is outdated.

### 2.8 Test-fitting drift

**Symptom:** An AI agent has a trivial path to turning a failing test green — weaken the pass/fail criterion instead of fixing the code. Without protection, tests drift from "strict checker" to "green void".

**Detection:** A change to a TC's pass/fail criteria without an explicit `[test-spec-change]` tag is flagged by the substrate. A periodic spot-check of 5 random passing TCs once per sprint.

**Prevention:**
- An MR / change that modifies pass/fail criteria MUST carry the `[test-spec-change]` tag and a separate Engineer approval (not combined with the approval of the code fix).
- Isolation of the judge model: the production model ≠ the judge model.
- A trending test-fitting drift-rate metric.

**Recovery:** Restore the old criteria; perform a root-cause analysis — why the AI agent chose greening over a fix; update the prompt / system instructions.

---

## 3. The 14 AI risks (brief summary)

Full descriptions, mitigations, and owners — in [reference/03-ai-risk-register](../../reference/en/03-ai-risk-register.md). Here is an operational summary: id, name, severity, the main detection signal.

| ID | Name | Severity | Detection signal |
|---|---|---|---|
| AIR-01 | Hallucination in AI-generated requirements | High | Hallucination Rate metric > threshold; adversarial critic flags |
| AIR-02 | Prompt injection via a client TZ | High | Suspicious pattern in imports; sandbox violation |
| AIR-03 | Model drift / version change | Medium | diff regression on a model switch; baseline eval failure |
| AIR-04 | Bias in AI requirement generation | Medium | Stakeholder map gaps; missing accessibility/locale considerations |
| AIR-05 | Single-model failure (no diversity) | Medium | All artifacts with one `ai-provenance.model`; no multi-model agreement |
| AIR-06 | Test-fitting / greening tests | High | diff in TC pass/fail without a `[test-spec-change]` tag |
| AIR-07 | Hallucinated citations | Medium-High | Citation validator hook fails |
| AIR-08 | Adversarial inputs in client data | High | Application-level (out-of-scope for RENAR, tracked in SPEC-SEC) |
| AIR-09 | Privacy leakage via AI logs | High | PII in the tool_event audit; redaction skip |
| AIR-10 | Knowledge graph poisoning | Medium | Incorrect edges; circular dependencies in the graph |
| AIR-11 | Reconciliation false-positive overload | Low-Medium | Findings/week trending up without real issues; high dismissal rate |
| AIR-12 | Cost runaway (uncontrolled AI spend) | Medium | Project AI cost approaching the budget cap |
| AIR-13 | A Stakeholder does not understand AI-generated requirements | Medium | Dispute rate at acceptance rising; long approval cycles |
| AIR-14 | Vendor lock-in to a specific LLM provider | Medium | All prompts work only on one provider |

The risk matrix and review cadence — [reference/03 §5-§2](../../reference/en/03-ai-risk-register.md).

### 3.5 Adversarial review (procedure)

> **Informative.** An operational procedure for WC-13; normative requirements — [standard/09 §9.4](../../standard/en/09-test-cases.md#9.4), [standard/13 §13.2](../../standard/en/13-conformance.md#13.2) (RENAR-5).

**When mandatory (normative):** adversarial review is QG-0 for RENAR-5 ([§11.8.1](../../standard/en/11-maturity-model.md#11.8.1)); for `SPEC-SEC` / `SPEC-AI` — an external reviewer at QG-0 ([§5](../../standard/en/05-roles.md)); declared-stricter MAY broaden the scope ([standard/00 §0.6](../../standard/en/00-introduction.md#0.6)).

| Step | Actor | Artifact | Exit criterion |
|---|---|---|---|
| 1. Scope | Architect | A list of TCs + the related SR/SPEC | Each `approved` TC in scope has a `tc-type` and `verified-by[]` |
| 2. Critic pass | AI critic (a separate model/prompt) | A findings log with id, severity, and a reference to the TC/SR | Findings are traceable to a concrete clause §9.x; no "generic" recommendations |
| 3. Triage | Architect + RE Engineer | Disposition: fix / accept / reject | Each finding has an owner + rationale; dismissal without rationale is forbidden (see §5.6) |
| 4. Re-run | AI agent or human | Updated TCs + diff | QG-2 pre-condition: `passing-tests / total-tests` for the scope ([§9.10](../../standard/en/09-test-cases.md#9.10)) |
| 5. Audit trail | substrate (V1) | A commit/change unit with the `adversarial-review` tag | provenance: model id, prompt version, findings hash ([§10.13](../../standard/en/10-lifecycle-qg.md#10.13)) |

**Approval discipline:** the "100%" metrics in §9 are a **target at QG-2**, not a guarantee of product quality. AI-risk severity comes from [reference/03](../../reference/en/03-ai-risk-register.md), not from an editorial override.

**Agent panel (no human reviewers):** an informative procedure — [§4.5](#35-adversarial-review-procedure) (steps 1–5); the rubric and severity — [reference/03](../../reference/en/03-ai-risk-register.md).

---

## 4. Organizational failure patterns

These problems are not caught by substrate mechanisms — they are behavioral patterns of teams. They typically appear 2–6 months after adopting RENAR.

### 4.1 ADAPT as a formality

**Symptom:** The client / Stakeholder does not read the ADAPT before signing. The backward section (questions for the client) is empty or contains yes/no answers without context.

**Sign:** An ADAPT approved < 24 hours after generation; the rate of disputed requirements at acceptance is rising.

**Mitigation:** Dual signature on the ADAPT ([standard/05-roles §5.5](../../standard/en/05-roles.md)) — both the Stakeholder and the Architect are required. The backward section MUST contain ≥ 1 non-rhetorical question. Spot-check ADAPTs in I&A.

### 4.2 SPEC overload

**Symptom:** The team creates a SPEC for every task, even when SR + TR are sufficient. The SPEC catalog balloons; every PR updates 5+ SPECs.

**Sign:** The SPEC / SR ratio > 1.5 (the expected value is < 0.3 for projects of medium complexity).

**Mitigation:** A pre-review checklist: "is a SPEC needed for this change?" A SPEC is justified only when several SRs share a common constraint. See [standard/08-specifications.md](../../standard/en/08-specifications.md) §8.2 — when a SPEC is mandatory.

### 4.3 Hooks as an obstacle

**Symptom:** The team routinely bypasses the substrate hooks (`--no-verify`, timestamp manipulation, manual status edits).

**Sign:** The git log / substrate audit trail shows a frequency of bypass commits; QG-0/QG-2 pass in suspiciously short times.

**Mitigation:** The root cause is hooks that are too slow / too noisy / too strict. Do not "ban the bypass" — fix the hooks. Treat the bypass frequency as a trending metric — if it rises, run a retro with the team.

### 4.4 Drift detection without action

**Symptom:** The reconciliation hook generates drift findings, but no one acts on them. The findings backlog grows; old findings are ignored.

**Sign:** Findings older than 14 days > 30; resolution rate < 20% / week.

**Mitigation:** Each drift finding gets an owner and an SLA (resolve / accept / reject within N days). Unresolved findings past the SLA are escalated. Reconciliation without human ownership = noise.

### 4.5 Tracker as a parallel universe

**Symptom:** The team lives in Jira / Linear / ADO; the `.req` directory is updated once a week "for the record". The tracker is the real Source of Truth, RENAR is a formal artifact for the audit.

**Sign:** The diff of `.req` vs the tracker > 30% in any given week; commits to `.req` are rare and batched.

**Mitigation:** The Source of Truth must reside in the substrate, not be tracker-resident. The tracker is a derived view only. If the team cannot work without the tracker — the substrate must push *into* the tracker, not the other way around.

### 4.6 Critic burnout

**Symptom:** The AI critic (adversarial review) generates many findings; gradually the developer / Architect start ignoring its output. Findings are rejected without consideration.

**Sign:** The AI critic's dismissal rate > 80%; time-to-dismiss < 30 seconds per finding.

**Mitigation:** Tunable thresholds for the critic. If the false-positive ratio is high — recalibrate the prompt / model. The "critic finding → real issue" metric (the % of dismissed findings that later surfaced as a defect) — if it is 0%, the critic is useless.

### 4.7 Single-engineer dependence

**Symptom:** Only one Engineer on the project "understands RENAR". All QG-0 / QG-2 pass through them. If they go on vacation — the process stalls.

**Sign:** The bus factor of RENAR ownership = 1. The distribution of QG approvals is heavily skewed toward one person.

**Mitigation:** Paired onboarding (at least 2 Engineers on the project know RENAR). Rotation of the QG-approver role. Documentation of project conventions in `<project>.req/CONVENTIONS.md`.

### 4.8 Ad-hoc delta

**Symptom:** Requirement changes happen without a delta-TZ being filed — "let's just change SR-12 right in the repository".

**Sign:** Direct commits to `<system>.req/sr/*` without a corresponding delta-TZ; the `created-by-order` field is empty.

**Mitigation:** The substrate hook blocks mutation of existing requirements without a `delta-ref` in the commit metadata. All changes go through the delta-TZ workflow ([standard/07-adapt §7.6](../../standard/en/07-adapt.md)).

### 4.9 TC abandonment

**Symptom:** TCs are created alongside the requirements, but then they are never run. `last-run` is older than N months; the coverage report shows "green" TCs that in reality have not run in half a year.

**Sign:** Median `last-run` age > 90 days; the TC count grows, the run count does not.

**Mitigation:** The substrate runs TCs automatically on a schedule (capability V4). A TC without a `last-run` for N days is automatically marked `stale`; QG-2 blocks until they are re-run.

---

## 5. Failure recovery playbook

What to do once the system is already broken. The sequence is common to all failure modes; the specifics depend on the class.

### Step 1: Stop the bleeding

Find and halt the ongoing damage:
- Drift: freeze further changes in the affected area.
- AI risk: suspend AI generation for the affected class of artifacts.
- Organizational: take it to a retro / I&A — this is not a technical fix.

### Step 2: Quantify

Measure the damage:
- How many artifacts are in a drift state?
- How many releases since the problem arose?
- Which SR / SPEC / TC are affected? (Capability V4 — coverage / drift report)

### Step 3: Triage

Segment the damage into:
- **Critical** — already in production, affecting users. Hot-fix.
- **Active** — in the current PI, affecting ongoing work. Block PI exit.
- **Historical** — old artifacts, not actively used. Batch fix.

### Step 4: Fix

For each class, the corresponding fix:
- Schema drift → roll back the frontmatter; RFC if the schema needs to be extended.
- Implementation drift → delta-TZ adopt OR roll back the code.
- TC drift → re-run the TC against the current requirement-version.
- Test-fitting → revert the criteria; root-cause the AI agent.
- Organizational → process retro + the specific mitigations (§5).

### Step 5: Prevent recurrence

- Strengthen detection (a lower threshold, a new metric).
- Add a mitigation to the processed artifact.
- Record lessons learned in the project decision log or in the ADAPT backward findings (category `scope` / `terminology`).

### Step 6: Verify

After the fix — re-run QG-2 on the affected artifacts. Drift detection should show a clean state.

---

## 6. Negative: what this chapter does not cover

- **Security incidents** — breach response, forensics, regulatory notification. This is an organization-level security process, not RENAR scope.
- **AI red team / penetration testing** — a separate security workflow; RENAR only tracks that the corresponding SR / SPEC-SEC should exist.
- **Compliance breach response** — a violation of GDPR / FZ-152 / PCI-DSS requires a legal process with the DPO / regulator, not a technical recovery.
- **Production incidents** — outages, performance regressions. These are operational; see the SPEC-OPS runbook.
- **Stakeholder conflicts** — disputes at acceptance, scope disagreements. RENAR provides the audit trail (who approved what, when), but resolution is a human process.

---

## 7. Relationship to other materials on failure modes

| Document | What is in it | When to read |
|---|---|---|
| [reference/03-ai-risk-register](../../reference/en/03-ai-risk-register.md) | The full register of 14 AIR risks with mitigations | When planning an AI use case; when reviewing the eval strategy |
| [standard/04-terms §4.11](../../standard/en/04-terms.md#4.11) | The closed list of drift classes with normative definitions | When disputing the terminology of failure modes |
| [05-safe-comparison §9](05-safe-comparison.md) | The RACI matrix — who is accountable for each activity | When investigating an organizational failure |
| [reference/04-ai-style-guide](../../reference/en/04-ai-style-guide.md) | The style of AI provenance; the minimal contract for AI-generated artifacts | When diagnosing AIR-01 (hallucination), AIR-07 (citations) |

---

## 8. Resolved decisions for v1.0

- **A set of recovery steps with no platform binding.** The sequence in §2 is universal in nature. The details of "how exactly to freeze changes" for `git` and a document store are in [03-tool-guide-git §3](03-tool-guide-git.md) and [04-document-store-substrate](04-document-store-substrate.md). The scope of the normative minimum is set right here, in chapter 7.
- **Tuning the critic event-driven.** Re-tuning the critic's prompt is performed when the drift / hallucination metrics breach their threshold ([§12.3.3](../../standard/en/12-metrics.md#12.3)); the RENAR-5 level requires continuous evaluation ([§11.8.1](../../standard/en/11-maturity-model.md#11.8.1)), so a regular "general review for no reason" is redundant. On a metric trigger — it is permitted.

### 8.1 Deferred to v1.1 (phase-8 backlog)

- **Numeric thresholds for the organizational patterns (§5).** Today only qualitative "signs" are given. A set of acceptable values will be needed once field data has accumulated. Owners: the RENAR standard team and the adopting organizations.
- **A formal measurement of the "bus factor" for §5.7.** The supporting tooling is not fixed; a possible approach is a graph query over commit authors across the revision chain (a built-in **V6** combination at the substrate). Owners: the authors of tooling for specific storage environments.

---
