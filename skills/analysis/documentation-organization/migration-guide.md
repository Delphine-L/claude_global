# Migration Guide

## Migrating to Directory-Based Organization

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
| *README*, *column*, *data* | data_descriptions | Yes |
| *workflow*, *method*, *protocol*, *plan* | methods | Yes |
| *summary*, *findings*, *results* | results | Yes |
| *progress*, *session*, *resume* | progress | No |
| *correction*, *update*, *regeneration*, *verification*, *migration* | action_reports | No |
| *todo*, *priority*, *task* | todos | No |
| *essential*, *organization*, *issue*, *fixes* | internal | No |
| *deprecated*, *old*, *backup* | deprecated | No |

## Best Practices

1. **Name files descriptively**: Use clear prefixes/suffixes
2. **Date internal docs**: Add dates to action reports and progress notes
3. **Update README**: Keep documentation/README.md current
4. **Regular cleanup**: Move old files to deprecated/
5. **Consistent naming**: Use established patterns for easy categorization
6. **Test sharing**: Verify shared packages have needed documentation

## Documenting Format Debugging

When solving format/compatibility issues, create a brief summary doc for future reference:

**Template** (`FORMAT_FIX.md` or `SPECIES_NAME_FIX.md`):
```markdown
# [Issue] Fix

**Date**: YYYY-MM-DD
**Issue**: Brief description of problem
**Root Cause**: Technical explanation
**Solution**: What was changed
**Files Updated**: List of affected files

## Verification
- [ ] Test case 1
- [ ] Test case 2

## Prevention
How to avoid this issue in future
```

**Example**: Species name case sensitivity fix
```markdown
# Species Name Case Sensitivity Fix

**Date**: 2026-02-25
**Issue**: iTOL config missing one species (Alca_torda)
**Root Cause**: Dataset had "Alca Torda" (uppercase T) instead of "Alca torda"
**Solution**: Added case normalization regex to generation script
**Files Updated**:
- generate_tech_year_itol_configs.py
- itol_clr_technology_binary.txt (regenerated)
- itol_release_year_gradient.txt (regenerated)

## Verification
- [x] All 40 CLR species appear in config
- [x] All 446 year species appear in config
- [x] No species name mismatches between tree and configs

## Prevention
Always normalize case in data pipeline:
```python
df['species_tree'] = df['species_tree'].str.replace(
    r'_([A-Z])', lambda m: '_' + m.group(1).lower(), regex=True
)
```
```

**Why document format fixes**:
- Prevents re-debugging same issue months later
- Provides search keywords for similar issues
- Documents validation steps for future formats
- Shows prevention strategy for data pipeline

**Location**: Place in project root or `documentation/working_files/`
