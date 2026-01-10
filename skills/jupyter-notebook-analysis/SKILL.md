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
