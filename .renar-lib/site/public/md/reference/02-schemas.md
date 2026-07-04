---
title: "Схемы (formal)"
description: "Canonical YAML frontmatter schemas for all RENAR artifact types + cross-field validation rules."
order: 2
lang: ru
version: "1.0-draft"
---

# Схемы (формальные)

> **Назначение:** машино-читаемые YAML frontmatter схемы для всех типов артефактов RENAR. Используются нативными для носителя валидаторами для проверки соответствия. **Нормативные определения структуры** — в [`standard/06`](../standard/06-requirements-hierarchy.md), [`standard/07`](../standard/07-adapt.md), [`standard/08`](../standard/08-specifications.md), [`standard/09`](../standard/09-test-cases.md). Валидация примеров: `node scripts/validate-schema-examples.js`. Этот документ — справочник (informative lookup).

---

## 1. Общий frontmatter (все артефакты требований и SPEC)

Поля, общие для BR/SR/TR/SPEC-* (канонические v1.0). Legacy типы `UIC` / `AIC` / `INT-SR` / `TS` deprecated в v1.0 ([standard/04 §4.14.1](../standard/04-terms.md#4.14.1)).

```yaml
# Identity
id: "<TYPE>-NN[.N]"
title: "<short, descriptive>"
type: BR | SR | TR | SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS
slug: "<kebab-case>"

# Scope
level: system | subsystem | module
scope: { system: "<system-id>", subsystem: "<subsystem-id>" }   # subsystem=null если level=system

# Жизненный цикл (verified — BR/SR; frozen — ADAPT §7; ready/passing/failing — TC §8; см. standard/04 §4.6)
status: draft | review | approved | verified | deprecated | obsolete | frozen
priority: must | should | could       # MoSCoW; SAFe — через WSJF (BR-specific)

# Provenance (conditional, standard/07 §7.4.1): ADAPT реактивен.
# Findings present → source.adapt + adapt-section mandatory. No findings → adversarial-review-ref mandatory.
# source.tz-section — обязательно всегда.
source:
  adapt: "ADAPT-NNN"                  # conditional
  adapt-section: "Forward §N.N"       # mandatory если adapt present
  tz-section: "§N.N"                  # обязательно всегда
  adversarial-review-ref: "<ссылка>"  # mandatory когда adapt omitted
  document-ref: "<ссылка>"            # pinned ревизия source-документа

# Hierarchy
parent: { id: "<parent-id>", ref: "<ссылка>" }   # id required для SR (→BR), TR (→SR); optional для BR
children: []                          # auto-derived

# Связь с SPEC (граф)
constrained-by: []                    # SR → SPEC-* (типизированные рёбра)
implements-spec: []                   # TR → SPEC-*
depends-on: []                        # между SPEC

# Verification
verified-by: []                       # auto-derived; TC IDs
verifies-business-goal: ""            # optional

# AI provenance (RENAR-4+ обязательно для approved)
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  generation-time-ms: integer
  generated-at: "<ISO-8601>"
  human-edits: boolean                # true required для approved

# AI cost budget (optional)
ai-budget: { context-tokens-target: integer, context-tokens-actual: integer, output-tokens-target: integer, output-tokens-actual: integer, generation-time-target-ms: integer }

# Замена + schema versioning
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"
schema-version: "1.0"
```

---

## 2. BR — Business Requirement

```yaml
# Extends common §1, дополнительно:

level: system | subsystem             # BR на уровне модуля запрещён (standard/06 §6.4)
scope: { system: "<system-id>", subsystem: "<subsystem-id>" }

# Межуровневая связь BR подсистемы → BR системы (standard/06 §6.8.2)
implements:                            # массив; substrate-agnostic ссылка
  - { id: BR-NN, scope: { system: "<system-id>" }, rationale: "<short>" }   # rationale опционально
implemented-by: []                     # auto-derived (обратное ребро; не пишется автором)

business-context:
  stakeholder: "<role>"
  business-goal: "<short statement>"
  kpi-impact:
    - { kpi: "<name>", direction: increase|decrease, target: "<measurable>" }

# business-outcome — required для QG-4
business-outcome:
  measurement-type: kpi | survey | observation | usage
  kpi-name: "<KPI>"
  measurement-method: "<how>"
  baseline-value: number
  baseline-measured-at: "<ISO date>"
  target-value: number
  target-met-by: "<ISO date>"
  current-value: { value: number, measured-at: "<ISO date>", achievement: "<percent>" }

prioritization: { framework: WSJF|RICE|MoSCoW, wsjf-score: number, prioritized-at: "<ISO date>", prioritized-by: "<role>" }

data-classification:
  contains-pii: boolean
  contains-financial: boolean
  contains-health: boolean
  contains-children-data: boolean
  retention-days: integer
  data-residency: ["RU" | "EU" | "US" | ...]

compliance:
  - { standard: "ISO 27001:2022", control: "<id>", rationale: "..." }
  - { standard: "GDPR", article: "Art.NN" }
  - { standard: "ФЗ-152", article: "ст.NN" }

ai-act: { risk-class: prohibited|high|limited|minimal, rationale: "<reason>", high-risk-domain: boolean }
```

### Поля `implements[]` / `implemented-by[]` — нормативные правила

| Правило | Уровень |
|---|---|
| `implements[]` обязателен при `level: subsystem` И когда родительская система имеет ≥1 approved BR | recommended v1.0; обязательно v1.1+ |
| Target BR обязан быть в статусе `approved` или выше на момент approve данного BR | hook-enforced |
| Cycle detection: цепочка `implements` не должна образовывать циклов | hook-enforced |
| `implements[]` — **не** parent-edge; запрет множественных parents (standard/06 §6.8.3) распространяется на SR/TR, не на BR | normative |
| Deprecate target BR → cascade-warning для всех `implemented-by` (не cascade-deprecate) | hook-enforced |
| Cross-substrate синтаксис: `id + scope.system` не зависит от носителя | normative |
| Cardinality: array (0..N) | normative |

Гейт обеспечения соблюдения — `scripts/check-implements-edge.js`. Поле `implemented-by` — auto-derived; ручная запись запрещена.

---

## 3. SR — System Requirement

```yaml
# Extends common §1, дополнительно:

parent:
  id: "BR-NN"                         # required

# Источник ADAPT — через канонические source.adapt / source.adapt-section (§1).
# Отдельного поля derived-from-adapt нет (standard/06 §6.6.2).

constrained-by:                       # типизированные рёбра к SPEC-*
  - "SPEC-UI-NN"
  - "SPEC-API-NN"
  - "SPEC-DATA-NN"
  - "SPEC-SEC-NN"

quality-characteristic:               # ISO/IEC 25010:2023 (9 характеристик; interaction-capability ← usability, flexibility ← portability в 25010:2011; safety — новая в 25010:2023)
  - functional-suitability | performance-efficiency | compatibility | interaction-capability | reliability | security | maintainability | flexibility | safety

# Inherited from parent BR (если применимо): data-classification, compliance, ai-act
```

---

## 4. TR — Task Requirement

```yaml
# Extends common §1, дополнительно:

parent:
  id: "SR-NN"                         # required

implements-spec: []                   # SPEC-* реализуемые этой задачей
estimated-effort: "<short statement>" # optional, free-form
```

---

## 5. SPEC-* common schema

Все 9 типов SPEC делят общую структуру (§1) + следующие SPEC-specific поля:

```yaml
type: SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS

referenced-by: []                     # auto-derived
depends-on: []                        # SPEC от которых этот зависит
compliance-refs: []                   # ISO / GDPR / ФЗ-152 / AI Act / NIST AI RMF
```

Обязательные разделы body: `## Назначение`, `## Scope`, `## <Type-specific sections — см. §6>`, `## Связь с требованиями`, `## Связь с другими SPEC`, `## Verification`, `## Open questions`.

---

## 6. SPEC type-specific extensions

Type-specific поля для 9 типов SPEC. Industry references — в [`standard/14`](../standard/14-normative-refs.md). Legacy замены: `UIC` → SPEC-UI, `AIC` → SPEC-AI, `INT-SR` → SPEC-INT.

### 6.1 SPEC-ARCH, SPEC-API, SPEC-DATA, SPEC-INT, SPEC-PROC

```yaml
# SPEC-ARCH
arch-style: monolith | microservices | modular-monolith | serverless | hybrid
deployment-model: cloud | on-prem | hybrid | edge
tech-stack: { languages: [], frameworks: [], data-stores: [], message-brokers: [] }
quality-attributes: [{ name: latency, target: "p95 < 200ms" }, { name: availability, target: "99.9%" }]

# SPEC-API
api-style: rest | graphql | grpc | websocket | async-events
api-version: "v1.2.0"
versioning-strategy: url-path | header | query-param | content-negotiation
authentication: bearer-jwt | api-key | oauth2 | mtls | none
rate-limits: [{ endpoint: "*", limit: "1000/min/key" }]
contract-file: { format: openapi-3.1 | asyncapi-2.6 | proto3, location: "contracts/<name>.yaml" }

# SPEC-DATA
data-style: relational | document | graph | columnar | hybrid
storage-engine: postgresql | mysql | couchdb | mongodb | clickhouse | ...
schema-version: "1.4.0"
pii-classification: [{ entity: User, fields: [email, phone], level: PII-high }]
retention-policies: [{ entity: Order, period: "7 years", basis: "tax law" }]
migration-strategy: forward-only | reversible | dual-write

# SPEC-INT
integration-pattern: request-response | event-driven | message-queue | webhook | file-transfer
direction: outbound | inbound | bidirectional
counterparty: { system: "<external-name>", contract-owner: "<team-or-vendor>", contract-ref: "<external-spec-url>" }
sla: { availability: "99.5%", latency-p95: "500ms", fallback: "queue + retry; manual reconciliation after 24h" }
idempotency: guaranteed | best-effort | none

# SPEC-PROC
process-style: bpmn | state-machine | saga | choreography | orchestration
state-count: integer
participants: [{ role: customer, system: client-portal }, { role: agent, system: back-office }]
sla: { end-to-end: "2 business hours" }
compensation: defined | not-applicable | manual
```

### 6.2 SPEC-UI, SPEC-AI, SPEC-SEC, SPEC-OPS

```yaml
# SPEC-UI
ui-platform: web | mobile-ios | mobile-android | desktop | tv | embedded
target-users: [{ role: end-customer, persona: "ADAPT-NNN §X.Y" }]
design-system: "<reference-or-internal>"
accessibility-level: WCAG-A | WCAG-AA | WCAG-AAA
i18n: required | not-required
mockup-links: [{ tool: figma, url: "<link>", version: "v3" }]
baseline-images: ["ai-concepts/baselines/SPEC-UI-NN-screen-01.png"]

# SPEC-AI (judge-model.vendor ≠ production-model.vendor — нормативно)
ai-pattern: rag | fine-tuning | prompt-engineering | tool-use | multi-agent | embedding-only
production-model: { vendor: anthropic|openai|google|local, model: "<name>", version: "<exact>" }
judge-model: { vendor: "<different-vendor>", model: "<different-model>" }
context-strategy: { embedding-model: "<model>", chunk-size: integer, chunk-overlap: integer, vector-store: pinecone|weaviate|pgvector|qdrant }
eval-strategy: { metric: accuracy|f1|rouge|custom-rubric, threshold: number, baseline-dataset: "<path>" }
cost-budget: { tokens-per-request-target: integer, tokens-per-request-ceiling: integer, monthly-budget-usd: number }

# SPEC-SEC
security-domains: [authentication, authorization, data-protection, audit, secrets-management]
auth-model: { authn: jwt-bearer|oauth2-pkce|mtls|passkey, authz: rbac|abac|relbac }
data-classification: [{ class: PII-high, fields: [...] }, { class: PCI, fields: [...] }]
threat-model-method: STRIDE | PASTA | OCTAVE
compliance: [ISO-27001, GDPR, ФЗ-152, PCI-DSS-4]

# SPEC-OPS
deployment-style: kubernetes | vm | serverless | docker-compose | bare-metal
environments:
  - { name: dev, purpose: development, scale: minimal }
  - { name: staging, purpose: integration-testing, scale: half-prod }
  - { name: prod, purpose: production, scale: full }
slo: { availability: "99.9%", error-budget-month: "43m", latency-p95: "300ms" }
observability: { logs: elastic|loki|cloudwatch, metrics: prometheus|datadog|cloudwatch, traces: jaeger|tempo|x-ray }
disaster-recovery: { rto: "<duration>", rpo: "<duration>" }
```

---

## 7. ADAPT schema

ADAPT — отдельный артефакт ([`standard/07`](../standard/07-adapt.md)). Реактивный: существует только при findings от состязательного обзора ТЗ (§7.4.1). Вердикт «no findings» — ADAPT не создаётся, фиксируется через `<artifact>.source.adversarial-review-ref`.

```yaml
# Identity
id: ADAPT-NNN
title: "Адаптация ТЗ <name>"
type: ADAPT
trigger-stage: import-tz | decompose-br | decompose-sr | spec | tc   # стадия-триггер (standard/07 §7.4.1.4)

# Source
source-tz: { id: TZ-YYYY-NNN, signed-date: "<ISO-date>", signed-by-client: "<name-role>", document-ref: "<ссылка>" }
parent-adapt: { id: ADAPT-NNN, delta-tz: TZ-YYYY-NNN }   # для delta-ADAPT

# Supersession (standard/07 §7.6.4) — только для superseding-ADAPT
supersedes: ADAPT-MMM                                    # ссылка на дезавуируемый ADAPT
superseded-by: ADAPT-NNN                                 # auto-derived; на дезавуируемом
supersession-rationale: "<противоречащее BR/SR/SPEC + источник>"   # mandatory если supersedes присутствует

# Lifecycle (подмножество §1: ADAPT не использует verified/deprecated; superseded — терминальное при дезавуировании)
status: draft | review | client-ready | answered | approved | frozen | superseded | obsolete
created: "<ISO-date>"
last-updated: "<ISO-date>"

# Approval (required для approved)
approval:
  client-signature: { signed-by: "<name>", role: "<role>", organization: "<client-org>", signed-at: "<ISO-datetime>", signature-ref: "<ссылка>" }
  architect-signature: { signed-by: "<name>", role: architect, signed-at: "<ISO-datetime>" }

# Auto-derived
generates-requirements: []
generates-specs: []
open-questions-count: integer         # должен быть 0 для approved
resolved-questions-count: integer

# AI provenance
ai-provenance: { generated-by: "<vendor>-<model>@<date>", prompt-template: "<template-path>@<version>", context-tokens: integer, output-tokens: integer, human-edits: boolean }
```

Backward записи внутри body:

```yaml
id: B-NNN
category: contradiction | gap | hidden-assumption | feasibility | regulatory | terminology | scope
status: open | asked-to-client | answered | resolved | frozen
tz-section: "§N.N"
description: "..."
asked-to-client: "<ISO-date>"
client-answer:
  signed-by: "<name>"
  signed-at: "<ISO-datetime>"
  channel: email | docusign | zoom-transcript | written-letter
  text: "..."
resolution: "..."                     # как ответ интегрирован в Forward
```

---

## 8. TC — Test Case

```yaml
# Identity
id: "TC-NN[.N]"
title: "<descriptive>"
type: TC
slug: "<kebab-case>"

# Classification
tc-type: acceptance | ux | system | contract | eval | security
negative: boolean                     # true для парного негативного TC

# Scope
level: system | subsystem | module
scope: { system: "<system-id>", subsystem: "<subsystem-id>", module: "<module-id>" }

# Lifecycle
status: draft | ready | passing | failing | obsolete

# Verification mapping (≥1)
verifies:
  - { id: "<requirement-id>", ref: "<ссылка>", requirement-version: "<version-ref>" }   # V5 pinning (standard/03 §3.3.5)

# Pair link (mandatory если negative=false и существует парный)
paired-with: ["<TC-id>"]

# Automation
automation:
  status: automated | manual-pending
  location: "<path-to-implementation>"      # mandatory если automated
  runner: pytest | jest | go-test | playwright | vlm-judge | ragas | pact | other
  manual-pending-until: "<ISO date>"        # mandatory если manual-pending
  manual-pending-reason: "<why>"

# Execution (mandatory если tc-type=ux | eval; judge.vendor ≠ production model vendor — см. §6.2 SPEC-AI, §9)
judge: { vendor: "<provider>", model: "<model-id>", prompt-template: "<template-path>@<version>" }
baseline: { artifact: "<pointer>", perceptual-diff-threshold: float, metric-thresholds: {} }

# Last run (auto-managed; bot-only)
last-run:
  date: "<ISO timestamp>"
  result: pass | fail | skipped | n/a
  runner-id: "<runner@version>"
  run-ref: "<ссылка>"
  requirement-version: "<version-ref>"
  judge-report: "<for ux/eval>"

# Замена / obsolescence
obsolete-pending: boolean             # true при detected delta-ТЗ инвалидации
replaces: "<old-id>"
replaced-by: "<new-id>"
obsoleted-date: "<ISO date>"

# Inherited
ai-provenance: { ... }                # см. §1
```

---

## 9. Validation rules (cross-field)

Правила, не выражаемые в чистой JSON Schema; требуют custom validator. Колонка «Формальная проверка» даёт исполнимый предикат или ссылку на готовый KG-запрос ([reference/05 §5/§6](05-knowledge-graph-schema.md)).

| Правило | Описание | Формальная проверка |
|---|---|---|
| **ID неизменяем** | При изменении файла поле `id` не меняется. | `diff(prev.id, curr.id) == ∅` |
| **`parent` exists** | Для SR — parent BR существует и в статусе ≥ `approved`. | `status(BR[SR.parent.id]) ≥ approved`; orphans — [05 §6.1](05-knowledge-graph-schema.md#61-orphan-approved-requirements) |
| **`source.adapt` approved** | Для BR/SR/SPEC — ADAPT в `source.adapt` в статусе `approved`/`frozen`. | `status(ADAPT[art.source.adapt]) ∈ {approved, frozen}` |
| **`verified-by` consistency** | TC в `verified-by` имеют `verifies[].id` = этот артефакт. | `∀ tc ∈ art.verified-by: art.id ∈ tc.verifies[].id` |
| **`requirement-version` lock** | `TC.last-run.requirement-version` = `verifies[].requirement-version`. | `tc.last-run.requirement-version == tc.verifies[].requirement-version`; stale — [05 §4.4](05-knowledge-graph-schema.md#44-stale-tc-criteria-version-drift) |
| **`source.adapt` для BR/SR/SPEC (conditional)** | Канонический источник ADAPT при наличии findings; при вердикте «no findings» — `source.adversarial-review-ref` ([standard/07 §7.4.1](../standard/07-adapt.md#7.4.1)). TR — через parent SR ([standard/06 §6.6.2](../standard/06-requirements-hierarchy.md#6.6.2)). | `art.type ∈ {BR, SR, SPEC-*} ⇒ art.source.adapt ≠ null ∨ art.source.adversarial-review-ref ≠ null` |
| **SPEC-AI requires ai-act** | Для AI-артефакта `ai-act.risk-class` обязательно. | `art.type == SPEC-AI ⇒ art.ai-act.risk-class ≠ null` |
| **Data residency consistency** | RU в `SR.data-classification.data-residency` ⇒ то же в parent BR. | `'RU' ∈ SR.…data-residency ⇒ 'RU' ∈ BR[SR.parent].…data-residency` |
| **Compliance hierarchy** | `SR.compliance ⊆ parent BR.compliance` (или явный justification). | `SR.compliance ⊆ BR[parent].compliance ∨ exists(extension-justification)` |
| **TC `automated` requires location** | `automation.status: automated` ⇒ `automation.location` непустое. | `tc.automation.status == 'automated' ⇒ tc.automation.location ≠ ''` |
| **Negative TC обязателен** | На каждое нормативное утверждение — TC с `negative: true`. | `∀ assertion ∈ art: ∃ tc(negative: true)` ([standard/09 §9.7](../standard/09-test-cases.md#9.7)) |
| **ADAPT open-questions == 0 for approved** | Approval блокируется при `open`/`asked-to-client` backward. | `adapt.status == approved ⇒ count(backward[status ∈ {open, asked-to-client}]) == 0` ([05 §4.7](05-knowledge-graph-schema.md#47-adapt-с-open-backward-findings)) |
| **Дезавуирование корректно** | `supersedes` ⇒ непустой `supersession-rationale` и симметричный `superseded-by` на цели; нет висячих `source.adapt` на `superseded` ([standard/07 §7.6.4](../standard/07-adapt.md#7.6), [standard/10 §10.8.5](../standard/10-lifecycle-qg.md#10.8)). | `adapt.supersedes ≠ null ⇒ adapt.supersession-rationale ≠ '' ∧ ADAPT[adapt.supersedes].superseded-by == adapt.id`; `∄ art: art.source.adapt = X ∧ status(ADAPT[X]) == superseded` |
| **Judge isolation (SPEC-AI)** | `judge.vendor` ≠ `production-model.vendor`. | `tc.judge.vendor ≠ SPEC-AI[tc.verifies].production-model.vendor` |
| **SPEC depends-on acyclic** | Граф `depends-on` между SPEC — DAG. | cypher cycle-detection ([05 §4.6](05-knowledge-graph-schema.md#46-spec-dependency-cycle-detection)): rows ≠ ∅ ⇒ нарушение |

---

## 10. Изоморфизм носителя

Отображение для git (YAML frontmatter) ↔ document-oriented store (JSON document):

| Поле (canonical) | git (YAML frontmatter) | Document store (JSON doc) |
|---|---|---|
| `id` | `id` | `_id = <project>:<doc-type>:<slug>`, поле `slug` |
| `type: BR` | `type: BR` | `level: "business"` |
| `type: SPEC-API` | `type: SPEC-API` | `doc_type: "spec_api"` |
| `parent.id` | `parent.id` | `parent` |
| `children` | (auto-derived) | `children` (auto-derived) |
| `status` | `status` | `status` |
| `priority` | `priority` | `priority` |
| `source.adapt` | `source.adapt` | `created_from_adapt` |
| `constrained-by[]` | `constrained-by` | `constrained_by` (subdoc array) |
| `verified-by[]` | (auto-derived) | `linked_tests` |
| `ai-provenance.*` | nested object | nested subdocument |
| `compliance` | `compliance` array | `compliance` subdoc |
| `data-classification` | nested object | nested subdoc |
| `business-outcome` | nested object | nested subdoc |
| `replaces` / `replaced-by` | string ID | `replaces` / `replaced_by` |

Нативные для носителя имена полей могут отличаться, но **семантика и invariants сохраняются** через capabilities V1-V6 ([01-glossary.md §27](01-glossary.md#27-substrate-capabilities-v1-v6)).

---

## 11. Schema versioning

Каждый артефакт имеет поле `schema-version` (semver). При несовпадении версии файла и текущей схемы validator предлагает migration.

| Изменение | Bump |
|---|---|
| Новое необязательное поле | minor (1.0 → 1.1) |
| Новое обязательное поле | major (1.0 → 2.0) + migration script |
| Удаление поля | major + migration script |
| Изменение enum | minor если добавление, major если удаление |
| Переименование поля | major + migration script |

**Текущая версия schemas:** 1.0-draft.

---

## 12. JSON Schema fragment example (BR)

Ключевые patterns (полная BR-схема — `reference/schemas/br.json`, планируется):

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://renar.tech/schemas/br.json",
  "type": "object",
  "required": ["id", "title", "type", "status", "priority", "source", "ai-provenance"],
  "properties": {
    "id":     { "type": "string", "pattern": "^BR-[0-9]{2}(\\.[0-9]+)?$" },
    "title":  { "type": "string", "minLength": 5, "maxLength": 100 },
    "type":   { "const": "BR" },
    "status": { "enum": ["draft", "review", "approved", "verified", "deprecated", "obsolete"] },
    "priority": { "enum": ["must", "should", "could"] },
    "source": { "type": "object", "required": ["tz-section"], "properties": { "adapt": { "pattern": "^ADAPT-[0-9]{3}(-delta-[0-9]+)?$" } } },
    "ai-provenance": { "required": ["generated-by", "generated-at"], "properties": { "generated-by": { "pattern": "^[a-z]+-[a-z0-9-]+@[0-9]{4}-[0-9]{2}-[0-9]{2}$" } } }
  }
}
```

Аналогичные JSON-схемы для SR/TR/SPEC-*/TC/ADAPT — в `reference/schemas/` (планируется).

---

*Schemas reference RENAR 1.0-draft — см. также [01-glossary.md](01-glossary.md), `standard/06`-`09` для нормативных определений.*
