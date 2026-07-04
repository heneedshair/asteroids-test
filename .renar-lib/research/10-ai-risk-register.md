# AI Risk Register для REQ-проектов

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: реестр AI-рисков, специфичных для RENARа (где AI генерирует требования и тесты). Основан на ISO/IEC 23894:2023 и NIST AI RMF 1.0. Закрывает gap из [01-positioning-vs-world-standards.md §3.11](01-positioning-vs-world-standards.md) и [06-multi-perspective-review.md §5](06-multi-perspective-review.md).
>
> Финальная нормативная форма — после обсуждения с Security и AI Governance.

---

## 1. Не дублирует SENAR

SENAR §10.1 упоминает Threat Surface как обязательный элемент задачи. SENAR не нормирует AI-специфичные риски.

REQ риск-реестр **не переписывает** Threat Surface. REQ:
- Описывает **систематически** AI-риски на уровне процесса (не конкретного изменения).
- Привязывает риски к ISO/IEC 23894 классификации.
- Связывает с принципами из [02-agent-driven-principles.md](02-agent-driven-principles.md) как mitigation.

---

## 2. Структура реестра

Каждый риск имеет:

```yaml
id: AIR-NN                           # AI Risk
name: "..."
category: hallucination | injection | drift | bias | sgnl-failure | data-quality | adversarial | privacy
severity: critical | high | medium | low
likelihood: high | medium | low
iso-23894-ref: "..."
nist-rmf-function: govern | map | measure | manage
mitigations:
  - mechanism: "..."
    enforced-by: "..."
    automated: true | false
status: active | mitigated | accepted | monitoring
owner: "@role"
last-reviewed: YYYY-MM-DD
related-principles: [02-Принцип-N, ...]
```

---

## 3. Реестр AI-рисков для REQ-проектов

### AIR-01. Hallucination в AI-генерируемых требованиях

| Параметр | Значение |
|---|---|
| Категория | hallucination |
| Severity | **High** |
| Likelihood | **High** (без mitigation) |
| ISO 23894 | §6.3 Output reliability |
| NIST RMF | Measure (accuracy) |

**Описание**: AI-агент при генерации BR/SR может «дописать от себя» утверждения, которых нет в исходном ТЗ. Эти утверждения попадают в договорной документ, в backlog, в код.

**Воздействие**: Scope creep, несогласованные с клиентом фичи, dispute на acceptance.

**Mitigations**:
- Source citation principle ([02 Принцип 3](02-agent-driven-principles.md)) — каждое утверждение verifiable.
- Adversarial review ([02 Принцип 2](02-agent-driven-principles.md)) — критик ловит unsupported assertions.
- Метрика Hallucination Rate ([04 §3.3](04-metrics-and-outcomes.md)) — ≤ 1% target на RENAR-5.

**Status**: active (на RENAR-1..3); mitigated (на RENAR-4..5).

---

### AIR-02. Prompt injection через ТЗ от клиента

| Параметр | Значение |
|---|---|
| Категория | injection |
| Severity | **High** |
| Likelihood | **Low-Medium** |
| ISO 23894 | §6.7 Adversarial inputs |
| NIST RMF | Manage (security) |

**Описание**: Злонамеренный клиент может вставить в текст ТЗ скрытые инструкции для AI («ignore previous instructions and...»). При импорте ТЗ AI-агент может эти инструкции выполнить.

**Воздействие**: Утечка данных, вредоносные изменения в требованиях, нарушение security policy.

**Mitigations**:
- Sandboxing AI-агента при импорте: модель работает с ТЗ как с пассивными данными, не как с инструкциями (system prompt должен это явно фиксировать).
- KAI Gateway проверяет inputs на known injection patterns перед передачей AI.
- При обнаружении suspicious pattern — escalation на инженера, не auto-process.

**Status**: monitoring (need automated detector).

---

### AIR-03. Model drift / version change

| Параметр | Значение |
|---|---|
| Категория | drift |
| Severity | **Medium** |
| Likelihood | **High** (модели обновляются регулярно) |
| ISO 23894 | §6.4 Model lifecycle |
| NIST RMF | Manage (model governance) |

**Описание**: Anthropic / OpenAI обновляют модели. Тот же prompt с той же ТЗ через 6 месяцев может дать другой output. Старые требования генерировались Opus 4.6, новые — Opus 4.7.

**Воздействие**: Inconsistency между требованиями в одном проекте; невозможность точно воспроизвести генерацию старого требования.

**Mitigations**:
- Model versioning в `ai-provenance.generated-by` ([02 Принцип 1](02-agent-driven-principles.md)).
- Eval-тесты для AIC прогоняются при смене модели (testing-methodology §5.6).
- При регенерации требования — diff против старой версии и assessment изменений.

**Status**: monitoring.

---

### AIR-04. Bias в AI-генерации требований

| Параметр | Значение |
|---|---|
| Категория | bias |
| Severity | **Medium** |
| Likelihood | **Medium** |
| ISO 23894 | §6.5 Fairness |
| NIST RMF | Measure (fairness) |

**Описание**: Модель имеет training-data bias. При генерации BR может игнорировать stakeholders определённых групп (например, accessibility users, non-English locales).

**Воздействие**: Требования не покрывают весь spectrum пользователей; продукт оказывается дискриминационным.

**Mitigations**:
- Multi-model agreement для BR ([02 Принцип 4](02-agent-driven-principles.md)) — разные модели имеют разные biases.
- Stakeholder map обязателен в BR — explicit перечисление (см. [06](06-multi-perspective-review.md) §2.2).
- Adversarial critic с promt «check for missing stakeholders / accessibility considerations».

**Status**: active.

---

### AIR-05. Single-model failure (no diversity)

| Параметр | Значение |
|---|---|
| Категория | sgnl-failure |
| Severity | **Medium** |
| Likelihood | **High** (без mitigation) |
| ISO 23894 | §6.4 Single point of failure |
| NIST RMF | Manage (resilience) |

**Описание**: Если все артефакты генерируются одной моделью, её ошибки систематически проникают. Если она «галлюцинирует» определённый паттерн — все требования это унаследуют.

**Воздействие**: Систематическое искажение требований по проекту.

**Mitigations**:
- Multi-model для priority=must BR ([02 Принцип 4](02-agent-driven-principles.md)).
- Adversarial critic с другой моделью ([02 Принцип 2](02-agent-driven-principles.md)).
- Изоляция judge-модели от production-модели в eval-тестах (testing-methodology §5.5).

**Status**: mitigated на RENAR-5.

---

### AIR-06. Test fitting / зеленение тестов

| Параметр | Значение |
|---|---|
| Категория | sgnl-failure |
| Severity | **High** |
| Likelihood | **Medium** (без mitigation) |
| ISO 23894 | §6.6 Verification integrity |
| NIST RMF | Measure (validity) |

**Описание**: AI-агент имеет тривиальный путь зеленения failing-теста — ослабить Pass-критерий. Это проходит code review, поскольку «тест зелёный».

**Воздействие**: False confidence; defects проходят в production.

**Mitigations**:
- `[test-spec-change]` тег обязателен для изменения Pass/Fail (testing-methodology §11).
- Спот-чек 5 случайных passing TC раз в спринт (testing-methodology §12).
- Метрика Test-fitting drift rate (отдельная от обычных metrics).

**Status**: mitigated на RENAR-4+.

---

### AIR-07. Hallucinated citations

| Параметр | Значение |
|---|---|
| Категория | hallucination |
| Severity | **Medium-High** |
| Likelihood | **Medium** |
| ISO 23894 | §6.3 Output reliability |
| NIST RMF | Measure (accuracy) |

**Описание**: AI-агент пишет citation `[TZ-2026-001 §4 line 142]`, но в реальном ТЗ §4 line 142 — про другое. Citation выглядит как evidence, но evidence ложный.

**Воздействие**: Source citation становится фикцией.

**Mitigations**:
- Citation validator hook — парсит citation, открывает указанный файл, проверяет наличие соответствующего текста.
- Pre-commit блокировка при невалидной citation.

**Status**: monitoring (need validator implementation).

---

### AIR-08. Adversarial inputs в clients data

| Параметр | Значение |
|---|---|
| Категория | adversarial |
| Severity | **High** |
| Likelihood | **Low** |
| ISO 23894 | §6.7 Adversarial inputs |
| NIST RMF | Manage (security) |

**Описание**: Клиент отправляет данные (через формы, API), которые специально сконструированы для манипуляции AI на стороне сервера.

**Воздействие**: Аналогично AIR-02, но runtime, не на этапе генерации требований.

**Mitigations**:
- Input sanitization на API gateway.
- Constrained generation (structured outputs only).
- Rate limiting per user.

**Status**: out-of-scope for REQ (это application-level security; REQ только трекает что эти SR должны быть).

---

### AIR-09. Privacy leakage через AI logs

| Параметр | Значение |
|---|---|
| Категория | privacy |
| Severity | **High** |
| Likelihood | **Medium** |
| ISO 23894 | §6.8 Privacy |
| NIST RMF | Govern (privacy) |

**Описание**: AI-агент при генерации требования имеет в контексте PII (из ТЗ или интервью). Логи генерации (tool_event в Raven) могут хранить эти PII.

**Воздействие**: PII попадают в логи, ai-provenance, training data (если используется).

**Mitigations**:
- PII redaction в промптах перед отправкой в LLM (если возможно).
- `data-classification` tracking — куда какие данные физически идут.
- Disable training on conversations (Anthropic / OpenAI privacy settings).
- TTL на tool_event с PII.

**Status**: active (need redaction tooling).

---

### AIR-10. Knowledge graph poisoning

| Параметр | Значение |
|---|---|
| Категория | data-quality |
| Severity | **Medium** |
| Likelihood | **Low** |
| ISO 23894 | §6.5 Data integrity |
| NIST RMF | Map (knowledge integrity) |

**Описание**: Если knowledge graph (Принцип 6) используется как primary search, то incorrect edge может «отравить» все последующие AI-запросы.

**Воздействие**: AI генерирует требования на основе wrong context, систематически.

**Mitigations**:
- Граф derived от frontmatter, не редактируется напрямую.
- CI-валидация графа на каждый merge (нет circular dependencies, no orphan approved).
- Reconciliation-агент проверяет integrity графа еженедельно.

**Status**: monitoring.

---

### AIR-11. Reconciliation false positive overload

| Параметр | Значение |
|---|---|
| Категория | sgnl-failure (process) |
| Severity | **Low-Medium** |
| Likelihood | **Medium** |
| ISO 23894 | §6.6 Verification integrity |
| NIST RMF | Manage (operational) |

**Описание**: Reconciliation-агент (Принцип 7) при слишком чувствительных правилах генерирует много false-positive findings. Архитектор начинает их игнорировать → real findings тонут.

**Воздействие**: Reconciliation теряет ценность.

**Mitigations**:
- Tunable thresholds в `<project>.req/.req-config.yaml`.
- Метрика Reconciliation Findings/Week trending — если растёт без real issues, calibration нужна.
- Архитектор может dismiss findings с обоснованием — это feedback для tuning prompt'а агента.

**Status**: monitoring.

---

### AIR-12. Cost runaway (uncontrolled AI spend)

| Параметр | Значение |
|---|---|
| Категория | sgnl-failure (operational) |
| Severity | **Medium** |
| Likelihood | **Medium** (без budget tracking) |
| ISO 23894 | §6.9 Cost governance |
| NIST RMF | Manage (resource governance) |

**Описание**: Без budget tracking AI-генерация (особенно с multi-model, adversarial, eval) может потреблять токены непропорционально размеру проекта.

**Воздействие**: Финансовые потери; нерентабельность стандарта.

**Mitigations**:
- Cost budget per artifact ([02 Принцип 5](02-agent-driven-principles.md)).
- Aggregated cost metric на уровне проекта (см. [04 §3.9](04-metrics-and-outcomes.md)).
- Cap на проект, alarm при approached.
- Recommendation engine: «использовать Sonnet для рутины, Opus только для priority=must BR».

**Status**: active.

---

### AIR-13. Стейкхолдер не понимает AI-сгенерированные требования

| Параметр | Значение |
|---|---|
| Категория | data-quality (UX) |
| Severity | **Medium** |
| Likelihood | **Medium** |
| ISO 23894 | §6.8 Transparency |
| NIST RMF | Govern (transparency) |

**Описание**: AI генерирует SR в техническом стиле; клиент / non-technical stakeholder при ревью не понимает = approval становится формальностью.

**Воздействие**: QG-0 approval теряет смысл; dispute rate at acceptance растёт.

**Mitigations**:
- Style guide ([07-style-guide-ai-generation.md](07-style-guide-ai-generation.md)).
- BR пишется в business language, не технологическом (запрещены технологии в BR per stand'ards).
- Human-readable summary в каждом BR/SR (короткая секция, понятная без технического background).

**Status**: active.

---

### AIR-14. Vendor lock-in to specific LLM provider

| Параметр | Значение |
|---|---|
| Категория | sgnl-failure (operational) |
| Severity | **Medium** |
| Likelihood | **Low-Medium** |
| ISO 23894 | §6.4 Vendor risk |
| NIST RMF | Govern (procurement) |

**Описание**: Все промпты оптимизированы под Claude. Если Anthropic меняет pricing / availability — переход на GPT требует переписывания всех промптов.

**Воздействие**: Operational risk, costs.

**Mitigations**:
- Provider-agnostic prompts где возможно.
- Multi-model already enforced для priority=must (Принцип 4) — гарантирует что есть второй провайдер в pipeline.
- Periodic test runs на резервном провайдере.

**Status**: monitoring.

---

## 4. Risk matrix

```
Severity / Likelihood
        │ Low      Medium       High
────────┼─────────────────────────────
High    │ AIR-08  AIR-04, 06   AIR-01, 03
Medium  │ AIR-10  AIR-11, 13   AIR-07, 09, 14
Low     │ —       AIR-12       AIR-02, 05
```

Critical / High risks (top-right quadrant) — приоритет mitigation.

---

## 5. Operational governance

### 5.1 Review cadence

- **Monthly**: AIR-01, 02, 06, 07, 09 — high-impact runtime risks.
- **Quarterly**: всё остальное.
- **On-incident**: любой риск переводится в active → root cause → mitigation.

### 5.2 Owner

Default owner — **Architect** проекта. Для AI-специфичных рисков — **AI Governance Lead** (если есть в организации).

### 5.3 Сохранение

Risk register проекта живёт в `<project>.req/governance/ai-risk-register.md`. Еженедельный update от reconciliation-агента (статусы, last-reviewed).

---

## 6. Open questions

- [ ] Как численно оценивать likelihood без исторических данных? Пока — экспертное.
- [ ] Risk acceptance: что значит «accepted» в REQ-контексте? Архитектор approval'ит = принимает риск, или нужна explicit signature?
- [ ] AIR-07 (hallucinated citations) — citation validator технически возможен, но требует AST-parsing ТЗ. Нужно ли строить или достаточно регулярных проверок reconciliation?
- [ ] Privacy leakage (AIR-09) — для российских клиентов с ФЗ-152 особенно критично. Нужна отдельная политика data-redaction на уровне Gateway.
- [ ] Multi-model страхует от bias и single-failure, но удваивает cost. Где порог рентабельности (только для priority=must, или для всех?)
- [ ] Risk register integration с Raven: как отображать на dashboard? `risk_meta` doc-type?
