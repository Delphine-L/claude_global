# Best Practices and Common Scenarios

## Common Scenarios

### Scenario 1: User Asks to Install Package

**Bad (without checking):**
```
pip install pandas
```

**Good (with environment check):**
```
1. Check environment status
2. Show user what environment is active
3. Ask: "Is this the environment you want to use?"
4. Wait for confirmation
5. Then: pip install pandas (or conda install as appropriate)
```

### Scenario 2: Multiple Packages Needed

**User:** "Install pandas, numpy, and matplotlib"

**Response:**
```
Let me first check your environment...

[run environment detection]

I've detected: [environment details]

I need to install:
- pandas
- numpy
- matplotlib

Is this the correct environment? Should I use [pip/conda install -c conda-forge]?
```

### Scenario 3: User in Wrong Environment

**User:** "Install scikit-learn" (but they're in a different project's venv)

**Response:**
```
I've detected you're in a virtual environment at:
/path/to/other-project/.venv

But we're working in directory:
/path/to/current-project

This might be the wrong environment. Options:
1. Deactivate and create/activate the correct environment for this project
2. Continue with current environment (if this is intentional)
3. Cancel installation

Which would you prefer?
```

### Scenario 4: Conda Base Environment

**Detection:** User is in conda base environment

**Response:**
```
You're currently in the conda 'base' environment.

It's generally better practice to create a separate environment for each project
to avoid dependency conflicts.

Options:
1. Create a new conda environment for this project
2. Continue with base environment (not recommended)

Would you like me to create a project-specific environment?
```

---

## Best Practices

### 1. One Environment Per Project

**Good:**
```
project-a/
├── .venv/          # project-a's environment
├── requirements.txt
└── src/

project-b/
├── .venv/          # project-b's environment
├── requirements.txt
└── src/
```

**Bad:**
```
# Using same environment for multiple projects
# → Version conflicts inevitable
```

### 2. Document Environment Setup

Always create environment specification files:

**For venv:**
```bash
# Create requirements.txt
pip freeze > requirements.txt

# Or for development
pip freeze > requirements-dev.txt
```

**For conda:**
```bash
# Create environment.yml
conda env export > environment.yml

# Or minimal version
conda env export --from-history > environment.yml
```

### 3. Add Environment to .gitignore

For complete `.gitignore` templates, see the **folder-organization** skill.

Environment-specific entries:
```gitignore
# Python venv
.venv/
venv/
env/

# Conda
.conda/
```

### 4. Include Python Version

**For venv (in README):**
```
Python 3.11+ required
```

**For conda (in environment.yml):**
```yaml
name: myproject
dependencies:
  - python=3.11
  - pandas
  - numpy
```

---

## Resumable Data Fetch Scripts

### Pattern for Long-Running Data Retrieval

When building scripts that fetch data from external sources (APIs, S3, etc.), implement these patterns for robustness:

```python
def fetch_with_caching(item_id, output_dir):
    """Fetch data with local caching to support resume."""
    output_file = output_dir / f"{item_id}_data.txt"

    # Skip if already downloaded
    if output_file.exists():
        with open(output_file, 'r') as f:
            content = f.read()
        return True, "cached", content

    # Fetch logic here...
    # Save to file on success

    return success, status, content

def main():
    # Load existing results to skip completed work
    existing_csv = base_dir / 'results.csv'
    if existing_csv.exists():
        df_existing = pd.read_csv(existing_csv)
        existing_ids = set(df_existing['id'].tolist())
        df_to_process = df_to_process[~df_to_process['id'].isin(existing_ids)]
        print(f"Skipping {len(existing_ids)} items with existing data")

    # Process remaining items
    for item in df_to_process:
        success, status, data = fetch_with_caching(item, output_dir)
        # Process and accumulate results...

    # Merge with existing results
    if existing_csv.exists():
        df_existing = pd.read_csv(existing_csv)
        df_combined = pd.concat([df_existing, df_new], ignore_index=True)
    else:
        df_combined = df_new

    # Save combined results
    df_combined.to_csv(output_csv, index=False)
```

### Key Features

1. **File-level caching**: Save each fetch result immediately
2. **Resume capability**: Skip already-processed items automatically
3. **Incremental results**: Merge new results with existing data
4. **Interruption-safe**: Can be stopped and restarted without data loss

### Progress Tracking

```python
try:
    from tqdm import tqdm
    iterator = tqdm(items, total=len(items), desc="Processing")
except ImportError:
    print("(Install tqdm for progress bar: pip install tqdm)")
    iterator = items
```

### Rate Limiting

```python
import time

for item in items:
    result = fetch_data(item)
    if result.success:
        time.sleep(0.2)  # Be respectful to external services
```

This pattern makes scripts production-ready and user-friendly for long-running operations.
