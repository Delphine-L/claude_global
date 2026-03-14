# Notebook Organization: Structure, Splitting, and Deprecation

## Organizing 60+ Cell Notebooks

1. **Section headers** (markdown cells):
   - Main sections: "## CPU Runtime Analysis", "## Memory Analysis"
   - Subsections: "### Genome Size vs CPU Runtime"

2. **Cell pairing pattern**:
   - Markdown header + code cell for each analysis
   - Keeps related content together
   - Easier to navigate and debug

3. **Consistent naming**:
   - Figure files: `fig18_genome_size_vs_cpu_hours.png`
   - Variables: `species_data`, `genome_sizes_full`, `genome_sizes_viz`
   - Functions: `safe_float_convert()` defined consistently

4. **Progressive enhancement**:
   - Start with basic analyses
   - Add enriched data (Cell 7 pattern)
   - Build increasingly complex correlations
   - End with multivariate analyses (PCA)

## Analyzing Notebook Figure Usage

To identify which figures are actually displayed/used in a notebook (useful for project cleanup):

### Extracting Figure References

```bash
# Extract figure paths from notebook JSON
grep -o "figures/[^'\"]*\.png" Notebook.ipynb | sort -u

# For Image() calls with filename parameter
grep "Image(filename=" Notebook.ipynb | grep -o "figures/[^'\"]*\.png"

# For display(Image(...)) patterns
grep "display(Image" Notebook.ipynb | grep -o "figures/[^'\"]*\.png"
```

### Analyzing Multiple Notebooks

```bash
for nb in *.ipynb; do
    echo "=== $nb ==="
    grep -o "figures/[^'\"]*\.png" "$nb" | sort -u
    echo ""
done > /tmp/all_used_figures.txt
```

### Common Figure Display Patterns to Search

- `Image(filename='figures/...')`  # Direct Image calls
- `display(Image(filename='...'))`  # Display wrapper
- `![Figure](figures/...)`  # Markdown cells
- `<img src="figures/...">`  # HTML in markdown cells

### Additional Quick Reference Commands

```bash
# Method 1: Simple grep for .png files
grep -o "\.png" notebook.ipynb | grep -v "image/png" | sort | uniq

# Method 2: Extract Image() calls with filenames
grep "Image(filename" notebook.ipynb | grep -o "'[^']*\.png'"

# Method 3: Find all display() calls with images
grep -n "\.png\|Image(\|display(" notebook.ipynb

# Method 4: Check multiple notebooks at once
for nb in *.ipynb; do
    echo "=== $nb ==="
    grep -o "[^'\"]*\.png" "$nb" | sort | uniq
done
```

### Cross-referencing Figures Across Notebooks

Check if figures are shared or unique:

```bash
# Find which notebooks use a specific figure
figure="01_scaffold_n50.png"
grep -l "$figure" *.ipynb

# Check if a notebook has unique figures
notebook="Analysis.ipynb"
for fig in $(grep -oh "[^'\"]*\.png" "$notebook"); do
    count=$(grep -l "$fig" *.ipynb | wc -l)
    if [ "$count" -eq 1 ]; then
        echo "UNIQUE: $fig"
    else
        echo "SHARED: $fig (used by $count notebooks)"
    fi
done
```

### Use Cases

- **Project cleanup**: Identify unused figures for archiving
- **Dependency analysis**: Verify figure generation scripts are needed
- **Documentation**: Map figures to notebooks that use them
- **Validation**: Ensure all referenced figures exist

### Example Workflow

```bash
# 1. Find all figures referenced in notebooks
grep -o "figures/[^'\"]*\.png" *.ipynb | sort -u > used_figures.txt

# 2. Find all existing figures
find figures/ -name "*.png" > all_figures.txt

# 3. Identify unused figures (those in all_figures but not in used_figures)
comm -23 <(sort all_figures.txt) <(sort used_figures.txt) > unused_figures.txt
```

## Splitting Large Notebooks

### When to Split

Split notebooks when they contain multiple distinct analyses that:
- Can run independently
- Have different execution times
- Serve different purposes (e.g., technology effects vs temporal trends)
- Would benefit from modular execution

### Splitting Strategy

**1. Identify Analysis Boundaries**
- Look for natural divisions (e.g., different research questions)
- Check for shared vs unique dependencies
- Consider which cells can be shared vs must be customized

**2. Common Pitfalls When Splitting**

**Missing Calculated Columns**: Columns created in code (not in CSV) must be recreated
```python
# Original notebook created this:
df['telomere_ratio'] = df['telomere_cat0_both_terminal'] / df['num_chromosomes_expected']

# Split notebook must recreate it - won't exist in data file!
```

**Missing Variable Definitions**: Variables defined in shared setup cells
```python
# These must be in BOTH notebooks:
category_colors = {'Phased+Dual': '#0072B2', ...}
df['year_numeric'] = df['release_year']
```

**Stale Notebook Metadata**: Jupyter execution state can cause issues
```python
# Clean all execution state before testing:
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        cell['execution_count'] = None
        cell['outputs'] = []
```

**3. Proper Splitting Workflow**

```python
import json

# Load original notebook
with open('Original_Notebook.ipynb', 'r') as f:
    original = json.load(f)

# Create new notebook with clean structure
new_nb = {
    "cells": [],
    "metadata": original["metadata"],  # Preserve original metadata
    "nbformat": original["nbformat"],
    "nbformat_minor": original["nbformat_minor"]
}

# Add cells - mix of custom and reused
new_nb["cells"].append({
    "cell_type": "markdown",
    "metadata": {},
    "source": ["# New Notebook Title"]
})

# Custom data loading with ALL required calculations
new_nb["cells"].append({
    "cell_type": "code",
    "execution_count": None,
    "metadata": {},
    "outputs": [],
    "source": [
        "df = pd.read_csv('data.csv')\n",
        "# Recreate calculated columns\n",
        "df['year_numeric'] = df['release_year']\n",
        "df['telomere_ratio'] = df['col_a'] / df['col_b']"
    ]
})

# Reuse complex cells from original
new_nb["cells"].append(original["cells"][25])  # Plotting cell

# Save
with open('New_Notebook.ipynb', 'w') as f:
    json.dump(new_nb, f, indent=2)
```

**4. Testing Split Notebooks**

```bash
# Test execution (don't rely on manual testing)
jupyter nbconvert --to notebook --execute New_Notebook.ipynb --output Test_Output.ipynb

# Check for errors
python3 << 'EOF'
import json
with open('Test_Output.ipynb', 'r') as f:
    nb = json.load(f)
for i, cell in enumerate(nb['cells']):
    if cell['cell_type'] == 'code':
        for output in cell.get('outputs', []):
            if output.get('output_type') == 'error':
                print(f"Error in cell {i}: {output.get('ename')}")
EOF
```

**5. Checklist for Split Notebooks**

- [ ] All calculated columns recreated in data loading
- [ ] All variable definitions included (colors, configs, etc.)
- [ ] Notebook metadata preserved from original
- [ ] Execution state cleaned (execution_count = None)
- [ ] Tested with `jupyter execute` (not just manual run)
- [ ] Figures generate successfully
- [ ] Statistics files created
- [ ] Documentation updated (MANIFEST.md)

### Debugging Jupyter Execution Errors

**Symptom**: `jupyter execute` or `nbconvert --execute` fails with `KeyError` or `NameError`, but running the same code in Python works perfectly.

**Root Causes**:

1. **Corrupted Notebook JSON Structure**
   - Cell metadata issues
   - Execution state conflicts
   - Malformed cell source arrays

2. **Variable Scoping in Notebook Execution**
   - Jupyter's kernel state differs from direct Python execution
   - Cells may execute in unexpected order during automated execution

**Debugging Strategy**:

```python
# Step 1: Test cells work in isolation
import pandas as pd
# Run each cell's code manually
df = pd.read_csv('data.csv')
df['year_numeric'] = df['release_year']
# ... verify each step works

# Step 2: Clean notebook execution state
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        cell['execution_count'] = None
        cell['outputs'] = []
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=2)

# Step 3: If still failing, rebuild notebook from scratch
# Use original metadata but fresh cell structure
```

**When Manual Test Succeeds but Jupyter Fails -> Rebuild**:

If code works in Python but Jupyter execution fails after cleaning execution state, the notebook JSON structure is likely corrupted. Solution: Rebuild from scratch using original cells.

```python
# Rebuild with clean structure
new_nb = {
    "cells": [],
    "metadata": original["metadata"],  # Use original metadata!
    "nbformat": 4,
    "nbformat_minor": 4
}
# Add cells systematically, test incrementally
```

**Prevention**:
- Always preserve original notebook metadata when creating new notebooks
- Clean execution state before committing notebooks
- Test with `jupyter execute` before considering notebook "done"

### Testing and Validation

**Level 1: Syntax Check**
```python
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
all_code = '\n'.join(''.join(cell['source']) for cell in nb['cells'] if cell['cell_type'] == 'code')
compile(all_code, '<notebook>', 'exec')  # Raises SyntaxError if invalid
```

**Level 2: Manual Execution**
```python
# Execute cells manually in sequence
namespace = {}
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        exec('\n'.join(cell['source']), namespace)
```

**Level 3: Jupyter Execution**
```bash
# The gold standard - tests actual Jupyter execution
jupyter nbconvert --to notebook --execute notebook.ipynb --output test.ipynb
```

**Level 4: Verify Outputs**
```python
# Check executed notebook for errors
with open('test.ipynb', 'r') as f:
    nb = json.load(f)
for cell in nb['cells']:
    for output in cell.get('outputs', []):
        if output.get('output_type') == 'error':
            print(f"Error: {output.get('ename')}: {output.get('evalue')}")
```

**Test Incrementally When Debugging**:
```python
# If full execution fails, test partial execution
jupyter nbconvert --execute --to notebook \
    --ExecutePreprocessor.timeout=60 \
    --execute-preprocessor-timeout=60 \
    notebook.ipynb
```

### Debugging Techniques

**Converting Notebook to Script for Testing**

When Jupyter execution fails mysteriously, convert to Python script:

```python
import json

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Extract code cells
script_lines = []
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        script_lines.extend(cell['source'])
        script_lines.append('\n')

with open('notebook_script.py', 'w') as f:
    f.write('\n'.join(script_lines))
```

Then run: `python3 notebook_script.py`

**Note**: This may hang on plotting code (waiting for display). Use for debugging only.

## Dual-Notebook System: Code vs Presentation

### The Problem with Single Large Notebooks

Trying to create a single notebook that serves both purposes leads to:
- Unwieldy files (25,000+ lines)
- Slow to load and execute
- Mixed purposes (code + narrative + documentation)
- Hard to maintain and update
- Difficult to share with different audiences

### The Solution: Two Complementary Notebooks

Maintain **two separate notebooks** with different purposes:

#### 1. Code-Based Analysis Notebook

**Purpose**: Execute analyses, generate figures, ensure reproducibility

**Contains**:
- Data loading and validation
- Statistical analyses and tests
- Figure generation code
- Quality checks and debugging
- All computational work

**Characteristics**:
- Heavy on code cells
- Light on narrative
- Executable top-to-bottom
- Version controlled
- Updated frequently during analysis

**File naming**: `Analysis_Name_3Categories.ipynb`

**Example structure**:
```python
# Cell 1: Imports and setup
import pandas as pd
import matplotlib.pyplot as plt

# Cell 2: Load data
df = pd.read_csv('data/dataset.csv')

# Cell 3: Validate data
assert len(df) == expected_n

# Cell 4: Generate Figure 1
fig, ax = plt.subplots()
# ... plotting code ...
plt.savefig('figures/fig1.png', dpi=300)

# Cell 5: Statistical test for Figure 1
from scipy.stats import mannwhitneyu
stat, pval = mannwhitneyu(group1, group2)
```

#### 2. Presentation Notebook

**Purpose**: Display results, document findings, prepare for publication

**Contains**:
- Figure displays (not generation)
- Comprehensive figure captions
- Detailed analyses and interpretations
- Methods documentation
- Statistical summaries
- Conclusions

**Characteristics**:
- Heavy on markdown
- Light on code (just figure loading)
- Narrative-focused
- Publication-ready
- Updated after analysis stabilizes

**File naming**: `Analysis_Name_3Categories_Presentation.ipynb`

**Example structure**:
```markdown
# Three-Category Curation Analysis

## Figure 1: Scaffold N50 Comparison
```
```python
from IPython.display import Image, display
display(Image('figures/fig1.png'))
```
```markdown
### Figure Caption
**Figure 1. Scaffold N50 increases with dual curation.**
(A) Comparison across three categories...
[Comprehensive caption]

### Analysis
The scaffold N50 shows a clear hierarchy...
[Detailed interpretation]

### Key Findings
- Phased+Dual: median N50 = X Mb (significantly higher, p<0.001)
- Phased+Single: median N50 = Y Mb
- Pri/alt+Single: median N50 = Z Mb
```

### Workflow Integration

**During active analysis:**
1. Work in **Code Notebook**
2. Generate and refine figures
3. Run statistical tests
4. Fix data issues

**After analysis stabilizes:**
1. Create **Presentation Notebook**
2. Display final figures
3. Write detailed analyses
4. Document methods
5. Prepare for publication

**When figures change:**
1. Update in **Code Notebook**
2. Regenerate figures
3. Update paths/captions in **Presentation Notebook** (minimal changes)

### Synchronization Strategy

**Keep synchronized:**
- Figure file paths
- Statistical results (p-values, effect sizes)
- Sample sizes
- Methods descriptions

**Use code notebook as single source of truth for:**
- Figure generation
- Statistical computations
- Data processing decisions

**Use presentation notebook for:**
- Narrative and interpretation
- Biological context
- Literature connections
- Publication formatting

### File Organization

```
project/
├── Analysis_Name_3Categories.ipynb          # Code notebook
├── Analysis_Name_3Categories_Presentation.ipynb  # Presentation
├── figures/
│   └── analysis_name/
│       ├── fig1.png
│       ├── fig2.png
│       └── ...
├── data/
│   └── dataset.csv
└── scripts/
    └── generate_figures.py  # Extracted from code notebook
```

### Benefits

**Code Notebook:**
- Fast execution (no heavy markdown)
- Easy debugging
- Clear computational workflow
- Version control friendly

**Presentation Notebook:**
- Publication-ready formatting
- Comprehensive documentation
- Easy to share with collaborators
- Focused narrative flow

### When to Use This Pattern

Use dual-notebook system when:
- Analysis generates 5+ figures
- Comprehensive documentation needed
- Preparing for publication
- Multiple collaborators involved
- Figures will be refined iteratively

Use single notebook when:
- Quick exploratory analysis
- Few figures (1-3)
- Informal documentation sufficient
- Solo project

### Alternative: Hybrid Approach

For moderately sized analyses, consider:
- Main code notebook for analysis
- Separate markdown document for narrative
- Link figures in markdown: `![Figure 1](figures/fig1.png)`
- Lighter weight than full presentation notebook

### Creating Presentation Notebooks: Three Approaches

#### Option A: Manual Creation
**Pros**: Full control, natural narrative flow
**Cons**: Labor intensive, hard to keep synchronized
**Best for**: Final publication notebook, one-time documentation

#### Option B: Programmatic Generation
**Pros**: Automatically synchronized, reusable
**Cons**: Upfront design effort, less flexible narrative
**Best for**: Repeated similar analyses, frequently updated figures

#### Option C: Hybrid (Recommended)
**Pros**: Balance of automation and customization
**Cons**: Requires planning both parts
**Best for**: Most scientific analyses

**Hybrid implementation**:
- Create notebook with placeholders
- Auto-populate figure displays from metadata
- Manually write analyses
- Use includes for methods from code notebook

## Creating Analysis Notebooks for Scientific Publications

When creating Jupyter notebooks to accompany manuscript figures:

### Structure Pattern
1. **Title and metadata** - Date, dataset info, sample sizes
2. **Overview** - Context from paper abstract/intro
3. **Figure-by-figure analysis**:
   - Code cell to display image
   - Detailed figure legend (publication-ready)
   - Comprehensive analysis paragraph explaining:
     - What the metric measures
     - Statistical results
     - Mechanistic explanation
     - Biological/technical implications
4. **Methods section** - Complete reproducibility information
5. **Conclusions** - Summary of findings

### Table of Contents

For analysis notebooks >10 cells, add a navigable table of contents at the top:

**Benefits**:
- Quick navigation to specific analyses
- Clear overview of notebook structure
- Professional presentation
- Easier for collaborators

**Implementation** (Markdown cell):
```markdown
# Analysis Name

## Table of Contents

1. [Data Loading](#data-loading)
2. [Data Quality Metrics](#data-quality-metrics)
3. [Figure 1: Completeness](#figure-1-completeness)
4. [Figure 2: Contiguity](#figure-2-contiguity)
5. [Figure 3: Scaffold Validation](#figure-3-scaffold-validation)
...
10. [Methods](#methods)
11. [References](#references)

---
```

**Section Headers** (Markdown cells):
```markdown
## Data Loading

[Your code/analysis]

---

## Data Quality Metrics

[Your code/analysis]
```

**Auto-generation**: For large notebooks, consider generating TOC programmatically:
```python
from IPython.display import Markdown

sections = ['Introduction', 'Data Loading', 'Analysis', ...]
toc = "## Table of Contents\n\n"
for i, section in enumerate(sections, 1):
    anchor = section.lower().replace(' ', '-')
    toc += f"{i}. [{section}](#{anchor})\n"

display(Markdown(toc))
```

### Methods Documentation

Always include a Methods section documenting:
- Data sources with accession numbers
- Key algorithms and formulas
- Statistical approaches
- Software versions
- Special adjustments (e.g., sex chromosome correction)
- Literature citations

**Example**:
```markdown
## Methods

### Karyotype Data

Karyotype data (diploid 2n and haploid n chromosome numbers) was manually curated from peer-reviewed literature for 97 species representing 17.8% of the VGP Phase 1 dataset (n = 545 assemblies).

#### Sex Chromosome Adjustment

When both sex chromosomes are present in the main haplotype, the expected number of chromosome-level scaffolds is:

**expected_scaffolds = n + 1**

For example:
- Asian elephant: 2n=56, n=28, has X+Y -> expected 29 scaffolds
- White-throated sparrow: 2n=82, n=41, has Z+W -> expected 42 scaffolds

This adjustment accounts for the biological reality that X and Y (or Z and W) are distinct chromosomes.
```

### Writing Style Matching
To match manuscript style:
- Read draft paper PDF to extract tone and terminology
- Use same technical vocabulary
- Match paragraph structure (observation -> mechanism -> implication)
- Include specific details (tool names, file formats, software versions)
- Use first-person plural ("we") if paper does
- Maintain consistent bullet point/list formatting

### Example Code Pattern
```python
# Display figure
from IPython.display import Image, display
from pathlib import Path

FIG_DIR = Path('figures/analysis_name')
display(Image(filename=str(FIG_DIR / 'figure_01.png')))
```

### Figure Legend Format
**Figure N. [Short title].** [Complete description of panels and what's shown]. [Statistical tests used]. [Sample sizes]. [Scale information]. [Color coding].

### Analysis Paragraph Structure
1. **What it measures** - Define the metric/comparison
2. **Statistical result** - Quantitative findings with p-values
3. **Mechanistic explanation** - Why this result occurs
4. **Implications** - What this means for conclusions

### Methods Section Must Include
- Dataset source and filtering criteria
- Metric definitions
- Outlier handling approach
- Statistical methods with justification
- Software versions and tools
- Reproducibility information
- Known limitations

This approach creates notebooks that serve both as analysis documentation and as supplementary material for publications.

## Notebook Deprecation Best Practices

When reorganizing or replacing notebooks, follow this deprecation workflow to preserve scientific content and maintain clear documentation:

### 1. Create Deprecation Directory with Date

```bash
mkdir -p deprecated/notebooks_YYYYMMDD/
```

Use dated directories to track when notebooks were deprecated and enable multiple deprecation events.

### 2. Move Old Notebook(s) with Clear Naming

```bash
# Rename to indicate deprecation
mv Temporal_Analysis_HiFi.ipynb deprecated/notebooks_20260226/Temporal_Analysis_HiFi_OLD.ipynb
```

Add `_OLD` suffix to clarify this is the deprecated version.

### 3. Create Deprecation Documentation (README.md)

Create comprehensive `deprecated/notebooks_YYYYMMDD/README.md`:

```markdown
# Deprecated Notebooks - YYYY-MM-DD

## [Analysis Type] Notebook Consolidation/Reorganization

**Date**: YYYY-MM-DD
**Reason**: [Why deprecated - e.g., "Reorganized for manuscript preparation"]

### Files Deprecated

#### `[Notebook_OLD.ipynb]` ([size])
- **Original name**: `[Notebook.ipynb]`
- **Created**: [date]
- **Last modified**: [date]
- **Purpose**: [brief description]

**Why deprecated:**
- [Specific reason 1 - e.g., "Unorganized structure (no TOC, methods scattered)"]
- [Specific reason 2 - e.g., "Section flow not logical for manuscript"]

**Replaced by:**
- New notebook: `[New_Notebook.ipynb]` (in root directory)
- Same analysis, better organization

**Content preserved:**
- All code cells
- All figures
- All statistical analyses
- All interpretations
- All CSV outputs

**What's different in new notebook:**
1. [Improvement 1 - e.g., "Table of contents with anchor links"]
2. [Improvement 2 - e.g., "Logical section flow (dataset -> analysis -> conclusions -> methods)"]
3. [Improvement 3 - e.g., "Clearer narrative for manuscript"]

### Recovery Instructions

If you need to reference the old notebook:
\```bash
# View old notebook
jupyter notebook deprecated/notebooks_YYYYMMDD/Notebook_OLD.ipynb

# Or copy back to root (not recommended)
cp deprecated/notebooks_YYYYMMDD/Notebook_OLD.ipynb .
\```
```

### 4. Update Root MANIFEST with PRIMARY Designation

After deprecating a notebook, update the root MANIFEST.md to clearly designate the replacement as PRIMARY:

**In MANIFEST.md:**
```markdown
**Entry Points**:
1. Start with MANIFEST.md (this file) for project overview
2. Read data/MIGRATION_GUIDE.md for data versioning
3. **Main analysis**: `New_Focused_Analysis.ipynb` (PRIMARY - focused approach)
4. Supporting analyses: `Other_Analysis.ipynb`, `Tech_Analysis.ipynb`
```

**Add deprecation note in "Recent Session Work":**
```markdown
**Recent Session Work** (YYYY-MM-DD):
- **Notebook deprecation**:
  - Deprecated `Old_Analysis.ipynb` (4.2 MB) -> `deprecated/notebooks_YYYYMMDD/`
  - Designated `New_Focused_Analysis.ipynb` as PRIMARY analysis notebook
  - Updated `deprecated/notebooks_YYYYMMDD/README.md` with full documentation
```

**Benefits of PRIMARY designation:**
- **Clear hierarchy**: Users immediately know which notebook to start with
- **Reduced confusion**: No ambiguity about which version to use
- **Smooth onboarding**: New collaborators find the right entry point
- **MANIFEST navigation**: Quick reference system shows active vs deprecated

### 5. Create Migration Guide (For Complex Reorganizations)

For notebooks with substantial reorganization, create `REORGANIZATION_GUIDE.md`:

```markdown
# [Notebook] Reorganization Guide

## Quick Reference: Which Cells to Copy Where

### Main Notebook: `[New_Notebook.ipynb]` (NEW - organized template)
### Source: `deprecated/notebooks_YYYYMMDD/[Old_Notebook.ipynb]`

---

## Section 1: [Section Name]

### 1.1 [Subsection]
**Copy these cells:**
- [ ] `cell_id_1` - [Cell description/purpose]
- [ ] `cell_id_2` - [Cell description/purpose]

### 1.2 [Subsection]
**Copy these cells:**
- [ ] `cell_id_3` - [Cell description/purpose]

---

## Section 2: [Section Name]

**Copy these cells:**
- [ ] `cell_id_4` - [Cell description/purpose]

---

## Cells NOT to Copy

These cells are in the original but not needed in reorganized version:
- [ ] `old_id_1` - [Reason - e.g., "Old section header (reorganized)"]
- [ ] `old_id_2` - [Reason - e.g., "Redundant with new section"]

---

## Cell ID Quick Reference

| Cell ID | Content | Goes to Section |
|---------|---------|----------------|
| `abc123` | Load data | 1.1 |
| `def456` | Figure 04 code | 2.1 |
| `ghi789` | Statistical analysis | 2.3 |

---

## Step-by-Step Instructions

1. **Open both notebooks in Jupyter:**
   - `[New_Notebook.ipynb]` (destination - NEW organized template)
   - `deprecated/notebooks_YYYYMMDD/[Old_Notebook_OLD.ipynb]` (source)

2. **For each section in template:**
   - Find the cell ID in source notebook (use Find/Search)
   - Copy the cell content
   - Paste into appropriate location in template
   - Check that it renders correctly

3. **Execute notebook top-to-bottom:**
   - Run all cells to verify everything works
   - Check that all figures generate correctly
   - Verify all statistics are calculated

4. **Final cleanup:**
   - Check TOC links work (click each anchor)
   - Verify section headers are clear
   - Save final version

---

## Verification Checklist

After copying all cells:

- [ ] TOC renders correctly with working links
- [ ] All code cells have proper dependencies (run top-to-bottom works)
- [ ] All figures generate correctly
- [ ] All statistics are calculated
- [ ] Markdown renders correctly (no broken formatting)
- [ ] Section flow is logical
- [ ] No duplicate content
- [ ] All interpretations match their figures
```

### 6. Create Notebook Status Tracker

`NOTEBOOK_STATUS.md` tracks active vs deprecated notebooks:

```markdown
# Notebook Status - [Analysis Type]

**Updated**: YYYY-MM-DD

## Current Active Notebook

### `[Active_Notebook.ipynb]` - ACTIVE
- **Purpose**: [Description]
- **Status**: [Template ready / Populated / Complete]
- **Structure**: [Section organization]
- **Sections**:
  1. [Section 1 name] ([key components])
  2. [Section 2 name] ([key components])
  3. [Section 3 name] ([key components])
  4. [Section 4 name] ([key components])

## Deprecated Notebooks

### `[Deprecated_Notebook_OLD.ipynb]` - DEPRECATED
- **Location**: `deprecated/notebooks_YYYYMMDD/`
- **Reason**: [Why deprecated]
- **Status**: Archived, kept for reference
- **Replaced by**: `[Active_Notebook.ipynb]`
- **Note**: [What's preserved, what changed]

## Supporting Files

### Active
- `REORGANIZATION_GUIDE.md` - Cell-by-cell copying instructions
- `figures/subfolder/` - All figure outputs
- `figures/subfolder/*.csv` - Statistical results

### Deprecated
- `deprecated/notebooks_YYYYMMDD/README.md` - Deprecation documentation

## Next Steps

1. [What needs to be done next]
2. [Any follow-up tasks]

## Key Improvements in New Notebook

1. [Improvement 1]
2. [Improvement 2]
3. [Improvement 3]
```

### 7. Update All MANIFESTs

Update relevant MANIFESTs to reflect deprecation (see documentation-organization skill "MANIFEST Update After Major Changes" section).

### Benefits of This Workflow

- **Scientific content preserved** for reference
- **Clear migration path** documented
- **No confusion** about which notebook to use
- **Reproducibility maintained** - old notebooks accessible
- **Organizational improvements** clearly explained
- **Cell-by-cell mapping** makes migration straightforward

### Token Efficiency

Future sessions can quickly understand notebook status from:
- `NOTEBOOK_STATUS.md` (~2 KB) - which notebook is active
- `deprecated/notebooks_YYYYMMDD/README.md` (~5 KB) - why deprecated
- `REORGANIZATION_GUIDE.md` (~10 KB) - how to migrate

Instead of exploring multiple large notebooks (~4 MB each) to understand status.

### Real Example

**Session**: Temporal analysis notebook reorganization (2026-02-26)

**Deprecation:**
- 2 notebooks deprecated: `Temporal_Analysis_HiFi.ipynb` (916 KB), `Technology_Temporal_Analysis.ipynb` (1.5 MB)
- Moved to `deprecated/notebooks_20260226/` with `_OLD` suffix
- Created comprehensive `README.md` explaining both deprecations
- Created `REORGANIZATION_GUIDE.md` with cell-by-cell instructions and 150+ line checklist
- Created `NOTEBOOK_STATUS.md` tracking active vs deprecated notebooks
- Updated 4 MANIFESTs (root, data, scripts, figures)

**Result:** New organized notebook `Temporal_Impact_Analysis.ipynb` with TOC, logical sections, and manuscript-ready structure, while preserving all scientific content from deprecated notebooks.
