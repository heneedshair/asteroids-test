---
title: "Библиотека примеров"
description: "Индекс E2E примеров RENAR: quickstart, login, GDPR export, API webhook, SPEC-AI eval, delta-ТЗ."
order: 9
lang: ru
version: "1.0-draft"
---

# 09. Библиотека примеров

> Шесть сценариев (E1–E6): три полных цикла in-doc (E3–E6) + два walkthrough (E1–E2). Каждый in-doc пример: **ТЗ → ADAPT → BR/SR → SPEC → TC → QG**.

| # | Сценарий | Документ | Аудитория | Акцент |
|---|---|---|---|---|
| E1 | Email/password sign-up (минимальный) | [00-quickstart](00-quickstart.md) | Новичок | 30 мин, минимум артефактов |
| E2 | Login + profile + permissions (полный) | [01-walkthrough](01-walkthrough.md) | Tech Lead, QA | Полный lifecycle, AI-генерация TC |
| E3 | Экспорт персональных данных (GDPR / ФЗ-152) | [§14](#2-e3--экспорт-персональных-данных-gdpr-art-15--фз-152) | Legal, PM, Architect | Compliance, SPEC-DATA/SEC |
| E4 | Webhook idempotency (REST API) | [§4](#3-e4--webhook-idempotency-spec-api) | Backend, Architect | `tc-type: contract`, SPEC-API |
| E5 | RAG-ассистент (SPEC-AI eval) | [§5](#4-e5--rag-assistant-spec-ai) | AI engineer | `tc-type: eval`, judge isolation |
| E6 | Delta-ТЗ: scope dispute | [§5](#5-e6--delta-тз-scope-dispute) | PM, Client, Architect | ADAPT backward, неизменяемое ТЗ |

---

## 2. E3 — Экспорт персональных данных (GDPR Art. 15 / ФЗ-152)

**Контекст:** SaaS «AcmeCRM» хранит PII клиентов. Регулятор и договор обязывают выдать машиночитаемый экспорт по запросу субъекта данных за ≤30 дней.

### 2.1 Фрагмент ТЗ (immutable)

```markdown
# TZ-2026-002 — Data subject export

§3.1 Субъект данных может запросить полный экспорт своих PII через UI «Privacy → Export my data».
§4.2 Формат: JSON + CSV bundle, zip, checksum SHA-256.
§4.3 SLA: готовность ссылки на скачивание ≤ 72 часа с момента verified identity.
§4.4 Экспорт включает: profile, activity log 24 мес., marketing consents.
§4.5 Запрос логируется; повторный экспорт — не чаще 1 раза в 30 дней без переопределения администратором.
```

### 2.2 ADAPT (сокращённо)

```yaml
id: ADAPT-002
type: ADAPT
status: approved
source-tz: { id: TZ-2026-002, signed-date: "2026-05-01" }
```

**Forward §3:** экспорт асинхронный (job queue); identity — через существующий MFA flow.

**Backward (resolved):**

| # | Finding | Resolution |
|---|---|---|
| B-01 | «24 мес. activity» — calendar или rolling? | Rolling 730 days |
| B-02 | Override admin — кто approves? | Role `privacy-officer` + журнал аудита |

### 2.3 BR + SR

```yaml
# br/BR-02-data-subject-export.md
id: BR-02
type: BR
title: "Субъект данных получает машиночитаемый экспорт PII"
status: approved
source: { adapt: ADAPT-002, adapt-section: "Forward §3" }
compliance:
  - { standard: GDPR, control: "Art. 15" }
  - { standard: "ФЗ-152", control: "ст.14" }
```

```yaml
# sr/SR-08-export-request.md
id: SR-08
type: SR
parent: { id: BR-02 }
title: "Authenticated user инициирует export job"
status: approved
constrained-by: ["SPEC-API-04", "SPEC-DATA-02", "SPEC-SEC-03"]
```

```yaml
# sr/SR-09-export-delivery.md
id: SR-09
type: SR
parent: { id: BR-02 }
title: "User скачивает готовый bundle по time-limited signed URL"
status: approved
constrained-by: ["SPEC-API-04", "SPEC-SEC-03"]
```

### 2.4 SPEC (выдержки)

**SPEC-DATA-02** — schema export bundle (tables: `users`, `activity_events`, `marketing_consents`).

**SPEC-SEC-03** — signed URL TTL 24h; rate limit 1 export / 30 days; role `privacy-officer` для override.

**SPEC-API-04** — `POST /v1/privacy/export`, `GET /v1/privacy/export/{job_id}`.

### 2.5 TC (pos/neg для SR-08)

```yaml
---
id: TC-080
title: "Export job создаётся для verified user"
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
title: "Export отклонён без MFA-verified session"
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
- 403; job не создан; security audit event
```

Аналогичные пары для SR-09 (signed URL valid / expired).

### 2.6 Контрольные точки качества

| Контрольная точка | Доказательства |
|---|---|
| **QG-ADAPT-approve** (по смыслу около «архитектурной точки»: `QG-3`) | ADAPT-002 в `approved`, замечания backward закрыты |
| **QG-2 Verification Gate** | `TC-080`…`081` успешны; в `last-run` совпадает `requirement-version` (`1.0`) |

### 2.7 Что дальше

- Полный сценарий под `git` — [03-tool-guide-git](03-tool-guide-git.md)
- Compliance mapping — [06-compliance](06-compliance.md)
- Conformance manifest — [reference/08](../reference/08-conformance-self-assessment.md)

---

## 3. E4 — Webhook idempotency (SPEC-API)

**Контекст:** платёжный провайдер шлёт `POST /webhooks/payment` с `Idempotency-Key`. Дубликаты не должны создавать двойное списание.

**ТЗ (фрагмент):** «Повторный webhook с тем же key в течение 24h возвращает тот же `payment_id`, HTTP 200».

**SR + SPEC:**

```yaml
id: SR-20
type: SR
constrained-by: ["SPEC-API-07"]
```

**SPEC-API-07** — контракт: headers, body schema, response codes 200/400/409.

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

Neg: второй key с другим body → 409 Conflict.

**Контрольная точка `QG-2`:** оба `TC` успешны; в `last-run` совпадает `requirement-version` (`1.0`).

---

## 4. E5 — RAG assistant (SPEC-AI)

**Контекст:** in-app чат отвечает по knowledge base; eval против golden Q&A set.

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

Neg eval: prompt injection в user message → refusal + audit event (`tc-type: eval`, adversarial negative).

См. [standard/09 §9.6.2](../standard/09-test-cases.md#962-tc-type-eval--eval-тесты-на-основе-spec-ai), [guide/07 §4.5](07-failure-modes.md#35-adversarial-review-процедура).

---

## 5. E6 — Delta-ТЗ: scope dispute

**Контекст:** после signed TZ клиент просит «добавить экспорт в PDF» — вне scope ADAPT-002.

**Правильный путь к источнику истины (SoT):**

1. **Не** править неизменяемое ТЗ и **не** молча расширять SR.
2. Оформить **delta-ТЗ** → новый ADAPT-002b (forward + backward).
3. Backward finding: «PDF export не входил в Forward §3 ADAPT-002».
4. Клиент подписывает delta-ADAPT → новые SR/SPEC/TC.

**Anti-pattern:** direct commit в `sr/SR-08` без `delta-ref` — drift class 4.11.6 ([standard/04 §4.11](../standard/04-terms.md#411-drift-классы-closed-list)).

См. [standard/07 §7.6](../standard/07-adapt.md), [guide/02-transition-guide](02-transition-guide.md).

---

## 6. E7 — Подсистема как самостоятельный продукт (`implements`-edge)

**Контекст:** платформа `acme` (система) состоит из подсистемы `acme.notify` — отдельный продукт с собственным бизнес-владельцем (Notify Lead), отдельной командой, отдельным releases-циклом. Сценарий §6.8.2 RENAR Standard.

### 6.1 Иерархия артефактов

```text
acme (система)
├── BR-01 (приём заказов с AI-консультацией)            level: system
├── BR-05 (мониторинг и алерты для операционной службы)  level: system
└── acme.notify (подсистема, самостоятельный продукт)
    └── BR-01 (доставка уведомлений по multichannel)    level: subsystem
         implements:
           - id: BR-01      (раскрывает «приём заказов»: уведомления при изменениях статуса)
             scope: { system: acme }
           - id: BR-05      (раскрывает «мониторинг»: уведомления о SLA-нарушениях)
             scope: { system: acme }
         ↓
         SR-01..SR-12 (notify-внутренние требования)
         SPEC-INT-01 (интеграция с acme через message bus)
         SPEC-API-01 (REST API для notify-клиентов)
```

`acme.notify.BR-01` — корневой узел своего дерева требований (`parent` отсутствует, как и у любого BR). Связь с системой выражена **типизированным** ребром `implements[]`, не parent-edge.

### 6.2 frontmatter `acme.notify/br/BR-01-multichannel-delivery.md` (фрагмент)

```yaml
---
id: BR-01
title: "Доставка уведомлений по multichannel"
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
  tz-section: "ТЗ-NOTIFY §3"

# === implements-edge §6.8.2 ===
implements:
  - id: BR-01
    scope:
      system: acme
    rationale: "ADAPT-NOTIFY-001 §2.1 — уведомления при изменении статуса заказа"
  - id: BR-05
    scope:
      system: acme
    rationale: "ADAPT-NOTIFY-001 §2.4 — алерты SLA для operations"

business-context:
  stakeholder: "Notify Lead"
  business-goal: "Своевременная доставка уведомлений end-customer и operations team"
---

# BR-01: Доставка уведомлений по multichannel

Notify-подсистема доставляет уведомления …
```

### 6.3 Машиночитаемая trace chain

```text
TC-NOTIFY-15
  → verifies SR-NOTIFY-08 (rate-limit для email канала)
        ├─ parent:   acme.notify.BR-01 v1.2
        │              └─ implements: acme.BR-01 v3.0, acme.BR-05 v1.4
        │                              (типизированное межуровневое ребро)
        ├─ source.adapt: ADAPT-NOTIFY-001 §Forward §2.2
        └─ constrained-by: SPEC-NOTIFY-API-01, SPEC-NOTIFY-OPS-01
```

При аудите от TC-NOTIFY-15 восстанавливается полная цепочка: SR → BR подсистемы → BR системы. До v1.0 (без `implements`-edge) цепочка обрывалась на `acme.notify.BR-01` и продолжалась только через текст раздела «Контекст».

### 6.4 Гейты на стороне носителя

При попытке approve `acme.notify.BR-01` нативный для носителя hook проверяет (см. [standard/10 §10.11.1](../standard/10-lifecycle-qg.md#10.11.1)):

1. `acme.BR-01` и `acme.BR-05` существуют в носителе по `id + scope.system`.
2. Оба target BR — в статусе `approved` (или `verified`).
3. Цепочка `acme.notify.BR-01 → acme.BR-01 → …` не образует цикла.
4. `acme.notify.BR-01.level = subsystem` (правило: `implements[]` не применяется на `level: system`).

Если любая проверка проваливается — approve блокируется. Поведение при `acme.BR-01 = deprecated`: warning, не fatal (Architect решает: обновить implements на актуальный BR или отметить `acme.notify.BR-01` как требующий пересмотра).

### 6.5 Эволюция «модуль → подсистема» через `implements`

Когда модуль приобретает бизнес-владельца ([standard/06 §6.9.1](../standard/06-requirements-hierarchy.md#6.9.1)):

1. Бизнес-владелец фиксируется через backward finding ADAPT (категория `scope`).
2. После approved delta-ADAPT — модуль повышается до подсистемы; создаётся BR подсистемы.
3. **Новый шаг (v1.0+):** BR подсистемы декларирует `implements[]` на applicable BR системы. Без этого шага сценарий §6.8.2 несёт несовместимое с v1.1 conformance отсутствие traceability.

Anti-pattern: создать `acme.notify.BR-01` с `level: subsystem`, но без `implements[]` — формально допустимо на v1.0 (recommended), но non-conformant на v1.1+. Если родительская система имеет approved BR, отсутствие `implements[]` обязано быть **явно обосновано** в разделе «Контекст» BR со ссылкой на ADAPT§.

См. [standard/06 §6.5.2](../standard/06-requirements-hierarchy.md#6.5.2), [§6.8.2](../standard/06-requirements-hierarchy.md#6.8.2), [§6.10.3](../standard/06-requirements-hierarchy.md#6.10.3), [standard/13 §13.3.8](../standard/13-conformance.md#13.3.8).

---

*Guide RENAR 1.0-draft — renar.tech*
