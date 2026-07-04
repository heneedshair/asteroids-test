# Положение RENARа в типологии методологий

> Версия: черновик 0.1 | Дата: 2026-05-11
> Статус: предложение к обсуждению с партнёром
> Назначение: зафиксировать три фундаментальных свойства RENARа, без которых остальные документы стандарта рассыпаются. Документ-обоснование; финальная нормативная форма — экстракт §N в `requirements-methodology.md`.

---

## 1. Не дублирует SENAR

SENAR описывает **ценности и правила** AI-native разработки (14 правил, 5 ценностей, QG-0..QG-4). SENAR **не фиксирует** позицию методологии в типологии (waterfall vs agile vs spec-driven), не нормирует требования к версионированию как substrate-свойству, не описывает инверсию «код vs спека как SoT».

RENAR закрывает эту дыру тремя нормативными утверждениями. Они логически связаны: без любого из них остальные документы стандарта (lifecycle, schema, quality gates, ADAPT, дельта-ТЗ workflow) теряют опору.

---

## 2. Три фундаментальных утверждения

### Утверждение 1 — Source of Truth inversion: требования, не код

**Что**: иерархия артефактов требований (ТЗ → ADAPT → BR / SR / SPEC → TR → TC) — единственный источник истины о поведении системы. Код — derived артефакт реализации. При расхождении побеждает требование.

**Зачем**:

В массовой инженерной практике (включая значительную часть AI-driven проектов) код де-факто становится спецификацией: люди читают код чтобы узнать «как оно работает», тесты подгоняются под текущее поведение, требования молча устаревают. Это и есть классический «requirements rot» — главный источник дрифта против которого SENAR изначально воюет.

RENAR переворачивает эту практику нормативно: код не является спецификацией ни в каком смысле, даже частично.

**Таблица ролей**:

| Уровень | Кто SoT | Кто derived |
|---|---|---|
| ТЗ | Договор с клиентом | — |
| ADAPT | Двусторонняя интерпретация ТЗ | derived from ТЗ |
| BR / SR / SPEC | Инженерный стандарт системы | derived from ADAPT |
| TC | Контракт поведения | derived from SR / SPEC |
| TR (задача) | Акт выдачи работы | derived from SR + SPEC |
| Код | Реализация | derived from всё вышестоящее |

**Контракт**:

- Pre-commit hook в implementation substrate: если diff кода ссылается на SR/SPEC, которого нет в requirements substrate — блок коммита (drift class 7.4).
- Code review проверяет соответствие коду; **отдельный** test-spec review проверяет соответствие TC требованиям. Это два разных гейта.
- При обнаружении расхождения «код делает X, SR говорит Y» — создаётся либо delta-TZ (если поведение правильное), либо bug-fix задача (если код не прав). Никогда: «обновим SR под код».
- AI-агент при генерации кода читает SR/SPEC как контракт. Запрещено reverse-engineering поведения из существующего кода для создания новых SR.

**Связь с мировыми стандартами**:

- ISO/IEC/IEEE 29148 §6.4.5 — Requirements management mandates traceability from requirements to implementation, not reverse.
- BABOK Guide §6.5 — Verify requirements before they drive solution work.
- Spec-Driven Development (термин 2024-2025): GitHub SDD framework, Anthropic spec-first work, Amazon Kiro — методологический тренд indus try признающий ту же инверсию.

---

### Утверждение 2 — Waterfall-форма, но не классический waterfall

**Что**: процесс RENAR имеет последовательную слоистую форму: ТЗ → ADAPT → BR/SR/SPEC → TR → код → TC-прогон. Слои, гейты, направленность. Это **waterfall-образная форма**, и стандарт это признаёт открыто.

Однако RENAR явно отстраивается от четырёх смертельных грехов классического waterfall (Royce, 1970, как его поняли индустрия и провалили в 1970–1990-х).

**Зачем явно проговаривать**:

Без явной позиции каждый ревьюер (партнёр, ISO 29148 аудитор, senior из enterprise) спотыкается на «а это же waterfall, мы же agile/CI/CD/DevOps». Standard должен иметь готовый ответ в самом тексте, а не оборонительно отбиваться при каждом ревью.

**Четыре отстройки от классического waterfall**:

| Классический waterfall (1970-х) | RENAR |
|---|---|
| Один большой проход «требования → дизайн → код → тесты» за квартал/год | **Дельта-ТЗ workflow**: каждое изменение — мини-цикл за дни/часы. «Фрактальный waterfall» — та же форма, повторяется сотни раз, быстро. |
| Тесты в конце, после реализации | **TC — first-class артефакт**, парные pos/neg, создаются вместе с SR/SPEC, не после кода. Ближе к V-model и ATDD, чем к waterfall. |
| Одностороннее «throw spec over the wall» | **ADAPT — двусторонний документ** по построению. Запрещено стандартом бросать спеку «через стену». |
| Спека написана один раз, потом неприкосновенна; реальность от неё уходит | **Continuous reconciliation hooks**: дрифт code↔spec детектится автоматически, попадает в delta-ТЗ. Спека живая. |

**Современное имя**: Spec-Driven Development (SDD) — термин, появившийся в 2024–2025 как осознание индустрией того, что AI-ускорение делает waterfall-форму снова жизнеспособной для контракт-ориентированной разработки. Reference frameworks: GitHub SDD, Anthropic spec-first agents, Amazon Kiro, BMAD-Method.

**Где RENAR применим**:

- Контракт-ориентированная разработка (есть договор с клиентом, есть подписанный ТЗ).
- Regulated industries (compliance, медицина, финтех, госсектор).
- Enterprise консалтинг (третья сторона делает продукт по чужому ТЗ).
- Проекты с высокой стоимостью изменений требований поздно в цикле.

**Где RENAR не применим** (или применим с оговорками):

- Чистый продуктовый дискавери без договорного контекста (lean startup, MVP сначала — потом понимаем что строим).
- R&D / исследование без определённых требований.

Это явно проговаривается, чтобы стандарт не пытались натянуть на неподходящие контексты.

**Контракт**:

Раздел 1 `requirements-methodology.md` начинается с подсекции «Положение в типологии» где прямо сказано: «RENAR is Spec-Driven Development, не классический waterfall и не agile». Четыре отстройки выше — нормативные свойства, а не оговорки.

---

### Утверждение 3 — Версионирование как обязательное substrate-свойство

**Что**: версионирование — **обязательное свойство любого substrate**, реализующего RENAR. Конкретный инструмент (Git / Mercurial / SVN / Perforce / CouchDB-Raven / любой будущий) — interchangeable. Стандарт нормирует **capabilities**, не tools.

**Зачем это нормативно**:

Утверждение 1 (SoT — требования) физически не работает без честного версионирования:

- Нельзя сказать «код собран против требований по состоянию на дату X» — пропадает provenance.
- Нельзя сделать delta-TZ — не от чего отсчитывать дельту.
- Нельзя верифицировать TC — поле `verifies[].requirement-version` теряет смысл.
- Нельзя продвинуть требование `verified → accepted` — гейт не на что опереться.
- Нельзя восстановить состояние «что мы сдавали клиенту по контракту 2025-Q3» при споре.

Версионирование — не «удобная фича Git», а техническая предпосылка SoT-инверсии. Поэтому substrate **без** версионирования (плоский файловый сервер, SharePoint с переименованием, любая система без immutable history) **не годится** для реализации RENARа независимо от других достоинств.

**Шесть обязательных capabilities любого substrate**:

| # | Capability | Что обязано уметь |
|---|---|---|
| V1 | **Immutable history** | Любое прошлое состояние артефакта адресуемо и восстановимо |
| V2 | **Atomic change unit** | «Изменение» — одна транзакция; всё или ничего |
| V3 | **Diff & review** | Человек видит что изменилось и может approve/reject до интеграции |
| V4 | **Branching / change-set** | WIP отделим от утверждённой правды (delta-ТЗ на отдельной ветке/changeset/документе-черновике) |
| V5 | **Version pin** | Implementation substrate (`.src`) может зафиксировать конкретную версию requirements substrate (`.req`) |
| V6 | **Author + timestamp** | На каждое изменение — кто и когда (provenance) |

**Mapping на конкретные инструменты**:

| Capability | Git | Mercurial | SVN | CouchDB / Raven |
|---|---|---|---|---|
| V1 immutable history | commits, hash-chain | changesets, hash-chain | revisions, sequential | revision tree per doc |
| V2 atomic | commit | commit | atomic revision | document update |
| V3 diff/review | PR / MR | hg phabricator, mq | svn diff + commit gate | API workflow + Hub UI |
| V4 branching | branches | named branches, bookmarks | branches (copy) | conflict branches / WIP docs |
| V5 version pin | submodule SHA | subrepo | externals (peg rev) | `_rev` reference, `created_by_order` |
| V6 author + time | commit metadata | commit metadata | revision props | doc fields |

**Контракт нормативного языка**:

В нормативных документах RENARа используется **substrate-agnostic** язык для обязательных требований и **substrate-specific** только в приложениях/примерах.

**Пример substrate-agnostic формулировки** (нормативный текст):

> Каждое изменение требования регистрируется как atomic change unit с автором и временем (V2, V6). Изменение проходит diff/review до интеграции (V3). Implementation substrate, использующий это требование, фиксирует конкретную версию требования (V5). Любая попытка изменить уже approved требование вне atomic change unit с явной review-процедурой — нарушение стандарта.

**Пример substrate-specific** (в приложении):

> Реализация на Git: `.req` — git репозиторий, изменения — commits в branch, review — Merge Request с обязательным reviewer, pin — submodule SHA в `.src/requirements/`.
>
> Реализация на Mercurial: `.req` — hg repository, изменения — changesets в named branch, review — phabricator / arc workflow, pin — subrepo с фиксированной changeset hash.
>
> Реализация на Raven (CouchDB): `requirement_meta` doc-type, изменения — API PUT с `_rev` token, review — Hub UI approve workflow, pin — `requirement_rev` поле в `linked_tasks` записи.

**Git — reference implementation**:

В примерах и tutorial RENARа используется Git как default по двум причинам: (а) бесплатен и доступен; (б) большинство команд уже знают. Это **не делает Git нормативно обязательным**. Команда может реализовать RENAR на Mercurial / SVN / Raven / любом будущем substrate, удовлетворяющем V1-V6.

**Контракт реализации**:

- Документация substrate-реализации обязана иметь раздел «Conformance to V1-V6 of RENAR §N» с явным mapping.
- При смене substrate (миграция git → Raven, например) — проверка V1-V6 на новом substrate перед началом миграции.
- CI-проверка: hook на любой изменение требования вне atomic change unit — блок.

**Связь с мировыми стандартами**:

- ISO/IEC/IEEE 29148 §6.4.5 — Configuration management of requirements (нормирует V1, V2, V6).
- BABOK Guide §5.3 — Maintain requirements (V1, V3).
- CMMI-DEV CM SG2 — Track and Control Changes (V1, V2, V3, V6).
- SAFe Solution Intent — версионируемый artifact (V1, V5).

Ни один из этих стандартов не нормирует **substrate** (все mention git/svn/SharePoint без предпочтения). RENAR follows the same neutrality.

---

## 3. Логическая связь трёх утверждений

```
                       Утверждение 1 (SoT inversion)
                       требования > код
                              │
                              │ требует
                              ▼
        Утверждение 3 (substrate versioning)
        provenance, pin, history, atomic change
                              │
                              │ позволяет
                              ▼
              Утверждение 2 (waterfall form, не классика)
              дельта-ТЗ, парные TC, ADAPT, reconciliation
                              │
                              │ возвращает
                              ▼
                       контракт-ориентированная разработка
                       снова жизнеспособна с AI-ускорением
```

- **Без 1**: SoT диффузен, спека дрейфует, audit невозможен.
- **Без 3**: 1 декларативен, но физически не работает.
- **Без 2 explicit**: ревьюер натягивает на стандарт неподходящие шаблоны (agile или classical waterfall) и отвергает.

Все три должны быть в самом верху нормативного документа, не как мелкие оговорки.

---

## 4. Что меняется в существующих документах стандарта

### 4.1 `requirements-methodology.md`

Новый §1 «Положение в типологии методологий» (~150 строк) с тремя утверждениями. Существующий §1 «Принципы» сдвигается на §2.

### 4.2 `requirements-storage-standard.md`

Раздел 6.2 «Версионирование» переписать substrate-agnostic: V1-V6 как нормативные capabilities, git как пример. Git-specific детали — в приложение.

Раздел 7 «Версионирование и Git-процесс» — переименовать в «Версионирование и change workflow». Git-специфичные шаги (`git branch`, `git push`) — в приложение «Реализация на Git».

### 4.3 `testing-methodology.md`

Раздел про `last-run` теста и `verified-by` — переписать substrate-agnostic. `requirement-version` — это substrate-native version identifier, не обязательно git SHA.

### 4.4 `developer-guide-requirements.md`

Workflow «как делать дельта-ТЗ» — переписать substrate-agnostic. Конкретные команды (`git checkout`, `git push`) — в раздел «Если ваш substrate — Git».

### 4.5 `00-architecture-vision.md`

Раздел 5 «Два substrate, одна модель данных» — расширить таблицей V1-V6 для git и Raven. Текст уже substrate-agnostic в основном, нужна docrination проверка.

### 4.6 `02-agent-driven-principles.md`

Принцип 1 (Model Cards) — добавить что `requirement-version` в `ai-provenance` — substrate-native ID, не git SHA.

---

## 5. Open questions

1. **Reference implementation in tutorials**: использовать Git везде в примерах? Или показывать два варианта (Git + Raven) параллельно? Trade-off: ясность vs polish.
2. **Migration guarantees**: при переходе substrate (git → Raven) обязана быть **изоморфная** миграция (все V1-V6 capabilities сохраняются, все ID и связи сохраняются). Нужен ли формальный proof? Или достаточно тестов миграции на pilot project?
3. **Минимальная V-spec**: должны ли мы дать спецификацию минимального VCS-like substrate (как «протокол») чтобы команда могла построить свой substrate под compliance-требования? Или это overkill?
4. **«Spec-Driven Development» в имени**: использовать ли термин SDD как self-identification стандарта в маркетинговых документах (README, presentation)? Pro: подключение к индустрии-тренду. Contra: новый термин, читатель не знает.

---

## 6. Закрытость нормативной части

Три утверждения — нормативные, не предлагаемые к изменению через PR (in соответствии с §6 closed list policy). Изменение любого из трёх — major version bump RENARа.

Type-specific capabilities (V1-V6) — закрыты на v1. Новые capabilities добавляются через PR в стандарт.

Конкретные substrate-implementations — открыты: любая команда может опубликовать «RENAR-conformance manifest» для своего substrate, и это не требует изменения стандарта.

---

## Приложение A. Историческая справка

**Почему waterfall провалился в 1970-1990-х**:
- Manual cycles были слишком медленные (недели/месяцы на проход).
- Тесты в конце означали что баги требований всплывали через 6-12 месяцев.
- Без VCS-tooling реальный delta-workflow был невозможен.
- Договоры писались как «весь продукт целиком», не дельтами.

**Что изменилось к 2026**:
- AI-агенты делают декомпозицию ТЗ → SR за минуты, не недели.
- TC как first-class артефакт — тесты в начале каждого цикла.
- Git/Mercurial/Raven делают версионирование и атомарные изменения тривиальными.
- Контракт-практика признаёт дельта-договоры (delta-TZ) как стандарт.

То есть waterfall не «всегда был плохим». Он был **преждевременным**. AI-ускорение делает waterfall-форму снова жизнеспособной для тех контекстов где она структурно правильна (контракт-ориентированная разработка).

---

## Приложение B. Mapping на существующие нормативные документы RENARа

| Документ RENAR | Какое утверждение поддерживает |
|---|---|
| `requirements-methodology.md` | Все три (фундамент) |
| `requirements-storage-standard.md` | 3 (substrate-agnostic format) |
| `testing-methodology.md` | 1 (TC как first-class — verifies, не reverse-engineers) |
| `developer-guide-requirements.md` | 2 (workflow дельта-ТЗ как micro-waterfall) |
| `00-architecture-vision.md` | Все три (vision) |
| `02-agent-driven-principles.md` | 1 (AI генерирует от спеки к коду, не наоборот) |
| `15-requirement-lifecycle-draft.md` | 3 (state transitions требуют versioned substrate) |

---

> **Статус документа**: после согласования с партнёром — содержание извлекается в §1 `requirements-methodology.md` и §1 `00-architecture-vision.md` как нормативные параграфы. Этот файл остаётся в `research/` как обоснование с историческими ссылками.
