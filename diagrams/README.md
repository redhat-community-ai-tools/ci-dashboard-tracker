# CI Failure Tracker - Architecture Diagrams

This directory contains Mermaid diagram definitions that can be rendered into high-quality PNG or SVG images for presentations and documentation.

## Available Diagrams

### 1. OpenShift Architecture (openshift-architecture.mmd)
**Purpose**: Complete OpenShift deployment showing all components
**Shows**:
- Two namespaces (Production and POC)
- Secrets, ConfigMaps
- BuildConfigs, ImageStreams
- Deployments, Pods, Services, Routes
- PersistentVolumeClaims
- External integrations (GitHub, ReportPortal, Prow GCS, Vertex AI, Jira)
- CI pipeline flow

**Best for**: Overview slides, architecture discussions

### 2. Deployment Flow (deployment-flow.mmd)
**Purpose**: Sequence diagram showing code-to-production flow
**Shows**:
- Developer push to GitHub
- Webhook trigger
- Build process
- Image creation
- Deployment rollout
- User access

**Best for**: CI/CD pipeline explanation, deployment process

### 3. Data Flow (data-flow.mmd)
**Purpose**: How test data flows through the system
**Shows**:
- CI jobs to data collectors
- Database storage and retrieval
- User interactions (AI analysis, Jira creation, classification)
- External API integrations

**Best for**: Data architecture, user workflow explanation

### 4. Component Architecture (component-architecture.mmd)
**Purpose**: Software architecture layers
**Shows**:
- Frontend layer (HTML, JS, CSS)
- API layer (Flask routes)
- Business logic (collectors, AI, Jira, metrics)
- Data layer (database, SQLite)
- External APIs

**Best for**: Code architecture, developer onboarding

### 5. Database Schema (database-schema.mmd)
**Purpose**: Entity-Relationship diagram
**Shows**:
- All database tables
- Column definitions
- Relationships between tables
- Primary and foreign keys

**Best for**: Database design discussion, data model explanation

## How to Render Diagrams

### Method 1: Mermaid Live Editor (Easiest)

1. Go to https://mermaid.live
2. Copy contents of any .mmd file
3. Paste into the editor
4. Diagram renders automatically
5. Click "Actions" -> "PNG" or "SVG" to download
6. Use in PowerPoint, Keynote, or Google Slides

### Method 2: VS Code Extension

1. Install "Markdown Preview Mermaid Support" extension
2. Open any .mmd file in VS Code
3. Right-click -> "Open Preview"
4. Take screenshot or use extension export feature

### Method 3: Command Line (mmdc)

Install mermaid-cli:
```bash
npm install -g @mermaid-js/mermaid-cli
```

Render to PNG:
```bash
mmdc -i openshift-architecture.mmd -o openshift-architecture.png -w 1920 -H 1080
```

Render to SVG (scalable):
```bash
mmdc -i openshift-architecture.mmd -o openshift-architecture.svg
```

Render all diagrams:
```bash
for file in *.mmd; do
  mmdc -i "$file" -o "${file%.mmd}.png" -w 1920 -H 1080
done
```

### Method 4: GitHub/GitLab Markdown

GitHub and GitLab automatically render Mermaid diagrams in Markdown files.

Create a markdown file:
````markdown
# Architecture

```mermaid
graph TB
    ...mermaid code...
```
````

View on GitHub - diagram renders automatically.

### Method 5: Online Tools

- **Mermaid Live**: https://mermaid.live (recommended)
- **Kroki**: https://kroki.io
- **Diagram.codes**: https://www.diagram.codes/d/mermaid

## Recommended Settings for Presentations

### For PowerPoint/Keynote (1920x1080)
```bash
mmdc -i diagram.mmd -o diagram.png -w 1920 -H 1080 -b white
```

### For Print/High Quality (4K)
```bash
mmdc -i diagram.mmd -o diagram.png -w 3840 -H 2160 -b white
```

### For SVG (Scalable - Best Quality)
```bash
mmdc -i diagram.mmd -o diagram.svg
```
SVG files scale to any size without quality loss.

## Customization

### Change Colors

Edit the style statements in .mmd files:

```mermaid
style ProdSecrets fill:#ff9999    # Light red for secrets
style POCPVC fill:#99ccff          # Light blue for storage
style GitHub fill:#ffcc99          # Light orange for external
```

Color codes:
- Red (#ff9999): Secrets/sensitive data
- Blue (#99ccff): Storage/persistence
- Orange (#ffcc99): Build/CI components
- Green (#ccffcc): Data sources
- Purple (#ffccff): External APIs

### Change Layout

Mermaid supports different graph directions:
- `graph TB` - Top to Bottom (default)
- `graph LR` - Left to Right
- `graph BT` - Bottom to Top
- `graph RL` - Right to Left

### Add/Remove Components

Edit .mmd files directly:
1. Add nodes: `NodeName[Display Text]`
2. Add connections: `Node1 --> Node2`
3. Add labels: `Node1 -->|Label| Node2`

## Tips for Lectures

### Slide 1: OpenShift Architecture
Use: `openshift-architecture.mmd`
- Shows complete system overview
- All components labeled
- Color-coded by type

### Slide 2: Deployment Pipeline
Use: `deployment-flow.mmd`
- Sequence diagram for step-by-step flow
- Shows timing and order
- Good for CI/CD explanation

### Slide 3: How Data Flows
Use: `data-flow.mmd`
- User journey through system
- Shows all integrations
- Good for feature explanation

### Slide 4: Software Architecture
Use: `component-architecture.mmd`
- Technical architecture
- Layer separation
- Good for developers

### Slide 5: Database Design
Use: `database-schema.mmd`
- Table relationships
- Data model
- Good for data discussions

## Exporting Multiple Formats

Create presentation-ready images:

```bash
# PNG for PowerPoint
mmdc -i openshift-architecture.mmd -o slides/slide1-architecture.png -w 1920 -H 1080 -b white

# SVG for web/print
mmdc -i openshift-architecture.mmd -o web/architecture.svg

# Both formats
mmdc -i openshift-architecture.mmd -o openshift-architecture.png -w 1920 -H 1080
mmdc -i openshift-architecture.mmd -o openshift-architecture.svg
```

## Updating Diagrams

To keep diagrams in sync with code:

1. Edit .mmd files when architecture changes
2. Re-render to PNG/SVG
3. Update presentation slides
4. Commit both .mmd and rendered images to Git

## Including in Documentation

### Markdown
````markdown
![Architecture](diagrams/openshift-architecture.svg)
````

### HTML
```html
<img src="diagrams/openshift-architecture.svg" alt="Architecture" width="100%">
```

### LaTeX
```latex
\includegraphics[width=\textwidth]{diagrams/openshift-architecture.pdf}
```

## Troubleshooting

### "mmdc command not found"
Install mermaid-cli:
```bash
npm install -g @mermaid-js/mermaid-cli
```

### Large diagrams don't render
Increase viewport size:
```bash
mmdc -i diagram.mmd -o diagram.png -w 3840 -H 2160
```

### Text is too small
Increase width and height proportionally:
```bash
mmdc -i diagram.mmd -o diagram.png -w 2560 -H 1440
```

### Syntax errors
Validate at https://mermaid.live before rendering

## Resources

- Mermaid Documentation: https://mermaid.js.org
- Mermaid Live Editor: https://mermaid.live
- Mermaid CLI: https://github.com/mermaid-js/mermaid-cli
- Examples: https://mermaid.js.org/ecosystem/integrations.html

## Quick Reference

```bash
# Install CLI
npm install -g @mermaid-js/mermaid-cli

# Render PNG
mmdc -i input.mmd -o output.png -w 1920 -H 1080

# Render SVG
mmdc -i input.mmd -o output.svg

# Batch render
for f in *.mmd; do mmdc -i "$f" -o "${f%.mmd}.png"; done

# White background
mmdc -i input.mmd -o output.png -b white

# Transparent background
mmdc -i input.mmd -o output.png -b transparent
```
