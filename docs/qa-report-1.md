# QA Report: Sprint 1 Week 2

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

---

## Validation Checks

### Check 1: All Three Services Are Running and Two Of Them Show Healthy

**Test:** Run `docker compose ps` from the `week-2/` directory

**Expected:** Three rows, each with "running" in the Status column

**Actual Result:**
```
TODO: Paste the actual output of docker compose ps
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If any service shows "starting" or "exited", what did the logs reveal?

---

### Check 2: Nginx Is Reachable on the Mapped Port

**Test:** Run `curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health`

**Expected:** HTTP 200

**Actual Result:** TODO: Record the status code

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If the request failed, what error message did you see?

---

### Check 3: Data Persists Across Container Restart

**Test:** Create a test incident, restart the PostgreSQL container, retrieve all incidents

**Steps Performed:**
```
TODO: Paste the commands you ran
```

**Actual Result:**
```
TODO: Paste the output showing the incident was retrieved after restart
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Was data present after the restart? Was anything lost?

---

### Check 4: Ansible Playbook Runs Clean

**Test:** Run `ansible-playbook -i ansible/inventory ansible/site.yml`

**Expected:** PLAY RECAP shows `failed=0` and `unreachable=0` for both plays

**Actual Result:**
```
TODO: Paste the PLAY RECAP section from the second run
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Did both plays (baseline and app-stack) complete? Any warnings or skipped tasks?

---

### Check 5: Check Script Passes

**Test:** Run `chmod +x scripts/check-week2.sh` then `./scripts/check-week2.sh`

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

### Part 1: Service Definition

TODO: [ ] All three services start in correct order
TODO: [ ] Health checks work as specified

### Part 2: Networking and Persistence

TODO: [ ] Data persists across `docker compose restart`
TODO: [ ] Data is lost after `docker compose down -v`

### Part 3: Environment and Ansible

TODO: [ ] `.env` is in `.gitignore`
TODO: [ ] `.env.example` documents all variables
TODO: [ ] Ansible playbook brings up stack without error
TODO: [ ] Playbook is idempotent

---

## Deliverables Verification

### Required Files

TODO: [ ] `week-2/docker-compose.yml` is committed
TODO: [ ] `week-2/.env.example` is committed
TODO: [ ] `week-2/nginx.conf` is committed
TODO: [ ] `week-2/README.md` is committed
TODO: [ ] `ansible/site.yml` includes app-stack role play
TODO: [ ] `ansible/roles/app-stack/tasks/main.yml` is committed
TODO: [ ] `.gitignore` excludes `week-2/.env`

### GitHub Repository

TODO: [ ] All changes are pushed to the main branch
TODO: [ ] GitHub Project board shows all tasks completed
TODO: [ ] PR descriptions explain implementation decisions

### Google Doc

TODO: [ ] Sprint 1 Week 2 reflection answers are recorded
TODO: [ ] Week 2 storage check values are recorded
TODO: [ ] Required screenshots are attached

---

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** _________________    **Date:** __________

---

## Notes for Sprint 2

[Any observations or recommendations for the next sprint]
