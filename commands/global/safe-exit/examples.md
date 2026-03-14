# Safe-Exit: Example Interactions

> Supporting file for `/safe-exit` command. See `commands/global/safe-exit.md` for the main workflow.

## Example 1: Full Exit with Backup and Obsidian Summary

```
User: /safe-exit

💾 Backup system detected in this project.

Would you like to create a backup before exiting?

Options:
  1. Daily backup (quick, with smart cleanup)
  2. Milestone backup (permanent, with description)
  3. Skip backup
  4. Cancel exit (stay in session)

Enter choice [1-4]: 1

💾 Creating daily backup before exit...

🧹 Cleaning 3 notebooks...
  ✓ Cleared outputs from analysis.ipynb
  ✓ Cleared outputs from exploration.ipynb
  ✓ Cleared outputs from results.ipynb

💾 Creating backup:
  → backups/daily/backup_2026-01-24/
    ├── notebooks/ (3 files, cleaned)
    └── data/ (2 files)

✓ Backup complete: 2026-01-24
✓ CHANGELOG updated

📋 Update MANIFEST files before exiting?

This will:
  • Detect modified directories from this session
  • Update file lists and timestamps
  • Add session context to "Notes for Resuming Work"
  • Verify file existence

Update MANIFESTs? (y/n): y

Running /update-manifest command...

📋 Analyzing session changes...
✅ Updated 2 MANIFESTs:
  - ./MANIFEST.md (added 3 files, updated 5 files)
  - data/MANIFEST.md (updated 2 files)

📝 Save session summary to Obsidian?

This will create a succinct note documenting:
  • What was accomplished
  • Key decisions made
  • Tasks remaining (if any)

Save summary? (y/n): y

📁 First time using Obsidian with this project.

Enter project name for Obsidian subdirectory (e.g., 'telomere-analysis'): telomere-analysis
✅ Project name saved for future sessions

Brief theme/topic of today's work: chromosome length analysis

✍️ Generating session summary...

✅ Session summary saved to: telomere-analysis/2026-01-24_chromosome-length-analysis.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: telomere-analysis
Backup status: Created daily backup
MANIFEST updates: 2 MANIFESTs updated
Obsidian note: Saved to telomere-analysis/2026-01-24_chromosome-length-analysis.md
Last backup: 2026-01-24

💡 Tips for next session:
  • Start with: /backup (for daily backup)
  • View backups: /backup list
  • Restore if needed: /backup restore DATE
  • Review session notes in Obsidian vault

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋

Note: To actually exit Claude Code, please use Ctrl+D or close the terminal.
```

## Example 2: Subsequent Session (Project Already Configured)

```
User: /safe-exit

💾 Backup system detected in this project.

Would you like to create a backup before exiting?

Enter choice [1-4]: 2

💾 Creating milestone backup before exit...

Milestone description: completed telomere classification model

🧹 Cleaning notebooks and data...
💾 Creating compressed milestone...

✓ Milestone backup created: milestone_2026-01-24_completed_telomere_classification_model.tar.gz
✓ CHANGELOG updated

📋 Update MANIFEST files before exiting?

Update MANIFESTs? (y/n): y

Running /update-manifest command...

📋 Analyzing session changes...
✅ Updated 1 MANIFEST:
  - ./MANIFEST.md (updated 3 files)

📝 Save session summary to Obsidian?

Save summary? (y/n): y

Brief theme/topic of today's work: telomere classification model

✍️ Generating session summary...

✅ Session summary saved to: telomere-analysis/2026-01-24_telomere-classification-model.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: telomere-analysis
Backup status: Created milestone backup
MANIFEST updates: 1 MANIFEST updated
Obsidian note: Saved to telomere-analysis/2026-01-24_telomere-classification-model.md
Last backup: 2026-01-24

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋
```

**Note:** In this example, the project name wasn't asked for again because it was saved from the first session in `.claude/project-config`.

## Example 3: Skip Both Backup and Summary

```
User: /safe-exit

💾 Backup system detected in this project.

Would you like to create a backup before exiting?

Enter choice [1-4]: 3

Skipping backup...

📋 Update MANIFEST files before exiting?

Update MANIFESTs? (y/n): n

Skipping MANIFEST updates...

📝 Save session summary to Obsidian?

Save summary? (y/n): n

Skipping Obsidian summary...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: my-project
Backup status: Skipped
MANIFEST updates: Skipped
Obsidian note: Skipped

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋
```

## Example 4: Obsidian Note Structure

This is what the generated Obsidian note looks like:

**File:** `telomere-analysis/2026-01-24_chromosome-length-analysis.md`

```markdown
---
type: session
project: telomere-analysis
date: 2026-01-24
tags:
  - session
  - dump
status: completed
---

# Session Summary

**Project:** telomere-analysis
**Date:** 2026-01-24
**Theme:** chromosome length analysis

## What Was Accomplished

- Analyzed chromosome length distributions across 50 species
- Created visualization scripts for telomere length vs chromosome size
- Identified outliers in chromosome length data (5 species flagged)
- Generated statistical summary of chromosome counts per species

## Key Decisions

- Using IQR method for outlier detection (1.5x threshold)
- Excluded species with <3 chromosomes from analysis
- Chose log-scale for visualization due to wide size range

## Tasks Remaining

- [ ] Validate outlier species manually (check assembly quality)
- [ ] Add statistical tests for chromosome length differences
- [ ] Create publication-quality figures with proper labels
- [ ] Document methodology in methods.md

## Notes

Found interesting pattern: species with >40 chromosomes tend to have shorter average chromosome lengths. Worth investigating further with phylogenetic context.

---
*Generated by Claude Code session ending at 2026-01-24 15:30:00*
```

## Example 5: Quick Exit Without Prompts

```
User: /safe-exit --no-backup

Exiting without backup prompt...

Goodbye! 👋

Note: To actually exit Claude Code, use Ctrl+D or close the terminal.
```
