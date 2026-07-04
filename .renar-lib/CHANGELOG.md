# RENAR Changelog

## EN edition (2026-06-06) — epic `en-translation`

Полное второе языковое издание стандарта на английском, добавлено рядом с первичным RU-корпусом (RU остаётся primary). Корпус стал bilingual.

- **EN-фундамент:** EN Style Guide (`reference/en/06-en-style-guide.md` — зеркало RU-стайл-гайда с инвертированной полярностью RFC-2119: EN UPPERCASE canonical, RU lowercase только в цитировании); EN-глоссарий (`reference/en/01-glossary.md`); конвенция директории `<секция>/en/<имя>.md` (ADR/decision #80); «ТЗ» → `TZ` (латиница, совпадает с ID `TZ-YYYY-NNN`).
- **Перевод:** `standard/en/` (16 файлов: 00–14 + README), `reference/en/` (12), `core/en/` (2), `guide/en/` (12). Faithful native-English; канон-идентификаторы (BR/SR/SPEC-*/TC/ADAPT/QG/MVR/V1–V6/статусы/поля) латиницей в обоих изданиях; §1.15-термины — нативный английский (manifest/conformance/provenance/adversarial review/lifecycle/…); RFC-2119 RU lowercase → EN UPPERCASE с сохранением уровня.
- **Гейты EN:** RU-scoped проверки (`check-substrate-term`, `check-process-vocab`, bucket-a/-e в `style-guide-check`) исключают `lang:en`; `check-rfc-modals` — двойной инвентарь RU/EN; новый `check-en-parity.js` — двусторонний паритет (наличие counterpart + совпадение множества §-номеров), в `check:all`.
- **Интеграция:** EN PDF (`build-pdf-en.js` + `pdf-manifest-en.json`, npm `pdf:en`, 4 документа); bilingual site (Astro i18n: `/en/` маршруты, переключатель RU↔EN, hreflang, RU default); cross-section ссылки EN-издания перенацелены на EN-аналоги (`scripts/repoint-en-crosslinks.js`).
- **Версия-веха:** EN-перевод выполнен → снят блокер для bump v1.0 (остаётся согласование партнёров).

## v1.0 (pending release; release date set at tag-v1)

> Финальная нормативная форма стандарта. Замораживает schemas, closed lists, lifecycle и conformance procedures. После релиза изменения — только через явный RFC с bump major version (v2.0+) или patch updates (v1.0.x для editorial corrections).

### Standard (15 normative chapters)

Полный 15-главный нормативный текст в `standard/`:

- **§00 Introduction** — MVR + drift taxonomy.
- **§01 Scope** — closed lists + negative scope.
- **§02 Normative references** — ISO/IEC, GDPR, AI Act, SAFe 6.0, и др.
- **§03 Terms and definitions** — глоссарий + canonical-only принцип.
- **§04 Roles** — RACI + dual-signature ADAPT.
- **§05 Methodology positioning** — три принципа (SoT inversion, waterfall-form, substrate-agnostic).
- **§06 Requirements hierarchy** — ТЗ → ADAPT → BR → SR → TR + frontmatter schemas.
- **§07 ADAPT** — bridge artefact, forward + backward, double signature.
- **§08 Specifications** — closed list 9 SPEC типов (ARCH/API/DATA/INT/PROC/UI/AI/SEC/OPS); specifications as parallel axis через `constrained-by[]` / `implements-spec[]`.
- **§09 Test cases** — first-class TC, closed list `tc-type` (acceptance/ux/system/contract/eval/security), pos/neg парность, VLM-judge, eval judge isolation.
- **§10 Lifecycle и Quality Gates** — состояния и переходы; QG-0 / QG-1 / QG-2 / QG-3 / QG-4.
- **§11 Substrate versioning** — capability V1-V6 (substrate-agnostic).
- **§12 Maturity model** — closed list уровней RENAR-1 (Ad-hoc) → RENAR-5 (Optimized).
- **§13 Metrics** — RDLT, Coverage Velocity, Hallucination Rate, Acceptance Coverage Rate, Multi-Model Disagreement Rate, и др.
- **§14 Conformance** — manifest schema, self-assessment, third-party assessment, re-assessment cadence.

### Core

- `core/renar-core.md` (~426 lines) — gentle single-doc введение: 5 правил + ADAPT + 2 QG + walkthrough.

### Reference (8 appendices)

- `reference/01-glossary.md` — компактный глоссарий.
- `reference/02-schemas.md` — frontmatter schemas.
- `reference/03-ai-risk-register.md` — AI risk register (14 AIR).
- `reference/04-ai-style-guide.md` — AI provenance + style.
- `reference/05-knowledge-graph-schema.md` — KG schema.
- `reference/06-ru-style-guide.md` — RU editorial rules.
- `reference/07-iso29148-trace-matrix.md` — ISO 29148 mapping.
- `reference/08-conformance-self-assessment.md` — printable conformance kit.

### Guide (11 practical chapters)

- `guide/00-quickstart.md` — 30-минутный hands-on.
- `guide/01-walkthrough.md` — полный example (Login Flow для AcmeCorp).
- `guide/02-transition-guide.md` — поэтапная миграция RENAR-1 → RENAR-5.
- `guide/03-tool-guide-git.md` — substrate-specific guide на git.
- `guide/04-document-store-substrate.md` — informative обзор V1–V6 на document-oriented store.
- `guide/05-safe-comparison.md` — mapping RENAR ↔ SAFe 6.0.
- `guide/06-compliance.md` — mapping на compliance фреймворки + printable checklists.
- `guide/07-failure-modes.md` — 8 классов дрифта + 14 AI-рисков.
- `guide/08-developer-guide.md` — practical guide для разработчиков.
- `guide/09-worked-examples.md` — библиотека E2E-примеров.
- `guide/10-migration-v1.md` — миграция deprecated типов на v1.0-draft.

### v1.0-draft hardening P1 (2026-05-22)

- Agent adversarial review: `research/ru-agent-adversarial-review.md`, findings `research/internal/agent-review-2026-05-22.md`.
- `guide/09` — E4 (webhook/API), E5 (SPEC-AI eval), E6 (delta-ТЗ dispute).
- `guide/06 §11.1` — GDPR/ФЗ-152 evidence pack templates.
- Decision trees (informative): `standard/09 §9.1.1`, `standard/10 §10.1.1`.

### v1.0-draft hardening (2026-05-22)

- `scripts/validate-schema-examples.js` — YAML example drift gate vs reference/02.
- `scripts/check-site-parity.js` — hero counts vs mkdocs nav.
- Anchor fixes: `standard/03 §3.11.5`, `guide/02`, `reference/04`, `reference/07`.
- `research/ru-external-review-kit.md` + `.gitlab/issue_templates/renar-external-review.md`.
- Site: hero 11 guides / 9 reference; llms.txt updated.

### Site infrastructure

- Astro static site (`site/`) — renar.tech, RU primary, EN deferred.
- Docker dev environment (`docker-compose.yml`) — local dev на порту 4321.
- `scripts/sync-site-content.js` — синхронизирует `{standard,guide,reference,core}/*.md` → `site/src/content/`.
- `scripts/add-chapter-frontmatter.js` — backfill helper для chapter frontmatter.
- Astro content collection schema валидирует chapter frontmatter (title / description / order / lang / version).

### Migration notes от v0.1-draft → v1.0

Несовместимые изменения терминологии (см. [standard/03 §3.14](standard/03-terms.md)):

| Deprecated (v0.1-draft) | Canonical (v1.0) | Notes |
|---|---|---|
| `INT-SR` (Integration SR) | `SR` с `constrained-by: [SPEC-INT-N]` | Интеграционные требования — обычный SR с ссылкой на SPEC-INT |
| `INT-TC` (Integration TC) | `TC` с `tc-type: contract` | Контрактные тесты получили явный `tc-type` |
| `AIC` (AI Concept) | `SPEC-AI` (§8.5.7) | AI use cases — один из 9 SPEC типов |
| `UIC` (UI Concept) | `SPEC-UI` | UI/UX baselines — отдельный SPEC тип |
| `TS` (Technical Specification) | `SPEC-ARCH` или `SPEC-OPS` | По содержанию (архитектурная vs операционная) |
| `TM` (Module/Submodule SR) | `SR` с `level: module` | Уровень указывается полем, не отдельным типом |

Существующие проекты на v0.1-draft могут оставаться там — RENAR Standard поддерживает major version concurrency. Миграция на v1.0:

1. Заменить deprecated имена файлов / папок на canonical (мaintain ID stability через `legacy-id` поле во frontmatter если требуется).
2. Обновить `constrained-by[]` / `verifies[]` cross-references.
3. Bump frontmatter `version: "1.0-draft"` → `version: "1.0"`.
4. Перепубликовать conformance manifest с новой версией.

### Closed list changes

Закрытые списки финализированы:
- 9 SPEC типов (`SPEC-{ARCH,API,DATA,INT,PROC,UI,AI,SEC,OPS}`).
- 6 `tc-type` значений (`acceptance / ux / system / contract / eval / security`).
- 5 maturity levels (`RENAR-1` через `RENAR-5`).
- 5 base статусов (`draft / approved / verified / deprecated / obsolete`).
- 5 QG (`QG-0 / QG-1 / QG-2 / QG-3 / QG-4`).

Project-local создание новых типов запрещено (`§14.3.4`). Расширения только через RFC + новый major version стандарта.

### Contributors

- **Vadim Soglaev** — author, normative GAP analysis and partner review.
- **Andrey Yumashev** — author, RENAR Standard editor, project lead.
- **AI collaborators** — Claude Opus / Sonnet (Anthropic) для генерации drafts, normative chapters, и review.

Спасибо ревьюерам черновиков и членам Andersen Stack team за feedback на партнёрском workflow patterns (research drafts 00, 06, 13).

### License

CC BY-SA 4.0 (наследовано из SENAR). Используется для всех текстов стандарта, guide, reference и core.

---

## v1.0-draft (in progress, 2026-05-21)

### Foundation
- 19 research drafts in `research/` covering vision, positioning vs world standards, agent-driven principles, maturity, metrics, glossary, multi-perspective review, AI style guide, SAFe/compliance mappings, AI risk register, elicitation, solution evaluation, worked example, requirement schema, lifecycle, knowledge graph, methodology positioning, specifications, ADAPT
- Skeleton structure for `standard/` (15 chapters), `guide/` (8 guides), `reference/` (5 appendices), `core/` (1 doc) created
- Scope v1.0 = 15 chapters confirmed by partner 2026-05-13
- LICENSE CC BY-SA 4.0 adopted (inherited from SENAR)

### Approved drafts (по итогам ревью партнёра 2026-05-13)
- **Draft 17** — Specification Schema and Templates: closed list of 9 SPEC types (ARCH/API/DATA/INT/PROC/UI/AI/SEC/OPS); specifications as parallel axis to requirements via `constrained-by[]` graph edges
- **Draft 18** — ADAPT: intermediate artifact between immutable TZ and BR/SR/SPEC; forward interpretation + backward findings with lifecycle (7 categories); client + architect double signature for approval
- **Draft 19** — Methodology Positioning: three principles — (1) SoT inversion (requirements, not code; Spec-Driven Development); (2) waterfall-form ≠ classical waterfall (4 differentiations); (3) substrate-agnostic versioning (V1-V6 capabilities)

### Renamed (earlier)
- Standard renamed REQ → RENAR (Requirements Engineering & Normative Adaptive Regulation)

### Phase 5 cleanup (2026-05-13)
- **E4 legacy cleanup:** удалены 4 legacy normative-документа из корня — содержание уже зафиксировано в `standard/00-14`:
  - `requirements-methodology.md` → перенесено в `standard/03` (terms), `standard/04` (roles), `standard/05` (methodology positioning), `standard/06` (hierarchy)
  - `requirements-storage-standard.md` → перенесено в `standard/06` (hierarchy), `standard/08` (specifications), `standard/10` (lifecycle/QG)
  - `testing-methodology.md` → перенесено в `standard/09` (test-cases)
  - `developer-guide-requirements.md` → мигрирован в `guide/08-developer-guide.md` (practical guide, не normative)

### TODO (Phase 5 onwards)
- Phase 5: senar-parity (site/, docs/, README.ru.md, RENAR-SUMMARY*.md, Dockerfile/CI) — epic `phase-5-senar-parity`
- EN translation parallel to RU (deferred)
- Site at renar.tech (E7, planned)
- PDF generation pipeline
- Generalization guide/08-developer-guide.md от Kibertum/andersen-specific examples к generic placeholders (follow-up)
