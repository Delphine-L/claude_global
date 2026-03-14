# MANIFEST-Aware Backups

For projects with MANIFEST files, create **intelligent backups** that include only essential files based on project documentation.

## Pattern: Read MANIFEST to Identify Key Files

Instead of backing up everything, read the project MANIFEST to determine what's important:

```bash
# Extract key file patterns from MANIFEST
grep -E "^(#### |### |##)" MANIFEST.md | head -40  # Get structure
grep -E "(\.csv|\.ipynb|\.md)" MANIFEST.md | grep "^\s*-" | head -20  # Get key files
```

## Backup Script Template

Modify your `milestone_backup()` function to read MANIFEST:

```bash
milestone_backup() {
    DESCRIPTION="$1"
    TEMP_DIR=$(mktemp -d)
    BACKUP_ROOT="$TEMP_DIR/Project_${DATE}"
    mkdir -p "$BACKUP_ROOT"

    echo "📦 Backing up key files from MANIFEST..."

    # 1. Active notebooks (exclude deprecated based on MANIFEST)
    # Look for files marked "PRIMARY" or "ACTIVE" in MANIFEST
    for nb in Primary_Analysis.ipynb Supporting_Analysis.ipynb; do
        if [ -f "$nb" ]; then
            cp "$nb" "$BACKUP_ROOT/" 2>/dev/null || true
        fi
    done

    # 2. Key data files (from MANIFEST "Key files" section)
    mkdir -p "$BACKUP_ROOT/data"
    cp data/main_dataset_corrected.csv "$BACKUP_ROOT/data/" 2>/dev/null || true
    cp data/MIGRATION_GUIDE.md "$BACKUP_ROOT/data/" 2>/dev/null || true

    # 3. Analysis files (from MANIFEST entry points)
    if [ -d "analysis_files" ]; then
        cp -r analysis_files "$BACKUP_ROOT/" 2>/dev/null || true
    fi

    # 4. Scripts (selective - main scripts only)
    mkdir -p "$BACKUP_ROOT/scripts"
    cp scripts/*.py "$BACKUP_ROOT/scripts/" 2>/dev/null || true

    # 5. Figures (manuscript only, not exploratory)
    if [ -d "figures/manuscript" ]; then
        mkdir -p "$BACKUP_ROOT/figures"
        cp -r figures/manuscript "$BACKUP_ROOT/figures/" 2>/dev/null || true
    fi

    # 6. MANIFESTs and documentation
    for doc in MANIFEST.md README.md *.md; do
        if [ -f "$doc" ]; then
            cp "$doc" "$BACKUP_ROOT/" 2>/dev/null || true
        fi
    done

    # Compress
    echo "🗜️  Compressing..."
    tar -czf "$MILESTONE_FILE" -C "$TEMP_DIR" "$(basename "$BACKUP_ROOT")"
    rm -rf "$TEMP_DIR"
}
```

## What to Include (from MANIFEST)

**Include:**
- Files marked as "PRIMARY" or "ACTIVE"
- Entry point notebooks/files
- Key data files explicitly mentioned
- Manuscript-ready figures
- Documentation (MANIFEST, README, guides)
- Analysis summaries and statistics
- Scripts that generate key outputs

**Exclude:**
- Files marked "DEPRECATED"
- Large data caches (unless marked critical)
- Temporary processing files
- Build artifacts
- Files in `deprecated/` directories
- Exploratory/draft figures
- Python cache (`__pycache__`, `.pyc`)

## Benefits

1. **Smaller backups**: 18 MB -> 11 MB compressed (vs. 50+ MB if backing up everything)
2. **Focused recovery**: Only important files included
3. **Manuscript-ready**: Backup contains publication-relevant files
4. **Documented selection**: MANIFEST shows what was chosen and why
5. **Faster backup/restore**: Less to compress and transfer

## Example Output

```
📦 Backing up key files from MANIFEST...
  → Notebooks (5 active)...
  → Key data files...
  → Analysis files...
  → Scripts...
  → Figures (manuscript)...
  → Documentation...

📊 Backup size (uncompressed):  18M
🗜️  Compressing...
  ✓ Compressed to:  11M

✅ Milestone backup created
```

## Cache Preservation Documentation

If MANIFEST identifies caches that should NOT be backed up but also NOT deleted:

```markdown
## GenomeScope QC Data Cache

**Purpose**: Cached QC data from AWS S3
**Status**: Active cache - DO NOT DELETE
**Backup**: Not included in backups (easily regenerated from S3)
```

Document these clearly in backup README to prevent accidental deletion during cleanup.

## Integration with /backup Command

When implementing `/backup` command, add MANIFEST detection:

1. **Check for MANIFEST file**: `if [ -f "MANIFEST.md" ]; then ...`
2. **Use MANIFEST-aware backup function** for milestone backups
3. **Show what was included** based on MANIFEST categories
4. **Update backup README** with MANIFEST reference
