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

3. **Symlink essential global skills automatically**:
   ```bash
   # These are ALWAYS recommended
   ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/token-efficiency
   ln -s $CLAUDE_METADATA/.claude/skills/claude-collaboration .claude/skills/claude-collaboration
   ln -s $CLAUDE_METADATA/.claude/skills/galaxy-automation .claude/skills/galaxy-automation
   ```

4. **Symlink useful global commands**:
   ```bash
   ln -s $CLAUDE_METADATA/commands/global/update-skills.md .claude/commands/
   ln -s $CLAUDE_METADATA/commands/global/list-skills.md .claude/commands/
   ```

5. **Detect project type** (if possible) and suggest relevant skills:

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

6. **Present project-specific skill recommendations**:

## Output Format

```
✅ Created .claude/skills/ and .claude/commands/

✅ Symlinked essential global skills:
   - token-efficiency (saves 80-90% tokens)
   - claude-collaboration (team best practices)
   - galaxy-automation (BioBlend & Planemo for Galaxy workflow automation)

✅ Symlinked useful global commands:
   - /update-skills (review and update skills)
   - /list-skills (show available skills)

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
git add .claude/
git commit -m "Add Claude Code skills: token-efficiency, claude-collaboration, galaxy-automation[, others]

Essential global skills for token optimization, team collaboration, and Galaxy automation.
[Additional project-specific skills if added]"
```

## Token Efficiency

- Use file existence checks (`ls`, `find`) instead of reading files
- Extract only frontmatter from skills (first 10 lines)
- Don't read entire skill files unnecessarily
