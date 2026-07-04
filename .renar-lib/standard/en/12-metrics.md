---
title: "Metrics"
order: 12
lang: en
---
# 12. Metrics

> **Part of the RENAR Standard v1.0-draft** · [← Table of contents](README.md)

## 12.1 What to measure in requirements

The general SENAR metrics (§9) will show that the team is fast and the tests are green. But they will not notice an AI agent quietly inserting into an SR a clause that was in neither the TZ nor the ADAPT — until it surfaces at acceptance as a dispute with the client. "The process as a whole" is healthy, yet the requirements work is not. So RENAR adds **ten metrics that look specifically at requirements**: how often an AI agent invents a clause without a source (Hallucination Rate), whether paired tests catch real defects, how quickly a delta-TZ reaches the code. This is an overlay on SENAR §9, not a replacement.

The list of metrics is closed; for each one, a formula, a target per maturity level ([chapter 11](11-maturity-model.md)), and a data source are specified. Metrics are collected natively for the substrate through V1–V6 ([chapter 3](03-substrate-versioning.md)); exactly how to render dashboards is an implementation question deferred to `guide/`. This chapter does not duplicate SENAR §9 but specializes it, and it does not touch ROI or pricing — those are not process indicators but business effects (§12.5).

---

## 12.2 Relationship to SENAR §9

SENAR §9 defines ten general-process metrics: Throughput, Lead Time, FPSR (First-Pass Success Rate), DER (Defect Escape Rate), KCR (Knowledge Capture Rate), Cost Predictability, Cost-per-task, MIR (Memory Integrity Rate), Cycle Time, ADR (Adversarial Detection Rate).

RENAR §12 does **not** edit and does **not** replace these metrics. The REQ-specific metrics of §12.3:

- **Refine** a SENAR metric for the requirements phase (for example, RDLT refines SENAR Lead Time for the requirements phase).
- **Add** observations specific to requirements engineering and not covered by SENAR §9 (Hallucination Rate, Multi-model Disagreement Rate).

The full mapping — §12.7.

The closed list of REQ metrics (§12.3) is maintained within RENAR; SENAR §9 is a separate closed list of general metrics. Changing either of the two lists is a formally independent change procedure of the respective standard.

---

## 12.3 Closed list of REQ-specific metrics

A closed list of ten REQ metrics. The list is changed only through the formal change procedure of the standard ([§13.9.3](13-conformance.md#13.9.3)); the general closed-list policy and master index — [§1.7.5](01-scope.md#1.7.5).

### 12.3.1 RDLT — Requirement Decomposition Lead Time

The time from registering a TZ in the substrate to the state "all BR/SR (the parent chain from this TZ) → `approved`, ready for QG-0 ([§10.3.1](10-lifecycle-qg.md#10.3.1))". **Formula:** `RDLT = timestamp(last BR/SR → approved) − timestamp(TZ registered)`. Measured in hours/days. **Source:** the audit log of promote-transitions ([§10.13](10-lifecycle-qg.md#10.13)). **Relationship to SENAR:** a refinement of SENAR `Lead Time` for the requirements phase. **Targets:** RENAR-3 < 1 week per 50-page TZ; RENAR-4 < 2 days; RENAR-5 < 4 hours.

### 12.3.2 Requirement-to-Task Latency

The time from the promote-transition SR → `approved` to the creation of the first TR with the reference `implements: SR-N`. **Formula:** `Latency = timestamp(first TR.created) − timestamp(SR → approved)`. Hours. **Source:** the substrate audit log + the cross-substrate references of the implementation substrate. **Relationship to SENAR:** a refinement of SENAR `Cycle Time` for the "requirement → executable task" pair. **Targets:** RENAR-3 < 3 days; RENAR-4 < 1 day; RENAR-5 < 1 hour (auto-create TR after approval).

### 12.3.3 Hallucination Rate

The percentage of normative assertions in an AI-generated artifact (BR/SR/SPEC) that are not traceable to a source (TZ/ADAPT/another normative artifact). Source citation is checked by a native citation parser ([§13.3.1](13-conformance.md#13.3.1), REQUIRED at RENAR-4). **Formula:** `assertions_without_valid_citation / total_normative_assertions × 100%`. Per artifact; aggregated per project. **Source:** the citation parser (AST or regex over inline references `[TZ-XXX §Y]` / `[ADAPT-NNN §Z]`). **Relationship to SENAR:** a new metric; corresponds to ISO/IEC 5338 traceability for AI-generated artifacts. **Targets:** RENAR-1..3 n/a; RENAR-4 ≤ 5%; RENAR-5 ≤ 1%.

**Negative scenario (loss-of-conformance trigger):** a Hallucination Rate > 5% on a RENAR-4 project is a normative loss-of-conformance trigger ([§13.8.1](13-conformance.md#13.8.1)); remedy it through a release recovery plan or downgrade to RENAR-3.

### 12.3.4 Multi-model Disagreement Rate

The percentage of artifacts with `priority: must` where two (or more) generating AI models produced normative assertions diverging beyond a threshold (by default, embedding similarity < 85%; the threshold is fixed in the manifest under `declared-stricter`). **Formula:** `BRs_with_high_disagreement / total_must_BRs × 100%`. **Source:** the multi-model runs log; embedding similarity computed offline over "model A vs B" pairs. **Relationship to SENAR:** a new metric. **Targets:** RENAR-1..4 n/a; RENAR-5 tracked, with per-project baseline values in the first quarter. **Interpretation:** a high value is an indicator of weak prompt engineering or a complex problem domain; it warrants attention but is not in itself a negative indicator.

### 12.3.5 DRA — Dispute Rate at Acceptance

The percentage of BR/SR for which, at the QG-4 stage ([§10.4.2](10-lifecycle-qg.md#10.4.2)), the client declared disagreement with the interpretation or coverage. **Formula:** `disputed_BRs_at_QG4 / total_BRs_in_release × 100%`. **Source:** the QG-4 audit log — a `gate-id: QG-4` event with `result: disputed`. **Relationship to SENAR:** a refinement of `DER (Defect Escape Rate)` for requirements. **Applicability:** only when QG-4 is in the manifest; when QG-4 = `absent` ([§13.3.6](13-conformance.md#13.3.6)) — not measured. **Targets:** RENAR-3 ≤ 10%; RENAR-4 ≤ 5%; RENAR-5 ≤ 2%.

### 12.3.6 ACR — Adversarial Catch Rate

The percentage of artifacts (BR/SR/SPEC) where the AI critic (a different model; REQUIRED at RENAR-5 per [§11.8.1](11-maturity-model.md#11.8.1)) found ≥ 1 high-severity issue before QG-0. **Formula:** `artifacts_with_critic_high_findings / total_reviewed_by_critic × 100%`. **Source:** the critic-runs audit log; severity (`high`/`medium`/`low`) in the critic output. **Relationship to SENAR:** a subclass of `ADR (Adversarial Detection Rate)` for requirements. **Targets:** RENAR-1..3 n/a; RENAR-4 optional (if `declared-stricter` — a baseline level of 20–30%; values < 20% are an indicator of a weak critic or of duplicating the primary); RENAR-5 tracked normatively, a rising ACR warrants attention to prompt quality.

### 12.3.7 Test-spec Drift Rate

The percentage of TC in status `passing` ([§10.9.1](10-lifecycle-qg.md#10.9.1)) whose `last-run.requirement-version` ([§9.12](09-test-cases.md#9.12)) differs from the current `version` of the verified artifact (`verifies[]`). **Formula:** `stale_passing_TCs / total_passing_TCs × 100%` (stale = `last-run.requirement-version` < current). **Source:** the COVERAGE artifact ([§9.15](09-test-cases.md#9.15)). **Relationship to SENAR:** a new metric. **Targets:** RENAR-1..3 n/a; RENAR-4 ≤ 5%; RENAR-5 ≤ 1% (auto-rerun on delta-ADAPT).

### 12.3.8 Coverage Velocity

The rate of `approved` → `verified` transition ([§10.5](10-lifecycle-qg.md#10.5)) per unit of time (default iteration; the substrate MAY define a different interval in the manifest). **Formula:** `(verified_count(end) − verified_count(start)) / approved_count(start) × 100%`. **Source:** the COVERAGE artifact history ([§9.15](09-test-cases.md#9.15)). **Relationship to SENAR:** a refinement of `Throughput` for requirements. **Targets:** RENAR-3 ≥ 30%/iteration; RENAR-4 ≥ 50%/iteration; RENAR-5 ≥ 70%/iteration.

### 12.3.9 Cost per Approved Requirement

The AI-generation cost (input tokens + output tokens × tariff) normalized to one artifact in status `approved`, including rejected versions (which remain in the substrate by virtue of V1 immutable history). **Formula:** `total_AI_tokens_cost(period) / count(artifacts_approved_in_period)`. Project currency. **Source:** the `ai-provenance.cost-budget` + `ai-provenance.cost-actual` frontmatter fields ([§11.7.1](11-maturity-model.md#11.7.1)). **Relationship to SENAR:** a refinement of `Cost-per-task` for requirements. **Targets:** RENAR-1..3 n/a; RENAR-4 tracked, with per-project baseline values; RENAR-5 tracked + year-over-year reduction or a justification.

### 12.3.10 Reconciliation Findings per Week

The number of issues detected by the reconciliation agent ([§2.4.2](02-methodology-positioning.md#2.4.2) continuous reconciliation) per week and registered as backward findings in a delta-ADAPT or a direct change-set requirement. **Formula:** `count(reconciliation_findings_registered) / weeks_in_period`. **Source:** the reconciliation-runs audit log + the ADAPT backward findings list ([§7.4.5](07-adapt.md#7.4.5)). **Relationship to SENAR:** a new metric. **Targets:** RENAR-1..3 n/a; RENAR-4 tracked > 0 (zero = the reconciliation hook is not working or V5 is lost); RENAR-5 trending **down** over the long term (a mature process does not generate new drift).

---

## 12.4 Summary table of targets by level

The closed list of 10 metrics from §12.3 — target values for the applicable levels.

| Metric | RENAR-3 | RENAR-4 | RENAR-5 | Data source |
|---|---|---|---|---|
| RDLT (Decomposition Lead Time) | < 1 week | < 2 days | < 4 hours | promote-transitions audit log |
| Requirement-to-Task Latency | < 3 days | < 1 day | < 1 hour | audit log + cross-substrate refs |
| Hallucination Rate | n/a | ≤ 5% | ≤ 1% | citation parser |
| Multi-model Disagreement Rate | n/a | n/a | tracked | multi-model runs log |
| DRA (Dispute Rate at Acceptance) | ≤ 10% | ≤ 5% | ≤ 2% | QG-4 audit log (if QG-4 declared) |
| ACR (Adversarial Catch Rate) | n/a | optional (if critic declared-stricter) | tracked normatively | critic-runs audit log |
| Test-spec Drift Rate | n/a | ≤ 5% | ≤ 1% | COVERAGE artifact |
| Coverage Velocity | ≥ 30%/iteration | ≥ 50%/iteration | ≥ 70%/iteration | COVERAGE history |
| Cost per Approved Requirement | n/a | tracked | tracked + optimized | ai-provenance fields |
| Reconciliation Findings/Week | n/a | tracked (> 0) | trending down | reconciliation audit log |

The concrete substrate-native presentation of these metrics in dashboards is substrate-specific and deferred to `guide/`.

> The target values for RENAR-4 / RENAR-5 are **provisional**: set as normative direction markers, but subject to calibration against field data in version v1.1 (see [guide/07 §8.1](../../guide/en/07-failure-modes.md)). These are guiding thresholds, not statistically validated values.

---

## 12.5 Business outcomes

Six normative effects of adopting RENAR, expected at the RENAR-3 level and above. The outcomes are **normative expectations of the standard**, not process indicators; measuring them is substrate-specific and not mandatory (although the §12.3 metrics capture them indirectly).

> ROI / cost-of-adoption is a **non-normative** topic and is not part of a normative chapter. A lightweight **illustrative** (not guaranteed) model of the cost and benefit of adoption for a decision-maker — in [guide/02-transition-guide](../../guide/en/02-transition-guide.md).

### 12.5.1 Outcome 1 — Reduced TZ decomposition time

Measured through §12.3.1 RDLT. Expected reduction from the baseline: on the order of 5–10× at RENAR-4, 20–50× at RENAR-5.

### 12.5.2 Outcome 2 — Lower dispute frequency at acceptance

Measured through §12.3.5 DRA. Expected reduction: from 15–30% to ≤ 5% at RENAR-4, ≤ 2% at RENAR-5.

### 12.5.3 Outcome 3 — Audit readiness

The event audit log ([§10.13](10-lifecycle-qg.md#10.13)) + AI provenance in frontmatter ([§11.7.1](11-maturity-model.md#11.7.1)) provide a compliance audit without separate preparatory work. Applicable to regulated industries (medicine, fintech, the public sector).

### 12.5.4 Outcome 4 — Lower cost of working with a delta-TZ

Impact analysis ([§9.16](09-test-cases.md#9.16)) + reverse evolution of verification ([§10.5.4](10-lifecycle-qg.md#10.5.4)) automate the handling of a delta-TZ. Expected reduction in human involvement: from tens of hours to an hour per delta.

### 12.5.5 Outcome 5 — Lower knowledge loss on team turnover

V6 author + timestamp ([§3.3.6](03-substrate-versioning.md#3.3.6)) records the author of all artifacts; the Source-of-Truth inversion ([§2.3.1](02-methodology-positioning.md#2.3.1)) moves knowledge out of people's heads into the substrate. Expected reduction in onboarding: from weeks to days.

### 12.5.6 Outcome 6 — The standard as a sellable product

At RENAR-4/5 a substrate-native implementation MAY be licensed to partners as an actionable product. A structural consequence of a formal standard, not a process metric.

---

## 12.6 Substrate-independent metric collection

### 12.6.1 Normative requirements

A substrate implementing RENAR at the RENAR-4+ level MUST provide **automatic collection** of the §12.3 metrics through:

| Source | Capabilities | Accessible |
|---|---|---|
| Event audit log ([§10.13](10-lifecycle-qg.md#10.13)) | V1 + V6 | gate-passage events with timestamps, artifact-version, actor |
| COVERAGE artifact ([§9.15](09-test-cases.md#9.15)) | V5 + V1 | counts approved/verified/total; pos/neg coverage; stale-rate |
| AI-provenance frontmatter fields | V6 | cost-budget, cost-actual, generated-by, generated-at |
| Reconciliation audit log | V1 + V6 | reconciliation runs + findings list ID |
| Critic-runs audit log (RENAR-5) | V1 + V6 | critic runs + severity classifications |

A substrate without access to any of the sources above **cannot** implement RENAR-4/5 ([§11.7.1](11-maturity-model.md#11.7.1), [§11.8.1](11-maturity-model.md#11.8.1)).

### 12.6.2 Substrate-native monitoring panels (dashboards)

The format (UI/CLI/report-generation) is substrate-specific; the standard does not regulate visualization. The substrate MUST export metrics in a machine-readable format for external audit (§13.6 third-party assessment). Dashboard templates — `guide/`.

### 12.6.3 Period aggregation

Per artifact — Hallucination Rate, Cost per Approved Requirement; per period (sprint/week/month) — Coverage Velocity, Reconciliation Findings/Week, ACR; per release — DRA; continuous trending — Multi-model Disagreement Rate, Test-spec Drift Rate. Period boundaries are fixed in the manifest ([§13.4.2](13-conformance.md#13.4.2)) under `declared-stricter` or are taken by default.

---

## 12.7 Mapping to SENAR metrics

The full mapping of the ten SENAR §9 metrics to the REQ refinements from §12.3.

| SENAR metric (§9) | REQ refinement from §12.3 |
|---|---|
| Throughput | + Coverage Velocity (§12.3.8) — at the requirements level |
| Lead Time | + RDLT (§12.3.1) — for the requirements phase |
| FPSR (First-Pass Success Rate) | + REQ-FPSR (share of artifacts passing QG-0 without rework) — derived, not a separate §12.3 metric |
| DER (Defect Escape Rate) | + DRA (§12.3.5) — defects at acceptance |
| KCR (Knowledge Capture Rate) | (used as-is; indirectly reinforced through the §12.5.5 outcome) |
| Cost Predictability | + variance of Cost per Approved Requirement (§12.3.9) |
| Cost-per-task | + Cost per Approved Requirement (§12.3.9) — for the requirements phase |
| MIR (Memory Integrity Rate) | (used as-is; reinforced through V1 + V6 at RENAR-4+) |
| Cycle Time | + RDLT (§12.3.1) + Requirement-to-Task Latency (§12.3.2) — both within SENAR Cycle Time |
| ADR (Adversarial Detection Rate) | + ACR (§12.3.6) — adversarial for the requirements zone |

Metrics with **no** SENAR counterpart (new in RENAR):

- Hallucination Rate (§12.3.3) — specific to AI-generated artifacts.
- Multi-model Disagreement Rate (§12.3.4) — specific to multi-model generation.
- Test-spec Drift Rate (§12.3.7) — specific to V5 requirement-version pinning.
- Reconciliation Findings per Week (§12.3.10) — specific to continuous reconciliation.

---

## 12.8 Relationship to other chapters

| Chapter | Relationship |
|---|---|
| [02 Positioning in the typology of methodologies](02-methodology-positioning.md) | [§2.3](02-methodology-positioning.md#2.3) Source-of-Truth inversion + [§2.4.2](02-methodology-positioning.md#2.4.2) continuous reconciliation — the foundation for §12.3.10 Reconciliation Findings |
| [07 ADAPT](07-adapt.md) | [§7.4.5](07-adapt.md#7.4.5) backward findings — input for §12.3.10; delta-ADAPT — measured through §12.3.5 DRA |
| [08 Specifications](08-specifications.md) | [§8.5.7](08-specifications.md#8.5.7) SPEC-AI continuous evaluation — related to §12.3.4 Multi-model Disagreement Rate |
| [09 Test cases](09-test-cases.md) | [§9.12](09-test-cases.md#9.12) last-run — input for §12.3.7 Drift Rate; [§9.15](09-test-cases.md#9.15) COVERAGE — the source for §12.3.8 Velocity and §12.3.7 |
| [10 Lifecycle and QG](10-lifecycle-qg.md) | [§10.13](10-lifecycle-qg.md#10.13) event audit log — the basis for all §12.3 metrics; [§10.4.2](10-lifecycle-qg.md#10.4.2) QG-4 — the gate at which §12.3.5 DRA is captured |
| [03 Substrate versioning](03-substrate-versioning.md) | V1 + V5 + V6 — capabilities mandatory for substrate-native collection of the §12.3 metrics (§12.6.1) |
| [11 Maturity model](11-maturity-model.md) | §12.3 targets per RENAR-3/4/5 level — a concretization of the level criteria from [§11.4](11-maturity-model.md#11.4)–[§11.8](11-maturity-model.md#11.8) |
| [13 Conformance](13-conformance.md) | §12.3 metrics — input for the [§13.5](13-conformance.md#13.5) self-assessment; exceeding thresholds (for example, Hallucination Rate > 5% at RENAR-4) — a loss-of-conformance trigger [§13.8.1](13-conformance.md#13.8.1) |
