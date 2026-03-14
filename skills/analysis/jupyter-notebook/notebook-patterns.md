# Notebook Patterns: Data Update, Enrichment, and AWS

## Data Update Notebook Pattern

### Use Case: Merging and Enriching Multi-Source Datasets

When maintaining datasets that need periodic updates from multiple sources (e.g., Google Sheets + enriched data + external APIs), use a structured notebook pattern.

**Example scenario**: VGP genome metadata updated monthly from Google Sheets, enriched with AWS QC data.

### Notebook Structure Pattern

**1. Configuration Section** (Cell 1-4)
```python
# Cell 1: Imports
import pandas as pd
import numpy as np
import glob
from datetime import datetime

# Cell 2: Configuration
TODAY = datetime.today().strftime('%Y-%m-%d')

# Google Sheets URL
SHEET_URL = "https://docs.google.com/spreadsheets/d/.../export?format=csv"

# Conflict resolution strategy
CONFLICT_RESOLUTION = "NEW"  # "NEW" or "OLD"

# AWS fetching (disabled by default for safety)
ENABLE_AWS_FETCH = False  # Set to True to fetch from AWS
TEST_MODE = True  # Process only 5 genomes for testing
TEST_SAMPLE_SIZE = 5

# Cell 3: Auto-detect previous file
previous_candidates = glob.glob("Data_table_*_merged.tsv")
previous_candidates = [f for f in previous_candidates if TODAY not in f]
previous_candidates.sort(reverse=True)

if previous_candidates:
    PREVIOUS_FILE = previous_candidates[0]
    print(f"Using previous file: {PREVIOUS_FILE}")
else:
    PREVIOUS_FILE = "Data_raw.tsv"
    print(f"No previous merged file found, using: {PREVIOUS_FILE}")
```

**2. Download New Data** (Cell 5)
```python
# Download latest from Google Sheets
new_file = f"Data_table_{TODAY}.tsv"
df_new = pd.read_csv(SHEET_URL, sep='\t')
df_new.to_csv(new_file, sep='\t', index=False)
print(f"Downloaded {len(df_new)} rows to {new_file}")
```

**3. Create Composite Keys** (Cell 6)
```python
# Create unique composite key for merging
def create_composite_key(df):
    """Create 3-part composite key for genome assemblies."""
    key = (
        df['ToLID'].astype(str) + '|' +
        df['Assembly_version'].astype(str) + '|' +
        df['Pipeline_version'].astype(str)
    )
    return key

df_new['_composite_key'] = create_composite_key(df_new)

# Verify uniqueness
print(f"Total rows: {len(df_new)}")
print(f"Unique keys: {df_new['_composite_key'].nunique()}")
assert df_new['_composite_key'].nunique() == len(df_new), "Composite key not unique!"
```

**4. Resolve Duplicates** (Cell 7)
```python
def resolve_duplicates(df, key_column='_composite_key', date_column='Curated'):
    """Keep latest or most complete record for duplicates."""
    duplicated_keys = df[df.duplicated(key_column, keep=False)][key_column].unique()

    if len(duplicated_keys) == 0:
        print("No duplicates found")
        return df

    rows_to_keep = []
    for key in duplicated_keys:
        dup_group = df[df[key_column] == key].copy()

        # Keep latest by date
        if date_column in dup_group.columns:
            dup_group[date_column] = pd.to_datetime(dup_group[date_column], errors='coerce')
            if dup_group[date_column].notna().any():
                latest = dup_group.loc[dup_group[date_column].idxmax()]
                rows_to_keep.append(latest)
                continue

        # Keep most complete
        dup_group['_completeness'] = dup_group.notna().sum(axis=1)
        most_complete = dup_group.loc[dup_group['_completeness'].idxmax()]
        rows_to_keep.append(most_complete)

    # Combine with non-duplicates
    df_clean = pd.concat([
        df[~df[key_column].isin(duplicated_keys)],
        pd.DataFrame(rows_to_keep)
    ], ignore_index=True)

    print(f"Resolved {len(duplicated_keys)} duplicate keys")
    return df_clean

df_new = resolve_duplicates(df_new)
```

**5. Merge with Previous Enrichments** (Cell 8-10)
```python
# Load previous data
df_previous = pd.read_csv(PREVIOUS_FILE, sep='\t', dtype=str)
df_previous['_composite_key'] = create_composite_key(df_previous)

# Merge on composite key
merged = df_new.merge(df_previous, on='_composite_key', how='left', suffixes=('_new', '_old'))

# Detect conflicts
conflicts = []
for col in base_columns:
    col_new = f"{col}_new"
    col_old = f"{col}_old"

    if col_new in merged.columns and col_old in merged.columns:
        mask = (merged[col_new].notna() & merged[col_old].notna() &
                (merged[col_new] != merged[col_old]))
        if mask.any():
            conflicts.append({
                'column': col,
                'num_conflicts': mask.sum()
            })

print(f"Found {len(conflicts)} columns with conflicts")
```

**6. Conflict Resolution** (Cell 11)
```python
# Resolve conflicts based on strategy
for col in all_columns:
    col_new = f"{col}_new"
    col_old = f"{col}_old"

    if col_new in merged.columns and col_old in merged.columns:
        if CONFLICT_RESOLUTION == "NEW":
            merged[col] = merged[col_new].fillna(merged[col_old])
        else:  # "OLD"
            merged[col] = merged[col_old].fillna(merged[col_new])
    elif col_new in merged.columns:
        merged[col] = merged[col_new]
    elif col_old in merged.columns:
        merged[col] = merged[col_old]

# Remove suffixed columns
df_merged = merged[[col for col in merged.columns
                     if not col.endswith('_new') and not col.endswith('_old')]]
```

**7. Enrichment from External Sources** (Cell 12-15)
```python
# Load unified data source
df_unified = pd.read_csv('vgp_assemblies_unified.csv')

# Column mapping
column_mapping = {
    'Genome_size': 'asm_stats_haploid_number',
    'Heterozygosity': 'heterozygosity',
    'Repeat_content': 'repeat_percent'
}

# Enrich missing data
for idx, row in df_merged.iterrows():
    if pd.isna(row['Genome_size']):
        # Find in unified data
        unified_match = df_unified[df_unified['tolid'] == row['ToLID']]
        if not unified_match.empty:
            for genome_col, unified_col in column_mapping.items():
                if pd.isna(row[genome_col]):
                    value = unified_match.iloc[0][unified_col]

                    # Handle type conversion for string columns
                    if df_merged[genome_col].dtype == 'object':
                        if isinstance(value, (int, float)):
                            value = str(int(value)) if value == int(value) else str(value)

                    df_merged.at[idx, genome_col] = value
```

**8. AWS Fetching (Optional)** (Cell 16-18)
```python
if ENABLE_AWS_FETCH:
    import subprocess

    def fetch_genomescope_data(s3_path, tolid):
        """Fetch GenomeScope summary from AWS."""
        # Try newer pattern first
        patterns = [
            f"{s3_path}evaluation/genomescope/{tolid}_genomescope__Summary.txt",
            f"{s3_path}evaluation/genomescope/{tolid}_Summary.txt"
        ]

        for pattern in patterns:
            cmd = f"aws s3 cp {pattern} - --no-sign-request"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if result.returncode == 0:
                return parse_genomescope(result.stdout)
        return None

    # Apply to genomes with missing data
    sample = df_merged.head(TEST_SAMPLE_SIZE) if TEST_MODE else df_merged

    for idx, row in sample.iterrows():
        if pd.isna(row['Genome_size']) and row['Draft_assembly_folder']:
            data = fetch_genomescope_data(row['Draft_assembly_folder'], row['ToLID'])
            if data:
                df_merged.at[idx, 'Genome_size'] = data.get('genome_size')
                df_merged.at[idx, 'Heterozygosity'] = data.get('heterozygosity')
```

**9. Save Results** (Cell 19)
```python
# Remove composite key (temporary working column)
df_merged = df_merged.drop(columns=['_composite_key'])

# Save merged result
output_file = f"Data_table_{TODAY}_merged.tsv"
df_merged.to_csv(output_file, sep='\t', index=False)
print(f"Saved {len(df_merged)} rows to {output_file}")
```

**10. Summary Report** (Cell 20)
```python
print("=== UPDATE SUMMARY ===")
print(f"New rows: {len(df_new)}")
print(f"Previous rows: {len(df_previous)}")
print(f"Merged rows: {len(df_merged)}")
print(f"Conflicts resolved: {len(conflicts)}")
print(f"Conflict strategy: {CONFLICT_RESOLUTION}")
print(f"Enrichment sources: {'AWS + unified CSV' if ENABLE_AWS_FETCH else 'unified CSV only'}")
```

### Key Design Principles

1. **Auto-detection**: Previous file detection prevents hardcoded paths
2. **Configuration section**: All settings in one place at top
3. **Safety defaults**: AWS disabled, test mode enabled by default
4. **Composite keys**: Handle complex uniqueness requirements
5. **Conflict reporting**: Show what changed, let user decide
6. **Type safety**: Handle string/numeric conversions properly
7. **Progressive enrichment**: Multiple sources tried in order
8. **Validation**: Assertions check assumptions

### Benefits

- **Reproducible**: Same structure for each update
- **Safe**: Test mode, disabled AWS by default
- **Transparent**: Clear reports of what changed
- **Flexible**: Easy to add new enrichment sources
- **Maintainable**: Each step in separate cell
- **Documented**: Configuration + summary in one place

### When to Use This Pattern

- Regular data updates from external sources
- Merging datasets with complex keys
- Preserving manually enriched data
- Multi-source enrichment workflows
- Data quality validation needs

### Companion Manual

Pair this notebook with a markdown manual documenting:
- When to run the notebook (monthly, quarterly)
- What each configuration option does
- Troubleshooting common errors
- Examples of running the workflow
- Expected outputs and verification steps

See VGP `DATA_UPDATE_MANUAL.md` for a complete example.

## Data Enrichment Notebook Pattern

### Two-Stage File Workflow

When building notebooks that enrich/augment existing data:

**Pattern**: Input file -> Processing -> Output file with distinct naming
- Input: `data_[date]_merged.tsv` (or similar base name)
- Output: `data_[date]_enriched.tsv` (or similar enriched name)

**Anti-pattern**: In-place modification (`OUTPUT_FILE = INPUT_FILE`)
- Overwrites source data
- Breaks pipeline traceability
- Makes it hard to re-run enrichment

### Implementation

```python
# Configuration cell - smart output file detection
if '_enriched' in INPUT_FILE:
    OUTPUT_FILE = INPUT_FILE  # Continue enriching existing file
else:
    # Extract date from input filename
    import re
    date_match = re.search(r'(\d{8})', INPUT_FILE)
    file_date = date_match.group(1) if date_match else datetime.now().strftime("%Y%m%d")

    OUTPUT_FILE = f"Data_table_{file_date}_enriched.tsv"
    print(f"Mode: New enrichment (creating {OUTPUT_FILE})")
```

### Column Addition Pattern

When enriching with new data fields:

```python
# Add columns if they don't exist (idempotent)
new_columns = {
    'Column Name': float,  # or str, int, etc.
    'Another Column': str
}

columns_added = []
for col, dtype in new_columns.items():
    if col not in df.columns:
        if dtype == float:
            df[col] = np.nan
        else:
            df[col] = None
        columns_added.append(col)

if columns_added:
    print(f"Added {len(columns_added)} columns: {', '.join(columns_added)}")
```

**Why this matters**:
- Makes notebooks safe to re-run
- Works whether columns exist or not
- Clear reporting of what was added

### Fetching and Saving Pattern

When fetching external data (APIs, S3, etc.):

**Anti-pattern**: Fetch data, print results, don't save
```python
data = fetch_from_external_source()
if data:
    print(f"Found data: {data['value']}")  # Only prints!
    enrichments['source'] += 1
```

**Correct pattern**: Fetch AND save to DataFrame
```python
data = fetch_from_external_source()
if data:
    # Save to DataFrame
    if 'value' in data and pd.isna(row['Column Name']):
        df.at[idx, 'Column Name'] = data['value']
        print(f"Saved: {data['value']}")
    enrichments['source'] += 1
```

### Enrichment Tracking

Track what was actually saved vs. what was fetched:

```python
# Good: Track by genomes enriched, not just data found
aws_enrichments = {
    'genomescope_fields': 0,    # Count individual fields filled
    'busco_genomes': 0,          # Count genomes with data saved
    'merqury_genomes': 0
}

# In fetch loop
if data_fetched:
    df.at[idx, 'column'] = data['value']  # SAVE IT
    aws_enrichments['busco_genomes'] += 1  # Track it was saved
```

## AWS Enrichment Notebook Pattern (GenomeArk)

When creating notebooks to enrich existing CSV datasets with QC data from AWS S3 (GenomeArk):

### Notebook Structure for AWS Enrichment

**1. Configuration Cell (Safety Defaults)**
```python
import pandas as pd
import subprocess
import re

# File paths
INPUT_FILE = "data/vgp_assemblies_unified_corrected.csv"
OUTPUT_FILE = "data/vgp_assemblies_unified_corrected_enriched.csv"

# AWS fetching (DISABLED by default)
ENABLE_AWS_FETCH = False  # Set to True to fetch from AWS
TEST_MODE = True          # Process only sample for testing
TEST_SAMPLE_SIZE = 5
```

**Why safety defaults:**
- Prevents accidental full AWS fetch (expensive, time-consuming)
- Forces user to explicitly enable fetching
- Test mode allows validation with small sample first

**2. Add New Columns Cell**
```python
# Add new columns if they don't exist (idempotent)
new_columns = {
    'busco_completeness': float,
    'busco_lineage': str,
    'merqury_qv': float
}

columns_added = []
for col, dtype in new_columns.items():
    if col not in df.columns:
        if dtype == float:
            df[col] = float('nan')
        else:
            df[col] = None
        columns_added.append(col)

if columns_added:
    print(f"Added {len(columns_added)} new columns: {', '.join(columns_added)}")
else:
    print("All columns already exist")
```

**3. S3 Path Normalization Function**
```python
def normalize_s3_path(s3_path):
    """Normalize S3 path for GenomeArk."""
    if not s3_path or pd.isna(s3_path):
        return None

    s3_path = s3_path.strip()

    # Fix case sensitivity: hic -> HiC
    s3_path = s3_path.replace('/assembly_vgp_hic_2.0/', '/assembly_vgp_HiC_2.0/')

    # Ensure trailing slash
    if not s3_path.endswith('/'):
        s3_path += '/'

    return s3_path
```

**4. AWS Fetching Functions with Multiple Patterns**
```python
def fetch_genomescope_data(s3_path, tolid):
    """Fetch GenomeScope summary from GenomeArk S3.

    Tries multiple filename patterns due to historical variations.
    """
    if not s3_path:
        return None

    # Try multiple GenomeScope filename patterns
    patterns = [
        f'evaluation/genomescope/{tolid}_genomescope__Summary.txt',  # Double underscore
        f'evaluation/genomescope/{tolid}_genomescope_Summary.txt',   # Single underscore
        f'evaluation/genomescope/{tolid}_Summary.txt',               # No prefix
    ]

    for pattern in patterns:
        full_path = f"{s3_path}{pattern}"
        cmd = ['aws', 's3', 'cp', full_path, '-', '--no-sign-request']

        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            # Parse GenomeScope format
            data = parse_genomescope(result.stdout)
            if data:
                data['tool'] = 'genomescope'
                return data

    return None

def fetch_busco_data(s3_path):
    """Fetch BUSCO completeness from GenomeArk S3."""
    if not s3_path:
        return None

    # List subdirectories in busco/
    busco_base = f"{s3_path}evaluation/busco/"
    list_cmd = ['aws', 's3', 'ls', busco_base, '--no-sign-request']

    result = subprocess.run(list_cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return None

    # Find subdirectories (lineage-specific)
    subdirs = [line.split()[-1] for line in result.stdout.split('\n')
               if 'PRE' in line]

    # Try each subdirectory for short_summary*.txt
    for subdir in subdirs:
        summary_path = f"{busco_base}{subdir}"
        ls_cmd = ['aws', 's3', 'ls', summary_path, '--recursive', '--no-sign-request']

        ls_result = subprocess.run(ls_cmd, capture_output=True, text=True)

        # Find short_summary file
        for line in ls_result.stdout.split('\n'):
            if 'short_summary' in line and line.endswith('.txt'):
                file_path = 's3://' + line.split()[-1]

                # Fetch and parse
                fetch_cmd = ['aws', 's3', 'cp', file_path, '-', '--no-sign-request']
                fetch_result = subprocess.run(fetch_cmd, capture_output=True, text=True)

                if fetch_result.returncode == 0:
                    return parse_busco(fetch_result.stdout)

    return None

def fetch_merqury_data(s3_path, tolid):
    """Fetch Merqury QV from GenomeArk S3."""
    if not s3_path:
        return None

    qv_path = f"{s3_path}evaluation/merqury/{tolid}.qv"
    cmd = ['aws', 's3', 'cp', qv_path, '-', '--no-sign-request']

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        return parse_merqury(result.stdout)

    return None
```

**5. Main Enrichment Loop with Tracking**
```python
if ENABLE_AWS_FETCH:
    print("AWS FETCH ENABLED - This will take time and bandwidth")

    sample = df.head(TEST_SAMPLE_SIZE) if TEST_MODE else df

    # Track enrichments
    enrichments = {
        'genomescope': 0,
        'busco': 0,
        'merqury': 0
    }

    for idx, row in sample.iterrows():
        tolid = row['tolid']
        s3_path = normalize_s3_path(row.get('s3_path'))

        if not s3_path:
            continue

        print(f"\nProcessing {tolid} ({idx+1}/{len(sample)})...")

        # Fetch GenomeScope (if missing)
        if pd.isna(row['genome_size_genomescope']):
            gs_data = fetch_genomescope_data(s3_path, tolid)
            if gs_data:
                df.at[idx, 'genome_size_genomescope'] = gs_data.get('genome_size')
                df.at[idx, 'heterozygosity_percent'] = gs_data.get('heterozygosity')
                enrichments['genomescope'] += 1
                print(f"  GenomeScope: {gs_data.get('genome_size')} bp")

        # Fetch BUSCO (if missing)
        if pd.isna(row['busco_completeness']):
            busco_data = fetch_busco_data(s3_path)
            if busco_data:
                df.at[idx, 'busco_completeness'] = busco_data.get('completeness')
                df.at[idx, 'busco_lineage'] = busco_data.get('lineage')
                enrichments['busco'] += 1
                print(f"  BUSCO: {busco_data.get('completeness')}% ({busco_data.get('lineage')})")

        # Fetch Merqury QV (if missing)
        if pd.isna(row['merqury_qv']):
            merqury_data = fetch_merqury_data(s3_path, tolid)
            if merqury_data:
                df.at[idx, 'merqury_qv'] = merqury_data.get('qv')
                enrichments['merqury'] += 1
                print(f"  Merqury: QV={merqury_data.get('qv')}")

    # Report enrichment summary
    print("\n=== ENRICHMENT SUMMARY ===")
    print(f"Genomes processed: {len(sample)}")
    print(f"GenomeScope enriched: {enrichments['genomescope']}")
    print(f"BUSCO enriched: {enrichments['busco']}")
    print(f"Merqury enriched: {enrichments['merqury']}")
else:
    print("AWS FETCH DISABLED - Set ENABLE_AWS_FETCH=True to fetch data")
```

**6. Save Output Cell**
```python
# Save enriched dataset
df.to_csv(OUTPUT_FILE, index=False)
print(f"\nSaved enriched dataset: {OUTPUT_FILE}")
print(f"  Size: {len(df)} assemblies, {len(df.columns)} columns")

# Calculate coverage
for col in ['busco_completeness', 'merqury_qv']:
    coverage = df[col].notna().sum()
    pct = 100 * coverage / len(df)
    print(f"  {col}: {coverage}/{len(df)} ({pct:.1f}%)")
```

### Key Design Patterns

**Safety First:**
- `ENABLE_AWS_FETCH = False` by default
- `TEST_MODE = True` by default
- User must consciously enable production mode

**Idempotent Column Addition:**
- Adding columns checks if they exist first
- Safe to re-run notebook multiple times
- No errors if columns already present

**Multiple Filename Patterns:**
- GenomeScope has 3 different naming conventions over time
- Try all patterns until one succeeds
- Handles historical data inconsistencies

**S3 Path Normalization:**
- Fix case sensitivity issues (hic -> HiC)
- Ensure trailing slashes
- Handle missing/null paths gracefully

**Conditional Fetching:**
- Only fetch if field is missing (`pd.isna()`)
- Preserves manually curated data
- Allows incremental enrichment

**Progress Tracking:**
- Print progress for each genome
- Track successful enrichments by source
- Report final coverage statistics

### Benefits

1. **Safe**: Won't accidentally fetch full dataset
2. **Testable**: Validate with 5 samples before full run
3. **Resumable**: Can stop and restart without losing progress
4. **Efficient**: Only fetches missing data
5. **Robust**: Handles multiple filename patterns and path variations
6. **Transparent**: Clear reporting of what was fetched

### Common Usage Pattern

```python
# First run: Test mode
ENABLE_AWS_FETCH = True
TEST_MODE = True
TEST_SAMPLE_SIZE = 5
# Run notebook -> verify 5 samples work correctly

# Second run: Production mode
ENABLE_AWS_FETCH = True
TEST_MODE = False
# Run notebook -> fetch all missing data (2-3 hours)

# Subsequent runs: Skip AWS
ENABLE_AWS_FETCH = False
# Notebook loads enriched data without re-fetching
```

### Expected Timing

- **Test mode (5 samples)**: 30-60 seconds
- **Full enrichment (700 samples)**: 2-3 hours
- **Reason**: AWS S3 API rate limits, network latency

### Coverage Expectations

For VGP GenomeArk data:
- GenomeScope: 40-60% (older tool, not all assemblies)
- BUSCO: 20-40% (compute-intensive, selective)
- Merqury: 15-30% (newer tool, recent assemblies)

Coverage varies based on assembly age and QC pipeline version.

### Configuration Cell Reporting

Configuration cells should clearly report their intended behavior:

```python
# Good: Clear mode indication
if '_enriched' in INPUT_FILE:
    OUTPUT_FILE = INPUT_FILE
    print(f"Mode: Continue enrichment")
else:
    OUTPUT_FILE = f"Data_{date}_enriched.tsv"
    print(f"Mode: New enrichment")

print(f"\nConfiguration:")
print(f"  Input:  {INPUT_FILE}")
print(f"  Output: {OUTPUT_FILE}")
print(f"  Test mode: {'ON (3 samples)' if TEST_MODE else 'OFF (all data)'}")
```

**Benefits**:
- User immediately knows what notebook will do
- Prevents accidental overwrites
- Makes test vs. production runs obvious

## Data Enrichment Pattern (Linking External Metadata)

When linking external metadata with analysis data:

```python
# Cell 6: Load genome metadata
import csv
genome_data = []
with open('genome_metadata.tsv') as f:
    reader = csv.DictReader(f, delimiter='\t')
    genome_data = list(reader)

genome_lookup = {}
for row in genome_data:
    species_id = row['species_id']
    if species_id not in genome_lookup:
        genome_lookup[species_id] = []
    genome_lookup[species_id].append(row)

# Cell 7: Enrich workflow data with genome characteristics
for inv in data:
    species_id = inv.get('species_id')

    if species_id and species_id in genome_lookup:
        genome_info = genome_lookup[species_id][0]

        # Add genome characteristics
        inv['genome_size'] = genome_info.get('Genome size', '')
        inv['heterozygosity'] = genome_info.get('Heterozygosity', '')
        # ... other characteristics
    else:
        # Set to None for missing data
        inv['genome_size'] = None
        inv['heterozygosity'] = None

# Create filtered dataset
data_with_species = [inv for inv in data if inv.get('species_id') and inv.get('genome_size')]
```

## Debugging Data Availability

Before creating correlation plots, verify data overlap:

```python
# Check how many entities have both metrics
species_with_metric_a = set(inv.get('species_id') for inv in data
                            if inv.get('metric_a'))
species_with_metric_b = set(inv.get('species_id') for inv in data
                            if inv.get('metric_b'))

overlap = species_with_metric_a.intersection(species_with_metric_b)
print(f"Species with both metrics: {len(overlap)}")

if len(overlap) < 10:
    print("Warning: Limited data for correlation analysis")
    print(f"  Metric A: {len(species_with_metric_a)} species")
    print(f"  Metric B: {len(species_with_metric_b)} species")
    print(f"  Overlap: {len(overlap)} species")
```
