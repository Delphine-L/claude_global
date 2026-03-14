---
name: claude-collaboration
description: Best practices for using Claude Code in team environments. Covers skill management, knowledge capture, version control, and collaborative workflows.
version: 1.0.0
allowed-tools: Read, Grep, Glob, Bash
---

# Claude Code Collaboration Best Practices

This skill provides guidance on effectively using Claude Code in team environments, managing shared knowledge through skills, and maximizing value from AI-assisted development.

## Core Principles

1. **Skills are living documentation** - They evolve as you learn
2. **Capture knowledge explicitly** - Claude doesn't auto-update skills
3. **All skills live in $CLAUDE_METADATA** - No local skills or commands in projects
4. **Share knowledge across the team** - Centralized repo ensures consistency
5. **Version control your skills** - Track changes and improvements
6. **Be intentional about updates** - Not everything learned needs to be captured

### Critical: No Local Skills or Commands

**ALL skills and commands MUST be in the $CLAUDE_METADATA repository, never in individual project directories.**

**Never do this:**
```bash
# Creating local skill in project
echo "---" > .claude/skills/my-local-skill/SKILL.md
```

**Always do this:**
```bash
# Create skill in central repo
mkdir -p $CLAUDE_METADATA/skills/project-name
echo "---" > $CLAUDE_METADATA/skills/project-name/SKILL.md

# Then symlink to project
ln -s $CLAUDE_METADATA/skills/project-name .claude/skills/project-name
```

**Why centralization is mandatory:**
- **Version control**: All skills tracked in one git repo
- **Team sharing**: Everyone uses the same knowledge
- **Consistency**: No divergence between projects
- **Maintenance**: Update once, applies everywhere
- **Discovery**: Team can see all available skills

**Even project-specific skills go in the central repo** under `$CLAUDE_METADATA/skills/project-name/`.

---

## Understanding How Skills Work

### What Happens During a Session

**At session start:**
- Claude reads all `.claude/skills/` files in your directory
- Skills provide context and guidelines for the session
- Knowledge from skills is "loaded" into Claude's working context

**During the session:**
- Claude learns from your conversation (temporary, in-context learning)
- Solutions discovered apply only to this conversation
- Skills remain unchanged unless you explicitly update them

**At session end:**
- All temporary learning is lost
- Skills remain exactly as they were at the start
- Next session starts fresh, reading skills again

### What This Means

- **Skills persist across sessions** - They're files on disk
- **Session learnings don't persist** - They exist only in conversation context
- **You must explicitly update skills** - Claude won't do it automatically

---

## When to Update Skills

### Always Update Skills For:

1. **Repeated problems with known solutions**
   - "We keep hitting this error, here's how to fix it"
   - Add to troubleshooting section

2. **New best practices discovered**
   - "Using --quiet saves 85% tokens, use it by default"
   - Add to optimization guidelines

3. **Common workflows that need standardization**
   - "Our team always does X before Y"
   - Add to standard procedures

4. **Configuration patterns that work**
   - "This cron job setup works best for our HPC"
   - Add as recommended configuration

5. **Important architectural decisions**
   - "We decided to use symlinks for global skills because..."
   - Document rationale for future reference

### Don't Update Skills For:

1. **One-time issues** - Specific to a particular run or environment
2. **Experimental approaches** - Wait until proven effective
3. **User-specific preferences** - Unless they should be team defaults
4. **Obvious information** - Already well-documented elsewhere
5. **Temporary workarounds** - Not worth making permanent

### Example: When to Update

**Scenario 1: New error pattern discovered**
```
Session: "WF8 fails when Hi-C files are missing R2 reads"
Action: ADD to troubleshooting - this will happen again
Rationale: Common issue with known solution
```

**Scenario 2: One-off configuration issue**
```
Session: "My personal laptop has Python 3.7, need 3.8"
Action: DON'T ADD to skill - personal environment issue
Rationale: Not relevant to others, not a recurring pattern
```

**Scenario 3: Token optimization discovered**
```
Session: "Using --quiet mode saves 15K to 2K tokens!"
Action: ADD to token efficiency skill
Rationale: Valuable for entire team, significant impact
```

---

## How to Update Skills

### Method 1: Explicit Request (Recommended)

```
User: "We just solved the issue with workflow timeouts in HPC environments.
       Add this to the VGP skill under troubleshooting."

Claude: [Reads current skill, adds new troubleshooting entry, saves file]
```

### Method 2: Ask Claude to Suggest Updates

```
User: "Based on our work today, what should we add to the VGP skill?"
Claude: [Reviews conversation, suggests additions]
User: "Yes, add those three things."
Claude: [Updates skill file]
```

### Method 3: End-of-Session Summary

```
User: "Summarize today's learnings and update the relevant skills."
Claude: [Creates summary, updates multiple skills if needed]
```

### Method 4: Periodic Review

```
User: "We've been working on VGP for a month.
       Review our conversation history and suggest skill improvements."
Claude: [Analyzes patterns, suggests updates]
```

---

## Skill Organization Patterns

### Pattern 1: Project-Specific Skills (In Central Repo)

**Use for:** Project-specific knowledge (VGP workflows, Galaxy APIs)

**Location:** `$CLAUDE_METADATA/skills/project-name/` (NOT in project directory)

```
$CLAUDE_METADATA/
└── skills/
    ├── my-project/              # Project-specific skill
    │   └── SKILL.md
    └── another-project/
        └── SKILL.md

my-project/
└── .claude/
    └── skills/
        └── my-project -> $CLAUDE_METADATA/skills/my-project  # Symlink only!
```

### Pattern 2: General Skills (Cross-Project)

**Use for:** General development practices, tool-agnostic optimizations, team-wide standards

**Location:** `$CLAUDE_METADATA/skills/`

### Pattern 3: Symlinking Skills to Projects

**This is THE standard pattern - all projects use symlinks, no exceptions.**

```bash
# In each project
cd /path/to/project
mkdir -p .claude/skills .claude/commands

# Symlink skills from central repo
ln -s $CLAUDE_METADATA/skills/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/my-project .claude/skills/my-project

# Symlink commands from central repo
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
```

**Critical rule:** Projects contain ONLY symlinks, never actual skill/command files.

### Pattern 4: Skills with Supporting Documentation

```
skills/skill-name/
├── SKILL.md              # Core concepts and quick reference
├── reference.md          # Detailed technical documentation
├── troubleshooting.md    # Common issues and solutions
├── examples/             # Code examples
└── templates/            # Template files
```

**When to use:**
- SKILL.md is getting too long (>500 lines)
- Detailed reference material available
- Multiple categories of information (guides, troubleshooting, examples)

**Best practice:**
- Keep SKILL.md under 500 lines
- Move detailed guides to supporting files
- Reference supporting files at end of SKILL.md
- Use descriptive filenames (troubleshooting.md, not tips.md)

---

## Quick Reference

### Daily Workflow

```
1. Start session -> Claude reads skills
2. Work on task -> Learn new patterns
3. End session -> "What should we add to skills?"
4. Claude suggests -> You approve/modify
5. Git commit -> Share with team
```

### Weekly Maintenance

```
1. Review week's commits
2. Identify patterns across sessions
3. Consolidate related updates
4. Remove outdated info
5. Share changelog with team
```

### Monthly Review

```
1. Audit all skills for conflicts
2. Measure token savings
3. Collect team feedback
4. Major refactoring if needed
5. Update skill documentation
```

---

## Summary

**Key Principles:**
1. **Skills are permanent, sessions are temporary**
2. **Update skills explicitly** - Claude won't auto-update
3. **ALL skills in $CLAUDE_METADATA** - No local skills or commands ever
4. **Version control your skills** with git in central repo
5. **Share skills across team** - Centralization ensures consistency
6. **Regular reviews** keep skills valuable

**Critical Architectural Rule:**
- **NEVER create skills or commands directly in project directories**
- **ALWAYS create in $CLAUDE_METADATA and symlink to projects**

Even project-specific skills must live in the central repository. This ensures:
- **Single source of truth** - No duplicates, no divergence
- **Version control** - All skills tracked in one git repo
- **Team sharing** - Everyone can discover and use all skills
- **Easy maintenance** - Update once, applies everywhere

**Remember:** Claude is a powerful assistant, but skills are how you make that power consistent, shareable, and permanent. The centralized architecture ensures your team's knowledge remains organized, discoverable, and maintainable. Invest in your skills, and they'll pay dividends for your entire team.

---

## Supporting Documentation

This skill includes detailed reference documentation in the same directory:

- **centralized-repository.md** - Centralized skill repository setup, migration patterns, team workflow, and directory structure examples
- **version-control-and-sharing.md** - Git setup for skills, team collaboration workflows, and four methods for sharing skills (git repo, network drive, copy-based, zip archive)
- **maintenance-and-effectiveness.md** - Best practices for skill maintenance, measuring effectiveness, metrics to track, and common pitfalls with solutions
- **advanced-patterns.md** - Tiered/conditional/role-based skill patterns and documentation for session interruptions (resume documentation templates)

These files provide deep technical details that complement the core concepts above.
