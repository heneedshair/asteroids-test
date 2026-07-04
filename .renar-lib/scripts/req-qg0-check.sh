#!/usr/bin/env bash
# =============================================================================
# req-qg0-check.sh — Проверка Context Gate QG-0 перед началом задачи
#
# Интерактивная проверка готовности задачи к разработке по чеклисту SENAR §8.1.
# Показывает связанный SR и помогает убедиться что все условия выполнены.
#
# Использование:
#   ./req-qg0-check.sh
#   ./req-qg0-check.sh --sr SR-01 --subsystem svc-a
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

SR_ID=""
SUBSYSTEM=""
PASS=0
FAIL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sr)        SR_ID="$2";    shift 2 ;;
    --subsystem) SUBSYSTEM="$2"; shift 2 ;;
    *) shift ;;
  esac
done

check_item() {
  local label="$1"
  local hint="$2"

  echo -e "  ${YELLOW}?${NC} ${label}"
  [ -n "$hint" ] && echo -e "    ${GRAY}${hint}${NC}"
  read -rp "    Выполнено? [y/n]: " ans

  if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
    echo -e "    ${GREEN}✓ OK${NC}"
    ((PASS++)) || true
    return 0
  else
    echo -e "    ${RED}✗ НЕ ВЫПОЛНЕНО${NC}"
    ((FAIL++)) || true
    return 1
  fi
}

find_sr_file() {
  local sr_id="$1"
  local sub="$2"

  if [ -n "$sub" ]; then
    find "${LOCAL_BASE}/${SYSTEM}/${sub}/${sub}.req" \
      -name "*.md" 2>/dev/null | \
      xargs grep -l "^id: ${sr_id}$" 2>/dev/null | head -1
  else
    find "${LOCAL_BASE}/${SYSTEM}" -name "*.req" -type d 2>/dev/null | \
      while read -r repo; do
        find "$repo" -name "*.md" 2>/dev/null | \
          xargs grep -l "^id: ${sr_id}$" 2>/dev/null | head -1
      done | head -1
  fi
}

echo ""
echo -e "${BLUE}=== Context Gate QG-0 (SENAR §8.1) ===${NC}"
echo ""
echo "Проверка готовности задачи к разработке."
echo ""

# --- Ввод данных задачи ---
read -rp "ID задачи (например TASK-42): " TASK_ID
read -rp "Краткое описание задачи: " TASK_DESC

if [ -z "$SR_ID" ]; then
  read -rp "Ссылка на SR (например SR-01, или Enter чтобы пропустить): " SR_ID
fi

# --- Показываем SR если найден ---
if [ -n "$SR_ID" ]; then
  sr_file=$(find_sr_file "$SR_ID" "$SUBSYSTEM")

  if [ -n "$sr_file" ]; then
    echo ""
    echo -e "${BLUE}=== Связанный SR ===${NC}"
    sr_title=$(grep "^title:" "$sr_file" | head -1 | sed 's/title: //' | tr -d '"')
    sr_status=$(grep "^status:" "$sr_file" | head -1 | awk '{print $2}')
    sr_parent=$(grep "^  id:" "$sr_file" | head -1 | awk '{print $2}')
    echo -e "  ${SR_ID}: ${sr_title}"
    echo -e "  Статус: ${sr_status} | Родитель: ${sr_parent:-не указан}"
    echo -e "  Файл: $(echo "$sr_file" | sed "s|${LOCAL_BASE}/||")"

    if [ "$sr_status" = "deprecated" ]; then
      echo ""
      echo -e "${RED}[СТОП]${NC} SR ${SR_ID} имеет статус 'deprecated'."
      echo "Задача не может ссылаться на устаревшее требование."
      echo "Уточните у архитектора актуальный SR."
      exit 1
    fi
  else
    echo -e "${YELLOW}[WARN]${NC} SR ${SR_ID} не найден локально."
    echo "Убедитесь что репозиторий требований клонирован (req-setup.sh)"
  fi
fi

echo ""
echo -e "${BLUE}=== Чеклист QG-0 ===${NC}"
echo ""

# --- Чеклист ---
check_item \
  "Цель задачи сформулирована (Goal)" \
  "Одно предложение: что нужно реализовать, понятное без контекста"

check_item \
  "Acceptance Criteria верифицируемы и независимы" \
  "Каждый AC можно проверить отдельно: 'система возвращает X при условии Y'"

check_item \
  "Есть хотя бы один негативный сценарий в AC" \
  "Например: 'возвращает 401 при неверном пароле', 'возвращает 422 если поле пустое'"

check_item \
  "Задача ссылается на SR (или BR)" \
  "Поле в трекере заполнено: SR-XX или BR-XX"

check_item \
  "Назначен тип работы (Work Type)" \
  "Feature / Bug / Refactor / Infrastructure / Research"

security_answer=""
read -rp "  ? Задача затрагивает безопасность? [y/n]: " security_answer
if [ "$security_answer" = "y" ] || [ "$security_answer" = "Y" ]; then
  check_item \
    "Threat Surface задекларирован" \
    "Описаны: какие данные затрагиваются, какие роли имеют доступ, какие угрозы возможны"
fi

# --- Итог ---
echo ""
echo -e "${BLUE}=== Результат ===${NC}"
echo ""
total=$((PASS+FAIL))

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ QG-0 пройден${NC} — ${PASS}/${total} пунктов выполнены"
  echo ""
  echo -e "  Задача ${TASK_ID} готова к разработке."
  echo ""
  echo "  Следующие шаги:"
  echo "  1. Создайте ветку:"
  echo "     git checkout -b feat/${TASK_ID}-$(echo "$TASK_DESC" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | head -c 40)"
  echo "  2. Реализуйте задачу согласно AC"
  echo "  3. Напишите тесты на каждый AC включая негативные"
else
  echo -e "${RED}✗ QG-0 не пройден${NC} — ${FAIL} пункт(ов) не выполнены"
  echo ""
  echo -e "  ${YELLOW}Задачу нельзя брать в разработку.${NC}"
  echo ""
  echo "  Что сделать:"
  echo "  1. Верните задачу Supervisor с комментарием о незаполненных пунктах"
  echo "  2. Дождитесь уточнения требований"
  echo "  3. Повторите проверку QG-0"
fi
echo ""
