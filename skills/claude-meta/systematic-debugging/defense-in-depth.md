# Defense-in-Depth Validation

When you fix a bug caused by invalid data, adding validation at one place feels sufficient. But that single check can be bypassed by different code paths, refactoring, or edge cases.

**Core principle:** Validate at EVERY layer data passes through. Make the bug structurally impossible.

## Why Multiple Layers

- Single validation: "We fixed the bug"
- Multiple layers: "We made the bug impossible"

Different layers catch different cases:
- Entry validation catches most bugs
- Business logic catches edge cases
- Environment guards prevent context-specific dangers
- Debug logging helps when other layers fail

## The Four Layers

### Layer 1: Entry Point Validation

Reject obviously invalid input at the API/function boundary.

```python
def run_analysis(input_file, output_dir):
    if not input_file or not os.path.exists(input_file):
        raise ValueError(f"Input file not found: {input_file}")
    if not output_dir or not os.path.isdir(output_dir):
        raise ValueError(f"Output directory invalid: {output_dir}")
```

### Layer 2: Business Logic Validation

Ensure data makes sense for this specific operation.

```python
def align_sequences(reference, reads):
    if os.path.getsize(reference) == 0:
        raise ValueError("Reference file is empty")
    # Verify format matches expectation
```

### Layer 3: Environment Guards

Prevent dangerous operations in specific contexts.

```python
def delete_intermediate_files(directory):
    # Never delete outside the project working directory
    if not os.path.abspath(directory).startswith(PROJECT_ROOT):
        raise ValueError(f"Refusing to delete outside project: {directory}")
```

### Layer 4: Debug Instrumentation

Capture context for forensics when issues do occur.

```python
import logging
logger = logging.getLogger(__name__)

def process_sample(sample_id, data_path):
    logger.debug(f"Processing {sample_id} from {data_path}, "
                 f"exists={os.path.exists(data_path)}, "
                 f"size={os.path.getsize(data_path) if os.path.exists(data_path) else 'N/A'}")
```

## Applying the Pattern

When you find a bug:

1. **Trace the data flow** — where does bad value originate? Where is it used?
2. **Map all checkpoints** — list every point data passes through
3. **Add validation at each layer** — entry, business, environment, debug
4. **Test each layer** — try to bypass layer 1, verify layer 2 catches it

## Key Insight

Don't stop at one validation point. Each layer catches bugs the others miss: different code paths bypass entry validation, edge cases bypass business logic, and debug logging identifies structural misuse.

Adapted from [obra/superpowers](https://github.com/obra/superpowers/).
