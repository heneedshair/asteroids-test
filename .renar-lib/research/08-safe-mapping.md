# Mapping REQ ↔ SAFe 6.0

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: явное соответствие REQ-артефактов и процессов масштабированному Agile (SAFe). Закрывает gap, выявленный в [06-multi-perspective-review.md §3](06-multi-perspective-review.md), §3.2 от Senior Project Manager / RTE.
>
> Финальная нормативная форма — после обсуждения с RTE Acme Stack (RTE-tool).

---

## 1. Не дублирует SENAR

SENAR §6 (Единицы работы) описывает Task / Story / Increment как абстрактные единицы. SENAR не нормирует SAFe-специфичные артефакты (Epic, Feature, Capability, Strategic Theme), не описывает PI Planning, не предписывает WSJF.

REQ **не переопределяет** SENAR Units of Work. REQ описывает **mapping** REQ-артефактов на SAFe-иерархию для проектов, использующих SAFe как координационный фреймворк (Acme Stack — пример: RTE-tool = SAFe RTE).

---

## 2. Главная таблица соответствия

| SAFe artifact | REQ artifact | Где живёт | Owner | Acceptance criteria |
|---|---|---|---|---|
| Strategic Theme | (вне REQ — корпоративная стратегия) | (стратегические доки) | Executive | (бизнес-уровень) |
| Portfolio Epic | Группа BR одной системы | `<system>.req/br/` aggregated | Lean Portfolio Mgmt | Все BR в группе verified |
| Capability | BR подсистемы (если у подсистемы свой stakeholder) | `<subsystem>.req/br/` | Solution Architect | Все BR подсистемы verified |
| Program Epic | (опционально) — крупная инициатива внутри ART | aggregated SR | Product Manager | Заданная outcome metric достигнута |
| Feature | SR (или связанная группа SR) | `<subsystem>.req/sr/` | Product Owner | TC из `verified-by` зелёные |
| Story | TR (Task в трекере) | TAUSIK DB / KAI DB / Raven `task` | Team | Все AC выполнены, evidence есть |
| Enabler Epic | AIC или TS | `<system>.req/ai-concepts/` или `tech-specs/` | Architect | Eval-метрики в пределах thresholds |
| Spike | Research task в трекере | TAUSIK DB | Team | Decision записан в KAI Decisions |
| Defect | Bug task в трекере + ссылка на нарушенный SR | TAUSIK DB + `linked_defects` в SR | Team | Negative TC проходит, regression test добавлен |

---

## 3. WSJF prioritization для REQ

SAFe использует **WSJF (Weighted Shortest Job First)** как приоритизационный framework. REQ адаптирует его для уровня BR/SR.

### 3.1 Формула

```
WSJF = (User-Business Value + Time Criticality + Risk Reduction & Opportunity Enablement) / Job Size
```

### 3.2 Frontmatter расширение для BR

```yaml
prioritization:
  framework: WSJF
  components:
    user-business-value: 10           # 1-20 шкала, оценка stakeholder
    time-criticality: 8               # 1-20 шкала
    risk-reduction-opportunity: 6     # 1-20 шкала
    job-size: 5                       # 1-20 шкала (relative effort)
  wsjf-score: 4.8                     # auto-calculated: (10+8+6)/5
  prioritized-at: 2026-05-03
  prioritized-by: "@product-owner"
```

### 3.3 Когда применяется

- **Обязательно** для BR с `priority: must` в проектах RENAR-3+.
- **Рекомендуется** для всех BR в проектах SAFe-координируемых.
- **Не применяется** для SR — SR следует за приоритетом своего BR.

### 3.4 Альтернативы

Если команда не использует SAFe:

- **MoSCoW** (Must / Should / Could / Won't) — простейший, для маленьких проектов. Уже есть как `priority` enum.
- **RICE** (Reach × Impact × Confidence / Effort) — для product-driven команд (типично продуктовые B2C).

RENAR нормирует только **поле и формат**; выбор framework — на проекте.

---

## 4. PI Planning интеграция

### 4.1 Что такое PI

Program Increment (PI) — 8-12 недель планирования в SAFe. Команды коммитятся на Features из общего backlog'а.

### 4.2 Где REQ-артефакты попадают в PI

```
[До PI Planning]
   └── Backlog: SR с status: approved, WSJF-prioritized
                                                  ↓
[PI Planning event]
   └── Команды берут SR (= Features) на следующий PI
   └── Декомпозиция SR → Stories (= TR в трекере)
   └── Identify cross-team dependencies (через INT-SR)
                                                  ↓
[Iteration 1..N]
   └── Stories → код → TC прогон → SR в `verified` после QG-2
                                                  ↓
[System Demo / Inspect & Adapt]
   └── Демо verified требований клиенту
   └── Метрики REQ feed в SAFe Inspect & Adapt
```

### 4.3 ART (Agile Release Train) и REQ

В Acme Stack — **RTE-tool = ART координатор / RTE**.

RTE-tool владеет:
- Эпиками (= группы BR одной системы).
- Cross-team dependencies (через `cross_deps` поле в KAI tasks; в REQ — через INT-SR).
- PI objectives (high-level outcomes от группы BR).

Сателлиты владеют:
- Своими SR в `<subsystem>.req/sr/`.
- Своими tasks по этим SR.

**Важно**: RTE-tool не редактирует SR в `<subsystem>.req` — только координирует через `cross_deps` и `kai_briefing`.

---

## 5. Definition of Done на каждом уровне

| Level | DoD criterion |
|---|---|
| Strategic Theme | (вне REQ scope) |
| Portfolio Epic | Все BR в группе → status `verified`, KPI impact подтверждён через outcome metric |
| Feature (= SR) | `verified` через QG-2: все TC из `verified-by` имеют `last-run.result = pass` на текущей `requirement-version` |
| Story (= TR) | Все AC выполнены, evidence есть, code reviewed, merged в main |
| Enabler (= AIC/TS) | Eval-runs прошли пороги, baseline зафиксирован |

DoD — **формальные** условия, проверяемые автоматически (CI hooks). На уровне Feature DoD совпадает с QG-2 в REQ.

---

## 6. Built-in Quality

SAFe принцип: качество встроено в процесс, не ad-hoc. REQ realises Built-in Quality через:

| SAFe Built-in Quality | REQ-механизм |
|---|---|
| Continuous Integration | TAUSIK хуки + CI на каждый PR в `.src` |
| Test-First | TC создаются **до** реализации (testing-methodology §3.1) |
| Refactoring | Continuous reconciliation hook ([02 Принцип 7](02-agent-driven-principles.md)) |
| Pairing/Mobbing | AI-генератор + AI-критик ([02 Принцип 2](02-agent-driven-principles.md)) — pair generation/review |
| Definition of Done | QG-2 как формальный gate |

---

## 7. RACI lifecycle требования (расширение из [06](06-multi-perspective-review.md))

| Активность | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| Импорт ТЗ | AI-агент | Архитектор | Stakeholder | Команда |
| Декомпозиция → BR | AI-генератор | Product Owner | Stakeholder, AI-критик | RTE, Команда |
| WSJF prioritization | Product Manager | Product Owner | RTE, Stakeholder | Команда |
| Декомпозиция BR → SR | AI-генератор | Architect | AI-критик | Команда, RTE |
| Генерация TC | AI-агент | Test Architect | — | Команда |
| QG-0 approval | Архитектор | Tech Lead | AI-критик | Stakeholder, RTE |
| Выбор SR на PI | Product Owner | RTE | Команда (capacity) | Stakeholder |
| Декомпозиция SR → Story (TR) | Команда | Product Owner | Architect | RTE |
| Реализация Story | Разработчик | Tech Lead | — | Команда |
| Прогон TC | Бот | — | — | Команда |
| QG-2 (Feature verified) | Архитектор | Tech Lead | — | Stakeholder, RTE |
| System Demo | Команда + RTE | Product Owner | Stakeholder | RTE, Executive |
| Дельта-ТЗ approval | Архитектор + Stakeholder | Product Owner | AI-impact, RTE | Команда |
| Spot-check 5 TC | Архитектор | — | — | RTE |
| Reconciliation MR | AI-агент-reconciler | Архитектор | — | Команда |

---

## 8. PI Objectives и REQ-метрики

PI Objectives = SMART outcomes на квартал. REQ-метрики (см. [04](04-metrics-and-outcomes.md)) feed в PI Objectives:

| PI Objective | REQ-метрика |
|---|---|
| «Сократить время от подписания ТЗ до первого commit'а до < 2 дней» | RDLT (Requirement Decomposition Lead Time) |
| «Достичь Coverage Velocity ≥ 60%/sprint» | Coverage Velocity |
| «Снизить Hallucination Rate в новых требованиях до < 2%» | Hallucination Rate |
| «0 disputed requirements на acceptance в этом PI» | Dispute Rate at Acceptance |

Это превращает REQ из «standard for documents» в **measurable contribution** к ART success.

---

## 9. Cross-team dependencies через INT-SR

Когда Feature в одной подсистеме блокирует другую:

```yaml
# В sr/SR-05.md (svc-a.req)
depends-on:
  - id: INT-SR-01
    repo: "acme.req"
    file: "int-sr/INT-SR-01-svc-a-svc-b.md"
```

```yaml
# В int-sr/INT-SR-01-svc-a-svc-b.md (acme.req)
participants:
  - id: SR-05
    repo: "example/acme/svc-a/svc-a.req"
  - id: SR-13
    repo: "example/acme/svc-b/svc-b.req"
contract-version: 1.2
```

В KAI / Raven cross-deps это уже отражено через `cross_deps` поле задач. На уровне требований — через `depends-on` и `participants`.

**RTE координация**: RTE-tool регулярно (раз в спринт) проверяет cross-team consistency через `kai_cross_project()` MCP-tool.

---

## 10. Скрипты / skills для SAFe-координации

Предлагаемые расширения TAUSIK skill `req`:

```
/req-pi-plan <PI-id>
   — собирает кандидаты SR с status:approved + WSJF-sorted
   — выводит таблицу "по командам" с estimated capacity

/req-pi-objectives
   — формирует список PI objectives на основе in-PI Features (SR)
   — связывает с REQ-метриками (target values)

/req-cross-deps
   — отчёт cross-team dependencies через INT-SR
   — алёрт на breaking changes в INT-SR contract

/req-system-demo
   — генерирует demo-script: список verified-в-PI Features
   — для каждой — link на TC last-run результаты
```

---

## 11. Open questions

- [ ] Estimation: WSJF использует Job Size как relative effort (1-20). Как AI-агент оценивает Job Size? Эвристика на основе количества AC, complexity TC, code surface? Нужна модель.
- [ ] Запрещать ли в `priority` поле `must` без WSJF score (для projects на RENAR-3+)? Или WSJF опционален?
- [ ] На каком уровне иерархии останавливается требование = Feature? Иногда крупный SR = Capability, иногда мелкий SR = Story. Нужна эвристика разделения.
- [ ] Cross-team dependencies: storage в `acme.req/int-sr/` или в каждом подсистема .req? Согласовано: в системном `.req/int-sr/` (см. requirements-storage-standard §3.3).
- [ ] PI Objectives как REQ-артефакт: создавать `pi-objectives/` папку в `<system>.req/` или это вне REQ?
- [ ] Inspect & Adapt: метрики REQ feed автоматически или manual extraction?
