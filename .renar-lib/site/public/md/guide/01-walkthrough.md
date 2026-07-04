---
title: "Сквозной пример"
description: "Полноразмерный сквозной пример RENAR на проекте Login Flow для AcmeCorp."
order: 1
lang: ru
version: "1.0-draft"
---

# 01. Сквозной пример: Login Flow для AcmeCorp

> Один полный цикл RENAR от подписанного ТЗ до accepted release. Пример — внутренний инструмент с регистрацией через корпоративный email и 2FA. Цель — показать **все этапы** на одном среднем по размеру проекте.
>
> **Контекст:** AcmeCorp, ~1 спринт работы команды, стек Next.js + FastAPI + PostgreSQL. RENAR-зрелость уровня RENAR-3+ (полный ADAPT + TC + adversarial). Пример **независим от вида хранилища**: операции через capabilities V1–V6; конкретная раскладка каталогов — [03-tool-guide-git](03-tool-guide-git.md) или [04-document-store-substrate](04-document-store-substrate.md).
>
> **Предпосылки:** [00-quickstart](00-quickstart.md), [core/renar-core](../core/renar-core.md), [reference/01-glossary](../reference/01-glossary.md).

**Маршрут читателя.** Фазы 0–2 — сбор контекста, подписание ТЗ, ADAPT. Фазы 3–4 — декомпозиция в BR/SR/SPEC и генерация пар pos/neg для TC. Фаза 5 — канонические шлюзы QG-0 (утверждение требований) и QG-1 (только переход TC `draft → ready`). Фазы 6–7 — реализация TR и верификация (QG-2). Фазы 8–9 — дельта-ТЗ при изменениях и приёмочный контур QG-4.

---

## Фаза 0 — Сбор требований (elicitation)

До подписания ТЗ. AI-агент проводит 2-3 интервью со stakeholder (Sales Director, IT Manager) и собирает контекст в структурированном виде.

Артефакты фазы 0 (справочные, не нормативные для RENAR Core): `elicitation/{domain-context.md, sales-director.yaml, it-manager.yaml, findings-clustered.md, critic-review.md, multi-model-diff.md}`. Фаза 0 не закреплена в Core — область методологии elicitation, вне scope RENAR v1.0 ([standard/01 §1.3](../standard/01-scope.md#1.3)).

---

## Фаза 1 — Импорт ТЗ

После итераций elicitation клиент подписывает `TZ-2026-042`:

```markdown
# TZ-2026-042 — Login Flow для AcmeCorp Internal Tool
Дата подписания: 2026-05-03 · Стороны: AcmeCorp + VendorCorp

## §1. Цели
Сократить время входа сотрудников AcmeCorp в инструмент до <2 минут от первого захода до полного доступа.

## §2. Функциональные требования
### ФТ-001. Регистрация по корпоративному email
Сотрудник регистрируется через email из домена @acmecorp.com. Email вне домена — отказ с пояснением.

### ФТ-002. Двухфакторная аутентификация (TOTP)
После регистрации обязательная настройка 2FA через TOTP.

### ФТ-003. Восстановление доступа через корпоративного администратора
При потере 2FA устройства — recovery через ticket в IT support.

## §3. Нефункциональные требования
### НФТ-001. Производительность: Login <2 секунд (p95).
### НФТ-002. Безопасность: bcrypt cost-factor ≥ 12; логи входов — 1 год; блокировка после 5 неудачных попыток за 15 минут.
### НФТ-003. Юрисдикция: все данные в РФ (гос-контракты).
```

ТЗ подписан → **неизменяемо**. Любые правки идут через ADAPT (фаза 2) или delta-TZ (фаза 8). Runtime **обязан** зарегистрировать неизменяемое ТЗ как ревизию (V1+V2) с AI-provenance (V6).

---

## Фаза 2 — ADAPT (двусторонняя интерпретация)

**2.1 Primary agent генерирует draft ADAPT.** Input: TZ-2026-042 (неизменяемо). Output: draft ADAPT-001 + Forward sections (по §2 ФТ + §3 НФТ) + Backward findings (6 candidates) + V6 provenance.

**2.2 Adversarial review.** Отдельный critic-agent (другая модель) проверяет backward findings; блокирует adapt-approve пока критические находки открыты. Примеры:

```text
[HIGH] B-001 reclassify gap → hidden-assumption
[HIGH] missed backward: case-sensitivity email in ФТ-001
[MEDIUM] B-004 terminology: define "сотрудник" via User.role
[MEDIUM] B-006 feasibility: rate-limit scope (IP vs email vs session)
```

**2.3 Iterative resolution.** Архитектор корректирует Forward и Backward, AI re-генерирует. После 2 циклов adversarial: 7 backward записей (B-001..B-007), все resolved или reclassified; Forward охватывает §2 + §3 ТЗ полностью.

**2.4 ADAPT в статусе `approved`:**

```yaml
---
id: ADAPT-001
title: "Адаптация TZ-2026-042 — Login Flow AcmeCorp"
type: ADAPT
source-tz: { id: TZ-2026-042, signed-date: "2026-05-03", signed-by-client: "AcmeCorp PM" }
status: approved
approval:
  client-signature: { signed-by: "Иванова А.А.", role: "Product Lead", organization: "AcmeCorp", signed-at: "2026-05-04T11:30:00Z" }
  architect-signature: { signed-by: "Петров П.П.", role: architect, signed-at: "2026-05-04T12:00:00Z" }
generates-requirements: [BR-01, BR-02, SR-01, SR-02, SR-03, SR-04, SR-05, SR-06, SR-07]
generates-specs: [SPEC-UI-01, SPEC-API-01, SPEC-DATA-01, SPEC-SEC-01]
open-questions-count: 0
resolved-questions-count: 7
ai-provenance: { generated-by: "anthropic-claude-opus-4-7@2026-05-04", prompt-template: "prompts/adapt-from-tz.md@v2.1", human-edits: true }
---
```

После утверждения ADAPT-001 — **неизменяем**.

---

## Фаза 3 — Декомпозиция в BR / SR / SPEC

**3.1 Декомпозиция.** Operation: `decompose`. Input: approved ADAPT-001. Output: draft BR (2), SR (7), SPEC (4) + adversarial-review артефактов.

**3.2 Adversarial-находки:**

```text
[HIGH] BR-01 stakeholder поле пустое — кто owner business goal?
[HIGH] SR-05 говорит "bcrypt cost-factor 12" — это deployment detail, должно быть в SPEC-SEC-01, не в SR.
[MEDIUM] НФТ-003 (юрисдикция) не отражено в data-classification SR-01.
[MEDIUM] SPEC-UI-01 не имеет accessibility-level — WCAG-AA минимум для корпоративного инструмента.
→ 4 находки → fix → re-generate.
```

**3.3 Финальный набор артефактов:**

```text
acmecorp-requirements/
├── br/
│   ├── BR-01-self-service-registration.md
│   └── BR-02-secure-mfa.md
├── sr/
│   ├── SR-01-email-domain-validation.md       (ФТ-001)
│   ├── SR-02-totp-enrollment.md               (ФТ-002 setup)
│   ├── SR-03-totp-verification.md             (ФТ-002 verify)
│   ├── SR-04-password-recovery-via-admin.md   (ФТ-003)
│   ├── SR-05-rate-limiting-failed-logins.md   (НФТ-002)
│   ├── SR-06-audit-logging.md                 (НФТ-002 audit)
│   └── SR-07-data-residency-ru.md             (НФТ-003)
├── specs/
│   ├── ui/SPEC-UI-01-login-flow.md
│   ├── api/SPEC-API-01-auth.md
│   ├── data/SPEC-DATA-01-user-model.md
│   └── sec/SPEC-SEC-01-auth-policy.md
└── tz/TZ-2026-042.md
```

**3.4 Пример: SR-01 (frontmatter + body):**

```yaml
---
id: SR-01
title: "Валидация домена email при регистрации"
type: SR
status: approved
parent: { id: BR-01 }
source: { adapt: "ADAPT-001", adapt-section: "Forward §2.1", tz-section: "§2 ФТ-001" }
constrained-by: ["SPEC-API-01", "SPEC-DATA-01", "SPEC-SEC-01"]
data-classification: { contains-pii: true, data-residency: ["RU"], retention-days: 365 }
compliance: [{ standard: "ФЗ-152", article: "ст.13.1" }]
ai-provenance: { generated-by: "anthropic-claude-opus-4-7@2026-05-04", prompt-template: "prompts/decompose-adapt.md@v2.1", context-tokens: 12450, output-tokens: 320, human-edits: true }
---

## Описание
Регистрация разрешена только если email принадлежит домену `@acmecorp.com`. Остальные домены отклоняются с пояснением.

## Поведение
- email НЕ из `@acmecorp.com` → 422 с `{"error":"email-domain-not-allowed", "allowed-domain":"acmecorp.com"}`. [ADAPT-001 §14.1 Forward; TZ-2026-042 §2 ФТ-001]
- email из `@acmecorp.com` → стандартная регистрация (SPEC-API-01).
- Whitelist хранится в `SPEC-SEC-01.allowed-domains`, расширяется без релиза.
- Сравнение домена — case-insensitive (ADAPT-001 §14.1 Forward).

## Ограничения
- `*.acmecorp.com` subdomain — отдельное решение архитектора (не входит).
```

**3.5 SPEC-API-01 (фрагмент):**

```yaml
---
id: SPEC-API-01
title: "REST API аутентификации"
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

### POST /auth/totp-setup — см. SR-02.

## Error model
Единая структура: `{"error": "<code>", "details": {...}}`.
```

---

## Фаза 4 — Генерация TC (пары pos/neg)

Operation: `tc-generate` SR-01 → pos/neg TC pairs per testable assertion (Правило 4 RENAR Core: для каждого assertion в SR — 1 pos + 1 neg TC).

**TC-001 (позитивный):**

```yaml
---
id: TC-001
title: "Регистрация с разрешённым доменом — happy path"
type: TC
tc-type: system
status: ready
verifies: [{ id: SR-01, requirement-version: "1.0" }]
negative: false
automation: { status: automated, location: "tests/auth/test_registration.py::test_allowed_domain_succeeds", runner: pytest }
---

## Given
- БД пуста; email alice@acmecorp.com не зарегистрирован.

## When
POST /auth/register {email: "alice@acmecorp.com", password: "ValidPass123!"}

## Then (Pass)
- status 201; body содержит {"user_id": "<uuid>", "verified": false, "totp_setup": false}; User в БД создан; verification email отправлен (mock SES).

## Fail criteria
- status ≠ 201; plaintext password в body/логах; User с другим email (case mismatch); email верификации не отправлен.

## Not in scope
- TOTP setup → TC-005 (SR-02); rate limiting → TC-009 (SR-05).
```

**TC-004 (негативный):**

```yaml
---
id: TC-004
title: "Регистрация с неразрешённым доменом — отказ с пояснением"
type: TC
tc-type: system
status: ready
verifies: [{ id: SR-01, requirement-version: "1.0" }]
negative: true
automation: { status: automated, location: "tests/auth/test_registration.py::test_disallowed_domain_rejected", runner: pytest }
---

## Given
- email "bob@gmail.com" (вне whitelist).

## When
POST /auth/register {email: "bob@gmail.com", password: "ValidPass123!"}

## Then (Pass)
- status 422; body == {"error": "email-domain-not-allowed", "allowed-domain": "acmecorp.com"}; User в БД НЕ создан; email НЕ отправлен; audit-запись о rejected attempt (для SR-06).

## Fail criteria
- status ≠ 422; User создан; email отправлен (security leak); audit-запись отсутствует.
```

---

## Фаза 5 — Шлюзы качества перед кодом (QG-0 и QG-1)

После генерации TC для всех 7 SR — суммарно 26 записей контрольных примеров (пары pos/neg + дополнительные негативы для SR-05, SR-06).

**5.1 QG-0 — утверждение BR-01 (`draft → approved`).** Предусловия: `source.adapt = ADAPT-001 (approved)`; дерево SR в допустимом состоянии перед утверждением BR; adversarial-review успешен; утверждения и связи cite разделы ADAPT-001. Постусловие: BR-01 + дочерние SR при необходимости каскад `draft → approved`.

**5.2 QG-1 — только TC: `draft → ready`.** По [§10.3.2](../standard/10-lifecycle-qg.md#1032-qg-1--гейт-реализации-проверки-только-tc) QG-1 применим только к TC и отделяет подготовленный контрольный пример с исполнимой реализацией проверки от черновика. Предусловия для TC: зафиксирован version-pin реализации (V5); `automation.status` + `location` валидны; статические проверки пройдены; pos/neg парность ([§9.7](../standard/09-test-cases.md#9.7)); обязательные секции body заполнены. Постусловие: `draft → ready`.

После **QG-0** на BR/SR и **QG-1** на каждом TC можно открывать работу по TR (фаза 6).

---

## Фаза 6 — Реализация

**6.1 Создание задач (TR).** Operation `sync-tasks`: input — verified SR/SPEC set; output — 7 TR in implementation tracker (parent SR, implements-spec[], QG-0 ready с Goal + AC).

**6.2 Разработчик берёт TR-101.** QG-0 checks: Goal from SR-01; AC list (4 items); parent.id resolves (approved); implements-spec present; negative scenario in AC → work session allowed.

**6.3 Реализация (фрагмент):**

```python
# acmecorp-login.src/src/auth/registration.py
from fastapi import HTTPException
from config import settings   # allowed-domains из SPEC-SEC-01

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

**6.4 Хук валидации на стороне носителя:**

```text
[hook] Проверка связей TR-101: parent.id SR-01 (approved); implements-spec [SPEC-API-01, SPEC-SEC-01].
[hook] Негативные TC: SR-01.verified-by включает TC-002, TC-004 (negative).
✓ Изменение разрешено.
```

---

## Фаза 7 — QG-2 (шлюз верификации)

**7.1 CI запускает TC.** `pytest acmecorp-login.src/tests/auth/test_registration.py` → 4 TC PASSED → Bot обновляет `last-run.result = pass`, `requirement-version = 1.0` в TC файлах.

**7.2 Выборочная проверка (Правило 5 Core).** Раз в спринт инженер вручную запускает 5 случайных passing TC и сверяет фактический результат с SR. Selected: TC-001, TC-008, TC-012, TC-019, TC-024 → 5/5 совпадают.

**7.3 Promote SR-01 → verified.** QG-2 предусловия: approved ADAPT linkage; pos/neg TC passing; `last-run.requirement-version` зафиксирован; выборочная проверка пройдена. Постусловие: SR-01 `approved → verified`; обновляется индекс покрытия.

---

## Фаза 8 — Дельта-ТЗ

**8.1 Клиент через неделю:**

```markdown
# TZ-2026-051 — Дополнение к TZ-2026-042
Базовый: TZ-2026-042

## §2 (изменение) ФТ-001 (расширение)
Дополнительно разрешить @subsidiary.acmecorp.com (дочерняя компания). Whitelist расширяется до 2 доменов.
```

**8.2 Delta-ADAPT.** Operation `adapt-from-tz (delta)`: input — TZ-2026-051 + parent ADAPT-001; output — draft ADAPT-001-delta-1 + delta Forward + backward findings (e.g. B-008 scope). После 1 итерации с клиентом → approved.

**8.3 Анализ влияния.** Operation `impact-analysis --delta TZ-2026-051`:

```text
Affected:
  BR-01 (расширение охвата)
  SR-01: verified → approved (TC rerun required)
  TC-001..004: re-pin 1.0 → 1.1; +2 new TC (subsidiary domain)
  TR-115: new implementation task
  SPEC-SEC-01: allowed-domains extended
```

**8.4 Apply delta.** Архитектор открывает изменения с маркером `[delta:TZ-2026-051]`. AI обновляет SR-01 (расширяет whitelist), генерирует 2 новых TC. Реализация в TR-115. CI прогоняет TC, бот обновляет last-run. После spot-check — SR-01 v1.1 → verified снова.

> **Note (simple delta).** Если adversarial reviewer выносит вердикт «no findings, no clarifications» ([§7.4.1.2](../standard/07-adapt.md#7.4.1)), **delta-ADAPT не создаётся** — BR/SR/SPEC получают `source.tz-section` напрямую с зафиксированным `adversarial-review-ref`. Снимает overhead двойной подписи для тривиальных изменений (e.g., переименование поля).

---

## Фаза 9 — QG-4 (приёмка)

**9.1 Через 4 недели после release.** Window: 4 weeks post-release.

```text
BR-01 KPI: Time-to-first-login — target <2min P95, actual 1.4min (143%)
BR-02 KPI: 2FA adoption — target ≥95%, actual 97%
```

**9.2 QG-4 report + adversarial.** AI генерирует acceptance report. Adversarial critic находит: «recovery через admin не покрыт TC, верифицирующим full flow с tickets». Архитектор соглашается → создаёт mini-delta для добавления acceptance TC.

**9.3 Sign-off.** После закрытия находок клиент подписывает acceptance. BR → status `accepted`. Архив отчёта: `QG-4-REPORT-v1.0.md` + lessons learned `lessons/2026-Q2.md`.

---

## Финальные артефакты

```text
acmecorp-requirements/
├── adapt/                 ADAPT-001-main.md (frozen) + ADAPT-001-delta-1.md (frozen)
├── br/                    BR-01 + BR-02 (status: accepted)
├── sr/                    SR-01 (v1.1, verified) + SR-02..SR-07 (v1.0, verified)
├── specs/                 SPEC-UI-01 + SPEC-API-01 + SPEC-DATA-01 + SPEC-SEC-01 (verified; SPEC-SEC-01 v1.1)
├── tests/                 TC-001..TC-028 (28 TC, 100% passing)
├── tz/                    TZ-2026-042.md + TZ-2026-051.md (delta, immutable)
├── elicitation/           # артефакты фазы 0
├── lessons/2026-Q2.md     # уроки фазы 9
└── QG-4-REPORT-v1.0.md    # acceptance report
```

---

## Метрики проекта

| Метрика | Значение |
|---|---|
| RDLT (TZ signed → all SR verified) | 11 days |
| Coverage Velocity | 100% за 2 спринта |
| Hallucination Rate (детектированных) | 0% |
| Найдено adversarial-находок (цикл 1) | 4 high + 2 medium |
| Test-spec drift на delta-ТЗ | 0% |
| Acceptance disputes | 0 (1 finding, resolved before sign-off) |
| Cost per BR | $0.46 (gen) + $0.18 (critic) = $0.64 |
| Total AI cost | ~$8.50 |
| BRs accepted | 2/2 |
| Дней до accept | 35 |

---

## Что показывает этот пример

1. **Прозрачность** — каждый артефакт имеет provenance, каждый переход — шлюз с явными условиями.
2. **Скорость** — декомпозиция approved ADAPT — десятки секунд + 2 цикла adversarial.
3. **Трассировка** — от строки в ТЗ до passing TC за несколько операций запроса к носителю.
4. **Дельта-ТЗ** — затронутые SR/SPEC/TC/TR вычисляются автоматически.
5. **Замыкание контура** — QG-4 связывает результат с бизнес-метриками (KPI achievement).
6. **AI-нативность** — критик и генератор — разные модели (изоляция); выборочная проверка находит расхождения, которые может пропустить только автоматический прогон.

---

## Что дальше

- [02-transition-guide.md](02-transition-guide.md) — переход с legacy подхода.
- [03-tool-guide-git.md](03-tool-guide-git.md) — git как носитель.
- [04-document-store-substrate.md](04-document-store-substrate.md) — документо-ориентированный носитель.
- [05-safe-comparison.md](05-safe-comparison.md) — сравнение с SAFe / BABOK / ISO 29148.
- [06-compliance.md](06-compliance.md) — compliance mapping (GDPR / ФЗ-152 / AI Act).
- [07-failure-modes.md](07-failure-modes.md) — failure modes.

---

*Сквозной пример RENAR 1.0-draft — renar.tech*
