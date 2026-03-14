---
name: project-sharing
description: Prepare organized packages of project files for sharing at different levels - from summary PDFs to fully reproducible archives. Creates copies with cleaned notebooks, documentation, and appropriate file selection. After creating sharing package, all work continues in the main project directory.
version: 1.1.0
---

# Project Sharing and Output Preparation

Expert guidance for preparing project outputs for sharing with collaborators, reviewers, or repositories. Creates organized packages at different sharing levels while preserving your working directory.

**Supporting files in this directory:**
- [notebook-streamlining.md](notebook-streamlining.md) - Streamlining notebooks for sharing and the abridge option
- [quality-assurance.md](quality-assurance.md) - QA procedures, best practices, checklists, and dependency management
- [common-scenarios.md](common-scenarios.md) - Sharing scenarios (collaborators, manuscripts, archival, repositories) and example scripts
- [cleanup-and-deprecation.md](cleanup-and-deprecation.md) - Correcting cleanup mistakes and deprecating redundant notebooks

## When to Use This Skill

- Sharing analysis results with collaborators
- Preparing supplementary materials for publications
- Creating reproducible research packages
- Archiving completed projects
- Handoff to other researchers
- Submitting to data repositories

## Core Principles

1. **Work on copies** - Never modify the working directory
2. **Choose appropriate level** - Match sharing depth to audience needs
3. **Document everything** - Include clear guides and metadata
4. **Clean before sharing** - Remove debug code, clear outputs, anonymize if needed
5. **Make it reproducible** - Include dependencies and instructions
6. **CRITICAL: After creating sharing folder, all future work happens in the main project directory, NOT in the sharing folder** - Sharing folders are read-only snapshots

---

## Three Sharing Levels

### Level 1: Summary Only

**Purpose:** Quick sharing for presentations, reports, or high-level review

**What to include:**
- PDF export of final notebook(s)
- Final data/results (CSV, Excel, figures) - optional
- Brief README

**Use when:**
- Sharing results with non-technical stakeholders
- Presentations or talks
- Quick review without reproduction needs
- Space/time constraints

**Structure:**
```
shared-summary/
├── README.md                          # Brief overview
├── analysis-YYYY-MM-DD.pdf           # Notebook as PDF
└── results/
    ├── figures/
    │   ├── fig1-main-result.png
    │   └── fig2-comparison.png
    └── tables/
        └── summary-statistics.csv
```

---

### Level 2: Reproducible

**Purpose:** Enable others to reproduce your analysis from processed data

**What to include:**
- Analysis notebooks (.ipynb) - cleaned
- Scripts for figure generation
- Processed/analysis-ready data
- Requirements file (requirements.txt or environment.yml)
- Detailed README with instructions

**Use when:**
- Sharing with collaborating researchers
- Peer review / manuscript supplementary materials
- Teaching or tutorials
- Standard collaboration needs

**Structure:**

For standard project structures, see the **folder-organization** skill. Reproducible packages should include:
- Processed data (in `data/processed/`)
- Cleaned notebooks (in `notebooks/`) with outputs cleared
- Scripts (in `scripts/`)
- Environment specification (`environment.yml` or `requirements.txt`)
- Documentation (`README.md`, `MANIFEST.md`)

```
shared-reproducible/
├── README.md                          # Setup and reproduction instructions
├── MANIFEST.md                        # File descriptions
├── environment.yml                    # Conda environment OR requirements.txt
├── notebooks/                         # Cleaned notebooks
├── scripts/                           # Standalone scripts
└── data/
    └── processed/                     # Analysis-ready data
```

---

### Level 3: Full Traceability

**Purpose:** Complete transparency from raw data through all processing steps

**What to include:**
- Starting/raw data
- All processing scripts and notebooks
- All intermediate files
- Final results
- Complete documentation
- Full dependency specification

**Use when:**
- Archiving for future reference
- Regulatory compliance
- High-stakes reproducibility (clinical, policy)
- Data repository submission (Zenodo, Dryad, etc.)
- Complete project handoff

**Structure:**

For standard project structures, see the **folder-organization** skill. Full traceability packages should include complete data hierarchy:

```
shared-complete/
├── README.md                          # Complete project guide
├── MANIFEST.md                        # Comprehensive file listing
├── environment.yml
├── data/
│   ├── raw/                          # Original, unmodified data
│   ├── intermediate/                 # Processing steps
│   └── processed/                    # Final analysis-ready
├── scripts/                           # All processing scripts
├── notebooks/                         # All notebooks (exploratory + final)
├── results/                           # All outputs
│   ├── figures/
│   ├── tables/
│   └── supplementary/
└── documentation/                     # Complete documentation
    ├── methods.md
    ├── changelog.md
    └── data-dictionary.md
```

---

## Preparation Workflow

### Step 1: Ask User for Sharing Level

**Questions to determine level:**

```
Which sharing level do you need?

1. Summary Only - PDF + final results (quick sharing)
2. Reproducible - Notebooks + scripts + data (standard sharing)
3. Full Traceability - Everything from raw data (archival/compliance)

Additional questions:
- Who is the audience? (colleagues, reviewers, public)
- Are there size constraints?
- Any sensitive data to handle?
- Timeline for sharing?
```

### Step 2: Identify Files to Include

**Level 1 - Summary:**
- Main analysis notebook(s)
- Key figures (publication-quality)
- Summary tables/statistics

**Level 2 - Reproducible:**
- All analysis notebooks (not exploratory)
- Figure generation scripts
- Processed/cleaned data
- Environment specification
- Any utility functions/modules

**Level 3 - Full:**
- Raw data (or links if too large)
- All processing scripts
- All notebooks (including exploratory)
- All intermediate files
- Complete documentation

### Step 3: Create Sharing Directory

```bash
# Create dated directory
SHARE_DIR="shared-$(date +%Y%m%d)-[level]"
mkdir -p "$SHARE_DIR"
```

### Step 4: Copy and Clean Files

**For notebooks (.ipynb):**

```python
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

def clean_notebook(input_path, output_path):
    """Clean notebook: clear outputs, remove debug cells."""
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    clear_output = ClearOutputPreprocessor()
    nb, _ = clear_output.preprocess(nb, {})

    nb.cells = [cell for cell in nb.cells
                if 'debug' not in cell.metadata.get('tags', [])
                and 'remove' not in cell.metadata.get('tags', [])]

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)
```

**For data files:** Copy as-is for small files; compress large files; check for sensitive information.

**For scripts:** Remove debugging code; add docstrings if missing; ensure paths are relative.

For notebook streamlining and the abridge option, see [notebook-streamlining.md](notebook-streamlining.md).

### Step 4.5: Verify and Fix File Paths

**Problem**: Notebooks and scripts with broken file paths will fail when shared.

For complete path verification procedures, automated checking scripts, and correction patterns, see the **folder-organization** skill.

| Breaks when shared | Works when shared |
|---------------------|-------------------|
| `/Users/yourname/project/data.csv` | `data/data.csv` |
| `C:\Users\yourname\project\fig.png` | `figures/fig.png` |
| `/absolute/path/to/results/` | `results/` |

**Quick check commands:**
```bash
# Check for absolute paths in notebooks
grep -l "/Users/" *.ipynb
grep -l "C:\\\\" *.ipynb
```

### Step 5: Generate Documentation

#### README.md Template

```markdown
# Project: [Project Name]

**Date:** YYYY-MM-DD
**Author:** [Your Name]
**Sharing Level:** [Summary/Reproducible/Full]

## Overview
Brief description of the project and analysis.

## Contents
See MANIFEST.md for detailed file descriptions.

## Requirements
[For Reproducible/Full levels]
- Python 3.X
- See environment.yml for dependencies

## Setup
\`\`\`bash
conda env create -f environment.yml
conda activate project-name
\`\`\`

## Reproduction Steps
[For Reproducible/Full levels]
1. [Description of first step]

## Data Sources
[For Full level]
- Dataset A: [Source, download date, version]

## Contact
[Your email or preferred contact]

## License
[If applicable - e.g., CC BY 4.0, MIT]
```

#### MANIFEST.md Template

```markdown
# File Manifest
Generated: YYYY-MM-DD

## File Descriptions

### Notebooks
- \`notebooks/01-data-processing.ipynb\` - Initial data loading and cleaning
- \`notebooks/02-analysis.ipynb\` - Main statistical analysis

### Data
- \`data/processed/cleaned_data.csv\` - Quality-controlled dataset (N=XXX samples)

### Scripts
- \`scripts/generate_figures.py\` - Automated figure generation

### Results
- \`results/figures/fig1-main.png\` - Main result showing [description]
```

### Step 6: Handle Sensitive Data

**Check for:** PII, access credentials, proprietary data, institutional restrictions, patient/subject identifiers.

**Strategies:**
1. **Anonymize** - Remove or hash identifiers
2. **Exclude** - Don't include sensitive files
3. **Aggregate** - Share summary statistics only
4. **Document restrictions** - Note what's excluded and why

### Step 7: Package and Compress

```bash
# For smaller packages (<100MB)
zip -r shared-YYYYMMDD.zip shared-YYYYMMDD/

# For larger packages
tar -czf shared-YYYYMMDD.tar.gz shared-YYYYMMDD/
```

### Step 8: Return to Working Directory

**IMPORTANT: After creating the sharing package, always work in the main project directory.**

The sharing folder is a **snapshot for distribution only**. Any future development, analysis, or modifications should happen in your original working directory.

```bash
cd /path/to/main/project  # Return to working directory
pwd                        # Verify location
# Continue work here, NOT in shared-YYYYMMDD/
```

---

## Integration with Other Skills

**Works well with:**
- **folder-organization** - Ensures source project is well-organized before sharing
- **jupyter-notebook-analysis** - Creates notebooks that are share-ready
- **managing-environments** - Documents dependencies properly

**Before using this skill:**
1. Organize working directory (folder-organization)
2. Finalize analysis (jupyter-notebook-analysis)
3. Document environment (managing-environments)

**After using this skill:**
1. Test package in clean environment
2. Share via appropriate channel (email, repository, cloud storage)
3. Keep archived copy for reference

For quality assurance procedures and checklists, see [quality-assurance.md](quality-assurance.md).
For common sharing scenarios and example scripts, see [common-scenarios.md](common-scenarios.md).
For handling cleanup mistakes and notebook deprecation, see [cleanup-and-deprecation.md](cleanup-and-deprecation.md).

---

## Summary

**Key principles for project sharing:**

1. **Choose the right level** - Match sharing depth to audience needs
2. **Copy, don't move** - Preserve your working directory
3. **Clean thoroughly** - Remove debug code, clear outputs
4. **Document everything** - README + MANIFEST minimum
5. **Check sensitivity** - Anonymize or exclude as needed
6. **Test before sharing** - Run in clean environment
7. **Package properly** - Compress and document contents
8. **Work in main directory** - After creating sharing package, ALL future work happens in the original project directory, NOT in the sharing folder

**Remember:** Good sharing practices benefit both collaborators and your future self!

---

## CRITICAL Reminder for Claude

**After creating any sharing package:**

1. **Always return to the main project directory**
2. **Never work in `shared-*/` directories** - These are read-only snapshots
3. **All future edits, analysis, and development happen in the original working directory**
4. **Sharing folders are for distribution only, not active development**

If the user asks to modify files, always check the current directory and ensure you're working in the main project location, not in a sharing package.
