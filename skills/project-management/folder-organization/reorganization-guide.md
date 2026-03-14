# Project Reorganization Guide

Systematic approach to reorganizing existing project folder structures without breaking dependencies.

## Post-Reorganization Path Updates

After reorganizing folders, **ALWAYS verify and update file paths** in all scripts and notebooks. Files often contain hardcoded paths that break after reorganization.

### Systematic Path Update Process

1. **Identify all files that reference other files**:
   ```bash
   # Find notebooks
   find . -name "*.ipynb"

   # Find Python scripts
   find . -name "*.py"

   # Search for file references
   grep -r "\.json\|\.csv\|\.tsv\|\.png" --include="*.ipynb" --include="*.py"
   ```

2. **Common file reference patterns to search for**:
   - Data files: `.json`, `.csv`, `.tsv`, `.xlsx`
   - Figures: `.png`, `.jpg`, `.pdf`, `.svg`
   - Python: `open()`, `read_csv()`, `read_json()`, `load()`
   - Jupyter: `savefig()`, file I/O operations

3. **Update paths using sed for batch replacements**:
   ```bash
   # Update data file paths
   sed -i.bak "s|'filename.json'|'../data/filename.json'|g" notebook.ipynb

   # Update figure output paths
   sed -i.bak "s|savefig('fig|savefig('../figures/fig|g" notebook.ipynb

   # Update with double quotes (common in Python code)
   sed -i.bak 's|"filename.csv"|"../data/filename.csv"|g' script.py
   ```

4. **Verify updates**:
   ```bash
   # Check that paths were updated correctly
   grep -o "'../data/[^']*'" notebook.ipynb | head -5
   grep -o "'../figures/[^']*'" notebook.ipynb | head -5
   ```

5. **Clean up backup files**:
   ```bash
   rm *.bak *.bak2 *.bak3
   ```

### Files to Check

Always check these file types after reorganization:

- **Jupyter notebooks** (`.ipynb`): Data loading, figure saving
- **Python scripts** (`.py`): File I/O operations
- **Test files** (`test_*.py`): Often reference data fixtures
- **Data processing scripts**: Input/output paths
- **Documentation**: Code examples with file paths
- **Configuration files**: Paths to resources

### Common Path Patterns

| Original Location | After Reorganization | Relative Path |
|------------------|---------------------|---------------|
| `./data.json` | `../data/data.json` | Go up one level, into data/ |
| `./figure.png` | `../figures/figure.png` | Go up one level, into figures/ |
| `./test.py` accessing `data.json` | `../data/data.json` | From tests/ to data/ |
| `./notebook.ipynb` accessing both | `../data/`, `../figures/` | From notebooks/ to both |

### Tips

- **Use relative paths** (`../data/`) not absolute paths for portability
- **Batch process** similar changes using sed or find/replace
- **Test one file type at a time** (notebooks first, then scripts)
- **Keep backup files** (`.bak`) until verification complete
- **Grep to verify** changes were applied correctly
- **Consider case sensitivity** on different operating systems

## Verification and Cleanup After Reorganization

After completing a reorganization, always verify the results and clean up:

### 1. Verify File Counts
```bash
# Count files moved to each directory
for dir in figures data tests notebooks docs archives; do
  echo "$dir: $(ls $dir 2>/dev/null | wc -l | tr -d ' ') files"
done
```

### 2. Check Root Directory
```bash
# Ensure root is clean
ls -la

# Should only see:
# - Organized directories (figures/, data/, etc.)
# - Project-specific folders (Fetch_data/, sharing/)
# - Config directories (.claude/, .git/)
# - Essential files (README.md, .gitignore, etc.)
```

### 3. Remove Temporary Files
```bash
# Remove Jupyter checkpoints (auto-generated, not needed in version control)
rm -rf .ipynb_checkpoints

# Remove sed backup files
rm *.bak *.bak2 *.bak3

# Remove duplicate/backup data files
rm *.backup *.backup2 *.old
```

### 4. Display Final Structure
```bash
# Show clean directory tree
tree -L 2 -d

# Or list directories only
ls -d */
```

### Verification Checklist

- [ ] All target directories created successfully
- [ ] File counts match expectations (no files lost)
- [ ] Root directory is clean (no scattered files)
- [ ] Temporary/backup files removed
- [ ] Paths in notebooks/scripts updated (see "Post-Reorganization Path Updates")
- [ ] Structure documented (README or similar)
- [ ] Test that notebooks/scripts still run correctly

## After Reorganization: Session Folder Cleanup

**Clean up old session folder variations:**

If you renamed folders during reorganization (e.g., `sessions-history/` -> `session-saves/`):

1. **Move archived sessions:**
```bash
mv old-folder/*.md session-saves/archived/daily/
```

2. **Remove empty old folders safely:**
```bash
rmdir old-folder/  # Fails if not empty - safety check
```

3. **Update any links** to old folder structure

**Don't leave multiple session folders:**
- Bad: `sessions-history/` and `session-saves/` both present
- Good: Single `session-saves/` with archived content

**Verification:**
```bash
# Check for session folder variations
find . -type d -name "*session*" -not -path "*/archived/*"
# Should show only: ./session-saves/
```

## Cleanup and Maintenance

### Regular Maintenance Tasks

1. **Archive old branches** - Delete merged feature branches
2. **Clean temp files** - Remove `TODO.md`, `NOTES.md` from completed work
3. **Update documentation** - Keep README current with changes
4. **Review .gitignore** - Ensure large files aren't tracked
5. **Organize notebooks** - Rename/renumber as project evolves

### End-of-Project Checklist

- [ ] README complete and accurate
- [ ] Code documented
- [ ] Tests passing
- [ ] Large files gitignored
- [ ] Working files removed (TODO.md, scratch notebooks)
- [ ] Final outputs in `results/`
- [ ] Environment files current
- [ ] License added (if applicable)
