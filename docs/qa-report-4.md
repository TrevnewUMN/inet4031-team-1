# QA Report: Sprint 4 Week 7

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

---

## Validation Checks

### Check 1: Flask Uses Custom ServiceAccount

**Test:** Run `kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}'`

**Expected:** `flask-app`

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If this doesn't match, was the ServiceAccount change applied through `tofu apply` rather than a direct `kubectl edit`?

---

### Check 2: NetworkPolicy Applied

**Test:** Run `kubectl get networkpolicy`

**Expected:** Rows for `default-deny-ingress`, `allow-nginx-to-flask`, `allow-flask-to-postgres`, and `allow-ingress-to-nginx`

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** All four are required -- `allow-ingress-to-nginx` is easy to miss since it's not part of the original three-policy set, but without it `default-deny-ingress` blocks all external traffic into nginx too.

---

### Check 3: Application Works After NetworkPolicy

**Test:** Run `curl -s http://localhost:8081/incidents`

**Expected:** Valid JSON response

**Actual Result:**
```
TODO: Paste the actual response
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If this fails while Check 2 passes, check whether `allow-flask-to-postgres` actually selects `app: db` (the real label on the db Deployment) -- a mismatched label here silently blocks flask from reaching the database.

---

### Check 4: SecurityContext Is Set

**Test:** Run `kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}'`

**Expected:** `false`

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Also confirm `readOnlyRootFilesystem`, `runAsNonRoot`, and `capabilities.drop: [ALL]` are set -- this check only verifies one of the four SecurityContext fields Step 12 adds.

---

### Check 5: OpenTofu State Matches the Cluster (No Drift)

**Test:** Run `cd infrastructure && tofu plan`

**Expected:** `No changes. Your infrastructure matches the configuration.`

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Drift here almost always means a change was applied with `kubectl apply`/`kubectl edit` instead of `tofu apply`.

---

### Check 6: Check Script Passes

**Test:** Run `chmod +x ./scripts/check-week7.sh` then `./scripts/check-week7.sh`

**Expected:** All checks pass with exit code 0

**Actual Result:**
```
TODO: Paste the full output of the check script
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If any checks failed, what did the script report?

---

## Acceptance Criteria Verification

Review the criteria below for each part of this week's deliverables. For each criterion, record whether it was met:

### Part 1: Kubernetes RBAC

TODO: [ ] `manifests/flask-serviceaccount.yaml` created with `automountServiceAccountToken: false`
TODO: [ ] `manifests/flask-role.yaml` created with least-privilege rules (configmaps get/list only)
TODO: [ ] `manifests/flask-rolebinding.yaml` created, binding the Role to the `flask-app` ServiceAccount
TODO: [ ] `infrastructure/flask.tf` updated with `service_account_name = "flask-app"`, applied via `tofu apply` (not `kubectl apply -f manifests/flask-deployment.yaml`, which OpenTofu no longer manages)

### Part 2: NetworkPolicy

TODO: [ ] `manifests/default-deny.yaml` created and applied; Step 8's debug-pod test actually timed out (not "connection refused" or immediate success)
TODO: [ ] `manifests/allow-nginx-to-flask.yaml` created (`app: flask` selector, allows from `app: nginx` on port 5000)
TODO: [ ] `manifests/allow-flask-to-postgres.yaml` created (`app: db` selector -- not `app: postgres`, which matches no real pods)
TODO: [ ] `manifests/allow-ingress-to-nginx.yaml` created (`app: nginx` selector, allows port 80 from any source)
TODO: [ ] All four policies applied; `curl http://localhost:8081/incidents` returns valid JSON end to end

### Part 3: SecurityContext

TODO: [ ] `infrastructure/flask.tf` container block gained `security_context` (allow_privilege_escalation=false, read_only_root_filesystem=true, run_as_non_root=true, run_as_user=1000, capabilities.drop=[ALL])
TODO: [ ] Applied via `tofu apply`; flask pods restarted and came back healthy
TODO: [ ] If pods failed on a read-only-filesystem write, the fix (e.g. an `emptyDir` mount) is documented

### Part 4: Image Vulnerability Scanning in CI

TODO: [ ] `.github/workflows/ci.yml` updated with a `security-scan` job running `aquasecurity/trivy-action`
TODO: [ ] Job authenticates to `ghcr.io` before scanning and lowercases the image reference (both required -- the image is a private package, and `${{ github.repository }}` includes the org name uncased)
TODO: [ ] Workflow run observed in the Actions tab; Trivy's log output captured regardless of pass/fail -- `exit-code: '1'` means a red X from real CRITICAL findings (e.g. unpatched base-image OS packages) is an expected, valid outcome, not a bug to chase

---

## Deliverables Verification

### Required Files

TODO: [ ] `manifests/flask-serviceaccount.yaml`, `flask-role.yaml`, `flask-rolebinding.yaml` committed
TODO: [ ] `manifests/default-deny.yaml`, `allow-nginx-to-flask.yaml`, `allow-flask-to-postgres.yaml`, `allow-ingress-to-nginx.yaml` committed
TODO: [ ] `infrastructure/flask.tf` updated with `service_account_name` and `security_context`
TODO: [ ] `.github/workflows/ci.yml` updated with the `security-scan` job
TODO: [ ] `scripts/check-week7.sh` present and runs clean

### GitHub Repository

TODO: [ ] All changes pushed to the main branch
TODO: [ ] `tofu plan` shows no drift at time of push

### Google Doc

TODO: [ ] Screenshot of the Step 8 connection timeout is attached
TODO: [ ] Screenshot of the application responding successfully after all NetworkPolicies applied is attached
TODO: [ ] Trivy scan log/result from GitHub Actions is attached (pass or fail)
TODO: [ ] Screenshot of `./scripts/check-week7.sh` passing is attached
TODO: [ ] Discussion answers recorded for Parts 1-4 (RBAC attack surface, NetworkPolicy enforcement verification and remaining attack paths, read-only-filesystem tradeoffs, scan-stage tradeoffs)

---

## Rework Required

If any validation checks or acceptance criteria failed, document the rework needed:

**Issues Found:**
```
TODO: List any failures here
```

**Rework Plan:**
```
TODO: For each failure, describe the steps to fix it and who will do the work
```

**Re-validation Date:** TODO: When will rework be complete?

---

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** _________________    **Date:** __________

---

## Notes for Sprint 5

[Any observations or recommendations for the next sprint]
