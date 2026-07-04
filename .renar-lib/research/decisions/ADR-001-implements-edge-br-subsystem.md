---
adr: 001
title: implements-edge между BR подсистемы и BR системы
status: accepted
date: 2026-05-26
context-gap: GAP-01 (GitLab Issue #1, reporter vsoglaev)
affects:
  - standard/06-requirements-hierarchy.md §6.5.2, §6.8.2, §6.8.3, §6.10.3
  - standard/10-lifecycle-qg.md §10.11
  - standard/13-conformance.md §13.3
  - reference/02-schemas.md (BR schema)
  - scripts/check-implements-edge.js (new gate)
implements-task: gap-01-implements-edge
---

# ADR-001: implements-edge между BR подсистемы и BR системы

## Контекст

Партнёр (vsoglaev, GitLab Issue #1) обнаружил структурный gap в текущей §6.8.2:

- §6.8.1 (подсистема — техническое деление): SR подсистемы имеет `parent → BR (системы)`, цепочка `SR → BR → TC` машиночитаема целиком.
- §6.8.2 (подсистема — самостоятельный продукт): `BR (подсистемы)` — корневой узел, `parent` отсутствует. Связь с BR системы — только через текст «Контекст» и общий ADAPT. Машиночитаемая цепочка `BR (подсистемы) → BR (системы)` отсутствует.

Асимметрия: более ответственный сценарий (§6.8.2) трассируется хуже, чем более простой (§6.8.1). Декларация §6.10.3 о полной trace chain для §6.8.2 не выполняется.

## Решение

Ввести новый тип ребра графа связей — `implements[]` — в frontmatter BR. Семантика: «данный BR подсистемы раскрывает и реализует указанные BR системы». Это **не** parent-edge (запрет множественных parent §6.8.3 сохраняется); это межуровневая связь между двумя независимыми деревьями.

### Schema

```yaml
# === Граф связей с уровнем системы (mandatory если применимо) ===
implements:                  # массив; optional на v1.0
  - id: BR-NN                # ID BR родительской системы
    scope:
      system: "<system-id>"  # обязательно если cross-system

# === Auto-derived (обратное ребро) ===
implemented-by: []           # auto-derived; BR подсистемы со ссылкой implements[].id=<этот BR>
```

### Нормативные правила (proposed для §6.5.2 / §6.8.2)

1. `implements[]` — `mandatory если`: `level: subsystem` AND родительская система имеет хотя бы один approved BR.
2. `implements[]` — `optional с justification в Контексте`: если родительская система — контейнер без BR (например, organisational-level scope).
3. Cardinality: array (0..N); один BR подсистемы может раскрывать несколько BR системы (audit + uptime + …).
4. Cycle detection: цепочка `implements` не должна образовывать циклы.
5. Target BR обязан быть в статусе `approved`+ на момент approve BR подсистемы.
6. Cascade-warning (не cascade-deprecate) при deprecate target BR.
7. Cross-substrate semantics: `id + scope.system` substrate-agnostic; конкретное разрешение в путь — обязанность носителя.

### Обновлённая trace chain (§6.10.3)

```
TC → SR (подсистема) → BR (подсистема) ──implements──► BR (система)
                                        │
                                        └─ source.adapt → ADAPT-NNN
```

## Альтернативы (rejected)

| # | Альтернатива | Почему rejected |
|---|---|---|
| 1 | Текстовая ссылка `[[BR-XX]]` в разделе «Контекст» | Не машиночитаемо — не решает root cause |
| 2 | Связь через общий `source.adapt` | Слабая связь; один ADAPT может породить независимые BR |
| 3 | Разрешить `parent` для BR подсистемы | Ломает §6.5.2 («BR — корневой узел») и философию двух независимых деревьев |
| 4 | Игнорировать gap | Нарушает декларацию §6.10.3 о полной trace chain |

## Последствия

- v1.0-draft: поле `optional`. Существующие проекты не требуют миграции.
- v1.1: рассмотреть переход на `mandatory когда применимо` после feedback с pilot-проектов.
- Новый гейт `check-implements-edge.js` в `check:all`.
- Schema bump (reference/02-schemas.md).
- Не затрагивает MVR — не требуется formal change procedure §13.9.

## Implementation tracking

Task: `gap-01-implements-edge`. Phase 2 в plan переработки.
