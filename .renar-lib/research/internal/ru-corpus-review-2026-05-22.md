# RENAR RU Corpus Review — 2026-05-22 (Pass 2, post-remediation)

> **Assessor:** independent chief editor (prompt.md)  
> **Baseline:** commits `963c892`…`2884169` (epic `ru-corpus-review-remediation`, closed)  
> **Scope:** RU public corpus — `standard/`, `guide/`, `reference/`, `core/`, `site/src/pages/ru/`, `site/public/llms.txt`, index READMEs  
> **Mode:** readonly re-assessment

---

## Executive summary (≤10 предложений)

После remediation epic корпус v1.0-draft **существенно приблизился к публикации**: blockers Pass 1 закрыты, automated gates зелёные (включая новый `check-research-provenance`), core path читается связно, on-ramp согласован (Core → Quickstart → Standard; assessor path отдельно в §0.6.3). Public narrative больше не выглядит как migration tracker — research-provenance убран из normative cross-ref tables, guide callouts и reference headers 01–05. Главная сила — pedagogical ladder + normative integrity (MVR ↔ §14.3, substrate-agnostic, CI enforcement). Остаточный риск — **литературная неоднородность H1** (8 глав standard с EN-суффиксами в скобках) и **устаревший RENAR-SUMMARY-RU.md** (`first-class`). Verdict: **PUBLISH-WITH-FIXES** (короткий polish pass, ~3–5 дней, не структурная переработка). При закрытии E1 ниже — допустим переход к **PUBLISH-READY**.

---

## Verdict

- [ ] PUBLISH-READY — можно v1.0-draft публично
- [x] **PUBLISH-WITH-FIXES** — короткий editorial pass (H1 sweep + summary sync)
- [ ] NOT-READY — структурная переработка

---

## Scorecard (1–5, 5 = эталон стандарта)

| Ось | Score | One-line rationale |
|---|---|---|
| 1 Standard vs notes | **4.5** | Narrative + index README сильные; research-provenance убран; остались internal метки `WC-02` / `Hotspot` в normative signposts |
| 2 Literary RU | **4.0** | Core path отличный; 8 H1 standard с `(Terms…)` / `(Test cases)`; EN titles в reference/02–05; `Cross-references` в guide/03 |
| 3 Clarity / essence | **4.5** | On-ramp единый; §0.6.3 разделяет novice vs assessor; hotspots §09/10/14 → guide/reference |
| 4 Normative integrity | **5.0** | Gates PASS; MVR bijection; closed lists; substrate-agnostic; schema gate |
| 5 Public surface | **4.5** | Site/llms RU-first; README.ru исправлен; RENAR-SUMMARY-RU отстаёт |
| 6 Layer separation | **4.5** | standard/guide/reference/core роли чёткие; reference/06 meta-heavy by design |

---

## Blockers (must fix before publish)

**Нет.** Pass 1 blockers B1–B5 закрыты и зафиксированы CI gate `check-research-provenance.js`.

Допустимые упоминания `research/` (не blockers):

| Location | Why allowed |
|---|---|
| `standard/00-introduction.md:169` | Explicit «`research/` вне публикации» в §0.6.2 |
| `reference/01-glossary.md:169` | Enum value `research/legacy` (status taxonomy) |
| `reference/06-ru-style-guide.md` | Meta maintainers doc (out of reader path per prompt) |

---

## Major (should fix)

| ID | Location | Quote | Why major | Concrete fix |
|---|---|---|---|---|
| M1 | `standard/03-terms.md:6` | `# 03. Термины и определения (Terms and definitions)` | Bilingual H1 в normative — red flag prompt | `# 03. Термины и определения` |
| M2 | `standard/04-roles.md:6` | `# 04. Роли (Roles)` | Same | `# 04. Роли` |
| M3 | `standard/06-requirements-hierarchy.md:6` | `# 06. Иерархия требований (Requirements hierarchy)` | Same | RU-only H1 |
| M4 | `standard/08-specifications.md:6` | `# 08. Спецификации — 9 типов SPEC (Specifications)` | Same | `# 08. Спецификации — 9 типов SPEC` |
| M5 | `standard/09-test-cases.md:6` | `# 09. Тест-кейсы (Test cases)` | Same | `# 09. Тест-кейсы` |
| M6 | `standard/12-maturity-model.md:6` | `# 12. Модель зрелости (Maturity model)` | Same | `# 12. Модель зрелости` |
| M7 | `standard/13-metrics.md:6` | `# 13. Метрики (Metrics)` | Same | `# 13. Метрики` |
| M8 | `RENAR-SUMMARY-RU.md:31,42` | «first-class артефакт» | 60-line public entry; site/README уже «полноценные» | Заменить на «полноценный / самостоятельный артефакт» |
| M9 | `reference/02-schemas.md:9` | `# Schemas — formal` | EN H1 в public lookup TOC | `# Схемы (формальные)` |
| M10 | `reference/04-ai-style-guide.md:9` | `# AI Style Guide — генерация…` | Mixed EN/RU H1 | `# Руководство по AI-стилю — генерация RENAR-арteфактов` |
| M11 | `reference/05-knowledge-graph-schema.md:9` | `# Knowledge Graph Schema` | EN H1 | `# Схема графа знаний` |

---

## Minor / polish

| ID | Location | Issue | Fix |
|---|---|---|---|
| m1 | `standard/00,06,09,10,14` | `Hotspot (WC-02)` — internal project label | «Плотная глава — см. guide/00 / reference/09» |
| m2 | `guide/07-failure-modes.md:9` | `# 07. Режимы отказа (Failure modes)` | RU-only H1 |
| m3 | `guide/06-compliance.md:9` | `# 06. Соответствие (Compliance)` | Optional RU-only |
| m4 | `guide/03-tool-guide-git.md:312` | `## 11. Cross-references` | `## 11. Перекрёстные ссылки` |
| m5 | `reference/04,05` §Cross-references | EN section title | RU heading |
| m6 | `guide/02-transition-guide.md:36` | «Disputed acceptances» | One-time RU gloss |
| m7 | Uncommitted `standard/README.md`, `guide/README.md`, `reference/README.md`, `core/README.md` | Literary README pass exists locally but not in HEAD | Commit or discard to avoid drift |

---

## Anti-pattern inventory

| Pattern | Count (public corpus*) | Top 3 locations |
|---|---|---|
| `research/` path (actionable leak) | **0** | — (gate PASS) |
| `research/` (allowed/meta) | 3 | `standard/00 §0.6.2`, `reference/01 enum`, `reference/06` meta |
| `(Introduction)` / `(Scope)` H1 suffix | **0** | Fixed in Pass 1 remediation |
| Other EN H1 suffix `(Terms…)` etc. | **8** | `standard/03,04,06,08,09,12,13`; `guide/07` |
| `Источник:` provenance blockquote | **0** | Fixed Pass 1 |
| `исследовательский draft` | **0** | Fixed Pass 1 |
| `Cross-references` EN heading | **3** | `guide/03`, `reference/04,05` |
| `first-class` без RU-обёртки | **2** | `RENAR-SUMMARY-RU.md` only (README.ru fixed) |
| `legacy extract` / `draft N` in prose | **0** | — |
| `Pre-conditions` / `Post-conditions` in prose | **0** | §10 uses «предусловие/постусловие» ✓ |

\*Excludes `reference/06-ru-style-guide.md` (meta).

---

## Pedagogical contract — all chapters standard/00–14

| Глава | Одна фраза «зачем читателю» |
|---|---|
| 00 | Понять что такое RENAR, MVR и куда идти по корпусу |
| 01 | Узнать, обязателен ли RENAR для вашего контекста |
| 02 | Сопоставить RENAR с ISO/NIST/EU рамками без переписывания чужих стандартов |
| 03 | Получить canonical термины — один термин, одно значение |
| 04 | Понять роли и ответственность за ADAPT, подписи, QG |
| 05 | Усвоить три несущих утверждения (SoT, waterfall-form, substrate) |
| 06 | Выучить closed list BR/SR/TR и связь с SPEC |
| 07 | Нормативно оформить мост ТЗ → инженерные арteфакты через ADAPT |
| 08 | Применить closed list 9 типов SPEC и граф связей |
| 09 | Вести TC как полноценные арteфакты с pos/neg и anti test-fitting |
| 10 | Знать когда можно менять status и какие QG блокируют переход |
| 11 | Проверить, что substrate удовлетворяет V1–V6 |
| 12 | Выбрать уровень зрелости RENAR-1..5 для проекта |
| 13 | Измерять процесс RE метриками (не бизнес-ROI) |
| 14 | Заявить conformance и пройти self-assessment / audit |

---

## Reader journey matrix

| Persona | Start | Found in 10 min? | Friction |
|---|---|---|---|
| **Разработчик** | `core/renar-core.md` → `guide/00` | **Да** | QG naming (QG-ADAPT-approve vs QG-3) — один абзац glossary |
| **Tech Lead** | `standard/README` → `guide/02` | **Да** | None critical post §0.6.3 fix |
| **PM** | `core` → `guide/05` | **Да** | None |
| **Auditor** | `reference/07` → `reference/08` → `standard/14` | **Да** | None — glossary header clean |

---

## Recommended epic (prioritized backlog)

| Epic | Title | Scope | Acceptance criteria | Effort |
|---|---|---|---|---|
| **E1** | H1 RU-only sweep — remaining standard chapters | `standard/03,04,06,08,09,12,13` + `guide/07` | 0 H1 with EN parenthetical suffix; extend `check-literary-headings` to H1 | **S** |
| **E2** | Reference lookup titles RU | `reference/02,04,05` + Cross-references headings | RU H1 in public TOC; no bare EN chapter titles | **S** |
| **E3** | Public summary sync | `RENAR-SUMMARY-RU.md`, optionally `RENAR-SUMMARY.md` | No `first-class`; aligned with README.ru + site | **S** |
| **E4** | De-internalize WC-02 signposts | `standard/00,06,09,10,14` | Replace `WC-02` with reader-facing «плотная глава» | **S** |
| **E5** | Commit or reconcile uncommitted index READMEs | `standard/README`, `guide/README`, `reference/README`, `core/README`, `standard/11` | No orphan local-only literary pass | **S** |

---

## What NOT to change

- Canonical loanwords: `substrate`, `frontmatter`, `conformance`, `traceability`, drift-classes §0.3.1
- RFC-2119 RU modals — не понижать
- Closed lists (MVR, SPEC, QG, backward categories)
- Substrate-agnostic normative / git-specific только в guide/03
- `reference/06-ru-style-guide.md` — research refs допустимы (maintainers meta)
- §0.6.2 row «`research/` вне публикации» — intentional boundary statement
- `check-research-provenance.js` gate — keep in `check:all`

---

## Delta vs Pass 1 (2026-05-22 morning)

| Metric | Pass 1 | Pass 2 |
|---|---|---|
| Blockers | 5 | **0** |
| Verdict | PUBLISH-WITH-FIXES | PUBLISH-WITH-FIXES (near READY) |
| Axis 1 | 3.5 | **4.5** |
| Axis 2 | 4.0 | 4.0 |
| Axis 3 | 4.0 | **4.5** |
| Axis 4 | 4.5 | **5.0** |
| `check-research-provenance` | n/a | **PASS** |
| Actionable `research/` leaks | ~15 | **0** |

---

## Appendix: gates output

```text
npm run check:all — PASS
  check-substrate-leakage.js: OK (0 findings standard/)
  check-md-links.js: OK (0 broken, 42 files)
  style-guide-check.js: OK (38 files, 0 findings)
  check-literary-headings.js: PASS
  check-site-russian-prose.js: PASS
  check-research-provenance.js: PASS

node scripts/validate-frontmatter.js — PASS (38 files, 0 failed)
```

---

*Pass 2 completed 2026-05-22 after remediation commits 963c892, 0ca63eb, 2884169.*

---

# Pass 3 — publish polish (epic `ru-corpus-publish-polish`)

> **Baseline:** uncommitted polish batch + epic tasks E1–E5  
> **Scope:** same as Pass 2  
> **Mode:** post-remediation verification

## Executive summary

Epic `ru-corpus-publish-polish` закрыт: H1 RU-only sweep (standard/03–13 + guide/07 + bonus guide/03,05,06,08), reference/02,04,05 titles, `RENAR-SUMMARY-RU.md` sync, WC-02 signposts de-internalized, index READMEs + `standard/11` committed. Gate `check-literary-headings.js` расширен на H1 (chapter suffix + reference Cyrillic). `npm run check:all` PASS.

## Verdict

- [x] **PUBLISH-READY** — v1.0-draft RU corpus готов к публичной публикации
- [ ] PUBLISH-WITH-FIXES
- [ ] NOT-READY

## Scorecard (Pass 3)

| Ось | Pass 2 | Pass 3 | Rationale |
|---|---|---|---|
| 1 Standard vs notes | 4.5 | **4.5** | WC-02/Hotspot убраны из normative signposts; reference/09 meta сохраняет WC-02 by design |
| 2 Literary RU | 4.0 | **4.5** | 0 EN H1 suffixes в standard; reference lookup titles RU; gate на H1 |
| 3 Clarity / essence | 4.5 | **4.5** | On-ramp без изменений |
| 4 Normative integrity | 5.0 | **5.0** | Gates PASS |
| 5 Public surface | 4.5 | **5.0** | RENAR-SUMMARY-RU синхронизирован |
| 6 Layer separation | 4.5 | **4.5** | Без регрессий |

## Blockers

**Нет.**

## Residual optional polish (non-blocking)

| ID | Location | Issue |
|---|---|---|
| o1 | `guide/03-tool-guide-git.md:312` | `## 11. Cross-references` → optional RU heading |
| o2 | `guide/02-transition-guide.md:36` | «Disputed acceptances» — optional one-time RU gloss |

## Delta vs Pass 2

| Metric | Pass 2 | Pass 3 |
|---|---|---|
| Blockers | 0 | **0** |
| Verdict | PUBLISH-WITH-FIXES | **PUBLISH-READY** |
| EN H1 suffix (standard) | 8 | **0** |
| `first-class` in RENAR-SUMMARY-RU | 2 | **0** |
| WC-02/Hotspot in standard signposts | 6 | **0** |
| H1 gate | H2/H3 only | **H1 + H2/H3** |

---

*Pass 3 completed 2026-05-22 after epic `ru-corpus-publish-polish`.*
