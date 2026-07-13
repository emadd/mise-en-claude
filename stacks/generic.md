# Stack: generic  — sane defaults when the stack isn't listed yet

Used when detection doesn't match a known module. Reason from first principles, but always:

- **structure:** a clear source dir, a tests dir, a `README`, a `CLAUDE.md`. Separate concerns;
  no God-files.
- **gitignore:** the language's build/dependency output, `.env*`, editor cruft, `.DS_Store`.
- **connectors:** only what the project actually touches.
- **cli_tools:** `gh` at minimum; the language's package manager and test runner.
- **skills:** `/orchestrate`, `/handoff`.
- **claude_md_notes:** how to build, how to test, how to run — the three things a fresh session
  always needs.
- **first_command:** whatever proves the project runs (build + test, or start).
