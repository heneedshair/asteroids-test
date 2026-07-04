---
title: "Style Guide §2 (draft): RFC-2119 RU normative wording"
status: draft
phase: "Phase 2 Style Guide §2 — compile в ru-style-lock"
epic: ru-normative-pass-v1
task: ru-style-rfc2119
draft-date: 2026-05-16
target-final-path: "reference/06-ru-style-guide.md (после compile в Phase 2 lock-in)"
lang: ru
---

# Style Guide §2: RFC-2119 RU normative wording (DRAFT)

> **Phase 2 draft.** Этот документ — рабочий черновик §2 будущего [`reference/06-ru-style-guide.md`](../reference/06-ru-style-guide.md). Задача [`ru-style-lock`](#) (Phase 2 final) скомпилирует §1+§2+§3 в финальный normative artifact.
> Статус: **draft** — может быть скорректирован Phase 3 pilot checkpoint feedback.
> Cross-link: [§1 terminology draft](ru-style-guide-draft-section-1-terminology.md), [`research/ru-editorial-audit.md`](ru-editorial-audit.md) (F2 systemic finding), [`research/ru-style-inconsistencies.md`](ru-style-inconsistencies.md) §3.1 + §3.6 (RFC-2119 + tense/mood data).

## §2.0 Назначение

§2 фиксирует **canonical RU normative wording** для RENAR Standard. Регламентирует:

- regime для RFC-2119 keywords (UPPERCASE EN / UPPERCASE RU / lowercase RU) — закрывает Phase 1 F2;
- canonical mapping для всех 11 RFC-2119 keywords (`MUST/MUST NOT/SHALL/SHALL NOT/SHOULD/SHOULD NOT/MAY/REQUIRED/RECOMMENDED/NOT RECOMMENDED/OPTIONAL`);
- strict semantic preservation rule (no «должен → следует» downgrade под видом editorial polish);
- tense/mood normative rules (imperative-mood для normative clauses; canonical form для definitions; future-tense scope);
- migration plan для 15 existing EN UPPERCASE occurrences;
- canonical negation patterns (`не должен / запрещено / не допускается / не следует / не рекомендуется`).

§2 — **normative** часть Style Guide. Phase 5 chapter pass обязан проверять каждую normative clause на соответствие §2 (см. [§2.10 Validation](#210-validation)).

## §2.1 Принципы

Шесть нормативных принципов §2, обязательные для применения Phase 5 chapter pass:

### §2.1.1 Semantic-fidelity первичен

RFC-2119 ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)) фиксирует **строгое semantic discrimination** между levels: MUST (absolute requirement) ≠ SHOULD (strong recommendation, allowed exceptions) ≠ MAY (optional). RU wording должен сохранить эту дискриминацию.

**Применение:** при выборе RU эквивалента для нормативной clause editor проверяет: совпадает ли семантика с RFC-2119 level? Если нет — это **content change**, требует отдельной задачи (см. [§1.1.2 Preserved normative semantic](ru-style-guide-draft-section-1-terminology.md#112-preserved-normative-semantic)).

### §2.1.2 No semantic downgrade под видом editorial

LLM-агент склонен «полировать читаемость» путём «должен → следует», что даёт **семантический downgrade** (MUST → SHOULD). Это потеря normative strength.

**Применение:** Phase 5 editorial pass **не имеет права** менять modal verb level. Если original clause использует «должен» — replacement тоже imperative-mood («должен/обязан»). Если original — «следует» — replacement в пределах SHOULD level. Перенос между levels — content change.

Cross-ref: [`§1.14.2 Confidence over precision`](ru-style-guide-draft-section-1-terminology.md#1142-confidence-over-precision).

### §2.1.3 RFC 8174 carve-out для RU

[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) уточняет: только **UPPERCASE** формы (MUST, SHALL, …) несут RFC-2119 нормативный смысл; lowercase английский («must», «shall») — обычный язык без normative weight.

RENAR Style Guide делает **явный carve-out** для русского:

> RU lowercase modal verbs (`должен`, `следует`, `может`, `рекомендуется`, `допускается`, `требуется`, `обязательно`, `опционально`, `обязан`, `запрещено`), использованные в нормативных clauses внутри RENAR Standard artifacts (`standard/`, `reference/`, `core/` с normative role), **являются canonical эквивалентом** RFC-2119 UPPERCASE keywords. Их normative weight равен соответствующему UPPERCASE keyword.

**Применение:** §2.2 mapping table определяет канонические соответствия. Document RFC-2119/RFC-8174 в `standard/02-normative-refs.md` cited; carve-out явно прописан в lock-in §2.

### §2.1.4 No UPPERCASE convention в RU prose

Convention `ОБЯЗАН/ДОЛЖЕН/СЛЕДУЕТ/МОЖЕТ` (capitalized) — **запрещена**. Phase 1 audit фиксирует 0 occurrences в текущем корпусе; вводить новую convention в Phase 2 — против consistency.

**Применение:** RU normative modals — always lowercase. Capitalization — только когда начинают предложение (orthographic, не emphatic).

**Negative scenario:** если автор хочет визуально emphasize requirement — использовать `**должен**` (markdown bold) либо вынести в выделенный нормативный блок (e.g. таблицу MVR / SPEC requirements). UPPERCASE — табу.

### §2.1.5 Imperative-mood для normative clauses

Normative clauses используют **imperative-mood** RU верб: «X должен Y», «X обязан Y», «X не должен Y», «X следует Y», «X может Y». Indicative form («X выполняет Y», «X is Y») — для descriptive prose, не для normative requirements.

**Применение:** при правке RU normative wording — keep imperative-mood. Если original imperative («должен») — replacement imperative («обязан» при contract obligations). Indicative form (`X — это Y`) допустим только для definitions (§2.4.2).

### §2.1.6 MVR special handling

Minimum Viable Requirements (MVR-1..MVR-7) — закрытый list из 7 MVR в [`standard/00-introduction.md §0.5`](../standard/00-introduction.md). Текущие 10 SHALL в этой таблице — намеренный RFC-2119 идиом per ISO 29148 reading.

**Decision (§2.6):** MVR таблица мигрирует на RU lowercase canonical (`обязан` для SHALL, `должен` для MUST), сохраняя semantic. ISO 29148 cross-link — в footnote или в `standard/02-normative-refs.md`.

## §2.2 F2 regime decision

### §2.2.1 Three options considered

Phase 1 audit ([editorial-audit §1.2 F2](ru-editorial-audit.md#12-top-3-systemic-findings)) выявил mixed regime. Style Guide §2 закрывает F2 одним из трёх options:

| Option | Description | Pros | Cons |
|---|---|---|---|
| (A) EN UPPERCASE everywhere | All normative modals в RU prose → MUST/SHALL/SHOULD/MAY | Direct ISO 29148 compatibility; zero ambiguity per RFC 2119 | Breaks RU readability (EN keywords inside RU sentence); 261 RU lowercase occurrences потребуют migration |
| (B) RU UPPERCASE | `ОБЯЗАН/ДОЛЖЕН/СЛЕДУЕТ/МОЖЕТ` capitalized | Visually emphatic; matches RFC 2119 UPPERCASE-bearing-semantic principle | 0 precedent в корпусе; visual noise typical for shouting; не natural в RU normative tradition |
| (C) RU lowercase canonical | `должен/обязан/следует/может/...` lowercase | 261/276 (95%) уже соответствуют; natural RU normative tradition; closer to ГОСТ Р normative style | Требует explicit RFC 8174 carve-out (см. §2.1.3); 15 EN UPPERCASE occurrences потребуют migration |

### §2.2.2 Decision: Option (C) RU lowercase

**Decision recorded.** RENAR Standard RU corpus использует **RU lowercase modal verbs** как canonical normative wording.

### §2.2.3 Rationale

1. **De-facto majority** (95%) уже соответствует — minimal disruption.
2. **Natural RU normative tradition** — ГОСТ Р, ISO 29148 RU translations, ИСО серия используют lowercase modals. Стандарт мирового уровня в RU — должен следовать RU normative tradition.
3. **RFC 8174 carve-out** (§2.1.3) явно устраняет ambiguity: lowercase RU modals в RENAR normative contexts = canonical RFC-2119 keywords.
4. **MVR table** — единственный pocket EN UPPERCASE (10 SHALL); migration plan (§2.6) минимизирует regression. ISO 29148 cross-link не теряется (`standard/02-normative-refs.md` carries).
5. **Visual emphasis** где нужен — через markdown `**bold**` либо через outdent в выделенные normative tables, не через capitalization.

### §2.2.4 What this decision is NOT

- §2.2.2 **не** запрещает EN UPPERCASE в `reference/04-ai-style-guide.md` (descriptive RFC 2119 mention, не normative usage in RENAR Standard sense).
- §2.2.2 **не** запрещает RFC-2119 UPPERCASE keywords в EN translation (`standard/en/` future epic). EN version будет следовать EN convention (UPPERCASE) per Phase 6/7 (TBD).
- §2.2.2 **не** mandates rewrite в каждой clause `«X необходимо Y»` → `«X должен Y»`. Phrase «необходимо» канонический synonym `«должен»` (см. §2.3) и допустим.

## §2.3 Canonical mapping table

11 RFC-2119/RFC-8174 keywords + RU canonical equivalents. Phase 5 chapter pass — primary reference.

### §2.3.1 Mandatory levels

| RFC-2119 | RU canonical (primary) | RU canonical (synonym) | Semantics |
|---|---|---|---|
| `MUST` | должен | обязан / необходимо / требуется | Absolute requirement — нет исключений |
| `MUST NOT` | не должен | запрещено / недопустимо | Absolute prohibition |
| `SHALL` | должен | обязан | Equivalent к MUST per RFC 2119 §2 |
| `SHALL NOT` | не должен | запрещено | Equivalent к MUST NOT |
| `REQUIRED` | обязателен / обязательно | необходим | Equivalent к MUST (adjective form) |

**Notes:**

- `должен` — modal verb (predicate): «X должен соответствовать Y».
- `обязан` — synonym `должен` для contract-style obligation: «Х обязан соблюдать Y» (часто в substrate / SPEC contexts).
- `обязателен` / `обязательно` — adjective / adverb (REQUIRED): «Поле X обязательно».
- `необходимо` — semantic equivalent: «Необходимо обеспечить Y».
- `требуется` — passive-voice equivalent: «Требуется обеспечить Y».
- `запрещено` / `недопустимо` — adjective predicate (MUST NOT): «Mass find-replace запрещено».

### §2.3.2 Strong recommendation level

| RFC-2119 | RU canonical (primary) | RU canonical (synonym) | Semantics |
|---|---|---|---|
| `SHOULD` | следует | рекомендуется | Strong recommendation; exceptions требуют explicit rationale |
| `SHOULD NOT` | не следует | не рекомендуется | Strong negative recommendation; exceptions требуют rationale |
| `RECOMMENDED` | рекомендуется | предпочтительно | Equivalent к SHOULD (predicate form) |
| `NOT RECOMMENDED` | не рекомендуется | нежелательно | Equivalent к SHOULD NOT |

**Notes:**

- `следует` — modal: «X следует verify Y».
- `рекомендуется` — passive equivalent: «Рекомендуется verify Y».
- `предпочтительно` — adverbial equivalent: «Предпочтительно использовать Y».
- `нежелательно` — equivalent NOT RECOMMENDED, lower-emphatic чем «не рекомендуется».

### §2.3.3 Optional level

| RFC-2119 | RU canonical (primary) | RU canonical (synonym) | Semantics |
|---|---|---|---|
| `MAY` | может | допускается | Truly optional; no preference |
| `OPTIONAL` | опционален / опционально | необязателен / по выбору | Equivalent к MAY (adjective form) |

**Notes:**

- `может` — modal: «X может содержать Y».
- `допускается` — passive: «Допускается включить Y».
- `опционально` — adverb (часто в YAML schema descriptions): «`field: optional` → опционально».
- `необязателен` — adjective negation REQUIRED, equivalent OPTIONAL: «Поле X необязательно».
- `по выбору` — phrase для optional choices: «Bucket assignment по выбору editor».

### §2.3.4 Negation table — canonical patterns

| Form | RU canonical | Discrimination |
|---|---|---|
| MUST NOT | не должен / запрещено / недопустимо | Hardcoded prohibition |
| SHALL NOT | не должен / запрещено | Equivalent MUST NOT |
| SHOULD NOT | не следует / не рекомендуется | Strong negative recommendation |
| NOT RECOMMENDED | не рекомендуется / нежелательно | Equivalent SHOULD NOT |
| (MAY NOT — non-canonical RFC) | не требуется (как absence-of-requirement) | RFC 2119 не содержит MAY NOT; «не требуется» = «MAY omit» |

**Hard rule:** «не должен» (MUST NOT) ≠ «не следует» (SHOULD NOT). Editor никогда не подменяет одну форму другой «для читаемости».

## §2.4 Tense / mood normative rules

Phase 1 audit ([style-inconsistencies §3.6](ru-style-inconsistencies.md#36-f-tense--mood-heuristic)) выявил: 67 present-copula + 52 imperative-mood + 15 future-tense. §2.4 фиксирует convention для каждого register.

### §2.4.1 Normative clauses → imperative-mood

**Rule:** normative requirements используют imperative-mood (`должен/обязан/следует/может/...`). Indicative present (`X выполняет Y`, `X is Y`) — для descriptive prose только.

**Canonical:**

```markdown
SR должен прослеживаться до родительского BR через `parent:` link.
```

**Anti-pattern:**

```markdown
SR прослеживается до родительского BR через `parent:` link.
```

Indicative form читается как **statement of fact**, не как requirement. Reader не знает, является ли это constraint, который должен соблюдаться, или observation.

### §2.4.2 Definitions → predicative form

**Rule:** definitions используют RU canonical predicative form `X — Y, нормированное Z`, где Y — категориальный класс, Z — distinguishing characteristic. Эта форма doминирует в [`standard/03-terms.md`](../standard/03-terms.md) и принята за canonical exemplar ([editorial-audit §3](ru-editorial-audit.md#3-per-chapter-density-синтез) canonical voice).

**Canonical:**

```markdown
ADAPT — двусторонняя адаптация ТЗ, нормированная процессом согласования с заказчиком.
```

**Acceptable variants:**

- `X — это Y, …` (с подчёркивающим частицей «это»).
- `X — Y` (без `это`, если context самостоятельно сигналит definition).

**Anti-pattern:**

- `X является Y` — formal-overhead; допустим в legal-style, но reads heavy.
- `X представляет собой Y` — anglicism-style копи verb chains; rewrite в `X — Y`.

**Discrimination:** «является» (67 occurrences corpus-wide) — допустим в low-density (≤2 per chapter), rewrite when ≥3 occurrences per § (excess formality). Phase 5 chapter pass — per-occurrence judgement.

### §2.4.3 Future tense — scope-limited

**Rule:** future-tense (`будет/будут`, 15 occurrences corpus-wide) **запрещён** в normative clauses. Допустим только в:

1. **Roadmap sections** — `standard/00 §0.7` (planned chapters), version-history sections.
2. **Forward-looking limitations** — «Phase 5 chapter pass [будет] применять §1.13 validation».
3. **Conditional consequences** — «при нарушении X — `tausik verify` [будет] flag clause as drift».

**Anti-pattern:** normative requirements в future tense.

```markdown
# WRONG (semantic ambiguous — это требование или прогноз?):
SR будет содержать parent link.

# CORRECT:
SR должен содержать parent link.
```

### §2.4.4 Conditional clauses

**Rule:** conditional normative requirements (`if X then Y must Z`) RU pattern:

```markdown
Если X, то Y должен Z.
```

Acceptable variants:

- `При условии X — Y должен Z.`
- `Когда X, Y обязан Z.`
- `X влечёт обязательство Y по Z.` (formal substrate-domain style).

**Anti-pattern:** conditional + indicative («Если X, то Y делает Z») — теряется normative weight.

## §2.5 Strict semantic preservation rule

**Hard rule (per §2.1.2):** Phase 5 editorial pass **не имеет права** менять RFC-2119 level clause's modal verb.

### §2.5.1 Allowed transformations

✅ Permitted (semantic-preserving):

| From | To | Reason |
|---|---|---|
| `должен` | `обязан` | Same level (MUST); synonym choice editorial |
| `следует` | `рекомендуется` | Same level (SHOULD); synonym choice editorial |
| `может` | `допускается` | Same level (MAY); synonym choice editorial |
| `необходимо` | `требуется` | Same level (MUST); same passive-voice register |
| `не должен` | `запрещено` | Same level (MUST NOT); emphatic synonym |

### §2.5.2 Forbidden transformations

❌ Forbidden (semantic-altering — это **content change**, не editorial):

| From | To | Reason |
|---|---|---|
| `должен` | `следует` | MUST → SHOULD downgrade |
| `следует` | `может` | SHOULD → MAY downgrade |
| `должен` | `может` | MUST → MAY downgrade |
| `не должен` | `не следует` | MUST NOT → SHOULD NOT downgrade |
| Любое modal | indicative («X делает Y») | Loss of normative weight |

### §2.5.3 Verification protocol

Phase 5 chapter pass:

1. **Pre-pass scan:** grep modal verbs в главе, count per level (MUST / SHOULD / MAY).
2. **Post-pass scan:** re-grep, compare counts.
3. **Delta acceptance:** sum-per-level не должна меняться. Если меняется — flag as **semantic drift**, revert, surface для content-review задачи.

## §2.6 MVR table migration plan

`standard/00-introduction.md §0.5` — closed-list MVR-1..MVR-7 таблица с 10 SHALL.

### §2.6.1 Current state (Phase 1 baseline)

| MVR | Current wording (excerpt) | RFC-2119 keyword |
|---|---|---|
| MVR-1 | «… SHALL be unambiguously identifiable …» | SHALL |
| MVR-2 | «… SHALL trace to parent …» | SHALL |
| MVR-3 | «… SHALL …» | SHALL |
| MVR-4 | «… SHALL …» | SHALL |
| MVR-5 | «… SHALL …» | SHALL |
| MVR-6 | «… SHALL …» | SHALL |
| MVR-7 | «… SHALL …» | SHALL |

(Note: actual MVR text per `standard/00-introduction.md` §0.5; Phase 1 audit зафиксировал 9 SHALL + 1 MUST в `standard/00` (10 total RFC-2119 keywords).)

### §2.6.2 Migration target

| MVR | Migration target (RU canonical) |
|---|---|
| SHALL be unambiguously identifiable | обязан иметь однозначный идентификатор |
| SHALL trace to parent | должен прослеживаться до родителя |
| SHALL ... | должен ... / обязан ... (по contract semantics) |

**Convention:** для MVR table — `обязан` preferred (substrate-contract obligation tone), `должен` — fallback when «обязан» reads awkward.

### §2.6.3 Migration procedure

Phase 5 chapter pass на `standard/00-introduction.md`:

1. **Pre-migration snapshot:** save current MVR table verbatim.
2. **Translate per §2.6.2 mapping** — manual per-row.
3. **Cross-ref check:** какие задачи / другие главы ссылаются на MVR (по EN keyword) — обновить refs.
4. **ISO 29148 cross-link:** добавить footnote `[¹]` к таблице — «Каждый MVR соответствует RFC-2119 SHALL per ISO/IEC/IEEE 29148:2018 §5.2.1.» Cross-link to `standard/02-normative-refs.md`.
5. **Quality check:** `node scripts/validate-frontmatter.js` + reread end-to-end ([memory #31 принцип 6](#)).

## §2.7 reference/04 descriptive carve-out

`reference/04-ai-style-guide.md` line 171 содержит 3 EN RFC-2119 keywords (`MUST NOT=1`, `MUST=2`) в **descriptive** контексте (mentions RFC 2119 vocabulary, не uses normatively).

### §2.7.1 Rule

**Descriptive mention** RFC-2119 keywords в reference / guide / core главах — **разрешено**, при условии:

1. Контекст явно descriptive: «RFC 2119 определяет `MUST` как absolute requirement» — это про-RFC reference, не RENAR normative clause.
2. Keyword обёрнут в `code-fence` (`` `MUST` ``) либо в blockquote / EN-citation context.
3. Phase 5 chapter pass distinguishes — descriptive mention не migrates на «должен», keeps EN form.

### §2.7.2 Treatment в `reference/04`

`reference/04-ai-style-guide.md` line ~171 — keep EN UPPERCASE forms (descriptive context). Phase 5 chapter pass не trogает.

**Verification:** Style Guide §2.7 explicit carve-out; subagent invocations в Phase 5 на reference/04 — pass §2.7 as constraint.

## §2.8 EN UPPERCASE migration plan (15 occurrences)

Phase 1 audit ([style-inconsistencies §3.1](ru-style-inconsistencies.md#31-a-rfc-2119-keywords)) фиксирует 15 EN UPPERCASE в 3 файлах. Per §2.6-§2.7 — migration / carve-out:

| File | EN total | Treatment | Status |
|---|---:|---|---|
| `standard/00-introduction.md` | 10 (1 MUST + 9 SHALL) | Migrate per §2.6 → RU lowercase | Pending Phase 5 |
| `standard/01-scope.md` | 2 (1 MUST + 1 SHALL) | Migrate → RU lowercase | Pending Phase 5 |
| `reference/04-ai-style-guide.md` | 3 (1 MUST NOT + 2 MUST) | Keep — descriptive carve-out §2.7 | No action |

**Net migration:** 12 occurrences → RU lowercase; 3 keep EN (descriptive).

### §2.8.1 Phase 5 priority order

Per editorial-audit §6 — recommended order:

1. `reference/01-glossary.md` (Phase 1.5 reconciliation prerequisite).
2. `standard/01-scope.md` (2 MUST/SHALL — small-scope migration combined with other Phase 5 work).
3. `standard/00-introduction.md` (10 SHALL → §2.6 MVR migration — substantial work, dedicated commit).

`reference/04-ai-style-guide.md` — отдельная задача (descriptive carve-out documentation), low priority.

### §2.8.2 Verification post-migration

After Phase 5 migration:

1. Grep `\b(MUST|SHALL|SHOULD|MAY)\b` in `standard/` — should return only `reference/04` matches (descriptive).
2. Grep `\b(должен|обязан|следует|может|рекомендуется|допускается|запрещено)\b` in `standard/` — expected count ≥276 (current 261 + ~15 migrated).
3. Manual diff review per [memory #31 принцип 6](#) (word-count delta sanity).

## §2.9 Negation patterns — canonical forms

§2.3.4 фиксирует negation forms. §2.9 expanding на edge cases.

### §2.9.1 Direct negation pattern

| Positive form | Direct negation |
|---|---|
| должен Y | не должен Y |
| обязан Y | не обязан Y / освобождён от Y |
| следует Y | не следует Y |
| может Y | не может Y / лишён права Y |
| допускается Y | не допускается Y / запрещено Y |
| требуется Y | не требуется Y |

### §2.9.2 Idiomatic negation

| Idiom | Discrimination |
|---|---|
| `запрещено Y` | Absolute prohibition (MUST NOT level), emphatic. Used for hard rules. |
| `недопустимо Y` | Equivalent `запрещено`, normative-flavored adjective. |
| `не подлежит Y` | Specialized: removes object from scope of Y. «X не подлежит modification» = MUST NOT modify X. |
| `исключается Y` | Removes Y from consideration; ≈ MUST NOT, applied to actions / options. |

### §2.9.3 Negation anti-patterns

❌ Anti-patterns to avoid:

- `должен не Y` (orphan negation) — replace with `не должен Y` (proper Russian) or `должен исключить Y` (rephrase).
- `не разрешён Y` — non-canonical, prefer `не допускается Y` или `запрещено Y`.
- Double negation in normative («не может не Y») — replace with positive («должен Y»).
- `обязан не Y` — replace with `не должен Y` или `запрещено Y`.

## §2.10 Validation

Phase 5 chapter pass обязан выполнить per главу:

### §2.10.1 Automated checks

1. **EN UPPERCASE residual scan:** grep `\b(MUST|MUST NOT|SHALL|SHALL NOT|SHOULD|SHOULD NOT|MAY|RECOMMENDED|NOT RECOMMENDED|REQUIRED|OPTIONAL)\b` — expected: 0 в `standard/`, controlled count в `reference/04` (descriptive).
2. **RU UPPERCASE scan:** grep `\b(ОБЯЗАН|ДОЛЖЕН|СЛЕДУЕТ|МОЖЕТ|ЗАПРЕЩЕНО|РЕКОМЕНДУЕТСЯ|ДОПУСКАЕТСЯ|ТРЕБУЕТСЯ)\b` — expected: 0 corpus-wide (§2.1.4).
3. **Modal-verb level integrity:** per-level counts (`должен/обязан/...` MUST; `следует/рекомендуется` SHOULD; `может/допускается` MAY) сохраняются ±0 после Phase 5 pass per chapter.
4. **Future-tense scan:** grep `\bбудет\b|\bбудут\b` в normative clauses — expected only in roadmap / forward-looking sections (§2.4.3).
5. **Indicative drift scan:** grep normative clauses without modal verb — manual review case-by-case (heuristic; precision ~70% per Phase 1 audit).

### §2.10.2 Human spot-check

Per [memory #31 принцип 8](#) — каждый Phase 5 chapter pass проходит spot-check на random 10% modal-verb правок. Spot-check проверяет:

- (a) Modal verb level preserved (§2.5).
- (b) Imperative-mood maintained для normative clauses (§2.4.1).
- (c) Definition form canonical (§2.4.2).
- (d) Future-tense scope (§2.4.3).

### §2.10.3 Phase 3 pilot checkpoint

Pilot chapter (recommend: `standard/03-terms.md` per editorial-audit §3 canonical-voice exemplar):

1. **Apply §2 ruleset** на pilot.
2. **Re-run §2.10.1 automated checks** — verify counts match expectation.
3. **User checkpoint:** review pilot diff (modal-verb level integrity, no semantic downgrade).
4. **Lock-in §2** after pilot approval; Phase 5 commences.

## §2.11 Subagent prompt template

For Phase 5 chapter pass — subagent invocations need explicit §2 reference. Template:

```text
You are performing RU editorial pass on RENAR Standard chapter <X>.

PRIMARY POLICY: reference/06-ru-style-guide.md §2 (RFC-2119 RU wording).

HARD RULES from §2:
- §2.1.4: NO UPPERCASE Russian modals (ОБЯЗАН/ДОЛЖЕН/...). Forbidden.
- §2.2: RU lowercase modals (должен/следует/может/...) are CANONICAL RFC-2119 equivalents.
- §2.5: NO modal verb LEVEL changes (MUST/SHOULD/MAY discrimination preserved).
   - "должен" → "следует" — FORBIDDEN (downgrade).
   - "должен" → "обязан" — OK (same level, synonym choice).
- §2.4.1: Normative clauses use IMPERATIVE-mood (modal verb). Indicative ("X выполняет Y") not for requirements.
- §2.4.3: Future tense ("будет/будут") forbidden in normative clauses.

AI BIAS GUARD: LLM trained on English skews toward "polishing" via semantic downgrade. Watch own output.

Output: per-clause diff with §2 rule cited.
```

## §2.12 AC mapping

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Artifact в `research/`, status:draft | этот файл, frontmatter |
| 2 | Cross-link на §1 + 3 inventories + editorial audit | intro callout + body refs |
| 3 | F2 regime decision + rationale | §2.2.1 (3 options) + §2.2.2 (decision) + §2.2.3 (rationale) |
| 4 | Canonical mapping для всех 11 RFC-2119 keywords | §2.3.1 (MUST/MUST NOT/SHALL/SHALL NOT/REQUIRED) + §2.3.2 (SHOULD/SHOULD NOT/RECOMMENDED/NOT RECOMMENDED) + §2.3.3 (MAY/OPTIONAL) — 11 total |
| 5 | RFC 8174 carve-out для RU | §2.1.3 — explicit policy statement |
| 6 | Strict semantic preservation rule | §2.5.1 (allowed) + §2.5.2 (forbidden) + §2.5.3 (verification) |
| 7 | Tense/mood normative rules | §2.4.1 (imperative) + §2.4.2 (definitions) + §2.4.3 (future) + §2.4.4 (conditional) |
| 8 | MVR table special handling | §2.6 (current state + migration target + procedure) |
| 9 | EN UPPERCASE migration plan для 15 occurrences | §2.8 (per-file treatment) + §2.8.1 (priority order) + §2.8.2 (verification) |
| 10 | Negation patterns canonical | §2.3.4 (top-level) + §2.9.1-§2.9.3 (expanded) |
| 11 | AC mapping table | этот § |
| 12 | Read-only invariant | git status: только новый research/-файл |

## §2.13 Limitations & follow-ups

1. **Draft status.** §2 — Phase 2 draft; Phase 3 pilot checkpoint может потребовать revision (e.g. discover, что `обязан` reads awkward в pilot chapter context — migrate back to `должен`).
2. **Synonym preference per chapter.** §2.3 даёт canonical + synonyms, но **не** dictates per-chapter synonym choice. Phase 5 — editorial judgement в пределах §2.3 (e.g. terminology-chapter может tend к `должен`; substrate-chapter — к `обязан`).
3. **Tense/mood heuristic precision** (§2.10.1.5) — ~70% per Phase 1 audit. Phase 5 chapter pass — manual review каждой flagged clause.
4. **MVR table reading** (§2.6.1) — Phase 1 audit зафиксировал 9 SHALL + 1 MUST; точная attribution per-MVR не сделана. Phase 5 chapter pass на `standard/00` — обязательно сделать exact mapping перед migration.
5. **EN translation deferred.** `standard/en/` (Phase 6/7 epic en-standard) использует EN UPPERCASE convention. §2 — только для RU corpus.
6. **No Phase 5 tooling yet.** §2.10.1 automated checks — manual grep сейчас. Lock-in to `scripts/style-guide-check.js` — future task (same as §1.13.1 limitation).
7. **`конформация` exception (per §1.7.1).** `conformance` (English) — keep latin в substrate-domain (`standard/14`); RU translation `соответствие` — для prose discussion. §2 не overrides §1 exception.

## §2.14 Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Decision #27 «F1 reconciliation = Phase 1.5 prerequisite для Phase 5»
- Phase 1 deliverable: [`research/ru-editorial-audit.md`](ru-editorial-audit.md) (F2 systemic finding)
- Source audits:
  - [`research/ru-style-inconsistencies.md §3.1`](ru-style-inconsistencies.md#31-a-rfc-2119-keywords) (RFC-2119 baseline)
  - [`research/ru-style-inconsistencies.md §3.6`](ru-style-inconsistencies.md#36-f-tense--mood-heuristic) (tense/mood baseline)
- Phase 2 §1: [`research/ru-style-guide-draft-section-1-terminology.md`](ru-style-guide-draft-section-1-terminology.md)
- RFC 2119 ([https://www.rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119))
- RFC 8174 ([https://www.rfc-editor.org/rfc/rfc8174](https://www.rfc-editor.org/rfc/rfc8174))
- ISO/IEC/IEEE 29148:2018 §5.2.1 (cited в `standard/02-normative-refs.md` for MVR mapping)
