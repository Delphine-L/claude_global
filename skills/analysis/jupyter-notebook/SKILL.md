---
name: jupyter-notebook-analysis
description: Best practices for creating comprehensive Jupyter notebook data analyses with statistical rigor, outlier handling, and publication-quality visualizations. Includes Claude API image size helpers.
version: 1.2.0
context: fork
allowed-tools: Read, Grep, Glob, Bash
---

# Jupyter Notebook Analysis Patterns

Expert knowledge for creating comprehensive, statistically rigorous Jupyter notebook analyses.

## When to Use This Skill

- Creating multi-cell Jupyter notebooks for data analysis
- Adding correlation analyses with statistical testing
- Implementing outlier removal strategies
- Building series of related visualizations (10+ figures)
- Analyzing large datasets with multiple characteristics
- Building data update/enrichment notebooks with multi-source merging
- Generating figures for sharing with Claude or other AI tools

## Important: Image Size Constraints

**When generating images to share with Claude**, images must not exceed **8000 pixels** in either dimension. Add this helper to your notebook imports:

```python
# Standard imports with Claude size checking
import matplotlib.pyplot as plt
import seaborn as sns
from PIL import Image

MAX_CLAUDE_DIM = 7999  # Claude API limit with safety margin

def save_figure(filename, dpi=300, **kwargs):
    """Save figure with automatic Claude size constraint check."""
    plt.savefig(filename, dpi=dpi, bbox_inches='tight', **kwargs)

    # Verify and auto-resize if needed
    img = Image.open(filename)
    if img.width > MAX_CLAUDE_DIM or img.height > MAX_CLAUDE_DIM:
        print(f"Auto-resizing {filename} for Claude compatibility")
        print(f"   Original: {img.width}x{img.height}")
        img.thumbnail((MAX_CLAUDE_DIM, MAX_CLAUDE_DIM), Image.Resampling.LANCZOS)
        img.save(filename)
        print(f"   Resized: {img.width}x{img.height}")
    else:
        print(f"OK {filename}: {img.width}x{img.height}")

# Safe figure sizes for Claude (300 DPI)
FIG_SIZES = {
    'small': (7, 5),       # 2100x1500 px
    'medium': (12, 9),     # 3600x2700 px
    'large': (20, 15),     # 6000x4500 px
    'max': (26, 26),       # 7800x7800 px - maximum safe
}

# Use in notebook
fig, ax = plt.subplots(figsize=FIG_SIZES['medium'])
# ... plotting code ...
save_figure('figure.png')
```

**For complete image size guidance**, see the **data-visualization** skill.

## Core Notebook Patterns

### Data Update/Enrichment Notebooks

Use structured notebook patterns for multi-source data merging and enrichment. Key principles:

1. **Configuration section at top** with safety defaults (`ENABLE_AWS_FETCH = False`, `TEST_MODE = True`)
2. **Composite keys** for complex merge uniqueness requirements
3. **Conflict resolution** with configurable strategy (NEW vs OLD priority)
4. **Idempotent column addition** -- check if columns exist before adding
5. **Enrichment tracking** -- count what was actually saved, not just fetched
6. **Two-stage file workflow** -- input file -> distinct output file (never in-place)

For detailed patterns including data update, enrichment, and AWS GenomeArk workflows, see [notebook-patterns.md](notebook-patterns.md).

### Notebook Editing

**Always use NotebookEdit tool** for `.ipynb` file modifications -- never the Edit tool (corrupts JSON structure).

Three modes: **replace** (update cell content), **insert** (add new cell after target), **delete** (remove cell).

Key rules:
- Always specify `cell_type` when inserting
- Find cell IDs with `jq` or Python JSON parsing
- After programmatic edits, instruct user to "Restart & Run All"
- Update in dependency order when changing metrics across cells

For NotebookEdit usage, programmatic JSON manipulation, bulk operations, and cell newline handling, see [notebook-editing.md](notebook-editing.md).

## Statistical Methods

### Required for All Correlation Analyses

1. **Pearson correlation with p-values** using `scipy.stats.pearsonr`
2. **Report r, p-value, and n** on every correlation plot
3. **Mann-Whitney U test** for group comparisons

### Outlier Handling

- **Stage 1**: Count-based outliers (IQR method) -- remove before analysis
- **Stage 2**: Value-based outliers (percentile) -- apply only to visualization, not statistics
- Apply characteristic-specific outlier removal separately per analysis
- Always report number of outliers removed

### Statistical Claim Verification (CRITICAL)

**BEFORE finalizing any analysis notebook**, verify ALL statistical claims against actual computed values. Text claims can become stale after data/code updates. Extract claims, rerun tests, create verification table.

For detailed statistical methods, outlier removal code, claim verification workflow, and confounding analysis, see [statistical-methods.md](statistical-methods.md).

## Publication-Quality Figures

### Key Standards

- **DPI**: 300 for publication, 150 for digital viewing
- **Font sizes**: Title 18pt bold, axis labels 16pt bold, ticks 14pt, legend 12pt
- **Colors**: Use colorblind-safe palettes (IBM/Okabe-Ito). Blue `#0173B2` + Orange `#DE8F05` for two-group comparisons
- **Data imbalance**: Add prominent warnings when sample size ratio > 5x

### Image Display

- Use HTML `<img>` tags in markdown cells for responsive SVG/PNG scaling
- Crop SVGs by modifying `viewBox` attributes directly (no ImageMagick needed)
- Manage DPI to prevent "Output too large" errors (use 150 DPI default)

For detailed font size tables, color palette code, imbalance handling, SVG manipulation, and DPI management, see [visualization-guide.md](visualization-guide.md).

## Notebook Organization

### Large Notebooks (60+ cells)

- Use markdown section headers with cell pairing pattern
- Consistent naming for figures, variables, and functions
- Progressive enhancement from basic to complex analyses

### Dual-Notebook System

For analyses with 5+ figures preparing for publication:
- **Code notebook**: Executable analysis, figure generation, statistical tests
- **Presentation notebook**: Figure displays, captions, interpretations, methods

### Splitting and Deprecation

When splitting notebooks, recreate all calculated columns and variable definitions in each split. When deprecating, create dated directories with documentation.

For figure usage analysis, splitting strategies, dual-notebook workflow, publication notebook structure, TOC generation, deprecation workflow, and migration guides, see [notebook-organization.md](notebook-organization.md).

## Sharing and Export

### Key Rules

- **Preserve outputs** when preparing sharing packages (outputs ARE the documentation)
- Use **relative paths** (never absolute) for portability
- **HTML export** is best for sharing (self-contained, no software needed)
- Update paths programmatically when moving notebooks to subdirectories

For path management, HTML/PDF/LaTeX export, sharing package structure, and output preservation guidelines, see [sharing-and-export.md](sharing-and-export.md).

## Template and Helper Patterns

### Template Generation

For creating multiple similar analysis cells:

```python
template = '''
if len(data_with_species) > 0:
    print('Analyzing {display} vs {metric}...\\n')
    species_data = {{}}
    for inv in data_with_species:
        {name} = safe_float_convert(inv.get('{name}'))
        if {name} is None:
            continue
        # ... analysis code
'''

characteristics = [
    {'name': 'genome_size', 'display': 'Genome Size', 'unit': 'Gb'},
    {'name': 'heterozygosity', 'display': 'Heterozygosity', 'unit': '%'},
]

for char in characteristics:
    code = template.format(**char)
```

### Helper Function Pattern

Define once, reuse throughout:

```python
def safe_float_convert(value):
    """Convert string to float, handling comma separators"""
    if not value or not str(value).strip():
        return None
    try:
        return float(str(value).replace(',', ''))
    except (ValueError, TypeError):
        return None
```

## Troubleshooting

Key pitfalls to watch for:
- **Variable shadowing**: Never use `data` as a loop variable (shadows global)
- **Column name mismatches**: Always print `df.columns.tolist()` before processing
- **Cell execution order**: After NotebookEdit inserts, "Restart & Run All"
- **Notebook size**: Use `jq` for notebooks > 256 KB

For detailed troubleshooting, variable validation, debugging techniques, and environment setup, see [troubleshooting.md](troubleshooting.md).

## Best Practices Summary

1. **Always check data availability** before creating analyses
2. **Document outlier removal** clearly in titles and comments
3. **Use consistent naming** for variables and figures
4. **Include statistical testing** for all correlations
5. **Separate visualization from statistics** when filtering outliers
6. **Create templates** for repetitive analyses
7. **Use helper functions** consistently across cells
8. **Organize with markdown headers** for navigation
9. **Test with small datasets** before running full analyses
10. **Save intermediate results** for expensive computations
11. **Use NotebookEdit tool** for all `.ipynb` file modifications

## Supporting Files Reference

| File | Contents |
|------|----------|
| [notebook-patterns.md](notebook-patterns.md) | Data update, enrichment, AWS GenomeArk patterns |
| [notebook-editing.md](notebook-editing.md) | NotebookEdit tool, programmatic manipulation, metrics updates |
| [visualization-guide.md](visualization-guide.md) | Publication figures, colors, image display, SVG, DPI |
| [statistical-methods.md](statistical-methods.md) | Outlier handling, statistical rigor, claim verification |
| [notebook-organization.md](notebook-organization.md) | Splitting, dual-notebook, deprecation, figure analysis |
| [sharing-and-export.md](sharing-and-export.md) | Paths, HTML/PDF export, sharing packages |
| [troubleshooting.md](troubleshooting.md) | Common pitfalls, debugging, validation, environment |
