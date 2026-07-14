---
description: Sweep the project for hygiene cruft — junk tracked in git, backup/scratch files, stale branches and orphaned worktrees — and clean it up, consent-first and non-destructively.
argument-hint: [optional focus, e.g. "just the git junk" or "after the last mise-cook run"]
---

You are running the **hygiene sweep** — "clean as you go, sweep the line at close." Same mise ethos
as everything else: **consent-first, non-destructive, snapshot-first.** **Report first, then act on a
yes, one category at a time.** Never blind-delete, never `git clean -fdx`, never rewrite history to
"tidy," and never touch a file that might hold a secret (defer to the secret protocol — do not ingest
the value). Focus: **$ARGUMENTS** if given, otherwise sweep it all.

Survey, then present findings grouped, each with a one-line "why it's cruft" and the exact fix:

1. **Junk tracked in git that shouldn't be.** Build output (`DerivedData/`, `build/`, `.next/`,
   `dist/`, `target/`), dependencies (`node_modules/`), OS/editor cruft (`.DS_Store`,
   `*.xcuserstate`). Fix = **untrack but keep on disk**: `git rm --cached` **and** add the pattern to
   `.gitignore` in the same step (untracking without ignoring isn't durable — a later `git add`
   re-tracks it). Removes bloat from the repo without deleting the user's files.
2. **Backup & scratch cruft.** mise's own `.bak-*` files and `.mise-backup/`, a resolved
   `HANDOFF.md`, stray `*.log`, temp/scratch dirs. These are deletable — list them and delete **only
   on a yes**.
3. **Git detritus.** Local branches already merged into the main line (offer to delete), **orphaned
   worktrees** (especially leftover `mise-cook` brigade lanes — `git worktree list`, then prune the
   stale ones), stale stashes (report; never auto-drop). Branch and worktree removals are
   recoverable from the reflog for a while — say so.
4. **Untracked files.** Separate real-looking work from junk. **Never delete untracked files
   blindly** — they may be the user's uncommitted work. List them, sort into "looks like junk" vs
   "looks like work," and let the user decide per item or per category.

**Do it yourself, don't narrate it.** Once the user approves a category, *run* the commands
(`git rm --cached`, `git worktree prune`, the deletes) — don't hand them a list to paste. Before you
touch tracked files, make sure there's a recovery point (a commit, or confirm the tree is already
committed).

Close with a short summary: what you cleaned, what you left and why, and how to recover anything
(untracked files stayed on disk; deleted branches live in the reflog).
