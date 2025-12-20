# Claude Code Project Setup Prompts

Copy and paste these prompts when starting a new project to set up global skills and commands.

## Recommended Setup (Essential Skills + Commands + Selective)

**RECOMMENDED for all new projects:**

```
Set up Claude Code for this project. First, symlink the essential global skills
(token-efficiency, claude-collaboration, and galaxy-automation) and global commands
(update-skills, list-skills, setup-project) from $CLAUDE_METADATA. Then show me
other available skills and let me choose which ones are relevant for this project.
```

This ensures you always get:
- ✅ **token-efficiency** - Saves 80-90% tokens, extends Claude Pro usage 5-10x
- ✅ **claude-collaboration** - Best practices for skill management
- ✅ **galaxy-automation** - BioBlend & Planemo for Galaxy workflow automation
- ✅ **Global commands**: `/update-skills`, `/list-skills`, `/setup-project`
- Plus any project-specific skills you choose

**Quick alternative using the command:**
```
/setup-project
```
(if setup-project command is already symlinked)

---

## Basic Setup (All Skills)

```
Set up Claude Code skills and commands for this project. Create symlinks to all available skills and commands in $CLAUDE_METADATA.
```

## Selective Setup (Choose Specific Skills)

```
Set up Claude Code for this project. Show me available skills in $CLAUDE_METADATA and let me choose which ones to symlink.
```

**Note:** These prompts should still include token-efficiency and claude-collaboration automatically.

## VGP Project Setup (VGP-specific)

```
Set up Claude Code for a VGP pipeline project. Symlink the essential global skills
(token-efficiency, claude-collaboration, and galaxy-automation), the vgp-pipeline
skill, and all VGP commands from $CLAUDE_METADATA.
```

**What you'll get:**
- token-efficiency, claude-collaboration, and galaxy-automation (always)
- vgp-pipeline skill (VGP-specific, depends on galaxy-automation)
- All VGP slash commands (/check-status, /debug-failed, etc.)

## Galaxy Tool Development Project

```
Set up Claude Code for Galaxy tool development. Symlink the essential global skills
(token-efficiency, claude-collaboration, and galaxy-automation), plus the galaxy-tool-wrapping
skill from $CLAUDE_METADATA.
```

**What you'll get:**
- token-efficiency, claude-collaboration, and galaxy-automation (always)
- galaxy-tool-wrapping skill with reference docs
- Ready for creating and testing Galaxy tools

## Galaxy Workflow Development Project

```
Set up Claude Code for Galaxy workflow development. Symlink the essential global
skills (token-efficiency, claude-collaboration, and galaxy-automation), plus the
galaxy-workflow-development skill from $CLAUDE_METADATA.
```

**What you'll get:**
- token-efficiency, claude-collaboration, and galaxy-automation (always)
- galaxy-workflow-development skill (IWC standards)
- Ready for creating Galaxy .ga workflows

## Update/Sync Existing Project

### Quick Method (if global commands already symlinked)
```
/sync-skills
```

### First Time Sync (global commands not yet symlinked)

**Copy-paste this prompt:**
```
Set up global commands from $CLAUDE_METADATA and sync this project with available
skills and commands. First, symlink all global commands (update-skills, list-skills,
setup-project, sync-skills), then run sync-skills to detect what else I should add.
```

**What this does:**
1. Creates `.claude/commands/` directory if needed
2. Symlinks all 4 global commands
3. Runs `/sync-skills` to show what's available vs what's linked
4. Lets you choose additional skills to add

### Manual Approach

**Or use this prompt** when you've added new skills or commands to `$CLAUDE_METADATA` and want to update an existing project:

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

**Best practice:** Run `/sync-skills` monthly to stay up to date with new skills and commands added to $CLAUDE_METADATA.

## What Claude Will Do

**For initial setup prompts**, Claude will:
1. Create `.claude/skills/` and `.claude/commands/` directories
2. **Automatically symlink essential global skills** (token-efficiency, claude-collaboration, galaxy-automation)
3. **Automatically symlink useful global commands** (update-skills, list-skills, setup-project, sync-skills)
4. List available skills/commands in `$CLAUDE_METADATA`
5. Create additional symlinks based on your request
6. Verify all symlinks are working correctly

**Essential global skills always included:**
- `token-efficiency` - Optimizes token usage (80-90% savings)
- `claude-collaboration` - Best practices for skill management
- `galaxy-automation` - BioBlend & Planemo for Galaxy workflow automation

**Useful global commands always included:**
- `/update-skills` - Review session and suggest skill updates
- `/list-skills` - Show all available skills
- `/setup-project` - Set up new projects with intelligent defaults
- `/sync-skills` - Sync project with available skills/commands
- `/cleanup-project` - End-of-project cleanup for branch documentation

**For update/sync prompts**, Claude will:
1. Check current symlinks in `.claude/skills/` and `.claude/commands/`
2. List all available skills/commands in `$CLAUDE_METADATA`
3. Show you what's new or not yet symlinked
4. Wait for you to choose which ones to add
5. Create symlinks for your selected items
6. Confirm the updates

## After Setup

Once set up, you can activate skills by:
- Mentioning them by name: "Use the vgp-pipeline skill to check workflow status"
- Matching their description: "Use the skill for Galaxy tool wrapping"
- Context: Claude activates automatically based on your request

## Environment Variable

Make sure `$CLAUDE_METADATA` is set in your shell:
```bash
echo $CLAUDE_METADATA
# Should output your claude_data directory path
```

If not set, add to `~/.zshrc`:
```bash
export CLAUDE_METADATA="$HOME/path/to/claude_data"  # Adjust to your actual path
```
