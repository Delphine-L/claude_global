# Safe-Clear Reference

Supporting file for `/safe-clear` command. Contains command flags, error handling, and integration details.

---

## Command Flags

### `--no-obsidian` Flag

Skip Obsidian prompt:

```bash
if [[ "$1" == "--no-obsidian" ]]; then
    echo "Skipping Obsidian notes..."
    SKIP_OBSIDIAN=true
fi
```

Usage: `/safe-clear --no-obsidian`

### `--no-skills` Flag

Skip skill updates:

```bash
if [[ "$1" == "--no-skills" ]]; then
    echo "Skipping skill updates..."
    SKIP_SKILLS=true
fi
```

Usage: `/safe-clear --no-skills`

### `--quick` Flag

Skip both prompts (save notes but no skills):

```bash
if [[ "$1" == "--quick" ]]; then
    echo "Quick clear mode: saving notes only..."
    SKIP_SKILLS=true
    AUTO_SAVE_NOTES=true
fi
```

Usage: `/safe-clear --quick`

---

## Error Handling

### Obsidian Vault Not Found

```
❌ Obsidian vault not found!

OBSIDIAN_VAULT is set to: $OBSIDIAN_VAULT
But this directory doesn't exist.

Options:
  1. Create the directory
  2. Update OBSIDIAN_VAULT in shell config
  3. Skip Obsidian notes for now

What would you like to do? [1/2/3]
```

### Note Creation Failed

```
❌ Failed to create Obsidian note

Error: [specific error]

Session notes were displayed above for manual copying if needed.
Continue with skill updates and clear? (y/n)
```

### Update Skills Command Not Found

```
⚠️  /update-skills command not found

This command requires:
  • update-skills.md in .claude/commands/ or global commands
  • Symlink from $CLAUDE_METADATA/commands/global/

Would you like to:
  1. Continue without skill updates
  2. Cancel context clear

Choice: [1/2]
```

---

## Integration with Other Commands

### Difference from `/safe-exit`

| Feature | `/safe-exit` | `/safe-clear` |
|---------|--------------|---------------|
| **Purpose** | End session completely | Continue with fresh context |
| **Backup prompt** | Yes | No (not exiting) |
| **Obsidian notes** | Session summary | Session notes with continuity |
| **MANIFEST updates** | No | Yes |
| **Skill updates** | No | Yes |
| **Context** | Session ends | Context cleared, session continues |
| **Use when** | Done for the day | Switching tasks, fresh start |

### Workflow Integration

**Typical workflow:**

```bash
# During work on Task A
[... work on feature/analysis ...]

# Ready to switch to Task B
/safe-clear

# Saves notes about Task A
# Updates MANIFESTs with changes
# Updates skills with learnings
# Clears context

# Start fresh on Task B
[... work on new task ...]

# End of day
/safe-exit

# Creates backup
# Saves session summary
# Exit session
```

---

## Summary

The `/safe-clear` command provides:

- **Knowledge preservation** - Session notes saved to Obsidian
- **MANIFEST tracking** - File inventories updated with session changes
- **Skill capture** - Learnings integrated into skills
- **Fresh context** - Clean slate for new work
- **Continuity** - Notes explain where you left off
- **Flexibility** - Skip notes or skills with flags
- **Safe workflow** - Never lose session knowledge

**Key differences from /safe-exit:**
- Designed for continuing work, not ending session
- Includes skill updates (captures learnings)
- Creates "continuation notes" vs "summary notes"
- No backup prompt (not exiting)
- Context clears but session continues

**Use when:**
- Switching between different tasks
- Context getting too large
- Want fresh start on new feature
- Completed one phase, starting another
- Need to pivot to different work
