# Centralized Skill Repository Pattern

**Problem**: Managing skills across multiple projects leads to duplication and maintenance overhead.

**Solution**: Use a centralized repository with selective symlinks and environment variables.

## Setup

1. **Create central repository**:
   ```bash
   mkdir -p $CLAUDE_METADATA/{skills,commands}
   ```

2. **Set environment variable** in `~/.zshrc`:
   ```bash
   export CLAUDE_METADATA="$CLAUDE_METADATA"
   ```

3. **Organize by domain**:
   ```
   $CLAUDE_METADATA/
   ├── skills/
   │   ├── domain-1/SKILL.md
   │   └── domain-2/SKILL.md
   └── commands/
       └── category/
           └── command.md
   ```

## Per-Project Activation

**Key principle**: Only symlink skills needed for each project

```bash
# In project directory
ln -s $CLAUDE_METADATA/skills/domain-1 .claude/skills/domain-1
ln -s $CLAUDE_METADATA/commands/category/*.md .claude/commands/
```

## Benefits

- **No performance penalty**: Progressive disclosure loads skills only when activated
- **Selective activation**: Each project sees only relevant skills
- **Easy maintenance**: Update once, all projects benefit
- **Portable**: Change location via environment variable
- **Team-friendly**: Commit symlinks, team members use their own central repo

## Standardized Setup Prompts

Provide users with copy-paste prompts for new projects in `$CLAUDE_METADATA/QUICK_REFERENCE.md`:

**Basic setup**:
```
Set up Claude Code for this project. Show me available skills in $CLAUDE_METADATA and let me choose which ones to symlink.
```

**Sync existing project**:
```
Check what skills and commands are available in $CLAUDE_METADATA and compare with what's currently symlinked in this project. Show me what's new or missing, and let me choose which ones to add.
```

**VGP-specific**:
```
Set up Claude Code for a VGP pipeline project. Symlink the vgp-pipeline skill and all VGP commands from $CLAUDE_METADATA.
```

## Example Directory Structure

```
$CLAUDE_METADATA/
├── README.md                    # Setup documentation
├── QUICK_REFERENCE.md           # Copy-paste prompts for users
├── NEW_MACHINE_SETUP.md         # First-time machine setup
├── skills/                      # ALL skills (general + project-specific)
│   ├── token-efficiency/        # General skill
│   │   └── SKILL.md
│   ├── claude-collaboration/    # General skill
│   │   └── SKILL.md
│   ├── vgp-pipeline/           # Project-specific skill
│   │   └── SKILL.md
│   └── galaxy-tool-wrapping/   # Domain skill
│       └── SKILL.md
└── commands/                    # ALL commands
    ├── global/                  # Commands for all projects
    │   ├── update-skills.md
    │   └── sync-skills.md
    └── vgp-pipeline/           # Project-specific commands
        ├── check-status.md
        └── debug-failed.md
```

**Key point:** ALL skills and commands live in this central repo. Projects contain only symlinks.

## Migration Pattern

**From duplicated or local skills** (old/wrong way):
```
project-1/.claude/skills/my-skill/SKILL.md          # ❌ Duplicate!
project-2/.claude/skills/my-skill/SKILL.md          # ❌ Duplicate!
project-3/.claude/skills/project-specific/SKILL.md  # ❌ Local only!
```

**To centralized skills** (correct way):
```
$CLAUDE_METADATA/skills/my-skill/SKILL.md          # ✅ Single source of truth
$CLAUDE_METADATA/skills/project-specific/SKILL.md  # ✅ Even project-specific!

project-1/.claude/skills/my-skill -> $CLAUDE_METADATA/skills/my-skill
project-2/.claude/skills/my-skill -> $CLAUDE_METADATA/skills/my-skill
project-3/.claude/skills/project-specific -> $CLAUDE_METADATA/skills/project-specific
```

**Critical rule:** ALL skills in $CLAUDE_METADATA, even if only used by one project.

## Team Workflow

1. **Central repo is git-tracked**:
   ```bash
   cd $CLAUDE_METADATA
   git init
   git remote add origin git@github.com:team/claude-metadata.git
   ```

2. **Team members clone**:
   ```bash
   git clone git@github.com:team/claude-metadata.git $CLAUDE_METADATA
   export CLAUDE_METADATA="$CLAUDE_METADATA"
   ```

3. **Projects use symlinks**:
   ```bash
   # Commit symlinks to project repos
   git add .claude/
   git commit -m "Add Claude Code skill symlinks"
   ```

4. **Updates propagate automatically**:
   ```bash
   # Update central skills
   cd $CLAUDE_METADATA
   git pull

   # All projects with symlinks now use updated skills!
   ```
