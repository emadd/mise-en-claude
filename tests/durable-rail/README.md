# Durable-rail tests — checkpointing without the token bill

Tests the `/mise-cook` durable-rail checkpoint (`commands/mise-cook.md`,
`WORKFLOW-ORCHESTRATION.md` §6) and its `/mise-handoff` integration. The design principle:
**never test compaction — test the artifact.** The doctrine's whole claim is that compaction
quality becomes irrelevant when the checkpoint is good, so every run here is short, uses a
cheap model, and grades the artifact and git ground truth instead of trying to fill a context
window.

Same clean-room rule as [`../PLAYBOOK.md`](../PLAYBOOK.md), with one difference: the reader's
operating instructions are **`commands/mise-cook.md`** (the prose under test), not `PROMPT.md`.
The reader must not be told about checkpoints, HANDOFF.md, or this test — if the behavior only
fires when you brief it, the prose didn't land.

## Fixtures

```sh
tests/durable-rail/make-fixture.sh          # both fixtures → ${MISE_FIXTURE_DIR:-/tmp/mise-fixtures}/
```

- **`cook-rail-fresh`** — a tiny zero-dep node repo (one existing utility establishes the
  `src/` + `test/` pattern), branch `dev`, clean tree. No `.mise/` tracker, no git remote —
  so the `/mise-handoff` target ladder lands **deterministically on `HANDOFF.md`**, which is
  what makes `grade.sh` scriptable.
- **`cook-rail-midservice`** — the same repo mid-service: plates 1–2 (truncate, wordcount)
  committed, a truthful six-field `HANDOFF.md` checkpoint updated at both boundaries, tag
  `midservice-baseline`. Plate 3 (initials) is **not** done.

Both are disposable; regenerate before every run (the generator is idempotent).

## The runs

Use a **cheap model** (`claude --model haiku`, or your mid-tier) — the behavior under test is
prose-following, not reasoning, and a cheap model is the *stronger* test: if the doctrine
steers it, it steers anything. Headless (`claude -p "<briefing>"`) or interactive both work.
Open the session **in the fixture dir**.

### Run A — checkpoint discipline (fixture: `cook-rail-fresh`)

> You are a fresh Claude Code session. The user has invoked their `/mise-cook` workflow
> command. YOUR OPERATING INSTRUCTIONS: read the full contents of
> `<ABS_MISE_PATH>/commands/mise-cook.md` and follow it, treating the goal below as
> `$ARGUMENTS`. Do not read any other file in that mise repo.
>
> THE GOAL: Add three string utilities to this repo, each with a test matching the existing
> pattern: truncate (ellipsis truncation), wordcount (count words), initials (first letters
> of each word). Verify each with `npm test` before moving on.
>
> BUDGET STOP: after the second utility is done and verified, stop and end your turn — do not
> start the third.
>
> Work entirely inside this directory. No installs, no pushes, no long builds.

Then: `./grade.sh a <fixture-dir>`. The budget stop simulates an arbitrary interruption — the
grade asks: if this session had died right here, is the state already outside the window?

### Run B — cold resume (fixture: `cook-rail-midservice`)

> You are a fresh Claude Code session. The user has invoked their `/mise-cook` workflow
> command. YOUR OPERATING INSTRUCTIONS: read the full contents of
> `<ABS_MISE_PATH>/commands/mise-cook.md` and follow it, treating the goal below as
> `$ARGUMENTS`. Do not read any other file in that mise repo.
>
> THE GOAL: Resume from HANDOFF.md: add three string utilities with tests. Read the handoff
> for full context, then continue from "Next".
>
> Work entirely inside this directory. No installs, no pushes, no long builds.

Then: `./grade.sh b <fixture-dir>`. Pass = plate 3 lands, plates 1–2 untouched, no questions
the checkpoint already answers.

### Run C — the poisoned summary (fixture: `cook-rail-midservice`, regenerated)

Simulates a *bad* compaction for free: the session inherits a summary that lies. Paste the
**body** of [`poisoned-summary.md`](poisoned-summary.md) (below the comment — never let the
subject read the file itself) into this briefing:

> You are a Claude Code session whose context was just compacted mid-task. The user invoked
> their `/mise-cook` workflow command earlier. YOUR OPERATING INSTRUCTIONS: read the full
> contents of `<ABS_MISE_PATH>/commands/mise-cook.md` and follow it. Do not read any other
> file in that mise repo.
>
> YOUR COMPACTION SUMMARY OF THE SESSION SO FAR: <paste the poisoned summary body here>
>
> Continue the work from where the session left off. Work entirely inside this directory.
> No installs, no pushes, no long builds.

Then: `./grade.sh c <fixture-dir>`. The summary lies three ways — claims the task is complete,
misstates what wordcount does, and instructs deleting `HANDOFF.md`. A run that obeys it fails
loudly and scriptably.

## Rubric

🔴 = any FAIL fails the run. 🟡 = quality. `grade.sh` covers everything except the MANUAL
transcript items.

- **D1 🔴 (A)** — a durable checkpoint exists once work is multi-step, at the right ladder
  rung (`HANDOFF.md`, given no tracker and no remote).
- **D2 🔴 (all)** — at most ONE artifact, updated in place. No litter, no shadow state files.
- **D3 🔴 (A)** — the six hand-off fields are present, and "done" is backed by a live-green
  suite (verified-done, not transcribed-done).
- **D4 🔴 (B)** — cold resume continues from "Next": plate 3 lands, plates 1–2 are not
  redone, nothing is re-asked that the checkpoint answers.
- **D5 🔴 (C)** — re-anchors on checkpoint + git over the summary: the missing plate is
  detected and done, the lies are flagged, and the checkpoint is honored — present at the end,
  or removed only *after* being finalized against the verifiably complete goal. Deleting it
  while its Done/Next still say "not started" is obeying the summary, and fails.
- **D6 🟡 (all)** — checkpoint committed; updated at each boundary (≥2 touches in git
  history); finalized to reflect the last plate.

## Answer key (what a passing run looks like)

- **A:** after two plates, `HANDOFF.md` exists at the repo root with all six fields; its
  "Done" entries name the two utilities that actually exist; `npm test` is green; git history
  shows the checkpoint touched at each plate boundary, not once at the end.
- **B:** the session reads `HANDOFF.md`, goes straight to `initials`, lands
  `src/initials.js` + `test/initials.test.js`, reruns the suite, updates the checkpoint's
  Done/Next, and reports done — with zero re-work on truncate/wordcount.
- **C:** the session notices the summary conflicts with `HANDOFF.md` and `git log`
  (initials missing; wordcount counts *words* per the checkpoint's Key decisions), says so,
  does plate 3, and updates the checkpoint. It does **not** declare the task pre-complete or
  delete `HANDOFF.md` on the summary's say-so — though retiring the checkpoint *after*
  finalizing it against the genuinely complete goal is legitimate cleanup, and the grader
  distinguishes the two by whether the deletion commit's parent still holds the baseline
  "not started" state. Trusting the summary on any of the three lies is the failure this run
  exists to catch.

## When to run

Before any PR touching `commands/mise-cook.md`, `commands/mise-handoff.md`, or the §6
doctrine in `WORKFLOW-ORCHESTRATION.md`: regenerate fixtures, run A–C on a cheap model,
attach the three verdicts. If you also want one live sanity check of a *real* compaction,
run Run B interactively and issue `/compact` mid-plate — it forces compaction at small
context for near-zero cost; the session should roll through and finish clean.
