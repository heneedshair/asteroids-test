#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# publish-github.sh — Sync RENAR standard to public GitHub mirror
#
# What it does:
#   1. rsync from this repo (req-standart/, private GitLab)
#   2. Excludes private dev tooling (.claude/, .tausik/, CLAUDE.md, ...)
#   3. Excludes research/ (internal drafts, not for public release)
#   4. Copies to ../renar-public/ (separate git repo → GitHub)
#   5. Shows diff for review
#   6. Commits and pushes ONLY with --push flag
#
# Usage (run from WSL or any *nix shell with rsync):
#   ./scripts/publish-github.sh          # dry run — shows what changed
#   ./scripts/publish-github.sh --push   # actually commit and push
#
# Prerequisites:
#   - rsync available (WSL on Windows: `wsl bash scripts/publish-github.sh`)
#   - ../renar-public/ exists with `git init` + GitHub remote configured
#   - GitHub repo: https://github.com/Kibertum/RENAR
#
# What gets EXCLUDED (stays only in GitLab):
#   .claude/          — TAUSIK + Claude tooling (scripts, MCP, skills)
#   .claude-project/  — ephemeral session state
#   .tausik/          — TAUSIK runtime (db, venv, rag, logs)
#   .tausik-lib/      — TAUSIK submodule source
#   CLAUDE.md         — internal AI agent rules
#   .mcp.json         — MCP server config (may carry private URLs)
#   .gitlab-ci.yml    — GitLab CI pipeline
#   .gitmodules       — submodule refs (point at private GitLab)
#   research/         — 19 internal drafts (обоснования, not normative)
#
# What gets INCLUDED (public on GitHub):
#   standard/         — RENAR Standard v1.0-draft (15 chapters)
#   guide/            — Practical Guide (8 chapters)
#   core/             — RENAR Core (gentle single-doc intro)
#   reference/        — Appendices (glossary, schemas, AI risk register)
#   site/             — Astro site source (renar.tech)
#   scripts/          — Build & sync scripts (including this one)
#   docs/             — Top-level docs
#   README.md / README.ru.md
#   LICENSE
#   CHANGELOG.md
#   RENAR-SUMMARY.md / RENAR-SUMMARY-RU.md
#   Dockerfile / docker-compose.yml
#   .gitignore / .dockerignore
# ─────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(cd "$SOURCE_DIR/../renar-public" 2>/dev/null && pwd)" || {
    echo "ERROR: renar-public/ not found at $SOURCE_DIR/../renar-public"
    echo ""
    echo "Create it first:"
    echo "  mkdir ../renar-public && cd ../renar-public"
    echo "  git init -b main"
    echo "  git remote add origin git@github.com:Kibertum/RENAR.git"
    echo ""
    echo "Then re-run this script."
    exit 1
}

PUSH=false
if [[ "${1:-}" == "--push" ]]; then
    PUSH=true
fi

EXCLUDE_PATTERNS=(
    ".claude/"
    ".claude-project/"
    ".tausik/"
    ".tausik-lib/"
    "CLAUDE.md"
    ".mcp.json"
    ".gitlab-ci.yml"
    ".gitmodules"
    "research/"
)

echo "═══ RENAR GitHub Publisher ═══"
echo "Source:  $SOURCE_DIR (GitLab — private)"
echo "Target:  $TARGET_DIR (GitHub — public)"
echo ""

EXCLUDE_ARGS=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    EXCLUDE_ARGS+=(--exclude="$pattern")
done

# Also exclude non-tracked / build dirs (defensive)
EXCLUDE_ARGS+=(--exclude=".git/")
EXCLUDE_ARGS+=(--exclude=".rag/")
EXCLUDE_ARGS+=(--exclude=".venv/")
EXCLUDE_ARGS+=(--exclude="node_modules/")
EXCLUDE_ARGS+=(--exclude="site/node_modules/")
EXCLUDE_ARGS+=(--exclude="site/dist/")
EXCLUDE_ARGS+=(--exclude="site/.astro/")
EXCLUDE_ARGS+=(--exclude="site/src/content/")
EXCLUDE_ARGS+=(--exclude="__pycache__/")

echo "Syncing files..."
rsync -av --delete \
    "${EXCLUDE_ARGS[@]}" \
    "$SOURCE_DIR/" "$TARGET_DIR/"

echo ""
echo "═══ Changes in renar-public ═══"
cd "$TARGET_DIR"
git add -A
git status --short

CHANGES=$(git diff --cached --stat | tail -1)
if [[ -z "$CHANGES" ]]; then
    echo "No changes to publish."
    exit 0
fi

echo ""
echo "$CHANGES"

if [[ "$PUSH" == true ]]; then
    GITLAB_HASH=$(cd "$SOURCE_DIR" && git rev-parse --short HEAD)

    echo ""
    echo "Committing and pushing..."
    git commit -m "sync: update from GitLab ($GITLAB_HASH)"
    git push origin main
    echo ""
    echo "✓ Published to GitHub"
else
    echo ""
    echo "Dry run complete. To publish:"
    echo "  ./scripts/publish-github.sh --push"
fi
