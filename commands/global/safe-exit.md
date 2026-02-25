---
name: safe-exit
description: Safely end Claude Code session with backup and Obsidian session summary prompts
---

End the current Claude Code session gracefully, with optional backup and session summary to Obsidian.

**⚠️ Important:** Use `/safe-exit` (not `exit`) to get the full workflow with backup prompts and session summaries. Typing `exit` alone will quit immediately without these safety features.

## ⛔ CRITICAL: Git Management

**NEVER perform ANY git operations** (add, commit, push, stash, etc.) for the user.

The user **always** manages git commits themselves. You may:
- ✅ Check git status and show uncommitted changes
- ✅ Suggest git commands the user could run
- ❌ NEVER run git add, commit, push, or any other git write operations

**The user wants full control over all git operations.**

## Your Task

### Step 1: Check for Git Repository and Backup System

```bash
# Check if in git repository - skip backup prompts if so
IN_GIT_REPO=false
if git rev-parse --git-dir > /dev/null 2>&1; then
    IN_GIT_REPO=true
fi

# Check if backup script exists (only relevant if not in git repo)
BACKUP_EXISTS=false
if [ "$IN_GIT_REPO" = "false" ] && ([ -f "backup_project.sh" ] || [ -f "backup_table.sh" ]); then
    BACKUP_EXISTS=true
fi
```

---

## If in Git Repository

Skip backup prompts entirely and proceed directly to Obsidian integration (Step 3).

```
ℹ️  Git repository detected - using git for version control.

For backups, use:
  • git commit && git push - Save and backup work to remote
  • git tag - Mark milestones

Skipping backup prompt...
```

Then proceed to Step 3 (Obsidian Session Summary).

---

## If Backup System Exists (and NOT in Git Repo)

### 1. Prompt User for Backup

Present clear options:

```
💾 Backup system detected in this project.

Would you like to create a backup before exiting?

Options:
  1. Daily backup (quick, with smart cleanup)
  2. Milestone backup (permanent, with description)
  3. Skip backup
  4. Cancel exit (stay in session)

Enter choice [1-4]:
```

### 2. Handle User Choice

**Choice 1: Daily Backup**
```bash
echo "💾 Creating daily backup before exit..."
echo ""

# Execute daily backup
if [ -f "backup_project.sh" ]; then
    ./backup_project.sh daily
elif [ -f "backup_table.sh" ]; then
    ./backup_table.sh
fi

echo ""
echo "✅ Backup complete!"
echo ""
# Proceed to exit
```

**Choice 2: Milestone Backup**
```bash
echo "💾 Creating milestone backup before exit..."
echo ""
read -p "Milestone description: " DESCRIPTION

# Execute milestone backup
if [ -f "backup_project.sh" ]; then
    ./backup_project.sh milestone "$DESCRIPTION"
elif [ -f "backup_table.sh" ]; then
    ./backup_table.sh milestone "$DESCRIPTION"
fi

echo ""
echo "✅ Milestone backup complete!"
echo ""
# Proceed to exit
```

**Choice 3: Skip Backup**
```bash
echo "Skipping backup..."
echo ""
# Proceed to exit
```

**Choice 4: Cancel Exit**
```bash
echo "Exit cancelled. Session continues."
# Do not exit
return
```

### 3. Obsidian Session Summary (Optional)

After handling backup, check if Obsidian integration is available and offer to save session summary.

#### Check for Obsidian Skill

```bash
# Check if obsidian skill is linked
OBSIDIAN_AVAILABLE=false
if [ -L ".claude/skills/obsidian" ] || [ -d ".claude/skills/obsidian" ]; then
    OBSIDIAN_AVAILABLE=true
fi

# Also check if OBSIDIAN_VAULT environment variable is set
if [ -n "$OBSIDIAN_VAULT" ]; then
    OBSIDIAN_AVAILABLE=true
fi
```

#### If Obsidian Available, Prompt for Session Summary

```
📝 Save session summary to Obsidian?

This will create a succinct note documenting:
  • What was accomplished
  • Key decisions made
  • Tasks remaining (if any)

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]:
```

#### Choice 1: Default Mode (Date-based in sessions-history/)

**Step 3a: Check for Project Configuration**

```bash
# Check if project has been configured before
PROJECT_CONFIG_FILE=".claude/project-config"

if [ -f "$PROJECT_CONFIG_FILE" ]; then
    # Read existing project configuration
    PROJECT_NAME=$(grep "^obsidian_project=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
    OBSIDIAN_PATH=$(grep "^obsidian_path=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
    # Fallback to project name if path not set (backward compatibility)
    OBSIDIAN_PATH=${OBSIDIAN_PATH:-$PROJECT_NAME}
else
    # Ask for project name and directory location
    echo ""
    echo "📁 First time using Obsidian with this project."
    echo ""
    read -p "Enter project name (e.g., 'telomere-analysis'): " PROJECT_NAME

    # Show vault structure and ask for directory placement
    echo ""
    echo "📁 Current vault structure:"

    # Use Python to show vault structure (follows obsidian skill guidance)
    python3 << 'SHOW_VAULT'
import os
from pathlib import Path

vault_path = Path(os.environ.get('OBSIDIAN_VAULT', ''))
if not vault_path.exists():
    print("   (Vault not found - will use root)")
else:
    print(f"   {vault_path.name}/")
    items = sorted([x for x in vault_path.iterdir() if x.is_dir() and not x.name.startswith('.')])
    for i, item in enumerate(items[:10]):
        is_last = i == len(items) - 1 or i == 9
        prefix = "   └──" if is_last else "   ├──"
        print(f"{prefix} {item.name}/")
    if len(items) > 10:
        print(f"   └── ... ({len(items) - 10} more)")
SHOW_VAULT

    echo ""
    echo "Where should this project's notes be stored?"
    echo ""
    echo "Options:"
    echo "  1. Root level (vault/$PROJECT_NAME/)"
    echo "  2. Custom path (e.g., vault/Work/$PROJECT_NAME/)"
    echo ""
    read -p "Enter choice [1-2]: " DIR_CHOICE

    if [ "$DIR_CHOICE" = "2" ]; then
        echo ""
        echo "Enter the parent directory path (relative to vault root)."
        echo "Examples: Work, Projects/Active, Personal/Research"
        echo ""
        read -p "Parent directory: " PARENT_DIR
        PARENT_DIR=$(echo "$PARENT_DIR" | sed 's:^/::; s:/$::')  # Clean slashes
        OBSIDIAN_PATH="$PARENT_DIR/$PROJECT_NAME"
    else
        OBSIDIAN_PATH="$PROJECT_NAME"
    fi

    # Save for future sessions
    mkdir -p .claude
    cat > "$PROJECT_CONFIG_FILE" << EOF
obsidian_project=$PROJECT_NAME
obsidian_path=$OBSIDIAN_PATH
EOF
    echo "✅ Project configuration saved for future sessions"
    echo "   Directory: $OBSIDIAN_PATH"
fi

# Set subfolder and filename for default mode
SUBFOLDER="sessions-history"
USE_THEME=false
```

#### Choice 2: Custom Mode

**Step 3a: Same configuration check as above**

Then ask for custom details:

```bash
echo ""
echo "📝 Custom note configuration:"
echo ""
read -p "Subfolder within project (e.g., 'meetings', 'sprints'): " SUBFOLDER
echo ""
read -p "Note filename (without .md, e.g., 'sprint-review', '2026-02-05-planning'): " CUSTOM_FILENAME
echo ""
read -p "Session theme/topic: " SESSION_THEME
echo ""

USE_THEME=true
```

#### Choice 3: Skip

```bash
echo "Skipping Obsidian summary..."
echo ""
# Proceed to exit message
```

**Step 3b: Generate Session Summary**

Based on the conversation, create a succinct summary.

**For DEFAULT mode (no theme):**

```markdown
## Session [HH:MM]

### What Was Accomplished

[Analyze the conversation and list 3-5 key accomplishments in bullet points]
- Created smart backup system with skill integration
- Implemented /backup command with auto-detection
- Added /safe-exit command with backup prompts
- Updated documentation and essential skills

### Key Decisions

[List any important decisions made - 2-3 bullets if any, otherwise omit section]
- Made data-backup an essential skill
- Integrated backup prompts into session exit workflow

### Tasks Remaining

[List any identified tasks that still need to be done - if none, say "None identified"]
- [ ] Test backup system with notebooks
- [ ] Verify /safe-exit prompts work correctly
- [ ] Update QUICK_REFERENCE.md with new commands

### Notes

[Any other relevant context - optional, omit if none]

---
```

**For CUSTOM mode (with theme):**

```markdown
# Session Summary

**Project:** [Project Name]
**Date:** [YYYY-MM-DD HH:MM]
**Theme:** [Session Theme]

## What Was Accomplished

[Same as above]

## Key Decisions

[Same as above]

## Tasks Remaining

[Same as above]

## Notes

[Same as above]

---
*Generated by Claude Code session ending at [timestamp]*
```

**Step 3c: Create or Append to Obsidian Note**

```python
import os
from datetime import datetime

# Get current date and time
now = datetime.now()
date_str = now.strftime("%Y-%m-%d")
time_str = now.strftime("%H:%M")
timestamp = now.strftime("%Y-%m-%d %H:%M")

# Determine filename based on mode
if USE_THEME:
    # Custom mode - use provided filename
    filename = f"{CUSTOM_FILENAME}.md"
else:
    # Default mode - use date
    filename = f"{date_str}.md"

# Ensure project directory and subfolder exist in Obsidian vault
vault_path = os.environ.get('OBSIDIAN_VAULT')
# Use OBSIDIAN_PATH from config (includes any parent directories)
project_dir = os.path.join(vault_path, OBSIDIAN_PATH, SUBFOLDER)
os.makedirs(project_dir, exist_ok=True)

# Full path for note
note_path = os.path.join(project_dir, filename)

# Check if note already exists
if os.path.exists(note_path):
    # Append to existing note
    print(f"📝 Appending to existing note: {filename}")
    with open(note_path, 'a') as f:
        f.write("\n\n")  # Add spacing
        f.write(summary_content)
    action = "appended to"
else:
    # Create new note with frontmatter and header
    print(f"📝 Creating new note: {filename}")
    with open(note_path, 'w') as f:
        # Add frontmatter for new files
        f.write("---\n")
        f.write("type: session\n")
        f.write(f"project: {PROJECT_NAME}\n")
        f.write(f"date: {date_str}\n")
        f.write("tags:\n")
        f.write("  - session\n")
        f.write("  - dump\n")
        f.write("status: completed\n")
        f.write("---\n\n")

        if not USE_THEME:
            # Add date header for default mode
            f.write(f"# {date_str}\n\n")
        f.write(summary_content)
    action = "saved to"

print(f"✅ Session summary {action}: {OBSIDIAN_PATH}/{SUBFOLDER}/{filename}")
```

**Important Guidelines for Summary Generation:**

1. **Be succinct** - Keep each section brief (3-5 bullets max)
2. **Focus on substance** - What was actually accomplished, not process
3. **Identify tasks** - Any unfinished work mentioned in conversation
4. **Use clear language** - Avoid jargon where possible
5. **Add context** - Brief notes on why decisions were made (if relevant)
6. **Default mode formatting** - Use `## Session [HH:MM]` as header for appending to daily notes
7. **Omit empty sections** - If no key decisions or notes, don't include those sections

### 4. Show Exit Message

After backup and Obsidian summary (if requested), show final message:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: [current directory name]
Backup status: [Created daily backup / Created milestone / Skipped / None]
Obsidian note: [Saved/Appended to ProjectName/sessions-history/YYYY-MM-DD.md / Custom location / Skipped / Not available]
Last backup: [timestamp from CHANGELOG or backup directory]

💡 Tips for next session:
  • Start with: /backup (for daily backup)
  • View backups: /backup list
  • Restore if needed: /backup restore DATE
  • Review session notes in Obsidian: [ProjectName]/sessions-history/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋
```

**Then inform the user:**
```
Note: To actually exit Claude Code, please use Ctrl+D or close the terminal.
This command provides a graceful session ending with backup and note-taking.
```

---

## If NO Backup System Exists

Even without backup system, still check for Obsidian and offer session summary.

### 1. Check for Obsidian (Same as Above)

Follow the same Obsidian integration steps from section 3.

### 2. Show Simple Exit Message

After Obsidian handling (if applicable):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: [current directory name]
Backup status: No backup system configured
Obsidian note: [Saved to ProjectName/YYYY-MM-DD_theme.md / Skipped / Not available]

💡 Want automatic backups next time?
  • Set up backup system: /backup
  • Creates smart backups with cleanup
  • Integrates with jupyter-notebook and other skills

💡 Want session notes next time?
  • Ensure obsidian skill is linked
  • Set OBSIDIAN_VAULT environment variable
  • See obsidian skill documentation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋

Note: To actually exit Claude Code, please use Ctrl+D or close the terminal.
```

---

## Command-Line Flags (Optional)

Support optional flags for quick exit:

### `--no-backup` Flag

```bash
# Check for --no-backup flag
if [[ "$1" == "--no-backup" ]]; then
    echo "Exiting without backup prompt..."
    echo ""
    echo "Goodbye! 👋"
    echo ""
    echo "Note: To actually exit Claude Code, use Ctrl+D or close the terminal."
    return
fi
```

Usage: `/safe-exit --no-backup`

### `--backup` Flag

```bash
# Check for --backup flag
if [[ "$1" == "--backup" ]]; then
    if [ -f "backup_project.sh" ] || [ -f "backup_table.sh" ]; then
        echo "💾 Creating daily backup before exit..."
        if [ -f "backup_project.sh" ]; then
            ./backup_project.sh daily
        elif [ -f "backup_table.sh" ]; then
            ./backup_table.sh
        fi
        echo "✅ Backup complete!"
    else
        echo "⚠️  No backup system configured. Exiting without backup."
    fi
    echo ""
    echo "Goodbye! 👋"
    return
fi
```

Usage: `/safe-exit --backup` (auto-backup and exit, no prompt)

---

## Additional Features

### Show Recent Activity (Optional Enhancement)

If available, show brief session summary:

```
Session activity:
  • Files modified: [count files with recent mtime]
  • Notebooks run: [check for updated .ipynb]
  • Data files changed: [check .csv/.tsv timestamps]
```

**Implementation:**
```bash
# Check for recently modified files (last 24 hours)
MODIFIED_COUNT=$(find . -maxdepth 1 -type f \( -name "*.ipynb" -o -name "*.csv" -o -name "*.tsv" -o -name "*.md" \) -mtime -1 2>/dev/null | wc -l | xargs)

if [ "$MODIFIED_COUNT" -gt 0 ]; then
    echo "Session activity: $MODIFIED_COUNT files modified in last 24 hours"
fi
```

### Git Status Check (Optional)

If in a git repository, show uncommitted changes:

```bash
if git rev-parse --git-dir > /dev/null 2>&1; then
    UNCOMMITTED=$(git status --porcelain | wc -l | xargs)
    if [ "$UNCOMMITTED" -gt 0 ]; then
        echo "⚠️  Warning: $UNCOMMITTED uncommitted changes in git"
        echo "   Consider: git add . && git commit -m \"session updates\""
    fi
fi
```

---

## Error Handling

### Backup Script Fails

If backup execution fails:

```
❌ Backup failed!

Error executing backup script. You can:
  1. Try again: /backup
  2. Exit without backup
  3. Cancel and investigate the issue

The backup script is at: ./backup_project.sh
Check backups/CHANGELOG.md for recent changes.

What would you like to do? [exit/cancel]
```

### No Permission to Execute

```
❌ Cannot execute backup script (permission denied)

Fix with: chmod +x backup_project.sh

Then:
  • Try exit again: /safe-exit
  • Or exit without backup

What would you like to do? [exit/cancel]
```

### Obsidian Vault Not Found

```
❌ Obsidian vault not found!

OBSIDIAN_VAULT environment variable is set to: /path/to/vault
But this directory doesn't exist or isn't accessible.

Options:
  1. Create the directory: mkdir -p /path/to/vault
  2. Update OBSIDIAN_VAULT in your shell config
  3. Skip Obsidian summary for now

What would you like to do? [create/skip/cancel]
```

### Obsidian Note Creation Failed

```
❌ Failed to create Obsidian note

Error: [specific error message]

The session summary was not saved, but you can still exit.
Summary content has been displayed above for manual copying if needed.

Continue exit? (y/n)
```

---

## Integration Notes

### For Claude Code

Since Claude Code may not have a built-in `/safe-exit` command that actually terminates the process, this command:

1. **Performs pre-exit tasks** (backup, summary)
2. **Shows goodbye message**
3. **Informs user** how to actually exit (Ctrl+D, close terminal)

This provides a **graceful session ending workflow** even though the actual termination is manual.

### For Future Enhancement

If Claude Code adds support for programmatic exit, this command could be enhanced to:
- Actually terminate the session
- Save session history
- Close file handles cleanly
- Run cleanup scripts

---

## Example Interactions

### Example 1: Full Exit with Backup and Obsidian Summary

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

### Example 2: Subsequent Session (Project Already Configured)

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

📝 Save session summary to Obsidian?

Save summary? (y/n): y

Brief theme/topic of today's work: telomere classification model

✍️ Generating session summary...

✅ Session summary saved to: telomere-analysis/2026-01-24_telomere-classification-model.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: telomere-analysis
Backup status: Created milestone backup
Obsidian note: Saved to telomere-analysis/2026-01-24_telomere-classification-model.md
Last backup: 2026-01-24

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋
```

**Note:** In this example, the project name wasn't asked for again because it was saved from the first session in `.claude/project-config`.

### Example 3: Skip Both Backup and Summary

```
User: /safe-exit

💾 Backup system detected in this project.

Would you like to create a backup before exiting?

Enter choice [1-4]: 3

Skipping backup...

📝 Save session summary to Obsidian?

Save summary? (y/n): n

Skipping Obsidian summary...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: my-project
Backup status: Skipped
Obsidian note: Skipped

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋
```

### Example 4: Obsidian Note Structure

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

### Example 5: Quick Exit Without Prompts

```
User: /safe-exit --no-backup

Exiting without backup prompt...

Goodbye! 👋

Note: To actually exit Claude Code, use Ctrl+D or close the terminal.
```

---

## Summary

The `/safe-exit` command provides:

✅ **Backup reminder** - Never forget to backup before ending session
✅ **Smart options** - Daily, milestone, skip, or cancel
✅ **Obsidian integration** - Save session summaries to your vault
✅ **Project tracking** - Remembers project name for future sessions
✅ **Succinct summaries** - Accomplishments, decisions, and remaining tasks
✅ **Session overview** - Clear summary of work done
✅ **Graceful exit** - Clean ending with helpful tips
✅ **Flag support** - Quick exit with `--no-backup` or `--backup`
✅ **Multi-skill integration** - Works with `/backup`, obsidian skill

**Session Summary Features:**
- Automatically generates based on conversation
- Includes accomplishments, decisions, and remaining tasks
- Saves to project-specific subdirectory in Obsidian vault
- Filename includes date and session theme
- Remembers project configuration across sessions
- Follows obsidian skill conventions

This ensures a professional workflow, prevents data loss, and maintains comprehensive session documentation!
