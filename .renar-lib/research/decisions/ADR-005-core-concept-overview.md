---
adr: 005
title: Core — переориентация из «облегчённого стандарта» в concept overview
status: accepted
date: 2026-05-26
supersedes: ADR-004
context-gap: GAP-04 (GitLab Issue #4, reporter vsoglaev, comment 17:24 UTC)
affects:
  - core/renar-core.md (полный rewrite ≤ 200 строк)
  - core/README.md
  - standard/00-introduction.md §0.6.2, §0.6.3, §0.6.4, callout §0
  - standard/01-scope.md §1.5.4 (core-mode boundary case)
  - standard/05-roles.md §5.5.3 (упоминания core minimal-mode)
  - standard/13-conformance.md §13.2.1, §13.4 (core-mode в manifest)
  - guide/00-quickstart.md (предпосылка «знакомство с RENAR Core»)
  - mkdocs.yml (Core как обзорная страница)
version-impact: cosmetic в Core (non-normative); но §1.5.4 core-mode выпиливается из conformance — это minor change через §13.9 (внутри тех же v1.2-draft бамп, что и ADR-006)
implements-tasks:
  - adr-005-core-pivot
  - core-rewrite-overview
  - core-mode-deprecation
  - intro-0-6-update
  - guide-and-references-cleanup
---

# ADR-005: Core — переориентация в concept overview

## Контекст

Партнёр (vsoglaev) в GitLab Issue #4, comment 17:24 UTC, отверг компромисс ADR-004 (альт. C — BR-light как абзац-преамбула) и предложил архитектурный pivot Core:

> *Вообще, подход «core» — облегчённый для малых команд применяется для упрощения использования. Но в данном случае так как мы декларируем использование AI агента для работы со стандартом — это будет вносить только путаницу (агенту что брать, core или весь стандарт), при этом не принеся особых выгод — агент замечательно будет работать и по полному стандарту. Я бы в коре вынес бы просто основные идеи без технических подробностей — для быстрого понимания читающего.*

Партнёрский аргумент логически вытекает из принятого §0.2.4 (AI-агент как штатный исполнитель, ADR-003):

1. §0.2.4 декларирует AI как primary author.
2. AI без проблем читает все 15 глав Standard — нет «слишком большой» для AI.
3. → Core как «облегчённая версия для small teams» теряет смысл: small teams тоже используют AI-агента + Standard.
4. → Two-tier model (Core simplified rules + Standard full rules) — путает агента (что брать?) и не приносит выгоды.
5. → Core нужен как **концептуальный обзор для человека-читателя**, без технических деталей.

## Решение

Core переориентируется из «облегчённого стандарта для small teams» в **concept overview для человека-читателя**: что такое RENAR на верхнем уровне, зачем, как работает концептуально, кому пригодится, где читать дальше. Без alternative технической модели.

ADR-004 переводится в статус `superseded`.

### Что меняется

#### 1. core/renar-core.md — полный rewrite

**Удаляется:**
- «5 правил Minimum Viable RENAR» как conformance-уровень (это техническая структура).
- «1 обязательный артефакт — ADAPT» с frontmatter примером и schema.
- «2 шлюза качества (QG-ADAPT-approve, QG-2 Verification Gate)» с детальными checklists.
- BR-light (введён в ADR-004 / superseded).
- ADAPT-light (введён в ADR-002 / superseded).
- Минимальный сквозной пример с YAML frontmatter SR-03, TC-15, TC-16, BR-1 преамбулой.
- Таблица «Соответствие правил Core правилам Standard».
- Раздел «Триггеры перехода на полный RENAR Standard» (нет two-tier — есть Standard + обзор).
- «Когда переходить на RENAR Standard» (там же).

**Остаётся / переписывается:**
- «Что такое RENAR» (1–2 параграфа): нормативный стандарт инженерии требований для AI-нативной разработки.
- «Зачем» (drift, contract-oriented, audit trail): мотивация существования стандарта.
- «Как работает концептуально» (без правил, без frontmatter, без QG): TZ → опциональный ADAPT → BR/SR/SPEC → TC → код; объяснение SoT inversion на верхнем уровне.
- «Кому пригодится»: заказная разработка, regulated industries, enterprise консалтинг, public-sector IT.
- «Маршруты по ролям»: ссылочные пути для PM/RTE, Legal/Compliance, Regulator/Auditor, RE engineer/Architect (без дублирования содержания, только pointers).
- «Где читать дальше»: links to `standard/`, `guide/`, `reference/`.

Целевой объём: ≤ 200 строк (текущий ~445).

#### 2. core/README.md — обновить

«Облегчённый для малых команд» → «концептуальный обзор RENAR».

#### 3. §1.5.4 core-mode boundary case — депрекация

`core-mode` ранее существовал как conformance mode для «internal product без external client» с **optional client-signature** ADAPT. С AI-primary author и реактивным ADAPT (ADR-006) этот escape hatch теряет смысл:

- Если ТЗ есть и Stakeholder идентифицируем — full conformance применим.
- Если ТЗ нет или Stakeholder отсутствует — это §1.5 negative scope (lean startup / pure discovery / internal R&D), стандарт неприменим вовсе.
- Middle ground «internal product с одним лицом за обе стороны» — нарушение §5.5.3 (two independent persons in signatures); не подменяется core-mode.

§1.5.4 переписывается: internal product без external client → §1.5 negative scope без core-mode escape hatch.

Соответственно удаляются упоминания core-mode / `mode: core` в:
- §13.2.1 (conformance levels).
- §13.4 (conformance manifest schema).
- §5.5.3 (negative scenarios двойной подписи).
- mkdocs.yml (если Core описан как conformance mode).

#### 4. §0.6 — пересмотреть позиционирование Core

- §0.6.2 «Вспомогательные каталоги»: Core описывается как «concept overview, non-normative» (вместо «gentle introduction»).
- §0.6.3 «Рекомендованный порядок чтения»: для AI-агента — Standard напрямую; для человека — Core overview → Standard или guide/.
- §0.6.4 «Маршруты читателей»: синхронизировать с новыми маршрутами Core.
- Callout в начале §0 («Новичкам — начните с core/renar-core.md (≈20 мин)...») — пересмотреть time-to-read.

#### 5. guide/00-quickstart.md — переформулировать «Предпосылки»

«Предпосылки: знакомство с RENAR Core (5 правил + ADAPT + 2 QG)» → «Предпосылки: концептуальное знакомство с RENAR (см. core/renar-core.md, ≤ 10 мин)».

## Альтернативы (rejected при принятии ADR-005)

| Alt | Описание | Почему rejected сейчас |
|---|---|---|
| A | Сохранить ADR-004 BR-light | Партнёр явно отверг как недостаточный — оставляет two-tier model, путающую AI-агента |
| B | Удалить директорию core/ полностью | Жёстко: концептуальный overview всё-таки полезен человеку перед погружением в 15 глав Standard |
| **C (принято)** | Core → concept overview без техдеталей | Закрывает аргумент партнёра: убирает two-tier model для AI, сохраняет обзор для человека |
| D | Inline `business-context` field в SR + удалить core/ | Не закрывает «обзорной» функции; разрезает смысловой слой по SR |

## Последствия

### Архитектурные

- **Two-tier model RENAR (Core simplified + Standard full) → upgraded to single-tier**: один Standard + один concept overview.
- `core-mode` как conformance mode — устаревает; conformance manifest упрощается.
- Migration guidance для существующих core-mode проектов: либо признать full RENAR conformance, либо переклассифицироваться в §1.5 negative scope.

### Operational

- AI-агент работает только с Standard. Core — для человека, не для AI.
- Documentation reading paths упрощаются.
- mkdocs / site/ возможно — Core теряет отдельный раздел в навигации (или становится «landing» одной обзорной страницы).

### Не меняется

- Standard (15 глав) — не меняется.
- guide/, reference/ — не меняются (кроме cross-refs на Core).
- §0.2.4 AI-роль (ADR-003) — наоборот, **усиливается** как обоснование pivot.
- ADR-001 (implements-edge) — не затрагивается.

## Migration guidance

Для существующих core-mode проектов (если такие были созданы):

1. Re-assess scope:
   - Если ТЗ + external Stakeholder есть → upgrade на full RENAR-N с manifest re-issue.
   - Если ТЗ нет или Stakeholder отсутствует → re-classify в §1.5 negative scope (без RENAR conformance заявления).
2. core-mode upgrade не automatic — требует human decision о scope/applicability.

## Implementation tracking

Tasks (5):
- `adr-005-core-pivot` (this document)
- `core-rewrite-overview` — полный rewrite renar-core.md
- `core-mode-deprecation` — §1.5.4, §13.2.1, §13.4, §5.5.3 cleanup
- `intro-0-6-update` — §0.6.2, §0.6.3, §0.6.4, callout §0
- `guide-and-references-cleanup` — guide/00, core/README, sweep всех cross-refs на «Правило 1», «QG-ADAPT-approve» (как педагогический псевдоним), «5 правил MVR»
