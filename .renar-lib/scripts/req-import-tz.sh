#!/usr/bin/env bash
# =============================================================================
# req-import-tz.sh — Импорт ТЗ из Princess в .req репозиторий
#
# Скачивает подписанное ТЗ из Princess API, конвертирует в Markdown
# и создаёт коммит в tz/ с правильным frontmatter.
#
# Использование:
#   ./req-import-tz.sh --order-id 123 --type initial
#   ./req-import-tz.sh --order-id 456 --type delta --base TZ-2025-001
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/example"
SYSTEM="acme"
PRINCESS_API="${PRINCESS_API_URL:-https://client.example.ru/api}"
PRINCESS_TOKEN="${PRINCESS_API_TOKEN:-}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }

ORDER_ID=""
TZ_TYPE=""
BASE_TZ=""
TZ_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --order-id) ORDER_ID="$2"; shift 2 ;;
    --type)     TZ_TYPE="$2";  shift 2 ;;
    --base)     BASE_TZ="$2";  shift 2 ;;
    --tz-id)    TZ_ID="$2";    shift 2 ;;
    -h|--help)
      echo "Использование:"
      echo "  $0 --order-id 123 --type initial"
      echo "  $0 --order-id 456 --type delta --base TZ-2025-001"
      echo ""
      echo "Переменные окружения:"
      echo "  PRINCESS_API_URL    — URL Princess API (default: https://client.example.ru/api)"
      echo "  PRINCESS_API_TOKEN  — токен авторизации"
      exit 0 ;;
    *) shift ;;
  esac
done

# --- Проверка репозитория ---
REQ_REPO="${LOCAL_BASE}/${SYSTEM}/${SYSTEM}.req"
if [ ! -d "$REQ_REPO" ]; then
  log_error "Репозиторий не найден: ${REQ_REPO}
  Сначала запустите req-setup.sh"
fi

# --- Интерактивный режим ---
echo ""
echo -e "${BLUE}=== Импорт ТЗ из Princess ===${NC}"
echo ""

if [ -z "$ORDER_ID" ]; then
  read -rp "ID заказа в Princess: " ORDER_ID
fi

if [ -z "$TZ_TYPE" ]; then
  echo "Тип ТЗ:"
  echo "  1) initial — первичное ТЗ"
  echo "  2) delta   — дополнение к существующему"
  read -rp "Выберите [1/2]: " tz_choice
  case "$tz_choice" in
    1) TZ_TYPE="initial" ;;
    2) TZ_TYPE="delta"   ;;
    *) log_error "Неверный выбор" ;;
  esac
fi

if [ "$TZ_TYPE" = "delta" ] && [ -z "$BASE_TZ" ]; then
  read -rp "ID базового ТЗ (например TZ-2025-001): " BASE_TZ
fi

# --- Генерируем ID ---
today=$(date +%Y-%m-%d)
year=$(date +%Y)

if [ -z "$TZ_ID" ]; then
  # Находим следующий номер
  existing=$(find "${REQ_REPO}/tz" -name "TZ-${year}-*.md" ! -name "*-index.md" ! -name "*-delta.md" 2>/dev/null | wc -l | tr -d ' ')
  next_num=$(printf "%03d" $((existing+1)))
  TZ_ID="TZ-${year}-${next_num}"
fi

log_info "ID нового ТЗ: ${TZ_ID}"

# --- Получение ТЗ из Princess ---
mkdir -p "${REQ_REPO}/tz"

if [ -n "$PRINCESS_TOKEN" ]; then
  log_info "Скачиваю ТЗ из Princess (заказ #${ORDER_ID})..."

  # Получаем метаданные заказа
  metadata=$(curl -sf \
    -H "Authorization: Bearer ${PRINCESS_TOKEN}" \
    "${PRINCESS_API}/orders/${ORDER_ID}/documents/tz" 2>/dev/null || echo "")

  if [ -z "$metadata" ]; then
    log_warn "Не удалось получить ТЗ из API. Переключаюсь на ручной режим."
    PRINCESS_TOKEN=""
  fi
fi

if [ -z "$PRINCESS_TOKEN" ]; then
  log_warn "PRINCESS_API_TOKEN не задан или API недоступен."
  echo ""
  echo "Ручной режим: вставьте содержимое ТЗ в Markdown."
  echo "Файл будет создан, вставьте содержимое самостоятельно."
  echo ""
fi

# --- Формируем имя файла ---
if [ "$TZ_TYPE" = "delta" ]; then
  tz_filename="${TZ_ID}-delta.md"
else
  tz_filename="${TZ_ID}.md"
fi

tz_file="${REQ_REPO}/tz/${tz_filename}"
tz_index="${REQ_REPO}/tz/${TZ_ID}-index.md"

if [ -f "$tz_file" ]; then
  log_error "Файл уже существует: ${tz_file}"
fi

# --- Получаем метаданные ---
read -rp "Название ТЗ: " TZ_TITLE
read -rp "Дата подписания (YYYY-MM-DD) [${today}]: " signed_date
signed_date="${signed_date:-$today}"
git_user=$(git config user.name 2>/dev/null || echo "unknown")

# --- Создаём файл ТЗ ---
cat > "$tz_file" << EOF
---
id: "${TZ_ID}"
title: "${TZ_TITLE}"
type: ${TZ_TYPE}
signed-date: ${signed_date}
source-url: "${PRINCESS_API_URL:-https://client.example.ru}/orders/${ORDER_ID}/documents/tz"
imported-date: ${today}
imported-by: "@${git_user}"
${BASE_TZ:+base-document: "${BASE_TZ}"}
---

> КОПИЯ. Источник истины: [${TZ_ID} в Princess](${PRINCESS_API_URL:-https://client.example.ru}/orders/${ORDER_ID}/documents/tz).
> При расхождении — оригинал имеет приоритет. Не редактировать вручную.

EOF

if [ -n "$metadata" ]; then
  # Если получили данные из API — добавляем content
  echo "$metadata" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('content_md', '<!-- Содержимое ТЗ -->'))
" >> "$tz_file" 2>/dev/null || echo "<!-- Вставьте содержимое ТЗ здесь -->" >> "$tz_file"
else
  echo "<!-- Вставьте содержимое ТЗ здесь -->" >> "$tz_file"
fi

log_ok "Файл ТЗ создан: tz/${tz_filename}"

# --- Создаём индекс ---
cat > "$tz_index" << EOF
---
document: "${TZ_ID}"
title: "${TZ_TITLE}"
type: ${TZ_TYPE}
${BASE_TZ:+base-document: "${BASE_TZ}"}
date: ${signed_date}
status: open
---

# ${TZ_ID} — Индекс маппинга

${TZ_TYPE:+**Тип:** ${TZ_TYPE}}
${BASE_TZ:+**Базовый документ:** ${BASE_TZ}}

| Раздел ТЗ | Название раздела | Требование(я) | Тип изменения |
|-----------|-----------------|---------------|---------------|
| §     |  |  | ${TZ_TYPE} |

EOF

log_ok "Файл индекса создан: tz/${TZ_ID}-index.md"

# --- Инструкция ---
echo ""
echo -e "${YELLOW}=== Следующие шаги ===${NC}"
echo ""
echo "1. Если ТЗ не подтянулось автоматически — вставьте содержимое вручную:"
echo "   ${tz_file}"
echo ""
echo "2. Заполните таблицу маппинга в индексе:"
echo "   ${tz_index}"
echo ""
echo "3. Создайте ветку и зафиксируйте:"
if [ "$TZ_TYPE" = "delta" ]; then
  echo "   cd ${REQ_REPO}"
  echo "   git checkout -b change/${TZ_ID}-$(echo "$TZ_TITLE" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | head -c 30)"
  echo "   git add tz/"
  echo "   git commit -m \"[delta:${TZ_ID}] импорт дельта-ТЗ: ${TZ_TITLE}\""
else
  echo "   cd ${REQ_REPO}"
  echo "   git checkout -b feat/${TZ_ID}-initial"
  echo "   git add tz/"
  echo "   git commit -m \"feat: импорт ТЗ ${TZ_ID}: ${TZ_TITLE}\""
fi
echo ""
echo "4. Выполните декомпозицию ТЗ → BR/SR:"
echo "   Запустите req-search.sh для просмотра существующих требований"
echo ""
