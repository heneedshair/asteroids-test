---
adr: 004
title: BR-light в RENAR Core
status: superseded
superseded-by: ADR-005
superseded-date: 2026-05-26
date: 2026-05-26
context-gap: GAP-04 (GitLab Issue #4, reporter vsoglaev)
affects:
  - core/renar-core.md (Ключевые термины, минимальный пример, триггеры перехода)
  - core/README.md (1 артефакт → +BR-light)
version-impact: none — Core non-normative, изменения cosmetic
implements-task: gap-04-br-in-core
---

# ADR-004: BR-light в RENAR Core

## Контекст

Партнёр (vsoglaev, GitLab Issue #4) обоснованно указывает: текущий Core пропускает BR (ADAPT → SR → TC). Партнёр прав:

- BR — фундаментальная единица смысла («зачем»), существующая в любом проекте независимо от размера команды.
- Из SR-03 «POST /auth/sign-up принимает email + password» не видно какую бизнес-потребность он реализует.
- ADAPT не заменяет BR: ADAPT фиксирует интерпретацию ТЗ + обратные находки; BR фиксирует бизнес-цель системы. Разные lifecycle: ADAPT — на каждое ТЗ; BR — стабильное описание, живёт дольше ТЗ.

Но: Core по дизайну — лёгкая дисциплина для small teams. Полноценный BR с frontmatter + lifecycle + двойная подпись → утяжеляет Core до уровня Standard.

## Решение

Ввести в Core **BR-light** — короткий смысловой слой без отдельного frontmatter, без отдельного lifecycle. Один абзац-преамбула перед группой связанных SR.

### Структура BR-light в Core

```markdown
## BR-1: Регистрация и доступ пользователя

**Зачем:** новый пользователь должен иметь возможность создать учётную запись
и получить доступ к личному кабинету. Без этого продукт неприменим для
end-customer use case.

**Источник:** ADAPT-001 §4.1 Forward.

**SR-группа:** SR-03 (sign-up), SR-04 (email verification), SR-05 (first login).

---
```

Минимум обязательного:
- Заголовок `## BR-N: <короткое название>`
- Параграф «Зачем» — 1-3 предложения.
- Ссылка на ADAPT§ — провенанс.
- Список SR-группы — обратная ссылка.

Чего нет (по сравнению с Standard §6.5):
- Нет yaml frontmatter с десятками полей.
- Нет отдельного lifecycle (draft/approved/verified/deprecated).
- Нет immutable ID требований на уровне поля (id в заголовке).
- Нет двойной подписи.
- Нет formal ai-provenance.

### Обновлённые «Ключевые термины» в core/renar-core.md

Добавить определение между ТЗ и ADAPT:

```
**BR (Business Requirement, бизнес-требование)** — бизнес-цель или потребность,
которую система должна удовлетворять. BR отвечает на вопрос «зачем», SR —
на вопрос «что». В Core достаточно короткой формы (абзац-преамбула); в Standard
BR — полноценный артефакт с frontmatter и lifecycle (§6.5).
```

### Обновлённая цепочка Core

```
ТЗ → ADAPT → BR-light → SR → TC
```

### Минимальный сквозной пример — обновление

Текущий пример идёт от ADAPT-001 §4.1 Forward сразу к SR-03. Вставить BR-1 между ADAPT и SR-03:

```markdown
### Шаг 3.5. BR-1 (выводится из ADAPT-001 §4.1 Forward)

## BR-1: Регистрация и доступ пользователя

**Зачем:** новый пользователь должен иметь возможность создать учётную запись
и получить доступ к личному кабинету. Без этого продукт неприменим для
end-customer use case.

**Источник:** ADAPT-001 §4.1 Forward.

**SR-группа:** SR-03 (sign-up), SR-04 (email verification), SR-05 (first login).
```

### Триггеры перехода Core → Standard — обновление

Добавить строку:

```
| Появилось > 1 BR с независимыми бизнес-владельцами →
  нужен полноценный BR с frontmatter, lifecycle, двойной подписью |
  Глава 6 §6.5 Requirements hierarchy
```

### Соответствие правил Core правилам Standard — обновление

Добавить новую строку:

```
| BR-light (абзац-преамбула) | Глава 6 §6.5 BR — Business Requirement |
```

## Альтернативы (rejected)

| # | Альтернатива | Почему rejected |
|---|---|---|
| A | Сохранить текущее (BR пропущен в Core) | Партнёр прав: бизнес-цель теряется в SR; ADAPT её не несёт |
| B (партнёр) | Полноценный BR в Core (с frontmatter, lifecycle) | Утяжеляет Core до уровня Standard; теряется differentiator |
| D | Inline `business-context` поле в SR | Дробит smyslовой слой по каждому SR; теряется группировка по бизнес-целям |

Принят **C** (BR-light как абзац-преамбула) — сохраняет лёгкость Core, восстанавливает смысловой слой «зачем».

## Последствия

- Core non-normative — изменения cosmetic, без version bump.
- Не меняется Standard.
- Не меняется MVR.
- Не добавляются гейты.
- Только онбординг улучшается.

## Implementation tracking

Task: `gap-04-br-in-core`. Phase 3.
