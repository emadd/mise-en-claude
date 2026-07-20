#!/usr/bin/env bash
#
# make-fixture.sh — generate the durable-rail QA fixtures.
#
# Tests the /mise-cook durable-rail checkpoint (see ../../commands/mise-cook.md and
# ../../WORKFLOW-ORCHESTRATION.md §6) without ever causing a real compaction. Fixtures are
# generated into a scratch dir, never committed — same policy as ../fixtures/make-fixtures.sh.
#
# Both fixtures deliberately have NO .mise/ tracker and NO git remote, so the /mise-handoff
# target ladder lands deterministically on HANDOFF.md — which is what makes grade.sh scriptable.
#
# Usage:
#   ./make-fixture.sh              # build both fixtures
#   ./make-fixture.sh fresh        # Run A fixture (no checkpoint yet)
#   ./make-fixture.sh midservice   # Run B/C fixture (plates 1-2 done + truthful checkpoint)
#   MISE_FIXTURE_DIR=/path ./make-fixture.sh   # override output root (default /tmp/mise-fixtures)
#
set -euo pipefail

ROOT="${MISE_FIXTURE_DIR:-/tmp/mise-fixtures}"

note()      { printf '  %s\n' "$*"; }
reset_dir() { rm -rf "$1"; mkdir -p "$1"; }
git_here()  { git -C "$1" -c user.name='mise-fixture' -c user.email='fixture@localhost' "${@:2}"; }

# Shared base: a tiny zero-dep ESM repo with one existing utility that establishes the
# pattern (src/<util>.js + test/<util>.test.js, node --test). Branch is `dev`, not main.
write_base() {
  local d="$1"
  mkdir -p "$d/src" "$d/test"
  cat > "$d/package.json" <<'EOF'
{ "name": "acme-textutils", "version": "0.1.0", "type": "module",
  "scripts": { "test": "node --test" } }
EOF
  cat > "$d/.gitignore" <<'EOF'
node_modules/
.DS_Store
EOF
  cat > "$d/README.md" <<'EOF'
# acme-textutils

Small string utilities. Zero dependencies. Run the tests with `npm test` (Node >= 18).
EOF
  cat > "$d/src/slugify.js" <<'EOF'
export function slugify(s) {
  return s.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}
EOF
  cat > "$d/test/slugify.test.js" <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { slugify } from '../src/slugify.js';

test('slugify', () => {
  assert.equal(slugify('Hello, World!'), 'hello-world');
  assert.equal(slugify('  spaced  out  '), 'spaced-out');
});
EOF
  git_here "$d" init -q
  git_here "$d" checkout -q -b dev
  git_here "$d" add -A
  git_here "$d" commit -q -m "acme-textutils: baseline (slugify + test)"
}

fx_fresh() {
  local d="$ROOT/cook-rail-fresh"; reset_dir "$d"
  write_base "$d"
  note "baseline repo only — Run A starts here with no checkpoint anywhere"
}

fx_midservice() {
  local d="$ROOT/cook-rail-midservice"; reset_dir "$d"
  write_base "$d"

  # --- Plate 1: truncate, committed with checkpoint v1 (models update-at-boundary #1). ---
  cat > "$d/src/truncate.js" <<'EOF'
export function truncate(s, n) {
  return s.length <= n ? s : s.slice(0, n - 1) + '…';
}
EOF
  cat > "$d/test/truncate.test.js" <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { truncate } from '../src/truncate.js';

test('truncate', () => {
  assert.equal(truncate('hello world', 8), 'hello w…');
  assert.equal(truncate('hi', 8), 'hi');
});
EOF
  cat > "$d/HANDOFF.md" <<'EOF'
# HANDOFF — running checkpoint

## Goal
Add three string utilities with tests — truncate, wordcount, initials — in src/ + test/,
matching the existing slugify pattern (ESM, node:test, zero deps).

## Done (verified)
- src/truncate.js + test/truncate.test.js — `npm test` green, run live at this checkpoint.

## Next
1. src/wordcount.js + test/wordcount.test.js.
2. src/initials.js + test/initials.test.js.
3. Re-run the full suite; update this checkpoint; report done.

## Key decisions
- Plain ESM + node:test, zero deps — matches the existing slugify pattern.

## Files touched
- src/truncate.js, test/truncate.test.js (new)
- HANDOFF.md (this checkpoint)

## Gotchas
- `npm test` needs Node >= 18 (node --test).
- truncate appends '…' only when it actually truncates — the tests assert exact output.
EOF
  git_here "$d" add -A
  git_here "$d" commit -q -m "truncate lands; checkpoint updated"

  # --- Plate 2: wordcount, committed with checkpoint v2 (update-at-boundary #2). ---
  cat > "$d/src/wordcount.js" <<'EOF'
export function wordcount(s) {
  const t = s.trim();
  return t ? t.split(/\s+/).length : 0;
}
EOF
  cat > "$d/test/wordcount.test.js" <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { wordcount } from '../src/wordcount.js';

test('wordcount', () => {
  assert.equal(wordcount('one two  three'), 3);
  assert.equal(wordcount('   '), 0);
  assert.equal(wordcount(''), 0);
});
EOF
  cat > "$d/HANDOFF.md" <<'EOF'
# HANDOFF — running checkpoint

## Goal
Add three string utilities with tests — truncate, wordcount, initials — in src/ + test/,
matching the existing slugify pattern (ESM, node:test, zero deps).

## Done (verified)
- src/truncate.js + test/truncate.test.js — `npm test` green, run live at this checkpoint.
- src/wordcount.js + test/wordcount.test.js — `npm test` green, run live at this checkpoint.

## Next
1. src/initials.js + test/initials.test.js — initials('Ada Lovelace') === 'AL'; collapse
   extra whitespace; empty/whitespace-only input → ''.
2. Re-run the full suite; update this checkpoint; report done.

## Key decisions
- Plain ESM + node:test, zero deps — matches the existing slugify pattern.
- wordcount counts WORDS split on whitespace (not characters); empty/whitespace-only → 0.

## Files touched
- src/truncate.js, test/truncate.test.js (new)
- src/wordcount.js, test/wordcount.test.js (new)
- HANDOFF.md (this checkpoint)

## Gotchas
- `npm test` needs Node >= 18 (node --test).
- truncate appends '…' only when it actually truncates — the tests assert exact output.
EOF
  git_here "$d" add -A
  git_here "$d" commit -q -m "wordcount lands; checkpoint updated"
  git_here "$d" tag midservice-baseline

  note "plates 1-2 committed (truncate, wordcount), truthful HANDOFF.md checkpoint at v2,"
  note "  tag 'midservice-baseline' for grade.sh no-redo diffing — initials is NOT done"
}

main() {
  mkdir -p "$ROOT"
  case "${1:-all}" in
    fresh)      echo "==> cook-rail-fresh";      fx_fresh ;;
    midservice) echo "==> cook-rail-midservice"; fx_midservice ;;
    all)        echo "==> cook-rail-fresh";      fx_fresh
                echo "==> cook-rail-midservice"; fx_midservice ;;
    *) echo "unknown fixture: $1 (use: fresh | midservice)" >&2; exit 1 ;;
  esac
  echo
  echo "Fixtures ready under: $ROOT"
  echo "Next: see README.md in this directory for the Run A/B/C briefings and grading."
}

main "$@"
