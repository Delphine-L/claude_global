# Centralized Claude Code Skills & Commands

This directory contains centralized Claude Code skills and commands that can be reused across multiple projects via symlinks.

**📋 Quick Start:** See [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md) for copy-paste prompts and commands.

## Directory Structure

```
$CLAUDE_METADATA (your claude_data directory)
├── README.md                      # This file
├── QUICK_REFERENCE.md            # Quick copy-paste prompts
├── SETUP_PROMPT.md               # Detailed setup prompts
├── skills/                        # Centralized agent skills
│   ├── vgp-pipeline/             # VGP workflow automation
│   │   └── SKILL.md
│   ├── galaxy-tool-wrapping/     # Galaxy tool development
│   │   └── SKILL.md
│   └── claude-skill-management/  # Skill management guide
│       └── SKILL.md
├── commands/                      # Centralized slash commands
│   ├── global/                   # Global commands (all projects)
│   │   ├── update-skills.md
│   │   ├── list-skills.md
│   │   ├── setup-project.md
│   │   └── sync-skills.md
│   └── vgp-pipeline/             # VGP-specific commands
│       ├── check-status.md
│       ├── debug-failed.md
│       ├── optimize-token-usage.md
│       ├── setup-cron.md
│       └── update-skills.md
├── templates/                     # Templates for creating skills/commands
│   ├── README.md                 # Template usage guide
│   ├── skill-basic.md            # Simple skill template
│   ├── skill-with-references.md  # Advanced skill template
│   ├── reference.md              # Reference doc template
│   ├── troubleshooting.md        # Troubleshooting template
│   ├── command.md                # Command template
│   ├── create-skill.sh           # Helper script for skills
│   └── create-command.sh         # Helper script for commands
└── .claude/                       # Global skills
    └── skills/
        ├── token-efficiency/
        ├── claude-collaboration/
        └── galaxy-automation/
```

**Environment Variable**: `CLAUDE_METADATA` is set in `~/.zshrc` to point to this directory

## How It Works

### Skills Discovery
Claude Code automatically discovers skills from:
1. **Personal skills**: `~/.claude/skills/` (available globally)
2. **Project skills**: `.claude/skills/` (per-project)
3. **Plugin skills**: bundled with installed plugins

### Progressive Loading
Skills use **progressive disclosure** to minimize token usage:
- Claude sees all skill **descriptions** when starting
- Full skill content is only loaded **when activated**
- Having many skills available doesn't impact performance

### Selective Activation
You can guide Claude to use specific skills by:
- **Mentioning by name**: "Use the galaxy-tool-wrapping skill to create a new tool"
- **Matching description**: "Use the skill for VGP pipelines to check workflow status"
- **Context-based**: Claude activates skills automatically based on your request

## Available Skills

### token-efficiency

**Purpose:** Automatic token optimization for cost-effective Claude Code usage

**Location:** `.claude/skills/token-efficiency/SKILL.md`

**What it does:**
- Automatically uses `--quiet` flags when available
- Reads only the end of log files (not entire files)
- Filters command output before reading
- Checks metadata before reading large files
- Uses grep instead of reading full files
- Summarizes findings instead of dumping raw data

**Token savings:** 80-90% reduction in typical usage

**Impact:**
- Claude Pro users can handle 5-10x more interactions
- Reduces risk of hitting usage limits
- Maintains high-quality assistance while being cost-effective

### claude-collaboration

**Purpose:** Best practices for team collaboration with Claude Code

**Location:** `.claude/skills/claude-collaboration/SKILL.md`

**What it does:**
- Explains how skills work and when to update them
- Provides patterns for organizing skills (project vs global)
- Shows how to version control skills with git
- Teaches effective knowledge capture strategies
- Demonstrates team skill-sharing workflows

**Key concepts:**
- Skills are permanent, sessions are temporary
- Update skills explicitly - Claude doesn't auto-update
- Use git for version control and team sharing
- Regular reviews keep skills valuable

**Impact:**
- Team consistency across all Claude Code sessions
- Accumulated knowledge doesn't get lost
- New team members onboard faster with shared skills
- Best practices propagate automatically

### galaxy-automation

**Purpose:** BioBlend and Planemo expertise for Galaxy workflow automation

**Location:** `.claude/skills/galaxy-automation/SKILL.md`

**What it does:**
- Provides foundational knowledge of BioBlend (Galaxy Python API)
- Explains Planemo command structure and job YAML format
- Demonstrates workflow invocation and status checking patterns
- Shows how to handle failed invocations and implement reruns
- Covers Galaxy histories, workflows, datasets, and collections
- Implements thread-safe batch processing patterns
- Security best practices (API key masking, path handling)

**Key concepts covered:**
- GalaxyInstance initialization and connection
- Workflow invocation with parameter mapping
- Invocation status polling and error categorization
- Dataset and collection management
- Planemo run commands and output parsing
- Common automation patterns (retries, caching, resume capability)

**When to use:**
- Any Galaxy workflow automation project
- Building batch processing systems with Galaxy
- Debugging BioBlend or Planemo errors
- Learning Galaxy API patterns
- Implementing workflow orchestration

**Impact:**
- Universal Galaxy automation knowledge available to all projects
- Reduces duplication across project-specific skills
- Serves as foundation for specialized skills (like vgp-pipeline)

### vgp-pipeline

**Purpose:** Expert knowledge for VGP genome assembly pipeline orchestration codebase

**Dependencies:** galaxy-automation

**Location:** `skills/vgp-pipeline/SKILL.md`

**What it does:**
- VGP-specific workflow orchestration (batch_vgp_run/ codebase)
- VGP workflow sequence logic (WF1 → WF4 → WF8 → WF9 → PreCuration)
- VGP metadata collection and GenomeArk integration
- VGP assembly ID handling and directory structure
- VGP-specific error handling (expected mitochondrial failures)
- Guides through profile.yaml configuration for VGP workflows
- Manages VGP template system and job YAML generation
- Handles species with non-standard GenomeArk structures

**Key VGP workflows covered:**
- WF1 (VGP1): Kmer profiling with HiFi data
- WF4 (VGP3/VGP4): Assembly with HiFi and Hi-C phasing
- WF8: Haplotype-specific scaffolding
- WF9: Decontamination (Kraken2 legacy or NCBI FCS-GX)
- WF0: Mitochondrial assembly
- PreCuration: Pretext maps for manual curation

**Note:** For general Galaxy automation (BioBlend/Planemo), see galaxy-automation skill. vgp-pipeline focuses only on VGP-specific orchestration logic.

### galaxy-tool-wrapping

**Purpose:** Expert in Galaxy tool wrapper development, XML schemas, and Planemo testing

**Location:** `skills/galaxy-tool-wrapping/SKILL.md`

**What it does:**
- Creates new Galaxy tool wrappers from scratch
- Converts command-line tools to Galaxy wrappers
- Debugs XML syntax and validation errors
- Writes Planemo tests for tools
- Implements conditional parameters and data types
- Handles tool dependencies (conda, containers)
- Optimizes tool performance and resource allocation

**Key concepts covered:**
- Galaxy tool XML structure
- Command blocks with Cheetah templating
- Input parameters and validators
- Output specifications and collections
- Automated testing with Planemo
- Best practices and IUC standards

### claude-skill-management

**Purpose:** Expert guide for managing Claude Code global skills and commands

**Location:** `skills/claude-skill-management/SKILL.md`

**What it does:**
- Creates new skills in `$CLAUDE_METADATA`
- Symlinks skills and commands to projects
- Updates existing skills
- Synchronizes projects with global repository
- Troubleshoots skill activation issues
- Organizes centralized skill repository
- Manages version control with git

**When to use:**
- Setting up new skills or commands
- Adding skills to new projects
- Updating skills after learning new patterns
- Debugging skill discovery issues
- Understanding the centralized pattern

---

## Global Commands (Useful for All Projects)

**Location:** `commands/global/`

These commands are useful across all projects and should be symlinked to every new project.

### /update-skills

**Purpose:** Review session and suggest skill updates

**What it does:**
- Analyzes conversation for new patterns and solutions
- Categorizes findings by relevant skill file
- Suggests updates with priority levels (high/medium/low)
- Provides draft markdown text to add
- Asks for approval before making changes
- Commits updates with clear messages

**When to use:**
- At the end of productive sessions
- After solving complex problems
- When discovering new optimization techniques
- After repeated patterns emerge

### /list-skills

**Purpose:** Show all available skills in $CLAUDE_METADATA

**What it does:**
- Scans both global and project-specific skills
- Extracts name, description, and version from frontmatter
- Shows which skills are already linked in current project
- Organizes by category (Global, Bioinformatics, Development, etc.)
- Provides commands to symlink additional skills

**When to use:**
- Exploring what skills are available
- Setting up a new project
- Discovering skills for specific use cases

### /setup-project

**Purpose:** Set up Claude Code skills for a new project intelligently

**What it does:**
- Creates `.claude/skills/` and `.claude/commands/` directories
- Automatically symlinks essential global skills (token-efficiency, claude-collaboration)
- Automatically symlinks global commands
- Detects project type (VGP, Galaxy, bioconda, etc.)
- Recommends relevant project-specific skills
- Verifies setup and suggests git commit message

**When to use:**
- Starting any new project
- Quick project initialization
- Ensuring consistent setup across projects

**Usage:**
```bash
# First time in a new project, symlink the command:
mkdir -p .claude/commands
ln -s $CLAUDE_METADATA/commands/global/setup-project.md .claude/commands/

# Then use it:
/setup-project
```

### /sync-skills

**Purpose:** Sync project with $CLAUDE_METADATA - detect new skills/commands

**What it does:**
- Compares current symlinks with available skills/commands in $CLAUDE_METADATA
- Shows NEW skills/commands added since project setup
- Shows CURRENT skills (already linked)
- Detects BROKEN symlinks (if any)
- Recommends project-specific skills based on detected project type
- Offers to symlink new additions
- Suggests git commit message for changes

**When to use:**
- After adding new skills to $CLAUDE_METADATA
- Periodically (monthly) to stay up to date
- When switching between projects
- After team members add skills to shared repo
- To see what you're missing

**Usage:**
```bash
/sync-skills
```

**Output example:**
```
Currently Linked: token-efficiency, claude-collaboration, vgp-pipeline
NEW Available: conda-recipe, galaxy-workflow-development
Recommended: conda-recipe (detected recipes/ directory)
```

### /cleanup-project

**Purpose:** End-of-project cleanup - removes working documentation and condenses verbose READMEs

**What it does:**
- Analyzes only files changed in current git branch vs base branch (main/master)
- Identifies working documentation (TODO.md, NOTES.md, PLAN.md, etc.)
- Finds test data, debug logs, and temporary files
- Detects verbose READMEs (> 200 lines)
- Shows git-aware categorization (tracked vs untracked)
- Suggests removals and condensing with interactive approval
- Creates backup before making any changes
- Condenses READMEs to essential info only (Purpose, Install, Usage, Key Examples)

**When to use:**
- End of feature development (before merging PR)
- After completing a project milestone
- Before archiving/releasing a project
- When cleaning up a messy working branch

**Usage:**
```bash
# On your feature branch
/cleanup-project

# Command will:
# 1. Detect current branch vs main
# 2. Show files changed only in your branch
# 3. Categorize documentation for cleanup
# 4. Ask for approval
# 5. Create backup and execute changes
```

**Safety features:**
- Only touches files YOU worked on in current branch
- Conservative with git-tracked files
- Interactive approval (no automatic deletions)
- Creates timestamped backup before changes
- Detailed summary report

---

## Setting Up a New Project

### Quick Start: Use This Prompt

When starting a new project, simply tell Claude:

**Recommended (includes essentials + selective):**
```
Set up Claude Code for this project. Symlink the essential global skills
(token-efficiency, claude-collaboration, galaxy-automation) and global commands from $CLAUDE_METADATA.
Then show me other available skills and let me choose which ones are relevant.
```

**Or use the /setup-project command:**
```
/setup-project
```
(if you've already symlinked the global commands once)

**For all skills:**
```
Set up Claude Code skills and commands for this project. Create symlinks to all
available skills and commands in $CLAUDE_METADATA, including the global commands.
```

**For selective skills (manual):**
```
Set up Claude Code for this project. Show me available skills in $CLAUDE_METADATA
and let me choose which ones to symlink.
```

**For VGP projects:**
```
Set up Claude Code for a VGP pipeline project. Symlink the essential global skills,
global commands, vgp-pipeline skill, and all VGP commands from $CLAUDE_METADATA.
```

**For Galaxy tool development:**
```
Set up Claude Code for Galaxy tool development. Symlink the essential global skills,
global commands, and galaxy-tool-wrapping skill from $CLAUDE_METADATA.
```

**To sync/update an existing project:**

If global commands already symlinked:
```
/sync-skills
```

If global commands NOT yet symlinked:
```
Set up global commands from $CLAUDE_METADATA and sync this project with available
skills and commands. First, symlink all global commands (update-skills, list-skills,
setup-project, sync-skills), then run sync-skills to detect what else I should add.
```

Manual alternative:
```
Check what skills and commands are available in $CLAUDE_METADATA and compare with what's currently symlinked in this project. Show me what's new or missing, and let me choose which ones to add.
```

See `SETUP_PROMPT.md` for more examples and detailed prompts.

### Manual Setup

### Option 1: Symlink Entire Skill Directories (Recommended)

```bash
# Navigate to your project
cd ~/Workdir/your-project/

# Create .claude directories if they don't exist
mkdir -p .claude/skills .claude/commands

# Symlink skills you need
ln -s $CLAUDE_METADATA/skills/vgp-pipeline .claude/skills/vgp-pipeline
ln -s $CLAUDE_METADATA/skills/galaxy-tool-wrapping .claude/skills/galaxy-tool-wrapping

# Symlink commands (wildcard links all .md files)
ln -s $CLAUDE_METADATA/commands/vgp-pipeline/*.md .claude/commands/

# Or link legacy global skills
ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/token-efficiency
```

### Option 2: Symlink to Personal Skills (Global Access)

```bash
# Make skills available to ALL projects
mkdir -p ~/.claude/skills
ln -s $CLAUDE_METADATA/skills/galaxy-tool-wrapping ~/.claude/skills/galaxy-tool-wrapping
ln -s $CLAUDE_METADATA/skills/vgp-pipeline ~/.claude/skills/vgp-pipeline
```

### Option 3: Selective Command Symlinks

```bash
# Only link specific commands you need
ln -s $CLAUDE_METADATA/commands/vgp-pipeline/check-status.md .claude/commands/
ln -s $CLAUDE_METADATA/commands/vgp-pipeline/debug-failed.md .claude/commands/
```

## Example: VGP Project Setup

The VGP-planemo-scripts project currently has:

```bash
.claude/
├── skills/
│   ├── token-efficiency -> $CLAUDE_METADATA/.claude/skills/token-efficiency
│   ├── claude-collaboration -> $CLAUDE_METADATA/.claude/skills/claude-collaboration
│   ├── galaxy-automation -> $CLAUDE_METADATA/.claude/skills/galaxy-automation
│   └── vgp-pipeline -> $CLAUDE_METADATA/skills/vgp-pipeline
└── commands/
    ├── check-status.md -> $CLAUDE_METADATA/commands/vgp-pipeline/check-status.md
    ├── debug-failed.md -> $CLAUDE_METADATA/commands/vgp-pipeline/debug-failed.md
    ├── optimize-token-usage.md -> $CLAUDE_METADATA/commands/vgp-pipeline/optimize-token-usage.md
    ├── setup-cron.md -> $CLAUDE_METADATA/commands/vgp-pipeline/setup-cron.md
    └── update-skills.md -> $CLAUDE_METADATA/commands/vgp-pipeline/update-skills.md
```

**Note:** vgp-pipeline v2.0.0 depends on galaxy-automation for BioBlend/Planemo knowledge.

To add galaxy-tool-wrapping skill:

```bash
cd ~/Workdir/VGP-planemo-scripts
ln -s $CLAUDE_METADATA/skills/galaxy-tool-wrapping .claude/skills/galaxy-tool-wrapping
```

Then tell Claude: "Use the galaxy-tool-wrapping skill to create a new tool for genome assembly"

## Adding New Skills

**Recommended: Use the skill templates!**

See `templates/` directory for standardized templates and helper scripts.

### Quick Start with Templates

**Method 1: Using helper script (easiest)**
```bash
cd $CLAUDE_METADATA
./templates/create-skill.sh my-new-skill "Brief description"
```

**Method 2: Manual copy from template**
```bash
cd $CLAUDE_METADATA/skills
mkdir my-new-skill
cp ../templates/skill-basic.md my-new-skill/SKILL.md
# Edit and customize
```

**Method 3: Ask Claude**
```
Create a new skill using the template from $CLAUDE_METADATA/templates/skill-basic.md
for [topic description].
```

For detailed guidance, see: `templates/README.md`

### Manual Creation (without templates)

### 1. Create Skill Directory

```bash
mkdir -p $CLAUDE_METADATA/skills/your-skill-name
```

### 2. Create SKILL.md with Frontmatter

```markdown
---
name: your-skill-name
description: Brief description that helps Claude decide when to use this skill
version: 1.0.0
---

# Your Skill Name

Detailed instructions for Claude when this skill is activated.

## When to Use This Skill

- Specific use case 1
- Specific use case 2

## Core Concepts

...your instructions...
```

### 3. Add Supporting Files (Optional)

```bash
# Add reference documentation
cp $CLAUDE_METADATA/templates/reference.md $CLAUDE_METADATA/skills/your-skill-name/

# Add troubleshooting
cp $CLAUDE_METADATA/templates/troubleshooting.md $CLAUDE_METADATA/skills/your-skill-name/

# Add examples
mkdir $CLAUDE_METADATA/skills/your-skill-name/examples
```

### 4. Link to Project

```bash
ln -s $CLAUDE_METADATA/skills/your-skill-name .claude/skills/your-skill-name
```

## Adding New Commands

**Recommended: Use the command template!**

### Quick Start with Template

**Method 1: Using helper script (easiest)**
```bash
cd $CLAUDE_METADATA
./templates/create-command.sh category command-name "Brief description"
```

**Method 2: Manual copy from template**
```bash
cp $CLAUDE_METADATA/templates/command.md \
   $CLAUDE_METADATA/commands/category/command-name.md
# Edit and customize
```

For detailed guidance, see: `templates/README.md`

### Manual Creation (without templates)

### Create Command File

```bash
cat > $CLAUDE_METADATA/commands/category/command-name.md << 'EOF'
---
name: command-name
description: Brief description shown in /help
---

Your command prompt here. This will be expanded when the user types /command-name
EOF
```

### Link to Project

```bash
ln -s $CLAUDE_METADATA/commands/category/command-name.md .claude/commands/
```

## Best Practices

### Skill Design
- **Keep skills focused**: One skill per domain/technology
- **Clear descriptions**: Help Claude understand when to activate
- **Progressive detail**: Put common info in SKILL.md, detailed info in reference.md
- **Test activation**: Verify Claude activates the right skill for your requests

### Organization
- **Group by domain**: Skills for related technologies in one directory
- **Separate project vs personal**: Use project skills for team-shared, personal for your workflow
- **Version control**: Commit symlinks to project repos, not actual files
- **Document dependencies**: Note if skills require specific tools installed

### Naming Conventions
- **Skills**: kebab-case (galaxy-tool-wrapping, vgp-pipeline)
- **Commands**: kebab-case matching functionality (check-status, debug-failed)
- **SKILL.md**: Always uppercase, required filename
- **Supporting files**: lowercase, descriptive (reference.md, examples.md)

## Troubleshooting

### Skill Not Activating
1. Check description is clear and matches your request
2. Try explicitly mentioning the skill name
3. Verify SKILL.md has proper frontmatter (name and description)
4. Check symlink points to correct location: `ls -la .claude/skills/`

### Command Not Found
1. Verify symlink exists: `ls -la .claude/commands/`
2. Check command file has proper frontmatter
3. Restart Claude Code session if recently added

### Symlink Issues
1. Use absolute paths in symlinks: `$CLAUDE_METADATA/...`
2. Verify target exists: `ls -la $CLAUDE_METADATA/skills/...`
3. Check permissions: `chmod 644` for .md files, `chmod 755` for directories
4. Verify `$CLAUDE_METADATA` is set: `echo $CLAUDE_METADATA` should show your claude_data directory path

## Global Skills Usage

### Option 1: Symlink to Specific Projects (Recommended)

Create a symlink in your project directory to use these global skills:

```bash
# From your project directory
cd ~/Workdir/my-project
ln -s $CLAUDE_METADATA/.claude .claude-global

# Or merge with existing .claude directory
mkdir -p .claude/skills
ln -s $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/token-efficiency
```

### Option 2: Copy to Project

Copy the skill files to your project's `.claude/skills/` directory:

```bash
# From your project directory
mkdir -p .claude/skills
cp -r $CLAUDE_METADATA/.claude/skills/token-efficiency .claude/skills/
```

### Option 3: Set as Default for All Projects

Add to your shell startup file (~/.bashrc or ~/.zshrc):

```bash
# Set environment variable for Claude Code
export CLAUDE_SKILLS_PATH="$CLAUDE_METADATA/.claude/skills"
```

Note: This depends on whether Claude Code supports this environment variable (check Claude Code documentation).

### Option 4: Work Directly in claude_data

Simply start Claude Code sessions in the `$CLAUDE_METADATA` directory:

```bash
cd $CLAUDE_METADATA
# Open your editor with Claude Code
```

The `.claude/skills/` will be automatically detected.

## Verifying Skills Are Loaded

When you open Claude Code in a directory with skills, you should see the skill being used automatically. You can verify by:

1. Asking Claude to check a large log file - it should use `tail` or `grep` automatically
2. Asking for command output - it should use `--quiet` mode by default
3. Asking Claude: "What skills are currently loaded?"

## Overriding Token Efficiency

If you need full output for a specific task, just ask:

```
"Show me the full log file (don't worry about tokens)"
"Read the entire file without filtering"
"Use verbose mode for this command"
```

## Creating Your Own Global Skills

Add new skills to `.claude/skills/` directory:

```bash
mkdir -p $CLAUDE_METADATA/.claude/skills/my-skill
nano $CLAUDE_METADATA/.claude/skills/my-skill/SKILL.md
```

Skill file format:
```markdown
---
name: my-skill
description: What this skill does
version: 1.0.0
---

# Skill Name

Skill content here...
```

## Benefits

**With token-efficiency skill active:**
- Status checks: 15K → 2K tokens (87% savings)
- Error debugging: 200K → 8K tokens (96% savings)
- Weekly monitoring: 60K → 8K tokens (87% savings)

**Impact on Claude plans:**
- **Claude Pro:** Comfortable for 10-15 species VGP runs
- **Claude Pro:** Can handle moderate production workloads
- **Claude Team:** Excellent for large-scale operations

## Maintenance

Update skills periodically to incorporate new best practices:

```bash
cd $CLAUDE_METADATA
git pull  # If using git
# Or manually edit .claude/skills/*/SKILL.md
```
