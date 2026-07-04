# Agent-driven принципы REQ

> Версия: черновик 0.1 | Дата: 2026-05-03
> Назначение: специфика RENARа для контекста, где **AI-агент создаёт 90-95% артефактов** (BR, SR, UIC, AIC, TC, реализации тестов), а человек делает one-click approval и спот-чек.
>
> Документ нормирует только то, что не покрыто SENAR §5 (Agent Instrumentation) и не очевидно из общих стандартов requirements engineering.

---

## 1. Что НЕ дублирует SENAR

SENAR §5 «Инструментирование агентов» уже покрывает:

- Уровни контроля над агентом.
- Профили агентов (что агент может делать в каком профиле).
- Структурированный протокол вызова инструментов.
- Изоляция диспетчеризации (worktree, sandboxing).
- Федерация агентов между проектами.

REQ **не переписывает** это. REQ **добавляет** правила, специфичные для контекста, где AI-агент **создаёт спецификации требований и тест-кейсов** (а не просто пишет код по требованиям).

Разница принципиальная: ошибка в коде ловится тестами; ошибка в требовании порождает технически корректный код, решающий не ту задачу. Поэтому agent-driven generation требований требует более строгих гарантий, чем agent-driven generation кода.

---

## 2. Контекст: чем отличается AI-генерация требований от AI-генерации кода

| Свойство | AI пишет код | AI пишет требования (REQ context) |
|---|---|---|
| Источник истины | Спецификация (требование) | Только текст ТЗ от клиента + интервью со стейкхолдерами |
| Способ верификации | Тесты, code review, прогон | Интерпретация архитектором, ревью клиентом — высокая стоимость ошибки |
| Видимость ошибки | Тест падает, lint ругается | Только в момент приёмки или в production |
| Cost of correction | Низкая (rebase, fix) | Высокая (договорные изменения, дельта-ТЗ, переработка цепочки) |
| Hallucination effect | Лёгкий (тест поймает) | Тяжёлый (требование живёт в договоре, в backlog, в коде) |
| Adversarial surface | Code injection, supply chain | Prompt injection через ТЗ, ambiguity exploitation, scope creep |

Из этого следует: для AI-driven requirements нужны **дополнительные защитные контуры**, которых нет в обычном AI-driven coding.

---

## 3. Семь принципов

Каждый принцип имеет: **что**, **зачем**, **контракт** (как enforced), **связь с SENAR/стандартами**.

### Принцип 1. AI-conformance level (Model Cards в артефактах)

**Что**: каждый AI-генерируемый артефакт хранит во frontmatter поле `ai-provenance` с моделью, prompt-версией, контекстом, токенами, временем.

```yaml
ai-provenance:
  generated-by: claude-opus-4-7@2026-05-03
  prompt-template: req-prompts/decompose-tz@v1.4
  context-tokens: 12450
  output-tokens: 1820
  generation-time-ms: 18200
  generated-at: 2026-05-03T14:32:00Z
  human-edits: false                 # true если архитектор редактировал руками
```

**Зачем**:

- Воспроизводимость: можно перегенерировать или сравнить с новой версией модели.
- Аудит: при нахождении ошибки в требовании — понятно, какой prompt дал плохой результат, можно фиксить prompt.
- Cost control: суммарные токены по проекту видны.
- ISO/IEC 5338 conformance: model versioning is mandatory for AI artifacts.

**Контракт**:

- Поле обязательно во frontmatter любого artifact, созданного AI-агентом (BR, SR, UIC, AIC, TC).
- Изменение `human-edits: true` — архитектор редактировал руками, это сигнал «не перегенерируется автоматически».
- Pre-commit hook валидирует наличие поля.

**Связь со SENAR**: расширяет §5 (Agent Instrumentation) детализацией для requirements artifacts. SENAR говорит «есть профили»; REQ добавляет «фиксируй какой профиль использовался».

---

### Принцип 2. Adversarial review as gate

**Что**: для каждого approved-перехода (`draft → approved`) — отдельный AI-агент-критик с другой моделью генерирует «red team» атаки на формулировку. Если критик находит ≥3 серьёзных вопроса (ambiguity, missing edge case, contradiction с другим требованием) — гейт не проходит.

**Зачем**:

- AI-генератор и AI-проверщик с одной моделью имеют коррелированные ошибки. Разные модели — разные слепые зоны.
- Формальный аналог inspection meeting из 29148, но автоматический.
- Снижает hallucination at scale.

**Контракт**:

- Genrator-модель (например, Claude Opus) ≠ Critic-модель (например, GPT-4 или Claude Sonnet с другим system prompt).
- Critic выдаёт structured output: `{issue: string, severity: high|medium|low, location: section, suggested-question: string}`.
- При severity=high count ≥1 OR severity=medium count ≥3 — `req-promote --to approved` блокируется. Архитектор должен либо доработать, либо явно `--override-critic` с обоснованием.
- Critic-output сохраняется как `ai-concepts/critics/<artifact-id>-critic-<run-id>.json`.

**Связь со стандартами**: формализация peer review из 29148 §6.5; реализация adversarial-critic паттерна, которым уже пользуется TAUSIK в `/review` (6th critic agent).

---

### Принцип 3. Hallucination-defense через source citation

**Что**: каждое утверждение в BR/SR должно иметь явный pointer в исходный текст ТЗ (line/section). AI не имеет права «дописывать от себя», все assertions verifiable против source.

```markdown
## Поведение

- При первом запуске отображается экран онбординга. [TZ-2026-001 §4 ФТ-001 line 142]
- Кнопка «Выдать доступ» открывает системные настройки Android. [TZ-2026-001 §4 ФТ-001 line 156]
- После выдачи разрешения система переходит к шагу OEM-карточки. [TZ-2026-001 §4 ФТ-002 line 178, derived]
```

`derived` маркер — для утверждений, которые AI логически вывел, но прямой цитаты нет. Архитектор видит и принимает решение.

**Зачем**:

- Любое требование можно валидировать против ТЗ механически.
- При споре с клиентом «мы такого не просили» — citation сразу разрешает.
- AI-генератор лимитирован в creative взгляде («что бы ещё клиент мог хотеть»), что снижает scope creep.

**Контракт**:

- Pre-commit hook парсит body требования, извлекает citations, проверяет существование `[TZ-XXX §Y line Z]` (или маркер `derived`).
- Утверждения без citation и без `derived` маркера — блокируют merge.
- При citation `derived` — обязательно объяснение в скобках после.

**Связь со стандартами**: ISO/IEC 5338 «traceability» в applied form; принцип «every assertion must be evidenced» из ISO 25010 (verifiability characteristic).

---

### Принцип 4. Multi-model agreement для критических BR

**Что**: для BR с `priority: must` — параллельная генерация двумя независимыми моделями (Claude + GPT, например) с автоматическим diff. Расхождение по существу (не стилистике) ≥ X% — обязательная сверка инженером.

**Зачем**:

- Single-model failure mode — один тип галлюцинации проходит насквозь. Два модели = две независимые ошибки, корреляция ниже.
- Особенно важно для BR — это договорной артефакт, его ошибка дорого стоит.

**Контракт**:

- Только для `priority: must` BR (для `should/could` — overhead не оправдан).
- Diff делается через embedding similarity на уровне утверждений (не текстовый diff).
- Threshold согласовывается per-project (по умолчанию 15% утверждений с расхождением).
- Превышение → MR помечается тегом `[multi-model-disagreement]` и требует архитектора к ручной сверке до merge.
- Результат сохраняется в `ai-concepts/critics/<br-id>-multi-model-<run-id>.json`.

**Связь со стандартами**: best practice из ISO/IEC 23894 §6.4 «Bias mitigation through model diversity».

---

### Принцип 5. AI cost / latency budget per artifact

**Что**: токены и время генерации фиксируются как атрибут артефакта. Превышение бюджета — сигнал «требование слишком сложное, декомпозируй».

```yaml
ai-budget:
  context-tokens-target: 8000        # из стандартного промпта
  context-tokens-actual: 12450       # реальное потребление
  context-tokens-overrun: 56%        # → флаг "too complex"
  output-tokens-target: 1500
  output-tokens-actual: 1820
  generation-time-target-ms: 15000
  generation-time-actual-ms: 18200
```

**Зачем**:

- Превентивный контроль bloat'а: если требование требует 20K токенов контекста — оно скорее всего охватывает несколько SR, нужно декомпозировать.
- Cost predictability: SENAR §9 упоминает Cost Predictability как метрику; REQ даёт ей данные на уровне artifact.
- Раннее обнаружение «requirement smell»: переусложнённое формулирование часто связано с неясностью у автора.

**Контракт**:

- Targets устанавливаются в `req-prompts/<template>.yaml` как часть prompt-инфры.
- Actuals записываются автоматически при генерации.
- Overrun > 50% — warning, > 100% — рекомендация декомпозиции.
- Метрика `Avg Token Overrun per Artifact` входит в COVERAGE.md/aggregated dashboard (см. [04-metrics-and-outcomes.md](04-metrics-and-outcomes.md)).

**Связь со SENAR**: прямое расширение метрики `Cost-per-task` (SENAR §9) на уровень artifact-генерации.

---

### Принцип 6. Knowledge graph как central source

**Что**: у Raven есть graph-memory. Все REQ-артефакты обязаны линковаться через граф, а не только через flat references.

Узлы графа: `BR`, `SR`, `UIC`, `AIC`, `TC`, `WorkOrder/TZ`, `Stakeholder`, `BusinessGoal`, `KPI`, `Task`, `CodeArtifact`, `Decision`, `DeadEnd`.

Грани: `derived-from`, `verifies`, `implements`, `blocks`, `related-to`, `replaces`, `evidence-for`.

**Зачем**:

- AI-агент при генерации может запросить semantic context: «дай все BR, влияющие на KPI X», «дай все SR, реализованные code artifacts <модуль>».
- Поиск по графу сильнее, чем плоский FTS5 по `.md`.
- Снимает класс ошибок типа «AI не нашёл связанное требование, потому что keyword не совпадал».

**Контракт**:

- На git-substrate граф — derived view от frontmatter полей `parent`, `verified-by`, `derived-from`, `linked_tasks`. TAUSIK skill `req graph build` строит SQLite-граф из `.req`.
- На Raven-substrate — граф родной (CouchDB graph-memory).
- AI-промпты для генерации требований обязаны принимать `graph_context` как параметр и использовать его (вместо raw FTS).
- На уровне CI: при merge MR в `.req` — граф пересобирается и валидируется (нет orphan nodes для approved требований, нет circular dependencies в `derived-from`).

**Связь со стандартами**: ISO/IEC 5338 «traceability matrix» realised as knowledge graph; SAFe «value stream mapping» applied at requirement level.

---

### Принцип 7. Continuous reconciliation hook

**Что**: раз в N дней автономный AI-агент (cron или webhook) проходит по всему `.req` и проверяет:

- Непротиворечивость между BR и SR (не противоречат ли друг другу).
- Актуальность TC (нет stale `last-run.requirement-version`).
- Orphan-артефакты (BR без SR, SR без TC, TC с broken `automation.location`).
- Terminological drift (использование терминов вне глоссария).
- Citation drift (broken `[TZ-XXX §Y]` ссылки).
- Граф consistency (см. Принцип 6).

Отчёт — MR с тегом `[reconciliation]` от reconciliation-агента. Архитектор делает one-click approval (да, AI прав, фиксим) или dismiss с обоснованием.

**Зачем**:

- Стандарт описывает множество inviarants. Ручная проверка не масштабируется.
- Drift в долгосрочных проектах (>6 месяцев) накапливается тихо — reconciliation ловит на ранних стадиях.
- Освобождает архитектора от рутинного аудита.

**Контракт**:

- Конфиг в `<project>.req/.req-config.yaml`: `reconciliation.schedule: weekly|daily|...`, `reconciliation.checks: [...]`.
- AI-агент имеет ограниченные права: только генерация MR, не auto-merge.
- Метрика «reconciliation findings per week» — как health indicator проекта (растёт = drift, падает = либо здоровый проект, либо агент перестал работать).

**Связь со SENAR**: прямой аналог Quality Sweep (SENAR §11.5), но автоматический и регулярный, не ad-hoc.

---

## 4. Сводка принципов

| # | Принцип | Защищает от | Вес enforcement |
|---|---|---|---|
| 1 | AI-conformance level | Невоспроизводимости, потери provenance | hook валидации поля |
| 2 | Adversarial review as gate | Single-model hallucination, групповой ошибки | блок merge |
| 3 | Source citation | «AI дописал от себя», scope creep | блок merge |
| 4 | Multi-model agreement | Single-model bias на критическом артефакте | блок merge для priority=must |
| 5 | Cost/latency budget | Bloat'а, переусложнённого требования | warning + recommendation |
| 6 | Knowledge graph | Потери семантического контекста | требование к промпту |
| 7 | Continuous reconciliation | Долгосрочного drift'а | cron + MR |

---

## 5. Что нормировано в каких документах

| Принцип | Где конкретные правила | Где enforcement |
|---|---|---|
| 1 (Model cards) | `requirement-schema.md` (frontmatter) | TAUSIK pre-commit hook |
| 2 (Adversarial) | `testing-methodology.md` extension + `req-prompts/critic.md` | TAUSIK pre-merge hook + skill `/req-promote` |
| 3 (Citation) | `requirements-storage-standard.md` §6.x (TODO) | pre-commit hook + `tausik req validate-citations` |
| 4 (Multi-model) | этот документ + `req-prompts/multi-model.yaml` | skill `/req-generate-must` |
| 5 (Budget) | этот документ + `req-prompts/<template>.yaml` | skill warning + COVERAGE.md метрика |
| 6 (Graph) | этот документ + `req-graph-schema.md` (TODO) | skill `req graph build` + CI |
| 7 (Reconciliation) | этот документ + `<project>.req/.req-config.yaml` | cron job + dedicated agent |

---

## 6. Что не даёт ни один из принципов в отдельности

Эти 7 принципов — **дополняющие**, не самостоятельные слои. Уверенность в качестве AI-сгенерированного требования = пересечение всех 7. Один без другого:

- Citation без adversarial review — citation «правильная», но требование всё равно ambiguous.
- Adversarial review без model cards — критик «нашёл проблему», но мы не знаем, какой версией промпта это было сгенерировано — невозможно фиксить prompt.
- Multi-model без budget — модели согласованы, но overrun → требование переусложнённое.
- Graph без reconciliation — граф устаревает.

Поэтому стандарт нормирует все 7 как обязательные для проекта на REQ-зрелости 4-5 (см. [03-maturity-model.md](03-maturity-model.md)). На уровнях 1-3 принципы вводятся постепенно.

---

## 7. Open questions

- [ ] Принцип 2: какая критическая модель для critic? Запрещать совпадение или просто требовать различие? Рекомендация — Sonnet генерирует, Opus критикует, или vice versa.
- [ ] Принцип 4: threshold расхождения 15% — взят с потолка. Нужны данные с реальных прогонов.
- [ ] Принцип 6: на git-substrate граф derived; нужен ли persistent storage (SQLite) или достаточно in-memory при запросе?
- [ ] Принцип 7: schedule daily | weekly | monthly — зависит от темпа проекта. Начать с weekly?
- [ ] Cost-распределение: эти 7 принципов удваивают-утраивают затраты на AI. Где порог рентабельности (для маленьких проектов скипать всё кроме 1-3)?
