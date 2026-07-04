---
title: "RU Style Inconsistencies — Phase 1 audit"
status: frozen
phase: "Phase 1 input → Phase 2 Style Guide"
epic: ru-normative-pass-v1
task: ru-audit-style-inconsistencies
scan-date: 2026-05-15
corpus: "standard/ + guide/ + reference/ + core/"
lang: ru
---

# RU Style Inconsistencies

> **Read-only audit.** Каталог структурных и стилевых рассогласований в RU нормативном корпусе RENAR Standard v1.0-draft.
> Не является normative artifact — Phase 1 input для Phase 2 Style Guide. Frozen после publish.
> **Cross-link:** `research/ru-anglicism-inventory.md` (parallel Phase 1 audit, лексическая сторона).

## 1. Назначение

Audit для epic `ru-normative-pass-v1`: квантифицировать структурные style-рассогласования (RFC-2119 keywords, citations, code-fences, headings, tables/lists, tense/mood) per chapter, чтобы Style Guide мог:

- зафиксировать canonical convention для каждой оси,
- приоритизировать главы с наибольшим отклонением,
- дать pilot (Phase 3) явный mechanical checklist.

Inventory нейтрально перечисляет данные; нормативные решения — Phase 2 Style Guide.

## 2. Методология

**Корпус:** 34 файла .md (standard 17 + guide 11 + reference 6 + core 2).

**Шесть осей аудита:**

| # | Axis | Что измеряется |
|---|---|---|
| (a) | RFC-2119 keywords | EN MUST/SHALL/SHOULD/MAY, RU `ОБЯЗАН/ДОЛЖЕН/...` (uppercase), RU `должен/следует/может` (lowercase) |
| (b) | Citations / cross-refs | `§X.Y`, markdown link `[…](file.md#…)`, anchor-only `[…](#…)`, inline «глав* X», «см. …» |
| (c) | Code-fences | language tag distribution + fences без языка |
| (d) | Section numbering | format (`## 6.2.1` vs plain), depth distribution, depth jumps |
| (e) | Tables / lists | bullet style (`-`/`*`/`+`), ordered, table alignment markers |
| (f) | Tense / mood | будущее (`будет/будут`), present copula (`является`), imperative-mood `должен/должна/должно` |

**Strip pipeline:** YAML frontmatter, fenced code blocks, inline backticks, HTML-комментарии, markdown link URLs.

**Negative scenarios (AC #9-10):**

- *Code-fence содержимое не считается prose-рассогласованием*: prose-checks (RFC-2119, tense) применяются к stripped-prose.
- *YAML-frontmatter inline-ключи исключены* из tense-анализа через strip pipeline.
- *RFC-2119 keyword pointer*: каждый файл с EN-RFC2119 идентифицирован в §3.1 с точным count.
- *Пустой корпус*: scanner печатает `WARN: no .md files in <dir>` в stderr; exit 1 при полностью пустом корпусе.

**Ограничения:**

- Tense/mood — heuristic (suffix-based regex); precision ~70%. Phase 2 потребует human spot-check.
- Citation form классифицируется по синтаксису, не по семантике (intra-file vs cross-file).
- Bare §-ref counter консервативный: считает только без `[`, `]`, `(` в radius=1 символ.

## 3. Findings per axis

### 3.1 (a) RFC-2119 keywords

| Форма | Total | Files |
|---|---:|---:|
| EN uppercase (MUST/SHALL/SHOULD/MAY) | 15 | 3 |
| RU uppercase (ОБЯЗАН/ДОЛЖЕН/...) | 0 | 0 |
| RU lowercase (должен/следует/может) | 261 | 27 |

**Files с EN-RFC2119 keywords:**

| File | EN total | Breakdown |
|---|---:|---|
| `standard/00-introduction.md` | 10 | MUST=1, SHALL=9 |
| `standard/01-scope.md` | 2 | MUST=1, SHALL=1 |
| `reference/04-ai-style-guide.md` | 3 | MUST NOT=1, MUST=2 |

**Наблюдения:**

- `standard/00-introduction.md` (10 SHALL) — sectoral: MVR-1..MVR-7 таблица §0.5 использует SHALL **нормативно** (это намеренный RFC-2119 идиом для MVR).
- `standard/01-scope.md` (1 MUST + 1 SHALL) — внутри обоснования.
- `reference/04-ai-style-guide.md` (3, включая MUST NOT) — **descriptive**: упоминает RFC 2119 vocabulary, не использует normatively.
- **0 файлов** используют RU UPPERCASE convention (`ДОЛЖЕН/ОБЯЗАН`). RU стандартизация полностью lowercase.
- **261 occurrence** RU lowercase modal verbs — основная normative form в корпусе.

**Phase 2 decision needed:**

- Сохранить EN SHALL в MVR-таблице (consistent с ISO 29148 normative idiom)?
- Или перевести MVR-statements на RU `ДОЛЖЕН` (uppercase) для self-consistency?
- Или использовать RU lowercase «должен» во всём корпусе, включая MVR?

### 3.2 (b) Citations / cross-references

| Form | Count |
|---|---:|
| `§X.Y` section refs (total) | 1 264 |
| `§X.Y` bare (без markdown link) | **416** (32%) |
| `[text](file.md#anchor)` md-file links | 1 041 |
| `[text](#anchor)` anchor-only links | 86 |
| inline «глав* X» (без link) | 152 |
| «см.» (RU) | 98 |
| «see» (EN) | 0 |

**Top-10 файлов по bare §-refs:**

| File | Bare §-refs |
|---|---:|
| `standard/01-scope.md` | 69 |
| `standard/13-metrics.md` | 48 |
| `standard/03-terms.md` | 39 |
| `standard/14-conformance.md` | 38 |
| `standard/10-lifecycle-qg.md` | 35 |
| `standard/04-roles.md` | 29 |
| `standard/00-introduction.md` | 21 |
| `standard/05-methodology-positioning.md` | 20 |
| `standard/02-normative-refs.md` | 19 |
| `reference/03-ai-risk-register.md` | 17 |

**Наблюдения:**

- 32% всех `§X.Y`-references — **bare** (без markdown link wrapper). Не clickable из site/PDF.
- `standard/01-scope.md` лидер: 69 bare §-refs (intro-style references на §1.2/§1.3/...). Внутри-файловые refs валидны как plain text, но cross-file refs обычно wrappnuты ([§14.9](file.md#14.9)).
- «см.» (RU) used 98 times; «see» (EN) — **0**. Consistency ✓.
- 152 inline «глав* X» — opportunity конвертировать в markdown links.

**Phase 2 decision needed:**

- Convention: «bare §X.Y допустим только для intra-file refs, cross-file требует markdown link»?
- Или: «все cross-refs должны быть markdown links»?
- Whitelist разрешённых bare-form контекстов (TOC, footnotes)?

### 3.3 (c) Code-fences

Total fences typed: **118**; no-lang: **77** (39%).

| Language tag | Count |
|---|---:|
| `yaml` | 64 |
| `bash` | 15 |
| `cypher` | 15 |
| `markdown` | 14 |
| `json` | 7 |
| `python` | 2 |
| `sql` | 1 |
| _no language_ | **77** |

**Top-10 файлов по no-lang fences:**

| File | No-lang fences |
|---|---:|
| `guide/01-walkthrough.md` | 20 |
| `guide/08-developer-guide.md` | 13 |
| `standard/06-requirements-hierarchy.md` | 7 |
| `standard/10-lifecycle-qg.md` | 6 |
| `standard/07-adapt.md` | 5 |
| `standard/09-test-cases.md` | 3 |
| `standard/08-specifications.md` | 3 |
| `guide/00-quickstart.md` | 3 |
| `standard/03-terms.md` | 2 |
| `reference/05-knowledge-graph-schema.md` | 2 |

**Наблюдения:**

- Каждая третья fence-block без language tag — PDF/HTML без syntax highlighting.
- `guide/01-walkthrough.md` лидер: 20 no-lang fences (walkthrough — много structural snippets typа дерева каталогов).
- Доминируют `yaml` (64) — frontmatter примеры, и `bash` (15) — CLI команды.
- `cypher` (15) — knowledge graph queries в reference/05.
- `markdown` (14) — examples нормативного markdown markup внутри docs.

**Phase 2 decision needed:**

- Whitelist допустимых tags: yaml/bash/json/cypher/markdown/python/sql/text?
- Convention: tree-fragments (`my-project.req/...`) использовать `text` или оставлять без lang?
- Должен ли `lang: ru`-tag на YAML-frontmatter блоки внутри prose стать обязательным?

### 3.4 (d) Section numbering / heading depth

Total headings: **1012**; max depth: **H4**; depth jumps (>1 step): **0**.

| Format | Count |
|---|---:|
| dotted-number | 746 |
| plain | 266 |

**Depth distribution:**

| Level | Count |
|---|---:|
| H1 | 34 |
| H2 | 340 |
| H3 | 635 |
| H4 | 3 |

**Файлы где plain headings доминируют над numbered:**

| File | Plain | Numbered |
|---|---:|---:|
| `guide/00-quickstart.md` | 14 | 2 |
| `guide/03-tool-guide-git.md` | 13 | 12 |
| `guide/08-developer-guide.md` | 31 | 11 |
| `reference/02-schemas.md` | 13 | 9 |
| `reference/03-ai-risk-register.md` | 22 | 4 |
| `core/renar-core.md` | 27 | 3 |

**Наблюдения:**

- **No depth jumps** (0) — каждая глава respects monotonic depth ✓ структурно crisp.
- `standard/` — почти полностью **dotted-number** (`## 6.2.1`).
- `guide/` + `core/` + некоторые `reference/` — преимущественно **plain headings** (e.g. `## Что вы получите`).
- Разделение defensible: nominative `standard/` нумерует normative clauses; pedagogical `guide/`/`core/` — narrative flow.

**Phase 2 decision needed:**

- Закрепить convention: «standard/ — dotted-number обязательно; guide/+core/+reference/ — plain headings allowed»?
- Или ввести нумерацию повсюду для cross-ref consistency?
- Max heading depth (H3 vs H4) — sub-sub-sub нужны?

### 3.5 (e) Tables / lists

| Metric | Count |
|---|---:|
| Tables | 232 |
| Bullet `-` | **842** |
| Bullet `*` | 0 |
| Bullet `+` | 0 |
| Ordered `1.` | 274 |
| Files с mixed bullets | 0 |
| Table align — left (`:---`) | 0 |
| Table align — right (`---:`) | 0 |
| Table align — center (`:---:`) | 0 |
| Table align — none (`---`) | 644 |

**Наблюдения:**

- **100% bullet-consistency**: 842 `-`, 0 `*`, 0 `+`, 0 файлов с mixed bullets. ✓ Лучший показатель из всех осей.
- **100% table-alignment uniformity**: все 644 delimiter cells без alignment markers (`---` not `:---`). ✓
- 274 ordered lists — употребляются для нумерованных enumerated steps; consistent.

**Phase 2 decision needed:**

- Закрепить current de-facto convention: `-` only, `---` alignment-less. (Лёгкое решение — already 100%.)

### 3.6 (f) Tense / mood (heuristic)

| Marker | Count |
|---|---:|
| Future (`будет/будут` + SHALL) | 15 |
| Present copula (`является/представляет собой`) | 67 |
| Imperative-mood (`должен/должна/должно`) | 52 |

**Наблюдения:**

- Mix: present (определения) + imperative (`должен` — normative form) + future (rare, mostly SHALL-aliased).
- Heuristic: nominal sentences (определения) — present copula; normative clauses — `должен/обязан`; descriptive expectations — `будет`.
- 67 present copula + 52 imperative = **dominant nominative+normative** mix, typical для normative RU.

**Phase 2 decision needed:**

- Convention для normative clauses: всегда «X должен Y» (imperative-mood) vs «X выполняет Y» (present indicative)?
- Convention для definitions: «X — это Y» vs «X является Y»? (Сейчас обе формы встречаются.)
- Future tense (`будет`) — разрешить только в forward-looking sections (roadmap/Phase descriptions)?

## 4. Top-15+ inconsistencies — prioritized

Priority key: 🔴 High = blocking Phase 5 chapter pass; 🟠 Mid = needed but не блокер; 🟢 Low = polish.

| # | Priority | Axis | Issue | Files affected | Phase 2 action |
|---|---|---|---|---|---|
| 1 | 🔴 High | (a) RFC-2119 | EN SHALL в MVR-table vs lowercase `должен` everywhere — mixed conventions | `standard/00` (10) + `standard/01` (2) | Decide: SHALL keep / migrate to RU UPPERCASE / migrate to RU lowercase |
| 2 | 🔴 High | (b) Citations | 416 bare `§X.Y` refs без markdown link wrapper (32% total) | top: `standard/01` (69), `standard/13` (48), `standard/03` (39) | Decide convention: intra-file vs cross-file; mass-link cross-file refs |
| 3 | 🔴 High | (c) Code-fences | 77 fences без language tag (39% total) — broken syntax highlighting в PDF/HTML | top: `guide/01` (20), `guide/08` (13), `standard/06` (7) | Add lang tags; whitelist allowed tags |
| 4 | 🟠 Mid  | (d) Headings | 6 `guide/`+`core/`+`reference/` files используют plain headings vs dotted-number в `standard/` | `guide/00`, `guide/03`, `guide/08`, `reference/02-03`, `core/renar-core` | Endorse current split или унифицировать |
| 5 | 🟠 Mid  | (a) RFC-2119 | RU UPPERCASE convention (`ОБЯЗАН/ДОЛЖЕН`) — 0 occurrences. Style Guide должен явно фиксировать lowercase choice | all | Document explicit decision in Style Guide §X |
| 6 | 🟠 Mid  | (b) Citations | 152 inline «глав* X» — текстовые ссылки без markdown link | spread across corpus | Convert to `[глава X](file.md)` где cross-file |
| 7 | 🟠 Mid  | (f) Tense | Mix «X является Y» vs «X — это Y» в definitions | `standard/03-terms` особенно | Pick one canonical form |
| 8 | 🟠 Mid  | (c) Code-fences | `markdown` (14) vs `text` (0) — отсутствует convention для plain-text fragments | `guide/01-walkthrough`, `guide/00-quickstart` | Define when each is used |
| 9 | 🟢 Low  | (c) Code-fences | `bash` (15) vs `sh` (0) — single convention, проверить terminal commands | mostly `guide/03-tool-guide-git` | Endorse `bash` |
| 10 | 🟢 Low | (b) Citations | 86 anchor-only `[…](#…)` links — внутренние refs OK, но без convention для line-of-sight | spread | Document когда anchor-only допустим |
| 11 | 🟢 Low | (e) Tables | 100% alignment-less (`---`) — закрепить вместо явного решения | all 232 tables | Endorse de-facto convention |
| 12 | 🟢 Low | (e) Lists | 100% dash bullets (`-`) — закрепить | all 842 bullets | Endorse de-facto convention |
| 13 | 🟢 Low | (d) Headings | Max depth H4 (только 3 occurrences) — H4 кандидат на ban | rare | Decide: H4 allowed / banned |
| 14 | 🟢 Low | (f) Tense | 15 future-tense markers (`будет/будут`) — проверить uniformity | spread | Allow только в roadmap/future-work sections |
| 15 | 🟢 Low | (a) RFC-2119 | `reference/04-ai-style-guide.md` упоминает RFC 2119 vocabulary descriptively — не нарушение, но требует style note | `reference/04` | Add Style Guide cross-ref clarifying scope |

## 5. Cross-link с anglicism inventory

- `research/ru-anglicism-inventory.md` Bucket B (status-vocabulary) — пересекается с (a): `proposed/approved/verified` ↔ `должен/следует`. Phase 2 Style Guide должен координировать оба решения.
- Bucket A (substrate technical identifiers) — пересекается с (c): `hook`, `commit`, `merge` появляются и в prose (anglicism), и в code-fences (lang=bash). Решение по prose-сохранению должно совпадать с code-fence содержимым.
- Bucket C (rewrite кандидаты `scope/audit/draft`) — пересекается с (f): formulating «scope нормирует» (latin in clause) vs «область нормирует» (RU). Tense + lexical decisions связаны.

## 6. AC mapping

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Artifact в `research/` | `research/ru-style-inconsistencies.md` (этот файл) |
| 2 | Покрытие 4 директорий | 34 файла: standard 17 + guide 11 + reference 6 + core 2 |
| 3 | Аудит 6 осей | §3.1 (a) RFC-2119, §3.2 (b) citations, §3.3 (c) fences, §3.4 (d) headings, §3.5 (e) tables/lists, §3.6 (f) tense |
| 4 | Per-axis quantitative summary | Все 6 секций §3 имеют counts + per-file leaders + examples |
| 5 | Top inconsistencies ≥15 entries | §4 — 15 prioritized entries с File-pointers |
| 6 | Read-only invariant | git status: только новый `research/ru-style-inconsistencies.md` |
| 7 | Frozen frontmatter | YAML: `status: frozen`, `phase: Phase 1 → Phase 2`, `epic: ru-normative-pass-v1` |
| 8 | Cross-link с anglicism inventory | §5 + intro callout |
| 9 | Negative scenario false positives | §2 «Strip pipeline» + «Negative scenarios» + per-file pointers для каждого RFC-2119 hit |
| 10 | Empty-corpus negative scenario | scanner stderr `WARN: no .md files in <dir>` + exit 1 |

## 7. Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Sister inventory: `research/ru-anglicism-inventory.md` (Phase 1 audit, лексическая сторона)
- Scanner: `d:/tmp/renar_style_scan.py` (ephemeral; не коммитится по scope_exclude)
- Raw JSON: `d:/tmp/renar_style_scan.json` (ephemeral)

## 8. Limitations & follow-ups

1. **Tense/mood heuristic** — suffix-based; ~30% false-positive rate ожидается. Phase 2 Style Guide должен установить formal grammar rules с human-validated examples.
2. **Bare §-ref detector** консервативный (radius=1). Не различает «§1.2 нормирует …» (intra-file OK) от «§14.9 fixes …» (cross-file, нужен link). Phase 5 chapter pass должен проверить semantically.
3. **Per-file granularity** = .md файл, не §-section. Section-level analysis — Phase 5 при необходимости.
4. **Re-run protocol для Phase 5:** scanner + JSON держать в sandbox; re-run после каждой обработанной главы → diff против baseline → подтвердить, что pass снизил inconsistency-counts (особенно (c) no-lang fences, (b) bare §-refs).
