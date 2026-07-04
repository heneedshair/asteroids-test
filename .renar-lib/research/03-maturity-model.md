# Модель зрелости REQ

> Версия: черновик 0.1 | Дата: 2026-05-03
> Назначение: 5 уровней соответствия проекта RENARу, conformance checklist, путь развития. Не дублирует SENAR maturity (5 уровней общей зрелости команды + методологии), а **специализирует** одну из её размерностей — управление требованиями.

---

## 1. Связь с SENAR maturity

SENAR определяет 5 уровней общей зрелости (Reference, Maturity Model):

```
Стихийный → Супервизируемый → Измеримый → Управляемый → Оптимизирующий
```

Это **одномерная** модель — общая для команды/процесса.

REQ-зрелость — **отдельная размерность** в этой модели. Проект может быть на SENAR-уровне 4 (Управляемый) при REQ-уровне 2 (Документирован). Это нормально: команда зрелая в SENAR-практиках в целом, но **именно requirements management** ещё формализован слабо.

```
SENAR Maturity (общая зрелость)        ──┐
                                          ├──── проект характеризуется парой (SENAR-N, REQ-M)
REQ Maturity (управление требованиями)  ──┘
```

Это **не противоречит** SENAR — SENAR Reference допускает domain-specific maturity dimensions (auth, security, observability и т.д.). REQ — одно из таких domain-specific измерений.

Аналог в индустрии: CMMI имеет capability levels per process area (REQM может быть на capability 3, в то время как Verification — на capability 4). REQ-maturity — наша версия capability level для process area "Requirements Management".

---

## 2. Пять уровней REQ-зрелости

### RENAR-1: Ad-hoc

**Состояние**:
- Требования живут как задачи в трекере, чаты, документы google docs.
- Нет общего формата.
- Нет связи требование ↔ задача ↔ код ↔ тест.
- Дельта-ТЗ оформляются устно.

**Симптомы**:
- При вопросе «откуда это требование?» — ответ «вроде клиент так сказал на встрече месяц назад».
- В коде есть фичи, которых нет ни в одном артефакте.
- Тесты иногда прогоняются, иногда нет.
- На приёмке клиента — споры «это я не просил» / «вы согласовывали».

**Что есть в Andersen Stack сейчас на этом уровне**: `notification_catcher` до приведения к формату; новые мелкие проекты без введённого стандарта.

### RENAR-2: Documented

**Состояние**:
- BR/SR существуют как файлы в `.req/` репо или в одной из подпапок.
- Использован какой-то формат (frontmatter), но без CI-валидации.
- Нет TC как отдельных артефактов; тесты есть в коде, но без ссылок на требования.
- Нет lifecycle (статусы).
- Дельта-ТЗ оформляется в свободной форме.

**Симптомы**:
- При обновлении требования никто не уверен, какие задачи затронуты.
- COVERAGE.md либо нет, либо устарел.
- Frontmatter полей разного качества: одни проекты с `version`, другие без, поля называются по-разному.

**Что есть в Andersen Stack сейчас на этом уровне**: текущий `notification_catcher.req` в исходном виде.

### RENAR-3: Tracked

**Состояние**:
- Frontmatter стандартизирован (по `requirement-schema.md`).
- Lifecycle implemented (draft → approved → verified → deprecated).
- TC существуют для требований приоритета `must`, но не для `should/could`.
- COVERAGE.md auto-generated, обновляется на финализации ветки.
- Дельта-ТЗ через PR с impact analysis.
- Submodule `.req` ⊂ `.src` для provenance.

**Симптомы**:
- На вопрос «что осталось до релиза?» — ответ из COVERAGE.md, не из памяти.
- При дельта-ТЗ архитектор видит затронутые задачи и тесты автоматически.
- Не все NFR имеют формализованные критерии (часть всё ещё «приемлемая производительность»).

**QG enforced**: QG-0 (нет goal/AC → блок старта); QG-1 (TC автоматизированы или manual-pending).

### RENAR-4: Verified

**Состояние**:
- Все `approved` требования имеют ≥1 TC из `verified-by`.
- Для каждого утверждения требования — пара pos/neg TC.
- QG-2 enforced: перевод в `verified` запрещён без зелёных TC на текущей `requirement-version`.
- UX-тесты с VLM-judge для UIC-зависимых SR.
- Eval-тесты для AIC.
- `[test-spec-change]` тег обязателен для изменения Pass/Fail.
- Спот-чек 5 случайных passing TC раз в спринт.
- AI-conformance level (Принцип 1 из [02](02-agent-driven-principles.md)) — model cards в frontmatter.
- Source citation (Принцип 3) — каждое утверждение имеет pointer в ТЗ.
- Continuous reconciliation (Принцип 7) — еженедельно.

**Симптомы**:
- На приёмке клиента — нет споров: каждое требование имеет citation, каждый тест имеет doverable result.
- Defect Escape Rate (SENAR метрика) стабильно ≤2%.
- При смене модели AI можно перегенерировать требование и сравнить с предыдущим.

### RENAR-5: Optimized

**Состояние**:
- Adversarial review as gate (Принцип 2) — обязательный critic-агент.
- Multi-model agreement для `priority: must` (Принцип 4).
- Cost/latency budget per artifact (Принцип 5) — overrun → автодекомпозиция.
- Knowledge graph как primary search (Принцип 6) — все запросы AI идут через граф, не FTS.
- Continuous validation для AIC — eval-runs по расписанию.
- Метрики: Hallucination Rate < 1%, Multi-model Disagreement Rate измеряется и trending.
- Возврат улучшений шаблонов в `requirements-library` через MR — стандартная практика.
- Cross-project Brain (Raven-feature) делится паттернами требований между командами.

**Симптомы**:
- Скорость декомпозиции ТЗ → ready BR/SR с pos/neg TC: < 1 часа человеческого времени на 50 требований.
- Дельта-ТЗ от клиента → impact analysis + обновлённые требования + обновлённые тесты + готовые задачи в backlog: < 30 минут human attention.
- Стандарт **продаётся партнёрам** как самостоятельный продукт.

---

## 3. Сравнительная таблица

| Признак | RENAR-1 | RENAR-2 | RENAR-3 | RENAR-4 | RENAR-5 |
|---|---|---|---|---|---|
| Frontmatter standardized | ❌ | partial | ✓ | ✓ | ✓ |
| Lifecycle (draft/approved/verified) | ❌ | partial | ✓ | ✓ | ✓ |
| CI validation frontmatter | ❌ | ❌ | ✓ | ✓ | ✓ |
| TC as first-class | ❌ | ❌ | partial | ✓ | ✓ |
| Pos/neg pair on every assertion | ❌ | ❌ | ❌ | ✓ | ✓ |
| COVERAGE.md auto-generated | ❌ | ❌ | ✓ | ✓ | ✓ |
| Submodule .req ⊂ .src | ❌ | ❌ | ✓ | ✓ | ✓ |
| QG-0 / QG-2 enforced | ❌ | ❌ | partial | ✓ | ✓ |
| AI-conformance fields | ❌ | ❌ | ❌ | ✓ | ✓ |
| Source citation в утверждениях | ❌ | ❌ | ❌ | ✓ | ✓ |
| Adversarial review as gate | ❌ | ❌ | ❌ | partial | ✓ |
| Multi-model agreement (must) | ❌ | ❌ | ❌ | ❌ | ✓ |
| Cost/latency budget | ❌ | ❌ | ❌ | ❌ | ✓ |
| Knowledge graph primary | ❌ | ❌ | ❌ | ❌ | ✓ |
| Continuous reconciliation | ❌ | ❌ | ❌ | ✓ (basic) | ✓ (full) |
| Metric: Hallucination Rate | n/a | n/a | n/a | tracked | tracked & < 1% |
| Метрика: Dispute Rate | high | medium | medium-low | low | minimal |

---

## 4. Conformance checklist (для самооценки)

### Чтобы заявить RENAR-2 (Documented):

- [ ] Существует `<project>.req/` с папками `br/`, `sr/`.
- [ ] Большинство BR/SR имеют frontmatter с `id` и `title`.
- [ ] Существует ТЗ от клиента (хотя бы как файл).

### Чтобы заявить RENAR-3 (Tracked):

- [ ] Все требования имеют frontmatter, валидируемый по `requirement-schema.md`.
- [ ] Каждое SR имеет `parent` и `source.document`.
- [ ] Lifecycle статусы используются (draft / approved / verified / deprecated).
- [ ] Дельта-ТЗ оформляется через PR с тегом `[delta:TZ-YYYY-NNN]`.
- [ ] `COVERAGE.md` существует и обновлён в последний месяц.
- [ ] Большинство `priority: must` требований имеют ≥1 TC.
- [ ] `<project>.src` использует submodule `requirements/` → `<project>.req`.

### Чтобы заявить RENAR-4 (Verified):

- [ ] 100% `approved` требований имеют `verified-by: [TC-...]`.
- [ ] На каждое утверждение требования — pos/neg TC.
- [ ] Все TC автоматизированы или явно `manual-pending` с дедлайном.
- [ ] Все TC имеют `automation.location`, ссылающийся на существующий код.
- [ ] QG-2 enforced — перевод в `verified` блокируется без зелёных TC.
- [ ] Frontmatter артефактов содержит `ai-provenance.generated-by` и `ai-provenance.generated-at`.
- [ ] Body BR/SR содержит inline citations `[TZ-XXX §Y line Z]` или маркер `derived`.
- [ ] Reconciliation-агент запускается еженедельно.
- [ ] Спот-чек 5 случайных TC раз в спринт фиксируется в `COVERAGE.md`.

### Чтобы заявить RENAR-5 (Optimized):

- [ ] Adversarial critic с другой моделью обязателен для `draft → approved`.
- [ ] `priority: must` BR проходят multi-model generation с `[multi-model-disagreement]` тегом если расхождения.
- [ ] Cost budget actual/target tracked во frontmatter всех AI-генерируемых артефактов.
- [ ] Knowledge graph существует и AI-промпты используют `graph_context`.
- [ ] Hallucination Rate измеряется и < 1% (см. [04-metrics-and-outcomes.md](04-metrics-and-outcomes.md)).
- [ ] Multi-model Disagreement Rate trending visible.
- [ ] Continuous eval для AIC (расписание + on-change).
- [ ] Шаблоны из `requirements-library` используются с `derived-from` provenance.

---

## 5. Путь развития проекта

### От RENAR-1 к RENAR-2

Шаги:
1. Создать `.req` репо.
2. Перенести существующие требования из ticket'ов в `.md` файлы с минимальным frontmatter (`id`, `title`, `parent`).
3. Соглашение в команде: новые требования — только в `.req`, не в тикетах.

Время: 1-2 недели на проект.

### От RENAR-2 к RENAR-3

Шаги:
1. Установить TAUSIK skill `req`.
2. Запустить `/req-init` (создаёт submodule structure, .req-config.yaml).
3. Привести frontmatter к схеме (TAUSIK skill `req normalize`).
4. Внедрить lifecycle: пройтись по всем требованиям, проставить статусы.
5. Включить CI-валидацию frontmatter.
6. Сгенерировать первоначальный `COVERAGE.md`.
7. Сгенерировать TC хотя бы для `priority: must` требований.

Время: 2-4 недели на проект, включая training команды.

### От RENAR-3 к RENAR-4

Шаги:
1. AI-агент проходит по всем требованиям, генерирует pos/neg TC где их нет.
2. Реализация TC в `.src`. Это растягивается на несколько спринтов — параллельно с feature work.
3. Включить QG-2 enforcement.
4. Внедрить spot-check workflow.
5. Включить reconciliation-агент с еженедельным расписанием.
6. Перенастроить промпты AI — теперь они должны включать model cards и source citation требования.

Время: 1-2 квартала на проект.

### От RENAR-4 к RENAR-5

Шаги:
1. Подключить adversarial critic с другой моделью.
2. Включить multi-model для `priority: must` BR.
3. Развернуть knowledge graph (на git-substrate — derived; на Raven — родной).
4. Tune прицельную метрику Hallucination Rate.
5. Возврат улучшений шаблонов в `requirements-library` — установить как практику команды.

Время: 1-2 квартала после RENAR-4.

---

## 6. Минимальный entry-level

RENAR может быть полезен начиная с RENAR-2 (Documented). Не нужно **сразу** требовать RENAR-5 от каждого проекта — это барьер входа, который убьёт adoption.

| Тип проекта | Целевой уровень |
|---|---|
| Small spike, < 1 спринт | RENAR-2 — достаточно |
| Внутренняя автоматизация, 1-3 месяца | RENAR-3 |
| Клиентский продукт по договору | RENAR-4 |
| Andersen Stack core (princess, gerda, laplandka, kai) | RENAR-5 |
| AI-критическая компонента (eval-зависимая) | RENAR-5 обязательно |

Это **не одинаково для всех**. Стандарт допускает разные уровни в разных проектах.

---

## 7. Связь с SENAR метрикой ADR (Adversarial Detection Rate)

SENAR §9 определяет ADR — Adversarial Detection Rate. На REQ-уровнях:

| REQ | ADR (ожидаемое) |
|---|---|
| 1-2 | n/a (не измеряется) |
| 3 | измеряется на code review |
| 4 | + measured on requirement adversarial review |
| 5 | + multi-model adversarial diff |

Так REQ-зрелость связана с SENAR-метрикой непрерывно, без дублирования.

---

## 8. Open questions

- [ ] Conformance может ли быть **выборочным** (RENAR-3 в части BR, RENAR-2 в части UIC)? Или всё или ничего?
- [ ] Нужно ли formal certification body? Или self-assessment достаточно?
- [ ] Разрешать ли «temporary regression» — проект upgrade'нулся до RENAR-4, потом из-за нагрузки скатился до RENAR-3? Что делать?
- [ ] REQ-уровни проекта — public для клиентов или internal? Возможны оба варианта.
- [ ] Бенчмарк по индустрии: какие REQ-уровни типичны для проектов SaaS / enterprise / startups? Нужны данные.
