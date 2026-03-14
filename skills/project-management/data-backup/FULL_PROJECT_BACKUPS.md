# Full Project Backups (vs Data-Only)

## Problem

Data-only backups (single CSV file) don't capture the complete project state. But backing up EVERYTHING creates bloated backups with old/irrelevant files.

## Solution: Selective Full Project Backup

**What to Include:**
- Main analysis notebook (e.g., `Analysis.ipynb`)
- Primary data file (e.g., `data.csv`)
- **Current** figure generation scripts only (e.g., `python_scripts/`)
- **Current** figures only (e.g., `figures/*.png` - root level)
- Active documentation (`.md` files, excluding backups)
- Utility scripts (`.sh` files)

**What to Exclude:**
- Backup notebooks (`*backup*.ipynb`, `*Copy*.ipynb`)
- Exploratory scripts in `scripts/` (only keep figure generators)
- Old figure versions (only current in `figures/`)
- Jupyter checkpoints (`.ipynb_checkpoints/`)
- Python cache (`__pycache__/`, `*.pyc`)

## Implementation Pattern

**Bash script with rsync + selective copy:**
```bash
# Copy specific directory with exclusions
if [ -d "python_scripts" ]; then
    rsync -a --exclude='__pycache__' --exclude='*.pyc' \
        "python_scripts/" "${BACKUP_DIR}/python_scripts/"
fi

# Copy only current figures (root level PNG files)
if [ -d "figures" ]; then
    if ls figures/*.png 1> /dev/null 2>&1; then
        cp figures/*.png "${BACKUP_DIR}/figures/"
    fi
fi

# Copy docs, excluding backups
shopt -s nullglob
for file in *.md *.sh; do
    if [[ ! "$file" =~ (backup|BACKUP|Copy) ]]; then
        cp "$file" "${BACKUP_DIR}/"
    fi
done
shopt -u nullglob
```

**Archive with tar:**
```bash
# Daily: uncompressed (fast restore)
tar -cf "backup_${DATE}.tar" "${PROJECT_NAME}/"

# Milestone: compressed (space efficient)
tar -czf "milestone_${DATE}_${NAME}.tar.gz" "${PROJECT_NAME}/"
```

## Backup Strategy

| Type | Format | Retention | Purpose |
|------|--------|-----------|---------|
| **Daily** | `.tar` (uncompressed) | 7 days | Quick recovery from recent mistakes |
| **Milestone** | `.tar.gz` (compressed) | Forever | Preserve major versions |

## Size Comparison

**Real project example:**
- Data-only backup: 211 KB (compressed CSV)
- Full project backup: 17 MB (notebook + data + scripts + 43 figures + docs)
- 7-day daily backups: ~120 MB total

## When This Matters

- Projects with evolving analyses where both code and data change
- Jupyter notebook workflows with generated figures
- Research projects needing reproducibility (code + data + outputs)

## Path Verification for Backups

**Before creating milestone backups**, verify that files use relative paths.

**Why this matters:**
- Backups may be restored to different locations
- Notebooks shared from backups must work for others
- Absolute paths break when directory structure changes

**For complete path verification procedures and automated checking scripts, see the `folder-organization` skill.**

**Quick check:**
```bash
# Check for absolute paths in notebooks
grep -l "/Users/" *.ipynb
grep -l "C:\\\\" *.ipynb

# Check in Python scripts
grep -l "/Users/" python_scripts/*.py
```

**What to look for:**
- `/Users/yourname/project/data.csv` (absolute) -- avoid
- `data/data.csv` (relative) -- preferred
- `Image('/Users/you/figures/fig.png')` (absolute) -- avoid
- `Image('figures/fig.png')` (relative) -- preferred

**Best practice:**
1. Run path check before milestone backups (see folder-organization skill)
2. Fix any absolute paths found
3. Test notebook runs from backup directory
4. Then create milestone backup
