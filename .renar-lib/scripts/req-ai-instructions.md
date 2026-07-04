# Инструкции для AI-агента: работа с требованиями

> Этот документ читает AI-агент перед началом работы с требованиями.  
> Инженер: передайте этот файл агенту вместе с `TASK.md`.

---

## 1. Контекст

Ты работаешь в репозитории требований (`.req`) проекта по стандарту SENAR.  
Твоя роль: **создавать и изменять файлы требований** в рамках задачи из `TASK.md`.  
Роль инженера: **контролировать результат и принимать решение о финализации**.

Никогда не финализируй самостоятельно — финализацию запускает инженер через `req-finalize.sh`.

---

## 2. Перед началом работы

1. **Прочитай `TASK.md`** — там задача, контекст, ветка и правила.
2. **Убедись что ты в правильной ветке**:
   ```bash
   git branch --show-current
   ```
   Ветка должна совпадать с полем `branch:` в `TASK.md`.
3. **Прочитай `REQUIREMENTS.md`** — общий реестр требований, поможет понять существующую структуру.
4. При изменении существующего требования — **прочитай файл целиком** перед правками.

---

## 3. Правила создания файлов требований

### 3.1 Статус

Все файлы, которые ты создаёшь или изменяешь, должны иметь `status: draft`.

```yaml
status: draft   # ВСЕГДА draft во время итерации
```

Никогда не ставь `approved`, `deprecated` или `replaced` самостоятельно.

### 3.2 Версия

- При **создании** нового файла: `version: "0.1.0"`
- При **изменении** существующего: **не трогай поле `version`** — его обновляет `req-finalize.sh`
- Не трогай поле `updated` — оно тоже обновляется при финализации

### 3.3 Поля `children` и `REQUIREMENTS.md`

**НЕ обновляй** во время итерации:
- `children:` в родительских требованиях
- Файл `REQUIREMENTS.md` (реестр)

Эти поля автоматически пересобираются при финализации.

### 3.4 Frontmatter: обязательные поля

**BR (бизнес-требование):**
```yaml
---
id: "BR-NN"
title: "Название"
type: BR
status: draft
version: "0.1.0"
created: YYYY-MM-DD
updated: YYYY-MM-DD
priority: must|should|could
source:
  document: "TZ-YYYY-NNN"
  section: "§N.N"
children: []
---
```

**SR (системное требование):**
```yaml
---
id: "SR-NN"
title: "Название"
type: SR
status: draft
version: "0.1.0"
created: YYYY-MM-DD
updated: YYYY-MM-DD
priority: must|should|could
parent:
  id: "BR-NN"
  repo: "../[system].req"   # если в другом репозитории
derived-from-tz:
  document: "TZ-YYYY-NNN"
  section: "§N.N"
# Связи с SPEC-* — типизированные рёбра (reference/02-schemas §3).
# Пример: SR ограничен экраном (SPEC-UI), контрактом API (SPEC-API),
# моделью данных (SPEC-DATA), интеграционным контрактом (SPEC-INT).
constrained-by:
  - "SPEC-UI-NN"            # если поведение завязано на UI-сценарий
  - "SPEC-API-NN"           # если использует/предоставляет API
children: []
---
```

**SPEC-UI (UI / UX артефакт):**
```yaml
---
id: "SPEC-UI-NN"
title: "Название"
type: SPEC-UI               # canonical RENAR v1.0 (см. standard/03 §3.14.1)
status: draft
version: "0.1.0"
created: YYYY-MM-DD
updated: YYYY-MM-DD
parent:
  id: "BR-NN"
  repo: "../[system].req"
---
```

**Интеграционное требование (SR, ограниченный SPEC-INT):**

В RENAR v1.0 нет отдельного интеграционного типа требования (см.
standard/03 §3.14.1). Интеграционное требование — это обычный `SR`,
который ссылается на интеграционный контракт через
`constrained-by: [SPEC-INT-N]`. Сам контракт описывается в SPEC-INT
артефакте (см. ниже).

```yaml
---
id: "SR-NN"
title: "Название интеграционного требования"
type: SR
status: draft
version: "0.1.0"
created: YYYY-MM-DD
updated: YYYY-MM-DD
parent:
  id: "BR-NN"
constrained-by:
  - "SPEC-INT-NN"           # ссылка на интеграционный контракт
---
```

**SPEC-INT (интеграционный контракт):**
```yaml
---
id: "SPEC-INT-NN"
title: "Название контракта"
type: SPEC-INT              # canonical RENAR v1.0 (см. standard/03 §3.14.1)
status: draft
version: "0.1.0"
created: YYYY-MM-DD
updated: YYYY-MM-DD
systems:
  - id: "SR-NN"
    repo: "[subsystem-a].req"
  - id: "SR-NN"
    repo: "[subsystem-b].req"
---
```

---

## 4. Структура папок

```
[repo].req/
├── br/           # Бизнес-требования: BR-NN-slug.md
├── sr/           # Системные требования: SR-NN-slug.md
├── tr/           # Задачные требования: TR-NN-slug.md
├── spec/         # SPEC артефакты: SPEC-{ARCH,API,DATA,INT,PROC,UI,AI,SEC,OPS}-NN-slug.md
├── tz/           # ТЗ от клиента (не редактировать!)
├── docs/         # Документация системы/подсистемы
├── REQUIREMENTS.md   # Не редактировать вручную
└── TASK.md           # Задача инженера
```

Все 9 типов SPEC (closed list, standard/03 §3.4.1) хранятся в общей
папке `spec/`; конкретный тип различается полем `type:` во frontmatter,
не директорией.

### Правила именования файлов

| Тип | Шаблон | Пример |
|-----|--------|--------|
| BR | `BR-NN-slug.md` | `BR-01-authentication.md` |
| SR | `SR-NN-slug.md` | `SR-01-auth-totp.md` |
| TR | `TR-NN-slug.md` | `TR-01-implement-totp-handler.md` |
| SPEC-ARCH | `SPEC-ARCH-NN-slug.md` | `SPEC-ARCH-01-auth-service.md` |
| SPEC-API | `SPEC-API-NN-slug.md` | `SPEC-API-01-auth-rest.md` |
| SPEC-DATA | `SPEC-DATA-NN-slug.md` | `SPEC-DATA-01-user-schema.md` |
| SPEC-INT | `SPEC-INT-NN-slug.md` | `SPEC-INT-01-auth-integration.md` |
| SPEC-PROC | `SPEC-PROC-NN-slug.md` | `SPEC-PROC-01-onboarding-flow.md` |
| SPEC-UI | `SPEC-UI-NN-slug.md` | `SPEC-UI-01-login-screen.md` |
| SPEC-AI | `SPEC-AI-NN-slug.md` | `SPEC-AI-01-chat-rag.md` |
| SPEC-SEC | `SPEC-SEC-NN-slug.md` | `SPEC-SEC-01-authn-model.md` |
| SPEC-OPS | `SPEC-OPS-NN-slug.md` | `SPEC-OPS-01-deploy-runbook.md` |
| SPEC-UI cross-cutting | `SPEC-UI-00-cross-cutting.md` | |

NN — двузначный номер (01, 02, ... 99).

---

## 5. Правила коммитов

Коммить каждое логически завершённое изменение **отдельно**. Не накапливай изменения.

### Формат сообщения коммита

```
[AI] <type>(<scope>): <краткое описание>
```

Типы:
- `feat` — новое требование
- `change` — изменение существующего требования
- `fix` — исправление ошибки в требовании
- `deprecate` — пометка требования как устаревшего

Примеры:
```
[AI] feat(sr): добавлен SR-01 аутентификация TOTP
[AI] change(br): уточнены AC в BR-03 управление сессиями
[AI] fix(sr): исправлен scope в SR-07 логирование событий
[AI] feat(spec): создан SPEC-UI-01 экран входа
```

---

## 6. Работа с шаблонами

Если для типа требования существует шаблон в библиотеке — используй его.  
Шаблоны находятся в `~/projects/kibertum/requirements-library/`.

Обязательно заполни поле `derived-from`:
```yaml
derived-from:
  template-id: "SR-AUTH-001"
  template-version: "1.2.0"
  library-commit: "abc1234"
```

---

## 7. Работа с дельта-ТЗ

Если тип ветки `change/TZ-YYYY-NNN-*`:

1. **Прочитай файл ТЗ** в `tz/TZ-YYYY-NNN-delta.md`
2. **Прочитай индекс** в `tz/TZ-YYYY-NNN-index.md` — там маппинг разделов на требования
3. **Выполни Impact Analysis** — какие BR/SR затрагивает каждый раздел дельты
4. Для каждого затронутого требования определи тип изменения:
   - `расширение` — добавляется новый функционал
   - `уточнение` — детализируется существующий
   - `замена` — требование полностью переопределяется
   - `отмена` — требование становится неактуальным

Для отменённых требований: **не удаляй файл**, только добавь в конец:
```markdown
## Статус устаревания

**Причина:** [причина из ТЗ]  
**Документ:** [TZ-YYYY-NNN §N.N]  
**Замена:** [SR-XX или "не предусмотрена"]
```
Статус `deprecated` проставит финализация.

---

## 8. Что категорически запрещено

- Изменять файлы в `tz/` — они только для чтения
- Удалять файлы требований — только помечать deprecated
- Обновлять `REQUIREMENTS.md` вручную
- Обновлять поля `children:` в родительских требованиях
- Проставлять `status: approved` самостоятельно
- Создавать ветки или делать merge
- Запускать `req-finalize.sh`

---

## 9. Сигнал о готовности

Когда задача из `TASK.md` выполнена, напиши инженеру:

```
Задача выполнена. Итог:
- Создано: [список файлов с кратким описанием]
- Изменено: [список файлов]
- Коммитов: N

Проверьте результат и запустите финализацию:
./docs/scripts/req-finalize.sh --repo <путь к репозиторию>
```

Не продолжай работу без подтверждения инженера после этого сообщения.

---

## 10. Быстрая шпаргалка

| Действие | Можно | Запрещено |
|----------|-------|-----------|
| Создать BR/SR/SPEC файл | ✓ | |
| Изменить содержимое требования | ✓ | |
| Поставить status: draft | ✓ | |
| Закоммитить изменение | ✓ | |
| Поставить status: approved | | ✗ |
| Обновить version | | ✗ (auto) |
| Обновить updated | | ✗ (auto) |
| Обновить children | | ✗ (auto) |
| Обновить REQUIREMENTS.md | | ✗ (auto) |
| Редактировать tz/ файлы | | ✗ |
| Удалить файл требования | | ✗ |
| Создать ветку | | ✗ |
| Запустить req-finalize.sh | | ✗ |
