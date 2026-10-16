#!/bin/bash

# Week 4 Validation Script
# This script runs the acceptance checks for Week 4 deliverables.
# It reads your OpenTofu and Ansible files and checks the health of your live
# cluster. It never runs tofu or ansible-playbook. Those run during the live
# rebuild, not this week.
# Run from the repository root: ./scripts/check-week4.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( dirname "$SCRIPT_DIR" )"

# kubectl/tofu are typically installed to /usr/local/bin; make sure it's on
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

MAIN_TF="$REPO_ROOT/infrastructure/main.tf"
FLASK_TF="$REPO_ROOT/infrastructure/flask.tf"
SITE_YML="$REPO_ROOT/ansible/site.yml"
ROLE_TASKS="$REPO_ROOT/ansible/roles/opentofu-setup/tasks/main.yml"

echo "========================================="
echo "Week 4 Validation Checks"
echo "========================================="
echo ""

# =========================================
# Check 1: Local Backend Is Explicit
# =========================================
echo "Check 1: Local Backend Is Explicit"
echo "-----------------------------------------"

if [ ! -f "$MAIN_TF" ]; then
    check_fail "File missing: infrastructure/main.tf"
else
    check_pass "File exists: infrastructure/main.tf"

    if grep -q 'backend "local"' "$MAIN_TF" && \
       grep -A2 'backend "local"' "$MAIN_TF" | grep -q 'terraform.tfstate'; then
        check_pass "infrastructure/main.tf has a local backend with path terraform.tfstate"
    else
        check_fail "infrastructure/main.tf is missing a local backend with path = terraform.tfstate"
    fi

    if grep -q 'required_providers' "$MAIN_TF" && grep -q 'kubernetes' "$MAIN_TF"; then
        check_pass "infrastructure/main.tf declares the kubernetes provider"
    else
        check_fail "infrastructure/main.tf does not declare the kubernetes provider"
    fi
fi

# =========================================
# Check 2: Flask Deployment Is Set to 3 Replicas
# =========================================
echo ""
echo "Check 2: Flask Deployment Is Set to 3 Replicas"
echo "-------------------------------------------------"

if [ ! -f "$FLASK_TF" ]; then
    check_fail "File missing: infrastructure/flask.tf"
else
    check_pass "File exists: infrastructure/flask.tf"

    if grep -q 'resource "kubernetes_deployment" "flask"' "$FLASK_TF"; then
        check_pass "flask.tf defines the flask Deployment"
    else
        check_fail "flask.tf does not define resource \"kubernetes_deployment\" \"flask\""
    fi

    if grep -q 'resource "kubernetes_service" "flask"' "$FLASK_TF"; then
        check_pass "flask.tf defines the flask Service"
    else
        check_fail "flask.tf does not define resource \"kubernetes_service\" \"flask\""
    fi

    if grep -q 'week-2-flask:latest' "$FLASK_TF" && grep -q 'IfNotPresent' "$FLASK_TF"; then
        check_pass "flask.tf uses week-2-flask:latest with image_pull_policy IfNotPresent"
    else
        check_fail "flask.tf must use image week-2-flask:latest with image_pull_policy = \"IfNotPresent\""
    fi

    if grep -Eq '^[[:space:]]*replicas[[:space:]]*=[[:space:]]*3([[:space:]]|$)' "$FLASK_TF"; then
        check_pass "flask.tf sets replicas = 3"
    else
        FOUND=$(grep -E '^[[:space:]]*replicas[[:space:]]*=' "$FLASK_TF" | head -1 | tr -s ' ' || true)
        check_fail "flask.tf does not set replicas = 3 (found: ${FOUND:-no replicas line})"
    fi
fi

# =========================================
# Check 3: Week 3 Flask Manifests Removed
# =========================================
echo ""
echo "Check 3: Week 3 Flask Manifests Removed"
echo "------------------------------------------"

for f in flask-deployment.yaml flask-service.yaml; do
    if [ -e "$REPO_ROOT/manifests/$f" ] || \
       git -C "$REPO_ROOT" cat-file -e "HEAD:manifests/$f" 2>/dev/null; then
        check_fail "manifests/$f still exists (run git rm and commit it)"
    else
        check_pass "manifests/$f is removed and committed"
    fi
done

if [ -f "$REPO_ROOT/manifests/flask-secret.yaml" ]; then
    check_pass "manifests/flask-secret.yaml is kept"
else
    check_fail "manifests/flask-secret.yaml is missing (flask.tf reads the flask-credentials Secret)"
fi

# =========================================
# Check 4: State and Working Files Ignored
# =========================================
echo ""
echo "Check 4: State and Working Files Ignored"
echo "-------------------------------------------"

for path in infrastructure/terraform.tfstate \
            infrastructure/terraform.tfstate.backup \
            infrastructure/.terraform/providers; do
    if git -C "$REPO_ROOT" check-ignore -q "$path"; then
        check_pass "$path is gitignored"
    else
        check_fail "$path is not gitignored"
    fi
done

# =========================================
# Check 5: Ansible Role Is in Place
# =========================================
echo ""
echo "Check 5: Ansible Role Is in Place"
echo "-------------------------------------"

if [ -f "$ROLE_TASKS" ]; then
    check_pass "File exists: ansible/roles/opentofu-setup/tasks/main.yml"

    if grep -q 'tofu init' "$ROLE_TASKS"; then
        check_pass "opentofu-setup role runs tofu init"
    else
        check_fail "opentofu-setup role does not run tofu init"
    fi
else
    check_fail "File missing: ansible/roles/opentofu-setup/tasks/main.yml"
fi

if grep -q "opentofu-setup" "$SITE_YML" 2>/dev/null; then
    check_pass "ansible/site.yml includes the opentofu-setup role"

    # Look at the play that lists the role and warn if it uses become.
    if command -v python3 &> /dev/null && python3 -c 'import yaml' 2> /dev/null; then
        PLAY_STATE=$(python3 - "$SITE_YML" <<'PYEOF' || echo "error"
import sys
import yaml

plays = yaml.safe_load(open(sys.argv[1])) or []
state = "missing"
for play in plays:
    roles = play.get("roles", []) or []
    names = [r if isinstance(r, str) else r.get("role", r.get("name")) for r in roles]
    if "opentofu-setup" in names:
        state = "become" if play.get("become") else "ok"
        break
print(state)
PYEOF
)
        case "$PLAY_STATE" in
            ok)
                check_pass "opentofu-setup play does not use become"
                ;;
            become)
                check_warn "opentofu-setup play uses become; tofu init would leave infrastructure/.terraform/ owned by root"
                ;;
            *)
                check_warn "could not inspect the opentofu-setup play in ansible/site.yml (check its YAML syntax)"
                ;;
        esac
    else
        check_warn "python3 with PyYAML not found; skipped the become check on the opentofu-setup play"
    fi
else
    check_fail "ansible/site.yml does not include the opentofu-setup role"
fi

if command -v tofu &> /dev/null; then
    check_pass "tofu is installed on this VM (instructor-provided)"
else
    check_warn "tofu is not installed on this VM; ask the instructor before the live rebuild"
fi

# =========================================
# Check 6: Live Cluster Is Still Healthy
# =========================================
echo ""
echo "Check 6: Live Cluster Is Still Healthy"
echo "-----------------------------------------"

if ! command -v kubectl &> /dev/null; then
    check_fail "kubectl is not installed or not on PATH"
elif ! kubectl get nodes &> /dev/null; then
    check_fail "kubectl cannot reach the cluster (is the k3d cluster running?)"
else
    if kubectl get deployment flask &> /dev/null; then
        check_pass "flask Deployment still exists in the live cluster"
    else
        check_fail "flask Deployment is missing from the live cluster (do not run kubectl delete this week)"
    fi

    FLASK_PODS=$(kubectl get pods -l app=flask --no-headers 2>/dev/null | wc -l)
    if [ "$FLASK_PODS" -ge 1 ]; then
        check_pass "Found $FLASK_PODS pod(s) labeled app=flask"
    else
        check_fail "No pods labeled app=flask were found"
    fi

    TOTAL_PODS=$(kubectl get pods --no-headers 2>/dev/null | wc -l)
    NOT_READY=$(kubectl get pods --no-headers 2>/dev/null | \
        awk '{ split($2, r, "/"); if ($3 != "Running" || r[1] != r[2]) print $1 " (" $2 ", " $3 ")" }')
    if [ "$TOTAL_PODS" -eq 0 ]; then
        check_fail "No pods found in the default namespace"
    elif [ -z "$NOT_READY" ]; then
        check_pass "All $TOTAL_PODS pods are Running and fully Ready"
    else
        check_fail "Pods not Running and Ready: $NOT_READY"
    fi
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
echo ""
echo "Not checked by this script (QA confirms in the Google Doc): the Prediction Log (P1 to P10)."
echo ""

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}Status: ALL CHECKS PASSED${NC}"
    exit 0
else
    echo -e "${RED}Status: SOME CHECKS FAILED - Review errors above${NC}"
    exit 1
fi
