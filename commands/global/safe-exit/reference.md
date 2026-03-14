# Safe-Exit: Reference Material

> Supporting file for `/safe-exit` command. See `commands/global/safe-exit.md` for the main workflow.

## Command-Line Flags

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

## Feature Summary

The `/safe-exit` command provides:

- **Backup reminder** - Never forget to backup before ending session
- **Smart options** - Daily, milestone, skip, or cancel
- **MANIFEST updates** - Keep file inventories current with session changes
- **Obsidian integration** - Save session summaries to your vault
- **Project tracking** - Remembers project name for future sessions
- **Succinct summaries** - Accomplishments, decisions, and remaining tasks
- **Session overview** - Clear summary of work done
- **Graceful exit** - Clean ending with helpful tips
- **Flag support** - Quick exit with `--no-backup` or `--backup`
- **Multi-skill integration** - Works with `/backup`, obsidian skill

**Session Summary Features:**
- Automatically generates based on conversation
- Includes accomplishments, decisions, and remaining tasks
- Saves to project-specific subdirectory in Obsidian vault
- Filename includes date and session theme
- Remembers project configuration across sessions
- Follows obsidian skill conventions

**MANIFEST Update Features:**
- Updates all MANIFESTs in modified directories
- Preserves user-entered content
- Adds session context to "Notes for Resuming Work"
- Verifies file existence
- Reuses session context from Obsidian notes for efficiency
