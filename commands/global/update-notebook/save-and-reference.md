# Save, Summary, and Reference

Supporting file for the `update-notebook` command. Contains Steps 10-11: saving the notebook, generating a summary, plus token efficiency tips, example usage, safety features, and usage guidance.

## Step 10: Save Updated Notebook

Create backup and save:

```python
from datetime import datetime

# Create backup
backup_path = f"{notebook_path}.backup-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
import shutil
shutil.copy(notebook_path, backup_path)
print(f"Backup created: {backup_path}")

# Save updated notebook
with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=1)

print(f"Notebook updated: {notebook_path}")
```

## Step 11: Generate Update Summary

```markdown
## Update Complete!

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
- All figure references: Valid
- All data references: Valid
- Table of Contents: Up to date

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
# Notebook updated successfully!
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
