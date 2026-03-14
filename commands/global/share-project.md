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
echo "Analyzing project structure..."
echo ""

# List key project files
ls -1 *.ipynb 2>/dev/null | head -5
ls -1 *.py 2>/dev/null | head -3
ls -d figures/ data/ scripts/ 2>/dev/null

# Check for environment specs
ls -1 environment.yml requirements.txt conda*.yml 2>/dev/null

# Check for MANIFEST files
echo ""
echo "Checking for MANIFEST files..."
MANIFESTS=$(find . -name "MANIFEST.md" -not -path "*/deprecated/*" 2>/dev/null)
if [ -n "$MANIFESTS" ]; then
    echo "Found MANIFEST files:"
    echo "$MANIFESTS" | while read manifest; do
        echo "  - $manifest"
    done
    HAVE_MANIFESTS=true
else
    echo "  No MANIFEST files found"
    HAVE_MANIFESTS=false
fi
```

---

### Step 1.5: Parse MANIFESTs to Identify Key Files (If Available)

**This step runs ONLY if MANIFEST files exist** (`HAVE_MANIFESTS=true`). Parses MANIFEST files to identify main files, active files, and deprecated files for intelligent file selection.

For detailed MANIFEST parsing code, see [share-project/manifest-parsing.md](share-project/manifest-parsing.md).

---

### Step 1.6: Ask About File Selection

Present two options to the user:

- **Option 1: Specific files at root** (Recommended for focused sharing) - User selects key files to place at package root; everything else in folders
- **Option 2: Share entire directory** (Full project structure) - Copy everything except deprecated/excluded patterns

If MANIFESTs exist, show intelligent suggestions with main files pre-identified. Allow quick selection with `main` keyword.

For detailed file selection workflows and code, see [share-project/file-selection.md](share-project/file-selection.md).

**Collect user input:**
- Store selected files in array: `ROOT_FILES=()`
- Validate files exist
- Confirm selection with user

---

### Step 2: Ask User for Sharing Level

Present options clearly:

```
Project Sharing Setup

Which sharing level do you need?

1. Summary Only
   - PDF of notebook(s) + final figures
   - Audience: Non-technical stakeholders, presentations
   - Size: Small (~10-50 MB)

2. Reproducible Package
   - Cleaned notebooks + scripts + processed data
   - Audience: Researchers, reviewers, collaborators
   - Size: Medium (~50-500 MB)

3. Full Archive
   - Everything from raw data through all processing
   - Audience: Repositories (Zenodo/Dryad), compliance, archival
   - Size: Large (may be GBs)

Enter choice [1-3]:
```

**Follow-up: Verbosity Level**

Ask if user wants abridged versions of notebooks/documentation:
- **No (default)**: Include full content as-is
- **Yes (abridge)**: Remove verbose content, create two versions (abridged at root, full in unabridged/)

```bash
ABRIDGE_MODE=false  # or true if user selects 'y'
```

---

### Step 3: Gather Additional Information

**For all levels:**
- Brief project description (for README)
- Sharing directory name (suggest: `shared-YYYY-MM-DD-[project-name]`)

**For Level 2-3 (Reproducible/Full):**
- Any data files with sensitive information to exclude?
- Include raw data or just link to source? (if raw data is large)

---

### Step 4: Create Sharing Directory Structure

Create directory based on approach selected in Step 1.6:

- **Approach A (Specific files):** `mkdir -p "$SHARE_DIR"/{figures,data,scripts,documentation}`
- **Approach B (Entire directory):** Copy with rsync, excluding deprecated/.git/__pycache__/etc.

For detailed directory structures and legacy level-based approaches, see [share-project/copy-and-clean.md](share-project/copy-and-clean.md).

---

### Step 5: Copy and Clean Files

Core operations for both approaches:

1. **Clean notebooks**: Remove outputs, clear execution counts, remove debug-tagged cells
2. **Copy supporting files**: figures/, data/, scripts/, documentation/ (with filtering)
3. **Export HTML**: Generate HTML versions of notebooks for easy viewing
4. **Copy environment files**: environment.yml, requirements.txt

**Documentation filtering**: Include shareable dirs (data_descriptions/, methods/, results/, reference/). Exclude internal dirs (progress/, action_reports/, todos/, internal/, deprecated/, logs/, working_files/).

For complete copy/clean code for both approaches and legacy level-based copying, see [share-project/copy-and-clean.md](share-project/copy-and-clean.md).

---

### Step 5.5: Verify and Fix File Paths in Notebooks

**CRITICAL:** After copying, verify all file references in notebooks point to correct locations in the sharing package. Check read_csv, Image, imread, and markdown image paths.

For path verification code and automated correction, see [share-project/path-verification.md](share-project/path-verification.md).

**Common issues:**
- CSV files need `data/` prefix when notebooks are at root
- Image paths must match actual figure directory structure
- Markdown images need correct relative paths
- Files from deprecated/ may need copying to sharing package

---

### Step 5.6: Create Abridged Versions (If Requested)

**ONLY if `ABRIDGE_MODE=true`.** Creates concise versions by removing verbose markdown cells (historical notes, revision history, lengthy discussions without results). Preserves all code cells, figures, statistical results, and conclusions. Full versions stored in unabridged/.

For abridging code and details, see [share-project/abridging.md](share-project/abridging.md).

---

### Step 6: Create Documentation Files

Generate README.md with project description, contents listing, reproduction instructions, and contact info. For Level 2-3, also generate MANIFEST.md with complete file listing.

For README and MANIFEST templates, see [share-project/templates.md](share-project/templates.md).

---

### Step 7: Final Checks and Summary

```bash
echo "Sharing package created!"
echo ""
echo "Location: $SHARE_DIR"
echo "Size:"
du -sh "$SHARE_DIR"
echo ""
echo "Contents:"
ls -lh "$SHARE_DIR" | tail -n +2

# Verify key files
[ -f "$SHARE_DIR/README.md" ] && echo "  README.md present" || echo "  README.md missing"
FILE_COUNT=$(find "$SHARE_DIR" -type f | wc -l)
echo "  $FILE_COUNT files total"
```

---

### Step 8: Next Steps Guidance

Present to user:
1. **Review** the package (`cd {SHARE_DIR} && ls -la`)
2. **Test reproduction** (recommended for Level 2-3): run notebooks in fresh environment
3. **Compress** for sharing: `tar -czf {SHARE_DIR}.tar.gz {SHARE_DIR}` or `zip -r`
4. **Share** via Email (<25 MB), Dropbox/Google Drive, Zenodo/Dryad, or GitHub release

**IMPORTANT:** Continue all work in your main project directory, not in the sharing folder. The sharing folder is a snapshot.

For detailed next steps and troubleshooting, see [share-project/reference.md](share-project/reference.md).

---

## Key Rules

### What to Exclude
- `.env` files or API keys
- Large raw data files (>1GB) without asking
- `__pycache__/`, `.ipynb_checkpoints/` (auto-excluded)
- Personal notes, drafts, intermediate debug files

### MANIFEST Integration
When MANIFEST files exist, the command provides: automatic main file identification, smart file suggestions, and auto-exclusion of deprecated files. Works without MANIFESTs too (manual file selection). For full details, see [share-project/reference.md](share-project/reference.md).

---

## Supporting Files

| File | Contents |
|------|----------|
| [share-project/manifest-parsing.md](share-project/manifest-parsing.md) | MANIFEST parsing Python code and bash integration |
| [share-project/file-selection.md](share-project/file-selection.md) | File selection workflows for both options |
| [share-project/copy-and-clean.md](share-project/copy-and-clean.md) | File copying, notebook cleaning, directory structures, legacy levels |
| [share-project/path-verification.md](share-project/path-verification.md) | Path verification and automated correction code |
| [share-project/abridging.md](share-project/abridging.md) | Notebook abridging logic and verbose cell detection |
| [share-project/templates.md](share-project/templates.md) | README/MANIFEST templates, final checks, legacy directory structures |
| [share-project/reference.md](share-project/reference.md) | Best practices, troubleshooting, MANIFEST integration details, next steps |

## Summary

This command creates professional, shareable project packages at three levels:

1. **Summary** - Quick sharing (PDF + figures)
2. **Reproducible** - Standard collaboration (notebooks + data + scripts)
3. **Full Archive** - Complete traceability (raw data through final results)

**Remember:** The sharing folder is a clean snapshot. All work continues in your main project directory.
