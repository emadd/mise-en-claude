# Changelog — user-facing changes to the installed mise commands

Read top-down; entries are keyed to `VERSION`. After an update, `/mise-update` shows you the
entries newer than your previously installed version — behavior changes, not file lists.

## 2026.07.20 — the durable rail: /mise-cook now checkpoints as it goes

- **`/mise-cook` keeps its task rail in a durable artifact** — your project's tracker, a GitHub
  issue, or `HANDOFF.md` (the same target ladder `/mise-handoff` uses). Any goal with more than
  one plate opens the checkpoint **before the first plate lands** — solo or brigade — and
  updates it in place at every phase boundary with goal / verified-done / next / key decisions /
  files touched / gotchas.
- **Why you care: context compaction becomes a non-event.** The load-bearing state lives
  outside the context window, so a long session rolls straight through compaction without
  losing fidelity — and any fresh session can resume from the artifact with a one-line prompt.
  You'll see the checkpoint named in the first line of every `/mise-cook` run ("checkpoint:
  HANDOFF.md", or "single plate, no rail").
- **Resume protocol hardened:** when a session resumes from a compaction or summary, the
  summary is briefing, never authority — the session re-anchors on the checkpoint + git log
  first, verifies any "done" claims against ground truth, and never deletes or finalizes the
  checkpoint on a summary's say-so.
- **`/mise-handoff`** now finalizes an existing running checkpoint in place instead of minting
  a second artifact; it remains the explicit stop-and-hand-off.
- Validated clean-room on unbriefed models (`tests/durable-rail/`): the full standard holds
  from the workhorse tier up; the cheapest tier holds the core safety behaviors.
- The installer now stamps the installed version (`mise-VERSION`) so future `/mise-update`
  runs can tell you exactly what changed since your last update.

## Earlier

The changelog begins at 2026.07.20 — for earlier history, see `git log` on the repo.
