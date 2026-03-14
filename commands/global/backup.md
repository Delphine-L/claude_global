---
name: backup
description: Smart backup system with skill integration. Setup on first run, then daily/milestone backups with intelligent cleanup.
disable-model-invocation: true
---

Set up or execute smart project backups with intelligent file-type detection and skill integration.

**Supporting files** (read as needed):
- `commands/global/backup/backup-script-template.md` - Full backup_project.sh script template
- `commands/global/backup/setup-and-documentation.md` - README creation and setup confirmation
- `commands/global/backup/execution-and-errors.md` - Execute mode, output format, error handling

## Your Task

### Step 1: Check if in Git Repository

```bash
# Check if in git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "⚠️  Git repository detected!"
  echo ""
  echo "This project is under version control with git."
  echo "The /backup command is designed for projects without version control."
  echo ""
  echo "For git repositories, use:"
  echo "  • git commit - Save your work"
  echo "  • git push - Backup to remote"
  echo "  • git branch - Create experimental branches"
  echo "  • git tag - Mark milestones"
  echo ""
  echo "Backup system not needed in git repositories."
  exit 0
fi
```

### Step 2: Check if Backup System Exists

```bash
# Check for backup script
if [ -f "backup_project.sh" ] || [ -f "backup_table.sh" ]; then
  MODE="execute"
else
  MODE="setup"
fi
```

---

## Setup Mode (First Run)

If no backup script exists, set up the system:

### 1. Detect Project Type

**Scan for file types:**
```bash
# Count different file types
NOTEBOOKS=$(ls *.ipynb 2>/dev/null | wc -l | xargs)
DATA_FILES=$(ls *.csv *.tsv 2>/dev/null | wc -l | xargs)
MARKDOWN=$(grep -l "^---" *.md 2>/dev/null | wc -l | xargs)
PYTHON_PROJECT=$([ -f "requirements.txt" ] || [ -f "environment.yml" ] && echo "yes" || echo "no")
```

**Determine project type:**
- If `NOTEBOOKS > 0 && DATA_FILES > 0`: Mixed (notebooks + data)
- If `NOTEBOOKS > 0`: Notebook project
- If `DATA_FILES > 0`: Data project
- If `MARKDOWN > 0`: Documentation project
- Otherwise: Generic project

### 2. Present Detection Results

```
🔍 Project Detection Results:

Detected files:
  • X Jupyter notebooks (*.ipynb)
  • Y data files (*.csv, *.tsv)
  • Z markdown files (*.md)
  • Python project: yes/no

Project type: [Mixed/Notebook/Data/Documentation/Generic]

Smart cleanup will use:
  ✓ jupyter-notebook skill (clear outputs, remove debug cells)
  ✓ hackmd skill (validate SVG, check formatting)
  ✓ managing-environments skill (clean Python artifacts)
  ✓ Data validation (check file integrity)
```

### 3. Ask User for Configuration

```
Backup configuration:

1. Backup directory location: [backups/]
2. Daily backup retention (days): [7]
3. Include Python environment files (requirements.txt, environment.yml)? [yes]
4. Set up automated daily backups? [no]

Confirm settings? (yes/no)
```

### 4. Create Backup Script

Generate `backup_project.sh` based on project type. See **backup-script-template.md** for the full script template including:
- Notebook cleaning (clear outputs, remove debug cells)
- Python artifact cleanup
- Daily backup with rolling retention
- Milestone backup with compression
- Backup listing and restore functions

After creating the script, run `chmod +x backup_project.sh`.

### 5. Create Documentation and Confirm

See **setup-and-documentation.md** for:
- `backups/README.md` template
- Setup confirmation message format

---

## Execute Mode (Backup System Exists)

If backup script already exists, execute the requested operation. See **execution-and-errors.md** for:
- Command argument parsing
- Running daily, milestone, list, and restore operations
- Expected output format
- Error handling and troubleshooting
- Integration with `/safe-exit`

---

## Related Commands

- `/safe-exit` - End session with optional backup prompt
- `/list-skills` - See all available skills including data-backup
- `/cleanup-project` - Clean working directory before backup
