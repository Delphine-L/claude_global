---
name: folder-organization
description: Best practices for organizing project folders, file naming conventions, and directory structure standards for research and development projects
version: 1.0.0
---

# Folder Organization Best Practices

Expert guidance for organizing project directories, establishing file naming conventions, and maintaining clean, navigable project structures for research and development work.

## When to Use This Skill

- Setting up new projects
- Reorganizing existing projects
- Establishing team conventions
- Creating reproducible research structures
- Managing data-intensive projects

## Core Principles

1. **Predictability** - Standard locations for common file types
2. **Scalability** - Structure grows gracefully with project
3. **Discoverability** - Easy for others (and future you) to navigate
4. **Separation of Concerns** - Code, data, documentation, outputs separated
5. **Version Control Friendly** - Large/generated files excluded appropriately

## Standard Project Structure

### Research/Analysis Projects

```
project-name/
├── README.md                 # Project overview and getting started
├── .gitignore               # Exclude data, outputs, env files
├── environment.yml          # Conda environment (or requirements.txt)
├── data/                    # Input data (often gitignored)
│   ├── raw/                # Original, immutable data
│   ├── processed/          # Cleaned, transformed data
│   └── external/           # Third-party data
├── notebooks/               # Jupyter notebooks for exploration
│   ├── 01-exploration.ipynb
│   ├── 02-analysis.ipynb
│   └── figures/            # Notebook-generated figures
├── src/                     # Source code (reusable modules)
│   ├── __init__.py
│   ├── data_processing.py
│   ├── analysis.py
│   └── visualization.py
├── scripts/                 # Standalone scripts and workflows
│   ├── download_data.sh
│   └── run_pipeline.py
├── tests/                   # Unit tests
│   └── test_analysis.py
├── docs/                    # Documentation
│   ├── methods.md
│   └── references.md
├── results/                 # Analysis outputs (gitignored)
│   ├── figures/
│   ├── tables/
│   └── models/
└── config/                  # Configuration files
    └── analysis_config.yaml
```

### Development Projects

```
project-name/
├── README.md
├── .gitignore
├── setup.py                 # Package configuration
├── requirements.txt         # or pyproject.toml
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── core.py
│       └── utils.py
├── tests/
│   ├── test_core.py
│   └── test_utils.py
├── docs/
│   ├── api.md
│   └── usage.md
├── examples/                # Example usage
│   └── example_workflow.py
└── .github/                 # CI/CD workflows
    └── workflows/
        └── tests.yml
```

### Bioinformatics/Workflow Projects

```
project-name/
├── README.md
├── data/
│   ├── raw/                # Raw sequencing data
│   ├── reference/          # Reference genomes, annotations
│   └── processed/          # Workflow outputs
├── workflows/               # Galaxy .ga or Snakemake files
│   ├── preprocessing.ga
│   └── assembly.ga
├── config/
│   ├── workflow_params.yaml
│   └── sample_sheet.tsv
├── scripts/                # Helper scripts
│   ├── submit_workflow.py
│   └── quality_check.py
├── results/                # Final outputs
│   ├── figures/
│   ├── tables/
│   └── reports/
└── logs/                   # Workflow execution logs
```

### Data Analysis Projects with Notebooks

For projects involving Jupyter notebooks, data analysis, and visualization with many generated figures:

```
project-name/
├── README.md                # Project overview
├── .gitignore
├── notebooks/               # Jupyter notebooks (analysis, exploration)
│   ├── 01-data-loading.ipynb
│   ├── 02-exploratory-analysis.ipynb
│   └── 03-final-analysis.ipynb
├── figures/                 # ALL generated visualizations (PNG, PDF, SVG)
│   ├── fig1_distribution.png
│   ├── fig2_correlation.png
│   └── supplementary_*.png
├── data/                    # Data files (JSON, CSV, TSV, Excel)
│   ├── raw/                # (optional) Original, unprocessed data
│   ├── processed/          # (optional) Cleaned, processed data
│   ├── input_data.json
│   └── metadata.tsv
├── tests/                   # Test scripts (test_*.py, pytest)
│   ├── test_processing.py
│   └── test_analysis.py
├── scripts/                 # Standalone Python/R scripts
│   ├── data_fetch.py
│   └── preprocessing.py
├── docs/                    # Documentation (MD, RST files)
│   ├── methods.md
│   └── analysis_notes.md
└── archives/                # Compressed archives, old versions
    └── backup_YYYYMMDD.tar.gz
```

**Benefits of This Structure**:
- **Clear separation** of concerns (code vs. data vs. outputs)
- **Easy navigation**: Find all figures in one place
- **Scalability**: Handles 50+ figures without cluttering root
- **Git-friendly**: Easy to .gitignore large data/figures
- **Collaboration**: Standard structure reduces onboarding time

**When to Use This Structure**:
- Projects with multiple notebooks
- Analysis generating many visualizations (10+ figures)
- Multiple data sources/formats
- Team collaboration
- Long-term research projects

**MANIFEST Integration**:

For enhanced navigation and token efficiency, add MANIFEST.md files:

```
project-name/
├── MANIFEST.md                  # Root project index (~1,500 tokens)
├── MANIFEST_TEMPLATE.md         # Template for creating new MANIFESTs
├── notebooks/
│   ├── MANIFEST.md             # (optional) Notebook catalog
│   └── [notebook files]
├── figures/
│   ├── MANIFEST.md             # Figure catalog (~500-1,000 tokens)
│   └── [figure files]
├── data/
│   ├── MANIFEST.md             # Data inventory (~500-1,000 tokens)
│   └── [data files]
├── scripts/
│   ├── MANIFEST.md             # Script documentation (~500-1,000 tokens)
│   └── [script files]
└── documentation/
    ├── MANIFEST.md             # Doc organization (~500-1,000 tokens)
    └── [doc files]
```

Benefits:
- 85-90% token reduction for session startup
- Complete project context in ~2,000 tokens (vs 15,000+)
- Quick work resumption without reading files
- Clear workflow documentation

See "MANIFEST System for Token-Efficient Navigation" section below for complete documentation.

## File Naming Conventions

### General Rules

1. **Use lowercase** with hyphens or underscores
   - ✅ `data-analysis.py` or `data_analysis.py`
   - ❌ `DataAnalysis.py` or `data analysis.py`

2. **Be descriptive but concise**
   - ✅ `process-telomere-data.py`
   - ❌ `script.py` or `process_all_the_telomere_sequencing_data_from_experiments.py`

3. **Use consistent separators**
   - Choose either hyphens or underscores and stick with it
   - Convention: hyphens for file names, underscores for Python modules

4. **Include version/date for important outputs**
   - ✅ `report-2026-01-23.pdf` or `model-v2.pkl`
   - ❌ `report-final-final-v3.pdf`

### Numbered Sequences

For sequential files (notebooks, scripts), use zero-padded numbers:

```
notebooks/
├── 01-data-exploration.ipynb
├── 02-quality-control.ipynb
├── 03-statistical-analysis.ipynb
└── 04-visualization.ipynb
```

### Data Files

Include metadata in filename when possible:

```
data/raw/
├── sample-A_hifi_reads_2026-01-15.fastq.gz
├── sample-B_hifi_reads_2026-01-15.fastq.gz
└── reference_genome_v3.fasta
```

## Directory Management Best Practices

### What to Version Control

**DO commit:**
- Source code
- Documentation
- Configuration files
- Small test datasets (<1MB)
- Requirements/environment files
- README files

**DON'T commit:**
- Large data files (use `.gitignore`)
- Generated outputs
- Environment directories (`venv/`, `conda-env/`)
- Logs
- Temporary files
- API keys/secrets

### .gitignore Template

```gitignore
# Claude Code (local skills and settings)
.claude/

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
*.egg-info/

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# Data
data/raw/
data/processed/
*.fastq.gz
*.bam
*.vcf.gz

# Outputs
results/
outputs/
*.png
*.pdf
*.html

# Logs
logs/
*.log

# Environment
.env
environment.local.yml

# OS
.DS_Store
Thumbs.db
```

### Session Notes Storage

**Standardize on `session-saves/`** (not `sessions-history/`, `Archive/`, or other variants)

Benefits:
- Consistent with standard naming pattern (noun + plural)
- Matches `archived/` pattern
- Works across all projects
- Prevents confusion when writing automation scripts

When reorganizing:
```bash
mv sessions-history/ session-saves/
mv Archive/ session-saves/  # if used for session notes
```

**Project folder template (with session notes):**
```
project-name/
├── TO-DOS.md                # Project-specific tasks
├── session-saves/           # Working session notes (tagged with #dump)
├── archived/                # Processed/consolidated notes
│   ├── daily/              # Daily consolidations
│   └── monthly/            # Monthly summaries
├── Planning/               # Planning documents
├── Development/            # Development notes
└── [other content folders]
```

**Integration with Obsidian:**
- Session notes should have `dump` tag in frontmatter for easy filtering
- See the **obsidian** skill for complete details on the dump tag requirement and frontmatter schema
- Archiving workflow: move from `session-saves/` to `archived/daily/` or `archived/monthly/`

### After Reorganization

**Clean up old session folder variations:**

If you renamed folders during reorganization (e.g., `sessions-history/` → `session-saves/`):

1. **Move archived sessions:**
```bash
mv old-folder/*.md session-saves/archived/daily/
```

2. **Remove empty old folders safely:**
```bash
rmdir old-folder/  # Fails if not empty - safety check
```

3. **Update any links** to old folder structure

**Don't leave multiple session folders:**
- ❌ `sessions-history/` and `session-saves/` both present
- ✅ Single `session-saves/` with archived content

**Verification:**
```bash
# Check for session folder variations
find . -type d -name "*session*" -not -path "*/archived/*"
# Should show only: ./session-saves/
```

## Data Organization

### Raw Data is Sacred

- **Never modify raw data** - Always keep originals untouched
- Store in `data/raw/` and make it read-only if possible
- Document data provenance (where it came from, when downloaded)

### Processed Data Hierarchy

```
data/
├── raw/                    # Original, immutable
├── interim/                # Intermediate processing steps
├── processed/              # Final, analysis-ready data
└── external/               # Third-party data
```

## Documentation Standards

### README.md Essentials

Every project should have a README with:

```markdown
# Project Name

Brief description

## Installation

How to set up the environment

## Usage

How to run the analysis/code

## Project Structure

Brief overview of directories

## Data

Where data lives and how to access it

## Results

Where to find outputs
```

### Code Documentation

- **Docstrings** for all functions/classes
- **Comments** for complex logic
- **CHANGELOG.md** for tracking changes
- **TODO.md** for tracking work (gitignored or removed before merge)

### Change Documentation Best Practices

After major changes (cleanup, deprecation, restoration), create summary documents:

1. **Create a dated summary document**:
   ```
   OPERATION_SUMMARY_YYYY-MM-DD.md
   ```

2. **Essential sections**:
   - **Overview**: What was done and why
   - **Problem**: What issue was being addressed
   - **Solution**: Actions taken
   - **Result**: Current state after changes
   - **Files affected**: What was moved/changed/restored
   - **Restoration**: How to undo if needed

3. **Examples of good summary docs**:
   - `FIGURE_RESTORATION_SUMMARY.md` - Documents restored files
   - `DEPRECATION_SUMMARY.md` - Documents deprecated notebooks
   - `RECENT_CHANGES_SUMMARY.md` - High-level overview

### Template for Change Summaries

```markdown
# [Operation] Summary - [Date]

## Problem
[Brief description of the issue]

## Solution
[What was done to address it]

### Files Changed
- **Moved**: [list]
- **Restored**: [list]
- **Updated**: [list]

## Current State
- **Active files**: [count and list]
- **Deprecated files**: [count and list]
- **Status**: [Ready/In Progress/etc.]

## Restoration Instructions
```bash
# Commands to undo changes if needed
```

## Documentation Updated
- [List of docs that were updated]

---
**Date**: YYYY-MM-DD
**Status**: [Complete/Partial/etc.]
```

**Why This Matters**:
- Future users (including yourself) understand what changed
- Provides restoration instructions if needed
- Creates audit trail for project history
- Helps collaborators understand project evolution

## Common Anti-Patterns to Avoid

❌ **Flat structure with everything in root**
```
project/
├── script1.py
├── script2.py
├── data.csv
├── output1.png
├── output2.png
└── final_really_final_v3.xlsx
```

❌ **Ambiguous naming**
```
notebooks/
├── notebook1.ipynb
├── test.ipynb
├── analysis.ipynb
└── analysis_new.ipynb
```

❌ **Mixed concerns**
```
project/
├── src/
│   ├── analysis.py
│   ├── data.csv          # Data in source code directory
│   └── figure1.png       # Output in source code directory
```

## Project Reorganization

When reorganizing an existing project's folder structure, follow this systematic approach to avoid breaking dependencies.

### Post-Reorganization Path Updates

After reorganizing folders, **ALWAYS verify and update file paths** in all scripts and notebooks. Files often contain hardcoded paths that break after reorganization.

#### Systematic Path Update Process

1. **Identify all files that reference other files**:
   ```bash
   # Find notebooks
   find . -name "*.ipynb"

   # Find Python scripts
   find . -name "*.py"

   # Search for file references
   grep -r "\.json\|\.csv\|\.tsv\|\.png" --include="*.ipynb" --include="*.py"
   ```

2. **Common file reference patterns to search for**:
   - Data files: `.json`, `.csv`, `.tsv`, `.xlsx`
   - Figures: `.png`, `.jpg`, `.pdf`, `.svg`
   - Python: `open()`, `read_csv()`, `read_json()`, `load()`
   - Jupyter: `savefig()`, file I/O operations

3. **Update paths using sed for batch replacements**:
   ```bash
   # Update data file paths
   sed -i.bak "s|'filename.json'|'../data/filename.json'|g" notebook.ipynb

   # Update figure output paths
   sed -i.bak "s|savefig('fig|savefig('../figures/fig|g" notebook.ipynb

   # Update with double quotes (common in Python code)
   sed -i.bak 's|"filename.csv"|"../data/filename.csv"|g' script.py
   ```

4. **Verify updates**:
   ```bash
   # Check that paths were updated correctly
   grep -o "'../data/[^']*'" notebook.ipynb | head -5
   grep -o "'../figures/[^']*'" notebook.ipynb | head -5
   ```

5. **Clean up backup files**:
   ```bash
   rm *.bak *.bak2 *.bak3
   ```

#### Files to Check

Always check these file types after reorganization:

- **Jupyter notebooks** (`.ipynb`): Data loading, figure saving
- **Python scripts** (`.py`): File I/O operations
- **Test files** (`test_*.py`): Often reference data fixtures
- **Data processing scripts**: Input/output paths
- **Documentation**: Code examples with file paths
- **Configuration files**: Paths to resources

#### Common Path Patterns

| Original Location | After Reorganization | Relative Path |
|------------------|---------------------|---------------|
| `./data.json` | `../data/data.json` | Go up one level, into data/ |
| `./figure.png` | `../figures/figure.png` | Go up one level, into figures/ |
| `./test.py` accessing `data.json` | `../data/data.json` | From tests/ to data/ |
| `./notebook.ipynb` accessing both | `../data/`, `../figures/` | From notebooks/ to both |

#### Tips

- **Use relative paths** (`../data/`) not absolute paths for portability
- **Batch process** similar changes using sed or find/replace
- **Test one file type at a time** (notebooks first, then scripts)
- **Keep backup files** (`.bak`) until verification complete
- **Grep to verify** changes were applied correctly
- **Consider case sensitivity** on different operating systems

### Verification and Cleanup After Reorganization

After completing a reorganization, always verify the results and clean up:

#### 1. Verify File Counts
```bash
# Count files moved to each directory
for dir in figures data tests notebooks docs archives; do
  echo "$dir: $(ls $dir 2>/dev/null | wc -l | tr -d ' ') files"
done
```

#### 2. Check Root Directory
```bash
# Ensure root is clean
ls -la

# Should only see:
# - Organized directories (figures/, data/, etc.)
# - Project-specific folders (Fetch_data/, sharing/)
# - Config directories (.claude/, .git/)
# - Essential files (README.md, .gitignore, etc.)
```

#### 3. Remove Temporary Files
```bash
# Remove Jupyter checkpoints (auto-generated, not needed in version control)
rm -rf .ipynb_checkpoints

# Remove sed backup files
rm *.bak *.bak2 *.bak3

# Remove duplicate/backup data files
rm *.backup *.backup2 *.old
```

#### 4. Display Final Structure
```bash
# Show clean directory tree
tree -L 2 -d

# Or list directories only
ls -d */
```

#### Verification Checklist

- [ ] All target directories created successfully
- [ ] File counts match expectations (no files lost)
- [ ] Root directory is clean (no scattered files)
- [ ] Temporary/backup files removed
- [ ] Paths in notebooks/scripts updated (see "Post-Reorganization Path Updates")
- [ ] Structure documented (README or similar)
- [ ] Test that notebooks/scripts still run correctly

## Cleanup and Maintenance

### Regular Maintenance Tasks

1. **Archive old branches** - Delete merged feature branches
2. **Clean temp files** - Remove `TODO.md`, `NOTES.md` from completed work
3. **Update documentation** - Keep README current with changes
4. **Review .gitignore** - Ensure large files aren't tracked
5. **Organize notebooks** - Rename/renumber as project evolves

### End-of-Project Checklist

- [ ] README complete and accurate
- [ ] Code documented
- [ ] Tests passing
- [ ] Large files gitignored
- [ ] Working files removed (TODO.md, scratch notebooks)
- [ ] Final outputs in `results/`
- [ ] Environment files current
- [ ] License added (if applicable)

## Project Cleanup: Identifying Essential Files

When projects accumulate many files over time, use this systematic approach to identify and keep only essential files:

### 1. Analyze Notebooks to Find Used Figures

```bash
# Extract figure references from Jupyter notebooks
grep -o "figures/[^'\"]*\.png" YourNotebook.ipynb | sort -u

# For multiple notebooks, check each one
for nb in *.ipynb; do
    echo "=== $nb ==="
    grep -o "figures/[^'\"]*\.png" "$nb" | sort -u
done
```

### 2. Map Figures to Generating Scripts

```bash
# Find which script generates a specific figure
grep -l "figure_name" scripts/*.py

# Search for output directory patterns
grep -l "figures/curation_impact" scripts/*.py
```

### 3. Organize Deprecated Files

Create clear structure:
```bash
mkdir -p deprecated/{figures,scripts,notebooks}
mkdir -p deprecated/figures/{unused_category1,unused_category2}
mkdir -p deprecated/scripts/unused_utilities
```

Use descriptive subdirectory names:

**Good structure:**
```
deprecated/
├── figures/
│   ├── unused_regression_plots/       # Category-based names
│   ├── unused_curation_impact/
│   └── exploratory_analysis/
├── scripts/
│   ├── unused_utilities/              # Purpose-based organization
│   ├── old_data_fetch/
│   └── notebook_fixes/
└── data/
    ├── intermediate_tables/
    └── old_versions/
```

**Poor structure:**
```
deprecated/
├── old_stuff/        # Too vague
├── misc/             # Unclear purpose
└── temp/             # Ambiguous
```

**Benefits of good naming:**
- Future-you understands what's in each folder
- Easy to restore specific categories
- Clear what can be safely deleted vs archived
- Documents project evolution

### 4. Document What Was Kept

Create `MINIMAL_ESSENTIAL_FILES.md`:
- List all active figures and their source scripts
- List essential scripts with their purposes
- Provide regeneration instructions
- Include restoration instructions for deprecated files

**Example structure**:
```markdown
## Active Figures
1. figure_01.png - Used in Notebook A (Figure 1)
   - Generated by: script_14.py

## Essential Scripts
1. script_14.py - Generates Figures 1-4, 7
2. build_data.py - Required infrastructure
```

### 5. Verification Checklist

Before finalizing cleanup:
- [ ] All notebook-referenced figures identified
- [ ] Scripts generating those figures identified
- [ ] Unused files moved (not deleted) to deprecated/
- [ ] Documentation created (MINIMAL_ESSENTIAL_FILES.md)
- [ ] Regeneration commands tested
- [ ] Notebooks still work with cleaned structure

### Benefits of This Approach

- **Reduced confusion**: Clear which files are active vs historical
- **Easier maintenance**: Only essential files to update
- **Better documentation**: Explicit mapping of figures → scripts
- **Recoverable**: Deprecated files preserved, not deleted
- **Onboarding**: New collaborators see minimal essential set

### Identifying Files for Deprecation

When cleaning up analysis directories with multiple config file versions:

**Patterns indicating old/superseded files:**

1. **Naming patterns:**
   - Files without `_UPDATED` suffix when `_UPDATED` versions exist
   - Files with intermediate version numbers or dates
   - Files named `*_old.txt`, `*_backup.csv`

2. **Content indicators:**
   - Old parameter values (e.g., old color schemes)
   - Old species names (e.g., Time Tree replacements)
   - Incomplete coverage (fewer species than current)

3. **Multiple similar files:**
   - `itol_branch_colors.txt`, `itol_branch_colors_v2.txt`, `itol_branch_colors_UPDATED.txt`
   - Keep: `_UPDATED.txt` (current version)
   - Deprecate: others (superseded)

**Cleanup Strategy:**

```bash
# Create deprecation directory with descriptive name
mkdir -p deprecated/phylo_old_configs

# Move superseded files (preserve for reference)
mv old_file1.txt old_file2.csv deprecated/phylo_old_configs/

# Verify move (should be empty or only current files)
ls *.txt *.csv
```

**Files to keep in active directory:**
- Current versions (e.g., `*_UPDATED.*`)
- Source scripts that generate configs
- Documentation (README, MANIFEST)
- Data files actively used

**Files to deprecate:**
- Superseded configs with old parameters
- Intermediate test versions
- Files from previous analysis versions
- Configs no longer referenced by notebooks

**Example from phylo cleanup (18 files deprecated):**
- Old: `itol_3category_colorstrip.txt` (old colors)
- Current: `itol_3category_colorstrip_UPDATED.txt` (new colors)
- Old: `species_curation_methods.csv` (2-category system)
- Current: `species_3category_methods_UPDATED.csv` (3-category system)

**Benefits:**
- Clear which files are current vs historical
- Reduced confusion when updating configs
- Preserved old versions for comparison
- Easier to identify files needing updates

## Documentation Organization Strategy

Projects accumulate documentation files (.md, .log, .txt) in the root directory. Consolidate them effectively:

### Structure

```
documentation/
├── README.md                    # Index to all documentation
├── logs/                        # Log files from processes
├── working_files/               # Temporary/working files
└── [organized .md files]
```

### Implementation

```bash
# 1. Create structure
mkdir -p documentation/{logs,working_files}

# 2. Move documentation
mv *.md documentation/
mv *.log documentation/logs/
mv *.txt documentation/working_files/  # or keep essential ones in root

# 3. Create index (documentation/README.md)
cat > documentation/README.md << 'EOF'
# Project Documentation

## Quick Start
- ESSENTIAL_FILE.md - Start here
- RECENT_CHANGES.md - Latest updates

## By Category
### Analysis
- analysis_summary.md
- results.md

### Methods
- methods.md
- protocols.md

[etc...]
EOF
```

### Documentation README Template

Include in `documentation/README.md`:
- **Quick start section** - Most important docs
- **Categorical organization** - Group by purpose
- **File descriptions** - One-line summaries
- **File counts** - Show organization scale
- **Archive policy** - Which docs are historical
- **Access instructions** - How to find specific info

### What to Keep in Root

**Keep in project root:**
- `README.md` - Project overview
- `LICENSE`, `CONTRIBUTING.md` - Standard files
- `.gitignore`, config files

**Move to documentation/:**
- Analysis summaries
- Session notes
- Method descriptions
- Update logs
- All other markdown files

### Benefits

- **Clean root directory**: Only essential project files visible
- **Organized docs**: Easy to find specific documentation
- **Categorized**: Logs separate from summaries separate from methods
- **Indexed**: README provides roadmap
- **Scalable**: Clear place for new documentation

### Common Mistake

❌ Don't delete old documentation - move it to `documentation/archive/`
✓ Preserve history but organize it clearly

## MANIFEST System for Token-Efficient Navigation

For large data analysis projects, implement a MANIFEST system to enable efficient project navigation and minimize token usage in Claude Code sessions.

### Problem Statement

**Challenge**: Large projects with many files consume excessive tokens during session startup:
- Reading large notebooks (4-6 MB) = 5,000-15,000 tokens
- Exploring data files and structure = 3,000-5,000 tokens
- Understanding scripts and workflows = 2,000-3,000 tokens
- **Total: 15,000-23,000 tokens just for orientation!**

**Solution**: MANIFEST files provide lightweight project indexes (~500-2,000 tokens each) that give complete context without reading actual files.

### Token Efficiency Impact

**Before MANIFESTs** (reading actual files):
```
Root MANIFEST: N/A
Notebooks: ~10,000-15,000 tokens (reading 3 large notebooks)
Data exploration: ~3,000-5,000 tokens
Scripts analysis: ~2,000-3,000 tokens
---
Total: ~15,000-23,000 tokens for project orientation
```

**After MANIFESTs** (reading indexes):
```
Root MANIFEST: ~1,500 tokens (full project overview)
Subdirectory MANIFEST: ~500-1,000 tokens (specific area)
---
Total: ~2,000-2,500 tokens for complete context
Savings: 85-90% token reduction!
```

### What is a MANIFEST?

A MANIFEST.md file is a comprehensive index for a directory that includes:
- **Quick Reference**: Entry points, key outputs, dependencies
- **File Inventory**: All files with descriptions, sizes, purposes
- **Workflow Dependencies**: How files relate and depend on each other
- **Notes for Resuming Work**: Current status, next steps, known issues
- **Metadata**: Tags, environment info, Obsidian notes links

**Key Principle**: MANIFEST provides 80% of context needed to resume work in 500-2,000 tokens instead of reading 5,000-15,000 tokens of actual files.

### MANIFEST Structure

#### Root Directory MANIFEST Template

```markdown
# [Project Name] - ROOT MANIFEST

**Last Updated**: YYYY-MM-DD
**Purpose**: [1-2 sentence description]
**Status**: Active/Deprecated/Archive

---

## Quick Reference

**Entry Points**: [Which files to read first]
**Key Outputs**: [Main deliverables]
**Dependencies**: [External requirements]

---

## Files

### Notebooks

#### `notebook_name.ipynb` (Size)
- **Purpose**: [What analysis/questions does this answer?]
- **Depends on**: [Input files, data, scripts]
- **Generates**: [Output files, figures]
- **Key findings**: [1-2 sentence summary]
- **Last modified**: YYYY-MM-DD
- **Execution time**: [~X minutes if relevant]
- **Priority**: [Main document or complementary analysis]

### Key Directories

#### `data/` (Size)
See `data/MANIFEST.md` for details.
- **Contents**: [Brief description]
- **Key files**: [Most important files]

[Repeat for figures/, scripts/, documentation/]

---

## Directory Structure

```
project/
├── MANIFEST.md (this file)
├── data/
│   └── MANIFEST.md
├── figures/
│   └── MANIFEST.md
└── [etc.]
```

---

## Workflow Dependencies

```
[Visual or text description of data → processing → outputs flow]

Example:
1. Data Acquisition: fetch_data.py → data/raw/
2. Processing: process.py → data/processed/
3. Analysis: analysis.ipynb → figures/
```

---

## Notes for Resuming Work

**Current Status**: [What was last completed?]
**Next Steps**: [What needs to be done next?]
**Known Issues**: [Problems, TODOs, blockers]
**Reference**: [Links to related docs, other MANIFESTs]

---

## Metadata

**Created by**: Claude Code
**Project**: [Project name]
**Tags**: [#keywords #for #searching]
**Environment**: [conda env name or venv path]
**Obsidian notes path**: [Link to project notes]

---

## For Claude Code Sessions

**Quick Start for New Sessions**:
1. Read this MANIFEST.md (~500 tokens)
2. Read relevant subdirectory MANIFEST.md (~500 tokens)
3. Only read actual files when editing them

**Token Efficiency**:
- This MANIFEST provides 80% of context needed
- Subdirectory MANIFESTs provide detailed file info
- Read actual code/notebooks only when making changes
```

#### Subdirectory MANIFEST Template

Use the same structure but focused on the specific directory. For subdirectories:

**data/MANIFEST.md** - Focus on:
- Data provenance (where data came from)
- File formats and structure (rows, columns, size)
- Data dependencies (which files depend on which)
- Processing history (original → processed versions)

**figures/MANIFEST.md** - Focus on:
- Which code generates which figure
- Figure purpose and key message
- Manuscript figure numbering
- Figure dependencies (data sources)

**scripts/MANIFEST.md** - Focus on:
- Script purpose and I/O
- Execution order and dependencies
- Usage examples and parameters
- Required dependencies

**documentation/MANIFEST.md** - Focus on:
- Document organization by category
- Critical entry points (RESUME_HERE.md)
- Active vs archived status
- Session summary locations

### Linking MANIFESTs Across Directories

When implementing analysis_files/ (Iteration 2), create bidirectional links:

**In figures/MANIFEST.md** - Link to analysis files:
```markdown
**01_figure_name.png** (318 KB)
- **Description**: Brief description
- **Analysis file**: `../analysis_files/figures/01_figure_name.md` - Detailed analysis
```

**In analysis_files/MANIFEST.md** - Link back to figures:
```markdown
#### 01_figure_name.md
- **Figure file**: `figures/curation_impact_3cat/01_figure_name.png`
- **Purpose**: Detailed analysis and interpretation
```

**In root MANIFEST.md** - Reference both:
```markdown
#### `analysis_files/` (~90 KB) **[NEW - ITERATION 2]**
- **Purpose**: Separate markdown files for figure analyses
- **Token efficiency**: ~98% reduction vs notebooks
- **Links to**: figures/ directory
```

This creates a navigable web of documentation.

### MANIFEST Template File

Create `MANIFEST_TEMPLATE.md` in project root as a starting point. See the template in the Curation_Paper_figures project for a complete example with all sections and guidance.

### Commands for MANIFEST Management

#### /generate-manifest Command

Create this command in `.claude/commands/generate-manifest.md` (or symlink from global commands):

**Purpose**: Automatically generates MANIFEST files by analyzing directory contents

**Key Features**:
- Analyzes directory type (root, data, figures, scripts, documentation)
- Extracts file information efficiently (sizes, dates, row counts)
- Identifies dependencies by searching code for file references
- Maps workflow relationships
- Uses AskUserQuestion for ambiguous information
- Marks fields requiring user input

**Usage**:
```bash
/generate-manifest              # Interactive mode
/generate-manifest data         # Generate for data/
/generate-manifest figures      # Generate for figures/
```

**Implementation Tips**:
- Don't read entire large files - use targeted searches
- Extract docstrings and header comments from scripts
- Use grep to find file references in code
- Check first/last cells of notebooks for descriptions
- Get row counts with `wc -l` for CSV files
- Target 1000-2000 tokens for root, 500-1000 for subdirectories

#### /update-manifest Command

Create this command in `.claude/commands/update-manifest.md`:

**Purpose**: Quickly updates existing MANIFESTs while preserving user content

**Key Features**:
- Preserves user-entered descriptions and notes
- Updates dates, sizes, and file existence
- Captures session context (asks "What did you accomplish?")
- Three modes: Minimal, Quick (default), Full
- Provides update summary

**Usage**:
```bash
/update-manifest              # Update current directory
/update-manifest data         # Update data/MANIFEST.md
/update-manifest --quick      # Force quick mode
/update-manifest --full       # Full re-analysis
```

**Session End Pattern**:
```bash
/update-manifest              # Capture session progress
/update-skills               # Save new knowledge
/safe-exit                   # Clean exit with notes
```

### MANIFEST Workflow

#### Initial Setup

1. **Create template**:
   ```bash
   # Copy MANIFEST_TEMPLATE.md to project root
   # Or use /generate-manifest to create from scratch
   ```

2. **Generate root MANIFEST**:
   ```bash
   /generate-manifest
   # Choose "root directory"
   # Fill in user-specific fields
   ```

3. **Generate subdirectory MANIFESTs**:
   ```bash
   /generate-manifest data
   /generate-manifest figures
   /generate-manifest scripts
   /generate-manifest documentation
   ```

4. **Customize MANIFESTs**:
   - Fill in [USER TO FILL] placeholders
   - Add key findings summaries
   - Document environment setup
   - Add Obsidian notes paths

#### During Active Development

1. **Start session** - Read MANIFESTs for context:
   ```bash
   cat MANIFEST.md              # Project overview
   cat figures/MANIFEST.md      # If working on figures
   ```

2. **Work on project** - Normal development

3. **End session** - Update MANIFESTs:
   ```bash
   /update-manifest              # Captures session progress
   ```

#### After Major Changes

When you:
- Add new files or directories
- Reorganize structure
- Complete major analysis
- Make significant changes

Run full regeneration:
```bash
/generate-manifest --update     # Full re-analysis
```

### MANIFEST Best Practices

#### Content Guidelines

1. **Be concise but informative**: Target 500-2,000 tokens
2. **Front-load important info**: Put critical details first
3. **Use bullet points**: Not paragraphs
4. **Include dates**: Everything should have timestamps
5. **Think "6 months from now"**: What would you need to know?

#### What to Document

**ALWAYS include**:
- File purpose and key message
- Dependencies (inputs)
- Outputs (what it generates)
- Last modified date
- Size for large files

**USER FILL fields for**:
- Key findings (requires understanding)
- Priority classification (main vs complementary)
- Known issues and TODOs
- Environment names
- Obsidian note paths

**Tip for filling user-specific fields**:
- **Obsidian notes path**: Check `.claude/project-config` file - it often contains the vault path in the `obsidian_vault` or similar field
- **Environment name**: Check conda env list or look for `environment.yml`/`requirements.txt`
- **Key findings**: Analyze generation scripts or read notebook markdown cells for summaries

**Auto-generate from code**:
- File sizes and dates
- Row/column counts for data
- Dependencies (by searching code)
- Script usage (from docstrings)

#### Documenting New Analysis Notebooks in MANIFEST

**Template for Analysis Notebook Entries:**

When adding a new analysis notebook to `MANIFEST.md`, include:

```markdown
#### `Notebook_Name.ipynb` (file size) **[NEW]**
- **Purpose**: One-sentence objective of the analysis
- **Type**: Category (e.g., "Confounding analysis", "Data enrichment", "Primary analysis")
- **Rationale**: Why this analysis is needed (2-3 sentences explaining motivation)
- **Approach**:
  - Bullet points of analytical steps
  - Key methodological decisions
- **Key Questions**:
  - Question 1 the analysis addresses
  - Question 2 the analysis addresses
- **Depends on**:
  - data/input_file.csv (description)
  - scripts/processing_script.py
- **Generates**:
  - figures/output_dir/figure1.png (what it shows)
  - results/statistics.csv
- **Dataset**: N assemblies/samples, key statistics
- **Last modified**: YYYY-MM-DD
- **Status**: Current state (e.g., "Code optimized", "In progress", "Complete")
- **Execution time**: ~XX minutes
- **Priority**: Role in project (e.g., "Confounding analysis - validates main findings")
- **Note**: Important caveats or special considerations
```

**Example: Technology/Temporal Confounding Analysis**

```markdown
#### `Technology_Temporal_Analysis.ipynb` (32 KB) **[NEW]**
- **Purpose**: Investigate whether sequencing technology (CLR vs HiFi) and temporal trends confound the curation method comparisons
- **Type**: Confounding analysis - technology and temporal effects
- **Rationale**: Sequencing technology evolved rapidly (CLR → HiFi), and assembly methods may correlate with technology era. Need to determine if observed quality differences are due to curation methods or underlying technology/temporal confounders.
- **Approach**:
  - Technology-separated analysis: Compare categories split by sequencing technology
  - Temporal trend analysis: Plot quality metrics over time (2019-2025)
  - HiFi-only temporal analysis: Eliminate technology confounding
- **Key Questions**:
  - Are quality differences consistent across technologies (HiFi vs CLR)?
  - Do quality metrics improve over time, and is this technology-driven?
  - Do temporal trends persist when technology is held constant?
- **Depends on**:
  - `data/vgp_assemblies_3categories_tech.csv` (3-category data with technology inference)
  - scipy for statistical tests (Mann-Whitney U, Spearman correlation)
- **Generates**:
  - `figures/technology_temporal/01_prialt_tech_comparison.png` (HiFi vs CLR)
  - `figures/technology_temporal/04_hifi_only_temporal_trends.png` (HiFi-only, 2021-2025)
  - `figures/technology_temporal/technology_effects_statistics.csv`
  - `figures/technology_temporal/temporal_trends_hifi_only_statistics.csv`
- **Dataset**: 541 VGP assemblies, 464/541 (86%) with technology assignment (355 HiFi, 107 CLR)
- **Last modified**: 2026-02-25
- **Status**: Code optimized (DPI reduced 300→150 to prevent image loading errors)
- **Execution time**: ~10-15 minutes
- **Priority**: Confounding analysis - validates that curation effects are not driven by technology or temporal biases
- **Note**: Figure sizes reduced (DPI 150) to prevent notebook image loading errors
```

**Benefits of Comprehensive Documentation:**

1. **Resume work easily**: Understand analysis purpose months later
2. **Collaboration**: Others can understand without reading code
3. **Dependency tracking**: Know what data/scripts are required
4. **Output tracking**: Know what files this notebook generates
5. **Execution planning**: Estimate time needed to re-run
6. **Prioritization**: Understand role in overall project

#### Update Frequency

- **End of every session**: Quick update with `/update-manifest`
- **After adding files**: Note new files, mark as [TO BE DOCUMENTED]
- **After major changes**: Full regeneration with `/generate-manifest`
- **Before sharing**: Ensure MANIFESTs are current

#### MANIFEST Session Context Updates

**Structure for "Recent Session Work" Section:**

When running `/update-manifest`, document the session in this format:

```markdown
**Recent Session Work** (YYYY-MM-DD):
- **[Action taken]**:
  - Specific change 1 with details
  - Specific change 2 with quantitative results
  - Why this change was made
- Brief description of problem solved or feature added
- Any updates to directory structure or workflow
```

**Example Session Documentation:**

```markdown
**Recent Session Work** (2026-02-25):
- **Updated Technology_Temporal_Analysis.ipynb code**:
  - Reduced DPI from 300→150 in global settings and all savefig calls
  - Reduced figure sizes: 01_prialt (15×10→12×8), 02_all_tech (18×12→14×9)
  - Prevents image loading errors while maintaining publication quality
  - File sizes reduced by ~75% (combination of DPI and size reduction)
- Added Technology_Temporal_Analysis.ipynb entry to root MANIFEST
- Updated directory structure to include figures/technology_temporal/
- Added HiFi-only temporal analysis section to eliminate technology confounding
```

**Next Steps Format:**

Prioritize and number action items:

```markdown
**Next Steps**:
1. **[High priority action]** - [Why it's important]
2. **[Medium priority]** - [Context]
3. **[Future work]** - [When to tackle]
```

**Example:**
```markdown
**Next Steps**:
1. **Re-run Technology_Temporal_Analysis.ipynb** - Execute cells to regenerate figures with optimized 150 DPI settings
2. **Generate notebook with temporal effect and only HiFi data** - Already added to notebook, need to execute new cells
3. **Write integrated manuscript Results section** - Combine findings from all 5 clades into cohesive narrative
```

This structure makes it easy to resume work by quickly understanding what was done and what's next.

### Integration with Project Structure

Add MANIFESTs to standard project organization:

```
project/
├── MANIFEST.md                 # Root project index
├── MANIFEST_TEMPLATE.md        # Template for new MANIFESTs
├── data/
│   ├── MANIFEST.md            # Data inventory
│   └── [data files]
├── figures/
│   ├── MANIFEST.md            # Figure catalog
│   └── [figure files]
├── scripts/
│   ├── MANIFEST.md            # Script documentation
│   └── [script files]
├── documentation/
│   ├── MANIFEST.md            # Doc organization
│   └── [doc files]
└── [other directories with MANIFESTs as needed]
```

### Common MANIFEST Patterns

#### For Data Directories

Emphasize:
- Data provenance and source
- File formats and structure
- Original vs processed versions
- Data dependencies and lineage
- Size and scale information

#### For Figure Directories

Emphasize:
- Generating code (which notebook/script)
- Data sources
- Manuscript figure numbers
- Key messages and findings
- Figure dependencies

#### For Script Directories

Emphasize:
- Input/output relationships
- Execution order
- Usage examples
- Dependencies (packages)
- Script purpose and logic

#### For Documentation Directories

Emphasize:
- Entry points (where to start)
- Document categories
- Active vs archived
- Session summaries location
- Critical documents for resuming work

### Real-World Example

See the `Curation_Paper_figures` project for a complete implementation:
- 5 MANIFEST files (root + 4 subdirectories)
- ~10,000 lines of documentation
- Covers 3 notebooks, 12 scripts, 18 figures, 48 doc files
- Enables session startup in 2,000 tokens vs 15,000+ tokens
- Includes working examples of all MANIFEST types

### Benefits Summary

**For Claude Code**:
- 85-90% reduction in session startup tokens
- Fast project orientation (2-3 MANIFESTs vs 20+ files)
- Clear entry points and workflow understanding
- Efficient file navigation without exploring

**For Users**:
- Quick work resumption (read 1 MANIFEST vs 10+ files)
- Clear project documentation
- Session continuity (Notes for Resuming Work)
- Workflow transparency (dependency maps)

**For Teams**:
- Faster onboarding for new members
- Shared understanding of project structure
- Clear documentation of decisions
- Easier code review (understand context quickly)

### Troubleshooting

**MANIFEST too long** (>2,500 tokens):
- Break into subdirectory MANIFESTs
- Use "See subdirectory MANIFEST" links
- Summarize instead of listing all files

**MANIFEST outdated**:
- Set up session-end habit: `/update-manifest` before `/safe-exit`
- Use `/generate-manifest --update` for full refresh
- Add "Last Updated" reminders

**Too many [USER TO FILL] fields**:
- Fill in during active work, not after
- Use `/update-manifest` to capture context immediately
- Ask user questions during generation for key info

**Unclear what to include**:
- Think: "What would I need to resume work in 6 months?"
- Include anything that saves reading a file
- Front-load critical information

## Integration with Other Skills

This skill works well with:
- **python-environment** - Environment setup and management
- **claude-collaboration** - Team workflow best practices
- **jupyter-notebook-analysis** - Notebook organization standards
- **data-backup** - Backup system should include MANIFESTs
- **project-sharing** - Include MANIFESTs in shared packages

## Templates and Tools

### Quick Project Setup

```bash
# Create standard research project structure
mkdir -p data/{raw,processed,external} notebooks scripts src tests docs results config
touch README.md .gitignore environment.yml
```

### Cookiecutter Templates

Consider using cookiecutter for standardized project templates:
- `cookiecutter-data-science` - Data science projects
- `cookiecutter-research` - Research projects
- Custom team templates

## References and Resources

- [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/)
- [A Quick Guide to Organizing Computational Biology Projects](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424)
- [Good Enough Practices in Scientific Computing](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005510)
