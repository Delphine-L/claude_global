# Centralized Claude Code Skills & Commands

Reusable Claude Code skills and commands for all projects via symlinks.

**📋 Quick Start:** See [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md) for copy-paste setup prompts.

## Directory Structure

```
$CLAUDE_METADATA/
├── skills/                    # Domain-specific skills
├── commands/                  # Slash commands
│   ├── global/               # All projects
│   └── vgp-pipeline/         # Project-specific
├── templates/                # Templates for new skills/commands
└── .claude/skills/           # Legacy global skills
```

## How It Works

Claude Code discovers skills from:
- `~/.claude/skills/` (global)
- `.claude/skills/` (per-project)

Skills load progressively - Claude sees descriptions first, full content only when activated.

## Available Skills

### Core Skills (.claude/skills/)
- **token-efficiency** - Automatic token optimization (80-90% savings). Uses `--quiet`, tail, grep instead of full file reads
- **claude-collaboration** - Team collaboration best practices. Skill management, git version control
- **galaxy-automation** - BioBlend/Planemo expertise. Galaxy API, workflows, batch processing

### Domain Skills (skills/)
- **vgp-pipeline** - VGP genome assembly orchestration. Workflow sequences, GenomeArk integration
- **galaxy-tool-wrapping** - Galaxy tool wrapper development. XML schemas, Planemo testing
- **bioinformatics-fundamentals** - Core bioinformatics concepts and tools
- **conda-recipe** - Bioconda recipe development and testing
- **galaxy-workflow-development** - Galaxy workflow design and optimization
- **claude-skill-management** - Managing this skills repository

## Global Commands (commands/global/)

- **`/setup-project`** - Initialize new project with essential skills
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
ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/
ln -s $CLAUDE_METADATA/skills/your-skill .claude/skills/
ln -s $CLAUDE_METADATA/commands/global/*.md .claude/commands/
```

See `SETUP_PROMPT.md` and `QUICK_REFERENCE.md` for detailed prompts.

## Adding New Skills/Commands

**Using templates (recommended):**
```bash
./templates/create-skill.sh my-skill "Description"
./templates/create-command.sh category cmd-name "Description"
```

**Manual:**
```bash
# Skill
mkdir skills/my-skill
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Brief description
version: 1.0.0
---
# Skill content...
EOF

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
