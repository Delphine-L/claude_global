# New Machine Setup Guide

This guide helps you set up this claude_data repository on a new computer.

## Quick Start

### 1. Clone the Repository

```bash
# Clone to your preferred location
git clone <your-repo-url> ~/path/to/claude_data

# Examples:
# git clone git@github.com:username/claude_data.git ~/Workdir/claude_data
# git clone git@github.com:username/claude_data.git ~/Documents/claude_data
```

### 2. Set Environment Variable

Add the `CLAUDE_METADATA` environment variable to your shell configuration:

```bash
# For zsh (macOS default)
echo 'export CLAUDE_METADATA="$HOME/path/to/claude_data"' >> ~/.zshrc
source ~/.zshrc

# For bash
echo 'export CLAUDE_METADATA="$HOME/path/to/claude_data"' >> ~/.bashrc
source ~/.bashrc
```

**Important:** Replace `$HOME/path/to/claude_data` with the actual path where you cloned the repository.

### 3. Verify Setup

```bash
# Check that the variable is set
echo $CLAUDE_METADATA
# Should output your claude_data directory path

# Verify the directory exists
ls $CLAUDE_METADATA
# Should list: README.md, skills/, .claude/, etc.
```

### 4. Create Local Settings (Optional)

The `.claude/settings.local.json` file is gitignored and needs to be created on each machine:

```bash
# Copy the template
cp $CLAUDE_METADATA/.claude/settings.local.json.template $CLAUDE_METADATA/.claude/settings.local.json

# The template already uses $CLAUDE_METADATA variable, so it should work as-is
```

### 5. Enable Skills in Your Projects

Choose one of these methods:

#### Option A: Use the enable-skills script

```bash
cd /path/to/your/project
bash $CLAUDE_METADATA/enable-skills.sh
```

#### Option B: Manual symlink

```bash
cd /path/to/your/project
mkdir -p .claude/skills .claude/commands

# Essential skills
ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/collaboration
ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/managing-environments
ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/folder-organization

# Global commands (management tools)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Project-specific skills (add as needed)
ln -s $CLAUDE_METADATA/skills/galaxy/automation .claude/skills/automation  # For Galaxy projects
```

#### Option C: Work directly in claude_data

```bash
cd $CLAUDE_METADATA
# Start Claude Code here
```

## Verification Checklist

- [ ] `echo $CLAUDE_METADATA` shows your claude_data directory path
- [ ] `ls $CLAUDE_METADATA/skills` shows available skills
- [ ] `ls $CLAUDE_METADATA/commands/global` shows available global commands
- [ ] `.claude/settings.local.json` exists (if using permissions)
- [ ] Skills and commands are enabled in your project (test with Claude Code)

## Customizing Paths

This repository is designed to work with any directory location. All you need to do is:

1. Clone it anywhere you want
2. Set `$CLAUDE_METADATA` to point to that location
3. Everything else uses `$CLAUDE_METADATA` and will work automatically

### Examples of Different Setups

```bash
# Setup 1: Traditional Workdir
export CLAUDE_METADATA="$HOME/Workdir/claude_data"

# Setup 2: Documents folder
export CLAUDE_METADATA="$HOME/Documents/claude_data"

# Setup 3: Dropbox sync
export CLAUDE_METADATA="$HOME/Dropbox/claude_data"

# Setup 4: Custom location
export CLAUDE_METADATA="/opt/claude_data"
```

## Troubleshooting

### Variable not set

```bash
# Check if it's set
echo $CLAUDE_METADATA

# If empty, make sure you added it to the right shell config file
# and that you've sourced it or restarted your terminal
```

### Skills not loading

```bash
# Verify symlinks
ls -la .claude/skills/
# Should show symlinks pointing to $CLAUDE_METADATA/...

# Verify targets exist
ls -L .claude/skills/
# Should show SKILL.md files
```

### Paths still showing old location

If you see references to old paths after moving the repository:

1. Update your `$CLAUDE_METADATA` variable in your shell config
2. Source your shell config: `source ~/.zshrc` (or `~/.bashrc`)
3. Recreate `.claude/settings.local.json` from the template
4. Restart your terminal or Claude Code session

## Team Setup

When sharing this repository with a team:

1. Each team member clones the repository to their preferred location
2. Each team member sets their own `$CLAUDE_METADATA` variable
3. The `.claude/settings.local.json` file is gitignored, so it won't cause conflicts
4. All documentation uses `$CLAUDE_METADATA`, so it works for everyone

## Next Steps

After setup, see:

- `README.md` - Full documentation and overview
- `QUICK_REFERENCE.md` - Copy-paste prompts, commands, and workflows
