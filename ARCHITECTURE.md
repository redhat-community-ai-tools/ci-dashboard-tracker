# CI Failure Tracker - Architecture Documentation

## Overview

The CI Failure Tracker is a comprehensive dashboard for monitoring and analyzing Windows Containers CI test failures in OpenShift. It provides automated failure analysis, Jira integration, and detailed metrics visualization.

## System Components

### 1. Web Application (Flask)

**Location**: `src/web/server.py`

The Flask web application serves as the main user interface and API backend.

**Key Routes**:
- `/` - Main dashboard UI
- `/api/summary` - Overall test statistics
- `/api/test-rankings` - Top failing tests
- `/api/platform-comparison` - Platform comparison metrics
- `/api/test-error-by-platform` - Detailed test failure data
- `/api/jira/create` - Create or find Jira issues
- `/api/analyze-failure` - AI failure analysis
- `/api/save-classification` - Save manual test classification
- `/api/get-test-data` - Retrieve test metadata (Jira key, classification, AI analysis)

**Features**:
- Server-side template rendering (Jinja2)
- RESTful API for data retrieval
- Real-time failure analysis
- Persistent data storage

### 2. Data Collectors

**Location**: `src/collectors/`

Collectors retrieve test results from various sources.

#### Prow GCS Collector (`prow_gcs.py`)
- Primary data collector
- Reads JUnit XML files from Google Cloud Storage
- Parses test results from Prow CI jobs
- Supports periodic, rehearse, and pull-CI job types
- Extracts GCS paths from job URLs to handle pr-logs structure
- Pattern-based job filtering
- Test name and description extraction
- Platform and version detection
- Error message parsing
- Cleans test descriptions (removes prefixes, tags)

### 3. Database Layer

**Location**: `src/storage/database.py`

SQLite database with comprehensive schema for test tracking.

**Tables**:

1. **job_runs** - Overall job statistics
   - job_name, build_id, status, timestamp
   - version, platform, total_tests, pass_rate
   - job_url for linking to CI system

2. **test_results** - Individual test results
   - test_name, test_description, status
   - error_message, duration, timestamp
   - version, platform, job_name, build_id
   - manual_classification (user-provided)
   - jira_issue_key (linked Jira ticket)

3. **ai_analyses** - AI-generated failure analyses
   - test_name, version, platform
   - root_cause, component, confidence
   - failure_type, evidence, suggested_action
   - analysis_mode (vertex-ai or local)

4. **daily_metrics** - Pre-aggregated daily statistics
5. **test_metrics** - Per-test aggregated metrics

**Key Features**:
- UNIQUE constraints prevent duplicate data
- Indexes for fast queries
- Case-insensitive platform matching
- Automatic schema migration (ALTER TABLE)

### 4. AI Failure Analyzer

**Location**: `src/ai/analyzer.py`

Provides automated failure analysis using Claude AI.

**Modes**:
- **Vertex AI**: Uses Claude via Google Cloud Vertex AI (production)
- **Direct API**: Uses Anthropic API directly (fallback)

**Analysis Output**:
- Root cause description
- Affected component
- Confidence score (0-100%)
- Failure classification (product_bug, automation_bug, system_issue, transient, to_investigate)
- Evidence from logs
- Suggested remediation actions

**Cost**: ~$0.024 per analysis (Sonnet 4 model)

### 5. Jira Integration

**Location**: `src/integrations/jira_integration.py`

Automated Jira ticket creation with duplicate detection.

**Workflow**:
1. Check for existing Jira ticket (JQL search with time restriction)
2. If found: Return existing ticket, save to database
3. If not found: Create new ticket with minimal description
4. Save Jira key to database for future reference

**Features**:
- Duplicate detection (prevents multiple tickets for same failure)
- Automatic retry on redirect (301/302 handling)
- Minimal ticket description to avoid CONTENT_LIMIT_EXCEEDED
- Links to dashboard and failed job

**Authentication**: Basic Auth with JIRA_API_TOKEN

### 6. Frontend UI

**Location**: `src/web/templates/dashboard.html`

Single-page dashboard with multiple views and interactive features.

**Components**:

1. **Summary Cards**
   - Total runs, pass rate, failing tests
   - Platform breakdown
   - Version metrics

2. **Test Rankings Table**
   - Top 100 failing tests
   - Click test to see detailed failure data
   - Sortable columns

3. **Platform Badges**
   - Click to filter test failures by platform
   - Shows run counts per platform

4. **Test Detail Modal**
   - Timestamp, platform, job info
   - Error logs with syntax highlighting
   - Manual classification dropdown
   - AI analysis section (auto-loaded from database)
   - Jira integration (create or view existing ticket)

**JavaScript Features**:
- Dynamic data loading (fetch API)
- No page reloads (SPA behavior)
- Persistent UI state in database
- Real-time updates

## Data Flow

### Collection Flow

```
CI System (Prow/ReportPortal)
         |
         v
   Data Collector
         |
         v
    Database (SQLite)
         |
         v
   Web Dashboard
```

### User Interaction Flow

```
User clicks platform badge
         |
         v
   Load test failures
         |
         v
   Display in table
         |
         v
User clicks test name
         |
         v
   Open detail modal
         |
         +---> Load existing data (Jira, classification, AI analysis)
         |
         +---> User can:
               - Save manual classification
               - Create/view Jira ticket
               - View AI analysis (auto-loaded if exists)
```

### Jira Creation Flow

```
User clicks "Create Jira"
         |
         v
   Search Jira for existing ticket
         |
         +---> Found existing
         |     |
         |     v
         |  Update button to show ticket link
         |  Save to database
         |
         +---> Not found
               |
               v
            Create new Jira ticket
               |
               v
            Open ticket in new tab
            Update button to show ticket link
            Save to database
```

## Environment Variables

### Required

- `ENABLE_AI_ANALYSIS` - Enable AI failure analysis (true/false)
- `JIRA_API_TOKEN` - Jira API token for ticket creation
- `JIRA_EMAIL` - Email for Jira Basic Auth

### Optional

- `ANTHROPIC_VERTEX_PROJECT_ID` - Google Cloud project for Vertex AI
- `ANTHROPIC_VERTEX_REGION` - Vertex AI region
- `CLAUDE_API_KEY` - Anthropic API key (fallback)
- `JIRA_URL` - Jira instance URL (default: https://issues.redhat.com)
- `JIRA_PROJECT` - Jira project key (default: WINC)
- `JIRA_COMPONENT` - Jira component name
- `DASHBOARD_URL` - Dashboard URL for Jira ticket links

### Prow GCS

- `GCS_URL` - GCS web URL (default: gcsweb-qe-private-deck-ci.apps.ci.l2s4.p1.openshiftapps.com)

## Deployment Architecture

**Namespace**: `winc-dashboard-poc` (will be renamed to `winc-dashboard`)

**Components**:
- Deployment: winc-dashboard-poc (1 replica)
- Service: winc-dashboard-poc (ClusterIP)
- Route: winc-dashboard-poc-winc-dashboard-poc.apps.build10.ci.devcluster.openshift.com
- PVC: dashboard-data (10Gi) - Persistent SQLite database
- BuildConfig: winc-dashboard-poc (Docker build)
- ImageStream: winc-dashboard-poc
- CronJob: dashboard-collector (runs every 6 hours)

**Data Source**: Prow GCS (JUnit XML files)

**Features**:
- Automated data collection (CronJob)
- AI failure analysis (Vertex AI/Claude 4)
- Jira integration with duplicate detection
- Manual test classification
- Persistent data storage (Jira keys, classifications, AI analyses)

## Database Persistence

Both deployments use PersistentVolumeClaim (PVC) to store the SQLite database.

**Benefits**:
- Data survives pod restarts
- Data survives builds and deployments
- No data loss on container updates

**Location**: `/data/dashboard.db` (mounted from PVC)

## Build Process

### Source-to-Image (S2I)

1. BuildConfig watches GitHub repository
2. Webhook triggers build on code push
3. S2I builds container image
4. Image pushed to ImageStream
5. Deployment automatically updates (ImageChange trigger)
6. Rolling update replaces old pod

**Build Time**: ~35 seconds

### Manual Build Trigger

```bash
oc start-build winc-dashboard-poc
```

## Security

### Secrets Management

Secrets stored in OpenShift Secrets, mounted as environment variables:

```bash
oc create secret generic dashboard-secrets \
  --from-literal=JIRA_API_TOKEN=xxx \
  --from-literal=JIRA_EMAIL=user@redhat.com \
  --from-literal=ANTHROPIC_VERTEX_PROJECT_ID=xxx
```

### Access Control

- Dashboard accessible via OpenShift Routes (HTTPS)
- No authentication required for read-only access
- Write operations (Jira, classification) require valid tokens

## Performance Considerations

### Database Optimization

- Indexes on frequently queried columns (timestamp, test_name, platform)
- UNIQUE constraints prevent duplicate inserts
- Pre-aggregated metrics tables for fast dashboard loading

### API Response Time

- Summary endpoint: <100ms
- Test rankings: <500ms (100 tests)
- Platform comparison: <200ms

### Collection Performance

- ReportPortal: Processes ~1000 tests in ~30 seconds
- Prow GCS: Processes ~500 tests in ~60 seconds (network I/O)

## Monitoring and Logging

### Application Logs

View logs:
```bash
oc logs deployment/winc-dashboard-poc --tail=100
```

### Log Levels

- INFO: Normal operation, collection progress
- WARNING: Non-critical issues (missing data, API warnings)
- ERROR: Failed operations (Jira errors, collection failures)

### Key Metrics to Monitor

- Build success rate
- Pod restarts
- Route availability
- Database size growth
- API response times

## Future Enhancements

### Planned Features

1. **Trend Analysis**
   - Historical pass rate trends
   - Regression detection
   - Platform-specific failure patterns

2. **Alerting**
   - Slack notifications for critical failures
   - Email reports for test owners

3. **Advanced Analytics**
   - Failure correlation analysis
   - Root cause clustering
   - Predictive failure detection

4. **Enhanced Jira Integration**
   - Auto-assignment based on component
   - Bulk ticket creation
   - Ticket status synchronization

### Technical Debt

1. Migrate from SQLite to PostgreSQL for better concurrency
2. Add API authentication
3. Implement caching layer (Redis)
4. Add comprehensive test suite
5. Set up CI/CD pipeline for dashboard itself
