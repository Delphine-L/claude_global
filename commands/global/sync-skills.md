---
name: sync-skills
description: Sync project with $CLAUDE_METADATA - detect new skills/commands to symlink
---

Compare this project's current skills and commands with what's available in `$CLAUDE_METADATA` and identify new additions.

> **Supporting files** (read as needed):
> - `commands/global/sync-skills/output-format.md` — Output template and recommended actions format
> - `commands/global/sync-skills/detection-logic.md` — Project type detection rules
> - `commands/global/sync-skills/special-cases.md` — Edge cases: broken symlinks, missing .claude/, symlinked settings

## Your Task

### Step 0: Resolve Project Root

**CRITICAL**: Skills and commands are stored at the **git repository root**, not in subdirectories.

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
echo "Git root: $PROJECT_ROOT"
echo "Current dir: $PWD"

if [ "$PROJECT_ROOT" != "$PWD" ]; then
  echo "NOTE: Working in subdirectory. Checking .claude/ at project root."
fi

if [ -d ".claude" ] && [ "$PROJECT_ROOT/.claude" != "$PWD/.claude" ]; then
  echo "WARNING: Subdirectory has its own .claude/ - may override root settings"
  ls "$PWD/.claude/" 2>/dev/null
fi
```

### Step 1: Analyze Current Project

**Check what's currently symlinked (at project root):**
```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# Current skills
ls -la "$PROJECT_ROOT/.claude/skills/" 2>/dev/null | grep "^l" | awk '{print $9, "->", $11}'

# Current commands
ls -la "$PROJECT_ROOT/.claude/commands/" 2>/dev/null | grep "^l" | awk '{print $9, "->", $11}'

# Check project settings
if [ -L "$PROJECT_ROOT/.claude/settings.local.json" ]; then
  echo "Settings: symlinked -> $(readlink "$PROJECT_ROOT/.claude/settings.local.json")"
elif [ -f "$PROJECT_ROOT/.claude/settings.local.json" ]; then
  echo "Settings: local file"
else
  echo "Settings: not found"
fi

# Check global settings
[ -f ~/.claude/settings.local.json ] && echo "Global settings: found" || echo "Global settings: NOT FOUND"
```

**Detect broken symlinks (CRITICAL):**
```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

for item in "$PROJECT_ROOT/.claude/skills/"* "$PROJECT_ROOT/.claude/commands/"*; do
  if [ -L "$item" ] && [ ! -e "$item" ]; then
    echo "BROKEN: $item -> $(readlink "$item")"
  fi
done
```

**Check for subdirectory settings overrides:**
```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
find "$PROJECT_ROOT" -path "*/.claude/settings.local.json" -not -path "$PROJECT_ROOT/.claude/settings.local.json" 2>/dev/null
```

### Step 1b: Verify Global Settings Health

```bash
if [ -f ~/.claude/settings.local.json ]; then
  echo "Global settings found"
  for pattern in 'Bash(ls:*)' 'Bash(cat:*)' 'Bash(echo:*)' 'Bash(git:*)' 'Bash(python3:*)'; do
    grep -q "$pattern" ~/.claude/settings.local.json 2>/dev/null && echo "  OK: $pattern" || echo "  MISSING: $pattern"
  done
else
  echo "No global settings at ~/.claude/settings.local.json"
  echo "  See $CLAUDE_METADATA/.claude/settings.local.json for reference."
fi
```

**Expected base patterns:** `Bash(ls:*)`, `Bash(cat:*)`, `Bash(head:*)`, `Bash(grep:*)`, `Bash(find:*)`, `Bash(tree:*)`, `Bash(git:*)`, `Bash(python3:*)`, `Bash(conda:*)`, `Bash(if:*)`, `Bash(for:*)`, `Bash(while:*)`, `Bash(test:*)`, `Read(path:$CLAUDE_METADATA/*)`, `Read(path:$OBSIDIAN_VAULT/*)`, `Skill(*)`, `SlashCommand(*)`, `WebSearch`, `WebFetch(domain:*)`

### Step 2: Scan $CLAUDE_METADATA

```bash
# Available skills
ls $CLAUDE_METADATA/.claude/skills/ 2>/dev/null
ls $CLAUDE_METADATA/skills/ 2>/dev/null

# Available commands
ls $CLAUDE_METADATA/commands/*/ 2>/dev/null | xargs -n1 basename | sed 's/\.md$//'
```

### Step 3: Compare and Categorize

Categorize into: **NEW** (available but not linked), **CURRENT** (already linked), **BROKEN** (link target missing).

### Step 4: Present Findings

Use the output format template from `commands/global/sync-skills/output-format.md`. Read that file for the full template with recommended actions.

Use project type detection rules from `commands/global/sync-skills/detection-logic.md` to recommend project-specific skills.

### Step 5: Interactive Symlinking

When user requests symlinking:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
mkdir -p "$PROJECT_ROOT/.claude/skills" "$PROJECT_ROOT/.claude/commands"

# For global commands — symlink ALL missing at once
for cmd in $CLAUDE_METADATA/commands/global/*.md; do
  cmd_name=$(basename "$cmd")
  if [ ! -e "$PROJECT_ROOT/.claude/commands/$cmd_name" ]; then
    ln -s "$cmd" "$PROJECT_ROOT/.claude/commands/$cmd_name"
    echo "Symlinked global command: $cmd_name"
  fi
done

# For skills and project-specific commands — symlink individually as requested
ln -s $CLAUDE_METADATA/skills/category/skill-name "$PROJECT_ROOT/.claude/skills/skill-name"
```

**Request handling:**
- "symlink global commands" --> symlink ALL missing global commands
- "symlink [skill-name]" --> symlink specific skill
- "symlink all new" --> confirm, then symlink all missing skills AND commands

### Step 6: Suggest Git Commit

If changes were made, suggest committing `.claude/` changes with a descriptive message.

### Special Cases

For edge cases (no .claude/ directory, symlinked settings, broken symlinks, subdirectory overrides, everything up to date), read `commands/global/sync-skills/special-cases.md`.

## Token Efficiency

- Use `ls` and file checks, not reading files
- Extract only frontmatter for descriptions (first 10 lines with grep)
- Don't read full skill files
- Use efficient bash commands for comparison
- Present summary, not raw output

## Related Commands

- `/list-skills` - Show all available skills with details
- `/setup-project` - Initial project setup with detection
- `/update-skills` - Update skills with new learnings

## When to Use

- After adding new skills to $CLAUDE_METADATA
- Periodically (monthly) to stay up to date
- When switching between projects
- After team members add new skills to shared repo
- When you see new skills mentioned in documentation
