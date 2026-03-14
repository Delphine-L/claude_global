# Data Validation Patterns

Patterns for verifying column names, data quality, and data provenance.

## Critical Data Validation: Column Name Verification

### The Problem: Column Names Can Be Misleading

**Column names don't always match their content.** This can happen due to:
- Copy-paste errors during data generation
- Misunderstanding of source code logic
- Legacy naming from previous versions
- Automatic column naming that reverses order

**Real-world example from VGP analysis:**
Dataset columns were named **opposite** of their actual content:
- `telomere_cat0_both_terminal` -> Actually contained "no telomeres" data (cat0)
- `telomere_cat1_one_terminal` -> Actually contained "both terminal" data (cat1)
- `telomere_cat2_no_terminal` -> Actually contained "one terminal" data (cat2)

**Impact**: Would have resulted in completely inverted biological interpretation (showing most chromosomes WITHOUT telomeres when the opposite was true).

### The Solution: Always Verify Against Source Code

**Before using any data column in analysis:**

1. **Find the source script** that generated the data
2. **Read the actual code** that assigns values to columns
3. **Verify column names match the logic**
4. **Add validation checks** comparing to known controls

**Example verification workflow:**
```python
# 1. Find source script (e.g., classify_telomeres.py)

# 2. Check the actual assignment logic in source:
"""
if terminal == 2 and interstitial == 0:
    category = 1  # Both terminal telomeres
elif terminal == 1 and interstitial == 0:
    category = 2  # One terminal telomere
else:
    category = 0  # No telomeres
"""

# 3. Verify column names match this logic
# Expected: cat0 = no telomeres, cat1 = both terminal, cat2 = one terminal

# 4. Check actual data against expectations
print("Cat1 (should be 'both terminal'):")
print(df['telomere_cat1_one_terminal'].describe())

# 5. Add biological plausibility check
# Most chromosomes should have at least some telomeres
pct_with_telomeres = ((df['telomere_cat1'] + df['telomere_cat2']) /
                       df['total_chr_scaffolds']).mean()
assert pct_with_telomeres > 0.5, f"Only {pct_with_telomeres:.1%} with telomeres - check column mapping!"

# 6. Cross-validate with known control samples
# Example: Chr1 of species X is known to have both terminal telomeres
control = df[(df['species'] == 'Homo_sapiens') & (df['chr'] == 'chr1')]
assert control['telomere_cat1_one_terminal'].sum() > 0, "Control chr1 should have cat1"
```

### Prevention Checklist

Before finalizing any analysis using categorical columns:

- [ ] Located source script that generated the data
- [ ] Verified column assignment logic in source code
- [ ] Cross-referenced column names with source logic
- [ ] Added assertions for biological plausibility
- [ ] Tested with known control samples
- [ ] Documented any discrepancies found
- [ ] Updated column names or added mapping if needed

### When This Is Critical

Column verification is **essential** when:
- Processing data from external scripts
- Working with categorical classifications
- Using data with non-obvious column names (cat0, cat1, cat2)
- Column names contain ambiguous terms
- Any time results seem biologically implausible

**Red flags that suggest column verification needed:**
- Results contradict biological expectations
- Percentages don't sum to 100% when they should
- Categories show inverse patterns to literature
- Column names use generic terms (cat0, cat1, cat2)
- Values seem swapped or inverted
- Known controls don't match expected values

### Fixing Column Name Mismatches

**Option 1: Rename columns in code**
```python
# Document the correction
"""
IMPORTANT: Column names are MISLABELED in the dataset!
Actual meanings based on classify_telomeres.py:
  cat0 = 0 terminal (no telomeres) - but column named "both_terminal"
  cat1 = 2 terminal (both terminal) - but column named "one_terminal"
  cat2 = 1 terminal (one terminal) - but column named "no_terminal"
"""

# Correct mapping with clear comments
df['telomere_pct_both_terminal'] = (df['telomere_cat1_one_terminal'] /  # cat1 = both terminal!
                                     df['total_chr_scaffolds'] * 100)
df['telomere_pct_one_terminal'] = (df['telomere_cat2_no_terminal'] /   # cat2 = one terminal!
                                    df['total_chr_scaffolds'] * 100)
df['telomere_pct_no_terminal'] = (df['telomere_cat0_both_terminal'] /   # cat0 = no terminal!
                                   df['total_chr_scaffolds'] * 100)
```

**Option 2: Create corrected dataset**
```python
# Rename columns correctly
df_corrected = df.rename(columns={
    'telomere_cat0_both_terminal': 'telomere_cat0_no_terminal',
    'telomere_cat1_one_terminal': 'telomere_cat1_both_terminal',
    'telomere_cat2_no_terminal': 'telomere_cat2_one_terminal'
})

# Save with clear documentation
df_corrected.to_csv('data_corrected_columns.csv', index=False)

# Document in README
"""
CORRECTED: 2026-02-16
- Column names were mislabeled in original data
- Verified against source code: classify_telomeres.py
- Corrected column names now match actual content
"""
```

### Documentation Template

When you discover and fix column mismatches, document thoroughly:

```markdown
## Data Quality Issue: Column Name Mismatch

**Discovered**: [Date] during [Analysis name]

**Problem**: Column names did not match their content

**Columns affected**:
- `[column_name]` - Named as [X] but actually contains [Y]
- `[column_name]` - Named as [A] but actually contains [B]

**Source of truth**: [script name and line numbers]

**Impact**: [What would have gone wrong without correction]

**Fix**: [How columns were remapped or renamed]

**Validation**: [How correctness was verified]
```

---

## Data Quality Verification During Analysis

### Detecting Implausible Values

When populating analysis files with statistical results, **verify biological plausibility**:

**Red flags for data issues**:
1. **Values outside expected range**:
   - Ratios >1.0 when measuring partial detection (<1.0 expected)
   - Ratios ~2.0 that match patterns from different metrics (e.g., diploid/haploid)
2. **Inconsistency with related metrics**:
   - Figure 5 shows 34.5% telomere detection -> Figure 5b should show ratio ~0.35, NOT 2.0
3. **Biological impossibility**:
   - 200% detection of telomeres (can't detect more than exist)
4. **Pattern matching wrong metric**:
   - Values matching chromosome counts when expecting telomere counts

**Example from Figure 5b issue**:
```markdown
## Statistical Results

### Sample Sizes and Descriptive Statistics

**IMPORTANT DATA ISSUE**: The values obtained appear to represent **chromosome achievement ratios** (similar to Figure 3) rather than **telomere detection ratios**. Expected telomere detection ratios based on Figure 5 results should be ~0.2-0.5, but observed values are ~1.9-2.0, matching chromosome ratio patterns.

| Category | n | Median | Mean +/- SEM | Q1 - Q3 |
|----------|---|--------|------------|---------|
[data table with problematic values]

**Note**: These ratios are consistent with diploid chromosome counts relative to haploid karyotype (expected ~2.0), NOT telomere detection ratios (which should be <1.0 and typically 0.2-0.5 based on Figure 5).
```

**Documentation approach for data issues**:
1. **Flag clearly at the start** of Statistical Results section
2. **Provide evidence** for the mismatch (multiple lines of reasoning)
3. **Explain what data likely represents** instead
4. **Document implications** of missing correct data
5. **Recommend corrective actions** for future analysis
6. **Provide context** from valid related metrics

**Benefits**:
- Prevents propagation of erroneous conclusions
- Creates clear audit trail for data quality issues
- Guides future data collection or correction efforts
- Maintains scientific integrity of analysis documentation

---

## Data Provenance: Verifying Derived vs Source Columns

### The Problem: Derived Columns May Use Inferior Sources

A derived column (e.g., `technology_simplified`) may have been created from an
incomplete external file rather than the richer source column already present in
the dataset. This causes silent data loss.

**Real-world example**: `technology_simplified` was populated from a 316-row
external metadata file, yielding 268 HiFi + 47 CLR. Meanwhile, the `Assembly tech`
column (already in the dataset) contained 536/541 values -> 378 HiFi + 141 CLR.
This meant **225 assemblies (42%) had missing technology** unnecessarily.

### Diagnostic Pattern

```python
# Compare a derived column against its likely source
derived_col = 'technology_simplified'
source_col = 'Assembly tech'

print(f"Derived non-null: {df[derived_col].notna().sum()}/{len(df)}")
print(f"Source non-null:  {df[source_col].notna().sum()}/{len(df)}")

# Cross-tabulate to see mapping
ct = pd.crosstab(
    df[source_col].fillna('MISSING'),
    df[derived_col].fillna('MISSING'),
    margins=True
)
print(ct)
```

### Prevention

1. When a build script merges external metadata, check if the column already exists
2. Document which source file each derived column comes from
3. After building datasets, validate coverage: `df[col].notna().mean()`
4. Prefer reclassifying from rich source columns over merging sparse external files
