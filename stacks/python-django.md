# Stack: python-django  — Django (batteries-included full-stack)

- **detect:** `manage.py`; a `settings.py`; `django` in the deps; apps containing `models.py`.
- **structure:** **follow Django's conventions — they *are* the structure.** A project package
  plus feature `apps/` (each with `models`, `views`, `urls`, `admin`, `migrations`, `tests`).
  Use **Django REST Framework** if it's an API. Split settings (`base`/`dev`/`prod`) or drive them
  from env. Fat models / thin views is the Django way.
- **gitignore:** `.venv/`, `venv/`, `__pycache__/`, `*.pyc`, `.env*` (keep `.env.example`),
  `db.sqlite3` (local), `/staticfiles/` (collected), `/media/` (user uploads), `.DS_Store`.
  **Never commit `SECRET_KEY` or the real `.env`.**
- **connectors:** **the database** (Postgres) via Django's ORM (migrations are first-class and
  built in); wire `psql`. Plus a deploy target, and Redis + Celery if there are background tasks.
- **cli_tools:** `gh`; the Python env manager (`uv` / pip / poetry); **`manage.py`** (the
  swiss-army CLI: `runserver`, `makemigrations`, `migrate`, `createsuperuser`, `shell`, `test`);
  `psql`; `ruff` / `black`.
- **skills:** `/mise-cook`, `/mise-handoff`.
- **claude_md_notes:** the app layout and what each app owns; the **migrations workflow**
  (`makemigrations` → `migrate`; Django migrations are first-class — **never delete one that has
  shipped**); settings management + `SECRET_KEY`/env; DRF if it's an API; the auth model (Django
  auth / DRF tokens); background tasks (Celery/Redis); how to `runserver` / `migrate` / `test`.
- **first_command:** `python manage.py migrate && python manage.py runserver`.
