#!/usr/bin/env bash
# =============================================================================
# req-search.sh — Поиск по требованиям
#
# Ищет требования по ID, ключевым словам, тегам или типу.
# Работает по всем локально клонированным .req репозиториям.
#
# Использование:
#   ./req-search.sh BR-01
#   ./req-search.sh --type SR --domain auth
#   ./req-search.sh --keyword "авторизация"
#   ./req-search.sh --status deprecated
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/example"
SYSTEM="acme"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

SEARCH_ID=""
SEARCH_TYPE=""
SEARCH_KEYWORD=""
SEARCH_STATUS=""
SEARCH_DOMAIN=""
FOUND=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)    SEARCH_TYPE="$2";    shift 2 ;;
    --keyword) SEARCH_KEYWORD="$2"; shift 2 ;;
    --status)  SEARCH_STATUS="$2";  shift 2 ;;
    --domain)  SEARCH_DOMAIN="$2";  shift 2 ;;
    -h|--help)
      echo "Использование:"
      echo "  $0 BR-01                        — поиск по ID"
      echo "  $0 --type SR                    — все SR"
      echo "  $0 --type SR --domain auth      — SR по домену"
      echo "  $0 --keyword авторизация        — по ключевому слову"
      echo "  $0 --status deprecated          — устаревшие требования"
      exit 0 ;;
    *)
      # Позиционный аргумент — поиск по ID
      SEARCH_ID="$1"; shift ;;
  esac
done

print_match() {
  local file="$1"
  local repo_label
  repo_label=$(echo "$file" | sed "s|${LOCAL_BASE}/||" | sed 's|/[^/]*$||')

  local req_id title level status version
  req_id=$(grep "^id:" "$file" | head -1 | awk '{print $2}' || echo "?")
  title=$(grep "^title:" "$file" | head -1 | sed 's/title: //' | tr -d '"' || echo "?")
  level=$(grep "^level:" "$file" | head -1 | awk '{print $2}' || echo "?")
  status=$(grep "^status:" "$file" | head -1 | awk '{print $2}' || echo "?")
  version=$(grep "^version:" "$file" | head -1 | awk '{print $2}' || echo "?")

  local status_color="$NC"
  case "$status" in
    approved|verified) status_color="$GREEN" ;;
    draft)             status_color="$YELLOW" ;;
    deprecated)        status_color="$GRAY" ;;
  esac

  echo -e "${BLUE}${req_id}${NC} [${level}] ${title}"
  echo -e "  ${GRAY}${repo_label}${NC} | v${version} | ${status_color}${status}${NC}"
  echo -e "  ${GRAY}$(echo "$file" | sed "s|${LOCAL_BASE}/||")${NC}"
  echo ""
  ((FOUND++)) || true
}

matches_filters() {
  local file="$1"

  # Фильтр по типу
  if [ -n "$SEARCH_TYPE" ]; then
    level=$(grep "^level:" "$file" | head -1 | awk '{print $2}' || true)
    [ "$level" != "$SEARCH_TYPE" ] && return 1
  fi

  # Фильтр по статусу
  if [ -n "$SEARCH_STATUS" ]; then
    status=$(grep "^status:" "$file" | head -1 | awk '{print $2}' || true)
    [ "$status" != "$SEARCH_STATUS" ] && return 1
  fi

  # Фильтр по домену (тег или путь)
  if [ -n "$SEARCH_DOMAIN" ]; then
    if ! grep -qi "$SEARCH_DOMAIN" "$file" 2>/dev/null; then
      return 1
    fi
  fi

  # Фильтр по ключевому слову
  if [ -n "$SEARCH_KEYWORD" ]; then
    if ! grep -qi "$SEARCH_KEYWORD" "$file" 2>/dev/null; then
      return 1
    fi
  fi

  return 0
}

echo ""
echo -e "${BLUE}=== Поиск требований ===${NC}"
echo ""

# Формируем список репозиториев для поиска
search_repos=()
while IFS= read -r d; do
  search_repos+=("$d")
done < <(find "${LOCAL_BASE}/${SYSTEM}" -name "*.req" -type d 2>/dev/null | sort)

if [ ${#search_repos[@]} -eq 0 ]; then
  echo "Нет клонированных .req репозиториев."
  echo "Запустите: req-setup.sh"
  exit 0
fi

for repo in "${search_repos[@]}"; do
  while IFS= read -r file; do
    # Пропускаем шаблоны и индексы
    echo "$file" | grep -q "/library/" && continue
    echo "$file" | grep -q "/tz/" && continue
    echo "$file" | grep -q "REQUIREMENTS.md" && continue

    # Поиск по ID
    if [ -n "$SEARCH_ID" ]; then
      if grep -q "^id: ${SEARCH_ID}$" "$file" 2>/dev/null; then
        print_match "$file"
        continue
      fi
    fi

    # Поиск по фильтрам
    if [ -z "$SEARCH_ID" ] && matches_filters "$file"; then
      print_match "$file"
    fi

  done < <(find "$repo" -name "*.md" -not -path "*/.git/*" 2>/dev/null)
done

if [ $FOUND -eq 0 ]; then
  echo -e "${YELLOW}Ничего не найдено.${NC}"
  echo ""
  echo "Попробуйте:"
  echo "  $0 --type BR               — список всех BR"
  echo "  $0 --type SR               — список всех SR"
  echo "  $0 --status deprecated     — устаревшие требования"
else
  echo -e "Найдено: ${GREEN}${FOUND}${NC} требований"
fi
echo ""
