---
title: "RU world-class gaps — roadmap"
status: informative
lang: ru
version: "1.0-draft"
frozen: false
---

# RU world-class gaps — roadmap to v1.0

> **Informative only.** Не нормативный документ. Политика: **RU corpus world-class FIRST**; задачи `en-*` и перевод заблокированы до закрытия epic `ru-corpus-world-class-v2`.

## Статус WC-01..WC-15 (2026-05-22)

| WC | Критерий | Статус | Deliverable / task |
|---|---|---|---|
| WC-01 | Reader journey | **PASS** | `guide/README` personas, `standard/00 §0.6.4`, `core/renar-core.md` |
| WC-02 | Pedagogical ladder | **PASS** | `reference/09-pedagogical-density.md`, signposts в `standard/00`, `06`, `10`, `14` |
| WC-03 | ISO 29148 trace matrix | **PASS** | `reference/07-iso29148-trace-matrix.md` |
| WC-04 | MVR ↔ §14.3 bijection | **PASS** | `reference/08-conformance-self-assessment.md §1` |
| WC-05 | Closed lists verify | **PASS** | `standard/01 §1.7.5` + cross-refs `standard/03`, `reference/01` |
| WC-06 | 2× E2E examples | **PASS** | `guide/09-worked-examples.md` (E1–E3) |
| WC-07 | Conformance kit | **PASS** | `reference/08-conformance-self-assessment.md` |
| WC-08 | Substrate neutrality | **PASS** | public corpus grep 0 vendor tools (Story B) |
| WC-09 | Cross-ref integrity | **PASS** | `scripts/check-md-links.js` + `scripts/cross-ref-baseline.log` |
| WC-10 | Terminology RU v2 | **PASS** | `reference/06`, `standard/00 §0.8`, style-guide-check 0 |
| WC-11 | SoT coherence | **PASS** | `core` Rule 2 ↔ `standard/05 §5.3.3` |
| WC-12 | PM / legal / regulator on-ramp | **PASS** | `standard/00 §0.6.4`, `guide/06`, `guide/09 §E3` |
| WC-13 | Adversarial / AI editorial | **PASS** | `guide/07 §3.5`, claims traceable to `standard/09`, `reference/03` |
| WC-14 | Pre-v1 migration guide | **PASS** | `guide/10-migration-v1.md` |
| WC-15 | EN parity inventory | **PASS** | §EN blockers ниже; external review kit — `research/ru-external-review-kit.md` |

## Приоритеты (RU-only)

| P | Область | Статус |
|---|---|---|
| P0 | Schema / closed lists / substrate neutrality | Закрыто |
| P1 | Deliverables (07, 08, 09, 10) | Закрыто |
| P2 | Pedagogical + cross-ref + on-ramp | Закрыто |
| P3 | EN translation | **BLOCKED** до tag epic done |

## EN blocker inventory (WC-15)

Без перевода до закрытия RU epic:

| Asset | RU path | EN planned path |
|---|---|---|
| Standard 15 chapters | `standard/00–14` | `standard/en/` |
| Guide 11 chapters | `guide/00–10` | `guide/en/` |
| Reference 8 appendices | `reference/01–08`, `06` | `reference/en/` |
| Core | `core/renar-core.md` | `core/en/` |
| Site | `site/` RU routes | `/en/` routes |
| PDF | — | `pdf-generate-ru-en` task |

## Связанные tasks (Story A–E)

| Story | Slug | Status |
|---|---|---|
| A | `ru-lang-surface` | done |
| B | `ru-internal-tools-purge` | done |
| C | `ru-remediate-audit-v3`, `ru-repo-hygiene` | deliverables complete |
| D | `ru-world-class-gaps` | этот документ |
| E | `ru-*` artifact tasks | deliverables in repo |

---

*Informative roadmap — renar.tech*
