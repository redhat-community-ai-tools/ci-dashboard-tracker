# CI Failure Tracker - Windows Containers Dashboard

Comprehensive web dashboard for monitoring, analyzing, and tracking Windows Containers CI test failures in OpenShift. Features automated AI analysis, Jira integration, and detailed failure metrics.

## Live Dashboards

- **Production**: https://winc-dashboard-winc-dashboard.apps.build10.ci.devcluster.openshift.com/
- **POC (with AI)**: https://winc-dashboard-poc-winc-dashboard-poc.apps.build10.ci.devcluster.openshift.com/

## Key Features

### Test Failure Tracking
- Real-time dashboard with test failure metrics
- Historical tracking (30+ days of test history)
- Platform-specific failure rates (AWS, Azure, GCP, vSphere, Nutanix)
- Version comparison (4.21, 4.22, 4.23)
- Top 100 failing tests with detailed statistics

### Interactive Test Analysis
- Click any test to view detailed failure information
- View error logs with syntax highlighting
- Filter failures by platform (click platform badges)
- Timestamp and job information for each failure
- Direct links to CI system (Prow/ReportPortal)

### AI-Powered Failure Analysis (POC)
- Automated root cause analysis using Claude 4 (Vertex AI)
- Identifies affected components
- Provides confidence scores
- Classifies failure types:
  - Product bugs
  - Automation bugs
  - System issues
  - Transient failures
  - Needs investigation
- Evidence extraction from logs
- Suggested remediation actions
- Auto-loads previous analysis from database

### Jira Integration (POC)
- One-click Jira ticket creation
- Automatic duplicate detection
- Minimal ticket description to avoid API limits
- Links to dashboard and failed job
- Persistent ticket references
- Click ticket number to view in Jira
- No popup for existing tickets

### Manual Classification
- User-defined test failure classification
- Save classifications to database
- Persistent across sessions
- Independent from AI analysis

### Data Persistence
- SQLite database with PersistentVolume
- Survives pod restarts and deployments
- Stores:
  - Job runs and test results
  - AI analyses
  - Manual classifications
  - Jira ticket references
- Optimized with indexes for fast queries

## Architecture

### System Components

```
┌────────────────────────────────────────────────────────────┐
│                    CI Pipeline                              │
│  Periodic Jobs / Rehearse Jobs / Pull-CI Jobs              │
└───────────────────────┬────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        v                               v
┌──────────────────┐          ┌──────────────────┐
│  ReportPortal    │          │   Prow GCS       │
│  (Production)    │          │   (POC)          │
└────────┬─────────┘          └────────┬─────────┘
         │                             │
         v                             v
┌────────────────────┐        ┌────────────────────┐
│  Production        │        │  POC Dashboard     │
│  Dashboard         │        │  + AI + Jira       │
└────────┬───────────┘        └────────┬───────────┘
         │                             │
         └──────────┬──────────────────┘
                    │
                    v
         ┌────────────────────┐
         │  SQLite Database   │
         │  (PersistentVolume)│
         └────────────────────┘
                    │
         ┌──────────┴──────────┐
         │                     │
         v                     v
┌─────────────────┐    ┌─────────────────┐
│  Vertex AI      │    │  Jira API       │
│  (Claude 4)     │    │  (Red Hat)      │
└─────────────────┘    └─────────────────┘
```

### Tech Stack

- **Backend**: Flask (Python 3.10+)
- **Database**: SQLite with WAL mode
- **AI**: Claude 4 via Google Vertex AI
- **Integration**: Jira REST API v3
- **Frontend**: HTML/CSS/JavaScript (vanilla)
- **Deployment**: OpenShift (S2I builds)
- **Storage**: PersistentVolumeClaim (10Gi)

## Quick Start

### Local Development

```bash
# Clone repository
git clone https://github.com/redhat-community-ai-tools/ci-dashboard-tracker.git
cd ci-dashboard-tracker

# Install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set environment variables
export REPORTPORTAL_URL=https://your-reportportal-instance.com
export REPORTPORTAL_API_KEY=your-api-key
export REPORTPORTAL_PROJECT=your-project

# Run locally
python dashboard.py
```

Open http://localhost:5000

### OpenShift Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment guide.

Quick deploy to POC:

```bash
oc new-project winc-dashboard-poc
cd openshift/poc
oc apply -f .
oc start-build winc-dashboard-poc
```

## Configuration

### Environment Variables

#### Required (Production)
```bash
REPORTPORTAL_URL=https://reportportal.example.com
REPORTPORTAL_API_KEY=your-api-key
REPORTPORTAL_PROJECT=project-name
```

#### Required (POC)
```bash
ENABLE_AI_ANALYSIS=true
JIRA_API_TOKEN=your-jira-token
JIRA_EMAIL=your-email@redhat.com
```

#### Optional (AI Features)
```bash
ANTHROPIC_VERTEX_PROJECT_ID=gcp-project-id
ANTHROPIC_VERTEX_REGION=us-east5
CLAUDE_API_KEY=sk-ant-xxx  # Alternative to Vertex AI
```

#### Optional (Customization)
```bash
JIRA_URL=https://issues.redhat.com
JIRA_PROJECT=WINC
JIRA_COMPONENT=component-name
DASHBOARD_URL=https://your-dashboard-url
GCS_URL=gcsweb-url  # For POC
```

## Usage

### Viewing Test Failures

1. Open dashboard URL
2. View summary cards (total runs, pass rate, failing tests)
3. Scroll to "Test Rankings" table
4. Click platform badge to filter failures
5. Click test name to see detailed information

### Analyzing Failures (POC)

1. Click test name to open detail modal
2. View error logs
3. AI analysis auto-loads if previously run
4. Review:
   - Root cause
   - Affected component
   - Confidence score
   - Evidence from logs
   - Suggested actions

### Creating Jira Tickets (POC)

1. Open test detail modal
2. Click "Create Jira" button
3. System searches for existing ticket
4. If found: Button shows ticket number (clickable)
5. If not found: Creates new ticket, opens in browser
6. Ticket reference saved to database

### Manual Classification (POC)

1. Open test detail modal
2. Select classification from dropdown:
   - Product Bug
   - Automation Bug
   - System Issue
   - Transient
   - To Investigate
3. Click "Save"
4. Classification persists across sessions

## Data Collection

### Production (ReportPortal)

Automatically collects from ReportPortal API:
- Periodic job results
- Test pass/fail status
- Error messages and logs
- Timestamp and duration

### POC (Prow GCS)

Collects from Prow CI via GCS:
- JUnit XML files from artifacts
- Supports periodic, rehearse, and pull-CI jobs
- Pattern-based job filtering
- Extracts test names, descriptions, errors

Job patterns configured in ConfigMap:
```yaml
job_patterns: |
  periodic-ci-openshift-openshift-tests-private-release-4.22-*-winc-*
  periodic-ci-openshift-openshift-tests-private-release-4.23-*-winc-*
  rehearse-*-winc-*
  pull-ci-*-winc-*
```

## API Endpoints

### Data Retrieval

- `GET /api/summary?days=7&version=4.22` - Overall statistics
- `GET /api/test-rankings?days=7&version=4.22&limit=100` - Top failing tests
- `GET /api/platform-comparison?days=7` - Platform metrics
- `GET /api/test-error-by-platform?test_name=OCP-12345&platform=aws&days=7` - Test details
- `GET /api/trend?days=7&version=4.22` - Historical trends
- `GET /api/version-comparison?days=7` - Version comparison

### Actions (POC)

- `POST /api/analyze-failure` - Run AI analysis
- `POST /api/jira/create` - Create/find Jira ticket
- `POST /api/save-classification` - Save manual classification
- `POST /api/get-test-data` - Get test metadata (Jira, classification, AI analysis)

### Management

- `POST /api/trigger-collection` - Trigger data collection

## Database Schema

### Tables

1. **job_runs** - Job execution records
   - job_name, build_id, status, timestamp
   - version, platform, test counts, pass_rate
   - job_url

2. **test_results** - Individual test results
   - test_name, test_description, status
   - error_message, timestamp, duration
   - version, platform, job info
   - manual_classification
   - jira_issue_key

3. **ai_analyses** - AI failure analyses
   - test_name, version, platform
   - root_cause, component, confidence
   - failure_type, evidence, suggested_action

4. **daily_metrics** - Pre-aggregated daily stats
5. **test_metrics** - Per-test aggregated metrics

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed system architecture
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide with diagrams
- [STATUS.md](STATUS.md) - Project status and roadmap
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide

## Development

### Project Structure

```
ci-dashboard-tracker/
├── src/
│   ├── ai/                  # AI failure analysis
│   │   └── analyzer.py     # Claude/Vertex AI integration
│   ├── collectors/          # Data collectors
│   │   ├── reportportal.py # ReportPortal API
│   │   └── prow_gcs.py     # Prow GCS (JUnit XML)
│   ├── integrations/        # External integrations
│   │   └── jira_integration.py
│   ├── storage/             # Database layer
│   │   └── database.py     # SQLite with schema
│   └── web/                 # Web interface
│       ├── server.py       # Flask app
│       └── templates/
│           └── dashboard.html
├── openshift/               # Deployment configs
│   ├── buildconfig.yaml
│   ├── deployment.yaml
│   └── poc/                # POC-specific configs
├── docs/                    # Additional documentation
├── Dockerfile              # Container image definition
├── requirements.txt        # Python dependencies
└── clean_test_descriptions.py  # Database maintenance
```

### Adding Features

1. Create feature branch
2. Implement changes in src/
3. Test locally
4. Update tests
5. Update documentation
6. Submit PR

### Running Tests

```bash
# Install test dependencies
pip install -r requirements-dev.txt

# Run tests
pytest

# Run with coverage
pytest --cov=src
```

## Maintenance

### Database Cleanup

Remove old data:

```bash
oc exec -it deployment/winc-dashboard-poc -- \
  python3 clean_test_descriptions.py
```

### View Logs

```bash
# Real-time logs
oc logs -f deployment/winc-dashboard-poc

# Recent logs
oc logs deployment/winc-dashboard-poc --tail=100

# Specific errors
oc logs deployment/winc-dashboard-poc | grep -i error
```

### Trigger Build

```bash
oc start-build winc-dashboard-poc
```

### Database Backup

```bash
oc exec deployment/winc-dashboard-poc -- \
  tar czf /tmp/backup.tar.gz /data/dashboard.db

oc cp winc-dashboard-poc/<pod-name>:/tmp/backup.tar.gz ./backup.tar.gz
```

## Troubleshooting

### Build Failures

Check build logs:
```bash
oc logs build/winc-dashboard-poc-<number>
```

Common issues:
- Git clone failure: Check webhook
- Dependency errors: Check requirements.txt
- Docker build: Check Dockerfile

### Pod Crashes

Check pod logs:
```bash
oc logs deployment/winc-dashboard-poc --previous
```

Common causes:
- Missing environment variables
- Database permission issues
- Port conflicts

### Jira Errors

Check Jira-specific logs:
```bash
oc logs deployment/winc-dashboard-poc | grep -i jira
```

Common issues:
- Invalid API token
- Wrong project key
- Content size limits (fixed in Build 79)

### AI Analysis Failures

Check AI logs:
```bash
oc logs deployment/winc-dashboard-poc | grep -i "vertex\|claude"
```

Common issues:
- Missing Vertex AI credentials
- Quota exceeded
- API permissions

## Roadmap

### Planned Features

- Historical trend analysis
- Slack notifications
- Email reports
- Failure correlation analysis
- Bulk Jira operations
- PostgreSQL migration
- API authentication
- Multi-replica support

### In Progress

- Enhanced metrics visualization
- Advanced filtering options
- Export functionality
- Custom dashboards

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

Internal Red Hat project. Not licensed for external use.

## Support

- GitHub Issues: https://github.com/redhat-community-ai-tools/ci-dashboard-tracker/issues
- Team: Windows Containers QE
- Contact: WINC team Slack channel

## Acknowledgments

- OpenShift CI team for Prow infrastructure
- ReportPortal team for test reporting platform
- Anthropic for Claude AI capabilities
- Red Hat Jira team for API access
