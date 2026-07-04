# ADAPT — двусторонняя адаптация ТЗ

> Версия: черновик 0.1 | Дата: 2026-05-11
> Статус: предложение к обсуждению с партнёром
> Назначение: ввести в стандарт промежуточный артефакт между immutable ТЗ и immutable-after-approval BR/SR/SPEC. ADAPT — рабочая интерпретация ТЗ инженером с двусторонней проработкой: forward (инженер → клиент: «вот как мы вас услышали») и backward (инженер → клиент: «вот что неясно / противоречит / отсутствует»).

---

## 1. Не дублирует SENAR

SENAR §3 фиксирует иерархию БТ → СТ → ТМ → ТЗ. SENAR §10 («Реализация без Task запрещена») требует существования утверждённых требований перед началом работы. SENAR **не нормирует** артефакт-буфер между договорным ТЗ и инженерными требованиями.

RENAR specifies ADAPT как обязательный артефакт жизненного цикла. Без ADAPT либо ТЗ дрейфует (что нарушает договор), либо инженерные предположения молча просачиваются в BR/SR/SPEC (что разрушает трассировку и provenance).

---

## 2. Проблема, которую закрывает ADAPT

### 2.1 Текущий разрыв

Сейчас в [requirements-storage-standard.md §1.1](../requirements-storage-standard.md#L34-L48):

```
ТЗ (immutable, договор)  →  [только tz-index.md]  →  BR/SR/SPEC
```

`tz-index.md` — плоский маппинг «ТЗ§N.N → BR-NN», не интерпретация. В нём нет:

- Инженерной перефразировки спорных формулировок ТЗ.
- Обнаруженных противоречий внутри ТЗ.
- Гэпов («про что ТЗ молчит, но без этого нельзя»).
- Предположений архитектора (которые могут быть неверны).
- Открытых вопросов к клиенту.
- Решений клиента по этим вопросам.

В результате архитектор пишет BR/SR/SPEC с **необъявленными** интерпретациями. Клиент при приёмке обнаруживает что «мы это не имели в виду», и идёт переоткрытие ТЗ (либо договорной скандал, либо тихий compromise со сдвигом сроков).

### 2.2 Что должен закрыть ADAPT

| Задача | Без ADAPT | С ADAPT |
|---|---|---|
| Клиент видит как его поняли | Никогда. Только в готовом продукте. | До написания SR. Двусторонне. |
| Инженер регистрирует вопрос | В голове или в чате | В ADAPT-документе с lifecycle |
| Гэп ТЗ обнаруживается | На QG-4 (приёмка) — поздно | На QG-ADAPT-approve — рано |
| Контракт с клиентом меняется? | Часто — открываем ТЗ | Никогда — все правки в ADAPT |
| Trace от TC до источника | TC→SR→ТЗ§N.N (но что было неясно — потеряно) | TC→SR→ADAPT→ТЗ§N.N (полная история интерпретаций и вопросов) |

### 2.3 Принцип неизменности ТЗ

ТЗ — договорной документ. После подписания клиентом ТЗ **не редактируется**. Если в ходе работы выясняется что в ТЗ ошибка/пропуск/противоречие — это фиксируется в ADAPT-разделе «Backward findings», клиент даёт ответ, ответ становится частью ADAPT (с подписью), а **ТЗ остаётся immutable**.

При большом количестве правок (или если правки меняют scope) — создаётся **delta-TZ** (новый ТЗ-документ как дополнение к основному), которое тоже immutable после подписания. На каждое delta-TZ — своё ADAPT.

---

## 3. Цикл двусторонней адаптации

```
            ┌─────────────────────────┐
            │   ТЗ (immutable)        │
            │   договор с клиентом    │
            └─────────────┬───────────┘
                          │ источник
                          ▼
┌─────────────────────────────────────────────────────┐
│                  ADAPT-NNN.md                       │
│                                                     │
│  ┌──────────────────────────────────────────┐       │
│  │  Forward (инженер → клиент)              │       │
│  │  Интерпретация каждого раздела ТЗ        │       │
│  │  Достроенные сценарии                    │       │
│  │  Term mapping (клиент.term → eng.term)   │       │
│  └──────────────────────────────────────────┘       │
│                                                     │
│  ┌──────────────────────────────────────────┐       │
│  │  Backward (инженер → клиент)             │       │
│  │  Противоречия в ТЗ                       │       │
│  │  Гэпы / неоговорённые ограничения        │       │
│  │  Скрытые предположения                   │       │
│  │  Открытые вопросы с lifecycle            │       │
│  │  (open → answered → resolved)            │       │
│  └──────────────────────────────────────────┘       │
│                                                     │
│  Status: draft → review → approved (immutable)      │
│  Approval: client-signature + architect-signature   │
└────────────────────────┬────────────────────────────┘
                         │ approved → derived from
                         ▼
            ┌─────────────────────────┐
            │   BR / SR / SPEC        │
            │   ссылаются на ADAPT§   │
            │   через source.adapt    │
            └─────────────────────────┘
```

### 3.1 Forward adaptation (ТЗ → инженер)

**Что**: для каждого раздела ТЗ инженер/AI-агент создаёт раздел в ADAPT с инженерной интерпретацией. Это не пересказ — это перевод языка клиента на язык требований.

**Содержание Forward раздела**:

- Цитата из ТЗ (точная ссылка ТЗ§N.N).
- Инженерная интерпретация (1-3 параграфа).
- Term mapping: «клиент говорит "клиент" — мы понимаем "User с ролью customer"».
- Достроенные сценарии: «клиент говорит "регистрация" — подразумевает (1) sign-up, (2) email verification, (3) profile completion».
- Scope clarification: что точно входит, что точно не входит (на основе разговоров со стейкхолдером).
- Forward links: список BR/SR/SPEC которые планируются к выводу из этого раздела (auto-generated после approval).

### 3.2 Backward adaptation (инженер → клиент)

**Что**: инженер фиксирует всё что нельзя вывести из ТЗ напрямую. Это **самая важная** часть ADAPT — место где обнаруживаются проблемы до того как они становятся производственными.

**Категории backward записей**:

| Категория | Описание | Пример |
|---|---|---|
| `contradiction` | Противоречие внутри ТЗ | «§3.1: "только email auth"; §5.2: "вход через Google" — что верно?» |
| `gap` | Гэп — про это ТЗ молчит | «ТЗ не описывает что происходит при отказе оплаты — отменить заказ или удерживать?» |
| `hidden-assumption` | Скрытое предположение инженера | «Предполагаем что клиент работает в одной timezone — подтвердите» |
| `feasibility` | Технически нереализуемое или дорогое | «Real-time sync с банком по требованию §4.7 невозможен — банк гарантирует 5-min лагу» |
| `regulatory` | Затрагивает законодательство | «Хранение PII по §6.3 требует ФЗ-152 уведомления — кто отвечает за регистрацию?» |
| `terminology` | Неясный термин | «"Менеджер" в §2 — это User-роль или должность в HR? — нужно разделить» |
| `scope` | Уточнение scope | «"Уведомления" в §7 — push, email, SMS, in-app? Какие именно?» |

**Lifecycle одной backward записи**:

```
open → asked-to-client → answered → resolved → frozen
                ↑                       │
                └───── revised ─────────┘  (если клиент дал расплывчатый ответ)
```

- `open`: инженер записал.
- `asked-to-client`: вопрос отправлен клиенту (с датой).
- `answered`: клиент ответил (ответ записан в документ с датой и автором-клиентом).
- `resolved`: инженер интегрировал ответ в Forward интерпретацию.
- `frozen`: после approval ADAPT — изменения невозможны.

### 3.3 Approval ADAPT — двойная подпись

ADAPT переходит в `approved` только после **двойной подписи**:

- **Клиент** (или представитель клиента с полномочиями): подтверждает что forward интерпретация совпадает с тем что они хотели; даёт ответы на все backward вопросы; подписывает что ответы — финальные.
- **Архитектор** (со стороны исполнителя): подтверждает что все backward findings отработаны (нет нерешённых вопросов), forward интерпретация технически реализуема.

Approval — atomic change unit (V2 из draft 19). Substrate-нативный механизм: на git — PR с двумя required reviewers; на Raven — endpoint `/adapt/<id>/approve` с двумя signature полями.

После approval ADAPT **immutable**, как и ТЗ. Дальнейшие изменения — только через delta-ADAPT (см. §6).

---

## 4. ADAPT schema

### 4.1 Frontmatter

```yaml
---
# === Identity ===
id: ADAPT-NNN                       # immutable; NNN sequential per project
title: "Адаптация ТЗ <name>"
type: ADAPT

# === Source ===
source-tz:
  id: TZ-YYYY-NNN                   # источник
  signed-date: "<ISO-date>"         # дата подписания ТЗ клиентом
  signed-by-client: "<name-role>"
  document-hash: "<substrate-native-version-ref>"  # pin ТЗ-substrate version
parent-adapt:                       # для delta-ADAPT
  id: ADAPT-NNN                     # null для основного ADAPT
  delta-tz: TZ-YYYY-NNN             # null для основного

# === Lifecycle ===
status: draft | review | approved | frozen | obsolete
created: "<ISO-date>"
last-updated: "<ISO-date>"
approval:
  client-signature:                 # обязательно для approved
    signed-by: "<name>"
    role: "<role>"
    organization: "<client-org>"
    signed-at: "<ISO-datetime>"
    signature-ref: "<substrate-native-ref>"   # подпись substrate-нативная
  architect-signature:              # обязательно для approved
    signed-by: "<name>"
    role: architect
    signed-at: "<ISO-datetime>"

# === Связи ===
generates-requirements: []          # auto-derived; список BR/SR/SPEC выведенных из этого ADAPT
generates-specs: []                 # auto-derived; список SPEC-* выведенных из этого ADAPT
open-questions-count: integer       # auto-derived; должен быть 0 для approved
resolved-questions-count: integer   # auto-derived

# === AI provenance ===
ai-provenance:
  generated-by: "<vendor>-<model>@<date>"
  prompt-template: "<template-path>@<version>"
  context-tokens: integer
  output-tokens: integer
  human-edits: boolean              # обязательно true для approved — клиент видел текст
---
```

### 4.2 Body structure

```markdown
## Краткое содержание
<3-5 параграфов: о чём ТЗ, какой scope, какие основные acceptance критерии — для одностраничного чтения клиентом>

## Term mapping (клиент → инженер)
| Термин клиента | Инженерное понимание | Раздел ТЗ |
|---|---|---|
| Клиент | User с ролью customer | §2.1 |
| Менеджер | User с ролью operator | §2.1 |
| Заказ | Order entity со state-machine PROC-01 | §3.4 |
...

## Forward: интерпретация по разделам ТЗ

### ТЗ §1. <Название раздела ТЗ>
<Цитата из ТЗ>

**Интерпретация**: <инженерное понимание>

**Достроенные сценарии**:
- <сценарий 1>
- <сценарий 2>

**Scope**:
- Входит: <...>
- НЕ входит: <...>

**Forward links** (после approval):
- BR-01: <title>
- SR-03: <title>
- SPEC-API-01: <title>

### ТЗ §2. <Название>
...

## Backward: обнаруженные проблемы и вопросы

### B-001: <короткое описание>
- **Категория**: contradiction | gap | hidden-assumption | feasibility | regulatory | terminology | scope
- **Статус**: open | asked-to-client | answered | resolved | frozen
- **Ссылка на ТЗ**: §N.N
- **Описание проблемы**:
  <2-5 параграфов>
- **Предположение инженера** (если есть):
  <...>
- **Вопрос к клиенту**:
  <...>
- **Asked-to-client**: <date>
- **Ответ клиента** (после answered):
  - **Кто ответил**: <name, role>
  - **Когда**: <ISO-datetime>
  - **Ответ**: <текст>
- **Resolution** (после resolved):
  <как ответ интегрирован в Forward; на какие BR/SR/SPEC повлиял>

### B-002: ...

## Резюме backward findings
| Категория | Open | Asked | Answered | Resolved | Frozen |
|---|---|---|---|---|---|
| contradiction | 0 | 0 | 0 | 3 | 3 |
| gap | 0 | 0 | 0 | 5 | 5 |
...

## Generated artifacts (auto-populated после approval)
- BR-01..BR-04
- SR-01..SR-12
- SPEC-ARCH-01
- SPEC-API-01, SPEC-API-02
- SPEC-DATA-01
- SPEC-UI-01
- SPEC-SEC-01

## История изменений ADAPT (substrate-native)
<В git — git log; в Raven — revisions; substrate-agnostic auto-generated>
```

### 4.3 Идентификация версии backward записи

Каждая backward запись имеет stable ID (`B-NNN`), immutable после создания. Даже если запись `obsolete`, ID не переиспользуется. Это нужно для долгосрочной audit-trail: при споре через 2 года «когда обнаружили это противоречие» — ответ есть в ADAPT.

---

## 5. Связь с другими артефактами

### 5.1 BR/SR/SPEC ссылаются на ADAPT, а не на ТЗ напрямую

```yaml
# Старое (текущее в стандарте):
source:
  document: "TZ-2025-001"
  section: "§3.4"

# Новое (с ADAPT):
source:
  adapt: "ADAPT-001"
  adapt-section: "Forward §3"       # forward интерпретация
  tz-section: "§3.4"                # для traceability; canonical источник остаётся ТЗ
```

Главное изменение: **canonical источник для BR/SR/SPEC — это раздел ADAPT, не раздел ТЗ**. ТЗ — первоисточник, но интерпретация формализована в ADAPT.

### 5.2 Полная trace chain

```
TC-NN
  └─ verifies SR-12
       └─ derived from ADAPT-001 §3 (forward)
             └─ interprets TZ-2025-001 §3.4
                   ↓
       └─ constrained-by SPEC-API-02
             └─ derived from ADAPT-001 §4 (forward)
             └─ resolves B-007 (was: contradiction, answered by client 2026-03-15)
```

При аудите можно от тест-кейса дойти до:
- Исходного раздела ТЗ.
- Интерпретации этого раздела.
- Какие вопросы инженер задал.
- Что клиент ответил.
- Какой именно BR/SR/SPEC появился в результате.

Это та **provenance chain**, ради которой делается RENAR.

### 5.3 TR не ссылается на ADAPT напрямую

TR (задача) ссылается на SR/SPEC, а они уже ссылаются на ADAPT. Разработчик/AI-агент при выполнении задачи **не должен** перечитывать ADAPT — все нужные интерпретации уже в SR/SPEC. ADAPT — это артефакт фазы requirements engineering, не implementation.

Если разработчик обнаружил что-то непонятное в SR — это сигнал что либо ADAPT неполный (новая backward запись), либо SR недостаточно детальный (новая задача на доработку SR), но **не** прямое обращение к ADAPT.

---

## 6. Delta-ТЗ и delta-ADAPT

### 6.1 Workflow при delta-ТЗ

1. Клиент даёт **delta-TZ** (TZ-YYYY-NNN-delta-N.md или новый TZ-YYYY-NNN+1).
2. Клиент подписывает delta-TZ — это immutable договорной документ.
3. Архитектор/AI создаёт **delta-ADAPT** (ADAPT-NNN-delta-N или новый ADAPT-NNN+1):
   - `parent-adapt: ADAPT-NNN` (ссылка на родительский ADAPT)
   - `source-tz.id: TZ-YYYY-NNN-delta-N`
4. Forward: интерпретация только разделов delta-TZ (не дублируем основной ADAPT).
5. Backward: вопросы конкретно по delta-TZ.
6. Approval — двойная подпись (как у основного).
7. Из approved delta-ADAPT — дельта в BR/SR/SPEC (новые / обновлённые / deprecated).

### 6.2 Множественные delta-ADAPT

```
ADAPT-001 (от TZ-2025-001 main)
  └─ ADAPT-001-delta-1 (от TZ-2025-001-delta-1)
        └─ ADAPT-001-delta-2 (от TZ-2025-001-delta-2)
              └─ ADAPT-001-delta-3 (от TZ-2025-001-delta-3)
```

Последовательная цепочка. Применение delta-ADAPT обязано идти по порядку (V5 из draft 19 — version pin). Перенумеровать нельзя.

### 6.3 Обнаружение проблемы в уже approved ADAPT

Что если через 3 месяца после approval обнаружили что в ADAPT-001 §5 неверная интерпретация ТЗ?

**Вариант 1: было incorrectly interpreted (наша ошибка)** — создаётся `errata-ADAPT-001-N`:
- Корректирует интерпретацию.
- Клиент должен подписать errata (если меняет contractual outcome) или просто архитектор (если cosmetic).
- ADAPT-001 не меняется (frozen), errata — отдельный артефакт.

**Вариант 2: ТЗ оказалось двусмысленным (gap в backward)** — создаётся delta-ADAPT с новым backward question и ответом клиента.

В обоих случаях — **никогда** правка frozen документа. Только добавление новых артефактов с явной связью.

---

## 7. ADAPT и AI-генерация

### 7.1 AI-агент создаёт draft ADAPT

При импорте ТЗ (`tausik req import-tz` или Raven API endpoint `/adapt/from-tz`) AI-агент создаёт **draft ADAPT** автоматически:

- Forward: интерпретация каждого раздела ТЗ.
- Backward: попытка обнаружить contradictions / gaps / ambiguous terms.
- Term mapping: первая версия таблицы.

Этот draft — стартовая точка для архитектора, не финальный артефакт.

### 7.2 Adversarial reviewer на backward findings

Применение [02-agent-driven-principles.md Принцип 2 (Adversarial review)](02-agent-driven-principles.md): отдельный AI-агент-критик с другой моделью **специально ищет** что primary агент пропустил — недостающие backward findings.

Если critic находит ≥3 серьёзных new findings — это сигнал что primary agent недостаточно тщательно отработал backward.

### 7.3 AI provenance для backward записей

Каждая backward запись имеет ai-provenance: какой агент её обнаружил, с какой версией. Это нужно для **анализа эффективности агентов** в долгосрочной перспективе: какие categories agent чаще пропускает, какой prompt улучшать.

### 7.4 Клиент не общается с AI напрямую

Backward вопросы агрегируются архитектором в человеческий формат перед отправкой клиенту. Архитектор может убрать дубликаты, переформулировать на язык клиента, объединить связанные. Цель: клиент видит **готовый список вопросов**, не raw output AI-агента.

Когда клиент отвечает — ответ может быть короче чем вопрос, может быть устным (по zoom), может быть письмом. Архитектор **транскрибирует ответ в ADAPT** с указанием канала ответа и аутентификации.

---

## 8. Quality Gates для ADAPT

### 8.1 ADAPT-specific gates

| Gate | Условие |
|---|---|
| QG-ADAPT-draft | ADAPT создан; forward охватывает все разделы ТЗ |
| QG-ADAPT-review | Все backward записи в состоянии `open` или `asked-to-client`; нет `draft` записей |
| QG-ADAPT-client-ready | Все backward переведены в `asked-to-client`; пакет вопросов сформирован |
| QG-ADAPT-answered | Все backward в `answered`; resolution начат |
| QG-ADAPT-approve | Все backward в `resolved`; двойная подпись; все вопросы closed |
| QG-ADAPT-frozen | Approved + immutable; BR/SR/SPEC generation начата |

### 8.2 Hooks (substrate-agnostic enforcement)

- **PreCommit / PreApproval**: при попытке approve ADAPT — проверка что `open-questions-count == 0`. Иначе блок.
- **PreCommit на BR/SR/SPEC creation**: если `source.adapt` ссылается на ADAPT в статусе `< approved` — блок.
- **PostUpdate на ADAPT**: пересчёт `open-questions-count`, `resolved-questions-count`, `generates-requirements[]`, `generates-specs[]`.
- **Long-open warning**: если backward запись в `asked-to-client` > 14 дней — warning в дашборд (клиент задерживает).

---

## 9. Storage layout

```
[project].req/
  adapt/
    ADAPT-001-main.md
    ADAPT-001-delta-1.md
    ADAPT-001-delta-2.md
    ADAPT-002-main.md           # для другого ТЗ
    errata/
      errata-ADAPT-001-1.md
  tz/
    TZ-2025-001.md
    TZ-2025-001-delta-1.md
    TZ-2025-001-delta-2.md
    TZ-2025-002.md
```

`tz-index.md` — **устаревает**, заменяется на ADAPT (который сам по сути index плюс интерпретация).

---

## 10. Open questions

1. **Подпись клиента — формат**: цифровая подпись (DocuSign), git PR approval с client account, скан подписанного PDF, или достаточно email confirmation? Trade-off: юридическая весомость vs трение. Возможно gradient: для крупных контрактов — DocuSign, для мелких — email.

2. **Кто такой "архитектор" для signature**: одна роль или может быть «techlead + architect» (две подписи)? Зависит от размера команды.

3. **Локализация**: ТЗ часто на русском, инженерия может вестись на английском (если команда международная). ADAPT обязан быть на языке клиента? Двуязычным? Term mapping должен быть особенно тщательным.

4. **Backward findings приватность**: некоторые findings могут быть неприятны для клиента («ваш ТЗ противоречит себе в §3»). Архитектор должен иметь возможность «draft mode» backward записей видимый только команде, перед отправкой клиенту? Сейчас не предусмотрено — все backward сразу видны.

5. **AI-генерируемый draft ADAPT качество**: сколько % backward findings будет находить primary agent vs скрытых до приёмки? Нужен pilot для измерения. Возможно метрика «adversarial-found-rate» в [04-metrics-and-outcomes.md](04-metrics-and-outcomes.md).

6. **Эскалация при затянутом ответе клиента**: если backward `asked-to-client` > 30 дней — что делаем? Заморозить проект? Сделать assumption и продолжить с пометкой «при отсутствии ответа клиента принимаем X»? Это организационная политика, но стандарт мог бы дать default.

7. **ADAPT vs BABOK Business Analysis Document**: насколько ADAPT — это переименование известного BABOK артефакта? Если да, стоит ли использовать BABOK термины (например, Requirements Analysis Document, RAD)? Сейчас выбрано «ADAPT» как самобытное; можно подумать о rebrand в BAD/RAD для familiarity у enterprise reviewers.

---

## 11. Связь с мировыми стандартами

| Стандарт | Концепция | Соответствие в ADAPT |
|---|---|---|
| ISO/IEC/IEEE 29148 §6.4 | Requirements Analysis output | ADAPT — формализация этого этапа |
| BABOK Guide §3 | Business Analysis Planning and Monitoring | ADAPT — её artifact |
| BABOK Guide §5.3 | Trace Requirements | Forward links + backward provenance |
| SAFe | Solution Intent (fixed + variable) | ADAPT — analog Solution Intent для контракт-разработки |
| PMBOK | Stakeholder requirements documentation | Backward findings — её часть |
| ISO/IEC 5338 | AI requirements engineering | Backward поддерживает identification of AI-specific gaps |

ADAPT не противоречит этим стандартам, а **формализует** этап который они описывают абстрактно («должен быть документ с интерпретацией»). RENAR говорит: вот конкретная schema, вот lifecycle, вот hooks.

---

## 12. Migration от текущего `tz-index.md`

### 12.1 Что меняется

| Старое | Новое |
|---|---|
| `tz/TZ-YYYY-NNN-index.md` (плоский маппинг) | `adapt/ADAPT-NNN-main.md` (forward + backward) |
| BR `source: { document: TZ, section: §N }` | BR `source: { adapt: ADAPT-NNN, adapt-section: §N, tz-section: §N }` |
| Workflow «AI декомпозирует ТЗ → BR/SR» | Workflow «AI → draft ADAPT → review → approved ADAPT → BR/SR/SPEC» |

### 12.2 Скрипт миграции для существующих проектов

```
1. Для каждого TZ-YYYY-NNN-index.md:
   1a. AI-агент читает ТЗ и index.
   1b. Генерирует draft ADAPT с forward для каждого раздела.
   1c. Backward — на основе анализа существующих BR/SR (если они расходятся с ТЗ — это backward finding).
   1d. Архитектор делает review.
   1e. Если необходимо — отправляет вопросы клиенту (legacy backward).
   1f. После approval — обновление BR/SR `source` поля.

2. Существующий TZ-YYYY-NNN-index.md помечается deprecated, ссылается на ADAPT-NNN.

3. Pilot: notification_catcher.req — генерация ADAPT для существующих 2 ТЗ.
```

---

## 13. Закрытость и эволюция

- **ADAPT как обязательный артефакт** — закрыто на v1. Нельзя «пропустить» ADAPT и идти прямо из ТЗ в SR.
- **Backward категории** (7 категорий §3.2) — закрыто на v1. Новые добавляются PR в стандарт.
- **Forward structure** (term mapping + интерпретация + достроенные сценарии + scope + forward links) — закрыто на v1.
- **Двойная подпись** — закрыто на v1. Нельзя one-side approval.

---

## 14. Что меняется в существующих документах RENARа

| Документ | Изменение |
|---|---|
| `requirements-storage-standard.md` §1.1 | Диаграмма потока — добавить ADAPT между ТЗ и BR/SR |
| `requirements-storage-standard.md` §5.2 | Папка `adapt/` в структуре `.req/` |
| `requirements-storage-standard.md` §8 | «Клиентский контур: ТЗ и требования» — переписать с ADAPT |
| `requirements-storage-standard.md` §9 | «Повторный заказ: дельта-ТЗ» — добавить delta-ADAPT |
| `requirements-methodology.md` | Новый параграф «ADAPT как обязательный артефакт» |
| `developer-guide-requirements.md` | Workflow «Создать ADAPT после импорта ТЗ» |
| `14-requirement-schema-draft.md` | `source.adapt` поле; ADAPT как separate type schema |
| `15-requirement-lifecycle-draft.md` | ADAPT lifecycle добавить как отдельный state machine |
| `00-architecture-vision.md` §6.4 | Workflow дельта-ТЗ — добавить delta-ADAPT step |
| `11-elicitation-workflow.md` | ADAPT — формализация результата elicitation |

---

> **Статус документа**: после согласования с партнёром — содержание извлекается в новый нормативный документ `adapt-standard.md` (или раздел в `requirements-storage-standard.md`). Этот файл остаётся в `research/` как обоснование с примером схемы и mapping на BABOK/SAFe/ISO.
