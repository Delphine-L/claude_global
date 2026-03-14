# Notebook Editing: NotebookEdit Tool and Programmatic Manipulation

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
- Updating existing cell content (figure captions, analysis text)
- Adding single new cells (headers, display code, descriptions)
- Removing specific cells
- Making targeted changes to notebook structure
- Synchronizing notebook documentation with code changes

**Use Python scripts when:**
- Bulk operations (reordering many cells, restructuring entire notebook)
- Complex conditional logic based on cell content
- Programmatic generation of many cells at once
- Cell reordering requires precise index manipulation

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

**Don't use Edit tool on .ipynb files** - It treats them as text, corrupting JSON structure
```python
# WRONG - corrupts notebook
Edit(
    file_path="notebook.ipynb",
    old_string="old text",
    new_string="new text"
)
```

**Use NotebookEdit for notebooks**
```python
# CORRECT
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-10",
    new_source="new cell content"
)
```

**Don't forget cell_type when inserting**
```python
# WRONG - missing cell_type
NotebookEdit(
    notebook_path="notebook.ipynb",
    edit_mode="insert",
    new_source="content"
)
```

**Always specify cell_type for insert**
```python
# CORRECT
NotebookEdit(
    notebook_path="notebook.ipynb",
    edit_mode="insert",
    cell_type="markdown",
    new_source="content"
)
```

## Updating Multiple Related Cells

### Systematic Metric Changes Across Notebook

When replacing a metric throughout an analysis notebook (e.g., changing from absolute counts to ratios), update in dependency order to prevent errors.

**Update Order**:
1. **Data loading cell**: Add calculation for new metric
2. **Metric definition cell**: Update the metrics list
3. **All plotting cells**: Use the new metric automatically via the metrics list

**Example: Switching from Absolute to Ratio Metric**

```python
# Step 1: Data loading cell - add calculation
df = pd.read_csv('data.csv')
df['telomere_ratio'] = df['telomere_count'] / df['expected_chromosomes']

# Step 2: Metrics definition cell - update list
metrics = [
    ('scaffold_n50', 'Scaffold N50 (bp)', True),
    ('telomere_ratio', 'Telomere Ratio (Found/Expected)', True),  # Changed
    ('chr_percentage', 'Chromosome Assignment (%)', True),
]

# Step 3: Plotting cells automatically use new metric via loop
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
axes = axes.flatten()

for idx, (metric, label, higher_better) in enumerate(metrics):
    ax = axes[idx]
    # Plot using metric, label from the list
    ax.scatter(df['year'], df[metric])
    ax.set_ylabel(label)
    ax.set_title(label, fontweight='bold')
```

**Benefits of This Approach**:
- **Single source of truth**: Metrics list defines all metrics used
- **Update once, applies everywhere**: Change metric list, all plots update
- **Prevents inconsistencies**: Can't accidentally miss updating one plot
- **Easy to add/remove metrics**: Just edit the list

**Common Pattern: Loop-Based Multi-Panel Figures**

```python
# Define metrics once
metrics = [
    ('metric_name', 'Display Label', higher_is_better),
    # ... add more
]

# All plots use the same structure
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
for idx, (metric, label, higher_better) in enumerate(metrics):
    ax = axes.flatten()[idx]

    # Plotting logic
    for category in categories:
        data = df[df['category'] == category]
        ax.scatter(data['x'], data[metric], label=category)

    ax.set_ylabel(label)
    ax.set_title(label, fontweight='bold')
```

**When to Use This Pattern**:
- Multiple figures showing the same metric
- Multi-panel figures with different metrics
- Systematic metric updates across analysis
- Adding/removing metrics from analysis

**Example Use Case**: Changing from absolute telomere counts to normalized ratios across 5 figures required only 2 cell edits instead of 15+ individual plot updates.

## Normalized vs Absolute Metrics

### When to Use Ratios Instead of Counts

**Problem**: Absolute counts can't be fairly compared across groups with different expected values.

**Example: Telomere Counts**
- Species A: 20 telomeres found, 50 chromosomes expected
- Species B: 15 telomeres found, 20 chromosomes expected
- **Which is better?** Can't tell from absolute values!

**Solution**: Use ratio = found / expected
- Species A: 20/50 = 0.40 (40%)
- Species B: 15/20 = 0.75 (75%) -- clearly better!

### Implementation Pattern

```python
# Add ratio calculation in data loading cell
df = pd.read_csv('assemblies.csv')
df['telomere_ratio'] = df['telomeres_found'] / df['chromosomes_expected']

# Update metrics list to use ratio instead of count
metrics = [
    # Before: ('telomeres_found', 'Complete Telomeres', True),
    ('telomere_ratio', 'Telomere Ratio (Found/Expected)', True),
]

# All plots automatically switch to using the ratio
```

### Benefits of Normalized Metrics

**Interpretability**:
- Ratio of 1.0 = perfect (all expected features present)
- Ratio of 0.5 = half present
- Ratio > 1.0 = more than expected (e.g., duplications)

**Comparability**:
- Fair comparison across species with different karyotypes
- Can identify systematic patterns vs species-specific effects
- Removes confounding effect of different expected values

**Statistical Power**:
- Reduces variance caused by different expected values
- Improves detection of real biological/technical effects
- Makes statistical tests more sensitive

### Common Normalized Metrics in Genomics

| Absolute Metric | Normalized Version | Formula |
|----------------|-------------------|---------|
| Chromosomes assigned | Assignment percentage | `assigned / total * 100` |
| Telomeres found | Telomere ratio | `found / expected_chromosomes` |
| Gaps in assembly | Gap density | `gaps / assembly_length * 100` |
| Contigs assembled | Reduction ratio | `initial_contigs / final_contigs` |
| Bases in scaffolds | N50 (size-weighted median) | Cumulative length metric |

### When to Keep Absolute Metrics

Keep absolute values when:
- The expected value is constant across all samples
- You're tracking total volume/magnitude changes
- Supplementary material where space allows both

**Best Practice**: Provide both absolute and normalized in supplementary materials when space allows. Use normalized for main figures and comparisons.

### Example: Multi-Species Assembly Quality

```python
# Load assembly data
df = pd.read_csv('assemblies.csv')

# Calculate normalized metrics
df['telomere_ratio'] = df['telomeres_found'] / df['chromosomes_expected']
df['gap_density'] = (df['gap_bases'] / df['assembly_length']) * 100
df['chr_assignment_pct'] = (df['chr_assigned_bases'] / df['total_bases']) * 100

# Now can fairly compare across species
for species in df['species'].unique():
    species_data = df[df['species'] == species]
    print(f"{species}: telomere_ratio = {species_data['telomere_ratio'].mean():.2f}")
```

## Programmatic Notebook Manipulation

### Legacy Method: JSON Manipulation (Use NotebookEdit Instead)

**Deprecated**: Use NotebookEdit tool for most operations. Only use JSON manipulation for:
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
- Renumbering figures after deletions (Figure 6->5, Figure 7->6, etc.)
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

**Pattern**: Code changes to figure generation -> Must update notebook text

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

**Wrong - produces malformed code cell:**
```python
# This creates a single-line string without newlines
cell['source'] = "# Comment\nimport pandas\ndf = pd.read_csv('file.csv')"
# Result in notebook: "# Commentimport pandasdf = pd.read_csv('file.csv')"  -- No line breaks!
```

**Correct - preserves line structure:**
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
