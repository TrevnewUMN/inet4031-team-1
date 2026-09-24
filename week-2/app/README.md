# Application Source Code

This is the incident tracking application: a Flask API backed by PostgreSQL.

Provided files:
- `Dockerfile` - container image definition for the Flask application (runs as a non-root user on port 5000)
- `app.py` - the Flask API application
- `seed.py` - synthetic data seeder used in Week 9's performance lab (not run in Week 2)
- `requirements.txt` - Python package dependencies

Do not modify the provided application code. Your responsibility is to configure how it runs via Docker Compose.

## What the app expects at runtime

- `DATABASE_URL` - a full PostgreSQL connection string, e.g.
  `postgresql://<user>:<password>@db:5432/<database>`. Provide this as an
  environment variable on the `flask` service in your `docker-compose.yml`;
  the app reads it from the environment, so no code changes or hardcoded
  credentials are needed.

The app creates its own `incidents` table on startup if it does not already
exist (`CREATE TABLE IF NOT EXISTS`) - you do not need to run any migration
step in Week 2.

## Endpoints

- `GET /health` - returns `200 {"status": "ok"}` once the app can serve
  requests. Used by Docker Compose's `service_healthy` condition.
- `GET /incidents` - returns the most recent 100 incidents as JSON, newest first.
- `POST /incidents` - creates an incident. Body: `{"title": ..., "status": ..., "description": ...}`
  (`title` and `status` are required). Returns the created row, including its `id`.

## `seed.py` (Week 9 only)

Week 9's performance lab needs a large `incidents` table to demonstrate a
sequential-scan query plan. `seed.py` is bundled into this image for that
purpose - it is not part of the Week 2 deliverable and should not be run
until Week 9's wiki instructs it. It inserts synthetic rows in batches using
the same `DATABASE_URL` the app itself uses:

```bash
docker compose -f week-2/docker-compose.yml exec flask python3 seed.py --rows 50000
```
