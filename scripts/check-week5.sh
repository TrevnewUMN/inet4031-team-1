#!/bin/bash

# check-week5.sh - Validation script for Week 5: Observability and Monitoring
#
# PATCHED BY QA SOLVE PASS (see _orchestration/solve-log-week-05.md): this file was
# originally placed at "Student Repositories/scripts/check-week5.sh" (one directory
# too high -- outside week-05/ entirely) instead of "Student Repositories/week-05/scripts/
# check-week5.sh". Every other week's check script lives inside that week's own
# directory; Week 5 did not, which would break `./scripts/check-week5.sh` when run from
# a repo assembled the way every other week expects. This is a corrected copy placed at
# the path students actually need. The original misplaced copy at the repo-root
# `scripts/` directory should be removed by the instructor/build process; this QA pass
# does not delete files, only authors corrected ones.
#
# This script verifies that all required components are deployed and configured correctly

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

echo "========================================="
echo "Week 5 Validation Script"
echo "Observability and Monitoring"
echo "========================================="
echo ""

check_status() {
    local check_name=$1
    local result=$2

    if [ $result -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} $check_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $check_name"
        FAILED=$((FAILED + 1))
    fi
}

echo "Checking Helm installation..."
if command -v helm &> /dev/null; then
    HELM_VERSION=$(helm version --short 2>/dev/null || echo "")
    if [[ $HELM_VERSION == *"v3"* || $HELM_VERSION == *"v4"* ]]; then
        check_status "Helm installed" 0
    else
        check_status "Helm installed" 1
    fi
else
    check_status "Helm installed" 1
fi
echo ""

echo "Checking Prometheus community repository..."
if helm repo list 2>/dev/null | grep -q "prometheus-community"; then
    check_status "Prometheus community repository added" 0
else
    check_status "Prometheus community repository added" 1
fi
echo ""

echo "Checking monitoring namespace..."
if kubectl get namespace monitoring &>/dev/null; then
    check_status "Monitoring namespace exists" 0
else
    check_status "Monitoring namespace exists" 1
fi
echo ""

echo "Checking monitoring pods status..."
TOTAL_PODS=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | wc -l || echo "0")
NOT_READY=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -vE "Running|Completed" | wc -l || echo "0")
if [ "$TOTAL_PODS" -gt 0 ] && [ "$NOT_READY" -eq 0 ]; then
    check_status "All monitoring pods running" 0
else
    check_status "All monitoring pods running" 1
fi
echo ""

echo "Checking Prometheus scrape and alert configuration..."
PROM_CONFIG=$(kubectl get configmap prometheus-server -n monitoring -o yaml 2>/dev/null || echo "")
if echo "$PROM_CONFIG" | grep -q "kubernetes-nodes-cadvisor"; then
    check_status "cAdvisor scrape job configured" 0
else
    check_status "cAdvisor scrape job configured" 1
fi
if echo "$PROM_CONFIG" | grep -q "HTTP5xxErrorRateHigh"; then
    check_status "HTTP5xxErrorRateHigh alert rule configured" 0
else
    check_status "HTTP5xxErrorRateHigh alert rule configured" 1
fi
echo ""

echo "Checking Prometheus metric availability (MANDATORY)..."
# Prometheus port is 9090 + team number (Week 2 HOST_PORT 8083 -> 9093). PROM_URL overrides it.
if [ -z "$PROM_URL" ] && [ -f "week-2/.env" ]; then
    HOST_PORT=$(grep -E "^HOST_PORT=" week-2/.env | cut -d '=' -f2)
    PROM_URL="http://localhost:$(( ${HOST_PORT:-8080} + 1010 ))"
fi
PROM_URL="${PROM_URL:-http://localhost:9090}"
if command -v curl &> /dev/null && command -v python3 &> /dev/null; then
    QUERY_RESULT=$(curl -s "$PROM_URL/api/v1/query?query=container_cpu_cfs_throttled_periods_total" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print('PASS') if d.get('data',{}).get('result') else print('FAIL')" 2>/dev/null || echo "SKIP")

    if [ "$QUERY_RESULT" = "PASS" ]; then
        check_status "container_cpu_cfs_throttled_periods_total returns data (MANDATORY)" 0
    elif [ "$QUERY_RESULT" = "SKIP" ]; then
        echo -e "${YELLOW}[SKIP]${NC} container_cpu_cfs_throttled_periods_total (requires port-forward to $PROM_URL)"
    else
        check_status "container_cpu_cfs_throttled_periods_total returns data (MANDATORY)" 1
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} container_cpu_cfs_throttled_periods_total (requires curl and python3)"
fi
echo ""

echo "Checking configuration files..."
if [ -f "week-5/prometheus-values.yaml" ]; then
    check_status "prometheus-values.yaml exists" 0
else
    check_status "prometheus-values.yaml exists" 1
fi
echo ""

echo "Checking load testing files..."
if [ -f "week-5/smoke-test.js" ]; then
    check_status "smoke-test.js exists" 0
else
    check_status "smoke-test.js exists" 1
fi
echo ""

echo "Checking k6 installation..."
if command -v k6 &> /dev/null; then
    check_status "k6 installed" 0
else
    check_status "k6 installed" 1
fi
echo ""

echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed. Review above for details.${NC}"
    exit 1
fi
