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

## Direct Notebook Editing with NotebookEdit Tool

**IMPORTANT**: You can edit Jupyter notebooks directly using the NotebookEdit tool without writing Python scripts or using command-line JSON manipulation.

### NotebookEdit Tool Overview

The NotebookEdit tool allows direct manipulation of `.ipynb` files with three modes:

**1. Replace mode** (default): Replace entire cell content
```python
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",
    cell_type="markdown",  # or "code"
    new_source="New content for this cell"
)
```

**2. Insert mode**: Add new cells
```python
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",  # Insert AFTER this cell
    edit_mode="insert",
    cell_type="markdown",
    new_source="Content for new cell"
)
```

**3. Delete mode**: Remove cells
```python
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",
    edit_mode="delete",
    new_source=""  # Required but ignored
)
```

### When to Use NotebookEdit vs Python Scripts

**Use NotebookEdit when:**
- ✅ Updating existing cell content (figure captions, analysis text)
- ✅ Adding single new cells (headers, display code, descriptions)
- ✅ Removing specific cells
- ✅ Making targeted changes to notebook structure
- ✅ Synchronizing notebook documentation with code changes

**Use Python scripts when:**
- ❌ Bulk operations (reordering many cells, restructuring entire notebook)
- ❌ Complex conditional logic based on cell content
- ❌ Programmatic generation of many cells at once
- ❌ Cell reordering requires precise index manipulation

### Finding Cell IDs

**Method 1: Bash with jq**
```bash
# List all cells with IDs
cat notebook.ipynb | jq '.cells[] | {id: .id, type: .cell_type, preview: .source[:2]}'

# Find specific content
cat notebook.ipynb | jq '.cells[] | select(.source[] | contains("Figure 10")) | .id'
```

**Method 2: Python script**
```python
import json
with open('notebook.ipynb') as f:
    nb = json.load(f)
for i, cell in enumerate(nb['cells']):
    src = ''.join(cell.get('source', []))[:60]
    print(f"{i}: {cell.get('id')}: {cell['cell_type']}: {src}...")
```

**Method 3: Insert without cell_id**
```python
# Insert at end of notebook
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    edit_mode="insert",
    cell_type="markdown",
    new_source="New section at end"
)
```

### Common Workflow: Updating Figure Documentation

When you regenerate figures with code changes:

1. **Update figure generation script**
2. **Regenerate figure file**
3. **Update notebook caption** with NotebookEdit:
   ```python
   NotebookEdit(
       notebook_path="Analysis.ipynb",
       cell_id="cell-26",  # Caption cell after figure display
       cell_type="markdown",
       new_source="**Figure 10. Updated caption...** [description]"
   )
   ```

### Common Workflow: Adding New Figure Section

When adding a new figure to existing notebook:

```python
# 1. Add section header
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-25",  # After previous figure
    edit_mode="insert",
    cell_type="markdown",
    new_source="---\n\n## Figure 10: New Analysis\n\n### Description"
)

# 2. Add display code
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-26",  # After header just created
    edit_mode="insert",
    cell_type="code",
    new_source="display(Image(filename=str(FIG_DIR / '10_analysis.png')))"
)

# 3. Add caption and analysis
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-27",  # After display code
    edit_mode="insert",
    cell_type="markdown",
    new_source="**Figure 10. Caption...** Analysis text..."
)
```

### Verifying Edits

Always check notebook structure after edits:
```bash
# Check cell count
cat notebook.ipynb | jq '.cells | length'

# Check specific section
cat notebook.ipynb | jq '.cells[25:30][] | {id: .id, type: .cell_type}'

# Preview content
cat notebook.ipynb | python3 -c "
import json, sys
nb = json.load(sys.stdin)
for i, c in enumerate(nb['cells'][25:30]):
    src = ''.join(c.get('source', []))[:80]
    print(f'{i+25}: {c.get(\"cell_type\")}: {src}...')
"
```

### Advantages of NotebookEdit

- **No temporary files** needed
- **No JSON manipulation** required
- **Preserves formatting** and cell metadata
- **Atomic operations** (single tool call per edit)
- **Clear intent** (replace/insert/delete modes)
- **Error handling** built-in

### Common Pitfalls

❌ **Don't use Edit tool on .ipynb files** - It treats them as text, corrupting JSON structure
```python
# WRONG - corrupts notebook
Edit(
    file_path="notebook.ipynb",
    old_string="old text",
    new_string="new text"
)
```

✅ **Use NotebookEdit for notebooks**
```python
# CORRECT
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-10",
    new_source="new cell content"
)
```

❌ **Don't forget cell_type when inserting**
```python
# WRONG - missing cell_type
NotebookEdit(
    notebook_path="notebook.ipynb",
    edit_mode="insert",
    new_source="content"
)
```

✅ **Always specify cell_type for insert**
```python
# CORRECT
NotebookEdit(
    notebook_path="notebook.ipynb",
    edit_mode="insert",
    cell_type="markdown",
    new_source="content"
)
```

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

### Verify Column Names Before Processing

**Problem**: Assuming column names without checking actual DataFrame structure leads to immediate failures. Column names may use different capitalization, spacing, or naming conventions than expected.

**Example error:**
```python
# Assumed column name
df_filtered = df[df['scientific_name'] == target]  # KeyError!

# Actual column name was 'Scientific Name' (capitalized with space)
```

**Solution**: Always check actual columns first:
```python
import pandas as pd
df = pd.read_csv('data.csv')

# ALWAYS print columns before processing
print("Available columns:")
print(df.columns.tolist())

# Then write filtering code with correct names
df_filtered = df[df['Scientific Name'] == target_species]  # Correct
```

**Best practice for data processing scripts:**
```python
# At the start of your script
def verify_required_columns(df, required_cols):
    """Verify DataFrame has required columns."""
    missing = [col for col in required_cols if col not in df.columns]
    if missing:
        print(f"ERROR: Missing columns: {missing}")
        print(f"Available columns: {df.columns.tolist()}")
        sys.exit(1)

# Use it
required = ['Scientific Name', 'tolid', 'accession']
verify_required_columns(df, required)
```

**Common column name variations to watch for:**
- `scientific_name` vs `Scientific Name` vs `ScientificName`
- `species_id` vs `species` vs `Species ID`
- `genome_size` vs `Genome size` vs `GenomeSize`

**Debugging tip**: Include column listing in all data processing scripts:
```python
# Add at script start for easy debugging
if '--debug' in sys.argv or len(df.columns) < 10:
    print(f"Columns ({len(df.columns)}): {df.columns.tolist()}")
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


###IQR-Based Outlier Removal for Visualization

**Standard Method**: 1.5×IQR (Interquartile Range)

**Implementation**:
```python
# Calculate IQR
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1

# Define outlier boundaries (standard: 1.5×IQR)
lower_bound = Q1 - 1.5*IQR
upper_bound = Q3 + 1.5*IQR

# Filter outliers
outlier_mask = (data >= lower_bound) & (data <= upper_bound)
data_filtered = data[outlier_mask]
n_outliers = (~outlier_mask).sum()

# IMPORTANT: Report outliers removed
print(f"Removed {n_outliers} outliers for visualization")
# Add to figure: f"({n_outliers} outliers removed)"
```

**Multi-dimensional Outlier Removal**:
```python
# For scatter plots with two dimensions (e.g., size ratio AND absolute size)
outlier_mask = (
    (ratio >= Q1_ratio - 1.5*IQR_ratio) &
    (ratio <= Q3_ratio + 1.5*IQR_ratio) &
    (size >= Q1_size - 1.5*IQR_size) &
    (size <= Q3_size + 1.5*IQR_size)
)
```

**Best Practice**: Always report number of outliers removed in figure statistics or caption.

**When to Use**: For visualization clarity when extreme values compress the main distribution. Not for removing "bad" data - use for display only.

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


### Adding Mann-Whitney U Tests to Figures

**When to Use**: Comparing continuous metrics between two groups (e.g., Dual vs Pri/alt curation)

**Standard Implementation**:
```python
from scipy import stats

# Calculate test
data_group1 = df[df['group'] == 'Group1']['metric']
data_group2 = df[df['group'] == 'Group2']['metric']

if len(data_group1) > 0 and len(data_group2) > 0:
    stat, pval = stats.mannwhitneyu(data_group1, data_group2, alternative='two-sided')
else:
    pval = np.nan

# Add to stats text
if not np.isnan(pval):
    stats_text += f"\nMann-Whitney p: {pval:.2e}"
```

**Display in Figures**: Include p-value in statistics box with format `Mann-Whitney p: 1.23e-04`

**Consistency**: Ensure all quantitative comparison figures include this test for statistical rigor.

## CRITICAL: Statistical Claim Verification

### The Problem
Notebook analysis text can contain claims based on:
- Preliminary results that changed
- Copy-paste errors from similar analyses
- Expectations that weren't verified
- Old results before data/code updates

**Real example from production notebook:**
- **Text claimed**: "significantly higher N50 values (p < 0.001)"
- **Actual result**: p = 0.28 (NOT significant)
- **Impact**: Would have published false conclusion

### Mandatory Verification Workflow

**BEFORE finalizing any analysis notebook:**

#### 1. Extract All Statistical Claims
Search for keywords:
- p-values: `p <`, `p =`, `p-value`
- Significance: `significant`, `significantly`, `difference`
- Comparisons: `higher`, `lower`, `greater`, `increased`, `decreased`

#### 2. Run Actual Statistical Tests
Don't trust existing text. Rerun the tests:

```python
from scipy import stats
import pandas as pd

# Load actual data
df = pd.read_csv('data.csv')

# Run test (example: Mann-Whitney U)
group1 = df[df['type']=='A']['metric']
group2 = df[df['type']=='B']['metric']
stat, p = stats.mannwhitneyu(group1, group2, alternative='two-sided')

print(f"Actual p-value: {p:.6f}")
print(f"Significant (p<0.05): {p < 0.05}")
```

#### 3. Document Actual Results
Create verification table:

| Figure | Metric | Text Claims | Actual p-value | Match? |
|--------|--------|-------------|----------------|--------|
| Fig 1 | N50 | "p<0.001 significant" | **0.28** | ❌ FALSE |
| Fig 2 | Gaps | "p=0.002 significant" | 0.0023 | ✅ TRUE |

#### 4. Common Discrepancy Patterns

**False Positive (Type I error in text):**
- Text claims significance when p > 0.05
- **Fix**: Rewrite to state "no significant difference"

**Missed Significance:**
- Text implies no difference when p < 0.05
- **Fix**: Add statistical evidence and effect interpretation

**Wrong Direction:**
- Text claims "Group A > Group B" when opposite is true
- **Fix**: Reverse comparison direction

**Outdated Organization:**
- Figures organized by old results
- **Fix**: Reorganize sections based on actual significance

#### 5. Correction Protocol

When errors found:
1. **Document the error** (create CORRECTIONS.md)
2. **Run verification script** on ALL claims
3. **Reorganize notebook** if section classification wrong
4. **Rewrite analysis text** to match actual results
5. **Update table of contents** with correct annotations
6. **Create milestone backup** documenting corrections

### Prevention

**For new analyses:**
```python
# Write analysis text AFTER running test, not before
stat, p = stats.mannwhitneyu(group1, group2)

# Generate text from actual results
if p < 0.05:
    text = f"significant difference (p={p:.4f})"
else:
    text = f"no significant difference (p={p:.2f})"
```

**Before any publication/sharing:**
1. Run verification on ALL statistical claims
2. Cross-check figure captions with actual p-values
3. Verify section organization matches significance
4. Get second person to spot-check key claims

### Why This Is Critical
- **Scientific integrity**: False claims damage credibility
- **Reproducibility**: Others can't reproduce wrong results
- **Peer review**: Reviewers will catch errors, causing rejection
- **Career impact**: Publishing false statistics has serious consequences

## Large-Scale Analysis Structure

### Control Analyses: Checking for Confounding

When comparing methods (e.g., Method A vs Method B), always check if observed differences could be explained by characteristics of the samples rather than the methods themselves.

**Critical control analysis**:
```python
import pandas as pd
from scipy import stats

def check_confounding(df, method_col, characteristics):
    """
    Compare sample characteristics between methods to check for confounding.

    Args:
        df: DataFrame with samples
        method_col: Column indicating method ('Method_A', 'Method_B')
        characteristics: List of column names to compare

    Returns:
        DataFrame with statistical comparison
    """
    results = []

    for char in characteristics:
        # Get data for each method
        method_a = df[df[method_col] == 'Method_A'][char].dropna()
        method_b = df[df[method_col] == 'Method_B'][char].dropna()

        if len(method_a) < 5 or len(method_b) < 5:
            continue

        # Statistical test
        stat, pval = stats.mannwhitneyu(method_a, method_b, alternative='two-sided')

        # Calculate effect size (% difference in medians)
        pooled_median = pd.concat([method_a, method_b]).median()
        effect_pct = (method_a.median() - method_b.median()) / pooled_median * 100

        results.append({
            'Characteristic': char,
            'Method_A_median': method_a.median(),
            'Method_A_n': len(method_a),
            'Method_B_median': method_b.median(),
            'Method_B_n': len(method_b),
            'p_value': pval,
            'effect_pct': effect_pct,
            'significant': pval < 0.05
        })

    return pd.DataFrame(results)

# Example usage
characteristics = ['genome_size', 'gc_content', 'heterozygosity',
                  'repeat_content', 'sequencing_coverage']

confounding_check = check_confounding(df, 'curation_method', characteristics)
print(confounding_check)
```

**Interpretation guide**:
- **No significant differences**: Methods compared equivalent samples → valid comparison
- **Method A has "easier" samples** (smaller genomes, lower complexity): Quality differences may be due to sample properties, not method
- **Method A has "harder" samples** (larger genomes, higher complexity): Strengthens conclusion that Method A is better despite challenges
- **Limited data** (n<10): Cannot rule out confounding, note as limitation

**Present in notebook**:
```markdown
## Genome Characteristics Comparison

**Control Analysis**: Are quality differences due to method or sample properties?

[Table comparing characteristics]

**Conclusion**:
- If no differences → Valid method comparison
- If Method A works with harder samples → Strengthens conclusions
- If Method A works with easier samples → Potential confounding
```

**Why critical**: Reviewers will ask this question. Preemptive control analysis demonstrates scientific rigor and prevents major revisions.


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


### Publication-Ready Font Sizes

**Problem**: Default matplotlib fonts are designed for screen viewing, not print publication.

**Solution**: Use larger, bold fonts for print readability.

**Recommended sizes** (for standard 10-12 cm wide figures):

| Element | Default | Publication | Code |
|---------|---------|-------------|------|
| **Title** | 11-12pt | **18pt** (bold) | `fontsize=18, fontweight='bold'` |
| **Axis labels** | 10-11pt | **16pt** (bold) | `fontsize=16, fontweight='bold'` |
| **Tick labels** | 9-10pt | **14pt** | `tick_params(labelsize=14)` |
| **Legend** | 8-10pt | **12pt** | `legend(fontsize=12)` |
| **Annotations** | 8-10pt | **11-13pt** | `fontsize=12` |
| **Data points** | 20-36 | **60-100** | `s=80` (scatter) |

**Implementation example**:
```python
fig, ax = plt.subplots(figsize=(10, 8))

# Plot data
ax.scatter(x, y, s=80, alpha=0.6)  # Larger points

# Titles and labels - BOLD
ax.set_title('Your Title Here', fontsize=18, fontweight='bold')
ax.set_xlabel('X Axis Label', fontsize=16, fontweight='bold')
ax.set_ylabel('Y Axis Label', fontsize=16, fontweight='bold')

# Tick labels
ax.tick_params(axis='both', which='major', labelsize=14)

# Legend
ax.legend(fontsize=12, loc='best')

# Stats box
stats_text = "Statistics:\nMean: 42.5"
ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
       fontsize=13, family='monospace',
       bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.3))

# Reference lines - thicker
ax.axhline(y=1.0, linewidth=2.5, linestyle='--', alpha=0.6)
```

**Quick check**: If you have to squint to read the figure on screen at 100% zoom, fonts are too small for print.

**Special cases**:
- Multi-panel figures: Increase 10-15% more
- Posters: Increase 50-100% more
- Presentations: Increase 30-50% more

### Accessibility: Colorblind-Safe Palettes

**Problem**: Standard color schemes (green vs blue, red vs green) are difficult or impossible to distinguish for people with color vision deficiencies, affecting ~8% of males and ~0.5% of females.

**Solution**: Use colorblind-safe palettes from validated sources.

**IBM Color Blind Safe Palette (Recommended)**:
```python
# For comparing two groups/conditions
colors = {
    'Group_A': '#0173B2',  # Blue
    'Group_B': '#DE8F05'   # Orange
}
```

**Why this works**:
- ✅ Maximum contrast for all color vision types (deuteranopia, protanopia, tritanopia, achromatopsia)
- ✅ Professional appearance for scientific publications
- ✅ Clear distinction even in grayscale printing
- ✅ Cultural neutrality (no red/green traffic light associations)

**Other colorblind-safe combinations**:
- Blue + Orange (best overall)
- Blue + Red (good for most types)
- Blue + Yellow (good but lower contrast)

**Avoid**:
- ❌ Green + Red (most common color blindness)
- ❌ Green + Blue (confusing for many)
- ❌ Blue + Purple (too similar)

**Implementation in matplotlib**:
```python
import matplotlib.pyplot as plt

# Define colorblind-safe palette
CB_COLORS = {
    'blue': '#0173B2',
    'orange': '#DE8F05',
    'green': '#029E73',
    'red': '#D55E00',
    'purple': '#CC78BC',
    'brown': '#CA9161'
}

# Use in plots
plt.scatter(x, y, color=CB_COLORS['blue'], label='Treatment')
plt.scatter(x2, y2, color=CB_COLORS['orange'], label='Control')
```

**Testing your colors**:
- Use online simulators: https://www.color-blindness.com/coblis-color-blindness-simulator/
- Check in grayscale: Convert figure to grayscale to ensure distinguishability

### Handling Severe Data Imbalance in Comparisons

**Problem**: Comparing groups with very different sample sizes (e.g., 84 vs 10) can lead to misleading conclusions.

**Solution**: Add prominent warnings both visually and in documentation.

**Visual warning on figure**:
```python
import matplotlib.pyplot as plt

# After creating your plot
n_group_a = len(df[df['group'] == 'A'])
n_group_b = len(df[df['group'] == 'B'])
total_a = 200
total_b = 350

warning_text = f"⚠️  DATA LIMITATION\n"
warning_text += f"Data availability:\n"
warning_text += f"  Group A: {n_group_a}/{total_a} ({n_group_a/total_a*100:.1f}%)\n"
warning_text += f"  Group B: {n_group_b}/{total_b} ({n_group_b/total_b*100:.1f}%)\n"
warning_text += f"Severe imbalance limits\nstatistical comparability"

ax.text(0.98, 0.02, warning_text, transform=ax.transAxes,
       fontsize=11, verticalalignment='bottom', horizontalalignment='right',
       bbox=dict(boxstyle='round', facecolor='red', alpha=0.2,
                edgecolor='red', linewidth=2),
       family='monospace', color='darkred', fontweight='bold')

# Update title to indicate limitation
ax.set_title('Your Title\n(SUPPLEMENTARY - Limited Data Availability)',
            fontsize=14, fontweight='bold')
```

**Text warning in notebook/paper**:
```markdown
**⚠️ CRITICAL DATA LIMITATION**: This figure suffers from severe data availability bias:
- Group A: 84/200 (42%)
- Group B: 10/350 (3%)

This **8-fold imbalance** severely limits statistical comparability. The 10 Group B
samples are unlikely to be representative of all 350.

**Interpretation**: Comparisons should be interpreted with extreme caution. This
figure is provided for completeness but should be considered **supplementary**.
```

**Guidelines for sample size imbalance**:
- **< 2× imbalance**: Generally acceptable, note in caption
- **2-5× imbalance**: Add note about limitations
- **> 5× imbalance**: Add prominent warnings (visual + text)
- **> 10× imbalance**: Consider excluding figure or supplementary-only

**Alternative**: If possible, subset the larger group to match sample size:
```python
# Random subset to balance groups
if n_group_a > n_group_b * 2:
    group_a_subset = df[df['group'] == 'A'].sample(n=n_group_b * 2, random_state=42)
    # Use subset for balanced comparison
```

## Image Display and Responsive Scaling

### Problem: Fixed-size images don't scale with notebook viewer window

When adding images to Jupyter notebooks, you often want them to scale responsively with the viewing window size rather than display at a fixed size.

### Solution Comparison

**❌ SVG with IPython.display.SVG():**
- Displays at native SVG size (fixed)
- Cannot specify width parameter (raises ValueError)
- Does not scale with window resizing
```python
from IPython.display import SVG, display
display(SVG(filename='image.svg'))  # Fixed size, no scaling
```

**❌ PNG conversion attempts:**
- ImageMagick may fail on complex SVG files with rendering errors
- Example error: `non-conforming drawing primitive definition 'stroke-linecap'`
- Conversion process adds complexity

**✅ HTML img tag in markdown cell (RECOMMENDED):**
```markdown
<img src="path/to/image.svg" width="100%" style="max-width: 1200px; height: auto;" alt="Description">
```

Benefits:
- Scales responsively to 100% of container width
- `max-width` prevents oversized display on large screens
- `height: auto` maintains aspect ratio
- Works with both SVG and PNG formats
- Browser handles rendering natively

### Implementation Pattern

Replace code cells using `display(Image(...))` or `display(SVG(...))` with markdown cells containing HTML:

**Before (code cell):**
```python
from IPython.display import SVG, display
display(SVG(filename='phylo/tree.svg'))
```

**After (markdown cell):**
```markdown
<img src="phylo/tree.svg" width="100%" style="max-width: 1200px; height: auto;" alt="Phylogenetic tree">
```

### When to Use Each Approach

- **Markdown + HTML img**: Publication notebooks, figures that need responsive sizing
- **IPython.display.Image()**: Quick exploration, when fixed PNG size is acceptable
- **IPython.display.SVG()**: When you want maximum quality at native size and don't need scaling

## SVG Manipulation

### Cropping SVG Files Without External Tools

SVG files can be cropped by modifying the `viewBox` and `width` attributes directly, avoiding ImageMagick or other conversion tools.

**Use case**: Remove empty space from generated figures (e.g., iTOL phylogenetic trees with excess whitespace)

**Method - Crop from right side:**
```python
import re

# Read original SVG
with open('original.svg', 'r') as f:
    svg_content = f.read()

# Calculate new dimensions (e.g., 30% width reduction)
original_width = 2560
crop_percentage = 30
new_width = int(original_width * (100 - crop_percentage) / 100)  # 1792
original_height = 1352  # Unchanged

# Update width and viewBox attributes
svg_content = re.sub(r'width="2560"', f'width="{new_width}"', svg_content)
svg_content = re.sub(
    r'viewBox="0,0,2560,1352"',
    f'viewBox="0,0,{new_width},{original_height}"',
    svg_content
)

# Save cropped version
with open('original_cropped.svg', 'w') as f:
    f.write(svg_content)
```

**How it works:**
- `viewBox="x,y,width,height"` defines the coordinate system for SVG content
- Reducing viewBox width crops from the right side (keeps left portion)
- Updating `width` attribute ensures proper rendering size
- Height remains unchanged to preserve vertical content

**Alternative crops:**
- **Left side**: `viewBox="crop_amount,0,new_width,height"`
- **Both sides**: Center the viewBox `viewBox="left_crop,0,new_width,height"`

**Advantages over ImageMagick:**
- No external dependencies or conversion errors
- Preserves vector quality (no rasterization)
- Fast and lightweight
- Works on any SVG file
- Easy to iterate (try 20%, 30%, 40% crops)

**Limitations:**
- Only crops to rectangular regions
- Doesn't handle complex transformations
- May cut off content if not careful (iterate and check visually)

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

### Legacy Method: JSON Manipulation (Use NotebookEdit Instead)

**⚠️ Deprecated**: Use NotebookEdit tool for most operations. Only use JSON manipulation for:
- Bulk cell reordering
- Complex conditional operations
- Custom cell metadata manipulation

When inserting cells into large notebooks using JSON:

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

### Reorganizing Notebook Sections

**When Needed:**
- Statistical significance changed (p-values updated)
- Need to regroup analyses by new criteria
- Logical flow improvement

**Bulk Cell Reordering Pattern:**

```python
import json

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Map figure numbers to cell ranges
figure_ranges = {
    1: (20, 26),  # Cells 20-25 contain Figure 1
    2: (4, 8),    # Cells 4-7 contain Figure 2
}

# Define new order
significant_figs = [2, 4, 5, 6, 7]
not_significant_figs = [1, 3]

# Build new cell list
new_cells = []
new_cells.extend(nb['cells'][0:3])  # Keep intro cells

# Add section header
section1_header = {
    'cell_type': 'markdown',
    'metadata': {},
    'source': ['## Section 1: Significant Results\n']
}
new_cells.append(section1_header)

# Add figures in new order
for fig_num in significant_figs:
    start, end = figure_ranges[fig_num]
    new_cells.extend(nb['cells'][start:end])

# Replace cells
nb['cells'] = new_cells

# Save
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**After Reorganization:**
- Regenerate Table of Contents to reflect new structure
- Verify all cross-references still work
- Update section numbering if needed


### Bulk Find-and-Replace Operations

**When Needed**:
- Renumbering figures after deletions (Figure 6→5, Figure 7→6, etc.)
- Updating terminology across multiple cells
- Changing file paths or references

**Pattern**: Use Python JSON manipulation for bulk updates across many cells

```python
import json

# Load notebook
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Find and modify cells
for i, cell in enumerate(nb['cells']):
    if cell.get('cell_type') == 'markdown':
        source = ''.join(cell.get('source', []))
        
        # Make replacements
        new_source = source.replace('Figure 7', 'Figure 6')
        new_source = new_source.replace('Figure 6', 'Figure 5')
        
        # Update cell source - split back to lines
        cell['source'] = new_source.split('\n')
        
        # Preserve trailing newline if present
        if cell['source'] and not cell['source'][-1]:
            cell['source'][-1] = '\n'
    
    elif cell.get('cell_type') == 'code':
        source = ''.join(cell.get('source', []))
        
        # Update image filenames
        new_source = source.replace('06_telomere.png', '05_telomere.png')
        cell['source'] = [new_source]

# Save
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**Delete multiple cells** in reverse order to maintain indices:
```python
cells_to_delete = [10, 11, 12]  # Identified cell indices

for idx in sorted(cells_to_delete, reverse=True):
    print(f"Deleting cell {idx}")
    del nb['cells'][idx]

# Save after all deletions
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**Best Practice**: 
- Use **NotebookEdit tool** for single-cell updates (cleaner, safer)
- Use **Python JSON** for bulk operations affecting 5+ cells
- Always work on a copy first when doing bulk operations
- Test changes by reopening notebook in Jupyter

### Synchronizing Figure Code and Notebook Documentation

**Pattern**: Code changes to figure generation → Must update notebook text

**Common Scenario**: Updated figure filtering/outlier removal/statistical tests

**Workflow**:
1. Update figure generation Python script
2. Regenerate figures
3. **CRITICAL**: Update Jupyter notebook markdown cells documenting the figure
4. Use `NotebookEdit` tool (NOT `Edit` tool) for `.ipynb` files

**Example**:
```python
# After adding Mann-Whitney test to figure generation:
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",  # Found via grep or Read
    cell_type="markdown",
    new_source="Updated description mentioning Mann-Whitney test..."
)
```

**Finding Figure Cells**:
```bash
# Locate figure references
grep -n "figure_name.png" notebook.ipynb

# Or use Glob + Grep
grep -n "Figure 4" notebook.ipynb
```

**Why Critical**: Outdated documentation causes confusion. Notebook text saying "Limited data" when data is now complete, or not mentioning new statistical tests, misleads readers.

### Preserving Newlines in Cell Source

Jupyter notebook cells store source as a **list of strings**, where each string typically ends with `\n`.

**Common pitfall**: String replacement that collapses multi-line code into a single string without newlines.

**❌ Wrong - produces malformed code cell:**
```python
# This creates a single-line string without newlines
cell['source'] = "# Comment\nimport pandas\ndf = pd.read_csv('file.csv')"
# Result in notebook: "# Commentimport pandasdf = pd.read_csv('file.csv')"  ← No line breaks!
```

**✅ Correct - preserves line structure:**
```python
cell['source'] = [
    "# Comment\n",
    "import pandas\n",
    "df = pd.read_csv('file.csv')"
]
# Result: Proper multi-line code cell with preserved formatting
```

**Debugging tip**: If a cell displays as single-line garbage, check the source format:
```python
print(repr(nb['cells'][26]['source']))  # Should show list with \n characters
```

**When updating cell content programmatically:**
1. Always use list of strings format
2. End each line with `\n` (except optionally the last)
3. Test by viewing the notebook afterward

**Example - Updating a cell while preserving formatting:**
```python
import json

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Find the cell to update
for cell in nb['cells']:
    if 'Final Tree.svg' in ''.join(cell.get('source', [])):
        # Update filename while preserving line structure
        cell['source'] = [
            "# Display phylogenetic tree\n",
            "from IPython.display import SVG, display\n",
            "display(SVG(filename='phylo/Final Tree_cropped.svg'))"
        ]

with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**Key lesson**: When you see a cell that "seems off" or "the image is not displayed", check if the source is a single string without newlines. This is a common error when using string replacement on cell content.

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
- ✅ No software required - opens in any browser
- ✅ All figures embedded (no missing images)
- ✅ Self-contained single file
- ✅ Fully interactive (shows code and outputs)
- ✅ Works on any platform

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

# ✅ GOOD: Relative paths work when notebook is moved
display(Image('figures/fig1.png'))
df = pd.read_csv('data/results.csv')

# ❌ BAD: Absolute paths break when sharing
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

## Common Tasks

### Removing Panels from Multi-Panel Figures

**Scenario**: Convert 2-panel figure to 1-panel after removing unavailable data.

**Steps**:
1. **Update subplot layout**:
   ```python
   # Before: 2 panels
   fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

   # After: 1 panel
   fig, ax = plt.subplots(1, 1, figsize=(10, 6))
   ```

2. **Remove panel code**: Delete all code for removed panel (ax2)

3. **Update figure filename**:
   ```python
   # Before
   plt.savefig('06_scaffold_l50_l90_comparison.png')

   # After
   plt.savefig('06_scaffold_l50_comparison.png')
   ```

4. **Update notebook references**:
   - Image display: `display(Image(...'06_scaffold_l50_comparison.png'))`
   - Title: Remove references to removed data
   - Description: Add note about why panel is excluded

5. **Clean up old files**:
   ```bash
   rm figures/*_l50_l90_*.png
   ```
