---
title: "RU Style Amendment 003: QG canonical names — Gate suffix unify"
status: proposed
phase: "Phase 2.x amendment"
epic: ru-normative-pass-v1
task: ru-style-amendment-003-qg-gate-suffix
draft-date: 2026-05-19
target-section: "§1.9.4 + §1.10.2 + §1.13.1.8 of reference/06-ru-style-guide.md"
lang: ru
---

# RU Style Amendment 003: QG canonical names — Gate suffix unify

## Rationale

Session #21 (commit `7b0f6ae`, audit-fix-qg-naming-unify) полностью унифицировал QG-2 descriptor: `verified-by-TC` → `QG-2 Verification Gate` (12 hits в 6 files + 3 pedagogical disclaimers удалены). Решение принято и pushed в `origin/main`. Эффективно — canonical form Quality Gate names получила "Gate" суффикс.

Однако reference/06 §1.9.4 (line 483) + §1.10.2 (Canonical v1.0 column) фиксируют short form БЕЗ "Gate":

```
QG-0 Approval | QG-1 Implementation | QG-2 Verification | QG-3 Architecture | QG-4 Acceptance
```

§1.13.1.8 grep pattern (`Context Gate|Requirements Gate|Implementation Gate|Verification Gate`) ловит и legacy формы, и post-Session #21 canonical (`QG-2 Verification Gate`) — produces false positives в `scripts/style-guide-check.js` legacy check (71 findings, ~10 из них именно canonical-mis-flagged).

### User decision (2026-05-19)

«Оставить с Gate (принять Session #21)» — canonical = WITH "Gate" suffix.

### Scope (this amendment)

**In scope:**
- reference/06 §1.9.4 — canonical list update.
- reference/06 §1.10.2 — Canonical v1.0 column update.
- reference/06 §1.13.1.8 — grep narrowed к prefixed-legacy strings.
- scripts/style-guide-check.js — LEGACY_LABELS const aligned.

**Out of scope (deferred):**
- standard/03-terms.md §3.14.1 (4 rows) — corpus sweep follow-up.
- standard/04-roles.md (5 mentions: lines 142, 223-227, 282-284).
- standard/10-lifecycle-qg.md (anchors / headings).
- reference/01-glossary.md (mixed: lines 115-119 already "Gate"; lines 284-290 без "Gate").

Follow-up task: `ru-qg-gate-suffix-corpus-sweep` — apply canonical update across normative chapters.

## Proposed change

### Delta 1 — §1.9.4 update

```diff
-`QG-0 Approval`, `QG-1 Implementation`, `QG-2 Verification`, `QG-3 Architecture` (optional), `QG-4 Acceptance` (optional).
+`QG-0 Approval Gate`, `QG-1 Implementation Gate`, `QG-2 Verification Gate`, `QG-3 Architecture Gate` (optional), `QG-4 Acceptance Gate` (optional).
```

### Delta 2 — §1.10.2 update

```diff
-| `QG-0 Context Gate` | `QG-0 Approval` |
-| `QG-1 Requirements Gate` | `QG-1 Implementation` (semantic shift: ранее approval BR/SR, теперь только TC `draft → ready`) |
-| `QG-2 Implementation Gate` | `QG-1 Implementation` |
-| `QG-3 Verification Gate` | `QG-2 Verification` |
+| `QG-0 Context Gate` | `QG-0 Approval Gate` |
+| `QG-1 Requirements Gate` | `QG-1 Implementation Gate` (semantic shift: ранее approval BR/SR, теперь только TC `draft → ready`) |
+| `QG-2 Implementation Gate` | `QG-1 Implementation Gate` |
+| `QG-3 Verification Gate` | `QG-2 Verification Gate` |
```

### Delta 3 — §1.13.1.8 grep narrowing

```diff
-8. **Legacy QG names** — grep `Context Gate|Requirements Gate|Implementation Gate|Verification Gate`; flag.
+8. **Legacy QG names** — grep `QG-0 Context Gate|QG-1 Requirements Gate|QG-2 Implementation Gate|QG-3 Verification Gate`; flag. Bare "Verification Gate" / "Implementation Gate" БЕЗ QG-prefix — canonical post-amendment 003 (§1.9.4); НЕ legacy.
```

### Delta 4 — script LEGACY_LABELS

```diff
 const LEGACY_LABELS = [
-  "UIC", "AIC", "INT-SR", "INT-TC", "TM", "TS",
-  "Context Gate", "Requirements Gate",
-  "Implementation Gate", "Verification Gate",
+  "UIC", "AIC", "INT-SR", "INT-TC", "TM", "TS",
+  "QG-0 Context Gate", "QG-1 Requirements Gate",
+  "QG-2 Implementation Gate", "QG-3 Verification Gate",
 ];
```

### Delta 5 — Frontmatter version

```diff
-version: "1.1"
+version: "1.1.1"
```

### Delta 6 — §5.1.3 changelog

Add sub-entry под §5.1.2.

## Pilot impact

- **RU corpus retroactive scan:** N/A в этой задаче. Session #21 уже сделал partial sweep (6 files). Remaining canonical-form-without-Gate occurrences (standard/03/04/10 + reference/01 partial) — отдельная follow-up задача `ru-qg-gate-suffix-corpus-sweep`.
- **Script behavior:** legacy check после amendment должен flag только prefixed-legacy strings; canonical `QG-2 Verification Gate` в corpus больше не triggered.

## Migration plan

1. Apply Deltas 1-6 atomically (single commit).
2. Re-run `node scripts/style-guide-check.js --check=legacy` — verify finding count drops (Session #21-canonical formes больше не flagged).
3. Create follow-up task `ru-qg-gate-suffix-corpus-sweep` для standard/03/04/10 + reference/01 update.
