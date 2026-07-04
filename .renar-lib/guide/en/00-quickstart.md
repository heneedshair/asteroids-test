---
title: "Quickstart"
description: "A 30-minute hands-on start with RENAR: TZ → ADAPT → SR → SPEC → TC → verified."
order: 0
lang: en
version: "1.0-draft"
---

# 00. Quickstart

> End-to-end example: a small "email/password sign-up" project. The full RENAR cycle with a minimal set of artifacts: TZ → ADAPT → BR → SR → SPEC → TC.
> Time: ~30 minutes of reading + sketching on paper; ~2-3 hours if you do it live on a substrate.
> Prerequisites: [core/renar-core.md](../../core/en/renar-core.md) (≤ 10 min). The full-size example with 2FA — [01-walkthrough.md](01-walkthrough.md). The RU corpus language — [standard/00 §0.7](../../standard/en/00-introduction.md#0.7).

After this start you will have: an understanding of the full RENAR cycle on one small example; ready-made YAML templates for each artifact type; experience passing two gates (QG-ADAPT-approve ≡ **QG-3 Architecture Gate** [§10.3](../../standard/en/10-lifecycle-qg.md#10.3) + **QG-2 Verification Gate**); a point from which to scale.

---

## Prerequisites

**Substrate** (`substrate`) — the system for storing and versioning artifacts. RENAR is independent of the kind of store; for the quickstart, any substrate with V1-V6 capabilities will do ([reference/01 §27](../../reference/en/01-glossary.md#27-substrate-capabilities-v1-v6)): git with PR review; a document-oriented store; a DBMS with history and signatures.

**Folder structure (the default convention for git):**

```text
my-project.req/
  tz/                   # immutable client TZ
  adapt/                # ADAPT artifacts
  br/                   # Business Requirements
  sr/                   # System Requirements
  specs/{arch,api,data,ui,sec,ai,proc,int,ops}/
  tests/                # TC (tc-type incl. contract)
```

For other substrates, use an equivalent organization by document type or namespace.

---

## Step 1. TZ (5 min)

The client provides a small TZ. It is a **contractual immutable** document — once signed, it is not edited.

**`tz/TZ-2026-001.md`** (excerpt):

```markdown
---
id: TZ-2026-001
title: "User registration via email"
signed-date: "2026-05-15"
signed-by-client: "J. Ivanov, PM, ClientCo"
---

# TZ-2026-001

## §1. Context
Build a system for user registration via email.

## §2. Requirements
- A user can register via email and password.
- After registration, the user confirms their email.
- After confirmation — access to the personal dashboard.

## §3. Constraints
- Web application only.
- Storage in the RF (ФЗ-152).
```

The TZ is signed by the client → immutable. All edits and interpretations go through ADAPT.

---

## Step 2. ADAPT `draft` (10 min)

Create `adapt/ADAPT-001-main.md`. An AI agent or an engineer fills in **Forward** (how we understood it) and **Backward** (what is unclear).

```yaml
---
id: ADAPT-001
title: "Adaptation of TZ-2026-001 — Registration via email"
type: ADAPT
source-tz: { id: TZ-2026-001, signed-date: "2026-05-15", signed-by-client: "J. Ivanov, PM, ClientCo", document-ref: "<link>" }
status: draft
created: "2026-05-16"
ai-provenance: { generated-by: "anthropic-claude-opus-4-7@2026-05-16", prompt-template: "prompts/adapt-from-tz.md@v1.0", context-tokens: 1024, output-tokens: 2048, human-edits: false }
---
```

**Forward §2 Requirements:**

```markdown
**Quote:** "A user can register via email and password. After registration, the user confirms their email. After confirmation — access to the personal dashboard."

**Interpretation:** POST /auth/sign-up with {email, password}. A User is created with status `unverified`. A verification link email is sent. Click → status `verified`. Only `verified` users can sign in.

**Elaborated scenarios:** sign-up; email verification; first sign-in.
**Coverage:** in scope — email/password + verification + dashboard access. Out of scope: OAuth, SMS, 2FA, password reset.
**Forward links** (auto-populated after approval): BR-01, SR-01, SR-02, SR-03.
```

**Backward (3 entries):**

```markdown
### B-001: gap — sign-in attempt by an unverified user
Status: open. Description: the TZ does not describe system behavior on a sign-in attempt before email verification.
Question to client: show a "verify your email" message with a resend button — or a 401 with no explanation?

### B-002: regulatory — ФЗ-152 storage in the RF
Status: open. Description: TZ §3 requires "storage in the RF". What exactly: the data center, the provider's jurisdiction, a separate installation?
Question to client: clarify the scope of ФЗ-152.

### B-003: gap — resending the email
Status: open. Description: what if the verification email is lost? what about a rate limit?
Question to client: the resend policy.
```

---

## Step 3. ADAPT `approved` (5 min)

The client provides answers. The backward lifecycle: `open → asked-to-client → answered → resolved → frozen (after approval)`.

Summary after the answers:

```markdown
### B-001: resolved (2026-05-18, J. Ivanov)
"Show a message + a resend button. A 401 with no explanation is bad UX."
→ a scenario added to Forward §2; SR-04 created.

### B-002: resolved (2026-05-18)
"Data center in the RF, RF jurisdiction. The provider is chosen by the contractor."
→ data-residency: ["RU"] in Forward §2.

### B-003: resolved (2026-05-18)
"Resend no more than once every 5 minutes, no more than 5 times per day."
→ rate-limit rules in Forward §2; SR-04 refined.
```

All backward entries → `resolved`, `open-questions-count = 0`. **QG-ADAPT-approve** — 6 items passed:

```yaml
status: approved
approval:
  client-signature: { signed-by: "J. Ivanov", role: PM, organization: "ClientCo", signed-at: "2026-05-18T15:30:00Z", signature-ref: "<link>" }
  architect-signature: { signed-by: "P. Petrov", role: architect, signed-at: "2026-05-18T16:00:00Z" }
ai-provenance: { human-edits: true }    # the architect edited the AI draft
open-questions-count: 0
resolved-questions-count: 3
```

After approval the ADAPT is **immutable** (frozen). All BR/SR/SPEC reference the approved ADAPT, not the TZ directly.

---

## Step 4. BR-01 (3 min)

`br/BR-01-user-registration.md`:

```yaml
---
id: BR-01
title: "User registration via email"
type: BR
status: approved
priority: must
source: { adapt: "ADAPT-001", adapt-section: "Forward §2", tz-section: "§2" }
business-context:
  stakeholder: "J. Ivanov (PM, ClientCo)"
  business-goal: "Enable users to create an account and gain access to the product"
business-outcome:
  measurement-type: kpi
  kpi-name: "registration-conversion-rate"
  measurement-method: "registered / visited_signup * 100%"
  baseline-value: 0
  target-value: 60
  target-met-by: "2026-09-01"
data-classification: { contains-pii: true, retention-days: 2555, data-residency: ["RU"] }   # 7 years per ФЗ-152
compliance: [{ standard: "ФЗ-152", article: "ст.6,12" }]
ai-provenance: { generated-by: "anthropic-claude-opus-4-7@2026-05-18", human-edits: true }
---

# BR-01: User registration via email

A user MUST be able to create an account on their own via email/password
and gain access to the personal dashboard after email confirmation.
```

---

## Step 5. SR-01..SR-04 (3 min)

Decompose the BR into verifiable SRs. Each SR references the approved ADAPT.

`sr/SR-01-sign-up.md` (frontmatter + body):

```yaml
---
id: SR-01
title: "Sign-up via email/password"
type: SR
status: approved
parent: { id: BR-01 }
source: { adapt: "ADAPT-001", adapt-section: "Forward §2" }
constrained-by: ["SPEC-API-01", "SPEC-DATA-01", "SPEC-SEC-01"]
quality-characteristic: [functional-suitability, security]
---

## Description
POST /auth/sign-up accepts {email, password}.
- Valid data → User status `unverified`, a verification email is sent, 201.
- Invalid email (regex/format) → 422 with the field indicated.
- Email already taken → 409.
- Weak password (< 8 chars or in the blacklist) → 422.
```

Likewise — SR-02 (email verification), SR-03 (sign-in for verified users), SR-04 (email resend with the rate limit from B-003).

---

## Step 6. SPEC-* (3 min)

`specs/api/SPEC-API-01-auth.md` (excerpt):

```yaml
---
id: SPEC-API-01
title: "Authentication REST API"
type: SPEC-API
status: approved
source: { adapt: "ADAPT-001" }
api-style: rest
api-version: "v1.0.0"
versioning-strategy: url-path
authentication: bearer-jwt
rate-limits: [{ endpoint: "POST /auth/resend-email", limit: "1/5min/user; 5/24h/user" }]
contract-file: { format: openapi-3.1, location: "contracts/auth-api.yaml" }
depends-on: ["SPEC-DATA-01", "SPEC-SEC-01"]
referenced-by: ["SR-01", "SR-02", "SR-03", "SR-04"]   # auto-derived
---
```

Likewise — SPEC-DATA-01 (the User schema), SPEC-SEC-01 (the auth model + ФЗ-152 controls).

---

## Step 7. TC pos/neg pairing (5 min)

Each SR — at least 1 positive + 1 negative TC. The canonical schema — [reference/02 §8](../../reference/en/02-schemas.md#8-tc--test-case).

`tests/TC-01-signup-success.md` (positive, for SR-01):

```yaml
---
id: TC-01
title: "Sign-up: successful registration"
type: TC
tc-type: system
status: ready
verifies: [{ id: SR-01, requirement-version: "1.0" }]
negative: false
automation: { status: automated, location: "tests/auth/test_signup.py::test_signup_success", runner: pytest }
---

## Given
- a new email (uniquely-generated@test.com); a valid password (length ≥ 8, not in the blacklist).

## When
POST /auth/sign-up {email, password}

## Then
- status 201; body {"user_id": "<uuid>", "status": "unverified"}; a User in the DB with status `unverified`; a verification email sent (mock).
```

`tests/TC-02-signup-invalid-email.md` (negative, for SR-01):

```yaml
---
id: TC-02
title: "Sign-up: reject an invalid email"
type: TC
tc-type: system
status: ready
verifies: [{ id: SR-01, requirement-version: "1.0" }]
negative: true
automation: { status: automated, location: "tests/auth/test_signup.py::test_signup_invalid_email", runner: pytest }
---

## Given
- email "not-an-email" (no `@`); any valid password.

## When
POST /auth/sign-up {email, password}

## Then
- status 422; body {"field": "email", "error": "invalid format"}; no User created in the DB; no email sent.
```

Likewise, pairs for SR-02, SR-03, SR-04. For SR-04 (with the rate limit) — an additional TC that checks the block after the 5th attempt within 24 hours.

---

## Step 8. Run the TCs and promote the SR (2 min)

The test runner on the substrate runs the TCs and updates `last-run`:

```yaml
# tests/TC-01-signup-success.md (after the run):
last-run: { date: "2026-05-19T10:00:00Z", result: pass, runner-id: "test-runner@1.0", run-ref: "<link>", requirement-version: "1.0" }
```

When **all** TCs from `SR-01.verified-by[]` are green → spot-check (Core Rule 5: the engineer manually runs 1-2 random passing TCs and checks them against the SR). If the spot-check passes → **QG-2 Verification Gate** passed → SR-01 → `verified`:

```yaml
# sr/SR-01-sign-up.md:
status: verified
verified-by: ["TC-01", "TC-02"]
verified-at: "2026-05-19T14:00:00Z"
verified-by-engineer: "P. Petrov"
```

Likewise — SR-02, SR-03, SR-04. When all SRs in BR-01 are verified → QG-4 (BR ready for acceptance).

---

## Traceability chain

At any moment the provenance of an artifact can be reconstructed:

```text
TC-02 (negative)
  └─ verifies SR-01 (sign-up)
       └─ derived from ADAPT-001 §2 Forward (email/password)
             └─ interprets TZ-2026-001 §2 (immutable)
       └─ constrained-by SPEC-API-01 (REST contract)
                                 └─ depends-on SPEC-DATA-01, SPEC-SEC-01
```

An audit a year later: "where did the requirement to return 422 on an invalid email come from" — TC-02 → SR-01 → ADAPT-001 §2. The trace is complete.

---

## What you just did

- Created an immutable contractual artifact (the TZ).
- Went through two-way interpretation via ADAPT with three backward findings → the client gave answers → approved.
- Decomposed it into a BR + 4 SRs, bound to the approved ADAPT.
- Described 3 SPECs (API, DATA, SEC) as the parallel structural axis.
- Covered each SR with a pos+neg TC pair (at least 8 TCs).
- Passed two quality gates: QG-ADAPT-approve (≡ QG-3 Architecture) and QG-2 Verification Gate.

This is the full RENAR cycle in minimal form. On a real project — more BR/SR/SPEC, more backward findings, delegation to AI agents; optionally QG-4 (acceptance).

**In real work, steps 2-7 are performed by an AI agent.** The engineer does not write the frontmatter and body of artifacts line by line — they frame the task, read the result, refine it, and approve. This is the regular mode ([standard/00 §0.2.1](../../standard/en/00-introduction.md#0.2.1)). The full scenario of an initial TZ and a delta-TZ with an adversarial reviewer — in [01-walkthrough.md phase 2 + phase 8](01-walkthrough.md).

---

## What next

| You want to... | Document |
|---|---|
| A detailed end-to-end example (login + 2FA + 9 phases) | [01-walkthrough.md](01-walkthrough.md) |
| Transition from a legacy approach to RENAR | [02-transition-guide.md](02-transition-guide.md) |
| Git as a substrate (commit policy, PR review, hooks) | [03-tool-guide-git.md](03-tool-guide-git.md) |
| A document-oriented substrate | [04-document-store-substrate.md](04-document-store-substrate.md) |
| A comparison of RENAR with SAFe / BABOK / ISO 29148 | [05-safe-comparison.md](05-safe-comparison.md) |
| Compliance: GDPR / ФЗ-152 / AI Act | [06-compliance.md](06-compliance.md) |
| Failure modes — typical failures and patterns | [07-failure-modes.md](07-failure-modes.md) |
| The full normative specification (15 chapters) | [`standard/`](../../standard/en/README.md) |
| Artifact schemas and validation rules | [`reference/02-schemas.md`](../../reference/en/02-schemas.md) |
| Glossary and mapping to industry standards | [`reference/01-glossary.md`](../../reference/en/01-glossary.md) |

---

*RENAR Quickstart 1.0-draft — renar.tech*
