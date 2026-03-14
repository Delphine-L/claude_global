# Updating Existing Skills

## When to Update Skills

**Update when you discover:**
- Repeated patterns or solutions
- New best practices
- Common errors and their fixes
- Token optimizations
- Workflow improvements

**Don't update for:**
- One-time issues
- Experimental approaches (wait until proven)
- User-specific preferences
- Obvious information

## Method 1: Direct Editing

```bash
# Edit the skill file
nano $CLAUDE_METADATA/skills/skill-name/SKILL.md

# Or use Claude
# Tell Claude: "Update the skill-name skill to add [new information]"
```

## Method 2: Use /update-skills Command

```bash
# If you have the update-skills command linked
/update-skills

# Claude will:
# 1. Review your session
# 2. Suggest skill updates
# 3. Ask for approval
# 4. Apply changes
```

## Method 3: End-of-Session Updates

**Tell Claude:**
```
Review today's session and suggest updates to relevant skills in $CLAUDE_METADATA.
```

## Propagation of Updates

**Automatic propagation:**
```bash
# Update skill in central location
vim $CLAUDE_METADATA/skills/vgp-pipeline/SKILL.md

# ALL projects with symlinks immediately see the update!
# No need to update each project individually
```

---

# Synchronizing Projects with Global Skills

## Scenario: Added New Skills to $CLAUDE_METADATA

**Tell Claude (in existing project):**
```
Check what skills and commands are available in $CLAUDE_METADATA and compare with what's currently symlinked in this project. Show me what's new or missing, and let me choose which ones to add.
```

Claude will:
1. List current symlinks
2. List available skills in `$CLAUDE_METADATA`
3. Show what's new
4. Create symlinks for selected items

## Manual Sync

```bash
# List available skills
ls $CLAUDE_METADATA/skills/

# List what you have
ls .claude/skills/

# Add missing ones
ln -s $CLAUDE_METADATA/skills/new-skill .claude/skills/new-skill
```
