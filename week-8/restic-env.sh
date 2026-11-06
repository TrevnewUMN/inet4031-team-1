# Usage: source week-8/restic-env.sh
# Reads MINIO_ROOT_USER, MINIO_ROOT_PASSWORD, and RESTIC_PASSWORD from
# week-8/.env.backup (git-ignored), so this file holds no secrets and is safe to commit.
# Needs the MinIO port-forward from Part 1, Step 5 to be running.
source "$(dirname "${BASH_SOURCE[0]}")/.env.backup"
export MINIO_PORT=9301   # TODO: change to your team's MinIO port (9300 + your team number)
export RESTIC_REPOSITORY="s3:http://localhost:${MINIO_PORT}/backups"
export AWS_ACCESS_KEY_ID="${MINIO_ROOT_USER}"
export AWS_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}"
export RESTIC_PASSWORD
