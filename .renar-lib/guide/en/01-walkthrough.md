---
title: "Walkthrough"
description: "A full-size end-to-end RENAR walkthrough on the Login Flow project for AcmeCorp."
order: 1
lang: en
version: "1.0-draft"
---

# 01. Walkthrough: Login Flow for AcmeCorp

> One full RENAR cycle from a signed TZ to an accepted release. The example is an internal tool with registration via corporate email and 2FA. The goal is to show **every phase** on a single medium-sized project.
>
> **Context:** AcmeCorp, ~1 sprint of team work, stack Next.js + FastAPI + PostgreSQL. RENAR maturity at the RENAR-3+ level (full ADAPT + TC + adversarial). The example is **substrate-independent**: operations go through the V1–V6 capabilities; the concrete directory layout is in [03-tool-guide-git](03-tool-guide-git.md) or [04-document-store-substrate](04-document-store-substrate.md).
>
> **Prerequisites:** [00-quickstart](00-quickstart.md), [core/renar-core](../../core/en/renar-core.md), [reference/01-glossary](../../reference/en/01-glossary.md).

**Reader's route.** Phases 0–2 — context gathering, signing the TZ, ADAPT. Phases 3–4 — decomposition into BR/SR/SPEC and generation of pos/neg pairs for TC. Phase 5 — the canonical gates QG-0 (requirement approval) and QG-1 (the TC `draft → ready` transition only). Phases 6–7 — TR implementation and verification (QG-2). Phases 8–9 — a delta-TZ on changes and the QG-4 acceptance loop.

---

## Phase 0 — Requirements elicitation

Before signing the TZ. The AI agent runs 2–3 interviews with stakeholders (Sales Director, IT Manager) and gathers context in structured form.

Phase 0 artifacts (informative, not normative for RENAR Core): `elicitation/{domain-context.md, sales-director.yaml, it-manager.yaml, findings-clustered.md, critic-review.md, multi-model-diff.md}`. Phase 0 is not fixed in Core — it belongs to the elicitation methodology, out of scope for RENAR v1.0 ([standard/01 §1.3](../../standard/en/01-scope.md#1.3)).

---

## Phase 1 — TZ import

After the elicitation iterations, the client signs `TZ-2026-042`:

```markdown
# TZ-2026-042 — Login Flow for AcmeCorp Internal Tool
Signing date: 2026-05-03 · Parties: AcmeCorp + VendorCorp

## §1. Goals
Cut AcmeCorp employees' time to enter the tool to <2 minutes from first arrival to full access.

## §2. Functional requirements
### FR-001. Registration by corporate email
An employee registers via an email in the @acmecorp.com domain. An email outside the domain — denial with an explanation.

### FR-002. Two-factor authentication (TOTP)
After registration, mandatory 2FA setup via TOTP.

### FR-003. Access recovery via the corporate administrator
On loss of the 2FA device — recovery via a ticket in IT support.

## §3. Non-functional requirements
### NFR-001. Performance: Login <2 seconds (p95).
### NFR-002. Security: bcrypt cost-factor ≥ 12; login logs — 1 year; lockout after 5 failed attempts in 15 minutes.
### NFR-003. Jurisdiction: all data in the RU (government contracts).
```

The TZ is signed → **immutable**. Any edits go through ADAPT (Phase 2) or a delta-TZ (Phase 8). The runtime MUST register the immutable TZ as a revision (V1+V2) with AI provenance (V6).

---

## Phase 2 — ADAPT (two-way interpretation)

**2.1 The primary agent generates a draft ADAPT.** Input: TZ-2026-042 (immutable). Output: draft ADAPT-001 + Forward sections (across §2 FR + §3 NFR) + Backward findings (6 candidates) + V6 provenance.

**2.2 Adversarial review.** A separate critic agent (a different model) checks the backward findings; it blocks adapt-approve while critical findings remain open. Examples:

```text
[HIGH] B-001 reclassify gap → hidden-assumption
[HIGH] missed backward: case-sensitivity email in FR-001
[MEDIUM] B-004 terminology: define "employee" via User.role
[MEDIUM] B-006 feasibility: rate-limit scope (IP vs email vs session)
```

**2.3 Iterative resolution.** The Architect adjusts the Forward and Backward, the AI regenerates. After 2 adversarial cycles: 7 backward entries (B-001..B-007), all resolved or reclassified; the Forward covers §2 + §3 of the TZ in full.

**2.4 ADAPT in status `approved`:**

```yaml
---
id: ADAPT-001
title: "Adaptation of TZ-2026-042 — Login Flow AcmeCorp"
type: ADAPT
source-tz: { id: TZ-2026-042, signed-date: "2026-05-03", signed-by-client: "AcmeCorp PM" }
status: approved
approval:
  client-signature: { signed-by: "A. A. Ivanova", role: "Product Lead", organization: "AcmeCorp", signed-at: "2026-05-04T11:30:00Z" }
  architect-signature: { signed-by: "P. P. Petrov", role: architect, signed-at: "2026-05-04T12:00:00Z" }
generates-requirements: [BR-01, BR-02, SR-01, SR-02, SR-03, SR-04, SR-05, SR-06, SR-07]
generates-specs: [SPEC-UI-01, SPEC-API-01, SPEC-DATA-01, SPEC-SEC-01]
open-questions-count: 0
resolved-questions-count: 7
ai-provenance: { generated-by: "anthropic-claude-opus-4-7@2026-05-04", prompt-template: "prompts/adapt-from-tz.md@v2.1", human-edits: true }
---
```

Once approved, ADAPT-001 is **immutable**.

---

## Phase 3 — Decomposition into BR / SR / SPEC

**3.1 Decomposition.** Operation: `decompose`. Input: approved ADAPT-001. Output: draft BR (2), SR (7), SPEC (4) + adversarial-review artifacts.

**3.2 Adversarial findings:**

```text
[HIGH] BR-01 stakeholder field empty — who owns the business goal?
[HIGH] SR-05 says "bcrypt cost-factor 12" — this is a deployment detail, it belongs in SPEC-SEC-01, not in the SR.
[MEDIUM] NFR-003 (jurisdiction) is not reflected in the data-classification of SR-01.
[MEDIUM] SPEC-UI-01 has no accessibility-level — WCAG-AA minimum for a corporate tool.
→ 4 findings → fix → re-generate.
```

**3.3 Final artifact set:**

```text
acmecorp-requirements/
├── br/
│   ├── BR-01-self-service-registration.md
│   └── BR-02-secure-mfa.md
├── sr/
│   ├── SR-01-email-domain-validation.md       (FR-001)
│   ├── SR-02-totp-enrollment.md               (FR-002 setup)
│   ├── SR-03-totp-verification.md             (FR-002 verify)
│   ├── SR-04-password-recovery-via-admin.md   (FR-003)
│   ├── SR-05-rate-limiting-failed-logins.md   (NFR-002)
│   ├── SR-06-audit-logging.md                 (NFR-002 audit)
│   └── SR-07-data-residency-ru.md             (NFR-003)
├── specs/
│   ├── ui/SPEC-UI-01-login-flow.md
│   ├── api/SPEC-API-01-auth.md
│   ├── data/SPEC-DATA-01-user-model.md
│   └── sec/SPEC-SEC-01-auth-policy.md
└── tz/TZ-2026-042.md
```

**3.4 Example: SR-01 (frontmatter + body):**

```yaml
---
id: SR-01
title: "Email domain validation at registration"
type: SR
status: approved
parent: { id: BR-01 }
source: { adapt: "ADAPT-001", adapt-section: "Forward §2.1", tz-section: "§2 FR-001" }
constrained-by: ["SPEC-API-01", "SPEC-DATA-01", "SPEC-SEC-01"]
data-classification: { contains-pii: true, data-residency: ["RU"], retention-days: 365 }
compliance: [{ standard: "FZ-152", article: "art. 13.1" }]
ai-provenance: { generated-by: "anthropic-claude-opus-4-7@2026-05-04", prompt-template: "prompts/decompose-adapt.md@v2.1", context-tokens: 12450, output-tokens: 320, human-edits: true }
---

## Description
Registration is allowed only if the email belongs to the `@acmecorp.com` domain. Other domains are rejected with an explanation.

## Behavior
- email NOT from `@acmecorp.com` → 422 with `{"error":"email-domain-not-allowed", "allowed-domain":"acmecorp.com"}`. [ADAPT-001 §14.1 Forward; TZ-2026-042 §2 FR-001]
- email from `@acmecorp.com` → standard registration (SPEC-API-01).
- The whitelist is stored in `SPEC-SEC-01.allowed-domains`, extended without a release.
- Domain comparison is case-insensitive (ADAPT-001 §14.1 Forward).

## Constraints
- `*.acmecorp.com` subdomain — a separate Architect decision (out of scope).
```

**3.5 SPEC-API-01 (fragment):**

```yaml
---
id: SPEC-API-01
title: "Authentication REST API"
type: SPEC-API
status: approved
source: { adapt: "ADAPT-001", adapt-section: "Forward §2" }
api-style: rest
api-version: "v1.0.0"
versioning-strategy: url-path
authentication: bearer-jwt
rate-limits: [{ endpoint: "POST /auth/login", limit: "5/15min/ip+email" }]
contract-file: { format: openapi-3.1, location: "contracts/auth-api.yaml" }
depends-on: ["SPEC-DATA-01", "SPEC-SEC-01"]
---

## Endpoints

### POST /auth/register
- body: `{"email": "<corp-email>", "password": "<strong>"}`
- 201 → `{"user_id": "<uuid>", "verified": false, "totp_setup": false}` · 422 → invalid · 409 → email exists

### POST /auth/login
- body: `{"email", "password", "totp": "<6digits>"}`
- 200 → `{"access_token": "<jwt>", "expires_in": 3600}` · 401 → invalid · 429 → rate limit

### POST /auth/totp-setup — see SR-02.

## Error model
A single structure: `{"error": "<code>", "details": {...}}`.
```

---

## Phase 4 — TC generation (pos/neg pairs)

Operation: `tc-generate` SR-01 → pos/neg TC pairs per testable assertion (RENAR Core Rule 4: for each assertion in an SR — 1 pos + 1 neg TC).

**TC-001 (positive):**

```yaml
---
id: TC-001
title: "Registration with an allowed domain — happy path"
type: TC
tc-type: system
status: ready
verifies: [{ id: SR-01, requirement-version: "1.0" }]
negative: false
automation: { status: automated, location: "tests/auth/test_registration.py::test_allowed_domain_succeeds", runner: pytest }
---

## Given
- The DB is empty; email alice@acmecorp.com is not registered.

## When
POST /auth/register {email: "alice@acmecorp.com", password: "ValidPass123!"}

## Then (Pass)
- status 201; body contains {"user_id": "<uuid>", "verified": false, "totp_setup": false}; the User is created in the DB; a verification email is sent (mock SES).

## Fail criteria
- status ≠ 201; plaintext password in the body/logs; a User with a different email (case mismatch); the verification email is not sent.

## Not in scope
- TOTP setup → TC-005 (SR-02); rate limiting → TC-009 (SR-05).
```

**TC-004 (negative):**

```yaml
---
id: TC-004
title: "Registration with a disallowed domain — denial with an explanation"
type: TC
tc-type: system
status: ready
verifies: [{ id: SR-01, requirement-version: "1.0" }]
negative: true
automation: { status: automated, location: "tests/auth/test_registration.py::test_disallowed_domain_rejected", runner: pytest }
---

## Given
- email "bob@gmail.com" (outside the whitelist).

## When
POST /auth/register {email: "bob@gmail.com", password: "ValidPass123!"}

## Then (Pass)
- status 422; body == {"error": "email-domain-not-allowed", "allowed-domain": "acmecorp.com"}; the User is NOT created in the DB; no email is sent; an audit entry about the rejected attempt (for SR-06).

## Fail criteria
- status ≠ 422; the User is created; an email is sent (security leak); the audit entry is missing.
```

---

## Phase 5 — Quality gates before code (QG-0 and QG-1)

After generating TCs for all 7 SRs — 26 test-case entries in total (pos/neg pairs + extra negatives for SR-05, SR-06).

**5.1 QG-0 — approval of BR-01 (`draft → approved`).** Preconditions: `source.adapt = ADAPT-001 (approved)`; the SR tree in an admissible state before the BR is approved; the adversarial review succeeded; the assertions and links cite sections of ADAPT-001. Postcondition: BR-01 + child SRs, where needed, cascade `draft → approved`.

**5.2 QG-1 — TC only: `draft → ready`.** Per [§10.3.2](../../standard/en/10-lifecycle-qg.md), QG-1 applies only to TC and separates a prepared test case with an executable verification implementation from a draft. Preconditions for a TC: the implementation version-pin is fixed (V5); `automation.status` + `location` are valid; static checks pass; pos/neg pairing ([§9.7](../../standard/en/09-test-cases.md#9.7)); the mandatory body sections are filled in. Postcondition: `draft → ready`.

After **QG-0** on BR/SR and **QG-1** on each TC, TR work can be opened (Phase 6).

---

## Phase 6 — Implementation

**6.1 Task creation (TR).** Operation `sync-tasks`: input — the verified SR/SPEC set; output — 7 TRs in the implementation tracker (parent SR, implements-spec[], QG-0 ready with Goal + AC).

**6.2 A developer picks up TR-101.** QG-0 checks: Goal from SR-01; AC list (4 items); parent.id resolves (approved); implements-spec present; negative scenario in AC → the work session is allowed.

**6.3 Implementation (fragment):**

```python
# acmecorp-login.src/src/auth/registration.py
from fastapi import HTTPException
from config import settings   # allowed-domains from SPEC-SEC-01

def validate_email_domain(email: str) -> None:
    domain = email.split("@", 1)[-1].lower()
    if domain not in settings.AUTH_ALLOWED_DOMAINS:
        raise HTTPException(status_code=422, detail={
            "error": "email-domain-not-allowed",
            "allowed-domain": settings.AUTH_ALLOWED_DOMAINS[0],
        })
```

```python
# acmecorp-login.src/tests/auth/test_registration.py
def test_allowed_domain_succeeds(client, db, mock_ses):
    r = client.post("/auth/register", json={"email": "alice@acmecorp.com", "password": "ValidPass123!"})
    assert r.status_code == 201
    assert "user_id" in r.json()
    user = db.query(User).filter_by(email="alice@acmecorp.com").one()
    assert user.verified is False
    mock_ses.send_email.assert_called_once_with(template_id="verification-email", to_email="alice@acmecorp.com")

def test_disallowed_domain_rejected(client, db):
    r = client.post("/auth/register", json={"email": "bob@gmail.com", "password": "ValidPass123!"})
    assert r.status_code == 422
    assert r.json() == {"error": "email-domain-not-allowed", "allowed-domain": "acmecorp.com"}
    assert db.query(User).count() == 0
```

**6.4 Substrate-side validation hook:**

```text
[hook] Checking links for TR-101: parent.id SR-01 (approved); implements-spec [SPEC-API-01, SPEC-SEC-01].
[hook] Negative TCs: SR-01.verified-by includes TC-002, TC-004 (negative).
✓ Change allowed.
```

---

## Phase 7 — QG-2 (verification gate)

**7.1 CI runs the TCs.** `pytest acmecorp-login.src/tests/auth/test_registration.py` → 4 TC PASSED → the Bot updates `last-run.result = pass`, `requirement-version = 1.0` in the TC files.

**7.2 Spot-check (Core Rule 5).** Once per sprint the Engineer manually runs 5 random passing TCs and checks the actual result against the SR. Selected: TC-001, TC-008, TC-012, TC-019, TC-024 → 5/5 match.

**7.3 Promote SR-01 → verified.** QG-2 preconditions: approved ADAPT linkage; pos/neg TCs passing; `last-run.requirement-version` is fixed; the spot-check passed. Postcondition: SR-01 `approved → verified`; the coverage index is updated.

---

## Phase 8 — Delta-TZ

**8.1 The client, a week later:**

```markdown
# TZ-2026-051 — Addendum to TZ-2026-042
Base: TZ-2026-042

## §2 (change) FR-001 (extension)
Additionally allow @subsidiary.acmecorp.com (the subsidiary company). The whitelist is extended to 2 domains.
```

**8.2 Delta-ADAPT.** Operation `adapt-from-tz (delta)`: input — TZ-2026-051 + parent ADAPT-001; output — draft ADAPT-001-delta-1 + delta Forward + backward findings (e.g. B-008 scope). After 1 iteration with the client → approved.

**8.3 Impact analysis.** Operation `impact-analysis --delta TZ-2026-051`:

```text
Affected:
  BR-01 (scope extension)
  SR-01: verified → approved (TC rerun required)
  TC-001..004: re-pin 1.0 → 1.1; +2 new TC (subsidiary domain)
  TR-115: new implementation task
  SPEC-SEC-01: allowed-domains extended
```

**8.4 Apply delta.** The Architect opens the changes with the marker `[delta:TZ-2026-051]`. The AI updates SR-01 (extends the whitelist) and generates 2 new TCs. Implementation in TR-115. CI runs the TCs, the bot updates last-run. After the spot-check — SR-01 v1.1 → verified again.

> **Note (simple delta).** If the adversarial reviewer returns a "no findings, no clarifications" verdict ([§7.4.1.2](../../standard/en/07-adapt.md#7.4.1)), **no delta-ADAPT is created** — BR/SR/SPEC get `source.tz-section` directly with a fixed `adversarial-review-ref`. This removes the dual-signature overhead for trivial changes (e.g., a field rename).

---

## Phase 9 — QG-4 (acceptance)

**9.1 Four weeks after release.** Window: 4 weeks post-release.

```text
BR-01 KPI: Time-to-first-login — target <2min P95, actual 1.4min (143%)
BR-02 KPI: 2FA adoption — target ≥95%, actual 97%
```

**9.2 QG-4 report + adversarial.** The AI generates an acceptance report. The adversarial critic finds: "recovery via admin is not covered by a TC verifying the full flow with tickets." The Architect agrees → creates a mini-delta to add an acceptance TC.

**9.3 Sign-off.** After the findings are closed, the client signs the acceptance. BR → status `accepted`. Report archive: `QG-4-REPORT-v1.0.md` + lessons learned `lessons/2026-Q2.md`.

---

## Final artifacts

```text
acmecorp-requirements/
├── adapt/                 ADAPT-001-main.md (frozen) + ADAPT-001-delta-1.md (frozen)
├── br/                    BR-01 + BR-02 (status: accepted)
├── sr/                    SR-01 (v1.1, verified) + SR-02..SR-07 (v1.0, verified)
├── specs/                 SPEC-UI-01 + SPEC-API-01 + SPEC-DATA-01 + SPEC-SEC-01 (verified; SPEC-SEC-01 v1.1)
├── tests/                 TC-001..TC-028 (28 TC, 100% passing)
├── tz/                    TZ-2026-042.md + TZ-2026-051.md (delta, immutable)
├── elicitation/           # Phase 0 artifacts
├── lessons/2026-Q2.md     # Phase 9 lessons
└── QG-4-REPORT-v1.0.md    # acceptance report
```

---

## Project metrics

| Metric | Value |
|---|---|
| RDLT (TZ signed → all SR verified) | 11 days |
| Coverage Velocity | 100% over 2 sprints |
| Hallucination Rate (detected) | 0% |
| Adversarial findings found (cycle 1) | 4 high + 2 medium |
| Test-spec drift on the delta-TZ | 0% |
| Acceptance disputes | 0 (1 finding, resolved before sign-off) |
| Cost per BR | $0.46 (gen) + $0.18 (critic) = $0.64 |
| Total AI cost | ~$8.50 |
| BRs accepted | 2/2 |
| Days to accept | 35 |

---

## What this example shows

1. **Transparency** — every artifact has provenance, every transition is a gate with explicit conditions.
2. **Speed** — decomposing an approved ADAPT — tens of seconds + 2 adversarial cycles.
3. **Traceability** — from a line in the TZ to a passing TC in a handful of substrate query operations.
4. **Delta-TZ** — the affected SR/SPEC/TC/TR are computed automatically.
5. **Closing the loop** — QG-4 ties the result to business metrics (KPI achievement).
6. **AI-nativeness** — the critic and the generator are different models (isolation); the spot-check finds discrepancies that an automated run alone may miss.

---

## What's next

- [02-transition-guide.md](02-transition-guide.md) — transitioning from a legacy approach.
- [03-tool-guide-git.md](03-tool-guide-git.md) — git as a substrate.
- [04-document-store-substrate.md](04-document-store-substrate.md) — a document-oriented substrate.
- [05-safe-comparison.md](05-safe-comparison.md) — comparison with SAFe / BABOK / ISO 29148.
- [06-compliance.md](06-compliance.md) — compliance mapping (GDPR / FZ-152 / AI Act).
- [07-failure-modes.md](07-failure-modes.md) — failure modes.

---

*RENAR Walkthrough 1.0-draft — renar.tech*
