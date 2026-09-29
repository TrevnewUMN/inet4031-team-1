#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1

failed=0
for service in db flask nginx; do
  id="$(docker compose ps -aq "$service" 2>/dev/null)"
  state="$(docker inspect -f '{{.State.Running}} {{if .State.Health}}{{.State.Health.Status}}{{end}}' "$id" 2>/dev/null)"

  if [ "$state" = "true healthy" ]; then
    echo "$service: healthy"
  else
    echo "$service: not healthy"
    failed=1
  fi
done

exit "$failed"
