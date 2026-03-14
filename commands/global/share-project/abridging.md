# Abridging Notebooks (Step 5.6)

**ONLY execute this step if `ABRIDGE_MODE=true`** (user selected 'yes' in Step 2)

This step creates professional, concise versions of notebooks and documentation by removing verbose content while preserving the full versions for reference.

```python
import json
import os
import shutil
import re

if ABRIDGE_MODE:
    print("\nCreating abridged versions...")

    # Create unabridged folder to store full versions
    UNABRIDGED_DIR = f"{SHARE_DIR}/unabridged"
    os.makedirs(UNABRIDGED_DIR, exist_ok=True)
    print(f"Created: {UNABRIDGED_DIR}/")

    # Process each notebook
    notebooks = []
    for root, dirs, files in os.walk(SHARE_DIR):
        # Skip unabridged folder itself
        if 'unabridged' in root:
            continue
        for file in files:
            if file.endswith('.ipynb'):
                notebooks.append(os.path.join(root, file))

    print(f"\nProcessing {len(notebooks)} notebooks...")

    for notebook_path in notebooks:
        notebook_name = os.path.basename(notebook_path)
        print(f"\n{notebook_name}")

        # Read notebook
        with open(notebook_path, 'r') as f:
            nb = json.load(f)

        # Patterns to identify verbose cells
        def should_remove_cell(cell):
            """Identify verbose cells to remove for abridged version."""
            if cell['cell_type'] != 'markdown':
                return False

            source = ''.join(cell['source']).lower()

            # Patterns indicating verbose historical/comparison content
            verbose_patterns = [
                r'comparison to.*previous',
                r'earlier version',
                r'historical.*note',
                r'why focus on',
                r'reconciliation with',
                r'methodological.*note.*filtering',
                r'interpretation of the significant difference',
                r'update.*summary',
                r'revision.*history',
                r'changes.*from.*version',
                r'previously.*we',
            ]

            for pattern in verbose_patterns:
                if re.search(pattern, source, re.IGNORECASE):
                    return True

            # Remove overly long cells without figures/results
            has_content_markers = any(marker in source for marker in [
                'figure', '![', '<img', 'result', 'table',
                '```', 'statistical', 'p-value', 'p <', 'p=', 'correlation'
            ])

            if len(source) > 2000 and not has_content_markers:
                return True

            return False

        # Count cells before filtering
        original_cell_count = len(nb['cells'])

        # Filter out verbose cells
        nb_abridged = nb.copy()
        nb_abridged['cells'] = [cell for cell in nb['cells']
                                if not should_remove_cell(cell)]

        cells_removed = original_cell_count - len(nb_abridged['cells'])

        if cells_removed > 0:
            # Move original to unabridged/
            rel_path = os.path.relpath(notebook_path, SHARE_DIR)
            unabridged_path = os.path.join(UNABRIDGED_DIR, notebook_name)

            # Move original notebook to unabridged/
            shutil.move(notebook_path, unabridged_path)
            print(f"  Moved full version to: unabridged/{notebook_name}")

            # Write abridged version to original location
            with open(notebook_path, 'w') as f:
                json.dump(nb_abridged, f, indent=1)

            print(f"  Removed {cells_removed} verbose cells ({cells_removed/original_cell_count*100:.1f}%)")
            print(f"  Created abridged version: {notebook_name}")

            # Regenerate HTML for abridged version if possible
            try:
                import subprocess
                html_path = notebook_path.replace('.ipynb', '.html')
                subprocess.run([
                    "jupyter", "nbconvert",
                    "--to", "html",
                    notebook_path,
                    "--output", html_path
                ], check=True, capture_output=True)
                print(f"  Updated HTML version")

                # Create HTML for unabridged version too
                unabridged_html = unabridged_path.replace('.ipynb', '.html')
                subprocess.run([
                    "jupyter", "nbconvert",
                    "--to", "html",
                    unabridged_path,
                    "--output", unabridged_html
                ], check=True, capture_output=True)
                print(f"  Generated HTML for unabridged version")
            except Exception as e:
                print(f"  HTML generation skipped (optional)")
        else:
            print(f"  No verbose cells found - keeping as-is")

    print("\n" + "="*70)
    print("ABRIDGING COMPLETE")
    print("="*70)
    print(f"\nStructure:")
    print(f"  |- {SHARE_DIR}/")
    print(f"  |  |- [notebooks].ipynb          <- Abridged (professional)")
    print(f"  |  |- [notebooks].html")
    print(f"  |  '- unabridged/")
    print(f"  |      |- [notebooks].ipynb      <- Full versions")
    print(f"  |      '- [notebooks].html")
    print(f"\nRecipients see clean, professional notebooks by default")
    print(f"Full versions available in unabridged/ for reference")
else:
    print("\nAbridging skipped (not requested)")
```

---

## What Gets Removed

- Historical notes ("Comparison to previous analysis")
- Revision history and change logs
- "Why focus on X" explanatory sections
- Methodological reconciliation discussions
- Overly detailed interpretations (>2000 chars without results/figures)
- Update summaries

## What Gets Preserved

- All code cells (analysis remains reproducible)
- Figure displays and captions
- Statistical results and tables
- Methods sections
- Conclusions and findings
- References to data sources

## Benefits

1. **Professional presentation**: Recipients see clean, focused notebooks
2. **Full transparency**: Complete versions preserved in unabridged/
3. **Reduced size**: 15-20% smaller HTML files
4. **Better readability**: 7-15% fewer cells, more focused content
5. **No information loss**: Everything available in unabridged/

## Verification Checklist

After abridging, verify:
- [ ] All figures still present
- [ ] Statistical results visible
- [ ] Methods sections complete
- [ ] Conclusions included
- [ ] HTML conversion successful
- [ ] unabridged/ folder has full versions
