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

**Claude Meta:**
- **claude-meta/token-efficiency** - Automatic token optimization (80-90% savings)
- **claude-meta/collaboration** - Team collaboration best practices

**Project Management:**
- **project-management/folder-organization** - Project structure and organization
- **project-management/managing-environments** - Development environment management (venv/conda)
- **project-management/obsidian** - Note-taking and knowledge management integration
- **project-management/data-backup** - Smart automated backups with skill integration

**Collaboration:**
- **collaboration/hackmd** - Collaborative documentation with HackMD
- **collaboration/project-sharing** - Prepare organized packages for sharing

### Skills by Category

- **Claude Meta** (3 skills) - Claude Code usage, collaboration, optimization
- **Project Management** (4 skills) - Project setup, folder organization, environment management, note-taking, backups
- **Collaboration** (2 skills) - Project sharing, collaborative documentation
- **Packaging** (1 skill) - Bioconda recipe development
- **Galaxy** (3 skills) - Galaxy platform development & automation
- **Bioinformatics** (2 skills) - Genome assembly, sequencing analysis
- **Analysis** (1 skill) - Jupyter notebooks, statistical analysis

Browse the full catalog: [`skills/INDEX.md`](skills/INDEX.md)

## Global Commands (commands/global/)

### Essential Commands (Use Regularly)

**Session Management:**
- **`/safe-exit`** - Safely end session with backup and Obsidian summary prompts (use instead of `exit`)
- **`/safe-clear`** - Context clearing with knowledge preservation (save notes and skills, then clear)

**Project Organization:**
- **`/consolidate-notes`** - Consolidate session notes with AI analysis, update project status, and archive (weekly/bi-weekly)
- **`/backup`** - Smart backup system with skill integration (daily/milestone backups)

**Setup & Discovery:**
- **`/setup-project`** - Initialize new project with essential skills
- **`/command-help`** - Show help and documentation for Claude Code commands

### Additional Commands

**Skills & Environment:**
- **`/sync-skills`** - Sync with $CLAUDE_METADATA, detect new skills
- **`/list-skills`** - Show all available skills
- **`/update-skills`** - Review session and update skills
- **`/setup-environment`** - Plan and set up Python environment (venv or conda)

**Project Maintenance:**
- **`/share-project`** - Prepare organized packages for sharing with collaborators
- **`/cleanup-project`** - Remove working docs, condense verbose READMEs

## Recommended Workflow

**Daily/Session:**
1. Start working on your project
2. End with **`/safe-exit`** (creates session notes + optional backup)
   - Or use **`/safe-clear`** if switching tasks mid-session

**Weekly/Bi-weekly:**
3. Run **`/consolidate-notes`** to:
   - Generate AI-powered project status
   - Track completed vs pending to-dos
   - Get improvement suggestions
   - Archive old session notes

**As Needed:**
4. **`/backup`** - Create milestone backups
5. **`/share-project`** - Prepare packages for collaborators
6. **`/command-help <command>`** - Get help on any command

---

## Setting Up a New Project

### Using enable-skills.sh (Recommended)

The `enable-skills.sh` script provides an interactive setup with **project type detection**:

```bash
cd /path/to/your/project
bash $CLAUDE_METADATA/enable-skills.sh
```

**Features:**
- **Project Type Detection** - Automatically suggests appropriate skills:
  - **Analysis/Research** - Adds jupyter-notebook, data-analysis-patterns, data-visualization, scientific-publication, documentation-organization
  - **Development** - Adds conda-recipe for package development
  - **Bioinformatics** - Adds bioinformatics/fundamentals, galaxy tools, VGP pipeline skills
  - **Other/Mixed** - Manual skill selection
- **Obsidian Integration** - Configure project notes location
- **Smart Suggestions** - Recommends skills based on your project type
- **Essential Skills** - Always includes core skills (token-efficiency, folder-organization, managing-environments, obsidian, data-backup, project-sharing)
- **Global Commands** - Links all commands (/safe-exit, /safe-clear, /backup, etc.)

### Quick Command Setup

**Quick Start:**
```bash
/setup-project  # Auto-detects project type and sets up skills
```

### Manual Setup
```bash
mkdir -p .claude/skills .claude/commands

# Essential skills (always include)
# Claude Meta
ln -s $CLAUDE_METADATA/skills/claude-meta/token-efficiency .claude/skills/token-efficiency
ln -s $CLAUDE_METADATA/skills/claude-meta/collaboration .claude/skills/collaboration

# Project Management
ln -s $CLAUDE_METADATA/skills/project-management/folder-organization .claude/skills/folder-organization
ln -s $CLAUDE_METADATA/skills/project-management/managing-environments .claude/skills/managing-environments
ln -s $CLAUDE_METADATA/skills/project-management/obsidian .claude/skills/obsidian
ln -s $CLAUDE_METADATA/skills/project-management/data-backup .claude/skills/data-backup

# Collaboration
ln -s $CLAUDE_METADATA/skills/collaboration/hackmd .claude/skills/hackmd
ln -s $CLAUDE_METADATA/skills/collaboration/project-sharing .claude/skills/project-sharing

# Global commands (always include)
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/

# Project-specific skills (add as needed)
ln -s $CLAUDE_METADATA/skills/galaxy/automation .claude/skills/automation  # For Galaxy projects
ln -s $CLAUDE_METADATA/skills/bioinformatics/vgp-pipeline .claude/skills/vgp-pipeline  # For VGP projects
ln -s $CLAUDE_METADATA/skills/category/your-skill .claude/skills/your-skill
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
