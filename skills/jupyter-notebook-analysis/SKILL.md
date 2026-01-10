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
