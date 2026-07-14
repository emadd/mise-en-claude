# Stack: node-express  — Node.js + Express API (TypeScript)

- **detect:** `package.json` with `express` and **no** `react`/`next`; a server entry
  (`src/server.ts`, `app.ts`, `index.ts`); often a `Dockerfile` / `Procfile`.
- **structure:** `src/` with `routes/` (thin — parse, validate, delegate), `services/` (the
  business logic), `db/` or `models/` (schema + a single connection/pool module), `middleware/`,
  `config/`, and tests. Keep routes thin and logic in services. TypeScript with `strict`.
  Validate input at the edge (`zod` or similar) — never trust the request body.
- **gitignore:** `node_modules/`, `dist/`, `build/`, `.env*` (keep `.env.example`), `coverage/`,
  `*.log`, `*.sqlite` / `*.db` (local), `.DS_Store`. **Secrets discipline is critical here** —
  the DB URL, JWT secret, and API keys live in env and are **never** committed.
- **connectors:** **the database is the one to wire programmatically** — Postgres via Prisma /
  Drizzle / Knex, whose CLI drives schema + migrations. Plus a deploy target (Railway / Render /
  Fly) and any third-party APIs. Config-as-code over their dashboards.
- **cli_tools:** `gh`; the package manager (from the lockfile); the ORM/migration CLI
  (`prisma` / `drizzle-kit` / `knex`); `psql` (or the DB's CLI); `tsx` / `nodemon` for dev;
  `vitest` / `jest`.
- **skills:** `/mise-cook`, `/mise-handoff`, `/mise-clean`.
- **claude_md_notes:** the DB + ORM and the **migration workflow** (how to create and run one;
  **never edit a migration that has shipped**); connection pooling; env/secret handling; the
  routing + middleware structure; the auth approach (JWT / sessions); input validation; how to
  run / test / migrate.
- **first_command:** run the dev server (e.g. `npm run dev`) — **after** the DB is up and
  migrations are applied.
