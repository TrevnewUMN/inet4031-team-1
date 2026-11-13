#!/bin/bash

# Week 9 Validation Check Script
# Verifies all critical Week 9 deliverables before submission.
# Run this from the repository root: ./scripts/check-week9.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASS_COUNT=0
FAIL_COUNT=0

# Function to print pass/fail/warn messages
check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "=========================================="
echo "Week 9 Validation Check"
echo "=========================================="
echo ""

# Check 1: Verify seeded row count
echo "Checking database row count..."
ROW_COUNT=$(kubectl exec deploy/db -- \
    psql -U appuser -d statustracker -t -A -c "SELECT COUNT(*) FROM incidents;" 2>/dev/null | tr -d ' ' || true)

if [ -n "$ROW_COUNT" ]; then
    if [ "$ROW_COUNT" -ge 49500 ] && [ "$ROW_COUNT" -le 51000 ]; then
        check_pass "Row count: $ROW_COUNT (approximately 50,000 expected)"
    else
        check_warn "Row count: $ROW_COUNT (expected ~50,000; count is within tolerance for asynchronous processes)"
    fi
else
    check_fail "Could not retrieve row count from database"
fi
echo ""

# Check 2: Verify index exists
echo "Checking database index..."
INDEX_EXISTS=$(kubectl exec deploy/db -- \
    psql -U appuser -d statustracker -t -A -c "SELECT COUNT(*) FROM pg_indexes WHERE indexname = 'idx_incidents_status_created';" 2>/dev/null | tr -d ' ' || true)

if [ "${INDEX_EXISTS:-0}" -gt 0 ] 2>/dev/null; then
    check_pass "Index idx_incidents_status_created exists"
else
    check_fail "Index idx_incidents_status_created not found"
fi
echo ""

# Check 3: Verify CPU throttle rate is near zero after fix
echo "Checking CPU throttle rate..."
# TODO: ASSUMPTION - This check requires Prometheus to be port-forwarded or accessible
# If running this check in automation, you may need to adjust the query endpoint
# NOTE: container_cpu_cfs_throttled_seconds_total is cgroup v1-only and is not
# exported by cAdvisor on cgroup v2 hosts (e.g. k3d on a modern Docker host).
# Use the periods-based ratio instead, which is available on both cgroup versions.
# Prometheus port is 9090 + team number (Week 2 HOST_PORT 8083 -> 9093). PROM_URL overrides it.
if [ -z "$PROM_URL" ] && [ -f "$REPO_ROOT/week-2/.env" ]; then
    HOST_PORT=$(grep -E "^HOST_PORT=" "$REPO_ROOT/week-2/.env" | cut -d '=' -f2)
    PROM_URL="http://localhost:$(( ${HOST_PORT:-8080} + 1010 ))"
fi
PROM_URL="${PROM_URL:-http://localhost:9090}"
if command -v curl &> /dev/null; then
    THROTTLE_RATE=$(curl -sg "$PROM_URL/api/v1/query?query=rate(container_cpu_cfs_throttled_periods_total{container=\"flask\"}[5m])/rate(container_cpu_cfs_periods_total{container=\"flask\"}[5m])" \
        | python3 -c "import json,sys; d=json.load(sys.stdin); v=float(d['data']['result'][0]['value'][1]) if d['data']['result'] else 0; print(f'{v:.4f}')" 2>/dev/null || echo "ERROR")

    if [ "$THROTTLE_RATE" != "ERROR" ]; then
        if python3 -c "import sys; sys.exit(0 if float('$THROTTLE_RATE') < 0.01 else 1)"; then
            check_pass "CPU throttle rate: $THROTTLE_RATE (< 0.01 after fix)"
        else
            check_warn "CPU throttle rate: $THROTTLE_RATE (> 0.01; verify fix was applied)"
        fi
    else
        check_warn "Could not query Prometheus at $PROM_URL (is the Step 0a port-forward running?); skipping throttle check"
    fi
else
    check_warn "curl not found; skipping Prometheus query"
fi
echo ""

# Check 4: Verify k6 test files exist
echo "Checking k6 test scripts..."
if [ -f "$REPO_ROOT/week-9/smoke-test.js" ]; then
    check_pass "smoke-test.js exists"
else
    check_fail "smoke-test.js not found"
fi

if [ -f "$REPO_ROOT/week-9/ramped-test.js" ]; then
    check_pass "ramped-test.js exists"
else
    check_fail "ramped-test.js not found"
fi
echo ""

# Check 5: Verify runbook exists
echo "Checking runbook documentation..."
if [ -f "$REPO_ROOT/week-9/runbook.md" ]; then
    check_pass "runbook.md exists"
    # Check for required sections
    if grep -q "Incident 1.*CPU" "$REPO_ROOT/week-9/runbook.md"; then
        check_pass "Runbook includes Incident 1 (CPU throttling)"
    else
        check_warn "Incident 1 section not clearly titled in runbook"
    fi
    if grep -q "Incident 2.*Sequential" "$REPO_ROOT/week-9/runbook.md"; then
        check_pass "Runbook includes Incident 2 (sequential scan)"
    else
        check_warn "Incident 2 section not clearly titled in runbook"
    fi
else
    check_fail "runbook.md not found"
fi
echo ""

# Check 6: Verify the CPU limit is restored, both live and in infrastructure/flask.tf
# OpenTofu is not run on the shared VM: the live Deployment is changed with kubectl,
# and infrastructure/flask.tf must describe the same limit for the rebuild.
echo "Checking Flask CPU limit (live cluster and infrastructure/flask.tf)..."
LIVE_CPU=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null || true)
if [ "$LIVE_CPU" = "500m" ]; then
    check_pass "Live Flask Deployment CPU limit is 500m"
else
    check_fail "Live Flask Deployment CPU limit is '$LIVE_CPU', expected 500m (kubectl set resources deployment flask -c flask --limits=cpu=500m)"
fi
if [ -f "$REPO_ROOT/infrastructure/flask.tf" ]; then
    check_pass "infrastructure/flask.tf exists"
    if grep -q "cpu.*=.*\"500m\"" "$REPO_ROOT/infrastructure/flask.tf"; then
        check_pass "infrastructure/flask.tf sets a 500m CPU limit"
    else
        check_fail "infrastructure/flask.tf does not set cpu = \"500m\""
    fi
else
    check_fail "infrastructure/flask.tf not found"
fi
echo ""

# Check 7: Verify CI workflow has k6 gate
echo "Checking GitHub Actions CI gate..."
if [ -f "$REPO_ROOT/.github/workflows/ci.yml" ]; then
    check_pass ".github/workflows/ci.yml exists"
    if grep -q "load-test-gate\|k6 run" "$REPO_ROOT/.github/workflows/ci.yml"; then
        check_pass "CI workflow includes k6 threshold gate"
    else
        check_warn "k6 gate not found in CI workflow; verify manually"
    fi
else
    check_fail ".github/workflows/ci.yml not found"
fi
echo ""

# Check 8: Verify role-artifact files exist
echo "Checking role artifact files..."
for file in docs/sprint-5-retrospective.md docs/qa-report-5.md; do
    if [ -f "$REPO_ROOT/$file" ]; then
        check_pass "$file exists"
    else
        check_fail "$file not found"
    fi
done
echo ""

# Check 9: pg_stat_statements is loaded at startup
echo "Checking pg_stat_statements..."
PRELOAD=$(kubectl exec deploy/db -- psql -U appuser -d statustracker -t -A -c "SHOW shared_preload_libraries;" 2>/dev/null || true)
if echo "$PRELOAD" | grep -q "pg_stat_statements"; then
    check_pass "pg_stat_statements is loaded (shared_preload_libraries)"
else
    check_fail "pg_stat_statements is not loaded - see Step 12a"
fi
echo ""

echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. See above for details.${NC}"
    exit 1
fi
