# Diagrams for Lecture - Quick Reference

All diagrams converted to PNG and SVG formats, ready for your presentation.

## Available Formats

### Standard Resolution (1920x1080) - For PowerPoint/Keynote
Located in: `diagrams/` directory

**System Architecture:**
- **openshift-architecture.png** (237 KB)
- **deployment-flow.png** (127 KB)
- **data-flow.png** (93 KB)
- **component-architecture.png** (144 KB)
- **database-schema.png** (208 KB)

**AI Analysis Feature:**
- **ai-analysis-flow.png** (156 KB) - Sequence diagram with user flow
- **ai-analysis-simple.png** (135 KB) - Decision flow and classification
- **ai-analysis-components.png** (133 KB) - Component block diagram

### High Resolution (3840x2160 4K) - For Large Displays/Print
Located in: `diagrams/high-res/` directory
Same files, 4K resolution for maximum quality

### SVG (Scalable Vector Graphics) - Best Quality, Any Size
Located in: `diagrams/svg/` directory
Scale to any size without quality loss - best for professional presentations

## Recommended Usage for Your Lecture

### Slide 1: System Overview
**Use**: `openshift-architecture.png` (237 KB)
**Shows**:
- Complete OpenShift deployment
- Namespace with all components
- BuildConfig, Deployment, Service, Route
- CronJob for scheduled collection
- PersistentVolume for database
- All external integrations (GitHub, Prow GCS, Vertex AI, Jira)
- Secrets and ConfigMaps

**Best for**: "Here's the complete system architecture"

### Slide 2: CI/CD Pipeline
**Use**: `deployment-flow.png` (127 KB)
**Shows**:
- Developer pushes code to GitHub
- Webhook triggers build
- Image creation and deployment
- Rolling update process
- CronJob scheduled collection
- User access flow

**Best for**: "How code gets from GitHub to production"

### Slide 3: Data Flow
**Use**: `data-flow.png` (93 KB)
**Shows**:
- CI jobs produce test results
- CronJob collects data every 6 hours
- Storage in SQLite database
- User interactions (AI analysis, Jira tickets, classification)
- Integration with Vertex AI and Jira

**Best for**: "How test data flows through the system"

### Slide 4: Software Architecture
**Use**: `component-architecture.png` (144 KB)
**Shows**:
- Frontend layer (HTML, JavaScript, CSS)
- API layer (Flask routes)
- Business logic (collectors, AI, Jira, metrics)
- Data layer (database)
- External API integrations

**Best for**: "Technical architecture for developers"

### Slide 5: Database Design
**Use**: `database-schema.png` (208 KB)
**Shows**:
- All database tables
- Relationships between tables
- Primary and foreign keys
- Column definitions

**Best for**: "How we store and relate test data"

### Slide 6: AI Analysis Feature (Choose One)

#### Option A: Sequence Flow
**Use**: `ai-analysis-flow.png` (156 KB)
**Shows**:
- User opens test detail modal
- Auto-loads existing AI analysis from database
- Fresh analysis flow (if needed)
- Request/response sequence with Vertex AI
- Database caching
- Cost information

**Best for**: "Step-by-step: how AI analysis works"

#### Option B: Decision Flow
**Use**: `ai-analysis-simple.png` (135 KB)
**Shows**:
- Check for cached analysis
- Data preparation
- Vertex AI integration
- Classification types (product bug, automation bug, system issue, transient, to investigate)
- Analysis result generation
- Database storage

**Best for**: "AI classification logic and decision tree"

#### Option C: Component View
**Use**: `ai-analysis-components.png` (133 KB)
**Shows**:
- User interface components
- Backend API and analyzer
- Database caching
- Vertex AI external service
- Data flow between components
- Auto-load vs fresh analysis paths

**Best for**: "AI feature architecture at a glance"

## File Sizes Reference

### Standard Resolution (1920x1080)
Perfect for most presentations, good balance of quality and file size.

| Diagram | Size | Best For |
|---------|------|----------|
| openshift-architecture.png | 237 KB | System overview |
| database-schema.png | 208 KB | Data model discussion |
| ai-analysis-flow.png | 156 KB | AI analysis sequence |
| component-architecture.png | 144 KB | Software layers |
| ai-analysis-simple.png | 135 KB | AI decision flow |
| ai-analysis-components.png | 133 KB | AI components |
| deployment-flow.png | 127 KB | CI/CD explanation |
| data-flow.png | 93 KB | Data pipeline |

### High Resolution (3840x2160 4K)
Use for large displays, printed materials, or when zooming in during presentation.
Same file sizes as standard (Mermaid renders clean regardless of resolution).

### SVG (Scalable)
Smallest file sizes, infinite scalability. Best choice for professional presentations.
Scale to any size without pixelation.

## How to Use in PowerPoint/Keynote

### PowerPoint
1. Insert > Pictures > This Device
2. Navigate to `diagrams/` folder
3. Select PNG file
4. Resize as needed (maintains quality up to 1920x1080)

For better quality:
- Use SVG files (Insert > Pictures > select .svg)
- Or use high-res PNG from `high-res/` folder

### Keynote
1. Drag PNG or SVG directly onto slide
2. Resize as needed
3. SVG files scale perfectly to any size

### Google Slides
1. Insert > Image > Upload from computer
2. Select PNG file
3. Resize on slide

## Color Legend

All diagrams use consistent color coding:

- **Red (#ff9999)**: Secrets and sensitive data
- **Blue (#99ccff)**: Storage and persistence (PVC, Database)
- **Orange (#ffcc99)**: Build and CI components (GitHub, BuildConfig)
- **Green (#ccffcc)**: Data sources (Prow GCS, CI Jobs)
- **Purple (#ffccff)**: External APIs (Vertex AI, Jira)
- **Yellow (#ffffcc)**: Scheduled tasks (CronJob)

## Quick Tips

1. **For projectors**: Use standard resolution PNG (1920x1080)
2. **For large displays**: Use high-res PNG (3840x2160)
3. **For print materials**: Use SVG or high-res PNG
4. **For web**: Use SVG (smallest file, perfect scaling)
5. **For PDFs**: SVG converts best to PDF format

## Regenerating Diagrams

If you need to modify any diagram:

1. Edit the `.mmd` file in text editor
2. Run: `./render-all.sh` (regenerates all formats)
3. Or manually: `mmdc -i diagram.mmd -o diagram.png -w 1920 -H 1080 -b white`

## File Locations Summary

```
diagrams/
├── *.mmd                           # Source files (editable)
├── *.png                           # Standard resolution (1920x1080)
├── high-res/
│   └── *.png                       # High resolution (3840x2160)
└── svg/
    └── *.svg                       # Scalable vector graphics
```

## Recommended Presentation Flow

1. **Start**: openshift-architecture.png - Show complete system
2. **Build process**: deployment-flow.png - Explain CI/CD
3. **Data pipeline**: data-flow.png - Show how data moves
4. **Deep dive**: component-architecture.png - Technical details
5. **Data model**: database-schema.png - Show database design

Total presentation time: 30-45 minutes with these 5 slides + explanations.
