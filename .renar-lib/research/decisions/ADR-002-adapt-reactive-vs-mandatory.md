---
adr: 002
title: ADAPT-full vs ADAPT-light для simple delta-ТЗ
status: superseded
superseded-by: ADR-006
superseded-date: 2026-05-26
date: 2026-05-26
context-gap: GAP-02 (GitLab Issue #2, reporter vsoglaev)
affects:
  - standard/00-introduction.md §0.5.1 (MVR-3 reformulation)
  - standard/07-adapt.md §7.4.1, §7.8.1, новый §7.13
  - standard/13-conformance.md §13.3.3
  - reference/02-schemas.md (ADAPT schema bump)
  - scripts/check-adapt-mode.js (new gate)
  - core/renar-core.md
version-impact: minor-version bump → v1.1
implements-task: gap-02-adapt-reactive
---

# ADR-002: ADAPT-full vs ADAPT-light

## Контекст

Партнёр (vsoglaev, GitLab Issue #2) обоснованно указывает: §7.4.1 устанавливает безусловное правило «каждое ТЗ обязано иметь ровно один корневой ADAPT». MVR-3 §0.5.1 закрепляет это как mandatory clause. Но реально:

- Объёмное первичное ТЗ почти всегда порождает backward findings — ADAPT нужен.
- Простое delta-ТЗ с чётко описанным изменением может конвертироваться в RENAR без вопросов — full ADAPT с двойной подписью становится формальностью.

Партнёр предлагает: ADAPT создаётся только при наличии backward findings. Это нарушает MVR-3 структурно (non-uniform trace chain: иногда BR/SR имеют source.adapt, иногда source.tz). Альтернатива — двухрежимная schema.

## Решение

Ввести два режима ADAPT — `full` и `light` — через поле `mode` в frontmatter. **MVR-3 концептуально сохраняется** (ADAPT-per-ТЗ обязателен), но процессные издержки для simple delta снимаются.

### Mode `full` (дефолт, применим всегда)

Текущая norma §7.4.1 — двойная подпись, все 6 секций body, полный lifecycle (draft → review → client-ready → answered → approved → frozen).

### Mode `light` (опт-ин для simple delta)

Сокращённая schema:

| Элемент | full | light |
|---|---|---|
| Forward interpretation | mandatory, по разделам ТЗ | mandatory, может быть один блок на весь delta |
| Backward findings | mandatory section (даже если пуста) | omitted (`open-questions-count: 0` обязательно) |
| Term mapping | mandatory если применимо | optional |
| Double signature | client + architect | **architect-only** (если delta cosmetic) |
| Lifecycle | draft → review → client-ready → answered → approved → frozen | **draft → approved → frozen** |
| Categories допустимые | все 7 | **только terminology / scope** (если что-то ещё всплыло — escalate to full) |

### Предусловия применимости `light` (закрытый список)

ADAPT может быть создан в режиме `light` **только если все** условия выполнены:

1. `source-tz.delta-of` существует (light применим **только** для delta-ТЗ, не для первичного).
2. Объём delta ≤ 3 разделов исходного ТЗ.
3. Adversarial reviewer (§7.10.2) не нашёл backward findings.
4. Term mapping пустой или содержит только уже approved термины из родительского ADAPT.
5. Архитектор явно декларирует mode в frontmatter; гейт проверяет предусловия.

Если любое условие нарушено — гейт блокирует approve в `light` и требует переход в `full`.

### MVR-3 переформулировка (§0.5.1)

**Было:**
> MVR-3: каждое ТЗ обязано иметь ровно один корневой ADAPT в статусе `approved` с двусторонней client-side validation и двойной подписью.

**Станет:**
> MVR-3: каждое ТЗ обязано иметь ровно один корневой ADAPT в статусе `approved`. Режим (`full` или `light`) определяется §7.4.1. ADAPT в режиме `full` обязателен для первичного ТЗ и для delta-ТЗ, не удовлетворяющего предусловиям §7.4.1; ADAPT в режиме `light` допустим для delta-ТЗ при выполнении предусловий §7.4.1.

### Новый §7.13 — ТЗ↔RENAR-описание

Партнёр запросил концепцию различия языков (§GAP-02 п.2). Новый раздел в стандарте:

```
§7.13. Соотношение ТЗ и RENAR-описания

ТЗ — договорной документ на языке клиента. Инкрементный: первое ТЗ описывает
систему полностью, последующие — только дельты.

RENAR-описание — полное формализованное описание системы на языке AI-агента.
Всегда полное (не инкрементное): перед изменением системы создаётся новая
версия полного описания.

ADAPT — реактивный артефакт на стыке: фиксирует обратные находки, возникающие
при конвертации языка клиента в язык агента. Если конвертация без находок —
ADAPT-light; если с находками — ADAPT-full.
```

## Альтернативы (rejected)

| # | Альтернатива | Почему rejected |
|---|---|---|
| A | Сохранить ADAPT-always (текущая норма) | Партнёр обосновал реальный overhead для simple delta |
| B (партнёр) | ADAPT только при наличии backward findings | Non-uniform trace chain; ломает MVR-3 структурно |
| D | Auto-determinable: гейт сам решает нужен ли ADAPT | Сложно гарантировать «нет findings» без human-in-loop |

Принят **C** (компромисс) — сохраняет MVR-3 концептуально, снимает реальные издержки.

## Последствия

- **Minor-version bump → v1.1** (изменение MVR через §13.9 procedure).
- Schema bump для ADAPT.
- Новый гейт `check-adapt-mode.js`.
- Migration guide для существующих conformant проектов (default mode=full сохраняет backward compatibility).
- CLAUDE.md «Версионирование стандарта» → новая запись.

## Implementation tracking

Task: `gap-02-adapt-reactive`. Phase 4 в plan переработки (самая тяжёлая фаза).
