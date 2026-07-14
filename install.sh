#!/usr/bin/env bash
#
# mise install.sh — Mode B (commands).
#
# Installs mise's vendored workflow commands into your Claude Code config:
#   /orchestrate  — the kitchen-brigade multi-agent workflow
#   /handoff      — write a durable session hand-off
# plus WORKFLOW-ORCHESTRATION.md (the /orchestrate playbook).
#
# The re-runnable /mise skill + the template library are still roadmap (see ARCHITECTURE.md);
# this installs the commands that exist today.
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
for f in commands/orchestrate.md commands/handoff.md WORKFLOW-ORCHESTRATION.md; do
  if [ ! -f "$REPO/$f" ]; then
    echo "error: $REPO/$f not found — run install.sh from a mise checkout." >&2
    exit 1
  fi
done

echo "mise: installing the workflow commands into $SCOPE"
echo "  -> $TARGET/commands/orchestrate.md"
echo "  -> $TARGET/commands/handoff.md"
echo "  -> $TARGET/WORKFLOW-ORCHESTRATION.md"
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

install_file commands/orchestrate.md      "$TARGET/commands/orchestrate.md"
install_file commands/handoff.md          "$TARGET/commands/handoff.md"
install_file WORKFLOW-ORCHESTRATION.md    "$TARGET/WORKFLOW-ORCHESTRATION.md"

echo
echo "Done. Start (or restart) Claude Code and try:  /orchestrate <a multi-part goal>"
echo "Hand-off any time with:  /handoff"
