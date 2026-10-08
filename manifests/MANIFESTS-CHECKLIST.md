# Kubernetes Manifests Checklist

## Expected Files from kompose

After running `kompose convert -f ../week-2/docker-compose.yml`, your `manifests/` directory should contain these files. Check them off as they are created and reviewed.

### Deployment Files

These define how containers are deployed to the cluster.

- [ ] `flask-deployment.yaml` - Flask API Deployment (MUST FIX: plaintext env vars + Recreate strategy)
- [ ] `postgres-deployment.yaml` - PostgreSQL Deployment (MUST FIX: plaintext env vars + Recreate strategy)
- [ ] `nginx-deployment.yaml` - Nginx Deployment (may also need strategy fix)

### Service Files

These expose Deployments to network traffic.

- [ ] `flask-service.yaml` - Flask service (internal, ClusterIP)
- [ ] `postgres-service.yaml` - PostgreSQL service (internal, ClusterIP)
- [ ] `nginx-service.yaml` - Nginx service (external, LoadBalancer)

### Network and Volume Files

These define shared storage and networking.

- [ ] Network definition (may be in individual Deployments or separate NetworkPolicy)
- [ ] PersistentVolumeClaim for `db-data` volume (or volume definition in postgres-deployment.yaml)

### Security Files (Student Created)

These are created to fix security issues in kompose output.

- [ ] `flask-secret.yaml` - Kubernetes Secret with Flask credentials (created in Part 2, Step 12)
- [ ] `postgres-secret.yaml` - Kubernetes Secret with PostgreSQL credentials (created in Part 2, Step 14)

## Required Fixes

### Fix 1: Plaintext Credentials

**Problem:** kompose extracts environment variables from your Docker Compose file and includes them literally in Deployment manifests. This means passwords appear in YAML files visible to anyone.

**Affected Files:**
- [ ] flask-deployment.yaml contains plaintext POSTGRES_USER, POSTGRES_PASSWORD, DATABASE_URL
- [ ] postgres-deployment.yaml contains plaintext POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- [ ] nginx-deployment.yaml (check if it references database credentials)

**Solution:**
- [ ] Create Secret files to hold the credentials
- [ ] Update Deployments to use `envFrom: secretRef` instead of inline `env:`

**Verification:**
```bash
kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].env}'
# Should return empty [] or only non-credential environment variables
```

### Fix 2: Recreate Strategy

**Problem:** kompose sets `strategy: type: Recreate` by default. This stops all old pods before starting new ones, causing service downtime during any deployment.

**Affected Files:**
- [ ] flask-deployment.yaml contains `strategy: type: Recreate`
- [ ] postgres-deployment.yaml contains `strategy: type: Recreate`
- [ ] nginx-deployment.yaml contains `strategy: type: Recreate`

**Solution:**
- [ ] Change all Deployments to use `strategy: type: RollingUpdate`
- [ ] Add RollingUpdate parameters:
  ```yaml
  rollingUpdate:
    maxSurge: 1        # Allow 1 extra pod during update
    maxUnavailable: 0  # Do not take any pods offline
  ```

**Verification:**
```bash
kubectl get deployment flask -o jsonpath='{.spec.strategy.type}'
# Should return: RollingUpdate
```

## Deployment Order

When applying manifests, follow this order:

1. Apply Secrets first (so they exist when Deployments start)
   ```bash
   kubectl apply -f manifests/flask-secret.yaml
   kubectl apply -f manifests/postgres-secret.yaml
   ```

2. Apply all other manifests
   ```bash
   kubectl apply -f manifests/
   ```

Do not apply Deployments before Secrets are in place, or pods will crash looking for referenced Secrets.

## Post-Deployment Checks

After applying all manifests, verify:

- [ ] All pods are Running: `kubectl get pods`
- [ ] Pods are ready: all show `1/1` in READY column
- [ ] Application responds: `curl http://localhost:8080/health`
- [ ] No pods in CrashLoopBackOff state
- [ ] No pods in Pending state for more than 2 minutes

## Screenshots to Capture

For the team Google Doc:

1. **Before Fixes:** Screenshot showing plaintext credentials and Recreate strategy in kompose output
2. **After Deployment:** Screenshot of `kubectl get pods` with all pods Running
3. **Rolling Update:** Screenshot showing two Flask pods running (during `kubectl scale deployment flask --replicas=2`)
4. **Validation Script:** Screenshot of `./scripts/check-week3.sh` passing

## Troubleshooting

### Pods Stuck in Pending

Check for resource constraints or missing volume provisioning:

```bash
kubectl describe pod <pod-name>
# Look for Events section explaining why pod is Pending
```

### Pods in CrashLoopBackOff

Check logs to see why container is crashing:

```bash
kubectl logs <pod-name>
# Look for connection errors (missing Secrets?) or startup failures
```

### Service Not Responding to Health Check

```bash
kubectl get svc
# Check if nginx service has an EXTERNAL-IP assigned
kubectl port-forward svc/nginx 8080:80
# Then curl http://localhost:8080/health in another terminal
```
