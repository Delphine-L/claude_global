---
name: safe-exit
description: Safely end Claude Code session with backup and Obsidian session summary prompts
disable-model-invocation: true
---

End the current Claude Code session gracefully, with optional backup and session summary to Obsidian.

**Important:** Use `/safe-exit` (not `exit`) to get the full workflow with backup prompts and session summaries. Typing `exit` alone will quit immediately without these safety features.

> **Supporting files** (detailed templates, examples, error handling):
> - `commands/global/safe-exit/examples.md` - Full interaction examples
> - `commands/global/safe-exit/obsidian-integration.md` - Obsidian config, templates, note creation
> - `commands/global/safe-exit/reference.md` - CLI flags, error handling, additional features

---

## CRITICAL: Git Management

**NEVER perform ANY git operations** (add, commit, push, stash, etc.) for the user.

- Check git status and show uncommitted changes: OK
- Suggest git commands the user could run: OK
- Run git add, commit, push, or any other git write operations: NEVER

**The user wants full control over all git operations.**

---

## Your Task

### Step 1: Detect Environment

```bash
# Check if in git repository
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

### Step 2: Handle Backup (if applicable)

**If in Git Repository:** Skip backup prompts. Show:
```
ℹ️  Git repository detected - using git for version control.
For backups, use: git commit && git push, or git tag for milestones.
```
Proceed directly to Step 3.

**If Backup System Exists (not in git repo):** Present options:
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

Handle each choice:
- **Choice 1 (Daily):** Run `./backup_project.sh daily` or `./backup_table.sh`
- **Choice 2 (Milestone):** Ask for description, run `./backup_project.sh milestone "$DESCRIPTION"`
- **Choice 3 (Skip):** Continue to next step
- **Choice 4 (Cancel):** Abort exit, return to session

**If No Backup System:** Continue to next step.

---

### Step 3: Update MANIFEST (if applicable)

Check if any MANIFEST.md files exist (excluding deprecated/). If found, prompt:

```
📋 Update MANIFEST files before exiting?

This will:
  • Detect modified directories from this session
  • Update file lists and timestamps
  • Add session context to "Notes for Resuming Work"
  • Verify file existence

Update MANIFESTs? (y/n):
```

If yes: Execute `/update-manifest` command. Ask user for session context if not already collected (current status, next steps, known issues). This context is reused for Obsidian summary.

If no: Skip.

---

### Step 4: Obsidian Session Summary (if available)

Check if Obsidian is available (skill linked or `$OBSIDIAN_VAULT` set). If available, prompt with options:
1. **Default** - Save to `sessions-history/` with today's date
2. **Custom** - Specify folder, filename, and theme
3. **Skip**

For first-time projects, ask for project name and vault directory placement. Configuration is saved to `.claude/project-config` for future sessions.

Generate a succinct summary covering: accomplishments (3-5 bullets), key decisions, remaining tasks, and notes. Append to existing daily note or create new one.

> **Full details:** See `commands/global/safe-exit/obsidian-integration.md` for configuration scripts, templates, and note creation code.

---

### Step 5: Show Exit Message

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:

Project: [current directory name]
Backup status: [Created daily backup / Created milestone / Skipped / None]
MANIFEST updates: [X MANIFESTs updated / Skipped / Not available]
Obsidian note: [Saved/Appended to path / Skipped / Not available]
Last backup: [timestamp from CHANGELOG or backup directory]

💡 Tips for next session:
  • Start with: /backup (for daily backup)
  • View backups: /backup list
  • Restore if needed: /backup restore DATE
  • Review session notes in Obsidian: [ProjectName]/sessions-history/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Goodbye! 👋
```

Then inform user: To actually exit Claude Code, use Ctrl+D or close the terminal.

**If no backup system exists**, replace tips with setup suggestions:
```
💡 Want automatic backups next time?
  • Set up backup system: /backup
💡 Want session notes next time?
  • Ensure obsidian skill is linked
  • Set OBSIDIAN_VAULT environment variable
```

---

## Quick Reference

| Flag | Effect |
|------|--------|
| *(none)* | Full interactive workflow |
| `--no-backup` | Skip all prompts, show goodbye |
| `--backup` | Auto daily backup, then exit |

> **Full flag implementations:** See `commands/global/safe-exit/reference.md`

> **Error handling** (backup failures, permission errors, vault not found): See `commands/global/safe-exit/reference.md`

> **Example interactions:** See `commands/global/safe-exit/examples.md`
