# Skills Index

Comprehensive catalog of all available Claude Code skills organized by category.

## Quick Reference

| Category | Skills | Use Cases |
|----------|--------|-----------|
| [Claude Meta](#claude-meta) | 3 | Claude Code usage, collaboration, optimization |
| [Project Management](#project-management) | 4 | Project setup, folder organization, environment management, note-taking, backups |
| [Packaging](#packaging) | 1 | Bioconda recipe development |
| [Galaxy](#galaxy) | 4 | Galaxy platform development, automation & training |
| [VGP](#vgp) | 2 | VGP assembly workflows, GenomeArk data access |
| [Bioinformatics](#bioinformatics) | 2 | Core bioinformatics, sequencing analysis |
| [Analysis](#analysis) | 1 | Jupyter notebooks, statistical analysis |
| [Collaboration](#collaboration) | 2 | Project sharing, collaborative documentation |

---

## Claude Meta

Skills for effectively using Claude Code itself.

### collaboration
- **Path:** `claude-meta/collaboration/`
- **Version:** 1.0.0
- **Description:** Best practices for using Claude Code in team environments. Covers skill management, knowledge capture, version control, and collaborative workflows.
- **When to use:** Setting up team workflows, managing shared skills, versioning best practices
- **Key topics:** Skills as living documentation, knowledge capture, team collaboration patterns

### skill-management
- **Path:** `claude-meta/skill-management/`
- **Description:** Expert guide for managing Claude Code global skills and commands. Use when creating new skills, symlinking to projects, updating existing skills, or organizing the centralized skill repository.
- **When to use:** Creating/updating skills, organizing skill repository, setting up new projects
- **Key topics:** Skill creation, templates, symlink management, repository organization

### token-efficiency
- **Path:** `claude-meta/token-efficiency/`
- **Version:** 1.4.0
- **Description:** Token optimization best practices for cost-effective Claude Code usage. Automatically applies efficient file reading, command execution, and output handling strategies.
- **When to use:** Always (foundational skill for cost optimization)
- **Key topics:** Efficient file reading, command optimization, model selection (Opus vs Sonnet), output handling
- **Best practices:** Use tail/grep instead of full reads, prefer bash commands, minimize token usage

---

## Project Management

Project setup, organization, and environment management.

### folder-organization
- **Path:** `project-management/folder-organization/`
- **Version:** 1.0.0
- **Description:** Best practices for organizing project folders, file naming conventions, and directory structure standards for research and development projects.
- **When to use:** Setting up new projects, reorganizing existing projects, establishing team conventions, creating reproducible research structures
- **Key topics:** Project structure templates, file naming conventions, .gitignore best practices, data organization, documentation standards
- **Best practices:** Separate raw/processed data, use numbered sequences, maintain clean structure

### managing-environments
- **Path:** `project-management/managing-environments/`
- **Version:** 1.1.0
- **Description:** Best practices for managing development environments including Python venv and conda. Always check environment status before installations and confirm with user before proceeding.
- **When to use:** Setting up Python projects, managing dependencies, troubleshooting package conflicts, choosing between venv and conda
- **Key topics:** venv creation, conda environments, environment activation, dependency management, bioconda channels
- **Safety:** Always confirm environment before installations

### obsidian
- **Path:** `project-management/obsidian/`
- **Version:** 1.0.0
- **Description:** Integration with Obsidian vault for managing notes, tasks, and knowledge when working with Claude. Supports adding notes, creating tasks, and organizing project documentation using $OBSIDIAN_CLAUDE environment variable.
- **When to use:** Creating session notes, tracking tasks during development, documenting decisions and solutions, building knowledge base, organizing research findings
- **Key topics:** Note templates, task management, wikilinks, tags, helper functions, vault organization, session documentation
- **Best practices:** Atomic notes, linking concepts, hierarchical tags, timestamp everything

### data-backup
- **Path:** `project-management/data-backup/`
- **Version:** 2.0.0
- **Description:** Smart automated backup system with skill integration. Detects project type (notebooks, data files, HackMD docs) and applies appropriate cleanup before backup. Rolling daily backups, compressed milestones, and CHANGELOG tracking.
- **When to use:** Any project with changing files, long-running analyses, data enrichment, or collaborative work
- **Key topics:** Smart detection, skill integration (jupyter-notebook, hackmd, managing-environments), daily/milestone backups, CHANGELOG tracking, session integration with /safe-exit
- **Commands:** `/backup` (setup and execute), `/safe-exit` (prompts for backup)
- **Features:**
  - Automatic cleanup: clears notebook outputs, removes debug cells, cleans Python artifacts
  - Two-tier system: daily rolling (7-day window) + permanent milestones
  - Session integration: prompts for backup when exiting with `/safe-exit`
  - Storage efficient: gzip compression (~80% reduction)

---

## Packaging

Package development and distribution.

### conda-recipe
- **Path:** `packaging/conda-recipe/`
- **Version:** 1.0.0
- **Description:** Expert in building and testing conda/bioconda recipes, including recipe creation, linting, dependency management, and debugging common build errors.
- **When to use:** Creating bioconda packages, troubleshooting conda builds, managing recipe dependencies
- **Key topics:** Recipe structure, meta.yaml, build scripts, bioconda submission

---

## Galaxy

Galaxy platform development, automation, and workflows.

### automation
- **Path:** `galaxy/automation/`
- **Version:** 1.0.0
- **Dependencies:** bioblend, planemo
- **Description:** BioBlend and Planemo expertise for Galaxy workflow automation. Galaxy API usage, workflow invocation, status checking, error handling, batch processing, and dataset management.
- **When to use:** Automating Galaxy workflows, batch processing, API integration, programmatic workflow execution
- **Key topics:** BioBlend API, Planemo, workflow invocation, dataset management, error handling
- **Tools:** BioBlend, Planemo, Galaxy API

### tool-wrapping
- **Path:** `galaxy/tool-wrapping/`
- **Version:** 1.0.0
- **Dependencies:** galaxy-automation
- **Description:** Expert in Galaxy tool wrapper development, XML schemas, Planemo testing, and best practices for creating Galaxy tools.
- **When to use:** Creating Galaxy tool wrappers, XML schema development, testing tools with Planemo
- **Key topics:** XML tool definitions, command-line integration, parameter handling, testing
- **Additional resources:**
  - `reference.md` - Detailed XML schema reference
  - `troubleshooting.md` - Common issues and solutions
  - `dependency-debugging.md` - Dependency resolution

### workflow-development
- **Path:** `galaxy/workflow-development/`
- **Version:** 1.0.0
- **Description:** Expert in Galaxy workflow development, testing, and IWC best practices. Create, validate, and optimize .ga workflows following Intergalactic Workflow Commission standards.
- **When to use:** Creating Galaxy workflows, IWC submissions, workflow optimization, validation
- **Key topics:** .ga format, IWC standards, workflow testing, best practices, optimization

### training-material
- **Path:** `galaxy/training-material/`
- **Version:** 1.0.0
- **Description:** Expert in Galaxy Training Network (GTN) tutorial development. GTN markdown syntax, special boxes, tool references, snippets, YAML front matter, and best practices for writing and updating training materials.
- **When to use:** Writing or editing GTN tutorials, creating new training content, understanding GTN-specific markdown syntax, fixing formatting issues
- **Key topics:** GTN markdown boxes (hands_on, question, tip, comment, details, warning), tool references, parameter icons, snippets, YAML front matter, slides, data libraries, pedagogical best practices

---

## VGP

Vertebrate Genomes Project (VGP) specific skills for assembly workflows and data access.

### vgp-pipeline
- **Path:** `vgp/vgp-pipeline/`
- **Version:** 2.0.0
- **Dependencies:** galaxy-automation
- **Description:** VGP genome assembly orchestration. Workflow sequences, quality control checkpoints for producing high-quality, phased, chromosome-level genome assemblies using Galaxy workflows.
- **When to use:** VGP genome assembly projects, workflow selection, trajectory planning, quality control checkpoints
- **Key topics:** Assembly trajectories (HiFi+Hi-C, Trio, HiFi-only), workflow sequences (WF1-WF9), quality checkpoints, GenomeScope integration
- **Additional resources:**
  - `MIGRATION.md` - Migration guide for workflow updates

### genomeark-aws
- **Path:** `vgp/genomeark-aws/`
- **Version:** 1.0.0
- **Description:** Comprehensive guide for accessing GenomeArk AWS S3 public bucket containing VGP assemblies and QC data. Includes directory structure, all filename patterns, data validation, and best practices for fetching GenomeScope, BUSCO, Merqury metrics, and meryl histograms.
- **When to use:** Accessing VGP genome data from S3, fetching QC metrics, downloading meryl histograms, building automated data retrieval pipelines, troubleshooting S3 access issues
- **Key topics:** S3 bucket structure, GenomeScope/BUSCO/Merqury data locations, filename pattern variations, case sensitivity, data validation, AWS CLI usage, batch processing, rate limiting
- **Critical features:**
  - Three GenomeScope filename patterns (includes easily-missed single underscore pattern)
  - GenomeScope validation logic (detect failed runs)
  - Evolution of directory structure (2022 → 2024+)
  - Meryl histogram access (700KB vs 10GB full database)
  - No credentials required (--no-sign-request)

---

## Bioinformatics

Core bioinformatics concepts and analysis patterns.

### fundamentals
- **Path:** `bioinformatics/fundamentals/`
- **Version:** 1.1.0
- **Description:** Core bioinformatics concepts including SAM/BAM format, AGP genome assembly format, sequencing technologies (Hi-C, HiFi, Illumina), quality metrics, and common data processing patterns.
- **When to use:** Debugging alignment issues, understanding sequence formats, quality control, AGP validation
- **Key topics:** SAM/BAM, AGP format, sequencing technologies, quality metrics, filtering, pairing
- **Additional resources:**
  - `reference.md` - Format specifications and examples
  - `common-issues.md` - Troubleshooting guide

### phylogenetics
- **Path:** `bioinformatics/phylogenetics/`
- **Description:** Phylogenetic tree construction, analysis, and visualization. Tree reconciliation, species mapping, and evolutionary analysis.
- **When to use:** Building phylogenetic trees, evolutionary analysis, tree-based visualizations
- **Key topics:** Tree construction, newick format, species reconciliation, time trees

---

## Analysis

Data analysis and computational notebooks.

### jupyter-notebook
- **Path:** `analysis/jupyter-notebook/`
- **Version:** 1.1.0
- **Description:** Best practices for creating comprehensive Jupyter notebook data analyses with statistical rigor, outlier handling, and publication-quality visualizations. Includes Claude API image size helpers.
- **When to use:** Creating analysis notebooks, statistical analysis, data visualization, publication figures, generating images for Claude review
- **Key topics:** Statistical methods, outlier detection, visualization best practices, reproducibility, Claude image constraints
- **Quality standards:** Statistical rigor, comprehensive documentation, publication-quality outputs

---

## Collaboration

Skills for sharing work and collaborating with teams.

### hackmd
- **Path:** `collaboration/hackmd/`
- **Description:** HackMD collaborative markdown platform best practices, including real-time editing, slide presentations, and embedded content.
- **When to use:** Creating collaborative documentation, presentations, embedded diagrams
- **Key topics:** HackMD syntax, SVG embedding, slide mode, collaboration features

### project-sharing
- **Path:** `collaboration/project-sharing/`
- **Version:** 1.0.0
- **Description:** Prepare organized packages of project files for sharing at different levels - from summary PDFs to fully reproducible archives. Creates copies with cleaned notebooks, documentation, and appropriate file selection.
- **When to use:** Sharing results with collaborators, preparing supplementary materials, creating reproducible packages, archiving projects
- **Key topics:** Three sharing levels (Summary/Reproducible/Full), notebook cleaning, file organization, documentation generation, sensitive data handling
- **Sharing levels:**
  - **Summary:** PDF + final results
  - **Reproducible:** Notebooks + scripts + processed data
  - **Full Traceability:** Raw data + all intermediates + complete documentation

---

## Skill Dependencies

```
galaxy/tool-wrapping
  └─ depends on: galaxy/automation

galaxy/automation
  └─ requires: bioblend, planemo

vgp/vgp-pipeline
  └─ depends on: galaxy/automation
```

---

## Essential Skills & Commands Recommendation

### Foundational Skills

For most projects, include these foundational skills:

1. **claude-meta/token-efficiency** - Always include for cost optimization
2. **claude-meta/skill-management** - Creating, updating, and organizing skills for your projects
3. **claude-meta/collaboration** - Team workflows and knowledge capture
4. **project-management/managing-environments** - Development environment setup and management (venv/conda)
5. **project-management/folder-organization** - Project structure and organization
6. **project-management/obsidian** - Session notes, task tracking, and knowledge management during Claude sessions
7. **project-management/data-backup** - Smart backup system with cleanup, rolling daily backups, and session integration
8. **collaboration/project-sharing** - Prepare organized packages for sharing with collaborators at different levels

### Essential Commands

Use these commands regularly for optimal workflow:

**Session Management:**
- `/safe-exit` - End sessions with notes and optional backup (use instead of plain exit)
- `/safe-clear` - Clear context while preserving knowledge (when switching tasks)

**Project Organization:**
- `/consolidate-notes` - Weekly/bi-weekly consolidation with AI analysis and project status updates
- `/backup` - Create daily or milestone backups
- `/update-manifest` - Update MANIFEST files with session changes
- `/deprecate-file` - Move files to deprecated/ with dependency tracking and MANIFEST updates

**Setup & Help:**
- `/setup-project` - Initialize new projects with skills and commands
- `/command-help` - Get help on any command

Add domain-specific skills as needed for your project type.

---

## Skill Activation

Skills load progressively - Claude sees descriptions first, full content only when:
- Skill name is mentioned explicitly
- Project context triggers skill activation
- Skill is needed for current task

**Manual activation:** Mention the skill name in your message to Claude.

---

## Cross-References Between Skills

Many skills reference each other for related content. When a skill mentions "See the **skill-name** skill," it's pointing you to authoritative documentation on that topic:

**Common cross-references:**
- **Path verification** - Detailed in `folder-organization`, referenced by `project-sharing` and `data-backup`
- **Project structures** - Canonical versions in `folder-organization`, adapted in `project-sharing`
- **Session notes** - Directory structure in `folder-organization`, dump tag details in `obsidian`
- **.gitignore templates** - Complete version in `folder-organization`, environment-specific in `managing-environments`
- **README templates** - General template in `folder-organization`, documentation-specific in `documentation-organization`

---

## File Structure Standard

Each skill follows this structure:
```
skill-name/
├── SKILL.md              # Main skill content (required)
├── reference.md          # Detailed reference (optional)
├── troubleshooting.md    # Common issues (optional)
└── examples/             # Example usage (optional)
```

---

## Maintenance

**Last updated:** 2026-03-02

**Recent changes:**
- 2026-03-02: Added galaxy/training-material skill (GTN tutorial syntax, structure, and best practices)
- 2026-02-26: Created VGP category, moved vgp-pipeline and genomeark-aws from bioinformatics to vgp
- 2026-02-26: Added genomeark-aws skill (comprehensive GenomeArk S3 access guide)
- 2026-02-25: Deduplicated content across skills, added cross-reference section
- 2026-02-25: Added Claude API image size constraints to data-visualization and jupyter-notebook skills

**How to update this index:**
1. When adding new skills, update the relevant category section
2. Update version numbers when skills are modified
3. Keep dependency graph current
4. Update quick reference table counts
5. Review and update essential skills recommendations

**Templates available:** See `../templates/` for skill and command creation templates.
