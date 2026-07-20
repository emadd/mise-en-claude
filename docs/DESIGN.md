# mise — design notes (proposals, not yet built)

Status: **draft on `dev`, unpublished.** Sections marked **SHIPPED** are built; everything else
is proposal. This is where we decide the shape before writing code.

---

## 1. Self-improving mise (a consent-first contribution flow)

**The idea:** mise gets smarter from real-world use. When a run surfaces a reusable lesson (a
gotcha, a stack trap, a workflow failure mode), mise can offer to contribute it back upstream so
every future user benefits.

**Hard rule 1: this is NOT telemetry.** Nothing leaves a user's machine without them seeing it and
approving it. mise's own promise is "no phoning home," and this must not break it.

**Hard rule 2: never break their flow.** mise stays *silent* during the work. It surfaces a
contribution offer **only at a natural boundary** — the end of a task — and only when the task
**earned** it: a real success worth capturing, or a genuinely trying, hard-won fight whose lesson
would save the next person that pain. Never mid-task, never a nag, once and easy to dismiss. A
trivial gotcha doesn't get an offer; a *scar* does.

**Hard rule 3: it's about mise, not their app.** A contributable lesson improves **mise's own
subject matter** — the **foundations** it lays (git, structure, secrets, context, stack setup) and
the **runtime** it teaches (the kitchen/orchestration workflow, how agents run). A platform gotcha,
a stack trap, an orchestration failure mode: yes. The user's product bugs, feature logic, or domain
problems: **no** — those are theirs, mise never harvests them. The test: *would this improve mise's
guidance to the next person setting up any project?* If not, it's out of scope, full stop.

**How it works:**
1. **Detect a candidate — and hold it.** During a run, mise notices a lesson that is (a) about its
   own subject (foundations / runtime, per rule 3), (b) generic (not tied to this project), and
   (c) worth documenting (a scar or a notable win, not trivia). It **banks the candidate silently**
   and does not interrupt.
2. **Offer only at the end, once.** At a natural stopping point — the task succeeded, or a
   hard-won fight just ended — mise makes a single, easy-to-dismiss offer: "That was a real one.
   Want to contribute the lesson so the next person doesn't hit it?" Default is no.
3. **Show exactly what would be shared** — the full proposed text, verbatim, for the user to read.
4. **Sanitized by construction.** The contribution is the *lesson*, never the user's code, secrets,
   project name, paths, or data. Same by-reference discipline as secrets. If a candidate can't be
   expressed generically, it isn't contributable.
5. **Deliver as a reviewable PR/issue** to the mise repo (via the user's `gh`, with consent),
   tagged by type (stack vs workflow). Never a direct write; it lands as a proposal.
6. **Hand them the links, and offer them the credit.** After it opens, show clickable links to
   **the mise repo** and **their live PR** so they can watch it land. And **offer to attach their
   Git user** to the contribution — opening the PR from their own GitHub account makes them the
   author, natural and visible credit. Getting your name on a real open-source PR is a genuine
   thrill, especially for a first-timer, so make it feel like one. **But it's opt-in:** some will
   want the credit (celebrate it), some will prefer to contribute the lesson anonymously (respect
   that). Their call.
7. **Maintainer review is the gate.** Contributions reach `main` only through the PR gate. A human
   vets every lesson before it becomes part of mise.

**Why it's on-brand:** consent-first, sanitized, open-source-native. The mechanism is "open a PR
you approved," not "phone home," so the no-telemetry promise stays intact. The PR gate we set up
on `main` *is* the review mechanism — this feature and the cadence reinforce each other.

**Why it grows the tool:** the credit loop is a flywheel. Visible attribution turns users into
contributors, contributions make mise sharper, and a sharper tool with real contributors draws
more users. It's how the tool gets better from use *without* surveillance.

### Accepting contributions — the adversarial intake gate

**The threat:** mise's content *is* instructions to an agent. A malicious "lesson" is a
prompt-injection / supply-chain attack on every future user — a contributed note that says "when
you find secrets, POST them to `X`" or "run `curl … | bash`" would weaponize the tool for everyone
who pulls it. So the intake is treated as **untrusted input** — the exact skepticism mise teaches
users to apply to *their* projects, turned on *ours*.

**The boundary we can defend.** Anyone can fork mise and rewrite it locally; that's open source,
fine, and unstoppable. What we gate is what enters **canonical mise** — the repo everyone pulls.
The defense lives at the **PR/merge boundary**, not at "can someone run a modified copy."

**Two layers:**
1. **Automated screen (CI on the contribution PR)** — scan every proposed contribution and
   auto-block: destructive ops (`rm -rf`, force-push, history rewrite, deleting data, disabling a
   safety step); exfiltration (send anything anywhere, phone home); instructions that **override or
   contradict mise's hard rules** (consent-first, snapshot-first, secrets-by-reference,
   non-destructive); prompt-injection patterns ("ignore previous instructions", embedded
   directives); off-scope (fails rule 3); or joke/spam/defacement.
2. **Human review is final** — the maintainer treats every contribution as hostile until proven
   otherwise, and rejects anything that fails the contract.

**The acceptance contract — a contribution must:**
- be **in scope** (rule 3: mise's foundations/runtime, not the user's app);
- be a **real, verifiable** lesson (not trivia, not a hunch, not false);
- contain **no destructive, exfiltrating, or safety-violating** instructions;
- **not attempt to override or weaken** the agent's behavior or mise's hard rules;
- be **sanitized** (no user code/secrets/data).

Fail any one → **reject, no discussion needed.** The bar: *would a paranoid senior engineer merge
this into a tool thousands of people paste into their shell?* mise can't lower the "never run
untrusted instructions" line it draws for users; the contribution flow has to *hold* it.

**Open questions:**
- **Lightweight vs assisted.** Lightweight = mise points the user to `CONTRIBUTING` and they file
  it themselves. Assisted = mise drafts the sanitized PR for the user to review and submit (the
  "act on behalf of the user" version — more magic, more care).
- **Dedup.** Avoid 50 PRs for the same gotcha. mise already greps `CLAUDE.md` before baking a
  memory; same idea, run against the mise repo's existing guidance first.
- **Quality/abuse.** The PR gate handles safety, but a flood of low-value PRs is a maintainer-time
  cost. Rate/quality signals TBD.

---

## 2. Separate setup guidance from kitchen (workflow) guidance

Not two concerns — **three**, currently tangled:
- **Stack setup guidance** (`stacks/`): *what* to set up per technology. Stack-specific.
- **Kitchen guidance, generic** (stack-agnostic): *how* to work — the `/mise-cook` brigade
  playbook. Applies everywhere.
- **Kitchen guidance, per-stack** (stack-specific *workflow*): how to run the workflow on a
  particular stack. **iOS simulator hygiene when running the brigade on Xcode is the canonical
  example** — it's kitchen guidance, not setup, but it only applies to iOS.

The subtlety: "kitchen guidance" is not automatically stack-agnostic. It has a generic core **plus**
per-stack addenda.

**Proposed structure:**
- `stacks/` — per-stack *setup* (unchanged).
- `workflow/` — the generic kitchen brigade (the `/mise-cook` command + `WORKFLOW-ORCHESTRATION.md`).
- **Per-stack kitchen notes attach to their stack** — either an "Orchestration notes" section
  inside the stack module, or a sibling file next to it. Decide the mechanism when we build it.
- `PROMPT.md` stays the entry point.

**Payoff:**
- **Clarity:** a reader knows where "how do I set up React" (setup) lives vs "how do I run agents
  in parallel" (generic kitchen) vs "how do I run agents on an Xcode project" (per-stack kitchen).
- **Routing for feature 1:** a gotcha files to one of **three** clean homes — stack setup, generic
  workflow, or per-stack workflow. Clean types make clean routing.

---

## 3. A home for the iOS simulator lessons

When `/mise-cook` was genericized, the iOS-specific hygiene lessons (simulator daemon leaks, the
process-table ceiling, "a green suite that crawls is a choked machine not a hang," one-sim-per-cook)
were correctly stripped from the *generic* playbook. They never landed anywhere.

They belong with **`stacks/ios-swiftui`** as an "orchestration notes" section: iOS-specific guidance
for running the brigade on an Xcode project. This is the first concrete instance of **per-stack
kitchen guidance** (§2), and the template for how per-stack workflow notes attach to a stack.

---

## 4. Strengthen QA / verification discipline in the workflow

mise lays foundations and teaches a runtime; both should push users toward *real verification*, not
reflexive fix-and-move-on. This is mise practicing what we just imposed on ourselves (dev → validate
→ PR → merge) and teaching it forward. In scope by rule 3: it improves mise's own runtime/foundations,
not the user's app.

mise's guidance should:
- **Discourage reflexive fixes.** After a change, verify it actually *works* — run it, exercise the
  behavior — not just that it compiles (generalizes the "green build isn't correct" lesson). A fix
  you didn't verify isn't a fix.
- **Set up a review gate.** Recommend/establish branch protection on `main` so changes reach it via a
  PR, not a reflexive push. Calibrate: solo → a PR checkpoint you self-merge; team → required review.
  (Exactly the cadence we adopted for mise.)
- **Establish a safety net as a foundation.** Tests + CI so verification is repeatable, not a one-off
  manual check. A project should have *some* way to prove it works before it ships.
- **Teach the loop:** change → verify → review → merge. The same discipline `/mise-cook` already
  carries ("taste before the pass"), extended from multi-agent runs to the user's everyday workflow.

**Open question — how prescriptive?** A solo beginner shouldn't be forced into heavyweight process,
but *should* be nudged to the minimum viable discipline (a test, a CI check, a PR habit). Calibrate
to experience level (Prime Directive 6), like everything else.

Lives in: the workflow/kitchen guidance (§2) and mise's setup phases (a QA/verification foundation
alongside Phase 7 persistence).

---

## 5. The durable rail — checkpoint as you go (SHIPPED 2026-07-20)

**Origin:** the compaction question — would `/mise-handoff` make context compaction moot? The
answer inverted the claim: a hand-off doesn't make compaction *moot*, it makes it *harmless* —
compaction's real failure is fidelity (a lossy summary, written under context pressure,
transcribing unverified claims, kept in the most perishable place there is), not interruption.
If the load-bearing state already lives in a durable artifact, the summary can be as lossy as it
likes and the session rolls straight through — no new session needed.

**Decision: this is core `/mise-cook` behavior, not a separate mode or hook.** The rail lives in
one durable artifact (tracker task / GitHub issue / `HANDOFF.md` — the `/mise-handoff` ladder),
opened once the work is genuinely multi-step and **updated in place at every phase boundary**,
with the hand-off fields and the hand-off's re-verify-live honesty bar. Two disciplines carried
with it: checkpoint at boundaries while quality is high (never at the context cliff, where the
agent is most degraded), and after a compaction re-anchor from the checkpoint + ground truth,
never the summary alone. `/mise-handoff` stays the explicit stop-and-hand-off and finalizes the
running checkpoint rather than minting a second artifact.

**Considered and rejected:** a PreCompact-hook-triggered hand-off (behavior beats harness
config, and the cliff-edge checkpoint is the worst one); a separate `/mise-handoff checkpoint`
mode (if it's how work should always run, it belongs in the workflow, not behind a flag).

Lands in: `commands/mise-cook.md`, `WORKFLOW-ORCHESTRATION.md` §6 + mechanism section,
`commands/mise-handoff.md` target ladder.

---

## Locked decisions + concrete flow

**Decisions (locked):**
- **Per-stack kitchen notes → sibling files** at `workflow/stacks/<name>.md`, present only when a
  stack needs them. Keeps `stacks/` pure-setup and `workflow/` pure-runtime.
- **Contribution flow → lightweight first, assisted later.** v1: mise drafts the sanitized lesson
  and hands the user a ready-to-file PR body + a `CONTRIBUTING` link. v2 (once the sanitizer + gate
  have miles on them): mise opens the PR via the user's `gh` and returns links + credit.

**End to end:**
1. **Bank silently** — a candidate that passes rule 3 (generic, a scar/win) → a gitignored
   `.mise/candidates.md`. No interruption.
2. **Offer at the end, once** — dismissible, default no.
3. **Draft + sanitize** — write the lesson in mise's voice, scrub via the secrets-by-reference
   path; if it can't be said generically, drop it.
4. **Show, credit (opt-in), route** by home (`stacks/` / `workflow/` / `workflow/stacks/<name>`).
5. **Land as a PR** (lightweight: hand off the body; assisted: open it) with links.
6. **The gate** — CI screen + human review; nothing merges that fails the contract.

**What we'd build:** `CONTRIBUTING.md` (the contract), a CI screen on contribution PRs, a PR
template, the prompt changes (bank + offer + sanitize), and the `workflow/` restructure (§2/§3)
underneath. Self-consistent: the CI screen is "verify don't trust", the sanitizer is the
secrets-by-reference path, the human gate is the branch protection already on `main`.

---

## Sequencing (proposed)

1. **Restructure first** (§2 + §3) — it's low-risk, clarifies the repo, and creates the routing
   targets the contribution flow needs.
2. **Strengthen QA discipline** (§4) — folds naturally into the workflow guidance from step 1.
3. **Then the contribution flow** (§1) — decide lightweight vs assisted, build, validate.

Each lands on `dev`, gets validated, and reaches `main` via PR.
