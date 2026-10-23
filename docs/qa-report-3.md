# QA Report - Sprint 3 Week 5

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

## Executive Summary

TODO: Provide a brief summary of the testing results, including pass/fail status and any critical issues found.

## Test Coverage

### Test Suite 1: Helm and Prometheus Installation

- [ ] Helm installation successful
- [ ] Prometheus community repository added
- [ ] Prometheus (`prometheus` chart 29.35.0) deployed without errors
- [ ] All monitoring pods reached Running state

**Result:** [TODO: PASS/FAIL]

**Notes:** 
TODO: Record any observations about the installation process, timeouts, or resource constraints.

### Test Suite 2: Prometheus Metric Collection (MANDATORY)

- [ ] Prometheus scraping pod metrics
- [ ] `kubernetes-nodes-cadvisor` scrape job present in `up` output
- [ ] Prometheus query for `container_cpu_cfs_throttled_periods_total` returns data
- [ ] At least one metric series returned

**Result:** [TODO: PASS/FAIL - THIS IS MANDATORY FOR WEEK 9]

**Metric Series Count:** [TODO: Number of series returned]

**Notes:**
TODO: If this test fails, record what was attempted to fix it (upgrade, reconfigure, etc.)

### Test Suite 3: USE Queries from the Command Line

- [ ] Prometheus port-forward running on the team's assigned Prometheus port
- [ ] Flask scrape target shows `up` = 1
- [ ] CPU Utilization query returns data
- [ ] CPU Throttle Rate query returns data
- [ ] HTTP 5xx Error Rate query runs (no results is expected until a 5xx occurs)

**Result:** [TODO: PASS/FAIL]

**Queries Verified:**
- [ ] Flask CPU Utilization: [TODO: Data visible Y/N]
- [ ] Flask CPU Throttle Rate: [TODO: Data visible Y/N]
- [ ] HTTP 5xx Error Rate: [TODO: Data visible Y/N]

**Notes:**
TODO: Record any issues with queries or metric availability.

### Test Suite 4: Prometheus Alert Rule

- [ ] Error rate alert configured
- [ ] Alert threshold set correctly (> 1%)
- [ ] Alert duration set correctly (1 minute)
- [ ] Alert rule loaded (`HTTP5xxErrorRateHigh` listed by the rules check)

**Result:** [TODO: PASS/FAIL]

**Notes:**
TODO: Record alert configuration details and any issues encountered.

### Test Suite 5: k6 Load Testing

- [ ] k6 installed successfully
- [ ] smoke-test.js created and formatted correctly
- [ ] Load test runs without errors
- [ ] Prometheus query results respond to load test activity

**Result:** [TODO: PASS/FAIL]

**Test Parameters:**
- Virtual users: [TODO: Record vus value]
- Duration: [TODO: Record duration]
- Requests per user: [TODO: Estimate]

**Metrics Observed:**
- CPU utilization increased: Yes/No
- Memory utilization increased: Yes/No
- Network activity increased: Yes/No
- HTTP requests recorded: Yes/No

**Notes:**
TODO: Document metrics observed during load test and any anomalies.

### Test Suite 6: Validation Scripts

- [ ] check-week5.sh exists and is executable
- [ ] All validation checks pass
- [ ] Exit code is 0
- [ ] Script output is clear and actionable

**Result:** [TODO: PASS/FAIL]

**Validation Results:**
- [ ] All monitoring pods running: PASS/FAIL
- [ ] cAdvisor scrape job and alert rule configured: PASS/FAIL
- [ ] container_cpu_cfs_throttled_periods_total returns data: PASS/FAIL

## Cross-Week Dependency Verification

**Week 9 CPU Throttling Diagnosis Dependency:**

- [ ] Prometheus is scraping cAdvisor metrics
- [ ] Query for `rate(container_cpu_cfs_throttled_periods_total[5m])` returns data
- [ ] Metric series is non-empty and consistent
- [ ] No manual fixes required; this will persist across restarts

**Status:** [VERIFIED/NOT VERIFIED]

**Notes:** 
TODO: Confirm that the Week 5 configuration will support Week 9's CPU diagnosis lab. If any issues, document them here.

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** _________________    **Date:** __________

---

## Notes for Sprint 4

[Any observations or recommendations for the next sprint]
