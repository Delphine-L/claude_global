---
name: data-backup
description: Smart automated backup system with skill integration. Detects project type (notebooks, data files, HackMD docs) and applies appropriate cleanup before backup. Rolling daily backups, compressed milestones, and CHANGELOG tracking.
version: 2.0.0
---

# Smart Backup System with Skill Integration

> **Supporting files in this directory:**
> - [MANIFEST_BACKUPS.md](./MANIFEST_BACKUPS.md) -- MANIFEST-aware intelligent backups
> - [FULL_PROJECT_BACKUPS.md](./FULL_PROJECT_BACKUPS.md) -- Full project backups, selective inclusion/exclusion, path verification
> - [ADVANCED_USAGE.md](./ADVANCED_USAGE.md) -- Custom scripts, multiple file backups, real-world examples

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
- Pre-backup cleanup: Clear all cell outputs, remove cells tagged 'debug' or 'remove', validate notebooks

**HackMD/Presentations** (uses `hackmd` skill):
- Detects: `*.md` files with `slideOptions:` frontmatter
- Pre-backup cleanup: Validate SVG elements, check slide separators, verify YAML frontmatter

**Data Files** (native handling):
- Detects: `*.csv`, `*.tsv`, `*.xlsx` files
- Pre-backup cleanup: Validate file integrity, check for corruption

**Python Projects** (uses `managing-environments` skill):
- Detects: `requirements.txt`, `environment.yml`, `venv/`, `.venv/`
- Pre-backup cleanup: Remove `.pyc`, `__pycache__`, `.pytest_cache`, clean build artifacts

**Mixed Projects**: Detects all of the above and applies appropriate cleanup for each file type.

### Directory Structure

**For data-only projects:**
```
project/
├── your_data_file.csv          # Main working file
├── backup_project.sh           # Smart backup script
└── backups/
    ├── daily/                  # Rolling 7-day backups
    ├── milestones/             # Permanent compressed backups
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
    │   └── backup_2026-01-17/
    │       ├── notebooks/      # Cleaned (no outputs)
    │       └── data/
    ├── milestones/             # Permanent compressed backups
    ├── CHANGELOG.md
    └── README.md
```

### Storage Efficiency

- **Daily backups**: ~5.4 MB (7 days x 770KB)
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

### Manual Script Usage (Alternative)

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

1. **Never overwrites without asking** - Prompts before overwriting existing backups
2. **Safety backup before restore** - Creates backup of current state before any restore
3. **Automatic cleanup** - Old daily backups auto-delete (configurable)
4. **Complete audit trail** - CHANGELOG tracks everything
5. **Milestone protection** - Important versions preserved forever (compressed)

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
- Daily backup created at 2026-01-23 15:00:00

## 2026-01-22
- Enriched GenomeScope data for 21 species from AWS repository
- Added column: `genomescope_path` with direct links to summary files
```

## Using `/backup` Command

**Setup mode (first run):** `/backup` -- Detects project type, sets up scripts, creates directory structure.

**Daily backup mode:** `/backup` -- Quick daily backup.

**Milestone mode:** `/backup milestone "description of changes"` -- e.g., `/backup milestone "added heterozygosity data"`

**List and restore:**
```
/backup list              # Show all available backups
/backup restore 2026-01-23 # Restore from specific date
```

**Configuration:** Edit `backup_project.sh` to change retention days (default: 7), backup directory location, or custom cleanup rules.

## Benefits for Data Analysis

- **Data Provenance**: CHANGELOG documents every modification; clear audit trail for methods sections in papers
- **Confidence to Experiment**: Easy rollback encourages trying different approaches safely
- **Professional Workflow**: Matches publication standards; reviewers can verify data processing steps
- **Collaboration-Ready**: Team members can understand data history and enrichment process

## Session Integration with `/safe-exit`

When you end a Claude Code session with `/safe-exit`, the system automatically:

1. **Detects if backup system exists** in the current project
2. **Prompts for backup** if system is configured (daily, milestone, skip, or cancel)
3. **Performs cleanup and backup** if requested
4. **Prompts for Obsidian session summary** (if obsidian skill is available)
5. **Exits session** cleanly

This ensures you never forget to backup AND document your work at the end of your session!

## Example Workflow

### Monday Morning
```
/backup                          # Daily backup with smart cleanup
# Work on notebooks and data enrichment all day
/backup milestone "added karyotype data for 50 new species"
```

### End of session
```
/safe-exit
# Prompted: daily backup -> backup complete -> session summary -> exit
```

### Friday (oops, made a mistake!)
```
/backup list                     # Check available backups
/backup restore 2026-01-23       # Restore from Wednesday
```

## MANIFEST-Aware Backups

For projects with MANIFEST files, use intelligent backups that include only essential files. See **[MANIFEST_BACKUPS.md](./MANIFEST_BACKUPS.md)** for the full pattern, script templates, inclusion/exclusion rules, and integration with the `/backup` command.

## Full Project Backups

For projects where both code and data change, selective full-project backups capture the complete state without bloat. See **[FULL_PROJECT_BACKUPS.md](./FULL_PROJECT_BACKUPS.md)** for implementation patterns, backup strategy comparison, size benchmarks, and path verification guidance.

## Advanced Usage

For custom backup script templates, handling multiple files, viewing compressed milestones, and real-world examples, see **[ADVANCED_USAGE.md](./ADVANCED_USAGE.md)**.

## Best Practices

1. **Create daily backups at session start** - Make it a habit
2. **Milestone after every major change** - Don't rely on memory
3. **Use descriptive milestone names** - "added genomescope" not "updates"
4. **Check CHANGELOG before sharing** - Verify data provenance is clear
5. **List backups periodically** - Ensure auto-cleanup is working
6. **Test restore once** - Verify you know how to recover

## Troubleshooting

### Backup script not found
```bash
ls -l backup_project.sh   # Check if backup system is set up
/backup                    # Set up if needed
```

### Disk space running low
```bash
du -sh backups/            # Check backup sizes
# Reduce retention: edit DAYS_TO_KEEP=3 in backup_table.sh
# Manually clean old milestones if needed
```

### CHANGELOG getting too large
```bash
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
