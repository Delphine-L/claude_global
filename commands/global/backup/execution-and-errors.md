# Backup Execution, Output, and Error Handling

Reference file for the `/backup` command. Covers execute mode details, expected output format, error handling, and integrations.

## Execute Mode (Backup System Exists)

If backup script exists, execute the requested backup operation.

### Parse Command Arguments

```bash
# Determine operation from user input
OPERATION="${1:-daily}"  # Default to daily
DESCRIPTION="$2"         # For milestone backups
```

### Execute Backup

**Daily backup (no arguments or "daily"):**
```bash
echo "💾 Running daily backup..."
./backup_project.sh daily
```

**Milestone backup:**
```bash
echo "💾 Creating milestone backup..."
./backup_project.sh milestone "$DESCRIPTION"
```

**List backups:**
```bash
./backup_project.sh list
```

**Restore backup:**
```bash
./backup_project.sh restore "$DATE"
```

### Output Format

Show clear, informative output:
```
🔍 Detected: 3 notebooks, 2 data files

🧹 Pre-backup cleanup:
  ✓ Cleared outputs from 3 notebooks
  ✓ Removed 5 debug cells
  ✓ Cleaned Python artifacts

💾 Creating backup:
  → backups/daily/backup_2026-01-24/
    ├── notebooks/ (3 files, cleaned)
    ├── data/ (2 files)
    └── requirements.txt

✓ Backup complete: 2026-01-24
✓ Old backups cleaned (>7 days)
✓ CHANGELOG updated
```

---

## Error Handling

### No backup script AND no files to backup
```
⚠️  No files detected to backup.

Looked for:
  - Jupyter notebooks (*.ipynb)
  - Data files (*.csv, *.tsv)
  - Markdown files (*.md)

Add files to this directory or run /backup in a different project.
```

### Backup script execution fails
```
❌ Backup failed!

Error: [error message]

Troubleshooting:
  1. Check backup_project.sh exists and is executable
  2. Ensure backup directory is writable
  3. Check disk space: df -h
  4. Review backups/CHANGELOG.md for recent changes

Need help? Check the data-backup skill documentation.
```

---

## Integration with `/safe-exit` Command

After creating the backup system, inform the user:
```
💡 Tip: The /safe-exit command will now prompt you to backup before ending sessions!

To skip backup prompt at exit, use: /safe-exit --no-backup
```

---

## Token Efficiency

- Use `ls` and `wc` instead of reading files to count
- Only show relevant output, not full script execution
- Summarize results clearly and concisely
- Don't display the entire backup script unless requested
