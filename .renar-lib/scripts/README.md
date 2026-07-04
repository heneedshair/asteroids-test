# Скрипты для работы с требованиями

Набор bash-скриптов для поддержки стандарта управления требованиями.  
Подробнее: [standard/06-requirements-hierarchy.md](../standard/06-requirements-hierarchy.md), [standard/08-specifications.md](../standard/08-specifications.md), [standard/10-lifecycle-qg.md](../standard/10-lifecycle-qg.md).

---

## Скрипты

### Цикл изменения требований (SENAR §7)

| Скрипт | Назначение |
|--------|-----------|
| [req-branch.sh](req-branch.sh) | **Шаг 1.** Создание рабочей ветки и TASK.md для AI-агента |
| [req-ai-instructions.md](req-ai-instructions.md) | **Шаг 2.** Правила для AI-агента (передать агенту вместе с TASK.md) |
| [req-finalize.sh](req-finalize.sh) | **Шаг 3.** Финализация: версии, статусы, REQUIREMENTS.md, diff-summary, MR |

### Вспомогательные скрипты

| Скрипт | Назначение |
|--------|-----------|
| [req-setup.sh](req-setup.sh) | Первоначальная настройка локального окружения |
| [req-update.sh](req-update.sh) | Обновление всех `.req` репозиториев и библиотеки |
| [req-search.sh](req-search.sh) | Поиск требований по ID, типу, ключевому слову |
| [req-qg0-check.sh](req-qg0-check.sh) | Интерактивная проверка Context Gate QG-0 |
| [req-import-tz.sh](req-import-tz.sh) | Импорт подписанного ТЗ из Princess |
| [req-use-template.sh](req-use-template.sh) | Использование шаблона из библиотеки |
| [req-contribute-template.sh](req-contribute-template.sh) | Предложение улучшения шаблона в библиотеку |
| [req-check-templates.sh](req-check-templates.sh) | Проверка устаревших шаблонов в проекте |

---

## Быстрый старт

```bash
# Сделать скрипты исполняемыми
chmod +x docs/scripts/*.sh

# 1. Настроить окружение (первый раз)
./docs/scripts/req-setup.sh

# 2. Обновлять регулярно
./docs/scripts/req-update.sh

# 3. Перед задачей — проверить QG-0
./docs/scripts/req-qg0-check.sh

# 4. При получении нового ТЗ
./docs/scripts/req-import-tz.sh --order-id 123 --type initial
```

## Цикл работы с требованиями (типовой)

```bash
# Инженер: создаём ветку и формулируем задачу для AI
./docs/scripts/req-branch.sh --subsystem svc-a --type feat --slug SR-01-auth-totp

# Инженер: передаём AI-агенту два файла:
cat ~/projects/example/acme/svc-a/svc-a.req/TASK.md
cat ./docs/scripts/req-ai-instructions.md

# AI-агент работает в ветке (создаёт/изменяет файлы, коммитит)
# ...

# Инженер: проверяем результат, финализируем и создаём MR
./docs/scripts/req-finalize.sh --repo ~/projects/example/acme/svc-a/svc-a.req
```

---

## Типичные сценарии

### Начало работы на новом проекте
```bash
./req-setup.sh --subsystem svc-a
```

### Найти требование перед задачей
```bash
./req-search.sh SR-01
./req-search.sh --type BR
./req-search.sh --keyword "авторизация"
```

### Использовать шаблон при создании SR
```bash
./req-use-template.sh --template SR-AUTH-001 --subsystem svc-a --id SR-01 --slug auth
```

### Предложить улучшение шаблона после разработки
```bash
./req-contribute-template.sh --req-file ~/projects/example/acme/svc-a/svc-a.req/sr/SR-01-auth.md
```

### Проверить устаревшие шаблоны
```bash
./req-check-templates.sh --subsystem svc-a
```

### Импортировать дельта-ТЗ
```bash
./req-import-tz.sh --order-id 456 --type delta --base TZ-2025-001
```

---

## Переменные окружения

| Переменная | Назначение | По умолчанию |
|-----------|-----------|-------------|
| `PRINCESS_API_URL` | URL Princess API | `https://client.example.ru/api` |
| `PRINCESS_API_TOKEN` | Токен авторизации в Princess | — |

Задайте в `~/.bashrc` или `~/.zshrc`:

```bash
export PRINCESS_API_URL="https://client.example.ru/api"
export PRINCESS_API_TOKEN="your-token-here"
```
