#!/usr/bin/env bash
# =============================================================================
# req-contribute-template.sh — Предложить улучшение шаблона в библиотеку
#
# Берёт улучшенное требование из текущего проекта и создаёт MR
# в requirements-library с предложением обновить шаблон.
#
# Использование:
#   ./req-contribute-template.sh
#   ./req-contribute-template.sh --req-file svc-a.req/sr/SR-01-auth.md
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/example"
LIBRARY="${LOCAL_BASE}/requirements-library"
GITLAB_BASE="git@gitlab.com:example"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }

REQ_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --req-file) REQ_FILE="$2"; shift 2 ;;
    -h|--help)
      echo "Использование: $0 --req-file path/to/SR-01-auth.md"
      exit 0 ;;
    *) shift ;;
  esac
done

# --- Проверка ---
if [ ! -d "$LIBRARY" ]; then
  log_error "Библиотека шаблонов не найдена: ${LIBRARY}
  Сначала запустите req-setup.sh"
fi

# --- Выбор файла требования ---
if [ -z "$REQ_FILE" ]; then
  echo ""
  echo -e "${BLUE}=== Предложение улучшения шаблона ===${NC}"
  echo ""
  echo "Укажите файл требования, которое вы хотите предложить как улучшение шаблона."
  echo "Файл должен содержать поле derived-from в frontmatter."
  echo ""
  read -rp "Путь к файлу требования: " REQ_FILE
fi

REQ_FILE=$(realpath "$REQ_FILE" 2>/dev/null || echo "$REQ_FILE")

if [ ! -f "$REQ_FILE" ]; then
  log_error "Файл не найден: ${REQ_FILE}"
fi

# --- Читаем метаданные из файла требования ---
template_id=$(grep "template-id:" "$REQ_FILE" | head -1 | awk '{print $2}' || true)
template_version=$(grep "template-version:" "$REQ_FILE" | head -1 | awk '{print $2}' || true)
req_id=$(grep "^id:" "$REQ_FILE" | head -1 | awk '{print $2}' || true)
req_title=$(grep "^title:" "$REQ_FILE" | head -1 | sed 's/title: //' | tr -d '"' || true)

if [ -z "$template_id" ]; then
  log_error "В файле ${REQ_FILE} не найдено поле derived-from.template-id.
  Этот файл не основан на шаблоне из библиотеки."
fi

log_info "Требование: ${req_id} — ${req_title}"
log_info "Шаблон-источник: ${template_id} v${template_version}"

# --- Найти оригинальный шаблон ---
template_file=$(find "$LIBRARY" -name "*.md" | xargs grep -l "^template-id: ${template_id}" 2>/dev/null | head -1 || true)
if [ -z "$template_file" ]; then
  log_error "Шаблон '${template_id}' не найден в библиотеке"
fi

current_version=$(grep "^version:" "$template_file" | head -1 | awk '{print $2}')
log_info "Текущая версия шаблона в библиотеке: v${current_version}"

# --- Показываем diff ---
echo ""
echo -e "${BLUE}=== Различия между вашим требованием и шаблоном ===${NC}"
echo ""

# Извлекаем тело (без frontmatter) из обоих файлов
extract_body() {
  awk '/^---/{i++; if(i==2){found=1; next}} found{print}' "$1"
}

tmp_req=$(mktemp)
tmp_tpl=$(mktemp)
extract_body "$REQ_FILE" > "$tmp_req"
extract_body "$template_file" > "$tmp_tpl"

if diff --unified=3 "$tmp_tpl" "$tmp_req" > /dev/null 2>&1; then
  echo -e "${YELLOW}Нет различий в содержимом между требованием и шаблоном.${NC}"
  echo "Возможно, изменения только во frontmatter — они не переносятся в шаблон."
  rm -f "$tmp_req" "$tmp_tpl"
  exit 0
fi

diff --unified=3 --color=always "$tmp_tpl" "$tmp_req" || true
rm -f "$tmp_req" "$tmp_tpl"

echo ""
read -rp "Предложить эти изменения в библиотеку? [y/N]: " confirm
[ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && exit 0

# --- Описание изменений ---
echo ""
echo "Опишите что вы изменили и почему (несколько строк, завершите пустой строкой):"
CHANGE_DESCRIPTION=""
while IFS= read -r line; do
  [ -z "$line" ] && break
  CHANGE_DESCRIPTION="${CHANGE_DESCRIPTION}${line}
"
done

echo ""
echo "Ссылка на задачу где это применялось (например TASK-42, или Enter чтобы пропустить):"
read -rp "> " TASK_REF

# --- Вычисляем новую версию ---
major=$(echo "$current_version" | cut -d. -f1)
minor=$(echo "$current_version" | cut -d. -f2)
new_version="${major}.$((minor+1))"

# --- Создаём ветку и коммит в библиотеке ---
today=$(date +%Y-%m-%d)
git_user=$(git config user.name 2>/dev/null || echo "unknown")
branch_slug=$(echo "$template_id" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
branch_name="contrib/${branch_slug}-$(date +%Y%m%d)"

log_info "Создаю ветку ${branch_name} в requirements-library..."

cd "$LIBRARY"

# Убеждаемся что main актуален
git checkout main --quiet
git pull --ff-only --quiet

git checkout -b "$branch_name"

# Обновляем версию в шаблоне
sed -i "s/^version: ${current_version}/version: ${new_version}/" "$template_file"

# Применяем изменения из файла требования (только тело, не frontmatter)
{
  # Сохраняем frontmatter шаблона
  awk '/^---/{i++; if(i==2){print; exit} print; next} i{print}' "$template_file"
  echo ""
  # Добавляем тело из требования
  awk '/^---/{i++; if(i==2){found=1; next}} found{print}' "$REQ_FILE"
} > "${template_file}.new"
mv "${template_file}.new" "$template_file"

# Добавляем проект в verified-in если его там нет
project_entry="  - \"example/acme (${today})\""
if ! grep -q "example/acme" "$template_file"; then
  sed -i "/^verified-in:/a\\${project_entry}" "$template_file"
fi

# Коммит
git add "$template_file"
git commit -m "contrib(${template_id}): предложить улучшение v${current_version} → v${new_version}

Источник: ${req_id} — ${req_title}
Автор: ${git_user}
${TASK_REF:+Задача: ${TASK_REF}}

Описание изменений:
${CHANGE_DESCRIPTION}"

log_ok "Коммит создан в ветке ${branch_name}"

# --- Инструкция по созданию MR ---
echo ""
echo -e "${YELLOW}=== Следующие шаги ===${NC}"
echo ""
echo "1. Отправьте ветку в GitLab:"
echo "   git -C ${LIBRARY} push origin ${branch_name}"
echo ""
echo "2. Создайте MR в GitLab:"
echo "   Откройте: https://gitlab.com/example/requirements-library/-/merge_requests/new"
echo "   Source branch: ${branch_name}"
echo "   Target branch: main"
echo ""
echo "   Описание MR (скопируйте):"
echo "   ─────────────────────────────────────────"
echo "   ## Улучшение шаблона ${template_id} v${current_version} → v${new_version}"
echo ""
echo "   **Источник:** ${req_id} в example/acme"
[ -n "$TASK_REF" ] && echo "   **Задача:** ${TASK_REF}"
echo ""
echo "   **Изменения:**"
echo "   ${CHANGE_DESCRIPTION}"
echo "   ─────────────────────────────────────────"
echo ""
echo "3. Дождитесь ревью архитектора."
echo "   - Принято → шаблон обновлён до v${new_version}"
echo "   - Отклонено → получите комментарий с обоснованием"
echo ""
