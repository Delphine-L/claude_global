# MANIFEST Update Best Practices

When updating MANIFEST files (data/MANIFEST.md, scripts/MANIFEST.md, etc.) after significant project changes, follow these patterns.

## Comprehensive Context Update Pattern

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
   - Completed item 1: Brief description
   - Completed item 2: Brief description
   - Completed item 3: Brief description

   **Next Steps**:
   1. Priority task 1
   2. Priority task 2

   **Known Issues**:
   - Issue 1: Description and context
   - Issue 2: Description and context
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

## Information to Capture

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

## Ask User for Context

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

## Example: Data Consolidation Update

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
- Data consolidation complete: Reduced from 34 CSV files to 2 core files
- AWS QC enrichment added: BUSCO/Merqury data fetched from GenomeArk
- All 34 deprecated files safely archived in `deprecated/data_backups_20260225/`
- All notebooks verified to use correct consolidated data
- 3categories file rebuilt with correct filtering (541 assemblies)

**Next Steps**:
1. Verify analyses with enriched data
2. Document enrichment methodology

**Known Issues**:
- BUSCO/Merqury coverage only ~21% (TEST_MODE - need full enrichment)
- VGP haplotype comparison files missing
```

## When to Update MANIFEST

Update MANIFEST whenever:
- **Data structure changes** (consolidation, new columns, file reorganization)
- **Major analysis milestones** (completed figure generation, finished enrichment)
- **File deprecation** (moved files to deprecated/, changed canonical files)
- **Known issues discovered** (missing data, coverage gaps, broken references)
- **Before ending session** (via `/update-manifest` command)

## Benefits

1. **Efficient resumption**: Future sessions have complete context
2. **Avoid redundant work**: Known issues documented to prevent re-investigation
3. **Clear next steps**: Priorities explicitly listed
4. **Accurate documentation**: File sizes, counts, and status match reality
5. **Session continuity**: Each session builds on documented progress

---

## MANIFEST Update Patterns

Common MANIFEST update patterns for different types of changes.

### Pattern 1: Data Consolidation

**Trigger**: Reduced multiple data files to single source of truth

**Update**:
```markdown
**Last Updated**: YYYY-MM-DD (data consolidation complete)
**Status**: Active - Consolidated to N core files only

**Current Status**:
- Data consolidation complete: Reduced from X files to N core files
- All deprecated files archived in `deprecated/data_backups_YYYYMMDD/`
- All notebooks verified to use consolidated data

**Known Issues**:
- [Any files still referencing deprecated data]
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
- [Source] enrichment added: [What data] (coverage: X%)
- New columns: col1, col2, col3

**Next Steps**:
1. Re-run analyses with enriched data
2. Document enrichment methodology

**Known Issues**:
- Coverage only X% ([reason, e.g., TEST_MODE, missing source data])
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
- Files reorganized: [describe change]
- Deprecated files archived in `deprecated/[subfolder]/`
- All references verified and updated

**Entry Points**:
1. **OLD (deprecated)**: `old_file.csv` -> moved to deprecated/
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
- [Analysis name] complete: [brief description]
- Figures generated: [which figures, where saved]
- Results documented in: [notebook/report path]

**Next Steps**:
1. [Follow-up analysis]
2. [Documentation tasks]
```

### Pattern 5: Discovered Issues

**Trigger**: Found missing data, broken references, coverage gaps

**Update**:
```markdown
**Known Issues**:
- [Issue name]: [Description]
  - Impact: [What this affects]
  - Workaround: [If available]
  - Resolution: [What needs to be done]
```

### Pattern 6: Notebook Splitting

**Trigger**: Split large analysis notebook into focused, modular notebooks

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

### Pattern 7: MANIFEST Update After Major Changes

**Trigger**: Made significant project changes (notebook reorganization, deprecations, new files/scripts) that affect multiple MANIFESTs

**Systematic Update Workflow**:

**1. Identify affected MANIFESTs:**
```bash
# List all MANIFESTs in project
find . -name "MANIFEST.md" -not -path "*/deprecated/*"
```

**2. Update in order of dependencies:**
- data/MANIFEST.md (if data changes)
- scripts/MANIFEST.md (if scripts added/changed)
- figures/MANIFEST.md (if figures added/changed)
- Root MANIFEST.md (last - references all subdirectories)

**3. Key sections to update in each MANIFEST:**
- **"Last Updated"** date and summary
- **New file entries** with full metadata (purpose, size, dependencies)
- **Deprecation entries** with reason and replacement
- **"Recent Session Work"** with session accomplishments
- **"Next Steps"** with updated priorities
- **"Known Issues"** if new issues discovered

**4. For deprecated notebooks:**
- Keep entry in MANIFEST with DEPRECATED status
- Add deprecation date and reason
- Link to replacement notebook
- Document what's different in new version
- Note migration guide if created

**Example deprecation entry:**
```markdown
#### `deprecated/notebooks_20260226/Temporal_Analysis_HiFi_OLD.ipynb` (916 KB) **[DEPRECATED - 2026-02-26]**
- **Status**: DEPRECATED - Reorganized for manuscript preparation
- **Original name**: `Temporal_Analysis_HiFi.ipynb`
- **Reason**: Unorganized structure (no TOC, methods scattered, phylo tree at end)
- **Replaced by**: `Temporal_Impact_Analysis.ipynb` (same analysis, better organization)
- **Content preserved**: All code, figures, statistics, interpretations, CSV outputs
- **What's different in new notebook**: TOC with anchor links, logical section flow (dataset -> analysis -> conclusions -> methods), clearer narrative for manuscript
- **Migration**: See `REORGANIZATION_GUIDE.md` for cell-by-cell copying instructions
- **Last modified**: 2026-02-26
- **Note**: Kept for reference, all scientific content is identical
```

**5. Track todo items for systematic updates:**

Use TodoWrite to ensure all MANIFESTs get updated:
```python
todos = [
    "Update root MANIFEST.md with new files and deprecations",
    "Update data/MANIFEST.md with assembly year extraction status",
    "Update scripts/MANIFEST.md with extract_assembly_year.py",
    "Update figures/MANIFEST.md with new figure descriptions",
    "Verify all MANIFEST updates are complete"
]
```

Mark each complete as you finish it to track progress.

**6. Verification checklist:**
- [ ] All "Last Updated" dates match current session date
- [ ] New files documented with complete metadata
- [ ] Deprecated files marked with explanation
- [ ] "Recent Session Work" captures what was accomplished
- [ ] "Next Steps" reflects current priorities
- [ ] All file references are accurate (no broken paths)
- [ ] File sizes updated if files changed

**Benefits**:
- Prevents missing MANIFEST updates across multiple directories
- Maintains documentation consistency
- Clear tracking of what changed when
- Future sessions can quickly understand project state

**Token efficiency**: Update MANIFESTs immediately after changes to avoid context loss and reduce future re-reading.

**Real example**: Session updated 4 MANIFESTs (root, data, scripts, figures) after temporal notebook reorganization and deprecation, documenting 2 deprecated notebooks, new template notebook, new script, enhanced figures, and all related documentation files.

## Quick Update Checklist

When updating MANIFEST after any change:

- [ ] Update "Last Updated" date (with brief description in parentheses)
- [ ] Add completed work to "Current Status"
- [ ] Update file sizes/counts if data changed
- [ ] Add any new issues to "Known Issues"
- [ ] Update "Next Steps" with new priorities
- [ ] Update Quick Reference if file paths changed
- [ ] Update Dependencies if scripts/notebooks changed
- [ ] Verify all file references are still accurate
