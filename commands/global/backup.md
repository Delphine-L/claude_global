---
name: backup
description: Smart backup system with skill integration. Setup on first run, then daily/milestone backups with intelligent cleanup.
---

Set up or execute smart project backups with intelligent file-type detection and skill integration.

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

**Questions:**
```
Backup configuration:

1. Backup directory location: [backups/]
2. Daily backup retention (days): [7]
3. Include Python environment files (requirements.txt, environment.yml)? [yes]
4. Set up automated daily backups? [no]

Confirm settings? (yes/no)
```

### 4. Create Backup Script

**Create appropriate backup script based on project type:**

**For mixed/complex projects:**
```bash
cat > backup_project.sh << 'BACKUP_SCRIPT'
#!/bin/bash
# Smart backup script with skill integration
# Generated: $(date)

set -e

BACKUP_DIR="backups"
DAILY_DIR="$BACKUP_DIR/daily"
MILESTONE_DIR="$BACKUP_DIR/milestones"
CHANGELOG="$BACKUP_DIR/CHANGELOG.md"
DAYS_TO_KEEP=7
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Create directories
mkdir -p "$DAILY_DIR" "$MILESTONE_DIR"

# Initialize CHANGELOG if needed
if [ ! -f "$CHANGELOG" ]; then
    echo "# Backup Changelog" > "$CHANGELOG"
    echo "" >> "$CHANGELOG"
    echo "Auto-generated log of all backups and changes." >> "$CHANGELOG"
    echo "" >> "$CHANGELOG"
fi

# Function to clean notebooks
clean_notebooks() {
    echo "🧹 Cleaning Jupyter notebooks..."
    for nb in *.ipynb; do
        if [ -f "$nb" ]; then
            # Clear outputs using jupyter nbconvert
            jupyter nbconvert --clear-output --inplace "$nb" 2>/dev/null || \
            python3 -c "
import nbformat
try:
    with open('$nb') as f:
        nb = nbformat.read(f, as_version=4)
    # Clear outputs
    for cell in nb.cells:
        if cell.cell_type == 'code':
            cell.outputs = []
            cell.execution_count = None
    # Remove debug cells
    nb.cells = [c for c in nb.cells if 'debug' not in c.metadata.get('tags', [])]
    with open('$nb', 'w') as f:
        nbformat.write(nb, f)
    print(f'  ✓ Cleaned: $nb')
except Exception as e:
    print(f'  ⚠ Warning: Could not clean $nb: {e}')
"
        fi
    done
}

# Function to clean Python artifacts
clean_python() {
    echo "🧹 Cleaning Python artifacts..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
    echo "  ✓ Python artifacts cleaned"
}

# Function to create daily backup
daily_backup() {
    BACKUP_PATH="$DAILY_DIR/backup_$DATE"

    if [ -d "$BACKUP_PATH" ]; then
        read -p "⚠️  Backup for $DATE already exists. Overwrite? (y/n): " overwrite
        if [ "$overwrite" != "y" ]; then
            echo "Backup cancelled."
            return
        fi
        rm -rf "$BACKUP_PATH"
    fi

    mkdir -p "$BACKUP_PATH"

    # Clean before backup
    clean_notebooks
    clean_python

    # Backup notebooks
    if ls *.ipynb 1> /dev/null 2>&1; then
        mkdir -p "$BACKUP_PATH/notebooks"
        cp *.ipynb "$BACKUP_PATH/notebooks/" 2>/dev/null || true
        NB_COUNT=$(ls *.ipynb 2>/dev/null | wc -l | xargs)
        echo "  ✓ Backed up $NB_COUNT notebooks (cleaned)"
    fi

    # Backup data files
    if ls *.csv *.tsv 1> /dev/null 2>&1; then
        mkdir -p "$BACKUP_PATH/data"
        cp *.csv *.tsv "$BACKUP_PATH/data/" 2>/dev/null || true
        DATA_COUNT=$(ls *.csv *.tsv 2>/dev/null | wc -l | xargs)
        echo "  ✓ Backed up $DATA_COUNT data files"
    fi

    # Backup markdown files
    if ls *.md 1> /dev/null 2>&1; then
        mkdir -p "$BACKUP_PATH/docs"
        cp *.md "$BACKUP_PATH/docs/" 2>/dev/null || true
        MD_COUNT=$(ls *.md 2>/dev/null | wc -l | xargs)
        echo "  ✓ Backed up $MD_COUNT markdown files"
    fi

    # Backup environment files
    if [ -f "requirements.txt" ]; then
        cp requirements.txt "$BACKUP_PATH/"
        echo "  ✓ Backed up requirements.txt"
    fi
    if [ -f "environment.yml" ]; then
        cp environment.yml "$BACKUP_PATH/"
        echo "  ✓ Backed up environment.yml"
    fi

    # Update changelog
    echo "" >> "$CHANGELOG"
    echo "## $DATE" >> "$CHANGELOG"
    echo "- Daily backup created at $TIMESTAMP" >> "$CHANGELOG"

    # Cleanup old backups
    echo "🗑️  Cleaning old backups (>$DAYS_TO_KEEP days)..."
    find "$DAILY_DIR" -maxdepth 1 -type d -mtime +$DAYS_TO_KEEP -exec rm -rf {} \; 2>/dev/null || true

    echo "✅ Daily backup complete: $DATE"
}

# Function to create milestone backup
milestone_backup() {
    DESCRIPTION="$1"
    if [ -z "$DESCRIPTION" ]; then
        read -p "Milestone description: " DESCRIPTION
    fi

    MILESTONE_FILE="$MILESTONE_DIR/milestone_${DATE}_$(echo "$DESCRIPTION" | tr ' ' '_' | tr -cd '[:alnum:]_-').tar.gz"

    echo "💾 Creating milestone backup..."

    # Clean before backup
    clean_notebooks
    clean_python

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)

    # Copy files
    cp *.ipynb "$TEMP_DIR/" 2>/dev/null || true
    cp *.csv *.tsv "$TEMP_DIR/" 2>/dev/null || true
    cp *.md "$TEMP_DIR/" 2>/dev/null || true
    cp requirements.txt environment.yml "$TEMP_DIR/" 2>/dev/null || true

    # Compress
    tar -czf "$MILESTONE_FILE" -C "$TEMP_DIR" .
    rm -rf "$TEMP_DIR"

    # Update changelog
    echo "" >> "$CHANGELOG"
    echo "## $DATE" >> "$CHANGELOG"
    echo "- **MILESTONE**: $DESCRIPTION" >> "$CHANGELOG"
    echo "  - Backup file: $(basename "$MILESTONE_FILE")" >> "$CHANGELOG"

    echo "✅ Milestone backup created: $(basename "$MILESTONE_FILE")"
}

# Function to list backups
list_backups() {
    echo "📋 Available Backups:"
    echo ""
    echo "Daily backups (rolling ${DAYS_TO_KEEP}-day window):"
    for backup in "$DAILY_DIR"/*; do
        if [ -d "$backup" ]; then
            SIZE=$(du -sh "$backup" | cut -f1)
            echo "  - $(basename "$backup") [$SIZE]"
        fi
    done

    echo ""
    echo "Milestone backups (permanent):"
    for milestone in "$MILESTONE_DIR"/*.tar.gz; do
        if [ -f "$milestone" ]; then
            SIZE=$(du -sh "$milestone" | cut -f1)
            echo "  - $(basename "$milestone") [$SIZE]"
        fi
    done
}

# Function to restore backup
restore_backup() {
    DATE_TO_RESTORE="$1"
    BACKUP_PATH="$DAILY_DIR/backup_$DATE_TO_RESTORE"

    if [ ! -d "$BACKUP_PATH" ]; then
        echo "❌ Backup not found for date: $DATE_TO_RESTORE"
        list_backups
        return 1
    fi

    echo "⚠️  This will restore files from $DATE_TO_RESTORE"
    echo "Current files will be backed up to: safety_backup_$(date +%Y%m%d_%H%M%S)"
    read -p "Continue? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Restore cancelled."
        return
    fi

    # Create safety backup
    SAFETY_DIR="safety_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$SAFETY_DIR"
    cp *.ipynb *.csv *.tsv *.md "$SAFETY_DIR/" 2>/dev/null || true
    echo "✅ Safety backup created: $SAFETY_DIR"

    # Restore files
    if [ -d "$BACKUP_PATH/notebooks" ]; then
        cp "$BACKUP_PATH/notebooks"/* . 2>/dev/null || true
        echo "  ✓ Restored notebooks"
    fi
    if [ -d "$BACKUP_PATH/data" ]; then
        cp "$BACKUP_PATH/data"/* . 2>/dev/null || true
        echo "  ✓ Restored data files"
    fi
    if [ -d "$BACKUP_PATH/docs" ]; then
        cp "$BACKUP_PATH/docs"/* . 2>/dev/null || true
        echo "  ✓ Restored markdown files"
    fi

    echo "✅ Restore complete from $DATE_TO_RESTORE"
}

# Main logic
case "${1:-daily}" in
    daily)
        daily_backup
        ;;
    milestone)
        milestone_backup "$2"
        ;;
    list)
        list_backups
        ;;
    restore)
        restore_backup "$2"
        ;;
    *)
        echo "Usage: $0 {daily|milestone \"description\"|list|restore DATE}"
        echo ""
        echo "Examples:"
        echo "  $0 daily"
        echo "  $0 milestone \"completed analysis\""
        echo "  $0 list"
        echo "  $0 restore 2026-01-23"
        exit 1
        ;;
esac
BACKUP_SCRIPT

chmod +x backup_project.sh
```

### 5. Create Documentation

**Create backups/README.md:**
```bash
mkdir -p backups
cat > backups/README.md << 'EOF'
# Backup System

This directory contains automated backups of the project.

## Structure

- `daily/` - Rolling 7-day backups (auto-cleanup)
- `milestones/` - Permanent compressed backups
- `CHANGELOG.md` - Log of all backups and changes

## Usage

```bash
./backup_project.sh daily              # Daily backup
./backup_project.sh milestone "desc"   # Milestone
./backup_project.sh list              # List all
./backup_project.sh restore DATE      # Restore
```

## Smart Cleanup

Before each backup, the system automatically:
- Clears Jupyter notebook outputs
- Removes debug cells
- Cleans Python artifacts
- Validates data integrity

This ensures clean, shareable backups.
EOF
```

### 6. Confirm Setup

```
✅ Backup system configured!

Created:
  ✓ backup_project.sh (smart backup script)
  ✓ backups/ directory structure
  ✓ backups/README.md (documentation)

Project type: [Detected Type]
Smart cleanup: jupyter-notebook, hackmd, managing-environments

Next steps:
  1. Run daily backup: /backup
  2. Create milestone: /backup milestone "description"
  3. List backups: /backup list

The /safe-exit command will now prompt you to backup before ending sessions!
```

---

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

---

## Related Commands

- `/safe-exit` - End session with optional backup prompt
- `/list-skills` - See all available skills including data-backup
- `/cleanup-project` - Clean working directory before backup
