# BioBlend Reference

Detailed BioBlend API patterns for Galaxy automation. See [SKILL.md](SKILL.md) for overview.

---

## 1. Galaxy Instance Connection

```python
from bioblend.galaxy import GalaxyInstance

# Connect to Galaxy server
gi = GalaxyInstance(url='https://usegalaxy.org', key='your_api_key')

# Verify connection
print(gi.whoami())
```

**Best practices:**
- Store API keys in environment variables, never in code
- Use HTTPS URLs for production
- Mask API keys in logs: `f"{key[:4]}{'*' * (len(key) - 8)}{key[-4:]}"`

---

## 2. History Management

**Create or find history:**
```python
def get_or_find_history_id(gi, history_name):
    """Get history ID by name, or create if doesn't exist"""
    histories = gi.histories.get_histories(name=history_name)

    if histories:
        return histories[0]['id']
    else:
        history = gi.histories.create_history(name=history_name)
        return history['id']
```

**List histories:**
```python
histories = gi.histories.get_histories()
for hist in histories:
    print(f"{hist['name']}: {hist['id']}")
```

**Get history contents:**
```python
history_id = '...'
contents = gi.histories.show_history(history_id, contents=True)

for item in contents:
    print(f"{item['name']}: {item['state']}")
```

---

## 3. Workflow Invocation

**Get workflow by ID:**
```python
workflow_id = 'a1b2c3d4e5f67890'
workflow = gi.workflows.show_workflow(workflow_id)
print(f"Workflow: {workflow['name']}")
```

**Invoke workflow:**
```python
# Prepare inputs (dataset IDs or dataset collection IDs)
inputs = {
    '0': {'id': dataset_id, 'src': 'hda'},  # hda = history dataset
    '1': {'id': collection_id, 'src': 'hdca'}  # hdca = history dataset collection
}

# Invoke workflow
invocation = gi.workflows.invoke_workflow(
    workflow_id,
    inputs=inputs,
    history_id=history_id,
    import_inputs_to_history=False  # Inputs already in history
)

invocation_id = invocation['id']
print(f"Invocation ID: {invocation_id}")
```

---

## 4. Invocation Status Checking

**Poll invocation status:**
```python
def check_invocation_complete(gi, invocation_id, include_steps=False):
    """
    Check if workflow invocation is complete.

    Returns:
        str: 'ok', 'running', 'failed', 'cancelled', 'error'
    """
    invocation = gi.invocations.show_invocation(
        invocation_id,
        include_workflow_steps=include_steps
    )

    state = invocation['state']

    # Possible states: 'new', 'ready', 'scheduled', 'running',
    #                  'ok', 'failed', 'cancelled', 'error'

    return state
```

**Wait for completion:**
```python
import time

def wait_for_invocation(gi, invocation_id, poll_interval=30, timeout=3600):
    """Wait for invocation to complete"""
    start_time = time.time()

    while True:
        state = check_invocation_complete(gi, invocation_id)

        if state in ['ok', 'failed', 'cancelled', 'error']:
            return state

        if time.time() - start_time > timeout:
            raise TimeoutError(f"Invocation {invocation_id} timed out after {timeout}s")

        time.sleep(poll_interval)
```

**Get invocation details with steps:**
```python
invocation = gi.invocations.show_invocation(
    invocation_id,
    include_workflow_steps=True
)

# Check individual steps
for step_id, step_data in invocation.get('steps', {}).items():
    step_state = step_data['state']
    job_id = step_data.get('job_id')
    print(f"Step {step_id}: {step_state} (job: {job_id})")
```

---

## 5. Error Handling Patterns

**Categorize failures:**
```python
def categorize_failure(gi, invocation_id):
    """Determine if failure is retriable"""
    invocation = gi.invocations.show_invocation(
        invocation_id,
        include_workflow_steps=True
    )

    if invocation['state'] != 'failed':
        return None

    # Check failed steps
    failed_steps = []
    for step_id, step_data in invocation.get('steps', {}).items():
        if step_data['state'] == 'error':
            failed_steps.append({
                'step_id': step_id,
                'job_id': step_data.get('job_id')
            })

    # Analyze job failures
    for step in failed_steps:
        if step['job_id']:
            job = gi.jobs.show_job(step['job_id'])
            stderr = job.get('stderr', '')

            # Check for specific error patterns
            if 'out of memory' in stderr.lower():
                return 'retriable_memory'
            elif 'timeout' in stderr.lower():
                return 'retriable_timeout'
            elif 'network' in stderr.lower():
                return 'retriable_network'

    return 'permanent_failure'
```

---

## 6. Rerun Failed Invocations

**Galaxy rerun API:**
```python
def rerun_failed_invocation(gi, invocation_id, use_cached_job=True,
                           replacement_params=None):
    """
    Rerun a failed invocation using Galaxy's native rerun API.

    Args:
        gi: GalaxyInstance
        invocation_id: Failed invocation ID
        use_cached_job: Reuse successful job results
        replacement_params: Dict of parameter changes

    Returns:
        New invocation ID
    """
    rerun_payload = {
        'use_cached_job': use_cached_job
    }

    if replacement_params:
        rerun_payload['replacement_params'] = replacement_params

    # Call Galaxy rerun API
    response = gi.invocations.rerun_invocation(
        invocation_id,
        **rerun_payload
    )

    new_invocation_id = response['id']
    return new_invocation_id
```

**Detect parameter changes from YAML:**
```python
def build_replacement_params_from_yaml(gi, invocation_id, job_yaml_path):
    """
    Compare YAML parameters with invocation parameters.

    Returns dict of changed parameters for rerun.
    """
    import yaml

    # Read new parameters from YAML
    with open(job_yaml_path, 'r') as f:
        new_params = yaml.safe_load(f)

    # Get original invocation parameters
    invocation = gi.invocations.show_invocation(invocation_id)
    orig_params = invocation.get('inputs', {})

    # Find differences
    replacement_params = {}
    for key, new_value in new_params.items():
        if key in orig_params:
            if orig_params[key] != new_value:
                replacement_params[key] = new_value
        else:
            replacement_params[key] = new_value

    return replacement_params
```

---

## 7. Dataset Operations

**Upload dataset:**
```python
file_path = '/path/to/file.fastq.gz'

dataset = gi.tools.upload_file(
    file_path,
    history_id,
    file_type='fastqsanger.gz'
)

dataset_id = dataset['outputs'][0]['id']
```

**Get dataset details:**
```python
dataset = gi.datasets.show_dataset(dataset_id)
print(f"Name: {dataset['name']}")
print(f"State: {dataset['state']}")  # 'ok', 'queued', 'running', 'error'
print(f"Size: {dataset.get('file_size', 0)} bytes")
```

**Wait for dataset upload:**
```python
def wait_for_dataset(gi, dataset_id, poll_interval=5, timeout=600):
    """Wait for dataset to finish uploading"""
    start_time = time.time()

    while True:
        dataset = gi.datasets.show_dataset(dataset_id)
        state = dataset['state']

        if state == 'ok':
            return True
        elif state == 'error':
            raise RuntimeError(f"Dataset {dataset_id} failed to upload")

        if time.time() - start_time > timeout:
            raise TimeoutError(f"Dataset upload timeout after {timeout}s")

        time.sleep(poll_interval)
```

---

## 8. Collections (Paired, List, List:Paired)

**Create dataset collection:**
```python
# List collection (multiple files)
collection_description = {
    'collection_type': 'list',
    'element_identifiers': [
        {'id': dataset_id1, 'name': 'sample1', 'src': 'hda'},
        {'id': dataset_id2, 'name': 'sample2', 'src': 'hda'},
    ]
}

collection = gi.histories.create_dataset_collection(
    history_id,
    collection_description
)

collection_id = collection['id']
```

**Paired collection (forward/reverse reads):**
```python
collection_description = {
    'collection_type': 'paired',
    'element_identifiers': [
        {'id': forward_dataset_id, 'name': 'forward', 'src': 'hda'},
        {'id': reverse_dataset_id, 'name': 'reverse', 'src': 'hda'},
    ]
}
```

**List:Paired (multiple paired-end samples):**
```python
collection_description = {
    'collection_type': 'list:paired',
    'element_identifiers': [
        {
            'name': 'sample1',
            'collection_type': 'paired',
            'element_identifiers': [
                {'id': sample1_fwd, 'name': 'forward', 'src': 'hda'},
                {'id': sample1_rev, 'name': 'reverse', 'src': 'hda'},
            ]
        },
        {
            'name': 'sample2',
            'collection_type': 'paired',
            'element_identifiers': [
                {'id': sample2_fwd, 'name': 'forward', 'src': 'hda'},
                {'id': sample2_rev, 'name': 'reverse', 'src': 'hda'},
            ]
        }
    ]
}
```
