"""Seeds the incidents table with synthetic rows for the Week 9 performance lab.

Run inside the flask container, which already has DATABASE_URL and psycopg2:

    docker compose -f week-2/docker-compose.yml exec flask python3 seed.py --rows 50000
"""
import argparse
import os
import random
from datetime import datetime, timedelta, timezone

import psycopg2
import psycopg2.extras

STATUSES = ["open", "in_progress", "closed"]
STATUS_WEIGHTS = [0.3, 0.2, 0.5]

SUBJECTS = [
    "Database connection pool exhausted",
    "API latency spike on checkout",
    "Disk usage above 90% on app node",
    "Memory leak in background worker",
    "SSL certificate expiring soon",
    "Failed login rate anomaly",
    "Queue backlog growing",
    "Cache hit rate dropped",
    "Load balancer health check failing",
    "Scheduled job did not run",
]


def random_row():
    days_ago = random.uniform(0, 180)
    created_at = datetime.now(timezone.utc) - timedelta(days=days_ago)
    subject = random.choice(SUBJECTS)
    status = random.choices(STATUSES, weights=STATUS_WEIGHTS)[0]
    description = f"Auto-generated seed record for load testing ({subject.lower()})."
    return subject, status, description, created_at


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rows", type=int, default=50000)
    parser.add_argument("--batch-size", type=int, default=2000)
    args = parser.parse_args()

    database_url = os.environ["DATABASE_URL"]
    conn = psycopg2.connect(database_url)
    conn.autocommit = False

    inserted = 0
    with conn, conn.cursor() as cur:
        while inserted < args.rows:
            batch = min(args.batch_size, args.rows - inserted)
            rows = [random_row() for _ in range(batch)]
            psycopg2.extras.execute_values(
                cur,
                "INSERT INTO incidents (title, status, description, created_at) VALUES %s",
                rows,
            )
            inserted += batch
            print(f"inserted {inserted}/{args.rows}")

    conn.close()
    print(f"done: inserted {inserted} rows")


if __name__ == "__main__":
    main()
