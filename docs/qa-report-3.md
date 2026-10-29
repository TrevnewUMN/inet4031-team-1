# QA Report: Sprint 3 Week 6

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

---

## Validation Checks

### Check 1: CI Workflow Passes on main

**Test:** Navigate to the Actions tab. Check the most recent run on `main`.

**Expected:** Green checkmark -- CI workflow completed successfully.

**Actual Result:**
```
TODO: Paste the run status/link
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If it failed, what did the run's error output show?

---

### Check 2: Branch Protection Configured

**Test:** Navigate to Settings > Branches and inspect the `main` rule.

**Expected:** Rule exists, requires the `build-and-push` status check, requires a PR before merging, requires branches to be up to date.

**Actual Result:**
```
TODO: Paste or describe the rule's configuration
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Was anything missing from the rule?

---

### Check 3: Scheduled Workflow Runs Successfully

**Test:** In the Actions tab, manually trigger "Scheduled Maintenance" (`workflow_dispatch`).

**Expected:** Workflow shows a green checkmark on completion.

**Actual Result:**
```
TODO: Paste the run status/link
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If it failed, was the failure in the Trivy scan step or elsewhere?

---

### Check 4: Check Script Passes

**Test:** Run `./scripts/check-week6.sh`

**Expected:** All automatable checks pass with exit code 0

**Actual Result:**
```
TODO: Paste the full output of the check script
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** This script only checks what's verifiable from inside the container (workflow files exist, are valid YAML, have the right triggers). It cannot check CI passing on main, branch protection, or the scheduled workflow's own run history -- those three still need manual confirmation in the GitHub UI per Checks 1-3 above.

---

## Acceptance Criteria Verification

Review the criteria below for each part of this week's deliverables. For each criterion, record whether it was met:

### Part 1: CI Pipeline for Docker Build and Push

TODO: [ ] `.github/workflows/ci.yml` created and committed
TODO: [ ] Workflow triggers on `push` to main, `pull_request` to main, and `workflow_dispatch`
TODO: [ ] Logs in to `ghcr.io` using `GITHUB_TOKEN` (no personal access token needed)
TODO: [ ] Image tagged via `docker/metadata-action` (sha, branch ref, and `latest` on main)
TODO: [ ] Push step conditional on not being a `pull_request` event (PRs build but don't push)
TODO: [ ] First workflow run after push completed successfully

### Part 2: Workflow Secrets and Branch Protection

TODO: [ ] `SLACK_WEBHOOK_URL` secret created under Settings > Secrets and variables > Actions
TODO: [ ] Branch protection rule added on `main` requiring the `build-and-push` status check
TODO: [ ] "Require branches to be up to date before merging" enabled
TODO: [ ] `test/failing-build` branch created with an intentional Dockerfile syntax error
TODO: [ ] PR from `test/failing-build` showed the merge button disabled while CI failed (screenshot captured)
TODO: [ ] Dockerfile fixed, CI re-ran and passed, PR merged, test branch deleted (screenshot captured)

### Part 3: Scheduled Maintenance Workflow

TODO: [ ] `.github/workflows/scheduled-maintenance.yml` created and committed
TODO: [ ] Cron trigger set to `0 8 * * 1` (08:00 UTC every Monday), plus `workflow_dispatch` for manual runs
TODO: [ ] Job has `permissions: packages: read` and logs in to `ghcr.io` before scanning (the image is a private package -- Trivy needs credentials, not just a valid reference)
TODO: [ ] Image reference is lowercased before being passed to Trivy (`${{ github.repository }}` includes the org name as-cased on GitHub, which breaks reference parsing if it contains uppercase letters)
TODO: [ ] Manually triggered run completed successfully (screenshot captured)

---

## Deliverables Verification

### Required Files

TODO: [ ] `.github/workflows/ci.yml` is committed (build and push, manual trigger)
TODO: [ ] `.github/workflows/scheduled-maintenance.yml` is committed
TODO: [ ] `scripts/check-week6.sh` is present and runs clean

### GitHub Repository

TODO: [ ] Branch protection rule configured on `main`
TODO: [ ] `test/failing-build` branch deleted after merge
TODO: [ ] All changes pushed to the main branch

### Google Doc

TODO: [ ] Screenshot of failed CI blocking a merge is attached
TODO: [ ] Screenshot of passing CI after the fix is attached
TODO: [ ] Screenshot of the Scheduled Maintenance workflow run showing success is attached
TODO: [ ] Screenshot of `./scripts/check-week6.sh` passing is attached
TODO: [ ] Discussion answers recorded (CI trigger tradeoffs, secret masking limitations, branch protection bypass governance, cron vs. systemd timers)
TODO: [ ] Week 6 storage check values recorded (`df -h`, `docker system df`)

---

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
