# Stack: react  — React SPA (Vite / TypeScript)

- **detect:** `package.json` with a `react` dependency; `.jsx` / `.tsx` files; a bundler config
  (`vite.config.*`, `react-scripts` (CRA), or Parcel). No `next` dep (that's the `nextjs` stack).
- **structure:** `src/` split into `components/` (small, presentational), `hooks/` (logic lives
  here, not in components), `lib/` or `services/` (API clients, helpers), and `routes/`/`pages/`
  if routed. Colocate tests next to what they test (`Button.test.tsx` beside `Button.tsx`).
  **Use TypeScript** and turn on `strict` — it's the single biggest quality lever for an
  AI-assisted codebase. Prefer Vite for new projects (CRA is effectively deprecated).
- **gitignore:** `node_modules/`, `dist/`, `build/`, `.env*` (keep `.env.example`), `coverage/`,
  `.vite/`, `.DS_Store`, editor cruft. **Never commit real `.env` values** — client bundles ship
  to the browser, so anything in a `VITE_`-prefixed var is public by design.
- **connectors:** usually none for a pure SPA. If it talks to a backend or DB, wire that
  programmatically; a Figma MCP is worth it for design-driven UI work.
- **cli_tools:** `gh`; the package manager **detected from the lockfile** (`pnpm` / `npm` /
  `yarn`, don't guess); the Vite CLI; `eslint` + `prettier`; `vitest` for tests.
- **skills:** `/mise-cook`, `/mise-handoff`, `/mise-clean`.
- **claude_md_notes:** the bundler (Vite/CRA), router (`react-router`?), state approach
  (Context / Zustand / Redux / TanStack Query — name the one in use), test runner (Vitest/Jest +
  React Testing Library), path aliases, the `VITE_`/`REACT_APP_` env-var convention (and that
  client env is public), and the dev/build/test commands.
- **first_command:** the project's dev script (usually `npm run dev` → Vite dev server).
