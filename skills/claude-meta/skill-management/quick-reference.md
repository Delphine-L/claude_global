# Quick Reference

## Create New Skill
```bash
mkdir -p $CLAUDE_METADATA/skills/skill-name
cat > $CLAUDE_METADATA/skills/skill-name/SKILL.md << 'EOF'
---
name: skill-name
description: Brief description
---
# Content here
EOF
```

## Link to Project
```bash
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name
```

## Update Skill
```bash
# Edit directly
vim $CLAUDE_METADATA/skills/skill-name/SKILL.md

# Or tell Claude
"Update the skill-name skill to add [information]"
```

## Sync Project
```bash
# Tell Claude
"Check what skills are available in $CLAUDE_METADATA and show me what's new"
```

## List Available Skills
```bash
ls $CLAUDE_METADATA/skills/
```

## List Available Commands
```bash
ls $CLAUDE_METADATA/commands/*/
```

## Verify Setup
```bash
echo $CLAUDE_METADATA
ls -la .claude/skills/
ls -la .claude/commands/
```

## Setup New Project with Essential Skills and Commands
```bash
# Quick setup for new project
cd ~/Workdir/new-project
mkdir -p .claude/skills .claude/commands

# Always symlink these essential skills
ln -s $CLAUDE_METADATA/skills/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-collaboration .claude/skills/claude-collaboration

# Always symlink these useful commands
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Verify
ls -la .claude/skills/
ls -la .claude/commands/
```

---

# Common Workflows

## Workflow 1: Creating and Using a New Skill

1. **Create skill**:
   ```bash
   mkdir -p $CLAUDE_METADATA/skills/docker-workflows
   # Create SKILL.md with frontmatter
   ```

2. **Test in isolated project**:
   ```bash
   mkdir -p /tmp/test/.claude/skills
   ln -s $CLAUDE_METADATA/skills/docker-workflows /tmp/test/.claude/skills/
   # Start Claude Code, test the skill
   ```

3. **Link to real projects**:
   ```bash
   cd ~/Workdir/real-project
   ln -s $CLAUDE_METADATA/skills/docker-workflows .claude/skills/
   ```

4. **Share with team**:
   ```bash
   cd $CLAUDE_METADATA
   git add skills/docker-workflows/
   git commit -m "Add docker-workflows skill"
   git push
   ```

## Workflow 2: Updating Skill After Learning

1. **Work with Claude, discover pattern**
2. **Tell Claude**: "Add this pattern to the vgp-pipeline skill"
3. **Claude updates**: `$CLAUDE_METADATA/skills/vgp-pipeline/SKILL.md`
4. **Review changes**: `git diff`
5. **Commit**: `git commit -m "Add WF8 troubleshooting pattern"`
6. **Push**: `git push` (if using team repo)
7. **All projects auto-updated** via symlinks!

## Workflow 3: Setting Up New Project

1. **Create .claude directory**:
   ```bash
   cd ~/Workdir/new-project
   mkdir -p .claude/skills .claude/commands
   ```

2. **Symlink essential global skills**:
   ```bash
   # Always include these
   ln -s $CLAUDE_METADATA/skills/token-efficiency .claude/skills/token-efficiency
   ln -s $CLAUDE_METADATA/skills/claude-collaboration .claude/skills/claude-collaboration
   ln -s $CLAUDE_METADATA/skills/python-environment-management .claude/skills/python-environment-management
   ```

3. **Symlink ALL global commands**:
   ```bash
   # Always include for all projects
   ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
   ```

4. **Add project-specific skills** (if needed):
   ```bash
   # For Galaxy projects:
   ln -s $CLAUDE_METADATA/skills/galaxy-automation .claude/skills/galaxy-automation
   ```

5. **Tell Claude** (or use `/setup-project` if already linked):
   ```
   I've set up the essential skills and commands. Show me other available skills in
   $CLAUDE_METADATA that might be relevant for [describe your project type].
   ```

   Or simply:
   ```
   /list-skills
   ```

5. **Claude shows list**, you choose project-specific skills

6. **Claude creates additional symlinks**

7. **Commit symlinks to project**:
   ```bash
   git add .claude/
   git commit -m "Add Claude Code configuration

   Essential global skills and commands:
   - token-efficiency (token optimization)
   - claude-collaboration (team best practices)
   - galaxy-automation (BioBlend & Planemo)
   - Global commands: /update-skills, /list-skills, /setup-project

   [Additional project-specific skills if added]"
   ```

8. **Team members get symlinks** via git pull

9. **Team members point to their $CLAUDE_METADATA**
   - They need to set `$CLAUDE_METADATA` in their shell config
   - Symlinks work automatically once environment variable is set

**Pro tip**: Use `/update-skills` at the end of productive sessions to capture new learnings!

---

# Repository Maintenance

## Periodic Cleanup to Remove Redundancies

As your skill repository grows, redundancies can accumulate from:
- Legacy files after reorganizations
- Duplicate documentation in different locations
- Outdated quick-start guides
- Superseded command files

**Cleanup workflow:**

1. **Identify redundancies**:
   ```bash
   # List all markdown files
   find $CLAUDE_METADATA -name "*.md" -type f | sort

   # Compare similar files
   diff file1.md file2.md

   # Search for overlapping content
   grep -r "specific topic" $CLAUDE_METADATA
   ```

2. **Categorize files**:
   - Skills (must be unique, in `skills/*/SKILL.md`)
   - Supporting docs (should be in skill subdirectories)
   - Commands (one version only, in `commands/category/`)
   - Root docs (only README.md, QUICK_REFERENCE.md)

3. **Always backup before cleanup**:
   ```bash
   cd $CLAUDE_METADATA
   mkdir -p .backup-$(date +%Y%m%d-%H%M%S)
   cp -r files-to-modify .backup-$(date +%Y%m%d-%H%M%S)/
   ```

4. **Consolidation patterns**:
   - **Standalone docs** -> Move to `skills/skill-name/reference.md`
   - **Legacy commands** -> Remove if superseded by new versions
   - **Duplicate guides** -> Consolidate into single skill
   - **Quick reference prompts** -> Replace with standardized QUICK_REFERENCE.md

5. **Update skill to reference supporting docs**:
   ```markdown
   ## Supporting Documentation

   This skill includes detailed reference documentation:
   - **reference.md** - Comprehensive guide
   - **troubleshooting.md** - Common issues and solutions
   ```

6. **Verify structure**:
   ```bash
   tree -L 3 $CLAUDE_METADATA
   # Should show clean, logical organization
   ```

**Benefits of regular cleanup:**
- Reduces confusion about which file to use
- Improves discoverability via progressive disclosure
- Easier maintenance (single source of truth)
- Faster skill loading (no duplicate content)

---

# Summary

**Key Principles:**
1. **Central repository** - All skills in `$CLAUDE_METADATA`
2. **Symlinks, not copies** - Updates propagate automatically
3. **Version control** - Track changes with git
4. **Essential global skills first** - Always symlink token-efficiency, claude-collaboration, and python-environment-management
5. **Selective activation** - Link only relevant skills per project
6. **Team collaboration** - Share via git, everyone benefits

**Every new project should start with:**
```bash
# Essential global skills (always)
ln -s $CLAUDE_METADATA/skills/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-collaboration .claude/skills/claude-collaboration
ln -s $CLAUDE_METADATA/skills/python-environment-management .claude/skills/python-environment-management

# ALL global commands (always include for management)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Project-specific skills (add as needed)
# For Galaxy projects:
# ln -s $CLAUDE_METADATA/skills/galaxy-automation .claude/skills/galaxy-automation
```

**Available global commands:**
- `/update-skills` - Capture learnings from current session
- `/list-skills` - Show all available skills
- `/setup-project` - Set up a new project intelligently
- `/sync-skills` - Check for new skills/commands to symlink
- `/cleanup-project` - End-of-project cleanup (removes working docs, condenses READMEs)

**Remember:** The centralized pattern makes skills:
- Maintainable (update once, apply everywhere)
- Shareable (team uses same knowledge)
- Versionable (track evolution with git)
- Scalable (works for 1 or 100 projects)
- Efficient (progressive disclosure = no token waste)

**With token-efficiency skill active:**
- 80-90% token savings on typical operations
- 5-10x more interactions from your Claude Pro subscription
- Strategic file reading for learning and debugging
