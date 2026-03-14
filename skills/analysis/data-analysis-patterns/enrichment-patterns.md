# Data Enrichment Patterns

Patterns for enriching datasets from AWS S3, external APIs, and multi-source workflows.

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
    print(f"Found enriched genome table from today: {INPUT_FILE}")
    print(f"  (Continuing enrichment of today's data)")
else:
    # Check for merged table with current date
    merged_today = f"Genome_table_{TODAY}_merged.tsv"

    if os.path.exists(merged_today):
        INPUT_FILE = merged_today
        print(f"Found merged genome table from today: {INPUT_FILE}")
    else:
        # Fall back to latest merged or raw data
        merged_files = glob.glob("Genome_table_*_merged.tsv")
        merged_files.sort(reverse=True)

        if merged_files:
            INPUT_FILE = merged_files[0]
            print(f"Using latest merged file: {INPUT_FILE}")
        else:
            INPUT_FILE = "VGP_VGL_genomes - raw data.tsv"
            print(f"Using raw data: {INPUT_FILE}")
```

**Priority Order**: `enriched_today > merged_today > latest_merged > raw`

**Benefits**:
- **In-place enrichment**: Updating same file prevents version proliferation
- **Idempotent**: Re-running adds missing data without duplicates
- **Recovery**: Can continue after interruption
- **Clear state**: User knows exactly what data is being used

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
    print(f"Added {len(columns_added)} columns: {', '.join(columns_added)}")
```

**Why idempotent operations matter**:
- Notebooks can be re-run without errors
- Works for both initial runs and continuation of enrichment
- Clear feedback on what changed
- Supports incremental data updates

**Anti-pattern**:
```python
# Fails on re-run if column exists
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

---

## Data Consolidation and Enrichment Workflows

### Pattern: Consolidate -> Enrich -> Verify

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

---

## Enrichment Pattern: Extracting Accurate Dates from Public Repositories

**Problem**: Public database release dates may not reflect actual completion dates due to curation/submission delays.

**Example**: NCBI `release_date` can lag behind actual assembly completion by months to years, affecting temporal trend analysis accuracy.

**Solution**: Extract completion dates from repository filenames or metadata.

### GenomeArk S3 Assembly Date Extraction

GenomeArk filenames contain YYYYMMDD timestamps indicating when assemblies were created:

```
s3://genomeark/species/Loxodonta_africana/mLoxAfr1/assembly_curated/
  mLoxAfr1.HiC.hap1.20221209.fasta.gz  # Assembly completed 2022-12-09
```

**Implementation Strategy**:

```python
def extract_assembly_year(tolid, scientific_name):
    """Extract assembly year from GenomeArk S3 filenames"""
    # 1. Find S3 path (try HiC, standard, hic assembly types)
    s3_path = find_s3_path(tolid, scientific_name)
    if not s3_path:
        return None

    # 2. List files recursively, excluding _curated directories
    # (curated versions have later dates)
    files = aws_s3_ls_recursive(s3_path, exclude_patterns=['_curated'])

    # 3. Extract dates matching YYYYMMDD pattern
    import re
    date_pattern = r'\.(\d{8})\.'
    dates = []
    for filename in files:
        match = re.search(date_pattern, filename)
        if match:
            datestr = match.group(1)
            dates.append(datestr)

    # 4. Validate dates (2000-2030 range, valid month/day)
    valid_dates = []
    for d in dates:
        year, month, day = int(d[:4]), int(d[4:6]), int(d[6:8])
        if 2000 <= year <= 2030 and 1 <= month <= 12 and 1 <= day <= 31:
            valid_dates.append(d)

    # 5. Return most recent year found
    if valid_dates:
        most_recent = max(valid_dates)
        return int(most_recent[:4])
    return None
```

**Expected Coverage**:
- Newer assemblies (2020+): 80-90% coverage
- Older assemblies (pre-2020): 50-60% coverage
- Overall: 60-80% expected

**Test Results Showing Delays**:
- mLoxAfr1: Assembly 2022, NCBI release 2023 (1-year delay)
- mLemCat1: Assembly 2021, NCBI release 2021 (same year)
- mRhyPet1: Assembly 2024, NCBI release 2024 (same year)

**Batch Processing**:

```python
# Process all assemblies in dataset
for idx, row in df.iterrows():
    assembly_year = extract_assembly_year(row['tolid'], row['scientific_name'])
    df.at[idx, 'assembly_year'] = assembly_year

# Calculate coverage
coverage = (df['assembly_year'].notna().sum() / len(df)) * 100
print(f"Assembly year coverage: {coverage:.1f}%")
```

**Integration Workflow**:

1. **Create temporary enriched file**:
   ```python
   df_enriched = df.copy()
   # ... run extraction ...
   df_enriched.to_csv('data/assemblies_with_assembly_year.csv')
   ```

2. **Verify results**:
   ```python
   # Compare release_year vs assembly_year
   df_enriched['year_diff'] = df_enriched['release_year'] - df_enriched['assembly_year']
   delays = df_enriched[df_enriched['year_diff'] > 0]
   print(f"{len(delays)} assemblies have release delays")
   ```

3. **Merge into main dataset**:
   ```python
   # Add assembly_year column to existing datasets
   df_main['assembly_year'] = df_enriched['assembly_year']
   df_main.to_csv('data/assemblies_unified_corrected.csv', index=False)
   ```

4. **Update temporal analyses**:
   ```python
   # Use assembly_year instead of release_year for temporal trends
   temporal_df = df[df['assembly_year'].notna()]
   # ... analyze trends with actual assembly dates ...
   ```

**Documentation**:
- Create `data/ASSEMBLY_YEAR_EXTRACTION.md` documenting:
  - Rationale (why release_date is insufficient)
  - Strategy (GenomeArk S3 filename parsing)
  - Implementation (script, algorithm)
  - Expected coverage (60-80%)
  - Test results (examples showing delays)

**Real Example**: Session extracted assembly years for 716 VGP assemblies from GenomeArk S3, achieving 24% coverage in initial extraction phase (172/716 assemblies), with documentation showing 1-year delays for some assemblies.

---

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

**Common Mistake**: Trying to merge new columns into existing subset leads to mismatches

**Correct Approach**: Always rebuild from enriched master using original filter
