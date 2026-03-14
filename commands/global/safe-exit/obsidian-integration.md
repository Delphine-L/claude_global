# Safe-Exit: Obsidian Integration Details

> Supporting file for `/safe-exit` command. See `commands/global/safe-exit.md` for the main workflow.

## Check for Obsidian Skill

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

## Prompt for Session Summary

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

## Choice 1: Default Mode (Date-based in sessions-history/)

### Check for Project Configuration

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

## Choice 2: Custom Mode

Same project configuration check as above, then ask for custom details:

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

## Choice 3: Skip

```bash
echo "Skipping Obsidian summary..."
echo ""
# Proceed to exit message
```

**Session Context Reuse:**
If session context was already collected for MANIFEST updates, reuse it here for the Obsidian summary.

---

## Summary Templates

### Default Mode (no theme) -- for appending to daily notes

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

### Custom Mode (with theme)

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

---

## Create or Append to Obsidian Note

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

---

## Summary Generation Guidelines

1. **Be succinct** - Keep each section brief (3-5 bullets max)
2. **Focus on substance** - What was actually accomplished, not process
3. **Identify tasks** - Any unfinished work mentioned in conversation
4. **Use clear language** - Avoid jargon where possible
5. **Add context** - Brief notes on why decisions were made (if relevant)
6. **Default mode formatting** - Use `## Session [HH:MM]` as header for appending to daily notes
7. **Omit empty sections** - If no key decisions or notes, don't include those sections
