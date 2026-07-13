# Stack module contract

Every `stacks/<name>.md` fills these fields. mise reads the detected stack's module to make its
recommendations concrete; a missing field just means "reason from first principles." Keep
modules short and factual.

- **detect** — signals that auto-suggest this stack (manifest files, extensions, config).
- **structure** — the directory layout a seasoned engineer would respect.
- **gitignore** — what must never be committed (build output, deps, secrets, OS junk).
- **connectors** — MCP servers worth wiring for this stack, each with a one-line why.
- **cli_tools** — the CLIs the workflow leans on (prefer these over dashboards).
- **skills** — workflow Skills to offer (always includes `/orchestrate`, `/handoff`).
- **claude_md_notes** — what a fresh agent must know before touching this code.
- **first_command** — the "you're ready — run this" handoff.

**Status:** a module is either **fleshed out** (like `ios-swiftui`, the reference stack) or a
**STUB** (fields sketched, flesh out later). Stubs still give mise a scaffold to reason from.
Adding or fleshing a stack is a single-file PR — that's the extensibility story.
