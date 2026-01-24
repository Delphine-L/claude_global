# Centralized Claude Code Skills & Commands

Reusable Claude Code skills and commands for all projects via symlinks.

**📋 Quick Start:** See [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md) for copy-paste setup prompts and commands.

## Directory Structure

```
$CLAUDE_METADATA/
├── skills/                    # All reusable skills (organized by category)
│   ├── claude-meta/          # Claude Code usage & optimization
│   ├── project-management/   # Project setup & organization
│   ├── packaging/            # Package development
│   ├── galaxy/               # Galaxy platform
│   ├── bioinformatics/       # Domain-specific bio skills
│   ├── analysis/             # Data analysis & notebooks
│   ├── collaboration/        # Sharing & collaboration
│   └── INDEX.md              # Comprehensive skills catalog
├── commands/                  # Slash commands
│   ├── global/               # All projects
│   └── vgp-pipeline/         # Project-specific
└── templates/                # Templates for new skills/commands
```

## How It Works

Claude Code discovers skills from:
- `~/.claude/skills/` (global)
- `.claude/skills/` (per-project)

Skills load progressively - Claude sees descriptions first, full content only when activated.

## Available Skills

**📚 See [`skills/INDEX.md`](skills/INDEX.md) for the complete catalog with detailed descriptions, use cases, and dependencies.**

### Essential Skills (Always Include)
- **claude-meta/token-efficiency** - Automatic token optimization (80-90% savings)
- **claude-meta/collaboration** - Team collaboration best practices
- **project-management/managing-environments** - Development environment management (venv/conda)
- **project-management/folder-organization** - Project structure and organization

### Skills by Category

- **Claude Meta** (3 skills) - Claude Code usage, collaboration, optimization
- **Project Management** (2 skills) - Project setup, folder organization, environment management
- **Packaging** (1 skill) - Bioconda recipe development
- **Galaxy** (3 skills) - Galaxy platform development & automation
- **Bioinformatics** (2 skills) - Genome assembly, sequencing analysis
- **Analysis** (1 skill) - Jupyter notebooks, statistical analysis
- **Collaboration** (2 skills) - Project sharing, collaborative documentation

Browse the full catalog: [`skills/INDEX.md`](skills/INDEX.md)

## Global Commands (commands/global/)

- **`/setup-project`** - Initialize new project with essential skills
- **`/setup-environment`** - Plan and set up Python environment (venv or conda)
- **`/sync-skills`** - Sync with $CLAUDE_METADATA, detect new skills
- **`/list-skills`** - Show all available skills
- **`/update-skills`** - Review session and update skills
- **`/cleanup-project`** - Remove working docs, condense verbose READMEs

## Setting Up a New Project

**Quick Start:**
```bash
/setup-project  # Auto-detects project type and sets up skills
```

**Manual Setup:**
```bash
mkdir -p .claude/skills .claude/commands

# Essential skills (always include)
ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/
ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/
ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/
ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/

# Global commands (always include)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Project-specific skills (add as needed)
ln -s $CLAUDE_METADATA/skills/galaxy/automation .claude/skills/  # For Galaxy projects
ln -s $CLAUDE_METADATA/skills/bioinformatics/vgp-pipeline .claude/skills/  # For VGP projects
ln -s $CLAUDE_METADATA/skills/category/your-skill .claude/skills/
```

See `QUICK_REFERENCE.md` for detailed prompts and workflows.

## Adding New Skills/Commands

**Using templates (recommended):**
```bash
./templates/create-skill.sh my-skill "Description"
./templates/create-command.sh category cmd-name "Description"
```

**Manual:**
```bash
# Skill (choose appropriate category: claude-meta, environments, galaxy, bioinformatics, analysis, tools)
mkdir skills/category/my-skill
cat > skills/category/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Brief description
version: 1.0.0
---
# Skill content...
EOF

# Update skills/INDEX.md with the new skill

# Command
cat > commands/global/my-cmd.md << 'EOF'
---
name: my-cmd
description: Brief description
---
Command prompt...
EOF
```

See `templates/README.md` for details.

## Troubleshooting

**Skill not activating:**
- Mention skill name explicitly
- Check `ls -la .claude/skills/` for symlink
- Verify SKILL.md has frontmatter

**Command not found:**
- Check `ls -la .claude/commands/`
- Verify command has frontmatter
- Restart Claude Code session

**Symlink issues:**
- Use absolute paths: `$CLAUDE_METADATA/...`
- Check target exists and permissions
