# QA Report: Sprint 5 Week 9

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

---

## Validation Checks

### Check 1: Seeded Row Count Is Approximately 50,000

**Test:** Run `kubectl exec deploy/db -- psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"`

**Expected:** Approximately 50,000 rows

**Actual Result:**
```
TODO: Paste the actual row count
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If the count is far off (e.g. near 0 or near 1), was `seed.py --rows 50000` re-run against a fresh Postgres container -- for example after a host reboot, since the `week-2` Compose stack does not restart automatically?

---

### Check 2: Sequential Scan Is Fixed by the New Index

**Test:** Run `kubectl exec deploy/db -- psql -U appuser -d statustracker -c "\di idx_incidents_status_created"`, then re-run `EXPLAIN (ANALYZE, BUFFERS)` on the status-filtered query from the runbook

**Expected:** Index listed by name; `EXPLAIN` output shows `Index Scan`, not `Seq Scan`

**Actual Result:**
```
TODO: Paste the index listing and the EXPLAIN ANALYZE output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Was `pg_stat_statements` confirmed loaded via `SHOW shared_preload_libraries;` before it was queried (Step 13a)? `CREATE EXTENSION IF NOT EXISTS pg_stat_statements` alone does not load it, and the stats query will error at runtime if this step was skipped.

---

### Check 3: CPU Throttle Rate Is Near Zero After the Fix

**Test:** Run the throttle-rate query from the wiki's Validation Checks section (`rate(container_cpu_cfs_throttled_periods_total{container="flask"}[5m])/rate(container_cpu_cfs_periods_total{container="flask"}[5m])`)

**Expected:** `PASS` (rate < 0.01)

**Actual Result:**
```
TODO: Paste the query result
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Did the ramped load test that produced this reading actually target your team's Kubernetes port (`k6 run -e BASE_URL=http://localhost:<your Kubernetes port> ...`)? Without `-e BASE_URL`, the test defaults to `http://localhost:8080`, which never reaches the throttled pods -- that reads as a clean "no throttling" result regardless of what the CPU limit is set to. Also confirm the metric name used was `container_cpu_cfs_throttled_periods_total`, not `_seconds_total` -- the latter is cgroup v1-only and returns no data at all on cgroup v2 hosts (the default on modern Docker/k3d setups).

---

### Check 4: k6 Smoke Test Passes Its Threshold

**Test:** Run `k6 run week-9/smoke-test.js`

**Expected:** Both thresholds (`p(95)<500`, `rate<0.01`) show passing (✓) in the summary

**Actual Result:**
```
TODO: Paste the k6 summary output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Was this run against your healthy k3d application (`kubectl get pods` all `Running`), with `-e BASE_URL=http://localhost:<your Kubernetes port>`? An application that isn't up fails every request instead of failing the threshold cleanly, and can be mistaken for a performance regression.

---

### Check 5: CPU Limit Restored in the Cluster and in `flask.tf`

**Test:** Run `kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}'` and `grep -n "cpu" infrastructure/flask.tf`

**Expected:** `No changes. Your infrastructure matches the configuration.`

**Actual Result:**
```
TODO: Paste the output of both commands
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Both should show `500m`. If the live value is still `100m`, the Step 15 `kubectl set resources` fix was not applied. Do not run `tofu plan` on the shared VM -- the OpenTofu step is predict-only this week.

---

### Check 6: Check Script Passes

**Test:** Run `chmod +x ./scripts/check-week9.sh` then `./scripts/check-week9.sh`

**Expected:** All checks pass with exit code 0

**Actual Result:**
```
TODO: Paste the full output of the check script
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** The script's CPU-throttle check queries Prometheus directly and requires the Step 0a port-forward (`kubectl port-forward -n monitoring service/prometheus-server <your Prometheus port>:80`) to still be running.

---

## Acceptance Criteria Verification

Review the criteria below for each part of this week's deliverables. For each criterion, record whether it was met:

### Part 1: Load the Database

TODO: [ ] `seed.py --rows 50000` executed inside the `flask` container, using the app's own `DATABASE_URL`
TODO: [ ] Row count verified as approximately 50,000

### Part 2: Baseline Load Test

TODO: [ ] `week-9/smoke-test.js` created with `p(95)<500` and `rate<0.01` thresholds
TODO: [ ] Baseline k6 run completed and screenshotted to the Google Doc

### Part 3: Ramped Load Test and USE Method Diagnosis

TODO: [ ] Intentional 100m CPU limit applied to `flask` with `kubectl set resources`, per Step 9
TODO: [ ] `week-9/ramped-test.js` created and run with `-e BASE_URL=http://localhost:<your Kubernetes port>`
TODO: [ ] Ramped test run while re-running the USE queries with `week-5/pq.sh`
TODO: [ ] Non-zero CPU throttle rate captured and screenshotted before the fix
TODO: [ ] `pg_stat_statements` enabled via `shared_preload_libraries` (Step 13a) before diagnosis
TODO: [ ] `EXPLAIN (ANALYZE, BUFFERS)` captured showing `Seq Scan` before the index

### Part 4: Fix Both Issues and Measure Improvement

TODO: [ ] Index created with `CREATE INDEX CONCURRENTLY idx_incidents_status_created`
TODO: [ ] `EXPLAIN (ANALYZE, BUFFERS)` re-run, confirms `Index Scan` replaces `Seq Scan`
TODO: [ ] `infrastructure/flask.tf` CPU limit confirmed/restored to 500m
TODO: [ ] Live CPU limit restored to 500m with `kubectl set resources`, `infrastructure/flask.tf` confirmed at 500m, and the [PREDICT ONLY] prediction recorded (Step 15)
TODO: [ ] Ramped test re-run; RPS, P50, P95, and error rate recorded and compared to baseline
TODO: [ ] CPU throttle rate re-queried and confirmed near zero

### Part 5: Add k6 Threshold Gate to CI

TODO: [ ] `.github/workflows/ci.yml` has a `load-test-gate` job depending on `build-and-push`
TODO: [ ] Job brings up the `week-2` Compose stack with `--wait` before running k6
TODO: [ ] Job runs `k6 run week-9/smoke-test.js` as the threshold gate
TODO: [ ] Teardown step runs `docker compose down -v` with `if: always()`
TODO: [ ] All changes committed and pushed to `main`

---

## Deliverables Verification

### Required Files

TODO: [ ] `week-9/smoke-test.js` is committed
TODO: [ ] `week-9/ramped-test.js` is committed and reads its target from `BASE_URL`
TODO: [ ] `week-9/runbook.md` is committed using the two-incident format, with measured values filled in (not placeholders)
TODO: [ ] `infrastructure/flask.tf` reflects the corrected 500m CPU limit
TODO: [ ] `.github/workflows/ci.yml` includes the `load-test-gate` job
TODO: [ ] `scripts/check-week9.sh` present and runs clean

### GitHub Repository

TODO: [ ] All changes are pushed to the main branch
TODO: [ ] `manifests/db-deployment.yaml` committed with the `pg_stat_statements` startup flag

### Google Doc

TODO: [ ] "Week 9 Baseline" k6 screenshot attached
TODO: [ ] Non-zero throttle rate screenshot (before fix) attached
TODO: [ ] `Seq Scan` EXPLAIN ANALYZE screenshot (before the index) attached
TODO: [ ] `Index Scan` EXPLAIN ANALYZE screenshot (after the index) attached
TODO: [ ] Post-fix k6 threshold-passing screenshot attached
TODO: [ ] `./scripts/check-week9.sh` passing screenshot attached
TODO: [ ] Discussion answers recorded for Parts 3, 4, and 5
TODO: [ ] Week 9 storage check recorded

---

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** _________________    **Date:** __________

---

## Notes for Sprint 6

[Any observations or recommendations for the next sprint]
