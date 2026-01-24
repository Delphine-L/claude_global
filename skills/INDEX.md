# Skills Index

Comprehensive catalog of all available Claude Code skills organized by category.

## Quick Reference

| Category | Skills | Use Cases |
|----------|--------|-----------|
| [Claude Meta](#claude-meta) | 3 | Claude Code usage, collaboration, optimization |
| [Project Management](#project-management) | 3 | Project setup, folder organization, environment management, note-taking |
| [Packaging](#packaging) | 1 | Bioconda recipe development |
| [Galaxy](#galaxy) | 3 | Galaxy platform development & automation |
| [Bioinformatics](#bioinformatics) | 2 | Genome assembly, sequencing analysis |
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

---

## Bioinformatics

Domain-specific bioinformatics knowledge.

### fundamentals
- **Path:** `bioinformatics/fundamentals/`
- **Version:** 1.1.0
- **Description:** Core bioinformatics concepts including SAM/BAM format, AGP genome assembly format, sequencing technologies (Hi-C, HiFi, Illumina), quality metrics, and common data processing patterns.
- **When to use:** Debugging alignment issues, understanding sequence formats, quality control, AGP validation
- **Key topics:** SAM/BAM, AGP format, sequencing technologies, quality metrics, filtering, pairing
- **Additional resources:**
  - `reference.md` - Format specifications and examples
  - `common-issues.md` - Troubleshooting guide

### vgp-pipeline
- **Path:** `bioinformatics/vgp-pipeline/`
- **Description:** VGP genome assembly orchestration. Workflow sequences, GenomeArk integration, quality control checkpoints for producing high-quality, phased, chromosome-level genome assemblies.
- **When to use:** VGP genome assembly projects, workflow selection, quality control
- **Key topics:** Assembly trajectories (HiFi+Hi-C, Trio), workflow sequences (WF1-WF9), GenomeArk, quality checkpoints
- **Additional resources:**
  - `MIGRATION.md` - Migration guide for workflow updates

---

## Analysis

Data analysis and computational notebooks.

### jupyter-notebook
- **Path:** `analysis/jupyter-notebook/`
- **Description:** Best practices for creating comprehensive Jupyter notebook data analyses with statistical rigor, outlier handling, and publication-quality visualizations.
- **When to use:** Creating analysis notebooks, statistical analysis, data visualization, publication figures
- **Key topics:** Statistical methods, outlier detection, visualization best practices, reproducibility
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
```

---

## Essential Skills Recommendation

For most projects, include these foundational skills:

1. **claude-meta/token-efficiency** - Always include for cost optimization
2. **claude-meta/skill-management** - Creating, updating, and organizing skills for your projects
3. **claude-meta/collaboration** - Team workflows and knowledge capture
4. **project-management/managing-environments** - Development environment setup and management (venv/conda)
5. **project-management/folder-organization** - Project structure and organization
6. **project-management/obsidian** - Session notes, task tracking, and knowledge management during Claude sessions

Add domain-specific skills as needed for your project type.

---

## Skill Activation

Skills load progressively - Claude sees descriptions first, full content only when:
- Skill name is mentioned explicitly
- Project context triggers skill activation
- Skill is needed for current task

**Manual activation:** Mention the skill name in your message to Claude.

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

**Last updated:** 2026-01-23

**How to update this index:**
1. When adding new skills, update the relevant category section
2. Update version numbers when skills are modified
3. Keep dependency graph current
4. Update quick reference table counts
5. Review and update essential skills recommendations

**Templates available:** See `../templates/` for skill and command creation templates.
