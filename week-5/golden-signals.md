# Lab 5 Bonus: Four Golden Signals for nginx (team1)

Run any query with `./week-5/pq.sh '<query>'` while the Prometheus port-forward on 9091 is up.
We don't run nginx-exporter, so these use the metrics our Prometheus already collects:
cAdvisor (per-container) and kube-state-metrics (pod status).

| Signal | PromQL | Value we saw (idle, 2026-10-23) |
|---|---|---|
| **Traffic**: bytes/s arriving at nginx | `sum(rate(container_network_receive_bytes_total{namespace="default",pod=~"nginx-.*",interface="eth0"}[5m]))` | 0 (no load at the time) |
| **Saturation**: nginx CPU (cores) | `sum(rate(container_cpu_usage_seconds_total{namespace="default",container="nginx"}[5m]))` | 0.0015 |
| **Saturation**: nginx memory (MB) | `sum(container_memory_working_set_bytes{namespace="default",container="nginx"}) / 1024 / 1024` | 4.9 |
| **Errors**: nginx restarts in the last hour | `sum(increase(kube_pod_container_status_restarts_total{namespace="default",container="nginx"}[1h]))` | 0 |
| **Errors**: network receive errors/s | `sum(rate(container_network_receive_errors_total{namespace="default",pod=~"nginx-.*"}[5m]))` | 0 |
| **Latency** | not available with our current metrics (see below) | none |

**Why there's no latency query:** none of our metrics time individual requests. cAdvisor and
node-exporter only see CPU, memory, disk and network, and `count({__name__=~"nginx_.*|flask_http_request_duration_seconds_bucket"})`
returned no results. Two ways to add it:
- Scrape Flask's request histogram (Wiki Step 12b's Service annotations, skipped this week on the
  professor's instructions). Then the p95 latency of requests nginx forwards to Flask is:
  `histogram_quantile(0.95, sum by (le) (rate(flask_http_request_duration_seconds_bucket[5m])))`
- Add nginx-prometheus-exporter as a sidecar. Note it only exposes `stub_status` counters
  (`nginx_http_requests_total` for traffic, `nginx_connections_active` for saturation), not latency.
  Real per-request nginx latency needs log-based metrics, for example `$request_time` in the access log.

During the k6 smoke test, k6 itself measured client-side latency: average 33 ms, p95 45 ms for `/api/incidents`.
