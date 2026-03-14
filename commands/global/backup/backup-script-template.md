# Backup Script Template

Reference file for the `/backup` command. Contains the full `backup_project.sh` script template generated during setup.

## Script Template

Create the script with `cat > backup_project.sh << 'BACKUP_SCRIPT'`:

```bash
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
```

After creating the script, run `chmod +x backup_project.sh`.
