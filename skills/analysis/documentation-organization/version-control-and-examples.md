# Version Control for Document Iterations

When creating documents through multiple iterations (especially for publication), maintain clear version history.

## Version Numbering Scheme

- **v1.0**: Initial complete version
- **v1.1**: Minor fixes (typos, formatting)
- **v2.0**: Major changes (new sections, figures, analyses)
- **vX.Y FINAL**: Ready for submission/sharing

## Version Documentation Template

Create `FINAL_PACKAGE_*.md` or `VERSION_HISTORY.md`:

```markdown
## Version X.Y - What Changed

### From vX.0 to vX.Y:
**Changed**: [What specifically changed]
- **Was**: [Previous state]
- **Now**: [Current state]

**Why**: [Rationale for change]

**Important**: [What stayed the same]

**Added**: [New content]

## Version Timeline

- **v1.0** (timestamp): [Description]
- **v2.0** (timestamp): [Description]
- **v2.1** (timestamp): [Description] <- **CURRENT**
```

**Benefits**:
- Collaborators understand document evolution
- Clear indication of which version to use
- Rationale for changes documented
- Easy to track what stayed consistent vs. what changed

**Example use case**: LaTeX supplementary document went through v1.0 (4 figures, release year only) -> v2.0 (5 figures, both dating methods) -> v2.1 (clean temporal figures, methodological clarifications). Version history showed what changed at each step and why.

---

## Notes for Resuming Work

**Current Status** (2026-02-25):
- Data consolidation complete: Reduced from 34 CSV files to 2 core files
- AWS QC enrichment added: BUSCO completeness/lineage and Merqury QV
- All 34 deprecated files safely archived in deprecated/data_backups_20260225/
- All notebooks and scripts verified to use correct data
- 3categories file properly rebuilt with correct filtering (541 assemblies)

**Next Steps**:
1. Verify analyses with enriched data: Re-run notebooks with new QC columns
2. Document enrichment methodology: GenomeArk sources, coverage stats

**Known Issues**:
- BUSCO/Merqury coverage only ~21%: Current enrichment in TEST_MODE
  - Impact: Missing QC data for ~79% of assemblies
  - Resolution: Set ENABLE_AWS_FETCH=True, TEST_MODE=False in enrich_unified_csv.ipynb
  - Estimated time: 2-3 hours for full enrichment
- VGP haplotype comparison files missing: Haplotype_Comparison_Analysis.ipynb
  references VGPPhase1-haplotype-comparison*.csv files not in project
  - Impact: Cannot run haplotype comparison analysis
  - Resolution: Locate or regenerate these files

**Files Updated**:
- Sizes: unified (482 KB), 3categories (422 KB)
- Columns: 74->77 (added 3 QC columns)
- Quick Reference: Noted new BUSCO/Merqury columns
- Dependencies: Added enrich_unified_csv.ipynb

This comprehensive update provides complete context for resuming work efficiently.

---

## Example: VGP Curation Project

Current state reorganization:

```
SHARE:
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

INTERNAL:
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
