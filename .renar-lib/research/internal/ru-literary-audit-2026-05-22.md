---
title: "Phase 0: RU literary audit matrix"
status: done
date: 2026-05-22
epic: ru-literary-pass-v1
method: "Style Guide §1–§3 + reference/09 + ru-editorial-audit + manual §02 review"
---

# Phase 0: матрица литературности RU-корпуса

> Input для epic [`ru-literary-pass-v1`](../ru-literary-pass-v1-epic.md).  
> **Lit.** = субъективная читаемость 1–5 (5 = хорошо). **Ang.** = anglicism pressure (🔴/🟠/🟢).

## Шкала Lit. (1–5)

| Score | Критерий |
|---|---|
| 5 | Читается как RU tech prose; входной абзац; заголовки RU |
| 4 | Мелкие EN вставки; структура OK |
| 3 | Смешанный EN/RU; нужен skimming map |
| 2 | Стены текста; EN headings; «перевод в голове» |
| 1 | Нечитаемо без glossary (§02 §2.5, principles.astro) |

## `standard/` — 15 глав

| Гл. | Lines | Tier¹ | Lit. | Ang. | RFC² | Priority | Top-3 проблемы |
|---|---:|---|---:|---|---:|---|---|
| 00 intro | 178 | M | 3 | 🟠 | ~12 | P0 | MVR EN SHALL; reader route слабый |
| 01 scope | 184 | M | 2 | 🔴 | ~15 | P0 | 69 bare §-refs; closed list EN cluster |
| **02 refs** | **221** | **M** | **1** | **🔴** | **~8** | **P0 pilot** | EN headings; §2.5×14 однотипно; §2.3 монолит EN |
| 03 terms | 283 | H | 3 | 🟠 | ~25 | P1 | «canonical» wallpaper; dense tables OK |
| 04 roles | 194 | M | 4 | 🟢 | ~8 | P2 | Minor EN role names |
| 05 methodology | 168 | M | 3 | 🟠 | ~10 | P1 | SoT inversion abstract |
| 06 hierarchy | 403 | H | 2 | 🔴 | ~45 | P1 | Frontmatter до объяснения; long chapter |
| 07 adapt | 259 | H | 3 | 🟠 | ~18 | P1 | forward/backward без RU gloss |
| 08 spec | 301 | H | 2 | 🟠 | ~30 | P1 | SPEC descriptions mixed EN |
| 09 TC | 405 | VH | 2 | 🔴 | ~55 | P1 | Longest normative; legalese clusters |
| 10 lifecycle | 446 | VH | 2 | 🔴 | ~60 | P1 | §10.11.3 densest; pre/post EN labels |
| 11 substrate | 164 | M | 3 | 🔴 | ~12 | P2 | V1–V6 latin labels (OK ID); prose EN |
| 12 maturity | 249 | M | 3 | 🟠 | ~15 | P2 | CMMI leakage risk on site, not here |
| 13 metrics | 227 | M | 3 | 🟠 | ~10 | P2 | 48 bare §-refs |
| 14 conformance | 275 | H | 3 | 🟠 | ~35 | P1 | manifest prose heavy latin |

¹ [`reference/09-pedagogical-density.md`](../../reference/09-pedagogical-density.md)  
² Оценка modal clauses (`должен/обязан/следует/…`) — для L3 gate scope

### P0 queue (первые 4 PR)

1. **02** — pilot template + optional `reference/11` overflow  
2. **01** — вход после 02; §1.7 «политика закрытого списка» readable  
3. **00** — MVR RU migration  
4. **site index + principles** — параллельно (Story G)

---

## §02 deep dive (user report: renar.tech/docs/standard/02-normative-refs/)

### Structural

| § | Проблема | Fix pattern |
|---|---|---|
| 2.1 | Bullet list без «кому» | + абзац: архитектор / compliance / агент |
| 2.3 | EN position statement | RU + ISO refs в footnote |
| 2.4.1.2 | `Immediate re-assessment triggers` | «Триггеры немедленной переоценки» |
| 2.4.2–6 | OK таблицы | RU в ячейках «Как соотносится» |
| 2.5 | 14× однотипный блок | Tier A (5) inline; Tier B → reference/11 |
| 2.6 | OK | RU column headers |
| 2.7 | OK structure | Bucket C in «Почему не принимает» |

### Sample EN-in-prose (must fix in F0)

| Строка (concept) | RU target |
|---|---|
| `claim conformance` | заявление о соответствии |
| `Informative references` | Информативные ссылки |
| `frameworks` | фреймворки / методологии |
| `vocabulary` | терминология |
| `positioning` | позиционирование |
| `replication` | полное воспроизведение |
| `agent-driven` | разработка с AI-агентами |
| `first-class` | полноценные артефакты (TC) |
| `dated reference` | датированная ссылка (dated reference) — один раз define |

### RFC-safe zones in §02

Мало normative MUST-clauses; безопасно для aggressive L1+L2:

- `обязан` (§2.4.3 SR frontmatter) — **keep MUST level**
- `обязаны` (§2.4.4 TC Pass) — **keep**
- `обязан отказывать` (§2.4.5) — **keep**
- `может` (§2.6.2, §2.6.3) — **keep MAY level**

---

## Site (`site/src/pages/ru/`)

| File | Lit. | Priority | Notes |
|---|---:|---|---|
| index.astro | 1 | P0 | Hero EN subtitle; V1–V6 EN card |
| principles.astro | 1 | P0 | EN value headings; **wrong V1–V6** vs §11 |
| llms.txt | 2 | P1 | EN Key Concepts block |
| Navbar | 4 | P2 | «Ядро (Core)» acceptable |

Detail: [`ru-site-anglicism-audit-2026-05-22.md`](ru-site-anglicism-audit-2026-05-22.md).

---

## Guide / reference (Story H — P2)

| File | Lit. | Ang. | Notes |
|---|---:|---|---|
| guide/01-walkthrough | 3 | 🟠 | 20 untagged fences |
| guide/00-quickstart | 4 | 🟢 | OK |
| reference/01-glossary | 4 | 🟢 | Reconciled; prose polish only |
| reference/06 style guide | 5 | 🟠 | Meta-doc; latin expected |

---

## Canonical voice targets (Phase 5)

| Жанр | Exemplar после pass | Не использовать как exemplar |
|---|---|---|
| Terminology | `standard/03-terms.md` (post-pass) | pre-pass glossary drift |
| Normative dense | `standard/10` (post-trim §10.11.3) | pre-pass §10.11.3 |
| Reference catalog | **`standard/02` (post-F0)** | current §2.5 wall |
| Landing | `site/ru/index` (post-G1) | current principles V1–V6 |

---

## Gates checklist (post-epic)

- [x] `node scripts/style-guide-check.js` — 38/38
- [x] `node scripts/check-substrate-leakage.js` — PASS
- [x] `node scripts/check-md-links.js` — 0 broken
- [x] `node scripts/check-rfc-modals.js` — inventory OK
- [x] `node scripts/check-literary-headings.js` — PASS
- [x] `node scripts/check-site-russian-prose.js` — PASS
- [x] `npm run check:all` — green (2026-05-22)

---

*Phase 0 complete. Next: Story E2 + Story F0 + Story G1 per epic.*
