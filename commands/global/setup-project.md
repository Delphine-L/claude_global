---
name: setup-project
description: Set up Claude Code skills for a new project
---

Set up Claude Code skills and commands for this project with intelligent defaults.

## Your Task

1. **Check if `.claude/` already exists**:
   ```bash
   ls -la .claude/ 2>/dev/null
   ```
   - If exists: Show current setup and ask if user wants to add more
   - If not exists: Proceed with fresh setup

2. **Create directory structure**:
   ```bash
   mkdir -p .claude/skills .claude/commands
   ```

3. **Add .claude/ to .gitignore if in a git repository**:
   ```bash
   # Check if we're in a git repository
   if git rev-parse --git-dir > /dev/null 2>&1; then
     # Check if .gitignore exists
     if [ -f .gitignore ]; then
       # Check if .claude/ is already in .gitignore
       if ! grep -q "^\.claude/" .gitignore; then
         cat >> .gitignore << 'EOF'

# Claude Code (local skills and settings)
.claude/
# Exception: Keep project configuration
!.claude/project-config
EOF
         echo "✅ Added .claude/ to .gitignore (excluding project-config)"
       else
         echo "✅ .claude/ already in .gitignore"
       fi
     else
       # Create .gitignore with .claude/
       cat > .gitignore << 'EOF'
# Claude Code (local skills and settings)
.claude/
# Exception: Keep project configuration
!.claude/project-config
EOF
       echo "✅ Created .gitignore and added .claude/ (excluding project-config)"
     fi
   fi
   ```

4. **Symlink essential global skills automatically**:
   ```bash
   # Claude Meta - ALWAYS recommended
   ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/token-efficiency
   ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/collaboration

   # Project Management - ALWAYS recommended
   ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/folder-organization
   ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/managing-environments
   ln -s $CLAUDE_METADATA/skills/project-management/obsidian .claude/skills/obsidian
   ln -s $CLAUDE_METADATA/skills/project-management/data-backup .claude/skills/data-backup

   # Collaboration - ALWAYS recommended
   ln -s $CLAUDE_METADATA/skills/collaboration/hackmd .claude/skills/hackmd
   ln -s $CLAUDE_METADATA/skills/collaboration/project-sharing .claude/skills/project-sharing
   ```

5. **Symlink useful global commands**:
   ```bash
   ln -s $CLAUDE_METADATA/commands/global/update-skills.md .claude/commands/
   ln -s $CLAUDE_METADATA/commands/global/list-skills.md .claude/commands/
   ln -s $CLAUDE_METADATA/commands/global/update-manifest.md .claude/commands/
   ln -s $CLAUDE_METADATA/commands/global/deprecate-file.md .claude/commands/
   ```

6. **Symlink global settings for consistent permissions**:
   ```bash
   # Check if global settings.local.json exists
   if [ -f "$CLAUDE_METADATA/.claude/settings.local.json" ]; then
     # Remove existing settings if it's not a symlink
     if [ -f .claude/settings.local.json ] && [ ! -L .claude/settings.local.json ]; then
       echo "⚠️  Backing up existing settings.local.json to settings.local.json.backup"
       mv .claude/settings.local.json .claude/settings.local.json.backup
     fi

     # Create symlink if it doesn't exist
     if [ ! -e .claude/settings.local.json ]; then
       ln -s "$CLAUDE_METADATA/.claude/settings.local.json" .claude/settings.local.json
       echo "✅ Symlinked global settings.local.json (permissions will be consistent across projects)"
     else
       echo "✅ Settings already symlinked"
     fi
   fi
   ```

7. **Set up Obsidian folder (optional)**:

   Ask the user if they want to configure Obsidian integration:

   ```
   📝 Obsidian Integration Setup

   Would you like to set up an Obsidian folder for this project?
   This will store session notes, decisions, and project documentation.

   Set up Obsidian folder? (y/n/skip):
   ```

   **If user chooses 'y' or 'yes':**

   ```bash
   # Check if OBSIDIAN_VAULT environment variable is set
   if [ -z "$OBSIDIAN_VAULT" ]; then
     echo "⚠️  OBSIDIAN_VAULT environment variable not set"
     echo "Please set OBSIDIAN_VAULT to your Obsidian vault path in your shell config"
     echo "Example: export OBSIDIAN_VAULT=\"$HOME/Documents/ObsidianVault\""
     echo ""
     read -p "Enter Obsidian vault path (or press Enter to skip): " VAULT_PATH

     if [ -z "$VAULT_PATH" ]; then
       echo "Skipping Obsidian setup"
     else
       OBSIDIAN_VAULT="$VAULT_PATH"
     fi
   fi

   if [ -n "$OBSIDIAN_VAULT" ]; then
     # Show vault structure
     echo ""
     echo "📁 Current vault structure:"
     python3 << 'SHOW_VAULT'
import os
from pathlib import Path

vault_path = Path(os.environ.get('OBSIDIAN_VAULT', ''))
if not vault_path.exists():
    print("   (Vault not found)")
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
     echo "Project folder name for Obsidian:"
     echo "  Suggested: $(basename $PWD)"
     echo ""
     read -p "Enter project name [$(basename $PWD)]: " PROJECT_NAME
     PROJECT_NAME=${PROJECT_NAME:-$(basename $PWD)}

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
     cat > .claude/project-config << EOF
obsidian_project=$PROJECT_NAME
obsidian_path=$OBSIDIAN_PATH
EOF

     echo ""
     echo "✅ Obsidian configuration saved"
     echo "   Project name: $PROJECT_NAME"
     echo "   Vault path: $OBSIDIAN_PATH"
     echo "   Notes will be saved to: \$OBSIDIAN_VAULT/$OBSIDIAN_PATH/"
   fi
   ```

   **If user chooses 'n', 'no', or 'skip':**
   ```bash
   echo "Skipping Obsidian setup (can be configured later with /safe-exit or /safe-clear)"
   ```

8. **Detect project type** (if possible) and suggest relevant skills:

   **Check for indicators**:
   ```bash
   # VGP pipeline ORCHESTRATION CODEBASE (be specific!)
   # Only recommend if both run_all.py AND batch_vgp_run/ exist
   if [ -f "run_all.py" ] && [ -d "batch_vgp_run/" ]; then
     detect: VGP pipeline orchestration codebase
   fi

   # Galaxy tools repository
   if [ -d "tools/" ]; then
     detect: Galaxy tools repository
   fi

   # Galaxy workflows repository
   if ls *.ga 2>/dev/null | head -1; then
     detect: Galaxy workflows repository
   fi

   # Bioconda recipes
   if [ -d "recipes/" ]; then
     detect: Bioconda recipes repository
   fi

   # Python project (generic)
   if ls setup.py requirements.txt pyproject.toml 2>/dev/null; then
     detect: Python project
   fi
   ```

   **IMPORTANT:** Only recommend `vgp-pipeline` skill if BOTH `run_all.py` AND `batch_vgp_run/` directory exist. This skill is for the VGP orchestration codebase specifically, not for general VGP-related work.

9. **Present project-specific skill recommendations**:

## Output Format

```
✅ Created .claude/skills/ and .claude/commands/

✅ Added .claude/ to .gitignore (or created .gitignore with .claude/)

✅ Symlinked essential global skills:
   Claude Meta:
   - token-efficiency (saves 80-90% tokens)
   - collaboration (team best practices)

   Project Management:
   - folder-organization (project structure standards)
   - managing-environments (Python venv/conda management)
   - obsidian (note-taking and knowledge management)
   - data-backup (smart automated backups with skill integration)

   Collaboration:
   - hackmd (collaborative documentation with HackMD)
   - project-sharing (prepare packages for sharing)

✅ Symlinked essential global commands:
   - /command-help (show help for commands)
   - /safe-exit (end session with backup & notes)
   - /safe-clear (clear context with knowledge preservation)
   - /consolidate-notes (consolidate session notes with AI)
   - /backup (daily/milestone backups)
   - /share-project (prepare packages for sharing)
   - /update-skills (review and update skills)
   - /list-skills (show available skills)
   - /sync-skills (sync with global metadata)
   - /setup-environment (Python environment setup)
   - /cleanup-project (project cleanup)
   - /update-manifest (update MANIFEST files)
   - /deprecate-file (move files to deprecated/)

✅ Symlinked global settings.local.json:
   - Permissions will be consistent across all projects
   - Updates to global settings auto-apply to all projects

✅ Obsidian integration configured:
   - Project name: [project-name]
   - Notes location: $OBSIDIAN_VAULT/[path]/
   (or "Skipped - can be configured later")

🔍 Detected project type: [type] (or "Generic project")

📚 Recommended skills for this project:

[If VGP pipeline orchestration codebase detected (run_all.py + batch_vgp_run/)]:
  - vgp-pipeline (VGP pipeline orchestration codebase - Python automation system)
    Depends on: galaxy-automation (already symlinked ✅)
  + All VGP commands (/check-status, /debug-failed, etc.)
  Note: This is for the pipeline automation code, not general VGP development

[If Galaxy tools detected]:
  - galaxy-tool-wrapping (Galaxy tool development)

[If Galaxy workflows detected]:
  - galaxy-workflow-development (IWC workflow standards)
  Note: If VGP workflows but no orchestration code, use this instead of vgp-pipeline

[If bioconda recipes detected]:
  - conda-recipe (Conda/bioconda recipe building)

[If generic or multiple types]:
  Available skills:
  - vgp-pipeline
  - galaxy-tool-wrapping
  - galaxy-workflow-development
  - conda-recipe
  - claude-skill-management

Would you like me to symlink any of these additional skills?
```

## After User Selection

For each selected skill:
```bash
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name
```

For category-specific commands (e.g., VGP):
```bash
ln -s $CLAUDE_METADATA/commands/category/*.md .claude/commands/
```

## Final Verification

```bash
# Verify symlinks
ls -la .claude/skills/
ls -la .claude/commands/

# Confirm setup
echo "✅ Setup complete! Available commands:"
ls .claude/commands/*.md | xargs -n1 basename | sed 's/\.md$//' | sed 's/^/  \//'
```

## Suggested Git Commit

If in git repository, suggest:
```bash
git add .gitignore .claude/project-config
git commit -m "Configure Claude Code for this project

- Added .claude/ to .gitignore (local skills and symlinks)
- Committed .claude/project-config (project-specific configuration)
  - Obsidian integration: [project-name] at [path]

Symlinks to global skills are environment-specific and will be recreated
when setting up the project on a new machine using /setup-project."
```

**Note:**
- The `.claude/` directory (skills/commands symlinks) should NOT be committed due to .gitignore
- The `.claude/project-config` file IS committed (exception in .gitignore) as it contains project-specific settings like Obsidian folder configuration

## Token Efficiency

- Use file existence checks (`ls`, `find`) instead of reading files
- Extract only frontmatter from skills (first 10 lines)
- Don't read entire skill files unnecessarily
