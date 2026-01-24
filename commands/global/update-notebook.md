---
name: update-notebook
description: Comprehensive Jupyter notebook maintenance - updates figures, verifies references, updates TOC, checks coherence
---

Update and validate a Jupyter notebook comprehensively after making changes to code, figures, or data.

## Your Task

This command performs a multi-stage validation and update of Jupyter notebooks to ensure:
- All figure references are current and correct
- Table of contents matches actual sections
- Variable names and data are consistent
- Cell execution order is logical
- Documentation is coherent

### Step 1: Identify Target Notebook

Ask user which notebook to update, or auto-detect if context is clear:

```bash
# List all notebooks in current directory
notebooks=$(find . -maxdepth 2 -name "*.ipynb" ! -path "*/.*" | sort)

if [ -z "$notebooks" ]; then
  echo "⚠️  No Jupyter notebooks found in current directory"
  exit 1
fi

# Count notebooks
nb_count=$(echo "$notebooks" | wc -l | tr -d ' ')

if [ "$nb_count" -eq 1 ]; then
  notebook_path="$notebooks"
  echo "📓 Found notebook: $notebook_path"
else
  echo "📓 Found $nb_count notebooks:"
  echo "$notebooks" | nl
  echo ""
  echo "Which notebook to update? (enter number or path)"
fi
```

### Step 2: Pre-Update Analysis

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

print(f"📊 Notebook Analysis:")
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

### Step 3: Validate Figure References

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
## 🔍 Validation Report

### Figure References

**Total figures detected:** {len(all_fig_nums)}
**Figure sequence:** {', '.join(all_fig_nums)}

{if issues['non_sequential']}
⚠️  **Non-sequential numbering detected**
  Expected: {expected_sequence}
  Found: {actual_sequence}
  Missing: {missing numbers}
  Extra: {extra numbers}
{end}

{if issues['missing_description']}
⚠️  **Figures missing descriptions:**
  {list figure numbers}
{end}

{if issues['missing_image']}
⚠️  **Figures missing image displays:**
  {list figure numbers}
{end}

{if issues['non_adjacent']}
⚠️  **Figure descriptions not adjacent to images:**
  {list}
{end}

{if issues['missing_file']}
❌ **Figure files not found:**
  {list with paths}
{end}

{if no issues}
✅ All figure references are valid and well-structured
{end}
```

### Step 4: Validate Variable and Data Coherence

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
  ⚠️  {type}: {message}
{end}
{else}
✅ All data references and variables are coherent
{end}
```

### Step 5: Update Table of Contents

Compare current TOC with actual structure:

```python
# Extract actual section structure
sections = []
for i, cell in enumerate(markdown_cells):
    source = ''.join(cell['source'])
    lines = source.split('\n')

    for line in lines:
        # Match headers
        match = re.match(r'^(#{1,6})\s+(.+)$', line)
        if match:
            level = len(match.group(1))
            title = match.group(2).strip()

            # Skip if it's the TOC header itself
            if 'Table of Contents' in title or 'Contents' in title:
                continue

            # Create anchor
            anchor = title.lower()
            anchor = re.sub(r'[^\w\s-]', '', anchor)
            anchor = re.sub(r'[\s]+', '-', anchor)

            sections.append({
                'level': level,
                'title': title,
                'anchor': anchor,
                'cell': i
            })

# Find TOC cell
toc_cell_idx = None
for i, cell in enumerate(markdown_cells):
    source = ''.join(cell['source'])
    if 'Table of Contents' in source or (source.startswith('##') and 'Contents' in source):
        toc_cell_idx = i
        break

# Generate new TOC
def generate_toc(sections, max_level=3):
    toc_lines = ['## Table of Contents\n', '\n']

    for section in sections:
        if section['level'] <= max_level:
            indent = '  ' * (section['level'] - 1)
            link = f"[{section['title']}](#{section['anchor']})"
            toc_lines.append(f"{indent}- {link}\n")

    return ''.join(toc_lines)

new_toc = generate_toc(sections)

if toc_cell_idx is not None:
    old_toc = ''.join(markdown_cells[toc_cell_idx]['source'])

    if old_toc.strip() != new_toc.strip():
        print("📝 Table of Contents needs updating")
        print("\n--- Current TOC ---")
        print(old_toc[:200] + "..." if len(old_toc) > 200 else old_toc)
        print("\n--- Proposed TOC ---")
        print(new_toc[:200] + "..." if len(new_toc) > 200 else new_toc)

        needs_toc_update = True
    else:
        print("✅ Table of Contents is up to date")
        needs_toc_update = False
else:
    print("⚠️  No Table of Contents found")
    print("Should I add one at the beginning? (y/n)")
    needs_toc_update = True
```

### Step 6: Validate Figure Legends and Descriptions

Check that all figures have proper descriptions:

```python
# For each figure, check description quality
legend_issues = []

for fig_num in sorted(all_fig_nums):
    if fig_num in figure_descriptions:
        desc_cells = figure_descriptions[fig_num]

        for cell_idx in desc_cells:
            source = ''.join(markdown_cells[cell_idx]['source'])

            # Extract the figure description
            match = re.search(r'\*\*Figure \d+\.([^*]+)\*\*', source)
            if match:
                desc_text = match.group(1).strip()

                # Check description quality
                if len(desc_text) < 50:
                    legend_issues.append({
                        'figure': fig_num,
                        'issue': 'too_short',
                        'length': len(desc_text),
                        'cell': cell_idx
                    })

                # Check for key components
                has_methods = any(word in desc_text.lower() for word in
                                ['violin', 'plot', 'scatter', 'histogram', 'panel', 'comparison'])
                has_data_info = any(word in desc_text.lower() for word in
                                  ['n=', 'dual', 'pri/alt', 'assemblies', 'species'])
                has_stats = any(word in desc_text.lower() for word in
                              ['mann-whitney', 'p <', 'statistical', 'test', 'chi-square'])

                if not has_methods:
                    legend_issues.append({
                        'figure': fig_num,
                        'issue': 'missing_methods',
                        'cell': cell_idx
                    })

                if not has_data_info:
                    legend_issues.append({
                        'figure': fig_num,
                        'issue': 'missing_data_info',
                        'cell': cell_idx
                    })

if legend_issues:
    print("⚠️  Figure legend issues found:")
    for issue in legend_issues:
        print(f"  Figure {issue['figure']}: {issue['issue']}")
else:
    print("✅ All figure legends are comprehensive")
```

### Step 7: Interactive Update Menu

Present options to user:

```markdown
## 🔧 Update Options

Based on the analysis, here are recommended updates:

1. **Fix figure numbering** {if non-sequential}
   - Renumber figures to be sequential
   - Update all references

2. **Update Table of Contents** {if needs update}
   - {X} sections added since last update
   - {Y} sections renamed

3. **Fix figure adjacency** {if non-adjacent issues}
   - Move figure descriptions next to images

4. **Add missing figure descriptions** {if missing}
   - {count} figures need descriptions

5. **Update data references** {if inconsistencies}
   - Fix inconsistent sample sizes
   - Update file paths

6. **Verify all and update** (recommended)
   - Performs all necessary updates

Select option (1-6) or 'skip' to cancel:
```

### Step 8: Execute Updates

For each selected update:

**8.1 Fix Figure Numbering**

```python
# Create mapping from old to new numbers
renumbering_map = {}
for i, old_num in enumerate(sorted(actual_sequence), start=1):
    if old_num != i:
        renumbering_map[old_num] = i

if renumbering_map:
    print(f"Renumbering {len(renumbering_map)} figures...")

    # Update all cells
    for cell in nb['cells']:
        if cell['cell_type'] in ['markdown', 'code']:
            source = ''.join(cell['source'])

            # Replace in reverse order to avoid double-replacement
            for old_num in sorted(renumbering_map.keys(), reverse=True):
                new_num = renumbering_map[old_num]

                # Update markdown figures
                source = re.sub(
                    rf'\*\*Figure {old_num}\.',
                    f'**Figure {new_num}.',
                    source
                )
                source = re.sub(
                    rf'Figure {old_num}:',
                    f'Figure {new_num}:',
                    source
                )

                # Update image filenames if they contain figure numbers
                source = re.sub(
                    rf'{old_num:02d}_',
                    f'{new_num:02d}_',
                    source
                )

            cell['source'] = [source]
```

**8.2 Update Table of Contents**

```python
if needs_toc_update:
    if toc_cell_idx is not None:
        # Update existing TOC
        nb['cells'][toc_cell_idx]['source'] = [new_toc]
        print(f"✓ Updated Table of Contents at cell {toc_cell_idx}")
    else:
        # Insert new TOC after title
        toc_cell = {
            'cell_type': 'markdown',
            'metadata': {},
            'source': [new_toc]
        }
        nb['cells'].insert(1, toc_cell)  # After title cell
        print("✓ Added new Table of Contents")
```

**8.3 Fix Figure Adjacency**

```python
# Move descriptions to be adjacent to images
for fig_num, issue in non_adjacent_issues.items():
    desc_cell = issue['description_cell']
    img_cell = issue['image_cell']

    # Move description cell to be right before or after image
    if desc_cell < img_cell:
        target_pos = img_cell - 1
    else:
        target_pos = img_cell + 1

    # Extract and move cell
    cell = nb['cells'].pop(desc_cell)
    nb['cells'].insert(target_pos, cell)
    print(f"✓ Moved Figure {fig_num} description to be adjacent to image")
```

### Step 9: Validation After Updates

Run validation checks again to ensure all issues resolved:

```python
# Re-run all validation checks
print("\n🔄 Re-validating notebook...")

# Quick validation
new_issues = validate_notebook(nb)

if not new_issues:
    print("✅ All issues resolved!")
else:
    print(f"⚠️  {len(new_issues)} issues remaining:")
    for issue in new_issues:
        print(f"  - {issue}")
```

### Step 10: Save Updated Notebook

Create backup and save:

```python
from datetime import datetime

# Create backup
backup_path = f"{notebook_path}.backup-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
import shutil
shutil.copy(notebook_path, backup_path)
print(f"📦 Backup created: {backup_path}")

# Save updated notebook
with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=1)

print(f"✅ Notebook updated: {notebook_path}")
```

### Step 11: Generate Update Summary

```markdown
## ✅ Update Complete!

**Notebook:** {notebook_path}
**Backup:** {backup_path}

### Changes Made:

{if figure_renumbering}
- **Figure numbering:** Renumbered {count} figures to be sequential
{end}

{if toc_updated}
- **Table of Contents:** Updated with {count} sections
{end}

{if adjacency_fixed}
- **Figure organization:** Moved {count} descriptions to be adjacent to images
{end}

{if data_updated}
- **Data references:** Fixed {count} inconsistencies
{end}

### Validation Results:

- Total cells: {total_cells}
- Figures: {figure_count}
- Sections: {section_count}
- All figure references: ✅ Valid
- All data references: ✅ Valid
- Table of Contents: ✅ Up to date

### Next Steps:

1. Review changes in Jupyter Notebook
2. Re-run notebook cells to verify execution
3. Commit changes: `git add {notebook_path} && git commit -m "docs: update notebook structure and references"`
4. Remove backup if satisfied: `rm {backup_path}`
```

---

## Token Efficiency Tips

1. **Don't read full notebook initially** - Use `jq` to extract structure:
   ```bash
   jq -r '.cells[] | select(.cell_type=="markdown") | .source | join("")' notebook.ipynb | grep "^#"
   ```

2. **Extract only needed information**:
   ```bash
   # Get figure references
   jq -r '.cells[] | .source | join("")' notebook.ipynb | grep -o "Figure [0-9]*"

   # Get image displays
   jq -r '.cells[] | .source | join("")' notebook.ipynb | grep "display(Image"
   ```

3. **Use Python only for complex updates** - Read JSON, make changes, write back

4. **Batch operations** - Collect all issues before prompting user

## Example Usage

```bash
# In project with Jupyter notebooks
/update-notebook

# Command detects notebook, analyzes it:
# - Found 28 cells
# - 8 figures detected
# - Issues: Figure 7 description missing, TOC outdated
#
# Fixes all issues automatically, creates backup
#
# ✅ Notebook updated successfully!
```

## Safety Features

1. **Always creates backup** before modifying
2. **Validates after changes** to ensure nothing broke
3. **Interactive approval** for major changes
4. **Preserves notebook metadata** and execution counts
5. **Detailed change log** of what was modified

## When to Use

- After adding/removing figures from analysis
- After changing data sources or sample sizes
- Before submitting notebook for review/publication
- When reorganizing notebook structure
- After renumbering figures in external scripts
- Before creating a final analysis report
