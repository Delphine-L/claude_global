# Claude Code Quick Reference

Quick copy-paste prompts and commands for common tasks.

---

## New Project Setup

### Recommended Setup (with essentials + selective)

**RECOMMENDED for all new projects:**

```
Set up Claude Code for this project. First, symlink the essential global skills
(claude-meta/token-efficiency, claude-meta/collaboration, project-management/managing-environments,
and project-management/folder-organization) from $CLAUDE_METADATA/skills/
and ALL global commands from $CLAUDE_METADATA/commands/global/. Then show me
other available skills and let me choose which ones are relevant for this project.
```

**What you'll get:**
- ✅ **claude-meta/token-efficiency** - Saves 80-90% tokens, extends Claude Pro usage 5-10x
- ✅ **claude-meta/collaboration** - Best practices for skill management
- ✅ **project-management/managing-environments** - Development environment management (venv/conda)
- ✅ **project-management/folder-organization** - Project structure and organization
- ✅ **All Global commands**: `/update-skills`, `/list-skills`, `/setup-project`, `/setup-environment`, `/sync-skills`, `/cleanup-project`
- Plus any project-specific skills you choose (e.g., galaxy/automation for Galaxy projects)

**Quick alternative using the command:**
```
/setup-project
```
(if setup-project command is already symlinked)

---

### Basic Setup (All Skills)

```
Set up Claude Code skills and commands for this project. Create symlinks to all available skills and commands in $CLAUDE_METADATA.
```

---

### Selective Setup (Choose Specific Skills)

```
Set up Claude Code for this project. Show me available skills in $CLAUDE_METADATA and let me choose which ones to symlink.
```

**Note:** These prompts should still include token-efficiency and claude-collaboration automatically.

---

## Project-Specific Setups

### VGP Pipeline Project

```
Set up Claude Code for a VGP pipeline project. Symlink the essential global skills
(claude-meta/token-efficiency and claude-meta/collaboration) from $CLAUDE_METADATA/skills/,
ALL global commands from $CLAUDE_METADATA/commands/global/, plus the galaxy/automation,
bioinformatics/vgp-pipeline skills, and all VGP commands from $CLAUDE_METADATA/commands/vgp-pipeline/.
```

**What you'll get:**
- claude-meta/token-efficiency, claude-meta/collaboration (essential)
- galaxy/automation (for Galaxy API/workflow support)
- bioinformatics/vgp-pipeline skill (VGP-specific, depends on galaxy/automation)
- All VGP slash commands (/check-status, /debug-failed, etc.)

---

### Galaxy Tool Development

```
Set up Claude Code for Galaxy tool development. Symlink the essential global skills
(claude-meta/token-efficiency and claude-meta/collaboration) from $CLAUDE_METADATA/skills/,
ALL global commands from $CLAUDE_METADATA/commands/global/, plus the galaxy/automation
and galaxy/tool-wrapping skills.
```

**What you'll get:**
- claude-meta/token-efficiency, claude-meta/collaboration (essential)
- galaxy/automation (for Galaxy API support)
- galaxy/tool-wrapping skill with reference docs
- Ready for creating and testing Galaxy tools

---

### Galaxy Workflow Development

```
Set up Claude Code for Galaxy workflow development. Symlink the essential global
skills (claude-meta/token-efficiency and claude-meta/collaboration) from $CLAUDE_METADATA/skills/,
ALL global commands from $CLAUDE_METADATA/commands/global/, plus the galaxy/automation
and galaxy/workflow-development skills.
```

**What you'll get:**
- claude-meta/token-efficiency, claude-meta/collaboration (essential)
- galaxy/automation (for Galaxy API support)
- galaxy/workflow-development skill (IWC standards)
- Ready for creating Galaxy .ga workflows

---

### Bioconda Recipe Development

```
Set up Claude Code for bioconda recipe development. Symlink the essential global
skills (claude-meta/token-efficiency and claude-meta/collaboration) from $CLAUDE_METADATA/skills/,
ALL global commands from $CLAUDE_METADATA/commands/global/, plus the packaging/conda-recipe skill.
```

---

## Sync Existing Project

### Quick Method (if global commands already symlinked)
```
/sync-skills
```

---

### First Time Sync (global commands not yet symlinked)

**Copy-paste this prompt:**
```
Set up global commands from $CLAUDE_METADATA and sync this project with available
skills and commands. First, symlink all global commands from $CLAUDE_METADATA/commands/global/,
then run sync-skills to detect what else I should add.
```

**What this does:**
1. Creates `.claude/commands/` directory if needed
2. Symlinks all global commands
3. Runs `/sync-skills` to show what's available vs what's linked
4. Lets you choose additional skills to add

---

### Manual Sync

**When you've added new skills or commands to $CLAUDE_METADATA:**

```
Check what skills and commands are available in $CLAUDE_METADATA and compare with what's currently symlinked in this project. Show me what's new or missing, and let me choose which ones to add.
```

**Alternative (more specific):**
```
Synchronize this project's Claude Code skills and commands with $CLAUDE_METADATA. Show me:
1. What skills/commands are currently symlinked here
2. What's available in the global directory
3. What's new that I don't have yet
Then let me choose which new ones to add.
```

**Best practice:** Run `/sync-skills` monthly to stay up to date.

---

## Set Up Python Environment

### Plan environment (venv or conda)
```
/setup-environment
```

---

## After Productive Session

### Capture learnings
```
/update-skills
```

---

## End of Project/Feature

### Cleanup working documentation
```
/cleanup-project
```
(Removes TODO.md, NOTES.md, condenses verbose READMEs - only for files changed in your branch)

---

## Explore Available Skills

### Show all available
```
/list-skills
```

---

## What Claude Will Do

### For initial setup prompts

Claude will:
1. Create `.claude/skills/` and `.claude/commands/` directories
2. **Automatically symlink essential global skills** (claude-meta/token-efficiency, claude-meta/collaboration, project-management/managing-environments, project-management/folder-organization)
3. **Automatically symlink ALL global commands** (update-skills, list-skills, setup-project, setup-environment, sync-skills, cleanup-project)
4. List available skills/commands in `$CLAUDE_METADATA`
5. Create additional symlinks based on your request (e.g., galaxy/automation for Galaxy projects)
6. Verify all symlinks are working correctly

**Essential global skills always included:**
- `claude-meta/token-efficiency` - Optimizes token usage (80-90% savings)
- `claude-meta/collaboration` - Best practices for skill management
- `project-management/managing-environments` - Development environment management (venv/conda)
- `project-management/folder-organization` - Project structure and organization

**Global commands always included:**
- `/setup-project` - Set up new projects with intelligent defaults
- `/setup-environment` - Plan and create Python environment (venv/conda)
- `/list-skills` - Show all available skills
- `/sync-skills` - Sync project with available skills/commands
- `/update-skills` - Review session and suggest skill updates
- `/cleanup-project` - End-of-project cleanup for branch documentation

### For update/sync prompts

Claude will:
1. Check current symlinks in `.claude/skills/` and `.claude/commands/`
2. List all available skills/commands in `$CLAUDE_METADATA`
3. Show you what's new or not yet symlinked
4. Wait for you to choose which ones to add
5. Create symlinks for your selected items
6. Confirm the updates

---

## After Setup

Once set up, you can activate skills by:
- **Mentioning them by name**: "Use the vgp-pipeline skill to check workflow status"
- **Matching their description**: "Use the skill for Galaxy tool wrapping"
- **Context**: Claude activates automatically based on your request

---

## Manual Commands Reference

### Essential Global Skills (Always Include)
```bash
ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/collaboration
ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/managing-environments
ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/folder-organization
```

### Project-Specific Skills (Add as Needed)
```bash
# For Galaxy projects
ln -s $CLAUDE_METADATA/skills/galaxy/automation .claude/skills/automation
```

### All Global Commands (Highly Recommended)
```bash
mkdir -p .claude/commands
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
```

### Specific Project Skill
```bash
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name
```

### Specific Command Category
```bash
ln -s $CLAUDE_METADATA/commands/category/*.md .claude/commands/
```

---

## Global Commands Available

Once global commands are symlinked, you can use:

- `/setup-project` - Set up new project with intelligent defaults
- `/setup-environment` - Plan and create Python environment (venv/conda)
- `/list-skills` - Show all available skills in $CLAUDE_METADATA
- `/sync-skills` - Check for new skills/commands to symlink
- `/update-skills` - Review session and suggest skill updates
- `/cleanup-project` - End-of-project cleanup

---

## Common Workflows

### Starting Brand New Project
```bash
cd ~/Workdir/new-project

# Option 1: Use prompt
# Tell Claude the prompt from "New Project Setup" above

# Option 2: Manual
mkdir -p .claude/skills .claude/commands

# Essential skills (always include)
ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/collaboration
ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/managing-environments
ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/folder-organization

# Global commands (always include)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Project-specific skills (add as needed)
ln -s $CLAUDE_METADATA/skills/galaxy/automation .claude/skills/automation  # For Galaxy projects

# Then use /sync-skills or /setup-project to add more skills
```

### Adding to Existing Project
```bash
cd ~/Workdir/existing-project

# If .claude/ doesn't exist yet
mkdir -p .claude/skills .claude/commands

# Essential skills
ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/collaboration
ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/managing-environments
ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/folder-organization

# Global commands (for management)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Project-specific skills (add as needed)
ln -s $CLAUDE_METADATA/skills/galaxy/automation .claude/skills/automation  # For Galaxy projects

# Then sync to add more project-specific skills
/sync-skills
```

### After Team Member Adds New Skill
```bash
cd ~/Workdir/project
git pull  # Get updated $CLAUDE_METADATA (if shared)
/sync-skills  # See new skills
```

---

## Troubleshooting

### Check Environment Variable
```bash
echo $CLAUDE_METADATA
# Should output your claude_data directory path
```

### If not set, add to shell config
```bash
# Add to ~/.zshrc or ~/.bashrc
export CLAUDE_METADATA="$HOME/path/to/claude_data"  # Adjust to your actual path

# Then reload
source ~/.zshrc  # or source ~/.bashrc
```

### Verify Symlinks
```bash
ls -la .claude/skills/
ls -la .claude/commands/
```

### Check What's Linked
```bash
ls -la .claude/skills/ | grep "^l"  # Show symlinks only
ls -la .claude/commands/ | grep "^l"
```

---

## Best Practices

1. **Every new project starts with:**
   - claude-meta/token-efficiency skill (token savings)
   - claude-meta/collaboration skill (best practices)
   - project-management/managing-environments skill (environment management: venv/conda)
   - project-management/folder-organization skill (project structure)
   - ALL global commands (management tools including /setup-environment)
   - Plus project-specific skills as needed (e.g., galaxy/automation for Galaxy projects)

2. **Monthly maintenance:**
   - Run `/sync-skills` to check for updates

3. **End of productive sessions:**
   - Run `/update-skills` to capture learnings

4. **When exploring:**
   - Use `/list-skills` to see what's available

5. **Commit .claude/ to git:**
   ```bash
   git add .claude/
   git commit -m "Add Claude Code configuration"
   ```

---

## Token Efficiency Reminders

**Use bash commands instead of reading files:**
```bash
# ✅ Good (zero token cost)
cp source.txt dest.txt
sed -i '' 's/old/new/g' file.txt
cat file1.txt file2.txt > combined.txt

# ❌ Bad (costs tokens)
Read: source.txt
Write: dest.txt (with content)
```

**Filter before reading:**
```bash
# ✅ Good
grep "ERROR" log.txt | tail -20

# ❌ Bad
Read: log.txt  # Entire 50K line file
```

**Use quiet modes:**
```bash
# ✅ Good
command --quiet

# ❌ Bad
command --verbose
```

---

## For More Information

- `README.md` - Full documentation
- `NEW_MACHINE_SETUP.md` - First-time machine setup guide
- `templates/` - Creating new skills/commands
