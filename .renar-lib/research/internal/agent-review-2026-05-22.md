# Agent adversarial review — 2026-05-22

> Internal findings log (informative). Procedure: [ru-agent-adversarial-review.md](../ru-agent-adversarial-review.md).

## Baseline

| Check | Result |
|---|---|
| check-md-links.js | 0 broken |
| validate-schema-examples.js | 0 violations |
| style-guide-check.js | 0 findings |
| check-site-parity.js | OK |

## A1 — RE architect

| ID | File | § | Sev | Observation | Disposition |
|---|---|---|---|---|---|
| F-A1-01 | standard/09 | §9.1.1 | minor | Decision tree added (P1) | fixed |
| F-A1-02 | standard/10 | §10.1.1 | minor | QG tree added (P1) | fixed |
| — | — | — | — | No blocker: closed lists §1.7.5 intact | — |

## A2 — Compliance skeptic

| ID | File | § | Sev | Observation | Disposition |
|---|---|---|---|---|---|
| F-A2-01 | guide/06 | §11.1 | minor | Evidence pack templates missing before P1 | fixed |
| F-A2-02 | guide/09 | E3 | — | GDPR trace path complete | pass |
| — | — | — | — | No false conformance path found in §14.3 vs reference/08 | — |

## A3 — Adversarial reader

| ID | File | § | Sev | Observation | Disposition |
|---|---|---|---|---|---|
| F-A3-01 | guide/09 | index | major | Only 3 E2E — insufficient for adoption | fixed (E4–E6) |
| F-A3-02 | research/ | external kit | minor | Human-only panel impractical | fixed → agent default |

## Sign-off

- Blockers: **0**
- Majors open: **0**
- Validators re-run after fixes: **PASS**
