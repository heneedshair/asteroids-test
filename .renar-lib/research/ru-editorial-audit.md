---
title: "RU Editorial Audit — Phase 1 deliverable"
status: frozen
phase: "Phase 1 deliverable → Phase 2 Style Guide input"
epic: ru-normative-pass-v1
task: ru-audit-document
scan-date: 2026-05-15
sources: 3
lang: ru
---

# RU Editorial Audit

> **Phase 1 deliverable.** Синтез трёх preceding Phase 1 audit'ов в единый prioritized editorial-audit для epic `ru-normative-pass-v1`.
> Не является normative artifact и не предписывает Phase 2 decisions. Frozen после publish.

## 1. Executive summary

### 1.1 Corpus-level метрики

| Метрика | Значение | Источник |
|---|---:|---|
| Файлов прочитано | 34 | `ru-anglicism-inventory.md` §3 |
| Prose-слов (после strip) | 50 649 | `ru-anglicism-inventory.md` §3 |
| Уникальных anglicism-terms | 105 | `ru-anglicism-inventory.md` §3 |
| Total anglicism occurrences | 3 263 | `ru-anglicism-inventory.md` §3 |
| Bare `§X.Y` cross-refs | 416 (33%) | `ru-style-inconsistencies.md` §3.2 |
| Untagged code-fences | 77 (39%) | `ru-style-inconsistencies.md` §3.3 |
| Glav прочитанo end-to-end | 4 (12% корпуса) | `ru-tone-sampling.md` §2 |
| Sister-audits скоммитчено | 3 | commits `6b1a9dd`, `b00d635`, `b3d4bde` |

### 1.2 Top-3 systemic findings

🔴 **(F1) Terminological drift `reference/01-glossary.md` ↔ `standard/03-terms.md`.** Glossary использует pre-v1.0 imenoвания (QG-N Context/Requirements/Implementation/Verification, плюс TM/UIC/AIC/INT-SR/INT-TC/TS как canonical), которые `standard/03-terms.md §3.14.1` явно депрекейтит. Это **ровно тот класс drift'а** (§3.11.5 terminological drift), который сам стандарт нормит. Глоссарий, противоречащий canonical-нормативу, теряет роль reference. Origin: tone audit §3.4 + §5 findings #1-3.

🔴 **(F2) RFC-2119 keyword regime несогласован.** 15 EN UPPERCASE (MUST/SHALL) в 3 файлах (преимущественно MVR-таблица standard/00 §0.5 + descriptive ref в reference/04) vs 261 RU lowercase «должен/следует/может» в остальном корпусе. RU UPPERCASE convention (`ОБЯЗАН/ДОЛЖЕН`) **0 occurrences** — отсутствует полностью. Style Guide должен зафиксировать одно из 3 решений: keep mixed / migrate all → RU uppercase / migrate all → RU lowercase. Origin: style-inconsistencies §3.1.

🔴 **(F3) Citation / fence convention нет.** 416 bare `§X.Y` ссылок без markdown link wrapper (33% всех cross-refs) + 77 fence-блоков без language tag (39% всех fences) — PDF/HTML без syntax highlighting + не clickable cross-refs. `standard/01-scope.md` лидер: 69 bare §-refs; `guide/01-walkthrough.md`: 20 untagged fences. Origin: style-inconsistencies §3.2 + §3.3.

### 1.3 Phase 2 readiness statement

**Готов к Phase 2 при условии разрешения F1.** F2-F3 — Style Guide decisions; F1 — content-correction prerequisite, потому что Style Guide будет ссылаться на glossary для terminology references; пока glossary drift активен — Style Guide унаследует drift.

**Рекомендация:** добавить Phase 1.5 reconciliation task (`ru-reconcile-glossary-vs-standard`) перед Phase 2 (см. §6 Risk register, R4).

## 2. Sources

Три preceding Phase 1 audit'а, скоммитчены в `research/`:

| # | Audit | Type | File | Commit | Lines |
|---|---|---|---|---|---:|
| 1 | Anglicism inventory | Lexical (mechanical) | `research/ru-anglicism-inventory.md` | `6b1a9dd` | 351 |
| 2 | Style inconsistencies | Structural (mechanical) | `research/ru-style-inconsistencies.md` | `b00d635` | 317 |
| 3 | Tone sampling | Qualitative (end-to-end) | `research/ru-tone-sampling.md` | `b3d4bde` | 270 |

Все три audit'а имеют unified frontmatter (status:frozen, phase:Phase 1 → Phase 2, epic:ru-normative-pass-v1) и AC mapping. Этот document — их prioritized aggregation, не их replacement.

**Completeness check (AC #10):** все findings из §4 этого document'а имеют origin-pointer в один из 3 source-audit'ов. Findings, не вошедшие в §4 (low-priority/redundant), остаются доступны в source-audit'ах.

## 3. Per-chapter density синтез

Combining anglicism density (per 1000 words) + bare §-refs + untagged fences per file. Top-10 density-hot chapters:

| # | File | Anglicism /1k | Bare §-refs | Untagged fences | Combined priority |
|---|---|---:|---:|---:|---|
| 1 | `standard/01-scope.md` | 90.1 | 69 | 0 | 🔴 **High** — двойной hot (lexical + citation) |
| 2 | `standard/11-substrate-versioning.md` | 93.4 | n/a | 0 | 🔴 High — lexical (substrate domain) |
| 3 | `standard/10-lifecycle-qg.md` | 80.1 | 35 | 6 | 🔴 High — все три оси hot |
| 4 | `guide/03-tool-guide-git.md` | 103.9 | 0 | 0 | 🟠 Mid — lexical only (tool-guide expected) |
| 5 | `standard/13-metrics.md` | 59.7 | 48 | 0 | 🟠 Mid — citation hot |
| 6 | `standard/03-terms.md` | 74.2 | 39 | 2 | 🟠 Mid — citation hot (но terminology chapter — expected refs) |
| 7 | `standard/14-conformance.md` | 68.4 | 38 | 0 | 🟠 Mid — citation hot |
| 8 | `guide/01-walkthrough.md` | 71.0 | 0 | 20 | 🟠 Mid — fence-hot (walkthrough — много structural snippets) |
| 9 | `guide/00-quickstart.md` | 72.8 | 0 | 3 | 🟢 Low |
| 10 | `standard/00-introduction.md` | 86.2 | 21 | 0 | 🟢 Low — lexical hot но short chapter |

**Канонические voice candidates (tone-sampling §4.1):**

| Chapter type | Canonical exemplar | Style baseline для Phase 5 |
|---|---|---|
| Terminology-heavy | `standard/03-terms.md` | Pithy definitions, cross-ref to detail |
| Normative-heavy | `standard/10-lifecycle-qg.md` | Formal-normative tone, но trim density |
| Explanatory guide | `guide/01-walkthrough.md` | Phase 0..9 narrative arc, trim CLI verbosity |
| Reference catalog | `standard/03-terms.md` (NOT `reference/01-glossary.md` — drift) | Pithy tables, post-F1-resolution |

## 4. Aggregate prioritized findings (25)

Unified priority: 🔴 High = blocking Phase 5 chapter pass; 🟠 Mid = needed; 🟢 Low = polish.

Origin-tags: [L]=anglicism (lexical), [S]=style (structural), [T]=tone (qualitative).

### 🔴 High — block Phase 5

| # | Origin | Finding | File:§ | Phase 2 decision-needed |
|---|---|---|---|---|
| 1 | [T] | Glossary terminological drift — TM/UIC/AIC/INT-SR/INT-TC/TS treated as canonical | `reference/01-glossary.md` §2.1 | Reconciliation: replace legacy labels с canonical v1.0 per `standard/03-terms.md` §3.14.1 mapping |
| 2 | [T] | Glossary uses pre-v1.0 QG-N names (Context Gate / Requirements Gate / Implementation Gate / Verification Gate / Acceptance Gate) | `reference/01-glossary.md` §2.4, §3 | Replace с canonical (Approval/Implementation/Verification/Architecture/Acceptance) per `standard/03-terms.md` §3.14.1 |
| 3 | [T] | Glossary marked «1.0-draft (Phase 7 наполнение)» с open-questions list | `reference/01-glossary.md` §5 | Decide: finalize до v1.0 или explicitly mark non-normative |
| 4 | [S] | RFC-2119 mixed regime — 15 EN UPPERCASE (3 файла) vs 261 RU lowercase | `standard/00` §0.5 MVR, `standard/01`, `reference/04` | Pick one: keep mixed / migrate all → RU UPPERCASE / migrate all → RU lowercase |
| 5 | [S] | 416 bare `§X.Y` cross-refs без markdown link wrapper (33% всех refs) | top: `standard/01` (69), `standard/13` (48), `standard/03` (39) | Decide convention: intra-file bare OK / cross-file requires link / whitelist TOC-style sections |
| 6 | [S] | 77 untagged code-fences (39%) — broken syntax highlighting | top: `guide/01` (20), `guide/08` (13), `standard/06` (7) | Whitelist allowed tags (yaml/bash/cypher/markdown/json/python/sql/text); add missing tags |

### 🟠 Mid — needed для Phase 5 quality

| # | Origin | Finding | File:§ | Phase 2 decision-needed |
|---|---|---|---|---|
| 7 | [L] | `имплементация` (52 occurrences) — calque с native RU equivalent | spread | Decide: rewrite → реализация / keep |
| 8 | [L] | `frontmatter` (178) — latin canonical но frequent в prose | spread | Decide: keep latin / «заголовочный блок» / mixed (latin in code-context, RU in prose) |
| 9 | [L] | `manifest` (124) — latin in prose | top: `standard/14` (31), `standard/00` (14) | Decide: keep / «манифест» / «декларация соответствия» |
| 10 | [L] | `review` (104), `audit` (89), `draft` (79), `scope` (92), `policy` (27) — organisational vocabulary | spread | Bucket C decisions: rewrite candidates per `ru-anglicism-inventory.md` §6.3 |
| 11 | [L] | Status-vocabulary `proposed/approved/verified/obsolete/frozen` — Bucket B | YAML + prose | Decide: all latin / all RU translit |
| 12 | [L] | `conformance` (124, частично within manifest) — нормативный термин ISO | `standard/14` heavy | Likely keep (ISO term), но prose explicitly link to definition |
| 13 | [S] | 152 inline «глав* X» без markdown link | spread | Convert to `[глава X](file.md)` где cross-file |
| 14 | [S] | Plain headings dominate в 6 файлах guide/+reference/+core/ vs dotted-number в standard/ | `guide/00`, `guide/03`, `guide/08`, `reference/02-03`, `core/renar-core` | Endorse split (standard/ numbered, guide/+reference/+core/ plain) или унифицировать |
| 15 | [T] | `standard/10` §10.11.3 «Change-of-criteria для TC» — densest legalese | `standard/10` §10.11.3 | Phase 5: trim to 3 sentences + bullet, preserve normative semantic |
| 16 | [T] | `standard/10` §10.12 + §10.13.1 — 13-row + 10-row dense tables | `standard/10` | Phase 5: split into multi-line cells for PDF readability |
| 17 | [T] | «Pre-condition / Post-condition / Триггер» — section-label anglicism cluster | `standard/10` §10.3.x | Phase 2: keep / «Предусловие / Постусловие / Триггер» / «Предусловие / Постусловие / Запуск» |
| 18 | [T] | Mixed-lang «корпоративный admin» | `guide/01` §1.1 line ~64 | Phase 5: → «корпоративный администратор» или \`admin\` (code-format) |
| 19 | [T] | `guide/01` Phase 3.4 — 50-line SR-01 frontmatter+body fence | `guide/01` Phase 3.4 | Phase 5: split into 2 fences (frontmatter / body) с одной prose sentence между |

### 🟢 Low — polish

| # | Origin | Finding | File:§ | Phase 2/5 action |
|---|---|---|---|---|
| 20 | [L] | `артефакт` (455), `нормативный` (275), `автор`/`шаблон`/`репозиторий` — accepted RU IT терминология | spread | Bucket D (keep, проверить overuse density > 3%) |
| 21 | [S] | 100% bullet consistency (842 `-`, 0 `*`/`+`) + 100% table alignment-less (`---`) | all 232 tables, 842 bullets | Endorse de-facto convention в Style Guide §X |
| 22 | [S] | 0 heading depth jumps (monotonic across corpus) | all 1012 headings | Endorse de-facto convention |
| 23 | [S] | 98 «см.» (RU) vs 0 «see» (EN) — consistent | spread | Endorse: RU only |
| 24 | [T] | `standard/03` §3.2 — «canonical» использован 15+ раз в RU prose | `standard/03` §3.2 | Phase 5: оставить в principle-defining position, reduce repetition |
| 25 | [T] | `guide/01` Phase 7.1 — verbatim CI dump 11 строк после pattern уже установлен | `guide/01` Phase 7.1 | Phase 5: trim до 3 lines + «… (см. полный output в research/example-runs/)» |

## 5. Phase 2 Style Guide — decision-points

Style Guide (`reference/06-ru-style-guide.md`, planned) обязан зафиксировать canonical convention для каждой оси. Этот раздел — input checklist, **не** prescriptive.

### 5.1 Terminology (lexical)

- **Bucket A (technical identifiers, keep latin):** Whitelist `commit/merge/diff/hook/branch/push/pull/frontmatter/manifest/slug/hash/trigger/runner/pipeline/release/deploy/build/patch/workflow/linter/parser/compiler/tooling/tracker`, plus capability-level `immutable/atomic/drift/provenance`. Decision-needed: phrasing of whitelist (allow-list vs deny-list).
- **Bucket B (status-vocabulary):** `proposed/approved/verified/obsolete/frozen/active/planning/blocked/review` — pick one regime (all latin matches YAML literally vs all RU for prose readability).
- **Bucket C (organisational, rewrite candidates):** `scope/audit/draft/policy/ownership/default/bypass/rollback/fallback/override/stub/guide` — decide per-term замена.
- **Bucket D (accepted кальки):** `реализация/нормативный/формальный/опциональный/атомарный/спецификация/декомпозиция/композиция/...` — keep, проверить overuse.
- **Bucket E (rewrite-кальки):** `имплементация → реализация`, `конформация → соответствие` (но `conformance` = ISO term, keep там), `эссенциальный → существенный/обязательный`, `дрифт → дрейф/расхождение`.
- **Bucket F (translit mixed):** keep: `артефакт/автор/шаблон/репозиторий`. Borderline: `ревью/кейс/стейкхолдер/гейт/чекпойнт/онбординг`. Rewrite low-count: `фронтенд/бэкенд/пайплайн/фолбэк/оверхед/апдейт`.

### 5.2 RFC-2119 (structural)

- **Pick one regime for normative keywords:** (1) EN UPPERCASE everywhere (matches ISO 29148, breaks RU readability); (2) RU UPPERCASE (`ОБЯЗАН/ДОЛЖЕН/...`, currently 0 occurrences); (3) RU lowercase (`должен/следует/может`, currently 261 dominant).
- **MVR-table в `standard/00-introduction.md` §0.5** — fix point of decision (10 SHALL there). Решение по MVR определяет regime для остального корпуса.
- **`reference/04-ai-style-guide.md` line 171** — meta-reference (mentions RFC 2119 vocabulary); separately note non-normative usage in Style Guide.

### 5.3 Citations (structural)

- **Bare `§X.Y` policy:** intra-file bare OK / cross-file requires markdown link / all-marked / whitelist (TOC, footnotes, prefix patterns).
- **Inline «глав* X»** (152 occurrences) — convert to `[глава X](file.md)` где cross-file?
- **Anchor-only links `[…](#…)`** (86 occurrences) — endorse vs document когда допустим.

### 5.4 Code-fences (structural)

- **Whitelist allowed lang tags:** `yaml/bash/cypher/markdown/json/python/sql/text` — endorse?
- **Convention для plain-text fragments** (tree fragments, output dumps): `text` или no-lang allowed?
- **Convention для structural markdown examples внутри docs:** lang `markdown` vs нет?

### 5.5 Headings (structural)

- **Numbering split:** standard/ numbered (`## 6.2.1`), guide/+core/+reference/ plain (`## Что вы получите`) — endorse current split, или унифицировать?
- **Max depth:** ban H4? (Only 3 occurrences globally; trivial.)

### 5.6 Tables/lists (structural)

- **Endorse de-facto:** all `-` bullets (842 occurrences, 0 mixed), all alignment-less (`---`) tables (100% consistency).

### 5.7 Tense / mood (qualitative)

- **Normative clauses:** «X должен Y» (imperative-mood) vs «X выполняет Y» (present indicative) — pick one.
- **Definitions:** «X — это Y» vs «X является Y» — pick one. (`standard/03-terms.md` мостly uses «X — Y, нормированное Z».)
- **Future tense (`будет/будут`, 15 occurrences):** allow только в forward-looking sections?

### 5.8 Tone / voice (qualitative)

- **Canonical voice per chapter type** — endorse §3 candidates:
  - terminology → `standard/03-terms.md` exemplar
  - normative → `standard/10-lifecycle-qg.md` exemplar (post-density-trim)
  - explanatory guide → `guide/01-walkthrough.md` exemplar
  - reference catalog → `standard/03-terms.md` exemplar (post-F1-resolution)
- **AI-bias guard (memory #31 принцип 8):** Style Guide §X.Y фиксирует human spot-check requirement для editorial pass (LLM trained on English skewes lexical decisions).

## 6. Phase 5 chapter pass — recommended priority order

Priority basis: combined hot-axes from §3 table + drift severity from §4.

| Order | Chapter | Reason | Estimated pass cost |
|---:|---|---|---|
| 1 | `reference/01-glossary.md` | F1+F2+F3 (Phase 1.5 prerequisite — Style Guide depends on synced glossary) | High (terminology reconciliation, не editorial) |
| 2 | `standard/01-scope.md` | Triple hot: 90.1 lexical + 69 bare §-refs | Medium-High |
| 3 | `standard/11-substrate-versioning.md` | Highest density (93.4 /1k); substrate-domain technical | Medium |
| 4 | `standard/10-lifecycle-qg.md` | All three axes hot + §10.11.3/§10.12 density issues (T15-T16) | High (density-reduction critical) |
| 5 | `standard/13-metrics.md` | 48 bare §-refs + 59.7 lexical | Medium |
| 6 | `standard/14-conformance.md` | 38 bare §-refs + mandatory clauses dense | Medium |
| 7 | `standard/03-terms.md` | Canonical voice exemplar (used as Phase 5 reference); only minor polish | Low (already canonical) |
| 8 | `guide/01-walkthrough.md` | T7-T8 trim + 20 untagged fences | Medium |
| 9 | `guide/03-tool-guide-git.md` | Highest guide lexical (103.9 /1k) но domain-specific | Low (mostly acceptable per Bucket A) |
| 10+ | All other chapters | Apply Style Guide; spot-check density reduction | Variable |

**Critical: Phase 5 не запускается без (a) F1-F3 resolved, (b) Phase 2 Style Guide approved, (c) Phase 3 pilot checkpoint approved (memory #31 принцип 3).**

## 7. Risk register

Что может сломаться при некачественной editorial pass.

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | **Lost normative semantic.** Editorial pass меняет «должен» → «следует» (от-RFC-2119 — strict to recommendation). Меняет MUST/SHALL→ may. | 🔴 Critical | Memory #31 принцип 2: если правка меняет MUST/SHALL/SHOULD/MAY — это **content change**, отдельная задача. Style Guide §X явно фиксирует normative-keyword strict semantics. |
| R2 | **Broken cross-refs.** Mass conversion bare §-refs → links вводит typos / dead links. | 🟠 High | Quality signal §6 memory #31: `node scripts/validate-frontmatter.js` + cross-ref dead-link scan после каждой главы. |
| R3 | **Scope creep.** Editorial задача начинает «исправлять» content (architecture decisions, examples). | 🟠 High | Memory #31 принцип 7: каждая глава перечитывается end-to-end перед commit; principles 2+7 строго separated. Scope_exclude в task definition. |
| R4 | **Glossary drift propagation.** Если F1-F3 не resolved до Phase 2 — Style Guide inherits drift, references устаревшие labels. | 🔴 Critical | Phase 1.5 reconciliation task **prerequisite** для Phase 2. Без неё Style Guide может содержать TM/UIC/AIC, что становится canonical → дрифт усиливается. |
| R5 | **AI-bias creep.** LLM editorial agent склонна вписывать anglicism, даже когда Style Guide запрещает. | 🟠 High | Memory #31 принцип 8: каждая editorial правка проверяется по Style Guide checklist. Subagent invocations с reference на Style Guide §X в prompt. |
| R6 | **PDF/HTML render regression.** Crowd-sourced editorial changes ломают heading anchors / table syntax. | 🟢 Mid | Quality signal §6 memory #31: diff visualization после каждой главы; word-count delta sanity-check (не должен schrumpfen / inflate). |
| R7 | **Pilot checkpoint skipped.** Phase 5 запускается без Phase 3 user-validated pilot diff. | 🔴 Critical | Memory #31 принцип 3: Phase 3 pilot — критический gateway. Style Guide §X фиксирует. |
| R8 | **Bulk find-replace.** «session» в §6 (substrate-capability V2) != «session» в §13 (метрическая единица). | 🟠 High | Memory #31 принцип 1: no mass find-replace. Каждое term-decision контекстуальное. Phase 5 chapter pass — 1 chapter = 1 commit. |

## 8. AC mapping

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Artifact в `research/` | этот файл (`research/ru-editorial-audit.md`) |
| 2 | Cross-link на 3 source-документа | §2 sources table + intro callout |
| 3 | Executive summary | §1 — corpus метрики + top-3 systemic findings F1-F3 + readiness statement |
| 4 | Aggregate prioritized findings ≥25 entries | §4 — 25 entries (6🔴 + 13🟠 + 6🟢), unified priority, Phase 2 decision-needed flag |
| 5 | Phase 2 Style Guide input | §5 — decision-points для 8 осей (terminology / RFC-2119 / citations / fences / headings / tables-lists / tense / tone) |
| 6 | Phase 5 chapter pass priority order | §6 — 10-row table с reason + estimated cost |
| 7 | Risk register | §7 — 8 risks с severity + mitigation, hooked в memory #31 принципы |
| 8 | Read-only invariant | git status: только новый `research/ru-editorial-audit.md` |
| 9 | Frozen frontmatter | YAML: `status: frozen`, `phase: Phase 1 deliverable → Phase 2 input`, `epic` |
| 10 | Completeness check (no cherry-pick) | §2 «Completeness check» note: каждый finding в §4 имеет origin-pointer; non-included findings остаются в source-audit'ах |
| 11 | No overstatement (не prescriptive) | §4 column header «Phase 2 decision-needed»; §5 явный disclaimer «input checklist, не prescriptive»; §6 «Phase 5 не запускается без…» — не prescribes Phase 2 |

## 9. Limitations & follow-ups

1. **Coverage:** Tone audit sampled 12% corpus (4/34). Lexical + structural audits — 100% corpus. Phase 5 chapter pass обеспечит remaining 88% tone coverage.
2. **Single-reviewer bias:** все 3 audit'а produced LLM (Claude Opus 4.7). Phase 2 human spot-check обязателен (memory #31 принцип 8 + tone-audit §9.1).
3. **Phase 1.5 reconciliation task (`ru-reconcile-glossary-vs-standard`) НЕ создан этой задачей.** Recommendation surfaced в §1.3 + R4; user-decision pending whether to create as separate task before Phase 2.
4. **Decision-points в §5 не exhaustive.** Phase 2 Style Guide может surface дополнительные decision-points при детальной проработке.
5. **Re-run protocol для Phase 5:** все 3 scanners (anglicism, style, tone-sample) можно re-run после каждой обработанной главы для density-delta confirmation. Scripts остались ephemeral в `d:/tmp/`.

## 10. Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Source audits:
  - `research/ru-anglicism-inventory.md` (commit `6b1a9dd`)
  - `research/ru-style-inconsistencies.md` (commit `b00d635`)
  - `research/ru-tone-sampling.md` (commit `b3d4bde`)
- Session #13 handoff: pushback «пестрит англицизмами», начало Phase 1
- Phase 1 epic-progress: 4/4 audit-задач завершены этим document'ом
