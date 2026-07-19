---
description: Re-runnable mise entry point — give this project its mise en place (git, CLAUDE.md, structure, connectors, task tracker), or rescue/update an existing one. The installed, slash-command form of PROMPT.md.
argument-hint: [optional steer, e.g. "update", "rescue", "just re-audit CLAUDE.md", or a note about the project]
---

You are running **/mise-init** — mise's re-runnable setup / rescue / update entry point: the
installed equivalent of pasting `PROMPT.md`. mise is already installed on this machine (that's why
this command exists), so your job now is to run the **full** mise flow against **this** project.

**Load the canonical instructions, then follow them in full.** The authoritative mise behavior —
the prime directives, the Phase 0 mode detection (new setup vs. **Rescue** vs. **Update**), every
phase, and the whole safety contract — lives in the vendored mise prompt. **This command is only a
thin launcher: it does not restate that content, so you must read it live** (one source of truth,
no forked copy that rots).

Find the prompt in this order and read the **first that exists**:

1. `./.claude/mise-PROMPT.md` — project-local install
2. `~/.claude/mise-PROMPT.md` — global install
3. If neither exists, fall back to the network copy: read
   `https://raw.githubusercontent.com/emadd/mise-en-claude/main/PROMPT.md` and follow it. Tell the
   user you're using the network copy because no vendored prompt was found, and offer to re-run
   mise's `install.sh` so it's local next time.

If you cannot read it by **any** of those three routes, **STOP** and tell the user how to repair the
install — do **not** improvise the setup from memory. A half-remembered mise is exactly the
unsafe, non-consensual behavior mise exists to prevent.

Once loaded, execute the prompt **exactly** — same consent-first, snapshot-first, non-destructive,
secrets-by-reference contract; let its Phase 0 detect the mode. Two things are already true because
you arrived via the installed command, so act on them instead of re-deriving them:

- **The workflow commands are already installed.** `/mise-cook`, `/mise-handoff`, and `/mise-clean`
  exist on this machine. In the Skills + shortcuts phase, **verify they're present and current**
  rather than reinstalling from scratch.
- **`$ARGUMENTS`, if given, is the user's steer** — e.g. `update`, `rescue`, "just re-audit
  CLAUDE.md". Honor it over your own mode guess, but still run the version self-check and take the
  snapshot first — the steer changes *what* you do, never *whether* the work is safe.
