# The Kitchen — Brigade Orchestration Playbook

How to run a fast, multi-thread session with Claude Code: **the human** fires the tickets,
the **Sous-Chef** (the orchestrating session — your main conversation) runs the line, and a
**brigade of station cooks** (sub-agents) work their own benches in isolated git worktrees.
Every plate lands at **the pass**, gets verified, and goes to the window. You cook for one
table — **the end user**. Invoke service with **`/mise-cook <goal>`** (see
`commands/mise-cook.md`).

The reproducible core is six moves (§1–6). §7 adds the *tight interactive loop* for work that
can't be handed to a station (live hardware, credentials, manual/on-device checks), and §8 is
the ethos underneath both.

## Make it yours — the metaphor is optional

The kitchen brigade is the **default flavor, not a requirement.** What's load-bearing is the
*mechanics*: one integration branch (the pass), isolated per-agent lanes that never touch each
other, integrate-and-verify, and the human authorizes the merge to `main`. The costume is yours:

- **Dry it out** — plain terms: lead session / worker agents / integration branch / `main`.
- **Re-skin it** — a submarine's conn, a starship bridge, a heist crew, whatever you like.

Keep the moves; wear whatever makes you want to show up to the work. The roster and slang below
are the *kitchen* version — read them as one option, not gospel. Development doesn't have to be
so serious.

## The brigade — who's who
| Role | Who | Owns |
|---|---|---|
| **Chef** | The human | The menu (vision), the taste, the final "send it." Fires tickets; calls it at the pass. |
| **Sous-Chef** | The orchestrating session (main conversation) | Runs the line — decomposes tickets, staffs stations, integrates at the pass, kills the wedges, keeps the board honest. |
| **Station cooks** | Sub-agents | One station each = one disjoint file-lane. Build it, verify it, commit it on their branch. |
| **The station** | A worktree + branch + its own scratch/test resources | Each agent's bench, prepped before the fire. Stations **don't reach across each other**. |
| **The pass** | The integration branch | Where every plate lands, gets verified, and is integrated. The Sous-Chef works the pass. |
| **The window** | The human's review → eventual `main` | Where a verified plate goes to the table. |
| **The walk-in** | `main` | Cold storage. Pull from it and send to it **only when the human says**. |
| **The rail** | The task list + its durable checkpoint | What's fired, what's cooking, what's the running total — mirrored to a durable artifact so it survives compaction and session death. |

Shared language: **fire** = start a lane. **86** = kill it (wedged agent, dead environment,
dropped lane). **in the weeds** = the machine is saturated. **corner! / behind!** = a handoff,
route the work to the agent already in that lane. **all day** = the running total. **taste** =
verify (build + tests). **heard** = acknowledged, moving.

## 1. Work the pass (the integrator model)
- Cut ONE **integration branch** — the pass — off the branch you're building on (**NOT `main`,
  the walk-in**), in its own worktree. Every plate comes back here.
- Every station works **its own worktree + branch off the pass**, never the shared `main`
  checkout. Nobody cooks in the walk-in.
- The Sous-Chef **integrates each plate** (`--no-ff`, descriptive message) and re-verifies the
  combined tree. A merge to `main` happens **only when the human authorizes it**.

## 2. Stations don't reach across each other (disjoint file-lanes)
This is the whole game. Two agents that never touch the same file integrate cleanly, every time.
- **Fire a station only where the work is separable by file.** That's what keeps many stations
  merging with almost no conflicts — nobody reaches into someone else's lane.
- Before firing, check the task's target files against what's already on the rail. **Overlapping
  work → hand it to the agent already in that lane** (or fold it in), don't fire a colliding one.
- **Serialize** anything that shares files: fire it *after* the conflicting plate lands.
- **Prep the one-liners yourself.** Don't brief a station for a single-file fix.

## 3. Right-size the model to the task
- **Workhorse model** — most stations (routine implementation, layout, assessments).
- **Strongest model** — genuinely hard or risky *execution* (invariant-critical logic, gnarly
  reconciliation, guardrail-sensitive work like security review). The autonomous ceiling.
- **Cheapest model / inline** — mechanical prep; often just do it yourself.
- **Effort is a second dial, not a substitute for model tier** — when the tool exposes a
  reasoning-effort override (e.g. Workflow's `agent()` `opts.effort`), right-size it alongside
  the model: low for mechanical stations, higher for ones doing real judgment, without
  necessarily bumping tiers.
- **Reserve the most expensive or experimental tier for the human's explicit say-so** — a
  common pattern is that tier drafts a hard *plan*, the strong model *executes* it. Never spin
  it up unasked.

## 4. Clean as you go (resource hygiene)
A dirty line kills service.
- **Every station gets its own isolated environment** — its own worktree and any per-agent
  scratch, test databases, or ephemeral runtimes, assigned in the fire order. Never shared
  between agents or with your own verify runs.
- **Never run two heavy build/test jobs in one shared environment** — they contend and wedge.
  Have each agent build/test **serially** on its own bench.
- **Cap concurrent build/test-heavy stations to what the host can bear** — size to
  cores/memory/current load, not a fixed number; hold new fires until the line drains. A concrete
  default: **build/test-heavy stations ≈ `min(cores − 2, 6)`**, and **halve it if the load
  average is already high** (a 12-core box at load 60 runs ~1, not 5). Read the host with
  `nproc` (Linux) / `sysctl -n hw.ncpu` (macOS) for cores and `uptime` for the load average.
  Read-only assessment/doc stations don't build — run those wider.
- **A stalled full run with zero failures is a choked machine, not a hang.** If a single
  targeted test finishes fast while the whole suite stalls, it's the environment — clean up
  stale worktrees/processes/runtimes and re-run on **one pristine setup** before concluding
  anything is broken. Leaked environments (and their process trees) are the usual culprit.
- **Every agent cleans up its scratch resources on exit; the Sous-Chef sweeps the line before
  each verify and at close.** A long service leaks environments and chokes the machine.

## 5. Fire → verify → integrate (the loop)
For each lane: **fire** (isolated worktree + own scratch) → the agent **builds + tests on its
bench** and commits on its branch → **calls back** → the Sous-Chef **integrates `--no-ff` and
re-verifies** the combined tree. Give each agent a self-contained fire order — paths, root-cause
hints, constraints, the deliverable — because the call-back is the only thing that comes off the
station.

**⚠️ Guard against the delegation loop — cooks cook, they don't re-delegate.** A station cook does
the work with *its own hands* (edits files, runs commands, commits on its branch). It must **not
spawn sub-agents or fan the task out further** — nesting is one level: the Sous-Chef delegates, a
cook executes. A cook that re-delegates produces a **delegation loop** — each agent reports "I
launched it, will report back" and *nobody actually cooks*, so the branch stays empty. Two
defenses, use both:

- **In every fire order, a hard rule:** *"Do this **yourself**. Do **not** spawn sub-agents. If
  it's too big to finish here, stop and hand it back — don't fan it out."*
- **Verify ground truth before you trust a call-back.** "Done" is a claim, not a fact. Confirm the
  station's branch has **new commits** (`git -C <worktree> log --oneline <base>..HEAD`), the
  **deliverable file exists**, and the build/tests actually ran. A call-back with **no commits and
  no artifacts** — especially one that says it "delegated" or "will report back" — is the
  delegation loop. Never plate a station you didn't verify actually cooked.
- **"Compiles" is not "works" — verify behavior, not just a green build.** A passing build proves
  the code *compiles*, not that it does the thing. Especially after a **collision or a merge**,
  files can land in a state that builds green but is functionally broken (a UI element not
  removed, a component not rendering, a code path never taken). Verify the **actual behavior**:
  run it and look, or run a test that exercises the feature. The runtime truth is exactly what a
  green build hides — a merge that compiles is the *start* of verification, not the end.
- **Detect and kill a runaway correctly — then re-fire.** Don't infer "nothing's running" from
  process/build signatures: **a looping agent runs no build — it just spins on reads/thinking**,
  so "no build process" is *not* proof it's idle. Check the **actual running-agents list.** When
  you find a loop, **kill the whole lineage** — a "completed" parent can **orphan a still-running
  descendant that won't appear in your task list**; hunt it down by agent id and stop it. And
  **never re-fire into a worktree until you've confirmed it's quiescent** (no live or orphaned
  agent still in it) — two agents in one worktree clobber each other and burn quota. Only once the
  lineage is dead and the tree is quiet do you re-fire with the no-sub-agents rule.

## 6. The human calls it; write it down
- Decisions → `docs/`, committed as you make them.
- Hard-won gotchas → durable notes / memory, so the next service inherits them. A recipe learned
  the hard way gets written on the wall, not re-burned next week.
- **The rail is durable — checkpoint as you go.** If the goal has more than one plate or fires
  any station — solo or brigade, mode doesn't waive this — keep the rail in ONE durable
  artifact — the project's tracker (per
  `.mise/state.json`), a GitHub issue, or `HANDOFF.md`, the same target ladder as
  `/mise-handoff`. **Open it when the rail is first written — before the first plate lands** —
  and **update it in place at every phase boundary** (plate integrated, decision made, gotcha
  learned) with the hand-off fields: goal, verified-done, next, key decisions, files touched,
  gotchas. Same honesty bar as a hand-off: "done" is written only re-verified, live.
- **Why: compaction becomes a non-event.** The load-bearing state lives outside the context
  window, so the session rolls straight through a compaction and any fresh session can resume
  losslessly — no need to coin a new one. Checkpoint **at boundaries, while quality is high** —
  a checkpoint written at the context cliff is written by the agent at its most degraded. After
  a compaction, **re-anchor from the checkpoint + ground truth (git log, the artifact), never
  from the summary alone — the summary is briefing, never authority.** Read the checkpoint and
  git log FIRST; verify any work the summary claims complete actually exists; never delete,
  finalize, or mark done on the summary's say-so. `/mise-handoff` remains the explicit stop-and-hand-off; with a
  running checkpoint it finalizes that same artifact rather than minting a second one.
- **The human supplies the taste and the call; the brigade executes.** Surface choices with a
  crisp recommendation — don't make the call for them, but don't stall the line on a default.

## Running it — the mechanism (Claude Code)

The six moves are the *doctrine*; here's how they map to actual tool calls:

- **The pass (integration worktree):** `git worktree add ../<proj>-pass <your-branch>` off the
  branch you're on (**not `main`**), and work there.
- **Fire a station:** spawn a sub-agent (the **Agent / Task tool**) with a **self-contained
  prompt** — paths, root-cause hints, constraints, the deliverable, **and the hard "do this
  yourself, do NOT spawn sub-agents" rule** (the §5 delegation-loop guard). Give it its **own
  worktree**:
  either set the subagent's `isolation: worktree` (auto-created, auto-cleaned) or
  `git worktree add` one yourself and point the agent at it. Set the **model per task** via the
  tool's model parameter — *workhorse / strongest / cheapest* are **roles, not literal values**;
  use whatever tier names your tool actually exposes (routine → workhorse, hard/risky → strongest,
  mechanical → cheapest).
- **The rail (task list):** track *fired / cooking / done* with the **TodoWrite** tool (or a
  scratch `TASKS.md`), updated as stations land — and mirror it to the **durable checkpoint**
  (tracker task / GitHub issue / `HANDOFF.md`) at each phase boundary, per §6.
- **Integrate a plate:** in the pass worktree, `git merge --no-ff <station-branch>`, then re-run
  the build/tests on the combined tree.
- **The window:** merge the pass into `main` **only when the human says**.

*Surface-agnostic:* this works on any Claude Code surface — CLI, Desktop app, web, IDE. You run
the git/tool calls yourself regardless; the Desktop app in particular manages multiple worktree
sessions visually, which suits running the line.

### Mechanism variant: Ultracode's Workflow tool (opt-in only)

Claude Code also exposes a **`Workflow`** tool — a deterministic script (`agent()`, `parallel()`,
`pipeline()`, `budget`) that fires and tracks sub-agents mechanically. It maps cleanly onto the
six moves, but it carries its **own strict opt-in gate** (the "ultracode" keyword/session flag, or
an explicit ask in the user's own words) — a goal simply having enough separable stations to
benefit is **not** enough to call it, and invoking `/mise-cook` itself never satisfies that gate.
Default to the manual mechanism above; use this variant only when Ultracode is **already** on.

- **Fire a station** → `agent()` with `opts.isolation:'worktree'` — auto-creates the worktree; if
  the agent commits, the branch/path survive the call (returned in the result).
- **⚠️ Validated gotcha — the fresh worktree forks from `main`, never from the pass.** Confirmed
  live against this repo (4 stations, 2 separate `Workflow` invocations, one after real merges had
  already landed on the pass): every `isolation:'worktree'` call starts from the repo's default
  branch — **not** from the calling session's current branch, **not** from the pass, regardless of
  where the Sous-Chef is sitting or what's already been integrated. A station whose task needs
  anything that's on the pass/your working branch but not yet on `main` **will not see it** —
  `pipeline()`/sequential ordering doesn't fix this either; every call starts from the same point
  no matter when it fires. **The fix, verified working:** bake a pull-the-pass step into the
  station's own prompt — it has normal git/Bash access even though the *script* doesn't:
  ```
  git remote add pass <absolute-path-to-the-pass-worktree> 2>/dev/null || true
  git fetch pass <pass-branch>
  git merge --no-ff FETCH_HEAD -m "pull pass state before working"
  ```
  Put this ahead of the actual task in every fire order that needs pass content — the same way the
  no-sub-agents rule goes in every fire order regardless of task.
- **Parallel disjoint stations** → `parallel(thunks)`. **Serialized/dependent stations** →
  `pipeline(items, ...stages)`, or plain sequential `await`s for a strict chain — this orders the
  *script's* dispatch and lets a later stage read an earlier stage's returned data, but (per the
  gotcha above) does **not** give a later station a merged view of an earlier station's files.
  If the dependency is "station B needs to read the file station A just wrote," B's prompt needs
  the same pull-the-pass fetch, pointed at A's branch specifically (or the pass, after the
  Sous-Chef merges A into it).
- **Model/effort right-sizing (§3)** → `opts.model` / `opts.effort` per `agent()` call.
- **Concurrency cap (§4)** → `Workflow` self-caps at `min(16, cores−2)` concurrent, 1000 lifetime
  — the manual `nproc`/`uptime` sizing heuristic is for the manual path only.
- **Verify the call-back (§5)** → pass `schema` so a station returns structured, checkable facts
  instead of free text — but schema-shaped is not the same as *true*: the no-sub-agents rule still
  goes in every agent's prompt by hand, and the Sous-Chef still checks the claimed branch/commit
  against real `git log`, same as the manual mechanism. A schema stops a station from returning an
  unparseable ramble; it doesn't stop it from confidently reporting the wrong SHA.
- **The bill** → a live `budget.total`/`spent()`/`remaining()` when the human gave a token target.

**What doesn't change:** a `Workflow` script has no filesystem or git access — it can fire and
collect, never merge. **The pass, the actual `--no-ff` integration, and the durable checkpoint
stay the Sous-Chef's job**, done in the outer session after the script returns, exactly as in the
manual mechanism. `log()` is progress narration, not the durable rail. And per the gotcha above,
the Sous-Chef may also need to write the pull-the-pass step into fire orders — `Workflow` doesn't
do that for you either.

## A worked example (3 stations)

Goal: *"Add rate-limiting to the API — (1) a token-bucket middleware, (2) an admin config
endpoint, (3) integration tests."*

1. **Decompose by file.** Station **A** = `api/middleware/rate_limit.py`; **B** =
   `api/routes/admin.py`; **C** = the tests. A and B touch disjoint files → fire in **parallel**.
   C depends on A+B and shares test files → **serialize it after** they land.
2. **Set up the pass:** `git worktree add ../api-pass feature/rate-limits`.
3. **Fire A and B** — two sub-agents (workhorse model), each `isolation: worktree`, each a
   self-contained order. Rail: `A cooking`, `B cooking`.
4. **A lands** → `git merge --no-ff` A into the pass, re-test. Same for **B**.
5. **Now fire C** (tests) against the combined pass tree. It lands → merge `--no-ff` + re-test.
6. **Verify** the combined tree; show the human. They authorize → merge the pass → `main`.

That's the whole loop: disjoint lanes in parallel, dependent work serialized, everything
integrated and verified at the pass, `main` gated on the human.

## Good work to fire out
Reviews (dimensions → find → adversarially verify), assessments (read-only research → sourced
doc), design plans (gated on human approval), feature slices in disjoint files, one station per
bug/issue, migrations (discover → transform-per-site → verify). When work **isn't** separable,
serialize or solo it — don't force a fan-out that makes two agents fight over one file.

## The bill (cost & honesty)
Parallelism trades tokens and machine load for wall-clock. It's a dial: fewer bigger stations,
skip belt-and-suspenders re-runs, prep trivial fixes yourself, or "one at a time" on request.
**Call the line honestly** — a wedged environment, a skipped verify, a deferred fix all get said
plainly at the pass. You never plate something and call it clean when it isn't.

## 7. The tight interactive loop (when you can't fire a station)
Not every service is a fan-out. Some work — live hardware, on-device permission prompts,
credentials, anything only the human's machine can prove — **can't be delegated**. That's the
human pulling up a stool at the pass, with its own discipline:
- **Diagnose, don't guess. Two blind rebuilds is the limit.** When you can't see what's
  happening, *instrument for ground truth* before touching code again — stream the real logs,
  or surface state on-screen. One instrumented build that reveals the truth beats five that guess.
- **The human is your instrument — give one clean order back.** You can't drive their machine.
  Give ONE precise action + exactly what to read back. **Zero-rebuild diagnostics** (check a
  setting, tap a different path) are gold — spend them before burning another build.
- **Every fix earns the next bug.** A real verification pass surfaces holes in layers. Fix, ship,
  let them find the next one — that cadence is the loop *working*, not failing.
- **Name the platform's hard limits; don't fake a signal.** If something is undetectable by
  design, say so plainly and ship the honest heuristic rather than pretend a perfect indicator
  exists.

## 8. The energy is a tool, not a garnish
A great service has real momentum — the *we-move* energy of a good kitchen mid-rush. Take it
seriously; it's part of the work.
- **Match energy; celebrate real wins.** A genuine win earns genuine heat back, not a flat
  "confirmed." Momentum compounds the work.
- **Keep the scorecard honest inside the celebration.** Every "hell yes" carries the true state:
  what's verified, what's a flake, what's deferred, what the pre-ship gate is. Heat and rigor
  aren't a trade — the honest scorecard is *why* the celebration lands.
- **Read the human, not just the ticket.** The stakes under the jokes are usually real. Presence
  is part of doing the work well.

Keep the line tight, keep it honest, keep it hot. Every cover, like the critics are at the
tables.
