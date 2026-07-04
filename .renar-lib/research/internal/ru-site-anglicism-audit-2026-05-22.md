---
title: "RU Site Anglicism Audit — renar.tech landing"
status: draft
date: 2026-05-22
scope: "site/src/pages/ru/, site/public/llms.txt"
epic: ru-site-russian-prose
related: "reference/06-ru-style-guide.md, research/ru-anglicism-inventory.md"
---

# Аудит англицизмов на RU-лендинге RENAR

> **Контекст:** пользовательский скриншот `/ru/` — публичная страница «пестрит англицизмами». Русский стандарт должен **объяснять по-русски**; латиница допустима только для **канонических идентификаторов** (BR, ADAPT, QG-0), не для пояснительного текста.

## 1. Политика (baseline)

| Слой | Ожидание | Источник |
|---|---|---|
| `standard/` | Bucket A identifiers + substrate-domain; ≤1 latin token / normative sentence | `reference/06-ru-style-guide.md` §1.3 |
| `guide/` | Мягкое применение Style Guide | §0.2 |
| **`site/` (лендинг)** | **Строже guide:** пояснительный prose — русский; идентификаторы — в `<code>` или с русским гloss в скобках | Запрос пользователя + дух §1.5 Bucket C |

### Что оставляем латиницей (Bucket A — OK)

`RENAR`, `SENAR`, `BR`, `SR`, `TR`, `ADAPT`, `SPEC`, `TC`, `QG-0`…`QG-2`, `V1`…`V6`, `ARCH`…`OPS`, `substrate` (термин RENAR), ISO-номера, имена инструментов (git), YAML/code keys (`constrained-by[]`), теги `[test-spec-change]`.

### Что переписываем на русский (Bucket C/E — MUST для site prose)

| Было | Стало (канон site) |
|---|---|
| substrate-agnostic | независим от конкретного хранилища (substrate) |
| document-oriented store | хранилище документов |
| capabilities | возможности (capabilities) — или только «возможности V1–V6» |
| бэкенд | серверная часть / хранилище |
| peer-to-peer | равноправное дополнение |
| lifecycle | жизненный цикл |
| Goal + Acceptance Criteria | цель + критерии приёмки |
| first-class | полноценные / самостоятельные артефакты |
| forward-интерпретация | прямая интерпретация (forward) |
| backward findings | обратные находки (backward) |
| immutable | неизменяемое |
| Source of Truth | источник истины |
| Quality Gates | шлюзы качества (QG) |
| maturity | зрелость |
| end-to-end / E2E | сквозной / сквозные примеры |
| Canonical | канонические |
| open-source | с открытым исходным кодом |
| runtime | среда исполнения |
| normative (prose) | нормативный |
| self-assessment kit | набор самооценки |
| trace matrix | матрица трассировки |
| pos/neg | позитивный/негативный сценарий |
| VLM-judge | оценка через VLM (vision-language model) |
| spec-specific | привязанные к типу SPEC |

### Отдельно: фактические ошибки (не только язык)

| Место | Ошибка | Норма (`standard/`) |
|---|---|---|
| `principles.astro` V1–V6 | V3=Parent-link, V4=Content-diff, V5=Branch/merge, V6=Hooks | §11.3: V1=Immutable history, V2=Atomic change unit, V3=Diff & review, V4=Branching/WIP, V5=Version pin, V6=Author+timestamp |
| `index.astro` + `principles.astro` maturity | Initial / Managed / Defined / Measured / Optimizing (CMMI) | §12.3: Ad-hoc / Documented / Tracked / Verified / Optimized |
| `index.astro` meta description | «тест-кейсами» без пояснения | §09: допустимо «контрольные примеры (TC)» в site prose |

---

## 2. Охват и метрики

| Файл | Latin tokens (оценка) | Severity | % проблемного prose |
|---|---:|---|---:|
| `site/src/pages/ru/index.astro` | ~45 видимых EN-фраз | **P0** | ~60% абзацев |
| `site/src/pages/ru/principles.astro` | ~80+ | **P0** | ~75% абзацев |
| `site/public/llms.txt` | ~25 | **P1** | смешанный RU/EN |
| `site/src/components/Navbar.astro` | 2 (`Core`) | P2 | OK с gloss |
| `site/src/components/Footer.astro` | 0 | — | OK |
| MkDocs `/docs/` | отдельный корпус | out of scope | Phase 5 normative pass |

**Вывод:** ~95% проблемы — два Astro-файла. MkDocs уже проходит `style-guide-check.js`; лендинг — **нет**.

---

## 3. Пофайловый аудит

### 3.1 `site/src/pages/ru/index.astro`

#### Hero (стр. 15–19)

| Строка | Текст | Verdict | Действие |
|---|---|---|---|
| 15–16 | RU subtitle OK | OK | — |
| 18–19 | `Requirements Engineering & Normative Adaptive Regulation` | **S0** | Убрать или `<span lang="en" class="text-slate-500 text-xs">` под RU-расшифровкой |
| 7 meta | «тест-кейсами» | S1 | «контрольными примерами (TC)» |

#### «Что такое RENAR» (51–58)

| Фрагмент | Verdict | Rewrite |
|---|---|---|
| `substrate-agnostic` | S0 | «независим от конкретного хранилища (substrate)» |
| `VCS (git, Mercurial, SVN)` | S2 | OK с пояснением «системы контроля версий» |
| `document-oriented store` | S0 | «хранилище документов» |
| `capabilities` | S1 | «возможности V1–V6» |
| `бэкенд` | S0 (Bucket E) | «хранилище» / «серверная часть» |
| `peer-to-peer` | S0 | «равноправное дополнение» |
| `lifecycle` | S1 | «жизненный цикл» |
| SENAR full name EN | S2 | OK один раз; можно сократить до «SENAR» + ссылка |

#### Карточки концепций (68–102)

| Карточка | Проблемы | Rewrite (кратко) |
|---|---|---|
| BR→SR→TR | `Goal + Acceptance Criteria` | «цель + критерии приёмки в трекере задач» |
| ADAPT | `immutable ТЗ`, `forward-интерпретация`, `backward findings` | «неизменяемое ТЗ»; «прямая интерпретация (forward) + обратные находки (backward)» |
| 9 SPEC | типы ARCH… — OK | Добавить «девять типов» без англ. заголовка карточки |
| Тест-кейсы | `first-class`, `pos/neg`, `VLM-judge`, `UX`, `spec-specific TC types` | Полная переработка на русский с TC/VLM в скобках |
| V1–V6 | **весь абзац на EN** | Взять формулировки из §11.3 (RU post-conditions) |
| RENAR-1..5 | Initial/Managed/… | Ad-hoc/Documented/Tracked/Verified/Optimized + RU gloss |

#### «Четыре документа» (116–144)

| Пункт | Verdict |
|---|---|
| `4 Quality Gates` | → «4 шлюза качества (QG)» |
| `RENAR-1..5 maturity` | → «уровни зрелости RENAR-1..5» |
| `end-to-end` | → «сквозной пример» |
| `E2E-примеров` | → «сквозных примеров» |
| `Canonical термины` | → «канонические термины» |
| `JSON Schemas` | → «JSON-схемы» (или «схемы артефактов») |
| `AI Risk Register` | → «реестр AI-рисков» |
| `ISO 29148 trace matrix` | → «матрица трассировки ISO 29148» |
| `Conformance self-assessment kit` | → «набор самооценки соответствия» |
| `Ядро (Core)` | S2 OK | Можно «Ядро» без Core в заголовке |

#### TAUSIK (159–171)

| Фрагмент | Rewrite |
|---|---|
| `open-source` | «с открытым исходным кодом» |
| `runtime` | «среда исполнения» |
| `normative текста` | «нормативного текста» |
| `RENAR-specific skills` | «навыки RENAR для TAUSIK» |

---

### 3.2 `site/src/pages/ru/principles.astro`

**Худший файл.** Много заголовков целиком на английском; V1–V6 **фактически неверны**.

#### Meta + TOC (7, 29–32)

- description: `substrate-agnostic`, `Quality Gates`, `maturity model` → русский
- TOC: `first-class`, `Substrate-agnostic`, `Quality Gates`, `Maturity` → русский

#### §1 Пять ценностей (45–62) — заголовки S0

| EN заголовок | RU заголовок |
|---|---|
| Source of Truth | Требования — источник истины |
| Trace перед speed | Трассируемость важнее скорости |
| Closed list policy | Политика закрытого списка |
| AI-aware design | Учёт AI в проектировании |
| Substrate independence | Независимость от хранилища |

Prose: `immutable`, `lifecycle`, `drift`, `document-oriented store`, `бэкенд` → rewrite.

#### §2 Иерархия (77–96)

| EN | RU |
|---|---|
| Business Requirement | Бизнес-требование |
| System Requirement | Система-требование / требование к системе |
| Task Requirement | Задача-требование / требование к задаче |
| Goal + Acceptance Criteria | цель + критерии приёмки |

#### §3 ADAPT (109–112)

- `Forward-интерпретация` → **Прямая интерпретация (forward):**
- `Backward findings` → **Обратные находки (backward):**
- `security-issues` → «проблемы безопасности»

#### §4 SPEC (133–165)

- `schemas`, `workflow`, `model card`, `eval strategy`, `fallback policy`, `threat model`, `controls`, `Operations: deploy, monitoring, incident response` — перевести описания карточек
- `amendment`, `project-local override` → «поправка стандарта», «локальное переопределение проекта»

#### §5 TC (173–179)

Полная переработка списка; убрать `not-just-happy-path`, `Spec-specific TC types`, `hallucination rate` → «доля галлюцинаций» где prose.

#### §6 Substrate + V1–V6 (187–199) — **P0 factual + language**

Заменить сетку на §11.3:

| ID | RU (из стандарта) |
|---|---|
| V1 | Неизменяемая история |
| V2 | Атомарная единица изменения |
| V3 | Сравнение и ревью (diff & review) |
| V4 | Ветвление и черновики (WIP) |
| V5 | Закрепление версии (version pin) |
| V6 | Автор и метка времени |

#### §7 Gates (206–223)

- Заголовок → «Шлюзы качества QG-0..2»
- `Approval Gate` → «шлюз утверждения»
- `Implementation Gate` → «шлюз реализации»
- `Verification Gate` → «шлюз верификации»
- `goal + acceptance criteria`, `pos + neg`, `AC`, `verified` → русский в prose; AC допустимо в скобках

#### §8 Maturity (231–253)

- Заголовок → «Зрелость RENAR-1..5»
- Заменить CMMI-метки на §12.3 + русские пояснения
- `conformance claim`, `frontmatter validated`, `Closed-loop`, `flag regressions`, `dashboards` → русский

#### §9 SENAR (262–267)

- `pairs naturally` → «естественно сочетается»
- `peer-to-peer`, `lifecycle` → как в index

---

### 3.3 `site/public/llms.txt`

| Строка | Issue |
|---|---|
| 1 | EN title — OK для AI crawlers, но добавить RU title строкой 2 |
| 3 | `TC first-class`, `substrate V1–V6` |
| 10–17 | EN fragments в описаниях ссылок |
| 21–25 | Key Concepts блок almost EN |
| 29–30 | `E2E`, `conformance kit` |

**Действие:** RU-first описания; EN только в canonical IDs.

---

## 4. План исправления (epic `ru-site-russian-prose`)

### Phase 0 — P0 rewrite (1 PR, ~2–3 ч)

**Файлы:** `index.astro`, `principles.astro`

1. Пройти каждый `<p>`, `<li>`, `<h3>` — правило: **русское предложение + идентификатор в `<code>` при необходимости**.
2. V1–V6 и maturity — **синхронизировать с `standard/11` и `standard/12`**, не с CMMI.
3. Hero EN subtitle — de-emphasize или удалить.
4. Meta `description` — без англ. prose.

**Acceptance criteria:**
- Нет англ. слов длиной ≥5 букв вне `<code>`, `lang="en"`, href, brand names.
- Ручной просмотр `/ru/` и `/ru/principles` — «читается как русская статья».

### Phase 1 — P1 llms + meta (0.5 PR)

- `site/public/llms.txt` — RU-first
- Проверить `Layout.astro` og:description если дублирует index meta

### Phase 2 — P1 gate `check-site-russian-prose.js`

Новый скрипт (по аналогии `style-guide-check.js`):

- Скан `site/src/pages/ru/**/*.astro` — strip HTML/astro, code blocks
- Denylist Bucket C/E + site-specific: `substrate-agnostic`, `first-class`, `peer-to-peer`, `document-oriented`, `end-to-end`, `maturity`, `Quality Gate` (без QG-), `Business Requirement`, …
- Allowlist: BR, SR, TR, ADAPT, SPEC, TC, QG-, V[1-6], RENAR-, ARCH, API, …
- `npm run check:site-prose` в CI рядом с `check-site-parity.js`

### Phase 3 — P2 polish

- Navbar: «Ядро» без «(Core)» в nav; Core только в href title
- CTA «Начать с ядра (Core)» → «Начать с ядра»
- Сверка дат hero (22.05 vs 21.05 в footer CTA)

### Phase 4 — out of scope (отдельный epic)

- MkDocs `/docs/` — уже под Style Guide Phase 5
- EN landing (когда появится) — mirror structure, не translate back

---

## 5. Примеры «до / после» (index, карточка V1–V6)

**До:**
> Versioned identity, atomic change unit, parent-link, content-diff, branch/merge, hooks — те же нормативные правила для VCS и document-oriented store.

**После:**
> Шесть возможностей хранилища: **V1** — неизменяемая история; **V2** — атомарная единица изменения; **V3** — сравнение и ревью; **V4** — ветвление и черновики; **V5** — закрепление версии; **V6** — автор и метка времени. Одни и те же правила для систем контроля версий и хранилищ документов.

**До:**
> pos/neg парность, VLM-judge для UX, spec-specific TC types

**После:**
> Парность позитивного и негативного сценария; оценка интерфейса через VLM; типы контрольных примеров (TC) привязаны к типу SPEC.

---

## 6. Оценка трудозатрат

| Phase | Effort | Risk |
|---|---|---|
| P0 rewrite | 2–3 h | Low — только copy |
| P1 llms | 30 min | Low |
| P2 gate | 1–2 h | Medium — tune allowlist |
| Factual V1–V6 fix | included in P0 | **High if skipped** — вводит в заблуждение |

---

## 7. Рекомендуемый порядок работ

1. ✅ Этот аудит (done)
2. PR «ru-site-prose-p0»: index + principles rewrite + factual fix
3. PR «ru-site-prose-gate»: script + npm script + CI
4. PR «ru-site-prose-llms»: llms.txt
5. Visual QA на `localhost:4321/ru/` после sync

**Не делать:** переводить closed-list IDs (ARCH, QG-0); возвращать TAUSIK в corpus; коммит без запроса пользователя.

---

*Аудитор: agent session 2026-05-22. Связанный corpus audit: `research/internal/ru-corpus-audit-2026-05-22.md`.*
