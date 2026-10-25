#!/bin/bash

# Week 6 Validation Script
# This script runs all acceptance checks for Week 6 deliverables
# Run from the repository root: ./scripts/check-week6.sh

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
echo "Week 6 Validation Checks"
echo "========================================="
echo ""

# =========================================
# Check 1: Workflow Files Exist
# =========================================
echo "Check 1: Workflow Files Exist"
echo "---------------------------------"

if [ -f "$REPO_ROOT/.github/workflows/ci.yml" ]; then
    check_pass ".github/workflows/ci.yml exists"
else
    check_fail ".github/workflows/ci.yml not found"
fi

if [ -f "$REPO_ROOT/.github/workflows/scheduled-maintenance.yml" ]; then
    check_pass ".github/workflows/scheduled-maintenance.yml exists"
else
    check_fail ".github/workflows/scheduled-maintenance.yml not found"
fi

# =========================================
# Check 2: Workflow YAML Is Well-Formed
# =========================================
echo ""
echo "Check 2: Workflow YAML Is Well-Formed"
echo "------------------------------------------"

if command -v python3 &> /dev/null && python3 -c "import yaml" &> /dev/null; then
    for f in ci.yml scheduled-maintenance.yml; do
        if [ -f "$REPO_ROOT/.github/workflows/$f" ]; then
            if python3 -c "import yaml; yaml.safe_load(open('$REPO_ROOT/.github/workflows/$f'))" 2>/dev/null; then
                check_pass "$f is valid YAML"
            else
                check_fail "$f is not valid YAML"
            fi
        fi
    done
else
    check_warn "YAML validation skipped (requires python3 with PyYAML)"
fi

# =========================================
# Check 3: CI Triggers
# =========================================
echo ""
echo "Check 3: CI Triggers"
echo "------------------------"

if grep -q "push:" "$REPO_ROOT/.github/workflows/ci.yml" 2>/dev/null && grep -q "pull_request:" "$REPO_ROOT/.github/workflows/ci.yml" 2>/dev/null; then
    check_pass "ci.yml has push and pull_request triggers"
else
    check_fail "ci.yml is missing push and/or pull_request triggers"
fi

# =========================================
# Check 4: Scheduled Maintenance Cron Trigger
# =========================================
echo ""
echo "Check 4: Scheduled Maintenance Cron Trigger"
echo "------------------------------------------------"

if grep -q "cron:" "$REPO_ROOT/.github/workflows/scheduled-maintenance.yml" 2>/dev/null; then
    check_pass "scheduled-maintenance.yml has a cron trigger"
else
    check_fail "scheduled-maintenance.yml is missing a cron trigger"
fi

# =========================================
# Manual Checks Reminder
# =========================================
echo ""
echo "Check 5: Manual GitHub UI Checks (not automatable from this container)"
echo "----------------------------------------------------------------------------"

check_warn "CI workflow run passing on main - verify in the Actions tab"
check_warn "Branch protection rule requiring CI to pass before merge - verify in Settings > Branches"
check_warn "Scheduled Maintenance workflow completing successfully - verify in the Actions tab"

# =========================================
# Summary
# =========================================
echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Status: ALL AUTOMATABLE CHECKS PASSED${NC} - confirm the manual GitHub checks above before submitting."
    exit 0
else
    echo -e "${RED}Status: SOME CHECKS FAILED - Review errors above${NC}"
    exit 1
fi
