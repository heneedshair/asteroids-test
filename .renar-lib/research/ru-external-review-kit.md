---
title: "RU external review kit"
status: informative
lang: ru
version: "1.0-draft"
frozen: false
---

# External review kit — RENAR RU v1.0-draft

> **Informative.** Процедура независимой экспертизы перед tag v1.0 или стартом EN. Не нормативный документ.

## Цель

Получить **tracked feedback** перед tag v1.0 или стартом EN. **Default (2026-05):** [agent adversarial review](ru-agent-adversarial-review.md) — три AI-persona без human panel. Human kit ниже — опционально.

## Состав panel (минимум 3, optional human)

| Роль | Фокус | Deliverable reviewer |
|---|---|---|
| **RE architect** | Нормативная согласованность §06–§10, closed lists, QG logic | `standard/06–10`, `reference/02` |
| **Legal / compliance** | Traceability, GDPR/ФЗ-152 evidence path | `guide/06`, `guide/09 §E3`, `reference/07–08` |
| **Industry skeptic** | Применимость, misuse, «можно ли заявить conformance ложно» | `standard/01`, `14`, `guide/07`, `guide/10` |

Опционально: **QA lead** — TC pos/neg, adversarial §guide/07.

## Rubric (severity)

| Severity | Критерий | Пример |
|---|---|---|
| **blocker** | Нормативное противоречие или ложный conformance path | MVR-7 выполним без QG-2 |
| **major** | Пропуск mandatory clause в examples / schema drift | `type: system` в guide example |
| **minor** | Editorial, anchor, pedagogical gap | Hotspot без signpost |
| **nit** | Стиль, typo | Bucket-A casing |

## Cadence (2 недели)

1. **Day 0** — brief + read order ([standard/00 §0.6.4](../standard/00-introduction.md#064-маршруты-читателей))
2. **Day 1–7** — async read; issues в GitLab (`/renar-external-review` template)
3. **Day 8** — sync call 60 min: blockers only
4. **Day 9–14** — authoring team triage; fix blockers + majors в corpus

## Read order (reviewer)

1. [core/renar-core.md](../core/renar-core.md)
2. [standard/00](../standard/00-introduction.md) → [01](../standard/01-scope.md) → [14](../standard/14-conformance.md)
3. Role branch: PM/legal → [guide/09](../guide/09-worked-examples.md); architect → [guide/00](../guide/00-quickstart.md)
4. [reference/08](../reference/08-conformance-self-assessment.md) — self-check

## Exit criteria (epic ru-v1-hardening)

- 0 open **blocker** issues
- Majors — fixed или accepted with rationale in issue
- Decision recorded in TAUSIK: `decide "External review RU v1.0-draft signed off"`

## Связанные артефакты

- Issue template: `.gitlab/issue_templates/renar-external-review.md`
- Validators: `scripts/validate-schema-examples.js`, `scripts/check-md-links.js`, `scripts/check-site-parity.js`

---

*Informative — renar.tech*
