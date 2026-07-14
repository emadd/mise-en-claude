# Stack: angular  — Angular (TypeScript)

- **detect:** `angular.json`; `package.json` with `@angular/core`; `*.component.ts` files.
- **structure:** for new work use **standalone components** (the modern default, Angular 17+) over
  NgModules; organize `src/app/` by feature folder with `components/`, `services/`, `models/`.
  TypeScript is native; keep `strict` on. Prefer **signals** for local state (modern Angular);
  reach for NgRx only when the app genuinely needs a global store.
- **gitignore:** `node_modules/`, `dist/`, `.angular/`, `coverage/`, `/out-tsc`, `tmp/`, `.env*`
  (keep `.env.example`), `.DS_Store`.
- **connectors:** the backend / API.
- **cli_tools:** `gh`; the package manager; the **`ng` Angular CLI** (scaffolding, build, test);
  `eslint`.
- **skills:** `/mise-cook`, `/mise-handoff`, `/mise-clean`.
- **claude_md_notes:** standalone components vs NgModules (say which the project uses); DI
  patterns; state approach (signals vs NgRx); routing; the degree of RxJS usage (a real
  onboarding hurdle — note the conventions); the `ng build` / `ng serve` / `ng test` commands;
  strict mode.
- **first_command:** `ng serve`.
