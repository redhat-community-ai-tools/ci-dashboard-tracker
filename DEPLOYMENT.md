# CI Failure Tracker - Deployment Guide

## Overview

This guide covers deploying the CI Failure Tracker dashboard to OpenShift clusters.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        OpenShift Cluster                                 │
│                  (build10.ci.devcluster.openshift.com)                  │
│                                                                          │
│  ┌───────────────────────────────┐  ┌────────────────────────────────┐ │
│  │  Namespace: winc-dashboard    │  │ Namespace: winc-dashboard-poc │ │
│  │         (PRODUCTION)          │  │           (POC)                │ │
│  ├───────────────────────────────┤  ├────────────────────────────────┤ │
│  │                               │  │                                │ │
│  │  ┌─────────────────────────┐ │  │  ┌──────────────────────────┐ │ │
│  │  │   BuildConfig           │ │  │  │   BuildConfig            │ │ │
│  │  │   winc-dashboard        │ │  │  │   winc-dashboard-poc     │ │ │
│  │  │                         │ │  │  │                          │ │ │
│  │  │  Source: GitHub         │ │  │  │  Source: GitHub          │ │ │
│  │  │  Strategy: S2I          │ │  │  │  Strategy: S2I           │ │ │
│  │  │  Output: ImageStream    │ │  │  │  Output: ImageStream     │ │ │
│  │  └─────────────────────────┘ │  │  └──────────────────────────┘ │ │
│  │            │                  │  │            │                 │ │
│  │            v                  │  │            v                 │ │
│  │  ┌─────────────────────────┐ │  │  ┌──────────────────────────┐ │ │
│  │  │   ImageStream           │ │  │  │   ImageStream            │ │ │
│  │  │   winc-dashboard:latest │ │  │  │   winc-dashboard-poc:... │ │ │
│  │  └─────────────────────────┘ │  │  └──────────────────────────┘ │ │
│  │            │                  │  │            │                 │ │
│  │            v                  │  │            v                 │ │
│  │  ┌─────────────────────────┐ │  │  ┌──────────────────────────┐ │ │
│  │  │   Deployment            │ │  │  │   Deployment             │ │ │
│  │  │   Replicas: 1           │ │  │  │   Replicas: 1            │ │ │
│  │  │                         │ │  │  │                          │ │ │
│  │  │   Container:            │ │  │  │   Container:             │ │ │
│  │  │   - Port: 5000          │ │  │  │   - Port: 5000           │ │ │
│  │  │   - Volume: /data       │ │  │  │   - Volume: /data        │ │ │
│  │  │   - Env: ReportPortal   │ │  │  │   - Env: AI enabled      │ │ │
│  │  └─────────────────────────┘ │  │  └──────────────────────────┘ │ │
│  │            │                  │  │            │                 │ │
│  │            v                  │  │            v                 │ │
│  │  ┌─────────────────────────┐ │  │  ┌──────────────────────────┐ │ │
│  │  │   Service               │ │  │  │   Service                │ │ │
│  │  │   Type: ClusterIP       │ │  │  │   Type: ClusterIP        │ │ │
│  │  │   Port: 5000            │ │  │  │   Port: 5000             │ │ │
│  │  └─────────────────────────┘ │  │  └──────────────────────────┘ │ │
│  │            │                  │  │            │                 │ │
│  │            v                  │  │            v                 │ │
│  │  ┌─────────────────────────┐ │  │  ┌──────────────────────────┐ │ │
│  │  │   Route                 │ │  │  │   Route                  │ │ │
│  │  │   TLS: Edge             │ │  │  │   TLS: Edge              │ │ │
│  │  │   URL: winc-dashboard-  │ │  │  │   URL: winc-dashboard-   │ │ │
│  │  │   ...apps.build10...    │ │  │  │   poc-...apps.build10... │ │ │
│  │  └─────────────────────────┘ │  │  └──────────────────────────┘ │ │
│  │                               │  │                                │ │
│  │  ┌─────────────────────────┐ │  │  ┌──────────────────────────┐ │ │
│  │  │   PVC                   │ │  │  │   PVC                    │ │ │
│  │  │   dashboard-data        │ │  │  │   dashboard-data         │ │ │
│  │  │   Size: 10Gi            │ │  │  │   Size: 10Gi             │ │ │
│  │  │   Mount: /data          │ │  │  │   Mount: /data           │ │ │
│  │  │   File: dashboard.db    │ │  │  │   File: dashboard.db     │ │ │
│  │  └─────────────────────────┘ │  │  └──────────────────────────┘ │ │
│  │                               │  │                                │ │
│  └───────────────────────────────┘  └────────────────────────────────┘ │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

External Services:
┌──────────────────┐     ┌─────────────────┐     ┌──────────────────┐
│   ReportPortal   │────▶│   Production    │     │   Prow GCS       │
│                  │     │   Dashboard     │     │  (JUnit XML)     │
└──────────────────┘     └─────────────────┘     └──────────────────┘
                                                           │
                                                           ▼
                         ┌─────────────────┐     ┌──────────────────┐
                         │   Vertex AI     │◀────│   POC Dashboard  │
                         │  (Claude API)   │     │                  │
                         └─────────────────┘     └──────────────────┘
                                                           │
                         ┌─────────────────┐              │
                         │   Jira          │◀─────────────┘
                         │  (Red Hat)      │
                         └─────────────────┘
```

## Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                          CI Pipeline                                  │
│                                                                       │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐          │
│  │ Periodic│    │Rehearse │    │ Pull-CI │    │ Manual  │          │
│  │  Jobs   │    │  Jobs   │    │  Jobs   │    │  Jobs   │          │
│  └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘          │
│       │              │              │              │                 │
│       └──────────────┴──────────────┴──────────────┘                │
│                      │                                               │
│                      v                                               │
│            ┌─────────────────────┐                                  │
│            │  Test Execution     │                                  │
│            │  (OpenShift CI)     │                                  │
│            └─────────────────────┘                                  │
│                      │                                               │
│                      v                                               │
│       ┌──────────────┴──────────────┐                              │
│       │                              │                              │
│       v                              v                              │
│  ┌─────────────┐            ┌──────────────┐                      │
│  │ ReportPortal│            │  Prow GCS    │                      │
│  │             │            │  (JUnit XML) │                      │
│  └──────┬──────┘            └──────┬───────┘                      │
│         │                          │                               │
└─────────┼──────────────────────────┼───────────────────────────────┘
          │                          │
          v                          v
  ┌────────────────┐        ┌────────────────┐
  │  Production    │        │  POC Dashboard │
  │  Dashboard     │        │                │
  └────────┬───────┘        └────────┬───────┘
           │                         │
           └──────────┬──────────────┘
                      │
                      v
           ┌────────────────────┐
           │  SQLite Database   │
           │  (PVC: /data)      │
           │                    │
           │  Tables:           │
           │  - job_runs        │
           │  - test_results    │
           │  - ai_analyses     │
           │  - daily_metrics   │
           └────────────────────┘
                      │
                      v
           ┌────────────────────┐
           │  User Actions      │
           ├────────────────────┤
           │  1. View failures  │
           │  2. Classify test  │
           │  3. Run AI analysis│
           │  4. Create Jira    │
           └─────────┬──────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
          v                     v
  ┌──────────────┐      ┌─────────────┐
  │  Vertex AI   │      │    Jira     │
  │  (Claude)    │      │  (Tickets)  │
  └──────────────┘      └─────────────┘
```

## Prerequisites

### Access Requirements

1. OpenShift cluster access with project admin permissions
2. GitHub repository access for webhook configuration
3. Jira API token (for Jira integration)
4. Google Cloud Vertex AI access (for AI features)

### Required Secrets

```bash
# Jira Integration
JIRA_API_TOKEN=<your-token>
JIRA_EMAIL=<your-email>

# AI Analysis (Vertex AI)
ANTHROPIC_VERTEX_PROJECT_ID=<gcp-project-id>
ANTHROPIC_VERTEX_REGION=<region>

# Alternative: Direct Anthropic API
CLAUDE_API_KEY=<anthropic-api-key>

# ReportPortal (Production only)
REPORTPORTAL_URL=<reportportal-url>
REPORTPORTAL_API_KEY=<api-key>
REPORTPORTAL_PROJECT=<project-name>
```

## Deployment Steps

### Option 1: Deploy Production Dashboard

Production dashboard uses ReportPortal as data source.

#### 1. Create Namespace

```bash
oc new-project winc-dashboard
```

#### 2. Create Secrets

```bash
oc create secret generic reportportal-secret \
  --from-literal=REPORTPORTAL_URL=https://reportportal.example.com \
  --from-literal=REPORTPORTAL_API_KEY=your-api-key \
  --from-literal=REPORTPORTAL_PROJECT=your-project

oc create secret generic dashboard-secrets \
  --from-literal=ENABLE_AI_ANALYSIS=false
```

#### 3. Deploy Resources

```bash
cd openshift

# Create PVC for database
oc apply -f pvc.yaml

# Create ImageStream
oc apply -f imagestream.yaml

# Create BuildConfig
oc apply -f buildconfig.yaml

# Create Deployment
oc apply -f deployment.yaml

# Create Service
oc apply -f service.yaml

# Create Route
oc apply -f route.yaml
```

#### 4. Trigger Build

```bash
oc start-build winc-dashboard
```

#### 5. Monitor Deployment

```bash
# Watch build
oc get builds -w

# Watch pods
oc get pods -w

# Check logs
oc logs deployment/winc-dashboard --tail=100
```

#### 6. Access Dashboard

```bash
oc get route winc-dashboard -o jsonpath='{.spec.host}'
```

Open the URL in your browser.

### Option 2: Deploy POC Dashboard

POC dashboard uses Prow GCS as data source and includes AI analysis.

#### 1. Create Namespace

```bash
oc new-project winc-dashboard-poc
```

#### 2. Create Secrets

```bash
oc create secret generic dashboard-secrets \
  --from-literal=ENABLE_AI_ANALYSIS=true \
  --from-literal=JIRA_API_TOKEN=your-jira-token \
  --from-literal=JIRA_EMAIL=your-email@redhat.com \
  --from-literal=ANTHROPIC_VERTEX_PROJECT_ID=your-gcp-project \
  --from-literal=ANTHROPIC_VERTEX_REGION=us-east5
```

#### 3. Deploy Resources

```bash
cd openshift/poc

# Create ConfigMap
oc apply -f dashboard-configmap.yaml

# Create PVC
oc apply -f dashboard-pvc.yaml

# Create ImageStream
oc apply -f dashboard-imagestream.yaml

# Create BuildConfig
oc apply -f dashboard-buildconfig.yaml

# Create Deployment
oc apply -f dashboard-deployment.yaml

# Create Service
oc apply -f dashboard-service.yaml

# Create Route
oc apply -f dashboard-route.yaml
```

#### 4. Configure GitHub Webhook

Get the webhook URL:

```bash
oc describe bc/winc-dashboard-poc | grep -A 3 "Webhook GitHub"
```

Add webhook to GitHub repository:
1. Go to repository Settings > Webhooks
2. Add webhook with URL from above
3. Content type: application/json
4. Events: Just the push event

#### 5. Trigger Build

```bash
oc start-build winc-dashboard-poc
```

#### 6. Monitor and Access

```bash
# Watch build progress
oc get builds -w

# Check pod status
oc get pods

# View logs
oc logs deployment/winc-dashboard-poc --tail=100

# Get dashboard URL
oc get route winc-dashboard-poc -o jsonpath='{.spec.host}'
```

## Configuration

### Environment Variables

Edit the deployment to add/modify environment variables:

```bash
oc edit deployment/winc-dashboard-poc
```

Add or modify:

```yaml
spec:
  template:
    spec:
      containers:
      - name: dashboard
        env:
        - name: ENABLE_AI_ANALYSIS
          value: "true"
        - name: JIRA_PROJECT
          value: "WINC"
        - name: DASHBOARD_URL
          value: "https://your-dashboard-url"
```

Or use `oc set env`:

```bash
oc set env deployment/winc-dashboard-poc \
  ENABLE_AI_ANALYSIS=true \
  JIRA_PROJECT=WINC
```

### Job Patterns

Configure which Prow jobs to collect (POC only):

Edit `dashboard-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dashboard-config
data:
  job_patterns: |
    periodic-ci-openshift-openshift-tests-private-release-4.22-amd64-*-winc-*
    periodic-ci-openshift-openshift-tests-private-release-4.23-amd64-*-winc-*
    rehearse-*-winc-*
    pull-ci-*-winc-*
```

Apply changes:

```bash
oc apply -f dashboard-configmap.yaml
oc rollout restart deployment/winc-dashboard-poc
```

## Maintenance

### Updating Code

Code updates trigger automatic builds via webhook.

Manual update:

```bash
# Trigger new build
oc start-build winc-dashboard-poc

# Watch build
oc get builds -w

# After build completes, deployment auto-updates
oc get pods -w
```

### Database Maintenance

#### Access Database

```bash
oc exec -it deployment/winc-dashboard-poc -- /bin/bash
cd /data
ls -lh dashboard.db
```

#### Backup Database

```bash
oc exec deployment/winc-dashboard-poc -- \
  tar czf /tmp/db-backup-$(date +%Y%m%d).tar.gz /data/dashboard.db

oc cp winc-dashboard-poc/<pod-name>:/tmp/db-backup-*.tar.gz ./backup/
```

#### Clean Old Data

Run the cleanup script:

```bash
oc exec -it deployment/winc-dashboard-poc -- python3 clean_test_descriptions.py
```

### Scaling

Currently runs 1 replica. SQLite doesn't support concurrent writes, so scaling requires migration to PostgreSQL.

Future: Multi-replica with PostgreSQL backend.

### Monitoring

#### Check Application Health

```bash
# View recent logs
oc logs deployment/winc-dashboard-poc --tail=100

# Follow logs in real-time
oc logs -f deployment/winc-dashboard-poc

# Check pod status
oc get pods

# Check pod resources
oc top pods
```

#### Check Build Status

```bash
# List recent builds
oc get builds

# Get build logs
oc logs build/winc-dashboard-poc-<build-number>
```

#### Check Route Availability

```bash
# Check route configuration
oc get route winc-dashboard-poc

# Test route
curl -I https://$(oc get route winc-dashboard-poc -o jsonpath='{.spec.host}')
```

## Troubleshooting

### Build Failures

**Problem**: Build fails with "error building image"

**Solution**:
```bash
# Check build logs
oc logs build/winc-dashboard-poc-<number>

# Common issues:
# - Git clone failure: Check webhook configuration
# - Dependency installation: Check requirements.txt
# - Docker build: Check Dockerfile syntax
```

### Pod CrashLoopBackOff

**Problem**: Pod keeps restarting

**Solution**:
```bash
# Check pod logs
oc logs deployment/winc-dashboard-poc --previous

# Common causes:
# - Missing environment variables
# - Database permissions
# - Port conflicts
```

### Data Not Updating

**Problem**: Dashboard shows old data

**Solution**:
```bash
# Check collector logs
oc logs deployment/winc-dashboard-poc | grep -i "collection\|error"

# Trigger manual collection
curl -X POST https://<dashboard-url>/api/trigger-collection

# Check database file size
oc exec deployment/winc-dashboard-poc -- ls -lh /data/dashboard.db
```

### Jira Integration Failures

**Problem**: "Failed to create Jira issue" error

**Solution**:
```bash
# Check logs for specific error
oc logs deployment/winc-dashboard-poc | grep -i jira

# Verify secrets
oc get secret dashboard-secrets -o yaml | grep JIRA

# Common issues:
# - Invalid token: Regenerate JIRA_API_TOKEN
# - Wrong project: Check JIRA_PROJECT env var
# - Content limit: Already fixed in Build 79
```

### AI Analysis Not Working

**Problem**: "AI Analysis Unknown" or failures

**Solution**:
```bash
# Check Vertex AI configuration
oc get secret dashboard-secrets -o yaml | grep ANTHROPIC

# Verify Vertex AI access
# - Check GCP project permissions
# - Verify Claude API is enabled
# - Check quota limits

# Check logs
oc logs deployment/winc-dashboard-poc | grep -i "vertex\|claude\|ai"
```

## Production Checklist

Before going live:

- [ ] Secrets configured and validated
- [ ] Database PVC created and mounted
- [ ] Route configured with TLS
- [ ] Webhook configured for automatic builds
- [ ] Initial data collection successful
- [ ] Dashboard accessible via route
- [ ] Jira integration tested
- [ ] AI analysis tested (POC only)
- [ ] Logs reviewed for errors
- [ ] Backup strategy in place
- [ ] Documentation updated
- [ ] Team trained on usage

## Rollback Procedure

If a deployment causes issues:

```bash
# Rollback to previous version
oc rollout undo deployment/winc-dashboard-poc

# Or rollback to specific revision
oc rollout history deployment/winc-dashboard-poc
oc rollout undo deployment/winc-dashboard-poc --to-revision=<number>

# Verify rollback
oc rollout status deployment/winc-dashboard-poc
oc get pods
```

## Performance Tuning

### Resource Limits

Current configuration:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

Adjust based on usage:

```bash
oc set resources deployment/winc-dashboard-poc \
  --requests=memory=512Mi,cpu=200m \
  --limits=memory=2Gi,cpu=1000m
```

### Database Optimization

For large datasets:

1. Add indexes (already implemented)
2. Archive old data periodically
3. Consider PostgreSQL migration for >100GB data

## Support and Contact

For issues or questions:
- GitHub Issues: https://github.com/redhat-community-ai-tools/ci-failure-tracker/issues
- Team Contact: Windows Containers QE Team
