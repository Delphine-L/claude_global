---
name: sync-skills
description: Sync project with $CLAUDE_METADATA - detect new skills/commands to symlink
---

Compare this project's current skills and commands with what's available in `$CLAUDE_METADATA` and identify new additions.

## Your Task

### Step 1: Analyze Current Project

**Check what's currently symlinked:**
```bash
# Current skills
ls -la .claude/skills/ 2>/dev/null | grep "^l" | awk '{print $9, "->", $11}'

# Current commands
ls -la .claude/commands/ 2>/dev/null | grep "^l" | awk '{print $9, "->", $11}'
```

**Extract names of currently linked skills and commands:**
```bash
# Skill names
current_skills=$(ls .claude/skills/ 2>/dev/null | sort)

# Command names
current_commands=$(ls .claude/commands/ 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.md$//' | sort)
```

### Step 2: Scan $CLAUDE_METADATA

**Find all available skills:**
```bash
# Global skills
ls $CLAUDE_METADATA/.claude/skills/ 2>/dev/null

# Project-specific skills
ls $CLAUDE_METADATA/skills/ 2>/dev/null
```

**Find all available commands:**
```bash
# All command categories
ls $CLAUDE_METADATA/commands/*/ 2>/dev/null | xargs -n1 basename | sed 's/\.md$//'
```

### Step 3: Compare and Categorize

**Categorize into:**
1. **NEW** - Available in $CLAUDE_METADATA but not yet symlinked here
2. **CURRENT** - Already symlinked
3. **BROKEN** - Symlinked but source doesn't exist (rare)

### Step 4: Present Findings

## Output Format

```
# Sync Status for $PWD

## Currently Linked

### Global Skills ✅
- token-efficiency (v1.3.0)
- claude-collaboration (v1.0.0)
- galaxy-automation (v1.0.0)

### Project Skills ✅
- vgp-pipeline (v2.0.0)
- galaxy-tool-wrapping (v1.0.0)

### Commands ✅
- /update-skills (global)
- /list-skills (global)
- /setup-project (global)
- /check-status (vgp-pipeline)

---

## NEW Skills Available 🆕

### Global Skills
- ❌ None - all global skills already linked ✅

### Project-Specific Skills
- **conda-recipe** (v1.0.0)
  - Expert in conda/bioconda recipe building
  - Recommended for: bioconda repositories
  - Symlink: `ln -s $CLAUDE_METADATA/skills/conda-recipe .claude/skills/conda-recipe`

- **galaxy-workflow-development**
  - Galaxy workflow development with IWC standards
  - Recommended for: Galaxy workflow repositories
  - Symlink: `ln -s $CLAUDE_METADATA/skills/galaxy-workflow-development .claude/skills/galaxy-workflow-development`

### New Commands
- **galaxy-workflow-development/beautify-export-wkfl** (.md)
  - Beautify and export Galaxy workflows
  - Symlink: `ln -s $CLAUDE_METADATA/commands/galaxy-workflow-development/beautify-export-wkfl.md .claude/commands/`

---

## Recommended Actions

Based on this project's structure, I recommend:

1. **Essential (if missing):**
   ```bash
   # These should be in EVERY project
   ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/token-efficiency
   ln -s $CLAUDE_METADATA/.claude/skills/claude-collaboration .claude/skills/claude-collaboration
   ln -s $CLAUDE_METADATA/.claude/skills/galaxy-automation .claude/skills/galaxy-automation
   ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
   ```

2. **Project-Specific (detected from codebase):**
   ```bash
   # Detected: recipes/ directory → bioconda repository
   ln -s $CLAUDE_METADATA/skills/conda-recipe .claude/skills/conda-recipe

   # OR

   # Detected: *.ga files → Galaxy workflow repository
   ln -s $CLAUDE_METADATA/skills/galaxy-workflow-development .claude/skills/galaxy-workflow-development
   ```

3. **Optional (based on your needs):**
   - List other available skills
   - User chooses

---

**Would you like me to symlink any of these new skills/commands?**
```

### Step 5: Interactive Symlinking

If user approves, execute the symlinks:

```bash
# Create directories if needed
mkdir -p .claude/skills .claude/commands

# Symlink as requested
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name
ln -s $CLAUDE_METADATA/commands/category/command-name.md .claude/commands/

# Verify
ls -la .claude/skills/
ls -la .claude/commands/
```

### Step 6: Suggest Git Commit

If in git repository and changes made:
```bash
git status .claude/

# Suggest commit message
git add .claude/
git commit -m "Sync Claude Code skills and commands

Added new skills:
- skill-name (description)

Added new commands:
- /command-name

Synced from $CLAUDE_METADATA"
```

## Detection Logic for Project Type

**Use these indicators to recommend skills:**

```bash
# VGP pipeline ORCHESTRATION CODEBASE (not just any VGP-related project)
# Only recommend if the actual orchestration Python code exists
if [ -f "run_all.py" ] && [ -d "batch_vgp_run/" ]; then
  recommend: vgp-pipeline + VGP commands
  note: "Detected VGP pipeline orchestration codebase"
fi

# Bioconda recipes
if ls -d recipes/ 2>/dev/null | grep -q recipes; then
  recommend: conda-recipe
  note: "Detected bioconda recipes directory"
fi

# Galaxy workflows (general)
if ls *.ga 2>/dev/null | head -1; then
  recommend: galaxy-workflow-development
  note: "Detected Galaxy workflow files (.ga)"
fi

# Galaxy tools repository
if ls -d tools/ 2>/dev/null | grep -q tools; then
  recommend: galaxy-tool-wrapping
  note: "Detected Galaxy tools directory"
fi
```

**IMPORTANT for VGP-related projects:**
- Only recommend `vgp-pipeline` skill if `run_all.py` AND `batch_vgp_run/` directory exist
- If project has VGP workflows (.ga files) but NO orchestration code, recommend `galaxy-workflow-development` instead
- If project is developing VGP tools, recommend `galaxy-tool-wrapping` instead
- The `vgp-pipeline` skill is specifically for the orchestration codebase, not general VGP development

## Special Cases

### No .claude/ Directory Yet
```
⚠️  No .claude/ directory found.

This project hasn't been set up for Claude Code yet.

Would you like me to run /setup-project instead?
```

### Everything Up to Date
```
✅ All synced!

Your project has all available skills and commands that are relevant.

Current setup:
- 2 global skills ✅
- X project skills ✅
- Y commands ✅

No new skills or commands available.
```

### Broken Symlinks
```
⚠️  Found broken symlinks:

.claude/skills/old-skill → $CLAUDE_METADATA/skills/old-skill (NOT FOUND)

These skills may have been renamed or removed.

Recommended actions:
1. Remove broken symlink: `rm .claude/skills/old-skill`
2. Check if skill was renamed
3. Run /list-skills to see current skills
```

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
