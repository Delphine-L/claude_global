# Troubleshooting: Common Pitfalls, Debugging, and Validation

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

**Common shadowing patterns to avoid**:
```python
for data in dataset:          # Shadows 'data'
for i, data in enumerate():   # Shadows 'data'
for key, data in dict.items() # Shadows 'data'
```

### Cell Execution Order with NotebookEdit

**Problem**: When adding cells with `NotebookEdit`, variable definitions must come before usage, but cell numbering doesn't update automatically.

**Error Pattern**:
```python
# Cell 14: Uses aws_available
if aws_available:
    ...

# Cell 16: Defines aws_available
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
    print("Run previous cells first to define aws_available")
    aws_available = False
```

**Best Practice**: Always test notebooks with "Restart & Run All" after programmatic modifications to catch execution order issues.
- Run "Restart & Run All" regularly to catch issues early

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

## Variable State Validation

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
    print(f'WARNING: data is a dict, not a list!')
    print(f'Dict keys: {list(data.keys())[:10]}')
    print(f'This suggests variable shadowing occurred.')
```

**When to use**:
- After "Restart & Run All" produces errors
- When error messages suggest wrong variable type
- Before cells that fail intermittently
- In notebooks with 50+ cells

**Best practice**: Include automatic validation in cells that depend on critical global variables.

## Notebook Size Management

For notebooks > 256 KB:
- Use `jq` to read specific cells: `cat notebook.ipynb | jq '.cells[10:20]'`
- Count cells: `cat notebook.ipynb | jq '.cells | length'`
- Check sections: `cat notebook.ipynb | jq '.cells[75:81] | .[].source[:2]'`

## Environment Setup

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
