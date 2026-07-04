# RENAR: архитектура и дорожная карта

> Версия: черновик 0.2 | Дата: 2026-05-03
> Статус: предложение к обсуждению с партнёром
> Назначение: зафиксировать ландшафт, предложить архитектуру, описать риски дрифта и план внедрения

> **Изменения 0.1 → 0.2** (после интеграции `testing-methodology.md` v1.1 и обновлений `requirements-storage-standard.md` v1.1):
> - **TC признан first-class артефактом** стандарта (был ошибочно описан как дубликат tasks).
> - `verified-by` в требовании, `tests/` папка в `.req`, `COVERAGE.md` и `TEST-PLAN.md` — **остаются обязательными** (были в 0.1 предложены к удалению — отозвано).
> - Добавлена тестовая методология как третий нормативный документ RENARа.
> - Расширен Two-repo pattern: `tests/`, `ai-concepts/baselines/`, `ai-concepts/eval-datasets/`.
> - Добавлены два новых класса дрифта (TC↔requirement provenance drift, test-fitting drift).
> - Раздел 9 переписан — пункты C2, C3, C4 (про удаление TC, verified-by, COVERAGE) скорректированы.

---

## Содержание

1. [Зачем этот документ](#1-зачем-этот-документ)
2. [Что у нас реально есть](#2-что-у-нас-реально-есть)
3. [Что ценного в партнёрском workflow](#3-что-ценного-в-партнёрском-workflow)
4. [Что предлагается: RENAR как стандарт над SENAR](#4-что-предлагается-req-как-стандарт-над-senar)
5. [Два substrate, одна модель данных](#5-два-substrate-одна-модель-данных)
6. [Pattern: `.req` как submodule в `.src`](#6-pattern-req-как-submodule-в-src)
7. [Где рождается дрифт и как его избегать](#7-где-рождается-дрифт-и-как-его-избегать)
8. [Дорожная карта](#8-дорожная-карта)
9. [Решения, которые надо зафиксировать сейчас](#9-решения-которые-надо-зафиксировать-сейчас)

---

## 1. Зачем этот документ

В компании одновременно существует несколько слоёв, каждый из которых по-своему касается требований:

- **SENAR** — методология (что должно быть).
- **req-standart** (эта папка) — нормативка управления требованиями (черновик).
- **TAUSIK** — open source runtime для AI-агентов (skills, hooks, локальная DB).
- **KAI / Raven** — внутренний runtime Andersen Stack (CouchDB + Meilisearch + Gateway).
- **Партнёрский подход** — git-репозитории `.req`/`.src`, ТЗ как документы, ручной workflow.

Без явной архитектуры эти слои **гарантированно** начнут пересекаться: одна и та же сущность (BR-01) станет жить в двух-трёх местах с разными версиями. Это и есть та коллизия, которую нужно поймать **до** имплементации, не после.

Документ описывает: **где сейчас правда, где будет правда, как переходить, и что делать, чтобы у одной сущности всегда был один писатель**.

---

## 2. Что у нас реально есть

### 2.1 SENAR — нормативная методология

- Стандарт AI-native разработки. 14 правил, 9 метрик, 5 Quality Gates (QG-0..QG-4), 3 конфигурации.
- Описывает иерархию **БТ → СТ → ТМ → ТЗ** (= BR → SR → TM → TR).
- НЕ описывает: где это всё хранится, как ревьюится, как привязывается к коду.
- **Готовность**: 1.3, опубликован на senar.tech.

### 2.2 req-standart (эта папка) — черновик нормативки

- 4 markdown-документа: methodology, storage standard (v1.1), **testing methodology (v1.1)**, developer guide.
- 8 bash-скриптов: `req-branch.sh`, `req-finalize.sh`, `req-import-tz.sh` и др.
- 1 файл инструкций для AI-агента (`req-ai-instructions.md`, 276 строк).
- **`testing-methodology.md`** — нормирует TC как first-class артефакт: lifecycle, pos/neg парность, UX через VLM-judge, eval с изоляцией judge-модели, защита от подгонки тестов через `[test-spec-change]` тег, спот-чек инженера.
- **Проблема**: предполагает ручной workflow «инженер копирует инструкции в чат AI» — никакого enforcement.
- **Готовность**: каркас есть, но не сшит ни с TAUSIK, ни с Raven.

### 2.3 TAUSIK — runtime для open source / внешних клиентов

`D:\Work\Personal\claude` (Github: Kibertum/tausik-core).

- Submodule `.tausik-lib` + bootstrap → SQLite в `.tausik/tausik.db` + 99 MCP-инструментов + 13 core skills.
- Уже реализует **QG-0** (нет goal/AC → блок старта задачи) и **QG-2** (нет evidence → блок закрытия).
- Project memory (FTS5), brain (cross-project), метрики FPSR/DER, anti-drift хуки.
- **TAUSIK = SENAR runtime для проектов вне Andersen Stack** (open source, заказчики на TAUSIK, новые продукты).
- **Готовность**: production, 2590 тестов, dogfooded.

### 2.4 Raven — runtime для Andersen Stack

`D:\Work\Kibertum\raven`.

- Gateway на :11221, бэкенд CouchDB + Meilisearch.
- В `api/routers/requirements.py` уже реализован полноценный CRUD `requirement_meta`:

  ```
  level:         BT | ST | TM | TK
  status:        draft | review | approved | obsolete
  quality_gate:  VK-1 | VK-2 | VK-3 | VK-4
  поля:          parent, children, linked_tasks, linked_tests,
                 linked_defects, contracts, storage,
                 created_by_order, last_modified_by_order, artifact_ref
  ```
- Эндпоинты: `/requirements`, `/specs`, `/work-orders`, `/library-artifacts`, `/systems`.
- **Это прямо отображает** иерархию SENAR + интеграции + связь с заказами + связь с задачами/тестами.
- **Готовность**: ~2 недели разработки + приёмочное тестирование. **Сейчас в проде использовать нельзя**.

### 2.5 KAI — skills + MCP внутри Andersen Stack

`D:\Work\Kibertum\kai`.

- CLI (`project.py`), skills, MCP-серверы, bootstrap. Аналог `.tausik-lib/` для внутренних проектов.
- Уже умеет: создание epic/story/task, sessions, decisions, dependencies, knowledge через Raven Gateway.
- **Готовность**: используется во всех 7 проектах стека.

### 2.6 Пример: `D:\Work\Kibertum\clients\notification_catcher.req`

113 markdown-файлов, 8066 строк, 881 KB. Структура:

| Папка | Файлов | Строк |
|---|---|---|
| `br/` | 6 | ~190 |
| `sr/` | 18 | ~975 |
| `ui-concepts/` | 6 | ~803 |
| `tests/` (TC-NN) | 76 | ~5100 |
| `tz/` | 2 | ~420 |
| `docs/` | 2 | ~220 |
| Сводные | 3 | ~407 |

**Что показывает этот пример:**

- Партнёрский подход к требованиям как git-документам **работает** — артефакты получаются, иерархия видна, ТЗ маппится, TC-файлы как first-class артефакты соответствуют `testing-methodology.md`.
- Реальные кандидаты на упрощение (~20-25% объёма):
  - Поля frontmatter дублирующие git: `version`, `updated`, `changes` (история — это `git log`).
  - **`verified-by` остаётся** — это derived auto-fill поле от TC, явная связь требование ↔ тесты с pinned-версией.
  - **TC-файлы остаются** — это first-class артефакт стандарта, а не дубликат TAUSIK tasks: TC описывает спецификацию проверки, реализация в `.src` адресуется через `automation.location`, `last-run` фиксирует прогон.
  - **`COVERAGE.md`/`TEST-PLAN.md` остаются** — это auto-generated bot-commits с тегом `[coverage]`, помеченные `linguist-generated=true`.
- Frontmatter SR-01 содержит 30 строк vs 19 строк тела. Из этих 30 на удаление — только `version`, `created`, `updated`, `changes` (~8 строк). Остальное (`verified-by`, `parent`, `derived-from-uic`, `priority`) — содержательное.

---

## 3. Что ценного в партнёрском workflow

Прежде чем критиковать — зафиксируем то, что в подходе партнёра действительно правильно. Это не должно быть выкинуто.

### 3.1 ТЗ как **дополнения**, а не правки

Партнёр предлагает: при появлении новых требований создавать **дельта-ТЗ**, а не редактировать исходное ТЗ. Это **корректно по двум причинам**:

- ТЗ — договорной документ. Подписанная клиентом версия должна оставаться неизменной.
- Любое изменение поведения должно иметь **provenance**: «это требование пришло из дельта-ТЗ №2 от 2026-05-15».

Это уже зафиксировано в `requirements-storage-standard.md` §9. Партнёр интуитивно вышел на тот же паттерн.

### 3.2 Новая версия ТЗ через git branch → PR → merge → запуск работы

Партнёр предлагает: дельта-ТЗ создаётся в feature-ветке, проходит ревью, мержится, и только после этого создаются задачи. **Это правильный паттерн**:

- Ревью договорного документа архитектором/Tech Lead до того, как разработчик начал тратить время.
- Атомарность: либо вся дельта зафиксирована (требования + индекс маппинга + impact analysis), либо ничего не запущено в работу.
- Естественная история: `git log` показывает, когда какое ТЗ пришло, какие требования породило.

Это работает на любом git-сервере без специнфраструктуры. Мы должны это сохранить.

### 3.3 Two-repo: `.req` + `.src` (один может быть submodule второго)

Это **отдельно ценная идея** — её стоит развить. См. раздел 6.

### 3.4 Где границы партнёрского подхода

Где он перестаёт работать сам по себе:

| Партнёр-style практика | Что зафиксировано в стандарте, и почему так |
|---|---|
| Хранить статус (draft/approved) во frontmatter | **Остаётся** — это договорной артефакт. Переходы выполняются по lifecycle через QG-0/QG-2, не вручную. На Raven-substrate то же поле в `requirement_meta.status`. |
| Хранить версию `version: 1.2` во frontmatter | **Удалить** — версия = git commit hash файла. Не дублируем. На Raven — `_rev`. |
| `created`, `updated`, `changes` поля во frontmatter | **Удалить** — это git. На Raven — `tool_event` doc-type. |
| `verified-by: [TC-...]` во frontmatter | **Остаётся** — это derived auto-fill поле, основа для QG-2 (требование не переходит в `verified` без зелёных TC из этого списка). На Raven — `linked_tests`. |
| TC-файлы как `.md` в `tests/` | **Остаётся** — first-class артефакт стандарта (см. testing-methodology), не сводимо к TAUSIK tasks. На Raven — `linked_tests` + `verification_runs` doc-type. |
| `COVERAGE.md`/`TEST-PLAN.md` как commit-артефакты | **Остаются** — auto-generated bot-commits с тегом `[coverage]` и `linguist-generated=true`. Перегенерация на финализации, merge, по расписанию. |
| Ручное редактирование TC инженером | **Запрещено** (testing-methodology §15.2) — TC создаёт и обновляет AI-агент. Инженер делает only one-click approval QG-0 / QG-2 + спот-чек. |
| Изменение Pass/Fail-критериев теста вместе с фиксом кода в одном MR | **Запрещено без `[test-spec-change]` тега и отдельного approval инженером** — иначе AI-агент имеет тривиальный путь зеленения через ослабление критерия. |

Решение — партнёрский workflow целиком корректен; стандарт уточняет какие поля **в** файлах являются договорными (status, verified-by, parent, source), какие выводятся (REQUIREMENTS/COVERAGE/TEST-PLAN от бота), и что вообще не должно быть в файлах (version, updated, changes).

---

## 4. Что предлагается: RENAR как стандарт над SENAR

### 4.1 Главная мысль

**REQ — это нормативный документ, описывающий управление требованиями для SENAR-совместимых систем. Он НЕ привязан к конкретному хранилищу. Он специфицирует data model, lifecycle, workflow и инварианты.**

Реализация REQ может жить:

- На **git-substrate** (TAUSIK / внешние проекты / Andersen interim, пока Raven не готов).
- На **Raven-substrate** (внутренние проекты Andersen Stack, когда Raven в проде).
- На обоих одновременно (один — SSoT, второй — derived snapshot).

При этом **data model и lifecycle одинаковые**. Это и делает REQ «равноценным дополнением к SENAR» — он не часть имплементации, он часть стандарта.

### 4.2 Что RENAR нормирует (содержание стандарта)

1. **Data model** для requirement (поля, типы, enum-значения, инварианты).
2. **Lifecycle** через Quality Gates: переходы статусов и их предусловия.
3. **Identity rules**: BR-NN/SR-NN/TC-NN — immutable, никогда не переиспользуются.
4. **Hierarchy rules**: parent/children, что разрешено, что запрещено.
5. **Provenance**: связь требования с work-order/ТЗ, с тестами (через `verifies.requirement-version`), с кодом (через `automation.location`).
6. **Workflow**: импорт ТЗ, дельта-ТЗ, impact analysis, deprecate, обязательная синхронная инвалидация TC при изменении требования.
7. **Substrate mapping**: как data model отображается на git frontmatter и на CouchDB документ — **должны быть изоморфны**.
8. **Тестовая методология**: TC как first-class артефакт, типы тестов (system / ux / eval / contract / acceptance), парность pos/neg, защита от подгонки тестов, изоляция judge-модели в eval, спот-чек инженером, auto-generated COVERAGE/TEST-PLAN от бота.

### 4.3 Структура RENARа (три нормативных документа)

| Документ | Что нормирует |
|---|---|
| `requirements-methodology.md` | Иерархия BR/SR/UIC/AIC/INT-SR, когда выделять подсистему, порядок работы |
| `requirements-storage-standard.md` | Форматы файлов (включая TC, COVERAGE.md, TEST-PLAN.md), структура `.req`, версионирование, git-процесс, дельта-ТЗ |
| `testing-methodology.md` | TC lifecycle, типы тестов, QG-0/QG-2 для тестов, защита от подгонки, AI-генерация, спот-чек |

### 4.4 Что RENAR НЕ нормирует

- Конкретное хранилище (git/CouchDB/иное).
- Конкретный UI для архитектора (web hub / IDE / vim).
- Конкретные команды (это уровень skills для TAUSIK/KAI).
- Конкретные runner'ы для тестов (pytest / jest / playwright / ragas / Pact) — их выбор фиксируется в проектном `.gitlab-ci.yml`.

---

## 5. Два substrate, одна модель данных

### 5.1 Substrate A — git (сейчас и для внешних проектов)

**Проект** = два репозитория:

- `<project>.req` — папки `br/`, `sr/`, `ui-concepts/`, `int-sr/`, `tz/`, `library/`, `docs/`.
- `<project>.src` — код, тесты, CI.

**Source of truth по полям:**

| Поле | Substrate A (git) | Кто пишет |
|---|---|---|
| Текст требования (тело .md) | файл `br/BR-01.md`, `sr/SR-NN.md` и т.п. | AI-агент по заданию архитектора, через PR |
| ID (BR-01, SR-05, TC-12) | имя файла + поле `id:` | AI-агент, **immutable** |
| Иерархия (parent/children) | frontmatter `parent:`, `children:` | AI-агент; `children` пересобирается финализацией |
| Approved-by-client | frontmatter `status: approved` | архитектор через one-click approval QG-0 |
| Версия требования | `git log` файла | git (НЕ хранить как поле во frontmatter) |
| История изменений | `git log` | git (НЕ хранить во frontmatter `changes:`) |
| Связь с ТЗ | frontmatter `source: { document, section }` | AI-агент при импорте ТЗ |
| Спецификация теста | `tests/TC-NN.md` со своим frontmatter и lifecycle | AI-агент; `[test-spec-change]` тег при изменении критериев |
| Реализация теста | `automation.location` в TC указывает в `.src/tests/...` | AI-агент при автоматизации |
| Результат прогона теста | `last-run` в TC | **только бот** по факту прогона |
| Связь requirement ↔ TC | `verified-by` в требовании, `verifies` в TC (с `requirement-version`) | AI-агент на финализации (derived) |
| Связь requirement → task (TR) | TAUSIK DB / KAI DB, поле `senar-req-id` в задаче | разработчик через `/task` |
| Агрегаты покрытия | `COVERAGE.md`, `TEST-PLAN.md`, `REQUIREMENTS.md` | бот при `[coverage]` коммите, `linguist-generated=true` |
| UX baseline | `ai-concepts/baselines/UIC-NN-*.png` | AI-агент через `[baseline-update]` тег + approval |
| Eval датасет | `ai-concepts/eval-datasets/AIC-NN-*.jsonl` | AI-агент-генератор + AI-критик + спот-чек 10% инженером |

**Что упрощаем во frontmatter требования** (исключаем дубликаты git, ~20-25% строк):

- `version`, `created`, `updated`, `changes` — git это знает.

**Что СОХРАНЯЕМ как обязательное** (исправление к версии 0.1):

- **TC-файлы** (`tests/TC-NN.md`) — first-class артефакт, нормируется `testing-methodology.md`. Спецификация проверки + связь с реализацией через `automation.location`. Не сводим к TAUSIK tasks.
- **`verified-by:`** в требовании — derived auto-fill, основа QG-2.
- **`COVERAGE.md` / `TEST-PLAN.md` / `REQUIREMENTS.md`** — auto-generated bot-commits, источник истины о покрытии и состоянии.
- **`ai-concepts/baselines/`** — PNG-эталоны для UX-тестов с perceptual diff.
- **`ai-concepts/eval-datasets/`** — JSONL для AIC eval-тестов, своя процедура версионирования и спот-чека.

### 5.2 Substrate B — Raven CouchDB (когда готов)

**Проект** = запись в Raven (`kai_<project>` database).

**Source of truth по полям:**

| Поле | Substrate B (Raven) | Кто пишет |
|---|---|---|
| Текст требования | поле `body` в `requirement_meta` | AI-агент через Hub UI или MCP |
| ID | `slug` + `_id = <project>:requirement_meta:<slug>` | AI-агент, immutable |
| Иерархия | `parent`, `children` поля | runtime (auto-fill children при создании ребёнка) |
| Approved | `status` enum | архитектор через approval workflow в Hub |
| Версия | `_rev` + `tool_event` audit log | CouchDB |
| История | `tool_event` doc-type | runtime |
| Связь с ТЗ | `created_by_order`, `last_modified_by_order` | runtime при импорте work-order |
| Связь requirement → task | `linked_tasks` | runtime при `task add` |
| TC как сущность | doc-type `test_case` (требует добавления в Raven) | AI-агент через MCP |
| Связь requirement ↔ TC | `linked_tests` в requirement, `verifies` в test_case | runtime |
| Результат прогона | `verification_runs` doc-type (уже есть) | бот через MCP |
| Покрытие тестами (агрегат) | derived view от `linked_tests` × последний `verification_run` | runtime |

### 5.3 Изоморфизм substrate A ↔ substrate B

Каждое поле git frontmatter имеет **точное соответствие** в CouchDB документе:

```
git frontmatter requirement                CouchDB requirement_meta
──────────────────────────────────────────────────────────────────
id: "BR-01"                          →    slug: "BR-01"
type: BR                             →    level: "BT"
status: approved                     →    status: "approved"
parent.id: BR-01                     →    parent: "BR-01"
source.document: TZ-2026-001         →    created_by_order: "TZ-2026-001"
source.section: "§4"                 →    (artifact_ref / contract)
verified-by: [TC-01, TC-02]          →    linked_tests: [TC-01, TC-02]

git frontmatter TC                         CouchDB test_case (новый doc-type)
──────────────────────────────────────────────────────────────────
id: "TC-01"                          →    slug: "TC-01"
type: system                         →    test_type: "system"
status: passing                      →    status: "passing"
verifies[].id: SR-01                 →    verifies: ["SR-01"]
verifies[].requirement-version: 1.2  →    verifies_version: "1.2"
automation.location: "..."           →    automation_location: "..."
last-run                             →    последний verification_run
```

**Изоморфизм даёт миграцию как механическую операцию.** Не «переписывание», а конвертация по таблице. Это снимает основной риск переключения substrate.

> Замечание по Raven: `requirement_meta` уже реализован (`api/routers/requirements.py`), `verification_runs` есть. **`test_case` как отдельный doc-type ещё нужно добавить** — это конкретный gap, который проявит себя при миграции git→Raven. Зафиксировано в дорожной карте Этап 2.

### 5.4 Когда какой substrate использовать

| Сценарий | Substrate | Обоснование |
|---|---|---|
| Внешний клиент, проект на TAUSIK | A (git) | TAUSIK ставится за 3 минуты, Raven ставить не будем |
| Open source проект | A (git) | Без зависимости от внутренней инфры |
| Andersen Stack, СЕЙЧАС | A (git) | Raven ещё не в проде |
| Andersen Stack, после ввода Raven | B (Raven) | Уже есть runtime, FTS, метрики |
| Договорной снапшот для клиента | A (git, derived) | Клиенту нужен подписываемый документ |

---

## 6. Pattern: `.req` как submodule в `.src`

Это отдельно описано, потому что решает важную проблему — **provenance кода относительно версии требований**.

### 6.1 Структура

```
<project>/
├── <project>.src/                          ← основной репозиторий разработки
│   ├── src/
│   ├── tests/                              ← реализации тестов; адресуются `automation.location` из TC
│   ├── .tausik/                            ← TAUSIK runtime (или .claude/ для KAI)
│   ├── requirements/                       ← submodule → <project>.req @ <commit>
│   │   └── (содержимое .req репо на конкретном коммите)
│   ├── .gitmodules
│   └── README.md
└── <project>.req/                          ← отдельный репозиторий требований
    ├── br/                                 ← BR-NN-*.md
    ├── sr/                                 ← SR-NN-*.md
    ├── ui-concepts/                        ← UIC-NN-*.md
    ├── int-sr/                             ← INT-SR-NN-*.md
    ├── ai-concepts/
    │   ├── AIC-NN-*.md
    │   ├── eval-datasets/                  ← JSONL для AIC eval-тестов
    │   └── baselines/                      ← PNG-эталоны для UX-тестов
    ├── tech-specs/                         ← TS-NN-*.md
    ├── tests/                              ← TC-NN-*.md, INT-TC-NN-*.md (first-class)
    ├── tz/                                 ← TZ-YYYY-NNN.md + индексы
    ├── library/
    │   ├── patterns/
    │   └── templates/                      ← скопированные шаблоны
    ├── docs/                               ← AI-generated документация
    ├── REQUIREMENTS.md                     ← bot-generated, [coverage]
    ├── TEST-PLAN.md                        ← bot-generated, [coverage]
    └── COVERAGE.md                         ← bot-generated, [coverage]
```

`linguist-generated=true` через `.gitattributes` для трёх MD-сводок и `docs/` — исключает их из статистики кода и MR diff'ов.

### 6.2 Как это работает

- `<project>.src` фиксирует **конкретный коммит** `<project>.req` через submodule.
- При сборке/CI код знает: «я реализую требования по состоянию на commit `abc1234`».
- Разработчик в задаче TAUSIK видит ссылку на SR-05 — открывает `requirements/sr/SR-05-*.md`, читает.
- При обновлении требований: PR в `<project>.req`, merge, потом отдельный PR в `<project>.src` который **только** двигает submodule pointer.
- Этот второй PR явно показывает: «требования обновились, вот diff, вот какие задачи затронуты».

### 6.3 Что это даёт

- **Провенанс**: для любого коммита кода точно известно, какую версию требований он реализовывал.
- **Ревью двух уровней**: сначала ревью требований (в `.req`), потом ревью кода (в `.src`). Не смешивается.
- **Атомарность дельта-ТЗ**: PR с дельта-ТЗ в `.req` сначала, потом PR в `.src` который двигает submodule + обновляет затронутые задачи. Ровно тот workflow, который хочет партнёр.
- **Совместимость с TAUSIK**: TAUSIK skill читает `requirements/sr/SR-NN.md` через обычный read — это просто файл в worktree.
- **Совместимость с Raven позже**: при переходе на Raven submodule pinning превращается в `requirement_meta._rev` pinning — концепция та же.

### 6.4 Workflow дельта-ТЗ (партнёрский, перенесённый на этот pattern)

```
1. Инженер:        git checkout -b change/TZ-2026-002 в <project>.req
2. AI-агент:       создаёт tz/TZ-2026-002-delta.md (текст ТЗ)
3. AI-агент:       impact analysis по требованиям и по TC
                   (затронутые TC помечает obsolete-pending)
4. AI-агент:       обновляет/создаёт BR/SR/UIC и парные TC (pos+neg) в той же ветке
5. AI-агент:       реализует обновлённые тесты в .src через automation.location
                   (отдельный коммит в feature-ветке .src если изменились реализации)
6. CI:             dry-run новых TC → должны запускаться без ошибок инфры
7. AI-агент:       финализация — version++, status: ready, regenerate REQUIREMENTS/COVERAGE/TEST-PLAN
8. Архитектор:     PR в <project>.req → one-click approval QG-0 → merge
9. Tech Lead:      git checkout -b change/TZ-2026-002 в <project>.src
10. Tech Lead:     cd requirements && git pull && cd ..  (бьёт submodule pointer)
11. Tech Lead:     создаёт TAUSIK tasks по новым/изменённым SR (через /task с senar-req-id)
12. Tech Lead:     PR в <project>.src «bump requirements + tests + new tasks» → ревью → merge
13. Разработка:    взять task → реализовать → CI прогон → бот заполняет last-run в TC
14. Архитектор:    при зелёных TC — one-click approval QG-2 → AI-агент переводит требование в verified
```

Это и есть тот ручной workflow, про который говорил партнёр — атомарная дельта-ТЗ через PR, ревью договорного документа, явный bump submodule, only after merge запуск задач. Стандарт лишь добавляет TC и quality gates.

---

## 7. Где рождается дрифт и как его избегать

Восемь классов дрифта, для каждого — конкретный контракт.

### 7.1 Schema drift

**Что**: поля в git frontmatter и в CouchDB документе расходятся.

**Когда возникает**: кто-то добавляет поле во frontmatter, не обновляя Raven schema, и наоборот.

**Контракт**:
- Schema описана **один раз** в этом стандарте (раздел будет выделен в `requirement-schema.md`).
- CI-проверка: на каждый PR в `<project>.req` парсится frontmatter, валидируется по JSON Schema.
- При расхождении CI красный.

### 7.2 Lifecycle drift

**Что**: статусы (draft/review/approved/obsolete) или Quality Gates имеют разный смысл в git и в Raven.

**Когда возникает**: разработчик в одном substrate понимает «approved» как «принял архитектор», в другом — «принял клиент».

**Контракт**:
- Состояния и переходы фиксированы в стандарте как state machine с pre/post-условиями.
- На git-substrate: переходы выполняются скриптом (`tausik req promote --to approved`), не ручной правкой frontmatter.
- На Raven-substrate: переходы — через API endpoint с проверкой условий.
- Скрипт и API используют **общую таблицу** условий (импортируется из YAML стандарта).

### 7.3 Source-of-truth drift (главный риск партнёрского подхода + Raven)

**Что**: одна и та же сущность правится и в git, и в Raven. Разводятся.

**Когда возникает**: переход с git на Raven делается частично, или обе системы работают параллельно.

**Контракт**:
- В каждый момент времени для проекта **выбран ровно один SSoT-substrate**. Конфигурация явная: `req.substrate: git | raven` в `<project>.src/.tausik/config.json`.
- Второй substrate — derived snapshot, read-only.
- Миграция между substrate — атомарная операция через `tausik req migrate`. Не «постепенный переход».
- На уровне UI: TAUSIK skill `/req-edit SR-05` смотрит на `req.substrate` и пишет только в один.

### 7.4 Implementation drift

**Что**: код в `.src` ссылается на SR, которого больше нет (deprecated, переименован, удалён).

**Когда возникает**: refactor требований без обновления кода, или наоборот.

**Контракт**:
- ID требований **immutable** — стандартом запрещено переименовывать BR-01 в BR-08. Заменять — через `deprecated` + новый ID.
- TAUSIK хук перед commit'ом в `.src`: ищет в diff упоминания SR-NN, проверяет существование в `requirements/` (submodule). При отсутствии — блок коммита.
- `tausik req orphans` — отчёт: SR без задач, задачи без SR.

### 7.5 Terminological drift

**Что**: «verified», «implemented», «approved» означают разное у разных людей.

**Когда возникает**: всегда, если термины не зафиксированы.

**Контракт**:
- Глоссарий в стандарте. Каждый термин = ровно одно состояние lifecycle.
- В коде/UI: использовать только термины из глоссария.
- В review checklist: «обнаружили термин не из глоссария — отклонить PR».

### 7.6 Order/provenance drift

**Что**: дельта-ТЗ #2 ссылается на SR, который был создан в дельте #1, но порядок применения был обратный — SR-NN не существовал.

**Когда возникает**: ветки дельта-ТЗ не сериализуются.

**Контракт**:
- Дельта-ТЗ нумеруются и применяются в порядке номеров. Перенумеровать нельзя.
- На каждый `requirement_meta` хранится `created_by_order` (ТЗ, в котором появился) и `last_modified_by_order` (последний апдейт).
- При impact analysis дельта-ТЗ обязан быть «применим» (все upstream ТЗ уже применены).

### 7.7 TC ↔ requirement provenance drift

**Что**: тест-кейс верифицирует требование, но требование уже изменилось — `last-run.requirement-version` ниже текущей `version` требования. Тест может быть зелёным, но проверяет устаревшее поведение.

**Когда возникает**: дельта-ТЗ изменил требование, но затронутые TC не обновили или не перезапустили.

**Контракт**:
- В TC обязательное поле `verifies[].requirement-version` — pinned версия требования.
- При изменении требования AI-агент находит все TC с устаревшей `verifies.requirement-version`, помечает `obsolete-pending`, обновляет/перезапускает в той же ветке.
- В `COVERAGE.md` отдельная категория «Stale» — TC с `last-run.requirement-version` ниже текущей. Метрика-краснеет до перезапуска.
- QG-2 запрещает перевод требования в `verified`, если хотя бы один TC из `verified-by` имеет stale `last-run`.

### 7.8 Test-fitting drift

**Что**: AI-агент имеет тривиальный путь зеленения теста — ослабить Pass/Fail-критерий вместо исправления кода. Без защиты тесты дрейфуют от «строгий проверщик» к «зелёная пустота».

**Когда возникает**: AI-агент в одном MR меняет и реализацию (`automation.location`), и Pass/Fail-критерии TC, чтобы failing стал passing.

**Контракт**:
- MR, изменяющий Pass/Fail-критерии в `tests/TC-*.md`, обязан иметь тег `[test-spec-change]` и **отдельный** approval инженера, не совмещённый с approval'ом фикса кода.
- CI-проверка: diff в TC-файле в полях `pass`/`fail`/`vlm-judge.pass-criteria`/`vlm-judge.fail-criteria`/`eval.metrics[].threshold` без `[test-spec-change]` тега → блок merge.
- Изменение `automation.location` без изменения критериев — допустимо без отдельного approval (это перемещение реализации, не ослабление).
- Изоляция judge-модели в eval: production-модель ≠ judge-модель. CI блокирует совпадение.
- Спот-чек инженером 5 случайных passing-TC раз в спринт — структурный rate-limit для дрифта.

---

## 8. Дорожная карта

### Этап 0 — Фиксация стандарта (СЕЙЧАС, до 15 мая)

**Цель**: RENAR становится готовым нормативным документом.

- [ ] Этот документ согласован с партнёром.
- [ ] Выделен `requirement-schema.md` — формальная JSON Schema с полями, enum, инвариантами.
- [ ] Выделен `requirement-lifecycle.md` — state machine с переходами и предусловиями.
- [ ] Глоссарий терминов вынесен в `glossary.md`.
- [ ] Существующие `requirements-methodology.md` / `requirements-storage-standard.md` приведены в соответствие (выкидываются дубликаты git, добавляется substrate-agnostic язык).

### Этап 1 — Лёгкая имплементация на git-substrate для TAUSIK (1-2 недели)

**Цель**: можно начать работать по RENARу прямо сейчас, без Raven.

- [ ] TAUSIK skill `req` (заменяет bash-скрипты):
  - `/req-init` — инициализация `.req` репо как submodule в `.src` с базовой структурой.
  - `/req-import-tz` — импорт ТЗ в `tz/`, генерация индекса маппинга.
  - `/req-decompose` — декомпозиция ТЗ → BR/SR/UIC (с placeholder для архитектора).
  - `/req-impact <delta>` — impact analysis для дельта-ТЗ (требования + TC + затронутые задачи).
  - `/req-promote <id> --to approved|verified` — продвижение по lifecycle с проверкой предусловий QG.
  - `/req-search` — поиск через FTS5.
  - `/req-orphans` — отчёт: SR без TC, TC без SR, требования без negative TC.
- [ ] TAUSIK skill `tc` (тестовая методология):
  - `/tc-generate <req-id>` — генерация pos/neg TC для требования.
  - `/tc-automate <tc-id>` — генерация реализации в `.src` + заполнение `automation.location`.
  - `/tc-run <tc-id>` — прогон, заполнение `last-run` через бот-роль.
  - `/tc-coverage` — перегенерация `COVERAGE.md` и `TEST-PLAN.md`.
  - `/tc-spotcheck` — выбор 5 случайных passing-TC для ручной проверки инженером.
- [ ] TAUSIK хуки:
  - PreCommit в `.src`: проверка что упомянутые SR/TC существуют в submodule.
  - PreCommit в `.req`: валидация frontmatter по schema; блок merge при diff критериев Pass/Fail без `[test-spec-change]` тега.
  - PreCommit в `.req`: блок если eval-TC указывает judge-модель совпадающую с production-моделью AIC.
  - Task creation: автозапись `senar-req-id` в задачу.
  - QG-2 хук: блок перевода требования в `verified` без зелёных TC из `verified-by`.
- [ ] Конвертер существующего `notification_catcher.req` под обновлённый формат (TC остаются, фронтматтер требований — без `version/updated/changes`).

### Этап 2 — Raven готов и принят (после +2-4 недели)

**Цель**: для проектов Andersen Stack включается Raven-substrate.

- [ ] **Добавить в Raven `test_case` doc-type** — это конкретный gap, выявленный в разделе 5.3.
- [ ] Скрипт миграции `tausik req migrate --from git --to raven --project <slug>`.
- [ ] Скрипт обратного экспорта `tausik req export --substrate raven --output ./req-snapshot/` (для договорных артефактов клиенту).
- [ ] TAUSIK / KAI skill `req` поддерживает оба substrate через конфиг `req.substrate`.
- [ ] Raven schema требований и тест-кейсов приведена к точному соответствию JSON Schema стандарта.
- [ ] CI-проверка изоморфизма: каждое поле git ↔ Raven map, новые поля попадают через PR в стандарт.
- [ ] Использовать существующий `verification_runs` doc-type как backend для `last-run`.

### Этап 3 — Стабилизация и Hub UI (+ ещё 2-4 недели)

**Цель**: для архитекторов появляется удобный интерфейс ревью требований и тест-кейсов.

- [ ] Raven Hub UI: diff/comment/approve workflow для requirements + TC (то, что партнёр интуитивно делал через MR в git — теперь нативно для Raven-substrate).
- [ ] One-click approval в Hub для QG-0 / QG-2 / `[test-spec-change]` / `[baseline-update]`.
- [ ] Cross-project search в Hub.
- [ ] Дашборд COVERAGE/SENAR-метрик (FPSR, DER, KCR) в Hub поверх requirements + TC.
- [ ] Спот-чек workflow в Hub: random sample 5 passing-TC раз в спринт с фиксацией результата.
- [ ] Закрытие gap'ов: требования стандарта, которые не покрыты ни одним substrate.

---

## 9. Решения, которые надо зафиксировать сейчас

Перед тем как начать что-то писать в коде или в скиллах, надо договориться по следующим пунктам. **Это и есть тот «момент рождения энтропии», который нужно поймать**.

### 9.1 Архитектурные

| # | Вопрос | Предлагаемый ответ |
|---|---|---|
| A1 | REQ — это нормативный документ или имплементация? | Нормативный, substrate-agnostic; три документа: methodology + storage + testing-methodology |
| A2 | Один SSoT для проекта или два? | Один в каждый момент времени, явно выбран в конфиге |
| A3 | Где правда о тексте требования? | На git-substrate — `.md` файл; на Raven-substrate — `requirement_meta.body` |
| A4 | Где правда о статусе/QG? | Тот же substrate, что и текст. Не разводим. |
| A5 | Где правда о версии требования? | Substrate-нативно: git commit hash или CouchDB `_rev`. Не дублируем во frontmatter. |
| A6 | Где живёт связь requirement ↔ task? | TAUSIK DB / Raven `linked_tasks`. Не во frontmatter. |
| A7 | Где хранятся TC (test cases)? | **First-class артефакт** в `.req/tests/` (на Raven — отдельный `test_case` doc-type, который надо добавить). Не сводимы к TAUSIK tasks. |
| A8 | Two-repo `.req` + `.src` через submodule? | Да, для git-substrate. Решает provenance кода относительно версии требований и тестов. |
| A9 | `last-run` теста — где правда? | TC frontmatter поле `last-run`, заполняется ТОЛЬКО ботом по факту прогона. На Raven — `verification_runs` doc-type. |
| A10 | Изменение Pass/Fail-критериев теста — что требует? | `[test-spec-change]` тег + отдельный one-click approval инженером, не совмещённый с approval'ом фикса кода. |

### 9.2 По партнёрскому workflow

| # | Вопрос | Предлагаемый ответ |
|---|---|---|
| B1 | ТЗ через дополнения или правки? | Дополнения (дельта-ТЗ). Никогда не редактируем подписанный ТЗ. |
| B2 | Дельта-ТЗ как отдельная ветка → PR → merge? | Да. На обоих substrate (для Raven — через API workflow). |
| B3 | Кто инициирует дельта-ТЗ? | Архитектор после согласования с клиентом. |
| B4 | Запуск работы после merge'а дельты? | Да, и только тогда. Никаких задач до approved требований. |

### 9.3 По формату файлов на git-substrate

| # | Вопрос | Предлагаемый ответ |
|---|---|---|
| C1 | Frontmatter поля версионирования (`version`, `updated`, `changes`)? | **Удалить**. Это git. |
| C2 | Поле `verified-by: [TC-NN]`? | **Оставить** — derived auto-fill, основа QG-2. |
| C3 | Файлы `TC-NN.md` в `tests/`? | **Оставить** — first-class артефакт, нормируется testing-methodology. |
| C4 | Сводные файлы `COVERAGE.md` / `TEST-PLAN.md` / `REQUIREMENTS.md`? | **Оставить** — auto-generated bot-commits с `linguist-generated=true`, тег `[coverage]`. |
| C5 | Что остаётся обязательным во frontmatter требования? | `id`, `title`, `type`, `parent`, `source`, `status`, `verified-by` (auto), `priority`. |
| C6 | Что обязательно во frontmatter TC? | `id`, `title`, `type`, `verifies[].requirement-version`, `negative`, `automation.{status,location,runner}`, `last-run` (bot-only). |
| C7 | UX baseline (`ai-concepts/baselines/`) — где хранится? | В `.req`, обновляется через `[baseline-update]` тег с approval. |
| C8 | Eval-датасеты (`ai-concepts/eval-datasets/`)? | В `.req`, JSONL формат, AI-генератор + AI-критик + 10% спот-чек инженером. |

### 9.4 По миграции на Raven

| # | Вопрос | Предлагаемый ответ |
|---|---|---|
| D1 | Когда мигрировать существующие проекты? | После приёмки Raven, по одному, явным решением. |
| D2 | Что делать с git-репо после миграции? | Либо архивируем, либо превращаем в derived snapshot (read-only export из Raven). |
| D3 | Два substrate одновременно работающие? | Запрещено. SSoT — ровно один в каждый момент. |
| D4 | Что если клиент хочет получить требования как документ после миграции? | `tausik req export --substrate raven --output ./snapshot/` — снапшот для PDF/договора. |

---

## Приложение A. Что не вошло, но требует отдельного документа

- `requirement-schema.md` — формальная JSON Schema (поля, типы, инварианты).
- `requirement-lifecycle.md` — state machine с pre/post-условиями.
- `work-order-decomposition.md` — нормативка для импорта ТЗ и дельта-ТЗ.
- `tausik-req-skill.md` — спецификация TAUSIK skill (команды, аргументы, поведение).
- `glossary.md` — глоссарий терминов REQ.
- Mapping таблица substrate A ↔ substrate B (изоморфизм полей).

Эти документы — следующая итерация после согласования основной архитектуры из этого файла.

---

## Приложение B. Связь со SENAR

RENAR дополняет SENAR в зоне, которую SENAR оставил абстрактной:

| SENAR говорит | REQ конкретизирует |
|---|---|
| §3 Иерархия БТ → СТ → ТМ → ТЗ | Поля parent/children, immutable IDs, правила декомпозиции |
| §6 Единицы работы (Task, Story) | Связь requirement ↔ task через `linked_tasks` / `senar-req-id` |
| §8 Quality Gates QG-0..QG-4 | State machine переходов, предусловия, enforcement через хуки |
| §10.1 Реализация без Task запрещена | TAUSIK хук блокирует commit без активного task с привязкой к SR |
| §3.21 Трассировка БТ → СТ → ТЗ | `created_by_order` + provenance chain в обе стороны |

REQ **не противоречит** SENAR — он специфицирует то, что SENAR оставил на усмотрение реализации.
