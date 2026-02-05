---
name: share-project
description: Prepare organized project package for sharing with collaborators, reviewers, or repositories. Creates clean copies at different levels (Summary/Reproducible/Full).
---

Prepare a shareable version of your current project, with cleaned notebooks, proper documentation, and appropriate file selection based on audience needs.

**Key Principle:** Creates a separate sharing folder - all future work continues in your main project directory.

## Your Task

### Step 1: Understand Current Project Structure

```bash
# Check what files exist
echo "📁 Analyzing project structure..."
echo ""

# List key project files
ls -1 *.ipynb 2>/dev/null | head -5
ls -1 *.py 2>/dev/null | head -3
ls -d figures/ data/ scripts/ 2>/dev/null

# Check for environment specs
ls -1 environment.yml requirements.txt conda*.yml 2>/dev/null
```

---

### Step 1.5: Ask About File Selection

**NEW WORKFLOW: Flexible file organization**

Present two options:

```
📋 What would you like to share?

Option 1: Specific files at root (Recommended for focused sharing)
   - You specify which files to highlight (e.g., notebooks)
   - Those files appear at the root of the sharing package
   - Everything else organized in folders
   - Example:
     shared-package/
     ├── Analysis_Notebook.ipynb        ← Your file at root
     ├── Results_Notebook.ipynb         ← Your file at root
     ├── figures/                       ← Supporting files in folders
     ├── data/
     ├── scripts/
     └── README.md

Option 2: Share entire directory (Full project structure)
   - Copy everything except 'deprecated/' folder
   - Maintains original directory structure
   - Good for complete project handoff

Which would you prefer? [1/2]
```

**If Option 1 (Specific files):**

```bash
# List available notebooks
echo "Available notebooks:"
ls -1 *.ipynb 2>/dev/null | nl

# List other potential root files
echo ""
echo "Other files that could go at root:"
ls -1 *.py *.md 2>/dev/null | nl

# Ask user
echo ""
echo "Which files do you want at the root of the sharing package?"
echo "Enter file names separated by spaces, or numbers from the list above:"
echo "Example: Notebook1.ipynb Notebook2.ipynb"
echo "Or: 1 2 (to select by number)"
```

**Collect user input:**
- Store selected files in array: `ROOT_FILES=()`
- Validate files exist
- Confirm selection with user

**If Option 2 (Entire directory):**

```bash
# Set flag to copy entire directory
SHARE_ENTIRE_DIR=true
EXCLUDE_PATTERNS=("deprecated" ".git" "__pycache__" "*.pyc" ".ipynb_checkpoints")
```

---

### Step 2: Ask User for Sharing Level

Present options clearly:

```
📦 Project Sharing Setup

Which sharing level do you need?

1. 📄 Summary Only
   - PDF of notebook(s) + final figures
   - Quick sharing for presentations/reports
   - Audience: Non-technical stakeholders, presentations
   - Size: Small (~10-50 MB)

2. 🔬 Reproducible Package
   - Cleaned notebooks + scripts + processed data
   - Standard for collaboration and peer review
   - Audience: Researchers, reviewers, collaborators
   - Size: Medium (~50-500 MB)

3. 📚 Full Archive
   - Everything from raw data through all processing
   - Complete transparency and traceability
   - Audience: Repositories (Zenodo/Dryad), compliance, archival
   - Size: Large (may be GBs)

Enter choice [1-3]:
```

---

### Step 3: Gather Additional Information

Based on level chosen, ask:

**For all levels:**
```
📝 Additional information:

1. Brief project description (for README):
   [User provides 1-2 sentence description]

2. Sharing directory name:
   Suggestion: shared-YYYY-MM-DD-[project-name]
   Or custom name: [User provides]
```

**For Level 2-3 (Reproducible/Full):**
```
3. Any data files with sensitive information to exclude? (y/n)
   [If yes: Which files/patterns?]

4. Include raw data or just link to source? (if raw data is large)
   [include/link/skip]
```

---

### Step 4: Create Sharing Directory Structure

**UPDATED WORKFLOW: Two approaches based on Step 1.5 selection**

#### Approach A: Specific Files at Root (Option 1 selected)

```bash
SHARE_DIR="shared-$(date +%Y%m%d)-${project_name}"
mkdir -p "$SHARE_DIR"

# Create folders for supporting files only
mkdir -p "$SHARE_DIR"/{figures,data,scripts,documentation}

echo "Created sharing package structure:"
echo "$SHARE_DIR/"
echo "├── [Selected files will be at root]"
echo "├── figures/"
echo "├── data/"
echo "├── scripts/"
echo "├── documentation/"
echo "└── README.md"
```

**Structure philosophy:**
- **Root level**: User-selected key files (e.g., notebooks) - immediately visible
- **Folders**: Supporting files (figures, data, scripts) - organized but not prominent
- **Clean and minimal**: Recipients see the important files first

#### Approach B: Entire Directory (Option 2 selected)

```bash
SHARE_DIR="shared-$(date +%Y%m%d)-${project_name}"
mkdir -p "$SHARE_DIR"

# Will copy entire directory structure, excluding specific patterns
EXCLUDE_PATTERNS=("deprecated" ".git" "__pycache__" "*.pyc" ".ipynb_checkpoints" "shared-*")

echo "Will copy entire project structure, excluding:"
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    echo "  - $pattern"
done
```

**Structure philosophy:**
- **Preserve original**: Maintains your project's directory organization
- **Exclude cruft**: Skips deprecated files, git history, Python cache, etc.
- **Complete handoff**: Good for comprehensive project transfer

---

#### Legacy: Traditional Sharing Levels (Alternative)

If you prefer the traditional Level 1/2/3 approach instead of the new file-selection workflow:

**Level 1 - Summary:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-summary"
mkdir -p "$SHARE_DIR"/{results/{figures,tables}}
```

**Level 2 - Reproducible:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-reproducible"
mkdir -p "$SHARE_DIR"/{notebooks,scripts,data/processed,figures}
```

**Level 3 - Full Archive:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-full"
mkdir -p "$SHARE_DIR"/{data/{raw,intermediate,processed},scripts,notebooks/{exploratory,final},results/{figures,tables,supplementary},documentation}
```

---

### Step 5: Copy and Clean Files

**UPDATED WORKFLOW: Handle both approaches**

#### Approach A: Specific Files at Root

```python
import nbformat
import shutil
import os
from pathlib import Path

# ROOT_FILES contains user-selected files from Step 1.5
# Example: ['Notebook1.ipynb', 'Notebook2.ipynb']

print("📦 Creating sharing package with selected files at root...")

# 1. Copy selected files to root (with cleaning for notebooks)
for file_path in ROOT_FILES:
    if file_path.endswith('.ipynb'):
        # Clean notebook: remove outputs
        print(f"Cleaning and copying: {file_path}")
        with open(file_path, 'r') as f:
            nb = nbformat.read(f, as_version=4)

        # Clear outputs
        for cell in nb.cells:
            if cell.cell_type == 'code':
                cell.outputs = []
                cell.execution_count = None

        # Remove debug cells
        nb.cells = [c for c in nb.cells
                    if 'debug' not in c.metadata.get('tags', [])]

        # Write to root of sharing package
        output_path = f"{SHARE_DIR}/{os.path.basename(file_path)}"
        with open(output_path, 'w') as f:
            nbformat.write(nb, f)
        print(f"  ✓ {os.path.basename(file_path)} → root")

        # Also export to HTML for easy viewing
        try:
            import subprocess
            html_path = output_path.replace('.ipynb', '.html')
            subprocess.run([
                "jupyter", "nbconvert",
                "--to", "html",
                "--no-input",  # Hide code cells (optional)
                output_path,
                "--output", html_path
            ], check=True, capture_output=True)
            print(f"  ✓ Generated HTML version")
        except:
            print(f"  ⚠️  HTML export failed (optional)")
    else:
        # Copy other files as-is
        shutil.copy(file_path, f"{SHARE_DIR}/{os.path.basename(file_path)}")
        print(f"  ✓ {os.path.basename(file_path)} → root")

# 2. Copy supporting files to organized folders
print("\n📁 Copying supporting files to folders...")

# Figures
if os.path.exists("figures"):
    shutil.copytree("figures", f"{SHARE_DIR}/figures",
                    ignore=shutil.ignore_patterns('*draft*', '*old*'),
                    dirs_exist_ok=True)
    print(f"  ✓ figures/ → {SHARE_DIR}/figures/")

# Data
if os.path.exists("data"):
    shutil.copytree("data", f"{SHARE_DIR}/data",
                    ignore=shutil.ignore_patterns('*backup*', '*old*'),
                    dirs_exist_ok=True)
    print(f"  ✓ data/ → {SHARE_DIR}/data/")

# Scripts
if os.path.exists("scripts"):
    shutil.copytree("scripts", f"{SHARE_DIR}/scripts",
                    ignore=shutil.ignore_patterns('__pycache__', '*.pyc'),
                    dirs_exist_ok=True)
    print(f"  ✓ scripts/ → {SHARE_DIR}/scripts/")

# Documentation
if os.path.exists("documentation"):
    shutil.copytree("documentation", f"{SHARE_DIR}/documentation",
                    dirs_exist_ok=True)
    print(f"  ✓ documentation/ → {SHARE_DIR}/documentation/")

# Environment file
for env_file in ["environment.yml", "requirements.txt", "environment.txt"]:
    if os.path.exists(env_file):
        shutil.copy(env_file, f"{SHARE_DIR}/{env_file}")
        print(f"  ✓ {env_file}")

print("\n✅ Package created with selected files at root!")
```

**Result structure:**
```
shared-YYYY-MM-DD-project/
├── Notebook1.ipynb              ← User-selected, at root
├── Notebook2.ipynb              ← User-selected, at root
├── Notebook1.html               ← Auto-generated
├── Notebook2.html               ← Auto-generated
├── README.md                    ← Generated
├── figures/                     ← Supporting files in folders
│   └── curation_impact/
├── data/
│   └── dataset.csv
├── scripts/
│   ├── plot_script.py
│   └── analysis.py
└── documentation/
    └── notes.md
```

#### Approach B: Copy Entire Directory

```bash
#!/bin/bash

echo "📦 Copying entire project structure..."

# Exclude patterns
EXCLUDE_PATTERNS=(
    "--exclude=deprecated"
    "--exclude=.git"
    "--exclude=__pycache__"
    "--exclude=*.pyc"
    "--exclude=.ipynb_checkpoints"
    "--exclude=shared-*"
    "--exclude=.DS_Store"
    "--exclude=*.swp"
)

# Use rsync for efficient copying with exclusions
rsync -av "${EXCLUDE_PATTERNS[@]}" \
    --exclude="$SHARE_DIR" \
    ./ "$SHARE_DIR/"

echo "✓ Copied entire directory"

# Clean notebooks in the copied directory
echo ""
echo "🧹 Cleaning notebooks..."
cd "$SHARE_DIR"
for notebook in $(find . -name "*.ipynb" -not -path "./.ipynb_checkpoints/*"); do
    python3 << EOF
import nbformat
with open("$notebook", 'r') as f:
    nb = nbformat.read(f, as_version=4)
for cell in nb.cells:
    if cell.cell_type == 'code':
        cell.outputs = []
        cell.execution_count = None
with open("$notebook", 'w') as f:
    nbformat.write(nb, f)
print(f"  ✓ Cleaned: $notebook")
EOF
done

cd ..
echo ""
echo "✅ Entire directory copied and cleaned!"
```

**Result structure:**
```
shared-YYYY-MM-DD-project/
├── Notebook1.ipynb
├── Notebook2.ipynb
├── figures/
│   └── curation_impact/
├── data/
│   └── dataset.csv
├── scripts/
│   ├── plot_script.py
│   └── analysis.py
├── documentation/
│   └── notes.md
└── [maintains original structure]
```

---

#### Legacy: Traditional Level-Based Copying

**For Level 1 (Summary):**

```python
# 1. Export notebook to PDF
import subprocess
import os

notebook = "main_analysis.ipynb"  # Identify main notebook
output_pdf = f"{share_dir}/analysis-{date}.pdf"

try:
    subprocess.run([
        "jupyter", "nbconvert",
        "--to", "pdf",
        "--output", output_pdf,
        notebook
    ], check=True)
    print(f"✓ Exported {notebook} to PDF")
except:
    print("⚠️  PDF export failed - ensure jupyter and LaTeX installed")
    print("Alternative: Export manually from Jupyter")

# 2. Copy figures
import shutil
if os.path.exists("figures"):
    for fig in os.listdir("figures"):
        if fig.endswith(".png"):
            shutil.copy(f"figures/{fig}", f"{share_dir}/results/figures/")
    print(f"✓ Copied figures")

# 3. Copy key result tables (if exist)
for table in ["summary_stats.csv", "results_table.csv"]:
    if os.path.exists(table):
        shutil.copy(table, f"{share_dir}/results/tables/")
```

**For Level 2 (Reproducible):**

```python
import nbformat
import shutil
import os

share_dir = "shared-YYYYMMDD-reproducible"

# 1. Clean and copy notebooks
def clean_notebook(input_path, output_path):
    """Clear outputs and remove debug cells."""
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    # Clear all outputs
    for cell in nb.cells:
        if cell.cell_type == 'code':
            cell.outputs = []
            cell.execution_count = None

    # Remove debug/test cells
    nb.cells = [cell for cell in nb.cells
                if 'debug' not in cell.metadata.get('tags', [])
                and 'remove' not in cell.metadata.get('tags', [])]

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)
    print(f"✓ Cleaned {input_path}")

# Find and clean all analysis notebooks
for notebook in glob.glob("*.ipynb"):
    if "checkpoint" not in notebook and "backup" not in notebook.lower():
        clean_notebook(notebook, f"{share_dir}/notebooks/{notebook}")

# 2. Copy scripts
if os.path.exists("python_scripts") or os.path.exists("scripts"):
    script_dir = "python_scripts" if os.path.exists("python_scripts") else "scripts"
    shutil.copytree(script_dir, f"{share_dir}/scripts",
                    ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '*backup*'))
    print(f"✓ Copied scripts from {script_dir}")

# 3. Copy processed data
if os.path.exists("data"):
    for data_file in os.listdir("data"):
        if data_file.endswith(('.csv', '.tsv', '.xlsx')):
            shutil.copy(f"data/{data_file}", f"{share_dir}/data/processed/")
    print("✓ Copied processed data")

# 4. Copy figures
if os.path.exists("figures"):
    shutil.copytree("figures", f"{share_dir}/figures",
                    ignore=shutil.ignore_patterns('*draft*', '*old*'))
    print("✓ Copied figures")

# 5. Copy environment file
for env_file in ["environment.yml", "requirements.txt", "conda-environment.yml"]:
    if os.path.exists(env_file):
        shutil.copy(env_file, f"{share_dir}/{env_file}")
        print(f"✓ Copied {env_file}")
        break
```

**For Level 3 (Full Archive):**
- Include all steps from Level 2
- Additionally copy raw data directory
- Copy all documentation files
- Include exploratory notebooks

---

### Step 5.5: Verify and Fix File Paths in Notebooks

**CRITICAL:** After copying files, verify that all file references in notebooks point to the correct locations in the sharing package structure.

```python
import json
import os
import re
from pathlib import Path

print("\n🔍 Verifying file paths in notebooks...")

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
    print(f"\n📝 Checking: {os.path.relpath(notebook_path, SHARE_DIR)}")

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
        print(f"  ⚠️  Found {len(issues_found)} path issues:")
        for issue in issues_found[:5]:  # Show first 5
            print(f"    - Cell {issue['cell']}: {issue['type']} → {issue['path']}")

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
                print(f"      💡 File exists at: {possible_locations[0]}")
                print(f"      🔧 Suggested fix: Update path from '{issue['path']}' to '{possible_locations[0]}'")
            else:
                print(f"      ❌ File not found in sharing package")

        if len(issues_found) > 5:
            print(f"    ... and {len(issues_found) - 5} more issues")
    else:
        print("  ✅ All paths verified")

print("\n" + "="*70)
print("PATH VERIFICATION COMPLETE")
print("="*70)
print("\n⚠️  IMPORTANT: If issues were found, you should:")
print("1. Fix paths manually in notebooks, OR")
print("2. Copy missing files to expected locations, OR")
print("3. Run automated path correction (see below)")
```

**Automated Path Correction (Optional):**

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
        print(f"  ✓ Fixed {changes} path references in {os.path.basename(notebook_path)}")
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

    print("\n🔧 Applying automated fixes...")
    fixed_count = 0
    for notebook in notebooks:
        if fix_notebook_paths(notebook, common_fixes):
            fixed_count += 1

    if fixed_count > 0:
        print(f"\n✅ Fixed paths in {fixed_count} notebooks")
        print("⚠️  Regenerate HTML files after fixing paths:")
        print("   jupyter nbconvert --to html <notebook>.ipynb")
```

**Common Path Issues to Check:**

1. **CSV files**: Should include `data/` prefix if notebooks are at root
   - ❌ `pd.read_csv('dataset.csv')`
   - ✅ `pd.read_csv('data/dataset.csv')`

2. **Images in notebooks**: Should match actual figure directory structure
   - ❌ `Image(filename='figure.png')`
   - ✅ `Image(filename='figures/curation_impact/figure.png')`

3. **Markdown images**: Should use correct relative paths
   - ❌ `<img src="phylo/tree.svg">`
   - ✅ `<img src="figures/curation_impact/tree.svg">`

4. **Files from deprecated/**: May need to be copied to sharing package
   - Check if notebooks reference files in `deprecated/` folder
   - Copy needed files to appropriate location in sharing package

**Verification Checklist:**

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

---

### Step 6: Create Documentation Files

**Generate README.md:**

```python
readme_content = f"""# {project_name}

## Description
{user_description}

## Contents

{'### Notebooks' if level >= 2 else '### Analysis'}
{list_files_in_section}

{'### Data' if level >= 2 else ''}
{data_description if level >= 2 else ''}

{'### Scripts' if level >= 2 else ''}
{script_description if level >= 2 else ''}

## Reproduction Instructions

{'### Requirements' if level >= 2 else ''}
{'Install dependencies:' if level >= 2 else ''}
{'```bash' if level >= 2 else ''}
{'conda env create -f environment.yml' if level >= 2 else ''}
{'# or' if level >= 2 else ''}
{'pip install -r requirements.txt' if level >= 2 else ''}
{'```' if level >= 2 else ''}

{'### Running the Analysis' if level >= 2 else ''}
{'1. Activate environment' if level >= 2 else ''}
{'2. Run notebooks in order (01, 02, 03...)' if level >= 2 else ''}
{'3. Figures will be generated in figures/' if level >= 2 else ''}

## Contact
[Add your contact information]

## Date Prepared
{datetime.now().strftime('%Y-%m-%d')}

---
📦 Package prepared with [Claude Code](https://claude.com/claude-code)
"""

with open(f"{share_dir}/README.md", "w") as f:
    f.write(readme_content)

print("✓ Created README.md")
```

**Create MANIFEST.md (for Level 2-3):**

```python
# Generate file listing with descriptions
manifest = "# Project Manifest\n\n"
manifest += "## File Structure\n\n"

for root, dirs, files in os.walk(share_dir):
    level = root.replace(share_dir, '').count(os.sep)
    indent = ' ' * 2 * level
    manifest += f"{indent}{os.path.basename(root)}/\n"
    subindent = ' ' * 2 * (level + 1)
    for file in files:
        manifest += f"{subindent}{file}\n"

with open(f"{share_dir}/MANIFEST.md", "w") as f:
    f.write(manifest)

print("✓ Created MANIFEST.md")
```

---

### Step 7: Final Checks and Summary

```bash
# Show what was created
echo ""
echo "✅ Sharing package created!"
echo ""
echo "📦 Location: $SHARE_DIR"
echo "📊 Size:"
du -sh "$SHARE_DIR"
echo ""
echo "📄 Contents:"
ls -lh "$SHARE_DIR" | tail -n +2
echo ""

# Verify key files present
echo "🔍 Verification:"
[ -f "$SHARE_DIR/README.md" ] && echo "  ✓ README.md" || echo "  ⚠️  README.md missing"
[ -f "$SHARE_DIR/MANIFEST.md" ] && echo "  ✓ MANIFEST.md" || true

# Count files
FILE_COUNT=$(find "$SHARE_DIR" -type f | wc -l)
echo "  ✓ $FILE_COUNT files total"
```

---

### Step 8: Next Steps Guidance

Present to user:

```
✅ Sharing package ready!

📦 Created: {SHARE_DIR}/
📊 Size: {size}
📄 Files: {count}

Next steps:

1. Review the package:
   cd {SHARE_DIR}
   ls -la

2. Test reproduction (recommended for Level 2-3):
   - Try running notebooks in a fresh environment
   - Verify all paths work
   - Check outputs match

3. Compress for sharing (optional):
   tar -czf {SHARE_DIR}.tar.gz {SHARE_DIR}
   # or
   zip -r {SHARE_DIR}.zip {SHARE_DIR}

4. Share via:
   - Email (if < 25 MB)
   - Dropbox/Google Drive
   - Zenodo/Dryad (for archival)
   - GitHub release

⚠️  IMPORTANT: Continue all work in your main project directory,
   not in {SHARE_DIR}. The sharing folder is a snapshot.
```

---

## Best Practices

### Before Creating Package

1. **Run full analysis** to ensure everything works
2. **Clear notebook outputs** (done automatically)
3. **Check for sensitive data** (passwords, API keys, personal info)
4. **Verify environment file** is up-to-date
5. **Test on a colleague** if possible

### What to Exclude

❌ Never include:
- `.env` files or API keys
- Large raw data files (>1GB) without asking
- `__pycache__/` directories (excluded automatically)
- `.ipynb_checkpoints/` (excluded automatically)
- Personal notes or drafts
- Intermediate debug files

### Documentation Tips

✅ Good README includes:
- Brief project description (1-2 paragraphs)
- System requirements
- Installation instructions
- How to run the analysis
- Expected outputs
- Contact information
- Citation (if applicable)

---

## Troubleshooting

### PDF export fails
```bash
# Check if jupyter and nbconvert installed
jupyter nbconvert --version

# If missing:
pip install jupyter nbconvert

# For PDF, also need LaTeX:
# macOS: brew install basictex
# Ubuntu: apt-get install texlive-xetex
```

### Files too large
- Compress large data: `gzip large_file.csv`
- Provide download links instead of including raw data
- Use Git LFS for versioned large files
- Consider splitting into multiple packages

### Notebooks won't run
- Missing dependencies - check environment.yml
- Absolute paths in code - convert to relative
- Data files in wrong location - update paths

---

## Summary

This command creates professional, shareable project packages at three levels:

1. **Summary** - Quick sharing (PDF + figures)
2. **Reproducible** - Standard collaboration (notebooks + data + scripts)
3. **Full Archive** - Complete traceability (raw data through final results)

**Remember:** The sharing folder is a clean snapshot. All work continues in your main project directory.
