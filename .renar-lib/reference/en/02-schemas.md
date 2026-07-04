---
title: "Schemas (formal)"
description: "Canonical YAML frontmatter schemas for all RENAR artifact types + cross-field validation rules."
order: 2
lang: en
version: "1.0-draft"
---

# Schemas (formal)

> **Purpose:** machine-readable YAML frontmatter schemas for all RENAR artifact types. Used by substrate-native validators to check conformance. **Normative structure definitions** live in [`standard/06`](../../standard/en/06-requirements-hierarchy.md), [`standard/07`](../../standard/en/07-adapt.md), [`standard/08`](../../standard/en/08-specifications.md), [`standard/09`](../../standard/en/09-test-cases.md). Example validation: `node scripts/validate-schema-examples.js`. This document is a reference (informative lookup).

---

## 1. Common frontmatter (all requirement and SPEC artifacts)

Fields common to BR/SR/TR/SPEC-* (canonical v1.0). Legacy types `UIC` / `AIC` / `INT-SR` / `TS` are deprecated in v1.0 ([standard/04 §4.14.1](../../standard/en/04-terms.md#4.14.1)).

```yaml
# Identity
id: "<TYPE>-NN[.N]"
title: "<short, descriptive>"
type: BR | SR | TR | SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS
slug: "<kebab-case>"

# Scope
level: system | subsystem | module
scope: { system: "<system-id>", subsystem: "<subsystem-id>" }   # subsystem=null if level=system

# Lifecycle (verified — BR/SR; frozen — ADAPT §7; ready/passing/failing — TC §8; see standard/04 §4.6)
status: draft | review | approved | verified | deprecated | obsolete | frozen
priority: must | should | could       # MoSCoW; SAFe — via WSJF (BR-specific)

# Provenance (conditional, standard/07 §7.4.1): ADAPT is reactive.
# Findings present → source.adapt + adapt-section mandatory. No findings → adversarial-review-ref mandatory.
# source.tz-section — always mandatory.
source:
  adapt: "ADAPT-NNN"                  # conditional
  adapt-section: "Forward §N.N"       # mandatory if adapt present
  tz-section: "§N.N"                  # always mandatory
  adversarial-review-ref: "<link>"    # mandatory when adapt omitted
  document-ref: "<link>"              # pinned revision of source document

# Hierarchy
parent: { id: "<parent-id>", ref: "<link>" }   # id required for SR (→BR), TR (→SR); optional for BR
children: []                          # auto-derived

# Link to SPEC (graph)
constrained-by: []                    # SR → SPEC-* (typed edges)
implements-spec: []                   # TR → SPEC-*
depends-on: []                        # between SPEC

# Verification
verified-by: []                       # auto-derived; TC IDs
verifies-business-goal: ""            # optional

# AI provenance (RENAR-4+ mandatory for approved)
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  generation-time-ms: integer
  generated-at: "<ISO-8601>"
  human-edits: boolean                # true required for approved

# AI cost budget (optional)
ai-budget: { context-tokens-target: integer, context-tokens-actual: integer, output-tokens-target: integer, output-tokens-actual: integer, generation-time-target-ms: integer }

# Replacement + schema versioning
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO date>"
schema-version: "1.0"
```

---

## 2. BR — Business Requirement

```yaml
# Extends common §1, additionally:

level: system | subsystem             # BR at module level is prohibited (standard/06 §6.4)
scope: { system: "<system-id>", subsystem: "<subsystem-id>" }

# Cross-level link: subsystem BR → system BR (standard/06 §6.8.2)
implements:                            # array; substrate-agnostic reference
  - { id: BR-NN, scope: { system: "<system-id>" }, rationale: "<short>" }   # rationale optional
implemented-by: []                     # auto-derived (reverse edge; not written by the author)

business-context:
  stakeholder: "<role>"
  business-goal: "<short statement>"
  kpi-impact:
    - { kpi: "<name>", direction: increase|decrease, target: "<measurable>" }

# business-outcome — required for QG-4
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

### Fields `implements[]` / `implemented-by[]` — normative rules

| Rule | Level |
|---|---|
| `implements[]` required when `level: subsystem` AND the parent system has ≥1 approved BR | recommended v1.0; mandatory v1.1+ |
| The target BR MUST be in status `approved` or higher at the moment this BR is approved | hook-enforced |
| Cycle detection: the `implements` chain MUST NOT form cycles | hook-enforced |
| `implements[]` is **not** a parent edge; the ban on multiple parents (standard/06 §6.8.3) applies to SR/TR, not to BR | normative |
| Deprecate target BR → cascade-warning for all `implemented-by` (not cascade-deprecate) | hook-enforced |
| Cross-substrate syntax: `id + scope.system` is substrate-independent | normative |
| Cardinality: array (0..N) | normative |

The enforcement gate is `scripts/check-implements-edge.js`. The `implemented-by` field is auto-derived; manual entry is prohibited.

---

## 3. SR — System Requirement

```yaml
# Extends common §1, additionally:

parent:
  id: "BR-NN"                         # required

# ADAPT source — via the canonical source.adapt / source.adapt-section (§1).
# There is no separate derived-from-adapt field (standard/06 §6.6.2).

constrained-by:                       # typed edges to SPEC-*
  - "SPEC-UI-NN"
  - "SPEC-API-NN"
  - "SPEC-DATA-NN"
  - "SPEC-SEC-NN"

quality-characteristic:               # ISO/IEC 25010:2023 (9 characteristics; interaction-capability ← usability, flexibility ← portability in 25010:2011; safety — new in 25010:2023)
  - functional-suitability | performance-efficiency | compatibility | interaction-capability | reliability | security | maintainability | flexibility | safety

# Inherited from parent BR (where applicable): data-classification, compliance, ai-act
```

---

## 4. TR — Task Requirement

```yaml
# Extends common §1, additionally:

parent:
  id: "SR-NN"                         # required

implements-spec: []                   # SPEC-* implemented by this task
estimated-effort: "<short statement>" # optional, free-form
```

---

## 5. SPEC-* common schema

All 9 SPEC types share a common structure (§1) plus the following SPEC-specific fields:

```yaml
type: SPEC-ARCH | SPEC-API | SPEC-DATA | SPEC-INT | SPEC-PROC | SPEC-UI | SPEC-AI | SPEC-SEC | SPEC-OPS

referenced-by: []                     # auto-derived
depends-on: []                        # SPEC this one depends on
compliance-refs: []                   # ISO / GDPR / ФЗ-152 / AI Act / NIST AI RMF
```

Mandatory body sections: `## Purpose`, `## Scope`, `## <Type-specific sections — see §6>`, `## Link to requirements`, `## Link to other SPEC`, `## Verification`, `## Open questions`.

---

## 6. SPEC type-specific extensions

Type-specific fields for the 9 SPEC types. Industry references are in [`standard/14`](../../standard/en/14-normative-refs.md). Legacy replacements: `UIC` → SPEC-UI, `AIC` → SPEC-AI, `INT-SR` → SPEC-INT.

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

# SPEC-AI (judge-model.vendor ≠ production-model.vendor — normative)
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

ADAPT is a separate artifact ([`standard/07`](../../standard/en/07-adapt.md)). It is reactive: it exists only when there are findings from the adversarial review of the TZ (§7.4.1). On a "no findings" verdict, no ADAPT is created; this is recorded via `<artifact>.source.adversarial-review-ref`.

```yaml
# Identity
id: ADAPT-NNN
title: "Adaptation of TZ <name>"
type: ADAPT
trigger-stage: import-tz | decompose-br | decompose-sr | spec | tc   # trigger stage (standard/07 §7.4.1.4)

# Source
source-tz: { id: TZ-YYYY-NNN, signed-date: "<ISO-date>", signed-by-client: "<name-role>", document-ref: "<link>" }
parent-adapt: { id: ADAPT-NNN, delta-tz: TZ-YYYY-NNN }   # for delta-ADAPT

# Supersession (standard/07 §7.6.4) — only for superseding-ADAPT
supersedes: ADAPT-MMM                                    # reference to the superseded ADAPT
superseded-by: ADAPT-NNN                                 # auto-derived; on the superseded one
supersession-rationale: "<contradicting BR/SR/SPEC + source>"   # mandatory if supersedes present

# Lifecycle (subset of §1: ADAPT does not use verified/deprecated; superseded — terminal on supersession)
status: draft | review | client-ready | answered | approved | frozen | superseded | obsolete
created: "<ISO-date>"
last-updated: "<ISO-date>"

# Approval (required for approved)
approval:
  client-signature: { signed-by: "<name>", role: "<role>", organization: "<client-org>", signed-at: "<ISO-datetime>", signature-ref: "<link>" }
  architect-signature: { signed-by: "<name>", role: architect, signed-at: "<ISO-datetime>" }

# Auto-derived
generates-requirements: []
generates-specs: []
open-questions-count: integer         # MUST be 0 for approved
resolved-questions-count: integer

# AI provenance
ai-provenance: { generated-by: "<vendor>-<model>@<date>", prompt-template: "<template-path>@<version>", context-tokens: integer, output-tokens: integer, human-edits: boolean }
```

Backward entries inside the body:

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
resolution: "..."                     # how the answer was integrated into Forward
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
negative: boolean                     # true for the paired negative TC

# Scope
level: system | subsystem | module
scope: { system: "<system-id>", subsystem: "<subsystem-id>", module: "<module-id>" }

# Lifecycle
status: draft | ready | passing | failing | obsolete

# Verification mapping (≥1)
verifies:
  - { id: "<requirement-id>", ref: "<link>", requirement-version: "<version-ref>" }   # V5 pinning (standard/03 §3.3.5)

# Pair link (mandatory if negative=false and a pair exists)
paired-with: ["<TC-id>"]

# Automation
automation:
  status: automated | manual-pending
  location: "<path-to-implementation>"      # mandatory if automated
  runner: pytest | jest | go-test | playwright | vlm-judge | ragas | pact | other
  manual-pending-until: "<ISO date>"        # mandatory if manual-pending
  manual-pending-reason: "<why>"

# Execution (mandatory if tc-type=ux | eval; judge.vendor ≠ production model vendor — see §6.2 SPEC-AI, §9)
judge: { vendor: "<provider>", model: "<model-id>", prompt-template: "<template-path>@<version>" }
baseline: { artifact: "<pointer>", perceptual-diff-threshold: float, metric-thresholds: {} }

# Last run (auto-managed; bot-only)
last-run:
  date: "<ISO timestamp>"
  result: pass | fail | skipped | n/a
  runner-id: "<runner@version>"
  run-ref: "<link>"
  requirement-version: "<version-ref>"
  judge-report: "<for ux/eval>"

# Replacement / obsolescence
obsolete-pending: boolean             # true on detected delta-TZ invalidation
replaces: "<old-id>"
replaced-by: "<new-id>"
obsoleted-date: "<ISO date>"

# Inherited
ai-provenance: { ... }                # see §1
```

---

## 9. Validation rules (cross-field)

Rules not expressible in pure JSON Schema; they require a custom validator. The "Formal check" column gives an executable predicate or a reference to a ready-made KG query ([reference/05 §5/§6](05-knowledge-graph-schema.md)).

| Rule | Description | Formal check |
|---|---|---|
| **ID immutable** | When a file changes, the `id` field does not change. | `diff(prev.id, curr.id) == ∅` |
| **`parent` exists** | For SR — the parent BR exists and is in status ≥ `approved`. | `status(BR[SR.parent.id]) ≥ approved`; orphans — [05 §6.1](05-knowledge-graph-schema.md#61-orphan-approved-requirements) |
| **`source.adapt` approved** | For BR/SR/SPEC — the ADAPT in `source.adapt` is in status `approved`/`frozen`. | `status(ADAPT[art.source.adapt]) ∈ {approved, frozen}` |
| **`verified-by` consistency** | TCs in `verified-by` have `verifies[].id` = this artifact. | `∀ tc ∈ art.verified-by: art.id ∈ tc.verifies[].id` |
| **`requirement-version` lock** | `TC.last-run.requirement-version` = `verifies[].requirement-version`. | `tc.last-run.requirement-version == tc.verifies[].requirement-version`; stale — [05 §4.4](05-knowledge-graph-schema.md#44-stale-tc-criteria-version-drift) |
| **`source.adapt` for BR/SR/SPEC (conditional)** | Canonical ADAPT source when findings are present; on a "no findings" verdict — `source.adversarial-review-ref` ([standard/07 §7.4.1](../../standard/en/07-adapt.md#7.4.1)). TR — via parent SR ([standard/06 §6.6.2](../../standard/en/06-requirements-hierarchy.md#6.6.2)). | `art.type ∈ {BR, SR, SPEC-*} ⇒ art.source.adapt ≠ null ∨ art.source.adversarial-review-ref ≠ null` |
| **SPEC-AI requires ai-act** | For an AI artifact, `ai-act.risk-class` is mandatory. | `art.type == SPEC-AI ⇒ art.ai-act.risk-class ≠ null` |
| **Data residency consistency** | RU in `SR.data-classification.data-residency` ⇒ the same in the parent BR. | `'RU' ∈ SR.…data-residency ⇒ 'RU' ∈ BR[SR.parent].…data-residency` |
| **Compliance hierarchy** | `SR.compliance ⊆ parent BR.compliance` (or explicit justification). | `SR.compliance ⊆ BR[parent].compliance ∨ exists(extension-justification)` |
| **TC `automated` requires location** | `automation.status: automated` ⇒ `automation.location` non-empty. | `tc.automation.status == 'automated' ⇒ tc.automation.location ≠ ''` |
| **Negative TC mandatory** | For every normative assertion — a TC with `negative: true`. | `∀ assertion ∈ art: ∃ tc(negative: true)` ([standard/09 §9.7](../../standard/en/09-test-cases.md#9.7)) |
| **ADAPT open-questions == 0 for approved** | Approval is blocked while there are `open`/`asked-to-client` backward entries. | `adapt.status == approved ⇒ count(backward[status ∈ {open, asked-to-client}]) == 0` ([05 §4.7](05-knowledge-graph-schema.md#47-adapt-with-open-backward-findings)) |
| **Supersession correct** | `supersedes` ⇒ non-empty `supersession-rationale` and a symmetric `superseded-by` on the target; no dangling `source.adapt` on a `superseded` ADAPT ([standard/07 §7.6.4](../../standard/en/07-adapt.md#7.6), [standard/10 §10.8.5](../../standard/en/10-lifecycle-qg.md#10.8)). | `adapt.supersedes ≠ null ⇒ adapt.supersession-rationale ≠ '' ∧ ADAPT[adapt.supersedes].superseded-by == adapt.id`; `∄ art: art.source.adapt = X ∧ status(ADAPT[X]) == superseded` |
| **Judge isolation (SPEC-AI)** | `judge.vendor` ≠ `production-model.vendor`. | `tc.judge.vendor ≠ SPEC-AI[tc.verifies].production-model.vendor` |
| **SPEC depends-on acyclic** | The `depends-on` graph between SPEC is a DAG. | cypher cycle-detection ([05 §4.6](05-knowledge-graph-schema.md#46-spec-dependency-cycle-detection)): rows ≠ ∅ ⇒ violation |

---

## 10. Substrate isomorphism

Mapping for git (YAML frontmatter) ↔ document-oriented store (JSON document):

| Field (canonical) | git (YAML frontmatter) | Document store (JSON doc) |
|---|---|---|
| `id` | `id` | `_id = <project>:<doc-type>:<slug>`, field `slug` |
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

Substrate-native field names MAY differ, but the **semantics and invariants are preserved** through capabilities V1–V6 ([01-glossary.md §27](01-glossary.md#27-substrate-capabilities-v1-v6)).

---

## 11. Schema versioning

Every artifact has a `schema-version` field (semver). When the file version and the current schema do not match, the validator proposes a migration.

| Change | Bump |
|---|---|
| New optional field | minor (1.0 → 1.1) |
| New mandatory field | major (1.0 → 2.0) + migration script |
| Field removal | major + migration script |
| Enum change | minor if addition, major if removal |
| Field rename | major + migration script |

**Current schemas version:** 1.0-draft.

---

## 12. JSON Schema fragment example (BR)

Key patterns (the full BR schema — `reference/schemas/br.json`, planned):

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

Equivalent JSON schemas for SR/TR/SPEC-*/TC/ADAPT are in `reference/schemas/` (planned).

---

*Schemas reference RENAR 1.0-draft — see also [01-glossary.md](01-glossary.md), `standard/06`-`09` for normative definitions.*
