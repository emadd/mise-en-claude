# Stack: python-fastapi  — FastAPI (async Python API)

- **detect:** `pyproject.toml` or `requirements.txt` with `fastapi`; a `main.py`/`app.py` with
  `FastAPI()`; a `uvicorn` dependency.
- **structure:** `app/` with `api/`/`routers/` (endpoints), `services/` (logic), `models/`
  (SQLAlchemy/SQLModel ORM), `schemas/` (Pydantic request/response — keep these **separate** from
  ORM models), `core/config.py`, `db/session.py`, and `tests/`. **Type hints everywhere** —
  they're FastAPI's whole value. Prefer **`uv`** for envs/deps (fast, modern) over bare pip.
- **gitignore:** `.venv/`, `venv/`, `__pycache__/`, `*.pyc`, `.env*` (keep `.env.example`),
  `.pytest_cache/`, `.mypy_cache/`, `.ruff_cache/`, `*.db` / `*.sqlite`, `dist/`, `build/`,
  `*.egg-info/`, `.DS_Store`. **Never commit the real `.env`** (DB URL, secret key, API keys).
- **connectors:** **the database** — Postgres via SQLAlchemy/SQLModel with **Alembic**
  migrations; wire the `alembic` and `psql` CLIs. Plus external APIs and a deploy target.
- **cli_tools:** `gh`; **`uv`** (or pip/poetry — detect from the lockfile); `uvicorn` (dev
  server); **`alembic`** (migrations); `psql`; `ruff` (lint + format); `pytest`; `mypy`.
- **skills:** `/mise-cook`, `/mise-handoff`.
- **claude_md_notes:** the **async model** (`async def` endpoints + an async DB driver — don't
  block the event loop with sync I/O); Pydantic schemas vs ORM models kept separate; the
  **Alembic migration workflow** (autogenerate then *review*; never hand-edit a shipped
  revision); settings via `pydantic-settings` + env; dependency injection (`Depends`); auth
  (OAuth2 / JWT); how to run (`uvicorn --reload`) / test (`pytest`) / migrate (`alembic upgrade`).
- **first_command:** `uvicorn app.main:app --reload` — after the DB is up and `alembic upgrade
  head` has run.
