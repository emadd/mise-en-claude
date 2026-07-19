#!/usr/bin/env bash
#
# mise install.sh — Mode B (commands).
#
# Installs mise's vendored workflow commands into your Claude Code config:
#   /mise-init     — the re-runnable setup / rescue / update entry point
#   /mise-update   — refresh the installed commands to the latest published version
#   /mise-cook     — the kitchen-brigade multi-agent workflow
#   /mise-handoff  — write a durable session hand-off
#   /mise-clean    — sweep the project for hygiene cruft
# plus WORKFLOW-ORCHESTRATION.md (the /mise-cook playbook) and mise-PROMPT.md (the canonical
# setup prompt that /mise-init reads — so the re-runnable entry point works with no network fetch).
#
# The template library is still roadmap (see ARCHITECTURE.md); this installs what exists today.
#
# Usage:
#   ./install.sh                 # install for ALL your projects (~/.claude)
#   ./install.sh --project [dir] # install into one project's ./.claude (default: current dir)
#   ./install.sh -y              # skip the confirmation prompt
#   ./install.sh -h              # help
#
# It is non-destructive: an existing command file that differs is backed up (.bak-<time>)
# before it is replaced, and identical files are left untouched (idempotent).

set -eu

REPO="$(cd "$(dirname "$0")" && pwd)"

TARGET="$HOME/.claude"
SCOPE="all your projects (~/.claude)"
ASSUME_YES=0

usage() {
  sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --project)
      dir="${2:-$PWD}"
      TARGET="$dir/.claude"; SCOPE="the project at $dir"
      if [ "${2:-}" != "" ]; then shift; fi ;;
    --project=*)
      dir="${1#*=}"
      TARGET="$dir/.claude"; SCOPE="the project at $dir" ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1 (try -h)" >&2; exit 2 ;;
  esac
  shift
done

# Verify we're running from a mise checkout that actually has the files.
for f in commands/mise-init.md commands/mise-update.md commands/mise-cook.md commands/mise-handoff.md commands/mise-clean.md WORKFLOW-ORCHESTRATION.md PROMPT.md; do
  if [ ! -f "$REPO/$f" ]; then
    echo "error: $REPO/$f not found — run install.sh from a mise checkout." >&2
    exit 1
  fi
done

echo "mise: installing the workflow commands into $SCOPE"
echo "  -> $TARGET/commands/mise-init.md"
echo "  -> $TARGET/commands/mise-update.md"
echo "  -> $TARGET/commands/mise-cook.md"
echo "  -> $TARGET/commands/mise-handoff.md"
echo "  -> $TARGET/commands/mise-clean.md"
echo "  -> $TARGET/WORKFLOW-ORCHESTRATION.md"
echo "  -> $TARGET/mise-PROMPT.md"
echo

if [ "$ASSUME_YES" -eq 0 ]; then
  printf "Proceed? [y/N] "
  read ans </dev/tty || ans=""
  case "$ans" in
    y|Y|yes|YES) : ;;
    *) echo "Aborted. Nothing was changed."; exit 0 ;;
  esac
fi

stamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$TARGET/commands"

install_file() {
  # $1 = source (in repo), $2 = destination
  src="$REPO/$1"; dst="$2"
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "  = $dst (already current)"
    return
  fi
  if [ -f "$dst" ]; then
    cp "$dst" "$dst.bak-$stamp"
    echo "  ~ $dst (backed up existing -> $dst.bak-$stamp)"
  fi
  cp "$src" "$dst"
  echo "  + $dst"
}

install_file commands/mise-init.md       "$TARGET/commands/mise-init.md"
install_file commands/mise-update.md     "$TARGET/commands/mise-update.md"
install_file commands/mise-cook.md       "$TARGET/commands/mise-cook.md"
install_file commands/mise-handoff.md    "$TARGET/commands/mise-handoff.md"
install_file commands/mise-clean.md      "$TARGET/commands/mise-clean.md"
install_file WORKFLOW-ORCHESTRATION.md   "$TARGET/WORKFLOW-ORCHESTRATION.md"
install_file PROMPT.md                   "$TARGET/mise-PROMPT.md"

echo
echo "Done. Start (or restart) Claude Code and try:  /mise-init   (set up, rescue, or update this project)"
echo "Update mise itself later with:  /mise-update"
echo "Orchestrate with:  /mise-cook <a multi-part goal>     Sweep up:  /mise-clean     Hand-off:  /mise-handoff"
