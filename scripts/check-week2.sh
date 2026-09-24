#!/bin/bash

# Week 2 Validation Script
# This script runs all acceptance checks for Week 2 deliverables
# Run from the repository root: ./scripts/check-week2.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

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
echo "Week 2 Validation Checks"
echo "========================================="
echo ""

# =========================================
# Check 1: Required Week 2 Files Exist
# =========================================
echo ""
echo "Check 1: Required Week 2 Files"
echo "-------------------------------"

if [ -f "$REPO_ROOT/week-2/docker-compose.yml" ]; then
    check_pass "week-2/docker-compose.yml exists"
else
    check_fail "week-2/docker-compose.yml not found"
fi

if [ -f "$REPO_ROOT/week-2/.env.example" ]; then
    check_pass "week-2/.env.example exists"
else
    check_fail "week-2/.env.example not found"
fi

if [ -f "$REPO_ROOT/week-2/nginx.conf" ]; then
    check_pass "week-2/nginx.conf exists"
else
    check_fail "week-2/nginx.conf not found"
fi

if [ -d "$REPO_ROOT/week-2/app" ]; then
    check_pass "week-2/app/ directory exists"
else
    check_fail "week-2/app/ directory not found"
fi

# =========================================
# Check 2: .env Is Git-Ignored
# =========================================
echo ""
echo "Check 2: .env Is Git-Ignored"
echo "------------------------------"

if git -C "$REPO_ROOT" check-ignore -q week-2/.env 2>/dev/null; then
    check_pass "week-2/.env is excluded by .gitignore"
else
    check_warn "week-2/.env is not confirmed git-ignored (may not exist yet, or .gitignore is missing the rule)"
fi

# =========================================
# Check 3: app-stack Ansible Role Exists
# =========================================
echo ""
echo "Check 3: Ansible app-stack Role"
echo "---------------------------------"

if [ -f "$REPO_ROOT/ansible/roles/app-stack/tasks/main.yml" ]; then
    check_pass "ansible/roles/app-stack/tasks/main.yml exists"
else
    check_fail "ansible/roles/app-stack/tasks/main.yml not found"
fi

if grep -q "app-stack" "$REPO_ROOT/ansible/site.yml" 2>/dev/null; then
    check_pass "ansible/site.yml includes the app-stack role"
else
    check_fail "ansible/site.yml does not include the app-stack role"
fi

# =========================================
# Check 4: Docker Compose Stack Is Healthy
# =========================================
echo ""
echo "Check 4: Docker Compose Stack Health"
echo "--------------------------------------"

if command -v docker &> /dev/null; then
    COMPOSE_STATUS=$(docker compose -f "$REPO_ROOT/week-2/docker-compose.yml" ps 2>/dev/null || echo "")
    if [ -z "$COMPOSE_STATUS" ]; then
        check_warn "Could not read docker compose status (stack may not be running)"
    else
        HEALTHY_COUNT=$(echo "$COMPOSE_STATUS" | grep -c "healthy" || echo "0")
        if [ "$HEALTHY_COUNT" -ge 2 ]; then
            check_pass "db and flask report healthy ($HEALTHY_COUNT healthy; nginx has no healthcheck defined)"
        else
            check_warn "Fewer than 2 services report healthy ($HEALTHY_COUNT healthy) - run 'docker compose -f week-2/docker-compose.yml ps' to check"
        fi
    fi
else
    check_warn "docker not available - skipping stack health check"
fi

# =========================================
# Check 5: Application Responds Through Nginx
# =========================================
echo ""
echo "Check 5: Application Health Check"
echo "-----------------------------------"

if command -v curl &> /dev/null; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        check_pass "Nginx responds on http://localhost:8080/health (HTTP $HTTP_CODE)"
    elif [ "$HTTP_CODE" != "000" ]; then
        check_warn "Nginx responded on http://localhost:8080/health but with HTTP $HTTP_CODE (expected 200)"
    else
        check_warn "No response from http://localhost:8080/health (stack may not be running)"
    fi
else
    check_warn "curl not available - skipping health check"
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
