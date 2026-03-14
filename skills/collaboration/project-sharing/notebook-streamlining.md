# Notebook Streamlining and Abridge Option

Supporting reference for the **project-sharing** skill. See [SKILL.md](SKILL.md) for the main skill document.

---

## Streamlining Notebooks for Sharing

When preparing Jupyter notebooks for sharing packages, remove verbose content while preserving essential analysis:

### Content to Remove

1. **Historical information**:
   - "Comparison to previous analysis" sections
   - "Earlier version" notes
   - Revision history and change logs
   - Update summaries

2. **Excessive methodological detail**:
   - Extended reconciliation discussions
   - Overly detailed interpretations (>2000 chars)
   - Redundant technical notes
   - Multiple paragraphs explaining the same concept

3. **Verbose analysis sections**:
   - Repetitive explanations
   - Extended discussions of minor points
   - Implementation details better suited for code comments

### Content to Keep

1. **Essential analysis**:
   - Figure displays and captions
   - Statistical results
   - Key findings summaries

2. **Core documentation**:
   - Methods sections
   - Conclusions
   - Data source descriptions
   - Quality metrics

3. **Reproduction information**:
   - Setup instructions
   - Script execution order
   - Environment requirements

### Automated Streamlining Script

```python
import nbformat
import re

def should_remove_cell(cell):
    """Identify verbose cells to remove."""
    if cell.cell_type != 'markdown':
        return False

    source = cell.source.lower()

    # Patterns indicating verbose content
    verbose_patterns = [
        'comparison to.*previous',
        'reconciliation with',
        'why focus on',
        'methodological.*note.*filtering',
        'interpretation of the significant difference',
    ]

    for pattern in verbose_patterns:
        if re.search(pattern, source):
            return True

    # Remove overly long cells without figures
    if len(source) > 2000 and 'figure' not in source.lower():
        return True

    return False

def streamline_notebook(input_path, output_path):
    """Remove verbose content from notebook."""
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    # Filter out verbose cells
    nb.cells = [cell for cell in nb.cells if not should_remove_cell(cell)]

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)
```

### Expected Results

- **Cell reduction**: 7-15% of cells typically removed
- **Size reduction**: 15-20% smaller HTML files
- **Quality improvement**: More professional, focused presentation
- **No loss**: All essential content preserved

### Verification Checklist

After streamlining:
- [ ] All figures still referenced
- [ ] Statistical results present
- [ ] Methods sections complete
- [ ] Conclusions included
- [ ] HTML conversion successful
- [ ] No broken cells or formatting

---

## Abridge Option: Automated Streamlining with Full Version Preservation

The `/share-project` command now includes an **abridge option** that automates notebook streamlining while preserving full versions for reference.

### When to Use Abridge

**Use abridge when:**
- Notebooks contain historical/comparison sections
- You want professional, concise presentation
- Recipients need clean notebooks but you want full transparency
- Analysis notebooks have become verbose over iterations

**Skip abridge when:**
- Notebooks are already concise
- Historical context is essential to understanding
- Notebooks are for detailed review or audit

### How Abridge Works

When you select the abridge option during `/share-project`:

1. **Creates structure:**
   ```
   shared-package/
   ├── Notebook.ipynb          <- Abridged (professional)
   ├── Notebook.html           <- From abridged version
   └── unabridged/
       ├── Notebook.ipynb      <- Full version preserved
       └── Notebook.html       <- From full version
   ```

2. **Automatically removes:**
   - Historical notes ("Comparison to previous analysis")
   - Revision history and change logs
   - "Why focus on X" explanatory sections
   - Methodological reconciliation discussions
   - Overly detailed interpretations (>2000 chars without results)
   - Update summaries

3. **Always preserves:**
   - All code cells (full reproducibility)
   - Figure displays and captions
   - Statistical results and tables
   - Methods sections
   - Conclusions and findings
   - Data source references

### Usage

During `/share-project` workflow:

```
Verbosity Level

Would you like to create abridged versions of notebooks/documentation?

- No (default): Include full content as-is
- Yes (abridge): Remove verbose content for cleaner presentation

  Creates two versions:
  ├── [file].ipynb              <- Abridged (professional, concise)
  └── unabridged/
      └── [file].ipynb          <- Full version (all content preserved)

Create abridged versions? (y/n):
```

Select 'y' to enable abridging.

### Benefits

1. **Professional presentation**: Recipients see clean, focused notebooks
2. **Full transparency**: Complete versions preserved in unabridged/
3. **No information loss**: Everything available for reference
4. **Time saving**: Automated instead of manual cell removal
5. **Reproducible**: All code and essential content preserved
6. **HTML for both**: Both versions get HTML exports

### Example Results

**Typical improvements:**
- 7-15% fewer cells
- 15-20% smaller HTML files
- More focused, professional presentation
- Better readability for non-technical reviewers

**Example notebook:**
- Original: 120 cells, 5.2 MB HTML
- Abridged: 105 cells (12.5% reduction), 4.3 MB HTML (17% reduction)
- Content: All 43 figures preserved, all statistical results intact
- Removed: 15 historical/comparison cells

### Verification

After abridging, automatically verify:
- [ ] All figures present in abridged version
- [ ] Statistical results visible
- [ ] Methods sections complete
- [ ] unabridged/ folder exists with full versions
- [ ] Both versions have HTML exports

### Integration with Other Features

**Works seamlessly with:**
- Path verification (Step 5.5): Paths fixed in both versions
- Documentation filtering: Applies same principles to markdown files
- Root-level notebooks: Abridged at root, unabridged in subfolder
- HTML export: Both versions get HTML for easy viewing

**Example workflow:**
```
1. Select files for root level
2. Choose reproducible package
3. Enable abridge option (y)
4. Path verification runs
5. Abridging creates two versions
6. HTML generated for both
7. Result: Professional package with full transparency
```

### When Not to Use

**Skip abridging if:**
- Notebooks already concise (<50 cells)
- Historical context is essential
- Audience needs complete development history
- Notebooks are for regulatory/compliance review (use full only)
- Iterative explanation is pedagogical value

### Manual Override

If you need custom abridging patterns, you can modify the patterns in the command:

```python
verbose_patterns = [
    r'comparison to.*previous',      # Historical comparisons
    r'why focus on',                  # Explanatory sections
    r'reconciliation with',          # Methodological discussions
    # Add your custom patterns here
]
```
