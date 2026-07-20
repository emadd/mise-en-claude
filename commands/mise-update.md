---
description: Update the installed mise workflow commands to the latest published version — fetches main from the canonical repo and re-runs its installer, never from a local working copy.
argument-hint: [optional: "--project ." to update this project's ./.claude instead of global; or a branch/ref other than main]
---

You are running **/mise-update** — it refreshes the *installed* mise commands (`/mise-init`,
`/mise-cook`, `/mise-handoff`, `/mise-clean`, plus `WORKFLOW-ORCHESTRATION.md` and `mise-PROMPT.md`)
to the **latest published version**. This updates the tool itself; it is **not** `/mise-init`'s
Update mode, which refreshes *a project's* mise en place.

**The one rule that makes this correct:** mise's `install.sh` copies from whatever checkout it lives
in — it never consults the remote. So you must install from a **fresh clone of the canonical
`main`**, not from any working copy that happens to be on disk. Installing from a local repo is how
un-pushed, half-finished work gets shipped by accident — the exact bug this command exists to
prevent. **Never** run an `install.sh` you find in the current directory or the user's mise repo.

Do exactly this:

1. **Resolve scope and ref.** Default scope is **global** (`~/.claude`). If `$ARGUMENTS` contains
   `--project [dir]`, pass that through to the installer instead. Default ref is `main`; if
   `$ARGUMENTS` names another branch/ref, use it. Canonical source:
   `https://github.com/emadd/mise-en-claude.git`.

2. **Clone the published version into a throwaway temp dir** (never the user's project or repo):
   ```
   TMP="$(mktemp -d)"
   git clone --depth 1 --branch main https://github.com/emadd/mise-en-claude.git "$TMP"
   ```
   If the clone fails (offline / network), **STOP** and tell the user — do **not** fall back to any
   local checkout.

3. **Show what "latest" resolved to:** `git -C "$TMP" log --oneline -1`, so the user sees the exact
   published commit before anything is written. **Also record where the user is coming FROM,
   before the installer overwrites the stamp:** `PREV="$(cat "<target>/mise-VERSION" 2>/dev/null
   || echo none)"` (target = `~/.claude`, or the project's `.claude` if `--project`).

4. **Run that clone's installer**, non-interactively, for the resolved scope:
   ```
   "$TMP/install.sh" -y                 # global (~/.claude) — the default
   "$TMP/install.sh" -y --project <dir> # only if the user asked for project scope
   ```
   The installer is non-destructive: it backs up any differing file as `.bak-<time>` and leaves
   identical files untouched, so re-running is safe and idempotent.

5. **Clean up** the temp clone (`rm -rf "$TMP"`). **Leave** any `.bak-<time>` files the installer
   created — those are the user's rollback copies — and tell them the paths so they can delete them
   once satisfied.

6. **Tell the user what changed in BEHAVIOR, not just which files moved.** Read the freshly
   installed `<target>/mise-CHANGELOG.md` and relay the entries **newer than `PREV`** — all
   entries if `PREV` is `none` (the stamp first ships with 2026.07.20). Lead
   with these: a user updating deserves "here's what your commands now do differently," not a
   file list. If nothing is newer than `PREV`, say the install was already current.

7. **Summarize** the result: the published commit installed, which files were updated (`+` / `~`)
   vs. already current (`=`), where any backups landed, and remind the user to **restart Claude
   Code** to pick up refreshed commands.

Never touch the user's own mise working repo, its branches, or its uncommitted changes — this
command updates the *installed* copies only, always from the published `main`.
