# Stack: nextjs  — Next.js (App Router / TypeScript)

- **detect:** `package.json` with `next`; `next.config.{js,ts,mjs}`; an `app/` (App Router) or
  `pages/` (Pages Router) directory.
- **structure:** for new work prefer the **App Router** (`app/`). Components are **server by
  default**; add `'use client'` only where you need interactivity or browser APIs — keep that
  boundary as low in the tree as possible. `components/`, `lib/`, and route handlers under
  `app/api/`. TypeScript with `strict`. Colocate.
- **gitignore:** `node_modules/`, `.next/`, `out/`, `build/`, `.env*` (keep `.env.example`),
  `.vercel/`, `coverage/`, `.DS_Store`. (`next-env.d.ts` is generated but conventionally
  committed.) **Env discipline matters here:** only `NEXT_PUBLIC_`-prefixed vars reach the
  browser — everything else stays server-only, so **never** put a secret behind `NEXT_PUBLIC_`.
- **connectors:** the DB / ORM (Postgres + Prisma or Drizzle) and the deploy target (Vercel) are
  worth wiring programmatically; an auth provider if used. Config-as-code beats their dashboards.
- **cli_tools:** `gh`; the package manager (from the lockfile); the `next` CLI; `vercel` CLI if
  deployed there; the ORM CLI (`prisma` / `drizzle-kit`) if used; `eslint`.
- **skills:** `/orchestrate`, `/handoff`.
- **claude_md_notes:** App vs Pages Router; the server/client component boundary and *when* to
  `'use client'`; the data-fetching model (server components / route handlers / server actions);
  env handling (`NEXT_PUBLIC_` = public, secrets server-only); the DB/ORM; the rendering strategy
  (SSR / SSG / ISR) per route; the deploy target.
- **first_command:** `npm run dev` (Next dev server).
