#!/usr/bin/env bash
# =============================================================================
# req-setup.sh — Настройка локального окружения разработчика
#
# Клонирует нужные .req и .src репозитории в правильную иерархию папок.
# Зеркалит структуру GitLab: org/system/subsystem/
#
# Использование:
#   ./req-setup.sh
#   ./req-setup.sh --subsystem svc-a
#   ./req-setup.sh --all
# =============================================================================

set -euo pipefail

# --- Конфигурация ---
GITLAB_BASE="git@gitlab.com:example"
LOCAL_BASE="${HOME}/projects/example"
SYSTEM="acme"
SUBSYSTEMS=("svc-a" "svc-b" "svc-c" "svc-d")

# --- Цвета ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERR]${NC}  $1"; }

# --- Функции ---

clone_if_missing() {
  local url="$1"
  local dest="$2"
  local label="$3"

  if [ -d "$dest/.git" ]; then
    log_warn "$label — уже клонирован, пропускаю"
  else
    log_info "Клонирую $label..."
    mkdir -p "$(dirname "$dest")"
    if git clone "$url" "$dest" --quiet; then
      log_ok "$label"
    else
      log_error "Не удалось клонировать $label ($url)"
      return 1
    fi
  fi
}

clone_system_req() {
  clone_if_missing \
    "${GITLAB_BASE}/${SYSTEM}/${SYSTEM}.req" \
    "${LOCAL_BASE}/${SYSTEM}/${SYSTEM}.req" \
    "System requirements (${SYSTEM}.req)"
}

clone_library() {
  clone_if_missing \
    "${GITLAB_BASE}/requirements-library" \
    "${LOCAL_BASE}/requirements-library" \
    "Requirements library"
}

clone_subsystem() {
  local sub="$1"
  local base="${LOCAL_BASE}/${SYSTEM}/${sub}"

  clone_if_missing \
    "${GITLAB_BASE}/${SYSTEM}/${sub}/${sub}.req" \
    "${base}/${sub}.req" \
    "${sub}.req"

  clone_if_missing \
    "${GITLAB_BASE}/${SYSTEM}/${sub}/${sub}.src" \
    "${base}/${sub}.src" \
    "${sub}.src"
}

create_workspace_file() {
  local sub="$1"
  local workspace_file="${LOCAL_BASE}/${SYSTEM}/${sub}/${sub}.code-workspace"

  if [ -f "$workspace_file" ]; then
    log_warn "Workspace файл уже существует: $workspace_file"
    return
  fi

  cat > "$workspace_file" << EOF
{
  "folders": [
    {
      "path": "${sub}.src",
      "name": "Code — ${sub}"
    },
    {
      "path": "${sub}.req",
      "name": "Requirements — ${sub}"
    },
    {
      "path": "../${SYSTEM}.req",
      "name": "Requirements — System (read only)"
    }
  ],
  "settings": {
    "files.exclude": {
      "**/.git": true
    },
    "search.exclude": {
      "**/library/templates": true
    }
  }
}
EOF
  log_ok "Workspace файл создан: ${sub}.code-workspace"
}

print_result() {
  echo ""
  echo -e "${GREEN}=== Готово ===${NC}"
  echo ""
  echo "Структура:"
  find "${LOCAL_BASE}" -maxdepth 4 \( -name "*.req" -o -name "*.src" -o -name "requirements-library" \) \
    -type d 2>/dev/null | sort | sed "s|${HOME}|~|g" | sed 's/^/  /'
  echo ""
  echo "Следующие шаги:"
  echo "  1. Откройте workspace в VS Code:"
  if [ -n "${CHOSEN_SUB:-}" ]; then
    echo "     code ~/projects/example/${SYSTEM}/${CHOSEN_SUB}/${CHOSEN_SUB}.code-workspace"
  fi
  echo "  2. Посмотрите шаблоны требований:"
  echo "     cat ~/projects/example/requirements-library/CATALOG.md"
  echo "  3. Прочитайте инструкцию разработчика:"
  echo "     guide/08-developer-guide.md"
}

# --- Парсинг аргументов ---

CHOSEN_SUB=""
CLONE_ALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subsystem)
      CHOSEN_SUB="$2"; shift 2 ;;
    --all)
      CLONE_ALL=true; shift ;;
    -h|--help)
      echo "Использование: $0 [--subsystem NAME | --all]"
      echo ""
      echo "Опции:"
      echo "  --subsystem NAME   Клонировать конкретную подсистему (${SUBSYSTEMS[*]})"
      echo "  --all              Клонировать все подсистемы"
      echo ""
      echo "Без опций — интерактивный выбор"
      exit 0 ;;
    *)
      log_error "Неизвестный аргумент: $1"; exit 1 ;;
  esac
done

# --- Интерактивный режим ---

if [ -z "$CHOSEN_SUB" ] && [ "$CLONE_ALL" = false ]; then
  echo ""
  echo "=== Настройка рабочего окружения ==="
  echo ""
  echo "Система: ${SYSTEM}"
  echo "Локальная папка: ${LOCAL_BASE}/${SYSTEM}/"
  echo ""
  echo "Доступные подсистемы:"
  for i in "${!SUBSYSTEMS[@]}"; do
    echo "  $((i+1))) ${SUBSYSTEMS[$i]}"
  done
  echo "  a) Все подсистемы"
  echo ""
  read -rp "Выберите подсистему [1-${#SUBSYSTEMS[@]}/a]: " choice

  case "$choice" in
    a|A) CLONE_ALL=true ;;
    [1-9])
      idx=$((choice-1))
      if [ $idx -lt ${#SUBSYSTEMS[@]} ]; then
        CHOSEN_SUB="${SUBSYSTEMS[$idx]}"
      else
        log_error "Неверный выбор"; exit 1
      fi ;;
    *) log_error "Неверный выбор"; exit 1 ;;
  esac
fi

# --- Выполнение ---

echo ""
log_info "Начинаю настройку..."
echo ""

# Всегда клонируем системные требования и библиотеку
clone_system_req
clone_library

if [ "$CLONE_ALL" = true ]; then
  for sub in "${SUBSYSTEMS[@]}"; do
    clone_subsystem "$sub"
    create_workspace_file "$sub"
  done
elif [ -n "$CHOSEN_SUB" ]; then
  # Проверяем что подсистема существует
  valid=false
  for sub in "${SUBSYSTEMS[@]}"; do
    [ "$sub" = "$CHOSEN_SUB" ] && valid=true
  done
  if [ "$valid" = false ]; then
    log_error "Неизвестная подсистема: ${CHOSEN_SUB}"
    echo "Доступные: ${SUBSYSTEMS[*]}"
    exit 1
  fi
  clone_subsystem "$CHOSEN_SUB"
  create_workspace_file "$CHOSEN_SUB"
fi

print_result
