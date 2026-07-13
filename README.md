<!-- mise — mise en place: get everything in its place before you cook. -->

# mise

**Get your project's *mise en place* — everything in its place before you build.**

> ⚠️ **Early draft.** The paste-in [`PROMPT.md`](./PROMPT.md) and the `/orchestrate` command work
> today, and [`stacks/`](./stacks) is scaffolded (iOS/iPadOS/macOS fleshed out; other platforms
> stubbed). The `Mode B` skill, `install.sh`, and templates described below are still roadmap
> ([`ARCHITECTURE.md`](./ARCHITECTURE.md)). Feedback welcome.

`mise` is a paste-in prompt for [Claude Code](https://claude.com/claude-code) that interviews
you about your project and then stands up (or upgrades) a real engineering foundation for it —
git, a `CLAUDE.md`, a sane project structure, the right connectors and CLI tools, workflow
skills like `/orchestrate`, and GitHub Issues as your workflow's memory — so you can stop
fiddling with setup and *start building*.

It's the foundation a seasoned engineer would lay before writing a line of feature code — the
"do this first" step most AI-assisted projects skip and later regret.

> **Honest scope:** the *ideas* here — project structure, git discipline, programmatic access,
> context hygiene — are tool-agnostic craft. **This repo is the concrete Claude Code reference
> implementation:** it installs Skills, slash commands, and MCP connectors, so it assumes **Claude
> Code (any surface — CLI, Desktop app, web, or IDE extension)**. The ideas port anywhere; the
> automation is Claude Code-flavored on purpose.

---

## Quickstart

### Mode A — zero install (fastest)

Works in **any Claude Code surface** — the CLI, the Desktop app, the web (claude.ai/code), or an
IDE extension.

1. Start a Claude Code session **for your project** (new *or* existing):
   - **CLI:** open a terminal in the project folder and run `claude`.
   - **Desktop app:** open Claude Code and open/select your project folder.
   - **Web / IDE:** open your project in claude.ai/code or your IDE extension.
2. Copy the contents of **[`PROMPT.md`](./PROMPT.md)** and paste it as your first message.

That's it. `mise` will interview you, show you a plan, and set nothing up until you say yes.

### Mode B — clone (richer, templated experience)

```sh
git clone https://github.com/emadd/mise
cd mise && ./install.sh    # installs the /mise skill + templates into your Claude Code config
```

Then, from *your* project: `claude` → `/mise`

Mode B gives you the full template library and lets `/mise` re-run as an **updater** any time
your project drifts.

---

## What it sets up

`mise` works in **consent-gated phases**. It always previews the whole plan first, and you can
skip any phase. Nothing is installed or written without your yes.

| Phase | What it does |
|---|---|
| **0 · Interview** | Asks about your vision, stack, goals, and whether this is a new or existing project. (Anthropic's "let Claude interview you" pattern.) |
| **1 · Assess** | Reads your current environment — git state, existing files, installed CLIs, OS — so recommendations fit reality, not a template. |
| **2 · Git** | Initializes (or adopts) the repo, writes a stack-appropriate `.gitignore`, sets branch conventions, makes a clean first commit. |
| **3 · Context** | Generates a starter `CLAUDE.md` and `README` from your interview, and lays down a project structure a real engineer would respect. |
| **4 · Connections** | Wires **programmatic access** (MCP / API / CLI) to the services your project touches — so agents can *operate* them, not just read about them. |
| **5 · CLI + tools** | Sets up `gh` and the other CLIs your workflow leans on; prefers a CLI/API over any dashboard, and flags browser-only bottlenecks. |
| **6 · Skills + shortcuts** | Installs the workflow Skills and slash commands — including **`/orchestrate`**, the kitchen-brigade multi-agent workflow. |
| **7 · Persistence** | Wires GitHub Issues + git as your workflow's durable memory, so context survives between sessions. |
| **8 · Verify + hand off** | Confirms everything works and hands you a first command to run. You're building in minutes, not hours. |

**Existing project?** `mise` detects it and runs in **Rescue mode** — see below.

---

## Started on the wrong foot? — Rescue mode

Most people who need `mise` already have a project: a half-built, AI-assisted tangle with no
git, no structure, a giant do-everything file, maybe an API key pasted into the source. `mise`
is built to **straighten it out without losing your work.**

When it detects an existing project, it switches from "set up" to **rescue**:

1. **Snapshot first — nothing is touched until your work is safe.** No repo? `mise`'s first act
   is to `git init` and commit your current state *verbatim* as a recovery point. Already have a
   repo? It works on a `mise/rescue` branch. Every change after this is reversible.
2. **A health report, in plain language.** `mise` reads your actual project and hands you a
   prioritized diagnosis — git hygiene, committed secrets, monolith files, missing
   `.gitignore` / `CLAUDE.md` / tests / CI — with *why each one bites you later*. No jargon
   wall; a checklist you understand.
3. **Triage, safety-first.** It fixes in the order a seasoned engineer would: stop-the-bleeding
   (leaked secrets) → recoverability (safely into git) → structure → context → workflow. Each
   fix is a separate, reviewable step. Stop whenever you want; everything stays intact.
4. **Your work is preserved, always.** Reorg happens via `git mv` (history kept), big changes
   arrive as diffs you approve, code is never deleted, and there's **no big-bang rewrite**.

Two things `mise` does that are worth the price of admission:

- **Writes the `CLAUDE.md` you never had** — by *reading your existing code*. Every future
  Claude session immediately gets smarter about your project.
- **Handles committed secrets like an adult.** If keys are already in your git history, `mise`
  *flags it, explains the real fix (rotation + history rewrite), and lets you decide* — it will
  **never rewrite your history behind your back.**

Rescue mode is idempotent too: re-run it any time the project drifts and it only addresses
what's newly wrong.

---

## Keeping it current — Update mode

`mise` is a *living* setup, not a one-shot. Guidance improves and Claude Code itself evolves —
so `mise` can **update itself and reconcile your project** with the latest.

When it configures a project, `mise` leaves a small committed **`.mise/` stamp** recording which
version set you up and what choices it applied. Later, run it again and pick **Update**:

1. **Fetches the latest** canonical `mise` from the repo (with your consent).
2. **Snapshots** first (same as rescue — reversible before any change).
3. **Reconciliation report**, in three buckets:
   - **🆕 New** — guidance, skills, or connectors added since your version.
   - **🔀 Drifted** — where your project diverged (maybe on purpose — `mise` treats it as yours).
   - **🗑 Deprecated** — anything the new guidance dropped.
4. **Applies what you approve**, non-destructively — and where you clearly customized something,
   it **asks "keep yours or adopt?"** instead of overwriting your choice.

Because the stamp records *what `mise` did*, it can tell a deliberate customization from bit-rot:
if it isn't in the stamp, `mise` didn't do it — so it's yours, and it asks before touching it.

---

## Safety — consent-first by design

This tool modifies your environment, so it behaves like a disciplined engineer, not a
`curl | bash` one-liner:

- **Previews the full plan** before touching anything, and asks before each phase.
- **Never clobbers.** Existing files are merged or appended, never overwritten silently.
- **Dry-run friendly.** Ask it to show you exactly what it would do first.
- **Explains as it goes.** Every step says *why*, so you learn the foundation instead of
  inheriting a black box.
- **Idempotent.** Safe to re-run; it detects what's already done and only fills gaps — which is
  what makes it double as an *updater*.
- **Secrets by reference, never by value.** When it audits and fixes exposed keys, the *plaintext
  never enters the model's context* — it detects by pattern, references findings by location,
  fixes structurally (env references, provider-side rotation). The tool fixes leaks without
  becoming one.
- **Context-window aware.** The foundation it lays makes your agents treat context as a budget —
  warn when it's tight, hand off cleanly to a durable artifact, and refuse to run into silent
  auto-compaction where fidelity quietly dies.
- **Runs on a capable model — and degrades safely if not.** `mise` assumes a frontier-class
  model and opens with a capability self-check. It can't truly *detect* the model (no prompt
  can), so if it's unsure it stays **read-only** — it'll give you the report but refuse to edit,
  install, or delete, and tell you to re-run on a stronger model. The real safety net is that
  every change is snapshot-first and reversible anyway.
- **Adapts to your environment.** The multi-agent workflow sizes its parallelism to *your*
  machine (cores/memory/load), not a hardcoded number of agents. And it's **local-first but
  cloud-adaptive** — it prefers local dev, but if you start in the cloud it does the portable
  work there and hands the local-only parts (native builds, simulators, signing) back to a local
  session.
- **Meets you at your level.** It asks how comfortable you are and calibrates — plain language by
  default, jargon only where it helps. It leads with the short version and layers the detail on
  request, so what you get back is something you can actually absorb, not a wall of text.
- **Understands multi-project workspaces.** If your tree holds several related projects — a
  backend + a web app + a mobile app, or a monorepo — it maps each one, offers to reorganize a
  tangled layout for clarity (proposed, never forced), and sets up context at *two* levels: each
  project's own `CLAUDE.md` **plus** a root map tying the whole system together, so agents grasp
  how the surfaces relate and where the boundaries are.
- **Mines your agent's memory.** It scans Claude Code's accumulated memories for durable,
  project-scoped facts and gotchas and offers to **bake the vetted ones into your `CLAUDE.md`** —
  version-controlled and shared — after checking each for correctness (against the actual code),
  accuracy, and scope. It never deletes your memories, and never bakes a sensitive one into a
  committed file.

The consent-first posture isn't friction — it's the whole point. Knowing what's happening to
your project *is* the skill.

---

## Supported stacks

Recommendations (structure, connectors, CLIs, `.gitignore`, skills) are driven by pluggable
**stack modules** in [`stacks/`](./stacks):

- `ios-swiftui` — **iOS / iPadOS / macOS, the fleshed-out reference stack.**
- `react`, `nextjs`, `angular`, `flutter`, `react-native` — **stubs** (scaffolded; being fleshed out).
- `generic` — a sane default when your stack isn't listed yet.

The focus is iOS/iPadOS/macOS for now; the rest are stubs by design — flesh one out or add a new
stack with a **single markdown module** ([Add a stack](./ARCHITECTURE.md#adding-a-stack)). PRs are
the point.

---

## Philosophy

> *Mise en place* — literally "everything in its place." Before a professional kitchen cooks a
> single dish, every ingredient is prepped, measured, and within reach. The meal goes fast
> because the prep was done first.

Most "build an app with AI" tutorials skip the prep and wonder why the build turns to chaos.
`mise` is the prep. It's opinionated the way a seasoned engineer is opinionated — not to boss
you around, but because these particular foundations are the difference between shipping and
flailing.

And it's opinionated about one thing in particular: **programmatic access.** The biggest
bottleneck in agent-assisted work is every point where the agent has to stop and drive a browser
or hand *you* a list of dashboard clicks. `mise` wires CLI / API / MCP / config-as-code paths
wherever it can, so the agent can *do* the work instead of narrating it — and reduces you to the
decisions only a human should make.

---

## License

MIT. Fork it, extend it, make it yours.
