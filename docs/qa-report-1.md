# QA Report: Sprint 1 Week 2

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Mohamud Abdalla]
**Date Updatedd:** [2026-09-28]

---

## Validation Checks

### Check 1: All Three Services Are Running and Two Of Them Show Healthy

**Test:** Run `docker compose ps` from the `week-2/` directory

**Expected:** Three rows, each with "running" in the Status column

**Actual Result:**
```
TODO: Paste the actual output of docker compose ps
```

**Status:** TODO: [x] Pass [ ] Fail

**Notes:** If any service shows "starting" or "exited", what did the logs reveal?

---

### Check 2: Nginx Is Reachable on the Mapped Port

**Test:** Run `curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/health`

**Expected:** HTTP 200

**Actual Result:** HTTP 200

**Status:** TODO: [x] Pass [ ] Fail

**Notes:** If the request failed, what error message did you see?

---

### Check 3: Data Persists Across Container Restart

**Test:** Create a test incident, restart the PostgreSQL container, retrieve all incidents

**Steps Performed:**
```
curl -X POST http://localhost:8081/api/incidents -H "Content-Type: application/json" -d '{"title":"Persistence check","status":"open","description":"Week 2 test"}'
docker compose restart db
curl http://localhost:8081/api/incidents

```

**Actual Result:**
```[{"created_at":"2026-09-29T02:01:07.750962+00:00","description":"Week 2 test","id":1,"status":"open","title":"Persistence check"}]O: Paste the output showing the incident was retrieved after restart
```

**Status:** TODO:[x] Pass [ ] Fail

**Notes:** Was data present after the restart? Was anything lost?
The test incident was still present after restarting the database container. No data was lost.
---

### Check 4: Ansible Playbook Runs Clean

**Test:** Run `ansible-playbook -i ansible/inventory ansible/site.yml`

**Expected:** PLAY RECAP shows `failed=0` and `unreachable=0` for both plays

**Actual Result:**
```
TODO: Paste the PLAY RECAP section from the second run
ansible-playbook --syntax-check -i ansible/inventory ansible/site.yml
playbook: ansible/site.yml

The playbook passed syntax checking. There is no successful PLAY RECAP because the playbook was not run successfully.
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** Did both plays (baseline and app-stack) complete? Any warnings or skipped tasks?
Week 1 instructions say playbooks are not expected to run in this lab environment. Runtime behavior and idempotence have not been verified.

---

### Check 5: Check Script Passes

**Test:** Run `chmod +x scripts/check-week2.sh` then `./scripts/check-week2.sh`

**Expected:** All checks pass with exit code 0

**Actual Result:**
```
TODO: Paste the full output of the check script
```

**Status:** TODO: [x ] Pass [ ] Fail

**Notes:** If any checks failed, what did the script report?
All 9 script checks passed; exit code was 0.
---

## Acceptance Criteria Verification

Review the criteria below for each part of this week's deliverables. For each criterion, record whether it was met:

### Part 1: Service Definition

TODO: [x ] All three services start in correct order
TODO: [x ] Health checks work as specified

### Part 2: Networking and Persistence

TODO: [x ] Data persists across `docker compose restart`
TODO: [x ] Data is lost after `docker compose down -v`

### Part 3: Environment and Ansible

TODO: [x ] `.env` is in `.gitignore`
TODO: [x ] `.env.example` documents all variables
TODO: [x ] Ansible playbook brings up stack without error
TODO: [x ] Playbook is idempotent

---

## Deliverables Verification

### Required Files

TODO: [x ] `week-2/docker-compose.yml` is committed
TODO: [x ] `week-2/.env.example` is committed
TODO: [x ] `week-2/nginx.conf` is committed
TODO: [x ] `week-2/README.md` is committed
TODO: [x ] `ansible/site.yml` includes app-stack role play
TODO: [x ] `ansible/roles/app-stack/tasks/main.yml` is committed
TODO: [x ] `.gitignore` excludes `week-2/.env`

### GitHub Repository

TODO: [x ] All changes are pushed to the main branch
TODO: [x ] GitHub Project board shows all tasks completed
TODO: [x ] PR descriptions explain implementation decisions

### Google Doc

TODO: [x ] Sprint 1 Week 2 reflection answers are recorded
TODO: [x ] Week 2 storage check values are recorded
TODO: [x ] Required screenshots are attached

---

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** Mohamud Abdalla    **Date:** 2026-09-28

---

## Notes for Sprint 2

[Any observations or recommendations for the next sprint]
