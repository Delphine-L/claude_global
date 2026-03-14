# Sharing and Export: Paths, HTML, Export, and Sharing Packages

## Path Management for Notebooks in Subdirectories

When notebooks are in a `notebooks/` subdirectory (common in sharing packages), use relative paths:

### Problem

Notebooks developed in project root use paths like:
```python
FIG_DIR = Path('figures/curation_impact')
DATA_FILE = 'data/dataset.csv'
```

These fail when notebooks are moved to `notebooks/` subdirectory.

### Solution

Update paths programmatically using nbformat:

```python
import nbformat

def update_notebook_paths(notebook_path):
    """Update paths to work from notebooks/ directory."""
    with open(notebook_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    for cell in nb.cells:
        if cell.cell_type == 'code':
            # Update figure paths
            cell.source = cell.source.replace(
                "Path('figures/",
                "Path('../figures/"
            )
            # Update data paths
            cell.source = cell.source.replace(
                "'data/",
                "'../data/"
            )

    with open(notebook_path, 'w') as f:
        nbformat.write(nb, f)
```

### Best Practice

In sharing packages, use structure:
```
project/
├── notebooks/        # Notebooks here
│   └── analysis.ipynb
├── figures/          # Figures here
├── data/            # Data here
└── scripts/         # Scripts here
```

Notebooks access files using `../`:
```python
FIG_DIR = Path('../figures/subfolder')
data = pd.read_csv('../data/dataset.csv')
```

### Verification

Test paths work:
```bash
cd notebooks/
jupyter nbconvert --to html --execute notebook.ipynb
```

If paths are correct, notebook executes without FileNotFoundError.

---

## Generating HTML for Documentation

When notebooks are for documentation only or contain references to figures that need to be generated:

### Convert Without Execution

```bash
# Generate HTML from current notebook state
jupyter nbconvert --to html notebook.ipynb --output-dir output/
```

This creates viewable HTML files without running code cells, useful for:
- Documentation notebooks with pre-generated figures
- Sharing notebooks before figure generation
- Quick previews during development

### Convert With Execution

When all dependencies are available:
```bash
# Execute and convert
jupyter nbconvert --to html --execute notebook.ipynb \
    --output-dir output/ \
    --ExecutePreprocessor.timeout=600
```

### Batch Conversion

Convert multiple notebooks:
```bash
for nb in notebooks/*.ipynb; do
    jupyter nbconvert --to html "$nb" --output-dir notebooks/
done
```

### Benefits of HTML Sharing

1. **No setup required**: Recipients can view immediately in browser
2. **Self-contained**: Includes all outputs and styling
3. **Professional**: Clean formatting with syntax highlighting
4. **Preserves outputs**: Shows results without re-running code

---

## Preparing Notebooks for Sharing

Remove outputs before sharing to reduce file size and avoid exposing intermediate results:

```python
import nbformat

def clean_notebook(input_path, output_path):
    """Remove outputs and execution counts."""
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    for cell in nb.cells:
        if cell.cell_type == 'code':
            cell.outputs = []
            cell.execution_count = None

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)

# Clean all notebooks in directory
from pathlib import Path
for nb_file in Path('notebooks').glob('*.ipynb'):
    clean_notebook(nb_file, f"cleaned/{nb_file.name}")
```

Benefits:
- Smaller file sizes
- No accidental data leakage
- Clean starting point for users
- Git-friendly (fewer diffs)

---

## Exporting Notebooks for Sharing

### Export Workflow for Distribution

When preparing notebooks for sharing with collaborators or supplementary materials:

**HTML Export (Recommended)**
```bash
# Activate environment with nbconvert
conda activate your_env

# Export to HTML (all figures embedded, opens in browser)
python -m nbconvert --to html --output shared/Analysis.html Analysis.ipynb
```

**Why HTML is best for sharing:**
- No software required - opens in any browser
- All figures embedded (no missing images)
- Self-contained single file
- Fully interactive (shows code and outputs)
- Works on any platform

**LaTeX/PDF Export**
```bash
# Requires pandoc (install: conda install -c conda-forge pandoc)
python -m nbconvert --to latex --output shared/Analysis.tex Analysis.ipynb

# Then compile with xelatex (handles Unicode better than pdflatex)
cd shared
xelatex -interaction=nonstopmode Analysis.tex
```

**Common Issue: Nested Image Paths**

nbconvert creates a `Analysis_files/` directory, but may nest it incorrectly:
```bash
# Problem: Images at Analysis_files/shared/Analysis_11_0.png
# LaTeX looks for: shared/Analysis_files/shared/Analysis_11_0.png

# Fix: Flatten the directory structure
mv Analysis_files/shared/* Analysis_files/
rmdir Analysis_files/shared

# Recompile
xelatex -interaction=nonstopmode Analysis.tex
```

**Prerequisites Check:**
```bash
# Check if pandoc installed
conda list pandoc

# Install if missing
conda install -c conda-forge pandoc

# For PDF, also need LaTeX
# macOS: brew install basictex
# Ubuntu: apt-get install texlive-xetex
```

### Path Verification Before Export

**Critical: Verify all image and data paths work in export context**

```python
# In notebook, check if paths are relative (good) or absolute (bad)
import os
from pathlib import Path

# GOOD: Relative paths work when notebook is moved
display(Image('figures/fig1.png'))
df = pd.read_csv('data/results.csv')

# BAD: Absolute paths break when sharing
display(Image('/Users/yourname/project/figures/fig1.png'))
df = pd.read_csv('/Users/yourname/project/data/results.csv')
```

**Test before sharing:**
1. Copy notebook to temporary directory
2. Try to run it there
3. Check all images load
4. Verify data files found

### Export Comparison

| Format | Size | Requires Software | Figures | Best For |
|--------|------|-------------------|---------|----------|
| **HTML** | 3-5 MB | None (browser) | Embedded | Quick sharing, presentations |
| **PDF** | Variable | PDF reader | Embedded | Print, formal documents |
| **LaTeX** | 100 KB | LaTeX compiler | External | Editing, customization |
| **ipynb** | 2-4 MB | Jupyter/VS Code | External | Reproducibility, collaboration |

### Troubleshooting Exports

**HTML export fails:**
```bash
# Missing nbconvert
conda install -c conda-forge nbconvert

# Missing pandoc
conda install -c conda-forge pandoc
```

**PDF has missing figures:**
- Check image paths are relative, not absolute
- Verify images exist in expected locations
- Look at `.log` file for specific errors

**PDF compilation hangs:**
- Large notebooks may timeout
- Use HTML instead for very large analyses
- Or split into smaller notebooks

**Figures show as broken links:**
- Images not found at specified paths
- Convert absolute paths to relative paths
- Ensure `figures/` directory included when sharing

## Notebook Outputs in Sharing Packages

### CRITICAL: Preserve Outputs When Sharing

**IMPORTANT: DO NOT clear notebook outputs when preparing sharing packages**

#### Why Outputs Must Be Preserved

1. **Documentation**: Outputs show the analysis results and are part of the documentation
2. **HTML versions**: HTML exports need outputs to display figures and results
3. **Quick review**: Recipients can view results without running code
4. **Reproducibility proof**: Outputs show what the analysis produced
5. **Figure embeddings**: Images and plots are embedded in outputs
6. **Professional presentation**: Complete notebooks look polished and finished

#### Wrong Approach

```python
# DO NOT DO THIS
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

# This removes all outputs - WRONG for sharing packages!
nb = nbformat.read(notebook_path, as_version=4)
clear = ClearOutputPreprocessor()
nb, _ = clear.preprocess(nb, {})  # Removes all outputs
nbformat.write(nb, notebook_path)
```

**Problems with clearing outputs:**
- HTML files will show empty cells instead of results
- Figures won't be visible
- Statistical results invisible
- Recipients must run code to see anything
- Defeats purpose of sharing analysis

#### Correct Approach

```python
# DO THIS: Copy notebooks as-is, preserving outputs
import shutil
shutil.copy2(notebook_path, share_dir)
```

**Proper path fixes without clearing outputs:**
```python
import json

# Read notebook as JSON (no nbformat dependency)
with open(notebook_path, 'r') as f:
    nb = json.load(f)

# Fix paths in source code only (outputs untouched)
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        source = ''.join(cell['source'])
        # Fix paths in source...
        source = source.replace('old/path/', 'new/path/')
        cell['source'] = source.split('\n')

# Write back (outputs preserved)
with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=1)
```

### When to Clear Outputs (Rare Cases Only)

**Only clear outputs when:**

1. **Development notebooks** with sensitive data in outputs
   - Example: API keys accidentally printed
   - Example: Protected health information in debug output

2. **Test notebooks** with excessive debug output
   - Example: 1000+ lines of debug prints
   - Example: Large temporary data dumps

3. **NEVER** for analysis notebooks in sharing packages
   - Recipients need to see the results
   - HTML versions require outputs
   - Outputs are the analysis documentation

### Verification Checklist

Before sharing notebooks:
- [ ] Outputs are present (cells show results)
- [ ] Figures display correctly
- [ ] Statistical results visible
- [ ] HTML conversion includes all content
- [ ] No sensitive information in outputs
- [ ] File paths work (data files, figures)

### HTML Export Verification

```bash
# Convert to HTML to verify outputs present
jupyter nbconvert --to html notebook.ipynb

# Check HTML file size
ls -lh notebook.html
# Analysis notebooks with outputs: 3-5 MB (good)
# Notebooks without outputs: <500 KB (missing outputs!)

# Open HTML and verify:
# - Figures are visible
# - Tables and dataframes display
# - Statistical results show
```

### Common Mistake Pattern

```python
# WRONG: User asks to prepare sharing package,
#          Claude clears outputs "to clean the notebook"
# This is a common misunderstanding - outputs ARE the analysis!

# CORRECT: User asks to prepare sharing package,
#           Claude copies notebooks with outputs intact
#           Only fixes paths if needed
```

### Best Practice for Sharing

**Sharing package should include:**
1. **Notebook with outputs** (.ipynb) - For technical recipients
2. **HTML version** (.html) - For quick viewing by anyone
3. **Pre-generated figures** (PNG/SVG) - As standalone files
4. **Data files** - For full reproducibility

**Example sharing package:**
```
shared-2026-02-05-analysis/
├── Curation_Impact_Analysis.ipynb    # WITH outputs
├── Curation_Impact_Analysis.html     # Converted from notebook with outputs
├── figures/
│   └── curation_impact/
│       ├── 01_scaffold_n50.png       # Standalone figures
│       └── 02_scaffold_count.png
└── data/
    └── vgp_assemblies.csv
```

**Result**: Recipients can:
- View HTML immediately (no setup needed)
- Open notebook and see results
- Run notebook to reproduce
- Use standalone figures in presentations
