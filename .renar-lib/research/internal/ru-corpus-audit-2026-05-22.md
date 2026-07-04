---
title: "RU corpus audit — 2026-05-22"
status: active
lang: ru
version: "1.0-draft"
---

# RU corpus audit — 2026-05-22

> **Scope:** `standard/`, `guide/`, `reference/`, `core/`, distribution (PDF/site), agent-ready artifacts.  
> **Не в scope:** `research/` drafts, `.claude/`, implementation/pilot.

## Executive summary

| Область | Verdict | Score |
|---|---|---|
| Automated gates | **PASS** (6/7 green; style 2 findings) | 9/10 |
| Vendor / substrate leakage (normative) | **PASS** | 10/10 |
| TAUSIK policy (corpus vs landing) | **PASS** | 10/10 |
| Distribution parity (SENAR-like) | **PASS** | 9/10 |
| Agent implementability (index + profile) | **PARTIAL** | 6/10 |
| RFC modal voice (hotspot §07/09/10/14) | **PASS** (minor P2) | 8/10 |
| Summary / EN stub freshness | **FAIL** | 4/10 |

**Overall RU v1.0-draft (theoretical): 8/10** — готов как литературный стандарт; agent-index и EN summary — главные пробелы.

---

## 1. Automated gates

| Gate | Result |
|---|---|
| `check-substrate-leakage.js` | ✅ 0 findings in `standard/` |
| `check-md-links.js` | ✅ 0 broken (41 files) |
| `check-site-parity.js` | ✅ guides=11, reference=10 |
| `validate-frontmatter.js` | ✅ 37/37 |
| `validate-schema-examples.js` | ✅ 0 violations |
| `style-guide-check.js` | ⚠️ **2 findings** (see §5) |

---

## 2. Vendor / tool leakage

### 2.1 Normative (`standard/00–14`)

| Check | Result |
|---|---|
| TAUSIK / KAI / Raven / Finka / Cursor | ✅ 0 |
| `.req/` layout paths | ✅ replaced → `[requirements-substrate]/` |
| `commit` as normative step | ✅ §11.8 → atomic change unit |
| §11.4 vendor table | ✅ explicitly non-normative example |

### 2.2 Guide / reference / core

| Location | Finding | Severity |
|---|---|---|
| `guide/*.md` | `.req/` paths in 03, 05, 06, 08 — **допустимо** (substrate guide) | — |
| `reference/06-ru-style-guide.md:64` | `.tausik/` — meta про repo tooling, не RENAR normative | P3 info |
| `guide/01-walkthrough.md` | 0 TAUSIK; substrate-agnostic `Operation:` blocks | ✅ |

### 2.3 TAUSIK policy

| Zone | TAUSIK |
|---|---|
| `standard/` | none ✅ |
| `guide/` | none ✅ |
| `reference/` | none (except repo path meta) ✅ |
| `README.md` / `README.ru.md` | removed ✅ |
| `site/src/pages/ru/index.astro` | **единственное** публичное упоминание ✅ |

---

## 3. Distribution parity (vs SENAR)

| Artifact | Status |
|---|---|
| Markdown source (`standard/`, `guide/`, `reference/`, `core/`) | ✅ |
| MkDocs `/docs/` (Docker hybrid) | ✅ built in CI image |
| PDF `docs/RENAR-v1.0-draft-ru.pdf` | ✅ ~12 MB; `npm run pdf:ru` |
| PDF on site `/renar-v1.0-draft-ru.pdf` | ✅ |
| README «PDF Downloads» | ✅ EN + RU |
| `mkdocs.yml` repo_url | ✅ gitlab req-standart |

**P3:** PDF не в Git LFS — diff тяжёлый при каждом regen.

**P3:** `pdf-manifest-ru.json` не включает `reference/10` в committed PDF from prior build — **verify regen** after §10 add (manifest already updated in repo).

---

## 4. Agent implementability

| Deliverable | Status | Gap |
|---|---|---|
| `reference/normative-index.yaml` | ✅ MVR + §14.3 + QG-0..2 | Per-chapter MUST clauses not indexed |
| `reference/10-agent-implementation-profile.md` | ✅ vendor-neutral | Coverage table says partial |
| Walkthrough substrate-agnostic | ✅ | — |
| Dedicated vendor RI guide | ✅ cancelled (landing only) | — |

**Agent can implement MVR + gates today;** full clause-level automation needs index expansion (~150–200 enforcement points estimated from modal count in `standard/`).

Modal density (approx. `должен|обязан|запрещ` hits): §10=34, §14=20, §09=15, §07=9 — hotspot chapters are dense enough.

---

## 5. Style / RFC modal audit

### 5.1 `style-guide-check.js` failures

| File | Rule | Fix |
|---|---|---|
| `guide/01-walkthrough.md:512` | bucket-a: `Substrate` → `substrate` | trivial |
| `reference/10-agent-implementation-profile.md:72` | EN `MUST` in RU table → `ОБЯЗАН` or backticks | trivial |

### 5.2 Hotspot chapters (§07, §09, §10, §14)

**§07 ADAPT:** imperative dominant (`обязано`, `обязаны`, `запрещён`). ✅

**§10 Lifecycle:** strong imperative (`обязан`, `обязано`, `не имеет права`). Definitions use «является» correctly (gate definition, policy specialization). ✅

**§14 Conformance:** mandatory §14.3 blocks use «обязан/обязано». ✅

**§09 TC — 2 modal P2:**

| Line | Text | Recommendation |
|---|---|---|
| §9.14.1 | «инженер **выполняет** спот-чек» | → «инженер **обязан выполнять**» |
| §9.16 (impact) | «AI-агент **выполняет** impact analysis» | → «AI-агент **обязан выполнять**» |

«является» elsewhere — definitions / explanatory (§6.2.3, §8 intro, §5 positioning) — **acceptable** per `reference/06 §2.4.2`.

---

## 6. Stale / inconsistent public docs

| File | Issue | Severity |
|---|---|---|
| `RENAR-SUMMARY.md` | v0.1-draft, **Raven**, wrong QG labels, stale date | **P1** |
| `RENAR-SUMMARY-RU.md` | ✅ updated v1.0-draft | — |
| `README.ru.md` §статус | aligned 2026-05-22 | ✅ |
| `site/ru/index.astro` CTA footer | «21.05.2026» vs hero «22.05.2026» | P3 |

---

## 7. Remediation backlog (prioritized)

### P0 — none

All blocking gates green.

### P1

1. Update `RENAR-SUMMARY.md` to mirror RU summary (v1.0-draft, no Raven, QG-0..4).
2. Fix 2 `style-guide-check` findings.
3. Regenerate PDF after §10 in manifest (if not done post-commit).

### P2

4. §09.14.1 + §09.16 modal imperative pass.
5. Expand `normative-index.yaml` — QG-3/4 optional + top 30 per-chapter MUST from §07/§09/§10.
6. Add `reference/10` to PDF regen verify.

### P3

7. Site CTA date sync.
8. Git LFS for PDF optional.
9. CI job `pdf:ru` in Docker (Chrome preinstalled).

---

## 8. Definition of Done — theoretical v1.0-draft

| Criterion | Status |
|---|---|
| 0 vendor-leak in `standard/` | ✅ |
| TAUSIK landing-only | ✅ |
| MVR + §14.3 in index | ✅ |
| Walkthrough vendor-neutral | ✅ |
| PDF + site + MD | ✅ |
| All validators green | ⚠️ style 2/37 |
| EN summary current | ❌ |
| Per-clause index complete | ❌ |

**Verdict:** theoretical RU standard **готов для чтения и review**; **agent-full-index + EN summary** — before calling «implementable without human gaps».

---

*Next audit trigger: after P1 fixes or before EN translation kickoff.*
