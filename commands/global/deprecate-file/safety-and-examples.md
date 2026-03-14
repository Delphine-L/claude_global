# Safety Features and Examples

## Validation Checks

```bash
# Check if file is in deprecated/ already
if [[ "$FILE_PATH" == *"/deprecated/"* ]]; then
    echo "Error: File is already in deprecated/"
    exit 1
fi

# Check for uncommitted changes
if git ls-files --error-unmatch "$FILE_PATH" &>/dev/null; then
    if ! git diff --quiet "$FILE_PATH"; then
        echo "Warning: File has uncommitted changes"
        read -p "Continue anyway? (y/n): " CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            exit 1
        fi
    fi
fi

# Check if target already exists in deprecated/
if [ -f "$TARGET_PATH" ]; then
    echo "Warning: File already exists in deprecated/"
    read -p "Overwrite? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        # Suggest renamed path
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        NEW_TARGET="${TARGET_PATH%.${TARGET_PATH##*.}}_$TIMESTAMP.${TARGET_PATH##*.}"
        echo "Moving to: $NEW_TARGET"
        TARGET_PATH="$NEW_TARGET"
    fi
fi
```

---

## Example 1: Deprecate Old Figure

```bash
/deprecate-file figures/assembly_size_plot_v1.png --reason "Updated with better color scheme in v2"
```

Output:
```
Analyzing dependencies for: figures/assembly_size_plot_v1.png

Found dependencies:
  - notebooks/create_figures.ipynb

Checking which dependencies are still needed...

  notebooks/create_figures.ipynb - still used by:
      - figures/assembly_size_plot_v2.png
      - figures/quality_metrics_plot.png

Deprecation Plan

Primary file to deprecate:
  figures/assembly_size_plot_v1.png
  Reason: Updated with better color scheme in v2

Dependencies that will NOT be deprecated (still in use):
  notebooks/create_figures.ipynb

Files will be moved to:
  deprecated/<original-path>

Moving files to deprecated/...

  Moved: figures/assembly_size_plot_v1.png -> deprecated/figures/assembly_size_plot_v1.png

Files moved to deprecated/

Updating MANIFEST files...

  Removing from figures/MANIFEST.md: assembly_size_plot_v1.png

Updating deprecation log...

Deprecation log updated: deprecated/DEPRECATION_LOG.md

Deprecation Complete

Files deprecated: 1
Location: deprecated/

Next steps:
  - Review deprecated/DEPRECATION_LOG.md for details
  - MANIFEST files have been updated automatically
  - Commit changes: git add . && git commit -m "Deprecate: assembly_size_plot_v1.png"
```

## Example 2: Deprecate Notebook with Dependencies

```bash
/deprecate-file notebooks/exploratory_analysis.ipynb --recursive --reason "Exploratory only, results integrated into final_analysis.ipynb"
```

Output shows recursive deprecation of data files created by the notebook that aren't used elsewhere.

## Example 3: Dry Run

```bash
/deprecate-file scripts/old_pipeline.py --dry-run
```

Shows what would be deprecated without actually moving files.

---

## Best Practices

1. **Always provide a reason** - Use `--reason` to document why
2. **Review dependencies** - Check what else might be deprecated recursively
3. **Use dry-run first** - Preview changes for complex deprecations
4. **Update MANIFESTs** - Let the command update them automatically
5. **Commit immediately** - Commit deprecation as a single logical change
6. **Keep deprecation log** - Don't delete deprecated/DEPRECATION_LOG.md

---

## Integration with Other Commands

### Use with /update-manifest

After deprecation, update MANIFEST with context:
```bash
/deprecate-file old_analysis.ipynb --reason "Replaced by new_analysis.ipynb"
/update-manifest  # Add notes about what replaced deprecated files
```

### Use with /cleanup-project

At project end, deprecate old exploratory files:
```bash
/deprecate-file notebooks/exploration_*.ipynb --recursive --reason "Project finalized"
/cleanup-project  # Clean up project structure
```
