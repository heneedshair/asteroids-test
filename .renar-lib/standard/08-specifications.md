---
title: "Спецификации (9 типов SPEC)"
order: 8
lang: ru
---
# 08. Спецификации — 9 типов SPEC

> **Часть RENAR Standard v1.0-draft** · [← Оглавление](README.md)

## 8.1 Зачем отдельная ось спецификаций

Возьмём требование «система создаёт заказ». Оно говорит, **что** должно происходить — но молчит о том, **как** система для этого устроена: какой у неё API-контракт, в какой таблице лежит заказ, по каким правилам доступа, на каком экране. Втиснуть всё это в само требование не выйдет — оно превратится в кашу. Поэтому RENAR разводит описание на две оси: **поведение** (BR / SR / TR, [глава 6](06-requirements-hierarchy.md)) и **структуру** — спецификации, SPEC.

Спецификация — не «более детальный SR» и не его ребёнок. Одно требование «создать заказ» обычно опирается сразу на пять-семь спецификаций (архитектура, API, данные, процесс, безопасность, экран), поэтому связь между осями — граф типизированных рёбер (`constrained-by[]`, `implements-spec[]`), а не дерево. Типов спецификаций ровно девять, и список закрыт: `SPEC-ARCH`, `API`, `DATA`, `INT`, `PROC`, `UI`, `AI`, `SEC`, `OPS` — новый тип вводится только через формальную процедуру изменения стандарта ([глава 13](13-conformance.md)).

---

## 8.2 Архитектурное решение: SPEC — параллельная ось, не дети SR

### 8.2.1 Две оси описания системы

Требования и спецификации отвечают на разные вопросы:

| Ось | Артефакты | Вопрос |
|---|---|---|
| Поведенческая | BR / SR / TR ([глава 6](06-requirements-hierarchy.md)) | Что система должна делать |
| Структурная | SPEC-* (9 типов) | Как система структурно устроена для выполнения этих требований |

### 8.2.2 SPEC как параллельная ось: связи через типизированный граф

Связи между осью требований (BR / SR / TR) и осью SPEC организованы как **граф зависимостей**, не дерево родителей. У SR ровно один родитель в дереве требований (BR), но множество типизированных рёбер `constrained-by[]` на SPEC. Один SR обязан ссылаться на каждую SPEC, ограничивающую его поведение в осях API / data / UI / process / security / ops; обратно — одна SPEC может ограничивать множество SR.

Пример: SR «создать заказ» опирается на SPEC-ARCH (где живёт компонент заказов), SPEC-API (контракт endpoint), SPEC-DATA (схема таблицы), SPEC-PROC (workflow), SPEC-SEC (правила доступа), SPEC-UI (форма).

Нормативно: каждое ребро `SR.constrained-by[]` и `TR.implements-spec[]` **должно** ссылаться на одну из закрытых категорий SPEC, перечисленных в [§8.3](#8.3); ad-hoc категории не допускаются (см. [§1.7](01-scope.md#1.7) closed-list policy).

```text
Дерево требований (поведенческая ось):     Параллельная ось спецификаций:

BR                                          SPEC-ARCH    SPEC-API
 └── SR  ←──── constrained-by[] ────►       SPEC-DATA    SPEC-INT
      └── TR ─── implements-spec[] ────►    SPEC-PROC    SPEC-UI
                                            SPEC-AI      SPEC-SEC
                                            SPEC-OPS

Дерево требований:
  SR.parent              → BR              (единственный родитель)
  TR.parent              → SR              (единственный родитель)

Граф связей (типизированные рёбра):
  SR.constrained-by[]    → SPEC-*
  TR.implements-spec[]   → SPEC-*
  SPEC-*.depends-on[]    → SPEC-*          (между спецификациями)
  SPEC-*.referenced-by[] → SR / TR          (auto-derived inverse)
```

### 8.2.3 Обоснование

| Аргумент | Следствие |
|---|---|
| SPEC и SR отвечают на разные вопросы | SPEC не уточняет SR на более глубоком уровне — это отдельная категория описания |
| Один SR опирается на 5–7 SPEC | Дерево «SPEC как родитель SR» приводит к множественному родительству |
| Industry standards (arc42, C4, OpenAPI, BPMN, ERD) живут параллельно требованиям | RENAR следует этой проверенной практике |
| AI-агент может параллелить генерацию SR и SPEC | Без блокировки одного типа другим |

---

## 8.3 Закрытый список из девяти типов SPEC

| Тип | Назначение | Industry reference |
|---|---|---|
| `SPEC-ARCH` | Архитектура системы / подсистемы: контексты, контейнеры, компоненты, deployment view, quality attributes | arc42, C4 model (Brown), ISO/IEC/IEEE 42010 |
| `SPEC-API` | API contracts: REST / GraphQL / gRPC / async events; версионирование, error model, rate limits | OpenAPI 3.x, AsyncAPI 2.x, gRPC IDL |
| `SPEC-DATA` | Модель данных: schema, ERD, indices, миграции, retention, PII classification | ISO/IEC 11179, JSON Schema |
| `SPEC-INT` | Integration: взаимодействие между подсистемами и внешними системами; протоколы, контракты, SLA | Enterprise Integration Patterns (Hohpe) |
| `SPEC-PROC` | Process / workflow: бизнес-процессы, state machines, saga, choreography, orchestration | BPMN 2.0, ISO/IEC 19510 |
| `SPEC-UI` | UI / UX: экраны, навигация, user journeys, accessibility, i18n, эталонные изображения | Material Design / Apple HIG, WCAG 2.2 |
| `SPEC-AI` | AI / ML: model cards, RAG, prompt engineering, eval strategy, cost budget | ISO/IEC 23894, NIST AI RMF |
| `SPEC-SEC` | Security: authn / authz, threat model, secrets management, data classification | STRIDE, OWASP ASVS, ISO/IEC 27001 |
| `SPEC-OPS` | Operations: deployment, observability, SLO / SLA, runbook, disaster recovery | Google SRE, ITIL v4, ISO/IEC 20000 |

### 8.3.1 Что НЕ вошло в v1.0 (с обоснованием)

| Кандидат | Решение | Обоснование |
|---|---|---|
| `SPEC-EVENT` | Не отдельный тип | События / очереди — раздел SPEC-API (asynchronous APIs) |
| `SPEC-CONFIG` | Не отдельный тип | Feature flags / env vars / secrets — раздел SPEC-OPS |
| `SPEC-PERF` | Не отдельный тип | Performance / NFR — раздел SPEC-ARCH (quality attributes) или SPEC-OPS (SLO) |
| `SPEC-TEST-ENV` | Не отдельный тип | Тестовые окружения — раздел SPEC-OPS |
| `SPEC-DOMAIN` | Не отдельный тип | Domain model — поглощён SPEC-ARCH (decomposition) + SPEC-DATA (entities) |
| `SPEC-MIGRATION` | Не отдельный тип | Migration — раздел SPEC-DATA (жизненный цикл) |
| `SPEC-COMPLIANCE` | Не отдельный тип | Compliance — связи между SR/SPEC и нормативами через `compliance-refs[]`, не отдельный артефакт |

Политика закрытого списка: если в дальнейшей работе обнаружится, что какой-то из исключённых типов реально нужен — он добавляется через формальную процедуру изменения стандарта с обоснованием.

---

## 8.4 Общая схема (общие поля frontmatter)

Все 9 типов SPEC делят общий набор frontmatter полей. Поля, специфичные для типа, добавляются как расширения поверх (§8.5). Полная machine-readable модель данных — в [reference/02-schemas.md](../reference/02-schemas.md).

```yaml
---
# === Identity (обязательно) ===
id: SPEC-<TYPE>-NN[.N]              # immutable; TYPE ∈ {ARCH,API,DATA,INT,PROC,UI,AI,SEC,OPS}
title: "<short, descriptive>"
type: SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS
slug: "<kebab-case>"                # auto-derived

# === Scope (обязательно) ===
level: system | subsystem | module
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"       # null если level=system

# === Жизненный цикл (обязательно) ===
status: draft | review | approved | verified | obsolete
priority: must | should | could     # not all types use; mostly SPEC-SEC / SPEC-OPS

# === Source: provenance (conditional, см. глава 7 §7.4.1) ===
# source.adapt — conditional (present когда ADAPT создавался; §7.4.1.1).
# source.tz-section — обязательно всегда.
# source.adversarial-review-ref — обязательно когда source.adapt omitted.
source:
  adapt: ADAPT-NNN                  # conditional
  adapt-section: "Forward §N"       # обязательно если adapt present
  tz-section: "§N.N"                # обязательно всегда
  adversarial-review-ref: "<нативная для носителя ссылка>"   # обязательно если adapt omitted

# === Граф связей (auto-managed except mandatory ones) ===
referenced-by: []                   # auto-derived; SR/TR/SPEC ссылающиеся сюда
depends-on: []                      # обязательно если есть; SPEC-* на которые опирается этот SPEC
verified-by: []                     # auto-derived; список TC IDs верифицирующих

# === AI provenance (обязательно на RENAR-4+; каноническая schema — §4.10.1) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  generated-at: "<ISO-8601>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  human-edits: boolean
  generation-time-ms: integer        # optional; см. §4.10.1
  # optional на RENAR-4, обязательно на RENAR-5:
  # cost-budget, cost-actual

# === Замена (обязательно если применимо) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"

# === Compliance (optional) ===
compliance-refs: []                 # ссылки на ISO/GDPR/AI Act/NIST AI RMF
---
```

### 8.4.1 Обязательные разделы body

Body любого SPEC обязательно содержит:

1. **Назначение** — 1–3 параграфа.
2. **Scope** — что входит, что не входит.
3. **Разделы, специфичные для типа** — см. §8.5.
4. **Связь с требованиями** — какие SR/BR ссылаются.
5. **Связь с другими SPEC** — `depends-on[]`.
6. **Verification** — какие TC верифицируют этот SPEC.

---

## 8.5 Расширения схемы по типам SPEC

Краткое описание специфичных для типа полей и обязательных body-разделов. Полная machine-readable extension schema — в [reference/02-schemas.md](../reference/02-schemas.md). Industry references детально — в указанных стандартах.

### 8.5.1 SPEC-ARCH

**Type-specific frontmatter**: `arch-style`, `deployment-model`, `tech-stack`, `quality-attributes`.

**Обязательное тело**: системный контекст (C4 L1), контейнеры (C4 L2), компоненты (C4 L3) для критических контейнеров, quality attributes (latency / throughput / availability), ADR-журнал.

**Spec-specific TC** ([глава 9](09-test-cases.md)): тесты соответствия архитектуры (zoning), эталонные тесты атрибутов качества.

### 8.5.2 SPEC-API

**Type-specific frontmatter**: `api-style` (rest / graphql / grpc / async-events), `api-version`, `versioning-strategy`, `authentication`, `rate-limits`, `contract-file` (location of machine-readable contract).

**Обязательное тело**: endpoints / operations с payload / response / errors, versioning rules (breaking vs non-breaking), error model, authn/authz reference на SPEC-SEC, rate limits, 2–3 example запросов на endpoint.

**Spec-specific TC**: contract tests, authentication negative, rate limit tests.

### 8.5.3 SPEC-DATA

**Type-specific frontmatter**: `data-style` (relational / document / graph / columnar), `storage-engine`, `schema-version`, `pii-classification[]`, `retention-policies[]`, `migration-strategy`.

**Обязательное тело**: domain entities, ERD (text / Mermaid / link), поля сущностей (type / constraints / indices / defaults), связи (FK / cardinality / cascade), PII / sensitive data classification + encryption at-rest + retention, migration approach, index strategy.

**Spec-specific TC**: migration tests, constraint tests (FK / NOT NULL / unique), PII handling tests, data retention tests.

### 8.5.4 SPEC-INT

**Type-specific frontmatter**: `integration-pattern` (request-response / event-driven / message-queue / webhook / file-transfer), `direction`, `counterparty`, `sla`, `idempotency`.

**Обязательное тело**: интегрируемые системы, контракт обмена, failure modes + retry strategy, идемпотентность + dedup, security между системами, observability (correlation IDs).

**Spec-specific TC**: contract tests с моком counterparty, failure injection, idempotency, end-to-end TC `tc-type: contract`.

**Замечание**: SPEC-INT заменяет существующий `INT-SR` ([§8.7](#8.7) migration).

### 8.5.5 SPEC-PROC

**Type-specific frontmatter**: `process-style` (bpmn / state-machine / saga / choreography / orchestration), `state-count`, `participants[]`, `sla` end-to-end и по шагам, `compensation` (defined / not-applicable / manual).

**Обязательное тело**: process diagram (BPMN-flavor / Mermaid / link), состояния и переходы (для машины состояний), participants и их роли, happy path, альтернативные сценарии и исключения, timeouts и compensation (для saga), SLA.

**Spec-specific TC**: happy path E2E, alternative paths, compensation tests (для saga), SLA tests.

### 8.5.6 SPEC-UI

**Type-specific frontmatter**: `ui-platform`, `target-users[]` (с ссылками на persona разделы ADAPT), `design-system`, `accessibility-level` (WCAG-A / AA / AAA), `i18n`, `mockup-links[]`, `baseline-images[]` для VLM-judge тестов.

**Обязательное тело**: общая структура интерфейса, ключевые экраны, user journeys без технических деталей, сквозные элементы (права доступа / уведомления / error / empty states), тон и стиль, accessibility, i18n.

**Spec-specific TC**: VLM-judge с эталоном (judge ≠ production изоляция), accessibility (axe-core / Pa11y), i18n (string overflow / RTL), user journey E2E.

**Замечание**: SPEC-UI заменяет существующий `UIC` ([§8.7](#8.7) migration).

### 8.5.7 SPEC-AI

**Type-specific frontmatter**: `ai-pattern` (rag / fine-tuning / prompt-engineering / tool-use / multi-agent), `production-model` (vendor / model / version), `judge-model` (обязан отличаться от production), `context-strategy`, `eval-strategy` (metric / threshold / baseline-dataset), `cost-budget`.

**Обязательное тело**: архитектура AI-компонент (pipeline / orchestration / fallback), model card (capabilities / limits / known failure modes), context strategy, eval strategy с изоляцией judge ≠ production, cost management, hallucination mitigation, состязательные аспекты.

**Spec-specific TC**: eval против эталона (judge isolated), состязательные (prompt injection как negative TC), cost regression, hallucination tests.

**Замечание**: SPEC-AI заменяет существующий `AIC`. Изоляция judge ≠ production model — обязательное требование стандарта для всех eval-TC.

### 8.5.8 SPEC-SEC

**Type-specific frontmatter**: `security-domains[]`, `auth-model` (authn / authz strategies), `data-classification[]` (PII-high / PCI / internal), `threat-model-method` (STRIDE / PASTA / OCTAVE), `compliance[]`, `incident-response` reference в SPEC-OPS.

**Обязательное тело**: auth model (authn flow / authz rules), data classification с защитой, threat model (STRIDE-таблица с mitigation на каждую угрозу), secrets management, audit (что логируется / retention / доступ), encryption (at-rest / in-transit / key management), compliance mapping (ссылки на конкретные пункты).

**Spec-specific TC**: authn (pos + neg), authz (RBAC matrix), threat-test (каждая STRIDE-угроза → минимум 1 negative TC), журнал аудита, secrets leakage.

### 8.5.9 SPEC-OPS

**Type-specific frontmatter**: `deployment-style`, `environments[]` (dev / staging / prod с purpose и scale), `slo`, `observability` (logs / metrics / traces / alerting), `runbook-link`, `disaster-recovery` (rto / rpo / backup-strategy).

**Обязательное тело**: environments, deployment process (CI/CD pipeline / gating / rollout strategy), SLO (availability / latency / error budget), observability, alerting (критические алерты / escalation), runbook, capacity planning, disaster recovery.

**Spec-specific TC**: deployment tests (smoke), SLO regression (load testing), failover (DR drills), observability (alerts срабатывают когда ожидается).

---

## 8.6 Связь с требованиями и задачами

### 8.6.1 SR.constrained-by[]

SR в frontmatter получает поле `constrained-by[]` — типизированные ссылки на SPEC. Это **граф**, не дерево родителей. Родитель SR в дереве требований — единственный (BR).

```yaml
# Frontmatter SR (пример)
id: SR-05
parent:
  id: BR-02
constrained-by:
  - SPEC-UI-01
  - SPEC-API-02
  - SPEC-DATA-03
  - SPEC-PROC-01
  - SPEC-SEC-01
verified-by:
  - TC-12
  - TC-13
source:
  adapt: ADAPT-001
  adapt-section: "Forward §3"       # см. канонический идентификатор §8.4
```

### 8.6.2 TR.implements-spec[]

TR (задача) ссылается на SR (родитель в дереве) + одна или более SPEC через `implements-spec[]`:

```yaml
id: TR-42
title: "Реализовать endpoint POST /orders"
parent:
  id: SR-05
implements-spec:
  - SPEC-API-02
  - SPEC-DATA-03
verified-by:
  - TC-14
```

### 8.6.3 SPEC.depends-on[]

SPEC может опираться на другой SPEC:

```yaml
id: SPEC-API-02
title: "REST API заказов"
type: SPEC-API
depends-on:
  - SPEC-DATA-03         # стабильная схема данных
  - SPEC-SEC-01          # auth model для endpoints
```

При изменении upstream SPEC (например SPEC-DATA-03) все downstream (SPEC-API-02 и через него связанные SR) обязаны быть пересмотрены: либо `verified` подтверждается (изменение совместимо), либо downstream-артефакт проходит повторную проверку по своей машине состояний ([§10.7](10-lifecycle-qg.md#10.7)) и до её завершения не считается `verified` относительно новой версии upstream.

### 8.6.4 Auto-derived обратные рёбра

`SPEC.referenced-by[]` пересчитывается хуком носителя после каждого изменения SR / TR / SPEC. Orphan SPEC (без `referenced-by[]` и без активного status) — предупреждение в отчёте качества.

---

## 8.7 Миграция UIC / AIC / INT-SR / TS → SPEC-*

### 8.7.1 Mapping таблица

| Старый тип | Новый тип | Тип миграции |
|---|---|---|
| `UIC-NN` | `SPEC-UI-NN` | Переименование ID + перенос в `specs/ui/` |
| `AIC-NN` | `SPEC-AI-NN` | Переименование ID + перенос в `specs/ai/` |
| `INT-SR-NN` | `SPEC-INT-NN` | Переименование ID + перенос в `specs/int/` |
| `TS-NN` | `SPEC-<TYPE>-NN` (распределение) | Manual review каждого TS; AI-агент классифицирует содержимое, архитектор утверждает в один клик |

### 8.7.2 Атомарная миграция

Миграция — одна atomic change unit ([V2](03-substrate-versioning.md#3.3.2)) на уровне проекта. Параллельное существование старых типов (UIC / AIC / INT-SR / TS) и SPEC-* как источника истины запрещено.

Процедура (независимо от носителя):

1. Подготовка: AI-агент классифицирует каждый существующий TS-NN в один из 9 типов SPEC.
2. Архитектор утверждает классификацию.
3. Atomic change: переименование IDs (UIC→SPEC-UI; AIC→SPEC-AI; INT-SR→SPEC-INT; TS→SPEC-*), перенос файлов в `specs/<type>/`, обновление всех ссылок в BR / SR / TR / TC frontmatter (`parent: UIC-NN` → `constrained-by: [SPEC-UI-NN]`).
4. Регенерация auto-derived файлов (REQUIREMENTS.md, SPECS.md, обратные рёбра).
5. CI-проверка: отсутствие orphan ссылок и старых IDs.

### 8.7.3 ID immutability

После миграции SPEC ID **неизменяемы** (см. [V1, §3.3.1](03-substrate-versioning.md#3.3.1)). Переименование `SPEC-API-02` → `SPEC-API-08` запрещено. Замена — через `deprecated` + новый ID с `replaces[]`.

---

## 8.8 Контрольные точки качества для SPEC

SPEC имеет выделенную машину состояний ([глава 10 §10.3](10-lifecycle-qg.md)):

| State | Условие перехода |
|---|---|
| `draft` | Создан; обязательные поля frontmatter заполняются |
| `review` | Готов к рецензированию; обязательные body-разделы (§8.4.1) и type-specific (§8.5) присутствуют |
| `approved` | Архитектор подтвердил; `depends-on[]` консистенция проверена |
| `verified` | Все обязательные spec-specific TC ([глава 9 §9.7](09-test-cases.md)) зелёные |
| `obsolete` | Заменён или больше не актуален; `replaced-by` обязателен |

Связь с QG-0 / QG-2 SENAR:

- QG-0 (есть goal/AC у задачи) расширяется: для задач реализующих SPEC обязательны `implements-spec[]` в TR frontmatter.
- QG-2 (есть evidence у `done`) расширяется: для задач реализующих SPEC обязательны TC соответствующего spec-specific вида ([глава 9 §9.7](09-test-cases.md)).

---

## 8.9 Схема хранения

### 8.9.1 На уровне системы

```text
[requirements-substrate]/      # корень носителя требований (layout — guide/03 или guide/04)
  br/
  sr/
  specs/
    arch/   SPEC-ARCH-NN-*.md
    api/    SPEC-API-NN-*.md
    data/   SPEC-DATA-NN-*.md
    ui/     SPEC-UI-NN-*.md
    ai/     SPEC-AI-NN-*.md
    int/    SPEC-INT-NN-*.md
    proc/   SPEC-PROC-NN-*.md
    sec/    SPEC-SEC-NN-*.md
    ops/    SPEC-OPS-NN-*.md
  adapt/
  tz/
  SPECS.md                # auto-generated index
```

> Все 9 типов SPEC ([§8.3](#8.3)) допустимы на любом `level`; подпапки `specs/<type>/` создаются по мере необходимости — не все обязательны на уровне системы.

### 8.9.2 На уровне подсистемы

```text
[subsystem-substrate]/         # scope подсистемы
  br/                     # если своя бизнес-сторона
  sr/
  specs/
    arch/   SPEC-ARCH-NN-*.md      # архитектура подсистемы
    api/    SPEC-API-NN-*.md
    data/   SPEC-DATA-NN-*.md
    ui/     SPEC-UI-NN-*.md
    ai/     SPEC-AI-NN-*.md
    int/    SPEC-INT-NN-*.md
    proc/   SPEC-PROC-NN-*.md
    sec/    SPEC-SEC-NN-*.md
    ops/    SPEC-OPS-NN-*.md
  adapt/
  SPECS.md
```

Нативная для носителя реализация хранения специфична для носителя (см. [guide/03](../guide/03-tool-guide-git.md), [guide/04](../guide/04-document-store-substrate.md)).

### 8.9.3 SPECS.md — auto-generated index

`SPECS.md` — auto-generated реестр всех SPEC: ID, тип, заголовок, статус, ссылка на верифицируемое требование, ссылка на файл. Помечается `linguist-generated=true`. Триггеры перегенерации — каждое изменение SPEC frontmatter или каждый approve / verify gate.

---

## 8.10 Связь с другими главами

| Глава | Связь |
|---|---|
| [02 Позиционирование методологии](02-methodology-positioning.md) | SPEC как параллельная ось — следствие инверсии источника истины |
| [06 Иерархия требований](06-requirements-hierarchy.md) | `SR.constrained-by[]`, `TR.implements-spec[]` |
| [07 ADAPT](07-adapt.md) | SPEC ссылается на ADAPT через `source.adapt` |
| [09 Тест-кейсы](09-test-cases.md) | Spec-specific TC types (таблица обязательных видов TC для каждого типа SPEC) |
| [10 Жизненный цикл и QG](10-lifecycle-qg.md) | SPEC машина состояний + QG расширения для SPEC |
| [03 Версионирование носителя](03-substrate-versioning.md) | SPEC ID неизменяемы (V1); migration атомарно (V2) |
| [11 Модель зрелости](11-maturity-model.md) | RENAR-3+: все 9 типов SPEC где применимо |
| [reference/02 — schemas](../reference/02-schemas.md) | Полная machine-readable schema для каждого type-specific extension |
| [reference/05 — knowledge graph schema](../reference/05-knowledge-graph-schema.md) | `constrained-by[]`, `implements-spec[]`, `depends-on[]` как edge types в графе |

