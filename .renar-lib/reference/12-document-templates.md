---
title: "Шаблоны документов BR / SR / TR / TC"
description: "Copy-paste заготовки артефактов RENAR (frontmatter + тело) — возможная реализация нормативных схем глав 6 и 9."
order: 12
lang: ru
version: "1.0-draft"
---

# Шаблоны документов BR / SR / TR / TC

> **Статус:** informative. Это **возможная реализация** нормативных схем — организации могут дорабатывать заготовки под свой носитель и редакционные конвенции. Нормативный текст, который шаблоны лишь иллюстрируют: [`standard/06`](../standard/06-requirements-hierarchy.md) (BR / SR / TR) и [`standard/09`](../standard/09-test-cases.md) (TC). При расхождении заготовки и главы стандарта **главенствует глава**.
>
> **Закрытый список не затрагивается:** приложение даёт заготовки для уже нормированных типов; новые типы артефактов или SPEC добавляются только через формальную процедуру изменения стандарта ([глава 13](../standard/13-conformance.md)).

---

## 12.1 Статус и как пользоваться

Каждый раздел ниже содержит две заготовки: блок `yaml` с frontmatter (с построчными комментариями об обязательности полей) и блок `markdown` со скелетом тела. Чтобы получить готовый файл артефакта, склейте обе части в один документ носителя: frontmatter сверху, тело — следом.

Соответствие заготовок нормативным схемам:

| Артефакт | frontmatter (норма) | Разделы тела (норма) |
|---|---|---|
| BR | [§6.5.2](../standard/06-requirements-hierarchy.md#6.5.2) | [§6.5.3](../standard/06-requirements-hierarchy.md#6.5.3) |
| SR | [§6.6.2](../standard/06-requirements-hierarchy.md#6.6.2) | [§6.6.3](../standard/06-requirements-hierarchy.md#6.6.3) |
| TR | [§6.7.2](../standard/06-requirements-hierarchy.md#6.7.2) | [§6.7.3](../standard/06-requirements-hierarchy.md#6.7.3) |
| TC | [§9.3](../standard/09-test-cases.md#9.3) | [§9.4](../standard/09-test-cases.md#9.4) |

Условные обозначения в заготовках: `<...>` — плейсхолдер для замены; `NN` — порядковый номер в рамках scope; комментарий `# conditional` помечает поле, обязательность которого зависит от условия (поясняется тут же); `# auto` — поле, которое ведёт носитель/runner, автор его не заполняет вручную.

---

## 12.2 Шаблон BR

BR фиксирует бизнес-потребность на уровне системы или подсистемы; технические детали в BR запрещены ([§6.5.1](../standard/06-requirements-hierarchy.md#6.5.1)). Frontmatter — по [§6.5.2](../standard/06-requirements-hierarchy.md#6.5.2); тело — по [§6.5.3](../standard/06-requirements-hierarchy.md#6.5.3).

```yaml
---
id: BR-NN                            # неизменяемый; NN — порядковый в рамках scope
title: "<краткое описательное название>"
type: BR
slug: "<kebab-case>"                 # выводится автоматически

# === Scope (обязательно) ===
level: system | subsystem            # BR на уровне модуля запрещён (§6.4)
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null, если level=system

# === Жизненный цикл (обязательно) ===
status: draft | approved | verified | deprecated
owner: "<роль / ответственное лицо>"

# === Источник: происхождение (см. §7.4.1) ===
source:
  tz-section: "§N.N"                 # обязательно всегда — первичное происхождение из TZ
  adapt: ADAPT-NNN                   # conditional: присутствует, если ADAPT создавался
  adapt-section: "Forward §N"        # обязательно, если задано adapt
  adversarial-review-ref: "<ссылка-носителя>"  # conditional: при отсутствии adapt — свидетельство вердикта «нет находок» (§7.4.1.2)

# === Межуровневая связь BR подсистемы → BR системы (см. §6.8.2) ===
implements:                          # массив; не parent-edge, отдельный тип ребра
  - id: BR-NN                        # ID BR родительской системы
    scope:
      system: "<system-id>"
    rationale: "<кратко>"            # опционально; ссылка на раздел ADAPT при наличии

# === Граф связей (ведётся носителем) ===
children: []                         # auto: SR со ссылкой parent.id = этот BR
implemented-by: []                   # auto: BR подсистем, ссылающиеся через implements[]
verified-by: []                      # auto: TC, верифицирующие через SR

# === Происхождение от ИИ (обязательно на RENAR-4+; схема — §4.10.1) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<дата>"
  generated-at: "<ISO-8601>"
  human-edits: boolean

# === Замена (обязательно, если применимо) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO-дата>"
---
```

```markdown
## Потребность

Кто (роль), что (действие), зачем (бизнес-цель) — одно предложение.

## Критерии успеха

1. <Измеримый результат, поддающийся независимой проверке.>
2. <…> (всего 3–7 пунктов.)

## Контекст

Откуда взялось требование (со ссылкой на раздел ADAPT при наличии); какие
альтернативы рассматривались.

## Ограничения

<Опционально: бизнес-ограничения — бюджет, сроки, регуляторика. Технические
ограничения здесь не место — для них существуют типы SPEC и SR.>
```

Поле `source.tz-section` присутствует всегда; `source.adapt` опускается, когда состязательный обзор вынес вердикт «нет находок» — тогда обязателен `source.adversarial-review-ref` ([§7.4.1](../standard/07-adapt.md#7.4.1)).

> **Где в BR «требования».** В шаблоне BR намеренно нет раздела с формулировками вида «система должна …»: в RENAR такие формулировки — это SR ([§6.6](../standard/06-requirements-hierarchy.md#6.6)), производные от данного BR. Смешение их с BR размывает границу «бизнес-потребность ↔ требование к системе» и порождает «технические BR», неотличимые от SR ([§6.4](../standard/06-requirements-hierarchy.md#6.4), [§6.5.1](../standard/06-requirements-hierarchy.md#6.5.1)). Проверяемое, перечислимое содержание самого BR несёт раздел **«Критерии успеха»**: 3–7 измеримых, независимо проверяемых результатов — это и есть бизнес-требования в проверяемой форме. Декомпозиция BR → SR превращает каждый критерий в одно или несколько нормативных SR (форма «система должна …» по [§6.6.3](../standard/06-requirements-hierarchy.md#6.6.3)).

---

## 12.3 Шаблон SR

SR фиксирует, что делает система (наблюдаемое поведение и ограничения); имена таблиц, фреймворков и структур данных — ответственность SPEC ([§6.6.1](../standard/06-requirements-hierarchy.md#6.6.1)). Frontmatter — по [§6.6.2](../standard/06-requirements-hierarchy.md#6.6.2); тело — по [§6.6.3](../standard/06-requirements-hierarchy.md#6.6.3).

```yaml
---
id: SR-NN                            # неизменяемый
title: "<краткое описательное название>"
type: SR
slug: "<kebab-case>"

# === Scope (обязательно) ===
level: system | subsystem | module
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null, если level=system
  module: "<module-id>"              # null, если level ≠ module

# === Жизненный цикл (обязательно) ===
status: draft | approved | verified | deprecated
owner: "<роль / ответственное лицо>"

# === Родитель (обязательно) ===
parent:
  id: BR-NN                          # единственный родитель

# === Источник: происхождение (см. §7.4.1; правила те же, что у BR) ===
source:
  tz-section: "§N.N"                 # обязательно всегда
  adapt: ADAPT-NNN                   # conditional
  adapt-section: "Forward §N"        # обязательно, если задано adapt
  adversarial-review-ref: "<ссылка-носителя>"  # обязательно, если adapt опущено

# === Граф связей ===
constrained-by:                      # типизированные рёбра к SPEC (глава 8)
  - SPEC-UI-NN
  - SPEC-API-NN
  - SPEC-DATA-NN
children: []                         # auto: TR со ссылкой parent.id = этот SR
verified-by: []                      # auto: TC, верифицирующие SR

# === Происхождение от ИИ (обязательно на RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<дата>"
  human-edits: boolean

# === Замена (обязательно, если применимо) ===
replaces: "<old-id>"
replaced-by: "<new-id>"
deprecated-date: "<ISO-дата>"
---
```

```markdown
## Требование

Одно предложение нормативной формы: «Система должна …» (модальность — по
конвенции §0.5).

## Поведение

Детальное описание наблюдаемого поведения; функциональные сценарии.

## Ограничения

<Обязательно, если применимо: нефункциональные ограничения — производительность,
безопасность. Полные ограничения выносятся в SPEC через constrained-by[].>

## Связь с SPEC

<Обязательно при наличии constrained-by[]: какие аспекты поведения нормированы
какими SPEC.>
```

`parent.id` — единственный BR (дерево родителей); `constrained-by[]` — граф ссылок на SPEC любого типа и в любом числе ([§6.6.2](../standard/06-requirements-hierarchy.md#6.6.2)).

---

## 12.4 Шаблон TR

TR — атомарная единица работы исполнителя: что именно реализовать в рамках одного SR ([§6.7.1](../standard/06-requirements-hierarchy.md#6.7.1)). Frontmatter — по [§6.7.2](../standard/06-requirements-hierarchy.md#6.7.2); тело — по [§6.7.3](../standard/06-requirements-hierarchy.md#6.7.3).

```yaml
---
id: TR-NN                            # неизменяемый
title: "<краткое описательное название>"
type: TR
slug: "<kebab-case>"

# === Scope (обязательно) ===
level: system | subsystem | module   # system — редко, кросс-подсистемные задачи
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null, если level=system
  module: "<module-id>"              # null, если level ≠ module

# === Жизненный цикл (обязательно) ===
status: draft | approved | done | obsolete
owner: "<роль исполнителя / агент>"

# === Родитель (обязательно) ===
parent:
  id: SR-NN                          # единственный родитель

# === Источник: цепочка прослеживаемости (наследуется от parent SR, §6.7.5) ===
source:
  adapt: ADAPT-NNN                   # auto: наследуется от parent SR; может отсутствовать
  sr-version: "<version-ref>"        # фиксация к версии SR (возможность носителя V5)

# === Граф связей ===
implements-spec:                     # типизированные рёбра к SPEC
  - SPEC-API-NN
  - SPEC-UI-NN
verified-by: []                      # auto: TC, верифицирующие через SR

# === Цель и критерии приёмки ===
goal: "<результат в одном предложении>"
acceptance-criteria:
  - "<нумеруемое, опровержимое, без двусмысленности>"
  - "<…>"

# === Происхождение от ИИ (обязательно на RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<дата>"
  human-edits: boolean
---
```

```markdown
## Goal

Один параграф; результат, который TR делает наблюдаемым.

## Acceptance Criteria

1. <Опровержимый критерий; покрывает положительный сценарий.>
2. <Опровержимый критерий; покрывает отрицательный сценарий / границу.>

## Scope

Что входит и что **не** входит в TR (соответствует SENAR Rule 2).

## Ссылки

<Обязательно, если применимо: на SPEC из implements-spec[] и разделы
родительского SR.>
```

Имена секций `Goal`, `Acceptance Criteria`, `Scope` — канонические по [§6.7.3](../standard/06-requirements-hierarchy.md#6.7.3). Исполнитель TR работает в рамках SR / SPEC и к ADAPT напрямую не обращается ([§6.7.5](../standard/06-requirements-hierarchy.md#6.7.5)).

---

## 12.5 Шаблон TC

TC верифицирует нормативное утверждение BR / SR / SPEC; общий frontmatter — по [§9.3](../standard/09-test-cases.md#9.3), тело — по [§9.4](../standard/09-test-cases.md#9.4). Type-specific поля (`judge`, `baseline` для `ux` / `eval`) добавляются поверх по [§9.6](../standard/09-test-cases.md#9.6).

```yaml
---
# === Идентичность (обязательно) ===
id: TC-NN                            # неизменяемый; NN — порядковый в рамках scope
title: "<краткое описательное название>"
type: TC
slug: "<kebab-case>"

# === Классификация (обязательно) ===
tc-type: acceptance | ux | system | contract | eval | security
negative: boolean                    # true для парного негативного TC

# === Scope (обязательно) ===
level: system | subsystem | module
scope:
  system: "<system-id>"
  subsystem: "<subsystem-id>"        # null, если level=system
  module: "<module-id>"              # null, если level ≠ module

# === Жизненный цикл (обязательно) ===
status: draft | ready | passing | failing | obsolete

# === Цель верификации (обязательно; хотя бы одна) ===
verifies:
  - id: SR-NN | BR-NN | SPEC-<TYPE>-NN
    requirement-version: "<version-ref>"   # фиксация версии артефакта (V5)

# === Парная связь (обязательно, если negative=false и парный существует) ===
paired-with:
  - TC-NN

# === Автоматизация (обязательно) ===
automation:
  status: automated | manual-pending
  location: "<ссылка-носителя на реализацию>"  # обязательно, если automated
  manual-pending-until: "<ISO-дата>"           # обязательно, если manual-pending
  manual-pending-reason: "<текст>"             # обязательно, если manual-pending

# === Прогон (обязательно для tc-type: ux | eval) ===
judge:
  vendor: "<provider>"               # обязательно; изоляция судьи — P7
  model: "<model-id>"
baseline:                            # обязательно для ux | eval
  artifact: "<ссылка-носителя>"
  perceptual-diff-threshold: float   # для ux
  metric-thresholds: {}              # для eval

# === Последний прогон (ведёт runner; автор не заполняет) ===
last-run:                            # auto
  date: "<ISO-datetime>"
  result: pass | fail | skipped | n/a
  runner-id: "<runner-name@version>"

# === Происхождение от ИИ (обязательно на RENAR-4+) ===
ai-provenance:
  generated-by: "<vendor>-<model>@<дата>"
  human-edits: boolean
---
```

```markdown
## Контекст

На какой пункт верифицируемого артефакта ссылается TC; цитата или пересказ
утверждения.

## Предусловия

Состояние системы и данных, требуемое для прогона; обеспечивается
seed-механизмом.

## Шаги

Действия runner. Для tc-type: ux — намерения, не селекторы (§9.6.1).

## Pass-критерий

Бинарный, наблюдаемый, воспроизводимый (§9.11).

## Fail-критерий

Перечень наблюдаемых признаков нарушения (не отрицание Pass-критерия): утечки,
side-effects, состояния гонки.

## Постусловия

Какое состояние ожидается после прогона; cleanup-механизм.

## Out of scope

Что **намеренно** не проверяется, с указанием парного TC, где это покрыто.
```

Заголовки `## Pass-критерий` и `## Fail-критерий` фиксированы: их детектирует хук контроля смены критериев ([§10.11.3](../standard/10-lifecycle-qg.md#10.11.3)) — локально переименовывать нельзя. Раздел «Out of scope» обязателен: его отсутствие блокирует переход TC в `ready` ([§9.4](../standard/09-test-cases.md#9.4)).

---

## 12.6 SPEC-шаблоны — отложены

Заготовки для типов SPEC ([глава 8](../standard/08-specifications.md)) в это приложение **намеренно не включены**. Партнёрское ревью отметило вопрос SPEC-заготовок как открытый: набор обязательных полей у SPEC-типов (UI, API, DATA, AI, SEC, INT) различается сильнее, чем у BR / SR / TR / TC, и преждевременная фиксация заготовки рискует прочитаться как нормативная.

Черновые наброски SPEC-заготовок ведутся в репозитории — `research/17-specification-schema-and-templates.md` (§5; внутренний черновик, на сайт не публикуется) — до отдельного решения. Когда решение будет принято, SPEC-заготовки добавляются сюда новым разделом — без изменения закрытого списка типов SPEC, который уже нормирован в [`standard/08 §8.2.2`](../standard/08-specifications.md#8.2.2) и [§8.3](../standard/08-specifications.md#8.3).

---

## 12.7 Заполнение плейсхолдеров и частые ошибки

| Плейсхолдер | Чем заменить | Частая ошибка |
|---|---|---|
| `BR-NN` / `SR-NN` / `TR-NN` / `TC-NN` | Порядковый ID в рамках scope (носитель присваивает при создании) | Менять ID после публикации — он неизменяемый |
| `<system-id>` / `<subsystem-id>` / `<module-id>` | Идентификаторы из реестра систем проекта | Заполнять `subsystem`, когда `level=system` (должен быть `null`) |
| `source.tz-section` | Раздел исходного TZ — присутствует всегда | Опускать его, полагая, что хватит ссылки на ADAPT |
| `constrained-by[]` / `implements-spec[]` | ID существующих SPEC | Указывать тип SPEC вне закрытого списка |
| Поля `# auto` (`children`, `verified-by`, `last-run`) | Ничего — их ведёт носитель / runner | Заполнять вручную и расходиться с графом связей |

Плейсхолдеры вида `BR-NN` и пустые `<...>` — это незаполненная заготовка, а не валидный артефакт: пропускайте такие файлы через проверки только после подстановки реальных значений, иначе валидаторы носителя справедливо отклонят шаблонные ID.

---

[← К обзору справочника](README.md)
