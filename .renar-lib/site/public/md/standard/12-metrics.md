---
title: "Метрики"
order: 12
lang: ru
---
# 12. Метрики

> **Часть RENAR Standard v1.0-draft** · [← Оглавление](README.md)

## 12.1 Что измерять в требованиях

Общие метрики SENAR (§9) покажут, что команда быстра и тесты зелёные. Но они не заметят, как AI-агент тихо вписал в SR пункт, которого не было ни в ТЗ, ни в ADAPT, — пока он не всплывёт на приёмке спором с клиентом. «Процесс в целом» здоров, а работа с требованиями — нет. Поэтому RENAR добавляет **десять метрик, которые смотрят именно на требования**: как часто AI-агент придумывает пункт без источника (Hallucination Rate), ловят ли парные тесты реальные дефекты, как быстро дельта-ТЗ доходит до кода. Это надстройка над SENAR §9, а не замена.

Список метрик закрыт; для каждой задаются формула, цель по уровню зрелости ([глава 11](11-maturity-model.md)) и источник данных. Метрики собираются нативно для носителя через V1–V6 ([глава 3](03-substrate-versioning.md)); как именно рисовать дашборды — вопрос реализации, вынесенный в `guide/`. Глава не дублирует SENAR §9, а специализирует его, и не касается ROI или ценообразования — это не индикаторы процесса, а бизнес-эффекты (§12.5).

---

## 12.2 Связь с SENAR §9

SENAR §9 определяет десять метрик общего процесса: Throughput, Lead Time, FPSR (First-Pass Success Rate), DER (Defect Escape Rate), KCR (Knowledge Capture Rate), Cost Predictability, Cost-per-task, MIR (Memory Integrity Rate), Cycle Time, ADR (Adversarial Detection Rate).

RENAR §12 **не** редактирует и **не** заменяет эти метрики. REQ-специфичные метрики §12.3:

- **Уточняют** SENAR метрику для фазы требований (например, RDLT уточняет SENAR Lead Time на фазе требований).
- **Добавляют** наблюдения, специфичные для инженерии требований и не покрываемые SENAR §9 (Hallucination Rate, Multi-model Disagreement Rate).

Полный mapping — §12.7.

Закрытый список REQ-метрик (§12.3) сохраняется в рамках RENAR; SENAR §9 — отдельный закрытый список общих метрик. Изменение любого из двух списков — формально независимые процедуры изменения соответствующих стандартов.

---

## 12.3 Закрытый список REQ-специфичных метрик

Закрытый список из десяти REQ-метрик. Изменение списка — только через формальную процедуру изменения стандарта ([§13.9.3](13-conformance.md#13.9.3)); общая политика закрытого списка и master-индекс — [§1.7.5](01-scope.md#1.7.5).

### 12.3.1 RDLT — Requirement Decomposition Lead Time

Время от регистрации ТЗ в носителе до состояния «все BR/SR (parent цепочка из этого ТЗ) → `approved`, готовы для QG-0 ([§10.3.1](10-lifecycle-qg.md#10.3.1))». **Формула:** `RDLT = timestamp(last BR/SR → approved) − timestamp(TZ registered)`. Измеряется в часах/днях. **Источник:** журнал аудита promote-transitions ([§10.13](10-lifecycle-qg.md#10.13)). **Связь с SENAR:** уточнение SENAR `Lead Time` для фазы требований. **Цели:** RENAR-3 < 1 неделя на 50-страничный ТЗ; RENAR-4 < 2 дня; RENAR-5 < 4 часа.

### 12.3.2 Requirement-to-Task Latency

Время от promote-transition SR → `approved` до создания первой TR со ссылкой `implements: SR-N`. **Формула:** `Latency = timestamp(first TR.created) − timestamp(SR → approved)`. Часы. **Источник:** журнал аудита носителя + межносительные ссылки реализационного носителя. **Связь с SENAR:** уточнение SENAR `Cycle Time` для пары «requirement → executable task». **Цели:** RENAR-3 < 3 дня; RENAR-4 < 1 день; RENAR-5 < 1 час (auto-create TR после approval).

### 12.3.3 Hallucination Rate

Процент нормативных утверждений в AI-генерируемом артефакте (BR/SR/SPEC), которые не traceable к source (ТЗ/ADAPT/другой нормативный артефакт). Source citation проверяется нативным citation parser ([§13.3.1](13-conformance.md#13.3.1), RENAR-4 обязательно). **Формула:** `assertions_without_valid_citation / total_normative_assertions × 100%`. Per артефакт; агрегируется per project. **Источник:** citation parser (AST или regex по inline references `[TZ-XXX §Y]` / `[ADAPT-NNN §Z]`). **Связь с SENAR:** новая метрика; соответствует ISO/IEC 5338 traceability для артефактов, сгенерированных AI. **Цели:** RENAR-1..3 n/a; RENAR-4 ≤ 5%; RENAR-5 ≤ 1%.

**Отрицательный сценарий (триггер потери соответствия):** Hallucination Rate > 5% на RENAR-4 проекте — нормативный триггер потери соответствия ([§13.8.1](13-conformance.md#13.8.1)); устранить через план восстановления релиза либо понижение до RENAR-3.

### 12.3.4 Multi-model Disagreement Rate

Процент артефактов с `priority: must`, где две (или более) генерирующие AI-модели произвели нормативные утверждения с расхождением выше порога (по умолчанию embedding similarity < 85%; порог фиксируется в манифесте `declared-stricter`). **Формула:** `BRs_with_high_disagreement / total_must_BRs × 100%`. **Источник:** multi-model runs log; embedding-similarity computed offline по парам «model A vs B». **Связь с SENAR:** новая метрика. **Цели:** RENAR-1..4 n/a; RENAR-5 tracked, базовые значения по проекту в первом квартале. **Интерпретация:** высокое значение — индикатор слабого prompt-engineering или сложной предметной области; требует внимания, но само по себе не является негативным показателем.

### 12.3.5 DRA — Dispute Rate at Acceptance

Процент BR/SR, по которым на этапе QG-4 ([§10.4.2](10-lifecycle-qg.md#10.4.2)) клиент заявил несогласие с интерпретацией или покрытием. **Формула:** `disputed_BRs_at_QG4 / total_BRs_in_release × 100%`. **Источник:** журнал аудита QG-4 — `gate-id: QG-4` event с `result: disputed`. **Связь с SENAR:** уточнение `DER (Defect Escape Rate)` для requirements. **Применимость:** только при QG-4 в манифесте; при QG-4 = `absent` ([§13.3.6](13-conformance.md#13.3.6)) — не измеряется. **Цели:** RENAR-3 ≤ 10%; RENAR-4 ≤ 5%; RENAR-5 ≤ 2%.

### 12.3.6 ACR — Adversarial Catch Rate

Процент артефактов (BR/SR/SPEC), где AI-критик (другая модель; обязательна на RENAR-5 per [§11.8.1](11-maturity-model.md#11.8.1)) нашёл ≥ 1 high-severity issue до QG-0. **Формула:** `artifacts_with_critic_high_findings / total_reviewed_by_critic × 100%`. **Источник:** журнал аудита critic-runs; severity (`high`/`medium`/`low`) в critic output. **Связь с SENAR:** подкласс `ADR (Adversarial Detection Rate)` для requirements. **Цели:** RENAR-1..3 n/a; RENAR-4 optional (если `declared-stricter` — базовый уровень 20–30%; значения < 20% — индикатор слабого критика или дублирования primary); RENAR-5 tracked normatively, рост ACR требует внимания к качеству промптов.

### 12.3.7 Test-spec Drift Rate

Процент TC в статусе `passing` ([§10.9.1](10-lifecycle-qg.md#10.9.1)), у которых `last-run.requirement-version` ([§9.12](09-test-cases.md#9.12)) отличается от текущей `version` верифицируемого артефакта (`verifies[]`). **Формула:** `stale_passing_TCs / total_passing_TCs × 100%` (stale = `last-run.requirement-version` < текущей). **Источник:** COVERAGE-artifact ([§9.15](09-test-cases.md#9.15)). **Связь с SENAR:** новая метрика. **Цели:** RENAR-1..3 n/a; RENAR-4 ≤ 5%; RENAR-5 ≤ 1% (auto-rerun на delta-ADAPT).

### 12.3.8 Coverage Velocity

Темп перехода `approved` → `verified` ([§10.5](10-lifecycle-qg.md#10.5)) за единицу времени (default итерация; носитель может определить другой интервал в манифесте). **Формула:** `(verified_count(end) − verified_count(start)) / approved_count(start) × 100%`. **Источник:** COVERAGE-artifact history ([§9.15](09-test-cases.md#9.15)). **Связь с SENAR:** уточнение `Throughput` для requirements. **Цели:** RENAR-3 ≥ 30%/итерация; RENAR-4 ≥ 50%/итерация; RENAR-5 ≥ 70%/итерация.

### 12.3.9 Cost per Approved Requirement

Стоимость AI-генерации (input tokens + output tokens × tariff) приведённая к одному артефакту в статусе `approved`, включая отвергнутые версии (остаются в носителе за счёт V1 immutable history). **Формула:** `total_AI_tokens_cost(period) / count(artifacts_approved_in_period)`. Валюта проекта. **Источник:** `ai-provenance.cost-budget` + `ai-provenance.cost-actual` поля frontmatter ([§11.7.1](11-maturity-model.md#11.7.1)). **Связь с SENAR:** уточнение `Cost-per-task` для requirements. **Цели:** RENAR-1..3 n/a; RENAR-4 tracked, базовые значения по проекту; RENAR-5 tracked + year-over-year снижение либо обоснование.

### 12.3.10 Reconciliation Findings per Week

Количество issues, обнаруженных reconciliation-агентом ([§2.4.2](02-methodology-positioning.md#2.4.2) continuous reconciliation) за неделю и зарегистрированных как backward findings в delta-ADAPT либо direct change-set requirement. **Формула:** `count(reconciliation_findings_registered) / weeks_in_period`. **Источник:** журнал аудита reconciliation runs + backward findings list ADAPT ([§7.4.5](07-adapt.md#7.4.5)). **Связь с SENAR:** новая метрика. **Цели:** RENAR-1..3 n/a; RENAR-4 tracked > 0 (ноль = reconciliation hook не работает либо потеря V5); RENAR-5 trending **down** в долгосрочной перспективе (зрелый процесс не порождает новых drift).

---

## 12.4 Сводная таблица целей по уровням

Закрытый список 10 метрик из §12.3 — целевые значения по применимым уровням.

| Метрика | RENAR-3 | RENAR-4 | RENAR-5 | Источник данных |
|---|---|---|---|---|
| RDLT (Decomposition Lead Time) | < 1 неделя | < 2 дня | < 4 часа | promote-transitions журнал аудита |
| Requirement-to-Task Latency | < 3 дня | < 1 день | < 1 час | журнал аудита + межносительные refs |
| Hallucination Rate | n/a | ≤ 5% | ≤ 1% | citation parser |
| Multi-model Disagreement Rate | n/a | n/a | tracked | multi-model runs log |
| DRA (Dispute Rate at Acceptance) | ≤ 10% | ≤ 5% | ≤ 2% | QG-4 журнал аудита (если QG-4 declared) |
| ACR (Adversarial Catch Rate) | n/a | optional (если critic declared-stricter) | tracked normatively | critic-runs журнал аудита |
| Test-spec Drift Rate | n/a | ≤ 5% | ≤ 1% | COVERAGE-artifact |
| Coverage Velocity | ≥ 30%/итерация | ≥ 50%/итерация | ≥ 70%/итерация | COVERAGE history |
| Cost per Approved Requirement | n/a | tracked | tracked + optimized | ai-provenance fields |
| Reconciliation Findings/Week | n/a | tracked (> 0) | trending down | reconciliation журнал аудита |

Конкретное нативное для носителя представление этих метрик в dashboards — специфично для носителя и выносится в `guide/`.

> Целевые значения для RENAR-4 / RENAR-5 — **provisional**: заданы как нормативные ориентиры направления, но подлежат калибровке по field-data в версии v1.1 (см. [guide/07 §8.1](../guide/07-failure-modes.md)). Это направляющие пороги, а не статистически валидированные значения.

---

## 12.5 Бизнес-результаты (Business outcomes)

Шесть нормативных эффектов внедрения RENAR, ожидаемых на уровнях RENAR-3 и выше. Outcomes являются **нормативными ожиданиями стандарта**, не индикаторами процесса; их измерение — специфично для носителя и не обязательно (хотя §12.3 метрики косвенно их фиксируют).

> ROI / cost-of-adoption — **ненормативная** тема и в нормативную главу не входит. Облегчённая **иллюстративная** (не гарантированная) модель стоимости и выгоды внедрения для лица, принимающего решение, — в [guide/02-transition-guide](../guide/02-transition-guide.md#стоимость-и-выгода-внедрения-иллюстративно).

### 12.5.1 Результат 1 — Сокращение времени декомпозиции ТЗ

Измеряется через §12.3.1 RDLT. Ожидаемое сокращение от базового уровня: порядок 5–10× на RENAR-4, 20–50× на RENAR-5.

### 12.5.2 Результат 2 — Снижение частоты споров на приёмке

Измеряется через §12.3.5 DRA. Ожидаемое снижение: с 15–30% до ≤ 5% на RENAR-4, ≤ 2% на RENAR-5.

### 12.5.3 Результат 3 — Аудиторская готовность

Журнал аудита событий ([§10.13](10-lifecycle-qg.md#10.13)) + AI-provenance во frontmatter ([§11.7.1](11-maturity-model.md#11.7.1)) обеспечивают compliance audit без отдельной подготовительной работы. Применимо для regulated industries (медицина, финтех, госсектор).

### 12.5.4 Результат 4 — Снижение стоимости работы с delta-ТЗ

Impact analysis ([§9.16](09-test-cases.md#9.16)) + reverse-эволюция верификации ([§10.5.4](10-lifecycle-qg.md#10.5.4)) автоматизируют обработку delta-ТЗ. Ожидаемое сокращение участия человека: с десятков часов до часа на delta.

### 12.5.5 Результат 5 — Снижение потери знаний при смене команды

V6 author + timestamp ([§3.3.6](03-substrate-versioning.md#3.3.6)) фиксирует автора всех артефактов; инверсия источника истины ([§2.3.1](02-methodology-positioning.md#2.3.1)) переносит знания из головы в носитель. Ожидаемое сокращение onboarding: с недель до дней.

### 12.5.6 Результат 6 — Стандарт как продаваемый продукт

При RENAR-4/5 нативная для носителя реализация может быть лицензирована партнёрам как actionable продукт. Структурное следствие formal standard, не процессная метрика.

---

## 12.6 Независимый от носителя сбор метрик

### 12.6.1 Нормативные требования

Носитель, реализующий RENAR на уровне RENAR-4+, обязан обеспечить **автоматический сбор** §12.3 метрик через:

| Источник | Capabilities | Accessible |
|---|---|---|
| Журнал аудита событий ([§10.13](10-lifecycle-qg.md#10.13)) | V1 + V6 | gate-passage events с timestamps, artifact-version, actor |
| COVERAGE-artifact ([§9.15](09-test-cases.md#9.15)) | V5 + V1 | counts approved/verified/total; pos/neg coverage; stale-rate |
| AI-provenance frontmatter fields | V6 | cost-budget, cost-actual, generated-by, generated-at |
| Reconciliation журнал аудита | V1 + V6 | reconciliation runs + ID списка находок |
| Critic-runs журнал аудита (RENAR-5) | V1 + V6 | critic runs + severity classifications |

Носитель без доступа к любому из источников выше **не** может реализовать RENAR-4/5 ([§11.7.1](11-maturity-model.md#11.7.1), [§11.8.1](11-maturity-model.md#11.8.1)).

### 12.6.2 Нативные для носителя панели мониторинга (dashboards)

Формат (UI/CLI/report-generation) специфичен для носителя; стандарт не нормирует визуализацию. Носитель обязан экспортировать метрики в machine-readable формате для внешнего аудита (§13.6 third-party assessment). Шаблоны dashboard — `guide/`.

### 12.6.3 Агрегация по периодам (period aggregation)

Per артефакт — Hallucination Rate, Cost per Approved Requirement; per period (sprint/неделя/месяц) — Coverage Velocity, Reconciliation Findings/Week, ACR; per release — DRA; continuous trending — Multi-model Disagreement Rate, Test-spec Drift Rate. Period boundaries фиксируются в манифесте ([§13.4.2](13-conformance.md#13.4.2)) `declared-stricter` или принимаются по умолчанию.

---

## 12.7 Сопоставление с метриками SENAR (mapping)

Полное сопоставление десяти метрик SENAR §9 с REQ-уточнениями из §12.3.

| SENAR метрика (§9) | REQ-уточнение из §12.3 |
|---|---|
| Throughput | + Coverage Velocity (§12.3.8) — на уровне требований |
| Lead Time | + RDLT (§12.3.1) — для requirements phase |
| FPSR (First-Pass Success Rate) | + REQ-FPSR (доля артефактов, прошедших QG-0 без переделки) — производное, не отдельная метрика §12.3 |
| DER (Defect Escape Rate) | + DRA (§12.3.5) — defects на приёмке |
| KCR (Knowledge Capture Rate) | (используется как есть; косвенно усиливается через §12.5.5 результата) |
| Cost Predictability | + variance Cost per Approved Requirement (§12.3.9) |
| Cost-per-task | + Cost per Approved Requirement (§12.3.9) — для requirements phase |
| MIR (Memory Integrity Rate) | (используется как есть; усиливается через V1 + V6 на RENAR-4+) |
| Cycle Time | + RDLT (§12.3.1) + Requirement-to-Task Latency (§12.3.2) — оба внутри SENAR Cycle Time |
| ADR (Adversarial Detection Rate) | + ACR (§12.3.6) — состязательный для requirements зоны |

Метрики, **не имеющие** SENAR аналога (новые в RENAR):

- Hallucination Rate (§12.3.3) — специфична для AI-generated artifacts.
- Multi-model Disagreement Rate (§12.3.4) — специфична для multi-model генерации.
- Test-spec Drift Rate (§12.3.7) — специфика requirement-version pinning V5.
- Reconciliation Findings per Week (§12.3.10) — специфика continuous reconciliation.

---

## 12.8 Связь с другими главами

| Глава | Связь |
|---|---|
| [02 Положение в типологии методологий](02-methodology-positioning.md) | [§2.3](02-methodology-positioning.md#2.3) инверсия источника истины + [§2.4.2](02-methodology-positioning.md#2.4.2) continuous reconciliation — фундамент для §12.3.10 Reconciliation Findings |
| [07 ADAPT](07-adapt.md) | [§7.4.5](07-adapt.md#7.4.5) backward findings — input для §12.3.10; delta-ADAPT — измеряется через §12.3.5 DRA |
| [08 Specifications](08-specifications.md) | [§8.5.7](08-specifications.md#8.5.7) SPEC-AI continuous evaluation — связана с §12.3.4 Multi-model Disagreement Rate |
| [09 Test cases](09-test-cases.md) | [§9.12](09-test-cases.md#9.12) last-run — input для §12.3.7 Drift Rate; [§9.15](09-test-cases.md#9.15) COVERAGE — источник для §12.3.8 Velocity и §12.3.7 |
| [10 Жизненный цикл и QG](10-lifecycle-qg.md) | [§10.13](10-lifecycle-qg.md#10.13) журнал аудита событий — основа для всех §12.3 метрик; [§10.4.2](10-lifecycle-qg.md#10.4.2) QG-4 — gate, на котором фиксируется §12.3.5 DRA |
| [03 Версионирование носителя](03-substrate-versioning.md) | V1 + V5 + V6 — capabilities обязательные для нативного для носителя сбора §12.3 метрик (§12.6.1) |
| [11 Модель зрелости](11-maturity-model.md) | §12.3 цели по уровням RENAR-3/4/5 — конкретизация уровневых критериев из [§11.4](11-maturity-model.md#11.4)–[§11.8](11-maturity-model.md#11.8) |
| [13 Соответствие](13-conformance.md) | §12.3 метрики — вход для [§13.5](13-conformance.md#13.5) самооценки; превышение порогов (например, Hallucination Rate > 5% на RENAR-4) — триггер потери соответствия [§13.8.1](13-conformance.md#13.8.1) |

