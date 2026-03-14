# Root Cause Tracing

Bugs often manifest deep in the call stack. Your instinct is to fix where the error appears, but that's treating a symptom.

**Core principle:** Trace backward through the call chain until you find the original trigger, then fix at the source.

## When to Use

- Error happens deep in execution (not at entry point)
- Stack trace shows long call chain
- Unclear where invalid data originated
- Multi-component systems (pipeline → tool → data)

## The Tracing Process

### 1. Observe the Symptom

```
Error: File not found: /path/to/expected/output.bam
```

### 2. Find Immediate Cause

What code directly causes this? What function, what line?

### 3. Ask: What Called This?

Trace the call chain upward:
```
process_alignment(input_file)
  → called by run_pipeline(sample)
  → called by batch_process(samples)
  → called by main()
```

### 4. Keep Tracing Up

What value was passed? Where did it come from?
- Was the path constructed wrong?
- Was a variable empty/None?
- Was configuration missing?

### 5. Find Original Trigger

The root cause is often far from where the error appears:
- A config file missing a key
- An environment variable not set
- A previous pipeline step that silently produced no output
- A data format assumption that doesn't hold

## Adding Diagnostic Instrumentation

When you can't trace manually, add temporary logging:

```python
# Before the problematic operation
import traceback
print(f"DEBUG: input_file={input_file}", file=sys.stderr)
print(f"DEBUG: cwd={os.getcwd()}", file=sys.stderr)
print(f"DEBUG: exists={os.path.exists(input_file)}", file=sys.stderr)
traceback.print_stack(file=sys.stderr)
```

**Tips:**
- Use `stderr` (not logger — may be suppressed)
- Log BEFORE the dangerous operation, not after it fails
- Include: paths, working directory, environment variables
- `traceback.print_stack()` shows complete call chain

## For Multi-Component Systems

For pipelines (Galaxy workflow → tool execution → data processing):

```
For EACH component boundary:
  - Log what data enters
  - Log what data exits
  - Verify configuration propagation
  - Check state at each layer

Run once → analyze evidence → identify failing component → investigate
```

## Key Principle

**NEVER fix just where the error appears.** Trace back to find the original trigger. Then also consider adding validation at intermediate layers (see defense-in-depth.md).

Adapted from [obra/superpowers](https://github.com/obra/superpowers/).
