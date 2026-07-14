---
description: Write a clean hand-off of the current session state to a durable artifact (a GitHub issue or HANDOFF.md) so a fresh session resumes losslessly.
argument-hint: [optional focus, e.g. "the auth refactor"]
---

Context is a budget, and this is the hand-off that beats silent auto-compaction. Capture the
current state so a **fresh session resumes with no loss**, then stop, rather than pushing into
compaction where fidelity quietly dies.

Write these six fields, tight and specific (focus: **$ARGUMENTS** if given):

- **Goal** — what we're actually trying to accomplish (the outcome, not the next keystroke).
- **Done** — what's finished *and verified*, with the evidence (a passing test, a running screen).
  **Re-verify it now, live** — rerun the test, reload the screen — don't transcribe an earlier
  claim (yours, a notes file's, a teammate's) on trust. If you can't re-verify something before
  the hand-off, write it as *unverified* rather than *done*; a stale "done" is worse than an
  honest gap, because the next session builds on top of it without rechecking.
- **Next** — the very next concrete step, then the ones after it.
- **Key decisions** — choices made and *why*, so they aren't relitigated or accidentally undone.
- **Files touched** — the files that matter and what changed in each; flag anything half-done.
- **Gotchas** — traps, dead ends, environment quirks, "don't do X, it breaks Y."

**Pick the durable target, most-programmatic first:**

- If `gh` is authenticated and the repo has a remote, **open a GitHub issue** (`gh issue create`) —
  it's shared, linkable, and survives the machine. Label it `handoff`.
- Otherwise write **`HANDOFF.md`** at the repo root. If you commit it, honor any no-auto-commit
  rule: ask first, then run the commit yourself on a yes — don't hand over a command to type.
- Never leave the hand-off only in chat; chat is the thing about to be lost.

Then give the user a **ready-to-paste resume prompt**, not just a pointer to the artifact. Put it
in its own fenced code block, on one line, so it can be copied with a single click and dropped
straight into a fresh session as the next `/mise-cook` (or plain) prompt — e.g.:

```
Resume from issue #190: <one-line goal>. Read the issue for full context, then continue from "Next".
```

Don't make the reader assemble this themselves from prose — the whole point of the hand-off is that
a fresh session (or a fresh reader) can go from "here's the artifact" to "working again" without
hand-crafting anything. Keep the hand-off itself scannable — a fresh reader should grasp the state
in under a minute, not wade through a transcript.
