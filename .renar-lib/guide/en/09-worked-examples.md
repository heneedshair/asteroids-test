---
title: "Examples library"
description: "Index of RENAR E2E examples: quickstart, login, GDPR export, API webhook, SPEC-AI eval, delta-TZ."
order: 9
lang: en
version: "1.0-draft"
---

# 09. Examples library

> Six scenarios (E1–E6): three full in-doc cycles (E3–E6) plus two walkthroughs (E1–E2). Each in-doc example: **TZ → ADAPT → BR/SR → SPEC → TC → QG**.

| # | Scenario | Document | Audience | Focus |
|---|---|---|---|---|
| E1 | Email/password sign-up (minimal) | [00-quickstart](00-quickstart.md) | Beginner | 30 min, minimal artifacts |
| E2 | Login + profile + permissions (full) | [01-walkthrough](01-walkthrough.md) | Tech Lead, QA | Full lifecycle, AI generation of TC |
| E3 | Personal-data export (GDPR / FZ-152) | [§14](#2-e3--personal-data-export-gdpr-art-15--fz-152) | Legal, PM, Architect | Compliance, SPEC-DATA/SEC |
| E4 | Webhook idempotency (REST API) | [§4](#3-e4--webhook-idempotency-spec-api) | Backend, Architect | `tc-type: contract`, SPEC-API |
| E5 | RAG assistant (SPEC-AI eval) | [§5](#4-e5--rag-assistant-spec-ai) | AI engineer | `tc-type: eval`, judge isolation |
| E6 | Delta-TZ: scope dispute | [§5](#5-e6--delta-tz-scope-dispute) | PM, Client, Architect | ADAPT backward, immutable TZ |

---

## 2. E3 — Personal-data export (GDPR Art. 15 / FZ-152)

**Context:** the SaaS "AcmeCRM" stores customer PII. The regulator and the contract require a machine-readable export to be delivered on a data-subject request within ≤30 days.

### 2.1 TZ fragment (immutable)

```markdown
# TZ-2026-002 — Data subject export

§3.1 A data subject can request a full export of their PII via the UI "Privacy → Export my data".
§4.2 Format: JSON + CSV bundle, zip, SHA-256 checksum.
§4.3 SLA: the download link is ready within ≤ 72 hours of verified identity.
§4.4 The export includes: profile, activity log for 24 months, marketing consents.
§4.5 The request is logged; a repeat export — no more than once every 30 days without an administrator override.
```

### 2.2 ADAPT (abridged)

```yaml
id: ADAPT-002
type: ADAPT
status: approved
source-tz: { id: TZ-2026-002, signed-date: "2026-05-01" }
```

**Forward §3:** the export is asynchronous (job queue); identity — via the existing MFA flow.

**Backward (resolved):**

| # | Finding | Resolution |
|---|---|---|
| B-01 | "24 months of activity" — calendar or rolling? | Rolling 730 days |
| B-02 | Admin override — who approves? | Role `privacy-officer` + an audit log |

### 2.3 BR + SR

```yaml
# br/BR-02-data-subject-export.md
id: BR-02
type: BR
title: "The data subject receives a machine-readable PII export"
status: approved
source: { adapt: ADAPT-002, adapt-section: "Forward §3" }
compliance:
  - { standard: GDPR, control: "Art. 15" }
  - { standard: "FZ-152", control: "art. 14" }
```

```yaml
# sr/SR-08-export-request.md
id: SR-08
type: SR
parent: { id: BR-02 }
title: "An authenticated user initiates an export job"
status: approved
constrained-by: ["SPEC-API-04", "SPEC-DATA-02", "SPEC-SEC-03"]
```

```yaml
# sr/SR-09-export-delivery.md
id: SR-09
type: SR
parent: { id: BR-02 }
title: "The user downloads the ready bundle via a time-limited signed URL"
status: approved
constrained-by: ["SPEC-API-04", "SPEC-SEC-03"]
```

### 2.4 SPEC (excerpts)

**SPEC-DATA-02** — the export-bundle schema (tables: `users`, `activity_events`, `marketing_consents`).

**SPEC-SEC-03** — signed URL TTL 24h; rate limit 1 export / 30 days; role `privacy-officer` for the override.

**SPEC-API-04** — `POST /v1/privacy/export`, `GET /v1/privacy/export/{job_id}`.

### 2.5 TC (pos/neg for SR-08)

```yaml
---
id: TC-080
title: "An export job is created for a verified user"
type: TC
tc-type: system
status: ready
verifies:
  - id: SR-08
    requirement-version: "1.0"
negative: false
---
## When
POST /v1/privacy/export (session: verified-user)
## Then
- 202 + job_id; status pending; audit event recorded
```

```yaml
---
id: TC-081
title: "Export rejected without an MFA-verified session"
type: TC
tc-type: security
status: ready
verifies:
  - id: SR-08
    requirement-version: "1.0"
negative: true
---
## When
POST /v1/privacy/export (session: password-only, no MFA)
## Then
- 403; job not created; security audit event
```

Analogous pairs for SR-09 (signed URL valid / expired).

### 2.6 Quality gates

| Quality gate | Evidence |
|---|---|
| **QG-ADAPT-approve** (by meaning, near the "architecture gate": `QG-3`) | ADAPT-002 in `approved`, backward findings closed |
| **QG-2 Verification Gate** | `TC-080`…`081` pass; the `requirement-version` in `last-run` matches (`1.0`) |

### 2.7 What next

- The full scenario under `git` — [03-tool-guide-git](03-tool-guide-git.md)
- Compliance mapping — [06-compliance](06-compliance.md)
- Conformance manifest — [reference/08](../../reference/en/08-conformance-self-assessment.md)

---

## 3. E4 — Webhook idempotency (SPEC-API)

**Context:** a payment provider sends `POST /webhooks/payment` with an `Idempotency-Key`. Duplicates MUST NOT create a double charge.

**TZ (fragment):** "A repeat webhook with the same key within 24h returns the same `payment_id`, HTTP 200."

**SR + SPEC:**

```yaml
id: SR-20
type: SR
constrained-by: ["SPEC-API-07"]
```

**SPEC-API-07** — the contract: headers, body schema, response codes 200/400/409.

**TC (contract pair):**

```yaml
id: TC-200
type: TC
tc-type: contract
verifies: [{ id: SR-20, requirement-version: "1.0" }]
negative: false
```

```yaml
id: TC-201
type: TC
tc-type: contract
verifies: [{ id: SR-20, requirement-version: "1.0" }]
negative: true
```

Neg: a second key with a different body → 409 Conflict.

**Quality gate `QG-2`:** both `TC`s pass; the `requirement-version` in `last-run` matches (`1.0`).

---

## 4. E5 — RAG assistant (SPEC-AI)

**Context:** an in-app chat answers from the knowledge base; eval against a golden Q&A set.

**SPEC-AI-02** — model card, fallback, cost cap.

**TC eval (judge ≠ production):**

```yaml
id: TC-300
type: TC
tc-type: eval
verifies: [{ id: SPEC-AI-02, requirement-version: "1.0" }]
automation:
  judge-model: "eval-judge-v2"   # ≠ production chat model
negative: false
```

Neg eval: prompt injection in the user message → refusal + audit event (`tc-type: eval`, adversarial negative).

See [standard/09 §9.6.2](../../standard/en/09-test-cases.md), [guide/07 §4.5](07-failure-modes.md#35-adversarial-review).

---

## 5. E6 — Delta-TZ: scope dispute

**Context:** after the signed TZ the client asks to "add PDF export" — outside the scope of ADAPT-002.

**The correct path to the Source of Truth (SoT):**

1. Do **not** edit the immutable TZ and do **not** silently extend the SR.
2. Draw up a **delta-TZ** → a new ADAPT-002b (forward + backward).
3. Backward finding: "PDF export was not part of Forward §3 of ADAPT-002."
4. The client signs the delta-ADAPT → new SR/SPEC/TC.

**Anti-pattern:** a direct commit to `sr/SR-08` without a `delta-ref` — drift class 4.11.6 ([standard/04 §4.11](../../standard/en/04-terms.md)).

See [standard/07 §7.6](../../standard/en/07-adapt.md), [guide/02-transition-guide](02-transition-guide.md).

---

## 6. E7 — A subsystem as a standalone product (`implements`-edge)

**Context:** the platform `acme` (a system) consists of the subsystem `acme.notify` — a separate product with its own business owner (Notify Lead), its own team, and its own release cycle. Scenario §6.8.2 of the RENAR Standard.

### 6.1 Artifact hierarchy

```text
acme (system)
├── BR-01 (order intake with AI assistance)               level: system
├── BR-05 (monitoring and alerts for the operations team)  level: system
└── acme.notify (subsystem, standalone product)
    └── BR-01 (multichannel notification delivery)         level: subsystem
         implements:
           - id: BR-01      (elaborates "order intake": notifications on status changes)
             scope: { system: acme }
           - id: BR-05      (elaborates "monitoring": notifications on SLA breaches)
             scope: { system: acme }
         ↓
         SR-01..SR-12 (notify-internal requirements)
         SPEC-INT-01 (integration with acme via the message bus)
         SPEC-API-01 (REST API for notify clients)
```

`acme.notify.BR-01` is the root node of its own requirements tree (`parent` is absent, as for any BR). The link to the system is expressed by a **typed** `implements[]` edge, not a parent-edge.

### 6.2 frontmatter `acme.notify/br/BR-01-multichannel-delivery.md` (fragment)

```yaml
---
id: BR-01
title: "Multichannel notification delivery"
type: BR
level: subsystem
scope:
  system: acme
  subsystem: acme.notify

status: approved
owner: "Notify Lead (notify-side); Architect (acme-side)"

source:
  adapt: ADAPT-NOTIFY-001
  adapt-section: "Forward §2"
  tz-section: "TZ-NOTIFY §3"

# === implements-edge §6.8.2 ===
implements:
  - id: BR-01
    scope:
      system: acme
    rationale: "ADAPT-NOTIFY-001 §2.1 — notifications on order status change"
  - id: BR-05
    scope:
      system: acme
    rationale: "ADAPT-NOTIFY-001 §2.4 — SLA alerts for operations"

business-context:
  stakeholder: "Notify Lead"
  business-goal: "Timely delivery of notifications to the end-customer and the operations team"
---

# BR-01: Multichannel notification delivery

The notify subsystem delivers notifications …
```

### 6.3 Machine-readable trace chain

```text
TC-NOTIFY-15
  → verifies SR-NOTIFY-08 (rate-limit for the email channel)
        ├─ parent:   acme.notify.BR-01 v1.2
        │              └─ implements: acme.BR-01 v3.0, acme.BR-05 v1.4
        │                              (typed cross-level edge)
        ├─ source.adapt: ADAPT-NOTIFY-001 §Forward §2.2
        └─ constrained-by: SPEC-NOTIFY-API-01, SPEC-NOTIFY-OPS-01
```

On an audit, the full chain is reconstructed from TC-NOTIFY-15: SR → subsystem BR → system BR. Before v1.0 (without the `implements`-edge) the chain broke off at `acme.notify.BR-01` and continued only through the prose of the "Context" section.

### 6.4 Gates on the substrate side

When `acme.notify.BR-01` is approved, the substrate-native hook checks (see [standard/10 §10.11.1](../../standard/en/10-lifecycle-qg.md#10.11.1)):

1. `acme.BR-01` and `acme.BR-05` exist in the substrate by `id + scope.system`.
2. Both target BRs are in status `approved` (or `verified`).
3. The chain `acme.notify.BR-01 → acme.BR-01 → …` does not form a cycle.
4. `acme.notify.BR-01.level = subsystem` (rule: `implements[]` does not apply at `level: system`).

If any check fails, the approval is blocked. Behavior when `acme.BR-01 = deprecated`: a warning, not fatal (the Architect decides: update `implements` to the current BR or mark `acme.notify.BR-01` as requiring review).

### 6.5 Evolution "module → subsystem" via `implements`

When a module acquires a business owner ([standard/06 §6.9.1](../../standard/en/06-requirements-hierarchy.md#6.9.1)):

1. The business owner is captured via an ADAPT backward finding (category `scope`).
2. After the delta-ADAPT is approved, the module is promoted to a subsystem; a subsystem BR is created.
3. **New step (v1.0+):** the subsystem BR declares `implements[]` on the applicable system BRs. Without this step, the §6.8.2 scenario carries an absence of traceability incompatible with v1.1 conformance.

Anti-pattern: creating `acme.notify.BR-01` with `level: subsystem` but without `implements[]` — formally permitted on v1.0 (recommended), but non-conformant on v1.1+. If the parent system has an approved BR, the absence of `implements[]` MUST be **explicitly justified** in the "Context" section of the BR with a reference to ADAPT§.

See [standard/06 §6.5.2](../../standard/en/06-requirements-hierarchy.md#6.5.2), [§6.8.2](../../standard/en/06-requirements-hierarchy.md#6.8.2), [§6.10.3](../../standard/en/06-requirements-hierarchy.md#6.10.3), [standard/13 §13.3.8](../../standard/en/13-conformance.md#13.3.8).

---

*RENAR Guide 1.0-draft — renar.tech*
