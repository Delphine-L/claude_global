---
name: safe-clear
description: Save session notes to Obsidian, update skills with session knowledge, then clear context to continue working
---

Save important session knowledge before clearing context to continue with a fresh slate.

**⚠️ Important:** Use `/safe-clear` instead of manually clearing to preserve session knowledge. This command:
1. Saves session notes to Obsidian
2. Captures learnings in skill updates
3. Clears context for fresh start

## ⛔ CRITICAL: Git Management

**NEVER perform ANY git operations** (add, commit, push, stash, etc.) for the user.

The user **always** manages git commits themselves. You may:
- ✅ Check git status and show uncommitted changes
- ✅ Suggest git commands the user could run
- ❌ NEVER run git add, commit, push, or any other git write operations

**The user wants full control over all git operations.**

## Your Task

### Step 1: Check for Git Repository

```bash
# Check if in git repository
IN_GIT_REPO=false
if git rev-parse --git-dir > /dev/null 2>&1; then
    IN_GIT_REPO=true
    echo "ℹ️  Git repository detected - using git for version control."
    echo ""
fi
```

**Note:** This command does not offer backup prompts. It's for:
- Saving session notes to Obsidian
- Updating skills with learnings
- Clearing context to continue fresh

For git repositories, use `git commit` to save work.

---

### Step 2: Check for Obsidian Integration

```bash
# Check if obsidian skill is available
OBSIDIAN_AVAILABLE=false
if [ -L ".claude/skills/obsidian" ] || [ -d ".claude/skills/obsidian" ]; then
    OBSIDIAN_AVAILABLE=true
fi

# Also check environment variable
if [ -n "$OBSIDIAN_VAULT" ]; then
    OBSIDIAN_AVAILABLE=true
fi

echo "Obsidian available: $OBSIDIAN_AVAILABLE"
```

---

### Step 3: Save Session Notes to Obsidian

**If Obsidian is available**, offer to save session notes:

```
📝 Save session notes to Obsidian before clearing?

This will create a note documenting:
  • What was accomplished in this session
  • Key decisions made
  • Important discoveries or patterns

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]:
```

#### Choice 1: Default Mode (Date-based in sessions-history/)

**Step 2a: Check for Project Configuration**

```bash
PROJECT_CONFIG_FILE=".claude/project-config"

if [ -f "$PROJECT_CONFIG_FILE" ]; then
    # Read existing configuration
    PROJECT_NAME=$(grep "^obsidian_project=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
    OBSIDIAN_PATH=$(grep "^obsidian_path=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
    OBSIDIAN_PATH=${OBSIDIAN_PATH:-$PROJECT_NAME}
else
    # First time setup
    echo ""
    echo "📁 First time using Obsidian with this project."
    echo ""
    read -p "Enter project name (e.g., 'genome-analysis'): " PROJECT_NAME

    # Show vault structure
    echo ""
    echo "📁 Current vault structure:"
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
        echo "Enter parent directory path (relative to vault root)."
        echo "Examples: Work, Projects/Active, Personal/Research"
        echo ""
        read -p "Parent directory: " PARENT_DIR
        PARENT_DIR=$(echo "$PARENT_DIR" | sed 's:^/::; s:/$::')
        OBSIDIAN_PATH="$PARENT_DIR/$PROJECT_NAME"
    else
        OBSIDIAN_PATH="$PROJECT_NAME"
    fi

    # Save configuration
    mkdir -p .claude
    cat > "$PROJECT_CONFIG_FILE" << EOF
obsidian_project=$PROJECT_NAME
obsidian_path=$OBSIDIAN_PATH
EOF
    echo "✅ Project configuration saved"
    echo "   Directory: $OBSIDIAN_PATH"
fi

# Set subfolder and filename for default mode
SUBFOLDER="sessions-history"
USE_THEME=false
```

#### Choice 2: Custom Mode

**Step 2a: Same configuration check as above**

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
echo "Skipping Obsidian notes..."
echo ""
# Proceed to Step 3
```

**Step 2b: Generate Session Notes**

Analyze the conversation and create succinct notes.

**For DEFAULT mode (no theme):**

```markdown
## Session [HH:MM]

### What Was Accomplished

[List 3-5 key accomplishments from this session]
- Implemented X feature with Y approach
- Fixed Z bug by adjusting configuration
- Created documentation for new workflow
- Analyzed data and identified key patterns

### Key Decisions & Rationale

[List important decisions made - 2-3 bullets if any, otherwise omit section]
- Chose approach A over B because of performance/simplicity/compatibility
- Decided to refactor component X for better maintainability

### Important Discoveries

[Any patterns, insights, or learnings discovered - otherwise omit section]
- Found that X performs better when Y is configured
- Discovered pattern in data suggesting Z
- Identified that approach A works well for use case B

### Context for Next Session

[What should be remembered when resuming]
- Currently working on: [specific task]
- Next steps: [what comes next]
- Open questions: [any unresolved questions]

### Notes

[Any other relevant context - optional, omit if none]

---
```

**For CUSTOM mode (with theme):**

```markdown
# Session Notes

**Project:** [Project Name]
**Date:** [YYYY-MM-DD HH:MM]
**Focus:** [Session Theme]

## What Was Accomplished

[Same as above]

## Key Decisions & Rationale

[Same as above]

## Important Discoveries

[Same as above]

## Context for Next Session

[Same as above]

## Notes

[Same as above]

---
*Session cleared at [timestamp] - Ready for fresh context*
```

**Step 2c: Create or Append to Obsidian Note**

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
        f.write(notes_content)
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
        f.write(notes_content)
    action = "saved to"

print(f"✅ Session notes {action}: {OBSIDIAN_PATH}/{SUBFOLDER}/{filename}")
```

---

### Step 4: Run Update Skills Command

Capture session learnings in skill updates:

```
🧠 Reviewing session for skill updates...

Would you like to update skills with knowledge from this session?

This will:
  • Analyze what was learned
  • Suggest relevant skill updates
  • Let you approve changes before applying

Update skills? (y/n):
```

#### If User Chooses Yes

```bash
echo ""
echo "Running /update-skills command..."
echo ""

# Execute the update-skills command
# This will analyze the conversation and suggest updates
```

**Tell Claude:**
```
Please execute the /update-skills command to review this session and suggest skill updates.

Focus on:
- New patterns or solutions discovered
- Problems solved and their solutions
- Workflow improvements
- Best practices identified
- Common errors and their fixes

Present updates organized by priority (high/medium/low) and wait for user approval before applying.
```

#### If User Chooses No

```bash
echo "Skipping skill updates..."
echo ""
```

---

### Step 5: Confirm Context Clear

Present final confirmation:

```
⚠️  Ready to clear context

Session knowledge preserved:
  • Obsidian notes: [Saved / Skipped / Not available]
  • Skill updates: [Applied / Skipped]

Context will be cleared to provide a fresh start for new work.
Your conversation history will be removed, but:
  ✓ Files remain unchanged
  ✓ Skills and commands remain available
  ✓ Project state preserved
  ✓ Session notes saved to Obsidian

This is useful when:
  • Switching to a different task
  • Starting fresh after long session
  • Context is getting too large
  • Want clean slate for new work

Clear context now? (y/n):
```

#### If User Confirms (y)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context Clear Summary:

Project: [current directory]
Session notes: [Saved/Appended to $OBSIDIAN_PATH/sessions-history/YYYY-MM-DD.md / Custom location / Skipped]
Skills updated: [Yes / No]
Context: Cleared ✓

💡 Your session notes are preserved in Obsidian
   Review them when you return: [ProjectName]/sessions-history/

💡 Skills have been updated with session knowledge
   Future sessions benefit from what was learned today.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context cleared. Ready for fresh start! 🔄
```

**Then execute the actual context clear:**

```bash
# Claude Code's context clear mechanism
# The actual implementation depends on Claude Code's capabilities

# Since there's no built-in /clear command, inform user:
echo ""
echo "Note: To clear context in Claude Code:"
echo "  • Use the built-in context clear option (if available)"
echo "  • Or restart the session (Ctrl+D and restart)"
echo ""
echo "Your session knowledge is safely preserved in:"
if [ "$OBSIDIAN_AVAILABLE" = "true" ]; then
    echo "  • Obsidian vault: $OBSIDIAN_PATH/sessions-history/"
fi
echo "  • Updated skills in: \$CLAUDE_METADATA/skills/"
```

#### If User Cancels (n)

```bash
echo ""
echo "Context clear cancelled. Session continues."
echo ""
echo "Your notes and skill updates (if selected) have been saved."
echo "You can continue working with the current context."
```

---

## Command Flags (Optional)

Support flags for quick workflows:

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

## Example Interactions

### Example 1: Default Mode (Date-based)

```
User: /safe-clear

📝 Save session notes to Obsidian before clearing?

This will create a note documenting:
  • What was accomplished in this session
  • Key decisions made
  • Important discoveries or patterns

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]: 1

✍️ Generating session notes...

📝 Appending to existing note: 2026-02-05.md
✅ Session notes appended to: genome-pipeline/sessions-history/2026-02-05.md

🧠 Reviewing session for skill updates...

Would you like to update skills with knowledge from this session?

Update skills? (y/n): y

Running /update-skills command...

[update-skills runs and shows suggested updates]

✅ 3 skills updated with session knowledge

⚠️  Ready to clear context

Session knowledge preserved:
  • Obsidian notes: Appended
  • Skill updates: Applied

Clear context now? (y/n): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context Clear Summary:

Project: genome-pipeline
Session notes: Appended to genome-pipeline/sessions-history/2026-02-05.md
Skills updated: Yes (3 skills)
Context: Cleared ✓

💡 Your session notes are preserved in Obsidian
   Review them when you return: genome-pipeline/sessions-history/

💡 Skills updated with session knowledge

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context cleared. Ready for fresh start! 🔄
```

### Example 2: Custom Mode

```
User: /safe-clear

📝 Save session notes to Obsidian before clearing?

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]: 2

📝 Custom note configuration:

Subfolder within project (e.g., 'meetings', 'sprints'): sprints

Note filename (without .md, e.g., 'sprint-review', '2026-02-05-planning'): sprint-15-retrospective

Session theme/topic: Sprint 15 Review and Planning

✍️ Generating session notes...

📝 Creating new note: sprint-15-retrospective.md
✅ Session notes saved to: genome-pipeline/sprints/sprint-15-retrospective.md

🧠 Reviewing session for skill updates...

Would you like to update skills with knowledge from this session?

Update skills? (y/n): n

Skipping skill updates...

⚠️  Ready to clear context

Session knowledge preserved:
  • Obsidian notes: Saved
  • Skill updates: Skipped

Clear context now? (y/n): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context Clear Summary:

Session notes: Saved to genome-pipeline/sprints/sprint-15-retrospective.md
Skills updated: Skipped
Context: Cleared ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context cleared. Ready for fresh start! 🔄
```

### Example 3: Default Mode Note Structure (Multiple Sessions per Day)

**File:** `genome-pipeline/sessions-history/2026-02-05.md`

```markdown
---
type: session
project: genome-pipeline
date: 2026-02-05
tags:
  - session
  - dump
status: completed
---

# 2026-02-05

## Session 09:30

### What Was Accomplished

- Implemented pathway enrichment analysis using Fisher's exact test
- Created visualization script for pathway networks
- Added statistical correction (Benjamini-Hochberg FDR)

### Key Decisions & Rationale

- Chose Fisher's exact test over hypergeometric due to small sample sizes
- FDR correction at 0.05 threshold (standard in field)

### Context for Next Session

- Currently working on: pathway visualization improvements
- Next steps: add gene-level annotations to network

---

## Session 14:30

### What Was Accomplished

- Added gene-level annotations to network visualization
- Tested on sample dataset with 200 genes
- Created export functionality for Cytoscape

### Important Discoveries

- Found that pathway overlap affects enrichment scores
- Background gene set selection significantly impacts results
- Need to filter pathways with <5 genes for reliable statistics

### Context for Next Session

- Next steps: implement pathway clustering
- Open questions: best way to handle overlapping pathways

### Notes

Consider using semantic similarity for pathway clustering to reduce redundancy.

---
```

**Benefits of this structure:**
- All work for a given day in one file (easy to review)
- Sessions appended chronologically with timestamps
- Can see progression of work throughout the day
- Searchable by date in Obsidian

---

## Summary

The `/safe-clear` command provides:

✅ **Knowledge preservation** - Session notes saved to Obsidian
✅ **Skill capture** - Learnings integrated into skills
✅ **Fresh context** - Clean slate for new work
✅ **Continuity** - Notes explain where you left off
✅ **Flexibility** - Skip notes or skills with flags
✅ **Safe workflow** - Never lose session knowledge

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

This ensures you can freely clear context without losing valuable session knowledge!
