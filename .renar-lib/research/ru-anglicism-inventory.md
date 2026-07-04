---
title: "RU Anglicism Inventory — Phase 1 audit"
status: frozen
phase: "Phase 1 input → Phase 2 Style Guide"
epic: ru-normative-pass-v1
task: ru-audit-anglicism-inventory
scan-date: 2026-05-15
corpus: "standard/ + guide/ + reference/ + core/"
lang: ru
---

# RU Anglicism Inventory

> **Read-only audit.** Frequency-таблица англицизмов в RU нормативном корпусе RENAR Standard v1.0-draft.
> Не является normative artifact — Phase 1 input для Phase 2 Style Guide. Frozen после publish.

## 1. Назначение

Audit для epic `ru-normative-pass-v1`: квантифицировать distribution англицизмов (Latin-in-prose + кальки + транслит) per chapter, чтобы Style Guide мог:

- сформировать decide-list по терминам (rewrite / keep / borderline),
- приоритизировать главы с наибольшей плотностью для Phase 5 chapter pass,
- проверить AI-bias гипотезу из memory #31: LLM trained on web English склонна вписывать anglicisms.

Inventory нейтрально перечисляет данные; решения по term-decisions принадлежат `reference/06-ru-style-guide.md` (Phase 2).

## 2. Методология

**Корпус:** 34 файла .md, 50 649 prose-слов (после strip non-prose).

**Strip pipeline** (что вырезается перед matching):

- YAML frontmatter (заголовочный блок `--- ... ---`)
- Fenced code blocks (` ``` ... ``` `)
- Inline backtick code (`` `token` ``)
- HTML-комментарии (`<!-- ... -->`)
- Markdown link URL-часть (`](url)` — link text сохраняется)

**False-positive filters (категория `latin`):**

- Brand/acronym whitelist: `RENAR`, `SENAR`, `TAUSIK`, `KAI`, `RAVEN`, `ADAPT`, `MVR`, `SPEC`, `BR`, `SR`, `TR`, `TC`, `QG`, `ISO`, `IEC`, `IEEE`, `IREB`, `CPRE`, `BABOK`, `NIST`, `MITRE`, `OASIS`, `W3C`, `OWASP`, `RFC`, `JSON`, `YAML`, `XML`, `HTML`, `CSS`, `SQL`, `API`, `HTTP`, `URI`, `URL`, `UUID`, `JWT`, `SAML`, `TLS`, `SSL`, `AI`, `ML`, `LLM`, `OS`, `MUST/SHALL/SHOULD/MAY`, `GitHub`, `Markdown`, `Astro`, `Linear`, `Slack`, `Jira` ...
- Префиксы `SPEC-*`, `RENAR-*`, `SENAR-*`, `QG-*` исключены.
- Versioned tokens (`v1.0-draft`, `V1`..`V6`) исключены.

**Категоризация:**

- `latin` — Latin-script слова в RU прозе (session, hook, manifest, drift).
- `calque` — русифицированные английские слова (имплементация, верификация, формальный).
- `translit` — заимствованные существительные с RU-орфографией (артефакт, скрипт, репозиторий).

**Negative scenarios (AC #9-10):**

- *Brand-name false positive:* исключается через WHITELIST_LITERAL до подсчёта; каждая строка Top-50 имеет обязательное поле `category` — без неё inventory считается неполным.
- *Пустая директория:* scanner печатает `WARN: no files matched in <dir>` в stderr (не молча) и продолжает. При полностью пустом корпусе — exit code 1 + `ERROR: no markdown files found in any corpus directory`.

**Ограничения метода:**

- Stem regex для кальк допускает редкие false positive на омонимах.
- Per-chapter granularity = .md файл (не §-section). Для §-level density нужно отдельное сканирование.
- ~150 candidate terms; новые англицизмы вне списка в inventory не попадают (recall < 100%).
- Style Guide должен handle context-sensitive cases (memory #31 принцип 1: «session в §6 ≠ session в §13»).

## 3. Корпус-сводка

| Метрика | Значение |
|---|---:|
| Файлов | 34 |
| Prose-слов (после strip) | 50 649 |
| Уникальных terms (≥1 hit) | 105 |
| Total occurrences | 3 263 |
| Категория `latin` | 1 838 |
| Категория `calque` | 823 |
| Категория `translit` | 602 |

### 3.1 Per-directory density

| Директория | hits | prose words | per 1 000 words |
|---|---:|---:|---:|
| `standard/` | 2 040 | 30 097 | **67.8** |
| `guide/` | 851 | 12 547 | **67.8** |
| `reference/` | 316 | 6 323 | **50.0** |
| `core/` | 56 | 1 682 | **33.3** |

**Наблюдение:** `standard/` и `guide/` показывают идентичную плотность (67.8 на 1k слов). `core/` — чище всех (gentle single-doc intro, 33.3). `reference/` — between.

### 3.2 Top-3 наиболее плотных chapters

| # | Chapter | hits | words | per 1 000 |
|---|---|---:|---:|---:|
| 1 | `guide/README.md` | 31 | 225 | **137.8** |
| 2 | `guide/03-tool-guide-git.md` | 126 | 1 213 | **103.9** |
| 3 | `standard/11-substrate-versioning.md` | 143 | 1 531 | **93.4** |

**Наблюдение:** Самые плотные — substrate/tooling главы. Это ожидаемо — substrate-capabilities оперируют англоязычной terminology (`hook`, `commit`, `merge`, `diff`). Phase 2 Style Guide должен явно зарезервировать эти термины как технические identifier-ы (Bucket A ниже), не editorial-кандидаты.

### 3.3 Bottom-3 чистых chapters

| # | Chapter | hits | words | per 1 000 |
|---|---|---:|---:|---:|
| 1 | `core/README.md` | 4 | 105 | **38.1** |
| 2 | `reference/03-ai-risk-register.md` | 53 | 1 602 | **33.1** |
| 3 | `core/renar-core.md` | 52 | 1 577 | **33.0** |

### 3.4 Полная per-file density

| Chapter | words | hits | per 1k | file |
|---|---:|---:|---:|---|
| guide/README | 225 | 31 | 137.8 | `guide/README.md` |
| guide/03 | 1 213 | 126 | 103.9 | `guide/03-tool-guide-git.md` |
| standard/11 | 1 531 | 143 | 93.4 | `standard/11-substrate-versioning.md` |
| standard/01 | 1 798 | 162 | 90.1 | `standard/01-scope.md` |
| standard/00 | 1 647 | 142 | 86.2 | `standard/00-introduction.md` |
| standard/10 | 3 083 | 247 | 80.1 | `standard/10-lifecycle-qg.md` |
| standard/12 | 2 219 | 171 | 77.1 | `standard/12-maturity-model.md` |
| standard/03 | 2 021 | 150 | 74.2 | `standard/03-terms.md` |
| guide/00 | 604 | 44 | 72.8 | `guide/00-quickstart.md` |
| guide/07 | 2 055 | 147 | 71.5 | `guide/07-failure-modes.md` |
| guide/01 | 620 | 44 | 71.0 | `guide/01-walkthrough.md` |
| guide/04 | 1 201 | 85 | 70.8 | `guide/04-tool-guide-raven.md` |
| reference/01 | 1 696 | 117 | 69.0 | `reference/01-glossary.md` |
| standard/05 | 1 468 | 101 | 68.8 | `standard/05-methodology-positioning.md` |
| standard/14 | 1 870 | 128 | 68.4 | `standard/14-conformance.md` |
| guide/02 | 1 743 | 119 | 68.3 | `guide/02-transition-guide.md` |
| standard/04 | 1 938 | 131 | 67.6 | `standard/04-roles.md` |
| standard/README | 342 | 23 | 67.3 | `standard/README.md` |
| standard/09 | 2 881 | 176 | 61.1 | `standard/09-test-cases.md` |
| guide/05 | 2 019 | 121 | 59.9 | `guide/05-safe-comparison.md` |
| standard/13 | 1 858 | 111 | 59.7 | `standard/13-metrics.md` |
| reference/README | 141 | 8 | 56.7 | `reference/README.md` |
| reference/05 | 1 054 | 58 | 55.0 | `reference/05-knowledge-graph-schema.md` |
| standard/06 | 2 265 | 113 | 49.9 | `standard/06-requirements-hierarchy.md` |
| guide/06 | 2 009 | 98 | 48.8 | `guide/06-compliance.md` |
| standard/07 | 1 346 | 65 | 48.3 | `standard/07-adapt.md` |
| standard/08 | 1 645 | 77 | 46.8 | `standard/08-specifications.md` |
| reference/02 | 521 | 24 | 46.1 | `reference/02-schemas.md` |
| standard/02 | 2 185 | 100 | 45.8 | `standard/02-normative-refs.md` |
| reference/04 | 1 309 | 56 | 42.8 | `reference/04-ai-style-guide.md` |
| guide/08 | 858 | 36 | 42.0 | `guide/08-developer-guide.md` |
| core/README | 105 | 4 | 38.1 | `core/README.md` |
| reference/03 | 1 602 | 53 | 33.1 | `reference/03-ai-risk-register.md` |
| core/renar | 1 577 | 52 | 33.0 | `core/renar-core.md` |

## 4. Heatmap: Top-20 terms × chapters

Колонки `c01`..`c34` соответствуют:

- `c01` = `core/README`
- `c02` = `core/renar`
- `c03` = `guide/00`
- `c04` = `guide/01`
- `c05` = `guide/02`
- `c06` = `guide/03`
- `c07` = `guide/04`
- `c08` = `guide/05`
- `c09` = `guide/06`
- `c10` = `guide/07`
- `c11` = `guide/08`
- `c12` = `guide/README`
- `c13` = `reference/01`
- `c14` = `reference/02`
- `c15` = `reference/03`
- `c16` = `reference/04`
- `c17` = `reference/05`
- `c18` = `reference/README`
- `c19` = `standard/00`
- `c20` = `standard/01`
- `c21` = `standard/02`
- `c22` = `standard/03`
- `c23` = `standard/04`
- `c24` = `standard/05`
- `c25` = `standard/06`
- `c26` = `standard/07`
- `c27` = `standard/08`
- `c28` = `standard/09`
- `c29` = `standard/10`
- `c30` = `standard/11`
- `c31` = `standard/12`
- `c32` = `standard/13`
- `c33` = `standard/14`
- `c34` = `standard/README`

Значения — raw occurrence counts (`·` = 0).

| # | term | cat | c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11 | c12 | c13 | c14 | c15 | c16 | c17 | c18 | c19 | c20 | c21 | c22 | c23 | c24 | c25 | c26 | c27 | c28 | c29 | c30 | c31 | c32 | c33 | c34 | **Σ** |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | `артефакт` | tra | 1 | 8 | 6 | 5 | 16 | 7 | 8 | 12 | 16 | 14 | · | · | 19 | 7 | 6 | 10 | 10 | · | 17 | 15 | 2 | 42 | 19 | 8 | 10 | 7 | 3 | 32 | 58 | 19 | 47 | 13 | 16 | 2 | **455** |
| 2 | `нормативный` | cal | · | 1 | 1 | 1 | 4 | 5 | 4 | 7 | 2 | 4 | 2 | · | 1 | 3 | · | · | · | · | 26 | 26 | 20 | 5 | 33 | 11 | 15 | 3 | 2 | 23 | 13 | 11 | 30 | 9 | 12 | 1 | **275** |
| 3 | `frontmatter` | lat | · | 1 | 1 | 1 | 18 | 7 | 7 | 4 | 10 | 7 | 3 | · | 5 | 4 | 2 | 8 | 12 | · | · | 1 | 5 | 12 | · | · | 8 | 3 | 16 | 6 | 11 | 2 | 17 | 3 | 4 | · | **178** |
| 4 | `manifest` | lat | · | · | · | · | 3 | · | · | 1 | 1 | · | · | · | · | · | · | · | · | · | 14 | 11 | 13 | · | 11 | · | · | 1 | · | 4 | 11 | 7 | 12 | 4 | 31 | · | **124** |
| 5 | `реализация` | cal | · | 8 | · | 3 | 2 | 2 | 4 | 4 | 1 | 4 | · | · | 2 | · | 1 | · | 3 | · | 4 | 4 | 4 | 5 | 3 | 15 | 4 | 2 | 1 | 13 | 9 | 6 | 2 | 1 | 4 | · | **111** |
| 6 | `review` | lat | · | · | · | 2 | 1 | 3 | 1 | 2 | 5 | 5 | · | 1 | 5 | · | 4 | · | · | · | 6 | 4 | 6 | 2 | 6 | 6 | 1 | 4 | 1 | 1 | 14 | 11 | 8 | 1 | 4 | · | **104** |
| 7 | `guide` | lat | · | · | 3 | 3 | 10 | 9 | 9 | · | 1 | 3 | · | 10 | 1 | · | 4 | 7 | 2 | 3 | 2 | · | 3 | · | · | 7 | 2 | 2 | 2 | 5 | 2 | 5 | · | · | · | · | **95** |
| 8 | `scope` | lat | · | 1 | · | · | · | · | · | 6 | 12 | 3 | · | · | 4 | · | 2 | 2 | 1 | · | 9 | 28 | · | · | 4 | · | 5 | 2 | 1 | 8 | 1 | · | · | · | 1 | 2 | **92** |
| 9 | `audit` | lat | 1 | 4 | · | · | 1 | · | 5 | 2 | 11 | 5 | · | · | 3 | · | 1 | 1 | · | · | · | 3 | 2 | 2 | · | 3 | · | 2 | 2 | 6 | 2 | 5 | 4 | 16 | 8 | · | **89** |
| 10 | `drift` | lat | · | · | · | 1 | 2 | 3 | 2 | 7 | 5 | 28 | · | · | · | · | 3 | 1 | 2 | · | 10 | 1 | 1 | 12 | · | 2 | · | 1 | · | · | · | 1 | · | 6 | · | · | **88** |
| 11 | `draft` | lat | · | 2 | 2 | 2 | · | 2 | · | 2 | 1 | 1 | · | 5 | 7 | 2 | 1 | 1 | 1 | 4 | 2 | 4 | 1 | 3 | 5 | 1 | 1 | 6 | 1 | 1 | 1 | 4 | 1 | 1 | 2 | 12 | **79** |
| 12 | `immutable` | lat | · | 4 | 4 | 3 | 3 | · | · | · | · | 1 | · | · | 4 | 1 | · | · | · | · | 3 | 8 | · | 4 | · | 2 | 5 | 9 | 2 | 2 | 9 | 7 | 2 | 1 | 3 | · | **77** |
| 13 | `нормировать` | cal | · | · | · | · | 1 | · | · | 11 | · | · | · | · | · | · | · | · | · | · | 8 | 15 | 7 | 3 | 4 | 5 | 4 | 2 | 1 | 2 | 7 | 2 | 1 | 2 | 1 | · | **76** |
| 14 | `hook` | lat | · | · | · | 1 | 3 | 7 | 2 | 2 | 5 | 5 | · | · | 1 | · | 2 | 1 | 1 | · | · | · | 1 | 10 | · | 1 | · | · | · | 5 | 4 | · | 11 | 2 | · | · | **64** |
| 15 | `spec` | lat | · | · | · | 1 | · | 1 | 1 | · | · | · | · | · | 8 | · | · | · | · | · | · | 3 | 2 | 3 | · | 9 | · | · | 13 | 6 | 6 | 4 | · | 4 | · | 1 | **62** |
| 16 | `approved` | lat | · | 4 | 5 | 4 | 2 | · | · | · | 1 | 3 | · | · | 6 | 2 | 2 | · | 2 | · | · | · | 1 | 2 | · | · | 8 | 5 | · | · | · | 7 | · | 6 | 1 | · | **61** |
| 17 | `runner` | lat | · | · | 1 | · | · | · | · | · | · | · | · | · | · | · | · | · | · | · | · | · | · | 5 | 7 | · | · | · | · | 19 | 23 | · | · | · | · | · | **55** |
| 18 | `workflow` | lat | · | 1 | · | · | 1 | 9 | 5 | 2 | 5 | 2 | 1 | 3 | · | 1 | · | · | · | · | 1 | 4 | 2 | 1 | · | 1 | · | 2 | 2 | 1 | 2 | 3 | 3 | · | 1 | · | **53** |
| 19 | `имплементация` | cal | · | · | · | · | · | 1 | 2 | 1 | 1 | · | · | 2 | · | · | · | · | · | · | 10 | 8 | 1 | 1 | 8 | 4 | · | 2 | · | · | 9 | 1 | · | · | 1 | · | **52** |
| 20 | `hooks` | lat | · | · | 1 | · | 8 | 7 | · | 2 | · | 4 | · | · | · | 1 | · | 1 | · | · | 3 | 2 | 1 | 1 | · | 2 | 3 | 2 | · | 2 | 1 | 1 | 3 | · | 1 | 1 | **47** |

## 5. Top-50 terms with first-sample context

Format: **N. [category] `term` (total)** — `first-file`: «context snippet».

1. **[translit] `артефакт` (455)** — `standard/00-introduction.md`: «- **Data model** артефактов требований (BR / SR / TR), ADAPT, девяти типов SPEC, TC.»
2. **[calque] `нормативный` (275)** — `standard/00-introduction.md`: «Глава вводит RENAR как нормативный стандарт: что он нормирует, почему существует, как соотносится с SENAR, и каков мин…»
3. **[latin] `frontmatter` (178)** — `standard/01-scope.md`: «- **Data model артефактов** — обязательные frontmatter поля, типы, enum-значения, инварианты согласованности.»
4. **[latin] `manifest` (124)** — `standard/00-introduction.md`: «- **Conformance** — уровни (RENAR-1..RENAR-5), mandatory clauses, manifest, assessment-процедуры.»
5. **[calque] `реализация` (111)** — `standard/00-introduction.md`: «RENAR — стандарт, а **не** реализация: имплементации могут существовать на разных substrate (single-SSoT правило,  §11.3 )…»
6. **[latin] `review` (104)** — `standard/00-introduction.md`: «… Pass/Fail-критерии TC вместо исправления реализации \| Adversarial review pattern + separate approval критериев TC ( §9.4 ,  §10.3.3 ) \|»
7. **[latin] `guide` (95)** — `standard/00-introduction.md`: «\|   \| **non-normative** \| Practical guides: quickstart, walkthrough, transition guide, substrate-specific tool guides, compliance, failure modes \|»
8. **[latin] `scope` (92)** — `standard/00-introduction.md`: «\| Data model артефактов \| — (вне scope) \| BR / SR / TR / ADAPT / 9 SPEC types / TC ( §6 ,  §7 ,  §8 ,  §9 ) \|»
9. **[latin] `audit` (89)** — `standard/01-scope.md`: «\| **Regulated industries** \| Compliance audit обязателен (медицина, финансы, госсектор); traceability requirements → tests → код требуется по нормативу. \|»
10. **[latin] `drift` (88)** — `standard/00-introduction.md`: «\| 1 \| **Schema drift** \| Поля артефактов расходятся между projects / substrate \| Closed list нормативных об…»
11. **[latin] `draft` (79)** — `standard/00-introduction.md`: «> **Часть RENAR Standard v1.0-draft** ·  ← Оглавление»
12. **[latin] `immutable` (77)** — `standard/00-introduction.md`: «…Код реализует требование, которое уже удалено или переименовано \| Immutable identifiers + V5 version-pin ( §11.3 ); reference-validation hooks ( §10.11.1 ) \|»
13. **[calque] `нормировать` (76)** — `standard/00-introduction.md`: «Глава вводит RENAR как нормативный стандарт: что он нормирует, почему существует, как соотносится с SENAR, и каков минимальный набор утверждений, …»
14. **[latin] `hook` (64)** — `standard/02-normative-refs.md`: «…отетически), **без** обновления   в manifest — невалидна; substrate hook ( §14.8.1  loss-of-conformance trigger) обнаруживает stale  .»
15. **[latin] `spec` (62)** — `standard/01-scope.md`: «\| 4 \| Test Cases как first-class артефакт; pos/neg парность; spec-specific TC-обязательства \|  09  \|»
16. **[latin] `approved` (61)** — `standard/02-normative-refs.md`: «**Что ещё**: Built-in quality (TC обязательно до approved); Continuous Delivery Pipeline (substrate triggers на каждое изменение); WSJF — реком…»
17. **[latin] `runner` (55)** — `standard/03-terms.md`: «\|   \| E2E-тесты бизнес-цели для BR ( §9.5 ); runner-family: E2E + AI-валидатор \|»
18. **[latin] `workflow` (53)** — `standard/00-introduction.md`: «…е в порядке, ссылается на несуществующее требование \| Delta-ADAPT workflow + V6 author/timestamp ( §7.6 ,  §11.3 ) \|»
19. **[calque] `имплементация` (52)** — `standard/00-introduction.md`: «…верждений, которым обязана удовлетворять любая RENAR-conformant имплементация (**Minimum Viable RENAR**, далее MVR). Глава фиксирует:»
20. **[latin] `hooks` (47)** — `standard/00-introduction.md`: «…utable identifiers + V5 version-pin ( §11.3 ); reference-validation hooks ( §10.11.1 ) \|»
21. **[calque] `формальный` (44)** — `standard/00-introduction.md`: «…т enforcement, а conformance manifest ( §14.4 ) фиксирует уровень формального соответствия.»
22. **[calque] `опциональный` (39)** — `standard/00-introduction.md`: «- **Lifecycle** артефактов через закрытый список Quality Gates (QG-0 / QG-1 / QG-2 обязательные; QG-3 / QG-4 опциональные).»
23. **[latin] `verified` (37)** — `standard/03-terms.md`: «\|   \| verified \| validated \|»
24. **[latin] `commit` (36)** — `standard/11-substrate-versioning.md`: «\| V2 atomic change unit \| commit \| commit \| atomic revision \| changelist submit \| document update (single _rev advance) \|»
25. **[latin] `diff` (34)** — `standard/00-introduction.md`: «…сти capabilities — immutable history (V1), atomic change unit (V2), diff & review (V3), branching / change-set (V4), cross-substrate version pin (V5), author + …»
26. **[latin] `approve` (32)** — `standard/03-terms.md`: «\|   — Diff & review \| Предложенное изменение представимо как diff против baseline и проходит approve до интеграции в SoT \|»
27. **[latin] `tool` (31)** — `standard/00-introduction.md`: «\|   \| **non-normative** \| Practical guides: quickstart, walkthrough, transition guide, substrate-specific tool guides, compliance, failure modes \|»
28. **[latin] `baseline` (31)** — `standard/02-normative-refs.md`: «…енимо для critical safety domains, но не общая практика; не часть baseline RENAR \|»
29. **[calque] `декомпозиция` (30)** — `standard/00-introduction.md`: «\| 06 \|  Requirements hierarchy  \| BR / SR / TR; декомпозиция система / подсистема / модуль \|»
30. **[calque] `композиция` (30)** — `standard/00-introduction.md`: «\| 06 \|  Requirements hierarchy  \| BR / SR / TR; декомпозиция система / подсистема / модуль \|»
31. **[latin] `task` (29)** — `standard/02-normative-refs.md`: «\| Requirements classes: stakeholder, system, software \| BR (stakeholder / business), SR (system / software), TR (task) \| Заимствует с переименованием \|»
32. **[calque] `миграция` (29)** — `standard/08-specifications.md`: «\|   \| Data model: schema, ERD, indices, миграции, retention, PII classification \| ISO/IEC 11179, JSON Schema \|»
33. **[translit] `ревью` (29)** — `standard/08-specifications.md`: «\|   \| Готов к ревью; обязательные body-разделы (§8.4.1) и type-specific (§8.5) присутствуют \|»
34. **[latin] `policy` (27)** — `standard/00-introduction.md`: «- **Closed list policy** (§0.7) — нерасширяемость MVR project-local, declared-stricter / declared-weaker правила.»
35. **[latin] `promote` (25)** — `standard/00-introduction.md`: «\| 7 \| **TC ↔ requirement provenance drift** \| TC верифицирует устаревшее поведение (  отстаёт) \| Pinned   + QG-2 блок promote в   ( §9 ,  §10.3.3 ) \|»
36. **[calque] `спецификация` (25)** — `standard/01-scope.md`: «\| 3 \| Closed list 9 типов спецификаций (SPEC-ARCH / API / DATA / INT / PROC / UI / AI / SEC / OPS) \|  08  \|»
37. **[latin] `story` (20)** — `standard/01-scope.md`: «…ent practices** \| Agile-ceremonies, sprint planning, kanban-boards, story-points estimation — вне scope; RENAR нормирует workflow артефактов требований, не mana…»
38. **[calque] `атомарный` (19)** — `standard/03-terms.md`: «…ния не наблюдаемы наружу. Конкретная substrate-native реализация (атомарная запись в distributed VCS, transaction в document store, иной механизм) — substrate-s…»
39. **[latin] `merge` (19)** — `standard/09-test-cases.md`: «…ие. Substrate-нативный hook ( глава 11 §11.3.3 ) обязан блокировать merge change unit при совпадении.»
40. **[translit] `репозиторий` (18)** — `standard/11-substrate-versioning.md`: «\| «Implementation substrate фиксирует конкретную версию requirements substrate (V5)» \| «  репозиторий фиксирует submodule SHA   репозитория» \|»
41. **[translit] `шаблон` (17)** — `standard/05-methodology-positioning.md`: «…з явного утверждения 2**: ревьюер натягивает на RENAR неподходящие шаблоны (agile sprint без waterfall-form, или classical waterfall без 4 отстроек) и отвергает…»
42. **[latin] `log` (17)** — `standard/08-specifications.md`: «**Spec-specific TC**: authn (pos + neg), authz (RBAC matrix), threat-test (каждая STRIDE-угроза → минимум 1 negative TC), audit log, secrets leakage.»
43. **[translit] `автор` (15)** — `standard/00-introduction.md`: «\| 2 \| **Lifecycle drift** \| Статусы (  /   /  ) значат разное у разных авторов \| Canonical state machines + closed list QG ( §10 ) \|»
44. **[latin] `epic` (15)** — `standard/02-normative-refs.md`: «\| Portfolio Epic / Strategic Theme \| BR группа одной системы \|»
45. **[calque] `итерация` (15)** — `standard/09-test-cases.md`: «Раз в итерацию (по умолчанию — регулярный цикл реализации; конкретный интервал фиксируется в conform…»
46. **[latin] `release` (14)** — `standard/04-roles.md`: «…го Architect **не является** достаточным actor. Подтверждение post-release бизнес-результата требует Stakeholder-а с полномочиями. При отсутствии QG-4 в manifes…»
47. **[latin] `tracker` (14)** — `guide/02-transition-guide.md`: «…уже есть тикеты в Jira»** — оставьте. RENAR-1 не требует миграции; tracker и substrate могут сосуществовать. Главное — substrate теперь источник истины для **но…»
48. **[translit] `кейс` (13)** — `standard/00-introduction.md`: «1. **Research draft** — обоснование с практическими кейсами.»
49. **[latin] `source of truth` (12)** — `standard/00-introduction.md`: «…\| **SoT inversion**: иерархия артефактов требований SHALL быть source of truth о поведении системы; код — derived артефакт реализации. Reverse-engineering повед…»
50. **[latin] `planning` (12)** — `standard/01-scope.md`: «\| 7 \| **Project management practices** \| Agile-ceremonies, sprint planning, kanban-boards, story-points estimation — вне scope; RENAR нормирует workflow артефак…»

## 6. Phase 2 рекомендации — bucket предложения

Bucket-ы — **предложение, не нормативное решение**. Phase 2 Style Guide (`reference/06-ru-style-guide.md`) финализирует.

### 6.1 Bucket A: технические identifier-ы — keep as is

Substrate-domain termini, для которых RU-эквивалент потеряет точность или связь с substrate-capabilities V1–V6:

- `commit`, `merge`, `diff`, `hook`, `hooks`, `branch`, `push`, `pull`, `frontmatter`, `manifest`, `slug`, `hash`, `trigger`, `runner`, `pipeline`, `release`, `deploy`, `build`, `patch`, `workflow`, `linter`, `parser`, `compiler`, `tooling`, `tracker`
- Capability-level: `immutable`, `atomic`, `drift`, `provenance`

### 6.2 Bucket B: status-vocabulary — decide consistent RU/EN

Появляются и в YAML, и в prose:

- `proposed`, `approved`, `verified`, `obsolete`, `frozen`, `active`, `planning`, `blocked`, `review`

**Trade-off:** либо все latin (matches frontmatter literally), либо все RU (читаемость prose). Style Guide §X.Y зафиксирует выбор.

### 6.3 Bucket C: organisational/structural — rewrite кандидаты

Заменяемы без потери семантики:

- `scope` → область / охват
- `audit` → ревизия / проверка / контроль
- `draft` → черновик
- `policy` → правило / политика
- `ownership` → владение / ответственность
- `default` → по умолчанию
- `bypass` → обход
- `rollback` / `fallback` → откат / отступление
- `override` → переопределение
- `stub` → заглушка
- `guide` → руководство (когда noun)

### 6.4 Bucket D: кальки accepted в RU IT — keep, проверить overuse

Кальки, давно прижившиеся; rewrite не требуется, но избыточное употребление снижает читаемость:

- `реализация` (111), `нормативный` (275), `формальный` (44), `опциональный` (39), `атомарный` (19), `спецификация` (25), `декомпозиция` (30), `композиция` (30), `верификация`, `валидация`, `идентификация`, `интеграция`, `миграция` (29), `авторизация`, `аутентификация`, `итерация` (15)

Phase 2: проверить density (>3% prose-слов → reduce).

### 6.5 Bucket E: кальки — rewrite кандидаты

Англоязычные кальки с нативными RU эквивалентами:

- `имплементация` (52) → реализация / исполнение
- `конформация` → соответствие *(но `conformance` — нормативный термин ISO; решение Phase 2)*
- `эссенциальный` → существенный / обязательный
- `дрифт` (11) → дрейф / расхождение
- `трейс*` → трасс* / отслеживание

### 6.6 Bucket F: транслит — mixed

- **Accepted (keep):** `артефакт` (455), `автор` (15), `шаблон` (17), `репозиторий` (18)
- **Borderline (Phase 2 decide):** `ревью` (29), `кейс` (13), `стейкхолдер` (12), `гейт`, `чекпойнт`, `онбординг`
- **Rewrite кандидаты (low-count):** `фронтенд`, `бэкенд`, `пайплайн`, `фолбэк`, `оверхед`, `апдейт` — если найдутся, переписать.

## 7. AC mapping

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Inventory artifact в `research/` | этот файл (`research/ru-anglicism-inventory.md`) |
| 2 | Покрытие 4 директорий | §3 corpus 34 файла: standard 17 + guide 11 + reference 6 + core 2 |
| 3 | Per-chapter heatmap (raw + per-1k) | §4 heatmap; §3.4 per-file density |
| 4 | 3 категории | latin / calque / translit колонки в §4 + §5 |
| 5 | Top-50 с context snippets | §5 |
| 6 | Сводка (unique, total, top-3 chapters, top-3 categories) | §3 |
| 7 | Read-only invariant | `git status`: только новый `research/ru-anglicism-inventory.md` |
| 8 | Frozen frontmatter | `status: frozen` в YAML |
| 9 | False-positive scenario | §2 «False-positive filters» + категория обязательна для каждой строки Top-50 |
| 10 | Empty-corpus negative scenario | scanner печатает `WARN: no files matched in <dir>` в stderr, exit 1 на полностью пустом корпусе |

## 8. Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Session #13 handoff: pushback «пестрит англицизмами», старт Phase 1
- Scanner: `d:/tmp/renar_anglicism_scan.py` (ephemeral; не коммитится по scope_exclude)
- Raw JSON: `d:/tmp/renar_anglicism_scan.json` (ephemeral)

## 9. Limitations & follow-ups

1. **Recall < 100%.** ~150 candidate terms; новые англицизмы вне списка не попали. Phase 2 может расширить список → re-run.
2. **Per-chapter, не §-section.** Granularity ограничена .md файлом; §-level density — Phase 5 при необходимости.
3. **Stem regex** ограничен ASCII-инфлектионными концовками; редкие падежные формы могут проскочить.
4. **Context-sensitivity.** «session» в §6 (substrate-capability V2) ≠ «session» в §13 (метрическая единица) — inventory эту разницу не различает; решение принимает Style Guide per memory #31 принцип 1.
5. **Re-run protocol** для Phase 5: copy scanner script + JSON в локальный sandbox, re-run после каждой главы → diff против baseline → подтвердить, что editorial pass снизил density.

