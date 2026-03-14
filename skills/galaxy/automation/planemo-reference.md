# Planemo Reference and Galaxy API Access

Detailed Planemo usage and Galaxy API patterns. See [SKILL.md](SKILL.md) for overview.

---

## Planemo Concepts

### 1. Planemo Command Structure

**Basic syntax:**
```bash
planemo run <workflow_file> <job_yaml> \
    --engine external_galaxy \
    --galaxy_url "https://usegalaxy.org" \
    --galaxy_user_key "your_api_key" \
    --history_name "My Analysis" \
    --test_output_json "invocation.json"
```

**Common options:**
- `--engine external_galaxy`: Use external Galaxy server (not local)
- `--simultaneous_uploads`: Upload all files simultaneously (faster but more resource-intensive)
- `--check_uploads_ok`: Verify uploads completed successfully
- `--test_output_json`: Save invocation details to JSON file

---

### 2. Job YAML Format

**Example job.yml:**
```yaml
# Inputs
input_reads:
  class: File
  path: /path/to/reads.fastq.gz

# Collections
paired_reads:
  class: Collection
  collection_type: paired
  elements:
    - identifier: forward
      class: File
      path: /path/to/forward.fastq.gz
    - identifier: reverse
      class: File
      path: /path/to/reverse.fastq.gz

# Parameters
kmer_size: 21
coverage_threshold: 30
```

---

### 3. Generating Planemo Commands Programmatically

```python
def build_planemo_command(workflow_path, job_yaml, galaxy_url, api_key,
                          history_name, output_json, log_file):
    """
    Build planemo run command.

    Security: Mask API key in display, but use full key in command.
    """
    command = (
        f'planemo run "{workflow_path}" "{job_yaml}" '
        f'--engine external_galaxy '
        f'--galaxy_url "{galaxy_url}" '
        f'--simultaneous_uploads '
        f'--check_uploads_ok '
        f'--galaxy_user_key "{api_key}" '
        f'--history_name "{history_name}" '
        f'--test_output_json "{output_json}" '
        f'> "{log_file}" 2>&1'
    )

    return command
```

**Execute with error handling:**
```python
import os

return_code = os.system(planemo_command)

if return_code != 0:
    # Planemo failed - workflow was NOT launched in Galaxy
    # No invocation ID exists
    print(f"ERROR: Planemo failed with return code {return_code}")
    print(f"Check log: {log_file}")
    # DO NOT mark invocation as failed - it was never created
else:
    # Planemo succeeded - workflow launched
    # Invocation ID is in output JSON
    print(f"SUCCESS: Workflow launched")
```

**CRITICAL:** `os.system()` return codes are shifted by 8 bits:
- Exit code 1 becomes return code 256
- Exit code 2 becomes return code 512
- To get actual exit code: `actual_exit = return_code >> 8`

---

### 4. Parsing Planemo Output

**Extract invocation ID from JSON:**
```python
import json

def extract_invocation_id(output_json_path):
    """Extract invocation ID from planemo test output"""
    with open(output_json_path, 'r') as f:
        data = json.load(f)

    # Planemo output structure
    tests = data.get('tests', [])
    if tests and len(tests) > 0:
        test = tests[0]
        invocation_id = test['data'].get('invocation_id')
        return invocation_id

    return None
```

---

## API Authentication and Access Patterns

### Galaxy API curl Syntax

When accessing Galaxy API endpoints directly with curl, use this exact syntax:

```bash
curl -X 'GET' 'https://galaxy.server.org/api/endpoint' \
  -H 'accept: application/json' \
  -H 'x-api-key: '$API_KEY_VAR
```

**Key points:**
- Use `-X 'GET'` (or POST/PUT/DELETE) with quotes
- Include `'accept: application/json'` header
- API key header is `x-api-key:` (not `Authorization:`)
- Variable expansion works: `'$API_KEY_VAR'` (single quotes with var inside)

### Common API Permission Errors

**Error 403002: "History is not accessible to the current user"**

This occurs when:
- Accessing workflow invocations that belong to another user's history
- API key lacks permission to view the specific resource
- History sharing has not been enabled

**Solutions:**
1. Verify you're using the correct API key (owner's key or shared user key)
2. Check if the history/invocation is shared with your user account
3. For workflow invocations: only the owner or explicitly shared users can access via API

**Testing API key permissions:**
```bash
# Test basic API access
curl -X 'GET' 'https://galaxy.server.org/api/users/current' \
  -H 'x-api-key: '$API_KEY

# Returns user info if key is valid
```

### Extracting Workflow Invocation Parameters

To get parameter values from a completed workflow invocation:

```bash
# Fetch invocation data
curl -X 'GET' 'https://galaxy.server.org/api/invocations/INVOCATION_ID' \
  -H 'accept: application/json' \
  -H 'x-api-key: '$API_KEY > invocation.json

# Extract input parameters
cat invocation.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
params = data.get('input_step_parameters', {})
for label, param_data in params.items():
    value = param_data.get('parameter_value')
    print(f'{label}: {value}')
"
```

The `input_step_parameters` field contains all workflow parameter values with their labels.
