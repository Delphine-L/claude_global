---
name: documentation-organization
description: Organize research project documentation - structure working files, prepare sharing packages, maintain clean project layout
allowed-tools: Read, Grep, Glob, Bash
---

# Documentation Organization for Research Projects

> **Supporting files in this directory:**
> - [migration-guide.md](migration-guide.md) - Migration from flat to directory-based organization, pattern reference, format debugging
> - [manifest-updates.md](manifest-updates.md) - MANIFEST update best practices, patterns, and checklists
> - [version-control-and-examples.md](version-control-and-examples.md) - Version control for document iterations, VGP project example

## Overview

Organize project documentation in a structured way that separates internal working files from shareable content. This makes it easy to:
- Find documents during development
- Prepare sharing packages
- Maintain clean professional documentation
- Collaborate effectively

## Recommended Structure

```
documentation/
├── README.md                          # Documentation index
│
├── data_descriptions/                 # SHARE: Data understanding
│   ├── dataset_name_README.md
│   ├── column_definitions.md
│   └── data_sources.md
│
├── methods/                           # SHARE: Methodology
│   ├── workflow.md
│   ├── analysis_plan.md
│   └── protocol.md
│
├── results/                           # SHARE: Key findings
│   ├── analysis_summary.md
│   └── key_findings.md
│
├── reference/                         # SHARE: External references (optional)
│   ├── citations.md
│   └── useful_resources.md
│
├── progress/                          # INTERNAL: Development tracking
│   ├── PROGRESS.md
│   ├── session_YYYY-MM-DD.md
│   └── RESUME_HERE.md
│
├── action_reports/                    # INTERNAL: What was done
│   ├── corrections_YYYY-MM-DD.md
│   ├── figure_regeneration.md
│   ├── data_verification.md
│   └── updates_summary.md
│
├── todos/                             # INTERNAL: Planning
│   ├── priorities.md
│   ├── search_lists.md
│   └── task_tracking.md
│
├── internal/                          # INTERNAL: Project management
│   ├── minimal_essential_files.md
│   ├── documentation_organization.md
│   └── notebook_issues.md
│
└── deprecated/                        # INTERNAL: Old versions
    ├── old_analysis_v1.md
    └── deprecated_workflow.md
```

## Categorization Guide

### data_descriptions/ (SHARE)
**Purpose**: Help recipients understand the data

**Include:**
- Dataset descriptions and README files
- Column/variable definitions
- Data sources and provenance
- Data quality notes
- Expected formats

**Examples:**
- `vgp_assemblies_README.md`
- `column_definitions.md`
- `data_sources.md`
- `karyotype_data_README.md`

### methods/ (SHARE)
**Purpose**: Explain how analysis was done

**Include:**
- Methodology documentation
- Analysis workflows
- Protocols and procedures
- Step-by-step guides

**Examples:**
- `karyotype_workflow.md`
- `analysis_plan.md`
- `data_fetching_protocol.md`
- `quality_control_methods.md`

### results/ (SHARE)
**Purpose**: Present findings and conclusions

**Include:**
- Analysis summaries
- Key findings
- Interpretation notes
- Publication-ready summaries

**Examples:**
- `analysis_summary.md`
- `complete_results.md`
- `haplotype_analysis_summary.md`

### reference/ (SHARE - optional)
**Purpose**: Provide additional context

**Include:**
- Citations and references
- Useful external resources
- Related work
- Background reading

### progress/ (INTERNAL)
**Purpose**: Track development and resume work

**Include:**
- Progress tracking files
- Session notes
- Resume-here files
- Status updates

**Examples:**
- `PROGRESS.md`
- `session_2026-02-05.md`
- `RESUME_HERE.md`
- `tier1_search_progress.md`

**Pattern matching:** `*progress*`, `*session*`, `*resume*`

### action_reports/ (INTERNAL)
**Purpose**: Document what actions were taken

**Include:**
- Corrections and fixes
- Update summaries
- Figure regeneration notes
- Data verification reports
- Migration documentation

**Examples:**
- `corrections_complete.md`
- `figure_regeneration_summary.md`
- `data_verification.md`
- `updates_summary.md`
- `migration_changes.md`

**Pattern matching:** `*correction*`, `*update*`, `*regeneration*`, `*restoration*`, `*verification*`, `*migration*`

### todos/ (INTERNAL)
**Purpose**: Planning and task management

**Include:**
- Priority lists
- Search task lists
- Task tracking
- To-do items

**Examples:**
- `karyotype_search_priorities.md`
- `analysis_todos.md`

**Pattern matching:** `*todo*`, `*priority*`, `*task*`

### internal/ (INTERNAL)
**Purpose**: Project meta-documentation

**Include:**
- Essential files documentation
- Organization notes
- Issue tracking
- Project management notes

**Examples:**
- `minimal_essential_files.md`
- `documentation_organization.md`
- `notebook_coherence_issues.md`
- `text_fixes_needed.md`

**Pattern matching:** `*essential*`, `*organization*`, `*issue*`, `*fixes*`, `*coherence*`

### deprecated/ (INTERNAL)
**Purpose**: Old versions kept for reference

**Include:**
- Deprecated files
- Old versions
- Superseded documentation

**Pattern matching:** `*deprecated*`, `*old*`, `*backup*`

## Sharing Package Selection

When creating sharing packages, include only these directories:

```python
SHARE_INCLUDE = [
    'data_descriptions',  # Essential for understanding data
    'methods',            # Essential for understanding methodology
    'results',            # Essential for understanding findings
    'reference'           # Optional: external references
]

INTERNAL_EXCLUDE = [
    'progress',           # Internal tracking
    'action_reports',     # Internal updates
    'todos',              # Internal planning
    'internal',           # Project management
    'deprecated',         # Old versions
    'logs',               # Runtime logs
    'working_files'       # Temporary files
]
```

## Implementation

### For New Projects

```bash
mkdir -p documentation/{data_descriptions,methods,results,reference,progress,action_reports,todos,internal,deprecated}

# Create documentation README
# For general project README templates, see the folder-organization skill
cat > documentation/README.md << 'EOF'
# Project Documentation

## For Recipients (Shareable)
- **data_descriptions/** - Understanding the data
- **methods/** - How the analysis was done
- **results/** - Key findings and summaries

## Internal (Development)
- **progress/** - Progress tracking and session notes
- **action_reports/** - Updates, corrections, verifications
- **todos/** - Task lists and priorities
- **internal/** - Project management
EOF
```

### For Existing Projects

Reorganize documentation gradually:

1. Create new structure
2. Move files to appropriate folders
3. Update any references
4. Test that notebooks still work

> **See [migration-guide.md](migration-guide.md)** for detailed migration commands, pattern reference table, and format debugging templates.

### In share-project Command

Update filtering to use directory-based exclusion:

```python
# Exclude entire directories
EXCLUDE_DIRS = ['progress', 'action_reports', 'todos', 'internal',
                'deprecated', 'logs', 'working_files']

# Or include only specific directories
INCLUDE_DIRS = ['data_descriptions', 'methods', 'results', 'reference']
```

## Sharing Package Integration

### Directory-Based Filtering (Recommended)

When creating sharing packages from projects with organized documentation:

**Advantages**:
- Simple and maintainable (no complex pattern matching)
- Clear intent (directory name = purpose)
- Easy to audit (just look at directory list)
- Scalable (add new categories without updating filters)

**Implementation in share-project command**:

```python
def ignore_internal_dirs(dir, files):
    """Exclude internal documentation directories."""
    ignore_list = []
    for item in files:
        # Exclude internal directories
        if item in ['progress', 'action_reports', 'todos', 'internal',
                   'deprecated', 'logs', 'working_files', 'temp', 'tmp']:
            ignore_list.append(item)
        # Exclude hidden files except .gitkeep
        elif item.startswith('.') and item != '.gitkeep':
            ignore_list.append(item)
    return ignore_list

shutil.copytree("documentation", f"{SHARE_DIR}/documentation",
                ignore=ignore_internal_dirs,
                dirs_exist_ok=True)
```

**Quick Reference**:
- **Include**: `data_descriptions/`, `methods/`, `results/`, `reference/`
- **Exclude**: `progress/`, `action_reports/`, `todos/`, `internal/`, `deprecated/`

### Why Directory-Based Over File-Pattern Matching?

**Before (file-pattern matching)**:
```python
# Complex, hard to maintain, easy to miss files
exclude_patterns = [
    '*CORRECTION*', '*UPDATE*', '*VERIFICATION*', '*REGENERATION*',
    '*RESTORATION*', '*PROGRESS*', '*SESSION*', '*RESUME*',
    '*PRIORITY*', '*TODO*', '*TASK*', '*ESSENTIAL*', '*ISSUE*',
    '*FIXES*', '*COHERENCE*', '*DEPRECATED*', '*CLEANUP*',
    '*MIGRATION*', # ... and many more
]
```

**After (directory-based)**:
```python
# Simple, clear, maintainable
exclude_dirs = ['progress', 'action_reports', 'todos', 'internal', 'deprecated']
```

**Impact**: In practice, this approach eliminated 15+ incorrectly shared files and reduced maintenance complexity from 50+ patterns to 5 directories.

## Benefits

1. **Clear Organization**: Easy to find documents during development
2. **Easy Sharing**: Simply include/exclude directories when sharing
3. **Professional**: Recipients see clean, relevant documentation
4. **Maintainable**: Clear categories make it obvious where to put new docs
5. **Collaborative**: Team members understand the structure
6. **Archival**: Easy to separate essential from temporary documentation

## Best Practices

1. **Name files descriptively**: Use clear prefixes/suffixes
2. **Date internal docs**: Add dates to action reports and progress notes
3. **Update README**: Keep documentation/README.md current
4. **Regular cleanup**: Move old files to deprecated/
5. **Consistent naming**: Use established patterns for easy categorization
6. **Test sharing**: Verify shared packages have needed documentation

> **See also:**
> - [manifest-updates.md](manifest-updates.md) for MANIFEST update patterns and checklists
> - [version-control-and-examples.md](version-control-and-examples.md) for document iteration tracking and a full VGP project example
