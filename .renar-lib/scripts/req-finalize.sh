#!/usr/bin/env bash
# =============================================================================
# req-finalize.sh — Финализация изменений требований и создание MR
#
# Выполняет фазы 2-4 цикла изменения требований (SENAR §7.3-7.5):
#   Фаза 2: финализирующий коммит (версии, статусы, REQUIREMENTS.md, children)
#   Фаза 3: генерация diff-summary для ревью
#   Фаза 4: создание MR в GitLab (через glab или вывод инструкций)
#
# Использование:
#   ./req-finalize.sh
#   ./req-finalize.sh --repo ~/projects/example/acme/svc-a/svc-a.req
#   ./req-finalize.sh --repo <path> --no-mr
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
log_step()  { echo -e "\n${BLUE}--- $1 ---${NC}"; }

REQ_REPO=""
NO_MR=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)    REQ_REPO="$2"; shift 2 ;;
    --no-mr)   NO_MR=true;    shift ;;
    --dry-run) DRY_RUN=true;  shift ;;
    -h|--help)
      echo "Использование: $0 [--repo PATH] [--no-mr] [--dry-run]"
      echo ""
      echo "  --repo PATH    Путь к .req репозиторию"
      echo "  --no-mr        Не создавать MR, только финализирующий коммит"
      echo "  --dry-run      Показать что будет сделано без изменений"
      exit 0 ;;
    *) shift ;;
  esac
done

echo ""
echo -e "${BLUE}=== Финализация требований (SENAR §7.3-7.5) ===${NC}"
echo ""

# --- Определяем репозиторий ---
if [ -z "$REQ_REPO" ]; then
  # Пытаемся определить из текущей директории
  if git -C . rev-parse --git-dir > /dev/null 2>&1; then
    REQ_REPO=$(git -C . rev-parse --show-toplevel)
    echo -e "Используется текущий репозиторий: ${GRAY}${REQ_REPO}${NC}"
  else
    log_error "Укажите репозиторий через --repo или запустите из .req директории"
  fi
fi

if [ ! -d "$REQ_REPO" ]; then
  log_error "Репозиторий не найден: ${REQ_REPO}"
fi

cd "$REQ_REPO"

# --- Проверки ---
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  log_error "Финализация запускается из рабочей ветки, не из main"
fi

# Проверяем что ветка соответствует стандарту
if ! echo "$CURRENT_BRANCH" | grep -qE '^(feat|change|fix|deprecate)/'; then
  log_warn "Ветка '${CURRENT_BRANCH}' не соответствует формату type/slug"
  read -rp "Продолжить? [y/N]: " confirm
  [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && exit 1
fi

log_info "Ветка: ${CURRENT_BRANCH}"
log_info "Репозиторий: ${REQ_REPO}"

# Определяем тип ветки
BRANCH_TYPE=$(echo "$CURRENT_BRANCH" | cut -d'/' -f1)
BRANCH_SLUG=$(echo "$CURRENT_BRANCH" | cut -d'/' -f2-)

# --- Находим изменённые файлы требований ---
log_step "Анализ изменений"

CHANGED_FILES=$(git diff --name-only main...HEAD -- '*.md' 2>/dev/null || \
                git diff --name-only origin/main...HEAD -- '*.md' 2>/dev/null || \
                git diff --name-only HEAD~1 -- '*.md' 2>/dev/null || echo "")

# Фильтруем только файлы требований (не tz/, не REQUIREMENTS.md, не TASK.md)
REQ_FILES=""
for f in $CHANGED_FILES; do
  # Пропускаем служебные файлы
  case "$f" in
    tz/*|REQUIREMENTS.md|TASK.md|*-index.md) continue ;;
  esac
  # Только br/, sr/, tr/, spec/, docs/
  # RENAR v1.0: SPEC-* артефакты унифицированы в spec/ (см. standard/03 §3.14)
  case "$f" in
    br/*|sr/*|tr/*|spec/*|docs/*)
      REQ_FILES="${REQ_FILES} ${f}"
      ;;
  esac
done

REQ_FILES=$(echo "$REQ_FILES" | tr ' ' '\n' | grep -v '^$' || true)

if [ -z "$REQ_FILES" ]; then
  log_warn "Не найдено изменённых файлов требований (br/, sr/, tr/, spec/, docs/)"
  echo "Изменённые файлы:"
  git diff --name-only main...HEAD -- '*.md' 2>/dev/null | head -20 || true
  read -rp "Продолжить без обновления файлов? [y/N]: " confirm
  [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && exit 1
fi

echo ""
echo "Файлы для финализации:"
echo "$REQ_FILES" | while read -r f; do
  [ -z "$f" ] && continue
  echo "  ${f}"
done

# ============================================================================
# ФАЗА 2: Финализирующий коммит
# ============================================================================
log_step "Фаза 2: Финализирующий коммит"

today=$(date +%Y-%m-%d)

update_req_file() {
  local file="$1"
  local action="$2"   # "approve" | "deprecate"

  if [ ! -f "$file" ]; then
    log_warn "Файл не найден: ${file}"
    return
  fi

  # Читаем текущую версию
  current_version=$(grep "^version:" "$file" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '"' || echo "0.1.0")
  current_status=$(grep "^status:" "$file" 2>/dev/null | head -1 | awk '{print $2}' || echo "draft")

  if [ "$current_status" != "draft" ]; then
    log_warn "Пропускаю ${file}: статус '${current_status}' (не draft)"
    return
  fi

  # Рассчитываем новую версию
  IFS='.' read -r major minor patch <<< "$current_version"
  major=${major:-0}
  minor=${minor:-1}
  patch=${patch:-0}

  if [ "$action" = "deprecate" ]; then
    new_version="${major}.${minor}.${patch}"
    new_status="deprecated"
  elif [ "$BRANCH_TYPE" = "change" ] && [ "$current_version" != "0.1.0" ]; then
    # Изменение существующего: minor bump
    new_minor=$((minor + 1))
    new_version="${major}.${new_minor}.0"
    new_status="approved"
  else
    # Новое или первая версия
    new_version="1.0.0"
    new_status="approved"
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] ${file}: ${current_version} → ${new_version}, ${current_status} → ${new_status}"
    return
  fi

  # Обновляем version, status, updated
  # Используем python для безопасного редактирования frontmatter
  python3 -c "
import re, sys

with open('${file}', 'r', encoding='utf-8') as f:
    content = f.read()

# Обновляем поля в frontmatter (между первыми двумя ---)
parts = content.split('---', 2)
if len(parts) < 3:
    sys.exit(0)

fm = parts[1]
fm = re.sub(r'^version:.*$', 'version: \"${new_version}\"', fm, flags=re.MULTILINE)
fm = re.sub(r'^status:.*$', 'status: ${new_status}', fm, flags=re.MULTILINE)
fm = re.sub(r'^updated:.*$', 'updated: ${today}', fm, flags=re.MULTILINE)

parts[1] = fm
with open('${file}', 'w', encoding='utf-8') as f:
    f.write('---'.join(parts))

print('  updated: ${file} → v${new_version} [${new_status}]')
" 2>/dev/null || log_warn "Не удалось обновить: ${file}"
}

# Обрабатываем каждый файл
echo "$REQ_FILES" | while read -r req_file; do
  [ -z "$req_file" ] && continue

  if [ "$BRANCH_TYPE" = "deprecate" ]; then
    update_req_file "$req_file" "deprecate"
  else
    update_req_file "$req_file" "approve"
  fi
done

# --- Пересобираем REQUIREMENTS.md ---
rebuild_requirements_md() {
  local req_md="${REQ_REPO}/REQUIREMENTS.md"

  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] Пересборка REQUIREMENTS.md"
    return
  fi

  log_info "Пересобираю REQUIREMENTS.md..."

  python3 -c "
import os, re, glob
from datetime import datetime

repo = '${REQ_REPO}'
today = '${today}'

# RENAR v1.0 canonical sections (standard/03 §3.3–§3.4, §3.14).
# Все 9 SPEC-* типов кладутся в общий spec/, различаются полем type: во frontmatter.
# Integration requirement = SR с constrained-by:[SPEC-INT-N] (§3.14.1), не отдельный тип.
# Каждая секция = (folder, title, type_filter):
#   type_filter=None — взять все файлы в папке;
#   type_filter='SPEC-X' — только файлы с frontmatter type: SPEC-X.
sections = [
    ('BR',        'br',   'Бизнес-требования',     None),
    ('SR',        'sr',   'Системные требования',  None),
    ('TR',        'tr',   'Задачные требования',   None),
    ('SPEC-ARCH', 'spec', 'SPEC-ARCH Артефакты',   'SPEC-ARCH'),
    ('SPEC-API',  'spec', 'SPEC-API Артефакты',    'SPEC-API'),
    ('SPEC-DATA', 'spec', 'SPEC-DATA Артефакты',   'SPEC-DATA'),
    ('SPEC-INT',  'spec', 'SPEC-INT Артефакты',    'SPEC-INT'),
    ('SPEC-PROC', 'spec', 'SPEC-PROC Артефакты',   'SPEC-PROC'),
    ('SPEC-UI',   'spec', 'SPEC-UI Артефакты',     'SPEC-UI'),
    ('SPEC-AI',   'spec', 'SPEC-AI Артефакты',     'SPEC-AI'),
    ('SPEC-SEC',  'spec', 'SPEC-SEC Артефакты',    'SPEC-SEC'),
    ('SPEC-OPS',  'spec', 'SPEC-OPS Артефакты',    'SPEC-OPS'),
]

output = []
output.append('# Реестр требований')
output.append('')
output.append(f'> Сгенерировано автоматически: {today}. Не редактировать вручную.')
output.append('')

def _read_fm(fpath):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    parts = content.split('---', 2)
    if len(parts) < 3:
        return None
    return parts[1]

def _get_field(fm, name):
    m = re.search(rf'^{name}:\s*(.+)$', fm, re.MULTILINE)
    return m.group(1).strip().strip('\"') if m else '-'

for req_type, folder, title, type_filter in sections:
    folder_path = os.path.join(repo, folder)
    if not os.path.isdir(folder_path):
        continue

    candidates = sorted(glob.glob(os.path.join(folder_path, '*.md')))
    files = []
    for fpath in candidates:
        fm = _read_fm(fpath)
        if fm is None:
            continue
        if type_filter is not None and _get_field(fm, 'type') != type_filter:
            continue
        files.append((fpath, fm))

    if not files:
        continue

    output.append(f'## {title} ({req_type})')
    output.append('')
    output.append('| ID | Название | Статус | Версия | Обновлено |')
    output.append('|----|----------|--------|--------|-----------|')

    for fpath, fm in files:
        rid = _get_field(fm, 'id')
        title_val = _get_field(fm, 'title')
        status = _get_field(fm, 'status')
        version = _get_field(fm, 'version')
        updated = _get_field(fm, 'updated')

        rel_path = os.path.relpath(fpath, repo)
        output.append(f'| [{rid}]({rel_path}) | {title_val} | {status} | {version} | {updated} |')

    output.append('')

with open(os.path.join(repo, 'REQUIREMENTS.md'), 'w', encoding='utf-8') as f:
    f.write('\n'.join(output))

print('  REQUIREMENTS.md пересобран')
" 2>/dev/null || log_warn "Не удалось пересобрать REQUIREMENTS.md"
}

rebuild_requirements_md

# --- Обновляем children в родителях ---
update_children_links() {
  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] Обновление children-ссылок"
    return
  fi

  log_info "Обновляю children-ссылки..."

  python3 -c "
import os, re, glob

repo = '${REQ_REPO}'

# Собираем карту parent → [children]
parent_map = {}

for folder in ['sr', 'tr', 'spec']:
    folder_path = os.path.join(repo, folder)
    if not os.path.isdir(folder_path):
        continue

    for fpath in glob.glob(os.path.join(folder_path, '*.md')):
        with open(fpath, 'r', encoding='utf-8') as f:
            content = f.read()

        parts = content.split('---', 2)
        if len(parts) < 3:
            continue
        fm = parts[1]

        # Ищем parent.id
        m = re.search(r'^\s*id:\s*[\"']?([^\"'\n]+)[\"']?', fm, re.MULTILINE)
        child_id_m = re.search(r'^id:\s*[\"']?([^\"'\n]+)[\"']?', fm, re.MULTILINE)

        parent_m = re.search(r'parent:\s*\n\s+id:\s*[\"']?([^\"'\n]+)[\"']?', fm)
        if not parent_m or not child_id_m:
            continue

        parent_id = parent_m.group(1).strip().strip('\"')
        child_id = child_id_m.group(1).strip().strip('\"')

        if parent_id not in parent_map:
            parent_map[parent_id] = []
        if child_id not in parent_map[parent_id]:
            parent_map[parent_id].append(child_id)

# Обновляем children в BR файлах
for fpath in glob.glob(os.path.join(repo, 'br', '*.md')):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()

    parts = content.split('---', 2)
    if len(parts) < 3:
        continue

    fm = parts[1]
    m = re.search(r'^id:\s*[\"']?([^\"'\n]+)[\"']?', fm, re.MULTILINE)
    if not m:
        continue

    br_id = m.group(1).strip().strip('\"')
    if br_id not in parent_map:
        continue

    children = parent_map[br_id]
    children_yaml = '[' + ', '.join(f'\"{c}\"' for c in children) + ']'

    new_fm = re.sub(r'^children:.*$', f'children: {children_yaml}', fm, flags=re.MULTILINE)
    if new_fm != fm:
        parts[1] = new_fm
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write('---'.join(parts))
        print(f'  children обновлены: {os.path.basename(fpath)} → {children}')
" 2>/dev/null || log_warn "Не удалось обновить children-ссылки"
}

update_children_links

# --- Финализирующий коммит ---
if [ "$DRY_RUN" = false ]; then
  git add -A

  if git diff --cached --quiet; then
    log_info "Нет изменений для коммита в фазе 2"
  else
    branch_slug_short=$(echo "$BRANCH_SLUG" | head -c 50)
    git commit -m "finalize: ${branch_slug_short}

Финализация ветки ${CURRENT_BRANCH}:
- Версии обновлены
- Статусы: draft → approved/deprecated
- REQUIREMENTS.md пересобран
- children-ссылки обновлены"

    log_ok "Финализирующий коммит создан"
  fi
fi

# ============================================================================
# ФАЗА 3: Генерация diff-summary
# ============================================================================
log_step "Фаза 3: Diff-summary для ревью"

DIFF_SUMMARY_FILE="${REQ_REPO}/DIFF-SUMMARY-${BRANCH_SLUG}.md"

generate_diff_summary() {
  local out_file="$1"

  python3 -c "
import subprocess, os, re, sys
from datetime import datetime

branch = '${CURRENT_BRANCH}'
slug = '${BRANCH_SLUG}'
branch_type = '${BRANCH_TYPE}'
today = '${today}'
repo = '${REQ_REPO}'

# Получаем список изменённых файлов
try:
    result = subprocess.run(
        ['git', 'diff', '--name-status', 'main...HEAD', '--', '*.md'],
        capture_output=True, text=True, cwd=repo
    )
    changed = result.stdout.strip().split('\n') if result.stdout.strip() else []
except:
    changed = []

lines = []
lines.append(f'# Diff-Summary: {branch}')
lines.append('')
lines.append(f'**Дата:** {today}  ')
lines.append(f'**Ветка:** \`{branch}\`  ')
lines.append(f'**Тип:** {branch_type}  ')
lines.append('')
lines.append('## Изменённые требования')
lines.append('')
lines.append('| Статус | Файл | ID | Описание изменения |')
lines.append('|--------|------|----|--------------------|')

status_map = {'A': 'Добавлен', 'M': 'Изменён', 'D': 'Удалён'}

for line in changed:
    if not line.strip():
        continue
    parts = line.split('\t', 1)
    if len(parts) != 2:
        continue

    st, fpath = parts
    # Пропускаем служебные
    if any(x in fpath for x in ['REQUIREMENTS.md', 'TASK.md', 'DIFF-SUMMARY', 'tz/']):
        continue

    status_label = status_map.get(st, st)
    fname = os.path.basename(fpath)

    # Читаем ID и title из файла
    req_id = '-'
    req_title = '-'
    full_path = os.path.join(repo, fpath)
    if os.path.exists(full_path):
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        fm_parts = content.split('---', 2)
        if len(fm_parts) >= 3:
            fm = fm_parts[1]
            m_id = re.search(r'^id:\s*[\"']?([^\"'\n]+)[\"']?', fm, re.MULTILINE)
            m_title = re.search(r'^title:\s*[\"']?([^\"'\n]+)[\"']?', fm, re.MULTILINE)
            if m_id:
                req_id = m_id.group(1).strip().strip('\"')
            if m_title:
                req_title = m_title.group(1).strip().strip('\"')

    lines.append(f'| {status_label} | {fpath} | {req_id} | {req_title} |')

lines.append('')
lines.append('## Коммиты в ветке')
lines.append('')
lines.append('\`\`\`')
try:
    result = subprocess.run(
        ['git', 'log', '--oneline', 'main..HEAD'],
        capture_output=True, text=True, cwd=repo
    )
    lines.append(result.stdout.strip())
except:
    lines.append('(не удалось получить лог)')
lines.append('\`\`\`')
lines.append('')
lines.append('## Чеклист ревью')
lines.append('')
lines.append('- [ ] Требования соответствуют ТЗ/задаче')
lines.append('- [ ] ID и slug файлов соответствуют стандарту именования')
lines.append('- [ ] Все AC верифицируемы и независимы')
lines.append('- [ ] Негативные сценарии описаны')
lines.append('- [ ] parent/children связи корректны')
lines.append('- [ ] Нет избыточных или дублирующих требований')
if branch_type == 'change':
    lines.append('- [ ] Impact Analysis выполнен полностью')
    lines.append('- [ ] Все затронутые требования обновлены')

print('\n'.join(lines))
" > "$out_file" 2>/dev/null

  if [ $? -eq 0 ] && [ -f "$out_file" ]; then
    log_ok "Diff-summary создан: $(basename ${out_file})"
  else
    log_warn "Не удалось сгенерировать diff-summary (python3 недоступен?)"
    cat > "$out_file" << HEREDOC
# Diff-Summary: ${CURRENT_BRANCH}

**Дата:** ${today}
**Ветка:** \`${CURRENT_BRANCH}\`

## Изменённые файлы

\`\`\`
$(git diff --name-status main...HEAD -- '*.md' 2>/dev/null | grep -v 'REQUIREMENTS\|TASK\|DIFF-SUMMARY\|tz/' || echo "(нет данных)")
\`\`\`

## Коммиты

\`\`\`
$(git log --oneline main..HEAD 2>/dev/null || echo "(нет данных)")
\`\`\`
HEREDOC
    log_ok "Базовый diff-summary создан: $(basename ${out_file})"
  fi
}

if [ "$DRY_RUN" = false ]; then
  generate_diff_summary "$DIFF_SUMMARY_FILE"
  git add "$(basename ${DIFF_SUMMARY_FILE})"
  if ! git diff --cached --quiet; then
    git commit -m "docs: diff-summary для ${BRANCH_SLUG}"
  fi
else
  echo "  [dry-run] Генерация diff-summary: DIFF-SUMMARY-${BRANCH_SLUG}.md"
fi

# ============================================================================
# ФАЗА 4: Создание MR
# ============================================================================
log_step "Фаза 4: Merge Request"

if [ "$NO_MR" = true ]; then
  log_info "Пропуск создания MR (--no-mr)"
else
  if [ "$DRY_RUN" = false ]; then
    # Пушим ветку
    log_info "Пушу ветку ${CURRENT_BRANCH}..."
    git push -u origin "$CURRENT_BRANCH" 2>/dev/null || \
      log_warn "Не удалось запушить ветку. Возможно нет remote или нет доступа."
  fi

  # Пробуем создать MR через glab
  if command -v glab &> /dev/null && [ "$DRY_RUN" = false ]; then
    log_info "Создаю MR через glab..."

    # Формируем описание MR
    MR_DESC=$(cat << MRDOC
## Изменения требований

**Ветка:** \`${CURRENT_BRANCH}\`
**Тип:** ${BRANCH_TYPE}

### Что изменено

$([ -f "$DIFF_SUMMARY_FILE" ] && grep -A 50 "## Изменённые требования" "$DIFF_SUMMARY_FILE" | head -20 || echo "см. DIFF-SUMMARY-${BRANCH_SLUG}.md")

### Чеклист ревью

- [ ] Требования соответствуют ТЗ/задаче
- [ ] ID и slug файлов корректны
- [ ] Все AC верифицируемы
- [ ] parent/children связи корректны

MRDOC
)

    glab mr create \
      --title "${BRANCH_TYPE}: ${BRANCH_SLUG}" \
      --description "$MR_DESC" \
      --target-branch main \
      --assignee "@me" \
      2>/dev/null && log_ok "MR создан" || \
      log_warn "glab mr create завершился с ошибкой. Создайте MR вручную."
  else
    # Выводим инструкции для ручного создания MR
    echo ""
    echo -e "${YELLOW}=== Создайте MR вручную ===${NC}"
    echo ""
    echo "  1. Откройте GitLab и создайте MR:"
    echo "     Source branch:  ${CURRENT_BRANCH}"
    echo "     Target branch:  main"
    echo ""
    echo "  2. Заголовок MR:"
    echo "     ${BRANCH_TYPE}: ${BRANCH_SLUG}"
    echo ""
    echo "  3. Прикрепите diff-summary к описанию:"
    echo "     $(basename ${DIFF_SUMMARY_FILE})"
    echo ""
    if [ "$DRY_RUN" = false ]; then
      echo "  4. Запуш ветку если не сделали:"
      echo "     git push -u origin ${CURRENT_BRANCH}"
      echo ""
    fi
  fi
fi

# --- Итог ---
echo ""
echo -e "${GREEN}=== Финализация завершена ===${NC}"
echo ""

if [ "$DRY_RUN" = false ]; then
  echo -e "  Ветка:        ${GREEN}${CURRENT_BRANCH}${NC}"
  echo -e "  Diff-summary: ${GRAY}$(basename ${DIFF_SUMMARY_FILE})${NC}"
  echo ""
  echo "Следующие шаги для инженера:"
  echo "  1. Просмотрите MR и diff-summary"
  echo "  2. После апрува — MR мержится в main"
  echo "  3. Удалите рабочую ветку после мержа"
else
  echo "  [dry-run] В реальном режиме будут выполнены все шаги выше"
fi
echo ""
