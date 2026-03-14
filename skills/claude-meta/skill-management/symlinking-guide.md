# Symlinking Skills and Commands to Projects

## Recommended Global Skills (Always Symlink These)

**Every new project should include these globally useful skills:**

### 1. token-efficiency (Essential)
**Why:** Automatically optimizes Claude's token usage, saving 80-90% on typical operations
```bash
ln -s $CLAUDE_METADATA/skills/token-efficiency .claude/skills/token-efficiency
```

**Benefits:**
- Uses `--quiet` mode for commands automatically
- Reads log files efficiently (tail/grep instead of full read)
- Strategic file selection for learning mode
- Extends your Claude Pro usage 5-10x

### 2. claude-collaboration (Highly Recommended)
**Why:** Teaches best practices for managing skills and team collaboration
```bash
ln -s $CLAUDE_METADATA/skills/claude-collaboration .claude/skills/claude-collaboration
```

**Benefits:**
- Explains when and how to update skills
- Documents skill lifecycle and version control
- Helps onboard team members
- Ensures consistency across projects

### 3. galaxy-automation (For Galaxy projects)
**Why:** Universal BioBlend and Planemo knowledge for any Galaxy automation project
```bash
ln -s $CLAUDE_METADATA/skills/galaxy-automation .claude/skills/galaxy-automation
```

**Benefits:**
- Foundation for Galaxy workflow automation
- Required dependency for vgp-pipeline
- Useful for galaxy-tool-wrapping (Planemo testing)
- Reduces duplication across Galaxy-related skills

### 4. Recommended Global Commands (Highly Recommended)
**Useful for managing skills across all projects:**
```bash
mkdir -p .claude/commands
# Symlink ALL global commands (always include)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
```

**Available commands:**
- `/update-skills` - Review session and suggest skill updates
- `/list-skills` - Show all available skills in $CLAUDE_METADATA
- `/setup-project` - Set up a new project with intelligent defaults
- `/sync-skills` - Check for new skills/commands added to $CLAUDE_METADATA
- `/cleanup-project` - End-of-project cleanup (working docs, verbose READMEs)

### Quick Setup for Both Skills and Commands
```bash
# Navigate to your new project
cd ~/Workdir/your-new-project/

# Create .claude directories
mkdir -p .claude/skills .claude/commands

# Symlink essential global skills
ln -s $CLAUDE_METADATA/skills/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-collaboration .claude/skills/claude-collaboration
ln -s $CLAUDE_METADATA/skills/python-environment-management .claude/skills/python-environment-management

# Symlink ALL global commands (always include)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Add project-specific skills as needed
# For Galaxy projects:
# ln -s $CLAUDE_METADATA/skills/galaxy-automation .claude/skills/galaxy-automation

# Verify
ls -la .claude/skills/
ls -la .claude/commands/
```

**Or ask Claude:**
```
Set up this new project with Claude Code. Symlink the essential global skills
(token-efficiency, claude-collaboration, and python-environment-management) and global commands
from $CLAUDE_METADATA/skills/ and ALL global commands from $CLAUDE_METADATA/commands/global/, then show me
other available skills I might want to add.
```

**Or simply use:**
```
/setup-project
```
(if the setup-project command is already symlinked)

---

## Method 1: Quick Setup (Recommended for New Projects)

**Tell Claude:**
```
Set up Claude Code for this project. Show me available skills in $CLAUDE_METADATA and let me choose which ones to symlink.
```

Claude will:
1. **Automatically symlink token-efficiency, claude-collaboration, python-environment-management** (if not already present)
2. List all available skills and commands
3. Ask which additional ones you want
4. Create the symlinks
5. Verify everything works

## Method 2: Manual Symlink (Specific Skills)

```bash
# Navigate to your project
cd ~/Workdir/your-project/

# Create directories if needed
mkdir -p .claude/skills .claude/commands

# Symlink specific skill
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name

# Symlink all commands from a category
ln -s $CLAUDE_METADATA/commands/category/*.md .claude/commands/

# Symlink specific command
ln -s $CLAUDE_METADATA/commands/category/command-name.md .claude/commands/command-name.md
```

## Method 3: Symlink All Skills

```bash
# Link every skill (use cautiously)
for skill in $CLAUDE_METADATA/skills/*; do
    ln -s "$skill" .claude/skills/$(basename "$skill")
done

# Link all commands from all categories
for category in $CLAUDE_METADATA/commands/*; do
    ln -s "$category"/*.md .claude/commands/
done
```

**Note:** Progressive disclosure means having many skills doesn't hurt performance, but keep projects focused on relevant skills for clarity.

## Hooks Management

Hooks live in `$CLAUDE_METADATA/hooks/` and are symlinked to `~/.claude/hooks/`:

```bash
ln -s $CLAUDE_METADATA/hooks/safety ~/.claude/hooks/safety
ln -s $CLAUDE_METADATA/hooks/peon-ping ~/.claude/hooks/peon-ping
```

### Portability

- In `~/.claude/settings.json`, use `~/.claude/hooks/` paths (not `/Users/username/...`)
- Runtime files (logs, `.state.json`, `.sound.pid`) are gitignored
- Hooks `.gitignore` covers: `*.log`, `*.state.json`, `.sound.pid`, `.last_update_check`

### New Machine Setup

```bash
mkdir -p ~/.claude/hooks
ln -s $CLAUDE_METADATA/hooks/safety ~/.claude/hooks/safety
ln -s $CLAUDE_METADATA/hooks/peon-ping ~/.claude/hooks/peon-ping
```

## Verify Symlinks

```bash
# Check what's linked
ls -la .claude/skills/
ls -la .claude/commands/

# Verify targets exist
ls -L .claude/skills/    # Follows symlinks
```
