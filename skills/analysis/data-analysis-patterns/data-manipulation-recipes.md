# Data Manipulation Recipes

Detailed patterns and code examples for data aggregation, composite keys, feature separation, and type conversion.

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
# BAD: Approximation loses critical information
new_cat1 = old_cat1  # Only 2 terminal with 0 interstitial
new_cat2 = old_cat2  # Only 1 terminal with 0 interstitial
new_cat3 = old_cat0 + old_cat3  # But old_cat3 includes 0, 1, AND 2 terminal!
# Result: Inaccurate categorization
```

**Correct approach** - Recalculate from raw data:
```python
# GOOD: Recalculate from scaffold-level data
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
   - Example: Per-scaffold -> Per-chromosome -> Per-species

4. **Publication accuracy is critical**
   - Approximations acceptable for exploration, not for figures

5. **The mapping is ambiguous or lossy**
   - If you can't confidently map old->new without information loss, recalculate

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
- We approximate by combining cat0 + cat3 -> new cat3
- Actual values may differ by ~5-10% from true recalculation
- Use for exploratory analysis only
"""
```

### Real-World Example: VGP Telomere Analysis

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

---

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

---

## Separating Conflated Features

### Pattern: When One Metric Combines Multiple Independent Features

**Example**: Telomere categories that mixed terminal AND interstitial presence

**Old (conflated)**:
- Cat 1: 2 terminal, 0 interstitial
- Cat 2: 1 terminal, 0 interstitial
- Cat 3: Has interstitial (could have 0, 1, OR 2 terminal!) - Conflated
- Cat 4: 0 terminal, 0 interstitial

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

---

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

# FAILS: Trying to assign int to string column
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
# Solution: Convert to string
unified_value = 4077481159
if isinstance(unified_value, (int, np.integer)):
    unified_value = str(unified_value)
df.loc[idx, 'Genome_size'] = unified_value  # "4077481159"
```

**Pattern 2: Float percentages in string columns**
```python
# Source: float64 (1.47)
# Target: object column
# Solution: Convert to string, optionally format
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
