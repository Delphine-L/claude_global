# MANIFEST System for Token-Efficient Navigation

For large data analysis projects, implement a MANIFEST system to enable efficient project navigation and minimize token usage in Claude Code sessions.

## Problem Statement

**Challenge**: Large projects with many files consume excessive tokens during session startup:
- Reading large notebooks (4-6 MB) = 5,000-15,000 tokens
- Exploring data files and structure = 3,000-5,000 tokens
- Understanding scripts and workflows = 2,000-3,000 tokens
- **Total: 15,000-23,000 tokens just for orientation!**

**Solution**: MANIFEST files provide lightweight project indexes (~500-2,000 tokens each) that give complete context without reading actual files.

## Token Efficiency Impact

**Before MANIFESTs** (reading actual files):
```
Root MANIFEST: N/A
Notebooks: ~10,000-15,000 tokens (reading 3 large notebooks)
Data exploration: ~3,000-5,000 tokens
Scripts analysis: ~2,000-3,000 tokens
---
Total: ~15,000-23,000 tokens for project orientation
```

**After MANIFESTs** (reading indexes):
```
Root MANIFEST: ~1,500 tokens (full project overview)
Subdirectory MANIFEST: ~500-1,000 tokens (specific area)
---
Total: ~2,000-2,500 tokens for complete context
Savings: 85-90% token reduction!
```

## What is a MANIFEST?

A MANIFEST.md file is a comprehensive index for a directory that includes:
- **Quick Reference**: Entry points, key outputs, dependencies
- **File Inventory**: All files with descriptions, sizes, purposes
- **Workflow Dependencies**: How files relate and depend on each other
- **Notes for Resuming Work**: Current status, next steps, known issues
- **Metadata**: Tags, environment info, Obsidian notes links

**Key Principle**: MANIFEST provides 80% of context needed to resume work in 500-2,000 tokens instead of reading 5,000-15,000 tokens of actual files.

## MANIFEST Structure

### Root Directory MANIFEST Template

```markdown
# [Project Name] - ROOT MANIFEST

**Last Updated**: YYYY-MM-DD
**Purpose**: [1-2 sentence description]
**Status**: Active/Deprecated/Archive

---

## Quick Reference

**Entry Points**: [Which files to read first]
**Key Outputs**: [Main deliverables]
**Dependencies**: [External requirements]

---

## Files

### Notebooks

#### `notebook_name.ipynb` (Size)
- **Purpose**: [What analysis/questions does this answer?]
- **Depends on**: [Input files, data, scripts]
- **Generates**: [Output files, figures]
- **Key findings**: [1-2 sentence summary]
- **Last modified**: YYYY-MM-DD
- **Execution time**: [~X minutes if relevant]
- **Priority**: [Main document or complementary analysis]

### Key Directories

#### `data/` (Size)
See `data/MANIFEST.md` for details.
- **Contents**: [Brief description]
- **Key files**: [Most important files]

[Repeat for figures/, scripts/, documentation/]

---

## Directory Structure

```
project/
├── MANIFEST.md (this file)
├── data/
│   └── MANIFEST.md
├── figures/
│   └── MANIFEST.md
└── [etc.]
```

---

## Workflow Dependencies

```
[Visual or text description of data -> processing -> outputs flow]

Example:
1. Data Acquisition: fetch_data.py -> data/raw/
2. Processing: process.py -> data/processed/
3. Analysis: analysis.ipynb -> figures/
```

---

## Notes for Resuming Work

**Current Status**: [What was last completed?]
**Next Steps**: [What needs to be done next?]
**Known Issues**: [Problems, TODOs, blockers]
**Reference**: [Links to related docs, other MANIFESTs]

---

## Metadata

**Created by**: Claude Code
**Project**: [Project name]
**Tags**: [#keywords #for #searching]
**Environment**: [conda env name or venv path]
**Obsidian notes path**: [Link to project notes]

---

## For Claude Code Sessions

**Quick Start for New Sessions**:
1. Read this MANIFEST.md (~500 tokens)
2. Read relevant subdirectory MANIFEST.md (~500 tokens)
3. Only read actual files when editing them

**Token Efficiency**:
- This MANIFEST provides 80% of context needed
- Subdirectory MANIFESTs provide detailed file info
- Read actual code/notebooks only when making changes
```

### Subdirectory MANIFEST Template

Use the same structure but focused on the specific directory. For subdirectories:

**data/MANIFEST.md** - Focus on:
- Data provenance (where data came from)
- File formats and structure (rows, columns, size)
- Data dependencies (which files depend on which)
- Processing history (original -> processed versions)

**figures/MANIFEST.md** - Focus on:
- Which code generates which figure
- Figure purpose and key message
- Manuscript figure numbering
- Figure dependencies (data sources)

**scripts/MANIFEST.md** - Focus on:
- Script purpose and I/O
- Execution order and dependencies
- Usage examples and parameters
- Required dependencies

**documentation/MANIFEST.md** - Focus on:
- Document organization by category
- Critical entry points (RESUME_HERE.md)
- Active vs archived status
- Session summary locations

## Linking MANIFESTs Across Directories

When implementing analysis_files/ (Iteration 2), create bidirectional links:

**In figures/MANIFEST.md** - Link to analysis files:
```markdown
**01_figure_name.png** (318 KB)
- **Description**: Brief description
- **Analysis file**: `../analysis_files/figures/01_figure_name.md` - Detailed analysis
```

**In analysis_files/MANIFEST.md** - Link back to figures:
```markdown
#### 01_figure_name.md
- **Figure file**: `figures/curation_impact_3cat/01_figure_name.png`
- **Purpose**: Detailed analysis and interpretation
```

**In root MANIFEST.md** - Reference both:
```markdown
#### `analysis_files/` (~90 KB) **[NEW - ITERATION 2]**
- **Purpose**: Separate markdown files for figure analyses
- **Token efficiency**: ~98% reduction vs notebooks
- **Links to**: figures/ directory
```

This creates a navigable web of documentation.

## MANIFEST Template File

Create `MANIFEST_TEMPLATE.md` in project root as a starting point. See the template in the Curation_Paper_figures project for a complete example with all sections and guidance.

## Commands for MANIFEST Management

### /generate-manifest Command

Create this command in `.claude/commands/generate-manifest.md` (or symlink from global commands):

**Purpose**: Automatically generates MANIFEST files by analyzing directory contents

**Key Features**:
- Analyzes directory type (root, data, figures, scripts, documentation)
- Extracts file information efficiently (sizes, dates, row counts)
- Identifies dependencies by searching code for file references
- Maps workflow relationships
- Uses AskUserQuestion for ambiguous information
- Marks fields requiring user input

**Usage**:
```bash
/generate-manifest              # Interactive mode
/generate-manifest data         # Generate for data/
/generate-manifest figures      # Generate for figures/
```

**Implementation Tips**:
- Don't read entire large files - use targeted searches
- Extract docstrings and header comments from scripts
- Use grep to find file references in code
- Check first/last cells of notebooks for descriptions
- Get row counts with `wc -l` for CSV files
- Target 1000-2000 tokens for root, 500-1000 for subdirectories

### /update-manifest Command

Create this command in `.claude/commands/update-manifest.md`:

**Purpose**: Quickly updates existing MANIFESTs while preserving user content

**Key Features**:
- Preserves user-entered descriptions and notes
- Updates dates, sizes, and file existence
- Captures session context (asks "What did you accomplish?")
- Three modes: Minimal, Quick (default), Full
- Provides update summary

**Usage**:
```bash
/update-manifest              # Update current directory
/update-manifest data         # Update data/MANIFEST.md
/update-manifest --quick      # Force quick mode
/update-manifest --full       # Full re-analysis
```

**Session End Pattern**:
```bash
/update-manifest              # Capture session progress
/update-skills               # Save new knowledge
/safe-exit                   # Clean exit with notes
```

## MANIFEST Workflow

### Initial Setup

1. **Create template**:
   ```bash
   # Copy MANIFEST_TEMPLATE.md to project root
   # Or use /generate-manifest to create from scratch
   ```

2. **Generate root MANIFEST**:
   ```bash
   /generate-manifest
   # Choose "root directory"
   # Fill in user-specific fields
   ```

3. **Generate subdirectory MANIFESTs**:
   ```bash
   /generate-manifest data
   /generate-manifest figures
   /generate-manifest scripts
   /generate-manifest documentation
   ```

4. **Customize MANIFESTs**:
   - Fill in [USER TO FILL] placeholders
   - Add key findings summaries
   - Document environment setup
   - Add Obsidian notes paths

### During Active Development

1. **Start session** - Read MANIFESTs for context:
   ```bash
   cat MANIFEST.md              # Project overview
   cat figures/MANIFEST.md      # If working on figures
   ```

2. **Work on project** - Normal development

3. **End session** - Update MANIFESTs:
   ```bash
   /update-manifest              # Captures session progress
   ```

### After Major Changes

When you:
- Add new files or directories
- Reorganize structure
- Complete major analysis
- Make significant changes

Run full regeneration:
```bash
/generate-manifest --update     # Full re-analysis
```

## MANIFEST Best Practices

### Content Guidelines

1. **Be concise but informative**: Target 500-2,000 tokens
2. **Front-load important info**: Put critical details first
3. **Use bullet points**: Not paragraphs
4. **Include dates**: Everything should have timestamps
5. **Think "6 months from now"**: What would you need to know?

### What to Document

**ALWAYS include**:
- File purpose and key message
- Dependencies (inputs)
- Outputs (what it generates)
- Last modified date
- Size for large files

**USER FILL fields for**:
- Key findings (requires understanding)
- Priority classification (main vs complementary)
- Known issues and TODOs
- Environment names
- Obsidian note paths

**Tip for filling user-specific fields**:
- **Obsidian notes path**: Check `.claude/project-config` file - it often contains the vault path in the `obsidian_vault` or similar field
- **Environment name**: Check conda env list or look for `environment.yml`/`requirements.txt`
- **Key findings**: Analyze generation scripts or read notebook markdown cells for summaries

**Auto-generate from code**:
- File sizes and dates
- Row/column counts for data
- Dependencies (by searching code)
- Script usage (from docstrings)

### Documenting New Analysis Notebooks in MANIFEST

**Template for Analysis Notebook Entries:**

When adding a new analysis notebook to `MANIFEST.md`, include:

```markdown
#### `Notebook_Name.ipynb` (file size) **[NEW]**
- **Purpose**: One-sentence objective of the analysis
- **Type**: Category (e.g., "Confounding analysis", "Data enrichment", "Primary analysis")
- **Rationale**: Why this analysis is needed (2-3 sentences explaining motivation)
- **Approach**:
  - Bullet points of analytical steps
  - Key methodological decisions
- **Key Questions**:
  - Question 1 the analysis addresses
  - Question 2 the analysis addresses
- **Depends on**:
  - data/input_file.csv (description)
  - scripts/processing_script.py
- **Generates**:
  - figures/output_dir/figure1.png (what it shows)
  - results/statistics.csv
- **Dataset**: N assemblies/samples, key statistics
- **Last modified**: YYYY-MM-DD
- **Status**: Current state (e.g., "Code optimized", "In progress", "Complete")
- **Execution time**: ~XX minutes
- **Priority**: Role in project (e.g., "Confounding analysis - validates main findings")
- **Note**: Important caveats or special considerations
```

**Example: Technology/Temporal Confounding Analysis**

```markdown
#### `Technology_Temporal_Analysis.ipynb` (32 KB) **[NEW]**
- **Purpose**: Investigate whether sequencing technology (CLR vs HiFi) and temporal trends confound the curation method comparisons
- **Type**: Confounding analysis - technology and temporal effects
- **Rationale**: Sequencing technology evolved rapidly (CLR -> HiFi), and assembly methods may correlate with technology era. Need to determine if observed quality differences are due to curation methods or underlying technology/temporal confounders.
- **Approach**:
  - Technology-separated analysis: Compare categories split by sequencing technology
  - Temporal trend analysis: Plot quality metrics over time (2019-2025)
  - HiFi-only temporal analysis: Eliminate technology confounding
- **Key Questions**:
  - Are quality differences consistent across technologies (HiFi vs CLR)?
  - Do quality metrics improve over time, and is this technology-driven?
  - Do temporal trends persist when technology is held constant?
- **Depends on**:
  - `data/vgp_assemblies_3categories_tech.csv` (3-category data with technology inference)
  - scipy for statistical tests (Mann-Whitney U, Spearman correlation)
- **Generates**:
  - `figures/technology_temporal/01_prialt_tech_comparison.png` (HiFi vs CLR)
  - `figures/technology_temporal/04_hifi_only_temporal_trends.png` (HiFi-only, 2021-2025)
  - `figures/technology_temporal/technology_effects_statistics.csv`
  - `figures/technology_temporal/temporal_trends_hifi_only_statistics.csv`
- **Dataset**: 541 VGP assemblies, 464/541 (86%) with technology assignment (355 HiFi, 107 CLR)
- **Last modified**: 2026-02-25
- **Status**: Code optimized (DPI reduced 300->150 to prevent image loading errors)
- **Execution time**: ~10-15 minutes
- **Priority**: Confounding analysis - validates that curation effects are not driven by technology or temporal biases
- **Note**: Figure sizes reduced (DPI 150) to prevent notebook image loading errors
```

**Benefits of Comprehensive Documentation:**

1. **Resume work easily**: Understand analysis purpose months later
2. **Collaboration**: Others can understand without reading code
3. **Dependency tracking**: Know what data/scripts are required
4. **Output tracking**: Know what files this notebook generates
5. **Execution planning**: Estimate time needed to re-run
6. **Prioritization**: Understand role in overall project

### Update Frequency

- **End of every session**: Quick update with `/update-manifest`
- **After adding files**: Note new files, mark as [TO BE DOCUMENTED]
- **After major changes**: Full regeneration with `/generate-manifest`
- **Before sharing**: Ensure MANIFESTs are current

### MANIFEST Session Context Updates

**Structure for "Recent Session Work" Section:**

When running `/update-manifest`, document the session in this format:

```markdown
**Recent Session Work** (YYYY-MM-DD):
- **[Action taken]**:
  - Specific change 1 with details
  - Specific change 2 with quantitative results
  - Why this change was made
- Brief description of problem solved or feature added
- Any updates to directory structure or workflow
```

**Example Session Documentation:**

```markdown
**Recent Session Work** (2026-02-25):
- **Updated Technology_Temporal_Analysis.ipynb code**:
  - Reduced DPI from 300->150 in global settings and all savefig calls
  - Reduced figure sizes: 01_prialt (15x10->12x8), 02_all_tech (18x12->14x9)
  - Prevents image loading errors while maintaining publication quality
  - File sizes reduced by ~75% (combination of DPI and size reduction)
- Added Technology_Temporal_Analysis.ipynb entry to root MANIFEST
- Updated directory structure to include figures/technology_temporal/
- Added HiFi-only temporal analysis section to eliminate technology confounding
```

**Next Steps Format:**

Prioritize and number action items:

```markdown
**Next Steps**:
1. **[High priority action]** - [Why it's important]
2. **[Medium priority]** - [Context]
3. **[Future work]** - [When to tackle]
```

**Example:**
```markdown
**Next Steps**:
1. **Re-run Technology_Temporal_Analysis.ipynb** - Execute cells to regenerate figures with optimized 150 DPI settings
2. **Generate notebook with temporal effect and only HiFi data** - Already added to notebook, need to execute new cells
3. **Write integrated manuscript Results section** - Combine findings from all 5 clades into cohesive narrative
```

This structure makes it easy to resume work by quickly understanding what was done and what's next.

## Integration with Project Structure

Add MANIFESTs to standard project organization:

```
project/
├── MANIFEST.md                 # Root project index
├── MANIFEST_TEMPLATE.md        # Template for new MANIFESTs
├── data/
│   ├── MANIFEST.md            # Data inventory
│   └── [data files]
├── figures/
│   ├── MANIFEST.md            # Figure catalog
│   └── [figure files]
├── scripts/
│   ├── MANIFEST.md            # Script documentation
│   └── [script files]
├── documentation/
│   ├── MANIFEST.md            # Doc organization
│   └── [doc files]
└── [other directories with MANIFESTs as needed]
```

## Common MANIFEST Patterns

### For Data Directories

Emphasize:
- Data provenance and source
- File formats and structure
- Original vs processed versions
- Data dependencies and lineage
- Size and scale information

### For Figure Directories

Emphasize:
- Generating code (which notebook/script)
- Data sources
- Manuscript figure numbers
- Key messages and findings
- Figure dependencies

### For Script Directories

Emphasize:
- Input/output relationships
- Execution order
- Usage examples
- Dependencies (packages)
- Script purpose and logic

### For Documentation Directories

Emphasize:
- Entry points (where to start)
- Document categories
- Active vs archived
- Session summaries location
- Critical documents for resuming work

## Real-World Example

See the `Curation_Paper_figures` project for a complete implementation:
- 5 MANIFEST files (root + 4 subdirectories)
- ~10,000 lines of documentation
- Covers 3 notebooks, 12 scripts, 18 figures, 48 doc files
- Enables session startup in 2,000 tokens vs 15,000+ tokens
- Includes working examples of all MANIFEST types

## Benefits Summary

**For Claude Code**:
- 85-90% reduction in session startup tokens
- Fast project orientation (2-3 MANIFESTs vs 20+ files)
- Clear entry points and workflow understanding
- Efficient file navigation without exploring

**For Users**:
- Quick work resumption (read 1 MANIFEST vs 10+ files)
- Clear project documentation
- Session continuity (Notes for Resuming Work)
- Workflow transparency (dependency maps)

**For Teams**:
- Faster onboarding for new members
- Shared understanding of project structure
- Clear documentation of decisions
- Easier code review (understand context quickly)

## Troubleshooting

**MANIFEST too long** (>2,500 tokens):
- Break into subdirectory MANIFESTs
- Use "See subdirectory MANIFEST" links
- Summarize instead of listing all files

**MANIFEST outdated**:
- Set up session-end habit: `/update-manifest` before `/safe-exit`
- Use `/generate-manifest --update` for full refresh
- Add "Last Updated" reminders

**Too many [USER TO FILL] fields**:
- Fill in during active work, not after
- Use `/update-manifest` to capture context immediately
- Ask user questions during generation for key info

**Unclear what to include**:
- Think: "What would I need to resume work in 6 months?"
- Include anything that saves reading a file
- Front-load critical information
