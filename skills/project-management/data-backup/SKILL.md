---
name: data-backup
description: Smart automated backup system with skill integration. Detects project type (notebooks, data files, HackMD docs) and applies appropriate cleanup before backup. Rolling daily backups, compressed milestones, and CHANGELOG tracking.
version: 2.0.0
---

# Smart Backup System with Skill Integration

## When to Use This Skill

Use this skill when:
- Working on any project with files that change over time
- Jupyter notebooks, data files (CSV/TSV), HackMD presentations, or mixed projects
- Need intelligent cleanup before backup (clear outputs, remove debug code)
- Want to track what changed when (data provenance)
- Need professional backup workflow for collaboration or publication
- Want context-aware backups that use other skills intelligently

## The Problem

Long-running data enrichment projects risk:
- Losing days of work from accidental overwrites
- Unable to revert to previous data states
- No documentation of what changed when
- Running out of disk space from manual backups
- Confusion about which version is current

## Solution: Smart Two-Tier Backup System with Skill Integration

### Core Features

1. **Intelligent Detection** - Automatically detects project type and files to backup
2. **Skill Integration** - Uses jupyter-notebook, hackmd, and other skills for pre-backup cleanup
3. **Daily backups** - Rolling 7-day window (auto-cleanup)
4. **Milestone backups** - Permanent, compressed (gzip ~80% reduction)
5. **CHANGELOG** - Automatic documentation of all changes
6. **Session Integration** - Prompts for backup when exiting Claude Code session

### Smart Detection & Integration

The backup system automatically detects your project type and applies appropriate cleanup:

**Jupyter Notebooks** (uses `jupyter-notebook` skill):
- Detects: `*.ipynb` files
- Pre-backup cleanup:
  - Clear all cell outputs
  - Remove cells tagged 'debug' or 'remove'
  - Validate notebooks are syntactically correct
- Result: Smaller backups, clean for sharing

**HackMD/Presentations** (uses `hackmd` skill):
- Detects: `*.md` files with `slideOptions:` frontmatter
- Pre-backup cleanup:
  - Validate SVG elements (remove unsupported filters)
  - Check slide separators are correct
  - Verify YAML frontmatter
- Result: Backup-ready presentations

**Data Files** (native handling):
- Detects: `*.csv`, `*.tsv`, `*.xlsx` files
- Pre-backup cleanup:
  - Validate file integrity
  - Check for corruption
- Result: Safe data backups

**Python Projects** (uses `managing-environments` skill):
- Detects: `requirements.txt`, `environment.yml`, `venv/`, `.venv/`
- Pre-backup cleanup:
  - Remove `.pyc`, `__pycache__`, `.pytest_cache`
  - Clean build artifacts
  - Include environment specifications
- Result: Clean, reproducible backups

**Mixed Projects**:
- Detects all of the above
- Applies appropriate cleanup for each file type
- Creates organized backup structure

### Directory Structure

**For data-only projects:**
```
project/
├── your_data_file.csv          # Main working file
├── backup_project.sh           # Smart backup script
└── backups/
    ├── daily/                  # Rolling 7-day backups
    │   ├── backup_2026-01-17.csv
    │   ├── backup_2026-01-18.csv
    │   └── backup_2026-01-23.csv
    ├── milestones/             # Permanent compressed backups
    │   ├── milestone_2026-01-20_initial_enrichment.csv.gz
    │   └── milestone_2026-01-23_recovered_accessions.csv.gz
    ├── CHANGELOG.md            # Auto-generated change log
    └── README.md               # User documentation
```

**For mixed projects (notebooks + data):**
```
project/
├── analysis.ipynb              # Jupyter notebooks
├── data.csv                    # Data files
├── backup_project.sh           # Smart backup script
└── backups/
    ├── daily/                  # Rolling 7-day backups
    │   ├── backup_2026-01-17/
    │   │   ├── notebooks/
    │   │   │   └── analysis.ipynb  # Cleaned (no outputs)
    │   │   └── data/
    │   │       └── data.csv
    │   └── backup_2026-01-23/
    ├── milestones/             # Permanent compressed backups
    │   └── milestone_2026-01-23_analysis_complete.tar.gz
    ├── CHANGELOG.md            # Auto-generated change log
    └── README.md               # User documentation
```

### Storage Efficiency

- **Daily backups**: ~5.4 MB (7 days × 770KB)
- **Milestone backups**: ~200KB each compressed (80% size reduction with gzip)
- **Total**: <10 MB for complete project history
- **Auto-cleanup**: Old daily backups delete after 7 days

## Implementation

### Quick Start with `/backup` Command

**First time - Setup the backup system:**
```
/backup
```
This will:
- Detect your project type (notebooks, data files, presentations, etc.)
- Set up appropriate backup scripts with smart cleanup
- Create backup directory structure
- Optionally configure automated backups

**Daily usage - Create backups:**
```
/backup                    # Daily backup with smart cleanup
/backup milestone "desc"   # Milestone backup
/backup list              # View all backups
/backup restore DATE      # Restore from backup
```

### What Happens During Backup

**Smart cleanup before backup:**
1. **Detects file types** in your project
2. **Applies skill-specific cleanup:**
   - Notebooks: Clear outputs, remove debug cells
   - HackMD: Validate SVG, check formatting
   - Python: Remove `.pyc`, `__pycache__`
   - Data: Validate integrity
3. **Creates organized backup** with cleaned files
4. **Updates CHANGELOG** with what was backed up

**Example output:**
```
/backup

🔍 Detected: 3 notebooks, 2 data files

🧹 Pre-backup cleanup:
  ✓ Cleared outputs from 3 notebooks
  ✓ Removed 5 debug cells
  ✓ Validated 2 data files

💾 Creating backup:
  → backups/daily/backup_2026-01-24/
    ├── notebooks/ (3 files, cleaned)
    └── data/ (2 files)

✓ Backup complete: 2026-01-24
✓ Old backups cleaned (>7 days)
✓ CHANGELOG updated
```

### Manual Script Usage (Alternative)

If you prefer to use the backup script directly:
```bash
./backup_project.sh                           # Daily backup
./backup_project.sh milestone "description"   # Milestone
./backup_project.sh list                      # List backups
./backup_project.sh restore 2026-01-23        # Restore
```

### When to Create Milestones

- After adding new data sources (GenomeScope, karyotypes, external APIs)
- Before major data transformations or filtering
- When completing analysis sections
- Before submitting/publishing
- Before sharing with collaborators
- After recovering missing data

## Key Features

### Safety Features

1. ✅ **Never overwrites without asking** - Prompts before overwriting existing backups
2. ✅ **Safety backup before restore** - Creates backup of current state before any restore
3. ✅ **Automatic cleanup** - Old daily backups auto-delete (configurable)
4. ✅ **Complete audit trail** - CHANGELOG tracks everything
5. ✅ **Milestone protection** - Important versions preserved forever (compressed)

### CHANGELOG Tracking

The CHANGELOG.md automatically documents:
- Date of each backup
- Type (daily vs milestone)
- Description of changes (for milestones)
- Major modifications made to data

**Example CHANGELOG:**
```markdown
## 2026-01-23
- **MILESTONE**: Recovered VGP accessions (backup created)
  - Added columns: `accession_recovered`, `accession_recovered_all`
  - Recovered 5 VGP accessions from NCBI
  - Searched AWS and NCBI for 17 species missing accessions
- Daily backup created at 2026-01-23 15:00:00

## 2026-01-22
- Enriched GenomeScope data for 21 species from AWS repository
- Added column: `genomescope_path` with direct links to summary files
```

## Using `/backup` Command

The `/backup` command is available in all projects to set up and manage backups.

**Setup mode (first run):**
```
/backup
```
- Detects project type automatically
- Sets up appropriate backup scripts
- Creates directory structure
- Prompts for configuration (retention days, auto-backup)

**Daily backup mode:**
```
/backup                    # Quick daily backup
```

**Milestone mode:**
```
/backup milestone "description of changes"
```
Examples:
- `/backup milestone "added heterozygosity data"`
- `/backup milestone "enriched with genomescope results"`
- `/backup milestone "recovered missing accessions"`

**List and restore:**
```
/backup list              # Show all available backups
/backup restore 2026-01-23 # Restore from specific date
```

**Configuration:**
The backup script can be customized by editing `backup_project.sh`:
- Change retention days (default: 7)
- Modify backup directory location
- Add custom cleanup rules

## Benefits for Data Analysis

### Data Provenance
- CHANGELOG documents every modification
- Clear audit trail for methods sections in papers
- Know exactly what changed when

### Confidence to Experiment
- Easy rollback encourages trying different approaches
- No fear of breaking working analyses
- Can test aggressive transformations safely

### Professional Workflow
- Matches publication standards
- Reviewers can verify data processing steps
- Reproducible research practices

### Collaboration-Ready
- Team members can understand data history
- New collaborators can see evolution of dataset
- Clear documentation of enrichment process

## Session Integration with `/safe-exit`

When you end a Claude Code session with `/safe-exit`, the system automatically:

1. **Detects if backup system exists** in the current project
2. **Prompts for backup** if system is configured:
   ```
   💾 Backup system detected. Would you like to create a backup before exiting?

   Options:
   1. Daily backup (quick)
   2. Milestone backup (with description)
   3. Skip backup
   4. Cancel exit

   Choice [1-4]:
   ```
3. **Performs cleanup and backup** if requested
4. **Prompts for Obsidian session summary** (if obsidian skill is available):
   - Asks for session theme
   - Generates succinct summary of accomplishments, decisions, and remaining tasks
   - Saves to project-specific subdirectory in Obsidian vault
5. **Exits session** cleanly

This ensures you never forget to backup AND document your work at the end of your session!

## Example Workflow

### Monday Morning
```
/backup                          # Daily backup with smart cleanup
# Work on notebooks and data enrichment all day
/backup milestone "added karyotype data for 50 new species"
```

### Tuesday
```
/backup                          # Daily backup
# Continue work...
```

### End of session
```
/safe-exit

💾 Backup system detected. Would you like to create a backup before exiting?
Choice: 1 (daily backup)

🧹 Cleaning 3 notebooks...
💾 Creating backup...
✓ Backup complete

📝 Save session summary to Obsidian?
Save summary? (y/n): y

Brief theme/topic of today's work: karyotype data enrichment

✍️ Generating session summary...
✅ Session summary saved to: project-name/2026-01-24_karyotype-data-enrichment.md

Session ended. Goodbye!
```

### Friday (oops, made a mistake!)
```
/backup list                     # Check available backups
/backup restore 2026-01-23       # Restore from Wednesday
```

## Advanced Usage

### Custom Backup Script Template

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

### Viewing Compressed Milestones

```bash
# View without decompressing
gunzip -c milestone_file.csv.gz | less

# Decompress permanently
gunzip milestone_file.csv.gz
```

### Multiple File Backups

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

## Best Practices

1. **Create daily backups at session start** - Make it a habit
2. **Milestone after every major change** - Don't rely on memory
3. **Use descriptive milestone names** - "added genomescope" not "updates"
4. **Check CHANGELOG before sharing** - Verify data provenance is clear
5. **List backups periodically** - Ensure auto-cleanup is working
6. **Test restore once** - Verify you know how to recover

## Full Project Backups (vs Data-Only)

### Problem
Data-only backups (single CSV file) don't capture the complete project state. But backing up EVERYTHING creates bloated backups with old/irrelevant files.

### Solution: Selective Full Project Backup

**What to Include:**
- ✅ Main analysis notebook (e.g., `Analysis.ipynb`)
- ✅ Primary data file (e.g., `data.csv`)
- ✅ **Current** figure generation scripts only (e.g., `python_scripts/`)
- ✅ **Current** figures only (e.g., `figures/*.png` - root level)
- ✅ Active documentation (`.md` files, excluding backups)
- ✅ Utility scripts (`.sh` files)

**What to Exclude:**
- ❌ Backup notebooks (`*backup*.ipynb`, `*Copy*.ipynb`)
- ❌ Exploratory scripts in `scripts/` (only keep figure generators)
- ❌ Old figure versions (only current in `figures/`)
- ❌ Jupyter checkpoints (`.ipynb_checkpoints/`)
- ❌ Python cache (`__pycache__/`, `*.pyc`)

### Implementation Pattern

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

### Backup Strategy

| Type | Format | Retention | Purpose |
|------|--------|-----------|---------|
| **Daily** | `.tar` (uncompressed) | 7 days | Quick recovery from recent mistakes |
| **Milestone** | `.tar.gz` (compressed) | Forever | Preserve major versions |

### Size Comparison

**Real project example:**
- Data-only backup: 211 KB (compressed CSV)
- Full project backup: 17 MB (notebook + data + scripts + 43 figures + docs)
- 7-day daily backups: ~120 MB total

### When This Matters
- Projects with evolving analyses where both code and data change
- Jupyter notebook workflows with generated figures
- Research projects needing reproducibility (code + data + outputs)

### Path Verification for Backups

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
- ❌ `/Users/yourname/project/data.csv` (absolute)
- ✅ `data/data.csv` (relative)
- ❌ `Image('/Users/you/figures/fig.png')` (absolute)
- ✅ `Image('figures/fig.png')` (relative)

**Best practice:**
1. Run path check before milestone backups (see folder-organization skill)
2. Fix any absolute paths found
3. Test notebook runs from backup directory
4. Then create milestone backup

## Troubleshooting

### Backup script not found
```bash
# Check if backup system is set up
ls -l backup_project.sh

# Set up if needed
/backup
```

### Disk space running low
```bash
# Check backup sizes
du -sh backups/

# Reduce retention days (edit backup_table.sh)
DAYS_TO_KEEP=3  # Instead of 7

# Manually clean old milestones (rare)
rm backups/milestones/milestone_old_file.csv.gz
```

### CHANGELOG getting too large
```bash
# Archive old entries (manual)
tail -100 backups/CHANGELOG.md > backups/CHANGELOG_recent.md
mv backups/CHANGELOG.md backups/CHANGELOG_archive.md
mv backups/CHANGELOG_recent.md backups/CHANGELOG.md
```

## Summary

- **Two-tier system**: Daily rolling + permanent milestones
- **Storage efficient**: Gzip compression (~80% reduction)
- **Auto-cleanup**: 7-day rolling window for dailies
- **Complete audit trail**: CHANGELOG tracks all changes
- **Safety first**: Never overwrites without confirmation
- **Global installer**: Use across all projects
- **Professional workflow**: Publication-ready data provenance
