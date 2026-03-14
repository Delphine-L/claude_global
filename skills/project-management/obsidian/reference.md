# Obsidian Reference

Quick reference for Obsidian markdown syntax, helper functions, plugins, Claude integration patterns, and troubleshooting.

> **Note**: Obsidian 1.12+ includes a native CLI. For CLI commands, see [cli-reference.md](cli-reference.md). The CLI replaces many of the bash patterns below. Prefer CLI for create, read, append, search, tasks, and property operations.

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
- [ ] High priority task (high)
- [ ] Medium priority task (medium)
- [ ] Low priority task (low)

# Task with date (if using Obsidian Tasks plugin)
- [ ] Task due 2026-01-23
- [ ] Task scheduled 2026-01-30
- [ ] Task done 2026-01-20

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
- **ALWAYS ask user where to save the note first** - Show vault structure and suggest options
- Create notes during the session, not after
- Use descriptive file names (kebab-case)
- Include YAML frontmatter with metadata
- Link to related notes and concepts
- Add relevant tags for organization
- Include timestamps for temporal context

**DON'T:**
- **Decide note location without asking user** - This is the #1 rule
- Create huge monolithic notes
- Forget to link related concepts
- Skip metadata and tags
- Use unclear or generic titles
- Duplicate information across notes

### Task Management

**DO:**
- Use checkbox syntax `- [ ]` for tasks
- Add priority indicators
- Link tasks to relevant notes
- Include context in task description
- Break down large tasks into subtasks

**DON'T:**
- Create tasks without context
- Leave tasks orphaned (unlinked)
- Forget to update task status
- Mix tasks and notes in disorganized way

### Linking and Tags

**DO:**
- Use wikilinks `[[note]]` liberally
- Create hierarchical tags `#project/area/topic`
- Link bidirectionally when relevant
- Tag by type, status, and project
- Build a web of knowledge

**DON'T:**
- Over-tag (diminishing returns)
- Use inconsistent tag hierarchies
- Create links without purpose
- Forget to use tag search features

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
   Updated from `$OBSIDIAN_CLAUDE` to `$OBSIDIAN_VAULT`
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
