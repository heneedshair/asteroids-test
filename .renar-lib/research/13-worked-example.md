# Worked example: end-to-end REQ workflow

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: пройти один полный цикл REQ от подписанного ТЗ до verified требования и accepted release. На примере маленького проекта «Login Flow». Закрывает gap из [06-multi-perspective-review.md §4.2](06-multi-perspective-review.md).

---

## 1. Контекст примера

**Клиент**: AcmeCorp.
**Проект**: Login Flow для внутреннего инструмента.
**Размер**: ~1 спринт работы команды.
**Стек**: Next.js + FastAPI + PostgreSQL.
**REQ-зрелость**: RENAR-4 (полный TC + adversarial + reconciliation).

Цель примера — показать **все** этапы; реальные проекты будут больше, но pipeline идентичный.

---

## 2. Phase 0 — Elicitation (см. [11-elicitation-workflow.md](11-elicitation-workflow.md))

После 2-х AI-led интервью (Sales Director, IT Manager) и synthesis получен ТЗ-черновик. После 1 итерации с клиентом — sign-off.

Артефакты Phase 0 (не показаны полностью; см. документ 11):

```
acmecorp-login.req/
  elicitation/
    domain-context.md
    sales-director.yaml
    it-manager.yaml
    findings-clustered.md
    critic-review.md
    multi-model-diff.md
```

---

## 3. Phase 1 — Импорт ТЗ

### 3.1 Подписанный ТЗ

```markdown
# TZ-2026-042 — Login Flow для AcmeCorp Internal Tool
Дата подписания: 2026-05-03
Стороны: AcmeCorp + Kibertum

## §1. Цели

Сократить время входа сотрудников AcmeCorp в инструмент с ручной выдачи учётных
данных до самостоятельной регистрации. Цель — <2 минут от первого захода до
полного доступа.

## §2. Функциональные требования

### ФТ-001. Самостоятельная регистрация по корпоративному email
Сотрудник может зарегистрироваться через email из домена @acmecorp.com.
Email вне домена — отказ с пояснением.

### ФТ-002. Двухфакторная аутентификация (TOTP)
После регистрации обязательная настройка 2FA через TOTP-приложение
(Google Authenticator, Authy).

### ФТ-003. Восстановление доступа через корпоративный admin
При потере 2FA устройства — recovery через ticket в IT support, не через
self-service email.

## §3. Нефункциональные требования

### НФТ-001. Производительность
Login flow от ввода email до dashboard <2 секунд (p95).

### НФТ-002. Безопасность
- Хранение паролей: bcrypt с cost-factor ≥ 12.
- Логи входов хранятся 1 год (compliance).
- Неудачные попытки: блокировка после 5 за 15 минут.

### НФТ-003. Юрисдикция
Все данные хранятся в РФ (компания работает с гос-контрактами).
```

### 3.2 Импорт командой

```bash
$ tausik req import-tz --order-id 042 --type initial \
    --signed-date 2026-05-03 \
    --source ./tz-input/TZ-2026-042.md

✓ Created acmecorp-login.req/tz/TZ-2026-042.md
✓ Created acmecorp-login.req/tz/TZ-2026-042-index.md (placeholder)
✓ Branch created: feat/TZ-2026-042-initial
✓ AI-провенанс: импорт сделал tausik-import@v1.4
```

---

## 4. Phase 2 — Декомпозиция через AI

### 4.1 Запуск декомпозиции

```bash
$ tausik req decompose --tz TZ-2026-042

[claude-opus-4-7] Reading TZ...
[claude-opus-4-7] Identifying business goals... 1 found.
[claude-opus-4-7] Generating BR candidates... 2 found.
[claude-opus-4-7] Generating SR candidates... 7 found.
[claude-opus-4-7] Generating UIC candidates... 1 found.
[claude-opus-4-7] Generated draft artifacts.

Cost: 14,200 input tokens + 3,800 output tokens = $0.46
Time: 28s
```

### 4.2 Адверсариальное review

```bash
$ tausik req adversarial-review --target br/

[gpt-4-turbo:critic] Reviewing draft BRs and SRs...

Findings:
[HIGH] BR-01 не указывает stakeholder explicitly — кто owner business goal?
[HIGH] SR-03 (TOTP) не описывает "edge case lost device" — это в ТЗ §2 ФТ-003
[MEDIUM] SR-05 говорит "bcrypt cost-factor 12" — это deployment detail, должно быть в TS, не в SR
[MEDIUM] НФТ-003 (юрисдикция) не отражено в data-classification ни одного SR

→ 4 findings: 2 high, 2 medium
→ Block req-promote --to approved until resolved
```

### 4.3 Iteration

Архитектор корректирует prompt, AI re-генерирует. Через 2 цикла все findings resolved.

### 4.4 Финальный набор артефактов

```
acmecorp-login.req/
├── br/
│   ├── BR-01-self-service-registration.md      # Самостоятельная регистрация
│   └── BR-02-secure-mfa.md                      # MFA как security baseline
├── sr/
│   ├── SR-01-email-domain-validation.md         # ФТ-001
│   ├── SR-02-totp-enrollment.md                 # ФТ-002
│   ├── SR-03-totp-verification.md               # ФТ-002
│   ├── SR-04-password-recovery-via-admin.md     # ФТ-003
│   ├── SR-05-rate-limiting-failed-logins.md     # НФТ-002
│   ├── SR-06-audit-logging.md                   # НФТ-002
│   └── SR-07-data-residency-ru.md               # НФТ-003
├── ui-concepts/
│   └── UIC-01-login-flow.md                     # Login + регистрация + 2FA setup
└── tz/
    ├── TZ-2026-042.md
    └── TZ-2026-042-index.md
```

### 4.5 Пример: SR-01 frontmatter

```yaml
---
id: SR-01
title: "Валидация домена email при регистрации"
type: SR
status: draft                          # будет approved после QG-0
parent:
  id: BR-01
  file: "br/BR-01-self-service-registration.md"
priority: must
source:
  document: "TZ-2026-042"
  section: "§2 ФТ-001"
data-classification:
  contains-pii: true
  data-residency: ["RU"]
  retention-days: 365
compliance:
  - { standard: "ФЗ-152", article: "ст.13.1" }
ai-provenance:
  generated-by: claude-opus-4-7@2026-05-03
  prompt-template: req-prompts/decompose-tz@v1.4
  context-tokens: 12450
  output-tokens: 320
  human-edits: false
verified-by: []                        # будет заполнено после генерации TC
---

## Требование

Система должна разрешать регистрацию только если email относится к домену
`@acmecorp.com`. Все остальные домены отклоняются с понятным пояснением.

## Поведение

- При попытке регистрации с email не из `@acmecorp.com` — система возвращает
  HTTP 422 с body `{"error":"email-domain-not-allowed", "allowed-domain":"acmecorp.com"}`.
  [TZ-2026-042 §2 ФТ-001 line 12]
- При email из `@acmecorp.com` — продолжается стандартный процесс регистрации.
  [TZ-2026-042 §2 ФТ-001 line 14]
- Список разрешённых доменов хранится в конфиге системы и может быть расширен
  без релиза. [derived: расширяемость — стандартная практика для domain-checking]

## Ограничения

- Subdomain `*.acmecorp.com` — отдельное решение архитектора (не входит в этот SR).
- Case-insensitive проверка домена.
```

---

## 5. Phase 3 — Генерация TC

### 5.1 Команда

```bash
$ tausik tc generate --requirement SR-01

[claude-opus-4-7] Analyzing SR-01...
[claude-opus-4-7] Identified 2 testable assertions.
[claude-opus-4-7] Generating positive TCs... 2.
[claude-opus-4-7] Generating negative TCs... 2.

Generated:
  tests/TC-001-sr01-allowed-domain-registration-pos.md
  tests/TC-002-sr01-allowed-domain-registration-neg.md
  tests/TC-003-sr01-disallowed-domain-rejected-pos.md
  tests/TC-004-sr01-disallowed-domain-rejected-neg.md

✓ verified-by в SR-01 обновлено: [TC-001, TC-002, TC-003, TC-004]
```

### 5.2 Пример: TC-001 frontmatter

```yaml
---
id: TC-001
title: "Регистрация с разрешённым доменом — успешный сценарий"
type: system
negative: false
verifies:
  - id: SR-01
    file: "sr/SR-01-email-domain-validation.md"
    requirement-version: 1.0
status: draft
ai-provenance:
  generated-by: claude-opus-4-7@2026-05-03
  prompt-template: req-prompts/generate-tc-pos-neg@v1.0
automation:
  status: automated
  location: "acmecorp-login.src/tests/integration/test_registration.py::test_allowed_domain_registers_successfully"
  runner: pytest
last-run: ~                            # будет заполнено CI после первого прогона
---

## Контекст

Проверяет happy path SR-01: регистрация с email из домена `@acmecorp.com`
успешна.

## Предусловия

- БД пуста (нет существующих пользователей с этим email).
- Email `alice@acmecorp.com` ещё не зарегистрирован.

## Шаги

1. POST /auth/register
   body: `{"email":"alice@acmecorp.com", "password":"ValidPass123!"}`

## Критерий успеха (Pass)

- Response status = 201.
- Response body содержит поле `user_id` (UUID format).
- В БД появляется запись `users` с `email="alice@acmecorp.com"`,
  `verified=false`, `2fa_setup=false`.
- Email верификации отправлен (mock SES получил вызов с правильным templ_id).

## Критерий неуспеха (Fail)

- Response status ≠ 201.
- В response body утечка password или его hash.
- В БД создан user с другим email (case mismatch).
- Email верификации не отправлен.
- В лог записан plaintext password.

## Постусловия

- Очистка БД (rollback transaction в test fixture).

## Не входит в этот тест

- TOTP setup workflow → TC-005 (verifies SR-02).
- Rate limiting → TC-009 (verifies SR-05).
```

---

## 6. Phase 4 — QG-0 approval

### 6.1 Команда

```bash
$ tausik req promote --to approved --requirement BR-01

Pre-conditions check (QG-0):
  ✓ source.document existed
  ✓ All assertions имеют citations
  ✓ children SRs все в status >= draft
  ✓ adversarial-review passed (cycle 2 of 2)
  ✓ TCs generated for all priority=must children
  ✓ pos/neg pair coverage = 100%

Awaiting one-click approval...
```

### 6.2 Архитектор open's MR в `.req`, видит summary report и нажимает Approve.

```bash
[архитектор approves]
✓ BR-01 status: draft → approved
✓ All children SR status: draft → approved (cascade)
✓ All TCs status: draft → ready
✓ ai-provenance.human-edits = false (no manual edits)
```

---

## 7. Phase 5 — Реализация (TR в трекере)

### 7.1 Создание задач

```bash
$ tausik req sync-tasks --substrate tausik

Создаю TAUSIK tasks:
  TASK-101: Implement domain validation (SR-01) — assignee: @backend-dev
  TASK-102: Implement registration form (UIC-01 part 1) — assignee: @frontend-dev
  TASK-103: Implement TOTP enrollment (SR-02) — assignee: @backend-dev
  ... 7 tasks total

Каждая task:
  - senar-req-id: <соответствующий SR>
  - QG-0 готов (есть Goal+AC из SR.поведение)
```

### 7.2 Разработчик берёт TASK-101

```bash
$ /task TASK-101

[QG-0 hook] Verifying task readiness...
  ✓ Goal exists
  ✓ AC list (4 items from SR-01 поведение)
  ✓ senar-req-id: SR-01 (resolves to existing requirement)
  ✓ Negative scenario in AC: yes (case-mismatch test)
  ✓ Threat Surface: low (input validation)

Task ready. Starting work session.
```

### 7.3 Реализация

```python
# acmecorp-login.src/src/auth/registration.py
from fastapi import HTTPException

ALLOWED_DOMAIN = "acmecorp.com"

def validate_email_domain(email: str) -> None:
    domain = email.split("@", 1)[-1].lower()
    if domain != ALLOWED_DOMAIN:
        raise HTTPException(
            status_code=422,
            detail={
                "error": "email-domain-not-allowed",
                "allowed-domain": ALLOWED_DOMAIN,
            },
        )
```

```python
# acmecorp-login.src/tests/integration/test_registration.py
def test_allowed_domain_registers_successfully(test_client, db_session, mock_ses):
    response = test_client.post(
        "/auth/register",
        json={"email": "alice@acmecorp.com", "password": "ValidPass123!"}
    )
    assert response.status_code == 201
    assert "user_id" in response.json()

    user = db_session.query(User).filter_by(email="alice@acmecorp.com").one()
    assert user.verified is False
    assert user.totp_setup is False

    mock_ses.send_email.assert_called_once_with(
        template_id="verification-email",
        to_email="alice@acmecorp.com",
    )
```

### 7.4 Commit

```bash
$ git add src/auth/registration.py tests/integration/test_registration.py
$ git commit -m "feat(auth): domain validation per SR-01 (TASK-101)"

[pre-commit] Verifying SR references...
  ✓ SR-01 exists in requirements/sr/SR-01-email-domain-validation.md
[pre-commit] Verifying senar-req-id linkage...
  ✓ TASK-101 has senar-req-id: SR-01
✓ Commit allowed

[pre-push] No direct push to main allowed
```

### 7.5 PR → CI

```bash
[CI] pytest acmecorp-login.src/tests/integration/test_registration.py
  test_allowed_domain_registers_successfully ............... PASSED
  test_disallowed_domain_rejected ............................ PASSED

[CI] Bot updates last-run в TC файлах:
  TC-001: last-run.result = pass, requirement-version = 1.0
  TC-003: last-run.result = pass, requirement-version = 1.0

[CI] COVERAGE.md regenerated automatically (commit by bot, tag [coverage])
```

---

## 8. Phase 6 — QG-2 (verified)

### 8.1 Команда

```bash
$ tausik req promote --to verified --requirement SR-01

QG-2 conditions:
  ✓ All TC in verified-by have last-run.result = pass
  ✓ All last-run.requirement-version match current SR-01 version (1.0)
  ✓ At least one negative TC: yes (TC-002, TC-004)
  ✓ All TCs in passing status (not manual-pending или failing)

Awaiting one-click approval...

[архитектор approves]
✓ SR-01 status: approved → verified
✓ COVERAGE.md updated: SR-01 verified
```

### 8.2 Расширенный COVERAGE.md (фрагмент)

```markdown
## Покрытие по требованиям

| Требование | Версия | Статус | TCs | Pass | Fail | Negative | Last run |
|---|---|---|---|---|---|---|---|
| BR-01 | 1.0 | approved | 0 (через children) | — | — | — | — |
| SR-01 | 1.0 | **verified** ✓ | 4 | 4 | 0 | 2 | 2026-05-08 |
| SR-02 | 1.0 | approved | 6 | 4 | 0 | 2 | 2026-05-08 (2 manual-pending) |
| SR-03 | 1.0 | approved | 4 | 0 | 0 | 0 | (not run yet) |
...

## REQ-метрики

| Метрика | Текущее | Цель (RENAR-4) | Тренд |
|---|---|---|---|
| RDLT | 1.2 days | < 2 days ✓ | ↓ |
| Hallucination Rate | 0.0% | ≤ 5% ✓ | → |
| Coverage Velocity | 14% (week 1) | ≥ 50% target | (early in sprint) |
| Cost per Approved BR | $0.46 | tracked | → |
```

---

## 9. Phase 7 — Дельта-ТЗ симуляция

### 9.1 Клиент через 1 неделю прислал дельта-ТЗ

```markdown
# TZ-2026-051 — Дополнение к TZ-2026-042
Базовый: TZ-2026-042

## §2 (изменение)

### ФТ-001 (расширение)

Дополнительно к домену `@acmecorp.com` разрешить `@subsidiary.acmecorp.com`
(дочерняя компания). Whitelist расширяется до 2 доменов.
```

### 9.2 Команда

```bash
$ tausik req import-tz --order-id 051 --type delta --base TZ-2026-042
$ tausik req impact --delta TZ-2026-051

Impact Analysis:
  Affected BR: BR-01 (расширяется scope)
  Affected SR:
    - SR-01: уточнение (domain whitelist 1 → 2)
    - status downgrade verified → approved (требует rerun TC)
  Affected TC:
    - TC-001..TC-004: requirement-version 1.0 → 1.1
    - obsolete-pending → перегенерация после release SR-01 v1.1
    - 2 новых TC нужны: registration с @subsidiary.acmecorp.com (pos/neg)
  Affected Tasks (TAUSIK):
    - TASK-101: completed; нужна new task TASK-115 для расширения validation

Recommended:
  - TASK-115: extend domain validation per SR-01 v1.1
  - SR-01 v1.0 → v1.1 в той же ветке change/TZ-2026-051
  - Перегенерация COVERAGE.md после merge
```

### 9.3 PR в `.req`

Архитектор делает PR с тегом `[delta:TZ-2026-051]`. AI обновляет SR-01 (расширяет whitelist), генерирует 2 новых TC. Merge.

### 9.4 PR в `.src`

Tech Lead двигает submodule pointer. Создаёт TASK-115. Разработчик имплементирует. Test runs. Bot updates last-run. SR-01 v1.1 → verified снова.

---

## 10. Phase 8 — QG-4 (Acceptance)

### 10.1 Через 4 недели после release

```bash
$ tausik req evaluate start --release v1.0

Measurement window: 4 weeks since 2026-05-15
Collecting KPI data...

BR-01: Самостоятельная регистрация
  KPI: Time-to-first-login (от первого захода до логина)
  Baseline: N/A (новая функциональность)
  Target: < 2 minutes (P95)
  Actual: 1.4 minutes (P95)
  Achievement: 143% (beat target)

BR-02: Secure MFA
  KPI: % users with 2FA enabled within 7 days of registration
  Target: ≥ 95%
  Actual: 97%
  Achievement: 102%
```

### 10.2 QG-4 report

AI генерирует отчёт. Adversarial critic находит 1 issue: «recovery через admin не покрыт TC verifying full flow». Архитектор соглашается → создаёт delta-TZ для acceptance test.

### 10.3 Финальный sign-off

После resolve issue клиент signs off. BRs → status `accepted`.

```
acmecorp-login.req/QG-4-REPORT-v1.0.md     # архив
acmecorp-login.req/lessons/2026-Q2.md       # lessons learned
```

---

## 11. Финальные артефакты после полного цикла

```
acmecorp-login.req/
├── br/
│   ├── BR-01-self-service-registration.md   (status: accepted)
│   └── BR-02-secure-mfa.md                   (status: accepted)
├── sr/
│   ├── SR-01-email-domain-validation.md      (v1.1, verified)
│   ├── SR-02-totp-enrollment.md              (v1.0, verified)
│   ├── SR-03-totp-verification.md            (v1.0, verified)
│   ├── SR-04-password-recovery-via-admin.md  (v1.0, verified)
│   ├── SR-05-rate-limiting-failed-logins.md  (v1.0, verified)
│   ├── SR-06-audit-logging.md                (v1.0, verified)
│   └── SR-07-data-residency-ru.md            (v1.0, verified)
├── ui-concepts/
│   └── UIC-01-login-flow.md                  (v1.0, verified)
├── tests/
│   ├── TC-001..TC-026                        (26 TC, 100% passing)
├── tz/
│   ├── TZ-2026-042.md                        (initial)
│   ├── TZ-2026-042-index.md
│   ├── TZ-2026-051-delta.md                  (delta)
│   └── TZ-2026-051-index.md
├── elicitation/                              (Phase 0 артефакты)
├── lessons/2026-Q2.md                        (Phase 8 lessons)
├── REQUIREMENTS.md                           (auto-generated)
├── TEST-PLAN.md                              (auto-generated)
├── COVERAGE.md                               (auto-generated, 100% verified)
└── QG-4-REPORT-v1.0.md                       (Phase 8)
```

---

## 12. Метрики проекта

После accepted release:

| Метрика | Значение |
|---|---|
| RDLT (TZ → all approved) | 1.2 days |
| Time-to-first-commit | 1.5 days |
| Coverage Velocity | 100% за 2 sprint'а |
| Hallucination Rate | 0% (CI validator) |
| Adversarial Catch Rate | 4 high findings caught (cycle 1) |
| Test-spec drift rate | 0% (rerun на дельта-ТЗ) |
| Dispute Rate at Acceptance | 0% (1 issue, resolved before sign-off) |
| Cost per BR | $0.46 + critic $0.18 = $0.64 |
| Total AI cost для проекта | ~$8.50 (декомпозиция + critics + reconciliation) |
| Дни до accept'а | 35 days |
| BRs в release | 2/2 accepted |

---

## 13. Что показывает этот пример

1. **Прозрачность**: каждый артефакт имеет provenance, каждый переход — gate.
2. **Скорость**: декомпозиция ТЗ — 28 секунд + 2 цикла adversarial.
3. **Trace**: от строки в ТЗ до passing TC — за 2 клика.
4. **Дельта-ТЗ обработка**: затронутые задачи и тесты — автоматически.
5. **Закрытие петли**: QG-4 связывает back в business outcomes.

---

## 14. Open questions

- [ ] Демо-репо где разместить? Internal GitLab? Public GitHub for showcase? Разная аудитория.
- [ ] Создать **runnable** demo (с настоящим кодом) или достаточно paper walkthrough?
- [ ] Локализация: английская или русская версия примера?
- [ ] Как держать пример в актуальном состоянии — переделывать при изменении стандарта?
- [ ] Несколько примеров для разных доменов (B2C, B2B, AI-heavy)? Или один достаточно?
