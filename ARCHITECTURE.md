# mise — Architecture

How the Install Prompt is built.

---

## 1. Design principles

1. **Interview-first, consent-gated.** Nothing happens before `mise` understands the project
   and the user approves a plan. This mirrors Anthropic's own recommended flow (interview →
   spec → build) and is the safety model.
2. **Idempotent + non-destructive.** Every operation checks current state and only fills gaps.
   Re-running is safe — that's what makes `mise` also an *updater*. Existing files are merged,
   never clobbered; git history is never rewritten.
3. **Teach while doing.** Each step explains *why*. The tool is pedagogy that happens to
   execute — it should leave the user *understanding* their foundation, not owning a black box.
4. **Stack-pluggable.** Language/framework specifics live in swappable **stack modules**. The
   core prompt is stack-agnostic; the recommendations aren't.
5. **Tool-honest.** This is a Claude Code reference kit (Skills, slash commands, MCP). It says
   so. The *lessons* it embodies are portable; the *automation* is not.
6. **Two on-ramps, one brain.** A zero-install paste (`PROMPT.md`) and an installed skill
   (`/mise`) share the same phase logic; the skill just adds the template library and re-run
   ergonomics.
7. **Programmatic access over manual steps.** For every external service the project touches,
   prefer an agent-usable path (CLI / API / MCP / config-as-code) over browser automation or
   "go click here" instructions. Manual/UI steps are the workflow bottleneck — unscriptable,
   unverifiable, human-blocking. `mise` treats a browser-only dependency as a gap to close and
   the irreducible-manual set as a short, documented list. (Assessed in Phase 2 as "agent
   reach"; acted on in Phases 5–6.)
8. **Context-safe by construction.** Auditing and fixing secrets must never pull the plaintext
   into the model's context. Detect by pattern/scanner, reference by `file:line`/redaction,
   remediate structurally (env references, provider-side rotation). The tool fixes leaks without
   becoming one. (Prime Directive 4; Phase 2 deeper-audit offer; Reference — context-safe
   auditing.)
9. **Context-window discipline in produced agents.** The foundation `mise` lays makes agents
   treat context as a finite budget — warn early, hand off to a durable artifact, refuse to run
   into silent auto-compaction. A clean hand-off beats a lossy compression. (Guiding principle;
   written into `CLAUDE.md` in Phase 4 and the `/handoff` shortcut in Phase 7.)
10. **Capability-gated, but honest about it.** `mise` assumes a frontier-class model and opens
    with a soft capability gate (restate-the-directives self-check + graceful degradation to
    read-only). **It does NOT pretend to detect the model** — self-report is unreliable and
    spoofable, so a hard gate would be theater. The real protection against a weak model is
    principles 1–2 (snapshot-first, consent-gated, reversible): the blast radius is structurally
    near-zero regardless of who's driving. Detection is the weak layer; fail-safe design is the
    strong one. (Capability gate in `PROMPT.md`; expected model recorded in the `.mise` stamp.)
11. **Adapt to the environment (resources & locality).** Detect, don't assume. The multi-agent
    workflow sizes its concurrent "cook" count to the host's resources (cores/memory/load), never
    a hardcoded number. And `mise` is local-first but cloud-adaptive: prefer local dev, but when
    running in cloud do the portable work there and hand off local-only tasks (native builds,
    sims, signing) to a local session — reusing the context hand-off contract. (Detected in
    Phase 0; configured into `/orchestrate` + `CLAUDE.md` in Phases 4 & 7.)
12. **Calibrated, low-load communication.** Don't assume expertise — ask, and when it's unknown
    default to plainer language. Lead with the short plain-language version; layer detail on
    request; never dump a wall of jargon (a failure even for experts). Cognitive load is a
    first-class UX concern, not an afterthought. (Prime Directive 6; interview calibration in
    Phase 1; layered health report in Phase 2.)
13. **Multi-project awareness.** Detect when the tree is a *workspace of related projects*
    (backend / web / mobile / shared), not one project. Map the tenants, suggest a reorg for
    context when the layout is tangled (propose, never force), and lay foundations at **two
    levels** — each project's own `CLAUDE.md` **plus a root workspace map** capturing how the
    surfaces relate. The root map is the highest-value artifact for multi-surface products.
    (Detected in Phase 0; handled in Phase W.)

---

## 2. Repo layout

```
mise/
├── README.md                  # front door (see README.md)
├── ARCHITECTURE.md            # this file
├── PROMPT.md                  # THE artifact — the paste-in master prompt (Mode A)
├── install.sh                 # installs the /mise skill + templates into ~/.claude (Mode B)
├── LICENSE                    # MIT (proposed)
│
├── phases/                    # one module per setup phase — the prompt @-includes these
│   ├── 00-interview.md
│   ├── 01-assess.md
│   ├── 02-git.md
│   ├── 03-context.md
│   ├── 04-connections.md
│   ├── 05-cli-tools.md
│   ├── 06-skills-shortcuts.md
│   ├── 07-persistence.md
│   └── 08-verify-handoff.md
│
├── stacks/                    # pluggable per-stack recommendation modules
│   ├── _schema.md             # the contract every stack module fills
│   ├── ios-swiftui.md         # iOS/iPadOS/macOS — fleshed-out reference stack
│   ├── react.md               # STUB
│   ├── nextjs.md              # STUB
│   ├── angular.md             # STUB
│   ├── flutter.md             # STUB
│   ├── react-native.md        # STUB
│   └── generic.md             # sane-default fallback
│
├── templates/                 # source files the phases render from
│   ├── CLAUDE.md.tmpl
│   ├── README.md.tmpl
│   ├── gitignore/
│   │   ├── ios-swiftui.gitignore
│   │   ├── web-next.gitignore
│   │   └── ...
│   └── structure/             # per-stack starter directory skeletons
│
├── commands/                  # slash-command definitions mise can install
│   └── orchestrate.md         # the kitchen-brigade /orchestrate command (vendored — built)
│
├── WORKFLOW-ORCHESTRATION.md   # the extended brigade playbook (companion to /orchestrate)
│
├── skills/                    # workflow Skills mise can install (future)
│
└── mcp/                       # per-stack recommended MCP connector configs (documented, not secrets)
```

**Why file modules instead of one giant prompt:** `PROMPT.md` stays short and readable and
`@`-imports the phase files (Claude Code supports `@path` imports). Contributors edit one small
module; the core stays stable. The same phase files back both Mode A and the `/mise` skill.

---

## 3. Control flow

```
Interview ──► Assess ──► PLAN + CONSENT ──►  Execute phases (each re-confirmed)  ──► Verify ──► Hand off
   │            │             │                    │                                   │
 vision,     git state,   full preview,       git → context → connections →         "run this
 stack,      files,       skip-any,           cli → skills → persistence →           first command"
 goals,      CLIs, OS     nothing yet         (convert-mode merges, never clobbers)
 new/exist
```

- **Interview (`phases/00`)** — resolves: new vs existing project; stack; goals; the user's
  experience level (tunes how much it explains); which optional phases they want.
- **Assess (`phases/01`)** — inspects the real environment: `git status`, existing `CLAUDE.md`
  / `README` / `.gitignore`, installed CLIs (`gh`, language toolchains), OS/arch, existing MCP
  config. Produces a *gap list*.
- **Plan + consent** — presents the gap list as a concrete plan ("I'll create X, install Y,
  wire Z"), lets the user drop any item, and **waits**. This is the single most important gate.
- **Execute** — runs each approved phase, re-confirming anything destructive or slow. Loads the
  selected stack module for recommendations. In convert-mode, every write is a merge.
- **Verify + hand off** — sanity-checks (repo builds / lints where possible, skills resolve,
  `gh auth status`), then hands the user a first real command tied to their goal.

---

## 3a. Rescue mode (existing / "wrong-foot" projects)

The larger audience arrives with an existing, chaotic project, not a blank folder. Rescue mode
is a **first-class path**, not a fallback — `phases/01-assess.md` branches into it whenever a
project already has code.

It shares the phase library but changes the **ordering and the guarantees**:

```
Snapshot ──► Audit (health report) ──► Triage (severity-ranked) ──► Remediate one fix at a time ──► Verify
   │              │                          │                            │
 recovery      plain-language            safety-first order:          each fix = its own
 point         diagnosis w/ "why         secrets → git recoverability  reviewable step on the
 (git init     it bites you"             → structure → context         rescue branch; stop
 or rescue                               → workflow                    anytime, work intact
 branch)
```

**The non-negotiable guarantees (this is the trust contract):**

1. **Snapshot before touching anything.** No repo → `git init` + verbatim commit of the current
   state as a recovery point. Existing repo → all work on a `mise/rescue` branch. Reversibility
   is established *before* the first change, so a nervous user can safely say yes.
2. **Audit produces a readable health report** — a scored, prioritized gap list across: git
   hygiene, **committed secrets/keys**, monolith/God-files, missing `.gitignore` /
   `CLAUDE.md` / `README` / tests / CI, dependency hygiene. Each item carries a one-line
   *why it matters*. The report is a teaching artifact, not just a to-do list.
3. **Triage is safety-first**, in this fixed order:
   1. **Stop the bleeding** — secrets in the working tree, a `.gitignore` that should have
      existed. (Secrets already in *history* are **flagged, not auto-rewritten** — see below.)
   2. **Recoverability** — get the project cleanly into git with a sane baseline.
   3. **Structure** — *propose* (never force) a reorganization; splits and moves are diffs.
   4. **Context** — generate `CLAUDE.md` + `README` **by reading the existing code** (the
      highest-leverage single act: every future session gets smarter immediately).
   5. **Workflow** — skills, `/orchestrate`, GitHub Issues, CI.
4. **Preserve the work, always.** Reorg via `git mv` (history preserved); no file is deleted;
   no big-bang rewrite; risky changes land as reviewable diffs/PRs.
5. **Committed-secrets fork, handled responsibly.** If keys are in git *history*, the honest fix
   is rotation + a history rewrite (`git filter-repo` / BFG) — a **destructive** operation.
   `mise` **detects, warns, explains, and defers to the human.** It never rewrites history
   silently. Modeling that restraint on camera *is* the veteran-vs-vibe-coder lesson.

Rescue mode is idempotent: re-running audits the current state and only addresses what's newly
wrong, so it doubles as ongoing project hygiene.

---

## 3b. Update mode + the `.mise` stamp

`mise` is a living setup. Update mode is the third entry path (alongside Greenfield and Rescue),
triggered when Phase 0 finds a `.mise/` stamp.

**The stamp** (`.mise/state.json`, committed) records *what mise applied*:

```json
{ "miseVersion": "…", "miseCommit": "…", "appliedAt": "…", "mode": "greenfield|rescue|update",
  "stack": "…", "expectedModel": "…", "phasesApplied": [], "skills": [], "connectors": [],
  "repoRawUrl": "…" }
```

**Update flow:**

```
Read stamp ──► Fetch latest (repoRawUrl) ──► Snapshot ──► Reconcile report ──► Apply w/ consent ──► Re-stamp
                     │                                        │
              git pull / gh /                     🆕 new  🔀 drifted  🗑 deprecated
              WebFetch / curl                     (drift may be intentional)
```

**Key properties:**

- **Reconcile against the *fetched* latest**, never the stale pasted copy — otherwise "update"
  is a no-op. In Mode A the pasted prompt *bootstraps the fetch*; in Mode B `install.sh`/`git
  pull` refreshes the local copy.
- **The stamp records intent, so drift is computable:** `drift = current reality − stamped
  intent`. Anything not in the stamp is the *user's* — mise asks before changing it. This is how
  Update mode distinguishes a deliberate customization from bit-rot without guessing.
- **Same safety contract as Rescue** — snapshot-first, non-destructive, consent-gated, never
  rewrites history.
- **Idempotent** — reconciling an already-current project is a clean no-op that just confirms
  you're up to date.

---

## 4. Phase contracts (what each module guarantees)

| Phase | Reads | Writes / installs | Idempotency check | Convert-mode behavior |
|---|---|---|---|---|
| **02 Git** | git state | `git init`, `.gitignore`, branch config, first commit | skip if repo exists | adopt repo; append `.gitignore`; never rewrite history |
| **03 Context** | interview, stack | `CLAUDE.md`, `README.md`, structure | skip if present | **merge/append** into existing `CLAUDE.md`; propose structure diffs |
| **04 Connections** | stack module | MCP connector config | skip already-wired | add missing only |
| **05 CLI tools** | assess | installs/points to `gh` etc. | skip if on PATH | verify + fill gaps |
| **06 Skills+shortcuts** | stack module | Skills + slash commands incl. `/orchestrate` | skip installed | add missing only |
| **07 Persistence** | repo, `gh` | GitHub Issues labels/templates, workflow doc | skip if configured | augment |

Each phase module is a small markdown spec: **Goal → Preconditions → Steps (with the exact
commands/edits) → Consent points → Idempotency rule → Verification.** Claude executes it; the
module is the source of truth for *what* and *why*.

---

## 5. Stack modules

A stack module (`stacks/<name>.md`) fills the `_schema.md` contract:

```
# Stack: <name>
- detect:            # signals that auto-suggest this stack (files, extensions, manifests)
- structure:         # recommended directory skeleton (→ templates/structure/<name>/)
- gitignore:         # → templates/gitignore/<name>.gitignore
- connectors:        # MCP servers worth wiring, each with a one-line why + config pointer
- cli_tools:         # CLIs the workflow uses, install hints per OS
- skills:            # workflow Skills to offer (always includes orchestrate)
- claude_md_notes:   # stack-specific CLAUDE.md guidance to seed
- first_command:     # the "you're ready — run this" handoff for this stack
```

`ios-swiftui` is the flagship, seeded from battle-tested conventions (structure discipline, a
lean `CLAUDE.md`, `gh`-based issue workflow, `/orchestrate`). New stacks are a single file + a
couple of templates — **the extensibility story is the community story**, and a healthy
`stacks/` directory is a growth signal for the project.

---

## 6. Distribution & versioning

- **Mode A (`PROMPT.md`)** is the canonical artifact — copy/paste, zero install, works on any
  machine with Claude Code.
- **Mode B (`/mise` skill via `install.sh`)** copies the phase modules, templates, skills, and
  commands into the user's `~/.claude` so `/mise` is available everywhere and re-runnable.
- **Versioning against Claude Code.** Claude Code evolves (new Skills, MCP surface, slash-command
  conventions). `mise` pins a **compatibility note** at the top of `PROMPT.md` and tags releases;
  a `CHANGELOG.md` tracks what changed and why. This is the "living artifact" promise — a reason
  users come back.

---

## 7. Adding a stack

1. Copy `stacks/_schema.md` to `stacks/<name>.md` and fill it in.
2. Add `templates/gitignore/<name>.gitignore` and (optional) `templates/structure/<name>/`.
3. Add detection signals so `mise` can auto-suggest it in the interview.
4. PR it. That's the whole contract — no core changes needed.

---

## 8. Open questions

- **Name** — `mise` vs `seed` / `groundwork` / `install-prompt`.
- **Skill vs prompt as the "real" artifact** — lead with the paste (broadest reach) or the
  installed skill (best ergonomics)? Current call: paste is canonical, skill is the power path.
- ~~**How much to vendor vs reference** — ship a copy of `/orchestrate`, or fetch it?~~
  **RESOLVED: vendored** as `commands/orchestrate.md` + `WORKFLOW-ORCHESTRATION.md` (a
  self-contained slash command + its extended playbook). Simpler for users; no external fetch.
- **Telemetry** — none, presumably (on-brand for a privacy-minded tool). Growth is measured by
  stars/forks, not by phoning home.
- **Guardrails on install** — how hard to gate genuinely destructive suggestions (e.g. force
  operations) beyond the consent prompts.
- **Update fetch mechanism** — a repo raw URL vs a versioned release endpoint; version compare
  by git commit vs a semver tag; graceful offline behavior (reconcile against the local copy and
  say so). Keep it dependency-free and consent-gated like everything else.

## Backlog — pinned

- **Modularize `PROMPT.md` into `phases/` for optimal context (pinned 2026-07-13).** The first
  draft is deliberately one self-contained file so it's paste-testable. Once the content is
  validated, split it so a run **only pulls the phase modules it needs into context** (lazy
  `@`-imports) instead of carrying the entire prompt the whole session. This is the context-budget
  principle (§1.9) applied to mise itself — the prompt should practice the hygiene it preaches.
  Do this *after* the prompt's behavior is validated against real projects, not before.
