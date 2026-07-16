<!-- mise en place: get everything in its place before you cook. -->

# mise

**Get your project's *mise en place*: everything in its place before you build.**

> ⚠️ **Early, and serious about safety.** The paste-in [`PROMPT.md`](./PROMPT.md) and the
> `/mise-cook` command work today, and [`stacks/`](./stacks) covers iOS/iPadOS/macOS plus React,
> Next.js, Angular, Flutter, React Native, and three backends. The safety behavior is validated by
> a QA harness that runs `mise` against synthetic projects on more than one model (see
> [Proven on itself](#proven-on-itself)). Mode B's `install.sh` installs the workflow commands
> today; still on the roadmap: the re-runnable `/mise` skill and the templates
> ([`ARCHITECTURE.md`](./ARCHITECTURE.md)). Feedback welcome.

`mise` is a paste-in prompt for [Claude Code](https://claude.com/claude-code) that interviews
you about your project and then stands up (or upgrades) a real engineering foundation for it:
git, a `CLAUDE.md`, a sane project structure, the right connectors and CLI tools, workflow
skills like `/mise-cook`, and a task tracker — yours if you already have one, GitHub Issues if not
— as your workflow's memory. Stop fiddling with
setup and *start building*.

It's the foundation a seasoned engineer would lay before writing a line of feature code: the
"do this first" step most AI-assisted projects skip and later regret.

> **Honest scope:** the *ideas* here (project structure, git discipline, programmatic access,
> context hygiene) are tool-agnostic craft. **This repo is the concrete Claude Code reference
> implementation:** it installs Skills, slash commands, and MCP connectors, so it assumes **Claude
> Code (any surface: CLI, Desktop app, web, or IDE extension)**. The ideas port anywhere; the
> automation is Claude Code-flavored on purpose.

---

## Quickstart

### Mode A: zero install (fastest)

Works in **any Claude Code surface**: the CLI, the Desktop app, the web (claude.ai/code), or an
IDE extension.

1. Start a Claude Code session **for your project** (new *or* existing):
   - **CLI:** open a terminal in the project folder and run `claude`.
   - **Desktop app:** open Claude Code and open/select your project folder.
   - **Web / IDE:** open your project in claude.ai/code or your IDE extension.
2. Copy the contents of **[`PROMPT.md`](./PROMPT.md)** and paste it as your first message.

That's it. `mise` will interview you, show you a plan, and set nothing up until you say yes.

**Don't have the file handy — just this link?** Paste this instead of the full file:

```
Read https://raw.githubusercontent.com/emadd/mise/main/PROMPT.md and follow it to set up my project.
```

That's a real instruction to fetch and run it — not the same as just dropping the bare link, which
Claude will (correctly, for safety) treat as something to look at rather than something to obey.

### Mode B: clone + install (the workflow commands)

Clone the repo and run the installer to put mise's **workflow commands** into your Claude Code
config:

```sh
git clone https://github.com/emadd/mise
cd mise && ./install.sh          # installs /mise-cook, /mise-handoff + /mise-clean for all your projects
# or:  ./install.sh --project .  # install into just this project's ./.claude
```

That gives you **`/mise-cook`** (kitchen brigade), **`/mise-handoff`** (session hand-off), and
**`/mise-clean`** (hygiene sweep), plus the orchestration playbook, globally or per-project. The install is non-destructive and idempotent: it
backs up any command file you'd edited before replacing it, and skips files already current.

Still on the roadmap: the re-runnable **`/mise` skill** and the **template library**, so `/mise`
can act as an updater whenever your project drifts. For the full setup/rescue flow today, use
**Mode A** above.

### Staying up to date

`mise` improves over time, so how you get the newest version depends on your mode:

- **Mode A (paste):** the prompt lives only in your session, so "updating `mise`" just means
  **re-copying the latest `PROMPT.md` and pasting it into a fresh session.** There is nothing
  installed to update, and nothing to run.
- **Mode B (planned):** once the installed `/mise` skill ships, updating becomes a real command
  you run once, and `/mise` picks up the latest on its own.

Note this is separate from **Update mode** (below), which brings *your project's* foundation up to
the latest guidance. Updating the *tool* is the paste/skill above; updating your *project* is
Update mode.

---

## What it sets up

`mise` works in **consent-gated phases**. It always previews the whole plan first, and you can
skip any phase. Nothing is installed or written without your yes.

| Phase | What it does |
|---|---|
| **0 · Vision** | Learns your vision, stack, goals, whether this is new or existing, and whether you already use a task tracker — your choice of a quick **interview** (Anthropic's "let Claude interview you" pattern) or an open **brainstorm** that helps you shape a fuzzy idea first. |
| **1 · Assess** | Reads your current environment (git state, existing files, installed CLIs, OS) so recommendations fit reality, not a template. |
| **2 · Git** | Initializes (or adopts) the repo, writes a stack-appropriate `.gitignore`, sets branch conventions, makes a clean first commit. |
| **3 · Context** | Generates a starter `CLAUDE.md` and `README` from your interview, and lays down a project structure a real engineer would respect. |
| **4 · Connections** | Wires **programmatic access** (MCP / API / CLI) to the services your project touches, so agents can *operate* them, not just read about them. |
| **5 · CLI + tools** | Sets up `gh` and the other CLIs your workflow leans on; prefers a CLI/API over any dashboard, and flags browser-only bottlenecks. |
| **6 · Skills + shortcuts** | Installs the workflow Skills and slash commands, including **`/mise-cook`**, the kitchen-brigade multi-agent workflow. |
| **7 · Persistence** | Wires your preferred task tracker (Jira, Linear, Asana, Trello — or GitHub Issues if you have none) + git as your workflow's durable memory, so context survives between sessions. |
| **8 · Verify + hand off** | Confirms everything works and hands you a first command to run. You're building in minutes, not hours. |

**Existing project?** `mise` detects it and runs in **Rescue mode** (see below).

---

## Started on the wrong foot? Rescue mode

Most people who need `mise` already have a project: a half-built, AI-assisted tangle with no
git, no structure, a giant do-everything file, maybe an API key pasted into the source. `mise`
is built to **straighten it out without losing your work.**

When it detects an existing project, it switches from "set up" to **rescue**:

1. **Snapshot first: nothing is touched until your work is safe.** No repo? `mise`'s first act
   is to `git init` and commit your current state *verbatim* as a recovery point. Already have a
   repo? It works on a `mise/rescue` branch. Every change after this is reversible.
2. **A health report, in plain language.** `mise` reads your actual project and hands you a
   prioritized diagnosis (git hygiene, committed secrets, monolith files, missing
   `.gitignore` / `CLAUDE.md` / tests / CI) with *why each one bites you later*. No jargon wall,
   just a checklist you understand.
3. **Triage, safety-first.** It fixes in the order a seasoned engineer would: stop-the-bleeding
   (leaked secrets) → recoverability (safely into git) → structure → context → workflow. Each
   fix is a separate, reviewable step. Stop whenever you want; everything stays intact.
4. **Your work is preserved, always.** Reorg happens via `git mv` (history kept), big changes
   arrive as diffs you approve, code is never deleted, and there's **no big-bang rewrite**.

Two things `mise` does that are worth the price of admission:

- **Writes the `CLAUDE.md` you never had**, by *reading your existing code*. Every future
  Claude session immediately gets smarter about your project.
- **Handles committed secrets like an adult.** It catches keys already in your git *history*,
  not just the working tree, and tells you plainly that quietly untracking them is **not** a fix.
  It explains the real one (rotate the key provider-side, and rewrite history only if *you*
  choose to), and it will **never rewrite your history behind your back.** Through all of it, the
  secret's plaintext never enters the model's context.

Rescue mode is idempotent too: re-run it any time the project drifts and it only addresses
what's newly wrong.

---

## Keeping it current: Update mode

`mise` is a *living* setup, not a one-shot. Guidance improves and Claude Code itself evolves, so
`mise` can **update itself and reconcile your project** with the latest.

When it configures a project, `mise` leaves a small committed **`.mise/` stamp** recording which
version set you up and what choices it applied. Later, run it again and pick **Update**:

1. **Fetches the latest** canonical `mise` from the repo (with your consent).
2. **Snapshots** first (same as rescue: reversible before any change).
3. **Reconciliation report**, in three buckets:
   - **🆕 New:** guidance, skills, or connectors added since your version.
   - **🔀 Drifted:** where your project diverged (maybe on purpose, so `mise` treats it as yours).
   - **🗑 Deprecated:** anything the new guidance dropped.
4. **Applies what you approve**, non-destructively. Where you clearly customized something, it
   **asks "keep yours or adopt?"** instead of overwriting your choice.

Because the stamp records *what `mise` did*, it can tell a deliberate customization from bit-rot:
if it isn't in the stamp, `mise` didn't do it, so it's yours, and it asks before touching it.

---

## Safety: consent-first by design

This tool modifies your environment, so it behaves like a disciplined engineer, not a
`curl | bash` one-liner:

- **Previews the full plan** before touching anything, and asks before each phase.
- **Never clobbers.** Existing files are merged or appended, never overwritten silently.
- **Dry-run friendly.** Ask it to show you exactly what it would do first.
- **Explains as it goes.** Every step says *why*, so you learn the foundation instead of
  inheriting a black box.
- **Idempotent.** Safe to re-run; it detects what's already done and only fills gaps, which is
  what makes it double as an *updater*.
- **Secrets by reference, never by value.** When it audits and fixes exposed keys, the *plaintext
  never enters the model's context*. It detects by pattern and location, references findings by
  `file:line`, and fixes structurally (env references, provider-side rotation). It gates the exact
  set of files it is about to commit, so a key can't ride in on a baseline commit, and it stays
  value-blind even on config files that mix real code with secrets. The tool fixes leaks without
  becoming one.
- **Context-window aware.** The foundation it lays makes your agents treat context as a budget:
  warn when it's tight, hand off cleanly to a durable artifact, and refuse to run into silent
  auto-compaction where fidelity quietly dies.
- **Runs on a capable model, and degrades safely if not.** `mise` assumes a frontier-class model
  and opens with a capability self-check. It can't truly *detect* the model (no prompt can), so if
  it's unsure it stays **read-only**: it gives you the report but refuses to edit, install, or
  delete, and tells you to re-run on a stronger model. The real safety net is that every change is
  snapshot-first and reversible anyway.
- **Adapts to your environment.** The multi-agent workflow sizes its parallelism to *your*
  machine (cores/memory/load), not a hardcoded number of agents. And it's **local-first but
  cloud-adaptive**: it prefers local dev, but if you start in the cloud it does the portable work
  there and hands the local-only parts (native builds, simulators, signing) back to a local
  session.
- **Meets you at your level.** It asks how comfortable you are and calibrates: plain language by
  default, jargon only where it helps. It leads with the short version and layers the detail on
  request, so what you get back is something you can actually absorb, not a wall of text.
- **Helps you pick a stack if you're starting from scratch.** Arrived with just an idea and no
  clue what to build it in? It asks what you're making and where it runs, then recommends a stack
  with plain-language trade-offs and a clear default, so you leave with something you understand
  and chose, not a guess.
- **Understands multi-project workspaces.** If your tree holds several related projects (a
  backend + a web app + a mobile app, or a monorepo), it maps each one, offers to reorganize a
  tangled layout for clarity (proposed, never forced), and sets up context at *two* levels: each
  project's own `CLAUDE.md` **plus** a root map tying the whole system together, so agents grasp
  how the surfaces relate and where the boundaries are.
- **Mines your agent's memory.** It scans Claude Code's accumulated memories for durable,
  project-scoped facts and gotchas and offers to **bake the vetted ones into your `CLAUDE.md`**,
  version-controlled and shared, after checking each for correctness (against the actual code),
  accuracy, and scope. It never deletes your memories, and never bakes a sensitive one into a
  committed file.

The consent-first posture isn't friction, it's the whole point. Knowing what's happening to
your project *is* the skill.

---

## Proven on itself

A tool that does consequential things to real projects should be able to prove it stays safe.
`mise` ships its own QA harness in [`tests/`](./tests):

- **A safety rubric** ([`RUBRIC.md`](./tests/RUBRIC.md)): the non-negotiable spine every run is
  graded against. Correct mode detection, a snapshot before any change, secrets handled
  value-blind, history never rewritten, consent respected, nothing clobbered.
- **A playbook** ([`PLAYBOOK.md`](./tests/PLAYBOOK.md)): how to test `mise` the honest way, with a
  fresh session that has only `PROMPT.md` and has never seen the design discussion, so the prompt
  is graded on what it actually *does*, not on what its author hoped it would do.
- **Synthetic fixtures** ([`fixtures/`](./tests/fixtures)): generated stand-ins for the situations
  that stress the spine (no git, a secret committed in history, a config file that mixes structure
  and secrets, a giant junk tree, an already-healthy repo). No real code, no real secrets, nothing
  checked in that a scanner would flag.

The harness is run across models, because the safety guarantees have to hold on the everyday
workhorse model, not just the top tier. `mise` eats its own dog food: the discipline it teaches
your project (snapshot, verify, review before you ship) is the discipline used on `mise` itself.

---

## Supported stacks

Recommendations (structure, connectors, CLIs, `.gitignore`, skills) are driven by pluggable
**stack modules** in [`stacks/`](./stacks):

**Frontend & mobile:**
- `ios-swiftui`: iOS / iPadOS / macOS (the reference stack).
- `react`: React SPA (Vite / TypeScript).
- `nextjs`: Next.js (App Router / TypeScript).
- `angular`: Angular (TypeScript).
- `flutter`: Flutter (Dart).
- `react-native`: React Native (Expo or bare).

**Backend:**
- `node-express`: Node.js + Express API (TypeScript).
- `python-fastapi`: FastAPI (async Python API).
- `python-django`: Django (batteries-included full-stack).

- `generic`: a sane default when your stack isn't listed yet.

Don't see yours, or want to sharpen one? A stack is a **single markdown module**
([Add a stack](./ARCHITECTURE.md#adding-a-stack)). PRs are the point.

---

## Philosophy

> *Mise en place*, literally "everything in its place." Before a professional kitchen cooks a
> single dish, every ingredient is prepped, measured, and within reach. The meal goes fast
> because the prep was done first.

Most "build an app with AI" tutorials skip the prep and wonder why the build turns to chaos.
`mise` is the prep. It's opinionated the way a seasoned engineer is opinionated: not to boss
you around, but because these particular foundations are the difference between shipping and
flailing.

And it's opinionated about one thing in particular: **programmatic access.** The biggest
bottleneck in agent-assisted work is every point where the agent has to stop and drive a browser
or hand *you* a list of dashboard clicks. `mise` wires CLI / API / MCP / config-as-code paths
wherever it can, so the agent can *do* the work instead of narrating it, and reduces you to the
decisions only a human should make.

---

## License

MIT. Fork it, extend it, make it yours.
