#!/usr/bin/env bash
# init-memory.sh — create the workspace memory files this skill expects.
#
# Usage:
#   ./init-memory.sh                       # prompts for workspace dir
#   ./init-memory.sh ~/.openclaw/ws/reddit # non-interactive
#
# Creates:
#   <workspace>/memory/
#     ├── reddit-recaps.md
#     ├── reddit-post-log.md
#     ├── reddit-reply-log.md
#     ├── reddit-karma-log.md
#     ├── reddit-subs-state.md
#     ├── reddit-ideas.md
#     └── reddit-learnings.md
#
# Idempotent: existing files are left untouched.

set -euo pipefail

WORKSPACE_DIR="${1:-}"

if [[ -z "${WORKSPACE_DIR}" ]]; then
  read -r -p "Workspace dir (e.g. ~/.openclaw/workspace/reddit-acme): " WORKSPACE_DIR
fi

WORKSPACE_DIR="${WORKSPACE_DIR/#\~/$HOME}"
MEMORY_DIR="${WORKSPACE_DIR}/memory"

mkdir -p "${MEMORY_DIR}"

FILES=(
  reddit-recaps.md
  reddit-post-log.md
  reddit-reply-log.md
  reddit-karma-log.md
  reddit-subs-state.md
  reddit-ideas.md
  reddit-learnings.md
)

created=0
skipped=0
for f in "${FILES[@]}"; do
  if [[ -f "${MEMORY_DIR}/${f}" ]]; then
    echo "↩  ${f} already exists — left untouched"
    skipped=$((skipped + 1))
  else
    {
      echo "# ${f%.md}"
      echo
      echo "<!-- Appended by reddit-account-operations crons. -->"
    } > "${MEMORY_DIR}/${f}"
    echo "✅ ${f} created"
    created=$((created + 1))
  fi
done

echo
echo "Done. ${created} created, ${skipped} skipped."
echo "Memory dir: ${MEMORY_DIR}"
