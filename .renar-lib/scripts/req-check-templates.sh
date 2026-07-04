#!/usr/bin/env bash
# =============================================================================
# req-check-templates.sh — Проверка устаревших шаблонов в проектах
#
# Сканирует все .req репозитории и находит требования, основанные на шаблонах
# у которых в библиотеке вышла новая версия.
#
# Использование:
#   ./req-check-templates.sh
#   ./req-check-templates.sh --subsystem svc-a
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/example"
LIBRARY="${LOCAL_BASE}/requirements-library"
SYSTEM="acme"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

SUBSYSTEM=""
OUTDATED=0
UPTODATE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --subsystem) SUBSYSTEM="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [ ! -d "$LIBRARY" ]; then
  echo -e "${RED}[ERR]${NC} Библиотека шаблонов не найдена: ${LIBRARY}"
  exit 1
fi

echo ""
echo -e "${BLUE}=== Проверка версий шаблонов ===${NC}"
echo ""

# Получаем текущие версии всех шаблонов из библиотеки
declare -A LIBRARY_VERSIONS
while IFS= read -r f; do
  tid=$(grep "^template-id:" "$f" 2>/dev/null | head -1 | awk '{print $2}' || true)
  ver=$(grep "^version:" "$f" 2>/dev/null | head -1 | awk '{print $2}' || true)
  [ -n "$tid" ] && [ -n "$ver" ] && LIBRARY_VERSIONS["$tid"]="$ver"
done < <(find "$LIBRARY" -name "*.md" ! -name "CATALOG.md")

if [ ${#LIBRARY_VERSIONS[@]} -eq 0 ]; then
  echo -e "${YELLOW}В библиотеке нет шаблонов.${NC}"
  exit 0
fi

# Определяем какие .req сканировать
if [ -n "$SUBSYSTEM" ]; then
  search_paths=("${LOCAL_BASE}/${SYSTEM}/${SUBSYSTEM}/${SUBSYSTEM}.req")
else
  search_paths=()
  while IFS= read -r d; do
    search_paths+=("$d")
  done < <(find "${LOCAL_BASE}/${SYSTEM}" -name "*.req" -type d 2>/dev/null)
fi

for req_repo in "${search_paths[@]}"; do
  [ ! -d "$req_repo" ] && continue

  repo_label=$(echo "$req_repo" | sed "s|${LOCAL_BASE}/||")
  found_in_repo=false

  while IFS= read -r req_file; do
    template_id=$(grep "template-id:" "$req_file" 2>/dev/null | head -1 | awk '{print $2}' || true)
    [ -z "$template_id" ] && continue

    used_version=$(grep "template-version:" "$req_file" 2>/dev/null | head -1 | awk '{print $2}' || true)
    library_version="${LIBRARY_VERSIONS[$template_id]:-}"

    if [ -z "$library_version" ]; then
      continue
    fi

    req_id=$(grep "^id:" "$req_file" | head -1 | awk '{print $2}' || true)
    req_file_short=$(echo "$req_file" | sed "s|${req_repo}/||")

    if [ "$used_version" != "$library_version" ]; then
      if [ "$found_in_repo" = false ]; then
        echo -e "${YELLOW}${repo_label}${NC}"
        found_in_repo=true
      fi
      echo -e "  ${RED}[OUTDATED]${NC} ${req_id} — шаблон ${template_id}: v${used_version} → v${library_version}"
      echo -e "  ${GRAY}  Файл: ${req_file_short}${NC}"
      ((OUTDATED++)) || true
    else
      ((UPTODATE++)) || true
    fi
  done < <(find "$req_repo" -name "*.md" ! -path "*/library/*" 2>/dev/null)
done

echo ""
if [ $OUTDATED -eq 0 ]; then
  echo -e "${GREEN}Все шаблоны актуальны.${NC} Проверено требований: $((OUTDATED+UPTODATE))"
else
  echo -e "Итог: ${RED}${OUTDATED} устаревших${NC} | ${GREEN}${UPTODATE} актуальных${NC}"
  echo ""
  echo -e "${YELLOW}Что делать с устаревшими требованиями:${NC}"
  echo "  1. Прочитайте что изменилось в шаблоне:"
  echo "     git -C ${LIBRARY} log --oneline -- [путь к шаблону]"
  echo "  2. Вручную обновите AC в своём требовании если изменение актуально"
  echo "  3. Обновите поле derived-from.template-version в frontmatter"
  echo "  4. Скопируйте новую версию шаблона в library/templates/:"
  echo "     req-use-template.sh (обновит копию)"
fi
echo ""
