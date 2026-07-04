#!/usr/bin/env bash
# =============================================================================
# req-use-template.sh — Использование шаблона требования из библиотеки
#
# Копирует шаблон из requirements-library в локальную библиотеку проекта,
# затем создаёт требование на его основе с заполненным frontmatter.
#
# Использование:
#   ./req-use-template.sh
#   ./req-use-template.sh --template SR-AUTH-001 --subsystem svc-a --id SR-01 --slug auth
# =============================================================================

set -euo pipefail

LOCAL_BASE="${HOME}/projects/example"
LIBRARY="${LOCAL_BASE}/requirements-library"
SYSTEM="acme"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }

# --- Парсинг аргументов ---
TEMPLATE_ID=""
SUBSYSTEM=""
REQ_ID=""
REQ_SLUG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template)   TEMPLATE_ID="$2"; shift 2 ;;
    --subsystem)  SUBSYSTEM="$2";   shift 2 ;;
    --id)         REQ_ID="$2";      shift 2 ;;
    --slug)       REQ_SLUG="$2";    shift 2 ;;
    -h|--help)
      echo "Использование: $0 --template SR-AUTH-001 --subsystem svc-a --id SR-01 --slug auth"
      exit 0 ;;
    *) shift ;;
  esac
done

# --- Проверка библиотеки ---
if [ ! -d "$LIBRARY" ]; then
  log_error "Библиотека шаблонов не найдена: ${LIBRARY}
  Сначала запустите req-setup.sh"
fi

# --- Интерактивный режим ---

show_catalog() {
  echo ""
  echo -e "${BLUE}=== Каталог шаблонов ===${NC}"
  echo ""
  if [ -f "${LIBRARY}/CATALOG.md" ]; then
    # Выводим только таблицу из CATALOG.md
    grep -E "^\|" "${LIBRARY}/CATALOG.md" | head -40
  else
    # Fallback — список файлов
    find "$LIBRARY" -name "*.md" ! -name "CATALOG.md" | sort | while read -r f; do
      template_id=$(grep "^template-id:" "$f" 2>/dev/null | head -1 | awk '{print $2}' || echo "?")
      title=$(grep "^title:" "$f" 2>/dev/null | head -1 | sed 's/title: //' | tr -d '"' || echo "?")
      status=$(grep "^status:" "$f" 2>/dev/null | head -1 | awk '{print $2}' || echo "?")
      echo "  ${template_id}  ${status}  ${title}"
    done
  fi
  echo ""
}

if [ -z "$TEMPLATE_ID" ]; then
  show_catalog
  read -rp "Введите template-id шаблона: " TEMPLATE_ID
fi

# Найти файл шаблона
template_file=$(find "$LIBRARY" -name "*.md" | xargs grep -l "^template-id: ${TEMPLATE_ID}" 2>/dev/null | head -1 || true)
if [ -z "$template_file" ]; then
  log_error "Шаблон '${TEMPLATE_ID}' не найден в библиотеке"
fi

template_version=$(grep "^version:" "$template_file" | head -1 | awk '{print $2}')
template_status=$(grep "^status:" "$template_file" | head -1 | awk '{print $2}')
template_type=$(grep "^type:" "$template_file" | head -1 | awk '{print $2}')

log_info "Шаблон найден: ${TEMPLATE_ID} v${template_version} [${template_status}]"

# Предупреждение о статусе draft
if [ "$template_status" = "draft" ]; then
  echo -e "${YELLOW}[WARN]${NC} Шаблон в статусе 'draft' — не прошёл ревью архитектора."
  read -rp "Продолжить? [y/N]: " confirm
  [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && exit 0
fi

# Выбор подсистемы
if [ -z "$SUBSYSTEM" ]; then
  echo ""
  echo "Доступные подсистемы:"
  find "${LOCAL_BASE}/${SYSTEM}" -maxdepth 1 -name "*.req" -type d 2>/dev/null | \
    sed "s|${LOCAL_BASE}/${SYSTEM}/||" | sed 's|/.*||' | sort | sed 's/^/  /'
  read -rp "Введите подсистему: " SUBSYSTEM
fi

REQ_REPO="${LOCAL_BASE}/${SYSTEM}/${SUBSYSTEM}/${SUBSYSTEM}.req"
if [ ! -d "$REQ_REPO" ]; then
  log_error "Репозиторий не найден: ${REQ_REPO}
  Сначала запустите req-setup.sh --subsystem ${SUBSYSTEM}"
fi

# ID и slug нового требования
if [ -z "$REQ_ID" ]; then
  read -rp "Введите ID требования (например SR-01): " REQ_ID
fi
if [ -z "$REQ_SLUG" ]; then
  read -rp "Введите slug (например auth-registration): " REQ_SLUG
fi

# Определяем папку по типу шаблона.
# RENAR v1.0: 9 closed-list SPEC types (standard/03 §3.14) кладутся в общий spec/.
# Тип артефакта различается полем `type:` во frontmatter, не директорией.
# Integration requirement = обычный SR с `constrained-by: [SPEC-INT-N]` (§3.14.1).
case "$template_type" in
  BR)         req_dir="br" ;;
  SR)         req_dir="sr" ;;
  TR)         req_dir="tr" ;;
  SPEC-ARCH|SPEC-API|SPEC-DATA|SPEC-INT|SPEC-PROC|SPEC-UI|SPEC-AI|SPEC-SEC|SPEC-OPS)
              req_dir="spec" ;;
  *)          req_dir="sr" ;;
esac

# --- Копирование шаблона в library/templates/ ---

templates_dir="${REQ_REPO}/library/templates"
mkdir -p "$templates_dir"

template_copy="${templates_dir}/${TEMPLATE_ID}@${template_version}.md"
if [ ! -f "$template_copy" ]; then
  cp "$template_file" "$template_copy"
  log_ok "Шаблон скопирован в library/templates/${TEMPLATE_ID}@${template_version}.md"
else
  log_warn "Шаблон уже есть в library/templates/"
fi

# --- Создание файла требования ---

req_dir_path="${REQ_REPO}/${req_dir}"
mkdir -p "$req_dir_path"

req_file="${req_dir_path}/${REQ_ID}-${REQ_SLUG}.md"

if [ -f "$req_file" ]; then
  log_error "Файл уже существует: ${req_file}"
fi

today=$(date +%Y-%m-%d)
git_user=$(git config user.name 2>/dev/null || echo "unknown")

# Читаем содержимое шаблона (без frontmatter)
template_body=$(awk '/^---/{i++; if(i==2){found=1; next}} found{print}' "$template_file")

cat > "$req_file" << EOF
---
id: ${REQ_ID}
title: ""
level: ${template_type}
status: draft
version: 0.1
created: ${today}
updated: ${today}
owner: "@${git_user}"
parent:
  id: ""
  repo: "example/${SYSTEM}/${SYSTEM}.req"
  file: ""
source:
  document: ""
  section: ""
derived-from:
  template-id: ${TEMPLATE_ID}
  template-version: ${template_version}
  library: "example/requirements-library"
---

${template_body}
EOF

log_ok "Требование создано: ${req_dir}/${REQ_ID}-${REQ_SLUG}.md"

echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "  1. Отредактируйте файл — замените [PLACEHOLDER] значениями проекта:"
echo "     ${req_file}"
echo "  2. Заполните поля frontmatter: title, parent, source"
echo "  3. Создайте ветку и PR:"
echo "     git -C ${REQ_REPO} checkout -b feat/${REQ_ID}-${REQ_SLUG}"
echo ""
