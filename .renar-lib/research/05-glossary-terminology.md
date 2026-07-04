# Глоссарий и terminology authority REQ

> Версия: черновик 0.1 | Дата: 2026-05-03
> Назначение: единый источник терминов REQ; mapping на SENAR (русский), Raven (latin), ISO/IEC 29148, BABOK, SAFe, ISTQB. Снимает класс «terminological drift» (см. [00-architecture-vision.md §7.5](00-architecture-vision.md)).

---

## 1. Принцип

RENAR **выбирает один canonical термин** на одну концепцию. В коде, UI, скриптах используется только canonical. Mappings — для документации и интеграции с внешними стандартами.

Если термин используется неправильно (по mapping-таблице — не canonical) — CI helper выдаёт warning при ревью PR.

---

## 2. Canonical термины REQ + mapping

### 2.1 Уровни требований

| REQ canonical | SENAR (RU) | Raven enum | ISO/IEC 29148 | BABOK | SAFe |
|---|---|---|---|---|---|
| **BR** (Business Requirement) | БТ (Бизнес-требование) | `BT` | Business Requirement | Business Need | Portfolio Epic / Strategic Theme |
| **SR** (System Requirement) | СТ (Системное требование) | `ST` | System Requirement / Software Requirement | Solution Requirement (Functional) | Feature |
| **TM** (Module/Submodule SR) | СТ модуля | `TM` | (n/a — extension) | (sub-component scope) | Story (sometimes) |
| **TR** (Task Requirement) | ТЗ (Требование к задаче) | `TK` | Implementation Requirement | Transition Requirement | Story |
| **UIC** (UI Concept) | UIC | (extend) | (между BR/SR — design specification) | Stakeholder Requirement (UX subset) | (n/a — design level) |
| **AIC** (AI Concept) | AIC | (extend) | (n/a — REQ-extension) | (n/a) | Enabler |
| **INT-SR** (Integration SR) | INT-СТ | (related) | Interface Requirement | Solution Interface | Cross-feature integration |
| **TC** (Test Case) | ТК | `test_case` (TODO в Raven) | Test Case (verifiable item) | Verification | Story acceptance test |
| **TS** (Technical Specification) | ТС | (extend) | Design Description | Solution Component | Enabler tech spec |

**Правило**: в `.req/` файлах в frontmatter `id` — canonical (BR-01, SR-05). В Raven — latin enum (BT, ST). При импорте/экспорте между substrate — mapping применяется автоматически.

### 2.2 Lifecycle статусы

| REQ canonical | Raven | ISO/IEC 29148 | CMMI |
|---|---|---|---|
| `draft` | `draft` | proposed | identified |
| `approved` | `approved` | agreed-to / baselined | committed |
| `verified` | `verified` (extend Raven enum) | verified | validated |
| `deprecated` | `obsolete` | retired | obsolete |
| `replaced` (через `replaced-by`) | (через `replaces`) | superseded | superseded |

### 2.3 Quality Gates

| REQ canonical | SENAR | Raven | CMMI activity |
|---|---|---|---|
| `QG-0` (Context Gate) | QG-0 | `VK-1` (start) | Requirements check before commitment |
| `QG-1` (Requirements Gate) | QG-1 | `VK-1` | Requirements baseline |
| `QG-2` (Implementation Gate) | QG-2 | `VK-2` | Verification |
| `QG-3` (Verification Gate) | QG-3 | `VK-3` | Validation |
| `QG-4` (Acceptance Gate) | QG-4 | `VK-4` | Customer acceptance |

**Замечание про Raven**: enum `VK-1..VK-4` соответствует RU «Validation Checkpoint». В REQ canonical — `QG-N`. В скриптах конвертация: `QG → VK` через таблицу.

### 2.4 Тестовые типы

| REQ canonical (`tests/TC-*.md` поле `type`) | ISTQB | Описание |
|---|---|---|
| `system` | System Testing | Проверка системного требования |
| `acceptance` | Acceptance Testing | Проверка бизнес-цели (BR) |
| `ux` | (Usability Testing extension) | Проверка UIC через VLM-judge |
| `eval` | (n/a — AI-specific) | Проверка AIC через LLM-judge / metrics |
| `contract` | Component Integration Testing | Проверка INT-SR через Pact |

### 2.5 Артефакты процесса

| REQ canonical | SENAR | Raven | BABOK |
|---|---|---|---|
| `Work Order` / `ТЗ` | (контекст SENAR) | `work_order` | Stakeholder commitment artifact |
| `delta-TZ` / `Дельта-ТЗ` | (context) | `work_order` with `base-document` | Change request |
| `Impact Analysis` | (контекст) | (derived view) | Impact Analysis (BABOK 8) |
| `Spot-check` | (n/a — REQ-extension) | (TODO) | Random sampling QA |
| `Adversarial review` | (через ADR метрику) | (TODO) | Independent verification |
| `Reconciliation` | Quality Sweep (§11.5) | (TODO — automated agent) | Continuous improvement audit |

### 2.6 Роли

REQ **не переопределяет** роли SENAR. Используются canonical SENAR-роли:

| SENAR (canonical для REQ) | Соответствие в REQ-workflow |
|---|---|
| Супервайзер | One-click approver QG-0 / QG-2; spot-check |
| Контекстный архитектор | Декомпозитор ТЗ → BR/SR; tech lead `.req` MR |
| Инженер знаний | Maintainer `requirements-library` |
| Менеджер потока | RTE / SAFe coordinator (Finka в Andersen Stack) |
| Инженер верификации | Owner adversarial critic prompts; spot-check |

Дополнительно (REQ-специфика):

- **AI-агент-генератор** — генерация артефактов, специальный профиль (см. SENAR §5).
- **AI-агент-критик** — adversarial review, обязательно с моделью отличной от генератора.
- **AI-агент-reconciler** — continuous reconciliation, отдельный профиль с правом только генерации MR.

### 2.7 AI-провенанс

REQ-canonical:

- `ai-provenance.generated-by` — модель в формате `<vendor>-<model>-<version>@<date>`. Пример: `claude-opus-4-7@2026-05-03`.
- `ai-provenance.prompt-template` — путь к prompt template в формате `<file>@<version>`.
- `ai-provenance.context-tokens` / `output-tokens` / `generation-time-ms` — численные.
- `ai-provenance.human-edits` — boolean.

Не путать с TAUSIK `senar.tool-calls` (это для tasks, не для requirements).

### 2.8 Связи и ссылки

| REQ canonical (frontmatter) | Назначение |
|---|---|
| `parent` | Родитель в иерархии (BR → SR → TM); один источник |
| `children` | Дочерние артефакты (auto-generated) |
| `verified-by` | TC, верифицирующие требование (auto-derived) |
| `verifies` (в TC) | Требования, которые TC покрывает (с `requirement-version`) |
| `derived-from` | Шаблон-источник (template-id + version + library commit) |
| `derived-from-uic` (в SR) | UIC, из которого выведен SR |
| `derived-from-tz` (в BR/SR) | ТЗ, из которого выведено требование, со ссылкой на section/line |
| `replaces` / `replaced-by` | Замена при deprecate |
| `supersedes` (в новом) | Какое требование заменяется |
| `linked-tasks` (через runtime) | Tasks, реализующие SR (TAUSIK DB или Raven) |
| `automation.location` (в TC) | Адрес реализации теста в `.src` |
| `last-run` (в TC) | Результат последнего прогона теста |

### 2.9 Имена файлов

| Тип | Шаблон | Пример |
|---|---|---|
| BR | `br/BR-NN-<slug>.md` | `br/BR-01-notification-capture.md` |
| SR | `sr/SR-NN-<slug>.md` | `sr/SR-05-notification-feed.md` |
| SR подсистемы | `sr/<MODULE>-SR-NN.N-<slug>.md` | `sr/WMS-SR-01.2-pick.md` |
| UIC | `ui-concepts/UIC-NN-<slug>.md` | `ui-concepts/UIC-02-notification-feed.md` |
| UIC сквозной | `ui-concepts/UIC-00-cross-cutting.md` | `ui-concepts/UIC-00-cross-cutting.md` |
| INT-SR | `int-sr/INT-SR-NN-<slug>.md` | `int-sr/INT-SR-01-princess-gerda.md` |
| AIC | `ai-concepts/AIC-NN-<slug>.md` | `ai-concepts/AIC-01-rag-strategy.md` |
| TS | `tech-specs/TS-NN-<slug>.md` | `tech-specs/TS-03-db-schema.md` |
| TC | `tests/TC-NN-<slug>.md` | `tests/TC-01-login-success.md` |
| INT-TC | `tests/INT-TC-NN-<slug>.md` | `tests/INT-TC-01-pact-princess-gerda.md` |
| ТЗ | `tz/TZ-YYYY-NNN.md` | `tz/TZ-2026-001.md` |
| ТЗ-индекс | `tz/TZ-YYYY-NNN-index.md` | `tz/TZ-2026-001-index.md` |
| Дельта-ТЗ | `tz/TZ-YYYY-NNN-delta.md` | `tz/TZ-2026-002-delta.md` |
| UX-эталон | `ai-concepts/baselines/UIC-NN-<scenario>.png` | `ai-concepts/baselines/UIC-02-feed-default.png` |
| Eval-датасет | `ai-concepts/eval-datasets/AIC-NN-<slug>.jsonl` | `ai-concepts/eval-datasets/AIC-01-typical-queries.jsonl` |

### 2.10 Тэги MR / commit messages

| Tag | Назначение | Кто использует |
|---|---|---|
| `[delta:TZ-YYYY-NNN]` | Изменение по дельта-ТЗ | архитектор |
| `[test-spec-change]` | Изменение Pass/Fail-критериев TC | требует отдельного approval |
| `[baseline-update]` | Обновление baseline для UX/eval | требует approval |
| `[coverage]` | Bot-commit COVERAGE/TEST-PLAN/REQUIREMENTS regeneration | бот |
| `[reconciliation]` | MR от reconciliation-агента | reconciliation бот |
| `[multi-model-disagreement]` | BR с расхождением моделей | требует архитектора |
| `[AI]` | Префикс коммитов от AI-агента | в коммитах в feat/change ветках |

---

## 3. Запрещённые/устаревшие термины

RENAR **не использует** следующие термины (даже если они есть в SENAR / литературе):

| Термин | Что вместо | Почему |
|---|---|---|
| «User Story» как требование | SR | Story — единица планирования, не требование. Story может реализовывать SR. |
| «Use Case» (формально) | UIC + SR | Use case mixes UX и behavior — REQ разделяет UIC (UX) и SR (поведение) |
| «Spec» | requirement / SR / BR | «Spec» неоднозначно. Используем точные термины. |
| «Бизнес-логика» | SR | «Бизнес-логика» термин кода, не требований. |
| «Функциональность» | SR / TR | Слишком широкое. |
| «Фича» | Feature (в SAFe сленге) или SR (в REQ) | Mixed Russian/English. |
| «Хотелка» | (никогда) | Договорный документ так не пишется. |
| «Эпик» (как требование) | BR (бизнес-уровень) или Portfolio Epic (если SAFe) | Epic — единица планирования, не требование. |

При обнаружении этих терминов в `.req` файлах — pre-commit hook warning.

---

## 4. Mapping для multilingual проектов

Проекты для русскоязычных клиентов могут **отображать** REQ-артефакты с переводом терминов в UI:

| English (canonical) | Russian (для UI) |
|---|---|
| Business Requirement | Бизнес-требование |
| System Requirement | Системное требование |
| Test Case | Тест-кейс |
| Quality Gate | Контрольная точка качества |
| Acceptance | Приёмка |
| Verified | Проверено |
| Approved | Утверждено |
| Deprecated | Устарело |

Это **только UI-перевод**. Frontmatter, ID, файлы — всегда canonical English/латиница.

---

## 5. Versioning глоссария

Глоссарий — самостоятельный документ со своей версией. Изменение canonical термина — major version bump (1.0 → 2.0) + migration script для всех `.req` репо.

Текущая версия: **0.1 (черновик)**.

Открытые вопросы:

- [ ] BR/SR/TR vs БТ/СТ/ТЗ — primary canonical латинское или русское? Для Andersen Stack — не критично, для open source — латиница; для российских договоров — русский. Решение: **canonical латинское, отображение русского — в UI**.
- [ ] `TM` vs нет — действительно ли нужен отдельный уровень TM (модульное СТ), или достаточно naming convention `<MODULE>-SR-NN.N`? Текущее решение: **есть, но используется только для крупных подсистем**.
- [ ] AIC — правильное ли это слово для AI Architecture Concept? Альтернативы: AIA, AAC. Решение: **AIC, для совместимости с уже написанными документами**.
- [ ] Для INT-TC — нужен ли отдельный уровень или хватает INT-SR + соответствующих TC с `type: contract`? Решение: **INT-TC как именование, не отдельный уровень**.

---

## 6. Authority

В случае разногласий по термину:

1. Canonical = то, что в этом документе.
2. Если этот документ молчит — обращаемся к SENAR §3 (терминология).
3. Если SENAR молчит — ISO/IEC 29148.
4. Если 29148 молчит — BABOK v3.
5. Если все молчат — фиксируем выбор в этом документе через PR.

Не использовать:
- Тикеты Jira / GitLab / Notion как источник терминов (часто противоречат).
- Чаты команды (slang ≠ canonical).
- Старые презентации (могут быть устаревшие термины).
