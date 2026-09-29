# Week 2: Three-Tier Application

Docker Compose runs three services: PostgreSQL 15 (`db`), a Flask API (`flask`), and an Nginx frontend (`nginx`). They communicate over the `app-network` network. Database records are stored in the named `db-data` volume. Health checks control startup order.

## Setup

From the `week-2` directory, copy `.env.example` to `.env`. Set `HOST_PORT=8081` and configure `POSTGRES_DB`, `POSTGRES_USER`, and `POSTGRES_PASSWORD`. Never commit `.env`.

Start the application with `docker compose up -d --build`.

## Checks

- `docker compose ps` shows the three services.
- `curl http://localhost:8081/` reaches the frontend.
- `curl http://localhost:8081/api/health` reaches Flask.
- `curl http://localhost:8081/api/incidents` queries PostgreSQL.
- `./health-check.sh` exits 0 when all services are healthy.

Database records survive a container restart because PostgreSQL uses the `db-data` volume.
