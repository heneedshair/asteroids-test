---
title: "Самооценка соответствия"
description: "Печатный чек-лист, взаимное соответствие MVR↔§13.3, шаблон RENAR-CONFORMANCE.yaml для самооценки."
order: 8
lang: ru
version: "1.0-draft"
---

# Самооценка соответствия

> **Назначение:** практический kit для Tech Lead / Архитектор перед выпуском [RENAR-CONFORMANCE.yaml](../standard/13-conformance.md#13.4). Нормативная база — [standard/13](../standard/13-conformance.md). Этот документ **informative**; при расхождении побеждает standard/13.

---

<a id="1-mvr-mandatory-clauses-133-bijection"></a>

## 1. Взаимное соответствие MVR ↔ обязательные пункты §13.3

| MVR ([§0.5](../standard/00-introduction.md#0.5)) | Положение §13.3 | Поле `mandatory-clauses-confirmed` |
|---|---|---|
| MVR-1 инверсия источника истины | §13.3.1 | `sot-inversion: true` |
| MVR-2 V1–V6 | §13.3.2 | `substrate-v1-v6: { v1..v6: true }` |
| MVR-3 ADAPT per ТЗ | §13.3.3 | `adapt-per-tz: true` |
| MVR-4 9 типов SPEC | §13.3.4 | `spec-types-closed-list: true` |
| MVR-5 TC pos/neg | §13.3.5 | `tc-pos-neg-pairing: true` |
| MVR-6 QG — закрытый список | §13.3.6 | `quality-gates-closed-list: true` |
| MVR-7 манифест соответствия | §13.4 (артефакт) | манифест существует + подписан |
| — (политика закрытых списков) | §13.3.7 | `closed-lists-backward-findings: true` |

Все семь MVR + §13.3.7 обязательны для **любого** уровня RENAR-1..5.

---

<a id="2-self-assessment-checklist-mandatory-clauses"></a>

## 2. Чек-лист самооценки (обязательные положения)

Отметьте после проверки доказательной базы в носителе:

### §13.3.1 Инверсия источника истины

- [ ] Иерархия BR/SR/SPEC/TC — авторитетный источник о поведении
- [ ] Нет SR, восстановленных из кода без обоснования исправления дефекта
- [ ] Drift-hooks / политика обзора блокируют молчаливую адаптацию SR←код

### §13.3.2 Возможности V1–V6 (носитель)

- [ ] V1 immutable history — включён
- [ ] V2 atomic change unit — включён
- [ ] V3 diff & review — включён
- [ ] V4 branching / change-set — включён
- [ ] V5 сквозная фиксация версии между носителями — включена (`verifies[].requirement-version`)
- [ ] V6 author + timestamp — включён

### §13.3.3 ADAPT

- [ ] Каждое активное ТЗ имеет approved ADAPT
- [ ] Каждый delta-ТЗ имеет delta-ADAPT
- [ ] Двойная подпись (Архитектор + Клиент) зафиксирована

### §13.3.4 SPEC types

- [ ] Все SPEC ∈ {ARCH, API, DATA, INT, PROC, UI, AI, SEC, OPS}
- [ ] Нет локальных `SPEC-CUSTOM-*`

### §13.3.5 TC pos/neg

- [ ] Каждое верифицируемое утверждение имеет pos + neg TC (или исключение негативного инварианта)
- [ ] QG-2 блокирует `verified` при нарушении

### §13.3.6 Quality Gates

- [ ] QG-0, QG-1, QG-2 реализованы как `required`
- [ ] QG-3, QG-4 объявлены `required` | `declared` | `absent` в манифесте
- [ ] Нет локальных пользовательских гейтов

### §13.3.7 Закрытые списки

- [ ] Backward finding types — только закрытый список §7.4.4
- [ ] Типы декомпозиции SPEC — только закрытый список §8

**Правило:** хотя бы один не отмечен → манифест **не выпускать** ([§13.5.1](../standard/13-conformance.md#13.5.1)).

---

## 3. Чек-лист уровня (выберите целевой RENAR-N)

Минимум для заявления уровня — [standard/11 §11.4–12.8](../standard/11-maturity-model.md). Краткая сводка:

| Уровень | Ключевые доп. критерии |
|---|---|
| RENAR-1 | Только обязательные положения; frontmatter минимален |
| RENAR-2 | Канонический frontmatter + обеспечивается соблюдение статусов жизненного цикла |
| RENAR-3 | Полная ось SPEC + hooks на все QG-0..QG-2 |
| RENAR-4 | ai-provenance обязателен; состязательный обзор для SPEC-SEC/AI |
| RENAR-5 | Согласие нескольких моделей; непрерывная оценка; согласование KG |

- [ ] Выбранный `level` в манифесте **не выше** фактически пройденного чек-листа
- [ ] `declared-stricter` (если есть) документирован отдельно

---

## 4. Шаблон манифеста (минимальный)

Сохранить как `RENAR-CONFORMANCE.yaml` в корне носителя требований:

```yaml
manifest-version: 1
manifest-id: "CFM-YYYY-NNN"
renar-version: "1.0-draft"
senar-version: "1.0"
level: RENAR-2
assessment-date: "2026-05-22"
assessment-type: self
next-assessment-due: "2026-08-22"

mandatory-clauses-confirmed:
  sot-inversion: true
  substrate-v1-v6: { v1: true, v2: true, v3: true, v4: true, v5: true, v6: true }
  adapt-per-tz: true
  spec-types-closed-list: true
  tc-pos-neg-pairing: true
  quality-gates-closed-list: true
  closed-lists-backward-findings: true

quality-gates:
  qg-0: required
  qg-1: required
  qg-2: required
  qg-3: declared
  qg-4: absent

external-claims:
  - standard: "ISO/IEC/IEEE 29148:2018"
    scope: "requirements classes, attributes, lifecycle, verification"
    evidence: "reference/07-iso29148-trace-matrix.md"

substrate:
  type: git
  capabilities-verified: "2026-05-22"
  project-req-ref: "<нативный для носителя pointer>"

signed-by:
  name: "<Architect / Tech Lead>"
  role: approver
  signed-at: "2026-05-22T12:00:00Z"
```

Полный список полей — [§13.4.2](../standard/13-conformance.md#13.4.2).

---

## 5. Периодичность

- Самооценка: **квартально** (по умолчанию)
- После delta-ТЗ с воздействием на обязательные положения — **внепланово**
- Триггеры потери соответствия — [§13.8](../standard/13-conformance.md#13.8)

---

*Reference RENAR 1.0-draft — renar.tech*
