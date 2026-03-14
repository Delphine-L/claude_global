# Quality Assurance and Best Practices

Supporting reference for the **project-sharing** skill. See [SKILL.md](SKILL.md) for the main skill document.

---

## Quality Assurance for Sharing Packages

After creating a sharing package, verify completeness:

### 1. Structure Verification

```bash
# Check directory structure
find package/ -type d | sort

# Expected structure:
# package/
# ├── notebooks/
# ├── scripts/
# ├── data/
# ├── figures/
# └── documentation/
```

### 2. File Count Verification

```bash
# Count files by type
echo "Notebooks: $(find package/ -name '*.ipynb' | wc -l)"
echo "Scripts: $(find package/ -name '*.py' | wc -l)"
echo "Data files: $(find package/ -name '*.csv' | wc -l)"
echo "Figures: $(find package/ -name '*.png' | wc -l)"
echo "Documentation: $(find package/ -name '*.md' | wc -l)"
```

### 3. Path Verification

Test that notebook paths work:
```bash
cd package/notebooks/
# Try to convert notebooks (tests paths)
for nb in *.ipynb; do
    jupyter nbconvert --to html "$nb" --output /tmp/test.html 2>&1 | \
        grep -E "(Error|FileNotFound)" && echo "ERROR in $nb" || echo "OK: $nb"
done
```

### 4. Documentation Checklist

Verify documentation is complete:
- [ ] README.md with setup instructions
- [ ] MANIFEST.md listing all files
- [ ] Environment specification (environment.txt or .yml)
- [ ] License file (if applicable)
- [ ] Citation information
- [ ] Data source documentation

### 5. Create Verification Notes

Document package status:
```markdown
# VERIFICATION_NOTES.md

## Package Contents
- Notebooks: X files
- Scripts: Y files
- Data: Z MB
- Figures: N/M present

## Known Limitations
- Missing figures can be generated using scripts X, Y, Z
- Platform-specific environment file

## Testing
- [ ] Notebooks load correctly
- [ ] Paths work from notebooks/
- [ ] HTML conversion successful
- [ ] All essential files present
```

### 6. Size Check

```bash
# Check package size
du -sh package/

# Ideal sizes:
# Level 1 (Summary): <5 MB
# Level 2 (Reproducible): 5-50 MB
# Level 3 (Full): varies
```

---

## Best Practices

### Notebook Cleaning

**Before sharing notebooks:**

1. **Clear all outputs**
   ```bash
   jupyter nbconvert --clear-output --inplace notebook.ipynb
   ```

2. **Remove debug cells**
   - Tag cells for removal: Cell > Cell Tags > add "remove"
   - Filter during copy

3. **Add markdown explanations**
   - Ensure each code cell has context
   - Add section headers
   - Document assumptions

4. **Check cell execution order**
   - Run "Restart & Run All" to verify
   - Fix any out-of-order dependencies

5. **Remove absolute paths**
   ```python
   # Bad
   data = pd.read_csv('/Users/yourname/project/data.csv')

   # Good
   data = pd.read_csv('../data/data.csv')
   # or
   from pathlib import Path
   data_dir = Path(__file__).parent / 'data'
   ```

### File Organization

**Naming conventions for shared files:**
- Use descriptive names: `telomere_analysis_results.csv` not `results.csv`
- Include dates for time-sensitive data: `data_2024-01-15.csv`
- Version if applicable: `analysis_v2.ipynb`
- No spaces: use `-` or `_`

**Size considerations:**
- Document large files in README
- Consider hosting large data separately (institutional storage, Zenodo)
- Provide download links instead of including in package
- Use `.gitattributes` for large file tracking if using Git

### Documentation Requirements

**Minimum documentation for each level:**

**Level 1 - Summary:**
- What the results show
- Key findings
- Date and author

**Level 2 - Reproducible:**
- Setup instructions
- How to run the analysis
- Software dependencies
- Expected runtime
- Data source information

**Level 3 - Full:**
- Complete methodology
- All data sources with versions
- Processing decisions and rationale
- Known issues or limitations
- Contact information

### Dependency Management

**Create requirements file:**

**For pip:**
```bash
# From active environment
pip freeze > requirements.txt

# Or manually curated (better)
cat > requirements.txt << EOF
pandas>=1.5.0
numpy>=1.23.0
matplotlib>=3.6.0
scipy>=1.9.0
EOF
```

**For conda:**
```bash
# Export current environment
conda env export > environment.yml

# Or minimal (recommended)
conda env export --from-history > environment.yml

# Then edit to remove build-specific details
```

---

## Quality Checklist

Before finalizing the sharing package:

### File Quality
- [ ] All notebooks run without errors
- [ ] Notebook outputs cleared
- [ ] No absolute paths in code
- [ ] No hardcoded credentials or API keys
- [ ] File sizes documented
- [ ] Large files compressed or linked

### Documentation
- [ ] README explains setup and usage
- [ ] MANIFEST describes all files
- [ ] Data sources documented
- [ ] Dependencies specified
- [ ] Contact information included
- [ ] License specified (if applicable)

### Reproducibility
- [ ] Requirements file tested in clean environment
- [ ] All data accessible (included or linked)
- [ ] Scripts run in documented order
- [ ] Expected outputs match actual outputs
- [ ] Processing time documented

### Privacy & Sensitivity
- [ ] No sensitive data included
- [ ] Identifiers anonymized if needed
- [ ] Institutional policies checked
- [ ] Collaborator permissions obtained

### Organization
- [ ] Clear directory structure
- [ ] Consistent naming conventions
- [ ] Files logically grouped
- [ ] No duplicate files
- [ ] No unnecessary files (cache, .DS_Store, etc.)

### Verify Data File References After Consolidation

After consolidating or moving data files, verify all code references:

**1. Find all data loading statements**:
```python
import re

# Search for read_csv patterns
csv_reads = re.findall(r'read_csv\([\'"]([^\'"]+)[\'"]', content)

# Check against valid files
VALID_FILES = {
    'data/vgp_assemblies_unified_corrected.csv',
    'data/vgp_assemblies_3categories.csv',
}

for csv_file in csv_reads:
    if 'vgp_assemblies' in csv_file and csv_file not in VALID_FILES:
        print(f"DEPRECATED: {csv_file}")
```

**2. Check notebooks and scripts**:
```bash
# Find all notebooks
find . -name "*.ipynb" -type f

# Find all Python scripts
find scripts -name "*.py" -type f

# Search for deprecated file patterns
grep -r "vgp_assemblies_unified\.csv" *.ipynb scripts/*.py
```

**3. Create verification report**:
- List each notebook/script
- Show which file(s) it loads
- Mark as CORRECT or DEPRECATED
- Document expected files vs. actual

**4. Update deprecated references**:
- Data processing scripts: Update to check deprecated/ folder
- Analysis notebooks: Update to use consolidated files
- Add comments noting file deprecation
