#!/usr/bin/env bash
# install.sh — copy this skill into your local agent's skills directory.
#
# Detects supported agent stacks and installs into each one that's present:
#   • Claude Code        → ~/.claude/skills/reddit-account-operations/
#   • OpenClaw           → ~/.openclaw/skills/reddit-account-operations/
#
# Idempotent: re-running overwrites the SKILL.md with the latest version.
#
# Usage:
#   ./install.sh              # auto-detect and install everywhere supported
#   ./install.sh claude       # force install into ~/.claude only
#   ./install.sh openclaw     # force install into ~/.openclaw only
#
# Exit codes:
#   0 = installed somewhere
#   1 = no supported target found

set -euo pipefail

SKILL_NAME="reddit-account-operations"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="${SCRIPT_DIR}/SKILL.md"

if [[ ! -f "${SKILL_SOURCE}" ]]; then
  echo "❌ SKILL.md not found next to install.sh (expected at ${SKILL_SOURCE})" >&2
  exit 1
fi

TARGET="${1:-auto}"
installed_count=0

install_into() {
  local label="$1"
  local base_dir="$2"
  local dest_dir="${base_dir}/${SKILL_NAME}"

  if [[ ! -d "${base_dir}" ]]; then
    if [[ "${TARGET}" == "auto" ]]; then
      return 0
    fi
    echo "⚠  ${label} skills directory (${base_dir}) does not exist — creating it."
    mkdir -p "${base_dir}"
  fi

  mkdir -p "${dest_dir}"
  cp "${SKILL_SOURCE}" "${dest_dir}/SKILL.md"
  echo "✅ Installed into ${label} → ${dest_dir}/SKILL.md"
  installed_count=$((installed_count + 1))
}

case "${TARGET}" in
  auto)
    install_into "Claude Code" "${HOME}/.claude/skills"
    install_into "OpenClaw"    "${HOME}/.openclaw/skills"
    ;;
  claude)
    install_into "Claude Code" "${HOME}/.claude/skills"
    ;;
  openclaw)
    install_into "OpenClaw"    "${HOME}/.openclaw/skills"
    ;;
  *)
    echo "Usage: $0 [auto|claude|openclaw]" >&2
    exit 2
    ;;
esac

if [[ ${installed_count} -eq 0 ]]; then
  echo "❌ No supported skills directory found (~/.claude/skills, ~/.openclaw/skills)." >&2
  echo "   Either install Claude Code / OpenClaw, or run:" >&2
  echo "   $0 claude     # force-create ~/.claude/skills" >&2
  echo "   $0 openclaw   # force-create ~/.openclaw/skills" >&2
  exit 1
fi

echo
echo "Next steps:"
echo "  1. Open SKILL.md (in the install location) and fill placeholders in Section 0."
echo "  2. Wire your crons / agent to the doctrine."
echo "  3. Start in Phase A (karma < 100, no brand mentions) until karma ≥ 100."
