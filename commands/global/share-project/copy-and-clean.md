# Copy and Clean Files (Step 5)

## Directory Structure Creation (Step 4)

### Approach A: Specific Files at Root (Option 1 selected)

```bash
SHARE_DIR="shared-$(date +%Y%m%d)-${project_name}"
mkdir -p "$SHARE_DIR"

# Create folders for supporting files only
mkdir -p "$SHARE_DIR"/{figures,data,scripts,documentation}

echo "Created sharing package structure:"
echo "$SHARE_DIR/"
echo "|- [Selected files will be at root]"
echo "|- figures/"
echo "|- data/"
echo "|- scripts/"
echo "|- documentation/"
echo "'- README.md"
```

**Structure philosophy:**
- **Root level**: User-selected key files (e.g., notebooks) - immediately visible
- **Folders**: Supporting files (figures, data, scripts) - organized but not prominent
- **Clean and minimal**: Recipients see the important files first

### Approach B: Entire Directory (Option 2 selected)

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

## Approach A: Copy Specific Files to Root

```python
import nbformat
import shutil
import os
from pathlib import Path

# ROOT_FILES contains user-selected files from Step 1.5
# Example: ['Notebook1.ipynb', 'Notebook2.ipynb']

print("Creating sharing package with selected files at root...")

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
        print(f"  {os.path.basename(file_path)} -> root")

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
            print(f"  Generated HTML version")
        except:
            print(f"  HTML export failed (optional)")
    else:
        # Copy other files as-is
        shutil.copy(file_path, f"{SHARE_DIR}/{os.path.basename(file_path)}")
        print(f"  {os.path.basename(file_path)} -> root")

# 2. Copy supporting files to organized folders
print("\nCopying supporting files to folders...")

# Figures
if os.path.exists("figures"):
    shutil.copytree("figures", f"{SHARE_DIR}/figures",
                    ignore=shutil.ignore_patterns('*draft*', '*old*'),
                    dirs_exist_ok=True)
    print(f"  figures/ -> {SHARE_DIR}/figures/")

# Data
if os.path.exists("data"):
    shutil.copytree("data", f"{SHARE_DIR}/data",
                    ignore=shutil.ignore_patterns('*backup*', '*old*'),
                    dirs_exist_ok=True)
    print(f"  data/ -> {SHARE_DIR}/data/")

# Scripts
if os.path.exists("scripts"):
    shutil.copytree("scripts", f"{SHARE_DIR}/scripts",
                    ignore=shutil.ignore_patterns('__pycache__', '*.pyc'),
                    dirs_exist_ok=True)
    print(f"  scripts/ -> {SHARE_DIR}/scripts/")

# Documentation (directory-based filtering)
# RECOMMENDED: Use organized documentation structure (see documentation-organization skill)
# Include: data_descriptions/, methods/, results/, reference/
# Exclude: progress/, action_reports/, todos/, internal/, deprecated/, logs/, working_files/
if os.path.exists("documentation"):
    def ignore_internal_dirs(dir, files):
        """Exclude internal documentation directories."""
        ignore_list = []
        for item in files:
            # Exclude internal directories
            if item in ['progress', 'action_reports', 'todos', 'internal',
                       'deprecated', 'logs', 'working_files', 'temp', 'tmp', '__pycache__']:
                ignore_list.append(item)
            # Exclude hidden files (except .gitkeep)
            elif item.startswith('.') and item != '.gitkeep':
                ignore_list.append(item)
        return ignore_list

    shutil.copytree("documentation", f"{SHARE_DIR}/documentation",
                    ignore=ignore_internal_dirs,
                    dirs_exist_ok=True)

    # Report what was copied
    import os
    copied_count = sum([len(files) for r, d, files in os.walk(f"{SHARE_DIR}/documentation")])
    dirs_copied = [d for d in os.listdir(f"{SHARE_DIR}/documentation")
                   if os.path.isdir(os.path.join(f"{SHARE_DIR}/documentation", d))]

    print(f"  documentation/ -> {SHARE_DIR}/documentation/ ({copied_count} files)")
    if dirs_copied:
        print(f"    Included directories: {', '.join(dirs_copied)}")
    print(f"    Excluded: progress/, action_reports/, todos/, internal/, deprecated/, logs/")

# Environment file
for env_file in ["environment.yml", "requirements.txt", "environment.txt"]:
    if os.path.exists(env_file):
        shutil.copy(env_file, f"{SHARE_DIR}/{env_file}")
        print(f"  {env_file}")

print("\nPackage created with selected files at root!")
```

**Result structure:**
```
shared-YYYY-MM-DD-project/
|- Notebook1.ipynb              <- User-selected, at root
|- Notebook2.ipynb              <- User-selected, at root
|- Notebook1.html               <- Auto-generated
|- Notebook2.html               <- Auto-generated
|- README.md                    <- Generated
|- figures/                     <- Supporting files in folders
|  '- curation_impact/
|- data/
|  '- dataset.csv
|- scripts/
|  |- plot_script.py
|  '- analysis.py
'- documentation/                  <- Filtered & organized
    |- README.md
    |- ANALYSIS_SUMMARY.md
    |- DATA_TABLE_VERIFICATION.md
    '- methods/                    <- Methodology docs subfolder
        |- KARYOTYPE_WORKFLOW.md
        |- analysis_plan.md
        '- data_fetching_plan.md
    # Excluded: logs/, working_files/, deprecation, cleanup, progress, session notes
```

---

## Documentation Filtering Details

**Included (essential for understanding project):**
- README files
- Analysis summaries and reports
- Data verification docs
- Reference materials
- Results summaries

**Included Directories (shareable):**
- `data_descriptions/` - Dataset documentation and README files
- `methods/` - Methodology, workflows, analysis plans
- `results/` - Analysis summaries and findings
- `reference/` - Citations and external references (if present)
- Root files: README.md

**Excluded Directories (internal):**
- `progress/` - Progress tracking, session notes
- `action_reports/` - Updates, corrections, verifications
- `todos/` - Task lists and priorities
- `internal/` - Project management documentation
- `deprecated/` - Old versions and deprecated files
- `logs/` - Runtime logs
- `working_files/` - Temporary files
- Hidden files (except .gitkeep)

**Recommendation**: Organize your documentation using the structure from the `documentation-organization` skill:
```
documentation/
|- data_descriptions/  # Share
|- methods/            # Share
|- results/            # Share
|- reference/          # Share (optional)
|- progress/           # Internal
|- action_reports/     # Internal
|- todos/              # Internal
|- internal/           # Internal
'- deprecated/         # Internal
```

This ensures recipients see:
- Clean, professional documentation
- Clear separation of shareable vs internal content
- Organized by purpose (data, methods, results)
- No working notes or development artifacts

---

## Approach B: Copy Entire Directory

```bash
#!/bin/bash

echo "Copying entire project structure..."

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

echo "Copied entire directory"

# Clean notebooks in the copied directory
echo ""
echo "Cleaning notebooks..."
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
print(f"  Cleaned: $notebook")
EOF
done

cd ..
echo ""
echo "Entire directory copied and cleaned!"
```

**Result structure:**
```
shared-YYYY-MM-DD-project/
|- Notebook1.ipynb
|- Notebook2.ipynb
|- figures/
|  '- curation_impact/
|- data/
|  '- dataset.csv
|- scripts/
|  |- plot_script.py
|  '- analysis.py
|- documentation/
|  '- notes.md
'- [maintains original structure]
```

---

## Legacy: Traditional Level-Based Copying

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
    print(f"Exported {notebook} to PDF")
except:
    print("PDF export failed - ensure jupyter and LaTeX installed")
    print("Alternative: Export manually from Jupyter")

# 2. Copy figures
import shutil
if os.path.exists("figures"):
    for fig in os.listdir("figures"):
        if fig.endswith(".png"):
            shutil.copy(f"figures/{fig}", f"{share_dir}/results/figures/")
    print(f"Copied figures")

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
    print(f"Cleaned {input_path}")

# Find and clean all analysis notebooks
for notebook in glob.glob("*.ipynb"):
    if "checkpoint" not in notebook and "backup" not in notebook.lower():
        clean_notebook(notebook, f"{share_dir}/notebooks/{notebook}")

# 2. Copy scripts
if os.path.exists("python_scripts") or os.path.exists("scripts"):
    script_dir = "python_scripts" if os.path.exists("python_scripts") else "scripts"
    shutil.copytree(script_dir, f"{share_dir}/scripts",
                    ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '*backup*'))
    print(f"Copied scripts from {script_dir}")

# 3. Copy processed data
if os.path.exists("data"):
    for data_file in os.listdir("data"):
        if data_file.endswith(('.csv', '.tsv', '.xlsx')):
            shutil.copy(f"data/{data_file}", f"{share_dir}/data/processed/")
    print("Copied processed data")

# 4. Copy figures
if os.path.exists("figures"):
    shutil.copytree("figures", f"{share_dir}/figures",
                    ignore=shutil.ignore_patterns('*draft*', '*old*'))
    print("Copied figures")

# 5. Copy environment file
for env_file in ["environment.yml", "requirements.txt", "conda-environment.yml"]:
    if os.path.exists(env_file):
        shutil.copy(env_file, f"{share_dir}/{env_file}")
        print(f"Copied {env_file}")
        break
```

**For Level 3 (Full Archive):**
- Include all steps from Level 2
- Additionally copy raw data directory
- Copy all documentation files
- Include exploratory notebooks
