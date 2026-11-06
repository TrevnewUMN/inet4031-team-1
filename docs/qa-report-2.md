# QA Report: Sprint 2 Week 3

QA is responsible for running all validation checks and signing off before deliverables are submitted. This report documents the validation process.


**QA Review:** October 16, 2026

**QA Status:** In Progress - Full validation pending

**Current Progress:**
- Week 3 k3d setup play has been added to `ansible/site.yml` on main.
- The k3d setup role has been created in pull request #34 and is awaiting review.
- The team's Kubernetes cluster was previously deployed using the name `team1`.
- Some Kubernetes manifest files are still missing from GitHub.
- Full Kubernetes validation has not been completed due to issues with the shared VM.

**Known Blockers:**
- The shared VM experienced low disk space, causing Kubernetes pods to be evicted.
- The Flask image needs to be restored.
- Week 3 Kubernetes manifests still need to be committed.
- The k3d setup role needs to be completed and tested.
- The cluster name in this QA template (`myapp`) differs from the team's cluster name (`team1`).


---

## Validation Checks

### Check 1: k3d Cluster Is Running

**Test:** Run `k3d cluster list`

**Expected:** One row showing `team1` with SERVERS 1/1 and AGENTS 2/2 (all nodes up).

**Note:** The original Week 3 template specifies `myapp`, but our team deployed the cluster as `team1`. This difference needs to be confirmed against the lab requirements.
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

**Overall Status:** In Progress - Validation Incomplete

**Blockers:**
- The shared VM experienced disk space issues, causing Kubernetes pods to be evicted.
- The Flask container image is currently unavailable.
- Some Week 3 Kubernetes manifests are missing from GitHub.
- The Week 3 k3d setup role still needs to be completed and tested.
- The Week 3 validation script has not been confirmed passing.

**Corrective Actions Taken:**
- Updated `ansible/site.yml` to include the Week 3 k3d setup play.
- Commented out the older Docker Compose deployment play.
- Created the `k3d-setup` Ansible role in PR #34.
- Documented the missing manifests and current VM issues.

**QA Sign-Off:** Pending

The full validation checks have not been completed. Final QA approval will be recorded after the environment is working and all required tests pass.

---

## Notes for Sprint 3

The team should focus on completing the missing Kubernetes manifests, improving the Ansible automation, and making sure the application can be rebuilt from GitHub.

The shared VM disk space issue needs to be resolved before the team can fully verify the Kubernetes deployment.

The Flask image name should also be consistent between the cluster and OpenTofu configuration.

