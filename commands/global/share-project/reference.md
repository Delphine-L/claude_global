# Reference: Best Practices, Troubleshooting, and MANIFEST Integration

## Best Practices

### Before Creating Package

1. **Run full analysis** to ensure everything works
2. **Clear notebook outputs** (done automatically)
3. **Check for sensitive data** (passwords, API keys, personal info)
4. **Verify environment file** is up-to-date
5. **Test on a colleague** if possible

### What to Exclude

Never include:
- `.env` files or API keys
- Large raw data files (>1GB) without asking
- `__pycache__/` directories (excluded automatically)
- `.ipynb_checkpoints/` (excluded automatically)
- Personal notes or drafts
- Intermediate debug files

### Documentation Tips

Good README includes:
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

## MANIFEST Integration Benefits

When MANIFEST files exist in your project, the command provides intelligent assistance:

**Automatic File Identification:**
- **Main files** - Identifies primary analysis notebooks/scripts marked in MANIFEST
- **Active files** - All non-deprecated, currently-used files
- **Deprecated files** - Files marked with `**[DEPRECATED]**` are auto-excluded

**Smart Suggestions:**
- Shows main files with their purposes from MANIFEST metadata
- Offers quick selection: type 'main' to select all primary files
- Displays file context (purpose, role) to help selection

**Enhanced Safety:**
- Automatically excludes MANIFEST-identified deprecated files
- Ensures only active, current files are shared
- Prevents accidental sharing of outdated analysis

**Example Output with MANIFEST:**
```
Found 2 MANIFEST file(s)
  Reading: ./MANIFEST.md
  Reading: figures/MANIFEST.md

MANIFEST Analysis:
  Main files: 2
  Active files: 15
  Deprecated files: 3

Main/Primary Files Identified:
  - Curation_Impact_Analysis.ipynb
    Purpose: Main analysis comparing curated vs uncurated assemblies
  - Figure_Generation.ipynb
    Purpose: Generate all publication figures

Tip: Main files are good candidates for the sharing package root

Which files should go at the root of the sharing package?

Options:
  - Enter numbers from list above (e.g., '1 2')
  - Enter filenames
  - Type 'main' to select all main files from MANIFEST  <- QUICK SELECT
  - Type 'all' to share entire directory structure

Selection: main
Selected 2 main files:
  - Curation_Impact_Analysis.ipynb
  - Figure_Generation.ipynb
```

**Integration with `/update-manifest`:**
1. Use `/update-manifest` to keep MANIFESTs current before sharing
2. Mark main analysis files appropriately in MANIFEST
3. Mark deprecated files with `**[DEPRECATED]**` tag
4. Use `/share-project` to benefit from this metadata

**Without MANIFEST:**
The command still works perfectly - it just won't have metadata to suggest main files. You'll select files manually from the file list.

---

## Next Steps Guidance (Step 8)

Present to user after package creation:

```
Sharing package ready!

Created: {SHARE_DIR}/
Size: {size}
Files: {count}

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

IMPORTANT: Continue all work in your main project directory,
   not in {SHARE_DIR}. The sharing folder is a snapshot.
```

**Remember:** The sharing folder is a clean snapshot. All work continues in your main project directory.
