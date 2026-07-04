#!/usr/bin/env bash
# =============================================================================
# req-branch.sh — Создание рабочей ветки для работы с требованиями
#
# Точка входа в цикл изменения требований (SENAR §7.2).
# Инженер запускает этот скрипт перед тем как поставить задачу AI-агенту.
# Скрипт создаёт ветку, записывает задачу в TASK.md и выводит инструкцию
# для AI-агента.
#
# Использование:
#   ./req-branch.sh
#   ./req-branch.sh --subsystem svc-a --type feat --slug SR-01-auth-totp
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/example"
SYSTEM="acme"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }

SUBSYSTEM=""
BRANCH_TYPE=""
BRANCH_SLUG=""
TZ_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subsystem) SUBSYSTEM="$2";    shift 2 ;;
    --type)      BRANCH_TYPE="$2";  shift 2 ;;
    --slug)      BRANCH_SLUG="$2";  shift 2 ;;
    --tz)        TZ_ID="$2";        shift 2 ;;
    -h|--help)
      echo "Использование: $0 [--subsystem NAME] [--type feat|change|fix|deprecate] [--slug SLUG] [--tz TZ-ID]"
      exit 0 ;;
    *) shift ;;
  esac
done

echo ""
echo -e "${BLUE}=== Создание рабочей ветки требований ===${NC}"
echo ""

# --- Выбор репозитория ---
if [ -z "$SUBSYSTEM" ]; then
  echo "В каком репозитории работаем?"
  echo "  1) ${SYSTEM}.req  (системный уровень — BR, SPEC-INT)"
  idx=2
  declare -A sub_map
  for sub in svc-a svc-b svc-c svc-d; do
    repo="${LOCAL_BASE}/${SYSTEM}/${sub}/${sub}.req"
    if [ -d "$repo" ]; then
      echo "  ${idx}) ${sub}.req"
      sub_map[$idx]="$sub"
      ((idx++)) || true
    fi
  done
  echo ""
  read -rp "Выберите [1-$((idx-1))]: " choice

  if [ "$choice" = "1" ]; then
    SUBSYSTEM="__system__"
    REQ_REPO="${LOCAL_BASE}/${SYSTEM}/${SYSTEM}.req"
  elif [ -n "${sub_map[$choice]:-}" ]; then
    SUBSYSTEM="${sub_map[$choice]}"
    REQ_REPO="${LOCAL_BASE}/${SYSTEM}/${SUBSYSTEM}/${SUBSYSTEM}.req"
  else
    log_error "Неверный выбор"
  fi
else
  if [ "$SUBSYSTEM" = "system" ]; then
    SUBSYSTEM="__system__"
    REQ_REPO="${LOCAL_BASE}/${SYSTEM}/${SYSTEM}.req"
  else
    REQ_REPO="${LOCAL_BASE}/${SYSTEM}/${SUBSYSTEM}/${SUBSYSTEM}.req"
  fi
fi

if [ ! -d "$REQ_REPO" ]; then
  log_error "Репозиторий не найден: ${REQ_REPO}\nЗапустите req-setup.sh"
fi

# --- Тип ветки ---
if [ -z "$BRANCH_TYPE" ]; then
  echo "Тип изменения:"
  echo "  1) feat     — новое требование"
  echo "  2) change   — изменение по ТЗ-дельте"
  echo "  3) fix      — исправление ошибки в требовании"
  echo "  4) deprecate — пометить требование устаревшим"
  echo ""
  read -rp "Выберите [1-4]: " type_choice
  case "$type_choice" in
    1) BRANCH_TYPE="feat" ;;
    2) BRANCH_TYPE="change" ;;
    3) BRANCH_TYPE="fix" ;;
    4) BRANCH_TYPE="deprecate" ;;
    *) log_error "Неверный выбор" ;;
  esac
fi

# --- Slug ветки ---
if [ -z "$BRANCH_SLUG" ]; then
  if [ "$BRANCH_TYPE" = "change" ] && [ -z "$TZ_ID" ]; then
    read -rp "ID дельта-ТЗ (например TZ-2026-002): " TZ_ID
    read -rp "Краткое описание изменения (slug): " slug_input
    BRANCH_SLUG="${TZ_ID}-$(echo "$slug_input" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
  else
    read -rp "Slug ветки (например SR-01-auth-totp): " BRANCH_SLUG
    BRANCH_SLUG=$(echo "$BRANCH_SLUG" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  fi
fi

BRANCH_NAME="${BRANCH_TYPE}/${BRANCH_SLUG}"

# --- Задача для AI-агента ---
echo ""
echo "Опишите задачу для AI-агента (что нужно создать/изменить)."
echo "Завершите пустой строкой:"
TASK_DESCRIPTION=""
while IFS= read -r line; do
  [ -z "$line" ] && break
  TASK_DESCRIPTION="${TASK_DESCRIPTION}${line}\n"
done

# --- Создание ветки ---
log_info "Создаю ветку ${BRANCH_NAME} в $(basename ${REQ_REPO})..."

cd "$REQ_REPO"
git checkout main --quiet
git pull --ff-only --quiet 2>/dev/null || log_warn "Не удалось обновить main, продолжаю с локальной версией"
git checkout -b "$BRANCH_NAME"

# --- Запись задачи в TASK.md ---
today=$(date +%Y-%m-%d)
git_user=$(git config user.name 2>/dev/null || echo "unknown")

cat > "${REQ_REPO}/TASK.md" << EOF
---
branch: ${BRANCH_NAME}
type: ${BRANCH_TYPE}
created: ${today}
engineer: "@${git_user}"
status: in-progress
phase: iteration
---

# Задача для AI-агента

## Что нужно сделать

$(echo -e "$TASK_DESCRIPTION")

## Контекст

- Репозиторий: $(basename ${REQ_REPO})
- Ветка: ${BRANCH_NAME}
${TZ_ID:+- ТЗ: ${TZ_ID}}

## Правила выполнения

1. Все файлы требований создавать/изменять со статусом \`draft\`
2. НЕ обновлять REQUIREMENTS.md, children-ссылки и updated во время итерации
3. Коммитить каждое логически завершённое изменение отдельно
4. Ждать подтверждения инженера перед финализацией
5. Финализацию выполнять только через \`req-finalize.sh\`
EOF

git add TASK.md
git commit -m "${BRANCH_TYPE}: начало работы над ${BRANCH_SLUG}"

log_ok "Ветка создана: ${BRANCH_NAME}"
log_ok "Задача записана в TASK.md"

# --- Инструкция ---
echo ""
echo -e "${YELLOW}=== Ветка готова к работе ===${NC}"
echo ""
echo -e "  Репозиторий: ${GRAY}$(echo ${REQ_REPO} | sed "s|${HOME}|~|")${NC}"
echo -e "  Ветка:       ${GREEN}${BRANCH_NAME}${NC}"
echo ""
echo "Следующие шаги:"
echo ""
echo "  1. Передайте AI-агенту задачу из TASK.md:"
echo "     cat ${REQ_REPO}/TASK.md"
echo ""
echo "  2. AI-агент работает в ветке, вы проверяете результат"
echo ""
echo "  3. Когда результат устраивает — финализируйте:"
echo "     ./docs/scripts/req-finalize.sh --repo ${REQ_REPO}"
echo ""
echo "  Правила для AI-агента:"
echo "     cat ./docs/scripts/req-ai-instructions.md"
echo ""
