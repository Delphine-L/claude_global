# Validation Checks

Supporting file for the `update-notebook` command. Contains Steps 2-4: pre-update analysis, figure reference validation, and data coherence checks.

## Step 2: Pre-Update Analysis

Read the notebook and analyze its structure:

```python
import json
from pathlib import Path

# Load notebook
with open(notebook_path, 'r') as f:
    nb = json.load(f)

# Extract key information
cells = nb['cells']
total_cells = len(cells)
markdown_cells = [c for c in cells if c['cell_type'] == 'markdown']
code_cells = [c for c in cells if c['cell_type'] == 'code']

print(f"Notebook Analysis:")
print(f"  Total cells: {total_cells}")
print(f"  Markdown: {len(markdown_cells)}")
print(f"  Code: {len(code_cells)}")
```

**Analyze structure:**

1. **Table of Contents Detection**
   - Find cell containing TOC (look for "## Table of Contents", "## Contents", "# Contents")
   - Extract all section headers from markdown cells
   - Extract all figure references

2. **Figure References**
   - Find all `display(Image(filename=...))` calls
   - Find all figure descriptions `**Figure X.`
   - Extract figure filenames and numbers

3. **Data References**
   - Find all dataset filenames mentioned
   - Find all variable names in code cells
   - Find all data loading statements

4. **Section Structure**
   - Extract all headers (`#`, `##`, `###`)
   - Build hierarchy of sections
   - Identify figure sections

## Step 3: Validate Figure References

Check for issues:

```python
import re
from collections import defaultdict

issues = defaultdict(list)

# Extract figure numbers from descriptions
figure_descriptions = {}
for i, cell in enumerate(markdown_cells):
    source = ''.join(cell['source'])
    matches = re.findall(r'\*\*Figure (\d+)\.', source)
    for fig_num in matches:
        if fig_num not in figure_descriptions:
            figure_descriptions[fig_num] = []
        figure_descriptions[fig_num].append(i)

# Extract figure images from code cells
figure_images = {}
for i, cell in enumerate(code_cells):
    source = ''.join(cell['source'])
    matches = re.findall(r"display\(Image\(filename=.*?['\"](.*?)['\"]", source)
    for img_path in matches:
        # Try to infer figure number from filename
        fig_match = re.search(r'(\d+)_.*\.png', img_path)
        if fig_match:
            fig_num = fig_match.group(1).lstrip('0')
            if fig_num not in figure_images:
                figure_images[fig_num] = []
            figure_images[fig_num].append({'cell': i, 'path': img_path})

# Check for missing figures
all_fig_nums = sorted(set(list(figure_descriptions.keys()) + list(figure_images.keys())))

for fig_num in all_fig_nums:
    if fig_num not in figure_descriptions:
        issues['missing_description'].append(fig_num)
    if fig_num not in figure_images:
        issues['missing_image'].append(fig_num)

    # Check if descriptions and images are adjacent
    if fig_num in figure_descriptions and fig_num in figure_images:
        desc_cells = figure_descriptions[fig_num]
        img_cells = [f['cell'] for f in figure_images[fig_num]]

        # They should be within 2-3 cells of each other
        for desc_cell in desc_cells:
            if not any(abs(desc_cell - img_cell) <= 2 for img_cell in img_cells):
                issues['non_adjacent'].append(f"Figure {fig_num}")

# Check for sequential numbering
expected_sequence = list(range(1, len(all_fig_nums) + 1))
actual_sequence = [int(n) for n in all_fig_nums]

if expected_sequence != actual_sequence:
    issues['non_sequential'] = {
        'expected': expected_sequence,
        'actual': actual_sequence,
        'missing': set(expected_sequence) - set(actual_sequence),
        'extra': set(actual_sequence) - set(expected_sequence)
    }

# Check if figure files exist
for fig_num, imgs in figure_images.items():
    for img_info in imgs:
        img_path = img_info['path']
        # Check both absolute and relative paths
        if not Path(img_path).exists():
            # Try looking in FIG_DIR if defined
            alt_paths = [
                Path('figures') / Path(img_path).name,
                Path('figures/curation_impact') / Path(img_path).name,
                Path('output') / Path(img_path).name
            ]
            if not any(p.exists() for p in alt_paths):
                issues['missing_file'].append(f"Figure {fig_num}: {img_path}")
```

**Report findings:**

```markdown
## Validation Report

### Figure References

**Total figures detected:** {len(all_fig_nums)}
**Figure sequence:** {', '.join(all_fig_nums)}

{if issues['non_sequential']}
  **Non-sequential numbering detected**
  Expected: {expected_sequence}
  Found: {actual_sequence}
  Missing: {missing numbers}
  Extra: {extra numbers}
{end}

{if issues['missing_description']}
  **Figures missing descriptions:**
  {list figure numbers}
{end}

{if issues['missing_image']}
  **Figures missing image displays:**
  {list figure numbers}
{end}

{if issues['non_adjacent']}
  **Figure descriptions not adjacent to images:**
  {list}
{end}

{if issues['missing_file']}
  **Figure files not found:**
  {list with paths}
{end}

{if no issues}
All figure references are valid and well-structured
{end}
```

## Step 4: Validate Variable and Data Coherence

Check for data consistency issues:

```python
# Extract all variable assignments from code cells
variables = defaultdict(list)
for i, cell in enumerate(code_cells):
    source = ''.join(cell['source'])

    # Find variable assignments
    var_matches = re.findall(r'(\w+)\s*=\s*', source)
    for var in var_matches:
        variables[var].append(i)

    # Find dataframe operations
    df_matches = re.findall(r'(df\w*)\[', source)
    for df_var in df_matches:
        if df_var not in variables:
            variables[df_var].append(i)

# Extract data references from markdown
data_refs = defaultdict(list)
for i, cell in enumerate(markdown_cells):
    source = ''.join(cell['source'])

    # Find dataset mentions (n=XXX)
    n_matches = re.findall(r'n\s*=\s*(\d+)', source)
    for n in n_matches:
        data_refs['sample_sizes'].append({'cell': i, 'value': n})

    # Find file references
    file_matches = re.findall(r'["\']([^"\']*\.(?:csv|tsv|xlsx|json))["\']', source)
    for filename in file_matches:
        data_refs['files'].append({'cell': i, 'file': filename})

# Check for inconsistencies
inconsistencies = []

# Check if sample sizes are consistent
sample_sizes = [int(d['value']) for d in data_refs['sample_sizes']]
if len(set(sample_sizes)) > 1:
    inconsistencies.append({
        'type': 'sample_size',
        'message': f'Multiple different sample sizes mentioned: {set(sample_sizes)}'
    })

# Check if file references exist
for file_ref in data_refs['files']:
    filename = file_ref['file']
    if not Path(filename).exists():
        inconsistencies.append({
            'type': 'missing_file',
            'cell': file_ref['cell'],
            'file': filename
        })

# Check for undefined variable usage
defined_vars = set(variables.keys())
used_vars = set()
for cell in code_cells:
    source = ''.join(cell['source'])
    # Find variable usage (simplified - actual implementation would be more sophisticated)
    var_uses = re.findall(r'\b(\w+)\b', source)
    used_vars.update(var_uses)

undefined = used_vars - defined_vars - {'print', 'len', 'str', 'int', 'float', 'list', 'dict', 'set'}
if undefined:
    inconsistencies.append({
        'type': 'undefined_vars',
        'variables': list(undefined)
    })
```

**Report findings:**

```markdown
### Data and Variable Coherence

**Variables defined:** {len(variables)}
**Data files referenced:** {len(data_refs['files'])}
**Sample size mentions:** {len(data_refs['sample_sizes'])}

{if inconsistencies}
{for each inconsistency}
  {type}: {message}
{end}
{else}
All data references and variables are coherent
{end}
```
