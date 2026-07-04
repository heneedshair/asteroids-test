---
title: "Epic: RU literary pass v1 — читаемость + RFC fidelity"
status: done
completed: 2026-05-22
lang: ru
version: "1.0-draft"
epic: ru-literary-pass-v1
parent: ru-normative-pass-v1
created: 2026-05-22
---

# Epic `ru-literary-pass-v1`

> **Продолжение** `ru-normative-pass-v1` Phase 5.  
> **Проблема:** RU-корпус и лендинг читаются как гибрид EN/RU; §02 и `/ru/` — типичные симптомы.  
> **Цель:** литературная подача на русском при **сохранении RFC 2119 semantic** (Style Guide §2, Option C).

## Definition of Done (epic)

1. **Phase 0 audit** опубликован: [`internal/ru-literary-audit-2026-05-22.md`](internal/ru-literary-audit-2026-05-22.md).
2. **15 глав** `standard/` прошли Phase 5 editorial pass (форма, не content).
3. **Лендинг** `site/src/pages/ru/` — RU prose; factual sync с §11/§12.
4. Gates green: `style-guide-check.js`, `check-substrate-leakage.js`, `check-md-links.js`, **`check-rfc-modals.js`**, **`check-literary-headings.js`** (new).
5. Spot-check: §02 читается за ≤5 мин skimming; position statement на русском.
6. `reference/09-pedagogical-density.md` — обновлены signposts после правок.

## Три оси (не смешивать в одном PR)

| Ось | Что меняем | RFC-риск | Gate |
|---|---|---|---|
| **L1 Anglicism** | Bucket C/E в prose | Низкий | `style-guide-check.js` |
| **L2 Literary** | абзацы, заголовки, маршруты читателя, структура §2.5 | Низкий | human + `check-literary-headings.js` |
| **L3 RFC fidelity** | только synonym **того же level** | **Высокий** | `check-rfc-modals.js` + diff review |

**Hard rule:** L1+L2 = editorial. Смена modal level (`должен`→`следует`) = content change → отдельная задача с rationale.

## Policy (canonical)

- [`reference/06-ru-style-guide.md`](../reference/06-ru-style-guide.md) §1–§3 — normative для pass.
- RFC 2119: RU lowercase `должен/обязан/следует/может/запрещено` = MUST/SHALL/SHOULD/MAY/MUST NOT (§2.1.3 carve-out).
- Заголовки §X.Y в `standard/` — **русский**; EN official title ISO — в скобках или subtitle.
- Closed-list IDs (BR, QG-0, SPEC-ARCH) — не переводить.
- `research/*` frozen — не трогать.

## Prerequisites (уже закрыты)

| Blocker | Статус |
|---|---|
| F1 glossary drift | ✅ Phase 1.5 reconciled (`reference/01` 2026-05-16) |
| F2 RFC regime | ✅ Option C locked in Style Guide §2.2 |
| Style Guide §1–§3 | ✅ `reference/06` published |
| Site anglicism audit | ✅ [`internal/ru-site-anglicism-audit-2026-05-22.md`](internal/ru-site-anglicism-audit-2026-05-22.md) |

---

## Story E — Audit + gates (foundation)

| ID | Задача | P | Статус | Output |
|---|---|---|---|---|
| E1 | Phase 0 literary audit matrix | P0 | **done** |
| E2 | `scripts/check-rfc-modals.js` | P0 | **done** |
| E3 | `scripts/check-literary-headings.js` | P1 | **done** |
| E4 | `scripts/check-site-russian-prose.js` | P1 | **done** |
| E5 | Wire gates в `package.json` (`check:all`) | P2 | **done** |

### E2 spec (RFC gate)

- Scan `standard/`, `reference/` (normative role), `core/` for modal inventory.
- In **PR diff mode**: flag if line removed `обязан|должен` and added `следует|рекомендуется` (same clause context heuristic).
- Report-only mode for baseline pass.

### E3 spec (literary headings)

Denylist EN-only H2/H3 patterns in `standard/*.md`:
`Conformance position statement`, `Informative references`, `Immediate re-assessment`, `Business Requirement`, `Source of Truth`, …
Allow: ISO titles in parentheses, code backticks, `README`.

---

## Story F — Normative Phase 5 (`standard/`)

**Порядок:** pilot §02 → входные §01/§00 → §03 → hotspots §06/§09/§10 → остальное.

| ID | Глава | P | Lit. | RFC modals | Статус | Ключевые правки |
|---|---|---|---|---|---|---|
| F0 | **02** normative-refs | P0 | **done** |
| F1 | 01 scope | P0 | **done** |
| F2 | 00 introduction | P0 | **done** |
| F3 | 03 terms | P1 | **done** |
| F4 | 05 methodology | P1 | **done** |
| F5 | 04 roles | P2 | **done** |
| F6 | 07 adapt | P1 | **done** |
| F7 | 08 specifications | P1 | **done** |
| F8 | 06 hierarchy | P1 | **done** |
| F9 | 09 test-cases | P1 | **done** |
| F10 | 10 lifecycle-qg | P1 | **done** |
| F11 | 11 substrate | P2 | **done** |
| F12 | 12 maturity | P2 | **done** |
| F13 | 13 metrics | P2 | **done** |
| F14 | 14 conformance | P1 | **done** |

**Per-chapter workflow (1 chapter = 1 PR):**

```
1. Read chapter + Style Guide §1–§3
2. L1: Bucket C/E pass (manual, no bulk replace)
3. L2: opening «кому/зач/куда»; headings RU; split walls; signpost
4. L3: modal inventory before/after → check-rfc-modals
5. npm run check:all (links, style, leakage, rfc-modals)
6. Update reference/09 signpost if tier changed
7. Human spot-check 10% lines (memory #31)
```

**§02 pilot — acceptance (F0):**

- §2.3 position statement — полностью на русском.
- §2.4.1.2 заголовок: «Триггеры немедленной переоценки».
- §2.5: сводная таблица + блок «Пять ключевых»; остальное с пометкой «расширенный каталог».
- 0 EN H2/H3 без скобок.
- Все RFC modals — тот же level.

---

## Story G — Site RU prose

| ID | Задача | P | Статус |
|---|---|---|---|
| G1 | `site/src/pages/ru/index.astro` | P0 | **done** |
| G2 | `site/src/pages/ru/principles.astro` | P0 | **done** |
| G3 | `site/public/llms.txt` | P1 | **done** |
| G4 | Navbar/Footer «Core» polish | P2 | **done** (index/principles без Core в CTA) |

Cross-ref: [`internal/ru-site-anglicism-audit-2026-05-22.md`](internal/ru-site-anglicism-audit-2026-05-22.md).

---

## Story H — Guide + reference polish (P2)

| ID | Задача | P | Статус |
|---|---|---|---|
| H3 | `reference/11-external-standards-mapping.md` | P3 | **done** |
| H1 | guide/00, guide/01, core/renar-core | P2 | **done** |
| H2 | reference/01 + guide/02–09 | P2 | **done** |

---

## Timeline (estimate)

| Sprint | Deliverable | ~hours |
|---|---|---|
| S1 | E2–E3 gates + F0 §02 pilot + G1 index | 6–8 |
| S2 | F1–F2 + G2 principles | 6–8 |
| S3 | F3, F6–F8 | 10–12 |
| S4 | F9–F10 hotspots | 12–16 |
| S5 | F11–F14 + G3 + E4–E5 | 8–10 |
| S6 | H1–H2 polish | 6–8 |

**Total:** ~48–62 h editorial (human spot-check included).

---

## Risks

| R | Mitigation |
|---|---|
| Semantic downgrade при «улучшении» | E2 gate + mandatory L3 inventory per PR |
| Scope creep (content change) | Editorial PR template: «form only» checkbox |
| §02.5 shrink loses information | Move to `reference/11`, link from §2.5 |
| PDF regression | Rebuild `npm run pdf:ru` after F0, F10 |

---

## Связанные артеfactы

| Doc | Role |
|---|---|
| [`ru-editorial-audit.md`](ru-editorial-audit.md) | Phase 1 frozen input |
| [`ru-anglicism-inventory.md`](ru-anglicism-inventory.md) | Frequency data |
| [`reference/06-ru-style-guide.md`](../reference/06-ru-style-guide.md) | Normative editorial policy |
| [`reference/09-pedagogical-density.md`](../reference/09-pedagogical-density.md) | Hotspot signposts |
| [`ru-agent-ready-roadmap.md`](ru-agent-ready-roadmap.md) | Sibling epic (agent-ready) |

---

## Следующий шаг (agent)

**Start S1:** E2 scaffold + **F0** rewrite `standard/02-normative-refs.md` + **G1** `index.astro`.

Коммит — только по запросу пользователя.
