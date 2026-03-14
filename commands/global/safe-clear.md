---
name: safe-clear
description: Save session notes to Obsidian, update skills with session knowledge, then clear context to continue working
disable-model-invocation: true
---

Save important session knowledge before clearing context to continue with a fresh slate.

**Important:** Use `/safe-clear` instead of manually clearing to preserve session knowledge. This command:
1. Saves session notes to Obsidian
2. Captures learnings in skill updates
3. Clears context for fresh start

> **Supporting files** (detailed templates, examples, error handling):
> - `safe-clear/obsidian-integration.md` - Obsidian setup, note templates, file creation logic
> - `safe-clear/examples.md` - Full interaction examples
> - `safe-clear/reference.md` - Command flags, error handling, integration details

---

## CRITICAL: Git Management

**NEVER perform ANY git operations** (add, commit, push, stash, etc.) for the user.

The user **always** manages git commits themselves. You may:
- Check git status and show uncommitted changes
- Suggest git commands the user could run
- NEVER run git add, commit, push, or any other git write operations

---

## Your Task

### Step 1: Check for Git Repository

```bash
IN_GIT_REPO=false
if git rev-parse --git-dir > /dev/null 2>&1; then
    IN_GIT_REPO=true
    echo "Git repository detected - using git for version control."
fi
```

This command does not offer backup prompts. For git repositories, use `git commit` to save work.

---

### Step 2: Check for Obsidian Integration

```bash
OBSIDIAN_AVAILABLE=false
if [ -L ".claude/skills/obsidian" ] || [ -d ".claude/skills/obsidian" ]; then
    OBSIDIAN_AVAILABLE=true
fi
if [ -n "$OBSIDIAN_VAULT" ]; then
    OBSIDIAN_AVAILABLE=true
fi
echo "Obsidian available: $OBSIDIAN_AVAILABLE"
```

---

### Step 3: Save Session Notes to Obsidian

**If Obsidian is available**, offer to save session notes:

```
Save session notes to Obsidian before clearing?

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]:
```

- **Choice 1 (Default):** Check project config, create/append date-based note in `sessions-history/`
- **Choice 2 (Custom):** Ask for subfolder, filename, and theme
- **Choice 3 (Skip):** Proceed to next step

> See `safe-clear/obsidian-integration.md` for full project configuration logic, note templates, and file creation code.

Analyze the conversation and create succinct notes covering:
- What was accomplished (3-5 bullets)
- Key decisions and rationale (if any)
- Important discoveries (if any)
- Context for next session (current task, next steps, open questions)

---

### Step 4: Update MANIFEST (Optional)

Check if MANIFEST files exist in the project:

```bash
MANIFEST_EXISTS=false
if find . -name "MANIFEST.md" -not -path "*/deprecated/*" 2>/dev/null | grep -q .; then
    MANIFEST_EXISTS=true
fi
```

**If MANIFEST files exist**, offer to update them. If user agrees, execute `/update-manifest` using the same session context collected for Obsidian notes. This will:
- Detect modified directories from this session
- Update file lists and timestamps
- Add session context to "Notes for Resuming Work"
- Verify file existence

---

### Step 5: Run Update Skills Command

```
Reviewing session for skill updates...

Would you like to update skills with knowledge from this session?
Update skills? (y/n):
```

If user agrees, execute `/update-skills` focusing on:
- New patterns or solutions discovered
- Problems solved and their solutions
- Workflow improvements and best practices
- Common errors and their fixes

Present updates organized by priority and wait for user approval before applying.

---

### Step 6: Confirm Context Clear

Present final confirmation showing what was preserved:

```
Ready to clear context

Session knowledge preserved:
  • Obsidian notes: [Saved / Skipped / Not available]
  • MANIFEST updates: [Updated / Skipped / Not available]
  • Skill updates: [Applied / Skipped]

Clear context now? (y/n):
```

**If confirmed:** Show summary, then instruct user to use built-in context clear or restart session (Ctrl+D).

**If cancelled:** Inform user that notes and skill updates (if selected) have been saved, and they can continue working.

---

## Command Flags

| Flag | Effect |
|------|--------|
| `--no-obsidian` | Skip Obsidian notes prompt |
| `--no-skills` | Skip skill updates prompt |
| `--quick` | Save notes automatically, skip skills |

> See `safe-clear/reference.md` for flag implementation details and error handling.
