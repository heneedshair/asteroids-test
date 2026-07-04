---
title: "RU Tone Sampling — Phase 1 audit"
status: frozen
phase: "Phase 1 input → Phase 2 Style Guide"
epic: ru-normative-pass-v1
task: ru-audit-tone-sampling
scan-date: 2026-05-15
sample-chapters: 4
lang: ru
---

# RU Tone Sampling

> **Read-only qualitative audit.** End-to-end sample-чтение 4-х глав RENAR Standard v1.0-draft по 4 архетипам.
> Не является normative artifact — Phase 1 input для Phase 2 Style Guide. Frozen после publish.
> **Cross-link:** `research/ru-anglicism-inventory.md` (лексика), `research/ru-style-inconsistencies.md` (структура).
> **Bias disclaimer:** single-reviewer audit (LLM Claude Opus 4.7); Phase 2 обязана валидировать human checker'ом.

## 1. Назначение

Лексическая (anglicism inventory) и структурная (style inconsistencies) audits — механические; они находят что повторяется, но не где **тяжело читать**. Этот audit отвечает на качественный вопрос:

- Где тон меняется внутри главы (regime smena лица, register)?
- Где читателю physically тяжело — длинные параграфы, плотные таблицы, нарративный провал?
- Есть ли единый narrative voice по всему стандарту, или каждая глава звучит по-своему?
- Какая глава — best-tone candidate для canonical voice Phase 2 Style Guide?

## 2. Методология

**Sample:** 4 главы из 4 архетипов корпуса:

| Архетип | File | Lines | Words | Архетипное обоснование |
|---|---|---:|---:|---|
| Normative-heavy | `standard/10-lifecycle-qg.md` | 627 | 4 423 | State-machines, pre/post-conditions, gates — densest normative material |
| Terminology-heavy | `standard/03-terms.md` | 414 | 3 105 | Glossary chapter в standard/; canonical definitions |
| Explanatory guide | `guide/01-walkthrough.md` | 781 | 2 775 | End-to-end pedagogical example, 9 фаз narrative |
| Reference catalog | `reference/01-glossary.md` | 318 | 2 551 | Reference glossary с cross-standard mapping |

**Прочтение:** end-to-end, от первой §X до последней; для главы 10 — двумя passes (sections 1-7 + 8-14) из-за объёма.

**7 narrative-flow осей per chapter:**

| Ось | Что отслеживается |
|---|---|
| (a) Voice consistency | 3-е лицо vs обращение к читателю; смена внутри главы |
| (b) Register | formal / informal / mixed; стабильность |
| (c) Paragraph rhythm | средняя длина; chunking; flow между параграфами |
| (d) Density | per-sentence load (concept count, modal verbs) |
| (e) Lexical patterns | штампы, AI-bias маркеры, repeated phrases |
| (f) «Стенающие» места | где читателю тяжело: длинные tables, ASCII диаграммы, dense formal text |
| (g) Narrative arc | есть ли структурный thrust или плоский catalog |

**Non-fabrication guarantee (AC #10):** каждый "weak"/"strong" judgment имеет concrete file:section pointer.

**Stub-replacement (AC #11):** Min ≥300 words; все 4 sampled главы — well above (2551..4423 words). Не было stub-замен.

## 3. Per-chapter findings

### 3.1 `standard/10-lifecycle-qg.md` — Normative-heavy

**(a) Voice consistency:** ✅ Strong. Третье лицо throughout. Subject = «Глава нормирует X», «Артефакт обязан Y», «Substrate обязан Z». 0 уходов в обращение к читателю.

**(b) Register:** ✅ Strong. Однородно formal-normative; читается как ISO-style standard. Ни в одном месте register не съезжает в colloquial.

**(c) Paragraph rhythm:** ⚠️ Tables dominate. Каждый QG-N имеет triple-table pattern (Pre-condition / Post-condition / Триггер); 13-row prohibited-transitions table (§10.12). Между параграфами — короткие connective sentences. Reads как reference, не как narrative.

**(d) Density:** ⚠️ Highest in corpus. Каждый § содержит 3-5 normative claims; «обязан/обязана» появляется ≥1 раз на параграф во многих секциях. Читателю тяжело consume в один присест.

**(e) Lexical patterns:**
- Repeated штампы (правомерные): «Pre-condition / Post-condition» (24 occurrences), «substrate-нативный» (8), «substrate обязан» (15), «закрытый список» (9), «прохождение gate» (5).
- Anglicism cluster: `Pre-condition / Post-condition` (latin-in-RU, 24 occurrences) — потенциальный Phase 5 кандидат на → «Предусловие / Постусловие» (см. anglicism Bucket E).
- `Триггер` (§10.3.x x5) — transliterated; Phase 2 решает keep/rewrite.
- AI-bias: latinisms принимаются непоколебимо («atomic change unit», «state machine», «diff & review»). Согласно memory #31 принципу 8 — это типичный AI-trained-on-English signal.

**(f) «Стенающие» места:**
1. **§10.11.3 Change-of-criteria для TC** (4 numbered substrate requirements) — densest legalese в главе; reader работает.
2. **§10.12 Запрещённые переходы** — 13-row table требует careful row-by-row reading. Format works, но dense.
3. **State-machine ASCII art** в §10.5.1, §10.7.1, §10.8.1, §10.9.1 — readable но требуют concentration; PDF-render может ломать.
4. **§10.13.1 Logging gate-passing events table** — 10 rows × 3 columns, каждое поле с requirement-level.

**(g) Narrative arc:** ⚠️ Linear catalog (intro → 5 gate definitions → 5 state machines → closed-list policy → enforcement → audit log → connections). No thrust beyond «вот таксономия gates». Reads as **reference**, не как didactic chapter.

**Verdict:** Strong consistency, но плотность изматывающая. Подходит как baseline для других normative chapters, но **не** как canonical voice для guide/.

---

### 3.2 `standard/03-terms.md` — Terminology-heavy

**(a) Voice consistency:** ✅ Strong. 100% definitorial-third-person.

**(b) Register:** ✅ Strong. Формальный glossary register. «X — Y, нормированное Z».

**(c) Paragraph rhythm:** ✅ Excellent. Каждый §3.X.Y = один термин + 1-3 sentence definition + cross-ref. Самая readable из normative chapters: pithy, scannable. Reads as reference catalog по design.

**(d) Density:** ✅ Moderate. По 1 концепту на §; cross-ref-heavy но не overwhelming.

**(e) Lexical patterns:**
- Repeated штампы: «closed list» (12 occurrences в RU prose), «canonical» (15+), «substrate-native» (5).
- Anglicism: «canonical» используется как accepted RU-IT term, но frequency высокая — Bucket D кандидат на overuse-check.
- §3.13 mapping tables вводят English terms из других стандартов; здесь mixed-lang ожидаем и justified.

**(f) «Стенающие» места:**
1. **§3.13 Cross-standard mapping** — 4 multi-column tables (RENAR↔SENAR↔ISO 29148↔BABOK↔SAFe). Visually busy, информационно ценны.
2. **§3.14 Запрещённые / устаревшие термины** — 8-row + 9-row tables; полезный contrast но требует concentration.
3. **§3.10.1 ai-provenance canonical schema** — 9-row table с per-field mandatory/optional/seleciton; reads как schema spec.

**(g) Narrative arc:** ⚠️ Catalog by design. §3.2 устанавливает один thrust («canonical-only»), далее — flat application of principle. Подходит как glossary.

**Verdict:** ✅ **Canonical-voice candidate for terminology-style chapters**. Tight, scannable, no waste. Phase 5 chapter pass — можно использовать §3 как stylistic exemplar.

---

### 3.3 `guide/01-walkthrough.md` — Explanatory guide

**(a) Voice consistency:** ⚠️ Mixed. Третье лицо в основной narrative, но множество verbatim CLI-output блоков (`$ tausik req ...`) + agent dialogue (`[claude-opus-4-7] Reading TZ...`) внутри fences. Voice внутри fence != voice prose. Технически OK (fence-content — verbatim), но читатель прыгает между registers.

**(b) Register:** ⚠️ Mixed. Narrative chunks formal-pedagogical («Архитектор открывает изменения»); CLI dumps — technical-verbatim; некоторые connective parts informal («Клиент через неделю»).

**(c) Paragraph rhythm:** ⚠️ Heavy fence:prose ratio. Каждая Phase X (Phase 0..9) имеет 3-5 sub-sections; каждый sub-section содержит 1-2 narrative paragraphs + 1-3 code-fence blocks (часто крупные — 20-50 строк YAML/CLI/code). Reader скансит больше, чем читает.

**(d) Density:** ✅ Low text density (60-70% контента — fences). Narrative chunks short and digestible.

**(e) Lexical patterns:**
- Anglicism heavy: «adversarial review» (untranslated, treated as technical term, 8 occurrences); «whitelist» (4), «recovery» (3), «handoff» — accepted technical loanwords.
- Mixed-lang: «корпоративный admin» (§1.1 line 64) — Russian + Latin без quotes/code-treat. Phase 5 кандидат на rewrite («корпоративный администратор» или «`admin` (corp ticketing)»).
- AI dialogue style: `[claude-opus-4-7] Reading TZ...` — used 20+ times; не нарушение тона если читатель понимает convention.

**(f) «Стенающие» места:**
1. **Phase 3.4** — full SR-01 frontmatter + body — ~50 lines YAML+markdown в одной fence. Полезно как complete example, но visually heavy.
2. **Phase 9 final artifacts tree** — 30-line directory listing с (status: ...) annotations. Полезный summary, но readers могут skip.
3. **Phase 7.1 CI output + bot last-run update** — verbatim CLI dump 11 строк; mostly noise если читатель уже видел pattern.

**(g) Narrative arc:** ✅✅ **Strongest narrative arc из 4 sampled.** Linear story: ТЗ → ADAPT → BR/SR/SPEC → TC → impl → verify → delta → accept. Каждая Phase advances the project. **Pedagogical exemplar** для других guide chapters.

**Verdict:** ✅ **Canonical-voice candidate for guide-style chapters.** Strong narrative; mixed-register justified жанром (worked example), но Phase 5 может trim CLI verbosity где repeats pattern.

---

### 3.4 `reference/01-glossary.md` — Reference catalog

**(a) Voice consistency:** ✅ Strong. Definitorial-third-person.

**(b) Register:** ✅ Strong. Formal-reference, table-heavy.

**(c) Paragraph rhythm:** ⚠️ Tables dominate (12 sub-tables across §2.1-§2.12). Almost no continuous prose. Reads as pure reference, не как narrative.

**(d) Density:** ✅ Cells short (often 1-line). Highly skimmable.

**(e) Lexical patterns:** Mixed canonical conventions — see (f) ниже.

**(f) «Стенающие» места:**

🔴 **CRITICAL FINDING — terminological drift с `standard/03-terms.md`:**

1. **§2.1 «Уровни требований» table** содержит:
   - `TM` (Module/Submodule SR) — указан как canonical level
   - `UIC` (UI Concept), `AIC` (AI Concept), `INT-SR`, `INT-TC`, `TS`
   - **НО** `standard/03-terms.md` §3.14.1 **явно депрекейтит** все эти labels: TM → `SR с level: module`, UIC → `SPEC-UI`, AIC → `SPEC-AI`, INT-SR → `SR с constrained-by: [SPEC-INT]`, INT-TC → `TC с tc-type: contract`, TS → `SPEC-ARCH or SPEC-OPS`.

2. **§2.4 Quality Gates table** содержит **pre-v1.0 gate names**:
   - «QG-0 Context Gate» (старое) — canonical §10.3.1 = **«QG-0 Approval»**
   - «QG-1 Requirements Gate» (старое) — canonical = «QG-1 Implementation»
   - «QG-2 Implementation Gate» (старое) — canonical = «QG-2 Verification»
   - «QG-3 Verification Gate» (старое) — canonical = «QG-3 Architecture»
   - **standard/03-terms.md §3.14.1** явно мапит эти старые имена → canonical v1.0.

3. **§3 cross-standard mapping** propagates те же old names («QG-2 Implementation» → CMMI Verification и т.д.).

4. **§5 Versioning глоссария** — статус «1.0-draft (Phase 7 наполнение)» с open questions — indicates глоссарий не финализирован synchronously со стандартом.

Это **ровно тот класс drift'а**, который RENAR §3.11.5 нормит как terminological drift. Глоссарий — reference, но **расходится с canonical normative**. Reader, читающий glossary без сверки со standard/03-terms, получит **устаревшую** картину.

5. **§2.11 «Имена файлов»** — содержит patterns с UIC/AIC/INT-SR/INT-TC directories, что согласовано с устаревшими labels §2.1.

**(g) Narrative arc:** ⚠️ Catalog-only by design — но catalog drift'нул от source-of-truth (standard/03).

**Verdict:** 🔴 Глоссарий технически читаем и хорошо структурирован, но **terminologically out-of-sync с canonical normative**. **Phase 1.5 / Phase 5 priority:** reconcile reference/01-glossary.md против standard/03-terms.md §3.14.1.

## 4. Cross-chapter comparison

| Ось | `standard/10` | `standard/03` | `guide/01` | `reference/01` |
|---|---|---|---|---|
| (a) Voice | ✅ 3rd, normative | ✅ 3rd, definitorial | ⚠️ Mixed (fence/prose) | ✅ 3rd, definitorial |
| (b) Register | ✅ Formal-normative | ✅ Formal-glossary | ⚠️ Mixed-pedagogical | ✅ Formal-reference |
| (c) Rhythm | ⚠️ Tables/dense | ✅ Pithy | ⚠️ Fence-heavy | ⚠️ Tables-only |
| (d) Density | ❌ Highest | ✅ Moderate | ✅ Low (fences) | ✅ Cells |
| (e) Lexicon | ⚠️ Anglicism cluster | ⚠️ "canonical" overuse | ⚠️ Mixed-lang spots | 🔴 **Terminology drift** |
| (f) Hard spots | §10.11.3, §10.12 | §3.13, §3.10.1 | Phase 3.4, Phase 9 | 🔴 §2.1, §2.4, §3 |
| (g) Arc | ⚠️ Catalog | ⚠️ Catalog | ✅✅ Strong narrative | ⚠️ Catalog |

### 4.1 Canonical-voice candidate per chapter type

| Chapter type | Canonical exemplar | Why |
|---|---|---|
| Normative-heavy (lifecycle/spec/conformance) | `standard/10-lifecycle-qg.md` (style baseline) | Consistent formal voice, structured tables. Phase 5 фокусируется на density-reduction, не на voice changes. |
| Terminology-heavy (terms/glossary normative) | `standard/03-terms.md` | Pithy definitions + cross-ref. Best scan-readability в normative корпусе. |
| Explanatory guide (walkthrough/quickstart) | `guide/01-walkthrough.md` | Strong Phase 0-9 narrative arc. Mixed-register оправдан жанром. |
| Reference catalog (glossary/schemas/risk-register) | `standard/03-terms.md` rather than `reference/01-glossary.md` | reference/01 имеет drift; standard/03 — canonical source. Phase 1.5 reconciliation needed. |

### 4.2 Common findings across all 4

1. **Voice consistency** — 3/4 chapters strong, 1/4 (`guide/01`) mixed but justified by genre.
2. **Latinisms accepted unapologetically** — «substrate», «state machine», «atomic change unit», «diff & review», «adversarial» — all 4 chapters use без quoting/translation. AI-bias signal per memory #31. Phase 2 Style Guide должен явно зафиксировать «accepted technical loanwords» whitelist.
3. **Anglicism mood: pre/post-condition + триггер cluster** — appears as section-label pattern в standard/10; Phase 5 кандидат на RU-equivalent если Style Guide §X.Y решит.
4. **No chapter has narrative voice problems internal** — voice issues все cross-chapter (drift), not intra-chapter.
5. **Density** — only standard/10 strong density issue; others digestible.

## 5. Top-12 prioritized findings

Priority: 🔴 High = blocking Phase 5 chapter pass; 🟠 Mid = needed но не блокер; 🟢 Low = polish.

| # | Priority | File:Section | Finding | Phase 2/5 action |
|---|---|---|---|---|
| 1 | 🔴 High | `reference/01-glossary.md` §2.1 | TM/UIC/AIC/INT-SR/INT-TC/TS treated as canonical, но `standard/03-terms` §3.14.1 explicitly депрекейтит | Reconcile glossary — replace legacy labels c canonical v1.0 (SPEC-UI/SPEC-AI/SR с constrained-by) |
| 2 | 🔴 High | `reference/01-glossary.md` §2.4 + §3 | QG-N gate names **pre-v1.0** (Context/Requirements/Implementation/Verification/Acceptance); standard/03 §3.14.1 mapping предписывает canonical (Approval/Implementation/Verification/Architecture/Acceptance) | Reconcile QG-N table; propagate во все mapping-tables §3 |
| 3 | 🔴 High | `reference/01-glossary.md` §5 | Status «1.0-draft (Phase 7 наполнение)» с open-questions list | Decision: либо finalize до v1.0, либо явно mark non-normative |
| 4 | 🟠 Mid | `standard/10` §10.3.x labels | «Pre-condition / Post-condition / Триггер» — anglicism cluster в section labels (24+5+5 occurrences) | Phase 2 decide: keep / «Предусловие / Постусловие / Триггер» / «Предусловие / Постусловие / Запуск» |
| 5 | 🟠 Mid | `standard/10` §10.11.3 | «Change-of-criteria для TC» — densest legalese в главе (4 numbered substrate requirements) | Phase 5: trim to 3 sentences + bullet list; preserve normative semantic |
| 6 | 🟠 Mid | `standard/10` §10.12 + §10.13.1 | 13-row prohibited-transitions table + 10-row logging-fields table — visually busy | Phase 5 keep но split into multi-line cells for PDF readability |
| 7 | 🟠 Mid | `guide/01` §1.1 line 64 | «корпоративный admin» (mixed-lang) | Phase 5 → «корпоративный администратор» or `\`admin\`` (code-format) |
| 8 | 🟠 Mid | `guide/01` Phase 3.4 | 50-line SR-01 frontmatter+body fence — visually heavy | Phase 5: split into 2 fences (frontmatter / body) с одной prose sentence между |
| 9 | 🟠 Mid | `standard/03` §3.2 «canonical» overuse | «canonical» использован 15+ раз в RU prose | Phase 5: оставить в ключевых positions (§3.2 principle), reduce repetition |
| 10 | 🟢 Low | All 4 chapters | Latinisms «substrate / state machine / atomic change unit / adversarial» accepted unapologetically | Phase 2 Style Guide §X фиксирует accepted-loanwords whitelist (technical vocabulary) |
| 11 | 🟢 Low | `standard/10` §10.13.1 fields table | «evidence-refs» field — anglicism в RU column | Phase 2: либо «evidence-refs» (latin OK as field-name), либо «evidence-ссылки» |
| 12 | 🟢 Low | `guide/01` Phase 7.1 | Verbatim CI dump 11 строк после Phase pattern уже установлен | Phase 5: trim до first 3 lines + «... (см. полный output в research/example-runs/)» — keep pedagogical concept, reduce noise |

## 6. Cross-link с parallel Phase 1 audits

| Phase 1 audit | Overlap с этим audit'ом |
|---|---|
| `research/ru-anglicism-inventory.md` Bucket A (technical identifiers — substrate/hook/commit) | Подтверждено — все 4 chapters use unapologetically (наблюдение §4.2.2) |
| `research/ru-anglicism-inventory.md` Bucket E (имплементация→реализация candidates) | Подтверждено — standard/10 + standard/03 содержат accepted кальки |
| `research/ru-style-inconsistencies.md` (a) RFC-2119 | standard/10 — pure RU lowercase modal verbs; reference/01 не использует RFC-2119 keywords (no SHALL there) — split confirmed |
| `research/ru-style-inconsistencies.md` (b) Citations | standard/10 имеет bare-§ references — confirmed в personal read (§10.5 references «§10.3», «§11.3.5» bare) |
| `research/ru-style-inconsistencies.md` (c) Code-fences | guide/01 — 20+ fences, mostly typed (yaml/bash); confirmed |

## 7. AC mapping

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Artifact в `research/` | `research/ru-tone-sampling.md` (этот файл) |
| 2 | Покрытие 4 архетипов | §2 table: standard/10 (normative) + standard/03 (terminology) + guide/01 (explanatory) + reference/01 (reference) |
| 3 | End-to-end чтение | §3.1-§3.4 содержат findings из всех § каждой главы (lines 1..end) |
| 4 | 7 narrative-flow осей per chapter | §3.1-§3.4 каждая глава покрывает (a)-(g) |
| 5 | Cross-chapter comparison | §4 матрица + §4.1 canonical candidates + §4.2 common findings |
| 6 | Top-12+ findings с file:section | §5 — 12 entries с File:§ pointers и Phase 2/5 actions |
| 7 | Cross-link с anglicism + style-inconsistencies | §6 таблица overlap |
| 8 | Read-only invariant | git diff: только новый research/ru-tone-sampling.md |
| 9 | Frozen frontmatter | `status: frozen`, `phase: Phase 1 → Phase 2`, `epic` в YAML |
| 10 | Bias disclaimer + concrete examples | Intro callout «Bias disclaimer» + каждое «weak»/«strong» judgment имеет file:§ pointer |
| 11 | Stub-replacement | §2 word-counts table: все ≥2551 words, well above 300 stub threshold; no replacement needed |

## 8. Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Sister Phase 1 audits: `research/ru-anglicism-inventory.md`, `research/ru-style-inconsistencies.md`
- Source chapters (read-only):
  - `standard/10-lifecycle-qg.md` (627 lines)
  - `standard/03-terms.md` (414 lines)
  - `guide/01-walkthrough.md` (781 lines)
  - `reference/01-glossary.md` (318 lines)

## 9. Limitations & follow-ups

1. **Single reviewer bias.** LLM (Claude Opus 4.7) sampled 4/34 chapters; tone judgments subjective. Phase 2 должна валидировать human checker'ом (особенно §3.4 critical-finding по reference/01 drift).
2. **Sample = 12% корпуса (4/34 files).** Остальные 30 файлов не sampled end-to-end; pattern extrapolation требует caution. Phase 5 chapter pass обеспечит coverage rest.
3. **No sentence-level read-time measurement.** «Стенающие места» — qualitative impressions, не quantified eye-tracking / read-time. Phase 2 может add cognitive-load proxy metrics.
4. **Cross-language-bias.** Reviewer trained on multilingual web; склонен tolerate anglicism heavier than RU-native reviewer. Memory #31 принцип 8 явно flags это — human spot-check обязателен.
5. **`reference/01-glossary.md` drift** — finding #1-3 — наиболее actionable; рекомендуется создать отдельную задачу `ru-reconcile-glossary-vs-standard` в epic ru-normative-pass-v1 как **Phase 1.5 prerequisite** для Phase 2 Style Guide work.
