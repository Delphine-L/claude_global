---
name: jupyter-notebook-analysis
description: Patterns for analyzing, improving, and documenting Jupyter notebooks for scientific data analysis. Includes data filtering, visualization optimization, and resource analysis techniques.
---

# Jupyter Notebook Analysis

## Data Filtering Patterns

### Regex-based Dataset Filtering

When filtering datasets for official/production data vs test/experimental data:

**Pattern**: Use inclusion + exclusion pattern approach
```python
def is_official_workflow(name):
    """Filter for official workflows, excluding test runs."""

    # Exclusion patterns (what to remove)
    exclusion_patterns = [
        r'^Export',           # Utility workflows
        r'test\d',            # test1, test2, etc.
        r'Attempt\d',         # Retry runs
        r'^Copy of',          # User copies
        r'^\d+\.',            # Numbered prefixes (1. 2. etc.)
        r'training workflow', # Tutorial/training
    ]

    # Inclusion patterns (what to keep)
    inclusion_patterns = [
        r'VGP[0-9]',         # Official workflow numbers
        r'v\d+\.\d+',        # Version numbers
        r'release v',        # Release tags
        r'WORKFLOW REPORT TEST', # Report testing (not execution)
    ]

    # Check exclusions first
    for pattern in exclusion_patterns:
        if re.search(pattern, name, re.IGNORECASE):
            return False

    # Then check if it matches inclusions
    for pattern in inclusion_patterns:
        if re.search(pattern, name, re.IGNORECASE):
            return True

    return False
```

**Why this matters**: Prevents analysis noise from test/debug runs while preserving legitimate test workflows (e.g., report generation tests).

### Name Normalization for Version Grouping

When analyzing data with multiple versions of the same entity:

```python
def normalize_name(name):
    """Group different versions under canonical names."""

    canonical_names = {
        'VGP0': 'Mitogenome Assembly (VGP0)',
        'VGP1': 'K-mer Profiling (VGP1)',
        # ... etc
    }

    # Extract identifier (handles VGP/WF variations)
    match = re.search(r'(VGP|WF)(\d+b?)', name, re.IGNORECASE)
    if match:
        workflow_num = match.group(2)
        workflow_id = f'VGP{workflow_num}'  # Normalize WF to VGP
        return canonical_names.get(workflow_id, f'VGP Workflow ({workflow_id})')

    return name
```

**Impact**: Reduces 86 unique workflow names to 12 canonical types for meaningful comparisons.

### Analysis-Specific Data Subsetting

**Use Case**: Different analyses within same notebook need different data requirements

**Pattern**: Create named subsets rather than filtering the main dataset

```python
# Load complete dataset
with open('data.json') as f:
    data = json.load(f)  # Keep original for general analysis

# Create analysis-specific subsets
data_with_species = [
    item for item in data
    if item.get('species_id') and item.get('genome_size')
]

data_with_timestamps = [
    item for item in data
    if item.get('start_time') and item.get('end_time')
]

# Report dataset composition
print(f'📊 Dataset Summary:')
print(f'  • Total items: {len(data)}')
print(f'  • With species linkage: {len(data_with_species)} ({len(data_with_species)/len(data)*100:.1f}%)')
print(f'  • With timing data: {len(data_with_timestamps)} ({len(data_with_timestamps)/len(data)*100:.1f}%)')
print()
print(f'  ℹ️  Analysis Strategy:')
print(f'     - General resource analysis: ALL {len(data)} items')
print(f'     - Genome size correlation: {len(data_with_species)} items with species data')
print(f'     - Temporal analysis: {len(data_with_timestamps)} items with timestamps')
```

**Documentation in Notebook**:
Add clear markdown cells before each analysis section:

```markdown
**Important Note**:
- **General resource analyses** use the **complete dataset** of all items
- **This genome correlation section** uses only the **subset with Species IDs**
```

**Benefits**:
- Maximizes data usage (don't discard items for analyses that don't need all fields)
- Clear documentation of what data each analysis uses
- Prevents confusion about different result counts
- Enables transparent reporting of data availability

**Example**: VGP workflow analysis
- Full dataset (1,630 invocations): Tool-level resource analysis, workflow timing
- Species subset (740 invocations): Genome size vs memory correlation
- Both analyses valid and informative

## Resource Analysis Patterns

### Tool-Level Resource Over-Allocation Analysis

Pattern for identifying tools wasting resources:

```python
# Calculate waste
df['wasted_memory_gb'] = df['allocated_memory_gb'] - df['peak_memory_gb']
df['memory_utilization_pct'] = (df['peak_memory_gb'] / df['allocated_memory_gb'] * 100)

# Aggregate by tool
tool_analysis = df.groupby('tool_name').agg({
    'wasted_memory_gb': ['sum', 'mean', 'median'],
    'memory_utilization_pct': ['mean', 'median'],
    'allocated_memory_gb': ['mean', 'median'],
    'peak_memory_gb': ['mean', 'median'],
    'job_id': 'count'  # Number of jobs
}).round(2)

# Sort by total waste to prioritize optimization
tool_analysis = tool_analysis.sort_values(('wasted_memory_gb', 'sum'), ascending=False)
```

**Actionable outputs**:
- Top tools by total wasted resources
- Average utilization % (color-coded: <25% red, <50% orange, ≥50% green)
- Potential savings estimates (70% of waste typically recoverable)

### Wallclock vs Cumulative Runtime Analysis

For workflow parallelization analysis:

```python
# Calculate wallclock time per workflow execution
wallclock_data = df.groupby(['workflow_id', 'workflow_type']).agg({
    'start_epoch': 'min',  # First job start
    'end_epoch': 'max',    # Last job end
    'runtime_hours': 'sum' # Cumulative runtime
})

wallclock_data['wallclock_hours'] = (
    wallclock_data['end_epoch'] - wallclock_data['start_epoch']
) / 3600

wallclock_data['parallelization_factor'] = (
    wallclock_data['runtime_hours'] / wallclock_data['wallclock_hours']
)
```

**Key metric - Parallelization Factor**:
- **High (>5x)**: Good parallelization
- **Medium (2-5x)**: Moderate parallelization
- **Low (<2x)**: Sequential bottlenecks or inefficient parallelization

**Use cases**:
- Estimate real completion times for workflow planning
- Identify workflows that could benefit from architectural improvements
- Understand resource requirements vs actual completion time

## Visualization Optimization

### Outlier Removal for Clarity

When scatter plots are obscured by extreme outliers:

```python
# Remove top 5% for visualization only
threshold = df['metric'].quantile(0.95)
df_viz = df[df['metric'] <= threshold]

# Use full dataset for statistics
print(f"Mean (all data): {df['metric'].mean():.2f}")
print(f"Median (all data): {df['metric'].median():.2f}")
print(f"\nVisualization uses {len(df_viz)/len(df)*100:.1f}% of data")
print(f"Removed {len(df) - len(df_viz)} outliers for clarity")

# Plot with filtered data
plt.scatter(df_viz['x'], df_viz['y'])
plt.title('Scatter Plot (top 5% outliers removed for clarity)')
```

**Important**: Always clarify in plot subtitle and console output what was filtered.

## Tool ID Parsing

### Galaxy Tool Shed ID Extraction

Galaxy tool IDs format: `toolshed.g2.bx.psu.edu/repos/owner/repo/toolname/version`

**Correct extraction** (tool name is second-to-last element):
```python
def extract_tool_name(tool_id):
    if tool_id:
        parts = tool_id.split('/')
        if len(parts) >= 2:
            return parts[-2]  # Tool name (NOT parts[-1] which is version)
        return tool_id
    return 'Unknown'
```

**Common mistake**: Using `parts[-1]` returns version (e.g., "3+galaxy0") instead of tool name (e.g., "mitohifi").

## Testing Strategies

### Standalone Test Scripts

Create simple test scripts without heavy dependencies for quick validation:

```python
#!/usr/bin/env python3
"""Test filtering logic without requiring pandas/jupyter"""
import re
import json

def filter_function(name):
    # ... filter logic
    pass

# Load test data from JSON
with open('test_data.json') as f:
    test_cases = json.load(f)

# Test and report
all_passed = True
for test in test_cases:
    result = filter_function(test['name'])
    expected = test['expected']
    if result != expected:
        print(f"✗ FAIL: {test['name']}")
        all_passed = False
    else:
        print(f"✓ PASS: {test['name']}")

print('\n' + '='*80)
print('✓ ALL TESTS PASSED' if all_passed else '✗ SOME TESTS FAILED')
```

**Benefits**:
- No conda environment needed
- Fast execution
- Easy to share and run independently
- Can validate logic before modifying notebook

### Diagnosing Wrong File Loads

**Symptom**: Expected data fields missing (e.g., "no metrics found", "no species IDs found")

**Root Cause**: Often loading wrong file with similar name but different contents

**Diagnostic Pattern**:
```python
import json

# Compare what's in each file
files_to_check = [
    'enriched_data.json',
    'metrics_data.json',
    'merged_data.json'
]

for filepath in files_to_check:
    try:
        with open(filepath) as f:
            data = json.load(f)

        print(f'\n📄 {filepath}')
        print(f'   Items: {len(data)}')

        if data:
            sample = data[0]
            print(f'   Keys: {list(sample.keys())[:10]}...')  # First 10 keys

            # Check for critical fields
            has_species = sum(1 for item in data if item.get('species_id'))
            has_metrics = sum(1 for item in data if item.get('metrics'))

            print(f'   With species_id: {has_species} ({has_species/len(data)*100:.1f}%)')
            print(f'   With metrics: {has_metrics} ({has_metrics/len(data)*100:.1f}%)')
    except FileNotFoundError:
        print(f'\n📄 {filepath} - NOT FOUND')
    except Exception as e:
        print(f'\n📄 {filepath} - ERROR: {e}')
```

**Common Issues**:

1. **Loading enrichment file instead of merged file**
   - Has species_id ✓
   - Has metrics ✗
   - **Fix**: Change to merged file

2. **Loading metrics file instead of merged file**
   - Has species_id ✗
   - Has metrics ✓
   - **Fix**: Change to merged file or run merge step

3. **Loading old file after pipeline update**
   - Missing new fields
   - **Fix**: Re-run pipeline to regenerate file

**Preventive Measures**:
- Add file validation in load cell:
  ```python
  with open('data.json') as f:
      data = json.load(f)

  # Validate expected fields
  if not data:
      print('⚠️ ERROR: File is empty!')
  else:
      with_metrics = sum(1 for item in data if item.get('metrics'))
      if with_metrics == 0:
          print(f'⚠️ WARNING: No metrics found! Are you loading the right file?')
  ```

## Documentation Patterns

### Two-Level Documentation

Maintain both detailed technical docs and quick start guides:

1. **IMPROVEMENTS_SUMMARY.md**: Comprehensive technical documentation
   - Detailed methodology
   - Code examples
   - Cell IDs for notebook navigation
   - Testing procedures
   - Troubleshooting

2. **QUICK_START.md**: User-friendly execution guide
   - Expected results
   - Example outputs
   - Visual indicators of success
   - Simple troubleshooting
   - Next steps

**User benefit**: Technical users get details, casual users get quick wins.

## Galaxy API Data Enrichment

### Enriching Invocations with Inputs and History Names

When analyzing Galaxy workflow executions, basic invocation data lacks workflow inputs and history context needed for linking with external datasets (e.g., genome characteristics).

**Problem**: Default `/api/invocations` endpoint returns minimal data:
- Invocation ID, workflow ID, history ID, state, timestamps
- **Missing**: workflow inputs, history names, input dataset details

**Solution**: Use BioBlend to fetch full invocation and history details

```python
from bioblend.galaxy import GalaxyInstance

def enrich_invocations_with_inputs_and_history(invocations, gi, skip_existing=True):
    """
    Enrich invocations with workflow inputs and history names.

    Returns invocations with added fields:
    - inputs: Dictionary of workflow input datasets
    - history_name: Name of Galaxy history (often contains identifiers)
    """
    enriched = []

    for inv in invocations:
        # Skip if already enriched
        if skip_existing and 'inputs' in inv and 'history_name' in inv:
            enriched.append(inv)
            continue

        # Get full invocation details (includes inputs)
        full_invocation = gi.invocations.show_invocation(inv['id'])
        inv['inputs'] = full_invocation.get('inputs', {})

        # Get history name
        history_details = gi.histories.show_history(inv['history_id'])
        inv['history_name'] = history_details.get('name', '')

        enriched.append(inv)
        time.sleep(0.2)  # Rate limiting

    return enriched
```

### Extracting Identifiers from History Names

**Use case**: VGP (Vertebrate Genomes Project) uses Species IDs (ToLIDs) in history names

**Pattern**: VGP ToLIDs follow format `[a-z][A-Z][a-z]{2}[A-Z][a-z]{2,3}\d+`
- Examples: aGasCar1 (amphibian), bAcrTri1 (bird), fHopMal1 (fish), mBalRic1 (mammal)

```python
import re

def extract_species_id(invocation):
    """Extract VGP Species ID from history name or inputs."""

    tolid_pattern = r'\b([a-z][A-Z][a-z]{2}[A-Z][a-z]{2,3}\d+)\b'

    # Check history name first
    history_name = invocation.get('history_name', '')
    if history_name:
        match = re.search(tolid_pattern, history_name)
        if match:
            return match.group(1)

    # Fallback to inputs
    inputs = invocation.get('inputs', {})
    if inputs:
        match = re.search(tolid_pattern, str(inputs))
        if match:
            return match.group(1)

    return None
```

### Linking with External Data

Once identifiers are extracted, link with external datasets:

```python
import pandas as pd

# Load external data (e.g., genome characteristics)
genome_data = pd.read_csv('genome_metadata.tsv', sep='\t')

# Enrich invocations
for inv in invocations:
    species_id = extract_species_id(inv)
    if species_id:
        inv['species_id'] = species_id

        # Link with genome data
        genome_row = genome_data[genome_data['ToLID'] == species_id]
        if not genome_row.empty:
            inv['genome_size'] = genome_row['Genome size'].values[0]
            inv['heterozygosity'] = genome_row['Heterozygosity'].values[0]

# Now analyze: correlate resource usage with genome characteristics
```

**Performance**:
- ~0.2s per invocation (2 API calls: show_invocation + show_history)
- For 2,330 invocations: ~8-12 minutes
- ~4,660 API calls total

**Benefits**:
- Links computational resource usage with biological characteristics
- Enables analysis: "Do larger genomes require more memory?"
- Tracks which species were processed by which workflows

## Complete Data Fetching Pipelines

### Multi-Step Pipeline with Automatic Pagination

For complex data fetching from APIs (e.g., Galaxy, GitHub), structure as incremental pipeline:

**Pattern**:
```
Step 1: Fetch base data (auto-paginated)
   ↓
Step 2: Filter to relevant subset
   ↓
Step 2.5: Enrich filtered data with additional API calls
   ↓
Step 3: Fetch detailed metrics
   ↓
Step 4: Fetch granular details (parallelized)
```

**Why incremental**:
- Resume capability at each step
- Save filtered data before expensive API calls
- Easier debugging (inspect intermediate outputs)
- Better progress tracking

**Implementation**:

```python
# Step 1: Auto-paginated fetch
def fetch_with_pagination(user_id, limit=100, skip_existing=True):
    offset = 0
    all_data = []

    while True:
        # Fetch page
        data = api_fetch(offset=offset, limit=limit)

        # Stop if empty
        if len(data) == 0:
            break

        all_data.extend(data)

        # Stop if less than limit (reached end)
        if len(data) < limit:
            break

        offset += limit

    return all_data

# Step 2: Filter
filtered = [item for item in all_data if is_relevant(item)]

# Step 2.5: Enrich (only filtered items)
enriched = enrich_with_additional_data(filtered)

# Step 3: Detailed fetch (only enriched items)
with_details = fetch_details(enriched)
```

**Resume pattern**:
```python
# Each step saves to dated file
step1_file = f'base_data_{date}.json'
step2_file = f'filtered_data_{date}.json'
step25_file = f'enriched_data_{date}.json'

# Can restart from any step by loading intermediate file
if os.path.exists(step25_file):
    with open(step25_file) as f:
        enriched = json.load(f)
    # Skip to step 3
```

**Benefits**:
- Reduced API calls (only enrich what you need)
- Resume from failures without re-fetching everything
- Clear progress tracking
- Easier to add new enrichment steps

### Independent Step Execution Pattern

**Problem**: Users want to re-run enrichment steps (e.g., with different regex patterns) without re-running expensive fetch steps.

**Solution**: Add configuration cell that allows loading from existing file OR using pipeline variable

**Implementation**:
```python
# Configuration cell (place before enrichment step)
LOAD_FROM_FILE = False  # Set to True to load from existing file
DATA_FILE = f'filtered_data_{date_string}.json'

# Execution cell
if LOAD_FROM_FILE:
    print(f'📂 Loading data from file: {DATA_FILE}')
    with open(DATA_FILE, 'r') as f:
        data_to_process = json.load(f)
    print(f'   • Loaded: {len(data_to_process)} items')
else:
    try:
        data_to_process = filtered_data  # From previous step
        print(f'📋 Using data from previous step: {len(data_to_process)} items')
    except NameError:
        print('⚠️ ERROR: "filtered_data" variable not found.')
        print('   Set LOAD_FROM_FILE = True to load from file instead.')
        data_to_process = []

# Enrichment step uses data_to_process regardless of source
enriched = enrich_function(data_to_process)
```

**User Benefits**:
1. **Time savings**: Skip 15-30 min of fetch/filter steps
2. **Flexibility**: Re-run enrichment with different settings
3. **Testing**: Test extraction patterns without full pipeline
4. **Debugging**: Easier to diagnose enrichment issues

**Documentation Requirements**:
- Add "Running Step X Independently" section to README
- Include quick start guide for independent execution
- Add troubleshooting entry for "variable not found" error
- Update pipeline diagram to show optional entry points

**Backward Compatibility**:
- Default: `LOAD_FROM_FILE = False` (uses pipeline variable)
- Existing workflows unchanged
- No breaking changes to cell execution order

## Multi-Source Data Merging

### Problem: Complementary Data in Separate Files

When data pipelines produce separate outputs with complementary information:
- **Enrichment file**: Has identifiers/metadata but no metrics
- **Metrics file**: Has metrics but no identifiers/metadata

**Example**: Galaxy workflow analysis
- `enriched_data.json`: Species IDs, history names, inputs (no resource metrics)
- `metrics_data.json`: Memory, CPU, runtime metrics (no species linkage)

### Solution: ID-Based Dictionary Merge

**Pattern**:
```python
# Load both data sources
with open('enriched_data.json') as f:
    enriched = json.load(f)
with open('metrics_data.json') as f:
    metrics = json.load(f)

# Create lookup dictionary from enrichment data
enriched_dict = {item['id']: item for item in enriched}

# Merge: Add enrichment fields to metrics data
merged = []
for metric_item in metrics:
    item_id = metric_item['id']
    if item_id in enriched_dict:
        enriched_item = enriched_dict[item_id]
        # Add enrichment fields
        metric_item['species_id'] = enriched_item.get('species_id')
        metric_item['history_name'] = enriched_item.get('history_name')
        metric_item['inputs'] = enriched_item.get('inputs', {})
        merged.append(metric_item)

# Save merged result
with open('merged_data.json', 'w') as f:
    json.dump(merged, f, indent=2)

print(f'Merged {len(merged)} items')
print(f'With identifier: {sum(1 for item in merged if item.get("species_id"))}')
```

**Key Principles**:
1. **Choose primary dataset**: Use the one with most critical data (usually metrics) as base
2. **Lookup pattern**: Create dictionary from secondary dataset for O(1) lookups
3. **Preserve all primary data**: Don't filter out items without enrichment
4. **Track merge statistics**: Report how many items matched, have identifiers, etc.

**Integration with Pipeline**:
- Add merge step AFTER both data sources are complete
- Make merge step fast (<1 min) since it's local processing only
- Include in pipeline documentation with clear data flow diagram

**Benefits**:
- Automated merging (no manual file manipulation)
- Consistent results (same merge logic every time)
- Resume-friendly (can re-merge without re-fetching)
- Clear statistics for verification
