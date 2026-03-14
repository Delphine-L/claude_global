# Automation Patterns and Debugging

Common patterns for Galaxy workflow automation and debugging techniques. See [SKILL.md](SKILL.md) for overview.

---

## Common Automation Patterns

### 1. Thread-Safe Galaxy Operations

**Use locks for concurrent API calls:**
```python
import threading

galaxy_lock = threading.Lock()

def thread_safe_invoke_workflow(gi, workflow_id, inputs, history_id):
    """Invoke workflow with thread safety"""
    with galaxy_lock:
        invocation = gi.workflows.invoke_workflow(
            workflow_id,
            inputs=inputs,
            history_id=history_id
        )
        return invocation['id']
```

**Why:** Galaxy API can have issues with concurrent uploads/operations from same API key.

---

### 2. Batch Processing Pattern

```python
def process_samples_batch(gi, workflow_id, samples, max_concurrent=3):
    """
    Process multiple samples with concurrency limit.

    Args:
        gi: GalaxyInstance
        workflow_id: Workflow to run
        samples: List of sample dicts with 'name' and 'files'
        max_concurrent: Max parallel invocations
    """
    from concurrent.futures import ThreadPoolExecutor, as_completed

    def process_one_sample(sample):
        # Create history
        history_id = get_or_find_history_id(gi, sample['name'])

        # Upload files
        dataset_ids = []
        for file_path in sample['files']:
            ds = gi.tools.upload_file(file_path, history_id)
            dataset_ids.append(ds['outputs'][0]['id'])

        # Invoke workflow
        inputs = {'0': {'id': dataset_ids[0], 'src': 'hda'}}
        invocation_id = thread_safe_invoke_workflow(
            gi, workflow_id, inputs, history_id
        )

        # Wait for completion
        state = wait_for_invocation(gi, invocation_id)

        return {
            'sample': sample['name'],
            'invocation_id': invocation_id,
            'state': state
        }

    # Process with limited concurrency
    with ThreadPoolExecutor(max_workers=max_concurrent) as executor:
        futures = {executor.submit(process_one_sample, s): s for s in samples}

        results = []
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(f"Completed: {result['sample']} - {result['state']}")

        return results
```

---

### 3. Resume Capability Pattern

**Track processed samples:**
```python
import json
import os

STATE_FILE = 'processing_state.json'

def load_state():
    """Load processing state"""
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, 'r') as f:
            return json.load(f)
    return {'completed': [], 'failed': []}

def save_state(state):
    """Save processing state"""
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=2)

def process_with_resume(samples):
    """Process samples with resume capability"""
    state = load_state()

    for sample in samples:
        sample_name = sample['name']

        # Skip if already completed
        if sample_name in state['completed']:
            print(f"Skipping {sample_name} (already completed)")
            continue

        try:
            # Process sample
            result = process_one_sample(sample)

            if result['state'] == 'ok':
                state['completed'].append(sample_name)
            else:
                state['failed'].append(sample_name)

            save_state(state)

        except Exception as e:
            print(f"Error processing {sample_name}: {e}")
            state['failed'].append(sample_name)
            save_state(state)
```

---

## Debugging

### 1. Galaxy History Inspection

```python
def inspect_history(gi, history_id):
    """Print detailed history information"""
    history = gi.histories.show_history(history_id)
    print(f"History: {history['name']} ({history['id']})")
    print(f"State: {history['state']}")

    contents = gi.histories.show_history(history_id, contents=True)

    for item in contents:
        print(f"  [{item['state']}] {item['name']} (type: {item['history_content_type']})")
```

---

### 2. Invocation Step Analysis

```python
def analyze_failed_invocation(gi, invocation_id):
    """Analyze why invocation failed"""
    invocation = gi.invocations.show_invocation(
        invocation_id,
        include_workflow_steps=True
    )

    print(f"Invocation: {invocation_id}")
    print(f"State: {invocation['state']}")

    for step_id, step_data in invocation.get('steps', {}).items():
        step_state = step_data['state']
        job_id = step_data.get('job_id')

        if step_state == 'error':
            print(f"\nFailed Step {step_id}:")

            if job_id:
                job = gi.jobs.show_job(job_id)
                print(f"  Tool: {job.get('tool_id')}")
                print(f"  Exit code: {job.get('exit_code')}")
                print(f"  Stderr:\n{job.get('stderr', 'N/A')}")
```
