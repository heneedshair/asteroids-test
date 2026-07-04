# Specification Schema и Templates: типизированные SPEC-артефакты

> Версия: черновик 0.1 | Дата: 2026-05-11
> Статус: предложение к обсуждению с партнёром
> Назначение: закрыть размытый класс «технических спецификаций» (текущий `TS` + UIC/AIC/INT-SR) закрытым списком из 9 типизированных SPEC-артефактов с общей схемой, type-specific шаблонами и связью с требованиями через граф ссылок.
>
> Реализует решения **S1–S7** зафиксированные в обсуждении 2026-05-11.

---

## 1. Не дублирует SENAR

SENAR §3 описывает иерархию требований (БТ → СТ → ТМ → ТЗ) на уровне ценностей. SENAR не нормирует:

- Какие виды **спецификаций** существуют рядом с требованиями.
- Как спецификации соотносятся с требованиями (вложены / параллельны).
- Какой минимальный набор полей должен быть в спецификации.
- Какие виды TC верифицируют какой тип SPEC.

RENAR specifies закрытый список из 9 типов SPEC, единую общую схему, type-specific extensions, граф связей и mapping на industry стандарты (arc42, C4, OpenAPI, BPMN, STRIDE, ISO/IEC 11179).

---

## 2. Архитектурное решение: SPEC — параллельная ось, не дети требований

### 2.1 Две оси описания системы

Требования и спецификации отвечают на разные вопросы:

| Ось | Артефакты | Вопрос |
|---|---|---|
| **Поведение** | BR / SR / TR | Что система должна делать |
| **Структура** | SPEC-* (9 типов) | Как система структурно устроена, чтобы это делать |

Один SR-05 «создать заказ» опирается на: SPEC-ARCH (где живёт сервис заказов), SPEC-API (контракт `/orders`), SPEC-DATA (схема таблицы), SPEC-PROC (workflow), SPEC-SEC (кто имеет право), SPEC-UI (как кнопка выглядит). Если делать SPEC ребёнком SR, у одного SR получается 5–6 родителей-спеков — это не дерево, а граф.

### 2.2 Решение: SPEC сиблинг SR, связи через типизированные рёбра

```
Дерево требований (поведенческая ось):     Параллельная ось спецификаций (структурная):

BR (бизнес-цель)                            SPEC-ARCH   — структура системы
 └── SR (поведение системы)                 SPEC-API    — контракты
      └── TR (задача)                       SPEC-DATA   — модель данных
                                            SPEC-INT    — интеграции
                                            SPEC-PROC   — процессы / workflow
                                            SPEC-UI     — UX
                                            SPEC-AI     — AI / ML решения
                                            SPEC-SEC    — безопасность
                                            SPEC-OPS    — эксплуатация

Связи (граф, не дерево):
  SR.parent              → BR        (дерево требований)
  TR.parent              → SR        (дерево требований)
  SR.constrained-by[]    → SPEC-*    (типизированные рёбра)
  TR.implements-spec[]   → SPEC-*    (типизированные рёбра)
  SPEC-*.referenced-by[] → SR / TR   (auto-derived, обратные рёбра)
  SPEC-*.depends-on[]    → SPEC-*    (между спецификациями)
```

### 2.3 Почему это правильно

- **Совместимо с industry**: arc42, C4, OpenAPI, BPMN, ERD — все живут параллельно требованиям, не вложены в них.
- **Одно правило вместо двух**: текущая аномалия (UIC между BR и SR, AIC параллельно SR, INT-SR на уровне системы, TS неопределённо где) исчезает.
- **AI-агент может параллелить генерацию**: SR и SPEC не блокируют друг друга цепочкой, у каждого свой Quality Gate.
- **TC типизируются**: контракт-тесты для SPEC-API, миграционные для SPEC-DATA, threat-test для SPEC-SEC.
- **Мягкая миграция**: UIC→SPEC-UI, AIC→SPEC-AI, INT-SR→SPEC-INT — переименование + перенос в `specs/` подпапки.

---

## 3. Закрытый список из 9 типов SPEC

Закрыт на v1 RENARа. Новые типы добавляются только через PR в стандарт. Open list был бы анти-паттерном (каждая команда придумала бы свои, и кросс-проектная навигация распалась бы).

### 3.1 Таблица типов

| Тип | Имя | Что внутри | Industry reference | Заменяет |
|---|---|---|---|---|
| `SPEC-ARCH` | Architecture | Контексты, контейнеры, компоненты системы/подсистемы; технологические решения, deployment view | arc42, C4 model, ISO/IEC/IEEE 42010 | часть текущего TS |
| `SPEC-API` | API Contract | REST / GraphQL / gRPC контракты, версионирование API, формат ошибок, rate limits | OpenAPI 3.x, AsyncAPI 2.x, gRPC IDL | часть текущего TS |
| `SPEC-DATA` | Data Model | Схема БД, ERD, индексы, миграции, retention, PII классификация | ISO/IEC 11179, JSON Schema | часть текущего TS |
| `SPEC-INT` | Integration | Взаимодействие между подсистемами и внешними системами; протоколы, контракты, SLA | (внутренний) | `INT-SR` |
| `SPEC-PROC` | Process | Бизнес-процессы, state machines, workflows, SLA | BPMN 2.0, ISO/IEC 19510 | часть текущего TS |
| `SPEC-UI` | UI/UX | Экраны, навигация, пользовательские сценарии; ссылки на макеты, baseline images | (внутренний) | `UIC` |
| `SPEC-AI` | AI/ML | Model cards, RAG-архитектура, eval-стратегия, fine-tuning подход, prompts | ISO/IEC 23894, NIST AI RMF | `AIC` |
| `SPEC-SEC` | Security | Auth/authz model, threat model, secrets management, data classification | STRIDE, OWASP ASVS, ISO 27001 | часть текущего TS |
| `SPEC-OPS` | Operations | Deployment, observability, SLO/SLA, runbook, scaling, disaster recovery | SRE practices, ITIL v4 | часть текущего TS |

### 3.2 Что **не вошло** и почему

| Кандидат | Почему отклонён |
|---|---|
| `SPEC-EVENT` | События/очереди — раздел SPEC-API (asynchronous APIs). Отдельный тип избыточен. |
| `SPEC-CONFIG` | Feature flags, env vars, secrets — раздел SPEC-OPS (configuration management). |
| `SPEC-PERF` | Performance/NFR — раздел SPEC-ARCH (quality attributes) или SPEC-OPS (SLO). Не самостоятельный артефакт. |
| `SPEC-TEST-ENV` | Тестовые окружения — раздел SPEC-OPS. |
| `SPEC-DOMAIN` | Domain model — поглощён SPEC-ARCH (domain decomposition) и SPEC-DATA (entities). |
| `SPEC-MIGRATION` | Миграции БД — раздел SPEC-DATA (lifecycle). |
| `SPEC-COMPLIANCE` | Compliance mapping — это связи между SR/SPEC и нормативами; реализуется через граф ссылок (`compliance-refs[]`), не отдельный артефакт. |

Если в дальнейшем работа выявит что какой-то из исключённых типов реально нужен — он добавляется PR в стандарт с обоснованием.

---

## 4. Общая схема (common fields for all SPEC types)

Все 9 типов SPEC делят общий набор полей frontmatter. Type-specific поля добавляются как extensions поверх.

### 4.1 Common frontmatter schema

```yaml
# === Identity ===
id: SPEC-<TYPE>-NN[.N]              # immutable; TYPE из {ARCH,API,DATA,INT,PROC,UI,AI,SEC,OPS}
title: "<short, descriptive>"
type: SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS
slug: "<kebab-case>"                # auto-derived from title

# === Scope ===
level: system | subsystem | module  # на каком уровне иерархии живёт
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"       # null если level=system

# === Lifecycle ===
status: draft | review | approved | obsolete
priority: must | should | could     # not all SPEC types use priority; mostly for SPEC-SEC, SPEC-OPS

# === Source (provenance from requirements) ===
source:
  adapt: "ADAPT-NNN"                # link to ADAPT document section (см. draft 18)
  tz-section: "§N.N"                # original TZ section, optional
  external-doc: "<url>"             # optional, link to external doc (e.g., partner spec)

# === Связь с требованиями (граф) ===
referenced-by: []                   # auto-derived; SR/TR/SPEC которые ссылаются на этот SPEC
depends-on: []                      # этот SPEC опирается на другие SPEC (e.g., SPEC-API depends-on SPEC-DATA)

# === Verification ===
verified-by: []                     # auto-derived; список TC IDs верифицирующих этот SPEC
verifies-business-goal: ""          # optional, link to BR.business-goal-id

# === AI provenance (RENAR-4+ обязательно) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  generation-time-ms: integer
  generated-at: "<ISO-8601>"
  human-edits: boolean

# === Замена ===
replaces: "<old-id>"                # if this artifact supersedes another
replaced-by: "<new-id>"             # if this is deprecated/replaced
deprecated-date: "<ISO date>"

# === Compliance refs (optional) ===
compliance-refs: []                 # ISO/GDPR/ФЗ-152/AI Act/NIST AI RMF — связи с compliance документами
```

### 4.2 Общие тела разделов (markdown body)

Любой SPEC имеет минимум следующие разделы:

```markdown
## Назначение
<1-3 параграфа: что описывает эта спецификация и зачем>

## Scope
<что входит, что не входит>

## <Type-specific sections — см. раздел 5>

## Связь с требованиями
<какие SR/BR ссылаются через constrained-by[]; как этот SPEC ограничивает поведение>

## Связь с другими SPEC
<depends-on[] — какие другие SPEC должны быть стабильны для этого>

## Verification
<какие TC верифицируют этот SPEC, как они структурированы>

## Open questions
<нерешённые вопросы, требующие согласования>
```

### 4.3 Связь с SR через `constrained-by[]`

SR во frontmatter получает новое поле:

```yaml
parent:
  id: BR-01                          # единственный родитель в дереве требований
constrained-by:
  - SPEC-UI-01                       # типизированные ссылки на спеки (граф)
  - SPEC-API-02
  - SPEC-DATA-03
  - SPEC-SEC-01
```

Связь «SR-05 произведён от SPEC-UI-01» теперь не ребро дерева, а **типизированное ребро графа**. Дерево родителей у SR остаётся одно: BR. Это решает аномалию текущего UIC между BR и SR.

---

## 5. Type-specific extensions

Каждый тип SPEC расширяет общую схему специфичными полями и обязательными разделами.

### 5.1 SPEC-ARCH — Architecture

**Frontmatter extension**:

```yaml
arch-style: monolith | microservices | modular-monolith | serverless | hybrid
deployment-model: cloud | on-prem | hybrid | edge
tech-stack:
  languages: []
  frameworks: []
  data-stores: []
  message-brokers: []
quality-attributes:
  - { name: latency, target: "p95 < 200ms" }
  - { name: availability, target: "99.9%" }
  - { name: throughput, target: "10k req/s peak" }
```

**Обязательные разделы body**:

- Системный контекст (C4 Level 1): внешние акторы и системы, границы.
- Контейнеры (C4 Level 2): процессы, базы, очереди; технологии.
- Компоненты (C4 Level 3): для критических контейнеров.
- Quality attributes: latency, throughput, availability, scalability, security overview.
- ADR-журнал: ключевые архитектурные решения с trade-off анализом.

**Industry reference**: arc42 (12-section template), C4 model (Brown), ISO/IEC/IEEE 42010.

**Spec-specific TC**:
- Architecture conformance test (zoning rules — какие компоненты могут вызывать какие).
- Quality attribute tests (latency baseline, throughput baseline).

---

### 5.2 SPEC-API — API Contract

**Frontmatter extension**:

```yaml
api-style: rest | graphql | grpc | websocket | async-events
api-version: "v1.2.0"                # semver
versioning-strategy: url-path | header | query-param | content-negotiation
authentication: bearer-jwt | api-key | oauth2 | mtls | none
rate-limits:
  - { endpoint: "*", limit: "1000/min/key" }
contract-file:                       # ссылка на машино-читаемый contract
  format: openapi-3.1 | asyncapi-2.6 | proto3
  location: "contracts/orders-api.yaml"
```

**Обязательные разделы body**:

- Endpoints (или операции для async): метод, путь, payload, response, errors.
- Версионирование: правила breaking vs non-breaking changes, deprecation policy.
- Error model: единая структура ошибок, коды.
- Authentication & authorization: ссылка на SPEC-SEC.
- Rate limits & quotas.
- Examples: 2-3 типовых запроса+ответа на каждый endpoint.

**Industry reference**: OpenAPI 3.1, AsyncAPI 2.6, gRPC IDL, JSON:API.

**Spec-specific TC**:
- Contract tests (Schemathesis / Pact / Dredd).
- Authentication negative tests.
- Rate limit tests.

---

### 5.3 SPEC-DATA — Data Model

**Frontmatter extension**:

```yaml
data-style: relational | document | graph | columnar | hybrid
storage-engine: postgresql | mysql | couchdb | mongodb | clickhouse | cassandra | ...
schema-version: "1.4.0"
pii-classification:
  - { entity: User, fields: [email, phone], level: PII-high }
  - { entity: Order, fields: [address], level: PII-medium }
retention-policies:
  - { entity: Order, period: "7 years", basis: "tax law" }
migration-strategy: forward-only | reversible | dual-write
```

**Обязательные разделы body**:

- Domain entities: список сущностей с описанием.
- ERD (ASCII или ссылка на dbdiagram.io / Mermaid block).
- Поля сущностей: тип, ограничения, индексы, default values.
- Связи: FK, cardinality, cascade rules.
- PII / sensitive data: классификация, шифрование at-rest, retention.
- Migration approach: zero-downtime / maintenance window, rollback.
- Index strategy: какие индексы для каких запросов.

**Industry reference**: ISO/IEC 11179, JSON Schema, ERD notation (Crow's Foot или UML).

**Spec-specific TC**:
- Migration tests (apply migration, verify schema).
- Constraint tests (FK violations, NOT NULL, unique).
- PII handling tests (encryption at rest verification).
- Data retention tests.

---

### 5.4 SPEC-INT — Integration

**Frontmatter extension**:

```yaml
integration-pattern: request-response | event-driven | message-queue | webhook | file-transfer
direction: outbound | inbound | bidirectional
counterparty:
  system: "<external-system-name>"
  contract-owner: "<team-or-vendor>"
  contract-ref: "<external-spec-url>"
sla:
  availability: "99.5%"
  latency-p95: "500ms"
  fallback: "queue + retry; manual reconciliation after 24h"
idempotency: guaranteed | best-effort | none
```

**Обязательные разделы body**:

- Интегрируемые системы: внутренние подсистемы и/или внешние сервисы.
- Контракт обмена: payload, error codes, response time.
- Failure modes: что делаем при недоступности counterparty, retry strategy.
- Идемпотентность и dedup.
- Security: auth между системами, encryption-in-transit.
- Observability: traceability across boundary (correlation IDs).

**Industry reference**: Enterprise Integration Patterns (Hohpe), ISO/IEC 19944 (cloud interop).

**Spec-specific TC**:
- Contract tests с моком counterparty.
- Failure injection tests (counterparty timeout, malformed response).
- Idempotency tests.
- INT-TC: end-to-end test с реальным или sandbox counterparty.

**Замечание**: SPEC-INT — заменяет существующий `INT-SR`. Семантически это **спецификация**, не «требование»: контракт интеграции описывает как стороны взаимодействуют, не что бизнес-стейкхолдер хочет от системы.

---

### 5.5 SPEC-PROC — Process / Workflow

**Frontmatter extension**:

```yaml
process-style: bpmn | state-machine | saga | choreography | orchestration
state-count: integer                # for state machines
participants:
  - { role: customer, system: client-portal }
  - { role: agent, system: back-office }
  - { role: system, system: order-processor }
sla:
  end-to-end: "2 business hours"
  manual-review-step: "4 business hours"
compensation: defined | not-applicable | manual
```

**Обязательные разделы body**:

- Процесс diagram (BPMN-flavor ASCII / Mermaid / ссылка).
- Состояния и переходы (для state machine).
- Participants и их роли.
- Happy path сценарий.
- Альтернативные сценарии и исключения.
- Timeouts и compensation logic (для saga).
- SLA для процесса в целом и для каждого шага.

**Industry reference**: BPMN 2.0 (OMG), ISO/IEC 19510, Saga pattern (Garcia-Molina).

**Spec-specific TC**:
- Happy path E2E test.
- Alternative path tests (cancellation, timeout, manual review).
- Compensation tests (для saga).
- SLA tests (process completes within target).

---

### 5.6 SPEC-UI — UI / UX

**Frontmatter extension**:

```yaml
ui-platform: web | mobile-ios | mobile-android | desktop | tv | embedded
target-users:
  - { role: end-customer, persona: "ADAPT-NNN §X.Y" }
  - { role: support-agent, persona: "ADAPT-NNN §X.Z" }
design-system: "<reference-or-internal>"
accessibility-level: WCAG-A | WCAG-AA | WCAG-AAA
i18n: required | not-required
mockup-links:
  - { tool: figma, url: "<link>", version: "v3" }
baseline-images:                    # для VLM-judge UX тестов
  - "ai-concepts/baselines/SPEC-UI-NN-screen-01.png"
```

**Обязательные разделы body**:

- Общая структура интерфейса: навигация, layout.
- Ключевые экраны: что пользователь видит, что может сделать.
- Пользовательские сценарии: основные flows без технических деталей.
- Сквозные элементы: права доступа по ролям, уведомления, error states, empty states.
- Тон и стиль: плотность информации, mobile-first / desktop-first.
- Accessibility: keyboard nav, screen reader, contrast.
- I18n: какие языки, RTL поддержка.

**Industry reference**: Material Design / Apple HIG / собственный design system. WCAG 2.2.

**Spec-specific TC**:
- UX VLM-judge tests с baseline images (isolation: production-model ≠ judge-model).
- Accessibility tests (axe-core / Pa11y).
- I18n tests (string overflow, RTL layout).
- User journey E2E tests (Playwright/Cypress).

**Замечание**: SPEC-UI заменяет существующий `UIC`. Существенно: новые baselines идут в `ai-concepts/baselines/` (см. [00-architecture-vision.md §6](00-architecture-vision.md#L347-L355)), обновляются через `[baseline-update]` теги.

---

### 5.7 SPEC-AI — AI / ML

**Frontmatter extension**:

```yaml
ai-pattern: rag | fine-tuning | prompt-engineering | tool-use | multi-agent | embedding-only
production-model:
  vendor: anthropic | openai | google | local
  model: claude-opus-4-7 | gpt-4o | gemini-pro | llama-3.1-70b
  version: "<exact-version>"
judge-model:                        # для eval; ОБЯЗАН отличаться от production
  vendor: <different-vendor>
  model: <different-model>
context-strategy:
  embedding-model: text-embedding-3-large
  chunk-size: 512
  chunk-overlap: 64
  vector-store: pinecone | weaviate | pgvector | qdrant
eval-strategy:
  metric: accuracy | f1 | rouge | custom-rubric
  threshold: 0.85
  baseline-dataset: "ai-concepts/eval-datasets/spec-ai-NN-v1.jsonl"
cost-budget:
  tokens-per-request-target: 8000
  tokens-per-request-ceiling: 15000
  monthly-budget-usd: 500
```

**Обязательные разделы body**:

- Архитектура AI-компонент: pipeline, оркестрация, fallback.
- Model card: capabilities, limits, known failure modes.
- Context strategy: что подаётся в prompt, как chunking, как retrieval.
- Eval strategy: датасет, метрики, threshold, изоляция judge.
- Cost management: бюджет, мониторинг.
- Hallucination mitigation: citations, abstention, retry.
- Adversarial considerations: prompt injection, jailbreak attempts.

**Industry reference**: ISO/IEC 23894 (AI risk management), NIST AI RMF, Anthropic Model Cards, Google Model Cards framework.

**Spec-specific TC**:
- Eval tests против baseline dataset (с изоляцией judge).
- Adversarial tests: prompt injection attempts (как negative TC).
- Cost regression tests: токены на типовом запросе.
- Hallucination tests: запросы без context → должны abstaining, не fabricating.

**Замечание**: SPEC-AI заменяет существующий `AIC`. Изоляция judge ≠ production — обязательно по [00-architecture-vision.md §7.8](00-architecture-vision.md#L484-L495).

---

### 5.8 SPEC-SEC — Security

**Frontmatter extension**:

```yaml
security-domains:
  - authentication
  - authorization
  - data-protection
  - audit
  - secrets-management
auth-model:
  authn: jwt-bearer | oauth2-pkce | mtls | passkey
  authz: rbac | abac | relbac
data-classification:
  - { class: PII-high, fields: [email, phone, address] }
  - { class: PCI, fields: [card-number] }
  - { class: internal, fields: [...] }
threat-model-method: STRIDE | PASTA | OCTAVE
compliance:
  - ISO-27001
  - GDPR
  - ФЗ-152
  - PCI-DSS-4
incident-response: "ссылка на runbook in SPEC-OPS"
```

**Обязательные разделы body**:

- Auth model: authn flow, authz правила.
- Data classification: что считается чувствительным, как защищено.
- Threat model: STRIDE-таблица с mitigation для каждой угрозы.
- Secrets management: где хранятся, как ротируются, кто имеет доступ.
- Audit: какие действия логируются, retention, доступ к логам.
- Encryption: at-rest, in-transit, key management.
- Compliance mapping: ссылки на конкретные пункты ISO/GDPR/ФЗ-152.

**Industry reference**: STRIDE (Microsoft), OWASP ASVS 4.0, ISO/IEC 27001, NIST 800-53.

**Spec-specific TC**:
- Authentication tests (positive + negative).
- Authorization tests (RBAC matrix coverage).
- Threat-test TC: каждая STRIDE-угроза → минимум 1 negative TC.
- Audit log tests (что логи пишутся, что неавторизованные не имеют доступа).
- Secrets leakage tests (статический анализ + runtime).

---

### 5.9 SPEC-OPS — Operations

**Frontmatter extension**:

```yaml
deployment-style: kubernetes | vm | serverless | docker-compose | bare-metal
environments:
  - { name: dev, purpose: development, scale: minimal }
  - { name: staging, purpose: integration-testing, scale: half-prod }
  - { name: prod, purpose: production, scale: full }
slo:
  availability: "99.9%"
  error-budget-month: "43m"
  latency-p95: "300ms"
observability:
  logs: elastic | loki | cloudwatch
  metrics: prometheus | datadog | cloudwatch
  traces: jaeger | tempo | x-ray
  alerting: pagerduty | opsgenie | grafana-alerting
runbook-link: "<location>"
disaster-recovery:
  rto: "4 hours"
  rpo: "1 hour"
  backup-strategy: "<description>"
```

**Обязательные разделы body**:

- Environments: dev / staging / prod, их назначение и масштаб.
- Deployment process: CI/CD pipeline, gating, rollout strategy.
- SLO: availability, latency, error budget.
- Observability: что логируется/измеряется/трейсится, dashboards.
- Alerting: критические алерты, escalation policy.
- Runbook: how-to для типовых инцидентов.
- Capacity planning: scaling rules, headroom.
- Disaster recovery: RTO/RPO, backup, restore procedure.

**Industry reference**: Google SRE Book / Workbook, ITIL v4, ISO/IEC 20000.

**Spec-specific TC**:
- Deployment tests (smoke after deploy).
- SLO regression tests (load testing, latency budget).
- Failover tests (DR drills).
- Observability tests (alerts fire когда ожидается).

---

## 6. Storage layout

### 6.1 На уровне системы

```
[system].req/
  br/
  sr/
  specs/
    arch/   SPEC-ARCH-NN-*.md            # архитектура системы
    int/    SPEC-INT-NN-*.md             # cross-subsystem интеграции
    proc/   SPEC-PROC-NN-*.md            # бизнес-процессы через подсистемы
    sec/    SPEC-SEC-NN-*.md             # политика безопасности системы
    ops/    SPEC-OPS-NN-*.md             # эксплуатация системы
  ai-concepts/
    baselines/                            # для SPEC-UI и SPEC-AI
    eval-datasets/                        # для SPEC-AI
  tests/
    TC-NN-*.md
    INT-TC-NN-*.md
  adapt/                                  # см. draft 18
    ADAPT-NNN-*.md
  tz/
    TZ-YYYY-NNN-*.md
  REQUIREMENTS.md                         # auto-generated, [coverage]
  SPECS.md                                # auto-generated, [coverage] — индекс всех SPEC
  TEST-PLAN.md                            # auto-generated, [coverage]
  COVERAGE.md                             # auto-generated, [coverage]
```

### 6.2 На уровне подсистемы

```
[subsystem].req/
  br/                                     # если у подсистемы свой стейкхолдер
  sr/
  specs/
    arch/   SPEC-ARCH-NN-*.md             # архитектура подсистемы
    api/    SPEC-API-NN-*.md              # API подсистемы
    data/   SPEC-DATA-NN-*.md             # data model подсистемы
    ui/     SPEC-UI-NN-*.md               # UI/UX подсистемы
    ai/     SPEC-AI-NN-*.md               # AI/ML внутри подсистемы
    int/    SPEC-INT-NN-*.md              # интеграции этой подсистемы
    proc/   SPEC-PROC-NN-*.md             # процессы внутри подсистемы
    sec/    SPEC-SEC-NN-*.md              # security specifics подсистемы
    ops/    SPEC-OPS-NN-*.md              # эксплуатация подсистемы
  tests/
  adapt/
  REQUIREMENTS.md
  SPECS.md
  TEST-PLAN.md
  COVERAGE.md
```

### 6.3 Auto-generated сводный файл `SPECS.md`

Аналогично `REQUIREMENTS.md`. Реестр всех SPEC в репозитории: ID, тип, заголовок, статус, ссылка на верифицируемое требование, ссылка на файл. Помечается `linguist-generated=true`. Триггеры перегенерации совпадают с `REQUIREMENTS.md`.

---

## 7. Связь с TC: типизированная таблица

Дополнение к `testing-methodology.md`: таблица «тип SPEC → обязательные виды TC».

| Тип SPEC | Обязательные виды TC | Дополнительные виды TC |
|---|---|---|
| SPEC-ARCH | Conformance (zoning rules) | Quality attribute baselines |
| SPEC-API | Contract tests | Auth negative, rate limit |
| SPEC-DATA | Constraint, migration | PII handling, retention |
| SPEC-INT | Contract (mocked counterparty), INT-TC (real/sandbox) | Failure injection, idempotency |
| SPEC-PROC | Happy path E2E, alternative paths | Compensation, SLA |
| SPEC-UI | VLM-judge с baseline (judge ≠ prod) | Accessibility, i18n, journey E2E |
| SPEC-AI | Eval против baseline dataset (judge isolated) | Adversarial, cost regression, hallucination |
| SPEC-SEC | RBAC matrix, threat-test per STRIDE | Audit log, secrets leakage |
| SPEC-OPS | Smoke after deploy | SLO regression, failover, alerting |

Это таблица **обязательного покрытия**: при promote SPEC в `verified` хук проверяет наличие минимум по одному TC каждого обязательного вида.

---

## 8. Связь с требованиями: примеры

### 8.1 SR ссылается на SPEC

```yaml
---
id: SR-05
title: "Создать заказ"
type: SR
level: subsystem
scope: { system: shop, subsystem: orders }
status: approved
parent:
  id: BR-02
constrained-by:
  - SPEC-UI-01           # как выглядит форма
  - SPEC-API-02          # endpoint POST /orders
  - SPEC-DATA-03         # таблица orders + связи
  - SPEC-PROC-01         # workflow заказа
  - SPEC-SEC-01          # кто имеет право создавать
verified-by:
  - TC-12
  - TC-13
source:
  adapt: "ADAPT-001 §3.4"
---
```

### 8.2 TR ссылается на SPEC

```yaml
---
id: TR-42
title: "Реализовать endpoint POST /orders"
type: TR
parent:
  id: SR-05
implements-spec:
  - SPEC-API-02          # реализуется контракт
  - SPEC-DATA-03         # пишется в БД по этой схеме
verified-by:
  - TC-14
---
```

### 8.3 SPEC depends-on другой SPEC

```yaml
---
id: SPEC-API-02
title: "REST API заказов"
type: SPEC-API
depends-on:
  - SPEC-DATA-03         # схема данных должна быть стабильна для контракта
  - SPEC-SEC-01          # auth model для endpoints
---
```

### 8.4 Auto-derived обратные рёбра

После любого изменения SR/TR/SPEC агент пересчитывает `referenced-by[]` в каждом SPEC. CI-проверка: orphan SPEC (без `referenced-by`) → warning (возможно мёртвый артефакт).

---

## 9. Quality Gates для SPEC

SPEC имеет свой life cycle, отличный от SR. Состояния:

| Состояние | Условие перехода |
|---|---|
| `draft` | Создан, поля заполняются |
| `review` | Готов к ревью; QG-review хук валидирует обязательные разделы + frontmatter |
| `approved` | Архитектор подтвердил; QG-approve хук валидирует depends-on консистентность |
| `verified` | Все обязательные TC (по таблице §7) зелёные; QG-verify хук проверяет TC coverage |
| `obsolete` | Заменён или больше не актуален; `replaced-by` обязателен если `obsolete` |

Связь с QG-0..QG-4 SENAR:
- QG-0 (есть goal/AC у задачи): требует не SR, а SR + impacted SPEC в `implements-spec[]` задачи.
- QG-2 (есть evidence) расширяется: для задач реализующих SPEC обязательны TC соответствующего типа.

---

## 10. Миграционный план: UIC / AIC / INT-SR → SPEC-*

### 10.1 Что меняется

| Старое | Новое | Тип переноса |
|---|---|---|
| `UIC-NN.md` | `SPEC-UI-NN.md` в `specs/ui/` | Переименование + перенос |
| `AIC-NN.md` | `SPEC-AI-NN.md` в `specs/ai/` | Переименование + перенос |
| `INT-SR-NN.md` | `SPEC-INT-NN.md` в `specs/int/` | Переименование + перенос |
| `TS-NN.md` | Распределение по `SPEC-ARCH/API/DATA/PROC/SEC/OPS` | Manual review каждого TS |

### 10.2 Скрипт миграции

```
1. Сканировать .req/ui-concepts/ → переименовать в specs/ui/ + ID UIC → SPEC-UI
2. Сканировать .req/(*)/aic/ → переименовать в specs/ai/ + ID AIC → SPEC-AI
3. Сканировать .req/int-sr/ → переименовать в specs/int/ + ID INT-SR → SPEC-INT
4. Для каждого TS-NN.md: AI-агент классифицирует body, предлагает SPEC-<TYPE>
   с обоснованием; архитектор approve через one-click; renaming.
5. Обновить все ссылки в BR/SR/TR/TC frontmatter:
   - parent: UIC-NN → constrained-by: [SPEC-UI-NN]
   - parent: AIC-NN → constrained-by: [SPEC-AI-NN]
   - parent: INT-SR-NN → constrained-by: [SPEC-INT-NN]
6. Регенерировать REQUIREMENTS.md и SPECS.md.
7. CI: проверка отсутствия orphan ссылок.
```

Миграция — одна atomic change unit в substrate (один commit / один changeset / одна Raven transaction). Не «постепенно».

### 10.3 Pilot на `notification_catcher.req`

Существующие 18 SR / 6 UIC / ... в `notification_catcher.req` мигрируются скриптом. Это **первая** реальная проверка скрипта. По итогам — fix скрипта + регрессионные тесты.

---

## 11. Open questions

1. **SPEC версионирование**: SPEC-API-02 эволюционирует (v1.0 → v1.1 → v2.0). Это (а) один файл с обновлением `version` поля, или (б) новые файлы `SPEC-API-02-v2.md` с `replaces`? Trade-off: continuity vs explicit history.
2. **Sub-types внутри типа**: например SPEC-API-REST vs SPEC-API-GRAPHQL. Делаем как поле `api-style`, или как sub-type в ID? Сейчас предложено как поле — но если поведение TC сильно различается, может стоить выделить.
3. **Multi-tenancy specs**: SPEC-DATA для multi-tenant SaaS — отдельный тип `SPEC-MULTITENANT` или подраздел SPEC-DATA + SPEC-SEC? Текущее решение — подраздел; нужно подтвердить на pilot.
4. **Cross-SPEC консистентность**: если SPEC-API-02 ссылается на сущности SPEC-DATA-03 — нужны ли formal consistency checks (например, payload field имеется в schema)? Возможно через JSON Schema cross-validation.
5. **Templates как `library/templates/` или вшиты в стандарт**: type-specific шаблоны — отдельные `.md` файлы (можно копировать) или встроены в `developer-guide`? Сейчас предложено как library/templates.
6. **Compliance refs как граф или поле**: `compliance-refs[]` сейчас плоский список. Возможно стоит сделать typed: `gdpr-refs[]`, `iso-27001-refs[]`. Trade-off: гибкость vs typing.

---

## 12. Закрытость и эволюция

- **9 типов SPEC** — закрыто на v1. Новые добавляются PR в стандарт с обоснованием.
- **Common schema** — закрыта на v1. Дополнения через minor version bump.
- **Type-specific extensions** — открыты для эволюции внутри типа.
- **Storage layout** — substrate-agnostic; конкретное расположение папок — substrate-specific (в Raven — doc-types, в git — папки).

---

## 13. Что меняется в существующих документах RENARа

| Документ | Изменение |
|---|---|
| `requirements-storage-standard.md` §3.3 | Таблица типов: убрать UIC/AIC/INT-SR/TS, добавить SPEC-* через ссылку на этот документ |
| `requirements-storage-standard.md` §4 | Раздел UI Concept — переименовать «SPEC-UI», обновить формат |
| `requirements-storage-standard.md` §6 | Forматы файлов — обновить с UIC/AIC на SPEC-* |
| `testing-methodology.md` | Добавить раздел про SPEC-specific TC + таблицу из §7 |
| `developer-guide-requirements.md` | Workflow «как создать SPEC» вместо «как создать UIC/AIC/TS» |
| `14-requirement-schema-draft.md` | Добавить SPEC-* типы; убрать UIC/AIC/INT-SR/TS из enum |
| `16-req-graph-schema-draft.md` | Добавить SPEC-* node types, `constrained-by` edge type |
| `00-architecture-vision.md` §5.3 | Замечание про test_case doc-type в Raven — добавить spec doc-type |

---

> **Статус документа**: после согласования с партнёром — содержание извлекается в (а) новый раздел `specifications-standard.md` или (б) §3a в `requirements-storage-standard.md`. Этот файл остаётся в `research/` как обоснование с industry mappings.
