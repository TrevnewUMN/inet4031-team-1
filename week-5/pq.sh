#!/usr/bin/env bash
# Run one PromQL query against Prometheus and print one line per result.
# Usage: ./week-5/pq.sh 'up'
# Needs the Prometheus port-forward from Part 2 to be running, and PROM_URL
# set to your team's Prometheus port, e.g. export PROM_URL=http://localhost:9093

url="${PROM_URL:-http://localhost:9090}"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 'promql expression'" >&2
  exit 2
fi

if ! response=$(curl -s "$url/api/v1/query" --data-urlencode "query=$1"); then
  echo "Could not reach Prometheus at $url. Is the port-forward running, and is PROM_URL set to your team's port?" >&2
  exit 1
fi

printf '%s' "$response" | python3 -c '
import json, sys
try:
    r = json.load(sys.stdin)
except ValueError:
    sys.exit("That did not look like an answer from Prometheus.")
if r.get("status") != "success":
    sys.exit("Prometheus said: " + str(r.get("error", "unknown error")))
data = r["data"]
if data["resultType"] != "vector":
    print(data["result"])
    sys.exit(0)
if not data["result"]:
    print("(no results)")
for s in data["result"]:
    labels = " ".join(k + "=" + v for k, v in s["metric"].items() if k != "__name__")
    print(labels or "(no labels)", "->", s["value"][1])
'
