# Advanced Usage

## Custom Backup Script Template

The backup script can be customized for different file types or naming conventions:

```bash
#!/bin/bash
# Backup script for PROJECT_NAME

MAIN_TABLE="your_data_file.csv"
DAILY_DIR="backups/daily"
MILESTONE_DIR="backups/milestones"
CHANGELOG="backups/CHANGELOG.md"
DAYS_TO_KEEP=7
```

## Viewing Compressed Milestones

```bash
# View without decompressing
gunzip -c milestone_file.csv.gz | less

# Decompress permanently
gunzip milestone_file.csv.gz
```

## Multiple File Backups

For projects with multiple related data files, create separate backup scripts or modify the script to handle multiple files:

```bash
# Create separate backups
./backup_main_table.sh
./backup_metadata.sh

# Or modify script to backup multiple files
for file in *.csv; do
    cp "$file" "backups/daily/backup_${DATE}_$(basename $file)"
done
```

## Token Efficiency

This backup system is token-efficient because:
- No need to read large files just to create backups (uses `cp`)
- Automated logging reduces manual documentation
- Quick restore prevents wasted time re-implementing lost work
- CHANGELOG serves as lightweight documentation

## Real-World Example

**VGP Phase 1 Enrichment Project:**
- Main file: 716 assemblies, 127 columns, ~770KB
- Daily backups: 7 files = ~5.4 MB
- Milestones: 3 compressed files = ~600KB
- Total: ~6 MB for complete project history
- Tracked: 2 weeks of data enrichment, 5 major milestones
- Prevented: Multiple accidental overwrites during NCBI searches
