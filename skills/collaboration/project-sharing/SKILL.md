---
name: project-sharing
description: Prepare organized packages of project files for sharing at different levels - from summary PDFs to fully reproducible archives. Creates copies with cleaned notebooks, documentation, and appropriate file selection. After creating sharing package, all work continues in the main project directory.
version: 1.1.0
---

# Project Sharing and Output Preparation

Expert guidance for preparing project outputs for sharing with collaborators, reviewers, or repositories. Creates organized packages at different sharing levels while preserving your working directory.

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
6. **⚠️ CRITICAL: After creating sharing folder, all future work happens in the main project directory, NOT in the sharing folder** - Sharing folders are read-only snapshots

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
```
shared-reproducible/
├── README.md                          # Setup and reproduction instructions
├── MANIFEST.md                        # File descriptions
├── environment.yml                    # Conda environment OR requirements.txt
├── notebooks/
│   ├── 01-data-processing.ipynb      # Cleaned, outputs cleared
│   ├── 02-analysis.ipynb
│   └── 03-visualization.ipynb
├── scripts/
│   ├── generate_figures.py           # Standalone scripts
│   └── utils.py
└── data/
    ├── processed/
    │   ├── cleaned_data.csv
    │   └── processed_results.tsv
    └── README.md                      # Data provenance
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
```
shared-complete/
├── README.md                          # Complete project guide
├── MANIFEST.md                        # Comprehensive file listing
├── environment.yml
├── data/
│   ├── raw/                          # Original, unmodified data
│   │   ├── sample_A_reads.fastq.gz
│   │   └── README.md                 # Data source, download date
│   ├── intermediate/                 # Processing steps
│   │   ├── 01-filtered/
│   │   ├── 02-aligned/
│   │   └── README.md
│   └── processed/                    # Final analysis-ready
│       └── final_dataset.csv
├── scripts/
│   ├── 01-download-data.sh
│   ├── 02-quality-control.py
│   ├── 03-filtering.py
│   ├── 04-analysis.py
│   └── utils/
├── notebooks/
│   ├── exploratory/                  # Early exploration
│   └── final/                        # Publication analyses
├── results/
│   ├── figures/
│   ├── tables/
│   └── supplementary/
└── documentation/
    ├── methods.md                    # Detailed methodology
    ├── changelog.md                  # Processing decisions
    └── data-dictionary.md            # Variable definitions
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

**For each level, identify:**

**Level 1 - Summary:**
- Main analysis notebook(s)
- Key figures (publication-quality)
- Summary tables/statistics
- Optional: Final processed dataset

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

# Create subdirectories based on level
# ... appropriate structure from above
```

### Step 4: Copy and Clean Files

**For notebooks (.ipynb):**

```python
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

def clean_notebook(input_path, output_path):
    """Clean notebook: clear outputs, remove debug cells."""

    # Read notebook
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    # Clear outputs
    clear_output = ClearOutputPreprocessor()
    nb, _ = clear_output.preprocess(nb, {})

    # Remove cells tagged as 'debug' or 'remove'
    nb.cells = [cell for cell in nb.cells
                if 'debug' not in cell.metadata.get('tags', [])
                and 'remove' not in cell.metadata.get('tags', [])]

    # Write cleaned notebook
    with open(output_path, 'w') as f:
        nbformat.write(nb, f)
```

**For data files:**
- Copy as-is for small files
- Consider compression for large files
- Check for sensitive information

**For scripts:**
- Remove debugging code
- Add docstrings if missing
- Ensure paths are relative

### Step 4.5: CRITICAL - Verify File Paths

**Problem**: Notebooks and scripts with absolute paths will break when shared.

**Check paths in notebooks:**
```python
# Search for absolute paths in notebook
import json
with open('analysis.ipynb', 'r') as f:
    nb = json.load(f)

abs_paths = []
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        source = ''.join(cell['source'])
        # Look for absolute paths
        if '/Users/' in source or 'C:\\' in source:
            abs_paths.append(source[:100])

if abs_paths:
    print("⚠️  Found absolute paths:")
    for path in abs_paths[:5]:
        print(f"  {path}")
```

**Common path issues:**

| ❌ Breaks when shared | ✅ Works when shared |
|---------------------|-------------------|
| `/Users/yourname/project/data.csv` | `data/data.csv` |
| `C:\Users\yourname\project\fig.png` | `figures/fig.png` |
| `/absolute/path/to/results/` | `results/` |
| `Image('/Users/you/notebook.png')` | `Image('figures/notebook.png')` |

**Fix absolute paths before copying:**
```python
# Find and list absolute paths
grep -r "/Users/" *.ipynb *.py
grep -r "C:\\\\" *.ipynb *.py

# Convert to relative paths (manual or scripted)
# Example: /Users/yourname/project/data/ → data/
```

**Verification checklist:**
1. ✅ All `pd.read_csv()` use relative paths
2. ✅ All `Image()` displays use relative paths
3. ✅ All figure saves use relative paths
4. ✅ All data file references use relative paths
5. ✅ Test notebook runs from different directory

**Test before sharing:**
```bash
# Copy to temp location
cp -r project /tmp/test-project
cd /tmp/test-project

# Try to run notebook
jupyter notebook analysis.ipynb

# Check if images load
# Check if data files found
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
# Create environment
conda env create -f environment.yml
conda activate project-name
\`\`\`

## Reproduction Steps

[For Reproducible/Full levels]

1. [Description of first step]
   \`\`\`bash
   jupyter notebook notebooks/01-analysis.ipynb
   \`\`\`

2. [Description of second step]

## Data Sources

[For Full level]
- Dataset A: [Source, download date, version]
- Dataset B: [Source, download date, version]

## Contact

[Your email or preferred contact]

## License

[If applicable - e.g., CC BY 4.0, MIT]
```

#### MANIFEST.md Template

```markdown
# File Manifest

Generated: YYYY-MM-DD

## Directory Structure

\`\`\`
shared-YYYYMMDD/
├── README.md                  - Project overview and setup
├── MANIFEST.md               - This file
[... complete tree ...]
\`\`\`

## File Descriptions

### Notebooks

- \`notebooks/01-data-processing.ipynb\` - Initial data loading and cleaning
- \`notebooks/02-analysis.ipynb\` - Main statistical analysis
- \`notebooks/03-visualization.ipynb\` - Figure generation for publication

### Data

- \`data/processed/cleaned_data.csv\` - Quality-controlled dataset (N=XXX samples)
  - Columns: [list key columns]
  - Missing values handled by [method]

### Scripts

- \`scripts/generate_figures.py\` - Automated figure generation
  - Usage: \`python generate_figures.py --input data/processed/cleaned_data.csv\`

### Results

- \`results/figures/fig1-main.png\` - Main result showing [description]
- \`results/tables/summary_stats.csv\` - Descriptive statistics

[Continue for all files...]
```

### Step 6: Handle Sensitive Data

**Check for sensitive information:**
- Personal identifiable information (PII)
- Access credentials (API keys, passwords)
- Proprietary data
- Institutional data with sharing restrictions
- Patient/subject identifiers

**Strategies:**
1. **Anonymize** - Remove or hash identifiers
2. **Exclude** - Don't include sensitive files
3. **Aggregate** - Share summary statistics only
4. **Document restrictions** - Note what's excluded and why

**Example anonymization:**
```python
import hashlib

def anonymize_ids(df, id_column='subject_id'):
    """Replace IDs with hashed values."""
    df[id_column] = df[id_column].apply(
        lambda x: hashlib.sha256(str(x).encode()).hexdigest()[:8]
    )
    return df
```

### Step 7: Package and Compress

**For smaller packages (<100MB):**
```bash
# Create zip archive
zip -r shared-YYYYMMDD.zip shared-YYYYMMDD/
```

**For larger packages:**
```bash
# Create tar.gz (better compression)
tar -czf shared-YYYYMMDD.tar.gz shared-YYYYMMDD/

# Or split into parts if very large
tar -czf - shared-YYYYMMDD/ | split -b 1G - shared-YYYYMMDD.tar.gz.part
```

**Document package contents:**
- Total size
- Number of files
- Compression method
- How to extract

### Step 8: Return to Working Directory

**⚠️ IMPORTANT: After creating the sharing package, always work in the main project directory.**

The sharing folder is a **snapshot for distribution only**. Any future development, analysis, or modifications should happen in your original working directory, not in the `shared-*/` folder.

**Claude should:**
- Change directory back to main project: `cd ..` (if needed)
- Confirm working directory: `pwd`
- Continue all work in the original project location
- Treat sharing folders as read-only archives

**Example:**
```bash
# After creating sharing package
cd /path/to/main/project  # Return to working directory
pwd                        # Verify location
# Continue work here, NOT in shared-YYYYMMDD/
```

---

## Streamlining Notebooks for Sharing

When preparing Jupyter notebooks for sharing packages, remove verbose content while preserving essential analysis:

### Content to Remove

1. **Historical information**:
   - "Comparison to previous analysis" sections
   - "Earlier version" notes
   - Revision history and change logs
   - Update summaries

2. **Excessive methodological detail**:
   - Extended reconciliation discussions
   - Overly detailed interpretations (>2000 chars)
   - Redundant technical notes
   - Multiple paragraphs explaining the same concept

3. **Verbose analysis sections**:
   - Repetitive explanations
   - Extended discussions of minor points
   - Implementation details better suited for code comments

### Content to Keep

1. **Essential analysis**:
   - Figure displays and captions
   - Statistical results
   - Key findings summaries

2. **Core documentation**:
   - Methods sections
   - Conclusions
   - Data source descriptions
   - Quality metrics

3. **Reproduction information**:
   - Setup instructions
   - Script execution order
   - Environment requirements

### Automated Streamlining Script

```python
import nbformat
import re

def should_remove_cell(cell):
    """Identify verbose cells to remove."""
    if cell.cell_type != 'markdown':
        return False

    source = cell.source.lower()

    # Patterns indicating verbose content
    verbose_patterns = [
        'comparison to.*previous',
        'reconciliation with',
        'why focus on',
        'methodological.*note.*filtering',
        'interpretation of the significant difference',
    ]

    for pattern in verbose_patterns:
        if re.search(pattern, source):
            return True

    # Remove overly long cells without figures
    if len(source) > 2000 and 'figure' not in source.lower():
        return True

    return False

def streamline_notebook(input_path, output_path):
    """Remove verbose content from notebook."""
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    # Filter out verbose cells
    nb.cells = [cell for cell in nb.cells if not should_remove_cell(cell)]

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)
```

### Expected Results

- **Cell reduction**: 7-15% of cells typically removed
- **Size reduction**: 15-20% smaller HTML files
- **Quality improvement**: More professional, focused presentation
- **No loss**: All essential content preserved

### Verification Checklist

After streamlining:
- [ ] All figures still referenced
- [ ] Statistical results present
- [ ] Methods sections complete
- [ ] Conclusions included
- [ ] HTML conversion successful
- [ ] No broken cells or formatting

---

## Quality Assurance for Sharing Packages

After creating a sharing package, verify completeness:

### 1. Structure Verification

```bash
# Check directory structure
find package/ -type d | sort

# Expected structure:
# package/
# ├── notebooks/
# ├── scripts/
# ├── data/
# ├── figures/
# └── documentation/
```

### 2. File Count Verification

```bash
# Count files by type
echo "Notebooks: $(find package/ -name '*.ipynb' | wc -l)"
echo "Scripts: $(find package/ -name '*.py' | wc -l)"
echo "Data files: $(find package/ -name '*.csv' | wc -l)"
echo "Figures: $(find package/ -name '*.png' | wc -l)"
echo "Documentation: $(find package/ -name '*.md' | wc -l)"
```

### 3. Path Verification

Test that notebook paths work:
```bash
cd package/notebooks/
# Try to convert notebooks (tests paths)
for nb in *.ipynb; do
    jupyter nbconvert --to html "$nb" --output /tmp/test.html 2>&1 | \
        grep -E "(Error|FileNotFound)" && echo "ERROR in $nb" || echo "OK: $nb"
done
```

### 4. Documentation Checklist

Verify documentation is complete:
- [ ] README.md with setup instructions
- [ ] MANIFEST.md listing all files
- [ ] Environment specification (environment.txt or .yml)
- [ ] License file (if applicable)
- [ ] Citation information
- [ ] Data source documentation

### 5. Create Verification Notes

Document package status:
```markdown
# VERIFICATION_NOTES.md

## Package Contents
- Notebooks: X files
- Scripts: Y files
- Data: Z MB
- Figures: N/M present

## Known Limitations
- Missing figures can be generated using scripts X, Y, Z
- Platform-specific environment file

## Testing
- [ ] Notebooks load correctly
- [ ] Paths work from notebooks/
- [ ] HTML conversion successful
- [ ] All essential files present
```

### 6. Size Check

```bash
# Check package size
du -sh package/

# Ideal sizes:
# Level 1 (Summary): <5 MB
# Level 2 (Reproducible): 5-50 MB
# Level 3 (Full): varies
```

---

## Best Practices

### Notebook Cleaning

**Before sharing notebooks:**

1. **Clear all outputs**
   ```bash
   jupyter nbconvert --clear-output --inplace notebook.ipynb
   ```

2. **Remove debug cells**
   - Tag cells for removal: Cell → Cell Tags → add "remove"
   - Filter during copy

3. **Add markdown explanations**
   - Ensure each code cell has context
   - Add section headers
   - Document assumptions

4. **Check cell execution order**
   - Run "Restart & Run All" to verify
   - Fix any out-of-order dependencies

5. **Remove absolute paths**
   ```python
   # ❌ Bad
   data = pd.read_csv('/Users/yourname/project/data.csv')

   # ✅ Good
   data = pd.read_csv('../data/data.csv')
   # or
   from pathlib import Path
   data_dir = Path(__file__).parent / 'data'
   ```

### File Organization

**Naming conventions for shared files:**
- Use descriptive names: `telomere_analysis_results.csv` not `results.csv`
- Include dates for time-sensitive data: `data_2024-01-15.csv`
- Version if applicable: `analysis_v2.ipynb`
- No spaces: use `-` or `_`

**Size considerations:**
- Document large files in README
- Consider hosting large data separately (institutional storage, Zenodo)
- Provide download links instead of including in package
- Use `.gitattributes` for large file tracking if using Git

### Documentation Requirements

**Minimum documentation for each level:**

**Level 1 - Summary:**
- What the results show
- Key findings
- Date and author

**Level 2 - Reproducible:**
- Setup instructions
- How to run the analysis
- Software dependencies
- Expected runtime
- Data source information

**Level 3 - Full:**
- Complete methodology
- All data sources with versions
- Processing decisions and rationale
- Known issues or limitations
- Contact information

### Dependency Management

**Create requirements file:**

**For pip:**
```bash
# From active environment
pip freeze > requirements.txt

# Or manually curated (better)
cat > requirements.txt << EOF
pandas>=1.5.0
numpy>=1.23.0
matplotlib>=3.6.0
scipy>=1.9.0
EOF
```

**For conda:**
```bash
# Export current environment
conda env export > environment.yml

# Or minimal (recommended)
conda env export --from-history > environment.yml

# Then edit to remove build-specific details
```

---

## Common Scenarios

### Scenario 1: Sharing with Lab Collaborators

**Level:** Reproducible

**Include:**
- Cleaned analysis notebooks
- Processed data
- Figure generation scripts
- environment.yml
- README with reproduction steps

**Don't include:**
- Exploratory notebooks
- Failed analysis attempts
- Debug outputs
- Personal notes

### Scenario 2: Manuscript Supplementary Material

**Level:** Reproducible or Full (depending on journal)

**Include:**
- All notebooks used for figures in paper
- Scripts for each figure panel
- Processed data (or instructions to obtain)
- Complete environment specification
- Detailed methods document

**Best practices:**
- Number notebooks to match paper sections
- Export key figures in publication formats (PDF, high-res PNG)
- Include data dictionary for all variables
- Test reproduction on clean environment

### Scenario 3: Project Archival

**Level:** Full Traceability

**Include:**
- Complete data pipeline from raw to processed
- All versions of analysis
- Meeting notes or decision logs
- External tool versions
- System information

**Organization tips:**
- Use dates in directory names
- Keep chronological changelog
- Document all external dependencies
- Include contact info for questions

### Scenario 4: Data Repository Submission (Zenodo, Figshare)

**Level:** Full Traceability

**Additional considerations:**
- Add LICENSE file (CC BY 4.0, MIT, etc.)
- Include CITATION.cff or CITATION.txt
- Comprehensive metadata
- README with DOI/reference instructions
- Consider maximum file sizes
- Review repository-specific guidelines

---

## Quality Checklist

Before finalizing the sharing package:

### File Quality
- [ ] All notebooks run without errors
- [ ] Notebook outputs cleared
- [ ] No absolute paths in code
- [ ] No hardcoded credentials or API keys
- [ ] File sizes documented
- [ ] Large files compressed or linked

### Documentation
- [ ] README explains setup and usage
- [ ] MANIFEST describes all files
- [ ] Data sources documented
- [ ] Dependencies specified
- [ ] Contact information included
- [ ] License specified (if applicable)

### Reproducibility
- [ ] Requirements file tested in clean environment
- [ ] All data accessible (included or linked)
- [ ] Scripts run in documented order
- [ ] Expected outputs match actual outputs
- [ ] Processing time documented

### Privacy & Sensitivity
- [ ] No sensitive data included
- [ ] Identifiers anonymized if needed
- [ ] Institutional policies checked
- [ ] Collaborator permissions obtained

### Organization
- [ ] Clear directory structure
- [ ] Consistent naming conventions
- [ ] Files logically grouped
- [ ] No duplicate files
- [ ] No unnecessary files (cache, .DS_Store, etc.)

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

---

## Example Scripts

### Create Sharing Package Script

```python
#!/usr/bin/env python3
"""Create sharing package for project."""

import shutil
from pathlib import Path
from datetime import date
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

def create_sharing_package(level='reproducible', output_dir=None):
    """
    Create sharing package.

    Args:
        level: 'summary', 'reproducible', or 'full'
        output_dir: Output directory name (auto-generated if None)
    """

    # Create output directory
    if output_dir is None:
        output_dir = f"shared-{date.today():%Y%m%d}-{level}"

    share_path = Path(output_dir)
    share_path.mkdir(exist_ok=True)

    print(f"Creating {level} sharing package in {share_path}")

    # Create structure based on level
    if level == 'summary':
        create_summary_package(share_path)
    elif level == 'reproducible':
        create_reproducible_package(share_path)
    elif level == 'full':
        create_full_package(share_path)

    print(f"✓ Package created: {share_path}")
    print(f"  Review and compress: tar -czf {share_path}.tar.gz {share_path}")

def clean_notebook(input_path, output_path):
    """Clean notebook outputs and debug cells."""
    with open(input_path) as f:
        nb = nbformat.read(f, as_version=4)

    # Clear outputs
    clear = ClearOutputPreprocessor()
    nb, _ = clear.preprocess(nb, {})

    # Remove debug cells
    nb.cells = [c for c in nb.cells
                if 'debug' not in c.metadata.get('tags', [])]

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)

# ... implement level-specific functions ...

if __name__ == '__main__':
    import sys
    level = sys.argv[1] if len(sys.argv) > 1 else 'reproducible'
    create_sharing_package(level)
```

---

## Summary

**Key principles for project sharing:**

1. 🎯 **Choose the right level** - Match sharing depth to audience needs
2. 📋 **Copy, don't move** - Preserve your working directory
3. 🧹 **Clean thoroughly** - Remove debug code, clear outputs
4. 📝 **Document everything** - README + MANIFEST minimum
5. 🔒 **Check sensitivity** - Anonymize or exclude as needed
6. ✅ **Test before sharing** - Run in clean environment
7. 📦 **Package properly** - Compress and document contents
8. ⚠️ **Work in main directory** - After creating sharing package, ALL future work happens in the original project directory, NOT in the sharing folder

**Remember:** Good sharing practices benefit both collaborators and your future self!

---

## Correcting Cleanup Mistakes

### Identifying Missing Files After Cleanup

When users report missing figures, scripts, or resources after a cleanup:

1. **Check notebook/code references systematically**:
   ```bash
   # Find all image references in notebooks
   grep -n "\.png\|Image(\|display(" notebook.ipynb

   # Find script imports
   grep -n "import\|from.*import\|\.py" notebook.ipynb

   # Find data file references
   grep -n "\.csv\|\.tsv\|\.json" notebook.ipynb
   ```

2. **Search deprecated folders**:
   ```bash
   # Find specific files
   find deprecated -name "*pattern*" -type f

   # Search by file type
   find deprecated -name "*.png" -o -name "*.py"
   ```

3. **Check original location**:
   ```bash
   # Sometimes files are in unexpected locations
   find . -name "phylogenetic_tree*"
   ```

### Restoration Workflow

1. **Verify the file is truly needed**:
   - Check if it's referenced in active notebooks
   - Confirm it's not redundant with other files
   - Check if other notebooks also use it

2. **Restore systematically**:
   ```bash
   # Restore to original location
   cp deprecated/path/to/file.png figures/target/

   # Update sharing packages if they exist
   cp deprecated/path/to/file.png sharing-package/figures/target/
   ```

3. **Document the restoration**:
   - Create a restoration summary document
   - List what was restored and why
   - Update MINIMAL_ESSENTIAL_FILES.md or equivalent

### Example: Figure Restoration

```bash
# 1. Identify missing figures from notebook
grep -o "'[^']*\.png'" Curation_Impact_Analysis.ipynb

# 2. Find them in deprecated
find deprecated -name "05_terminal_telomeres.png"

# 3. Restore systematically
for fig in 05_terminal_telomeres.png 07_chromosome_assignment_comparison.png; do
    cp "deprecated/figures/curation_impact/$fig" figures/curation_impact/
    cp "deprecated/figures/curation_impact/$fig" shared-package/figures/curation_impact/
done

# 4. Verify restoration
ls -lh figures/curation_impact/*.png | wc -l  # Should match expected count
```

### Prevention: Better Cleanup Verification

Before finalizing cleanup:

1. **Grep all notebooks for references**:
   ```bash
   # Find all figure references across notebooks
   grep -h "\.png" *.ipynb | sort | uniq
   ```

2. **Cross-reference with existing files**:
   ```bash
   # Compare referenced vs existing
   comm -13 <(ls figures/*/*.png | sort) <(grep -oh "[^/]*\.png" *.ipynb | sort | uniq)
   ```

3. **Test notebook execution** (if feasible):
   - Open each notebook
   - Check that all figures load
   - Verify no broken image references

**Lesson**: Always verify notebook dependencies before moving files to deprecated. Use grep to find all references before cleanup operations.

---

## Deprecating Redundant Notebooks

### Identifying Redundancy

A notebook may be redundant if:
- **Content overlaps** with another notebook
- **No unique figures**: All visualizations come from shared directories
- **No unique scripts**: All code is shared with other analyses
- **No unique data**: Uses the same datasets as other notebooks

### Dependency Analysis Workflow

Before deprecating a notebook, check what it uses:

```bash
# 1. Check figure references
grep -o "Image(filename.*\.png" notebook.ipynb | sort | uniq

# 2. Check if figures are unique or shared
for fig in $(grep -oh "[^/]*\.png" notebook.ipynb); do
    grep -l "$fig" *.ipynb | grep -v notebook.ipynb
done

# 3. Check data file usage
grep -o "read_csv.*\.csv" notebook.ipynb

# 4. Check script imports (if any)
grep -o "^import\|^from.*import" notebook.ipynb
```

### Safe Deprecation Process

1. **Document the notebook's purpose**:
   - What analysis does it perform?
   - Why was it created?
   - What makes it redundant now?

2. **Verify no unique dependencies**:
   ```bash
   # Check figures
   figures_used=$(grep -oh "[^'\"]*\.png" notebook_to_deprecate.ipynb | sort | uniq)

   # Check if any are unique to this notebook
   for fig in $figures_used; do
       other_notebooks=$(grep -l "$fig" *.ipynb | grep -v notebook_to_deprecate | wc -l)
       if [ "$other_notebooks" -eq 0 ]; then
           echo "WARNING: $fig is only used by this notebook"
       fi
   done
   ```

3. **Move notebook only** (if no unique dependencies):
   ```bash
   # Move notebook to deprecated
   mv Redundant_Notebook.ipynb deprecated/

   # Remove from sharing packages
   rm -f sharing-package/notebooks/Redundant_Notebook.ipynb
   ```

4. **Document the deprecation**:
   Create a `DEPRECATION_SUMMARY.md`:
   ```markdown
   # Notebook Deprecation: [Name]

   **Date**: YYYY-MM-DD
   **Reason**: [Brief explanation]

   ## Analysis
   - Figures: [all shared/unique ones moved]
   - Scripts: [all shared/unique ones moved]
   - Data: [all shared]

   ## Files Moved
   - Notebook: [path] → deprecated/
   - Figures: [none/list]
   - Scripts: [none/list]

   ## Active Notebooks
   [List remaining active notebooks]

   ## Restoration
   ```bash
   cp deprecated/Notebook.ipynb .
   ```
   ```

### Example: Both_Haplotypes Deprecation

```bash
# 1. Check dependencies
grep "\.png" Curation_Impact_Analysis_Both_Haplotypes.ipynb
# Result: All figures from figures/curation_impact/

grep "\.png" Curation_Impact_Analysis.ipynb
# Result: Same figures - confirmed shared

# 2. Check data files
grep "\.csv" Curation_Impact_Analysis_Both_Haplotypes.ipynb
# Result: vgp_assemblies_unified.csv (shared with main notebook)

# 3. Safely deprecate (notebook only, no other files)
mv Curation_Impact_Analysis_Both_Haplotypes.ipynb deprecated/
rm shared-package/notebooks/Curation_Impact_Analysis_Both_Haplotypes.ipynb

# 4. Document
echo "All figures, scripts, and data remain active (shared)" > documentation/DEPRECATION_SUMMARY.md
```

**Key Principle**: Only move the notebook if ALL dependencies are shared with active notebooks. Never move shared resources to deprecated.

---

## ⚠️ Critical Reminder for Claude

**After creating any sharing package:**

1. **Always return to the main project directory**
2. **Never work in `shared-*/` directories** - These are read-only snapshots
3. **All future edits, analysis, and development happen in the original working directory**
4. **Sharing folders are for distribution only, not active development**

If the user asks to modify files, always check the current directory and ensure you're working in the main project location, not in a sharing package.
