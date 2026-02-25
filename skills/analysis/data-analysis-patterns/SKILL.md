---
name: data-analysis-patterns
description: Best practices for data aggregation, recalculation, and category management in scientific analyses. Covers when to recalculate vs reuse aggregated data, handling category changes, and ensuring analytical accuracy.
version: 1.0.0
---

# Data Analysis Patterns

Expert guidance for making critical decisions in data analysis workflows, particularly around aggregation, recalculation, and maintaining analytical integrity.

## When to Use This Skill

- Deciding whether to recalculate from raw data vs reuse aggregated data
- Changing category definitions in existing analyses
- Ensuring accuracy in publication-quality analyses
- Handling conflated features that need separation
- Optimizing analysis pipelines without sacrificing correctness
- Merging multi-source datasets with composite keys
- Handling DataFrame type conversion issues during enrichment

## Recalculating vs Reusing Aggregated Data

### The Core Decision

When you have pre-aggregated data but need different categories or groupings, you face a choice:
1. **Recalculate** from raw data (slower but accurate)
2. **Remap** existing aggregates (faster but potentially inaccurate)

### When to Recalculate from Raw Data

**Scenario**: You have species-level counts in 4 categories, but need different categories based on different criteria.

**Example**:
```python
# Existing aggregated data
# Species | cat0 | cat1 | cat2 | cat3
# A       | 10   | 20   | 15   | 5

# OLD categories:
# cat0: Other (0 terminal OR >2 terminal)
# cat1: 2 terminal AND 0 interstitial
# cat2: 1 terminal AND 0 interstitial
# cat3: Any interstitial present

# NEW categories needed:
# cat1: 2 terminal (regardless of interstitial)
# cat2: 1 terminal (regardless of interstitial)
# cat3: 0 terminal (regardless of interstitial)
```

**Wrong approach** - Try to remap aggregates:
```python
# ❌ BAD: Approximation loses critical information
new_cat1 = old_cat1  # Only 2 terminal with 0 interstitial
new_cat2 = old_cat2  # Only 1 terminal with 0 interstitial
new_cat3 = old_cat0 + old_cat3  # But old_cat3 includes 0, 1, AND 2 terminal!
# Result: Inaccurate categorization
```

**Correct approach** - Recalculate from raw data:
```python
# ✅ GOOD: Recalculate from scaffold-level data
df_scaffolds = pd.read_csv('scaffold_level_data.csv')

def new_categorization(row):
    """Categorize based ONLY on terminal telomere count."""
    if row['num_terminal_telomeres'] == 2:
        return 'cat1_2terminal'
    elif row['num_terminal_telomeres'] == 1:
        return 'cat2_1terminal'
    else:  # 0 or other values
        return 'cat3_0terminal'

df_scaffolds['new_category'] = df_scaffolds.apply(new_categorization, axis=1)

# Aggregate to species level with NEW categories
species_summary = []
for species in df_scaffolds['species'].unique():
    df_sp = df_scaffolds[df_scaffolds['species'] == species]
    total = len(df_sp)

    species_summary.append({
        'species': species,
        'pct_cat1': (df_sp['new_category'] == 'cat1_2terminal').sum() / total * 100,
        'pct_cat2': (df_sp['new_category'] == 'cat2_1terminal').sum() / total * 100,
        'pct_cat3': (df_sp['new_category'] == 'cat3_0terminal').sum() / total * 100
    })

df_new = pd.DataFrame(species_summary)
```

### When Recalculation is REQUIRED

1. **Category definitions fundamentally change**
   - Example: Old categories mixed multiple features, new ones separate them

2. **Previously conflated features need separation**
   - Example: "Has interstitial" conflated terminal count with interstitial presence

3. **Aggregation criteria change**
   - Example: Per-scaffold → Per-chromosome → Per-species

4. **Publication accuracy is critical**
   - Approximations acceptable for exploration, not for figures

5. **The mapping is ambiguous or lossy**
   - If you can't confidently map old→new without information loss, recalculate

### When Approximation May Be Acceptable

1. **Exploratory analysis** (not final publication figures)
2. **Categories align closely** with existing ones
3. **Small differences acceptable** for the research question
4. **Raw data unavailable or extremely expensive to reprocess**

**IF using approximation**:
```python
# Document the approximation clearly
"""
NOTE: These percentages are APPROXIMATIONS because:
- Old cat3 included chromosomes with interstitial + varying terminal counts
- We approximate by combining cat0 + cat3 → new cat3
- Actual values may differ by ~5-10% from true recalculation
- Use for exploratory analysis only
"""
```

## Composite Keys for Multi-Source Data Merging

### The Problem: Simple Keys Aren't Always Unique

When merging datasets from multiple sources (e.g., Google Sheets + enriched AWS data + unified CSV), a single identifier often isn't enough to ensure uniqueness:

**Example scenario**:
- **ToLID alone**: Not unique (same genome has hap1, hap2, maternal, paternal variants)
- **ToLID + Assembly version**: Still not unique (same assembly processed with different pipelines)
- **ToLID + Assembly version + Pipeline version**: Finally unique!

### Creating Composite Keys

**Pattern**: Concatenate multiple fields with a delimiter to create unique identifiers.

```python
# 3-part composite key for genome assemblies
df['_composite_key'] = (
    df['ToLID'].astype(str) + '|' +
    df['Assembly_version'].astype(str) + '|' +
    df['Pipeline_version'].astype(str)
)

# Verify uniqueness
assert df['_composite_key'].nunique() == len(df), f"Composite key not unique! {df['_composite_key'].nunique()} unique vs {len(df)} rows"
```

**Key design decisions**:
1. **Delimiter choice**: Use `|` or `::` (avoid `-` or `_` which may appear in field values)
2. **Field order**: Most to least specific (ToLID > Assembly > Pipeline)
3. **Type casting**: Always `.astype(str)` to avoid concatenation errors
4. **Temporary column**: Use `_composite_key` (underscore prefix) to indicate temporary/internal use

### Handling Duplicates After Composite Key

Even with composite keys, you may still find duplicates due to:
- Multiple uploads of the same assembly
- Different curated dates for the same genome
- Partial vs complete records

**Resolution strategy**:

```python
def resolve_duplicates(df, key_column='_composite_key', date_column='Curated'):
    """
    For duplicate composite keys, keep:
    1. Latest record (by date) if dates differ
    2. Most complete record (most non-null values) if dates same/missing
    """
    duplicated_keys = df[df.duplicated(key_column, keep=False)][key_column].unique()

    rows_to_keep = []

    for key in duplicated_keys:
        dup_group = df[df[key_column] == key].copy()

        # Strategy 1: Keep latest by date
        if date_column in dup_group.columns:
            dup_group[date_column] = pd.to_datetime(dup_group[date_column], errors='coerce')
            if dup_group[date_column].notna().any():
                latest = dup_group.loc[dup_group[date_column].idxmax()]
                rows_to_keep.append(latest)
                continue

        # Strategy 2: Keep most complete record
        dup_group['_completeness'] = dup_group.notna().sum(axis=1)
        most_complete = dup_group.loc[dup_group['_completeness'].idxmax()]
        rows_to_keep.append(most_complete)

    # Combine deduplicated rows with non-duplicated rows
    df_deduped = pd.concat([
        df[~df[key_column].isin(duplicated_keys)],
        pd.DataFrame(rows_to_keep)
    ], ignore_index=True)

    return df_deduped

# Apply deduplication
df_clean = resolve_duplicates(df_new, key_column='_composite_key', date_column='Curated')
```

### Merging with Composite Keys

**Scenario**: Merge new data (from Google Sheets) with previous enrichments (AWS-fetched QC data).

**Critical requirement**: Preserve manually enriched data while updating base fields.

```python
# Create composite keys in both DataFrames
df_new['_composite_key'] = create_composite_key(df_new)
df_previous['_composite_key'] = create_composite_key(df_previous)

# Identify rows in both datasets
merged = df_new.merge(
    df_previous,
    on='_composite_key',
    how='left',
    suffixes=('_new', '_old')
)

# Detect conflicts (both have non-null values but they differ)
conflicts = []
for col in base_columns:  # Columns from Google Sheets
    col_new = f"{col}_new"
    col_old = f"{col}_old"

    if col_new in merged.columns and col_old in merged.columns:
        mask = (merged[col_new].notna() &
                merged[col_old].notna() &
                (merged[col_new] != merged[col_old]))

        if mask.any():
            conflicts.append({
                'column': col,
                'num_conflicts': mask.sum(),
                'examples': merged.loc[mask, ['_composite_key', col_new, col_old]].head(3)
            })

# Resolve conflicts based on strategy
CONFLICT_RESOLUTION = "NEW"  # or "OLD"

for col in all_columns:
    col_new = f"{col}_new"
    col_old = f"{col}_old"

    if col_new in merged.columns and col_old in merged.columns:
        if CONFLICT_RESOLUTION == "NEW":
            # Use new data, fallback to old if new is null
            merged[col] = merged[col_new].fillna(merged[col_old])
        else:  # "OLD"
            # Use old data, fallback to new if old is null
            merged[col] = merged[col_old].fillna(merged[col_new])
    elif col_new in merged.columns:
        merged[col] = merged[col_new]
    elif col_old in merged.columns:
        merged[col] = merged[col_old]

# Clean up suffixed columns
merged = merged[[col for col in merged.columns if not col.endswith('_new') and not col.endswith('_old')]]
```

### Best Practices

1. **Always verify uniqueness** after creating composite key
2. **Document composite key fields** in data documentation
3. **Handle duplicates explicitly** before merging
4. **Report conflicts** to user for review
5. **Provide conflict resolution options** (NEW vs OLD)
6. **Remove composite key** before final save (it's a temporary working column)
7. **Test on small subset** before processing full dataset

### Example Use Case: VGP Genome Data Updates

**Workflow**:
1. Download latest genome table from Google Sheets
2. Create 3-part composite key (ToLID + Assembly + Pipeline)
3. Resolve duplicates (latest date, then most complete)
4. Merge with previous table to preserve AWS-enriched QC data
5. Detect and report conflicts
6. Let user choose NEW (Google Sheets) or OLD (preserved enrichments) values
7. Save merged result with composite key removed

**Result**: Updated genome metadata that preserves valuable enriched data while incorporating new/updated base information.

## Separating Conflated Features

### Pattern: When One Metric Combines Multiple Independent Features

**Example**: Telomere categories that mixed terminal AND interstitial presence

**Old (conflated)**:
- Cat 1: 2 terminal, 0 interstitial ✓
- Cat 2: 1 terminal, 0 interstitial ✓
- Cat 3: Has interstitial (could have 0, 1, OR 2 terminal!) ❌ Conflated
- Cat 4: 0 terminal, 0 interstitial ✓

**Problem**: Can't answer "How many have 2 terminal telomeres?" because Cat 3 mixed terminal counts.

**Solution**: Separate into two independent analyses
1. **Terminal telomere presence** (3 categories: 2, 1, 0)
2. **Interstitial telomere presence** (separate binary or count analysis)

**Implementation**:
```python
# Analysis 1: Terminal telomeres ONLY
df['terminal_category'] = df['num_terminal'].map({2: 'cat1', 1: 'cat2', 0: 'cat3'})

# Analysis 2: Interstitial telomeres ONLY (separate figure)
df['has_interstitial'] = df['num_interstitial'] > 0
df['interstitial_count'] = df['num_interstitial']
```

**Benefits**:
- Clear interpretation of each feature independently
- Can correlate features if needed (terminal vs interstitial)
- No ambiguity in categories
- Enables future analyses of each feature separately

## AWS Data Enrichment Patterns

When enriching tabular data from AWS S3 repositories:

### Multi-Source S3 Path Resolution

**Problem**: Primary data source (e.g., genome table) has incomplete S3 path coverage (e.g., 48/716 = 6.7%)

**Solution**: Two-tier path resolution strategy:

1. **Direct Lookup**: Map known paths from primary source
2. **Path Inference**: Construct and validate paths for missing entries

**Implementation Pattern**:
```python
# Tier 1: Direct lookup from primary source
s3_lookup = {}
for _, row in df_primary.iterrows():
    key = row['identifier']
    path = row['s3_path']
    if pd.notna(key) and pd.notna(path):
        if key not in s3_lookup:
            s3_lookup[key] = path

df_target['_s3_path'] = df_target['identifier'].map(s3_lookup)

# Tier 2: Infer missing paths with validation
def infer_s3_path(identifier, metadata):
    """Construct S3 path from metadata and validate existence"""
    path = f"s3://bucket/{construct_path(metadata, identifier)}/"

    # CRITICAL: Validate path exists before using
    result = subprocess.run(
        ['aws', 's3', 'ls', path, '--no-sign-request'],
        capture_output=True, timeout=10
    )
    return path if result.returncode == 0 else None

# Apply inference to missing paths
for idx in df_target[df_target['_s3_path'].isna()].index:
    inferred = infer_s3_path(df_target.at[idx, 'id'],
                            df_target.at[idx, 'metadata'])
    if inferred:
        df_target.at[idx, '_s3_path'] = inferred
```

**Key Considerations**:
- **Validation is essential**: Always verify inferred paths exist (prevent 404s during data fetch)
- **Performance**: Path validation takes ~5-10s per entry (budget time for large datasets)
- **Test mode**: Use `TEST_MODE` to validate inference on small sample first
- **Temporary columns**: Use `_s3_path` prefix for columns removed before saving

**Time Savings**: For 668 missing paths @ 7s each = ~78 minutes of validation, but prevents hours of debugging failed fetches

### Input File Priority Detection

**Pattern**: When enrichment notebooks can run multiple times, auto-detect the most complete input file:

```python
# Check for enriched table with current date first
enriched_today = f"Genome_table_{TODAY}_enriched.tsv"

if os.path.exists(enriched_today):
    INPUT_FILE = enriched_today
    print(f"✓ Found enriched genome table from today: {INPUT_FILE}")
    print(f"  (Continuing enrichment of today's data)")
else:
    # Check for merged table with current date
    merged_today = f"Genome_table_{TODAY}_merged.tsv"

    if os.path.exists(merged_today):
        INPUT_FILE = merged_today
        print(f"✓ Found merged genome table from today: {INPUT_FILE}")
    else:
        # Fall back to latest merged or raw data
        merged_files = glob.glob("Genome_table_*_merged.tsv")
        merged_files.sort(reverse=True)

        if merged_files:
            INPUT_FILE = merged_files[0]
            print(f"✓ Using latest merged file: {INPUT_FILE}")
        else:
            INPUT_FILE = "VGP_VGL_genomes - raw data.tsv"
            print(f"✓ Using raw data: {INPUT_FILE}")
```

**Priority Order**: `enriched_today > merged_today > latest_merged > raw`

**Benefits**:
- **In-place enrichment**: Updating same file prevents version proliferation
- **Idempotent**: Re-running adds missing data without duplicates
- **Recovery**: Can continue after interruption
- **Clear state**: User knows exactly what data is being used

**User Experience**:
```
✓ Found enriched genome table from today: Genome_table_20260220_enriched.tsv
  (Continuing enrichment of today's data)
```

### Idempotent Column Addition

When adding new columns to existing DataFrames (especially in notebooks that may be re-run):

```python
# Pattern: Check before adding
new_columns = {
    'BUSCO completeness': float,
    'BUSCO lineage': str,
    'Merqury QV': float
}

columns_added = []
for col, dtype in new_columns.items():
    if col not in df.columns:
        if dtype == float:
            df[col] = np.nan
        else:
            df[col] = None  # or pd.NA for pandas 1.0+
        columns_added.append(col)

if columns_added:
    print(f"✓ Added {len(columns_added)} columns: {', '.join(columns_added)}")
```

**Why idempotent operations matter**:
- Notebooks can be re-run without errors
- Works for both initial runs and continuation of enrichment
- Clear feedback on what changed
- Supports incremental data updates

**Anti-pattern**:
```python
# ❌ Fails on re-run if column exists
df['New Column'] = np.nan
# Raises: ValueError: The column label 'New Column' is not unique
```

**Type handling during enrichment**:
```python
# When source and target have different dtypes
for idx, row in df.iterrows():
    if pd.isna(row['Numeric Column']):
        value = external_data.get('value')  # Returns float or int

        # Handle object dtype columns (common after TSV loading)
        if df['Numeric Column'].dtype == 'object':
            value = str(int(value)) if value == int(value) else str(value)

        df.at[idx, 'Numeric Column'] = value
```

## Critical Data Validation: Column Name Verification

### The Problem: Column Names Can Be Misleading

**Column names don't always match their content.** This can happen due to:
- Copy-paste errors during data generation
- Misunderstanding of source code logic
- Legacy naming from previous versions
- Automatic column naming that reverses order

**Real-world example from VGP analysis:**
Dataset columns were named **opposite** of their actual content:
- `telomere_cat0_both_terminal` → Actually contained "no telomeres" data (cat0)
- `telomere_cat1_one_terminal` → Actually contained "both terminal" data (cat1)
- `telomere_cat2_no_terminal` → Actually contained "one terminal" data (cat2)

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
- ⚠️ Results contradict biological expectations
- ⚠️ Percentages don't sum to 100% when they should
- ⚠️ Categories show inverse patterns to literature
- ⚠️ Column names use generic terms (cat0, cat1, cat2)
- ⚠️ Values seem swapped or inverted
- ⚠️ Known controls don't match expected values

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

## DataFrame Type Conversion During Enrichment

### The Problem: Type Mismatches When Enriching DataFrames

When enriching a DataFrame with data from external sources (CSV files, AWS, APIs), you often encounter **type conversion errors**:

```python
# Common error:
TypeError: Invalid value '12345' for dtype object
# OR
TypeError: Cannot assign float64 to object column
```

**Root cause**: Target DataFrame column has a specific dtype (often `object`/string), but you're trying to assign numeric or other typed values directly.

### Why This Happens

**Scenario**: Genome metadata table with string columns being enriched from numeric sources.

```python
# Original DataFrame (from Google Sheets or CSV)
df = pd.read_csv('genome_table.csv', dtype=str)  # All columns loaded as strings
print(df['Genome_size'].dtype)  # dtype: object

# Enrichment source (unified CSV with proper types)
unified_df = pd.read_csv('vgp_assemblies_unified.csv')
print(unified_df['asm_stats_haploid_number'].dtype)  # dtype: int64

# ❌ FAILS: Trying to assign int to string column
df.loc[mask, 'Genome_size'] = unified_df['asm_stats_haploid_number']
# TypeError: Invalid value '4077481159' for dtype object
```

**Why columns are strings**:
1. Mixed data types in original source (numbers + text like "N/A")
2. Explicit `dtype=str` during loading to preserve formatting
3. Previous text values in column
4. Pandas inference chose `object` dtype

### The Solution: Type-Safe Assignment Pattern

**Before assigning, check target dtype and convert if needed:**

```python
def safe_assign_to_string_column(df, row_mask, target_col, value):
    """
    Safely assign a value to a DataFrame column, handling type conversion.

    If target column is string type and value is numeric, convert to string first.
    """
    # Check if target column is string/object type
    if df[target_col].dtype == 'object' or pd.api.types.is_string_dtype(df[target_col]):
        # Convert numeric values to string
        if isinstance(value, (int, float, np.integer, np.floating)):
            # Remove unnecessary decimal places for integers
            if isinstance(value, float) and value == int(value):
                value = str(int(value))
            else:
                value = str(value)

    # Now safe to assign
    df.loc[row_mask, target_col] = value

# Usage
for idx, row in df_genome.iterrows():
    if condition:
        unified_value = unified_df.loc[unified_mask, 'asm_stats_haploid_number'].values[0]
        safe_assign_to_string_column(df_genome, idx, 'Genome_size', unified_value)
```

### Vectorized Approach for Multiple Columns

**For enriching many rows/columns efficiently:**

```python
# Define column mapping: genome_table_col -> unified_csv_col
column_mapping = {
    'Genome_size': 'asm_stats_haploid_number',
    'Heterozygosity': 'heterozygosity',
    'Repeat_content': 'repeat_percent',
    'Scaffold_N50': 'asm_stats_n50',
    'GC_content': 'gc_percent'
}

for genome_col, unified_col in column_mapping.items():
    # Get values from unified CSV
    enrichment_values = unified_df[unified_col]

    # Check if target column is string type
    is_string_target = (df_genome[genome_col].dtype == 'object' or
                        pd.api.types.is_string_dtype(df_genome[genome_col]))

    if is_string_target:
        # Convert numeric values to strings
        if pd.api.types.is_numeric_dtype(enrichment_values):
            # Handle integers vs floats
            enrichment_values = enrichment_values.apply(
                lambda x: str(int(x)) if pd.notna(x) and x == int(x) else str(x) if pd.notna(x) else x
            )

    # Now safe to assign
    df_genome.loc[mask, genome_col] = enrichment_values.values
```

### Common Patterns and Solutions

**Pattern 1: Integer values in string columns**
```python
# Source: int64 (4077481159)
# Target: object column
# ✅ Solution: Convert to string
unified_value = 4077481159
if isinstance(unified_value, (int, np.integer)):
    unified_value = str(unified_value)
df.loc[idx, 'Genome_size'] = unified_value  # "4077481159"
```

**Pattern 2: Float percentages in string columns**
```python
# Source: float64 (1.47)
# Target: object column
# ✅ Solution: Convert to string, optionally format
unified_value = 1.47696
if isinstance(unified_value, (float, np.floating)):
    unified_value = f"{unified_value:.2f}"  # "1.48" or str(unified_value) # "1.47696"
df.loc[idx, 'Heterozygosity'] = unified_value
```

**Pattern 3: Mixed type columns (some strings, some numbers)**
```python
# Some rows have "N/A", others should have numbers
# Target MUST be object dtype to hold both
df['Genome_size'] = df['Genome_size'].astype('object')  # Ensure object dtype

# Then assign with type checking
for idx, value in enrichments.items():
    if pd.notna(value):
        if isinstance(value, (int, float)):
            value = str(value)
    df.loc[idx, 'Genome_size'] = value
```

### When to Convert Target Column Type Instead

**Consider changing target dtype if**:
1. Column should be numeric for calculations
2. All existing values are numeric or NaN
3. No need to preserve string formatting
4. Column will be used in statistical analysis

```python
# Check if safe to convert
if df['Genome_size'].apply(lambda x: pd.isna(x) or str(x).replace('.','').isdigit()).all():
    # All values are numeric or NaN - safe to convert
    df['Genome_size'] = pd.to_numeric(df['Genome_size'], errors='coerce')
    # Now can assign numeric values directly
    df.loc[mask, 'Genome_size'] = unified_df['asm_stats_haploid_number']
```

**Don't convert if**:
- Source data mixes text and numbers ("N/A", "Unknown", etc.)
- Need to preserve exact string representation
- Column used for display/export, not calculations

### Debugging Type Errors

**When you get a type error, check:**

```python
# 1. Check target column dtype
print(f"Target column dtype: {df['Genome_size'].dtype}")
print(f"Target column type: {type(df['Genome_size'].iloc[0])}")

# 2. Check source value type
print(f"Source value type: {type(unified_value)}")
print(f"Source value: {unified_value}")

# 3. Check for mixed types in target column
print(df['Genome_size'].apply(type).value_counts())

# 4. Sample target column values
print(df['Genome_size'].head(10))
```

### Real-World Example: VGP Genome Enrichment

**Situation**: Enriching genome table from two sources:
1. `vgp_assemblies_unified.csv`: Numeric dtypes (int64, float64)
2. GenomeArk AWS: Parsed from text files (strings)
3. Target: Genome table loaded with `dtype=str` to preserve original formatting

**Problem**:
```python
df_genome.loc[idx, 'Genome_size'] = 4077481159  # int64
# TypeError: Invalid value '4077481159' for dtype object
```

**Solution**: Type-safe assignment pattern
```python
# Check target dtype before assignment
genome_col = 'Genome_size'
if df_genome[genome_col].dtype == 'object':
    if isinstance(unified_value, (int, float)):
        unified_value = str(int(unified_value)) if unified_value == int(unified_value) else str(unified_value)

df_genome.loc[idx, genome_col] = unified_value  # Now works: "4077481159"
```

**Result**: Successfully enriched 11 fields across 716 genomes without type errors.

### Best Practices

1. **Check dtype before assignment** - Don't assume column types
2. **Convert values to match target dtype** - Easier than converting whole column
3. **Use helper functions** - Encapsulate type checking logic
4. **Handle NaN explicitly** - `pd.notna()` checks before conversion
5. **Preserve integers as integers** - Use `int(x)` before `str()` to avoid ".0"
6. **Test on small sample first** - Catch type errors early
7. **Document dtype expectations** - Comment why columns are string vs numeric

### Prevention Checklist

Before enriching a DataFrame:
- [ ] Check target column dtypes: `df.dtypes`
- [ ] Check source value types: `type(value)` or `df_source.dtypes`
- [ ] Decide: Convert values or convert column?
- [ ] Implement type-safe assignment function
- [ ] Test on 2-3 rows before full enrichment
- [ ] Handle NaN/None cases explicitly

## Best Practices

### 1. Assess Information Loss
Before deciding to reuse aggregated data, check:
```python
# Can you perfectly reconstruct raw data from aggregates?
# If NO → Recalculate
```

### 2. Document Your Decision
```python
"""
Data source: scaffold_telomere_data.csv (n=6,356 scaffolds)
Recalculated: 2026-01-29
Reason: Previous aggregation conflated terminal and interstitial presence
Method: [describe categorization logic]
"""
```

### 3. Validate Against Original if Possible
```python
# If reusing aggregates, check consistency
original_total = df['cat1'] + df['cat2'] + df['cat3'] + df['cat4']
new_total = df['new_cat1'] + df['new_cat2'] + df['new_cat3']
assert (original_total == new_total).all(), "Category totals don't match!"
```

### 4. Time vs Accuracy Trade-off
- **Exploration phase**: Approximations okay, clearly documented
- **Publication phase**: Always recalculate for accuracy
- **Intermediate**: Recalculate once, save results, reuse those

## Real-World Example: VGP Telomere Analysis

**Situation**: Initial figure used 4 categories that conflated terminal and interstitial telomeres. Needed simplified 3-category system based ONLY on terminal count.

**Attempted**: Approximation by combining old categories
**Problem**: Old cat3 included chromosomes with 0, 1, OR 2 terminal telomeres + interstitial

**Solution**:
1. Returned to scaffold-level data (11,812 scaffolds)
2. Recategorized based purely on `num_terminal_telomeres` field
3. Aggregated to species level (310 species)
4. Generated accurate Figure 5 for publication

**Result**:
- Dual: 52% chromosomes with 1 terminal (accurate)
- vs approximate: 12% (old cat2 only, missed many in old cat3)
- **40 percentage point difference** - approximation would have been wildly wrong

**Lesson**: When category semantics change fundamentally, recalculation is not optional.

## Performance Considerations

**Recalculation is often faster than you think**:
```python
# Modern pandas on 10,000+ rows
start = time.time()
df['new_cat'] = df.apply(categorize_func, axis=1)
result = df.groupby('species').agg({'new_cat': 'value_counts'})
print(f"Recalculation: {time.time() - start:.2f}s")  # Often < 1 second
```

**Optimize recalculation**:
- Use vectorized operations instead of apply() when possible
- Filter to relevant columns before processing
- Cache intermediate results if running multiple times

---

## Organizing Analysis Text for Token Efficiency

### Use Case
Scientific projects with:
- Large Jupyter notebooks containing analysis + interpretation
- Multiple figures requiring detailed analysis text
- Need to reference specific analyses without loading entire notebook

### The Problem
- Notebook: 4.2 MB with code + analysis text → ~1,050,000 tokens
- Can't efficiently load just the analysis for one figure
- Difficult to maintain and update analysis text in notebook cells
- Hard to reuse analysis text in manuscript preparation

### The Solution: analysis_files/ Directory

Separate computation (notebooks) from interpretation (markdown files):

**Directory structure**:
```
project/
├── analysis_files/
│   ├── MANIFEST.md           # Guide to the analysis files
│   ├── Method.md             # Methods section
│   └── figures/
│       ├── 01_figure1.md     # Analysis for figure 1
│       ├── 02_figure2.md     # Analysis for figure 2
│       └── ...
├── notebooks/
│   └── Analysis.ipynb        # Code for computation & figures
├── figures/
│   └── output/
│       ├── 01_figure1.png
│       └── 02_figure2.png
└── data/
```

### What Goes in Each File

**analysis_files/figures/NN_name.md**:
- Figure description (figure legend format)
- Statistical methods used
- Analysis framework and interpretation
- Mechanistic explanations
- Context from other results
- Biological/technical considerations
- Publication-ready prose

**analysis_files/Method.md**:
- Complete methods section
- Dataset description
- Statistical approaches
- Data sources
- Limitations

**notebooks/*.ipynb**:
- Data loading and processing
- Statistical computations
- Figure generation code
- Minimal text (link to analysis files instead)

### Writing Style Guidelines

Base style on existing notebook/paper:
1. Read current notebook for analysis patterns
2. Read paper draft (if exists) for writing style
3. Match level of detail and technical depth
4. Include same types of explanations (statistical, mechanistic, biological)

**Common elements in scientific analysis files**:
- Clear figure descriptions with n values
- Statistical test details (test name, p-values, why chosen)
- Interpretation framework (what comparison shows)
- Mechanistic explanations (why differences occur)
- Context (how relates to other results)
- Practical implications
- Limitations and caveats

### Token Efficiency

**Example savings**:
- Full notebook: 1,135,000 tokens
- All analysis files: 22,000 tokens
- Single figure analysis: 5,000 tokens
- **Reduction: 98%**

**Practical benefit**: In 200K context window, can load all analyses + have 175K tokens for conversation.

### Integration with MANIFEST System

Update manifests to link figures to analyses:

**figures/MANIFEST.md**:
```markdown
**01_figure_name.png**
- **Description**: Brief description
- **Analysis file**: `../analysis_files/figures/01_figure_name.md`
```

**analysis_files/MANIFEST.md**:
- Document purpose and usage
- Explain token efficiency gains
- Provide usage examples
- Link to figure files

### Managing TODOs

**Critical**: Keep analysis files clean and publication-ready

**In analysis files** (❌ DON'T):
```markdown
## Analysis
[TO BE COMPLETED - add results here]
- [ ] Run statistical test
- [ ] Fill in p-values
```

**In separate TODO note** (✅ DO):
Create Obsidian note or similar tracking document:
```markdown
# Figure Analysis TODOs
## Figure 1
- [ ] Run Kruskal-Wallis test
- [ ] Get n for each category
- [ ] Fill in p-values in 01_figure1.md
```

### Workflow

1. **Setup**: Create directory structure
2. **Extract**: Pull analysis text from notebooks
3. **Clean**: Create publication-ready markdown files
4. **Track**: Move TODOs to separate tracking system
5. **Link**: Update MANIFESTs with cross-references
6. **Maintain**: Update analysis files, not notebooks

### When to Use This Pattern

✅ **Good fit**:
- Multiple figures with detailed analyses
- Large notebooks (>1 MB)
- Preparing for publication
- Frequent reference to specific analyses
- Collaborative writing

❌ **Overkill for**:
- Single figure projects
- Exploratory analysis (not publication-bound)
- Small notebooks (<500 KB)
- Code-heavy, minimal text notebooks

### Populating Analysis Files with Statistical Results

When framework analysis files have been created but need statistical results filled in:

**Workflow pattern**:
1. **Use TodoWrite to track progress** - Create todos for each file to fill in
2. **Work sequentially through files** - Complete one file before moving to next
3. **Read framework file** - Understand existing structure and placeholders
4. **Add Statistical Results section** with:
   - Sample sizes and descriptive statistics table
   - Statistical test results (with exact values)
   - Achievement thresholds or accuracy metrics (if applicable)
5. **Add Interpretation section** with:
   - Effect type analysis (isolating different experimental factors)
   - Mechanistic explanations
   - Practical implications
   - Context from other metrics
   - Limitations
   - Conclusion
6. **Mark todo completed immediately** - Don't batch completions

**Example structure for each analysis file**:
```markdown
## Statistical Results

### Sample Sizes and Descriptive Statistics
| Category | n | Median | Mean ± SEM | Q1 - Q3 |
|----------|---|--------|------------|---------|
[data table]

### Statistical Tests
**Kruskal-Wallis test** (three-group comparison):
- H statistic = X.XX
- p-value = X.XXX
- **Result**: [HIGHLY significant/Significant/NO significant] differences

**Post-hoc pairwise tests**:
- Category A vs B: p = X.XXX (interpretation)
- Category A vs C: p = X.XXX (interpretation)
- Category B vs C: p = X.XXX (interpretation)

## Interpretation

### [Primary Finding Title]
[Statistical interpretation paragraph]

### Implications by Effect Type
**1. Factor 1 Effect**: [Analysis isolating first factor]
**2. Factor 2 Effect**: [Analysis isolating second factor]
**3. Combined Effect**: [Overall pattern]

### [Mechanistic Explanation Section]
[Why differences occur]

### [Context from Other Metrics]
[How this relates to other findings]

### Limitations
[Study-specific caveats]

## Conclusion
[Summary paragraph with key takeaways]
```

**Key practices**:
- **Maintain consistent formatting** across all analysis files
- **Include exact statistical values** (H statistic, p-values, sample sizes)
- **Provide mechanistic explanations** beyond just reporting significance
- **Cross-reference other findings** to build coherent narrative
- **Document data issues clearly** (e.g., implausible values, mismatched columns)
- **Use significance markers consistently**: *** p<0.001, ** p<0.01, * p<0.05, ns

---

## Data Quality Verification During Analysis

### Detecting Implausible Values

When populating analysis files with statistical results, **verify biological plausibility**:

**Red flags for data issues**:
1. **Values outside expected range**:
   - Ratios >1.0 when measuring partial detection (<1.0 expected)
   - Ratios ~2.0 that match patterns from different metrics (e.g., diploid/haploid)
2. **Inconsistency with related metrics**:
   - Figure 5 shows 34.5% telomere detection → Figure 5b should show ratio ~0.35, NOT 2.0
3. **Biological impossibility**:
   - 200% detection of telomeres (can't detect more than exist)
4. **Pattern matching wrong metric**:
   - Values matching chromosome counts when expecting telomere counts

**Example from Figure 5b issue**:
```markdown
## Statistical Results

### Sample Sizes and Descriptive Statistics

**IMPORTANT DATA ISSUE**: The values obtained appear to represent **chromosome achievement ratios** (similar to Figure 3) rather than **telomere detection ratios**. Expected telomere detection ratios based on Figure 5 results should be ~0.2-0.5, but observed values are ~1.9-2.0, matching chromosome ratio patterns.

| Category | n | Median | Mean ± SEM | Q1 - Q3 |
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

## Multi-Factor Experimental Design Analysis

### Analyzing Multi-Factor Experimental Designs

When experimental design has multiple factors (e.g., assembly architecture × curation method):

**Three-category design pattern**:
- **Category 1**: Factor A + Factor B (e.g., Phased + Dual)
- **Category 2**: Factor A + ~B (e.g., Phased + Single)
- **Category 3**: ~A + ~B (e.g., Pri/alt + Single)

**Enables isolation of effects**:
1. **Factor B effect**: Compare Category 1 vs Category 2 (controls Factor A)
2. **Factor A effect**: Compare Category 2 vs Category 3 (controls Factor B)
3. **Combined effect**: Compare Category 1 vs Category 3 (both factors)

**Interpretation framework**:
```markdown
### Implications by Effect Type

**1. [Factor B] Effect (Category1 vs Category2):**
- Comparison: [values]
- p-value: [X.XXX]
- **Finding**: [significant/not significant]
- **Interpretation**: [what this means for Factor B in isolation]

**2. [Factor A] Effect (Category2 vs Category3):**
- Comparison: [values]
- p-value: [X.XXX]
- **Finding**: [significant/not significant]
- **Interpretation**: [what this means for Factor A in isolation]

**3. Combined Effect:**
- If Category1 vs Category3 shows larger difference than either individual factor → synergistic
- If similar to one factor → that factor dominates
- If no difference despite individual effects → antagonistic
```

**Example from VGP analysis**:
- **Curation effect** (Dual vs Single): Compare Phased+Dual vs Phased+Single
- **Assembly effect** (Phased vs Pri/alt): Compare Phased+Single vs Pri/alt+Single
- **Result**: Assembly architecture dominates (8× gap density difference), curation has no effect

**Benefits**:
- Cleanly separates confounded effects
- Identifies which factor drives observed differences
- Enables mechanistic interpretation

---

## Interpreting Paradoxical or Contradictory Results

### Recognizing Paradoxes

**Pattern**: When one category performs BETTER on metric X but WORSE on related metrics Y and Z:

**Example from VGP analysis**:
- Pri/alt: ✅ HIGHER chromosome assignment (98.7%)
- Pri/alt: ❌ 8× MORE gaps, ❌ 2-3× FEWER telomeres
- **Paradox**: Higher assignment despite worse quality

### Trade-off Hypothesis Framework

When contradictory patterns emerge, consider **quality trade-offs**:

```markdown
### The Trade-off Hypothesis

The contrasting patterns suggest a fundamental **[dimension 1] vs [dimension 2] trade-off**:

**Maximize [dimension 1] ([approach A])**:
- ✅ Better on metric X
- ❌ Worse on metric Y
- ❌ Worse on metric Z
- 🤷 Equivalent on metric W

**Maximize [dimension 2] ([approach B])**:
- ❌ Worse on metric X
- ✅ Better on metric Y
- ✅ Better on metric Z
- 🤷 Equivalent on metric W

**Interpretation**: [Approach A] prioritizes [goal 1], while [Approach B] prioritizes [goal 2]. Neither approach is universally superior - the optimal choice depends on [application requirements].
```

**Example application**:
```markdown
**Pri/alt: Maximize chromosome assignment**
- Liberal assignment criteria
- More sequence on chromosomes
- Result: High assignment%, but chromosomes have gaps/incomplete ends

**Phased: Maximize chromosome accuracy**
- Conservative assignment criteria
- Only high-confidence sequences on chromosomes
- Result: Lower assignment%, but chromosomes are higher quality
```

**Benefits of trade-off framing**:
- Resolves apparent contradictions
- Identifies different optimization strategies
- Guides methodology selection based on priorities
- Prevents oversimplified "best method" conclusions

### Documenting Counter-Intuitive Results

When results contradict initial hypotheses:

**Documentation pattern**:
1. **State the expectation clearly**: "Dual curation was expected to improve telomere detection"
2. **Present the contradictory finding**: "Phased+Single median 34.5% vs Phased+Dual 19.5%"
3. **Acknowledge the surprise**: "Counter-intuitive finding", "Opposite to expectation"
4. **Explore mechanistic explanations**: Why might the opposite be true?
   - Reduced complexity in single curation
   - Clearer Hi-C signals
   - More focused curation effort
5. **Consider confounds**: Temporal factors, sample composition
6. **State statistical significance clearly**: p=0.213 (not significant, but trend exists)

**Example**:
```markdown
**1. Curation Method Effect (Dual vs Single): Marginal, OPPOSITE Direction**

The comparison shows **no statistically significant difference** (p = 0.213), but reveals a **surprising trend favoring single curation**:

- **Phased+Single performs better**: Median 34.5% vs 19.5% (1.8× higher)
- **Counter-intuitive finding**: This is **opposite** to the expectation that dual curation would improve telomere detection

**Mechanistic interpretation**: Why might single curation perform better?
- Reduced complexity: Curators make more conservative, accurate decisions
- Clearer Hi-C signal: Single haplotype maps show clearer terminus signals
- Temporal factors: May benefit from more recent algorithms
```

**Benefits**:
- Transparent about unexpected results
- Stimulates mechanistic thinking
- Prevents confirmation bias
- Guides future experimental design

---

## Species Name Reconciliation Across Data Sources

### Problem
When using external phylogenetic tree services (TimeTree, NCBI Taxonomy, etc.), species names often don't match your metadata due to:
- Database standardization
- Taxonomic updates
- Spelling variants
- OCR/data entry errors
- Trailing whitespace

### Three-Category Classification

Analyze mismatches by categorizing into:

1. **Exact matches** (already synchronized)
2. **Systematic replacements** (database standardization)
   - Example: TimeTree replacing subspecies with species names
   - Document in `species_replacements.json`
3. **Name variants** (spelling/case/whitespace)
   - Example: `Alca_torda` vs `Alca_Torda`
   - Document in `name_variant_replacements.json`

### Reconciliation Workflow

```python
# Step 1: Extract all species from tree
tree_species = set(re.findall(r'[A-Z][a-z]+_[a-z]+', tree_content))

# Step 2: Load metadata species
metadata_species = set(df['Species'].str.replace(' ', '_'))

# Step 3: Identify categories
exact_matches = tree_species & metadata_species
in_tree_only = tree_species - metadata_species
in_metadata_only = metadata_species - tree_species

# Step 4: Fuzzy match for variants
from difflib import get_close_matches
variants = {}
for tree_sp in in_tree_only:
    matches = get_close_matches(tree_sp, in_metadata_only, n=1, cutoff=0.8)
    if matches:
        variants[tree_sp] = matches[0]
```

### Critical Decision: Which Version to Keep?

**Rule of thumb**:
- Use **metadata version** when it's your authoritative source
- Exception: Remove trailing whitespace (causes file format issues)
- Document the choice in README

### Propagating Corrections

Once replacements are defined, apply to ALL related files:
```python
replacements = json.load('name_replacements.json')

files_to_update = [
    'tree.nwk',
    'annotation_dataset1.txt',
    'annotation_dataset2.txt',
    # ... all files referencing species names
]

for filepath in files_to_update:
    content = read_file(filepath)
    for old, new in replacements.items():
        content = content.replace(old, new)
    write_file(filepath.replace('.txt', '_corrected.txt'), content)
```

### Versioning Strategy

Use suffixes to track correction stages:
- `_original` - Untouched file from external source
- `_corrected` - After first round of replacements
- `_final` - After all corrections applied

This enables:
- Reproducibility
- Easy rollback if errors found
- Clear audit trail

## Phylogenetic Tree Coverage Analysis

### Coverage Metric Definition

When reconciling phylogenetic trees with species datasets, track coverage:

```
Coverage = (Species in both tree AND dataset) / (Total species in tree) × 100%
```

This metric indicates what percentage of the phylogenetic tree has data available for analysis.

### Identifying Missing Species

**Workflow:**

1. **Extract species from tree** (Newick format):
```python
import re
with open('Tree_final.nwk', 'r') as f:
    tree_content = f.read()
# Extract species names (underscored format)
tree_species = set(re.findall(r'([A-Z][a-z]+_[a-z]+)', tree_content))
```

2. **Extract species from dataset**:
```python
import pandas as pd
df = pd.read_csv('species_methods.csv')
dataset_species = set(df['Species'].str.replace(' ', '_'))
```

3. **Calculate coverage**:
```python
matched_species = tree_species & dataset_species
missing_from_dataset = tree_species - dataset_species
coverage_pct = (len(matched_species) / len(tree_species)) * 100

print(f"Coverage: {len(matched_species)}/{len(tree_species)} ({coverage_pct:.1f}%)")
print(f"Missing: {len(missing_from_dataset)} species")
```

### Categorizing Missing Species

Not all missing species are equal. Categorize them:

1. **Recoverable from data**:
   - Time Tree replacements (proxy species used)
   - Species in deprecated datasets
   - Species with different naming conventions

2. **Phylogenetic context only**:
   - Species added by tree builder for phylogenetic completeness
   - Reference species for temporal calibration
   - Not in your study scope

3. **Unknown/Uncategorizable**:
   - Species in dataset but cannot classify with current criteria
   - May need different analysis approach

### Recovery Workflow for Time Tree Replacements

**Problem**: Time Tree uses proxy species when exact species lacks data.

**Example**:
- Tree contains: `Anniella_pulchra` (proxy with available phylogenetic data)
- Dataset contains: `Anniella_stebbinsi` (actual species being studied)

**Solution**:

1. **Document replacements** in `species_replacements.json`:
```json
{
  "actual_species_name": "tree_proxy_name",
  "Anniella_stebbinsi": "Anniella_pulchra",
  "Pelomedusa_somalica": "Pelomedusa_subrufa"
}
```

2. **Check for actual species** in deprecated datasets:
```python
import json
replacements = json.load(open('species_replacements.json'))

for actual_sp, tree_sp in replacements.items():
    if tree_sp in missing_from_dataset:
        # Check deprecated datasets for actual_sp
        matches = df_deprecated[df_deprecated['Species'] == actual_sp.replace('_', ' ')]
        if not matches.empty:
            print(f"Found {actual_sp} in deprecated data - can recover!")
```

3. **Update tree to use actual names**:
```python
# Replace proxy names with actual species names in tree file
tree_content_updated = tree_content
for actual_sp, tree_sp in replacements.items():
    tree_content_updated = tree_content_updated.replace(tree_sp, actual_sp)

with open('Tree_final.nwk', 'w') as f:
    f.write(tree_content_updated)
```

4. **Synchronize all annotation files** with the updated names.

### Acceptable Coverage Levels

**Guidelines for phylogenetic analysis:**
- **100%**: Ideal, all tree species have data
- **99%+**: Excellent, few phylogenetic context species only
- **95-99%**: Good, some context species expected
- **<95%**: Investigate for recovery opportunities

**Interpretation:**
- Missing 1-3 species at 99%+ often represents phylogenetic context species
- These are acceptable and expected when tree includes reference taxa
- Focus recovery efforts on species that should have data

### Example Recovery Impact

**Case study from VGP analysis:**
- Initial coverage: 506/511 species (99.0%)
- Identified 2 Time Tree replacement species
- Recovered from deprecated datasets
- Updated tree with actual VGP species names
- Final coverage: 508/511 (99.4%)
- Remaining 3: Phylogenetic context species (acceptable)

**Outcome**: Improved coverage by identifying and correcting Time Tree proxy usage.

### Best Practices

1. **Always check for Time Tree replacements** when coverage < 100%
2. **Document all replacements** in JSON for reproducibility
3. **Update tree file** to match dataset (not the reverse)
4. **Synchronize ALL config files** after tree updates
5. **Accept phylogenetic context species** as valid missing data
6. **Track coverage metrics** throughout analysis

### Integration with Species Name Reconciliation

This coverage analysis complements the "Species Name Reconciliation Across Data Sources" section:
- Reconciliation fixes name variants and spellings
- Coverage analysis identifies true missing species vs naming issues
- Together they ensure maximal tree-dataset alignment

---

## Distinguishing True Variation from Power Limitations

**Challenge**: When analyzing multiple groups (clades, populations, cohorts), how to determine if lack of effect is real or just insufficient power?

**Key Indicators of Power Limitations** (not true null effects):

1. **Sample size much smaller** than groups showing effects
   - Example: Amphibians n=28 vs Mammals n=160
   - Effect could exist but be undetectable

2. **Trend in same direction** but non-significant
   - Medians show similar pattern
   - p-value >0.05 but effect direction matches larger groups
   - Suggests real effect masked by noise

3. **Category imbalance within group**
   - One category has only 2-5 samples
   - Can't perform robust pairwise comparisons
   - Example: Amphibians Phased+Single n=2 (only 7% of clade)

4. **Wider confidence intervals** than other groups
   - Large IQR or SD relative to median
   - Indicates high variance from small sample

**Key Indicators of True Null Effect**:

1. **Large sample** with p>0.05 and narrow confidence intervals
   - Sufficient power to detect effect if present
   - Tight distribution suggests true lack of difference

2. **Opposite direction** from other groups
   - Not just non-significant, but reversed
   - Suggests biological difference is real

3. **Significant in some metrics** but not others within same group
   - Group has power (shown by significant effects elsewhere)
   - Null result more likely to be real

**Reporting Recommendations**:

For power-limited groups:
```markdown
"No significant effects detected (all p>0.13), likely reflecting
insufficient statistical power (n=55) rather than true absence of
effects. The modest sample size and relatively balanced category
distribution reduce power to detect effects observed in larger clades."
```

For true null effects:
```markdown
"Despite excellent statistical power (n=124), dual curation showed
no improvement in scaffold N50 (p=0.378), in marked contrast to
mammals (p=0.037). This suggests fundamental differences in how avian
genomes respond to curation intensity."
```

**Example from Session** (Reptiles vs Birds):
- **Reptiles** (n=55): No significant effects → Power limitation
  - Small sample, balanced categories, trends in expected direction

- **Birds** (n=124): No N50 curation effect → True null
  - Large sample, significant effects in OTHER metrics (gap density)
  - Biological explanation: genomes already near-optimal for N50

---

## Summary

**Default to recalculation when**:
- Category definitions change
- Features were conflated
- Publication accuracy needed
- Raw data is available

**Document approximations when used**, and validate them against subsets of recalculated data.

**Separate conflated features** into independent analyses for clarity.

**For species name reconciliation**:
- Classify mismatches into systematic vs variant changes
- Apply corrections consistently across all files
- Version files to track correction stages
- Document decisions and maintain reproducibility

## Data Consolidation and Enrichment Workflows

### Pattern: Consolidate → Enrich → Verify

When working with multiple intermediate dataset versions and external data sources:

**1. Consolidation Phase**
- Identify the single source of truth (most recent, most complete version)
- Archive all intermediate/backup versions with clear documentation
- Create a consolidated dataset with enriched columns
- Use descriptive backups: `deprecated/data_backups_YYYYMMDD/`

**2. Enrichment Phase (AWS/External Data)**
- Create dedicated enrichment notebook (e.g., `enrich_unified_csv.ipynb`)
- Use TEST_MODE for initial validation (small subset)
- Add new columns to existing dataset (don't replace)
- Track enrichment coverage (% filled for each new column)

**Example Configuration**:
```python
# Safety defaults for AWS enrichment
ENABLE_AWS_FETCH = False  # Start disabled
TEST_MODE = True          # Start with small sample
TEST_SAMPLE_SIZE = 5      # Validate before full run

# After validation
ENABLE_AWS_FETCH = True
TEST_MODE = False  # Full enrichment
```

**3. Verification Phase**
- Verify all notebooks/scripts reference correct consolidated file
- Check for deprecated file references in code
- Update MANIFEST with new structure
- Document enrichment coverage and sources

**Key Files to Update**:
- Main dataset (add new columns, don't replace)
- Derivative datasets (e.g., 3-category subset)
- MANIFEST.md (document changes, archive locations)
- Column metadata documentation

**Traceability**: Always preserve:
- Pre-enrichment backups
- Enrichment logs (what was fetched, when, coverage)
- README in deprecated folders explaining what was archived

## Filtered Dataset Rebuilding Pattern

### Problem
When you enrich a master dataset with new columns, all filtered/subset versions become out of sync.

### Solution: Rebuild from Master

**Pattern**:
1. Update master dataset with new columns
2. Identify all filtered subsets (e.g., 3-category subset)
3. Rebuild each subset by re-applying the original filter to updated master
4. Verify row counts and categories match expectations

**Example**: 3-Category Dataset
```python
# Load enriched master
df_master = pd.read_csv('data/vgp_assemblies_unified_corrected.csv')

# Re-apply original filter
valid_categories = ['Phased+Dual', 'Phased+Single', 'Pri/alt+Single']
df_3cat = df_master[df_master['category_combined'].isin(valid_categories)].copy()

# Verify
assert len(df_3cat) == expected_count
assert set(df_3cat['category_combined'].unique()) == set(valid_categories)

# Save
df_3cat.to_csv('data/vgp_assemblies_3categories.csv', index=False)
```

**Key Steps**:
1. **Don't manually merge** new columns into subset - rebuild from master
2. **Preserve filter logic** - document the exact filter criteria
3. **Verify counts** - ensure category breakdown matches expectations
4. **Update documentation** - note rebuild date and reason in MANIFEST

**Common Mistake**: Trying to merge new columns into existing subset → leads to mismatches

**Correct Approach**: Always rebuild from enriched master using original filter

## Confounding Analysis: Technology and Temporal Effects

### Pattern: Technology Confounding in Temporal Analysis

**Problem**: Temporal trends may reflect technology adoption rather than methodology improvements

**Example from VGP assemblies:**
- Gap density shows strong improvement over time (ρ = -0.54, p < 1e-40)
- But is this better assembly methods or just CLR→HiFi technology shift?

### Solution: Technology-Stratified Temporal Analysis

**Three-stage approach:**

#### Stage 1: Mixed-Technology Analysis (Baseline)
```python
# All assemblies, mixed technologies
temporal_results_mixed = []
for category in ['Method_A', 'Method_B', 'All']:
    data = df[df['category'] == category][['metric', 'year']].dropna()
    rho, pvalue = stats.spearmanr(data['year'], data['metric'])
    temporal_results_mixed.append({
        'category': category,
        'rho': rho,
        'p_value': pvalue
    })
```

#### Stage 2: Technology-Only Subset Analysis
```python
# Filter to single technology (e.g., HiFi only)
df_single_tech = df[df['technology'] == 'HiFi'].copy()

temporal_results_controlled = []
for category in ['Method_A', 'Method_B', 'All HiFi']:
    data = df_single_tech[df_single_tech['category'] == category][['metric', 'year']].dropna()
    rho, pvalue = stats.spearmanr(data['year'], data['metric'])
    temporal_results_controlled.append({
        'category': category,
        'rho': rho,
        'p_value': pvalue
    })
```

#### Stage 3: Compare Mixed vs Controlled
```python
# Identify technology artifacts vs real trends
for metric in metrics:
    mixed_row = mixed_df[mixed_df['metric'] == metric]
    controlled_row = controlled_df[controlled_df['metric'] == metric]

    delta_rho = controlled_row['rho'] - mixed_row['rho']

    # Technology artifact: significant in mixed, not in controlled
    if mixed_row['p_value'] < 0.05 and controlled_row['p_value'] >= 0.05:
        print(f"⚠️  TECHNOLOGY ARTIFACT: {metric}")
        print(f"    Mixed: ρ={mixed_row['rho']:.3f} (p={mixed_row['p_value']:.4e}) SIGNIFICANT")
        print(f"    Controlled: ρ={controlled_row['rho']:.3f} (p={controlled_row['p_value']:.4e}) NOT SIG")

    # Real trend: significant in both or only in controlled
    elif controlled_row['p_value'] < 0.05:
        print(f"✓  REAL TEMPORAL TREND: {metric}")
```

### Interpretation Guidelines

**Technology Artifact Indicators:**
- Trend disappears when technology is held constant
- |Δρ| > 0.15 (large change in correlation strength)
- Timeline coincides with technology adoption (e.g., 2021 CLR→HiFi shift)

**Real Temporal Trend Indicators:**
- Trend persists or strengthens in technology-controlled analysis
- Consistent direction across different technology subsets
- Gradual change rather than step-function at technology transition

### Visualization: Side-by-Side Temporal Plots

```python
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Mixed technology (with technology markers)
for tech, marker in [('HiFi', 'o'), ('CLR', 's')]:
    tech_data = df[df['technology'] == tech]
    ax1.scatter(tech_data['year'], tech_data['metric'],
                marker=marker, label=tech, alpha=0.6)
ax1.set_title('Mixed Technology (Confounded)')

# Single technology only
ax2.scatter(df_single_tech['year'], df_single_tech['metric'],
            marker='o', alpha=0.6)
ax2.set_title('HiFi Only (Controlled)')
```

### When to Use This Pattern

- **Sequencing technology evolution**: CLR→HiFi, Illumina→Nanopore
- **Software version changes**: Major algorithm updates over time
- **Hardware improvements**: Sequencer model changes
- **Protocol evolution**: Wet lab method changes over study period

### Output: Comparison Statistics Table

Save detailed comparison for manuscript reporting:
```python
comparison_df = pd.DataFrame({
    'metric': metrics,
    'mixed_rho': [mixed results],
    'controlled_rho': [controlled results],
    'delta_rho': [differences],
    'mixed_pval': [p-values],
    'controlled_pval': [p-values],
    'interpretation': ['artifact' or 'real trend']
})
comparison_df.to_csv('temporal_trends_comparison.csv')
```

### Real Example: VGP Assembly Quality (2019-2025)

**Gap Density:**
- Mixed: ρ = -0.54 (p < 1e-40) - strong improvement
- HiFi-only: ρ = -0.35 (p < 0.001) - weaker but still significant
- **Interpretation**: Some improvement is technology shift, but real temporal improvement exists within HiFi

**Scaffold N50:**
- Mixed: ρ = +0.15 (p < 0.001)
- HiFi-only: ρ = +0.18 (p < 0.01)
- **Interpretation**: Real temporal trend, not technology artifact

This pattern ensures conclusions about temporal improvements are robust to technology confounding.
