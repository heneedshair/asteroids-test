#!/usr/bin/env bash
# =============================================================================
# req-update.sh — Обновление всех .req репозиториев и библиотеки шаблонов
#
# Делает git pull --ff-only во всех локально клонированных .req репозиториях.
# Показывает какие обновились, какие остались без изменений.
#
# Использование:
#   ./req-update.sh
#   ./req-update.sh --quiet
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/kibertum"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

QUIET=false
UPDATED=0
SKIPPED=0
FAILED=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet|-q) QUIET=true; shift ;;
    *) shift ;;
  esac
done

update_repo() {
  local repo_path="$1"
  local label
  label=$(echo "$repo_path" | sed "s|${HOME}/projects/kibertum/||")

  if [ ! -d "$repo_path/.git" ]; then
    return
  fi

  # Проверяем есть ли upstream
  if ! git -C "$repo_path" remote get-url origin &>/dev/null; then
    echo -e "${YELLOW}[SKIP]${NC}  $label — нет remote"
    ((SKIPPED++)) || true
    return
  fi

  # Fetch без вывода
  git -C "$repo_path" fetch --quiet 2>/dev/null || {
    echo -e "${RED}[ERR]${NC}   $label — не удалось сделать fetch"
    ((FAILED++)) || true
    return
  }

  local_hash=$(git -C "$repo_path" rev-parse HEAD)
  remote_hash=$(git -C "$repo_path" rev-parse '@{u}' 2>/dev/null || echo "none")

  if [ "$local_hash" = "$remote_hash" ]; then
    [ "$QUIET" = false ] && echo -e "${GRAY}[UP-TO-DATE]${NC} $label"
    ((SKIPPED++)) || true
  else
    if git -C "$repo_path" pull --ff-only --quiet 2>/dev/null; then
      commits=$(git -C "$repo_path" log "${local_hash}..HEAD" --oneline 2>/dev/null | wc -l | tr -d ' ')
      echo -e "${GREEN}[UPDATED]${NC}  $label — +${commits} коммит(ов)"
      ((UPDATED++)) || true

      # Проверяем обновились ли шаблоны
      if echo "$repo_path" | grep -q "requirements-library"; then
        changed_templates=$(git -C "$repo_path" diff --name-only "${local_hash}..HEAD" 2>/dev/null | grep -v "^CATALOG" || true)
        if [ -n "$changed_templates" ]; then
          echo -e "  ${YELLOW}↳ Обновлены шаблоны:${NC}"
          echo "$changed_templates" | sed 's/^/     /'
          echo -e "  ${YELLOW}↳ Запустите req-check-templates.sh для поиска устаревших требований${NC}"
        fi
      fi
    else
      echo -e "${RED}[CONFLICT]${NC} $label — есть локальные изменения, pull пропущен"
      ((FAILED++)) || true
    fi
  fi
}

echo ""
echo -e "${BLUE}=== Обновление репозиториев требований ===${NC}"
echo ""

# Обновляем библиотеку шаблонов
if [ -d "${LOCAL_BASE}/requirements-library" ]; then
  update_repo "${LOCAL_BASE}/requirements-library"
fi

# Обновляем все .req репозитории
find "${LOCAL_BASE}" -name "*.req" -type d 2>/dev/null | sort | while read -r repo; do
  update_repo "$repo"
done

echo ""
echo -e "Итог: ${GREEN}${UPDATED} обновлено${NC} | ${GRAY}${SKIPPED} без изменений${NC} | ${RED}${FAILED} ошибок${NC}"
echo ""
