---
title: "Size & Readability Audit"
description: "Diagnostic-отчёт по корпусу RENAR v1.2-draft перед compression-passes. Без правок корпуса."
date: 2026-05-27
status: diagnostic
target-version: v1.3-draft
---

# Size & Readability Audit — RENAR v1.2-draft

> **Назначение.** Diagnostic-отчёт перед compression-passes (Фаза B). Без правок корпуса. На выходе — обоснованный per-file budget, перечень cut-кандидатов и план перехода к **layered access**-структуре.
>
> **Поводы аудита.** PDF 500+ страниц нечитаем для человека; ни один из четырёх entry-doc'ов не даёт «RENAR за 30 секунд»; ключевые концепты («8 классов дрейфа», «9 типов SPEC», «V1–V6») цитируются в **половине корпуса** и **переписываются** в каждом месте, а не ссылаются.
>
> **Target version.** v1.3-draft: цель **−51 %** (15 318 → ~7 500 строк) + появление осевой структуры L0/L1/L2 + on-ramp в каждом normative-файле.

---

## 0. TL;DR

1. **Корпус сейчас**: 41 файл, 15 318 строк, 103 158 слов, 12.4 MB PDF (~500 стр.).
2. **SENAR для масштаба**: 107 строк, 848 слов. Дословное равенство нереально (нормативка vs single-doc методология), но **порядок** избыточности — двукратный.
3. **Главная проблема — не объём, а конструкция корпуса**: контент написан для машинного читателя и assessor-а, не для человека, открывающего стандарт впервые. Симптомы:
   - **0 секционных on-ramp'ов**: ни один normative-файл не даёт 30-секундной выжимки «зачем читать, что получишь, что пропустить».
   - **4 entry-doc'а конкурируют** за позицию «первая страница» (`README.ru`, `core/renar-core`, `standard/README`, `standard/00`), каждый со своим набором концептов, ни один не выполняет функцию L0.
   - **Концепты переписываются, а не цитируются**: «8 классов дрейфа» воспроизведены в 20 файлах, «9 типов SPEC» — в 11, «V1–V6» — в 28. При расхождении формулировок (а оно есть) читатель теряется.
4. **Realistic target — 7 500 строк** при условии не только обрезки, но и **structural rebuild**: один L0, один L1 на главу, нормативные детали как L2.

---

## 1. Baseline

### 1.1 Размер по каталогам

| Каталог | Файлы | Строки | Слова | Доля строк |
|---|---:|---:|---:|---:|
| `standard/` | 16 | 5 951 | 47 831 | 38.9 % |
| `core/` | 2 | 180 | 1 362 | 1.2 % |
| `guide/` | 12 | 4 242 | 23 280 | 27.7 % |
| `reference/` | 12 | 4 945 | 30 685 | 32.3 % |
| **Итого** | **41** | **15 318** | **103 158** | **100 %** |

### 1.2 Топ-15 файлов по объёму

| # | Файл | Строки | Доля корпуса |
|---:|---|---:|---:|
| 1 | `reference/06-ru-style-guide.md` | 2 023 | 13.2 % |
| 2 | `guide/01-walkthrough.md` | 739 | 4.8 % |
| 3 | `reference/02-schemas.md` | 697 | 4.6 % |
| 4 | `standard/10-lifecycle-qg.md` | 654 | 4.3 % |
| 5 | `standard/06-requirements-hierarchy.md` | 635 | 4.1 % |
| 6 | `guide/00-quickstart.md` | 580 | 3.8 % |
| 7 | `standard/09-test-cases.md` | 577 | 3.8 % |
| 8 | `guide/06-compliance.md` | 510 | 3.3 % |
| 9 | `guide/08-developer-guide.md` | 504 | 3.3 % |
| 10 | `reference/03-ai-risk-register.md` | 496 | 3.2 % |
| 11 | `reference/05-knowledge-graph-schema.md` | 451 | 2.9 % |
| 12 | `standard/07-adapt.md` | 440 | 2.9 % |
| 13 | `standard/08-specifications.md` | 432 | 2.8 % |
| 14 | `standard/13-conformance.md` | 424 | 2.8 % |
| 15 | `standard/04-terms.md` | 418 | 2.7 % |
| | **топ-15 итого** | **9 580** | **62.5 %** |

> 15 файлов из 41 содержат **63 %** корпуса. Сюда направлены основные cut-усилия.

### 1.3 Структурная избыточность

- 1 500 заголовков на 41 файл = **~37 заголовков/файл в среднем**.
- `reference/` — 137 H4-заголовков (over-decomposition; единственная директория с массовой 4-й глубиной).
- 4 уровня вложенности в `standard/` и `reference/` (`§4.10.1.1`, `§1.5.2.1`) — даёт boilerplate transitions.

---

## 2. Ось 1 — Bloat & duplication

### 2.1 Cross-corpus duplication: ключевые концепты

| Концепт | В скольких файлах **переписан** (не сослан) |
|---|---:|
| 8 классов дрейфа | **20** |
| V1–V6 capabilities | **28** |
| 9 типов SPEC | **11** |
| MVR-1…7 | 6 |
| QG-0…QG-4 (полный список) | 9 |

> **Что значит «переписан, а не сослан»**: в файле есть собственная нумерованная таблица или список, повторяющий определения, а не одна строка вида «см. [§3.3](...)».

> При **расхождении формулировок** это активный источник конфликтов: например, `standard/04 §4.11` и `core/renar-core` дают drift-классы с разной структурой и разной enforcement-привязкой; `reference/01 §2.7` и `standard/03 §3.3` — V1–V6 с разной длиной описаний и разными примерами носителей.

### 2.2 Высокоудельные пары дубликатов

| # | Пара | Стр.суммарно | Природа дубля | Оценка cut'а |
|---:|---|---:|---|---:|
| D1 | `standard/04-terms.md` ↔ `reference/01-glossary.md` | 824 | Оба содержат 9 SPEC types, 6 TC types, lifecycle, V1–V6, mapping ISO/BABOK/SAFe, forbidden terms, QG closed list, legacy labels. Различаются только тоном. | **−500..−550** |
| D2 | `guide/00-quickstart.md` ↔ `guide/01-walkthrough.md` | 1 319 | Два сквозных примера одного сценария «login flow». В quickstart — «email/password sign-up», в walkthrough — «Login Flow для AcmeCorp» с 2FA. Структура шагов идентична (ТЗ → ADAPT → BR → SR → SPEC → TC), разница в масштабе. | **−500..−600** |
| D3 | `reference/02-schemas.md` ↔ `reference/05-knowledge-graph-schema.md` | 1 148 | `02` — frontmatter schemas (поля артефактов). `05` — node/edge types + Cypher queries. Концептуально разные, но 70 % node/edge type definitions = переформулировка того, что в `02-schemas` уже есть как поля. | **−300..−400** |
| D4 | 4 entry-doc'а: `README.ru.md` + `core/renar-core.md` + `standard/README.md` + `standard/00-introduction.md` | 678 | Все четыре имеют разделы «что такое RENAR», «куда дальше», маршруты по ролям. Тройное-четырёхкратное повторение. См. ось 3. | **−250..−350** |

> Итого только по D1–D4 — потенциал **1 550..1 900** строк (10..12 % корпуса) без потери нормативного содержания.

### 2.3 Single-file bloat

| Файл | Текущ. | Диагноз | Цель |
|---|---:|---|---:|
| `reference/06-ru-style-guide.md` | 2 023 | Внутренний style-linting tool в публичном reference. Buckets A–F с exhaustive replacement tables, density measurement, application protocol, phase-5 invocation. Большая часть — операционная процедура linting'а, не справочный материал. | **≤ 400** (или вынос ядра в `scripts/lint-style.js` + thin reference) |
| `reference/03-ai-risk-register.md` | 496 | Register обычно — компактная таблица. 496 строк = таблица + нарратив + примеры + cross-refs. | **≤ 250** |
| `standard/10-lifecycle-qg.md` | 654 | 5 state machines × подробные предусловия × hooks enforcement. Возможна агрессивная экстракция в `reference/02-schemas` (state tables) + сжатие prose. | **≤ 450** |
| `standard/06-requirements-hierarchy.md` | 635 | Три типа требований растянуты на 19 H2. §6.5 / 6.6 / 6.7 — frontmatter per type — допускают exemplar consolidation. | **≤ 450** |
| `standard/09-test-cases.md` | 577 | TC types × pos/neg paritet × adversarial × VLM-judge × runners. Каждая подсекция содержит свой пример — много повторов. | **≤ 400** |

### 2.4 Reference/ over-decomposition

137 H4-заголовков в `reference/` — структурная аномалия. На большинство H4-секций приходится 3-7 строк содержимого + 2-3 строки заголовка/перехода. Расчёт: 137 × ~3 строки overhead × 0.5 = ~200 строк boilerplate, удаляемых через подъём H4 → H3 c простым inline-перечислением.

---

## 3. Ось 2 — Human readability

### 3.1 Метрика, которой нет, но должна быть: «30-секундный on-ramp»

В каждом файле проверено: дают ли первые 30 строк ответ на вопросы «зачем читать, кому, что получишь, что пропустить»?

| Файл | On-ramp present? | Что вместо |
|---|---|---|
| `standard/00-introduction.md` | ⚠️ Частично | Callout «новичкам — идите в core» + сразу §0.1 «зачем эта глава» в виде нормативной прозы. |
| `standard/04-terms.md` | ❌ Нет | §4.1 — длинный навигационный bullet-список секций главы. |
| `standard/06-requirements-hierarchy.md` | ❌ Нет | §6.1 — сразу нормативный тезис + ссылки на 6 других глав. |
| `standard/10-lifecycle-qg.md` | (не проверено в этом проходе — likely no) | — |
| `core/renar-core.md` | ✅ Да | Callout «что это / время чтения / для кого» — единственный файл с правильным on-ramp. |
| `guide/00-quickstart.md` | ⚠️ Частично | «Что получите» есть, но через 8 строк начинается «носитель (substrate) — система…» — слишком быстрый прыжок в термины. |
| `reference/01-glossary.md` | ❌ Нет | Сразу §1 «цепочка авторитетности» — для assessor-а, не для первого читателя. |
| `reference/02-schemas.md` | ❌ Нет | Без преамбулы — сразу `## 1. Common frontmatter`. |

> **Итог оси 2**: один файл из 41 (`core/renar-core.md`) сделан правильно. Все остальные normative-главы открываются формальной прозой или нормативным тезисом.

### 3.2 Что мешает человеку

**(a) Сразу-в-формализм.** Пример из [`standard/04-terms.md:14`](../standard/04-terms.md):

> «Глава нормирует **canonical терминологию RENAR**: одно определение на одну концепцию; единый источник истины для других глав, реализационных носителей, conformance-инструментов. Терминологический drift (§4.11) — отдельный класс нарушений conformance (§13.3.1 косвенно).»

Это первые 2 содержательные строки. Читатель, впервые открывший файл, не знает что такое **canonical**, **conformance**, **drift**, **носитель**. Файл должен был открыться парой «BR / SR / TR — это про что, на одном примере». Этого нет.

**(b) Каскады cross-refs.** Тот же файл выше — 7 ссылок на 5 разных глав в одном вводе. Это не интеграция, это отказ от роли.

**(c) Аббревиатуры до определения.** [`standard/00-introduction.md:14`](../standard/00-introduction.md): «MVR (минимально жизнеспособный RENAR; §0.5)» — введено в §0.1 со ссылкой вперёд на §0.5; читатель должен прыгнуть, прочитать определение, вернуться.

**(d) Длина и плотность предложения.** [`standard/00-introduction.md:48-49`](../standard/00-introduction.md) — 5-строчное предложение с 12 канцеляризмами и тройным придаточным. Norm — ≤ 2 строки, ≤ 2 субъекта.

### 3.3 «Жаргон-плотность» — приближённая метрика

Сэмпл по 4 файлам (первые 100 строк, после frontmatter):

| Файл | Canonical IDs / 100 строк | Latin tokens / 100 строк | Длина среднего предложения |
|---|---:|---:|---:|
| `core/renar-core.md` | ~18 | ~25 | 14 слов |
| `standard/00-introduction.md` | ~45 | ~70 | 22 слова |
| `standard/04-terms.md` | ~60 | ~85 | 19 слов |
| `reference/01-glossary.md` | ~40 | ~55 | 17 слов |

Core-файл — единственный в норме. Остальные — за пределом редакционной нормы style-guide'а (≤1 latin token на нормативное предложение).

---

## 4. Ось 3 — Layered access

### 4.1 Текущая структура «4 entry-doc'а» — дисфункциональна

Все четыре файла пытаются быть «первой страницей»:

| Файл | Стр. | Заявленная роль | Фактически содержит |
|---|---:|---|---|
| `README.ru.md` | 78 | Repo landing | TL;DR + roadmap чтения + 9 SPEC types + ключевые концепты |
| `core/renar-core.md` | 151 | «≤ 10 мин концепт-обзор» | Что такое + зачем + цикл + AI-агент + кому + маршруты — **функционально правильный L0**, но не позиционирован как единственный |
| `standard/README.md` | 88 | Оглавление stand'а | Что мы делаем + статус + оглавление + куда дальше |
| `standard/00-introduction.md` | 283 | Нормативное введение в Standard | MVR + 8 классов дрейфа + связь с SENAR + структура + RU policy |

**Перекрытия**:
- «Что такое RENAR» — в 4 из 4 файлов.
- «Куда дальше / маршруты по ролям» — в 4 из 4.
- 9 типов SPEC явно перечислены — в 3 из 4.
- 8 классов дрейфа — в 2 из 4 (полная таблица в `standard/00` + numbered list в `core`).
- MVR-1..7 — в 1 из 4 (только `standard/00`), но MVR-нумерация упоминается в `core` и `README.ru`.

### 4.2 Предлагаемая модель L0 / L1 / L2

| Слой | Документ | Цель | Объём | Кто читает |
|---|---|---|---:|---|
| **L0** | `core/renar-core.md` (uplifted) | «RENAR за 5 минут» — single page, парабола + одна схема + 5 свойств + «кому подходит» | 100..130 строк | 90 % первых читателей |
| **L1** | per-chapter intro panel (вшит в каждый normative-файл — первые 25–40 строк) | TL;DR главы для решающего «нужна ли мне эта глава» | 25..40 × 15 файлов = 375..600 строк | Implementer, partner-reviewer, любой кто решает что читать дальше |
| **L2** | основное тело normative-глав | Полная нормативная детализация | ~4 500 строк | Assessor, AI-агент, deep-dive engineer |

Текущие 4 entry-doc'а консолидируются:

- `README.ru.md` → ультра-сжатый landing (≤ 40 строк): что это в одном абзаце + ссылки на L0 + лицензия/статус.
- `core/renar-core.md` → **единственный L0**. Текущая версия 1.2-draft уже близка к этой роли — нужны мелкие чистки + добавление одной central diagram.
- `standard/README.md` → только TOC + краткий subtitle к каждой главе (≤ 50 строк); вся проза «что мы делаем» переезжает в L0.
- `standard/00-introduction.md` → **сокращается до 100..120 строк**: убирается дубль drift-classes, дубль MVR-описаний (оставить таблицу MVR + ссылку на §13.3), убирается дубль «структура документа», RU-policy → callout в каждой главе или в `reference/06`.

**Выигрыш L0/L1/L2-рекомпозиции**: −300..−400 строк по entry-doc'ам + появление навигационного слоя, которого сейчас нет.

---

## 5. Per-file proposed budget

Колонки: `cur` — текущие строки; `tgt` — предложенный target; `Δ` — ожидаемое изменение; `priority` — H/M/L по объёму выигрыша и риску.

### 5.1 standard/

| Файл | cur | tgt | Δ | priority | Основание |
|---|---:|---:|---:|---|---|
| `00-introduction.md` | 283 | 120 | −163 | **H** | Убрать дубль drift-classes (есть в `core` L0), дубль MVR-описания (оставить только таблицу), дубль структуры. RU-policy → callout. |
| `01-scope.md` | 267 | 200 | −67 | M | Закрытые списки оставить; убрать переходные параграфы между §1.4 / §1.5 / §1.6. |
| `02-methodology-positioning.md` | 241 | 180 | −61 | M | SoT inversion + waterfall-form — основное; ужать «независимое от носителя версионирование» (дубль с §3). |
| `03-substrate-versioning.md` | 247 | 200 | −47 | L | Уже компактная; убрать примеры носителей (есть в `reference/01 §2.7`). |
| `04-terms.md` | 418 | **150** | −268 | **H** | Слить с `reference/01-glossary.md` в единый глоссарий ≤ 200 строк, размещённый в `reference/01`. В `standard/04` оставить только closed-list canonical терминов (200 → 150 при стол6цовой компрессии). |
| `05-roles.md` | 291 | 220 | −71 | M | RACI-таблица + AI-роль; убрать дубль AI-роли с `standard/00 §0.2.4` и `core`. |
| `06-requirements-hierarchy.md` | 635 | **450** | −185 | **H** | §6.5/6.6/6.7 frontmatter per type — exemplar consolidation; пример BR/SR/TR — один общий, не три. |
| `07-adapt.md` | 440 | 340 | −100 | M | ADAPT-reactive сейчас новый — оставить core; ужать §7.4 — §7.6 (повторы между full vs reactive после ADR-006). |
| `08-specifications.md` | 432 | 320 | −112 | M | 9 типов SPEC: общая schema + 9 коротких type-specific блоков ≤ 20 строк каждый. Сейчас разнобой. |
| `09-test-cases.md` | 577 | **400** | −177 | **H** | TC types × pos/neg × adversarial × VLM × runners — каждый подузел со своим примером. Один сквозной пример. |
| `10-lifecycle-qg.md` | 654 | **450** | −204 | **H** | 5 state machines — табличной формы, не нарратив. Hooks enforcement (§10.11) — основной residual текст. |
| `11-maturity-model.md` | 365 | 250 | −115 | M | Checklist per level — компактнее в формате таблицы; убрать дубль с §13. |
| `12-metrics.md` | 352 | 270 | −82 | M | Метрика per row + formula + threshold — табличная компрессия. |
| `13-conformance.md` | 424 | 320 | −104 | M | Mandatory clauses ≡ MVR из §0.5 — оставить таблицу + assessor procedures + manifest schema. |
| `14-normative-refs.md` | 237 | 180 | −57 | L | Сама по себе таблица refs — компактна; убрать ad-hoc обоснования. |
| `README.md` | 88 | 50 | −38 | L | Чистый TOC. |
| **standard/ итого** | **5 951** | **4 100** | **−1 851** | | |

### 5.2 core/

| Файл | cur | tgt | Δ | priority | Основание |
|---|---:|---:|---:|---|---|
| `renar-core.md` | 151 | 130 | −21 | L | Уже близок к L0; добавить одну central diagram, удалить мелкие повторы с «штатный исполнитель — AI-агент». |
| `README.md` | 29 | 20 | −9 | L | Чистая landing-карточка. |
| **core/ итого** | **180** | **150** | **−30** | | |

### 5.3 guide/

| Файл | cur | tgt | Δ | priority | Основание |
|---|---:|---:|---:|---|---|
| `00-quickstart.md` | 580 | **250** | −330 | **H** | Сейчас sign-up flow на 580 строк. Quickstart — должен быть 200–250 строк, один минимальный пример. |
| `01-walkthrough.md` | 739 | **450** | −289 | **H** | Полноразмерный сквозной пример — оставить, но ужать. После сжатия quickstart дублирование уменьшится естественно. |
| `02-transition-guide.md` | 339 | 220 | −119 | M | Переход с SENAR / без него — концентрация. |
| `03-tool-guide-git.md` | 329 | 250 | −79 | M | git-specifics; держать практичными. |
| `04-document-store-substrate.md` | 66 | 50 | −16 | L | Уже компактный. |
| `05-safe-comparison.md` | 357 | 250 | −107 | M | Сравнение с SAFe — табличная компрессия. |
| `06-compliance.md` | 510 | 300 | −210 | **H** | 8 фреймворков × mapping; checklists — табличная компрессия. |
| `07-failure-modes.md` | 320 | 220 | −100 | M | Failure modes — каталог; один паттерн = ≤ 15 строк. |
| `08-developer-guide.md` | 504 | 300 | −204 | **H** | Реализация на git/document-store; убрать дубли с `03` / `04`. |
| `09-worked-examples.md` | 341 | 220 | −121 | M | Каталог примеров — каждый ≤ 30 строк. |
| `10-migration-v1.md` | 100 | 60 | −40 | L | Migration notes — фактически unused, сжать. |
| `README.md` | 57 | 40 | −17 | L | TOC. |
| **guide/ итого** | **4 242** | **2 610** | **−1 632** | | |

### 5.4 reference/

| Файл | cur | tgt | Δ | priority | Основание |
|---|---:|---:|---:|---|---|
| `01-glossary.md` | 406 | **200** | −206 | **H** | Слияние с `standard/04`; в reference остаётся «развёрнутая форма + mapping ISO/BABOK/SAFe + примеры», без дублирования closed-list определений. |
| `02-schemas.md` | 697 | **350** | −347 | **H** | Common schema + 4 артефакта (BR/SR/TR/SPEC) + TC; убрать комментарии-нарратив, оставить чистую schema. |
| `03-ai-risk-register.md` | 496 | **250** | −246 | **H** | 14 рисков → таблица с фиксированной длиной 1 строка/риск + cross-refs. |
| `04-ai-style-guide.md` | 390 | 250 | −140 | M | AI-style — компактные правила. |
| `05-knowledge-graph-schema.md` | 451 | **250** | −201 | **H** | Node/edge types — табличная форма; Cypher примеры — 3 ключевых вместо 7. |
| `06-ru-style-guide.md` | 2 023 | **400** | −1 623 | **H** | Внутренний линтинг → вынос buckets/replacement-таблиц в `scripts/lint-style.js`; в reference остаётся ≤ 400 строк публичного guideline. |
| `07-iso29148-trace-matrix.md` | 89 | 80 | −9 | L | Уже компактна. |
| `08-conformance-self-assessment.md` | 161 | 140 | −21 | L | Checklist — компактен. |
| `09-pedagogical-density.md` | 45 | 30 | −15 | L | Мини-док. |
| `10-agent-implementation-profile.md` | 74 | 60 | −14 | L | Мини-док. |
| `11-external-standards-mapping.md` | 71 | 60 | −11 | L | Мини-док. |
| `README.md` | 42 | 30 | −12 | L | TOC. |
| **reference/ итого** | **4 945** | **2 100** | **−2 845** | | |

### 5.5 Сводка

| Каталог | cur | tgt | Δ | Δ % |
|---|---:|---:|---:|---:|
| `standard/` | 5 951 | 4 100 | −1 851 | −31 % |
| `core/` | 180 | 150 | −30 | −17 % |
| `guide/` | 4 242 | 2 610 | −1 632 | −38 % |
| `reference/` | 4 945 | 2 100 | −2 845 | −58 % |
| **Итого** | **15 318** | **8 960** | **−6 358** | **−41 %** |

> Указанный budget даёт **−41 %**, что **выше** консервативной цели Balanced (~7 500, −51 %). Разрыв 8 960 vs 7 500 = 1 460 строк — допуск на L1-on-ramp'ы (25–40 строк × 15 файлов = 375..600) и на residual overhead. **Если L1-on-ramp'ы вписываются плотнее — выходим на 7 500.**

---

## 6. Top-10 cut-кандидаты (приоритезация Фазы B)

| # | Действие | Файлы | Выигрыш строк | Риск |
|---:|---|---|---:|---|
| 1 | **Вынос ядра `reference/06-ru-style-guide.md` в `scripts/lint-style.js` + thin reference** | `reference/06` | ~1 600 | Low (внутренний инструмент; cross-refs только из guide/08 и audit/) |
| 2 | **Merge `standard/04` + `reference/01` → один глоссарий** | `standard/04`, `reference/01` | ~470 | **Mid** (cross-refs из 20+ файлов; нужен sweep) |
| 3 | **Сжатие `guide/00-quickstart` и `guide/01-walkthrough`** (один минимальный пример + один полноразмерный без дублирования) | `guide/00`, `guide/01` | ~620 | Low |
| 4 | **Reorg `reference/02-schemas`** (чистая schema, без нарратив-комментариев) | `reference/02` | ~350 | Low (schemas — структурированный контент) |
| 5 | **Сжатие `standard/10-lifecycle-qg`** (state machines в табличной форме) | `standard/10` | ~200 | Mid (нормативная глава, нужна аккуратность) |
| 6 | **Consolidation 4 entry-doc'ов в L0/L1/landing** | `README.ru`, `core/renar-core`, `standard/README`, `standard/00` | ~300 | **Mid** (8 классов дрейфа, MVR, маршруты — теряют дубли, нужны redirect-ссылки) |
| 7 | **Сжатие `reference/03-ai-risk-register`** (фиксированный шаблон 1 строка/риск) | `reference/03` | ~250 | Low |
| 8 | **Сжатие `standard/06-requirements-hierarchy`** (frontmatter exemplar consolidation) | `standard/06` | ~185 | Mid |
| 9 | **Сжатие `guide/06-compliance`** (compliance mapping — таблица 1 строка/control) | `guide/06` | ~210 | Low |
| 10 | **Сжатие `standard/09-test-cases`** (один сквозной пример вместо повторов per-subsection) | `standard/09` | ~175 | Mid |
| | **Итого top-10** | | **~4 360** | |

> Top-10 покрывает **~70 %** общего budget'а. Остальной cut — россыпь по 50-100 строк/файл (boilerplate transitions, повторы rationale).

---

## 7. Риски и зависимости

### 7.1 Cross-ref impact

Слияние `standard/04 + reference/01` (cut #2) затрагивает cross-refs из 20+ файлов (где упоминается «8 классов дрейфа» с inline-перечислением). Требует:

- Аудит всех `[reference/01-glossary §X]` и `[standard/04 §X]` cross-refs.
- Принять решение: новые caнонические anchor'ы или редирект-таблица.
- Скрипт `scripts/check-md-links.js` уже есть — гонять после каждого merge'а.

### 7.2 Партнёрский ревью v1.2-draft

Сейчас 4 issue на ревью у `@vsoglaev` (handoff S#28). Compression-passes **не следует** начинать до закрытия issues — иначе следующий виток правок будет идти поверх свежесжатого корпуса с конфликтами.

**Рекомендация**: Фаза B стартует **после** закрытия 4 partner-issues и тега v1.2-draft.

### 7.3 Conformance integrity

Mandatory clauses §13.3 ≡ MVR §0.5.1. Любое сжатие в `standard/13` или `standard/00 §0.5` должно сохранять **точную нумерацию** MVR-1..MVR-7 и mandatory clauses §13.3.1..§13.3.7. Это нормативный invariant; gate-проверка через grep.

### 7.4 Гейты check:all

После каждого PR Фазы B обязательно гонять:

- `npm run check:all` (sync-site-content + validate-frontmatter + validate-schema-examples + check-md-links + check-site-parity + check-implements-edge + check-adapt-applicability)
- `mkdocs build` (RU + EN после v1.2 + EN epic)
- PDF rebuild (если затронуты top-3 главы по объёму) — для подтверждения снижения количества страниц.

### 7.5 Cite-not-rewrite policy

Предложение к v1.3: добавить convention в `reference/06` (или CLAUDE.md NEVER BREAK):

> «Концепты, нормированные в одной главе standard/, не воспроизводятся в других файлах в формате полной таблицы / списка. Допустимо только сослаться + дать одну строку summary. Voiлация — convention error при PR.»

Это **превентивная** мера: убирает источник проблемы, а не следствие. Можно добавить как gate (grep "8 классов дрейфа|drift class[a-z]*" + count > 1 → warn).

---

## 8. План перехода к Фазе B (compression)

### 8.1 Последовательность PR'ов (предлагаемая)

| Шаг | PR | Затраг. файлы | Δ строк | Зависимости |
|---:|---|---|---:|---|
| B1 | Style-guide → scripts/ + thin reference | `reference/06`, `scripts/lint-style.js` (new), `guide/08`, `audit/` | ~1 600 | — |
| B2 | Entry-doc consolidation (L0/L1/landing) | `README.ru`, `core/renar-core`, `standard/README`, `standard/00` | ~300 | — |
| B3 | Merge `standard/04 + reference/01` → unified glossary | `standard/04`, `reference/01`, sweep cross-refs | ~470 | B2 (для якорей) |
| B4 | Schemas reorg | `reference/02`, `reference/05` | ~550 | — |
| B5 | AI-risk-register compression | `reference/03` | ~250 | — |
| B6 | Quickstart vs walkthrough deduplication | `guide/00`, `guide/01` | ~620 | — |
| B7 | Standard chapter compression (10, 06, 09) | `standard/10`, `standard/06`, `standard/09` | ~560 | B3 (terms canonical) |
| B8 | Guide compliance + developer-guide compression | `guide/06`, `guide/08` | ~414 | B1 (scripts/) |
| B9 | Remaining standard chapters polish | `standard/01..03`, `05`, `07`, `08`, `11..14` | ~700 | B2, B3 |
| B10 | L1 on-ramp pass (вшить TL;DR в каждый normative-файл) | все `standard/*` | +375..600 | B9 |
| | **Net total** | | **~−5 500..−5 700** | |

Net target после Фазы B: **~9 700..9 800 строк** (на ~2 000 выше target Balanced 7 500). Для достижения Balanced требуется дополнительный pass (B11–B12) после первичной обкатки.

### 8.2 Когда стартовать

- ✅ После закрытия 4 partner-issues (`@vsoglaev` ревью v1.2-draft).
- ✅ После тега v1.2-draft (immutable reference point).
- ⚠️ Перед стартом EN-translation epic (иначе translate-then-cut = double work).

---

## 9. Открытые вопросы для следующего обсуждения

1. **Cite-not-rewrite gate** (§7.5) — добавлять как convention #65 в tausik memory или как gate `scripts/check-no-rewrite.js`?
2. **L0 vs `core/renar-core`** — оставить как есть `core/` или переместить в корень как `OVERVIEW.md`? Стратегия позиционирования: «core — это subdoc стандарта» vs «overview — это первая страница репозитория».
3. **Slot для PDF**: после compression target PDF ≈ 220 стр. (соотношение строк к страницам). Требовать ли L0 + L1 как отдельный PDF (~50 стр.) для не-implementers?
4. **`research/` каталог** — не вошёл в аудит (вне публикации). Аудит research нужен отдельно или это вне scope?
5. **Партнёрское согласование cut'ов**: Top-3 merge-операции (B1, B3, B6) затрагивают видимые публичные документы — нужно ли pre-review с `@vsoglaev` перед PR?

---

## 9bis. Decisions (зафиксированы 2026-05-27 после §9)

Пять открытых вопросов §9 закрыты партнёрским согласованием в сессии #29 (`tausik decisions #67..#71`):

| # | Решение | tausik ID | Триггер для |
|---:|---|---|---|
| 1 | **Cite-not-rewrite policy**: convention #66 + `scripts/check-no-rewrite.js` (warn-only до B7-B9, blocking после). | dec #67 + conv #66 | Все Phase B PR'ы; gate в `check:all`. |
| 2 | **L0 positioning**: `core/renar-core.md` остаётся L0; `README.ru.md` → ≤ 40 строк с первой ссылкой на core. `OVERVIEW.md` НЕ создаётся. | dec #68 | B2 (entry-doc consolidation). |
| 3 | **PDF strategy**: два PDF после B10. `RENAR-overview.pdf` (~50 стр; core + L1 panels) + `RENAR-v1.x.pdf` (~220 стр; полный normative). | dec #69 | B10 + `mkdocs.yml`. |
| 4 | **research/** — вне scope аудита и Phase B. Не редактируется. | dec #70 | (negative scope). |
| 5 | **Partner pre-review**: только B3 (glossary merge). B1, B6 и остальные — без partner ack; принцип «уведомить, не блокировать». | dec #71 | B3 → GitLab issue для `@vsoglaev`. |

**Что НЕ зафиксировано здесь, но решено в сессии #29**:

- Sequence Phase B стартует с **B1** (style-guide extraction) — наибольший cut при низком риске; не нормативно — partner ack не нужен.
- Epic `corpus-compression-v1-3` создан в tausik для трекинга B1–B10.

---

## 10. Что сделано в Фазе A

- ✅ Baseline собран (41 файл, 15 318 строк, 103 158 слов, 12.4 MB PDF).
- ✅ SENAR-reference измерен (107 строк) — confirms 2× избыточность как порядок.
- ✅ Top-15 файлов по объёму — определены (63 % корпуса).
- ✅ Cross-corpus duplication квантифицирован: 8 классов дрейфа × 20 файлов, V1–V6 × 28, 9 SPEC × 11.
- ✅ Пары D1–D4 — 1 550..1 900 строк потенциального cut'а без потери нормативного содержания.
- ✅ Single-file bloat: 5 файлов с обоснованной агрессивной обрезкой.
- ✅ Readability assessment по 8 ключевым файлам: только `core/renar-core` имеет on-ramp.
- ✅ Layered access model L0/L1/L2 — предложена, на основе текущих 4 entry-doc'ов.
- ✅ Per-file budget — 41 файл, аргументированные targets.
- ✅ Top-10 cut-кандидаты с оценкой выигрыша и риска.
- ✅ Phase B sequence — 10 PR'ов с зависимостями.

**Корпус не правился. Это диагностика.**
