# Sync-Skills: Output Format Reference

## Output Format

```
# Sync Status for $PWD

## Currently Linked

### Settings Health
- Global: ~/.claude/settings.local.json ✅ (X broad patterns)
- Project: .claude/settings.local.json — local file ✅ (Y project-specific rules)

### Essential Global Skills ✅
Claude Meta:
- token-efficiency (v1.4.0)
- collaboration (v1.0.0)

Project Management:
- folder-organization (v1.0.0)
- managing-environments (v1.1.0)
- obsidian (v1.0.0)
- data-backup (v2.0.0)

Collaboration:
- hackmd
- project-sharing (v1.1.0)

### Project-Specific Skills ✅
- vgp-pipeline (v2.0.0)
- galaxy-tool-wrapping (v1.0.0)

### Commands ✅
- /update-skills (global)
- /list-skills (global)
- /setup-project (global)
- /check-status (vgp-pipeline)

---

## NEW Skills Available 🆕

### Essential Global Skills
- ❌ None - all essential skills already linked ✅

### Project-Specific Skills
- **conda-recipe** (v1.0.0)
  - Expert in conda/bioconda recipe building
  - Recommended for: bioconda repositories
  - Symlink: `ln -s $CLAUDE_METADATA/skills/conda-recipe .claude/skills/conda-recipe`

- **galaxy-workflow-development**
  - Galaxy workflow development with IWC standards
  - Recommended for: Galaxy workflow repositories
  - Symlink: `ln -s $CLAUDE_METADATA/skills/galaxy-workflow-development .claude/skills/galaxy-workflow-development`

### New Global Commands 🆕
- **generate-manifest** - Generate project manifest
- **read-manifest** - Read project manifest
- **update-manifest** - Update project manifest

To symlink all new global commands at once:
```bash
# Symlink all missing global commands
for cmd in $CLAUDE_METADATA/commands/global/*.md; do
  cmd_name=$(basename "$cmd")
  if [ ! -e ".claude/commands/$cmd_name" ]; then
    ln -s "$cmd" ".claude/commands/$cmd_name"
  fi
done
```

### New Project-Specific Commands
- **galaxy-workflow-development/beautify-export-wkfl** (.md)
  - Beautify and export Galaxy workflows
  - Symlink: `ln -s $CLAUDE_METADATA/commands/galaxy-workflow-development/beautify-export-wkfl.md .claude/commands/beautify-export-wkfl.md`

---

## Recommended Actions

Based on this project's structure, I recommend:

1. **Essential (if missing):**
   ```bash
   PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

   # These should be in EVERY project (symlinked at git root)

   # Claude Meta
   ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency "$PROJECT_ROOT/.claude/skills/token-efficiency"
   ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration "$PROJECT_ROOT/.claude/skills/collaboration"

   # Project Management
   ln -s $CLAUDE_METADATA/skills/project-management/folder-organization "$PROJECT_ROOT/.claude/skills/folder-organization"
   ln -s $CLAUDE_METADATA/skills/project-management/managing-environments "$PROJECT_ROOT/.claude/skills/managing-environments"
   ln -s $CLAUDE_METADATA/skills/project-management/obsidian "$PROJECT_ROOT/.claude/skills/obsidian"
   ln -s $CLAUDE_METADATA/skills/project-management/data-backup "$PROJECT_ROOT/.claude/skills/data-backup"

   # Collaboration
   ln -s $CLAUDE_METADATA/skills/collaboration/hackmd "$PROJECT_ROOT/.claude/skills/hackmd"
   ln -s $CLAUDE_METADATA/skills/collaboration/project-sharing "$PROJECT_ROOT/.claude/skills/project-sharing"

   # Global commands (symlink all at once)
   for cmd in $CLAUDE_METADATA/commands/global/*.md; do
     cmd_name=$(basename "$cmd")
     [ ! -e "$PROJECT_ROOT/.claude/commands/$cmd_name" ] && ln -s "$cmd" "$PROJECT_ROOT/.claude/commands/$cmd_name"
   done
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
