# Mapping REQ ↔ Compliance Standards

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: показать, как REQ-артефакты закрывают регуляторные требования (ISO 27001, GDPR, ФЗ-152, AI Act EU, NIST AI RMF). Self-assessment checklist для compliance teams. Закрывает gap из [06-multi-perspective-review.md §5](06-multi-perspective-review.md).
>
> Финальная нормативная форма — после ревью с юристом / compliance officer.

---

## 1. Не дублирует SENAR

SENAR не покрывает регуляторное соответствие. SENAR говорит «контекст важнее кода» как принцип; REQ конкретизирует **какая часть контекста закрывает какую регуляторную норму**.

REQ не пытается быть compliance-стандартом сам по себе. REQ предоставляет **инфраструктуру traceability**, которая позволяет другим стандартам (ISO 27001, GDPR, ...) быть выполнимыми.

---

## 2. Принципы compliance в REQ

### 2.1 Compliance — first-class artifact

Каждое требование, имеющее регуляторное обоснование, **обязано** иметь поле `compliance` во frontmatter:

```yaml
compliance:
  - standard: "ISO 27001:2022"
    control: "A.5.34"
    rationale: "Privacy and protection of PII — требование шифрования персональных данных"
  - standard: "GDPR"
    article: "Art.32"
    rationale: "Security of processing"
  - standard: "ФЗ-152"
    article: "ст.19"
    rationale: "Меры по обеспечению безопасности персональных данных"
```

### 2.2 Data classification как обязательное расширение

```yaml
data-classification:
  contains-pii: true                  # GDPR / ФЗ-152 trigger
  contains-financial: false           # PCI DSS trigger
  contains-health: false              # HIPAA trigger (US healthcare)
  contains-children-data: false       # COPPA trigger
  retention-days: 1095                # 3 years
  data-residency: ["RU", "EU"]        # где может физически храниться
```

При `contains-pii: true` — обязательны соответствующие SR (encryption, audit log, deletion на запрос пользователя).

### 2.3 Traceability как audit foundation

REQ traceability `BR → SR → TC → code → CI run` — это и есть audit trail. Аудитор открывает COVERAGE.md, видит:

- Какие требования закрывают конкретный compliance control.
- Какие тесты их верифицируют.
- Когда прошёл последний прогон (`last-run.date`).
- Каким code commit реализованы.

Время аудита: 1-2 дня вместо 2-3 недель.

---

## 3. ISO 27001:2022 — Information Security

### 3.1 Mapping

| ISO 27001:2022 Annex A control | REQ-артефакт |
|---|---|
| A.5.7 Threat intelligence | Threat Surface поле задачи (SENAR §10.1 расширение); REQ: SR с `compliance: A.5.7` |
| A.5.8 Information security in project management | Сам RENAR = process compliance с этим control |
| A.5.34 Privacy and protection of PII | SR с шифрованием + `data-classification.contains-pii: true` |
| A.6.3 Information security awareness | Onboarding process включает чтение RENARа |
| A.8.1 User endpoint devices | Если в scope — SR с device requirements |
| A.8.5 Secure authentication | SR-AUTH-* шаблоны из requirements-library |
| A.8.7 Protection against malware | SR + Threat Surface + adversarial review |
| A.8.10 Information deletion | SR с deletion logic + `data-classification.retention-days` |
| A.8.16 Monitoring activities | SR с logging + audit-log artifacts |
| A.8.24 Use of cryptography | SR с явным crypto algorithm + ISO 25010 Security characteristic |
| A.8.25 Secure development life cycle | SENAR + RENAR как evidence |
| A.12.1.2 Change management (наследие 27001:2013) | `[delta:TZ-XXX]` процесс + Impact Analysis |

### 3.2 Audit deliverable

Для ISO 27001 аудита генерируется отчёт:

```markdown
# ISO 27001:2022 Conformance Report — <project>
Generated: 2026-05-03

## Scope
- BR: 12 (with compliance.iso27001 = N controls)
- SR: 47 (32 with compliance metadata)
- TC: 156 (124 verifying compliance-tagged SR)

## Coverage by Annex A
| Control | Required (per Statement of Applicability) | Mapped SR | Status |
|---|---|---|---|
| A.5.34 | Yes | SR-12, SR-25 | verified ✓ |
| A.8.5 | Yes | SR-01, SR-08 | verified ✓ |
| A.8.10 | Yes | SR-32 | approved (TC pending) ⚠ |

## Last verification runs
[список TC last-run для compliance-tagged]
```

Скрипт: `tausik req compliance-report --standard iso27001 --project <slug>`.

---

## 4. GDPR (Regulation EU 2016/679)

### 4.1 Mapping

| GDPR Article | REQ-артефакт |
|---|---|
| Art.5 Principles | BR должен явно указывать lawful basis |
| Art.6 Lawfulness | BR с `lawful-basis: consent | contract | legal-obligation | ...` |
| Art.7 Conditions for consent | SR с consent management workflow |
| Art.13 Information to data subject | UIC с privacy notice экраном |
| Art.15 Right of access | SR с export-user-data функциональностью |
| Art.16 Right to rectification | SR с edit-user-profile |
| Art.17 Right to erasure (right to be forgotten) | SR с delete-user-data + propagation на linked entities |
| Art.18 Right to restriction | SR с suspend-processing |
| Art.20 Right to data portability | SR с export в machine-readable формате |
| Art.25 Data protection by design and by default | data-classification обязателен на BR-уровне |
| Art.30 Records of processing activities | Auto-generated из BR с `data-classification.contains-pii` |
| Art.32 Security of processing | SR с encryption + access control |
| Art.33 Notification of personal data breach | SR с breach notification workflow + 72h timer |
| Art.35 Data Protection Impact Assessment (DPIA) | Для high-risk processing — отдельный документ `dpia/<feature>.md` |

### 4.2 Frontmatter расширение для GDPR

```yaml
gdpr:
  data-categories:
    - "identification: email, name"
    - "contact: phone, address"
    - "behavioral: usage logs"
  lawful-basis: contract              # Art.6
  retention-period-days: 1095
  cross-border-transfer: false        # если true — обязательны SCCs или adequacy decision
  dpia-required: false                # если true — link на DPIA документ
  data-subject-rights:
    - access                           # Art.15
    - rectification                    # Art.16
    - erasure                          # Art.17
    - portability                      # Art.20
```

### 4.3 DPIA как REQ-артефакт

Для high-risk processing создаётся `<system>.req/dpia/DPIA-NN-<slug>.md`:

```markdown
---
id: DPIA-01
title: "DPIA: AI-генерация документов на основе клиентских данных"
type: DPIA
status: approved
gdpr-article: 35
related-br: [BR-01, BR-03]
risks-identified: 4
mitigations: 7
---

## Описание процесса обработки
## Необходимость и пропорциональность
## Риски для прав и свобод субъектов
## Меры снижения рисков
## Согласование с DPO
```

---

## 5. ФЗ-152 «О персональных данных» (РФ)

### 5.1 Mapping

| ФЗ-152 Статья | REQ-артефакт |
|---|---|
| ст.5 Принципы обработки | BR с явным целевым назначением (поле `business-context.business-goal`) |
| ст.6 Условия обработки | BR с `lawful-basis` |
| ст.9 Согласие на обработку | SR с consent management |
| ст.13.1 Хранение в РФ | `data-classification.data-residency: ["RU"]` для российских клиентов |
| ст.14 Доступ к информации | SR с export-user-data |
| ст.15 Право на уточнение | SR с edit-user-profile |
| ст.16 Удаление | SR с delete-user-data |
| ст.18 Обязанности оператора | Audit trail через REQ traceability |
| ст.18.1 Локализация ПДн граждан РФ | `data-classification.data-residency` обязательно |
| ст.19 Меры защиты | SR с encryption + access control + ISO 25010 Security |
| ст.21 Уведомление о нарушении | SR с breach notification workflow |
| ст.22 Уведомление РКН (если применимо) | (operational, не REQ) |

### 5.2 Особенность: data residency

Для проектов с российскими клиентами `data-residency` **обязательное** поле в `data-classification`. CI hook проверяет:

- Если `data-residency: ["RU"]` — все upstream SR (хранение, бэкапы, репликация) должны иметь evidence хранения в РФ.
- Если требование добавляет хранение в зарубежной юрисдикции для RU-резидентного BR — блок merge.

---

## 6. AI Act (Regulation EU — applicable when EU clients)

### 6.1 Risk classification

AI Act классифицирует AI-системы по риску. REQ должен явно указывать класс:

```yaml
ai-act:
  risk-class: limited                 # prohibited | high | limited | minimal
  rationale: "Generative AI for document drafting, no autonomous decisions affecting users' legal rights"
  high-risk-domain: false             # если true — требуется conformity assessment
  general-purpose-ai: true            # GPAI — Claude / GPT базовая модель
```

### 6.2 High-risk AI requirements (Art.9-15)

Для AI-систем класса `high` (financial scoring, hiring, public services, ...):

| AI Act требование | REQ-артефакт |
|---|---|
| Art.9 Risk management system | AIC + AI risk register (см. [10-ai-risk-register.md](10-ai-risk-register.md)) |
| Art.10 Data and data governance | `eval-datasets/` с provenance + спот-чек |
| Art.11 Technical documentation | AIC + ISO/IEC 5338 conformance |
| Art.12 Record-keeping | tool_event doc-type в Raven; ai-provenance в frontmatter |
| Art.13 Transparency to users | UIC с обозначением AI-обработки |
| Art.14 Human oversight | One-click approval + spot-check |
| Art.15 Accuracy, robustness, cybersecurity | Eval-tests + adversarial review |

---

## 7. NIST AI RMF 1.0 (US clients)

### 7.1 Mapping функций RMF

| NIST AI RMF Function | REQ-механизм |
|---|---|
| **Govern** | RENAR сам + roles из SENAR + compliance frontmatter |
| **Map** | BR с business-context, data-classification, ai-act risk-class |
| **Measure** | Eval-тесты с metric thresholds + REQ-метрики (Hallucination Rate, ACR) |
| **Manage** | Lifecycle с QG + reconciliation hook + AI risk register |

### 7.2 RMF-specific extensions

```yaml
nist-ai-rmf:
  applicable: true
  govern: { role: "AI Governance Lead", policy-link: "..." }
  map:
    use-case-category: "content-generation"
    affected-stakeholders: ["clients", "internal-team"]
  measure:
    metrics-tracked: ["accuracy", "fairness", "robustness"]
    baseline-run-id: "eval-2026-04-01"
  manage:
    risk-tolerance: "low"
    incident-response-plan: "<link>"
```

### 7.3 Когда применять

- Только для проектов с US-юрисдикцией клиентов.
- Опциональное расширение, не required для всех REQ-проектов.

---

## 8. Self-assessment compliance checklist

Для каждого compliance стандарта — короткий yes/no checklist для compliance teams:

### ISO 27001:2022

- [ ] Все BR с `data-classification.contains-pii: true` имеют SR закрывающий A.5.34
- [ ] SoA (Statement of Applicability) задокументирован — какие Annex A controls в scope
- [ ] Каждый in-scope control имеет ≥1 verifying SR
- [ ] COVERAGE.md показывает зелёные TC для всех compliance-tagged SR
- [ ] Auditor может пройти от Annex A control до passing TC за < 5 минут

### GDPR

- [ ] Все обработки PII задокументированы в Records of Processing (auto-generated)
- [ ] Lawful basis указан для каждой обработки
- [ ] Data subject rights (Art.15-22) имеют верифицированные SR
- [ ] DPIA выполнен для high-risk processing
- [ ] Cross-border transfers обоснованы (SCCs или adequacy)

### ФЗ-152

- [ ] Все требования с PII граждан РФ имеют `data-residency: ["RU"]`
- [ ] CI hook проверяет, что upstream SR хранения находятся в РФ
- [ ] Согласие на обработку реализовано в SR
- [ ] Меры защиты (ст.19) покрыты SR с верифицированными TC

### AI Act EU

- [ ] AIC имеет `ai-act.risk-class`
- [ ] Для `high` — выполнено всё из Art.9-15
- [ ] Human oversight встроен (QG-0 / QG-2 + spot-check)
- [ ] Technical documentation генерируется (AIC + traceability)

---

## 9. Compliance-friendly artifacts

REQ предлагает auto-generated artifacts для compliance:

| Artifact | Команда | Содержание |
|---|---|---|
| Records of Processing (GDPR Art.30) | `tausik req gdpr-records` | Все BR/SR с PII, lawful basis, retention |
| Statement of Applicability (ISO 27001) | `tausik req iso-soa` | Какие Annex A controls in/out of scope, justification |
| Data Inventory | `tausik req data-inventory` | Все data-classifications, residency, retention |
| AI System Cards | `tausik req ai-cards` | Для каждого AIC — карточка по NIST AI RMF / AI Act format |
| Audit trail report | `tausik req audit-trail --standard X --period Y` | Traceability для аудитора |

Все генерируются from existing REQ data — без дополнительной ручной работы.

---

## 10. Что REQ НЕ покрывает в compliance

REQ — это инфраструктура для compliance, но не **substitute** для:

- DPO (Data Protection Officer) — человеческая роль.
- Legal review договоров.
- Pen-testing security implementation.
- Bug bounty / vulnerability management.
- Physical security.
- Operational security (key rotation, incident response).
- Insurance / cyber insurance.
- Regulatory filings (РКН уведомления, GDPR registration).

REQ помогает делать compliance **в процессе разработки**. Operational compliance — отдельные процессы.

---

## 11. Open questions

- [ ] Compliance frontmatter — обязательный или optional? Compromise: optional, но если есть `data-classification.contains-pii: true` → обязательным становится compliance с GDPR/152.
- [ ] DPIA как REQ-артефакт vs внешний документ? Mixed: формальный DPIA = внешний (юристы), но `dpia/<slug>.md` ссылается на него и трассируется в REQ.
- [ ] Data residency: как enforced на уровне инфры? Кросс-чек CI на deployment configs (terraform / ansible / k8s manifests). Это уже DevOps зона.
- [ ] Custom compliance frameworks (отраслевые, например, ЦБ РФ для финтех) — добавлять в этот документ или в отдельный?
- [ ] Третейские сертификации (Schrems II adequacy для EU↔RF transfers): можно ли через REQ автоматически генерировать evidence? Скорее — частично.
