# Позиционирование REQ относительно мировых стандартов

> Версия: черновик 0.1 | Дата: 2026-05-03
> Назначение: показать, как RENAR соотносится с established стандартами requirements engineering, quality, AI governance и Agile-фреймворками. Что REQ заимствует, что адаптирует, что не покрывает.

---

## 1. Не дублирует SENAR

| Из SENAR используется без переписывания | Где |
|---|---|
| 5 ценностей и 14 правил | Контекст всего REQ |
| QG-0..QG-4 как концепция | REQ конкретизирует state machine |
| 10 метрик (Throughput, FPSR, DER, KCR, MIR, Cycle Time, ADR, Cost-per-task, Lead Time, Cost Predictability) | REQ добавляет доменные на их фундаменте, см. [04-metrics-and-outcomes.md](04-metrics-and-outcomes.md) |
| 5 уровней зрелости (Стихийный → Оптимизирующий) | REQ-зрелость — одна из размерностей, см. [03-maturity-model.md](03-maturity-model.md) |
| 5 ролей (Супервайзер, Контекстный архитектор, ...) | REQ не переопределяет; роли управляют артефактами REQ |
| Agent instrumentation: уровни контроля, профили агентов, dispatch isolation, федерация | REQ расширяет специфику для требований, см. [02-agent-driven-principles.md](02-agent-driven-principles.md) |

REQ начинается **там, где SENAR заканчивается**: SENAR — методология, REQ — нормативный документ управления требованиями для SENAR-совместимых систем.

---

## 2. Главная позиционная мысль

> **REQ = ISO/IEC/IEEE 29148-конформный requirements management, операционализированный для 100% agent-driven контекста, поверх SENAR-методологии и SAFe-координации.**

Эта фраза — точка отсчёта для всех последующих сравнений.

---

## 3. Mapping на стандарты

### 3.1 ISO/IEC/IEEE 29148:2018 — Requirements engineering

**Что это**: международный стандарт по requirements engineering. Покрывает: stakeholder needs, requirements specification, validation, verification, attributes, traceability.

**Что REQ заимствует**:

| 29148 | REQ |
|---|---|
| Requirements classes: stakeholder, system, software | BR (stakeholder/business), SR (system/software), TR (task) |
| Requirement attributes: necessity, priority, source, rationale, fit criterion, owner, traceability | Все обязательные во frontmatter REQ |
| SRS structure (chapters: introduction, overall description, specific requirements, appendix) | Структура `.req` репо изоморфна |
| Verification methods: inspection, analysis, demonstration, test | REQ требует test (`automation`) для verifiable требований; inspection возможен через `[test-spec-change]` ревью |

**Что REQ адаптирует**:

- 29148 предусматривает 18 атрибутов требования. REQ оставляет 7-8 обязательных, остальные — auto-derived или необязательные. **Reasoning**: 29148 написан под manual-driven контекст; в agent-driven избыточная атрибутика создаёт hallucination surface.
- 29148 не предусматривает first-class TC. REQ выделяет TC как отдельный артефакт (см. testing-methodology.md).

**Что REQ НЕ берёт**: 29148 предусматривает review meetings и formal walkthroughs. В REQ заменено на one-click approval QG-0/QG-2 + adversarial AI-review (см. [02](02-agent-driven-principles.md)).

### 3.2 ISO/IEC 25010:2011 — SQuaRE Quality Model

**Что это**: модель качества ПО — 8 характеристик: Functional Suitability, Performance Efficiency, Compatibility, Usability, Reliability, Security, Maintainability, Portability.

**Что REQ заимствует**:

- 8 характеристик становятся обязательными категориями для non-functional SR. Вместо одного NFR-мешка (как сейчас в `notification_catcher.req/sr/SR-15-platform-nonfunctional.md`) — 8 отдельных SR с явной категорией.

**Предлагаемое расширение**: ввести во frontmatter SR поле:

```yaml
quality-characteristic:
  - performance-efficiency
  - reliability
```

CI-проверка: каждое NFR должно быть mapped на минимум одну характеристику. Без этого — отчёт о покрытии non-functional требований невозможен.

### 3.3 ISO/IEC 25022 / 25023:2016 — Quality measures

**Что это**: формальные метрики качества для каждой 25010-характеристики (например, Time Behavior measured as Mean Response Time in ms).

**Что REQ заимствует**: Pass-критерии в TC должны быть выражены через 25022/25023 measures, где это применимо. Пример: вместо «производительность приемлемая» — «p95 < 200 мс при 100 RPS» (это `Mean Response Time` из 25022).

### 3.4 IEEE 830-1998 — SRS Recommended Practice

**Что это**: классическая структура Software Requirements Specification (deprecated в пользу 29148, но конвенция SRS-структуры из неё).

**Что REQ заимствует**: ничего напрямую (29148 это покрывает); упоминается для credibility и узнаваемости — `REQUIREMENTS.md` ≈ современный SRS.

### 3.5 BABOK v3 (IIBA) — Business Analysis Body of Knowledge

**Что это**: 6 knowledge areas: Business Analysis Planning, **Elicitation**, Requirements Life Cycle Management, Strategy Analysis, Requirements Analysis & Design Definition, **Solution Evaluation**.

**Что REQ покрывает (хорошо)**:

- Requirements Life Cycle Management — REQ purpose-built для этого.
- Requirements Analysis & Design Definition — иерархия BR/SR/UIC/AIC и декомпозиция.

**Что REQ покрывает слабо** (gap):

- **Elicitation** — как добывать требования у клиента. Сейчас в REQ предполагается, что ТЗ уже подписан и приходит готовым. Но 90% AI-driven elicitation — отдельный класс задач (Socratic Q&A через `/interview` skill, structured брифы через Gerda).
- **Solution Evaluation** — как валидировать, что решение даёт business value. Сейчас QG-4 (приёмка клиентом) описана абстрактно.

**Предложение**: вынести в отдельные документы:
- `req-elicitation-workflow.md` — как AI-агент проводит интервью со стейкхолдерами для BR generation.
- `req-solution-evaluation.md` — нормативный QG-4 с outcome metrics.

### 3.6 PMBOK 7th edition (PMI) — Project Management

**Что это**: 8 performance domains: Stakeholders, Team, Development Approach, Planning, Project Work, Delivery, Measurement, Uncertainty. Ключевой сдвиг 7-го издания — **principles over processes**.

**Что REQ заимствует**:

- Принцип «principles over processes» — RENAR нормирует **что** должно быть (data model, lifecycle, invariants), не **как именно** реализовано (substrate-agnostic).
- Stakeholder map (BR указывает stakeholder owner, не abstract «business»).

**Не берёт**: process-heavy практики PMBOK 6 (WBS, etc) — несовместимы с agent-driven скоростью.

### 3.7 SAFe 6.0 — Scaled Agile Framework

**Что это**: framework для масштабированного Agile. Уровни: Portfolio (Strategic Themes, Epics) → Solution → ART/Program (Features) → Team (Stories).

**Что REQ заимствует**: маппинг на SAFe-иерархию (нужно явно зафиксировать):

| SAFe | REQ |
|---|---|
| Strategic Theme / Investment Horizon | (вне REQ — корпоративная стратегия) |
| Portfolio Epic | Группа BR одной системы |
| Capability / Program Epic | BR подсистемы |
| Feature | SR (или несколько связанных SR) |
| Story | TR (Task в трекере) |
| Enabler Epic | AIC (для AI) или TS (technical specification) |

**Что REQ заимствует ещё**:

- Built-in quality — REQ обязывает TC до approved.
- Continuous Delivery Pipeline — REQ-артефакты triggers CI на каждое изменение.
- WSJF (Weighted Shortest Job First) — рекомендованный prioritization framework для REQ priority field.

**Уже используется в стеке**: Finka = SAFe Release Train Engineer (RTE). См. её AGENTS.md.

### 3.8 ISTQB Foundation — Test Vocabulary

**Что это**: международный glossary и certification body для тестирования.

**Что REQ заимствует**:

- Test design techniques (equivalence partitioning, boundary value analysis, decision tables, state transition testing) — рекомендации для AI-генерации TC.
- Test levels (component → integration → system → acceptance) — REQ уже использует эту терминологию в `type` поле TC (system / contract / acceptance).
- ISTQB definition of "test case" — REQ-определение совместимо.

**Reasoning**: использование ISTQB-вокабуляра делает RENAR credible для аудиторов и QA-сообщества без объяснений. «Это equivalent partitioning» сразу понятно профессиональному QA.

### 3.9 CMMI for Development v2.0 — Capability Maturity

**Что это**: process areas, maturity levels (1-5).

**Process areas, релевантные REQ**:
- Requirements Management (REQM) — управление изменениями требований.
- Requirements Development (RD) — formulation требований.
- Verification (VER) — что мы построили правильно.
- Validation (VAL) — что мы построили правильное (right thing).

**Что REQ заимствует**: vocabulary REQM/RD/VER/VAL для сопоставления документов и активностей. Maturity levels (1-5) — prior art для REQ maturity model.

**Что REQ не берёт**: process-heavy CMMI artifacts (organisational standard processes, statistical process control). CMMI разработан до Agile и до AI; прямое применение убьёт скорость.

### 3.10 ISO/IEC 5338:2023 — AI system life cycle processes

**Что это**: первый официальный стандарт life cycle для AI-систем. Adapts ISO 12207 (general SE life cycle) для AI specifics.

**Что REQ заимствует** (важно):

- **Decision logs**: каждое существенное решение AI-агента должно быть задокументировано (что решил, на основе чего, какая модель, какой prompt).
- **Data versioning**: training data и evaluation data должны быть versioned. У REQ это `ai-concepts/eval-datasets/` с явным `version`.
- **Model versioning**: каждый artifact, генерируемый AI, фиксирует модель и её версию (это часть [02 Agent-driven principles](02-agent-driven-principles.md), Principle #1).
- **Continuous validation**: для AI-компонент верификация не одноразовая — eval-runs по расписанию (testing-methodology §5.6).

**Прямая reference**: RENAR **claims conformance to ISO/IEC 5338** в части AIC и AI-driven artifact generation.

### 3.11 ISO/IEC 23894:2023 — AI Risk Management

**Что это**: framework для управления рисками AI-систем.

**Релевантные риски** (которые REQ должен явно адресовать):

| Риск (23894) | Mitigation в REQ |
|---|---|
| Hallucination в AI output | Source citation principle ([02 Principle 3](02-agent-driven-principles.md)) |
| Model drift | `last-run.requirement-version` pinning, periodic re-run |
| Prompt injection через input data | Input sanitization при импорте ТЗ; защита через KAI gateway |
| Bias в AI-генерации | Multi-model agreement для критических BR ([02 Principle 4](02-agent-driven-principles.md)) |
| Adversarial inputs | Adversarial review gate ([02 Principle 2](02-agent-driven-principles.md)) |
| Single point of failure (one model) | Multi-model agreement, изоляция judge-модели в eval |

**Предложение**: добавить в REQ AI risk register по этой таблице с owner и mitigation status.

### 3.12 NIST AI RMF 1.0 — AI Risk Management Framework

**Что это**: 4 функции — Govern, Map, Measure, Manage.

**Mapping на REQ**:

| NIST AI RMF | REQ |
|---|---|
| Govern: policies, accountability | RENAR + roles (через SENAR) |
| Map: контекст использования | BR описывает context of use, AIC — AI context |
| Measure: performance, bias, robustness | Eval-тесты в `tests/` с metric thresholds |
| Manage: prioritization & response | Lifecycle deprecate + impact analysis при дельта-ТЗ |

**Польза reference**: для US-клиентов NIST AI RMF — стандарт de facto. RENAR-conformance к NIST AI RMF — продаваемое позиционирование.

---

## 4. Сводка соответствий

| Стандарт | Тип | Уровень соответствия REQ | Документ-основание |
|---|---|---|---|
| ISO/IEC/IEEE 29148:2018 | Requirements engineering | Высокий — берём core, упрощаем атрибуты | requirements-storage-standard.md, requirements-methodology.md |
| ISO/IEC 25010:2011 | Software quality model | Среднее — нужно расширение `quality-characteristic` поле | requirements-storage-standard.md (TODO) |
| ISO/IEC 25022/25023 | Quality measures | Среднее — рекомендация для Pass-критериев | testing-methodology.md §6.1 (расширить) |
| BABOK v3 | Business analysis | Частичное — Elicitation и Solution Evaluation gaps | requirements-methodology.md (TODO: elicitation chapter) |
| PMBOK 7 | Project management | Принципиальное — principles over processes совпадает | architecture-vision.md |
| SAFe 6.0 | Scaled Agile | Высокий — мэппинг REQ ↔ SAFe иерархия | этот документ §3.7 (TODO: вынести в отдельный) |
| ISTQB Foundation | Testing vocabulary | Высокий — vocabulary совпадает | testing-methodology.md |
| CMMI v2.0 | Maturity | Среднее — REQM/RD/VER/VAL vocabulary | 03-maturity-model.md |
| ISO/IEC 5338:2023 | AI life cycle | Высокий — claim conformance | 02-agent-driven-principles.md |
| ISO/IEC 23894:2023 | AI risk management | Среднее — нужен risk register | TODO: req-ai-risk-register.md |
| NIST AI RMF 1.0 | AI governance (US) | Среднее — мэппинг для US-клиентов | этот документ §3.12 |

---

## 5. Что это даёт REQ

1. **Credibility для аудита**. «Conformant to ISO/IEC/IEEE 29148 + ISO/IEC 5338» в положении стандарта закрывает 80% вопросов от corporate compliance teams.
2. **Знакомый vocabulary**. ISTQB-термины, CMMI-process-areas, BABOK-knowledge-areas — это lingua franca индустрии. AI-агенты, обученные на широких корпусах, узнают эти термины, что делает их инструкции более стабильными (меньше hallucination).
3. **Прайсинг и продажа**. Стандарт, явно опирающийся на ISO, легче продавать партнёрам как «корпоративный продукт», а не «kibertum-внутренняя разработка».
4. **Легкость интеграции с регуляторными требованиями**. Клиенту с ISO 27001 / GDPR / ФЗ-152 проще принять REQ, потому что vocabulary совпадает.

---

## 6. Что НЕ берётся принципиально

- **Document-heavy practices** (RUP, SWEBOK chapter on review meetings, formal inspections в стиле IEEE 1028). Несовместимо с agent-driven скоростью.
- **Manual-only verification** (29148 предусматривает inspection meetings). Заменено на adversarial AI-review.
- **Process-первый CMMI** (organisational standard processes, formal CCB). Заменено на принципы и автоматический enforcement.
- **Heavy formal methods** (B-method, Z-notation, TLA+ для всех требований). Применимо для critical safety domains, но не общая практика.

---

## 7. Открытые вопросы

- [ ] Делать ли формальный claim conformance (с self-assessment) к 29148 и 5338? Это бесплатно по содержимому, но требует юридической проверки формулировок.
- [ ] Поднимать ли REQ под IEEE/ISO как extension? Слишком ранний этап — сначала проверить на 3-5 проектах.
- [ ] SAFe-маппинг — выносить в отдельный документ `req-safe-mapping.md` или оставить здесь?
- [ ] AI risk register — отдельный документ? Связь с NIST AI RMF и ISO 23894 — да; объединить.
