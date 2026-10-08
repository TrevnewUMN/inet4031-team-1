# QA Report: Sprint 2 Week 3

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.

**QA Team Member:** [Name]
**Date Completed:** [Date]

---

## Validation Checks

### Check 1: k3d Cluster Is Running

**Test:** Run `k3d cluster list`

**Expected:** One row showing `myapp` with `SERVERS 1/1` and `AGENTS 2/2` (all nodes up)

**Actual Result:**
```
TODO: Paste the actual output of k3d cluster list
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If any nodes aren't up, what did `kubectl describe node <node-name>` reveal?

---

### Check 2: All Pods Running

**Test:** Run `kubectl get pods`

**Expected:** All pods in `Running` state with `1/1` in READY

**Actual Result:**
```
TODO: Paste the actual output of kubectl get pods
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If any pod is not Running (Pending, CrashLoopBackOff, ErrImagePull), what did `kubectl describe pod <pod-name>` or `kubectl logs <pod-name>` reveal?

---

### Check 3: Credentials Are in a Secret, Not a Deployment

**Test:** Run `kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].env}'` and `kubectl get deployment db -o jsonpath='{.spec.template.spec.containers[0].env}'`, then `kubectl get secret flask-credentials` and `kubectl get secret db-credentials`

**Expected:** Both deployment env outputs are empty (no output) or show only non-credential variables; both Secrets exist

**Actual Result:**
```
TODO: Paste the actual output
```

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** If credentials are still visible in either Deployment, which one and what variable?

---

### Check 4: RollingUpdate Strategy Applied

**Test:** Run `kubectl get deployment db -o jsonpath='{.spec.strategy.type}'`

**Expected:** `RollingUpdate`

**Actual Result:** TODO: Record the strategy type returned

**Status:** TODO: [ ] Pass [ ] Fail

**Notes:** This checks the `db` Deployment, not `flask` — kompose only generates a `Recreate` strategy for services with a volume mount, and only `db` has one.

---

### Check 5: Check Script Passes

**Test:** Run `chmod +x scripts/check-week3.sh` then `./scripts/check-week3.sh`

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

### Part 1: k3d Cluster Creation

TODO: [ ] k3d cluster `myapp` created with 1 server and 2 agent nodes
TODO: [ ] Traefik disabled at cluster creation (`--k3s-arg "--disable=traefik@server:0"`)
TODO: [ ] `kubectl get nodes` shows all three nodes `Ready`

### Part 2: Docker Compose to Kubernetes Manifests

TODO: [ ] `kompose convert` generated a Deployment and Service for `db`, `flask`, and `nginx`, plus a PersistentVolumeClaim and ConfigMap
TODO: [ ] All `io.kompose.service` labels replaced with `app:` labels
TODO: [ ] Plaintext credentials moved to `flask-secret.yaml` and `db-secret.yaml`; Deployments use `envFrom`/`secretRef`
TODO: [ ] `db-deployment.yaml` strategy changed from `Recreate` to `RollingUpdate`
TODO: [ ] `flask-deployment.yaml` image reference fixed to the locally built image (not the kompose placeholder) and imported into the cluster with `k3d image import`
TODO: [ ] `nginx-service.yaml` changed from `ClusterIP` to `LoadBalancer`
TODO: [ ] `db-deployment.yaml` liveness probe command split into separate array items

### Part 3: Deploy and Verify

TODO: [ ] Secrets applied before other manifests
TODO: [ ] All pods reach `Running` / `1/1` Ready
TODO: [ ] Application responds at `http://localhost:8081/health`
TODO: [ ] Scaling `flask` to 2 replicas demonstrates a rolling update (new pod comes up before old one terminates)

### Part 4: Ansible Update

TODO: [ ] `ansible/roles/k3d-setup/tasks/main.yml` installs k3d and creates the cluster idempotently
TODO: [ ] `ansible/site.yml` includes the k3d-setup play
TODO: [ ] `app-stack` play commented out in `ansible/site.yml` (Kubernetes now supersedes Docker Compose)
TODO: [ ] Playbook runs clean end to end

---

## Deliverables Verification

### Required Files

TODO: [ ] `manifests/` directory is committed with all Kubernetes manifests (Deployments, Services, Secrets, PVC, ConfigMap)
TODO: [ ] `manifests/flask-secret.yaml` and `manifests/db-secret.yaml` are committed
TODO: [ ] `ansible/site.yml` includes the k3d-setup play (and has `app-stack` commented out)
TODO: [ ] `ansible/roles/k3d-setup/tasks/main.yml` is committed
TODO: [ ] `week-2/docker-compose.yml` is committed with the `ports:` entries added for `db` and `flask`

### GitHub Repository

TODO: [ ] All changes are pushed to the main branch
TODO: [ ] GitHub Project board shows all Week 3 tasks completed

### Google Doc

TODO: [ ] Sprint 1 close-out answers are recorded
TODO: [ ] Sprint 2 kickoff environment state checkpoint is recorded
TODO: [ ] Week 3 discussion answers are recorded (k3d resource competition, kompose translation risks, RollingUpdate vs. Recreate, Secret encoding vs. encryption, PostgreSQL data durability)
TODO: [ ] Required screenshots are attached: kompose output showing plaintext env vars and Recreate strategy (before fixes), `kubectl get pods` showing all pods Running, rolling update in progress (two Flask pods visible), `./scripts/check-week3.sh` passing
TODO: [ ] Week 3 storage check values are recorded

---

## Summary

**Overall Status:** [ ] ALL CHECKS PASS [ ] SOME CHECKS FAIL

**Blockers:** [List any blockers that prevent submission]

**Corrective Actions Taken:** [List any fixes applied during QA]

**QA Sign-Off:**

By signing below, QA certifies that all required validation checks have been executed and all deliverables meet the acceptance criteria.

**QA Signature:** _________________    **Date:** __________

---

## Notes for Sprint 3

[Any observations or recommendations for the next sprint]
