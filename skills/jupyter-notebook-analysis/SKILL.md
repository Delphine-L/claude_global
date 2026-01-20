---
name: jupyter-notebook-analysis
description: Best practices for creating comprehensive Jupyter notebook data analyses with statistical rigor, outlier handling, and publication-quality visualizations
---

# Jupyter Notebook Analysis Patterns

Expert knowledge for creating comprehensive, statistically rigorous Jupyter notebook analyses.

## When to Use This Skill

- Creating multi-cell Jupyter notebooks for data analysis
- Adding correlation analyses with statistical testing
- Implementing outlier removal strategies
- Building series of related visualizations (10+ figures)
- Analyzing large datasets with multiple characteristics

## Common Pitfalls

### Variable Shadowing in Loops

**Problem**: Using common variable names like `data` as loop variables overwrites global variables:

```python
# BAD - Shadows global 'data' variable
for i, (sp, data) in enumerate(species_by_gc_content[:10], 1):
    val = data['gc_content']
    print(f'{sp}: {val}')
```

After this loop, `data` is no longer your dataset list - it's the last species dict!

**Solution**: Use descriptive loop variable names:

```python
# GOOD - Uses specific name
for i, (sp, sp_data) in enumerate(species_by_gc_content[:10], 1):
    val = sp_data['gc_content']
    print(f'{sp}: {val}')
```

**Detection**: If you see errors like "Type: <class 'dict'>" when expecting a list, check for variable shadowing in recent cells.

**Prevention**:
- Never use generic names (`data`, `item`, `value`) as loop variables
- Use prefixed names (`sp_data`, `row_data`, `inv_data`)
- Add validation cells that check variable types
- Run "Restart & Run All" regularly to catch issues early

**Common shadowing patterns to avoid**:
```python
for data in dataset:          # Shadows 'data'
for i, data in enumerate():   # Shadows 'data'
for key, data in dict.items() # Shadows 'data'
```

## Outlier Handling Best Practices

### Two-Stage Outlier Removal

For analyses correlating characteristics across aggregated entities (e.g., species-level summaries):

1. **Stage 1: Count-based outliers (IQR method)**
   - Remove entities with abnormally high sample counts
   - Prevents over-represented entities from skewing correlations
   - Apply BEFORE other analyses

   ```python
   import numpy as np
   workflow_counts = [entity_data[id]['workflow_count'] for id in entity_data.keys()]
   q1 = np.percentile(workflow_counts, 25)
   q3 = np.percentile(workflow_counts, 75)
   iqr = q3 - q1
   upper_bound = q3 + 1.5 * iqr

   outliers = [id for id in entity_data.keys()
               if entity_data[id]['workflow_count'] > upper_bound]
   for id in outliers:
       del entity_data[id]
   ```

2. **Stage 2: Value-based outliers (percentile)**
   - Remove extreme values for visualization clarity
   - Apply ONLY to visualization data, not statistics
   - Typically top 5% for highly skewed distributions

   ```python
   values = [entity_data[id]['metric'] for id in entity_data.keys()]
   threshold = np.percentile(values, 95)
   viz_entities = [id for id in entity_data.keys()
                   if entity_data[id]['metric'] <= threshold]

   # Use viz_entities for plotting
   # Use full entity_data.keys() for statistics
   ```

### Characteristic-Specific Outlier Removal

When analyzing genome characteristics vs metrics, remove outliers for the characteristic being analyzed:

```python
# After removing workflow count outliers, also remove heterozygosity outliers
heterozygosity_values = [species_data[sp]['heterozygosity'] for sp in species_data.keys()]

het_q1 = np.percentile(heterozygosity_values, 25)
het_q3 = np.percentile(heterozygosity_values, 75)
het_iqr = het_q3 - het_q1
het_upper_bound = het_q3 + 1.5 * het_iqr

het_outliers = [sp for sp in species_data.keys()
                if species_data[sp]['heterozygosity'] > het_upper_bound]

for sp in het_outliers:
    del species_data[sp]

print(f'Removed {len(het_outliers)} heterozygosity outliers (>{het_upper_bound:.2f}%)')
print(f'New heterozygosity range: {min(vals):.2f}% - {max(vals):.2f}%')
```

**Apply separately for each characteristic**:
- Genome size outliers for genome size analysis
- Heterozygosity outliers for heterozygosity analysis
- Repeat content outliers for repeat content analysis

### When to Skip Outlier Removal

- Memory usage plots when investigating over-allocation patterns
- Comparison plots (allocated vs used) where outliers reveal problems
- User explicitly requests to see all data
- Data is already limited (< 10 points)

**Document clearly** in plot titles and code comments which outlier removal is applied.

## Statistical Rigor

### Required for Correlation Analyses

1. **Pearson correlation with p-values**:
   ```python
   from scipy import stats
   correlation, p_value = stats.pearsonr(x_values, y_values)
   sig_text = 'significant' if p_value < 0.05 else 'not significant'
   ```

2. **Report both metrics**:
   - Correlation coefficient (r) - strength and direction
   - P-value - statistical significance (α=0.05)
   - Sample size (n)

3. **Display on plots**:
   ```python
   ax.text(0.98, 0.02,
           f'r = {correlation:.3f}\np = {p_value:.2e}\n({sig_text})\nn = {len(data)} species',
           transform=ax.transAxes, ...)
   ```

## Large-Scale Analysis Structure

### Organizing 60+ Cell Notebooks

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

## Template Generation Pattern

For creating multiple similar analysis cells:

```python
# Create template with placeholder variables
template = '''
if len(data_with_species) > 0:
    print('Analyzing {display} vs {metric}...\\n')

    # Aggregate data per species
    species_data = {{}}

    for inv in data_with_species:
        {name} = safe_float_convert(inv.get('{name}'))
        if {name} is None:
            continue
        # ... analysis code
'''

# Generate multiple cells from characteristics list
characteristics = [
    {'name': 'genome_size', 'display': 'Genome Size', 'unit': 'Gb'},
    {'name': 'heterozygosity', 'display': 'Heterozygosity', 'unit': '%'},
    # ...
]

for char in characteristics:
    code = template.format(**char)
    # Write to notebook or temp file
```

## Helper Function Pattern

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

Include in Cell 7 (enrichment) and reference: "# Helper function (same as Cell 7)"

## Publication-Quality Figures

Standard settings:
- DPI: 300
- Figure size: (12, 8) for single plots, (16, 7) for side-by-side
- Grid: `alpha=0.3, linestyle='--'`
- Point size: Proportional to sample count (`s=[50 + count*20 for count in counts]`)
- Colormap: 'viridis' for workflow counts

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
- Asian elephant: 2n=56, n=28, has X+Y → expected 29 scaffolds
- White-throated sparrow: 2n=82, n=41, has Z+W → expected 42 scaffolds

This adjustment accounts for the biological reality that X and Y (or Z and W) are distinct chromosomes.
```

### Writing Style Matching
To match manuscript style:
- Read draft paper PDF to extract tone and terminology
- Use same technical vocabulary
- Match paragraph structure (observation → mechanism → implication)
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

### Environment Setup

For CLI-based workflows (Claude Code, SSH sessions):

```bash
# Run in background with token authentication
/path/to/conda/envs/ENV_NAME/bin/jupyter lab --no-browser --port=8888
```

**Parameters**:
- `--no-browser`: Don't auto-open browser (for remote sessions)
- `--port=8888`: Specify port (default, can change if occupied)
- Run in background: Use `run_in_background=true` in Bash tool

**Access URL format**:
```
http://localhost:8888/lab?token=TOKEN_STRING
```

**To stop later**:
- Find shell ID from BashOutput tool
- Use KillShell with that ID

**Installation if missing**:
```bash
/path/to/conda/envs/ENV_NAME/bin/pip install jupyterlab
```

## Notebook Size Management

For notebooks > 256 KB:
- Use `jq` to read specific cells: `cat notebook.ipynb | jq '.cells[10:20]'`
- Count cells: `cat notebook.ipynb | jq '.cells | length'`
- Check sections: `cat notebook.ipynb | jq '.cells[75:81] | .[].source[:2]'`

## Data Enrichment Pattern

When linking external metadata with analysis data:

```python
# Cell 6: Load genome metadata
import csv
genome_data = []
with open('genome_metadata.tsv') as f:
    reader = csv.DictReader(f, delimiter='\t')
    genome_data = list(reader)

genome_lookup = {}
for row in genome_data:
    species_id = row['species_id']
    if species_id not in genome_lookup:
        genome_lookup[species_id] = []
    genome_lookup[species_id].append(row)

# Cell 7: Enrich workflow data with genome characteristics
for inv in data:
    species_id = inv.get('species_id')

    if species_id and species_id in genome_lookup:
        genome_info = genome_lookup[species_id][0]

        # Add genome characteristics
        inv['genome_size'] = genome_info.get('Genome size', '')
        inv['heterozygosity'] = genome_info.get('Heterozygosity', '')
        # ... other characteristics
    else:
        # Set to None for missing data
        inv['genome_size'] = None
        inv['heterozygosity'] = None

# Create filtered dataset
data_with_species = [inv for inv in data if inv.get('species_id') and inv.get('genome_size')]
```

## Debugging Data Availability

Before creating correlation plots, verify data overlap:

```python
# Check how many entities have both metrics
species_with_metric_a = set(inv.get('species_id') for inv in data
                            if inv.get('metric_a'))
species_with_metric_b = set(inv.get('species_id') for inv in data
                            if inv.get('metric_b'))

overlap = species_with_metric_a.intersection(species_with_metric_b)
print(f"Species with both metrics: {len(overlap)}")

if len(overlap) < 10:
    print("⚠️ Warning: Limited data for correlation analysis")
    print(f"  Metric A: {len(species_with_metric_a)} species")
    print(f"  Metric B: {len(species_with_metric_b)} species")
    print(f"  Overlap: {len(overlap)} species")
```

### Variable State Validation

When debugging notebook errors, add validation cells to check variable integrity:

```python
# Validation cell - place before error-prone sections
print('=== VARIABLE VALIDATION ===')
print(f'Type of data: {type(data)}')
print(f'Is data a list? {isinstance(data, list)}')

if isinstance(data, list):
    print(f'Length: {len(data)}')
    if len(data) > 0:
        print(f'First item type: {type(data[0])}')
        print(f'First item keys: {list(data[0].keys())[:10]}')
elif isinstance(data, dict):
    print(f'⚠️  WARNING: data is a dict, not a list!')
    print(f'Dict keys: {list(data.keys())[:10]}')
    print(f'This suggests variable shadowing occurred.')
```

**When to use**:
- After "Restart & Run All" produces errors
- When error messages suggest wrong variable type
- Before cells that fail intermittently
- In notebooks with 50+ cells

**Best practice**: Include automatic validation in cells that depend on critical global variables.

## Programmatic Notebook Manipulation

When inserting cells into large notebooks:

```python
import json

# Read notebook
with open('notebook.ipynb', 'r') as f:
    notebook = json.load(f)

# Create new cell
new_cell = {
    "cell_type": "code",
    "execution_count": None,
    "metadata": {},
    "outputs": [],
    "source": [line + '\n' for line in code.split('\n')]
}

# Insert at position
insert_position = 50
notebook['cells'] = (notebook['cells'][:insert_position] +
                     [new_cell] +
                     notebook['cells'][insert_position:])

# Write back
with open('notebook.ipynb', 'w') as f:
    json.dump(notebook, f, indent=1)
```

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
