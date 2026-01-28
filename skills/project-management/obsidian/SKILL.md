---
name: obsidian
description: Integration with Obsidian vault for managing notes, tasks, and knowledge when working with Claude. Supports adding notes, creating tasks, and organizing project documentation.
version: 1.0.0
---

# Obsidian Integration

Expert guidance for integrating Claude workflows with Obsidian vault, including note creation, task management, and knowledge organization using Obsidian's markdown-based system.

## When to Use This Skill

- Creating notes during development sessions with Claude
- Tracking tasks and TODOs in Obsidian
- Documenting decisions and solutions discovered with Claude
- Building a knowledge base of project insights
- Organizing research findings from Claude sessions
- Creating meeting notes or session summaries

## Core Principles

1. **Vault Location** - Use `$OBSIDIAN_VAULT` environment variable for vault path
2. **Always Ask User for Note Placement** - Never decide where to save notes without asking the user first. Show vault structure, suggest options, and let the user choose.
3. **Atomic Notes** - Each note focuses on a single concept or topic
4. **Linking** - Use wikilinks `[[note-name]]` to connect related ideas
5. **Tags** - Organize with hierarchical tags like `#project/feature`
6. **Tasks** - Use checkbox syntax for actionable items
7. **Timestamps** - Include dates for temporal context

## Vault Configuration

### Environment Setup

The Obsidian vault location is stored in the `$OBSIDIAN_VAULT` environment variable:

```bash
# Check vault location
echo $OBSIDIAN_VAULT

# Should return something like:
# /Users/username/Documents/Notes
```

If not set, you'll need to configure it in your shell profile:

```bash
# Add to ~/.zshrc or ~/.bashrc
export OBSIDIAN_VAULT="/path/to/your/vault"
```

## Project Organization in Vault

### Selecting Project Directory Location

When creating a new project's notes in Obsidian, ask the user where the project directory should be located within the vault:

**Workflow:**

1. **Show current vault structure** to help user decide
2. **Offer two options:**
   - **Option 1:** Root level - Project directory directly in vault root
   - **Option 2:** Custom path - User specifies subdirectory structure

3. **Create directory if it doesn't exist**

### Implementation Pattern

```python
import os
from pathlib import Path

# Get vault path
vault_path = Path(os.environ.get('OBSIDIAN_VAULT'))

# Show vault structure to user
print("📁 Current vault structure:")
print(f"   {vault_path}/")

# Show top-level directories (up to 2 levels)
for item in sorted(vault_path.iterdir()):
    if item.is_dir() and not item.name.startswith('.'):
        print(f"   ├── {item.name}/")
        # Show one level deeper
        for subitem in sorted(item.iterdir())[:3]:
            if subitem.is_dir() and not subitem.name.startswith('.'):
                print(f"   │   ├── {subitem.name}/")
        # Indicate if there are more
        remaining = len([x for x in item.iterdir() if x.is_dir()]) - 3
        if remaining > 0:
            print(f"   │   └── ... ({remaining} more)")

print()
print("Where should this project's notes be stored?")
print()
print("Options:")
print("  1. Root level (vault/project-name/)")
print("  2. Custom path (e.g., vault/Work/project-name/ or vault/Projects/Active/project-name/)")
print()

choice = input("Enter choice [1-2]: ")

if choice == "1":
    # Root level
    project_dir = vault_path / project_name
else:
    # Custom path
    print()
    print("Enter the parent directory path (relative to vault root).")
    print("Examples:")
    print("  - Work")
    print("  - Projects/Active")
    print("  - Personal/Research")
    print()
    parent_path = input("Parent directory: ").strip()

    # Clean and validate path
    parent_path = parent_path.strip('/')
    project_dir = vault_path / parent_path / project_name

# Create directory if it doesn't exist
project_dir.mkdir(parents=True, exist_ok=True)
print(f"✅ Project directory: {project_dir.relative_to(vault_path)}")
```

### Best Practices for Organization

**Root Level:**
- ✅ Quick access to frequently used projects
- ✅ Simple structure for small vaults
- ❌ Can become cluttered with many projects

**Organized Subdirectories:**
- ✅ Better organization for many projects
- ✅ Logical grouping (Work, Personal, Research, etc.)
- ✅ Easier to navigate in large vaults
- ✅ Better for team vaults with shared structure

**Recommended Structures:**

```
vault/
├── Work/
│   ├── project-a/
│   ├── project-b/
│   └── project-c/
├── Personal/
│   ├── hobby-project/
│   └── research/
├── Archive/
│   └── old-project/
└── Templates/
```

Or by status:

```
vault/
├── Active/
│   ├── project-a/
│   └── project-b/
├── Planning/
│   └── project-c/
├── Completed/
│   └── old-project/
└── Archive/
```

### Directory Creation Safety

**Always check before creating:**
```python
if project_dir.exists():
    print(f"⚠️  Directory already exists: {project_dir}")
    overwrite = input("Continue using this directory? (y/n): ")
    if overwrite.lower() != 'y':
        # Ask for different name or path
        return
else:
    # Create with parents
    project_dir.mkdir(parents=True, exist_ok=True)
    print(f"✅ Created directory: {project_dir}")
```

### Storing Project Configuration

Save the project directory path for future sessions:

```python
# In .claude/project-config
config_content = f"""obsidian_project={project_name}
obsidian_path={project_dir.relative_to(vault_path)}
"""

with open('.claude/project-config', 'w') as f:
    f.write(config_content)
```

This allows subsequent sessions to use the same directory without asking again.

## User Choice: Never Assume Note Placement

**CRITICAL PRINCIPLE**: When creating ANY note in Obsidian, ALWAYS ask the user where they want it saved. Never decide the location yourself, even if it seems obvious.

### Why This Matters

1. **User has context you don't** - They know how their vault is organized
2. **Flexibility is key** - Different notes may belong in different places
3. **Avoids reorganization work** - User won't need to move notes later
4. **Respects user's system** - Their vault organization is personal

### The Workflow for ANY Note Creation

**Step 1: Show Current Structure**
```python
# Display vault structure to help user decide
vault_path = Path(os.environ.get('OBSIDIAN_VAULT'))
print("📁 Current vault structure:")
print(f"   {vault_path.name}/")

for item in sorted(vault_path.iterdir())[:10]:
    if item.is_dir() and not item.name.startswith('.'):
        print(f"   ├── {item.name}/")
```

**Step 2: Suggest Options (Don't Decide)**
```python
print("\nWhere would you like to save this note?")
print()
print("Suggestions:")
print("  1. Root level - Notes/note-name.md")
print("  2. [Specific folder] - Notes/Folder/note-name.md")
print("  3. Custom path - You specify")
print()
```

**Step 3: Get User Input**
```python
choice = input("Enter choice or custom path: ").strip()
```

**Step 4: Create in Chosen Location**
```python
# Use their choice, don't override it
if choice == "1":
    note_path = vault_path / "note-name.md"
elif choice == "2":
    note_path = vault_path / "Folder" / "note-name.md"
else:
    # Custom path
    note_path = vault_path / choice / "note-name.md"

# Create directory if needed
note_path.parent.mkdir(parents=True, exist_ok=True)
```

### Examples of When to Ask

❌ **WRONG - Assuming location:**
```python
# Creating documentation note
note_path = vault_path / "Guides" / "How-to.md"  # DON'T DO THIS
```

✅ **RIGHT - Asking user:**
```python
# Show structure and suggest
print("Where should this documentation note be saved?")
print("Suggestions:")
print("  1. Root level (simple)")
print("  2. New 'Guides' folder (for documentation)")
print("  3. Existing 'Work' folder")
print("  4. Custom path")

choice = input("Your choice: ")
# Then create based on their input
```

### Exception: Project Session Notes

The ONLY exception is when using `/safe-exit` for project session notes:
- Configuration already exists in `.claude/project-config`
- User has previously chosen the project location
- All session notes for that project go to the same place

Even then, on FIRST use, always ask and save the choice.

### Summary

**Golden Rule**: If you're about to write a file to the Obsidian vault, STOP and ask the user where it should go first.

## Obsidian Markdown Syntax

### Wikilinks (Internal Links)

```markdown
# Link to another note
[[Note Name]]

# Link with custom display text
[[Note Name|Display Text]]

# Link to heading in another note
[[Note Name#Heading]]

# Link to block
[[Note Name#^block-id]]
```

### Tags

```markdown
# Simple tags
#tag

# Hierarchical tags
#project/feature
#status/in-progress
#type/note
#type/task

# Tags in YAML frontmatter
---
tags:
  - project/feature
  - status/active
---
```

### Tasks

```markdown
# Basic task
- [ ] Task to do

# Completed task
- [x] Completed task

# Task with priority
- [ ] High priority task ⚠️
- [ ] Medium priority task 🔸
- [ ] Low priority task 🔹

# Task with date (if using Obsidian Tasks plugin)
- [ ] Task 📅 2026-01-23
- [ ] Task ⏳ 2026-01-30
- [ ] Task ✅ 2026-01-20

# Task with metadata
- [ ] Implement feature #coding #high-priority @claude-session
```

### Callouts (Obsidian-specific)

```markdown
> [!note]
> This is a note callout

> [!tip]
> Helpful tip here

> [!warning]
> Important warning

> [!todo]
> Task to complete

> [!example]
> Example code or content

> [!quote]
> Quote or citation
```

## Note Templates

### Session Note Template

```markdown
---
date: {{date}}
type: session-note
tags:
  - claude-session
  - project/{{project-name}}
---

# Session: {{topic}} - {{date}}

## Context
What we're working on and why

## Summary
Key points and outcomes from this session

## Decisions
- Decision 1
- Decision 2

## Action Items
- [ ] Task 1
- [ ] Task 2

## Links
- [[Related Note 1]]
- [[Related Note 2]]

## Code References
- `file.py:123` - Description of code location

---
**Session with**: Claude
**Duration**: {{duration}}
```

### Technical Note Template

```markdown
---
date: {{date}}
type: technical-note
tags:
  - technical
  - {{topic}}
---

# {{Title}}

## Problem
Description of the issue or topic

## Solution
How it was resolved or implemented

## Implementation Details
```language
code example
```

## Related Concepts
- [[Concept 1]]
- [[Concept 2]]

## References
- External links or documentation

## Notes
Additional thoughts or considerations
```

### Task Note Template

```markdown
---
date: {{date}}
type: task
tags:
  - task
  - status/pending
project: {{project-name}}
---

# Task: {{task-name}}

## Description
What needs to be done

## Requirements
- Requirement 1
- Requirement 2

## Checklist
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Dependencies
- [[Related Task 1]]
- [[Related Task 2]]

## Notes
Additional context or considerations

## Completion
**Status**: Pending
**Priority**: Medium
**Due**: {{date}}
```

## Working with Claude: Common Patterns

### Pattern 1: Creating a Session Note

When starting a work session with Claude:

```bash
# Create new session note in Obsidian vault
cat > "$OBSIDIAN_VAULT/Sessions/$(date +%Y-%m-%d)-session.md" <<EOF
---
date: $(date +%Y-%m-%d)
type: session-note
tags:
  - claude-session
---

# Session: $(date +%Y-%m-%d)

## Context


## Summary


## Action Items
- [ ]

## Links

EOF
```

### Pattern 2: Adding Quick Notes

For quick insights during development:

```bash
# Append to daily note
echo "## $(date +%H:%M) - Quick Note

Content here

" >> "$OBSIDIAN_VAULT/Daily/$(date +%Y-%m-%d).md"
```

### Pattern 3: Creating Task from Claude Session

```bash
# Create task file
TASK_NAME="implement-feature-x"
cat > "$OBSIDIAN_VAULT/Tasks/$TASK_NAME.md" <<EOF
---
date: $(date +%Y-%m-%d)
type: task
tags:
  - task
  - status/pending
---

# Task: $TASK_NAME

## Description


## Checklist
- [ ]

## Created by
Claude session on $(date +%Y-%m-%d)
EOF
```

### Pattern 4: Documenting Code Solutions

```bash
# Create solution note
SOLUTION_NAME="fix-api-error"
cat > "$OBSIDIAN_VAULT/Solutions/$SOLUTION_NAME.md" <<EOF
---
date: $(date +%Y-%m-%d)
type: solution
tags:
  - solution
  - coding
---

# Solution: $SOLUTION_NAME

## Problem


## Solution


## Code
\`\`\`language
code here
\`\`\`

## Related
- [[Related Note]]
EOF
```

## Folder Organization for Claude Integration

Recommended folder structure within Obsidian vault:

```
$OBSIDIAN_VAULT/
├── Daily/                      # Daily notes
│   └── YYYY-MM-DD.md
├── Sessions/                   # Claude session notes
│   └── YYYY-MM-DD-topic.md
├── Tasks/                      # Task tracking
│   ├── active/
│   └── completed/
├── Projects/                   # Project documentation
│   └── project-name/
│       ├── index.md
│       ├── architecture.md
│       └── decisions.md
├── Solutions/                  # Code solutions and fixes
│   └── solution-name.md
├── Research/                   # Research notes
│   └── topic.md
├── Knowledge/                  # Permanent notes
│   └── concept.md
└── Templates/                  # Note templates
    ├── session.md
    ├── task.md
    └── solution.md
```

## Helper Functions for Obsidian Integration

### Bash Helper Functions

Add these to your shell profile for easy integration:

```bash
# Create new session note in Obsidian
obs-session() {
    local topic="${1:-general}"
    local date=$(date +%Y-%m-%d)
    local file="$OBSIDIAN_VAULT/Sessions/${date}-${topic}.md"

    cat > "$file" <<EOF
---
date: $date
type: session-note
tags:
  - claude-session
  - project/$topic
---

# Session: $topic - $date

## Context


## Summary


## Action Items
- [ ]

## Links

EOF

    echo "Created session note: $file"
}

# Create task in Obsidian
obs-task() {
    local task_name="$1"
    local date=$(date +%Y-%m-%d)
    local file="$OBSIDIAN_VAULT/Tasks/${task_name}.md"

    cat > "$file" <<EOF
---
date: $date
type: task
tags:
  - task
  - status/pending
---

# Task: $task_name

## Description


## Checklist
- [ ]

## Created
$date via Claude session
EOF

    echo "Created task: $file"
}

# Append to daily note
obs-note() {
    local date=$(date +%Y-%m-%d)
    local time=$(date +%H:%M)
    local daily_note="$OBSIDIAN_VAULT/Daily/${date}.md"

    # Create daily note if doesn't exist
    if [ ! -f "$daily_note" ]; then
        cat > "$daily_note" <<EOF
---
date: $date
type: daily-note
---

# $date

EOF
    fi

    # Append note
    cat >> "$daily_note" <<EOF

## $time


EOF

    echo "Added entry to daily note: $daily_note"
}

# Quick search in Obsidian vault
obs-search() {
    grep -r "$1" "$OBSIDIAN_VAULT" --include="*.md"
}
```

## Integration Workflow with Claude

### Before Session

1. **Set up environment**
   ```bash
   echo $OBSIDIAN_VAULT  # Verify vault location
   ```

2. **Create session note** (optional)
   ```bash
   obs-session "feature-implementation"
   ```

### During Session

1. **Add notes as you go**
   - Use Claude to create notes for important insights
   - Document decisions and reasoning
   - Track code locations with `file.py:line` references

2. **Create tasks for follow-ups**
   ```bash
   obs-task "refactor-authentication"
   ```

3. **Link to existing notes**
   - Reference related documentation
   - Build knowledge graph through links

### After Session

1. **Review and organize**
   - Add tags to notes
   - Create links between related notes
   - Update project index

2. **Update task status**
   - Mark completed tasks
   - Add new discovered tasks

3. **Archive session notes**
   - Move to appropriate project folder if needed
   - Link from project index

## Best Practices

### Note Creation

**DO:**
- ✅ **ALWAYS ask user where to save the note first** - Show vault structure and suggest options
- ✅ Create notes during the session, not after
- ✅ Use descriptive file names (kebab-case)
- ✅ Include YAML frontmatter with metadata
- ✅ Link to related notes and concepts
- ✅ Add relevant tags for organization
- ✅ Include timestamps for temporal context

**DON'T:**
- ❌ **Decide note location without asking user** - This is the #1 rule
- ❌ Create huge monolithic notes
- ❌ Forget to link related concepts
- ❌ Skip metadata and tags
- ❌ Use unclear or generic titles
- ❌ Duplicate information across notes

### Task Management

**DO:**
- ✅ Use checkbox syntax `- [ ]` for tasks
- ✅ Add priority indicators
- ✅ Link tasks to relevant notes
- ✅ Include context in task description
- ✅ Break down large tasks into subtasks

**DON'T:**
- ❌ Create tasks without context
- ❌ Leave tasks orphaned (unlinked)
- ❌ Forget to update task status
- ❌ Mix tasks and notes in disorganized way

### Linking and Tags

**DO:**
- ✅ Use wikilinks `[[note]]` liberally
- ✅ Create hierarchical tags `#project/area/topic`
- ✅ Link bidirectionally when relevant
- ✅ Tag by type, status, and project
- ✅ Build a web of knowledge

**DON'T:**
- ❌ Over-tag (diminishing returns)
- ❌ Use inconsistent tag hierarchies
- ❌ Create links without purpose
- ❌ Forget to use tag search features

## Obsidian Plugins for Claude Integration

### Recommended Plugins

1. **Templater** - Advanced templates with dynamic content
2. **Dataview** - Query and display notes dynamically
3. **Tasks** - Enhanced task management
4. **Calendar** - Visual daily note navigation
5. **Git** - Version control for vault (if using)
6. **Quick Add** - Rapid note creation with macros

### Dataview Examples for Claude Sessions

```dataview
# Recent Claude sessions
TABLE date, summary
FROM #claude-session
SORT date DESC
LIMIT 10
```

```dataview
# Pending tasks from sessions
TASK
FROM #claude-session
WHERE !completed
```

## Troubleshooting

### Issue 1: $OBSIDIAN_VAULT not set

**Problem**: Environment variable not defined

**Solution**:
```bash
# Add to shell profile
echo 'export OBSIDIAN_VAULT="/path/to/vault"' >> ~/.zshrc
source ~/.zshrc
```

### Issue 2: Note not appearing in Obsidian

**Problem**: File created but not visible

**Solution**:
- Ensure file has `.md` extension
- Check file permissions
- Verify path is within vault
- Refresh Obsidian file list

### Issue 3: Links not working

**Problem**: Wikilinks don't navigate correctly

**Solution**:
- Ensure exact note name match (case-sensitive)
- Check for file extension in link (shouldn't include `.md`)
- Verify linked note exists
- Use Obsidian's link autocomplete

### Issue 4: Frontmatter rendering in preview

**Problem**: YAML frontmatter shows as text

**Solution**:
- Ensure frontmatter is first thing in file
- Use proper YAML syntax (three dashes before and after)
- Check for trailing spaces

### Issue 5: Environment Variable Mismatches

**Symptom**: `TypeError: expected str, bytes or os.PathLike object, not NoneType`

**Cause**: Documentation uses different variable name than user's environment

**Diagnosis Steps**:
```bash
# Check which variable is actually set
echo $OBSIDIAN_VAULT
echo $OBSIDIAN_CLAUDE
echo $OBSIDIAN_PATH

# List all Obsidian-related variables
env | grep -i obsidian
```

**Common Variable Names**:
- `$OBSIDIAN_VAULT` (recommended standard)
- `$OBSIDIAN_CLAUDE` (older documentation)
- `$OBSIDIAN_PATH` (alternative)

**Resolution**:
1. Ask user which variable they use
2. Update ALL references systematically:
   ```bash
   # Find all references
   grep -r "OBSIDIAN_CLAUDE" $CLAUDE_METADATA/skills/obsidian/
   grep -r "OBSIDIAN_CLAUDE" $CLAUDE_METADATA/.claude/commands/safe-exit.md

   # Use Edit tool with replace_all=true for each file
   ```

3. Document the change:
   ```markdown
   ## Environment Variable Update
   Updated from `$OBSIDIAN_CLAUDE` → `$OBSIDIAN_VAULT`
   - Files modified: safe-exit.md (7 refs), obsidian/SKILL.md (21 refs)
   - Verified: 0 remaining old references
   ```

**Prevention**: When creating new integrations, check user's environment FIRST:
```bash
# Detect which variable exists
if [ -n "$OBSIDIAN_VAULT" ]; then
    VAULT_VAR="OBSIDIAN_VAULT"
elif [ -n "$OBSIDIAN_CLAUDE" ]; then
    VAULT_VAR="OBSIDIAN_CLAUDE"
else
    echo "Error: No Obsidian vault variable set"
fi
```

## Quick Reference

### Creating Notes with Claude

```bash
# Session note
cat > "$OBSIDIAN_VAULT/Sessions/$(date +%Y-%m-%d)-topic.md" <<'EOF'
---
date: 2026-01-23
type: session-note
tags: [claude-session]
---
# Content here
EOF

# Task note
cat > "$OBSIDIAN_VAULT/Tasks/task-name.md" <<'EOF'
---
date: 2026-01-23
type: task
tags: [task, status/pending]
---
# Task: task-name
- [ ] Step 1
EOF

# Quick append to daily
echo "## Note

Content" >> "$OBSIDIAN_VAULT/Daily/$(date +%Y-%m-%d).md"
```

### Essential Obsidian Syntax

```markdown
# Wikilinks
[[Note Name]]
[[Note#Heading]]
[[Note|Display Text]]

# Tags
#tag
#hierarchical/tag

# Tasks
- [ ] Pending
- [x] Done

# Callouts
> [!note]
> Content

# Block references
^block-id
[[Note#^block-id]]
```

## Integration with Other Skills

This skill works well with:
- **folder-organization** - Vault structure standards
- **managing-environments** - Development workflow
- **claude-collaboration** - Team knowledge sharing

## References and Resources

- [Obsidian Documentation](https://help.obsidian.md/)
- [Obsidian Community Plugins](https://obsidian.md/plugins)
- [Zettelkasten Method](https://zettelkasten.de/introduction/)
- [PARA Method](https://fortelabs.com/blog/para/) - Projects, Areas, Resources, Archives

---

**Remember**: The goal is to build a searchable, linked knowledge base that grows with each Claude session. Start simple, add structure as needed.
