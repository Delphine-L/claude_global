# Correcting Cleanup Mistakes and Deprecating Notebooks

Supporting reference for the **project-sharing** skill. See [SKILL.md](SKILL.md) for the main skill document.

---

## Correcting Cleanup Mistakes

### Identifying Missing Files After Cleanup

When users report missing figures, scripts, or resources after a cleanup:

1. **Check notebook/code references systematically**:
   ```bash
   # Find all image references in notebooks
   grep -n "\.png\|Image(\|display(" notebook.ipynb

   # Find script imports
   grep -n "import\|from.*import\|\.py" notebook.ipynb

   # Find data file references
   grep -n "\.csv\|\.tsv\|\.json" notebook.ipynb
   ```

2. **Search deprecated folders**:
   ```bash
   # Find specific files
   find deprecated -name "*pattern*" -type f

   # Search by file type
   find deprecated -name "*.png" -o -name "*.py"
   ```

3. **Check original location**:
   ```bash
   # Sometimes files are in unexpected locations
   find . -name "phylogenetic_tree*"
   ```

### Restoration Workflow

1. **Verify the file is truly needed**:
   - Check if it's referenced in active notebooks
   - Confirm it's not redundant with other files
   - Check if other notebooks also use it

2. **Restore systematically**:
   ```bash
   # Restore to original location
   cp deprecated/path/to/file.png figures/target/

   # Update sharing packages if they exist
   cp deprecated/path/to/file.png sharing-package/figures/target/
   ```

3. **Document the restoration**:
   - Create a restoration summary document
   - List what was restored and why
   - Update MINIMAL_ESSENTIAL_FILES.md or equivalent

### Example: Figure Restoration

```bash
# 1. Identify missing figures from notebook
grep -o "'[^']*\.png'" Curation_Impact_Analysis.ipynb

# 2. Find them in deprecated
find deprecated -name "05_terminal_telomeres.png"

# 3. Restore systematically
for fig in 05_terminal_telomeres.png 07_chromosome_assignment_comparison.png; do
    cp "deprecated/figures/curation_impact/$fig" figures/curation_impact/
    cp "deprecated/figures/curation_impact/$fig" shared-package/figures/curation_impact/
done

# 4. Verify restoration
ls -lh figures/curation_impact/*.png | wc -l  # Should match expected count
```

### Prevention: Better Cleanup Verification

Before finalizing cleanup:

1. **Grep all notebooks for references**:
   ```bash
   # Find all figure references across notebooks
   grep -h "\.png" *.ipynb | sort | uniq
   ```

2. **Cross-reference with existing files**:
   ```bash
   # Compare referenced vs existing
   comm -13 <(ls figures/*/*.png | sort) <(grep -oh "[^/]*\.png" *.ipynb | sort | uniq)
   ```

3. **Test notebook execution** (if feasible):
   - Open each notebook
   - Check that all figures load
   - Verify no broken image references

**Lesson**: Always verify notebook dependencies before moving files to deprecated. Use grep to find all references before cleanup operations.

---

## Deprecating Redundant Notebooks

### Identifying Redundancy

A notebook may be redundant if:
- **Content overlaps** with another notebook
- **No unique figures**: All visualizations come from shared directories
- **No unique scripts**: All code is shared with other analyses
- **No unique data**: Uses the same datasets as other notebooks

### Dependency Analysis Workflow

Before deprecating a notebook, check what it uses:

```bash
# 1. Check figure references
grep -o "Image(filename.*\.png" notebook.ipynb | sort | uniq

# 2. Check if figures are unique or shared
for fig in $(grep -oh "[^/]*\.png" notebook.ipynb); do
    grep -l "$fig" *.ipynb | grep -v notebook.ipynb
done

# 3. Check data file usage
grep -o "read_csv.*\.csv" notebook.ipynb

# 4. Check script imports (if any)
grep -o "^import\|^from.*import" notebook.ipynb
```

### Safe Deprecation Process

1. **Document the notebook's purpose**:
   - What analysis does it perform?
   - Why was it created?
   - What makes it redundant now?

2. **Verify no unique dependencies**:
   ```bash
   # Check figures
   figures_used=$(grep -oh "[^'\"]*\.png" notebook_to_deprecate.ipynb | sort | uniq)

   # Check if any are unique to this notebook
   for fig in $figures_used; do
       other_notebooks=$(grep -l "$fig" *.ipynb | grep -v notebook_to_deprecate | wc -l)
       if [ "$other_notebooks" -eq 0 ]; then
           echo "WARNING: $fig is only used by this notebook"
       fi
   done
   ```

3. **Move notebook only** (if no unique dependencies):
   ```bash
   # Move notebook to deprecated
   mv Redundant_Notebook.ipynb deprecated/

   # Remove from sharing packages
   rm -f sharing-package/notebooks/Redundant_Notebook.ipynb
   ```

4. **Document the deprecation**:
   Create a `DEPRECATION_SUMMARY.md`:
   ```markdown
   # Notebook Deprecation: [Name]

   **Date**: YYYY-MM-DD
   **Reason**: [Brief explanation]

   ## Analysis
   - Figures: [all shared/unique ones moved]
   - Scripts: [all shared/unique ones moved]
   - Data: [all shared]

   ## Files Moved
   - Notebook: [path] -> deprecated/
   - Figures: [none/list]
   - Scripts: [none/list]

   ## Active Notebooks
   [List remaining active notebooks]

   ## Restoration
   ```bash
   cp deprecated/Notebook.ipynb .
   ```
   ```

### Example: Both_Haplotypes Deprecation

```bash
# 1. Check dependencies
grep "\.png" Curation_Impact_Analysis_Both_Haplotypes.ipynb
# Result: All figures from figures/curation_impact/

grep "\.png" Curation_Impact_Analysis.ipynb
# Result: Same figures - confirmed shared

# 2. Check data files
grep "\.csv" Curation_Impact_Analysis_Both_Haplotypes.ipynb
# Result: vgp_assemblies_unified.csv (shared with main notebook)

# 3. Safely deprecate (notebook only, no other files)
mv Curation_Impact_Analysis_Both_Haplotypes.ipynb deprecated/
rm shared-package/notebooks/Curation_Impact_Analysis_Both_Haplotypes.ipynb

# 4. Document
echo "All figures, scripts, and data remain active (shared)" > documentation/DEPRECATION_SUMMARY.md
```

**Key Principle**: Only move the notebook if ALL dependencies are shared with active notebooks. Never move shared resources to deprecated.
