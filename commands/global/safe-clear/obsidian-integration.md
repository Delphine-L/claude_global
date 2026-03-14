# Obsidian Integration Details

Supporting file for `/safe-clear` command. Contains detailed Obsidian setup, note templates, and file creation logic.

---

## Choice 1: Default Mode (Date-based in sessions-history/)

### Step 2a: Check for Project Configuration

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

## Choice 2: Custom Mode

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

## Choice 3: Skip

```bash
echo "Skipping Obsidian notes..."
echo ""
# Proceed to next step
```

---

## Note Templates

### Default Mode Template (no theme)

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

### Custom Mode Template (with theme)

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

---

## File Creation Logic

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
