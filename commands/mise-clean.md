---
description: Sweep the project for hygiene cruft — junk tracked in git, backup/scratch files, stale branches and orphaned worktrees — and clean it up, consent-first and non-destructively. Optionally audits CLAUDE.md against the code for stale and bloated guidance.
argument-hint: [optional focus, e.g. "just the git junk", "after the last mise-cook run", or "audit CLAUDE.md"]
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

**Optional — the `CLAUDE.md` audit (opt-in; don't run it by default).** The four sweeps above are
cheap surveys of files that shouldn't be there. This one is different: the file *should* be there, but
its contents rot — and verifying that means reading the code, which is a real context spend. So it
runs **only** when asked (a focus arg like "audit CLAUDE.md" / "check the brain"), or when the user
takes you up on the one-line offer at close. Never bundle it into a routine sweep.

It belongs in the hygiene lens because `CLAUDE.md` is cruft's worst hiding place: it's written once
and then read by every future session — by an agent that *believes it*. A stale line doesn't just sit
there like a `.DS_Store`; it actively misinforms every run that follows, and every surplus line is a
tax on every session's context. Same consent contract as the rest of this sweep — **fix what you can
prove wrong, propose the rest, never blind-delete.**

- **Stale** — names a path, script, flag, or command that changed or vanished. **Verify it** (`ls`
  the path, run or grep the command; don't reason about whether it's *probably* still true). Verified
  stale is a fact, not a judgment: **fix it and report it in a line.**
- **Duplicated** — restates the `README`/`ARCHITECTURE`/docs, and has since drifted from them. The
  doc is the source of truth: **propose** replacing it with a one-line pointer.
- **Generic** — advice a competent model already has ("write tests", "use types"). Pure context tax:
  **propose** the cut.
- **Unearned** — a rule the code doesn't actually follow. **Flag it, never cut it** — it may be a
  live intent rather than dead weight.

Weigh every cut by what it costs to be wrong: a wrong trim silently removes a guardrail and nobody
notices until it bites; a wrong keep costs some tokens. So the default is **keep and flag**, and "I
don't see why this is here" is a reason to ask, not to delete. **Watch the one real failure mode:**
stripping the odd, hyper-specific gotchas — the highest value-per-token lines in the file — because
they look like one-offs out of context. A weird rule is evidence of a scar. Group findings into a few
real decisions with the diff and the reason, never a line-by-line checkbox cart. A tight, accurate
brain earns a one-sentence "it's current" — not a manufactured trim.

**Do it yourself, don't narrate it.** Once the user approves a category, *run* the commands
(`git rm --cached`, `git worktree prune`, the deletes) — don't hand them a list to paste. Before you
touch tracked files, make sure there's a recovery point (a commit, or confirm the tree is already
committed).

Close with a short summary: what you cleaned, what you left and why, and how to recover anything
(untracked files stayed on disk; deleted branches live in the reflog). If a `CLAUDE.md` exists and you
didn't audit it, add **one line** offering it ("`CLAUDE.md` is 400 lines and I haven't checked it
against the code — want me to?"), and drop the offer entirely if they've declined it or the sweep was
scoped to something else. An opt-in nobody hears about is dead weight; an opt-in you pitch twice is a
shopping cart.
