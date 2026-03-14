# Path Verification and Fixing (Step 5.5)

**CRITICAL:** After copying files, verify that all file references in notebooks point to the correct locations in the sharing package structure.

```python
import json
import os
import re
from pathlib import Path

print("\nVerifying file paths in notebooks...")

SHARE_DIR = "shared-YYYY-MM-DD-project"  # Replace with actual directory

# 1. Find all notebooks in sharing package
notebooks = []
for root, dirs, files in os.walk(SHARE_DIR):
    for file in files:
        if file.endswith('.ipynb'):
            notebooks.append(os.path.join(root, file))

print(f"Found {len(notebooks)} notebooks to check")

# 2. Check and fix paths in each notebook
for notebook_path in notebooks:
    print(f"\nChecking: {os.path.relpath(notebook_path, SHARE_DIR)}")

    with open(notebook_path, 'r') as f:
        nb = json.load(f)

    changes_made = False
    issues_found = []

    for cell_idx, cell in enumerate(nb['cells']):
        if cell['cell_type'] == 'code':
            source = ''.join(cell['source'])

            # Check for common file references
            patterns = {
                'read_csv': r'read_csv\([\'"]([^\'")]+)[\'"]',
                'Image': r'Image\(filename=[\'"]([^\'")]+)[\'"]',
                'imread': r'imread\([\'"]([^\'")]+)[\'"]',
                'src=': r'src=[\'"]([^\'")]+)[\'"]',
            }

            for pattern_name, pattern in patterns.items():
                matches = re.findall(pattern, source)
                for match in matches:
                    # Check if file exists at referenced path
                    # Determine notebook's location relative to SHARE_DIR root
                    notebook_dir = os.path.dirname(notebook_path)

                    # Try to resolve the path
                    if notebook_dir == SHARE_DIR:
                        # Notebook is at root
                        referenced_path = os.path.join(SHARE_DIR, match)
                    else:
                        # Notebook is in subdirectory - adjust relative path
                        referenced_path = os.path.normpath(
                            os.path.join(notebook_dir, match)
                        )

                    if not os.path.exists(referenced_path):
                        issues_found.append({
                            'cell': cell_idx,
                            'type': pattern_name,
                            'path': match,
                            'expected': referenced_path
                        })

        elif cell['cell_type'] == 'markdown':
            source = ''.join(cell['source'])

            # Check for image/file references in markdown
            img_pattern = r'!\[[^\]]*\]\(([^)]+)\)|<img[^>]+src=[\'"]([^\'")]+)[\'"]'
            matches = re.findall(img_pattern, source)
            for match_tuple in matches:
                match = match_tuple[0] or match_tuple[1]
                if match and not match.startswith('http'):
                    notebook_dir = os.path.dirname(notebook_path)
                    if notebook_dir == SHARE_DIR:
                        referenced_path = os.path.join(SHARE_DIR, match)
                    else:
                        referenced_path = os.path.normpath(
                            os.path.join(notebook_dir, match)
                        )

                    if not os.path.exists(referenced_path):
                        issues_found.append({
                            'cell': cell_idx,
                            'type': 'markdown_image',
                            'path': match,
                            'expected': referenced_path
                        })

    # 3. Report issues and suggest fixes
    if issues_found:
        print(f"  Found {len(issues_found)} path issues:")
        for issue in issues_found[:5]:  # Show first 5
            print(f"    - Cell {issue['cell']}: {issue['type']} -> {issue['path']}")

            # Try to find the file in the sharing package
            filename = os.path.basename(issue['path'])
            possible_locations = []
            for root, dirs, files in os.walk(SHARE_DIR):
                if filename in files:
                    rel_path = os.path.relpath(
                        os.path.join(root, filename),
                        os.path.dirname(notebook_path)
                    )
                    possible_locations.append(rel_path)

            if possible_locations:
                print(f"      File exists at: {possible_locations[0]}")
                print(f"      Suggested fix: Update path from '{issue['path']}' to '{possible_locations[0]}'")
            else:
                print(f"      File not found in sharing package")

        if len(issues_found) > 5:
            print(f"    ... and {len(issues_found) - 5} more issues")
    else:
        print("  All paths verified")

print("\n" + "="*70)
print("PATH VERIFICATION COMPLETE")
print("="*70)
print("\nIMPORTANT: If issues were found, you should:")
print("1. Fix paths manually in notebooks, OR")
print("2. Copy missing files to expected locations, OR")
print("3. Run automated path correction (see below)")
```

---

## Automated Path Correction (Optional)

If you want to automatically fix common path issues:

```python
def fix_notebook_paths(notebook_path, path_mappings):
    """
    Update paths in notebook based on mapping dictionary.

    Args:
        notebook_path: Path to notebook
        path_mappings: Dict of {old_path: new_path}
    """
    with open(notebook_path, 'r') as f:
        nb = json.load(f)

    changes = 0
    for cell in nb['cells']:
        if cell['cell_type'] == 'code' or cell['cell_type'] == 'markdown':
            source = ''.join(cell['source'])
            updated_source = source

            for old_path, new_path in path_mappings.items():
                if old_path in updated_source:
                    updated_source = updated_source.replace(old_path, new_path)
                    changes += 1

            if updated_source != source:
                cell['source'] = updated_source.split('\n')
                # Preserve newlines
                cell['source'] = [line + '\n' for line in cell['source'][:-1]] + [cell['source'][-1]]

    if changes > 0:
        with open(notebook_path, 'w') as f:
            json.dump(nb, f, indent=1)
        print(f"  Fixed {changes} path references in {os.path.basename(notebook_path)}")
        return True
    return False

# Example: Fix common path issues for root-level notebooks
if notebooks:
    common_fixes = {
        # Add data/ prefix if files are in data/
        "read_csv('VGP": "read_csv('data/VGP",
        "read_csv(\"VGP": "read_csv(\"data/VGP",

        # Fix phylo tree path if copied to figures/
        "phylo/Final Tree": "figures/curation_impact/Final Tree",
        "phylo/final_tree": "figures/curation_impact/final_tree",
    }

    print("\nApplying automated fixes...")
    fixed_count = 0
    for notebook in notebooks:
        if fix_notebook_paths(notebook, common_fixes):
            fixed_count += 1

    if fixed_count > 0:
        print(f"\nFixed paths in {fixed_count} notebooks")
        print("Regenerate HTML files after fixing paths:")
        print("   jupyter nbconvert --to html <notebook>.ipynb")
```

---

## Common Path Issues to Check

1. **CSV files**: Should include `data/` prefix if notebooks are at root
   - Wrong: `pd.read_csv('dataset.csv')`
   - Right: `pd.read_csv('data/dataset.csv')`

2. **Images in notebooks**: Should match actual figure directory structure
   - Wrong: `Image(filename='figure.png')`
   - Right: `Image(filename='figures/curation_impact/figure.png')`

3. **Markdown images**: Should use correct relative paths
   - Wrong: `<img src="phylo/tree.svg">`
   - Right: `<img src="figures/curation_impact/tree.svg">`

4. **Files from deprecated/**: May need to be copied to sharing package
   - Check if notebooks reference files in `deprecated/` folder
   - Copy needed files to appropriate location in sharing package

---

## Verification Checklist

```bash
# After path fixes, verify notebooks can load data
cd "$SHARE_DIR"

# Check data files exist where notebooks expect them
echo "Data files referenced in notebooks:"
grep -h "read_csv\|read_excel\|load" *.ipynb | grep -o "'[^']*'" | sort -u

# Check image files exist where notebooks expect them
echo "Image files referenced in notebooks:"
grep -h "Image(filename\|<img src" *.ipynb | grep -o "'[^']*'" | sort -u

# List what actually exists
echo "Actual data files:"
ls -1 data/

echo "Actual figure files:"
find figures -type f
```
