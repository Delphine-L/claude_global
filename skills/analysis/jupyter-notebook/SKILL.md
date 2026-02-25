---
name: jupyter-notebook-analysis
description: Best practices for creating comprehensive Jupyter notebook data analyses with statistical rigor, outlier handling, and publication-quality visualizations. Includes Claude API image size helpers.
version: 1.1.0
---

# Jupyter Notebook Analysis Patterns

Expert knowledge for creating comprehensive, statistically rigorous Jupyter notebook analyses.

## When to Use This Skill

- Creating multi-cell Jupyter notebooks for data analysis
- Adding correlation analyses with statistical testing
- Implementing outlier removal strategies
- Building series of related visualizations (10+ figures)
- Analyzing large datasets with multiple characteristics
- Building data update/enrichment notebooks with multi-source merging
- Generating figures for sharing with Claude or other AI tools

## Important: Image Size Constraints

**When generating images to share with Claude**, images must not exceed **8000 pixels** in either dimension. Add this helper to your notebook imports:

```python
# Standard imports with Claude size checking
import matplotlib.pyplot as plt
import seaborn as sns
from PIL import Image

MAX_CLAUDE_DIM = 7999  # Claude API limit with safety margin

def save_figure(filename, dpi=300, **kwargs):
    """Save figure with automatic Claude size constraint check."""
    plt.savefig(filename, dpi=dpi, bbox_inches='tight', **kwargs)

    # Verify and auto-resize if needed
    img = Image.open(filename)
    if img.width > MAX_CLAUDE_DIM or img.height > MAX_CLAUDE_DIM:
        print(f"⚠️  Auto-resizing {filename} for Claude compatibility")
        print(f"   Original: {img.width}x{img.height}")
        img.thumbnail((MAX_CLAUDE_DIM, MAX_CLAUDE_DIM), Image.Resampling.LANCZOS)
        img.save(filename)
        print(f"   Resized: {img.width}x{img.height}")
    else:
        print(f"✓ {filename}: {img.width}x{img.height}")

# Safe figure sizes for Claude (300 DPI)
FIG_SIZES = {
    'small': (7, 5),       # 2100x1500 px
    'medium': (12, 9),     # 3600x2700 px
    'large': (20, 15),     # 6000x4500 px
    'max': (26, 26),       # 7800x7800 px - maximum safe
}

# Use in notebook
fig, ax = plt.subplots(figsize=FIG_SIZES['medium'])
# ... plotting code ...
save_figure('figure.png')
```

**For complete image size guidance**, see the **data-visualization** skill.

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

**Pattern**: Input file → Processing → Output file with distinct naming
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
    print(f"📝 Mode: New enrichment (creating {OUTPUT_FILE})")
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
    print(f"✓ Added {len(columns_added)} columns: {', '.join(columns_added)}")
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
    print(f"Found data: {data['value']}")  # ❌ Only prints!
    enrichments['source'] += 1
```

**Correct pattern**: Fetch AND save to DataFrame
```python
data = fetch_from_external_source()
if data:
    # Save to DataFrame
    if 'value' in data and pd.isna(row['Column Name']):
        df.at[idx, 'Column Name'] = data['value']
        print(f"✓ Saved: {data['value']}")
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
    print(f"✓ Added {len(columns_added)} new columns: {', '.join(columns_added)}")
else:
    print("✓ All columns already exist")
```

**3. S3 Path Normalization Function**
```python
def normalize_s3_path(s3_path):
    """Normalize S3 path for GenomeArk."""
    if not s3_path or pd.isna(s3_path):
        return None

    s3_path = s3_path.strip()

    # Fix case sensitivity: hic → HiC
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
    print("⚠️ AWS FETCH ENABLED - This will take time and bandwidth")

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
                print(f"  ✓ GenomeScope: {gs_data.get('genome_size')} bp")

        # Fetch BUSCO (if missing)
        if pd.isna(row['busco_completeness']):
            busco_data = fetch_busco_data(s3_path)
            if busco_data:
                df.at[idx, 'busco_completeness'] = busco_data.get('completeness')
                df.at[idx, 'busco_lineage'] = busco_data.get('lineage')
                enrichments['busco'] += 1
                print(f"  ✓ BUSCO: {busco_data.get('completeness')}% ({busco_data.get('lineage')})")

        # Fetch Merqury QV (if missing)
        if pd.isna(row['merqury_qv']):
            merqury_data = fetch_merqury_data(s3_path, tolid)
            if merqury_data:
                df.at[idx, 'merqury_qv'] = merqury_data.get('qv')
                enrichments['merqury'] += 1
                print(f"  ✓ Merqury: QV={merqury_data.get('qv')}")

    # Report enrichment summary
    print("\n=== ENRICHMENT SUMMARY ===")
    print(f"Genomes processed: {len(sample)}")
    print(f"GenomeScope enriched: {enrichments['genomescope']}")
    print(f"BUSCO enriched: {enrichments['busco']}")
    print(f"Merqury enriched: {enrichments['merqury']}")
else:
    print("⚠️ AWS FETCH DISABLED - Set ENABLE_AWS_FETCH=True to fetch data")
```

**6. Save Output Cell**
```python
# Save enriched dataset
df.to_csv(OUTPUT_FILE, index=False)
print(f"\n✓ Saved enriched dataset: {OUTPUT_FILE}")
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
- Fix case sensitivity issues (hic → HiC)
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
# Run notebook → verify 5 samples work correctly

# Second run: Production mode
ENABLE_AWS_FETCH = True
TEST_MODE = False
# Run notebook → fetch all missing data (2-3 hours)

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
    print(f"📝 Mode: Continue enrichment")
else:
    OUTPUT_FILE = f"Data_{date}_enriched.tsv"
    print(f"📝 Mode: New enrichment")

print(f"\nConfiguration:")
print(f"  Input:  {INPUT_FILE}")
print(f"  Output: {OUTPUT_FILE}")
print(f"  Test mode: {'ON (3 samples)' if TEST_MODE else 'OFF (all data)'}")
```

**Benefits**:
- User immediately knows what notebook will do
- Prevents accidental overwrites
- Makes test vs. production runs obvious

## Direct Notebook Editing with NotebookEdit Tool

**IMPORTANT**: You can edit Jupyter notebooks directly using the NotebookEdit tool without writing Python scripts or using command-line JSON manipulation.

### NotebookEdit Tool Overview

The NotebookEdit tool allows direct manipulation of `.ipynb` files with three modes:

**1. Replace mode** (default): Replace entire cell content
```python
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",
    cell_type="markdown",  # or "code"
    new_source="New content for this cell"
)
```

**2. Insert mode**: Add new cells
```python
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",  # Insert AFTER this cell
    edit_mode="insert",
    cell_type="markdown",
    new_source="Content for new cell"
)
```

**3. Delete mode**: Remove cells
```python
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",
    edit_mode="delete",
    new_source=""  # Required but ignored
)
```

### When to Use NotebookEdit vs Python Scripts

**Use NotebookEdit when:**
- ✅ Updating existing cell content (figure captions, analysis text)
- ✅ Adding single new cells (headers, display code, descriptions)
- ✅ Removing specific cells
- ✅ Making targeted changes to notebook structure
- ✅ Synchronizing notebook documentation with code changes

**Use Python scripts when:**
- ❌ Bulk operations (reordering many cells, restructuring entire notebook)
- ❌ Complex conditional logic based on cell content
- ❌ Programmatic generation of many cells at once
- ❌ Cell reordering requires precise index manipulation

### Finding Cell IDs

**Method 1: Bash with jq**
```bash
# List all cells with IDs
cat notebook.ipynb | jq '.cells[] | {id: .id, type: .cell_type, preview: .source[:2]}'

# Find specific content
cat notebook.ipynb | jq '.cells[] | select(.source[] | contains("Figure 10")) | .id'
```

**Method 2: Python script**
```python
import json
with open('notebook.ipynb') as f:
    nb = json.load(f)
for i, cell in enumerate(nb['cells']):
    src = ''.join(cell.get('source', []))[:60]
    print(f"{i}: {cell.get('id')}: {cell['cell_type']}: {src}...")
```

**Method 3: Insert without cell_id**
```python
# Insert at end of notebook
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    edit_mode="insert",
    cell_type="markdown",
    new_source="New section at end"
)
```

### Common Workflow: Updating Figure Documentation

When you regenerate figures with code changes:

1. **Update figure generation script**
2. **Regenerate figure file**
3. **Update notebook caption** with NotebookEdit:
   ```python
   NotebookEdit(
       notebook_path="Analysis.ipynb",
       cell_id="cell-26",  # Caption cell after figure display
       cell_type="markdown",
       new_source="**Figure 10. Updated caption...** [description]"
   )
   ```

### Common Workflow: Adding New Figure Section

When adding a new figure to existing notebook:

```python
# 1. Add section header
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-25",  # After previous figure
    edit_mode="insert",
    cell_type="markdown",
    new_source="---\n\n## Figure 10: New Analysis\n\n### Description"
)

# 2. Add display code
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-26",  # After header just created
    edit_mode="insert",
    cell_type="code",
    new_source="display(Image(filename=str(FIG_DIR / '10_analysis.png')))"
)

# 3. Add caption and analysis
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-27",  # After display code
    edit_mode="insert",
    cell_type="markdown",
    new_source="**Figure 10. Caption...** Analysis text..."
)
```

### Verifying Edits

Always check notebook structure after edits:
```bash
# Check cell count
cat notebook.ipynb | jq '.cells | length'

# Check specific section
cat notebook.ipynb | jq '.cells[25:30][] | {id: .id, type: .cell_type}'

# Preview content
cat notebook.ipynb | python3 -c "
import json, sys
nb = json.load(sys.stdin)
for i, c in enumerate(nb['cells'][25:30]):
    src = ''.join(c.get('source', []))[:80]
    print(f'{i+25}: {c.get(\"cell_type\")}: {src}...')
"
```

### Advantages of NotebookEdit

- **No temporary files** needed
- **No JSON manipulation** required
- **Preserves formatting** and cell metadata
- **Atomic operations** (single tool call per edit)
- **Clear intent** (replace/insert/delete modes)
- **Error handling** built-in

### Common Pitfalls

❌ **Don't use Edit tool on .ipynb files** - It treats them as text, corrupting JSON structure
```python
# WRONG - corrupts notebook
Edit(
    file_path="notebook.ipynb",
    old_string="old text",
    new_string="new text"
)
```

✅ **Use NotebookEdit for notebooks**
```python
# CORRECT
NotebookEdit(
    notebook_path="notebook.ipynb",
    cell_id="cell-10",
    new_source="new cell content"
)
```

❌ **Don't forget cell_type when inserting**
```python
# WRONG - missing cell_type
NotebookEdit(
    notebook_path="notebook.ipynb",
    edit_mode="insert",
    new_source="content"
)
```

✅ **Always specify cell_type for insert**
```python
# CORRECT
NotebookEdit(
    notebook_path="notebook.ipynb",
    edit_mode="insert",
    cell_type="markdown",
    new_source="content"
)
```

## Updating Multiple Related Cells

### Systematic Metric Changes Across Notebook

When replacing a metric throughout an analysis notebook (e.g., changing from absolute counts to ratios), update in dependency order to prevent errors.

**Update Order**:
1. **Data loading cell**: Add calculation for new metric
2. **Metric definition cell**: Update the metrics list
3. **All plotting cells**: Use the new metric automatically via the metrics list

**Example: Switching from Absolute to Ratio Metric**

```python
# Step 1: Data loading cell - add calculation
df = pd.read_csv('data.csv')
df['telomere_ratio'] = df['telomere_count'] / df['expected_chromosomes']

# Step 2: Metrics definition cell - update list
metrics = [
    ('scaffold_n50', 'Scaffold N50 (bp)', True),
    ('telomere_ratio', 'Telomere Ratio (Found/Expected)', True),  # Changed
    ('chr_percentage', 'Chromosome Assignment (%)', True),
]

# Step 3: Plotting cells automatically use new metric via loop
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
axes = axes.flatten()

for idx, (metric, label, higher_better) in enumerate(metrics):
    ax = axes[idx]
    # Plot using metric, label from the list
    ax.scatter(df['year'], df[metric])
    ax.set_ylabel(label)
    ax.set_title(label, fontweight='bold')
```

**Benefits of This Approach**:
- **Single source of truth**: Metrics list defines all metrics used
- **Update once, applies everywhere**: Change metric list, all plots update
- **Prevents inconsistencies**: Can't accidentally miss updating one plot
- **Easy to add/remove metrics**: Just edit the list

**Common Pattern: Loop-Based Multi-Panel Figures**

```python
# Define metrics once
metrics = [
    ('metric_name', 'Display Label', higher_is_better),
    # ... add more
]

# All plots use the same structure
fig, axes = plt.subplots(2, 3, figsize=(14, 9))
for idx, (metric, label, higher_better) in enumerate(metrics):
    ax = axes.flatten()[idx]

    # Plotting logic
    for category in categories:
        data = df[df['category'] == category]
        ax.scatter(data['x'], data[metric], label=category)

    ax.set_ylabel(label)
    ax.set_title(label, fontweight='bold')
```

**When to Use This Pattern**:
- Multiple figures showing the same metric
- Multi-panel figures with different metrics
- Systematic metric updates across analysis
- Adding/removing metrics from analysis

**Example Use Case**: Changing from absolute telomere counts to normalized ratios across 5 figures required only 2 cell edits instead of 15+ individual plot updates.

## Normalized vs Absolute Metrics

### When to Use Ratios Instead of Counts

**Problem**: Absolute counts can't be fairly compared across groups with different expected values.

**Example: Telomere Counts**
- Species A: 20 telomeres found, 50 chromosomes expected
- Species B: 15 telomeres found, 20 chromosomes expected
- **Which is better?** Can't tell from absolute values!

**Solution**: Use ratio = found / expected
- Species A: 20/50 = 0.40 (40%)
- Species B: 15/20 = 0.75 (75%) ← clearly better!

### Implementation Pattern

```python
# Add ratio calculation in data loading cell
df = pd.read_csv('assemblies.csv')
df['telomere_ratio'] = df['telomeres_found'] / df['chromosomes_expected']

# Update metrics list to use ratio instead of count
metrics = [
    # Before: ('telomeres_found', 'Complete Telomeres', True),
    ('telomere_ratio', 'Telomere Ratio (Found/Expected)', True),
]

# All plots automatically switch to using the ratio
```

### Benefits of Normalized Metrics

**Interpretability**:
- Ratio of 1.0 = perfect (all expected features present)
- Ratio of 0.5 = half present
- Ratio > 1.0 = more than expected (e.g., duplications)

**Comparability**:
- Fair comparison across species with different karyotypes
- Can identify systematic patterns vs species-specific effects
- Removes confounding effect of different expected values

**Statistical Power**:
- Reduces variance caused by different expected values
- Improves detection of real biological/technical effects
- Makes statistical tests more sensitive

### Common Normalized Metrics in Genomics

| Absolute Metric | Normalized Version | Formula |
|----------------|-------------------|---------|
| Chromosomes assigned | Assignment percentage | `assigned / total * 100` |
| Telomeres found | Telomere ratio | `found / expected_chromosomes` |
| Gaps in assembly | Gap density | `gaps / assembly_length * 100` |
| Contigs assembled | Reduction ratio | `initial_contigs / final_contigs` |
| Bases in scaffolds | N50 (size-weighted median) | Cumulative length metric |

### When to Keep Absolute Metrics

Keep absolute values when:
- The expected value is constant across all samples
- You're tracking total volume/magnitude changes
- Supplementary material where space allows both

**Best Practice**: Provide both absolute and normalized in supplementary materials when space allows. Use normalized for main figures and comparisons.

### Example: Multi-Species Assembly Quality

```python
# Load assembly data
df = pd.read_csv('assemblies.csv')

# Calculate normalized metrics
df['telomere_ratio'] = df['telomeres_found'] / df['chromosomes_expected']
df['gap_density'] = (df['gap_bases'] / df['assembly_length']) * 100
df['chr_assignment_pct'] = (df['chr_assigned_bases'] / df['total_bases']) * 100

# Now can fairly compare across species
for species in df['species'].unique():
    species_data = df[df['species'] == species]
    print(f"{species}: telomere_ratio = {species_data['telomere_ratio'].mean():.2f}")
```

## Analyzing Notebook Figure Usage

To identify which figures are actually displayed/used in a notebook (useful for project cleanup):

### Extracting Figure References

```bash
# Extract figure paths from notebook JSON
grep -o "figures/[^'\"]*\.png" Notebook.ipynb | sort -u

# For Image() calls with filename parameter
grep "Image(filename=" Notebook.ipynb | grep -o "figures/[^'\"]*\.png"

# For display(Image(...)) patterns
grep "display(Image" Notebook.ipynb | grep -o "figures/[^'\"]*\.png"
```

### Analyzing Multiple Notebooks

```bash
for nb in *.ipynb; do
    echo "=== $nb ==="
    grep -o "figures/[^'\"]*\.png" "$nb" | sort -u
    echo ""
done > /tmp/all_used_figures.txt
```

### Common Figure Display Patterns to Search

- `Image(filename='figures/...')`  # Direct Image calls
- `display(Image(filename='...'))`  # Display wrapper
- `![Figure](figures/...)`  # Markdown cells
- `<img src="figures/...">`  # HTML in markdown cells

### Additional Quick Reference Commands

```bash
# Method 1: Simple grep for .png files
grep -o "\.png" notebook.ipynb | grep -v "image/png" | sort | uniq

# Method 2: Extract Image() calls with filenames
grep "Image(filename" notebook.ipynb | grep -o "'[^']*\.png'"

# Method 3: Find all display() calls with images
grep -n "\.png\|Image(\|display(" notebook.ipynb

# Method 4: Check multiple notebooks at once
for nb in *.ipynb; do
    echo "=== $nb ==="
    grep -o "[^'\"]*\.png" "$nb" | sort | uniq
done
```

### Cross-referencing Figures Across Notebooks

Check if figures are shared or unique:

```bash
# Find which notebooks use a specific figure
figure="01_scaffold_n50.png"
grep -l "$figure" *.ipynb

# Check if a notebook has unique figures
notebook="Analysis.ipynb"
for fig in $(grep -oh "[^'\"]*\.png" "$notebook"); do
    count=$(grep -l "$fig" *.ipynb | wc -l)
    if [ "$count" -eq 1 ]; then
        echo "UNIQUE: $fig"
    else
        echo "SHARED: $fig (used by $count notebooks)"
    fi
done
```

### Use Cases

- **Project cleanup**: Identify unused figures for archiving
- **Dependency analysis**: Verify figure generation scripts are needed
- **Documentation**: Map figures to notebooks that use them
- **Validation**: Ensure all referenced figures exist

### Example Workflow

```bash
# 1. Find all figures referenced in notebooks
grep -o "figures/[^'\"]*\.png" *.ipynb | sort -u > used_figures.txt

# 2. Find all existing figures
find figures/ -name "*.png" > all_figures.txt

# 3. Identify unused figures (those in all_figures but not in used_figures)
comm -23 <(sort all_figures.txt) <(sort used_figures.txt) > unused_figures.txt
```

---

## Path Management for Notebooks in Subdirectories

When notebooks are in a `notebooks/` subdirectory (common in sharing packages), use relative paths:

### Problem

Notebooks developed in project root use paths like:
```python
FIG_DIR = Path('figures/curation_impact')
DATA_FILE = 'data/dataset.csv'
```

These fail when notebooks are moved to `notebooks/` subdirectory.

### Solution

Update paths programmatically using nbformat:

```python
import nbformat

def update_notebook_paths(notebook_path):
    """Update paths to work from notebooks/ directory."""
    with open(notebook_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    for cell in nb.cells:
        if cell.cell_type == 'code':
            # Update figure paths
            cell.source = cell.source.replace(
                "Path('figures/",
                "Path('../figures/"
            )
            # Update data paths
            cell.source = cell.source.replace(
                "'data/",
                "'../data/"
            )

    with open(notebook_path, 'w') as f:
        nbformat.write(nb, f)
```

### Best Practice

In sharing packages, use structure:
```
project/
├── notebooks/        # Notebooks here
│   └── analysis.ipynb
├── figures/          # Figures here
├── data/            # Data here
└── scripts/         # Scripts here
```

Notebooks access files using `../`:
```python
FIG_DIR = Path('../figures/subfolder')
data = pd.read_csv('../data/dataset.csv')
```

### Verification

Test paths work:
```bash
cd notebooks/
jupyter nbconvert --to html --execute notebook.ipynb
```

If paths are correct, notebook executes without FileNotFoundError.

---

## Generating HTML for Documentation

When notebooks are for documentation only or contain references to figures that need to be generated:

### Convert Without Execution

```bash
# Generate HTML from current notebook state
jupyter nbconvert --to html notebook.ipynb --output-dir output/
```

This creates viewable HTML files without running code cells, useful for:
- Documentation notebooks with pre-generated figures
- Sharing notebooks before figure generation
- Quick previews during development

### Convert With Execution

When all dependencies are available:
```bash
# Execute and convert
jupyter nbconvert --to html --execute notebook.ipynb \
    --output-dir output/ \
    --ExecutePreprocessor.timeout=600
```

### Batch Conversion

Convert multiple notebooks:
```bash
for nb in notebooks/*.ipynb; do
    jupyter nbconvert --to html "$nb" --output-dir notebooks/
done
```

### Benefits of HTML Sharing

1. **No setup required**: Recipients can view immediately in browser
2. **Self-contained**: Includes all outputs and styling
3. **Professional**: Clean formatting with syntax highlighting
4. **Preserves outputs**: Shows results without re-running code

---

## Preparing Notebooks for Sharing

Remove outputs before sharing to reduce file size and avoid exposing intermediate results:

```python
import nbformat

def clean_notebook(input_path, output_path):
    """Remove outputs and execution counts."""
    with open(input_path, 'r') as f:
        nb = nbformat.read(f, as_version=4)

    for cell in nb.cells:
        if cell.cell_type == 'code':
            cell.outputs = []
            cell.execution_count = None

    with open(output_path, 'w') as f:
        nbformat.write(nb, f)

# Clean all notebooks in directory
from pathlib import Path
for nb_file in Path('notebooks').glob('*.ipynb'):
    clean_notebook(nb_file, f"cleaned/{nb_file.name}")
```

Benefits:
- Smaller file sizes
- No accidental data leakage
- Clean starting point for users
- Git-friendly (fewer diffs)

---

## Common Pitfalls

### Variable Shadowing in Loops

**Problem**: Using common variable names like `data` as loop variables overwrites global variables:

```python
# BAD - Shadows global 'data' variable
for i, (sp, data) in enumerate(species_by_gc_content[:10], 1):
    val = data['gc_content']
    print(f'{sp}: {val}')
```

After this loop, `data` is no longer your dataset list - it's the last species dict!

**Solution**: Use descriptive loop variable names:

```python
# GOOD - Uses specific name
for i, (sp, sp_data) in enumerate(species_by_gc_content[:10], 1):
    val = sp_data['gc_content']
    print(f'{sp}: {val}')
```

**Detection**: If you see errors like "Type: <class 'dict'>" when expecting a list, check for variable shadowing in recent cells.

**Prevention**:
- Never use generic names (`data`, `item`, `value`) as loop variables
- Use prefixed names (`sp_data`, `row_data`, `inv_data`)
- Add validation cells that check variable types

### Cell Execution Order with NotebookEdit

**Problem**: When adding cells with `NotebookEdit`, variable definitions must come before usage, but cell numbering doesn't update automatically.

**Error Pattern**:
```python
# Cell 14: Uses aws_available ✗
if aws_available:
    ...

# Cell 16: Defines aws_available ✓
aws_available = check_aws_cli()
```

**Error**: `NameError: name 'aws_available' is not defined`

**Why This Happens**: When you insert cells programmatically, they're added in the file but notebooks execute cells in the order they're run, not their position in the file.

**Solution**: Insert prerequisite cells BEFORE cells that use the variables:

```python
# Insert new cell AFTER cell-12 (so it becomes cell-13, before old cell-13 that uses it)
NotebookEdit(
    notebook_path="...",
    cell_id="cell-12",
    edit_mode="insert",  # Creates new cell after cell-12
    new_source="aws_available = check_aws_cli()"
)
```

**Critical**: After adding cells, instruct user to **Restart & Run All** to ensure clean execution order.

**Prevention**: When designing notebooks with dependencies:
1. Define all helper functions first (Section: Helper Functions)
2. Define all global variables needed (Section: Configuration/Setup)
3. Use dependent variables only in later sections

**Alternative - Defensive Check**:
```python
try:
    if aws_available:
        ...
except NameError:
    print("⚠ Run previous cells first to define aws_available")
    aws_available = False
```

**Best Practice**: Always test notebooks with "Restart & Run All" after programmatic modifications to catch execution order issues.
- Run "Restart & Run All" regularly to catch issues early

**Common shadowing patterns to avoid**:
```python
for data in dataset:          # Shadows 'data'
for i, data in enumerate():   # Shadows 'data'
for key, data in dict.items() # Shadows 'data'
```

### Verify Column Names Before Processing

**Problem**: Assuming column names without checking actual DataFrame structure leads to immediate failures. Column names may use different capitalization, spacing, or naming conventions than expected.

**Example error:**
```python
# Assumed column name
df_filtered = df[df['scientific_name'] == target]  # KeyError!

# Actual column name was 'Scientific Name' (capitalized with space)
```

**Solution**: Always check actual columns first:
```python
import pandas as pd
df = pd.read_csv('data.csv')

# ALWAYS print columns before processing
print("Available columns:")
print(df.columns.tolist())

# Then write filtering code with correct names
df_filtered = df[df['Scientific Name'] == target_species]  # Correct
```

**Best practice for data processing scripts:**
```python
# At the start of your script
def verify_required_columns(df, required_cols):
    """Verify DataFrame has required columns."""
    missing = [col for col in required_cols if col not in df.columns]
    if missing:
        print(f"ERROR: Missing columns: {missing}")
        print(f"Available columns: {df.columns.tolist()}")
        sys.exit(1)

# Use it
required = ['Scientific Name', 'tolid', 'accession']
verify_required_columns(df, required)
```

**Common column name variations to watch for:**
- `scientific_name` vs `Scientific Name` vs `ScientificName`
- `species_id` vs `species` vs `Species ID`
- `genome_size` vs `Genome size` vs `GenomeSize`

**Debugging tip**: Include column listing in all data processing scripts:
```python
# Add at script start for easy debugging
if '--debug' in sys.argv or len(df.columns) < 10:
    print(f"Columns ({len(df.columns)}): {df.columns.tolist()}")
```

## Splitting Large Notebooks

### When to Split

Split notebooks when they contain multiple distinct analyses that:
- Can run independently
- Have different execution times
- Serve different purposes (e.g., technology effects vs temporal trends)
- Would benefit from modular execution

### Splitting Strategy

**1. Identify Analysis Boundaries**
- Look for natural divisions (e.g., different research questions)
- Check for shared vs unique dependencies
- Consider which cells can be shared vs must be customized

**2. Common Pitfalls When Splitting**

❌ **Missing Calculated Columns**: Columns created in code (not in CSV) must be recreated
```python
# Original notebook created this:
df['telomere_ratio'] = df['telomere_cat0_both_terminal'] / df['num_chromosomes_expected']

# Split notebook must recreate it - won't exist in data file!
```

❌ **Missing Variable Definitions**: Variables defined in shared setup cells
```python
# These must be in BOTH notebooks:
category_colors = {'Phased+Dual': '#0072B2', ...}
df['year_numeric'] = df['release_year']
```

❌ **Stale Notebook Metadata**: Jupyter execution state can cause issues
```python
# Clean all execution state before testing:
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        cell['execution_count'] = None
        cell['outputs'] = []
```

**3. Proper Splitting Workflow**

```python
import json

# Load original notebook
with open('Original_Notebook.ipynb', 'r') as f:
    original = json.load(f)

# Create new notebook with clean structure
new_nb = {
    "cells": [],
    "metadata": original["metadata"],  # Preserve original metadata
    "nbformat": original["nbformat"],
    "nbformat_minor": original["nbformat_minor"]
}

# Add cells - mix of custom and reused
new_nb["cells"].append({
    "cell_type": "markdown",
    "metadata": {},
    "source": ["# New Notebook Title"]
})

# Custom data loading with ALL required calculations
new_nb["cells"].append({
    "cell_type": "code",
    "execution_count": None,
    "metadata": {},
    "outputs": [],
    "source": [
        "df = pd.read_csv('data.csv')\n",
        "# Recreate calculated columns\n",
        "df['year_numeric'] = df['release_year']\n",
        "df['telomere_ratio'] = df['col_a'] / df['col_b']"
    ]
})

# Reuse complex cells from original
new_nb["cells"].append(original["cells"][25])  # Plotting cell

# Save
with open('New_Notebook.ipynb', 'w') as f:
    json.dump(new_nb, f, indent=2)
```

**4. Testing Split Notebooks**

```bash
# Test execution (don't rely on manual testing)
jupyter nbconvert --to notebook --execute New_Notebook.ipynb --output Test_Output.ipynb

# Check for errors
python3 << 'EOF'
import json
with open('Test_Output.ipynb', 'r') as f:
    nb = json.load(f)
for i, cell in enumerate(nb['cells']):
    if cell['cell_type'] == 'code':
        for output in cell.get('outputs', []):
            if output.get('output_type') == 'error':
                print(f"Error in cell {i}: {output.get('ename')}")
EOF
```

**5. Checklist for Split Notebooks**

- [ ] All calculated columns recreated in data loading
- [ ] All variable definitions included (colors, configs, etc.)
- [ ] Notebook metadata preserved from original
- [ ] Execution state cleaned (execution_count = None)
- [ ] Tested with `jupyter execute` (not just manual run)
- [ ] Figures generate successfully
- [ ] Statistics files created
- [ ] Documentation updated (MANIFEST.md)

### Debugging Jupyter Execution Errors

**Symptom**: `jupyter execute` or `nbconvert --execute` fails with `KeyError` or `NameError`, but running the same code in Python works perfectly.

**Root Causes**:

1. **Corrupted Notebook JSON Structure**
   - Cell metadata issues
   - Execution state conflicts
   - Malformed cell source arrays

2. **Variable Scoping in Notebook Execution**
   - Jupyter's kernel state differs from direct Python execution
   - Cells may execute in unexpected order during automated execution

**Debugging Strategy**:

```python
# Step 1: Test cells work in isolation
import pandas as pd
# Run each cell's code manually
df = pd.read_csv('data.csv')
df['year_numeric'] = df['release_year']
# ... verify each step works

# Step 2: Clean notebook execution state
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        cell['execution_count'] = None
        cell['outputs'] = []
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=2)

# Step 3: If still failing, rebuild notebook from scratch
# Use original metadata but fresh cell structure
```

**When Manual Test Succeeds but Jupyter Fails → Rebuild**:

If code works in Python but Jupyter execution fails after cleaning execution state, the notebook JSON structure is likely corrupted. Solution: Rebuild from scratch using original cells.

```python
# Rebuild with clean structure
new_nb = {
    "cells": [],
    "metadata": original["metadata"],  # Use original metadata!
    "nbformat": 4,
    "nbformat_minor": 4
}
# Add cells systematically, test incrementally
```

**Prevention**:
- Always preserve original notebook metadata when creating new notebooks
- Clean execution state before committing notebooks
- Test with `jupyter execute` before considering notebook "done"

### Testing and Validation

**Level 1: Syntax Check**
```python
import json
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)
all_code = '\n'.join(''.join(cell['source']) for cell in nb['cells'] if cell['cell_type'] == 'code')
compile(all_code, '<notebook>', 'exec')  # Raises SyntaxError if invalid
```

**Level 2: Manual Execution**
```python
# Execute cells manually in sequence
namespace = {}
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        exec('\n'.join(cell['source']), namespace)
```

**Level 3: Jupyter Execution**
```bash
# The gold standard - tests actual Jupyter execution
jupyter nbconvert --to notebook --execute notebook.ipynb --output test.ipynb
```

**Level 4: Verify Outputs**
```python
# Check executed notebook for errors
with open('test.ipynb', 'r') as f:
    nb = json.load(f)
for cell in nb['cells']:
    for output in cell.get('outputs', []):
        if output.get('output_type') == 'error':
            print(f"Error: {output.get('ename')}: {output.get('evalue')}")
```

**Test Incrementally When Debugging**:
```python
# If full execution fails, test partial execution
jupyter nbconvert --execute --to notebook \
    --ExecutePreprocessor.timeout=60 \
    --execute-preprocessor-timeout=60 \
    notebook.ipynb
```

### Debugging Techniques

**Converting Notebook to Script for Testing**

When Jupyter execution fails mysteriously, convert to Python script:

```python
import json

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Extract code cells
script_lines = []
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        script_lines.extend(cell['source'])
        script_lines.append('\n')

with open('notebook_script.py', 'w') as f:
    f.write('\n'.join(script_lines))
```

Then run: `python3 notebook_script.py`

**Note**: This may hang on plotting code (waiting for display). Use for debugging only.

## Outlier Handling Best Practices

### Two-Stage Outlier Removal

For analyses correlating characteristics across aggregated entities (e.g., species-level summaries):

1. **Stage 1: Count-based outliers (IQR method)**
   - Remove entities with abnormally high sample counts
   - Prevents over-represented entities from skewing correlations
   - Apply BEFORE other analyses

   ```python
   import numpy as np
   workflow_counts = [entity_data[id]['workflow_count'] for id in entity_data.keys()]
   q1 = np.percentile(workflow_counts, 25)
   q3 = np.percentile(workflow_counts, 75)
   iqr = q3 - q1
   upper_bound = q3 + 1.5 * iqr

   outliers = [id for id in entity_data.keys()
               if entity_data[id]['workflow_count'] > upper_bound]
   for id in outliers:
       del entity_data[id]
   ```

2. **Stage 2: Value-based outliers (percentile)**
   - Remove extreme values for visualization clarity
   - Apply ONLY to visualization data, not statistics
   - Typically top 5% for highly skewed distributions

   ```python
   values = [entity_data[id]['metric'] for id in entity_data.keys()]
   threshold = np.percentile(values, 95)
   viz_entities = [id for id in entity_data.keys()
                   if entity_data[id]['metric'] <= threshold]

   # Use viz_entities for plotting
   # Use full entity_data.keys() for statistics
   ```

### Characteristic-Specific Outlier Removal

When analyzing genome characteristics vs metrics, remove outliers for the characteristic being analyzed:

```python
# After removing workflow count outliers, also remove heterozygosity outliers
heterozygosity_values = [species_data[sp]['heterozygosity'] for sp in species_data.keys()]

het_q1 = np.percentile(heterozygosity_values, 25)
het_q3 = np.percentile(heterozygosity_values, 75)
het_iqr = het_q3 - het_q1
het_upper_bound = het_q3 + 1.5 * het_iqr

het_outliers = [sp for sp in species_data.keys()
                if species_data[sp]['heterozygosity'] > het_upper_bound]

for sp in het_outliers:
    del species_data[sp]

print(f'Removed {len(het_outliers)} heterozygosity outliers (>{het_upper_bound:.2f}%)')
print(f'New heterozygosity range: {min(vals):.2f}% - {max(vals):.2f}%')
```

**Apply separately for each characteristic**:
- Genome size outliers for genome size analysis
- Heterozygosity outliers for heterozygosity analysis
- Repeat content outliers for repeat content analysis

### When to Skip Outlier Removal

- Memory usage plots when investigating over-allocation patterns
- Comparison plots (allocated vs used) where outliers reveal problems
- User explicitly requests to see all data
- Data is already limited (< 10 points)

**Document clearly** in plot titles and code comments which outlier removal is applied.


###IQR-Based Outlier Removal for Visualization

**Standard Method**: 1.5×IQR (Interquartile Range)

**Implementation**:
```python
# Calculate IQR
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1

# Define outlier boundaries (standard: 1.5×IQR)
lower_bound = Q1 - 1.5*IQR
upper_bound = Q3 + 1.5*IQR

# Filter outliers
outlier_mask = (data >= lower_bound) & (data <= upper_bound)
data_filtered = data[outlier_mask]
n_outliers = (~outlier_mask).sum()

# IMPORTANT: Report outliers removed
print(f"Removed {n_outliers} outliers for visualization")
# Add to figure: f"({n_outliers} outliers removed)"
```

**Multi-dimensional Outlier Removal**:
```python
# For scatter plots with two dimensions (e.g., size ratio AND absolute size)
outlier_mask = (
    (ratio >= Q1_ratio - 1.5*IQR_ratio) &
    (ratio <= Q3_ratio + 1.5*IQR_ratio) &
    (size >= Q1_size - 1.5*IQR_size) &
    (size <= Q3_size + 1.5*IQR_size)
)
```

**Best Practice**: Always report number of outliers removed in figure statistics or caption.

**When to Use**: For visualization clarity when extreme values compress the main distribution. Not for removing "bad" data - use for display only.

## Statistical Rigor

### Required for Correlation Analyses

1. **Pearson correlation with p-values**:
   ```python
   from scipy import stats
   correlation, p_value = stats.pearsonr(x_values, y_values)
   sig_text = 'significant' if p_value < 0.05 else 'not significant'
   ```

2. **Report both metrics**:
   - Correlation coefficient (r) - strength and direction
   - P-value - statistical significance (α=0.05)
   - Sample size (n)

3. **Display on plots**:
   ```python
   ax.text(0.98, 0.02,
           f'r = {correlation:.3f}\np = {p_value:.2e}\n({sig_text})\nn = {len(data)} species',
           transform=ax.transAxes, ...)
   ```


### Adding Mann-Whitney U Tests to Figures

**When to Use**: Comparing continuous metrics between two groups (e.g., Dual vs Pri/alt curation)

**Standard Implementation**:
```python
from scipy import stats

# Calculate test
data_group1 = df[df['group'] == 'Group1']['metric']
data_group2 = df[df['group'] == 'Group2']['metric']

if len(data_group1) > 0 and len(data_group2) > 0:
    stat, pval = stats.mannwhitneyu(data_group1, data_group2, alternative='two-sided')
else:
    pval = np.nan

# Add to stats text
if not np.isnan(pval):
    stats_text += f"\nMann-Whitney p: {pval:.2e}"
```

**Display in Figures**: Include p-value in statistics box with format `Mann-Whitney p: 1.23e-04`

**Consistency**: Ensure all quantitative comparison figures include this test for statistical rigor.

## CRITICAL: Statistical Claim Verification

### The Problem
Notebook analysis text can contain claims based on:
- Preliminary results that changed
- Copy-paste errors from similar analyses
- Expectations that weren't verified
- Old results before data/code updates

**Real example from production notebook:**
- **Text claimed**: "significantly higher N50 values (p < 0.001)"
- **Actual result**: p = 0.28 (NOT significant)
- **Impact**: Would have published false conclusion

### Mandatory Verification Workflow

**BEFORE finalizing any analysis notebook:**

#### 1. Extract All Statistical Claims
Search for keywords:
- p-values: `p <`, `p =`, `p-value`
- Significance: `significant`, `significantly`, `difference`
- Comparisons: `higher`, `lower`, `greater`, `increased`, `decreased`

#### 2. Run Actual Statistical Tests
Don't trust existing text. Rerun the tests:

```python
from scipy import stats
import pandas as pd

# Load actual data
df = pd.read_csv('data.csv')

# Run test (example: Mann-Whitney U)
group1 = df[df['type']=='A']['metric']
group2 = df[df['type']=='B']['metric']
stat, p = stats.mannwhitneyu(group1, group2, alternative='two-sided')

print(f"Actual p-value: {p:.6f}")
print(f"Significant (p<0.05): {p < 0.05}")
```

#### 3. Document Actual Results
Create verification table:

| Figure | Metric | Text Claims | Actual p-value | Match? |
|--------|--------|-------------|----------------|--------|
| Fig 1 | N50 | "p<0.001 significant" | **0.28** | ❌ FALSE |
| Fig 2 | Gaps | "p=0.002 significant" | 0.0023 | ✅ TRUE |

#### 4. Common Discrepancy Patterns

**False Positive (Type I error in text):**
- Text claims significance when p > 0.05
- **Fix**: Rewrite to state "no significant difference"

**Missed Significance:**
- Text implies no difference when p < 0.05
- **Fix**: Add statistical evidence and effect interpretation

**Wrong Direction:**
- Text claims "Group A > Group B" when opposite is true
- **Fix**: Reverse comparison direction

**Outdated Organization:**
- Figures organized by old results
- **Fix**: Reorganize sections based on actual significance

#### 5. Correction Protocol

When errors found:
1. **Document the error** (create CORRECTIONS.md)
2. **Run verification script** on ALL claims
3. **Reorganize notebook** if section classification wrong
4. **Rewrite analysis text** to match actual results
5. **Update table of contents** with correct annotations
6. **Create milestone backup** documenting corrections

### Prevention

**For new analyses:**
```python
# Write analysis text AFTER running test, not before
stat, p = stats.mannwhitneyu(group1, group2)

# Generate text from actual results
if p < 0.05:
    text = f"significant difference (p={p:.4f})"
else:
    text = f"no significant difference (p={p:.2f})"
```

**Before any publication/sharing:**
1. Run verification on ALL statistical claims
2. Cross-check figure captions with actual p-values
3. Verify section organization matches significance
4. Get second person to spot-check key claims

### Why This Is Critical
- **Scientific integrity**: False claims damage credibility
- **Reproducibility**: Others can't reproduce wrong results
- **Peer review**: Reviewers will catch errors, causing rejection
- **Career impact**: Publishing false statistics has serious consequences

## Large-Scale Analysis Structure

### Control Analyses: Checking for Confounding

When comparing methods (e.g., Method A vs Method B), always check if observed differences could be explained by characteristics of the samples rather than the methods themselves.

**Critical control analysis**:
```python
import pandas as pd
from scipy import stats

def check_confounding(df, method_col, characteristics):
    """
    Compare sample characteristics between methods to check for confounding.

    Args:
        df: DataFrame with samples
        method_col: Column indicating method ('Method_A', 'Method_B')
        characteristics: List of column names to compare

    Returns:
        DataFrame with statistical comparison
    """
    results = []

    for char in characteristics:
        # Get data for each method
        method_a = df[df[method_col] == 'Method_A'][char].dropna()
        method_b = df[df[method_col] == 'Method_B'][char].dropna()

        if len(method_a) < 5 or len(method_b) < 5:
            continue

        # Statistical test
        stat, pval = stats.mannwhitneyu(method_a, method_b, alternative='two-sided')

        # Calculate effect size (% difference in medians)
        pooled_median = pd.concat([method_a, method_b]).median()
        effect_pct = (method_a.median() - method_b.median()) / pooled_median * 100

        results.append({
            'Characteristic': char,
            'Method_A_median': method_a.median(),
            'Method_A_n': len(method_a),
            'Method_B_median': method_b.median(),
            'Method_B_n': len(method_b),
            'p_value': pval,
            'effect_pct': effect_pct,
            'significant': pval < 0.05
        })

    return pd.DataFrame(results)

# Example usage
characteristics = ['genome_size', 'gc_content', 'heterozygosity',
                  'repeat_content', 'sequencing_coverage']

confounding_check = check_confounding(df, 'curation_method', characteristics)
print(confounding_check)
```

**Interpretation guide**:
- **No significant differences**: Methods compared equivalent samples → valid comparison
- **Method A has "easier" samples** (smaller genomes, lower complexity): Quality differences may be due to sample properties, not method
- **Method A has "harder" samples** (larger genomes, higher complexity): Strengthens conclusion that Method A is better despite challenges
- **Limited data** (n<10): Cannot rule out confounding, note as limitation

**Present in notebook**:
```markdown
## Genome Characteristics Comparison

**Control Analysis**: Are quality differences due to method or sample properties?

[Table comparing characteristics]

**Conclusion**:
- If no differences → Valid method comparison
- If Method A works with harder samples → Strengthens conclusions
- If Method A works with easier samples → Potential confounding
```

**Why critical**: Reviewers will ask this question. Preemptive control analysis demonstrates scientific rigor and prevents major revisions.


### Organizing 60+ Cell Notebooks

1. **Section headers** (markdown cells):
   - Main sections: "## CPU Runtime Analysis", "## Memory Analysis"
   - Subsections: "### Genome Size vs CPU Runtime"

2. **Cell pairing pattern**:
   - Markdown header + code cell for each analysis
   - Keeps related content together
   - Easier to navigate and debug

3. **Consistent naming**:
   - Figure files: `fig18_genome_size_vs_cpu_hours.png`
   - Variables: `species_data`, `genome_sizes_full`, `genome_sizes_viz`
   - Functions: `safe_float_convert()` defined consistently

4. **Progressive enhancement**:
   - Start with basic analyses
   - Add enriched data (Cell 7 pattern)
   - Build increasingly complex correlations
   - End with multivariate analyses (PCA)

## Template Generation Pattern

For creating multiple similar analysis cells:

```python
# Create template with placeholder variables
template = '''
if len(data_with_species) > 0:
    print('Analyzing {display} vs {metric}...\\n')

    # Aggregate data per species
    species_data = {{}}

    for inv in data_with_species:
        {name} = safe_float_convert(inv.get('{name}'))
        if {name} is None:
            continue
        # ... analysis code
'''

# Generate multiple cells from characteristics list
characteristics = [
    {'name': 'genome_size', 'display': 'Genome Size', 'unit': 'Gb'},
    {'name': 'heterozygosity', 'display': 'Heterozygosity', 'unit': '%'},
    # ...
]

for char in characteristics:
    code = template.format(**char)
    # Write to notebook or temp file
```

## Helper Function Pattern

Define once, reuse throughout:

```python
def safe_float_convert(value):
    """Convert string to float, handling comma separators"""
    if not value or not str(value).strip():
        return None
    try:
        return float(str(value).replace(',', ''))
    except (ValueError, TypeError):
        return None
```

Include in Cell 7 (enrichment) and reference: "# Helper function (same as Cell 7)"

## Publication-Quality Figures

Standard settings:
- DPI: 300
- Figure size: (12, 8) for single plots, (16, 7) for side-by-side
- Grid: `alpha=0.3, linestyle='--'`
- Point size: Proportional to sample count (`s=[50 + count*20 for count in counts]`)
- Colormap: 'viridis' for workflow counts


### Publication-Ready Font Sizes

**Problem**: Default matplotlib fonts are designed for screen viewing, not print publication.

**Solution**: Use larger, bold fonts for print readability.

**Recommended sizes** (for standard 10-12 cm wide figures):

| Element | Default | Publication | Code |
|---------|---------|-------------|------|
| **Title** | 11-12pt | **18pt** (bold) | `fontsize=18, fontweight='bold'` |
| **Axis labels** | 10-11pt | **16pt** (bold) | `fontsize=16, fontweight='bold'` |
| **Tick labels** | 9-10pt | **14pt** | `tick_params(labelsize=14)` |
| **Legend** | 8-10pt | **12pt** | `legend(fontsize=12)` |
| **Annotations** | 8-10pt | **11-13pt** | `fontsize=12` |
| **Data points** | 20-36 | **60-100** | `s=80` (scatter) |

**Implementation example**:
```python
fig, ax = plt.subplots(figsize=(10, 8))

# Plot data
ax.scatter(x, y, s=80, alpha=0.6)  # Larger points

# Titles and labels - BOLD
ax.set_title('Your Title Here', fontsize=18, fontweight='bold')
ax.set_xlabel('X Axis Label', fontsize=16, fontweight='bold')
ax.set_ylabel('Y Axis Label', fontsize=16, fontweight='bold')

# Tick labels
ax.tick_params(axis='both', which='major', labelsize=14)

# Legend
ax.legend(fontsize=12, loc='best')

# Stats box
stats_text = "Statistics:\nMean: 42.5"
ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
       fontsize=13, family='monospace',
       bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.3))

# Reference lines - thicker
ax.axhline(y=1.0, linewidth=2.5, linestyle='--', alpha=0.6)
```

**Quick check**: If you have to squint to read the figure on screen at 100% zoom, fonts are too small for print.

**Special cases**:
- Multi-panel figures: Increase 10-15% more
- Posters: Increase 50-100% more
- Presentations: Increase 30-50% more

### Accessibility: Colorblind-Safe Palettes

**Problem**: Standard color schemes (green vs blue, red vs green) are difficult or impossible to distinguish for people with color vision deficiencies, affecting ~8% of males and ~0.5% of females.

**Solution**: Use colorblind-safe palettes from validated sources.

**IBM Color Blind Safe Palette (Recommended)**:
```python
# For comparing two groups/conditions
colors = {
    'Group_A': '#0173B2',  # Blue
    'Group_B': '#DE8F05'   # Orange
}
```

**Why this works**:
- ✅ Maximum contrast for all color vision types (deuteranopia, protanopia, tritanopia, achromatopsia)
- ✅ Professional appearance for scientific publications
- ✅ Clear distinction even in grayscale printing
- ✅ Cultural neutrality (no red/green traffic light associations)

**Other colorblind-safe combinations**:
- Blue + Orange (best overall)
- Blue + Red (good for most types)
- Blue + Yellow (good but lower contrast)

**Avoid**:
- ❌ Green + Red (most common color blindness)
- ❌ Green + Blue (confusing for many)
- ❌ Blue + Purple (too similar)

**Implementation in matplotlib**:
```python
import matplotlib.pyplot as plt

# Define colorblind-safe palette
CB_COLORS = {
    'blue': '#0173B2',
    'orange': '#DE8F05',
    'green': '#029E73',
    'red': '#D55E00',
    'purple': '#CC78BC',
    'brown': '#CA9161'
}

# Use in plots
plt.scatter(x, y, color=CB_COLORS['blue'], label='Treatment')
plt.scatter(x2, y2, color=CB_COLORS['orange'], label='Control')
```

**Testing your colors**:
- Use online simulators: https://www.color-blindness.com/coblis-color-blindness-simulator/
- Check in grayscale: Convert figure to grayscale to ensure distinguishability

### Handling Severe Data Imbalance in Comparisons

**Problem**: Comparing groups with very different sample sizes (e.g., 84 vs 10) can lead to misleading conclusions.

**Solution**: Add prominent warnings both visually and in documentation.

**Visual warning on figure**:
```python
import matplotlib.pyplot as plt

# After creating your plot
n_group_a = len(df[df['group'] == 'A'])
n_group_b = len(df[df['group'] == 'B'])
total_a = 200
total_b = 350

warning_text = f"⚠️  DATA LIMITATION\n"
warning_text += f"Data availability:\n"
warning_text += f"  Group A: {n_group_a}/{total_a} ({n_group_a/total_a*100:.1f}%)\n"
warning_text += f"  Group B: {n_group_b}/{total_b} ({n_group_b/total_b*100:.1f}%)\n"
warning_text += f"Severe imbalance limits\nstatistical comparability"

ax.text(0.98, 0.02, warning_text, transform=ax.transAxes,
       fontsize=11, verticalalignment='bottom', horizontalalignment='right',
       bbox=dict(boxstyle='round', facecolor='red', alpha=0.2,
                edgecolor='red', linewidth=2),
       family='monospace', color='darkred', fontweight='bold')

# Update title to indicate limitation
ax.set_title('Your Title\n(SUPPLEMENTARY - Limited Data Availability)',
            fontsize=14, fontweight='bold')
```

**Text warning in notebook/paper**:
```markdown
**⚠️ CRITICAL DATA LIMITATION**: This figure suffers from severe data availability bias:
- Group A: 84/200 (42%)
- Group B: 10/350 (3%)

This **8-fold imbalance** severely limits statistical comparability. The 10 Group B
samples are unlikely to be representative of all 350.

**Interpretation**: Comparisons should be interpreted with extreme caution. This
figure is provided for completeness but should be considered **supplementary**.
```

**Guidelines for sample size imbalance**:
- **< 2× imbalance**: Generally acceptable, note in caption
- **2-5× imbalance**: Add note about limitations
- **> 5× imbalance**: Add prominent warnings (visual + text)
- **> 10× imbalance**: Consider excluding figure or supplementary-only

**Alternative**: If possible, subset the larger group to match sample size:
```python
# Random subset to balance groups
if n_group_a > n_group_b * 2:
    group_a_subset = df[df['group'] == 'A'].sample(n=n_group_b * 2, random_state=42)
    # Use subset for balanced comparison
```

## Image Display and Responsive Scaling

### Problem: Fixed-size images don't scale with notebook viewer window

When adding images to Jupyter notebooks, you often want them to scale responsively with the viewing window size rather than display at a fixed size.

### Solution Comparison

**❌ SVG with IPython.display.SVG():**
- Displays at native SVG size (fixed)
- Cannot specify width parameter (raises ValueError)
- Does not scale with window resizing
```python
from IPython.display import SVG, display
display(SVG(filename='image.svg'))  # Fixed size, no scaling
```

**❌ PNG conversion attempts:**
- ImageMagick may fail on complex SVG files with rendering errors
- Example error: `non-conforming drawing primitive definition 'stroke-linecap'`
- Conversion process adds complexity

**✅ HTML img tag in markdown cell (RECOMMENDED):**
```markdown
<img src="path/to/image.svg" width="100%" style="max-width: 1200px; height: auto;" alt="Description">
```

Benefits:
- Scales responsively to 100% of container width
- `max-width` prevents oversized display on large screens
- `height: auto` maintains aspect ratio
- Works with both SVG and PNG formats
- Browser handles rendering natively

### Implementation Pattern

Replace code cells using `display(Image(...))` or `display(SVG(...))` with markdown cells containing HTML:

**Before (code cell):**
```python
from IPython.display import SVG, display
display(SVG(filename='phylo/tree.svg'))
```

**After (markdown cell):**
```markdown
<img src="phylo/tree.svg" width="100%" style="max-width: 1200px; height: auto;" alt="Phylogenetic tree">
```

### When to Use Each Approach

- **Markdown + HTML img**: Publication notebooks, figures that need responsive sizing
- **IPython.display.Image()**: Quick exploration, when fixed PNG size is acceptable
- **IPython.display.SVG()**: When you want maximum quality at native size and don't need scaling

## SVG Manipulation

### Cropping SVG Files Without External Tools

SVG files can be cropped by modifying the `viewBox` and `width` attributes directly, avoiding ImageMagick or other conversion tools.

**Use case**: Remove empty space from generated figures (e.g., iTOL phylogenetic trees with excess whitespace)

**Method - Crop from right side:**
```python
import re

# Read original SVG
with open('original.svg', 'r') as f:
    svg_content = f.read()

# Calculate new dimensions (e.g., 30% width reduction)
original_width = 2560
crop_percentage = 30
new_width = int(original_width * (100 - crop_percentage) / 100)  # 1792
original_height = 1352  # Unchanged

# Update width and viewBox attributes
svg_content = re.sub(r'width="2560"', f'width="{new_width}"', svg_content)
svg_content = re.sub(
    r'viewBox="0,0,2560,1352"',
    f'viewBox="0,0,{new_width},{original_height}"',
    svg_content
)

# Save cropped version
with open('original_cropped.svg', 'w') as f:
    f.write(svg_content)
```

**How it works:**
- `viewBox="x,y,width,height"` defines the coordinate system for SVG content
- Reducing viewBox width crops from the right side (keeps left portion)
- Updating `width` attribute ensures proper rendering size
- Height remains unchanged to preserve vertical content

**Alternative crops:**
- **Left side**: `viewBox="crop_amount,0,new_width,height"`
- **Both sides**: Center the viewBox `viewBox="left_crop,0,new_width,height"`

**Advantages over ImageMagick:**
- No external dependencies or conversion errors
- Preserves vector quality (no rasterization)
- Fast and lightweight
- Works on any SVG file
- Easy to iterate (try 20%, 30%, 40% crops)

**Limitations:**
- Only crops to rectangular regions
- Doesn't handle complex transformations
- May cut off content if not careful (iterate and check visually)

## Dual-Notebook System: Code vs Presentation

### The Problem with Single Large Notebooks

Trying to create a single notebook that serves both purposes leads to:
- 📄 Unwieldy files (25,000+ lines)
- 🐌 Slow to load and execute
- 🔀 Mixed purposes (code + narrative + documentation)
- 🔧 Hard to maintain and update
- 📝 Difficult to share with different audiences

### The Solution: Two Complementary Notebooks

Maintain **two separate notebooks** with different purposes:

#### 1. Code-Based Analysis Notebook

**Purpose**: Execute analyses, generate figures, ensure reproducibility

**Contains**:
- Data loading and validation
- Statistical analyses and tests
- Figure generation code
- Quality checks and debugging
- All computational work

**Characteristics**:
- Heavy on code cells
- Light on narrative
- Executable top-to-bottom
- Version controlled
- Updated frequently during analysis

**File naming**: `Analysis_Name_3Categories.ipynb`

**Example structure**:
```python
# Cell 1: Imports and setup
import pandas as pd
import matplotlib.pyplot as plt

# Cell 2: Load data
df = pd.read_csv('data/dataset.csv')

# Cell 3: Validate data
assert len(df) == expected_n

# Cell 4: Generate Figure 1
fig, ax = plt.subplots()
# ... plotting code ...
plt.savefig('figures/fig1.png', dpi=300)

# Cell 5: Statistical test for Figure 1
from scipy.stats import mannwhitneyu
stat, pval = mannwhitneyu(group1, group2)
```

#### 2. Presentation Notebook

**Purpose**: Display results, document findings, prepare for publication

**Contains**:
- Figure displays (not generation)
- Comprehensive figure captions
- Detailed analyses and interpretations
- Methods documentation
- Statistical summaries
- Conclusions

**Characteristics**:
- Heavy on markdown
- Light on code (just figure loading)
- Narrative-focused
- Publication-ready
- Updated after analysis stabilizes

**File naming**: `Analysis_Name_3Categories_Presentation.ipynb`

**Example structure**:
```markdown
# Three-Category Curation Analysis

## Figure 1: Scaffold N50 Comparison

```python
from IPython.display import Image, display
display(Image('figures/fig1.png'))
```

### Figure Caption
**Figure 1. Scaffold N50 increases with dual curation.**
(A) Comparison across three categories...
[Comprehensive caption]

### Analysis
The scaffold N50 shows a clear hierarchy...
[Detailed interpretation]

### Key Findings
- Phased+Dual: median N50 = X Mb (significantly higher, p<0.001)
- Phased+Single: median N50 = Y Mb
- Pri/alt+Single: median N50 = Z Mb
```

### Workflow Integration

**During active analysis:**
1. Work in **Code Notebook**
2. Generate and refine figures
3. Run statistical tests
4. Fix data issues

**After analysis stabilizes:**
1. Create **Presentation Notebook**
2. Display final figures
3. Write detailed analyses
4. Document methods
5. Prepare for publication

**When figures change:**
1. Update in **Code Notebook**
2. Regenerate figures
3. Update paths/captions in **Presentation Notebook** (minimal changes)

### Synchronization Strategy

**Keep synchronized:**
- Figure file paths
- Statistical results (p-values, effect sizes)
- Sample sizes
- Methods descriptions

**Use code notebook as single source of truth for:**
- Figure generation
- Statistical computations
- Data processing decisions

**Use presentation notebook for:**
- Narrative and interpretation
- Biological context
- Literature connections
- Publication formatting

### File Organization

```
project/
├── Analysis_Name_3Categories.ipynb          # Code notebook
├── Analysis_Name_3Categories_Presentation.ipynb  # Presentation
├── figures/
│   └── analysis_name/
│       ├── fig1.png
│       ├── fig2.png
│       └── ...
├── data/
│   └── dataset.csv
└── scripts/
    └── generate_figures.py  # Extracted from code notebook
```

### Benefits

**Code Notebook:**
- ✅ Fast execution (no heavy markdown)
- ✅ Easy debugging
- ✅ Clear computational workflow
- ✅ Version control friendly

**Presentation Notebook:**
- ✅ Publication-ready formatting
- ✅ Comprehensive documentation
- ✅ Easy to share with collaborators
- ✅ Focused narrative flow

### When to Use This Pattern

Use dual-notebook system when:
- Analysis generates 5+ figures
- Comprehensive documentation needed
- Preparing for publication
- Multiple collaborators involved
- Figures will be refined iteratively

Use single notebook when:
- Quick exploratory analysis
- Few figures (1-3)
- Informal documentation sufficient
- Solo project

### Alternative: Hybrid Approach

For moderately sized analyses, consider:
- Main code notebook for analysis
- Separate markdown document for narrative
- Link figures in markdown: `![Figure 1](figures/fig1.png)`
- Lighter weight than full presentation notebook

### Creating Presentation Notebooks: Three Approaches

#### Option A: Manual Creation
**Pros**: Full control, natural narrative flow
**Cons**: Labor intensive, hard to keep synchronized
**Best for**: Final publication notebook, one-time documentation

#### Option B: Programmatic Generation
**Pros**: Automatically synchronized, reusable
**Cons**: Upfront design effort, less flexible narrative
**Best for**: Repeated similar analyses, frequently updated figures

#### Option C: Hybrid (Recommended)
**Pros**: Balance of automation and customization
**Cons**: Requires planning both parts
**Best for**: Most scientific analyses

**Hybrid implementation**:
- Create notebook with placeholders
- Auto-populate figure displays from metadata
- Manually write analyses
- Use includes for methods from code notebook

## Creating Analysis Notebooks for Scientific Publications

When creating Jupyter notebooks to accompany manuscript figures:

### Structure Pattern
1. **Title and metadata** - Date, dataset info, sample sizes
2. **Overview** - Context from paper abstract/intro
3. **Figure-by-figure analysis**:
   - Code cell to display image
   - Detailed figure legend (publication-ready)
   - Comprehensive analysis paragraph explaining:
     - What the metric measures
     - Statistical results
     - Mechanistic explanation
     - Biological/technical implications
4. **Methods section** - Complete reproducibility information
5. **Conclusions** - Summary of findings

### Table of Contents

For analysis notebooks >10 cells, add a navigable table of contents at the top:

**Benefits**:
- Quick navigation to specific analyses
- Clear overview of notebook structure
- Professional presentation
- Easier for collaborators

**Implementation** (Markdown cell):
```markdown
# Analysis Name

## Table of Contents

1. [Data Loading](#data-loading)
2. [Data Quality Metrics](#data-quality-metrics)
3. [Figure 1: Completeness](#figure-1-completeness)
4. [Figure 2: Contiguity](#figure-2-contiguity)
5. [Figure 3: Scaffold Validation](#figure-3-scaffold-validation)
...
10. [Methods](#methods)
11. [References](#references)

---
```

**Section Headers** (Markdown cells):
```markdown
## Data Loading

[Your code/analysis]

---

## Data Quality Metrics

[Your code/analysis]
```

**Auto-generation**: For large notebooks, consider generating TOC programmatically:
```python
from IPython.display import Markdown

sections = ['Introduction', 'Data Loading', 'Analysis', ...]
toc = "## Table of Contents\n\n"
for i, section in enumerate(sections, 1):
    anchor = section.lower().replace(' ', '-')
    toc += f"{i}. [{section}](#{anchor})\n"

display(Markdown(toc))
```

### Methods Documentation

Always include a Methods section documenting:
- Data sources with accession numbers
- Key algorithms and formulas
- Statistical approaches
- Software versions
- Special adjustments (e.g., sex chromosome correction)
- Literature citations

**Example**:
```markdown
## Methods

### Karyotype Data

Karyotype data (diploid 2n and haploid n chromosome numbers) was manually curated from peer-reviewed literature for 97 species representing 17.8% of the VGP Phase 1 dataset (n = 545 assemblies).

#### Sex Chromosome Adjustment

When both sex chromosomes are present in the main haplotype, the expected number of chromosome-level scaffolds is:

**expected_scaffolds = n + 1**

For example:
- Asian elephant: 2n=56, n=28, has X+Y → expected 29 scaffolds
- White-throated sparrow: 2n=82, n=41, has Z+W → expected 42 scaffolds

This adjustment accounts for the biological reality that X and Y (or Z and W) are distinct chromosomes.
```

### Writing Style Matching
To match manuscript style:
- Read draft paper PDF to extract tone and terminology
- Use same technical vocabulary
- Match paragraph structure (observation → mechanism → implication)
- Include specific details (tool names, file formats, software versions)
- Use first-person plural ("we") if paper does
- Maintain consistent bullet point/list formatting

### Example Code Pattern
```python
# Display figure
from IPython.display import Image, display
from pathlib import Path

FIG_DIR = Path('figures/analysis_name')
display(Image(filename=str(FIG_DIR / 'figure_01.png')))
```

### Figure Legend Format
**Figure N. [Short title].** [Complete description of panels and what's shown]. [Statistical tests used]. [Sample sizes]. [Scale information]. [Color coding].

### Analysis Paragraph Structure
1. **What it measures** - Define the metric/comparison
2. **Statistical result** - Quantitative findings with p-values
3. **Mechanistic explanation** - Why this result occurs
4. **Implications** - What this means for conclusions

### Methods Section Must Include
- Dataset source and filtering criteria
- Metric definitions
- Outlier handling approach
- Statistical methods with justification
- Software versions and tools
- Reproducibility information
- Known limitations

This approach creates notebooks that serve both as analysis documentation and as supplementary material for publications.

### Environment Setup

For CLI-based workflows (Claude Code, SSH sessions):

```bash
# Run in background with token authentication
/path/to/conda/envs/ENV_NAME/bin/jupyter lab --no-browser --port=8888
```

**Parameters**:
- `--no-browser`: Don't auto-open browser (for remote sessions)
- `--port=8888`: Specify port (default, can change if occupied)
- Run in background: Use `run_in_background=true` in Bash tool

**Access URL format**:
```
http://localhost:8888/lab?token=TOKEN_STRING
```

**To stop later**:
- Find shell ID from BashOutput tool
- Use KillShell with that ID

**Installation if missing**:
```bash
/path/to/conda/envs/ENV_NAME/bin/pip install jupyterlab
```

## Notebook Size Management

For notebooks > 256 KB:
- Use `jq` to read specific cells: `cat notebook.ipynb | jq '.cells[10:20]'`
- Count cells: `cat notebook.ipynb | jq '.cells | length'`
- Check sections: `cat notebook.ipynb | jq '.cells[75:81] | .[].source[:2]'`

## Managing Large Image Outputs in Notebooks

### Problem: Image Loading Errors

**Symptom**: Notebook displays "Output too large" or fails to load images when opening
**Cause**: High-DPI figures (300 DPI) combined with large figure sizes generate massive image outputs

### Solution: Optimize Figure DPI and Sizes

**For matplotlib/seaborn notebooks:**

```python
# In setup cell - set global defaults
plt.rcParams['figure.dpi'] = 150      # Reduced from 300
plt.rcParams['savefig.dpi'] = 150     # Reduced from 300
```

**In individual savefig calls:**
```python
# Also reduce figure dimensions
fig, axes = plt.subplots(2, 3, figsize=(12, 8))  # Was (15, 10)
# ... plotting code ...
plt.savefig('output.png', dpi=150, bbox_inches='tight')  # Was dpi=300
```

**Expected results:**
- File size reduction: ~75% (combination of DPI and size reduction)
- Still publication-quality: 150 DPI is sufficient for digital viewing and most journals
- Notebook remains viewable: Images load without errors

### When to Use Different DPI Settings

- **150 DPI**: Digital viewing, manuscript review, most online journals (recommended default)
- **300 DPI**: Print publication requirements, final submission only
- **72-96 DPI**: Presentations, slides, web display only

### Pattern: Update Existing High-DPI Notebooks

If you have a notebook with loading errors:

1. **Identify figure generation cells** (look for `plt.savefig`)
2. **Update setup cell** with reduced DPI settings
3. **Update figure sizes** in `plt.subplots(figsize=...)` calls
4. **Update savefig DPI** parameters
5. **Re-run cells** to regenerate optimized figures

**Example transformation:**
```python
# Before (causes loading errors)
plt.rcParams['savefig.dpi'] = 300
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
plt.savefig('figure.png', dpi=300, bbox_inches='tight')

# After (loads correctly)
plt.rcParams['savefig.dpi'] = 150
fig, axes = plt.subplots(2, 3, figsize=(12, 8))
plt.savefig('figure.png', dpi=150, bbox_inches='tight')
```

**Token efficiency note**: Use `jupyter nbconvert --to python` to extract code and identify all figure-generating cells quickly without reading full notebook.

### Updating Color Palettes Across Multiple Cells

**Pattern**: When changing visualization colors throughout a notebook:

1. **Identify palette definition cells** - Usually early in notebook (setup or prep cells)
2. **Update centralized color dictionary** - Change palette in one location
3. **Check for hardcoded colors** - Some cells may override the palette
4. **Update all override locations** - Use NotebookEdit for each cell

**Example: Updating from default to colorblind-safe palette**

```python
# Cell 1: Main palette definition
category_colors = {
    'Cat_A': '#0072B2',    # Blue (Okabe-Ito)
    'Cat_B': '#E69F00',    # Orange (Okabe-Ito)
    'Cat_C': '#CC79A7'     # Reddish Purple (Okabe-Ito)
}
```

```python
# Cell 2: Technology-specific palette (may need separate update)
tech_palette = {
    'Cat_A+Tech1': '#0072B2',
    'Cat_A+Tech2': '#56B4E9',
    'Cat_B+Tech1': '#E69F00',
    'Cat_C+Tech1': '#CC79A7',
    'Cat_C+Tech2': '#F0E442'
}
```

**Systematic update process**:
1. Update main `category_colors` dict
2. Update any `palette` or `tech_palette` dicts
3. Check for cells with hardcoded `color='#...'` parameters
4. Re-run affected visualization cells

**Token-efficient approach**: Use `jupyter nbconvert --to python | grep -n "color"` to find all color references before updating.

## Data Enrichment Pattern

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
    print("⚠️ Warning: Limited data for correlation analysis")
    print(f"  Metric A: {len(species_with_metric_a)} species")
    print(f"  Metric B: {len(species_with_metric_b)} species")
    print(f"  Overlap: {len(overlap)} species")
```

### Variable State Validation

When debugging notebook errors, add validation cells to check variable integrity:

```python
# Validation cell - place before error-prone sections
print('=== VARIABLE VALIDATION ===')
print(f'Type of data: {type(data)}')
print(f'Is data a list? {isinstance(data, list)}')

if isinstance(data, list):
    print(f'Length: {len(data)}')
    if len(data) > 0:
        print(f'First item type: {type(data[0])}')
        print(f'First item keys: {list(data[0].keys())[:10]}')
elif isinstance(data, dict):
    print(f'⚠️  WARNING: data is a dict, not a list!')
    print(f'Dict keys: {list(data.keys())[:10]}')
    print(f'This suggests variable shadowing occurred.')
```

**When to use**:
- After "Restart & Run All" produces errors
- When error messages suggest wrong variable type
- Before cells that fail intermittently
- In notebooks with 50+ cells

**Best practice**: Include automatic validation in cells that depend on critical global variables.

## Programmatic Notebook Manipulation

### Legacy Method: JSON Manipulation (Use NotebookEdit Instead)

**⚠️ Deprecated**: Use NotebookEdit tool for most operations. Only use JSON manipulation for:
- Bulk cell reordering
- Complex conditional operations
- Custom cell metadata manipulation

When inserting cells into large notebooks using JSON:

```python
import json

# Read notebook
with open('notebook.ipynb', 'r') as f:
    notebook = json.load(f)

# Create new cell
new_cell = {
    "cell_type": "code",
    "execution_count": None,
    "metadata": {},
    "outputs": [],
    "source": [line + '\n' for line in code.split('\n')]
}

# Insert at position
insert_position = 50
notebook['cells'] = (notebook['cells'][:insert_position] +
                     [new_cell] +
                     notebook['cells'][insert_position:])

# Write back
with open('notebook.ipynb', 'w') as f:
    json.dump(notebook, f, indent=1)
```

### Reorganizing Notebook Sections

**When Needed:**
- Statistical significance changed (p-values updated)
- Need to regroup analyses by new criteria
- Logical flow improvement

**Bulk Cell Reordering Pattern:**

```python
import json

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Map figure numbers to cell ranges
figure_ranges = {
    1: (20, 26),  # Cells 20-25 contain Figure 1
    2: (4, 8),    # Cells 4-7 contain Figure 2
}

# Define new order
significant_figs = [2, 4, 5, 6, 7]
not_significant_figs = [1, 3]

# Build new cell list
new_cells = []
new_cells.extend(nb['cells'][0:3])  # Keep intro cells

# Add section header
section1_header = {
    'cell_type': 'markdown',
    'metadata': {},
    'source': ['## Section 1: Significant Results\n']
}
new_cells.append(section1_header)

# Add figures in new order
for fig_num in significant_figs:
    start, end = figure_ranges[fig_num]
    new_cells.extend(nb['cells'][start:end])

# Replace cells
nb['cells'] = new_cells

# Save
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**After Reorganization:**
- Regenerate Table of Contents to reflect new structure
- Verify all cross-references still work
- Update section numbering if needed


### Bulk Find-and-Replace Operations

**When Needed**:
- Renumbering figures after deletions (Figure 6→5, Figure 7→6, etc.)
- Updating terminology across multiple cells
- Changing file paths or references

**Pattern**: Use Python JSON manipulation for bulk updates across many cells

```python
import json

# Load notebook
with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Find and modify cells
for i, cell in enumerate(nb['cells']):
    if cell.get('cell_type') == 'markdown':
        source = ''.join(cell.get('source', []))
        
        # Make replacements
        new_source = source.replace('Figure 7', 'Figure 6')
        new_source = new_source.replace('Figure 6', 'Figure 5')
        
        # Update cell source - split back to lines
        cell['source'] = new_source.split('\n')
        
        # Preserve trailing newline if present
        if cell['source'] and not cell['source'][-1]:
            cell['source'][-1] = '\n'
    
    elif cell.get('cell_type') == 'code':
        source = ''.join(cell.get('source', []))
        
        # Update image filenames
        new_source = source.replace('06_telomere.png', '05_telomere.png')
        cell['source'] = [new_source]

# Save
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**Delete multiple cells** in reverse order to maintain indices:
```python
cells_to_delete = [10, 11, 12]  # Identified cell indices

for idx in sorted(cells_to_delete, reverse=True):
    print(f"Deleting cell {idx}")
    del nb['cells'][idx]

# Save after all deletions
with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**Best Practice**: 
- Use **NotebookEdit tool** for single-cell updates (cleaner, safer)
- Use **Python JSON** for bulk operations affecting 5+ cells
- Always work on a copy first when doing bulk operations
- Test changes by reopening notebook in Jupyter

### Synchronizing Figure Code and Notebook Documentation

**Pattern**: Code changes to figure generation → Must update notebook text

**Common Scenario**: Updated figure filtering/outlier removal/statistical tests

**Workflow**:
1. Update figure generation Python script
2. Regenerate figures
3. **CRITICAL**: Update Jupyter notebook markdown cells documenting the figure
4. Use `NotebookEdit` tool (NOT `Edit` tool) for `.ipynb` files

**Example**:
```python
# After adding Mann-Whitney test to figure generation:
NotebookEdit(
    notebook_path="/path/to/notebook.ipynb",
    cell_id="cell-14",  # Found via grep or Read
    cell_type="markdown",
    new_source="Updated description mentioning Mann-Whitney test..."
)
```

**Finding Figure Cells**:
```bash
# Locate figure references
grep -n "figure_name.png" notebook.ipynb

# Or use Glob + Grep
grep -n "Figure 4" notebook.ipynb
```

**Why Critical**: Outdated documentation causes confusion. Notebook text saying "Limited data" when data is now complete, or not mentioning new statistical tests, misleads readers.

### Preserving Newlines in Cell Source

Jupyter notebook cells store source as a **list of strings**, where each string typically ends with `\n`.

**Common pitfall**: String replacement that collapses multi-line code into a single string without newlines.

**❌ Wrong - produces malformed code cell:**
```python
# This creates a single-line string without newlines
cell['source'] = "# Comment\nimport pandas\ndf = pd.read_csv('file.csv')"
# Result in notebook: "# Commentimport pandasdf = pd.read_csv('file.csv')"  ← No line breaks!
```

**✅ Correct - preserves line structure:**
```python
cell['source'] = [
    "# Comment\n",
    "import pandas\n",
    "df = pd.read_csv('file.csv')"
]
# Result: Proper multi-line code cell with preserved formatting
```

**Debugging tip**: If a cell displays as single-line garbage, check the source format:
```python
print(repr(nb['cells'][26]['source']))  # Should show list with \n characters
```

**When updating cell content programmatically:**
1. Always use list of strings format
2. End each line with `\n` (except optionally the last)
3. Test by viewing the notebook afterward

**Example - Updating a cell while preserving formatting:**
```python
import json

with open('notebook.ipynb', 'r') as f:
    nb = json.load(f)

# Find the cell to update
for cell in nb['cells']:
    if 'Final Tree.svg' in ''.join(cell.get('source', [])):
        # Update filename while preserving line structure
        cell['source'] = [
            "# Display phylogenetic tree\n",
            "from IPython.display import SVG, display\n",
            "display(SVG(filename='phylo/Final Tree_cropped.svg'))"
        ]

with open('notebook.ipynb', 'w') as f:
    json.dump(nb, f, indent=1)
```

**Key lesson**: When you see a cell that "seems off" or "the image is not displayed", check if the source is a single string without newlines. This is a common error when using string replacement on cell content.

## Exporting Notebooks for Sharing

### Export Workflow for Distribution

When preparing notebooks for sharing with collaborators or supplementary materials:

**HTML Export (Recommended)**
```bash
# Activate environment with nbconvert
conda activate your_env

# Export to HTML (all figures embedded, opens in browser)
python -m nbconvert --to html --output shared/Analysis.html Analysis.ipynb
```

**Why HTML is best for sharing:**
- ✅ No software required - opens in any browser
- ✅ All figures embedded (no missing images)
- ✅ Self-contained single file
- ✅ Fully interactive (shows code and outputs)
- ✅ Works on any platform

**LaTeX/PDF Export**
```bash
# Requires pandoc (install: conda install -c conda-forge pandoc)
python -m nbconvert --to latex --output shared/Analysis.tex Analysis.ipynb

# Then compile with xelatex (handles Unicode better than pdflatex)
cd shared
xelatex -interaction=nonstopmode Analysis.tex
```

**Common Issue: Nested Image Paths**

nbconvert creates a `Analysis_files/` directory, but may nest it incorrectly:
```bash
# Problem: Images at Analysis_files/shared/Analysis_11_0.png
# LaTeX looks for: shared/Analysis_files/shared/Analysis_11_0.png

# Fix: Flatten the directory structure
mv Analysis_files/shared/* Analysis_files/
rmdir Analysis_files/shared

# Recompile
xelatex -interaction=nonstopmode Analysis.tex
```

**Prerequisites Check:**
```bash
# Check if pandoc installed
conda list pandoc

# Install if missing
conda install -c conda-forge pandoc

# For PDF, also need LaTeX
# macOS: brew install basictex
# Ubuntu: apt-get install texlive-xetex
```

### Path Verification Before Export

**Critical: Verify all image and data paths work in export context**

```python
# In notebook, check if paths are relative (good) or absolute (bad)
import os
from pathlib import Path

# ✅ GOOD: Relative paths work when notebook is moved
display(Image('figures/fig1.png'))
df = pd.read_csv('data/results.csv')

# ❌ BAD: Absolute paths break when sharing
display(Image('/Users/yourname/project/figures/fig1.png'))
df = pd.read_csv('/Users/yourname/project/data/results.csv')
```

**Test before sharing:**
1. Copy notebook to temporary directory
2. Try to run it there
3. Check all images load
4. Verify data files found

### Export Comparison

| Format | Size | Requires Software | Figures | Best For |
|--------|------|-------------------|---------|----------|
| **HTML** | 3-5 MB | None (browser) | Embedded | Quick sharing, presentations |
| **PDF** | Variable | PDF reader | Embedded | Print, formal documents |
| **LaTeX** | 100 KB | LaTeX compiler | External | Editing, customization |
| **ipynb** | 2-4 MB | Jupyter/VS Code | External | Reproducibility, collaboration |

### Troubleshooting Exports

**HTML export fails:**
```bash
# Missing nbconvert
conda install -c conda-forge nbconvert

# Missing pandoc
conda install -c conda-forge pandoc
```

**PDF has missing figures:**
- Check image paths are relative, not absolute
- Verify images exist in expected locations
- Look at `.log` file for specific errors

**PDF compilation hangs:**
- Large notebooks may timeout
- Use HTML instead for very large analyses
- Or split into smaller notebooks

**Figures show as broken links:**
- Images not found at specified paths
- Convert absolute paths to relative paths
- Ensure `figures/` directory included when sharing

## Notebook Outputs in Sharing Packages

### CRITICAL: Preserve Outputs When Sharing

**IMPORTANT: DO NOT clear notebook outputs when preparing sharing packages**

#### Why Outputs Must Be Preserved

1. **Documentation**: Outputs show the analysis results and are part of the documentation
2. **HTML versions**: HTML exports need outputs to display figures and results
3. **Quick review**: Recipients can view results without running code
4. **Reproducibility proof**: Outputs show what the analysis produced
5. **Figure embeddings**: Images and plots are embedded in outputs
6. **Professional presentation**: Complete notebooks look polished and finished

#### Wrong Approach

```python
# ❌ DO NOT DO THIS
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

# This removes all outputs - WRONG for sharing packages!
nb = nbformat.read(notebook_path, as_version=4)
clear = ClearOutputPreprocessor()
nb, _ = clear.preprocess(nb, {})  # Removes all outputs
nbformat.write(nb, notebook_path)
```

**Problems with clearing outputs:**
- HTML files will show empty cells instead of results
- Figures won't be visible
- Statistical results invisible
- Recipients must run code to see anything
- Defeats purpose of sharing analysis

#### Correct Approach

```python
# ✅ DO THIS: Copy notebooks as-is, preserving outputs
import shutil
shutil.copy2(notebook_path, share_dir)
```

**Proper path fixes without clearing outputs:**
```python
import json

# Read notebook as JSON (no nbformat dependency)
with open(notebook_path, 'r') as f:
    nb = json.load(f)

# Fix paths in source code only (outputs untouched)
for cell in nb['cells']:
    if cell['cell_type'] == 'code':
        source = ''.join(cell['source'])
        # Fix paths in source...
        source = source.replace('old/path/', 'new/path/')
        cell['source'] = source.split('\n')

# Write back (outputs preserved)
with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=1)
```

### When to Clear Outputs (Rare Cases Only)

**Only clear outputs when:**

1. **Development notebooks** with sensitive data in outputs
   - Example: API keys accidentally printed
   - Example: Protected health information in debug output

2. **Test notebooks** with excessive debug output
   - Example: 1000+ lines of debug prints
   - Example: Large temporary data dumps

3. **NEVER** for analysis notebooks in sharing packages
   - Recipients need to see the results
   - HTML versions require outputs
   - Outputs are the analysis documentation

### Verification Checklist

Before sharing notebooks:
- [ ] Outputs are present (cells show results)
- [ ] Figures display correctly
- [ ] Statistical results visible
- [ ] HTML conversion includes all content
- [ ] No sensitive information in outputs
- [ ] File paths work (data files, figures)

### HTML Export Verification

```bash
# Convert to HTML to verify outputs present
jupyter nbconvert --to html notebook.ipynb

# Check HTML file size
ls -lh notebook.html
# Analysis notebooks with outputs: 3-5 MB (good)
# Notebooks without outputs: <500 KB (missing outputs!)

# Open HTML and verify:
# - Figures are visible
# - Tables and dataframes display
# - Statistical results show
```

### Common Mistake Pattern

```python
# ❌ WRONG: User asks to prepare sharing package,
#          Claude clears outputs "to clean the notebook"
# This is a common misunderstanding - outputs ARE the analysis!

# ✅ CORRECT: User asks to prepare sharing package,
#           Claude copies notebooks with outputs intact
#           Only fixes paths if needed
```

### Best Practice for Sharing

**Sharing package should include:**
1. **Notebook with outputs** (.ipynb) - For technical recipients
2. **HTML version** (.html) - For quick viewing by anyone
3. **Pre-generated figures** (PNG/SVG) - As standalone files
4. **Data files** - For full reproducibility

**Example sharing package:**
```
shared-2026-02-05-analysis/
├── Curation_Impact_Analysis.ipynb    # WITH outputs
├── Curation_Impact_Analysis.html     # Converted from notebook with outputs
├── figures/
│   └── curation_impact/
│       ├── 01_scaffold_n50.png       # Standalone figures
│       └── 02_scaffold_count.png
└── data/
    └── vgp_assemblies.csv
```

**Result**: Recipients can:
- View HTML immediately (no setup needed)
- Open notebook and see results
- Run notebook to reproduce
- Use standalone figures in presentations

## Best Practices Summary

1. **Always check data availability** before creating analyses
2. **Document outlier removal** clearly in titles and comments
3. **Use consistent naming** for variables and figures
4. **Include statistical testing** for all correlations
5. **Separate visualization from statistics** when filtering outliers
6. **Create templates** for repetitive analyses
7. **Use helper functions** consistently across cells
8. **Organize with markdown headers** for navigation
9. **Test with small datasets** before running full analyses
10. **Save intermediate results** for expensive computations
11. **Use NotebookEdit tool** for all `.ipynb` file modifications

## Common Tasks

### Removing Panels from Multi-Panel Figures

**Scenario**: Convert 2-panel figure to 1-panel after removing unavailable data.

**Steps**:
1. **Update subplot layout**:
   ```python
   # Before: 2 panels
   fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

   # After: 1 panel
   fig, ax = plt.subplots(1, 1, figsize=(10, 6))
   ```

2. **Remove panel code**: Delete all code for removed panel (ax2)

3. **Update figure filename**:
   ```python
   # Before
   plt.savefig('06_scaffold_l50_l90_comparison.png')

   # After
   plt.savefig('06_scaffold_l50_comparison.png')
   ```

4. **Update notebook references**:
   - Image display: `display(Image(...'06_scaffold_l50_comparison.png'))`
   - Title: Remove references to removed data
   - Description: Add note about why panel is excluded

5. **Clean up old files**:
   ```bash
   rm figures/*_l50_l90_*.png
   ```
