# Claude Code Global Skills Repository

Centralized skills and commands for Claude Code, symlinked into projects via `enable-skills.sh`. All projects share and auto-update from this single source.

## Table of Contents

- [Setup](#setup)
- [Skills](#skills)
  - [Analysis](#analysis)
  - [Bioinformatics](#bioinformatics)
  - [Claude Meta](#claude-meta) (essential — auto-included)
  - [Collaboration](#collaboration)
  - [Databases](#databases)
  - [Galaxy](#galaxy)
  - [Packaging](#packaging)
  - [Project Management](#project-management) (essential — auto-included)
  - [VGP](#vgp)
- [Commands](#commands)
- [Hooks](#hooks)
- [Adding New Skills](#adding-new-skills)

## Setup

```bash
# Set environment variable (add to ~/.zshrc)
export CLAUDE_METADATA="$HOME/Workdir/claude_global"

# Enable skills in a project
cd /path/to/your/project
bash $CLAUDE_METADATA/enable-skills.sh
```

The setup script detects project type and suggests appropriate skills:

| Project Type | Suggested Skills |
|---|---|
| **Analysis/Research** | All `analysis/*`, `bioinformatics/*`, `databases/*`, `collaboration/hackmd`, `collaboration/project-sharing` |
| **Development** | `packaging/conda-recipe` |
| **Bioinformatics** | All `galaxy/*` |

All `claude-meta/*` and `project-management/*` skills are always included as essentials.

## Skills

### Analysis

| Skill | Description |
|---|---|
| `data-analysis-patterns` | Data aggregation, recalculation vs reuse, category management, analytical accuracy. |
| `data-visualization` | Publication-quality figures with matplotlib/seaborn. Journal-specific `.mplstyle` files (Nature/Science/Cell), colorblind-safe palettes, figure export helpers, Claude API image constraints. |
| `documentation-organization` | Structure working files, prepare sharing packages, clean project layout. |
| `jupyter-notebook` | Comprehensive notebook analyses with statistical rigor, outlier handling, publication-quality visualizations. |
| `scientific-publication` | Iterative refinement of publication figures — systematic improvement, layout optimization. |

### Bioinformatics

| Skill | Description |
|---|---|
| `fundamentals` | SAM/BAM, AGP, sequencing technologies (Hi-C, HiFi, Illumina), quality metrics, alignment debugging. |
| `phylogenetics` | Phylogenetic tree analysis, visualization, annotation management, iTOL troubleshooting. |
| `visualization` | Publication-quality bioinformatics figures — phylogenetic trees, genome browsers, iTOL datasets. |

### Claude Meta

Essential skills defining how Claude works with you. **Auto-included in all projects.**

| Skill | Description |
|---|---|
| `collaboration` | Team workflows — skill management, knowledge capture, version control. |
| `documentation` | Session documentation — incremental summaries, fix reports, audit trails. |
| `skill-management` | Creating, symlinking, updating, and organizing the centralized skill repository. |
| `systematic-debugging` | 4-phase debugging: root cause → pattern analysis → hypothesis → fix. Anti-rationalization tables. |
| `token-efficiency` | Token optimization — efficient file reading, command execution, model selection (Opus for learning, Sonnet for dev). |
| `verification-before-completion` | Evidence-based completion claims. Run verification before claiming success. |

### Collaboration

| Skill | Description |
|---|---|
| `hackmd` | Slide presentations, embedded SVG diagrams, real-time collaborative editing. |
| `project-sharing` | Prepare organized sharing packages at different levels (Summary/Reproducible/Full). |

### Databases

| Skill | Description |
|---|---|
| `bioservices` | Unified Python interface to 40+ bioinformatics services (UniProt, KEGG, ChEMBL, Reactome, PSICQUIC). Cross-database analysis and ID mapping. |
| `gget` | Fast CLI/Python queries to 20+ databases — gene info, BLAST, AlphaFold, enrichment, single-cell, disease associations. |
| `gnomad` | gnomAD GraphQL API — population allele frequencies, constraint scores (pLI, LOEUF), variant pathogenicity, ACMG criteria. |

### Galaxy

| Skill | Description |
|---|---|
| `automation` | BioBlend and Planemo — Galaxy API, workflow invocation, batch processing, dataset management. |
| `tool-wrapping` | Galaxy tool wrapper XML, Planemo testing, best practices. |
| `training-material` | GTN tutorial development — markdown syntax, special boxes, tool references, YAML front matter. |
| `workflow-development` | Galaxy .ga workflows, IWC standards, testing, optimization. |

### Packaging

| Skill | Description |
|---|---|
| `conda-recipe` | Conda/bioconda recipe creation, linting, dependency management, build debugging. |

### Project Management

Essential skills. **Auto-included in all projects.**

| Skill | Description |
|---|---|
| `data-backup` | Smart backups with project type detection. Rolling daily, compressed milestones, CHANGELOG. |
| `folder-organization` | Project folder structure, file naming conventions, directory standards. |
| `managing-environments` | Python venv and conda environment management. |
| `obsidian` | Obsidian vault integration — notes, tasks, knowledge management, MOCs, CLI (1.12+). |

### VGP

| Skill | Description |
|---|---|
| `genomeark-aws` | GenomeArk AWS S3 bucket — VGP assemblies, QC data, species directories. |
| `vgp-pipeline` | VGP assembly pipeline — Galaxy workflow selection, QC checkpoints, batch orchestration. |

## Commands

### Session Management

| Command | Description |
|---|---|
| `/safe-exit` | End session with backup and Obsidian summary. |
| `/safe-clear` | Save notes to Obsidian, update skills, clear context. |

### Project Organization

| Command | Description |
|---|---|
| `/backup` | Smart backup with skill-aware cleanup. |
| `/consolidate-notes` | Consolidate session notes with AI-powered analysis. |
| `/cleanup-project` | Remove working docs, condense verbose READMEs. |
| `/deprecate-file` | Move files to deprecated/ with dependency handling. |
| `/share-project` | Prepare sharing packages (Summary/Reproducible/Full). |

### Navigation & Discovery

| Command | Description |
|---|---|
| `/command-help` | Show help for any command. |
| `/list-skills` | List all available skills with descriptions. |
| `/read-manifest` | Smart session startup — load relevant context. |
| `/generate-manifest` | Generate or update MANIFEST.md file inventories. |
| `/update-manifest` | Quick-update MANIFEST.md preserving user content. |

### Setup & Maintenance

| Command | Description |
|---|---|
| `/setup-project` | Set up Claude Code skills for a new project. |
| `/setup-environment` | Plan and set up Python venv or conda environment. |
| `/sync-skills` | Sync project with global metadata — detect new skills/commands. |
| `/update-skills` | Review session and suggest skill updates. |
| `/update-notebook` | Notebook maintenance — figures, references, TOC, coherence. |

### Planning

| Command | Description |
|---|---|
| `/design-and-plan` | Brainstorm → design → plan → execute workflow for complex tasks. |

## Hooks

Hooks live in `hooks/` and are symlinked to `~/.claude/hooks/`. Configured in `~/.claude/settings.json` with portable `~/` paths.

```bash
# Setup on a new machine
mkdir -p ~/.claude/hooks
ln -s $CLAUDE_METADATA/hooks/safety ~/.claude/hooks/safety
ln -s $CLAUDE_METADATA/hooks/peon-ping ~/.claude/hooks/peon-ping
```

### Safety Hooks (`hooks/safety/`)

#### Blocking (PreToolUse)

| Hook | Matcher | What it does |
|---|---|---|
| `git-guard.sh` | `Bash` | Blocks `reset --hard`, `push --force`, `clean -f`, `checkout -- .`, `stash drop/clear`, `branch -D` |
| `protect-files.sh` | `Write\|Edit` | Blocks edits to `.env`, `raw/`, `datasets/`, `.log`, lock files |

#### Context Preservation

| Hook | Event | What it does |
|---|---|---|
| `context-reinject.sh` | `SessionStart` / `compact` | Re-injects branch, commits, conda env, project-config, and PROGRESS.md after compaction |
| `transcript-backup.sh` | `PreCompact` | Saves transcript before compaction (keeps last 20) |

#### Progress Tracking

| Hook | Event | What it does |
|---|---|---|
| Prompt hook | `SessionEnd` (`clear\|logout\|prompt_input_exit`) | Claude writes/updates PROGRESS.md with task summary, accomplishments, next steps, key decisions. Also updates MANIFEST.md if present. |
| Prompt hook | `PreCompact` | Same as above — preserves context before compaction |
| `progress-update-fallback.sh` | `SessionEnd`, `PreCompact` | Fallback if prompt hook fails — writes mechanical PROGRESS.md from git state (branch, recent commits, changed files) or filesystem (recent files, project contents). Skips if PROGRESS.md was updated in the last 60s. |

#### Auto-formatting (PostToolUse, async)

| Hook | Matcher | What it does |
|---|---|---|
| `auto-format.sh` | `Edit\|Write` | Runs `ruff format` on .py files |
| `notebook-strip.sh` | `Edit\|Write\|NotebookEdit` | Runs `nbstripout` on .ipynb files |
| `command-audit.sh` | `Bash` | Logs commands to `.claude/command-audit.log` |

### Peon Ping (`hooks/peon-ping/`)

Sound notification system that plays audio cues on hook events (session start/end, tool use, errors, etc.). Supports multiple voice packs, volume control, and push notifications (ntfy, Pushover, Telegram) via environment variables.

| Config | Description |
|---|---|
| `config.json` | Volume, active pack, rotation mode, notification settings |
| `packs/` | Voice pack sound files |
| `scripts/` | Helper scripts for renaming, usage tracking |

## Adding New Skills

```bash
mkdir skills/category/my-skill
# Create SKILL.md with frontmatter (name, description, version, allowed-tools)
# Keep SKILL.md under 500 lines — move details to supporting files
# Add to enable-skills.sh suggested list if appropriate
```

See `skills/claude-meta/skill-management/` for the complete guide.
