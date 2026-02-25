# Documentation Organization for Research Projects

**Category**: Analysis
**Last Updated**: 2026-02-05
**Use Cases**: Organizing project documentation, preparing sharing packages, maintaining clean project structure

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

### Migration from File-Pattern to Directory-Based

If migrating from file-pattern matching:

1. **Categorize existing files** by purpose:
   - What helps recipients understand the project? → shareable
   - What tracks development progress? → internal

2. **Move files** to appropriate directories:
```bash
# Example migration
mv CORRECTIONS_COMPLETE.md documentation/action_reports/
mv ANALYSIS_SUMMARY.md documentation/results/
mv README_KARYOTYPE_FETCH.md documentation/methods/
```

3. **Update share-project command**: Replace pattern matching with directory inclusion/exclusion

4. **Update project README**: Explain new organization to team

### Why This Approach?

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

## Migration Guide

To reorganize an existing project:

```bash
# Create new structure
mkdir -p documentation/{data_descriptions,methods,results,action_reports,progress,todos,internal}

# Move data descriptions
mv documentation/*README*.md documentation/data_descriptions/
mv documentation/*DATA*.md documentation/data_descriptions/

# Move methods
mv documentation/*workflow*.md documentation/methods/
mv documentation/*plan*.md documentation/methods/
mv documentation/*protocol*.md documentation/methods/

# Move results
mv documentation/*ANALYSIS_SUMMARY*.md documentation/results/
mv documentation/*COMPLETE*.md documentation/results/

# Move progress tracking
mv documentation/*PROGRESS*.md documentation/progress/
mv documentation/*SESSION*.md documentation/progress/
mv documentation/*RESUME*.md documentation/progress/

# Move action reports
mv documentation/*CORRECTION*.md documentation/action_reports/
mv documentation/*UPDATE*.md documentation/action_reports/
mv documentation/*REGENERATION*.md documentation/action_reports/
mv documentation/*RESTORATION*.md documentation/action_reports/
mv documentation/*VERIFICATION*.md documentation/action_reports/

# Move todos
mv documentation/*PRIORITY*.md documentation/todos/
mv documentation/*TODO*.md documentation/todos/

# Move internal/meta docs
mv documentation/*ESSENTIAL*.md documentation/internal/
mv documentation/*ORGANIZATION*.md documentation/internal/
mv documentation/*ISSUE*.md documentation/internal/
mv documentation/*FIXES*.md documentation/internal/
```

## Pattern Reference

Quick reference for categorizing files:

| Pattern | Category | Share? |
|---------|----------|--------|
| *README*, *column*, *data* | data_descriptions | ✅ |
| *workflow*, *method*, *protocol*, *plan* | methods | ✅ |
| *summary*, *findings*, *results* | results | ✅ |
| *progress*, *session*, *resume* | progress | ❌ |
| *correction*, *update*, *regeneration*, *verification*, *migration* | action_reports | ❌ |
| *todo*, *priority*, *task* | todos | ❌ |
| *essential*, *organization*, *issue*, *fixes* | internal | ❌ |
| *deprecated*, *old*, *backup* | deprecated | ❌ |

## Best Practices

1. **Name files descriptively**: Use clear prefixes/suffixes
2. **Date internal docs**: Add dates to action reports and progress notes
3. **Update README**: Keep documentation/README.md current
4. **Regular cleanup**: Move old files to deprecated/
5. **Consistent naming**: Use established patterns for easy categorization
6. **Test sharing**: Verify shared packages have needed documentation

## MANIFEST Update Best Practices

When updating MANIFEST files (data/MANIFEST.md, scripts/MANIFEST.md, etc.) after significant project changes, follow these patterns:

### Pattern: Comprehensive Context Update

**Purpose**: Provide future sessions with complete context to resume work efficiently

**Key Sections to Update**:

1. **Last Updated Date**: Always update to current date
   ```markdown
   **Last Updated**: 2026-02-25 (data consolidation complete, AWS QC enrichment added)
   ```

2. **Notes for Resuming Work**: Most critical section
   ```markdown
   ## Notes for Resuming Work

   **Current Status** (YYYY-MM-DD):
   - ✅ Completed item 1: Brief description
   - ✅ Completed item 2: Brief description
   - ✅ Completed item 3: Brief description

   **Next Steps**:
   1. Priority task 1
   2. Priority task 2

   **Known Issues**:
   - ⚠️ Issue 1: Description and context
   - ⚠️ Issue 2: Description and context
   ```

3. **File Sizes and Counts**: Update actual metrics
   ```markdown
   - **Size**: 482 KB, 716 rows, 77 columns
   ```

4. **Quick Reference**: Update entry points if data structure changed
   ```markdown
   **Entry Points**:
   1. **Start here**: `file.csv` - Description (N rows, M columns)
   ```

### Information to Capture

**Completed Work**:
- What was accomplished (data consolidation, enrichment, verification)
- How many files affected (e.g., "34 files reduced to 2")
- Where deprecated files moved (e.g., "archived in deprecated/data_backups_20260225/")
- New columns/features added (e.g., "added 3 QC columns: busco_completeness, busco_lineage, merqury_qv")

**Next Steps**:
- Immediate priorities (e.g., "Verify analyses with enriched data")
- Follow-up tasks (e.g., "Document enrichment methodology")
- Future improvements (e.g., "Run full AWS enrichment to increase coverage")

**Known Issues**:
- Incomplete work (e.g., "BUSCO/Merqury coverage only ~21% (TEST_MODE)")
- Missing dependencies (e.g., "VGP haplotype comparison files missing")
- Warnings about data quality or coverage

### Ask User for Context

When updating MANIFEST, gather context from user via AskUserQuestion:

```python
AskUserQuestion({
    "questions": [{
        "question": "What did we accomplish in this session?",
        "header": "Accomplished",
        "options": [
            {"label": "Data consolidation", "description": "..."},
            {"label": "New analysis", "description": "..."},
            # ... more options
        ],
        "multiSelect": True
    }]
})
```

### Example: Data Consolidation Update

**Before**:
```markdown
**Last Updated**: 2026-02-19
**Purpose**: VGP assembly metadata
**Status**: Active
```

**After**:
```markdown
**Last Updated**: 2026-02-25 (data consolidation complete, AWS QC enrichment added)
**Purpose**: VGP assembly metadata and quality metrics in unified, optimized format
**Status**: Active - Consolidated to 2 core files only

## Notes for Resuming Work

**Current Status** (2026-02-25):
- ✅ Data consolidation complete: Reduced from 34 CSV files to 2 core files
- ✅ AWS QC enrichment added: BUSCO/Merqury data fetched from GenomeArk
- ✅ All 34 deprecated files safely archived in `deprecated/data_backups_20260225/`
- ✅ All notebooks verified to use correct consolidated data
- ✅ 3categories file rebuilt with correct filtering (541 assemblies)

**Next Steps**:
1. Verify analyses with enriched data
2. Document enrichment methodology

**Known Issues**:
- ⚠️ BUSCO/Merqury coverage only ~21% (TEST_MODE - need full enrichment)
- ⚠️ VGP haplotype comparison files missing
```

### When to Update MANIFEST

Update MANIFEST whenever:
- **Data structure changes** (consolidation, new columns, file reorganization)
- **Major analysis milestones** (completed figure generation, finished enrichment)
- **File deprecation** (moved files to deprecated/, changed canonical files)
- **Known issues discovered** (missing data, coverage gaps, broken references)
- **Before ending session** (via `/update-manifest` command)

### Benefits

1. **Efficient resumption**: Future sessions have complete context
2. **Avoid redundant work**: Known issues documented to prevent re-investigation
3. **Clear next steps**: Priorities explicitly listed
4. **Accurate documentation**: File sizes, counts, and status match reality
5. **Session continuity**: Each session builds on documented progress

## MANIFEST Update Patterns

Common MANIFEST update patterns for different types of changes:

### Pattern 1: Data Consolidation

**Trigger**: Reduced multiple data files to single source of truth

**Update**:
```markdown
**Last Updated**: YYYY-MM-DD (data consolidation complete)
**Status**: Active - Consolidated to N core files only

**Current Status**:
- ✅ Data consolidation complete: Reduced from X files to N core files
- ✅ All deprecated files archived in `deprecated/data_backups_YYYYMMDD/`
- ✅ All notebooks verified to use consolidated data

**Known Issues**:
- ⚠️ [Any files still referencing deprecated data]
```

**Also Update**:
- File sizes (actual size after consolidation)
- Row/column counts
- Quick Reference (which file to use for what)
- Dependencies (update script references)

### Pattern 2: Data Enrichment

**Trigger**: Added new columns from external sources (AWS, APIs, manual curation)

**Update**:
```markdown
**Last Updated**: YYYY-MM-DD (enrichment added: [source])

**Current Status**:
- ✅ [Source] enrichment added: [What data] (coverage: X%)
- ✅ New columns: col1, col2, col3

**Next Steps**:
1. Re-run analyses with enriched data
2. Document enrichment methodology

**Known Issues**:
- ⚠️ Coverage only X% ([reason, e.g., TEST_MODE, missing source data])
```

**Also Update**:
- Column count (add new columns to total)
- Column descriptions in metadata files
- Dependencies (enrichment notebook/script)

### Pattern 3: File Deprecation/Reorganization

**Trigger**: Moved files to deprecated/, changed canonical file locations

**Update**:
```markdown
**Current Status**:
- ✅ Files reorganized: [describe change]
- ✅ Deprecated files archived in `deprecated/[subfolder]/`
- ✅ All references verified and updated

**Entry Points**:
1. **OLD (deprecated)**: `old_file.csv` → moved to deprecated/
2. **NEW (use this)**: `new_file.csv` - Description
```

**Also Update**:
- Remove deprecated files from main file list
- Add note in Quick Reference about location change
- Update dependencies section

### Pattern 4: Analysis Milestone

**Trigger**: Completed major analysis, generated figures, finished enrichment

**Update**:
```markdown
**Current Status**:
- ✅ [Analysis name] complete: [brief description]
- ✅ Figures generated: [which figures, where saved]
- ✅ Results documented in: [notebook/report path]

**Next Steps**:
1. [Follow-up analysis]
2. [Documentation tasks]
```

### Pattern 5: Discovered Issues

**Trigger**: Found missing data, broken references, coverage gaps

**Update**:
```markdown
**Known Issues**:
- ⚠️ [Issue name]: [Description]
  - Impact: [What this affects]
  - Workaround: [If available]
  - Resolution: [What needs to be done]
```

### Quick Update Checklist

When updating MANIFEST after any change:

- [ ] Update "Last Updated" date (with brief description in parentheses)
- [ ] Add completed work to "Current Status" with ✅
- [ ] Update file sizes/counts if data changed
- [ ] Add any new issues to "Known Issues" with ⚠️
- [ ] Update "Next Steps" with new priorities
- [ ] Update Quick Reference if file paths changed
- [ ] Update Dependencies if scripts/notebooks changed
- [ ] Verify all file references are still accurate

### Real Example: VGP Curation Project

**Session**: Data consolidation + AWS enrichment (2026-02-25)

**Changes Made**:
1. Reduced 34 CSV files → 2 core files
2. Added 3 QC columns (BUSCO, Merqury)
3. Rebuilt 3categories file (680→541 assemblies)
4. Archived all deprecated files
5. Verified all notebook references

**MANIFEST Updates**:
```markdown
**Last Updated**: 2026-02-25 (data consolidation complete, AWS QC enrichment added)
**Status**: Active - Consolidated to 2 core files only
```

### Pattern 3: Notebook Splitting

**Trigger**: Split large analysis notebook into focused, modular notebooks

**Update Root MANIFEST**:

**Mark the Original as Deprecated**:
```markdown
#### `Original_Combined_Analysis.ipynb` (1.5 MB) **[DEPRECATED - 2026-02-25]**
- **Status**: DEPRECATED - Split into Analysis_Part1.ipynb and Analysis_Part2.ipynb
- **Note**: This notebook combined both X and Y analyses. Now split for clarity.
- **Replacement notebooks**:
  - `Analysis_Part1.ipynb` - X analysis (Figures 01-02)
  - `Analysis_Part2.ipynb` - Y analysis (Figures 04-05)
- **Last modified**: 2026-02-25
- **Action**: Keep for reference, but use the split notebooks for future work
```

**Document Each Split Notebook**:
```markdown
#### `Analysis_Part1.ipynb` (NEW - 2026-02-25)
- **Purpose**: X analysis only
- **Type**: Focused analysis - X effects
- **Rationale**: [Why this analysis is separate]
- **Approach**: [Brief methodology]
- **Generates**:
  - `figures/subfolder/01_figure_name.png`
  - `figures/subfolder/02_figure_name.png`
  - `statistics_file.csv`
- **Dataset**: N samples, X condition
- **Execution time**: ~3-5 minutes (vs ~10-15 for combined)
- **Priority**: [Where it fits in analysis workflow]
```

**Update figures/MANIFEST.md**:
```markdown
### `figures/subfolder/`
**Generated by**:
  - `Analysis_Part1.ipynb` (Figures 01-02) - X analysis
  - `Analysis_Part2.ipynb` (Figures 04-05) - Y analysis
  - ~~Original_Combined_Analysis.ipynb~~ (DEPRECATED)
```

**Also Update**:
- "Current Status" in Notes for Resuming Work
- Any workflow diagrams or dependencies
- Quick Reference entry points

## Notes for Resuming Work

**Current Status** (2026-02-25):
- ✅ Data consolidation complete: Reduced from 34 CSV files to 2 core files
- ✅ AWS QC enrichment added: BUSCO completeness/lineage and Merqury QV
- ✅ All 34 deprecated files safely archived in deprecated/data_backups_20260225/
- ✅ All notebooks and scripts verified to use correct data
- ✅ 3categories file properly rebuilt with correct filtering (541 assemblies)

**Next Steps**:
1. Verify analyses with enriched data: Re-run notebooks with new QC columns
2. Document enrichment methodology: GenomeArk sources, coverage stats

**Known Issues**:
- ⚠️ BUSCO/Merqury coverage only ~21%: Current enrichment in TEST_MODE
  - Impact: Missing QC data for ~79% of assemblies
  - Resolution: Set ENABLE_AWS_FETCH=True, TEST_MODE=False in enrich_unified_csv.ipynb
  - Estimated time: 2-3 hours for full enrichment
- ⚠️ VGP haplotype comparison files missing: Haplotype_Comparison_Analysis.ipynb
  references VGPPhase1-haplotype-comparison*.csv files not in project
  - Impact: Cannot run haplotype comparison analysis
  - Resolution: Locate or regenerate these files
```

**Files Updated**:
- Sizes: unified (482 KB), 3categories (422 KB)
- Columns: 74→77 (added 3 QC columns)
- Quick Reference: Noted new BUSCO/Merqury columns
- Dependencies: Added enrich_unified_csv.ipynb

This comprehensive update provides complete context for resuming work efficiently.

## Example: VGP Curation Project

Current state reorganization:

```
✅ SHARE:
data_descriptions/
  - HAPLOTYPE_COMPARISON_TABLE_README.md
  - vgp_assemblies_data_dictionary.md

methods/
  - KARYOTYPE_WORKFLOW.md
  - analysis_plan.md
  - data_fetching_plan.md
  - updated_methods_section.md

results/
  - ANALYSIS_SUMMARY.md
  - COMPLETE_ANALYSIS_SUMMARY.md
  - DUAL_HAPLOTYPE_ANALYSIS_SUMMARY.md
  - HAPLOTYPE_ANALYSIS_COMPLETE.md
  - DETAILED_METRICS_SUMMARY.md

❌ INTERNAL:
action_reports/
  - CORRECTIONS_COMPLETE.md
  - DATA_TABLE_VERIFICATION.md
  - FIGURE_REGENERATION_SUMMARY.md
  - FIGURE_RESTORATION_SUMMARY.md
  - FINAL_UPDATE_SUMMARY.md
  - UPDATE_SUMMARY.md
  - GENOMESCOPE_DATA_RETRIEVAL_STATUS.md
  - IMPROVED_PLOTS_SUMMARY.md
  - KARYOTYPE_UPDATES_SUMMARY.md

progress/
  - PROGRESS.md
  - RESUME_HERE.md
  - KARYOTYPE_SESSION_SUMMARY.md
  - TIER1_SEARCH_PROGRESS.md
  - TIER2_SESSION_SUMMARY.md

todos/
  - KARYOTYPE_SEARCH_PRIORITY_LIST.md

internal/
  - MINIMAL_ESSENTIAL_FILES.md
  - DOCUMENTATION_ORGANIZATION.md
  - NOTEBOOK_COHERENCE_ISSUES.md
  - NOTEBOOK_UPDATE_COMMAND.md
  - TEXT_FIXES_NEEDED.md
  - OUTLIER_ANALYSIS_REPORT.md

deprecated/
  - CLEANUP_SUMMARY.md
  - MIGRATION_CHANGES.md
  - BOTH_HAPLOTYPES_DEPRECATION.md
```

This organization makes it immediately clear what should be shared and what is internal.
