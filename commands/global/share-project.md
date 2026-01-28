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

**Level 1 - Summary:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-summary"
mkdir -p "$SHARE_DIR"/{results/{figures,tables}}

echo "Created structure:"
tree -L 2 "$SHARE_DIR" 2>/dev/null || ls -R "$SHARE_DIR"
```

**Level 2 - Reproducible:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-reproducible"
mkdir -p "$SHARE_DIR"/{notebooks,scripts,data/processed,figures}

echo "Created structure:"
tree -L 2 "$SHARE_DIR" 2>/dev/null || ls -R "$SHARE_DIR"
```

**Level 3 - Full Archive:**
```bash
SHARE_DIR="shared-$(date +%Y%m%d)-full"
mkdir -p "$SHARE_DIR"/{data/{raw,intermediate,processed},scripts,notebooks/{exploratory,final},results/{figures,tables,supplementary},documentation}

echo "Created structure:"
tree -L 2 "$SHARE_DIR" 2>/dev/null || ls -R "$SHARE_DIR"
```

---

### Step 5: Copy and Clean Files

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
