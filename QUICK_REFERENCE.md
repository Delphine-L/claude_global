# Claude Code Quick Reference

Quick copy-paste prompts for common tasks.

---

## New Project Setup

### Recommended (with essentials)
```
Set up Claude Code for this project. Symlink the essential global skills
(token-efficiency, claude-collaboration, galaxy-automation) and global commands from
$CLAUDE_METADATA. Then show me other available skills and let me choose which ones are relevant.
```

### Or use command (if already symlinked once)
```
/setup-project
```

---

## Sync Existing Project

### If global commands already symlinked
```
/sync-skills
```

### If global commands NOT yet symlinked
```
Set up global commands from $CLAUDE_METADATA and sync this project with available
skills and commands. First, symlink all global commands (update-skills, list-skills,
setup-project, sync-skills), then run sync-skills to detect what else I should add.
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

## Project-Specific Setups

### VGP Pipeline Project
```
Set up Claude Code for a VGP pipeline project. Symlink the essential global skills,
global commands, vgp-pipeline skill, and all VGP commands from $CLAUDE_METADATA.
```

### Galaxy Tool Development
```
Set up Claude Code for Galaxy tool development. Symlink the essential global skills,
global commands, and galaxy-tool-wrapping skill from $CLAUDE_METADATA.
```

### Galaxy Workflow Development
```
Set up Claude Code for Galaxy workflow development. Symlink the essential global
skills, global commands, and galaxy-workflow-development skill from $CLAUDE_METADATA.
```

### Bioconda Recipe Development
```
Set up Claude Code for bioconda recipe development. Symlink the essential global
skills, global commands, and conda-recipe skill from $CLAUDE_METADATA.
```

---

## Manual Commands Reference

### Essential Global Skills (Always Include)
```bash
ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/.claude/skills/claude-collaboration .claude/skills/claude-collaboration
ln -s $CLAUDE_METADATA/.claude/skills/galaxy-automation .claude/skills/galaxy-automation
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

- `/update-skills` - Review session and suggest skill updates
- `/list-skills` - Show all available skills in $CLAUDE_METADATA
- `/setup-project` - Set up new project with intelligent defaults
- `/sync-skills` - Check for new skills/commands to symlink

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
   - token-efficiency skill (token savings)
   - claude-collaboration skill (best practices)
   - Global commands (management tools)

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

## Common Workflows

### Starting Brand New Project
```bash
cd ~/Workdir/new-project

# Option 1: Use prompt
# Tell Claude the prompt from "New Project Setup" above

# Option 2: Manual
mkdir -p .claude/skills .claude/commands
ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/.claude/skills/claude-collaboration .claude/skills/claude-collaboration
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
# Then use /sync-skills or /setup-project
```

### Adding to Existing Project
```bash
cd ~/Workdir/existing-project

# If .claude/ doesn't exist yet
mkdir -p .claude/skills .claude/commands
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Then sync
/sync-skills
```

### After Team Member Adds New Skill
```bash
cd ~/Workdir/project
git pull  # Get updated $CLAUDE_METADATA (if shared)
/sync-skills  # See new skills
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

For complete documentation, see:
- `README.md` - Full documentation
- `SETUP_PROMPT.md` - All setup prompts
- `templates/` - Creating new skills/commands
