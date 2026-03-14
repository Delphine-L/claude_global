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
  echo "No Jupyter notebooks found in current directory"
  exit 1
fi

# Count notebooks
nb_count=$(echo "$notebooks" | wc -l | tr -d ' ')

if [ "$nb_count" -eq 1 ]; then
  notebook_path="$notebooks"
  echo "Found notebook: $notebook_path"
else
  echo "Found $nb_count notebooks:"
  echo "$notebooks" | nl
  echo ""
  echo "Which notebook to update? (enter number or path)"
fi
```

### Steps 2-4: Pre-Update Analysis and Validation

Analyze notebook structure, validate figure references, and check data coherence.

> **Full details:** See [validation-checks.md](./update-notebook/validation-checks.md)

**Summary of checks performed:**

1. **Pre-Update Analysis (Step 2)** - Load notebook, count cells by type, detect TOC, extract figure references, data references, and section structure.

2. **Figure Reference Validation (Step 3)** - Extract figure numbers from descriptions and code cells. Check for: missing descriptions, missing image displays, non-adjacent figure/description pairs, non-sequential numbering, missing figure files on disk. Generate a validation report.

3. **Variable and Data Coherence (Step 4)** - Extract variable assignments and dataframe operations from code cells. Check markdown for sample size mentions and file references. Flag inconsistent sample sizes, missing referenced files, and undefined variables.

### Steps 5-6: TOC and Figure Legend Validation

Update table of contents and validate figure legend quality.

> **Full details:** See [toc-and-legends.md](./update-notebook/toc-and-legends.md)

**Summary of checks performed:**

1. **Table of Contents Update (Step 5)** - Extract all section headers, build hierarchy, generate new TOC with proper anchors. Compare with existing TOC and flag if update needed. Offer to insert TOC if none exists.

2. **Figure Legend Validation (Step 6)** - For each figure, check description quality: minimum length (50 chars), presence of method keywords (plot type), data info keywords (sample details), and statistical keywords. Report issues per figure.

### Steps 7-9: Interactive Updates and Execution

Present update options, execute selected fixes, and re-validate.

> **Full details:** See [execute-updates.md](./update-notebook/execute-updates.md)

**Summary of operations:**

1. **Interactive Menu (Step 7)** - Present numbered list of recommended fixes: figure renumbering, TOC update, adjacency fixes, missing descriptions, data reference fixes, or "verify all" option.

2. **Execute Updates (Step 8)** - Fix figure numbering (reverse-order replacement to avoid collisions), update TOC cell content, move description cells adjacent to image cells.

3. **Post-Update Validation (Step 9)** - Re-run all validation checks to confirm issues are resolved.

### Steps 10-11: Save and Summary

Create backup, save notebook, and generate change summary.

> **Full details:** See [save-and-reference.md](./update-notebook/save-and-reference.md)

**Summary:**

1. **Save (Step 10)** - Create timestamped backup, then write updated notebook JSON.

2. **Summary (Step 11)** - Report all changes made (renumbering, TOC, adjacency, data fixes), validation results, and next steps (review, re-run cells, commit, remove backup).

---

## Quick Reference

### Token Efficiency Tips

1. Use `jq` to extract structure without reading full notebook:
   ```bash
   jq -r '.cells[] | select(.cell_type=="markdown") | .source | join("")' notebook.ipynb | grep "^#"
   ```
2. Extract only needed information (figure refs, image displays) via `jq` + `grep`
3. Use Python only for complex updates
4. Batch all issues before prompting user

> **More tips and examples:** See [save-and-reference.md](./update-notebook/save-and-reference.md)

### Safety Features

1. Always creates backup before modifying
2. Validates after changes to ensure nothing broke
3. Interactive approval for major changes
4. Preserves notebook metadata and execution counts
5. Detailed change log of what was modified

### When to Use

- After adding/removing figures from analysis
- After changing data sources or sample sizes
- Before submitting notebook for review/publication
- When reorganizing notebook structure
- After renumbering figures in external scripts
- Before creating a final analysis report
