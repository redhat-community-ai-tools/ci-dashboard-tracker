# OpenShift Architecture - CI Failure Tracker

Complete architecture diagram showing all OpenShift components, namespaces, workloads, secrets, builds, and webhooks.

## Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 OpenShift Cluster                                            │
│                         (build10.ci.devcluster.openshift.com)                               │
│                                                                                              │
│  ┌────────────────────────────────────────┐  ┌────────────────────────────────────────────┐│
│  │ Namespace: winc-dashboard              │  │ Namespace: winc-dashboard-poc              ││
│  │ Purpose: Production Dashboard          │  │ Purpose: POC with AI + Jira                ││
│  ├────────────────────────────────────────┤  ├────────────────────────────────────────────┤│
│  │                                        │  │                                            ││
│  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ││
│  │ ┃ Secrets (Environment Variables)   ┃ │  │ ┃ Secrets (Environment Variables)        ┃ ││
│  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ │  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ││
│  │ ┃ reportportal-secret:              ┃ │  │ ┃ dashboard-secrets:                     ┃ ││
│  │ ┃ - REPORTPORTAL_URL                ┃ │  │ ┃ - ENABLE_AI_ANALYSIS=true              ┃ ││
│  │ ┃ - REPORTPORTAL_API_KEY            ┃ │  │ ┃ - JIRA_API_TOKEN                       ┃ ││
│  │ ┃ - REPORTPORTAL_PROJECT            ┃ │  │ ┃ - JIRA_EMAIL                           ┃ ││
│  │ ┃                                    ┃ │  │ ┃ - ANTHROPIC_VERTEX_PROJECT_ID          ┃ ││
│  │ ┃ dashboard-secrets:                ┃ │  │ ┃ - ANTHROPIC_VERTEX_REGION              ┃ ││
│  │ ┃ - ENABLE_AI_ANALYSIS=false        ┃ │  │ ┃ - JIRA_PROJECT=WINC                    ┃ ││
│  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ││
│  │                                        │  │                                            ││
│  │ ┌────────────────────────────────────┐ │  │ ┌──────────────────────────────────────┐ ││
│  │ │ ConfigMap                          │ │  │ │ ConfigMap: dashboard-config          │ ││
│  │ │ (Not used - secrets only)          │ │  │ │                                      │ ││
│  │ └────────────────────────────────────┘ │  │ │ Data:                                │ ││
│  │                                        │  │ │   job_patterns:                      │ ││
│  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │  │ │     periodic-ci-*-winc-*             │ ││
│  │ ┃ Build Pipeline                    ┃ │  │ │     rehearse-*-winc-*                │ ││
│  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ │  │ │     pull-ci-*-winc-*                 │ ││
│  │ ┃                                    ┃ │  │ └──────────────────────────────────────┘ ││
│  │ ┃ GitHub Repository                 ┃ │  │                                            ││
│  │ ┃ redhat-community-ai-tools/        ┃ │  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ││
│  │ ┃ ci-failure-tracker                ┃ │  │ ┃ Build Pipeline                         ┃ ││
│  │ ┃        │                          ┃ │  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ││
│  │ ┃        │ (push to master)         ┃ │  │ ┃                                        ┃ ││
│  │ ┃        ↓                          ┃ │  │ ┃ GitHub Repository                     ┃ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ redhat-community-ai-tools/            ┃ ││
│  │ ┃ │ GitHub Webhook              │  ┃ │  │ ┃ ci-failure-tracker                    ┃ ││
│  │ ┃ │ Payload URL:                │  ┃ │  │ ┃        │                              ┃ ││
│  │ ┃ │ https://api.build10.ci...   │  ┃ │  │ ┃        │ (push to master)             ┃ ││
│  │ ┃ │ /apis/build.openshift.io/v1/│  ┃ │  │ ┃        ↓                              ┃ ││
│  │ ┃ │ namespaces/winc-dashboard/  │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │ buildconfigs/winc-dashboard/│  ┃ │  │ ┃ │ GitHub Webhook                  │  ┃ ││
│  │ ┃ │ webhooks/<secret>/github    │  ┃ │  │ ┃ │ Payload URL:                    │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │ https://api.build10.ci...       │  ┃ ││
│  │ ┃ │ Events: push                │  ┃ │  │ ┃ │ /apis/build.openshift.io/v1/    │  ┃ ││
│  │ ┃ │ Content-Type: application/  │  ┃ │  │ ┃ │ namespaces/winc-dashboard-poc/  │  ┃ ││
│  │ ┃ │               json          │  ┃ │  │ ┃ │ buildconfigs/winc-dashboard-poc/│  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │ webhooks/<secret>/github        │  ┃ ││
│  │ ┃        │                          ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃        ↓                          ┃ │  │ ┃ │ Events: push                    │  ┃ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ │ Content-Type: application/json  │  ┃ ││
│  │ ┃ │ BuildConfig                 │  ┃ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┃ │ Name: winc-dashboard        │  ┃ │  │ ┃        │                              ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃        ↓                              ┃ ││
│  │ ┃ │ Source:                     │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │   Type: Git                 │  ┃ │  │ ┃ │ BuildConfig                     │  ┃ ││
│  │ ┃ │   URI: github.com/...       │  ┃ │  │ ┃ │ Name: winc-dashboard-poc        │  ┃ ││
│  │ ┃ │   Ref: master               │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │   ContextDir: dashboard     │  ┃ │  │ ┃ │ Source:                         │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │   Type: Git                     │  ┃ ││
│  │ ┃ │ Strategy:                   │  ┃ │  │ ┃ │   URI: github.com/...           │  ┃ ││
│  │ ┃ │   Type: Docker              │  ┃ │  │ ┃ │   Ref: master                   │  ┃ ││
│  │ ┃ │   DockerfilePath: Dockerfile│  ┃ │  │ ┃ │   ContextDir: dashboard         │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │ Output:                     │  ┃ │  │ ┃ │ Strategy:                       │  ┃ ││
│  │ ┃ │   To: ImageStream           │  ┃ │  │ ┃ │   Type: Docker                  │  ┃ ││
│  │ ┃ │       winc-dashboard:latest │  ┃ │  │ ┃ │   DockerfilePath: Dockerfile    │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │ Triggers:                   │  ┃ │  │ ┃ │ Output:                         │  ┃ ││
│  │ ┃ │   - GitHub webhook          │  ┃ │  │ ┃ │   To: ImageStream               │  ┃ ││
│  │ ┃ │   - ConfigChange            │  ┃ │  │ ┃ │       winc-dashboard-poc:latest │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃        │                          ┃ │  │ ┃ │ Triggers:                       │  ┃ ││
│  │ ┃        ↓ (Build: ~35 seconds)    ┃ │  │ ┃ │   - GitHub webhook              │  ┃ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ │   - ConfigChange                │  ┃ ││
│  │ ┃ │ ImageStream                 │  ┃ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┃ │ Name: winc-dashboard        │  ┃ │  │ ┃        │                              ┃ ││
│  │ ┃ │ Tags:                       │  ┃ │  │ ┃        ↓ (Build: ~35 seconds)        ┃ ││
│  │ ┃ │   - latest                  │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │   - Build numbers (1,2,3...)│  ┃ │  │ ┃ │ ImageStream                     │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │ Name: winc-dashboard-poc        │  ┃ ││
│  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │  │ ┃ │ Tags:                           │  ┃ ││
│  │                                        │  │ ┃ │   - latest                      │  ┃ ││
│  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │  │ ┃ │   - Build numbers (1-134...)    │  ┃ ││
│  │ ┃ Workloads                         ┃ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ │  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ││
│  │ ┃                                    ┃ │  │                                            ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ││
│  │ ┃ │ Deployment                  │  ┃ │  │ ┃ Workloads                              ┃ ││
│  │ ┃ │ Name: winc-dashboard        │  ┃ │  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ││
│  │ ┃ │                             │  ┃ │  │ ┃                                        ┃ ││
│  │ ┃ │ Replicas: 1                 │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │ Strategy: RollingUpdate     │  ┃ │  │ ┃ │ Deployment                      │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │ Name: winc-dashboard-poc        │  ┃ ││
│  │ ┃ │ Pod Template:               │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │   Containers:               │  ┃ │  │ ┃ │ Replicas: 1                     │  ┃ ││
│  │ ┃ │   - Name: dashboard         │  ┃ │  │ ┃ │ Strategy: RollingUpdate         │  ┃ ││
│  │ ┃ │     Image: winc-dashboard:  │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │            latest           │  ┃ │  │ ┃ │ Pod Template:                   │  ┃ ││
│  │ ┃ │     Port: 5000              │  ┃ │  │ ┃ │   Containers:                   │  ┃ ││
│  │ ┃ │     EnvFrom:                │  ┃ │  │ ┃ │   - Name: dashboard             │  ┃ ││
│  │ ┃ │       - reportportal-secret │  ┃ │  │ ┃ │     Image: winc-dashboard-poc:  │  ┃ ││
│  │ ┃ │       - dashboard-secrets   │  ┃ │  │ ┃ │            latest               │  ┃ ││
│  │ ┃ │     VolumeMounts:           │  ┃ │  │ ┃ │     Port: 5000                  │  ┃ ││
│  │ ┃ │       - /data               │  ┃ │  │ ┃ │     EnvFrom:                    │  ┃ ││
│  │ ┃ │     Resources:              │  ┃ │  │ ┃ │       - dashboard-secrets       │  ┃ ││
│  │ ┃ │       Requests:             │  ┃ │  │ ┃ │     VolumeMounts:               │  ┃ ││
│  │ ┃ │         memory: 256Mi       │  ┃ │  │ ┃ │       - /data                   │  ┃ ││
│  │ ┃ │         cpu: 100m           │  ┃ │  │ ┃ │     Resources:                  │  ┃ ││
│  │ ┃ │       Limits:               │  ┃ │  │ ┃ │       Requests:                 │  ┃ ││
│  │ ┃ │         memory: 1Gi         │  ┃ │  │ ┃ │         memory: 256Mi           │  ┃ ││
│  │ ┃ │         cpu: 500m           │  ┃ │  │ ┃ │         cpu: 100m               │  ┃ ││
│  │ ┃ │   Volumes:                  │  ┃ │  │ ┃ │       Limits:                   │  ┃ ││
│  │ ┃ │     - dashboard-data (PVC)  │  ┃ │  │ ┃ │         memory: 1Gi             │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │         cpu: 500m               │  ┃ ││
│  │ ┃ │ Triggers:                   │  ┃ │  │ ┃ │   Volumes:                      │  ┃ ││
│  │ ┃ │   - ImageChange             │  ┃ │  │ ┃ │     - dashboard-data (PVC)      │  ┃ ││
│  │ ┃ │   - ConfigChange            │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │ Triggers:                       │  ┃ ││
│  │ ┃        │                          ┃ │  │ ┃ │   - ImageChange                 │  ┃ ││
│  │ ┃        ↓                          ┃ │  │ ┃ │   - ConfigChange                │  ┃ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┃ │ Pod                         │  ┃ │  │ ┃        │                              ┃ ││
│  │ ┃ │ Status: Running             │  ┃ │  │ ┃        ↓                              ┃ ││
│  │ ┃ │ IP: 10.x.x.x                │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │ Node: worker-xyz            │  ┃ │  │ ┃ │ Pod                             │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │ Status: Running                 │  ┃ ││
│  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │  │ ┃ │ IP: 10.x.x.x                    │  ┃ ││
│  │                                        │  │ ┃ │ Node: worker-abc                │  ┃ ││
│  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┃ Networking                        ┃ │  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ││
│  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ │  │                                            ││
│  │ ┃                                    ┃ │  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ Networking                             ┃ ││
│  │ ┃ │ Service                     │  ┃ │  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ││
│  │ ┃ │ Name: winc-dashboard        │  ┃ │  │ ┃                                        ┃ ││
│  │ ┃ │ Type: ClusterIP             │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │ ClusterIP: 172.x.x.x        │  ┃ │  │ ┃ │ Service                         │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │ Name: winc-dashboard-poc        │  ┃ ││
│  │ ┃ │ Ports:                      │  ┃ │  │ ┃ │ Type: ClusterIP                 │  ┃ ││
│  │ ┃ │   - Port: 5000              │  ┃ │  │ ┃ │ ClusterIP: 172.x.x.x            │  ┃ ││
│  │ ┃ │     TargetPort: 5000        │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │     Protocol: TCP           │  ┃ │  │ ┃ │ Ports:                          │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │   - Port: 5000                  │  ┃ ││
│  │ ┃ │ Selector:                   │  ┃ │  │ ┃ │     TargetPort: 5000            │  ┃ ││
│  │ ┃ │   app: winc-dashboard       │  ┃ │  │ ┃ │     Protocol: TCP               │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃        │                          ┃ │  │ ┃ │ Selector:                       │  ┃ ││
│  │ ┃        ↓                          ┃ │  │ ┃ │   app: winc-dashboard-poc       │  ┃ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┃ │ Route                       │  ┃ │  │ ┃        │                              ┃ ││
│  │ ┃ │ Name: winc-dashboard        │  ┃ │  │ ┃        ↓                              ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │ Host:                       │  ┃ │  │ ┃ │ Route                           │  ┃ ││
│  │ ┃ │ winc-dashboard-winc-        │  ┃ │  │ ┃ │ Name: winc-dashboard-poc        │  ┃ ││
│  │ ┃ │ dashboard.apps.build10.ci.  │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │ devcluster.openshift.com    │  ┃ │  │ ┃ │ Host:                           │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │ winc-dashboard-poc-winc-        │  ┃ ││
│  │ ┃ │ TLS:                        │  ┃ │  │ ┃ │ dashboard-poc.apps.build10.ci.  │  ┃ ││
│  │ ┃ │   Termination: edge         │  ┃ │  │ ┃ │ devcluster.openshift.com        │  ┃ ││
│  │ ┃ │   InsecureEdgeTermination:  │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │   Redirect                  │  ┃ │  │ ┃ │ TLS:                            │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │   Termination: edge             │  ┃ ││
│  │ ┃ │ To:                         │  ┃ │  │ ┃ │   InsecureEdgeTermination:      │  ┃ ││
│  │ ┃ │   Service: winc-dashboard   │  ┃ │  │ ┃ │   Redirect                      │  ┃ ││
│  │ ┃ │   Port: 5000                │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │ To:                             │  ┃ ││
│  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │  │ ┃ │   Service: winc-dashboard-poc   │  ┃ ││
│  │                                        │  │ ┃ │   Port: 5000                    │  ┃ ││
│  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │  │ ┃ └─────────────────────────────────┘  ┃ ││
│  │ ┃ Storage                           ┃ │  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ││
│  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ │  │                                            ││
│  │ ┃                                    ┃ │  │ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ││
│  │ ┃ ┌─────────────────────────────┐  ┃ │  │ ┃ Storage                                ┃ ││
│  │ ┃ │ PersistentVolumeClaim       │  ┃ │  │ ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ││
│  │ ┃ │ Name: dashboard-data        │  ┃ │  │ ┃                                        ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ ┌─────────────────────────────────┐  ┃ ││
│  │ ┃ │ Size: 10Gi                  │  ┃ │  │ ┃ │ PersistentVolumeClaim           │  ┃ ││
│  │ ┃ │ AccessMode: ReadWriteOnce   │  ┃ │  │ ┃ │ Name: dashboard-data            │  ┃ ││
│  │ ┃ │ StorageClass: gp2           │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │                             │  ┃ │  │ ┃ │ Size: 10Gi                      │  ┃ ││
│  │ ┃ │ Mount Path: /data           │  ┃ │  │ ┃ │ AccessMode: ReadWriteOnce       │  ┃ ││
│  │ ┃ │ Contents:                   │  ┃ │  │ ┃ │ StorageClass: gp2               │  ┃ ││
│  │ ┃ │   - dashboard.db (SQLite)   │  ┃ │  │ ┃ │                                 │  ┃ ││
│  │ ┃ │   - dashboard.db-wal        │  ┃ │  │ ┃ │ Mount Path: /data               │  ┃ ││
│  │ ┃ │   - dashboard.db-shm        │  ┃ │  │ ┃ │ Contents:                       │  ┃ ││
│  │ ┃ └─────────────────────────────┘  ┃ │  │ ┃ │   - dashboard.db (SQLite)       │  ┃ ││
│  │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │  │ ┃ │   - dashboard.db-wal            │  ┃ ││
│  └────────────────────────────────────────┘  │ ┃ │   - dashboard.db-shm            │  ┃ ││
│                                               │ ┃ └─────────────────────────────────┘  ┃ ││
│                                               │ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ││
│                                               └────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────────────────┘

External Integrations:
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│  ReportPortal API    │────▶│  Production          │     │  Prow GCS            │
│  reportportal.       │     │  Dashboard           │     │  gcsweb-qe-private-  │
│  example.com         │     │                      │     │  deck-ci...          │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
                                                                    │
                                                                    ▼
                             ┌──────────────────────┐     ┌──────────────────────┐
                             │  Google Vertex AI    │◀────│  POC Dashboard       │
                             │  Claude API          │     │  (AI Analysis)       │
                             │  (us-east5)          │     └──────────────────────┘
                             └──────────────────────┘              │
                                                                    ▼
                             ┌──────────────────────┐     ┌──────────────────────┐
                             │  Jira API            │◀────│  POC Dashboard       │
                             │  issues.redhat.com   │     │  (Ticket Creation)   │
                             │  (REST API v3)       │     └──────────────────────┘
                             └──────────────────────┘
```

## Component Details

### Secrets

#### Production (winc-dashboard)
- **reportportal-secret**: ReportPortal API credentials
- **dashboard-secrets**: Feature flags (AI disabled)

#### POC (winc-dashboard-poc)
- **dashboard-secrets**: Contains all credentials
  - JIRA_API_TOKEN
  - JIRA_EMAIL
  - ANTHROPIC_VERTEX_PROJECT_ID
  - ANTHROPIC_VERTEX_REGION
  - ENABLE_AI_ANALYSIS=true

### Build Process

1. **Trigger**: Push to GitHub master branch
2. **Webhook**: GitHub sends POST to BuildConfig webhook URL
3. **BuildConfig**: Clones repo, builds Docker image
4. **ImageStream**: Stores built images with tags
5. **Deployment**: Auto-updates on new image (ImageChange trigger)
6. **Pod**: Rolling update replaces old pod

### Workloads

#### Deployment Configuration

**Replicas**: 1 (SQLite limitation)
**Strategy**: RollingUpdate
**Resources**:
- Requests: 256Mi memory, 100m CPU
- Limits: 1Gi memory, 500m CPU

**Containers**:
- Name: dashboard
- Port: 5000
- Mount: /data (from PVC)
- Environment: From secrets

### Networking

#### Service
- Type: ClusterIP (internal only)
- Port: 5000
- Selector: app label

#### Route
- TLS: Edge termination
- Insecure: Redirect to HTTPS
- Host: Auto-generated by OpenShift

### Storage

#### PersistentVolumeClaim
- Size: 10Gi
- AccessMode: ReadWriteOnce
- StorageClass: gp2 (AWS EBS)
- Mount: /data in pod
- Contents:
  - dashboard.db (main database)
  - dashboard.db-wal (Write-Ahead Log)
  - dashboard.db-shm (Shared Memory)

### External Links

#### Production Dashboard
- URL: https://winc-dashboard-winc-dashboard.apps.build10.ci.devcluster.openshift.com/
- Data Source: ReportPortal API
- Features: Basic metrics, test tracking

#### POC Dashboard
- URL: https://winc-dashboard-poc-winc-dashboard-poc.apps.build10.ci.devcluster.openshift.com/
- Data Source: Prow GCS (JUnit XML)
- Features: Full features including AI and Jira

#### GitHub Repository
- URL: https://github.com/redhat-community-ai-tools/ci-failure-tracker
- Branch: master
- Context Dir: dashboard

#### ReportPortal
- Used by: Production dashboard
- Authentication: API token in secret

#### Prow GCS
- URL: gcsweb-qe-private-deck-ci.apps.ci.l2s4.p1.openshiftapps.com
- Used by: POC dashboard
- Access: Public read

#### Google Vertex AI
- Region: us-east5
- Model: Claude Sonnet 4
- Used by: POC dashboard for AI analysis

#### Jira
- URL: https://issues.redhat.com (or https://redhat.atlassian.net)
- Project: WINC
- Authentication: API token (Basic Auth)
- Used by: POC dashboard for ticket creation

## Deployment Flow

```
Developer pushes code to GitHub
         │
         v
GitHub webhook triggers OpenShift BuildConfig
         │
         v
BuildConfig clones repo and builds Docker image
         │
         v
Image pushed to ImageStream with new tag
         │
         v
ImageChange trigger updates Deployment
         │
         v
Deployment starts rolling update
         │
         v
New pod created with new image
         │
         v
Service routes traffic to new pod
         │
         v
Old pod terminated after grace period
         │
         v
Deployment complete (build number incremented)
```

## Data Flow

```
CI Jobs (Prow/ReportPortal)
         │
         v
Data Collection (scheduled or manual)
         │
         v
Parse test results and extract data
         │
         v
Store in SQLite database (PVC)
         │
         v
User accesses dashboard via Route
         │
         v
Flask serves HTML/API endpoints
         │
         v
User clicks test for details
         │
         ├──> Load from database (Jira key, classification, AI analysis)
         │
         ├──> User can analyze with AI (Vertex AI)
         │
         ├──> User can create Jira ticket (Jira API)
         │
         └──> User can classify manually (save to database)
```

## Resource Monitoring

### Commands

```bash
# List all resources
oc get all -n winc-dashboard-poc

# View pod details
oc describe pod <pod-name>

# Check resource usage
oc top pods

# View events
oc get events --sort-by='.lastTimestamp'

# Check PVC usage
oc exec deployment/winc-dashboard-poc -- df -h /data

# View logs
oc logs deployment/winc-dashboard-poc --tail=100

# Follow logs
oc logs -f deployment/winc-dashboard-poc
```

### Metrics to Monitor

- Pod CPU/Memory usage
- PVC disk usage
- Build success rate
- Deployment rollout time
- Route availability
- API response times

## Security

### Network Policies

Default OpenShift network policies apply:
- Pods can communicate within namespace
- Route provides external HTTPS access
- Services are cluster-internal only

### RBAC

Project admin permissions required for:
- Creating/modifying deployments
- Managing secrets
- Viewing logs
- Triggering builds

### Secrets Management

All sensitive data stored in OpenShift Secrets:
- Never committed to Git
- Mounted as environment variables
- Encrypted at rest in etcd

## Troubleshooting Guide

### Build Not Triggered

Check:
1. Webhook configured in GitHub
2. Webhook secret matches BuildConfig
3. GitHub can reach OpenShift API
4. BuildConfig exists and is not paused

### Pod CrashLoopBackOff

Check:
1. Environment variables set correctly
2. PVC mounted successfully
3. Container logs for errors
4. Resource limits not exceeded

### Route Not Accessible

Check:
1. Route exists and has host
2. TLS termination configured
3. Service points to correct pod
4. Pod is running and ready

### Database Issues

Check:
1. PVC bound to pod
2. Disk space available
3. File permissions correct
4. WAL mode working

## Lecture Presentation Notes

### Key Points to Cover

1. **OpenShift Components**
   - Namespaces for environment isolation
   - BuildConfigs for CI/CD
   - Deployments for workload management
   - Services for internal networking
   - Routes for external access
   - PVCs for persistent storage

2. **GitOps Workflow**
   - Code changes trigger builds automatically
   - Rolling updates with zero downtime
   - Easy rollback to previous versions

3. **Secrets Management**
   - Secure credential storage
   - Environment variable injection
   - Never in source code

4. **Scalability Considerations**
   - Current: Single replica (SQLite)
   - Future: PostgreSQL for multi-replica

5. **Monitoring and Ops**
   - Built-in logging
   - Resource monitoring
   - Easy troubleshooting

6. **External Integrations**
   - ReportPortal for test data
   - Vertex AI for analysis
   - Jira for ticket management

### Demo Flow

1. Show live dashboards (Production and POC)
2. Make code change and push to GitHub
3. Watch build trigger and progress
4. See automatic deployment
5. Show new features live
6. Demonstrate rollback if needed

### Audience Questions to Prepare For

- Why two namespaces?
- Why SQLite instead of PostgreSQL?
- How is database backed up?
- What happens if pod crashes?
- How to scale to multiple replicas?
- Security considerations?
- Cost of AI analysis?
