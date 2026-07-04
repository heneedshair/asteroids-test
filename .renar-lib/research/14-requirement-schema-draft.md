# Requirement Schema (формальная)

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: формальная JSON Schema для требований (BR, SR, UIC, AIC, INT-SR, TS) и тест-кейсов (TC). Закрывает gap из [00-architecture-vision.md §A](00-architecture-vision.md) и [03-maturity-model.md RENAR-3 conformance](03-maturity-model.md).
>
> Финальная нормативная форма — после согласования полей с партнёром и ревью schemas через JSON Schema validator на реальных артефактах.

---

## 1. Не дублирует SENAR

SENAR §3 описывает иерархию (БТ → СТ → ТМ → ТЗ) на уровне терминологии и принципов. SENAR не нормирует **формальную схему данных** для каждого уровня.

REQ specifies формальную JSON Schema. Reference на ISO/IEC/IEEE 29148 §5 (Requirement attributes) — мы берём 8 ключевых атрибутов оттуда (упрощено с 18 из стандарта).

---

## 2. Common fields для всех типов требований

Все артефакты требований (BR, SR, UIC, AIC, INT-SR, TS) делят следующие поля:

```yaml
# === Identity ===
id: "<TYPE>-NN[.N]"                   # immutable, see naming convention
title: "<short, descriptive>"
type: BR | SR | UIC | AIC | INT-SR | TS
slug: "<kebab-case>"                  # auto-derived from title

# === Lifecycle ===
status: draft | review | approved | verified | accepted | obsolete
priority: must | should | could       # MoSCoW; for SAFe — see 08-safe-mapping.md

# === Provenance: source ===
source:
  document: "TZ-YYYY-NNN"             # ID of source TZ
  section: "§N.N"                     # section reference
  line: 142                           # optional, for precise citation
  url: "<link>"                       # optional, link to portal artifact

# === Hierarchy ===
parent:
  id: "<parent-id>"                   # required for SR/UIC/AIC; optional for BR
  file: "<relative-path>"
  repo: "<gitlab-path>"               # if cross-repo
children: []                          # auto-generated

# === Verification ===
verified-by: []                       # auto-derived; list of TC IDs
verifies-business-goal: ""            # optional, link to BR.business-goal-id

# === AI provenance (RENAR-4+ обязательно) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  generation-time-ms: integer
  generated-at: "<ISO-8601>"
  human-edits: boolean

# === AI cost budget (RENAR-5) ===
ai-budget:
  context-tokens-target: integer
  context-tokens-actual: integer
  context-tokens-overrun-percent: number
  output-tokens-target: integer
  output-tokens-actual: integer
  generation-time-target-ms: integer
  generation-time-actual-ms: integer

# === Замена ===
replaces: "<old-id>"                  # if this artifact supersedes another
replaced-by: "<new-id>"               # if this is deprecated/replaced
deprecated-date: "<ISO date>"
```

---

## 3. BR-specific fields

```yaml
# === BR-only ===
business-context:
  stakeholder: "<role>"               # required
  business-goal: "<short statement>"  # required
  kpi-impact:                         # optional but recommended
    - kpi: "<KPI name>"
      direction: increase | decrease
      target: "<measurable>"

business-outcome:                     # required for QG-4 (see 12-solution-evaluation.md)
  measurement-type: kpi | survey | observation | usage
  kpi-name: "<KPI>"
  measurement-method: "<how>"
  baseline-value: number
  baseline-measured-at: "<ISO date>"
  target-value: number
  target-met-by: "<ISO date>"
  current-value:                      # auto-updated post-release
    value: number
    measured-at: "<ISO date>"
    achievement: "<percent>"

prioritization:                       # SAFe / WSJF (see 08-safe-mapping.md)
  framework: WSJF | RICE | MoSCoW
  components: { ... }
  wsjf-score: number
  prioritized-at: "<ISO date>"
  prioritized-by: "<role>"

data-classification:                  # if BR involves user data
  contains-pii: boolean
  contains-financial: boolean
  contains-health: boolean
  contains-children-data: boolean
  retention-days: integer
  data-residency: ["RU", "EU", ...]

compliance:                           # if applicable, see 09-compliance-mapping.md
  - standard: "ISO 27001:2022"
    control: "<id>"
    rationale: "<reason>"
  - standard: "GDPR"
    article: "Art.NN"
  - standard: "ФЗ-152"
    article: "ст.NN"

ai-act:                               # if AI-heavy
  risk-class: prohibited | high | limited | minimal
  rationale: "<reason>"
  high-risk-domain: boolean
```

---

## 4. SR-specific fields

```yaml
# === SR-only ===
parent:                               # required для SR
  id: "BR-NN"

derived-from-uic: "UIC-NN"            # if SR derived from UIC
derived-from-aic: "AIC-NN"            # if SR derived from AIC

quality-characteristic:               # ISO 25010 (see 01-positioning §3.2)
  - functional-suitability
  - performance-efficiency
  - compatibility
  - usability
  - reliability
  - security
  - maintainability
  - portability

# Inherited: data-classification, compliance, ai-act if relevant
```

---

## 5. UIC-specific fields

```yaml
# === UIC-only ===
ux:
  scope: cross-cutting | feature | role-specific
  device-targets: [desktop, mobile, tablet]
  primary-personas: ["<persona>"]
  baseline-mockup: "<path-to-figma-or-png>"
  accessibility:
    wcag-level: A | AA | AAA           # ISO 25010 Usability extension
    screen-reader-tested: boolean
    keyboard-navigable: boolean
```

---

## 6. AIC-specific fields

```yaml
# === AIC-only ===
ai-architecture:
  type: rag | fine-tuning | prompt-engineering | hybrid
  models-considered: ["<model>", ...]
  models-selected: ["<model>"]
  rationale: "<why>"

eval-strategy:
  dataset: "<path-to-jsonl>"
  metrics:
    - name: "<metric>"
      target-threshold: "<value>"
  baseline-run-id: "<id>"

ai-act:
  risk-class: ...                     # required для AIC
  conformity-assessment: "<link>"      # if high-risk
```

---

## 7. INT-SR-specific fields

```yaml
# === INT-SR-only ===
integration:
  direction: synchronous | async | event-driven
  protocol: HTTP | gRPC | SSE | websocket | message-queue
  format: JSON | protobuf | XML

participants:                         # required, ≥ 2
  - id: "<requirement-id>"
    repo: "<path>"
  - id: "<requirement-id>"
    repo: "<path>"

contract-version: "<semver>"
breaking-change-policy: "<rules>"
```

---

## 8. TS-specific fields

```yaml
# === TS-only ===
tech-spec:
  domain: database | api-design | infrastructure | other
  related-sr: ["<SR-id>", ...]
```

---

## 9. TC schema (отдельный)

```yaml
# === Identity ===
id: "TC-NN[.N]"
title: "<descriptive>"
level: TC                             # для distinguishing от requirements
type: system | acceptance | ux | eval | contract

# === Lifecycle ===
status: draft | ready | passing | failing | obsolete

# === Verification mapping ===
verifies:                             # required, ≥1
  - id: "<requirement-id>"
    file: "<relative-path>"
    requirement-version: "<semver>"   # immutable lock to req version

negative: boolean                     # required: pos or neg

# === Test specification ===
prerequisites: ["<condition>", ...]
environment: dev | staging | prod | eval

# === Automation ===
automation:
  status: automated | manual-pending
  location: "<path-to-implementation>"
  runner: pytest | jest | go-test | playwright | vlm-judge | ragas | pact | other
  manual-pending-until: "<ISO date>"  # required if status=manual-pending
  manual-pending-reason: "<why>"      # required if status=manual-pending

# === Last run (bot-only) ===
last-run:
  date: "<ISO timestamp>"
  result: pass | fail | skipped | n/a
  ci-run-url: "<URL>"
  agent-run-id: "<id>"
  requirement-version: "<semver>"     # должна совпадать с verifies[].requirement-version
  judge-report: "<for ux/eval>"

# === UX-specific ===
ux:
  persona: "<role>"
  scenario-ref: "<UIC reference>"
  device: desktop | mobile | tablet
  viewport: "<WxH>"
  mockup-baseline: "<path>"
  vlm-judge:
    model: "<judge-model>"
    pass-criteria: ["<criterion>", ...]
    fail-criteria: ["<criterion>", ...]

# === Eval-specific ===
eval:
  dataset:
    location: "<path>"
    version: "<semver>"
    size: integer
  metrics:
    - name: "<metric>"
      method: "<measurement-method>"
      threshold: "<expression>"
  baseline:
    run-id: "<id>"
    "<metric>": number
  regression-rule: "<expression>"

# === Inherited ===
ai-provenance: { ... }
```

---

## 10. JSON Schema fragment example (BR)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://kibertum.ru/req/schema/br.json",
  "title": "Business Requirement",
  "type": "object",
  "required": ["id", "title", "type", "status", "priority", "source", "ai-provenance"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^BR-[0-9]{2}(\\.[0-9]+)?$"
    },
    "title": {
      "type": "string",
      "minLength": 5,
      "maxLength": 100
    },
    "type": { "const": "BR" },
    "status": {
      "enum": ["draft", "review", "approved", "verified", "accepted", "obsolete"]
    },
    "priority": {
      "enum": ["must", "should", "could"]
    },
    "source": {
      "type": "object",
      "required": ["document", "section"],
      "properties": {
        "document": { "type": "string", "pattern": "^TZ-[0-9]{4}-[0-9]{3}$" },
        "section": { "type": "string" },
        "line": { "type": "integer", "minimum": 1 },
        "url": { "type": "string", "format": "uri" }
      }
    },
    "business-context": {
      "type": "object",
      "required": ["stakeholder", "business-goal"],
      "properties": {
        "stakeholder": { "type": "string" },
        "business-goal": { "type": "string", "minLength": 10 }
      }
    },
    "ai-provenance": {
      "type": "object",
      "required": ["generated-by", "prompt-template", "generated-at"],
      "properties": {
        "generated-by": {
          "type": "string",
          "pattern": "^[a-z]+-[a-z0-9-]+@[0-9]{4}-[0-9]{2}-[0-9]{2}$"
        },
        "human-edits": { "type": "boolean" }
      }
    }
  }
}
```

Аналогичные schemas для SR/UIC/AIC/INT-SR/TS/TC будут в `schemas/` подпапке репозитория стандарта (TODO).

---

## 11. Validation rules (cross-field)

Не выражаемые в чистой JSON Schema, требуют custom validator:

| Правило | Описание |
|---|---|
| ID immutable | При изменении файла `id:` поле не меняется (CI: проверка `git diff` на ID) |
| `parent` exists | Для SR — parent BR должен существовать в репо |
| `verified-by` consistency | TCs в `verified-by` имеют `verifies[].id` совпадающий с этим SR |
| `requirement-version` lock | TC.last-run.requirement-version совпадает с verifies[].requirement-version |
| `derived-from-uic` only for SR | Поле допустимо только в SR |
| AIC requires ai-act | Для AIC поле `ai-act.risk-class` обязательно |
| Data residency consistency | Если SR.data-classification.data-residency includes RU, parent BR то же |
| Compliance hierarchy | SR не может иметь compliance, если parent BR не имеет (или нужно явное extension justification) |
| TC `automated` requires location | `automation.status: automated` → `automation.location` непустое и существующее |
| Negative TC mandatory | На каждое утверждение SR существует TC с `negative: true` |

---

## 12. Schema versioning

JSON Schema сама версионируется:

- `schema-version: 1.0` в frontmatter каждого артефакта.
- Major bump = breaking change для существующих файлов → migration script.
- Minor bump = новое поле, backward compatible.

При несовпадении `schema-version` файла и текущей schema — CI hook предлагает migration.

---

## 13. Migration tooling

```
$ tausik req schema migrate --from 1.0 --to 1.1 --project <slug>

Reading 47 .md files...
Migration steps:
  1. Add ai-budget block (default values from prompt)
  2. Rename `derived-from` → `derived-from-template` for clarity
  3. Add data-classification.data-residency field (default: empty)

Dry-run: would modify 47 files
Applied changes? [y/N]
```

---

## 14. Связь с substrate (изоморфизм)

| JSON Schema field (git) | CouchDB requirement_meta (Raven) |
|---|---|
| `id` | `slug` + `_id = <project>:requirement_meta:<slug>` |
| `type: BR` | `level: "BT"` |
| `parent.id` | `parent` |
| `children` | `children` (auto-derived) |
| `status` | `status` |
| `priority` | `priority` |
| `source.document` | `created_by_order` |
| `verified-by` | `linked_tests` |
| `ai-provenance.*` | (subdocument в Raven) |
| `compliance` | `compliance` (TODO: добавить в Raven) |
| `data-classification` | (TODO: добавить в Raven) |
| `business-outcome` | (TODO: добавить в Raven) |

Migration script `git → Raven` использует эту таблицу как mapping.

---

## 15. Open questions

- [ ] `id` immutability: что если при reorganisation SR-05 концептуально стал SR-12? Запрещаем — заводим SR-12 (новый), помечаем SR-05 deprecated с replaced-by. Согласовать.
- [ ] `compliance` поле — array или single? Решено: array (одно требование может закрывать несколько controls).
- [ ] Free-form fields в frontmatter — разрешать или нет? Можно `extensions: {}` для проектно-специфичных полей.
- [ ] Schema extensions per-project (кастомные поля): через `schema-extensions: <path>` в `.req-config.yaml`?
- [ ] AI-budget overrun percent — кто считает? Validator или генератор? Согласовано: validator (по target из prompt template).
- [ ] TC `verifies[].requirement-version` — какой format semver? Просто major.minor (1.0, 1.1) или полный (1.0.0)? Решено: major.minor (как в frontmatter `version` устаревшем).
- [ ] Локализация: schema `description` поля — multilingual? Сейчас нет.
