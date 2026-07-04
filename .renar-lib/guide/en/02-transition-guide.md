---
title: "Transitioning to RENAR"
description: "Phased migration of a team from a manual TZ→code workflow to RENAR. From RENAR-1 to RENAR-5, no big-bang."
order: 2
lang: en
version: "1.0-draft"
---

# 02. Transitioning to RENAR

> Teams rarely start from a blank page. This chapter is about how to move an existing project from the manual "TZ → code" loop to RENAR gradually, step by step, without halting development. Each level delivers tangible value; a team chooses which `RENAR-N` to reach based on real value, not on a race for "full conformance" to claims on paper.
>
> **Prerequisites:** [RENAR Core](../../core/en/renar-core.md), [standard/11-maturity-model](../../standard/en/11-maturity-model.md) (closed list of levels RENAR-1..RENAR-5), [guide/07-failure-modes](07-failure-modes.md). Already on early RENAR with legacy types (`INT-TC`, `AIC`, …) — see [10-migration-v1](10-migration-v1.md).

---

## 1. Assessment: where the team is now

Before migrating, assess the current state. A "pre-RENAR" checklist:

| Signal | Pre-RENAR | RENAR-1 minimum |
|---|---|---|
| The TZ exists as an artifact | In chat / Google Doc / Notion | Fixed in the substrate as a file |
| Someone maintains the requirements | Only in a tracker (Jira / Linear) | In the substrate as BR / SR / ADAPT |
| Where a requirement came from | From memory / we re-ask | Anyone can find the source in the substrate |
| Requirement changes | Verbally at standup | Through an explicit change-set (delta-TZ) |
| Tests | In code, no link to requirements | TC as artifacts, or at least in code with an SR-ID mention |

If 3+ rows fall in the "Pre-RENAR" column, the team is **below RENAR-1**. This is a normal starting point for most projects.

### 1.1 Readiness signals

A team is ready to migrate if:

- It hurts that requirements get lost between chats / tickets / documents.
- Disputed acceptances happen regularly — "this isn't what we asked for".
- Onboarding a new engineer takes months to reconstruct context.
- AI is used to generate requirements / code, but there is no systematic verification.

If none of this hurts, RENAR may be premature optimization. See §8 "when it is not needed".

---

## 2. Stage 1 — entering RENAR-1 (Ad-hoc)

**Level goal:** requirements live in the substrate, not in chat; every TZ has an ADAPT.

**Typical duration:** 1-2 weeks.

### 2.1 What gets added

1. An artifact **substrate** is chosen and set up: a `<project>.req/` directory in the repository, a document-store workspace, or another substrate — RENAR is not tied to a specific implementation; see capabilities **V1–V6** ([glossary §2.7](../../reference/en/01-glossary.md#27-substrate-capabilities-v1-v6)).
2. The existing TZ is moved into this environment as an artifact not subject to arbitrary edits (with date and signatures).
3. For each TZ an `ADAPT` is created — a bridge artifact: a Forward section ("how we understood it") and a backward section (questions for the client).
4. New requirements are recorded as BR / SR files in the substrate, not only in the tracker.

### 2.2 What is NOT required at this stage

- Standardized frontmatter (at minimum — `id` + `title`).
- Lifecycle statuses (`draft`/`approved`/...) — artifacts MAY live without explicit transitions.
- TC as separate artifacts.
- Substrate hooks.
- Substrate-native COVERAGE.

### 2.3 Common blockers

- **"We already have tickets in Jira"** — leave them. RENAR-1 does not require migration; the tracker and the substrate can coexist. The key point is that the substrate is now the Source of Truth for **new** requirements.
- **"ADAPT is extra work"** — an ADAPT takes 1-2 hours per TZ. It pays off at the very first disputed acceptance.
- **"Where do we store it?"** — any substrate that satisfies **V1–V6**. See [guide/03-tool-guide-git](03-tool-guide-git.md) or [guide/04-document-store-substrate](04-document-store-substrate.md).

### 2.4 When to move to RENAR-2

When **new requirements** have stopped going into chats and started appearing in the substrate reliably. This takes 4-6 sprints of habit-building.

---

## 3. Stage 2 — moving to RENAR-2 (Documented)

**Level goal:** structure and frontmatter; delta-TZ as an explicit change-set.

**Typical duration:** 2-4 weeks after RENAR-1.

### 3.1 What gets added

1. Every BR / SR gets frontmatter with mandatory fields (see [reference/02-schemas](../../reference/en/02-schemas.md)).
2. Folders are structured: `br/`, `sr/`, `adapt/`, `dpia/`, ...
3. Requirement changes — only through a delta-TZ (a new immutable artifact), not through direct editing.
4. The TZ is fixed as immutable (changes only through a delta-TZ).

### 3.2 Template: legalizing existing requirements

Old requirements (already in the substrate since RENAR-1) — run a review and stamp frontmatter "as-is" without revising the content. This is **legalization**, not **rewrite**:

```yaml
---
id: BR-12
title: "Employee registration via corporate email"
status: approved          # already running in prod
created-at: "2025-12-01"  # retroactively
priority: must            # retroactive assessment
legacy: true              # marker: the requirement did not go through ADAPT from scratch
---
```

The `legacy: true` field is optional but RECOMMENDED — it distinguishes "historical" requirements from new ones that went through the full RENAR pipeline from the start.

### 3.3 Common blockers

- **"frontmatter for 100 requirements is a month"** — yes. Do it in the background, 10-15 requirements / week; new requirements get frontmatter immediately.
- **"Delta-TZ slows us down"** — in the first weeks, yes. After 2-3 iterations it usually becomes faster than "let's just change it".
- **"We don't know what priority to set retroactively"** — leave `priority: should` for all legacy; an explicit `must` is set only when confirmed with a Stakeholder.

### 3.4 When to move to RENAR-3

When frontmatter is valid for 80%+ of artifacts and the team has gotten used to delta-TZ.

---

## 4. Stage 3 — moving to RENAR-3 (Tracked)

**Level goal:** automatic validation + lifecycle enforcement + TC coverage for priority=must.

**Typical duration:** 4-8 weeks after RENAR-2.

### 4.1 What gets added

1. Substrate hooks validate frontmatter against the schema on every change. Invalid ones — integration is blocked.
2. Lifecycle statuses are used for real: every artifact is in one of the closed states (`draft` / `approved` / `verified` / `deprecated` / `obsolete`).
3. TC are created for all priority=must BR / SR / SPEC.
4. A substrate-native COVERAGE report is auto-generated on every promote-transition.
5. Reference-validation hook: creating a BR / SR with a link to an ADAPT in a status below `approved` — blocked.
6. The implementation references BR / SR / SPEC with a pinned `verifies[].version`.

### 4.2 Template: backfilling TC

For all priority=must requirements without a TC:

1. Sort by "frequency of mention in incident reports" — where a TC delivers the most value.
2. Cover 3-5 requirements / sprint, without trying to backfill everything at once.
3. `TC` are created as artifacts in your substrate with a `verified-by` link.

### 4.3 Common blockers

- **"Old requirements stubbornly resist the schema"** — leave them in a legacy folder; new ones are schema-valid right away. The substrate hook applies only to new / modified artifacts.
- **"Hooks slow down the PR cycle"** — measure: if > 30s — optimize the hooks (parallelization, caching); do not "turn them off".
- **"The team bypasses hooks via `--no-verify`"** — this is an [organizational failure pattern](07-failure-modes.md#4.3); the root cause is that the hooks are too slow / noisy. Fix them, do not forbid.

### 4.4 When to move to RENAR-4

When COVERAGE for priority=must = 100%, frontmatter is valid everywhere, and the lifecycle actually works.

---

## 5. Stage 4 — moving to RENAR-4 (Verified)

**Level goal:** all approved artifacts have successfully passing test cases (`TC`); the transition under the **`QG-2`** gate (`Verification Gate`) is enforced by the substrate; positive / negative pairing is observed; an `ai-provenance` block is set for AI-sourced material.

**Typical duration:** 6-12 weeks after RENAR-3.

### 5.1 What gets added

1. 100% of approved artifacts have a `verified-by` link to ≥ 1 TC.
2. Pos/neg pairing for every normative clause.
3. The `QG-2` gate (`Verification Gate`) is blocked by substrate-built-in checks: a transition to `verified` only when all `TC`s pass for the current `requirement-version`.
4. All TC are automated or explicitly `manual-pending` with a deadline.
5. For `tc-type: ux` — VLM-judge isolation.
6. For `tc-type: eval` — the judge model ≠ the implementation model.
7. `ai-provenance` for AI-generated artifacts: at minimum `generated-by` + `generated-at`.
8. Source citation — every normative clause has a pointer to a source in the TZ or ADAPT.
9. Reconciliation is run by the substrate at least once a week.
10. Spot-check 5 random passing TC once a sprint.

### 5.2 Template: phased coverage

Reaching 100% verified-by coverage is not a single PR. The approach:

1. First pos-only TC for all priority=must (the benefit — fast feedback).
2. Then neg-TC pairs (the benefit — catching test-fitting drift).
3. Then `tc-type` extensions (ux / eval / contract / security) as needed.

### 5.3 Common blockers

- **"Judge-model isolation is expensive"** — true. But it is a structural rate limit on [AIR-06 test-fitting drift](07-failure-modes.md#3-the-14-ai-risks-brief-summary) — it cannot be circumvented without losing verification integrity.
- **"Source citation slows authors down"** — automate it: the AI generator should emit the citation right away; manual authoring is only for legacy backfill.
- **"Reconciliation findings overwhelm the team"** — tunable thresholds; start with conservative defaults and loosen gradually.

### 5.4 When to move to RENAR-5

When RENAR-4 runs stably for 2-3 quarters, the metrics are stable, and the team is not "burning out" from reconciliation noise.

---

## 6. Stage 5 — moving to RENAR-5 (Optimized)

**Level goal:** adversarial review as a gate; multi-model agreement for priority=must; cost/latency budgets; knowledge graph as primary search; continuous evaluation for AI-critical components.

**Typical duration:** 12+ weeks after stable RENAR-4.

### 6.1 What gets added

1. An adversarial critic — a mandatory gate for `draft → approved`. The critic is a model different from the generation model.
2. Multi-model agreement for priority=must: the artifact is generated by ≥ 2 models; divergences are flagged and MUST be reviewed.
3. Cost / latency budget per artifact; an overrun → automatic decomposition.
4. Knowledge graph as primary search for AI agents.
5. Continuous evaluation for SPEC-AI.
6. Hallucination Rate metric < 1%.
7. Multi-model Disagreement Rate metric is tracked.
8. Feeding template improvements back into the `requirements-library` is standard practice.

### 6.2 When RENAR-5 is needed

- Regulated industries (fintech, healthcare, high-risk AI systems per the AI Act).
- When the product critically depends on AI-generation quality (generative products).
- When there is a budget for continuous-evaluation infrastructure.

Many projects can stop at RENAR-4 — it is enough for **conformance to a declared RENAR profile**. RENAR-5 is not necessarily "better", but it is almost always **more expensive and stricter**. Choose by need, not by fashion.

---

## 7. Migrating legacy requirements

Thousands of existing requirements in Jira / Confluence — how do you pull them in?

### 7.1 Non-migration strategy

If legacy requirements are not being actively changed — **do not migrate**. RENAR applies only to new requirements and actively changed ones. Legacy stays in its original place as read-only "historical context".

### 7.2 Selective-migration strategy

For legacy that is actively changing:

1. At the moment of the first change — pull it into the substrate as a BR/SR with a `legacy: true` marker and minimal frontmatter.
2. Apply the change as a delta-TZ.
3. After 1-2 iterations the requirement "matures" — it becomes full-RENAR (no legacy marker, with full frontmatter and TC).

### 7.3 Bulk-import strategy

When you need to migrate > 100 requirements at once (for example, during an organizational reorganization):

1. Scripted export from the tracker → a frontmatter skeleton (id, title, minimum).
2. All imported requirements — `legacy: true` + `status: approved` (as in prod).
3. Backfill TC and full frontmatter — sprint by sprint, without blocking current work.

---

## 8. When RENAR is NOT needed

RENAR is overhead. Do not apply it to:

- **One-off scripts and prototypes** — they never reach production, or they become production only through a rewrite.
- **Very small teams (1-2 people)** — the overhead of managing a substrate may exceed the benefit.
- **Projects with no AI-generation of requirements / tests** — the main value of RENAR (protection against AI-specific failure modes) is lost.
- **Short-lived experiments (≤ 1 sprint)** — you will not have time to recoup the ADAPT setup.

Minimum payback threshold: a project with ≥ 3 requirement iterations, ≥ 2 developers, using AI somewhere in the pipeline (generation of requirements / code / tests / documentation).

---

## 9. Migration anti-patterns

What to avoid:

### 9.1 Big-bang migration

**Symptom:** The team stops development for 2 sprints to "move to RENAR". After 2 sprints they get burnout and an abandoned migration.

**Instead:** Hybrid mode. New requirements go straight into RENAR, old ones — as they are touched. Slow, but sustainable.

### 9.2 Skipping levels

**Symptom:** "Let's go straight to RENAR-4". The team skips RENAR-2/3, puts in full hooks + ai-provenance + an adversarial critic, but frontmatter is not valid and the lifecycle is chaotic.

**Instead:** Levels go in order. RENAR-4 without a RENAR-3 base does not work.

### 9.3 "Perfect frontmatter" paralysis

**Symptom:** The team spends weeks polishing one piece of frontmatter — "did I pick the right `priority`?" The real work stalls.

**Instead:** frontmatter is "good enough". Mistakes are fixed in a delta-TZ. The point is that something is in the substrate, not that it is buffed to a shine.

### 9.4 Partial adoption of the substrate

**Symptom:** Half the requirements are in the substrate, half are still in Jira. Nobody knows where the Source of Truth is.

**Instead:** The Source of Truth MUST exist **right away**. If you cannot move everything — move only the new ones and explicitly declare the substrate the owner of "everything new".

### 9.5 "Tooling first" approach

**Symptom:** The team spends half a year writing internal tooling around RENAR (its own validator / its own CI / its own UI) without using the standard itself.

**Instead:** Practice first, on a minimal substrate (even a flat folder of markdown). Tooling — when it starts to hurt by hand.

---

## Adoption cost and benefit (illustrative)

> This section is **illustrative and non-normative** — it helps estimate orders of magnitude. The concrete numbers depend on the project; calibrate the real model against your own data.

**Adoption cost (what you put in):**

- Training the team on Core (5 rules + ADAPT) — on the order of half a day to a day per engineer.
- ADAPT discipline per TZ — additional hours on elicitation / backward before coding starts (recouped by not re-opening the TZ later).
- The substrate already exists (git) — no separate licenses needed; tooling automation is optional and introduced gradually.

**Benefit (what you get back):**

- Reduced TZ-decomposition time with AI acceleration (order of magnitude — [standard/12 §12.5.1](../../standard/en/12-metrics.md#12.5.1): 5–10× at RENAR-4, illustrative).
- Fewer disputes at acceptance: an ADAPT with a dual signature fixes the interpretation before code.
- Fewer incidents from negative scenarios — thanks to mandatory pos/neg TC pairing.
- An audit log of "what we delivered under contract" — free from the substrate (V1 / V6).

**When it does not pay off:** short-lived prototypes, pure product discovery without a contract, teams with no compliance pressure and no external client (see §8 "when RENAR is not needed"). For them, [RENAR Core](../../core/en/renar-core.md) or nothing is enough.

> A quantitative ROI model (per-project savings order, etc.) currently lives in the research materials; porting a calibrated version into this section is planned in the **phase-8 backlog** for v1.1.

---

## 10. Related documents

- [standard/11-maturity-model](../../standard/en/11-maturity-model.md) — normative definitions of the RENAR-1..RENAR-5 levels (closed list).
- [00-quickstart](00-quickstart.md) — a 30-minute sample for a small project.
- [01-walkthrough](01-walkthrough.md) — a full example on one project.
- [07-failure-modes](07-failure-modes.md) — what can go wrong during migration; organizational failure patterns §5.
- [reference/02-schemas](../../reference/en/02-schemas.md) — frontmatter schemas, mandatory for RENAR-2+.
- [03-tool-guide-git](03-tool-guide-git.md) — a substrate-specific guide for git.
- [04-document-store-substrate](04-document-store-substrate.md) — an informative overview of a document-oriented store substrate.

---

## 11. Decisions fixed for v1.0

- **Legacy backfill bulk-import — bypass is forbidden.** On initial import, artifacts are entered with the status `imported-legacy` (a substrate-specific marker, not part of the normative closed-list lifecycle [§10.5–§10.8](../../standard/en/10-lifecycle-qg.md#10.5)) and do not participate in conformance assessment until promoted through the normal QG-0 flow. This preserves the [§1.7.3](../../standard/en/01-scope.md#1.7.3) declared-weaker prohibition: validation is not bypassed, only deferred until the moment the artifact begins to claim conformance.
- **A rollback from RENAR-3 → RENAR-2 is permitted** through a formal downgrade per [§13.8.2](../../standard/en/13-conformance.md#13.8.2): a new version of the manifest is issued with a lowered `level`. A recovery plan is **not** mandatory (a downgrade is intentional, not a loss of conformance), but it is RECOMMENDED to record the reason for the downgrade in the audit log.
- **Cross-org migration: each subsystem — its own manifest with its own `level`** ([§13.4](../../standard/en/13-conformance.md#13.4)). The organization-aggregate "RENAR-N" is informally defined as the minimum of the subsystems' levels; an organizational manifest is **not** standardized by RENAR v1.0.

### 11.1 Deferred to v1.1 (phase-8 backlog)

- **Migration templates for teams of 50+ engineers.** The guide targets groups of 5–15 people; a larger scale needs field observations. Owners: RENAR standard maintenance and early adopters.
