---
title: "Migration to v1.0-draft"
description: "Moving from pre-RENAR / v0.1-draft practices to RENAR v1.0-draft: deprecated types, frontmatter fields, the manifest."
order: 10
lang: en
version: "1.0-draft"
---

# 10. Migration to v1.0-draft

> For teams that already managed requirements "their own way" or on early RENAR drafts. The goal is **no big-bang**: preserve immutable IDs, replace deprecated constructs, and issue a new conformance manifest. The normative basis — [standard/04 §4.14](../../standard/en/04-terms.md#4.14), [CHANGELOG §Migration](https://github.com/Kibertum/RENAR/blob/main/CHANGELOG.md).

**Do not confuse this with** [02-transition-guide](02-transition-guide.md) — that covers a staged entry into RENAR-1..5 from scratch; here we deal with a **breaking rename** and schema alignment when moving to the current edition of the standard.

---

## 1. When this migration is needed

| Situation | Action |
|---|---|
| A project with no RENAR, but with a TZ + Jira | First [02-transition-guide](02-transition-guide.md), not this document |
| Files with `INT-SR`, `INT-TC`, `AIC`, `UIC`, `TS` | This guide |
| `verifies[].version` without `requirement-version` | Update the TC frontmatter ([reference/02 §8](../../reference/en/02-schemas.md#8-tc--test-case)) |
| Manifest `renar-version: 0.1-draft` or absent | Issue a new manifest ([reference/08](../../reference/en/08-conformance-self-assessment.md)) |

---

## 2. Type-replacement table (closed list, v1.0-draft)

| Deprecated | Canonical | Migration step |
|---|---|---|
| `INT-SR` | `SR` + `constrained-by: [SPEC-INT-N]` | Rename the type; create / bind a SPEC-INT |
| `INT-TC` | `TC` + `tc-type: contract` | Add `type: TC`, `tc-type: contract` |
| `AIC` | `SPEC-AI` | Move the body into the SPEC-AI frontmatter |
| `UIC` | `SPEC-UI` | Move baselines into `specs/ui/baselines/` |
| `TS` | `SPEC-ARCH` or `SPEC-OPS` | By content (architecture vs ops runbook) |
| `TM` (module SR type) | `SR` + `level: module` | Drop the pseudo-type; set the level |

**Do not change IDs.** If a filename contains a legacy prefix, a `legacy-id` field in the frontmatter is acceptable (informative traceability).

---

## 3. Step-by-step plan (1–2 sprints)

### Phase A — inventory (1–2 days)

1. `grep` / search across the substrate: `INT-SR`, `INT-TC`, `AIC`, `UIC`, `type: system` (the erroneous TC type).
2. List the artifacts with broken `verifies` / missing `source.adapt`.
3. Record the current `RENAR-CONFORMANCE.yaml` (if any) as the baseline state.

### Phase B — schema pass (3–5 days)

1. Batch-rename the types per the §14 table (one PR per type, or one atomic change-set per delta-TZ).
2. TC: `type: TC`, `tc-type`, `verifies[].requirement-version`, `last-run.requirement-version`.
3. SR: `constrained-by[]` on every SPEC in use.
4. BR: `source.adapt` on the approved ADAPT.

### Phase C — validation (1–2 days)

1. Substrate hooks / CI: the frontmatter validator ([reference/02](../../reference/en/02-schemas.md)).
2. Run the TCs; update `last-run`.
3. Self-assessment checklist — [reference/08 §14](../../reference/en/08-conformance-self-assessment.md#2-self-assessment-checklist-mandatory-clauses).

### Phase D — manifest (1 day)

1. Bump `renar-version: "1.0-draft"`.
2. Increment `manifest-version`; new `manifest-id`.
3. Signature of the Architect / Tech Lead (V6).

---

## 4. Common pitfalls

| Mistake | Consequence | Fix |
|---|---|---|
| Renaming `SR-05` → `SR-05-v2` | V1 immutable-ID violation | `deprecated` + a new ID with `replaces` |
| Leaving `type: system` on a TC | Validator fail; KG drift | `type: TC` + `tc-type: system` |
| Migrating code before the `.req` | SoT inversion violated | First the SR/SPEC/TC approved, then the TR |
| Skipping ADAPT "only for new TZs" | Non-conformant for legacy TZ | A retrospective ADAPT for every active TZ |

---

## 5. Rollback

The migration runs through the substrate history (V1). Rollback means reverting the change-set / PR, **not** deleting artifacts. Deprecated artifacts remain with `status: deprecated` for audit.

---

## 6. Related documents

| Document | Why |
|---|---|
| [02-transition-guide](02-transition-guide.md) | RENAR-1..5 without schema breaking changes |
| [09-worked-examples](09-worked-examples.md) | Reference frontmatter after migration |
| [reference/07](../../reference/en/07-iso29148-trace-matrix.md) | External ISO 29148 statement |
| [standard/13 §13.7](../../standard/en/13-conformance.md#13.7) | Re-assessment after migration |

---

*RENAR Guide 1.0-draft — renar.tech*
