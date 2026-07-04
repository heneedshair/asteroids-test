# research/ — исследовательские материалы RENARа

> Назначение: материалы для проектирования RENARа. Архитектурное видение, позиционирование, мульти-перспективный обзор, специфика 100% agent-driven контекста, формализации и worked examples.
>
> Эти документы **не являются нормативной частью** RENARа (нормативные — в корне репозитория: `requirements-methodology.md`, `requirements-storage-standard.md`, `testing-methodology.md`, `developer-guide-requirements.md`). Здесь — обоснования, исследования, предложения, которые могут стать нормативными после согласования.

---

## Принцип отделения от SENAR

REQ — **специализация SENAR для управления требованиями**. Каждый документ здесь имеет в начале раздел «Не дублирует SENAR» с явным перечислением что переписывает, что расширяет, что не покрывает.

| Уровень | Что покрывает SENAR | Что добавляет REQ |
|---|---|---|
| Методология | 5 ценностей, 14 правил | Конкретика для требований |
| Quality Gates | QG-0..QG-4 как концепция | State machines, pre/post conditions |
| Метрики | 10 общих | REQ-специфичные доменные метрики |
| Maturity | 5 уровней общей зрелости | REQ-уровни как одна из размерностей |
| Agent instrumentation | Уровни контроля, профили | 7 принципов для requirements generation |
| Роли | 5 ролей SENAR | Не переопределяет; ссылается |

---

## Документы

### Основа (фундаментальные документы)

| # | Документ | Что внутри | Аудитория |
|---|---|---|---|
| 00 | [Архитектурное видение](00-architecture-vision.md) | Что есть, что предлагается, как избегать дрифта (8 классов), two-substrate, two-repo через submodule, дорожная карта, 23 решения к фиксации | Партнёр, архитектор, Tech Lead |
| 01 | [Positioning vs мировые стандарты](01-positioning-vs-world-standards.md) | Mapping REQ ↔ ISO/IEC 29148, ISO 25010, BABOK, PMBOK, SAFe, ISTQB, ISO/IEC 5338, ISO/IEC 23894, NIST AI RMF, CMMI | CTO, руководство, ревьюеры стандарта |
| 02 | [Agent-driven принципы](02-agent-driven-principles.md) | 7 нормативных расширений: model cards, adversarial gate, source citation, multi-model, cost budget, knowledge graph, continuous reconciliation | AI-инженер, архитектор |
| 03 | [Maturity model](03-maturity-model.md) | 5 уровней RENAR-conformance (RENAR-1..RENAR-5) как размерность SENAR maturity, conformance checklist | Руководство, аудитор, PM |
| 04 | [Метрики и outcomes](04-metrics-and-outcomes.md) | Бизнес-outcomes, REQ-специфичные метрики (НЕ дублирующие 10 SENAR-метрик), целевые значения, ROI-модель | Product Manager, CTO |
| 05 | [Глоссарий и terminology authority](05-glossary-terminology.md) | Canonical термины + mapping на SENAR (БТ/СТ), Raven (BT/ST), ISO 29148, BABOK, SAFe | Все |
| 06 | [Multi-perspective review](06-multi-perspective-review.md) | Анализ от 4 senior-ролей (PM, RTE, Tech Writer, Head of Engineering) + синтез из мировых стандартов | Архитекторы, ревьюеры стандарта |
| 07 | [Style Guide для AI-генерации](07-style-guide-ai-generation.md) | Стиль, тон, структура, длина, цитирование source — для AI-агентов, генерирующих BR/SR/TC | AI-инженер, prompt engineer |
| 19 | [Положение в типологии методологий](19-methodology-positioning.md) | Три фундаментальных утверждения: (1) SoT — требования, не код (SDD); (2) waterfall-форма ≠ классический waterfall; (3) версионирование как обязательное substrate-свойство (V1-V6) | Партнёр, CTO, ревьюеры стандарта |

### Драфты предметных стандартов (для обсуждения)

| # | Документ | Что внутри | Закрывает gap из |
|---|---|---|---|
| 08 | [SAFe mapping](08-safe-mapping.md) | REQ ↔ SAFe иерархия, WSJF, PI Planning, ART координация, RACI lifecycle, Built-in Quality | 06 §3 (RTE) |
| 09 | [Compliance mapping](09-compliance-mapping.md) | ISO 27001, GDPR, ФЗ-152, AI Act EU, NIST AI RMF — mapping на REQ-артефакты, self-assessment checklist | 06 §5 (Head) |
| 10 | [AI Risk Register](10-ai-risk-register.md) | 14 AI-рисков по ISO/IEC 23894 + NIST AI RMF, mitigation strategies, severity/likelihood matrix | 01 §3.11 |
| 11 | [Elicitation Workflow](11-elicitation-workflow.md) | AI-driven Socratic Q&A, 5-фазный pipeline, BABOK Elicitation knowledge area | 01 §3.5 (BABOK) |
| 12 | [Solution Evaluation и QG-4](12-solution-evaluation.md) | Acceptance gate нормирование, BABOK Solution Evaluation, business outcome tracking | 01 §3.5 (BABOK) |
| 13 | [Worked example end-to-end](13-worked-example.md) | Полный цикл REQ на примере «Login Flow для AcmeCorp» — от ТЗ до accepted release | 06 §4 (Tech Writer) |
| 17 | [Specification Schema и Templates](17-specification-schema-and-templates.md) | Закрытый список из 9 типов SPEC (ARCH/API/DATA/INT/PROC/UI/AI/SEC/OPS), общая схема + type-specific extensions, граф `constrained-by[]`, миграция UIC/AIC/INT-SR/TS | Архитектор, partner |
| 18 | [ADAPT — двусторонняя адаптация ТЗ](18-adapt-document.md) | Промежуточный артефакт между immutable ТЗ и BR/SR/SPEC: forward интерпретация + backward findings (7 категорий) с lifecycle, двойная подпись клиент+архитектор | Партнёр, архитектор, заказчик |

### Драфты формализаций (для обсуждения)

| # | Документ | Что внутри | Зрелость |
|---|---|---|---|
| 14 | [Requirement Schema](14-requirement-schema-draft.md) | Формальная JSON Schema для BR/SR/UIC/AIC/INT-SR/TS/TC, validation rules, изоморфизм git ↔ Raven | Drafted; нужны pilot-validation |
| 15 | [Requirement Lifecycle](15-requirement-lifecycle-draft.md) | State machines для requirement и test_case, hooks enforcement, transition logging | Drafted; нужно реализовать в TAUSIK skill |
| 16 | [Knowledge Graph Schema](16-req-graph-schema-draft.md) | Node types, edge types, Cypher-style queries, storage strategy, federated queries | Drafted; MVP на RENAR-4 проектах |

---

## Рекомендованный порядок чтения

### Партнёр / клиент стандарта

00 → 19 → 17 → 18 → 03 → 13 → 06.

Сначала видение, потом три фундаментальных утверждения (положение в типологии, SoT, версионирование), потом закрытый список SPEC и ADAPT (которые партнёр приоритизировал), потом видеть путь развития (maturity), потом видеть конкретный пример как это работает, потом — какие gaps нашли независимые ревьюеры.

### Архитектор внедряющий REQ

00 → 02 → 14 → 15 → 16 → нормативные документы в корне.

Видение → принципы → schema → lifecycle → graph → нормативная имплементация.

### Product Manager / CTO

04 → 03 → 09 → 01 → 06.

Outcomes & ROI → maturity → compliance (важно для corporate sales) → positioning vs мировые стандарты → независимые ревью.

### AI-инженер / prompt engineer

02 → 07 → 14 → 16 → нормативные документы.

Принципы → style → schema (что генерировать) → graph (как использовать context).

### SAFe RTE / Project Manager

08 → 03 → 12 → 06 §3.

SAFe mapping → maturity → solution evaluation (QG-4) → review от RTE perspective.

### Compliance / Security officer

09 → 10 → 01 §3.10-3.12 → 14 (data-classification поля).

### Ревьюер стандарта

06 → 01 → 02 → 13 → все остальные по референсу.

---

## Lifecycle материалов research/

Документы в `research/` могут пройти три состояния:

| Состояние | Где живут |
|---|---|
| Исследование (текущее) | `research/` |
| Нормативно зафиксировано | Перенос/extract в корневые документы стандарта (с adapt'ом под нормативный стиль) |
| Отвергнуто | Остаётся в `research/` со статусом `archived: <дата>, reason: <...>` в frontmatter |

Документы здесь **могут противоречить** друг другу (это исследование). После согласования — конкретные секции переносятся в нормативную часть.

---

## Что осталось как TODO

Несмотря на 16 документов, остаются open области:

- **`req-prompts/` библиотека** — версионированные prompt templates для AI-агентов (decompose-tz, generate-sr, generate-tc, critic-review, ...). Это операционный артефакт, не нормативный — место в отдельном репозитории организации.
- **Pilot validation на 1-2 реальных проектах** — RENAR-3 setup на новом проекте, fit-checking драфтов 14/15/16.
- **`requirements-library/`** — стандарт-обёртка над уже существующей идеей шаблонов; нужна организационная инициатива.
- **Hub UI workflows** — design для approval/review/spot-check workflows в Raven Hub. Сначала нужен Raven приёмочно стабилизированный.
- **Migration tooling git ↔ Raven** — после Raven приёмки.

Эти не сделаны сейчас потому что:
1. Зависят от внешних блокеров (Raven, pilot-проект).
2. Не могут быть согласованы абстрактно без real-data validation.
3. Должны идти после того как 16 документов выдержат критику от партнёра.

---

## Метрики самого стандарта (мета)

Что показывает прогресс работы над REQ:

| Метрика | Значение на 2026-05-11 |
|---|---|
| Документов в research/ | 19 + README |
| Совокупно строк markdown | ~7,500 |
| Покрыто senior-перспектив | 4 (PM, RTE, Tech Writer, Head) |
| Mapped мировых стандартов | 11 (ISO 29148, 25010, 25022, BABOK, PMBOK, SAFe, ISTQB, CMMI, ISO/IEC 5338, ISO/IEC 23894, NIST AI RMF) |
| Open questions суммарно | ~80 |
| Готовность к pilot | drafts достаточны для проверки на реальном проекте |
| Готовность к продаже партнёрам | после согласования с Kibertum партнёром и 1-2 pilots |
