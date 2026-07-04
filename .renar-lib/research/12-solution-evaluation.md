# Solution Evaluation и QG-4

> Версия: черновик 0.1 (для обсуждения) | Дата: 2026-05-03
> Назначение: нормирование QG-4 (acceptance gate). BABOK Solution Evaluation knowledge area для REQ. Закрывает gap, выявленный в [01-positioning-vs-world-standards.md §3.5](01-positioning-vs-world-standards.md).
>
> Финальная нормативная форма — после пилота на 1-2 проектах с реальной приёмкой.

---

## 1. Не дублирует SENAR

SENAR §8 описывает QG-4 концептуально (Acceptance gate). SENAR не нормирует **конкретные процедуры приёмки** для проектов с клиентом, не описывает outcome-based evaluation.

REQ конкретизирует: **что именно проверяется на QG-4, какими artifacts, какими метриками, кто accountable**. Это не дублирование SENAR — это операционализация.

---

## 2. Связь с BABOK Solution Evaluation

BABOK v3 §8 Solution Evaluation охватывает:

- **Measure Solution Performance** (8.1) — измерение фактического performance.
- **Analyze Performance Measures** (8.2) — анализ результатов.
- **Assess Solution Limitations** (8.3) — что решение **не делает** хорошо.
- **Assess Enterprise Limitations** (8.4) — внешние ограничения.
- **Recommend Actions to Increase Solution Value** (8.5) — что делать дальше.

REQ адаптирует все 5 sub-areas как часть QG-4.

---

## 3. Что такое QG-4 в REQ

### 3.1 Определение

QG-4 (Acceptance Gate) — формальный gate перевода **release** проекта (или его части) в статус «принят клиентом». Не путать с QG-2 (verified — техническая верификация требования).

```
Требование lifecycle:           Release lifecycle:
draft → approved → verified     dev → uat → released → accepted
                       │                         │       │
                       │                         │       └── QG-4
                       └── QG-2                  └── QG-3 (verification gate)
```

### 3.2 Что проверяется на QG-4

**Не код, не тесты — outcomes.** Команда могла построить идеально работающую систему, которая не делает того, что нужно бизнесу. QG-4 ловит этот случай.

QG-4 проверяет:

1. **Все BR в release scope**: достигнуты ли заявленные business outcomes?
2. **Все KPI**: фактические значения vs target?
3. **Обнаруженные limitations**: что система не делает хорошо?
4. **Stakeholder satisfaction**: реальная оценка от клиента.
5. **Lessons learned**: что в следующем проекте делать иначе?

---

## 4. Frontmatter расширение для BR

Для measurement BR должен иметь outcome metric:

```yaml
business-outcome:
  measurement-type: kpi               # kpi | survey | observation | usage
  kpi-name: "Sales Cycle Time"
  measurement-method: "Daily aggregation from Princess CRM"
  baseline-value: 14.0                # дни (до проекта)
  baseline-measured-at: 2026-04-01
  target-value: 10.0                  # дни (после релиза)
  target-met-by: 2026-08-01           # дата, когда должны достичь
  current-value:                       # auto-updated после релиза
    value: 11.5
    measured-at: 2026-07-15
    achievement: 80%                  # (baseline - current) / (baseline - target)
```

---

## 5. Pipeline QG-4

```
[Code released to production / final UAT]
      │
      ▼
PHASE 1 — Wait for measurement window
   ├── Each BR имеет measurement window (1 неделя — 6 месяцев)
   └── KPI tracked through Princess / external systems
      │
      ▼
PHASE 2 — Measure
   ├── Auto-collect KPI values (через kai_search метрики)
   ├── Survey stakeholders (через Princess survey)
   └── Observe usage patterns (analytics)
      │
      ▼
PHASE 3 — Analyze
   ├── AI генерирует QG-4 report:
   │   ├── BR-by-BR achievement %
   │   ├── KPI trend graphs
   │   ├── Gap analysis (что не достигнуто, почему)
   │   └── Solution limitations (BABOK 8.3)
   ├── Adversarial critic — что упущено в анализе
   └── Multi-model: альтернативные интерпретации данных
      │
      ▼
PHASE 4 — Stakeholder review
   ├── Report презентуется stakeholders
   ├── Stakeholder feedback (acceptance / partial / rejection)
   └── Lessons learned session
      │
      ▼
PHASE 5 — Recommend Actions (BABOK 8.5)
   ├── Что accept (закрывается)
   ├── Что нужно дельта-ТЗ (новые требования)
   ├── Что нужно fix (failed BR — gap from target)
   └── Что нужно discontinue (BR оказался неактуальным)
      │
      ▼
PHASE 6 — Sign-off
   ├── Формальная приёмка release
   ├── BR обновляются: status → accepted (новый terminal state)
   └── Lessons → Project memory + Brain
```

---

## 6. Lifecycle BR с QG-4

Расширение существующего lifecycle:

```
draft → approved → verified → accepted
                                  │
                                  ├── (Phase 5) decision: keep
                                  │
                          OR ─────┼── decision: needs delta-TZ
                                  │
                          OR ─────┴── decision: discontinue (deprecated)
```

Новый статус: **`accepted`** (BR прошёл QG-4 с achievement ≥ target).

Расширение `requirement_meta.status` enum в Raven: `draft | review | approved | verified | accepted | obsolete`.

---

## 7. QG-4 report (auto-generated)

Структура `<project>.src/QG-4-REPORT.md` (или сохраняется в Princess для клиента):

```markdown
# QG-4 Acceptance Report — <project> Release v<X>

Generated: 2026-08-01
Period covered: 2026-05-01 — 2026-07-31
Stakeholder review: 2026-08-15

---

## Executive summary

| Status | Count |
|---|---|
| BRs accepted (target met) | 8 |
| BRs partial (50-99%) | 2 |
| BRs failed (< 50%) | 1 |
| BRs deprecated (no longer relevant) | 1 |

**Overall release acceptance**: 8/12 BRs fully accepted = **67%**

---

## BR-by-BR

### BR-01: Сократить sales cycle ✓ ACCEPTED
- KPI: Sales Cycle Time
- Baseline: 14.0 days → Target: 10.0 days → Actual: 9.5 days
- Achievement: 113%
- Stakeholder feedback: "Beat the target. Sales team is happy."

### BR-04: Автоматизировать onboarding ⚠ PARTIAL
- KPI: Onboarding completion rate
- Baseline: 60% → Target: 90% → Actual: 75%
- Achievement: 50%
- Gap analysis: Email notifications не triggered в 25% случаев
- Recommended action: delta-TZ для investigate + fix

### BR-09: Multi-language support ✗ FAILED
- KPI: Non-English session rate
- Baseline: 5% → Target: 30% → Actual: 8%
- Achievement: 12%
- Gap analysis: Marketing на non-EN рынки не запущено (внешний blocker)
- Recommended action: Discontinue or replan with marketing team

---

## Solution Limitations (BABOK 8.3)

1. **Performance under load**: При >1000 concurrent users latency p99 > 500ms (target was < 300ms)
2. **Mobile UX**: Form usability на mobile хуже desktop (survey scores)
3. **Integration coverage**: 12 CRM systems integrated, target was 20

## Enterprise Limitations (BABOK 8.4)

1. Marketing didn't launch promised campaigns affecting BR-09
2. Compliance review для AI features delayed by 6 weeks

## Lessons Learned

- AI-генерация требований работала хорошо (RDLT 1.8 days vs target 2 days).
- Multi-model для priority=must БУДЕТ КЛЮЧЕВЫМ — нашли 3 серьёзных issues.
- Stakeholder survey должен запускаться раньше (не дожидаться full release).

## Recommended Actions

| BR | Action |
|---|---|
| BR-04 | Open delta-TZ-2026-NNN: investigate notification delivery |
| BR-09 | Pause; revisit when marketing campaigns launch |
| BR-12 | Discontinue (stakeholder confirmed not needed anymore) |
| Performance | New SR-NN: optimize query performance |
| Mobile UX | New UIC-NN: mobile-first redesign |
```

---

## 8. Skill `/req-evaluate`

```
/req-evaluate start --release <release-id>
   — открывает QG-4 cycle для конкретного release

/req-evaluate measure
   — Phase 2: collect KPI values, run surveys
   — auto-update business-outcome.current-value во всех BR

/req-evaluate analyze
   — Phase 3: generate QG-4 report
   — adversarial + multi-model

/req-evaluate review --stakeholder <id>
   — Phase 4: stakeholder review session

/req-evaluate finalize
   — Phase 5-6: stakeholder sign-off, BR status updates
   — generate lessons learned
```

---

## 9. Метрики QG-4

| Метрика | Что показывает | Цель |
|---|---|---|
| BR Achievement Rate | (BRs accepted) / (BRs in release) | ≥ 80% для зрелых проектов |
| KPI Realisation | avg achievement % across все BR с KPI | ≥ 90% |
| Time-to-Acceptance | От release до formal acceptance | < 90 days |
| Survey Score | Stakeholder satisfaction 1-5 | ≥ 4.0 |
| Limitation Rate | (BRs with significant limitations) / total | ≤ 20% |
| Lessons-learned actionability | (lessons converted to project changes) / total lessons | ≥ 70% |

---

## 10. Связь с другими частями REQ

| Аспект | Где |
|---|---|
| KPI tracking infrastructure | [04-metrics-and-outcomes.md](04-metrics-and-outcomes.md) §2.1 |
| Multi-model для analysis | [02-agent-driven-principles.md Принцип 4](02-agent-driven-principles.md) |
| Adversarial review | [02-agent-driven-principles.md Принцип 2](02-agent-driven-principles.md) |
| Reconciliation | [02-agent-driven-principles.md Принцип 7](02-agent-driven-principles.md) — после QG-4 reconciliation проверяет, что accepted BRs не drift |
| Knowledge graph | [16-req-graph-schema-draft.md](16-req-graph-schema-draft.md) — accepted BRs становятся precedent для будущих проектов |

---

## 11. Continuous Solution Evaluation

QG-4 — discrete event при release. Но BABOK 8.1 «Measure Solution Performance» подразумевает **continuous**.

Расширение для долгосрочных проектов:

- KPI отслеживаются всегда (после `verified`).
- Если BR `accepted` со временем drifts вниз (KPI деградирует) — alert.
- Reconciliation-агент создаёт MR с пометкой «BR-NN no longer meeting target» → triggers re-evaluation.

Это превращает QG-4 из «one-shot» в long-term governance механизм.

---

## 12. Open questions

- [ ] Measurement window для разных доменов: для sales — недели; для UX — месяцы; для compliance — годы. Как нормировать?
- [ ] Surveys: SUS (System Usability Scale)? NPS? Custom? Нужна стандартизация.
- [ ] Когда BR с failed achievement переводится в `deprecated`, а когда в delta-TZ for fixing? Эвристика?
- [ ] Lessons learned — где storage? Brain (cross-project)? `<project>.req/lessons/`?
- [ ] QG-4 для internal projects (где нет client'а)? Subset процесса?
- [ ] AI Act conformity assessment — может ли быть частью QG-4 для AI-systems? Скорее да, как extension.
- [ ] Continuous evaluation cost: KPI tracking ad-infinitum дорого. Sunset criteria когда BR можно перестать мониторить?
