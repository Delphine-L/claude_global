# Deprecation and Cleanup Guide

Strategies for deprecating files, identifying essential files, and cleaning up projects.

## Systematic Deprecation Strategy

When cleaning up projects, **deprecate rather than delete** to maintain project history and recovery options.

### Pattern: Create Deprecated Subdirectories with Documentation

Instead of deleting old files:

```bash
# Create deprecated subdirectory with descriptive name
mkdir -p data-processing/phylo/deprecated_pre_feb20/

# Move old files
mv old_file1.txt old_file2.csv deprecated_pre_feb20/

# Create comprehensive README
cat > deprecated_pre_feb20/README.md << 'EOF'
# Deprecated [Category] - [Date/Reason]

**Date Deprecated**: YYYY-MM-DD
**Reason**: [Why these files are no longer active]

---

## Files ([N] files, ~[SIZE] total)

[List each file with explanation]

### 1. [Category of Files]
- **file1.txt** - What it was, why superseded
- **file2.csv** - Original purpose, replacement file

**Superseded by**: [Current active file(s)]

---

## Current Active Files (Use These Instead)

- `current_file.csv` - [Purpose and location]
- `updated_script.py` - [What it does now]

---

## Recovery Instructions

If you need to reference these old files:

```bash
cd deprecated_pre_feb20/
ls -lh
```

**Note**: These files should NOT be used for new analyses.
EOF
```

### Benefits

1. **Maintains history** - Can review what was changed and why
2. **Recovery option** - Files aren't permanently lost
3. **Clear documentation** - Future users understand what happened
4. **Clean working directory** - Old files don't clutter main workspace
5. **Audit trail** - Shows project evolution over time

### When to Use Deprecation

- Old analysis versions that have been superseded
- Intermediate processing files no longer needed
- Configuration files from previous approaches
- Batch processing logs from completed workflows

### When to Delete Instead

- Truly temporary files (e.g., Python `__pycache__`)
- Large data files that are easily regenerated
- LaTeX build artifacts
- Duplicate copies with no historical value

### Example: Multi-Directory Deprecation

When cleaning multiple subdirectories (phylo, telomeres, genomescope), create parallel deprecation structure:

```
data-processing/
├── phylo/
│   ├── deprecated_pre_feb20/
│   │   ├── README.md (explains 25 old files)
│   │   └── [old files]
│   └── [current files]
├── telomeres/
│   ├── deprecated_versions/
│   │   ├── README.md (explains 3 old CSV versions)
│   │   └── [old versions]
│   └── [current table]
└── genomescope_batch/
    ├── deprecated_batch_logs/
    │   ├── README.md (explains 11 log files)
    │   └── [processing logs]
    └── [current results]
```

**Each README should document:**
- What was deprecated and when
- Why these files are no longer active
- What replaced them (with file paths)
- How to recover if needed
- Warning not to use for new work

## Consolidating Scattered Deprecated Directories

When projects have deprecated files scattered in multiple subdirectories, consolidate them to a single root `deprecated/` location for easier management.

### Problem: Scattered Deprecation

```
project/
├── deprecated/
│   └── notebooks_20260226/
├── documentation/
│   └── deprecated/          # Scattered
├── data-processing/
│   ├── telomeres/
│   │   └── deprecated_versions/  # Scattered
│   ├── phylo/
│   │   └── deprecated_pre_feb20/ # Scattered
│   └── genomescope_batch/
│       └── deprecated_batch_logs/ # Scattered
```

**Issues:**
- Hard to find all deprecated files
- No central inventory
- Inconsistent naming
- Clutters active subdirectories

### Solution: Centralized Deprecation

**Step 1: Find all deprecated directories**
```bash
find . -type d -name "*deprecated*" -o -name "*OLD*" 2>/dev/null | grep -v ".git"
```

**Step 2: Create organized structure in root**
```bash
mkdir -p deprecated/data-processing
```

**Step 3: Move with descriptive names**
```bash
# Use clear, descriptive names that indicate origin
mv data-processing/telomeres/deprecated_versions \
   deprecated/data-processing/telomeres_versions

mv data-processing/phylo/deprecated_pre_feb20 \
   deprecated/data-processing/phylo_pre_feb20

mv documentation/deprecated \
   deprecated/documentation
```

**Step 4: Create master README**
```bash
cat > deprecated/README.md << 'EOF'
# Deprecated Files - [Project Name]

**Last Updated**: YYYY-MM-DD
**Purpose**: Central archive of all deprecated project files

## Organization

deprecated/
├── notebooks_YYYYMMDD/       # Deprecated notebooks
├── data-processing/          # Data processing deprecated
│   ├── telomeres_versions/
│   ├── phylo_pre_feb20/
│   └── genomescope_batch_logs/
├── documentation/            # Deprecated docs
└── [other categories]

## Contents

### 1. Category Name
- What was deprecated
- When and why
- What replaced it
- Where to find active files

[... sections for each category ...]

## Recovery

```bash
# Browse deprecated files
cd deprecated/
ls -lh
```

**Status**: Archived - Complete (YYYY-MM-DD)
EOF
```

**Step 5: Verify cleanup**
```bash
# Check that source directories are gone
for dir in path/to/old/deprecated1 path/to/old/deprecated2; do
    if [ -d "$dir" ]; then
        echo "Still exists: $dir"
    else
        echo "Removed: $dir"
    fi
done
```

### Result: Consolidated Structure

```
project/
└── deprecated/
    ├── README.md                # Master index
    ├── notebooks_YYYYMMDD/
    ├── data-processing/
    │   ├── category1/
    │   ├── category2/
    │   └── category3/
    ├── documentation/
    └── [other categories]
```

### Benefits

1. **Single location**: All deprecated files in one place
2. **Easy navigation**: Master README explains everything
3. **Clean subdirectories**: No scattered `deprecated_*/` folders
4. **Preserved history**: All files and their READMEs intact
5. **Clear inventory**: Know exactly what's archived

### When to Consolidate

- **During major cleanup** - Part of project organization
- **Before sharing** - Single deprecated/ easier to exclude
- **When scattered dirs > 3** - Multiple deprecation locations confusing
- **After project maturity** - Once deprecation patterns emerge

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
- **Better documentation**: Explicit mapping of figures to scripts
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
