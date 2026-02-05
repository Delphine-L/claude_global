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

## Integration with Other Skills

This skill works well with:
- **python-environment** - Environment setup and management
- **claude-collaboration** - Team workflow best practices
- **jupyter-notebook-analysis** - Notebook organization standards

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
