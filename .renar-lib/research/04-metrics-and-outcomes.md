# Метрики и outcomes RENARа

> Версия: черновик 0.1 | Дата: 2026-05-03
> Назначение: бизнес-outcomes, которые делает REQ; домен-специфичные метрики (НЕ дублирующие 10 метрик SENAR §9); целевые значения; ROI-обоснование; связь с SENAR метриками.

---

## 1. Не дублирует SENAR §9

SENAR §9 определяет 10 общих метрик: **Throughput, Lead Time, FPSR, DER, KCR, Cost Predictability, Cost-per-task, MIR, Cycle Time, ADR**.

REQ **использует их as-is**, не переопределяет. Здесь — **дополнительные** метрики специфичные для управления требованиями. Каждая отвечает на вопрос, который SENAR-10 не отвечает.

| SENAR метрика | Что отвечает | Что НЕ отвечает (где REQ добавляет) |
|---|---|---|
| Throughput (tasks/period) | Скорость выполнения задач | Скорость декомпозиции ТЗ → готовые требования |
| FPSR | Качество с первого раза для задач | Качество с первого раза для требований (генерация без переделки) |
| DER (Defect Escape Rate) | Дефекты в коде, проникшие в прод | Дефекты в требованиях (мисс-понимание) |
| ADR (Adversarial Detection Rate) | Скрытые дефекты в AI-выводе кода | Скрытые дефекты в AI-генерации требований |
| Cost-per-task | Стоимость задачи | Стоимость декомпозиции ТЗ, стоимость BR/SR |

REQ-метрики **уточняют** SENAR на уровне requirements management, не дублируют.

---

## 2. Outcomes (что RENAR даёт бизнесу)

### Outcome 1. Сокращение времени от ТЗ до первой реализованной фичи

**До REQ**: подписан ТЗ → команда читает, спорит, декомпозирует — 1-3 недели на 50-страничный ТЗ → создание задач — 3-5 дней → старт разработки. **Итого: 2-4 недели до первого commit'а**.

**С RENAR-4/5**: AI-агент декомпозирует ТЗ за < 1 часа человеческого времени → adversarial review → approval QG-0 → задачи в трекере. **Итого: < 2 дня до первого commit'а**.

**Outcome KPI**: `TZ-to-first-commit` в днях.

### Outcome 2. Снижение dispute rate на приёмке

**До REQ**: клиент при приёмке говорит «это я не просил» / «вот это пропустили». Споры разрешаются перепиской и переделкой за свой счёт. 10-30% задач — disputed.

**С RENAR-4/5**: каждое требование имеет `source` citation в ТЗ, каждый TC имеет `last-run.result = pass` на текущей `requirement-version`. Dispute → быстрая проверка по citation. **Dispute Rate ≤ 2%**.

**Outcome KPI**: `Dispute Rate at acceptance`.

### Outcome 3. Аудиторская готовность

**До REQ**: при ISO 27001 / ФЗ-152 / GDPR аудите — 2-3 недели подготовки документов вручную.

**С RENAR-3+**: traceability matrix BR ↔ SR ↔ TC ↔ implementation генерируется автоматически. Аудит занимает 1-2 дня.

**Outcome KPI**: `Audit prep time` в человеко-днях.

### Outcome 4. Возможность продавать стандарт партнёрам

**До REQ**: партнёр получает «kibertum way» как чёрный ящик, не может верифицировать качество процесса.

**С RENAR-5**: партнёр получает нормативный документ + tooling, может self-assess по conformance checklist (см. [03-maturity-model.md](03-maturity-model.md)) — стандарт становится продуктом.

**Outcome KPI**: `Partner adoption rate` (partners using REQ / total partners).

### Outcome 5. Снижение стоимости работы с клиентскими дельта-ТЗ

**До REQ**: дельта-ТЗ → ручной impact analysis → пересмотр backlog → у инженеров (2-5 человеко-дней).

**С RENAR-3+**: `tausik req impact <delta-tz>` за минуты выдаёт затронутые BR/SR/TC/задачи. Архитектор подтверждает, AI генерирует обновлённые артефакты.

**Outcome KPI**: `Delta-TZ processing cost` в человеко-часах.

### Outcome 6. Снижение «знаниевой дыры» при смене команды

**До REQ**: разработчик уходит → знания теряются → новый разработчик читает код, гадает «зачем так».

**С RENAR-3+**: knowledge graph + traceability BR → SR → TC → code → decision (KAI Decisions) — onboarding нового члена команды через `/onboard` skill за часы вместо недель.

**Outcome KPI**: `Onboarding time to first productive PR` в днях.

---

## 3. REQ-специфичные метрики

### 3.1 Requirement Decomposition Lead Time (RDLT)

**Что**: время от подписания ТЗ до состояния «все BR/SR в статусе `approved`, готовы для QG-0».

**Формула**: `approved_at(last BR/SR) - signed_at(TZ)`.

**Цель**:
- RENAR-3: < 1 неделя на 50-страничный ТЗ.
- RENAR-4: < 2 дня.
- RENAR-5: < 4 часа.

**Связь с SENAR**: уточнение SENAR `Lead Time` для requirements phase.

### 3.2 Requirement-to-Task Latency

**Что**: время от `approved` SR до создания первого Task с `senar-req-id` ссылкой на этот SR.

**Формула**: `created_at(first Task) - approved_at(SR)`.

**Цель**:
- RENAR-3: < 3 дня.
- RENAR-5: < 1 час (автоматически после approval).

**Зачем**: indicator overall lubrication процесса. Если SR approved лежит без задачи неделю — что-то сломано.

### 3.3 Hallucination Rate in AI-generated Requirements

**Что**: процент утверждений в AI-генерированном BR/SR, которые не traceable к source (ТЗ + интервью).

**Формула**: `assertions_without_citation / total_assertions × 100%`.

**Измерение**: автоматическое — pre-commit hook парсит body требования, проверяет citations.

**Цель**:
- RENAR-4: ≤ 5%.
- RENAR-5: ≤ 1%.

**Связь со стандартами**: ISO/IEC 5338 «traceability requirement».

### 3.4 Multi-model Disagreement Rate

**Что**: процент `priority: must` BR, где две модели сгенерировали утверждения с расхождениями ≥ 15% по embedding similarity.

**Формула**: `BRs_with_high_disagreement / total_must_BRs × 100%`.

**Цель**:
- RENAR-5: tracked, baseline устанавливается per-project.

**Зачем**: высокий disagreement rate может означать плохой prompt (нужно улучшить), либо реально сложный domain (нужно больше human review).

### 3.5 Dispute Rate at Acceptance (DRA)

**Что**: процент требований, по которым клиент при приёмке (QG-4) сказал «не то/не так согласовали».

**Формула**: `disputed_requirements_at_QG4 / total_requirements_in_release × 100%`.

**Цель**:
- RENAR-3: ≤ 10%.
- RENAR-4: ≤ 5%.
- RENAR-5: ≤ 2%.

**Зачем**: главный outcome-сигнал. Если дельта высокая — стандарт не работает на главное (управление ожиданиями клиента).

### 3.6 Adversarial Catch Rate (ACR)

**Что**: процент требований, где AI-критик (Принцип 2 из [02](02-agent-driven-principles.md)) нашёл ≥1 high-severity issue.

**Формула**: `requirements_with_critic_high_findings / total_reviewed × 100%`.

**Цель**:
- RENAR-4: tracked, baseline 20-30% (если ниже — критик слабый или дублирует генератора).
- RENAR-5: trending — рост ACR требует attention к качеству prompts.

**Зачем**: измеряет качество adversarial review. Слишком низкое → false confidence. Слишком высокое → процесс генерации плохой.

**Связь со SENAR**: подкласс ADR (Adversarial Detection Rate) для требований.

### 3.7 Test-spec Drift Rate

**Что**: процент TC с `last-run.requirement-version` ниже текущей `requirement.version`.

**Формула**: `stale_TCs / total_TCs × 100%`.

**Измерение**: автоматическое в COVERAGE.md.

**Цель**:
- RENAR-4: ≤ 5%.
- RENAR-5: ≤ 1% (auto-rerun при дельта-ТЗ).

### 3.8 Coverage Velocity

**Что**: как быстро `approved` требования становятся `verified`.

**Формула**: `(verified_count(end_period) - verified_count(start_period)) / approved_at_start × 100% per sprint`.

**Цель**:
- RENAR-3: ≥ 30% за спринт (медленный темп, ещё много ручного TC написания).
- RENAR-5: ≥ 70% за спринт (autoматическая генерация и прогон TC).

### 3.9 Cost per Approved Requirement

**Что**: стоимость AI-генерации (токены × цена) приведённая к одному approved requirement (включая отвергнутые версии).

**Формула**: `total_AI_cost / count(approved_requirements)`.

**Цель**:
- RENAR-4 baseline: $0.50-2.00 per BR, $0.20-0.80 per SR (грубо).
- RENAR-5: tracked, optimization target.

**Связь со SENAR**: уточнение `Cost-per-task` (SENAR §9) для requirements phase.

### 3.10 Reconciliation Findings per Week

**Что**: количество issues, найденных reconciliation-агентом (Принцип 7 из [02](02-agent-driven-principles.md)) за неделю.

**Формула**: `count(reconciliation_MR.findings) per week`.

**Цель**:
- RENAR-4: tracked, не ноль (если ноль — агент не работает).
- RENAR-5: trend down (зрелый процесс не порождает drift).

---

## 4. Сводная таблица метрик

| Метрика | Цель RENAR-3 | Цель RENAR-4 | Цель RENAR-5 | Откуда данные |
|---|---|---|---|---|
| RDLT (Decomposition Lead Time) | < 1 неделя | < 2 дня | < 4 часа | git log .req |
| Requirement-to-Task Latency | < 3 дня | < 1 день | < 1 час | TAUSIK DB / Raven |
| Hallucination Rate | n/a | ≤ 5% | ≤ 1% | citation parser |
| Multi-model Disagreement Rate | n/a | n/a | tracked | multi-model runs log |
| Dispute Rate at Acceptance | ≤ 10% | ≤ 5% | ≤ 2% | QG-4 records |
| Adversarial Catch Rate | n/a | tracked baseline | trending | critic outputs |
| Test-spec Drift Rate | n/a | ≤ 5% | ≤ 1% | COVERAGE.md |
| Coverage Velocity | ≥ 30%/спринт | ≥ 50% | ≥ 70% | COVERAGE.md history |
| Cost per Approved Requirement | tracked | optimized | optimized | ai-provenance fields |
| Reconciliation Findings/Week | n/a | tracked | trending down | reconciliation MRs |

---

## 5. ROI-модель

### 5.1 Затраты

| Категория | RENAR-3 setup | RENAR-4 | RENAR-5 |
|---|---|---|---|
| Внедрение (one-time, человеко-дни) | 5-10 | +10-20 | +10-15 |
| AI-генерация (на средний проект 100 SR) | $50-150 | $200-500 | $400-1000 |
| Human attention (one-click + spot-check) | 10% времени архитектора | 15% | 5-10% (better tooling = меньше) |
| Инфра (CI runners, vector DB для graph) | $0 (на TAUSIK) | $20-50/мес | $100-300/мес (Raven) |

### 5.2 Выгоды (на проект 100 SR, длительностью 6 месяцев)

| Что | До REQ | С RENAR-4 | Экономия |
|---|---|---|---|
| Время декомпозиции ТЗ (RDLT) | 80 человеко-часов | 8 часов | 72 ч × $80 = **$5760** |
| Дельта-ТЗ обработка (3 дельты за проект) | 24 человеко-часа | 6 часов | 18 ч × $80 = **$1440** |
| Аудит compliance (1 раз) | 60 часов | 8 часов | 52 ч × $80 = **$4160** |
| Dispute resolution (10% вместо 2%) | 32 часа | 6 часов | 26 ч × $80 = **$2080** |
| Onboarding 2 новых разработчиков | 80 часов | 16 часов | 64 ч × $50 = **$3200** |
| **Итого экономия на проект** | | | **~$16640** |

**Затраты на проект RENAR-4**: ~$500 (AI) + ~30 человеко-дней внедрения amortised across multiple projects.

**ROI на 1 проект (после внедрения)**: 30x+ возврат.

### 5.3 Прайсинг для партнёров

RENAR + tooling может продаваться партнёрам как:

| Tier | Что включено | Цена |
|---|---|---|
| Self-hosted | Стандарт-документы + TAUSIK skill `req` | $0 (open) |
| Tooling subscription | + reconciliation hosted, knowledge graph | $200-500/мес per project |
| Managed | + adversarial critic API (Kibertum LLM keys), priority support | $1000-2000/мес |
| Enterprise | + on-prem deploy, SLA, custom prompts, training | договорной |

Это превращает методологию в **продаваемый продукт**, не cost center.

---

## 6. Дашборд (как минимум)

`COVERAGE.md` (обновляется ботом) включает следующий блок (расширение существующего):

```markdown
## REQ-метрики проекта

| Метрика | Текущее | Цель (REQ-N) | Тренд (30d) |
|---|---|---|---|
| RDLT (последний ТЗ) | 2.1 days | < 4h (RENAR-5) | ↓ 12% |
| Hallucination Rate | 3.4% | ≤ 1% (RENAR-5) | ↓ 8% |
| Dispute Rate at Acceptance | 4.0% | ≤ 2% (RENAR-5) | ↓ 25% |
| Coverage Velocity | 62%/sprint | ≥ 70% (RENAR-5) | ↑ 5% |
| Cost per Approved BR | $0.84 | tracked | → |
| Reconciliation Findings/Week | 3 | tracked | ↓ 50% |

**REQ-уровень проекта**: **RENAR-4** (см. checklist [03-maturity-model.md](03-maturity-model.md))
```

---

## 7. Связь с SENAR метриками — итоговый mapping

| SENAR метрика | REQ-уточнение |
|---|---|
| Throughput | + Coverage Velocity (на уровне требований) |
| Lead Time | + RDLT, Requirement-to-Task Latency |
| FPSR | + REQ-FPSR (доля требований, прошедших QG-0 без переделки) |
| DER | + Dispute Rate at Acceptance (DER в зоне требований) |
| KCR | (используется как есть) |
| Cost Predictability | + variance Cost per Approved Requirement |
| Cost-per-task | + Cost per Approved Requirement |
| MIR (Memory Integrity Rate) | (используется как есть) |
| Cycle Time | + RDLT — это cycle time для requirements stage |
| ADR (Adversarial Detection Rate) | + Adversarial Catch Rate (специально для requirements) |

---

## 8. Open questions

- [ ] Hallucination Rate — методика измерения automated parsing citations vs human verification. На RENAR-4 хватит automated, на RENAR-5 нужен sample human verification.
- [ ] Dispute Rate измеряется только в проектах с формальной приёмкой. Для внутренних — что прокси?
- [ ] Cost per Requirement — какая модель ценообразования AI-токенов? Зависит от тарифов Anthropic / OpenAI на момент.
- [ ] Бенчмарки — какие baseline у проектов до REQ? Нужны исторические данные. Можно ли извлечь из закрытых проектов (sales pipeline, etc)?
- [ ] Comparable industry benchmarks — существуют ли публичные данные на dispute rate / hallucination rate / coverage velocity для AI-driven требований? Скорее всего нет, мы окажемся first.
