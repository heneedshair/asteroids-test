---
title: "Style Guide §1 (draft): Terminology canonicalization rules"
status: draft
phase: "Phase 2 Style Guide §1 — compile в ru-style-lock"
epic: ru-normative-pass-v1
task: ru-style-terminology
draft-date: 2026-05-15
target-final-path: "reference/06-ru-style-guide.md (после compile в Phase 2 lock-in)"
lang: ru
---

# Style Guide §1: Terminology canonicalization rules (DRAFT)

> **Phase 2 draft.** Этот документ — рабочий черновик §1 будущего `reference/06-ru-style-guide.md`. Задача `ru-style-lock` (Phase 2 final) скомпилирует §1+§2+§3 в финальный normative artifact.
> Статус: **draft** — может быть скорректирован Phase 3 pilot checkpoint feedback.
> Cross-link: `research/ru-editorial-audit.md` (Phase 1 deliverable), `research/ru-anglicism-inventory.md`, `research/ru-style-inconsistencies.md`, `research/ru-tone-sampling.md`.

## §1.0 Назначение

§1 фиксирует **canonical terminology rules** для RU normative корпуса RENAR Standard. Регламентирует:

- какие термины остаются латиницей (`commit`, `frontmatter`),
- какие — кальками с RU инфлекцией (`реализация`, `спецификация`),
- какие — транслитом (`артефакт`, `репозиторий`),
- какие — нативно-русскими (`область применения` вместо `scope`),
- какие — устарели и требуют canonical замены (`UIC → SPEC-UI`).

§1 — **normative** часть Style Guide. Phase 5 chapter pass обязан валидировать соответствие §1 при правке каждой главы (см. [§1.13 Validation](#113-validation)).

## §1.1 Принципы

Шесть нормативных принципов §1, обязательные для применения Style Guide:

### §1.1.1 No mass find-replace

Каждое term-decision контекстуальное. Пример: `session` в [`standard/06`](../standard/06-requirements-hierarchy.md) (substrate-capability V2 — atomic change unit context) — это технический identifier, остаётся латиницей. `session` в [`standard/13`](../standard/13-metrics.md) (метрическая единица, e.g. «session duration») — может быть переведено («длительность сеанса»). Слепая поиск-замена ломает нормативный смысл.

**Применение:** Phase 5 chapter pass — 1 chapter = 1 commit = 1 review (memory #31 принцип 5). Bulk find-replace инструменты запрещены.

### §1.1.2 Preserved normative semantic

Если правка терминa меняет MUST/SHALL/SHOULD/MAY semantics (RFC-2119 §2), normative MVR clauses, closed-list policy — это **content change**, требует отдельной задачи с явным rationale, не editorial. Editorial задача §1-§3 правит **только форму**, не содержание.

**Применение:** Style Guide §2 (RFC-2119 wording) — pure form-level convention; semantic preservation guaranteed by §1.1.2.

### §1.1.3 AI-bias guard

LLM-агент trained on web English склонна вписывать anglicism (имплементация / эссенциальный / латинизмы в prose) и tolerate их в editorial review. Style Guide применяется через **explicit checklist** + human spot-check, не через «выбор того, что нормально звучит».

**Применение:** каждая editorial правка Phase 5 проходит human spot-check на random sample (memory #31 принцип 8). Subagent invocations передают Style Guide §1 как primary policy в prompt.

### §1.1.4 Closed list canonical terms

§1.9 фиксирует closed list canonical RENAR terms. Добавление новых — только через formal change procedure стандарта (mirrors [`standard/01-scope.md §1.7`](../standard/01-scope.md#1.7) closed list policy).

**Применение:** project-local создание новых canonical terms запрещено. Synonyms допустимы как pedagogical aid (UI projection, see [`standard/03 §3.13.3`](../standard/03-terms.md#3.13.3)).

### §1.1.5 Single source of truth для terminology

Canonical normative источник: [`standard/03-terms.md`](../standard/03-terms.md). Reference-катало g [`reference/01-glossary.md`](../reference/01-glossary.md) обязан быть синхронизирован с canonical. При расхождении — `standard/03` побеждает; `reference/01` обновляется (см. [§1.10 F1 reconciliation](#110-f1-reconciliation)).

**Применение:** при Phase 5 chapter pass на `reference/01-glossary.md` — обязательная reconciliation против `standard/03 §3.14.1` mapping table.

### §1.1.6 Domain-context preservation

Термины из substrate / version-control / software-engineering domain (`commit`, `merge`, `hook`, `pipeline`, `runner`, `linter`) остаются латиницей, потому что (a) являются конвенциями отрасли, (b) RU-эквиваленты теряют точность или вызывают двусмысленность, (c) удалить связь с substrate-capability V1-V6 [§11.3] невозможно.

**Применение:** см. [Bucket A](#13-bucket-a-technical-identifiers-keep-latin) whitelist §1.3.

## §1.2 Категории терминов (шесть buckets)

Все термины RU normative корпуса RENAR классифицируются в одну из шести buckets:

| Bucket | Категория | Policy | Section |
|---|---|---|---|
| A | Technical identifiers (substrate / VCS / SE domain) | Keep latin | §1.3 |
| B | Status vocabulary (lifecycle статусы) | Keep latin (matches YAML schema) | §1.4 |
| C | Organisational vocabulary | Rewrite в RU (prose); keep в YAML/code | §1.5 |
| D | Accepted кальки | Keep, density-cap 1% per chapter | §1.6 |
| E | Rewrite кальки | Per-term replacement table | §1.7 |
| F | Translit | Triage: accepted / borderline / rewrite | §1.8 |

Bucket determination per term — Phase 2 closed list (§1.9). Phase 5 не пересматривает classification.

## §1.3 Bucket A: technical identifiers (keep latin)

**Rule:** термины этой группы остаются латиницей в prose, code-fence content, frontmatter field names и section labels (когда technical).

**Rationale:** см. [§1.1.6 Domain-context preservation](#116-domain-context-preservation). Дополнительно: substrate-capabilities V1-V6 [`standard/11`](../standard/11-substrate-versioning.md) определены через эти термины; перевод нарушит referential integrity.

### §1.3.1 Whitelist (closed list)

| Term | Domain | RU UI projection (optional) |
|---|---|---|
| `commit` | VCS | фиксация |
| `merge` | VCS | слияние |
| `diff` | VCS | различие |
| `branch` | VCS | ветка |
| `push` | VCS | отправка |
| `pull` | VCS | получение |
| `hook` | VCS | перехватчик |
| `patch` | VCS | патч |
| `frontmatter` | Markdown | заголовочный блок |
| `manifest` | RENAR | манифест |
| `slug` | Markdown | слаг |
| `hash` | crypto / VCS | хеш |
| `trigger` | RENAR enforcement | триггер |
| `runner` | CI / testing | прогонщик |
| `pipeline` | CI | конвейер |
| `release` | RENAR | релиз |
| `deploy` | RENAR / DevOps | развёртывание |
| `build` | DevOps | сборка |
| `workflow` | RENAR / VCS | рабочий поток |
| `linter` | tooling | линтер |
| `parser` | tooling | парсер |
| `compiler` | tooling | компилятор |
| `tooling` | meta | оснастка |
| `tracker` | RENAR | трекер |
| `substrate` | RENAR | (no UI projection; canonical) |
| `provenance` | RENAR | происхождение |

**RU UI projection** — допустимо в multilingual UI (см. [`standard/03 §3.13.3`](../standard/03-terms.md#3.13.3)), но **canonical** — латиница. Frontmatter, ID, body normative paragraphs, scripts, CI hooks — всегда `commit/merge/...`.

### §1.3.2 Cross-bucket extension

Bucket A whitelist **не закрыт** в смысле §1.1.4. Это **открытый список substrate-domain identifiers**: новые VCS / SE / CI / observability domain-terms могут быть добавлены proactively при необходимости. Phase 5 chapter pass: новые domain-terms идут в Bucket A автоматически, если match domain pattern «substrate / VCS / SE tooling».

**Negative scenario:** brand names (`GitHub`, `Astro`, `Markdown`, `JetBrains`) не Bucket A — они proper nouns. Treat как canonical references без перевода / транслитерации.

## §1.4 Bucket B: status vocabulary (keep latin)

**Rule:** lifecycle status identifiers (`proposed`, `approved`, `verified`, `obsolete`, `frozen`, `active`, `planning`, `blocked`, `review`, `accepted`, `deprecated`, `done`, `ready`, `passing`, `failing`, `draft`, `client-ready`, `answered`, `resolved`, `revised`) остаются латиницей в prose, frontmatter, code-fence content.

**Rationale:**
1. Status — system-readable identifier, появляется в YAML frontmatter (`status: approved`); перевод prose-form вызывал бы dual-vocabulary («утверждённый → approved» mapping required for substrate enforcement).
2. State machines [`standard/10`](../standard/10-lifecycle-qg.md) определены через эти identifiers; перевод в prose разрывает референциальную цепь.
3. [`standard/03 §3.6`](../standard/03-terms.md#3.6) явно фиксирует canonical lowercase latin identifiers для всех типов артефактов.

### §1.4.1 RU UI projection (для pedagogical/UI usage)

| Status | RU UI projection (allowed in pedagogical guide/) |
|---|---|
| `draft` | черновик |
| `proposed` | предложенный |
| `approved` | утверждённый |
| `verified` | проверенный |
| `accepted` | принятый |
| `done` | выполненный |
| `obsolete` | устаревший |
| `deprecated` | удалённый |
| `frozen` | замороженный |
| `active` | активный |
| `planning` | планируется |
| `blocked` | заблокирован |
| `review` | на ревью |
| `ready` | готов |
| `passing` | проходит |
| `failing` | не проходит |
| `client-ready` | готов к клиенту |
| `answered` | отвечен |
| `resolved` | разрешён |
| `revised` | переуточнён |

**Pedagogical-only:** RU projection допустим в `guide/` (where reader-facing narrative dominates), **не** в `standard/`, `reference/`, `core/`.

### §1.4.2 Negative scenario — mixed-case mistakes

Распространённый paste-error: `proposed → Proposed → Предложенный` в одном файле. Style Guide требует **case consistency**: всегда lowercase `proposed`. Phase 5 chapter pass проверяет каждое statuс-mention.

## §1.5 Bucket C: organisational vocabulary (rewrite в prose)

**Rule:** в **prose** заменить на RU; в **YAML field names, code-identifiers, fence content** — keep latin.

**Rationale:** organisational vocabulary не имеет domain-specific semantic; RU equivalents существуют, чтение естественнее.

### §1.5.1 Replacement table

| Latin (prose) | RU canonical | Notes |
|---|---|---|
| `scope` | область (применения) / охват | YAML key `scope:` keeps latin |
| `audit` | ревизия / проверка / контроль | «audit trail» — keep latin (§1.3.1 extension: substrate-domain) |
| `draft` (как verb) | черновик / черновой | status `draft:` keeps latin (§1.4) |
| `policy` | правило / политика | «closed list policy» — keep latin (RENAR canonical phrase, §1.10) |
| `ownership` | владение / ответственность | — |
| `default` | по умолчанию | в YAML — keep `default:` |
| `bypass` | обход | — |
| `rollback` | откат | — |
| `fallback` | отступление / запасной вариант | — |
| `override` | переопределение | — |
| `stub` | заглушка | — |
| `guide` (noun) | руководство | директория `guide/` — keep latin (path) |
| `walkthrough` | прохождение / пошаговый разбор | — |
| `quickstart` | быстрый старт | — |

### §1.5.2 Negative scenario — context discrimination

Перед применением каждого rewrite — проверить контекст:

- Pure prose («scope нормирует X») → replace («область определяет X»).
- YAML/code field name (`scope:`) → keep.
- Substrate-domain technical phrase («audit trail», «commit audit») → keep latin per §1.3.
- Cross-ref label («closed list policy» как RENAR canonical phrase) → keep latin.

Phase 5 chapter pass: для каждого Bucket C term — 100% manual context-discrimination (no automation).

## §1.6 Bucket D: accepted кальки (keep, density-cap 1%)

**Rule:** accepted кальки остаются как есть; Phase 5 chapter pass проверяет **density-cap**: term frequency ≤ 1% prose-words per chapter. При превышении — Phase 5 reducer заменяет на synonym / pronominal reference / structural rewrite.

**Rationale:** эти термины давно accepted в RU IT, перевод не даёт reading-improvement. Но overuse снижает scan-readability (читатель видит wallpaper of «нормативный» + «реализация» + «спецификация» в каждом параграфе).

### §1.6.1 Accepted кальки list

| Term | Phase 1 count | Phase 5 density-cap action |
|---|---:|---|
| `нормативный` | 275 | Reduce if >1% chapter density |
| `реализация` | 111 | Same |
| `спецификация` | 25 | Below cap |
| `формальный` | 44 | Below cap |
| `опциональный` | 39 | Below cap |
| `атомарный` | 19 | Below cap |
| `декомпозиция` | 30 | Below cap |
| `композиция` | 30 | Below cap |
| `верификация` | (low) | Below cap |
| `валидация` | (low) | Below cap |
| `идентификация` | (low) | Below cap |
| `идентификатор` | 12 | Below cap |
| `интеграция` | (low) | Below cap |
| `миграция` | 29 | Below cap |
| `авторизация` | (low) | Below cap |
| `аутентификация` | (low) | Below cap |
| `итерация` | 15 | Below cap |

### §1.6.2 Density measurement

Density = (term occurrences) / (prose words after strip) × 100. Strip: YAML frontmatter, fenced code blocks, inline backticks, markdown link URLs (см. [`research/ru-anglicism-inventory.md §2`](ru-anglicism-inventory.md) методология). Cap: 1.0% per chapter.

**Verification protocol:** Phase 5 re-runs anglicism scanner (`d:/tmp/renar_anglicism_scan.py` ephemeral) на правленой главе; density delta — positive only (или, на best-of-class chapters, 0).

## §1.7 Bucket E: rewrite кальки

**Rule:** заменить на RU canonical per replacement table. Phase 5 chapter pass — manual per-occurrence (no mass-replace per §1.1.1).

**Rationale:** имеется precise RU equivalent; калька — anglicism-creep без semantic value.

### §1.7.1 Replacement table

| Latin (calque) | RU canonical | Notes |
|---|---|---|
| `имплементация` | реализация (общее) / исполнение (active-voice) | Phase 5: 52 occurrences corpus-wide |
| `конформация` | соответствие | **Exception:** `conformance` — ISO 29148 term, keep latin в substrate-domain context (см. `standard/14-conformance.md`). RU «соответствие» — для prose discussion outside ISO context |
| `эссенциальный` | существенный / обязательный | depending on context: «obligatory» vs «central» |
| `дрифт` (translit form) | дрейф / расхождение | **Exception:** `drift` (latin) — RENAR canonical class name §3.11; keep `Schema drift / Lifecycle drift` латиницей. RU «дрифт» только в prose mentions outside §3.11 context |
| `трейс*` (in prose) | трасс* / отслеживание | «traceability» — RENAR canonical, keep latin |
| `аннотация` (когда AI-bias overuse) | пояснение / примечание | Context-dependent — see §1.5.2 |
| `регуляция` | регулирование | Rare, AI-bias residue |
| `корреляция` | (Bucket D — keep) | Listed for clarification: it's accepted, not rewrite |

### §1.7.2 Exceptions and edge cases

При rewrite encountered:

- **Frozen quote / citation** — when calque appears inside quoted text from ISO/IEC/IEEE source — keep verbatim, add translator note if needed.
- **Field name in YAML schema** — never touch (canonical schema [`reference/02-schemas.md`](../reference/02-schemas.md) is normative).
- **Cross-ref label** — if part of canonical RENAR phrase — keep latin per §1.3.1 extension.

## §1.8 Bucket F: translit triage

**Rule:** триаж по 3 категориям — accepted / borderline / rewrite. Phase 2 финализирует triage; Phase 5 chapter pass применяет.

### §1.8.1 Triage — Accepted (keep)

Транслит-термины, давно accepted в RU IT, keep:

| Term | Phase 1 count | RU equivalent (not used) |
|---|---:|---|
| `артефакт` | 455 | (RU equivalent «изделие» лишь утилитарно; «артефакт» canonical в IT) |
| `автор` | 15 | (Russian word — not anglicism per se) |
| `шаблон` | 17 | (Russian word — not anglicism) |
| `репозиторий` | 18 | (RU equivalents «хранилище» / «склад» не охватывают version-control semantics) |

### §1.8.2 Triage — Borderline (case-by-case)

Decide context-dependent:

| Term | Phase 1 count | Decision rule |
|---|---:|---|
| `ревью` | 29 | Keep when after «adversarial» (technical compound); rewrite to «рецензия» / «ревизия» when stand-alone |
| `кейс` | 13 | Keep in «edge case» / «test case» — technical compound; rewrite to «случай» в общем контексте |
| `стейкхолдер` | 12 | Keep как formal IT term; alternative «заинтересованная сторона» (longer, more formal — for `standard/`); «стейкхолдер» в `guide/` OK |
| `чекпойнт` | low | Keep если refers to RENAR/SENAR `/checkpoint` skill; rewrite to «контрольная точка» otherwise |
| `гейт` | low | Keep в normative RENAR context (Quality Gate); rewrite to «ворота» / «контроль» avoided (loses canonical meaning) |
| `онбординг` | low | Keep |

### §1.8.3 Triage — Rewrite (low-count, ambiguous)

Транслит с RU equivalents — rewrite:

| Term | Phase 1 count | RU replacement |
|---|---:|---|
| `фронтенд` | low | «клиентская часть» / «frontend» (latin) — pick latin |
| `бэкенд` | low | «серверная часть» / `backend` |
| `пайплайн` (RU form) | low | Keep `pipeline` (Bucket A latin) — don't use translit |
| `фолбэк` | low | Keep `fallback` (Bucket A) — don't translit |
| `оверхед` | low | «накладные расходы» |
| `апдейт` | low | «обновление» / «правка» |

**Negative scenario:** Bucket F triage **не** rewrite того, что Bucket A keeps latin. Pick latin (`pipeline`) over translit (`пайплайн`). Translit forms — anti-pattern для substrate-domain terms.

## §1.9 Closed list canonical RENAR terms

Закрытый список 50+ canonical RENAR terms, синхронизированный с [`standard/03-terms.md`](../standard/03-terms.md). Изменение списка — formal change procedure стандарта.

### §1.9.1 Артефакты requirements (canonical from `standard/03 §3.3`)

| Canonical | RU UI projection | Latin | Source |
|---|---|---|---|
| `BR` | Бизнес-требование | Business Requirement | `standard/03 §3.3.3` |
| `SR` | Системное требование | System Requirement | `§3.3.4` |
| `TR` | Требование к задаче | Task Requirement | `§3.3.5` |
| `ADAPT` | Двусторонняя адаптация ТЗ | (canonical RENAR-extension) | `§3.3.2` |
| `ТЗ` | Техническое задание | (canonical RU) | `§3.3.1` |
| `delta-ТЗ` | дельта-ТЗ | — | `§3.3.1` |

### §1.9.2 SPEC family (closed list 9 types from `§3.4`)

`SPEC-ARCH`, `SPEC-API`, `SPEC-DATA`, `SPEC-INT`, `SPEC-PROC`, `SPEC-UI`, `SPEC-AI`, `SPEC-SEC`, `SPEC-OPS` — все latin.

### §1.9.3 TC types (closed list 6 from `§3.5.2`)

`acceptance`, `ux`, `system`, `contract`, `eval`, `security` — все latin, lowercase.

### §1.9.4 Quality Gates (canonical v1.0 from `§3.7`)

`QG-0 Approval`, `QG-1 Implementation`, `QG-2 Verification`, `QG-3 Architecture` (optional), `QG-4 Acceptance` (optional).

**Important:** legacy names (`QG-0 Context Gate`, `QG-1 Requirements Gate`, `QG-2 Implementation Gate`, `QG-3 Verification Gate`) **deprecated**. См. [§1.10 F1 reconciliation](#110-f1-reconciliation).

### §1.9.5 Lifecycle статусы (canonical from `§3.6`)

См. [§1.4.1 RU UI projection table](#141-ru-ui-projection-для-pedagogicalui-usage).

### §1.9.6 Substrate capabilities (V1–V6)

`V1 Immutable history`, `V2 Atomic change unit`, `V3 Diff & review`, `V4 Branching / change-set`, `V5 Cross-substrate version pin`, `V6 Author + timestamp` — все labels latin. RU описания допустимы в prose.

### §1.9.7 Drift classes (closed list 8 from `§3.11`)

Все 8 классов — латиница в canonical name: `Schema drift`, `Lifecycle drift`, `Source-of-truth drift`, `Implementation drift`, `Terminological drift`, `Order / provenance drift`, `TC ↔ requirement provenance drift`, `Test-fitting drift`.

## §1.10 F1 reconciliation: legacy → canonical v1.0

**Source:** [`standard/03-terms.md §3.14.1`](../standard/03-terms.md#3.14.1) Устаревшие RENAR-specific labels.

**Rule:** при обнаружении в normative artifact — substrate-нативный hook обязан флагнуть; Phase 5 chapter pass правит на canonical.

### §1.10.1 Legacy artifact labels

| Устаревший | Canonical v1.0 | Где применять |
|---|---|---|
| `UIC` (UI Concept) | `SPEC-UI` | All occurrences |
| `AIC` (AI Concept) | `SPEC-AI` | All occurrences |
| `INT-SR` (Integration SR) | `SR` с `constrained-by: [SPEC-INT-N]` | All occurrences |
| `INT-TC` (Integration TC) | `TC` с `tc-type: contract` | All occurrences |
| `TM` (Module/Submodule SR) | `SR` с `level: module` | All occurrences |
| `TS` (Technical Specification) | `SPEC-ARCH` / `SPEC-OPS` (context-dependent) | Manual per occurrence |

### §1.10.2 Legacy Quality Gate names

| Устаревший (pre-v1.0) | Canonical v1.0 |
|---|---|
| `QG-0 Context Gate` | `QG-0 Approval` |
| `QG-1 Requirements Gate` | `QG-1 Implementation` (semantic shift: ранее approval BR/SR, теперь только TC `draft → ready`) |
| `QG-2 Implementation Gate` | `QG-1 Implementation` |
| `QG-3 Verification Gate` | `QG-2 Verification` |

### §1.10.3 Affected file (Phase 5 priority 1)

[`reference/01-glossary.md`](../reference/01-glossary.md):
- §2.1 «Уровни требований» table — replace `TM`/`UIC`/`AIC`/`INT-SR`/`INT-TC`/`TS` per §1.10.1.
- §2.4 «Quality Gates» table — replace pre-v1.0 names per §1.10.2.
- §3.2 «Quality gates» cross-mapping table — same.

**Phase 1.5 prerequisite:** до Phase 2 ru-style-lock — `reference/01-glossary.md` reconciliation должна быть выполнена. Recommend separate task `ru-reconcile-glossary-vs-standard`.

## §1.11 Accepted technical loanwords

Cross-bucket whitelist для substrate-domain / IT-canonical terms, **которые не калька, не translit, а accepted technical loanwords**:

| Term | Domain | Used in canonical RENAR |
|---|---|---|
| `substrate` | RENAR foundation | `standard/03 §3.8`, `standard/11` everywhere |
| `state machine` | distributed systems | `standard/10` §10.5-§10.9 |
| `atomic change unit` | distributed systems | `standard/11 §11.3.2` V2 |
| `diff & review` | VCS / RENAR | `standard/11 §11.3.3` V3 |
| `adversarial review` | RENAR / AI | `standard/00 §0.3`, `standard/03 §3.13.4` |
| `eval` / `evaluation` | AI testing | `standard/09 §9.6.2` |
| `runner` | CI / RENAR | `standard/03 §3.7`, `standard/10 §10.3.2` |
| `branching` | VCS | `standard/11 §11.3.4` V4 |
| `version pin` | RENAR substrate | `standard/03 §3.8.4`, `standard/11 §11.3.5` |
| `traceability` | RE general | `standard/01 §1.6`, `standard/03 §3.10.3` |
| `provenance` | RENAR AI | `standard/03 §3.10`, `standard/12 §12.7.1` |
| `closed list` | RENAR meta-policy | `standard/01 §1.7` |

**Rule:** эти термины не подлежат rewrite в Phase 5; они canonical в RENAR domain и широко accepted в международной literature. AI-bias guard §1.1.3 особенно: не пытаться «перевести» в RU equivalents — это поломает domain accuracy.

## §1.12 Process for adding new terms

Добавление нового canonical term:

1. **Identify need** — term появляется в нормативной главе ≥3 раз без §1.9 listing.
2. **Bucket classification** — определить bucket A-F (применить §1.2 criteria).
3. **Rationale draft** — submitter готовит rationale (3-5 sentences): why this term needed, why this bucket, what RU/EN alternatives rejected.
4. **Phase 2 review** — submit к Style Guide §1 editor (review same way как добавление в `standard/03-terms.md` per [§3.14 formal change procedure](../standard/03-terms.md#3.14)).
5. **Phase 5 retroactive** — после approval, Phase 5 chapter pass нормализует existing occurrences.

**Interim period (между submission и approval):** new term допустим в `research/` drafts; в `standard/`, `guide/`, `reference/`, `core/` — только после approval.

## §1.13 Validation

Phase 5 chapter pass обязан выполнить per глава:

### §1.13.1 Automated checks

1. **Bucket A whitelist coverage** — grep latin terms vs §1.3.1 list; flag mismatches.
2. **Bucket B status consistency** — `proposed/approved/...` always lowercase latin; flag mixed-case.
3. **Bucket C latin-in-prose** — grep `scope|audit|draft|policy|...` вне code-fences / YAML; manual review each.
4. **Bucket D density-cap** — re-run anglicism scanner; verify <1% per term.
5. **Bucket E presence** — grep rewrite-target terms (`имплементация|конформация|эссенциальный|...`); manual review each.
6. **Bucket F triage** — grep translit forms; classify each per §1.8.
7. **Legacy labels (F1)** — grep `UIC|AIC|INT-SR|INT-TC|TM|TS`; flag every occurrence.
8. **Legacy QG names** — grep `Context Gate|Requirements Gate|Implementation Gate|Verification Gate`; flag.

Tooling: `d:/tmp/renar_anglicism_scan.py` (Phase 1 ephemeral); Phase 5 lock-in version → `scripts/style-guide-check.js` (planned in future epic).

### §1.13.2 Human spot-check requirements

Per memory #31 принцип 8: **каждый Phase 5 chapter pass проходит human spot-check на random 10% правок**. Spot-check verifies:
- (a) AI-agent не вписал anglicism, не разрешённые §1.
- (b) Context-discrimination сделана правильно (§1.5.2).
- (c) Domain accuracy сохранена (§1.11 accepted loanwords).
- (d) Normative semantic preserved (§1.1.2).

### §1.13.3 Phase 3 pilot checkpoint

До Phase 5 запуска (mass application) — Phase 3 pilot:
1. **Pick one chapter** (recommend: `standard/03-terms.md` — canonical-voice exemplar per [`research/ru-tone-sampling.md §4.1`](ru-tone-sampling.md)).
2. **Apply full §1 ruleset.**
3. **User checkpoint:** review pilot diff, adjust §1 if needed.
4. **Lock-in Phase 2** after pilot approval.

## §1.14 AI-bias guard

Этот § явно фиксирует known AI-bias failure modes при editorial pass:

### §1.14.1 LLM English-bias

LLM trained on multilingual web with English dominance склонна:

- Inserting anglicism в prose где RU equivalent exists.
- Tolerating mixed-lang («корпоративный admin») as «normal».
- Rewriting RU into English-flavored RU («это implementation, которая verifies...»).
- Preferring kalkу («имплементация») over native («реализация»).

**Mitigation:** Bucket E replacement table (§1.7.1) — hard-coded substitutions; agent invocation prompt includes «strict RU prose; bias toward §1.7 RU canonical».

### §1.14.2 Confidence over precision

LLM может confidently rewrite phrase в форме, которая ломает normative semantic — например, заменять «должен» на «следует» «для читаемости» (это semantic downgrade per RFC-2119 §2).

**Mitigation:** §1.1.2 — normative semantic preserved; Phase 5 pilot checkpoint catches semantic drift.

### §1.14.3 Pattern-completion drift

LLM, видя 50 examples «X нормирует Y», completes 51-й example с тем же pattern, даже если §1 требует RU rewrite.

**Mitigation:** spot-check на random samples (§1.13.2), не на «typical» examples.

### §1.14.4 Human review obligation

**Hard rule:** Phase 5 chapter pass без human spot-check **запрещён**. Memory #31 принцип 8 — обязательно. Subagent invocations передают этот § в prompt.

## §1.15 Negative scenarios

### §1.15.1 No mass find-replace

Запрещено по §1.1.1. Tools (sed / awk / IDE find-replace) — banned for Phase 5 chapter pass. Manual per-occurrence approve required.

### §1.15.2 No prescriptive Phase 5 decisions

§1 — terminology rules; **не** dictates wording per sentence. Phase 5 chapter pass — editorial judgment within §1 constraints, не mechanical rewrite.

### §1.15.3 Closed list violation

Project-local создание новых canonical terms (`SR-CLIENT`, `BR-INTERNAL`, ...) — violation of §1.1.4 closed list policy. Substrate-нативный hook должен flag; Phase 5 pass — substrate hook integration TBD (future epic).

### §1.15.4 Style Guide bypass

Phase 5 chapter pass без §1 application — **violates Phase 2 lock-in contract**. Style Guide §1 — normative, не recommendation. SENAR Rule 9.15 (AI Output QA) requires.

## §1.16 Cross-link к sections §2, §3

- **§2 RFC-2119 RU normative wording** (task `ru-style-rfc2119`) — regime для MUST/SHALL/SHOULD/MAY (EN UPPERCASE vs RU lowercase «должен/следует/может»). §1 не trogает this — §2 reserved.
- **§3 Formatting conventions** (task `ru-style-formatting`) — citations bare/link, code-fence lang tags, headings, tables. §1 не дублирует.

## §1.17 AC mapping (for ru-style-terminology task)

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Artifact в `research/` | `research/ru-style-guide-draft-section-1-terminology.md` (этот файл) |
| 2 | Cross-link на editorial-audit + 3 inventories | Intro callout + §1.13.1 link to anglicism scan |
| 3 | Принципы §1.1 (5+) | §1.1.1-§1.1.6 — 6 принципов |
| 4 | Closed list 50-100 canonical terms | §1.9 (artifacts) + §1.3.1 (Bucket A) + §1.4.1 (Bucket B) + §1.5.1 (Bucket C) + §1.6.1 (Bucket D) + §1.7.1 (Bucket E) + §1.8 (Bucket F) + §1.10 (legacy → canonical) + §1.11 (loanwords) — total ~80 terms with explicit decisions |
| 5 | Six buckets A-F with rule per bucket | §1.3 (A) + §1.4 (B) + §1.5 (C) + §1.6 (D) + §1.7 (E) + §1.8 (F) |
| 6 | F1 reconciliation table | §1.10.1 (artifacts) + §1.10.2 (QG names) + §1.10.3 (affected files) |
| 7 | Accepted technical loanwords whitelist | §1.11 — cross-bucket whitelist 12 terms |
| 8 | Process for adding new terms | §1.12 — 5-step process |
| 9 | Phase 5 validation | §1.13 (automated + spot-check + pilot checkpoint) |
| 10 | Read-only invariant | git status: только новый research/-файл |
| 11 | Frontmatter status:draft | YAML: `status: draft`, target final path declared |
| 12 | Each decision has rationale + ambiguity + verification | §1.3-§1.8 — каждая bucket section has Rule + Rationale + Notes + Verification approach |
| 13 | AI-bias guard § | §1.14 — 4 sub-sections (English-bias / confidence-over-precision / pattern-completion / human-review-obligation) |
| 14 | Closed list canonical terms (formal change procedure) | §1.1.4 + §1.9 + §1.12 — closed list policy mirrors standard/01.7 |

## §1.18 Limitations & follow-ups

1. **Draft status.** §1 — Phase 2 draft; Phase 3 pilot checkpoint может потребовать revision. Lock-in (`ru-style-lock`) compiles после §2, §3, pilot validation.
2. **Bucket assignments edge cases.** Some terms могут не вписываться в один bucket (e.g. `cache` — Bucket A или D?). Phase 5 chapter pass — when encountered, editor applies §1.1.5 SoT principle and submits ambiguity for §1 amendment (§1.12 process).
3. **Density-cap 1.0%** (§1.6.2) — initial threshold, not empirically validated. Phase 3 pilot may adjust.
4. **No Phase 5 tooling yet.** §1.13.1 automated checks reference ephemeral scripts (`d:/tmp/renar_anglicism_scan.py`). Lock-in requires moving to `scripts/style-guide-check.js` (separate future task).
5. **Phase 1.5 prerequisite for `reference/01-glossary.md`** (§1.10.3) — recommended separate task `ru-reconcile-glossary-vs-standard` before Phase 5 chapter pass на glossary. Without it, glossary remains drifted vs §1 canonical.
6. **F1 reconciliation impact assessment.** §1.10.3 — only `reference/01-glossary.md` identified. Phase 1 audits sample-read 12% corpus end-to-end (`research/ru-tone-sampling.md`); other files may also contain legacy labels. Phase 5 chapter pass per file должна grep §1.10 patterns and flag findings.

## §1.19 Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Phase 1 deliverable: `research/ru-editorial-audit.md` (Top-3 systemic findings F1-F3 + 25 prioritized findings)
- Source audits:
  - `research/ru-anglicism-inventory.md` (Buckets A-F definitions, 105 unique terms)
  - `research/ru-style-inconsistencies.md` (terminology + structural overlap)
  - `research/ru-tone-sampling.md` (canonical voice candidates + drift discovery)
- Canonical normative: `standard/03-terms.md` (especially §3.13.3 UI projection + §3.14.1 legacy mapping)
- Multilingual UI policy: `standard/03-terms.md §3.13.3`
