#!/bin/bash

# Week 3 Validation Script
# This script runs all acceptance checks for Week 3 deliverables
# Run from the repository root: ./scripts/check-week3.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

# k3d/kubectl are typically installed to /usr/local/bin; make sure it's on
# PATH regardless of how this script is invoked (e.g. under sudo, where
# root's PATH may not include it).
export PATH="/usr/local/bin:$PATH"

# k3d writes its kubeconfig under the home directory of whichever user ran
# `k3d cluster create` (your normal user, not root). If this script is run
# with sudo, point kubectl back at that config instead of root's.
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
if [ -f "$REAL_HOME/.kube/config" ]; then
    export KUBECONFIG="$REAL_HOME/.kube/config"
fi

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track pass/fail status
PASS_COUNT=0
FAIL_COUNT=0

# Helper function to print results
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

echo "========================================="
echo "Week 3 Validation Checks"
echo "========================================="
echo ""

# =========================================
# Check 1: k3d Cluster Is Running
# =========================================
echo ""
echo "Check 1: k3d Cluster Is Running"
echo "---------------------------------"

if command -v k3d &> /dev/null; then
    check_pass "k3d is installed"
else
    check_fail "k3d is not installed"
fi

if k3d cluster list 2>&1 | grep -q "^myapp"; then
    check_pass "k3d cluster 'myapp' exists"
else
    check_fail "k3d cluster 'myapp' not found"
fi

NODE_COUNT=$(kubectl get nodes 2>/dev/null | grep -c "Ready" || echo "0")
if [ "$NODE_COUNT" -eq 3 ]; then
    check_pass "k3d cluster has exactly 3 Ready nodes"
else
    check_fail "k3d cluster does not have 3 Ready nodes (found: $NODE_COUNT)"
fi

# =========================================
# Check 2: All Pods Running
# =========================================
echo ""
echo "Check 2: All Pods Running"
echo "-------------------------"

POD_STATUS=$(kubectl get pods 2>/dev/null | grep -v "NAME" || echo "")

if [ -z "$POD_STATUS" ]; then
    check_warn "No pods found - deployment may not have started yet"
else
    RUNNING_PODS=$(echo "$POD_STATUS" | grep -c "Running" || echo "0")
    TOTAL_PODS=$(echo "$POD_STATUS" | wc -l)

    if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
        check_pass "All pods are in Running state"
    else
        check_fail "Not all pods are Running (Running: $RUNNING_PODS / Total: $TOTAL_PODS)"
        echo "Pod Status:"
        kubectl get pods
    fi

    READY_PODS=$(echo "$POD_STATUS" | grep -c "1/1" || echo "0")
    if [ "$READY_PODS" -gt 0 ]; then
        check_pass "$READY_PODS pods report 1/1 Ready"
    else
        check_warn "No pods report 1/1 Ready - check pod status"
    fi
fi

# =========================================
# Check 3: Credentials in Secrets, Not Deployments
# =========================================
echo ""
echo "Check 3: Credentials in Secrets, Not Deployments"
echo "------------------------------------------------"

if kubectl get secret flask-credentials &>/dev/null; then
    check_pass "Secret 'flask-credentials' exists"
else
    check_fail "Secret 'flask-credentials' not found"
fi

if kubectl get secret db-credentials &>/dev/null; then
    check_pass "Secret 'db-credentials' exists"
else
    check_fail "Secret 'db-credentials' not found"
fi

FLASK_ENV=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].env}' 2>/dev/null || echo "")
if [ -z "$FLASK_ENV" ] || [ "$FLASK_ENV" = "[]" ]; then
    check_pass "Flask Deployment does not have inline env vars (using envFrom/secretRef)"
else
    check_fail "Flask Deployment contains inline env vars - use envFrom/secretRef instead"
fi

DB_ENV=$(kubectl get deployment db -o jsonpath='{.spec.template.spec.containers[0].env}' 2>/dev/null || echo "")
if [ -z "$DB_ENV" ] || [ "$DB_ENV" = "[]" ]; then
    check_pass "Postgres Deployment does not have inline env vars (using envFrom/secretRef)"
else
    check_fail "Postgres Deployment contains inline env vars - use envFrom/secretRef instead"
fi

# =========================================
# Check 4: RollingUpdate Strategy Applied
# =========================================
echo ""
echo "Check 4: RollingUpdate Strategy Applied"
echo "----------------------------------------"

DB_STRATEGY=$(kubectl get deployment db -o jsonpath='{.spec.strategy.type}' 2>/dev/null || echo "")
if [ "$DB_STRATEGY" = "RollingUpdate" ]; then
    check_pass "Postgres Deployment uses RollingUpdate strategy"
else
    check_fail "Postgres Deployment does not use RollingUpdate (current: $DB_STRATEGY)"
fi

DB_SURGE=$(kubectl get deployment db -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null || echo "")
DB_UNAVAIL=$(kubectl get deployment db -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null || echo "")

if [ -n "$DB_SURGE" ] && [ -n "$DB_UNAVAIL" ]; then
    check_pass "Postgres Deployment has RollingUpdate parameters (maxSurge: $DB_SURGE, maxUnavailable: $DB_UNAVAIL)"
else
    check_warn "Postgres Deployment RollingUpdate parameters not fully configured"
fi

# =========================================
# Check 5: Application Health Check
# =========================================
echo ""
echo "Check 5: Application Health Check"
echo "-----------------------------------"

if command -v curl &> /dev/null; then
    # Kubernetes port is the team's Week 2 HOST_PORT + 10 (e.g. 8083 -> 8093)
    if [ -f "$REPO_ROOT/week-2/.env" ]; then
        HOST_PORT=$(grep -E "^HOST_PORT=" "$REPO_ROOT/week-2/.env" | cut -d '=' -f2)
    fi
    KUBE_PORT=$(( ${HOST_PORT:-8071} + 10 ))

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${KUBE_PORT}/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        check_pass "Application responds to health check at http://localhost:${KUBE_PORT}/health (HTTP $HTTP_CODE)"
    else
        check_warn "Application not responding to health check at http://localhost:${KUBE_PORT}/health (HTTP $HTTP_CODE) - may still be starting, or HOST_PORT in week-2/.env doesn't match your assigned port"
    fi
else
    check_warn "curl not available - skipping health check"
fi

# =========================================
# Check 6: Ansible k3d-setup Role
# =========================================
echo ""
echo "Check 6: Ansible k3d-setup Role"
echo "--------------------------------"

if [ -f "$REPO_ROOT/ansible/roles/k3d-setup/tasks/main.yml" ]; then
    check_pass "ansible/roles/k3d-setup/tasks/main.yml exists"
else
    check_fail "ansible/roles/k3d-setup/tasks/main.yml not found"
fi

if grep -q "k3d-setup" "$REPO_ROOT/ansible/site.yml" 2>/dev/null; then
    check_pass "ansible/site.yml includes k3d-setup role"
else
    check_fail "ansible/site.yml does not include k3d-setup role"
fi

# =========================================
# Check 7: Manifests Committed
# =========================================
echo ""
echo "Check 7: Manifests Directory"
echo "-----------------------------"

if [ -d "$REPO_ROOT/manifests" ]; then
    check_pass "manifests/ directory exists"

    MANIFEST_FILES=$(find "$REPO_ROOT/manifests" \( -name "*.yaml" -o -name "*.yml" \) | wc -l)
    if [ "$MANIFEST_FILES" -gt 0 ]; then
        check_pass "Found $MANIFEST_FILES YAML manifest files"
    else
        check_warn "No YAML files found in manifests/ directory"
    fi

    if [ -f "$REPO_ROOT/manifests/flask-secret.yaml" ]; then
        check_pass "Flask Secret manifest found (flask-secret.yaml)"
    else
        check_fail "Flask Secret manifest not found (expected manifests/flask-secret.yaml)"
    fi

    if [ -f "$REPO_ROOT/manifests/db-secret.yaml" ]; then
        check_pass "Postgres Secret manifest found (db-secret.yaml)"
    else
        check_fail "Postgres Secret manifest not found (expected manifests/db-secret.yaml)"
    fi

    if grep -q "io.kompose.service" "$REPO_ROOT"/manifests/*.yaml 2>/dev/null; then
        check_fail "Some manifests still use io.kompose.service labels instead of app:"
    else
        check_pass "No io.kompose.service labels remain in manifests/"
    fi

    if grep -q "^          image: flask$" "$REPO_ROOT/manifests/flask-deployment.yaml" 2>/dev/null; then
        check_fail "flask-deployment.yaml still uses the kompose placeholder image (image: flask)"
    else
        check_pass "flask-deployment.yaml image reference has been fixed"
    fi

    if grep -q "type: LoadBalancer" "$REPO_ROOT/manifests/nginx-service.yaml" 2>/dev/null; then
        check_pass "nginx-service.yaml is exposed as a LoadBalancer"
    else
        check_fail "nginx-service.yaml is not type: LoadBalancer (traffic won't reach the cluster)"
    fi
else
    check_fail "manifests/ directory not found"
fi

# =========================================
# Summary
# =========================================
echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo "Warnings: (see above)"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Status: ALL CHECKS PASSED${NC}"
    exit 0
else
    echo -e "${RED}Status: SOME CHECKS FAILED - Review errors above${NC}"
    exit 1
fi
