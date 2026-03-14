---
name: galaxy-automation
description: BioBlend and Planemo expertise for Galaxy workflow automation. Galaxy API usage, workflow invocation, status checking, error handling, batch processing, and dataset management. Essential for any Galaxy automation project.
version: 1.0.0
dependencies: bioblend, planemo
---

# Galaxy Workflow Automation with BioBlend and Planemo

## Purpose

This skill provides expert knowledge for automating Galaxy workflows using **BioBlend** (Python Galaxy API library) and **Planemo** (Galaxy workflow testing and execution tool).

## When to Use This Skill

**Use this skill when:**
- Automating Galaxy workflow execution via API
- Building batch processing systems for Galaxy
- Using BioBlend to interact with Galaxy
- Testing workflows with Planemo
- Managing Galaxy histories, datasets, and collections programmatically
- Polling workflow invocation status
- Implementing error handling and retry logic for Galaxy operations
- Creating Galaxy automation pipelines
- Integrating Galaxy into larger bioinformatics workflows

**This skill is NOT project-specific** - it's useful for ANY Galaxy automation project.

## Supporting Files

Detailed reference material is split into separate files:

- **[bioblend-reference.md](bioblend-reference.md)** -- BioBlend API patterns: connection, history management, workflow invocation, status checking, error handling, rerun API, dataset operations, and collections
- **[planemo-reference.md](planemo-reference.md)** -- Planemo command structure, job YAML format, programmatic command generation, output parsing, and Galaxy API curl/authentication patterns
- **[automation-patterns.md](automation-patterns.md)** -- Thread-safe operations, batch processing, resume capability, and debugging (history inspection, invocation step analysis)

---

## Security Best Practices

### 1. API Key Management

**Store in environment variables:**
```python
import os

api_key = os.environ.get('GALAXY_API_KEY')
if not api_key:
    raise ValueError("GALAXY_API_KEY environment variable not set")

gi = GalaxyInstance(url, api_key)
```

**Mask in logs:**
```python
def mask_api_key(key):
    """Mask API key for display"""
    if len(key) <= 8:
        return '*' * len(key)
    return f"{key[:4]}{'*' * (len(key) - 8)}{key[-4:]}"

masked_key = mask_api_key(api_key)
print(f"Using API key: {masked_key}")
```

---

### 2. Path Handling

**Always quote paths in shell commands:**
```python
# Good - handles spaces
command = f'planemo run "{workflow_path}" "{job_yaml}"'

# Bad - breaks with spaces
command = f'planemo run {workflow_path} {job_yaml}'
```

---

## Common Pitfalls

1. **Planemo failures vs Galaxy failures**
   - Planemo return code != 0: Workflow was NOT launched, no invocation exists
   - Invocation state = 'failed': Workflow was launched but Galaxy job failed
   - Don't confuse these two failure modes

2. **Concurrent uploads**
   - Too many simultaneous uploads can overwhelm Galaxy
   - Use max_concurrent limits (typically 3-5)
   - Consider `--simultaneous_uploads` vs sequential

3. **Dataset state checking**
   - Don't invoke workflows before uploads complete
   - Always wait for dataset state = 'ok'

4. **History name conflicts**
   - Use unique history names (add timestamps or suffixes)
   - Check for existing histories before creating

5. **Return code interpretation**
   - `os.system()` shifts exit codes (exit 1 -> return 256)
   - Use `return_code >> 8` to get actual exit code

6. **Invocation ID recovery**
   - Terminal disconnection loses invocation ID
   - Always save invocation IDs to file immediately
   - Use `--test_output_json` with planemo

---

## Best Practices Summary

1. Use environment variables for API keys
2. Mask API keys in logs and output
3. Quote all file paths in shell commands
4. Implement thread-safety for concurrent operations
5. Save state frequently for resume capability
6. Wait for dataset uploads before invoking workflows
7. Poll invocation status with reasonable intervals (30-60s)
8. Distinguish planemo failures from Galaxy failures
9. Implement proper error handling and retry logic
10. Use unique history names to avoid conflicts

---

## Galaxy MCP Connection

When using the Galaxy MCP tools (mcp__Galaxy__*), connect at the start of each session.

### Connection Pattern
MCP tools cannot read shell environment variables directly. Resolve them via Bash first:

```bash
# Resolve env vars
echo "$GXYVGP"   # Galaxy instance URL
echo "$MAINKEY"   # API key
```

Then pass the resolved values:
```
mcp__Galaxy__connect(url="<resolved_url>", api_key="<resolved_key>")
```

### Known Instances
| Env Var | Instance | Notes |
|---------|----------|-------|
| `$GXYVGP` | https://vgp.usegalaxy.org | VGP production, user: delphinel (admin) |
| `$MAINKEY` | API key for VGP instance | Used with $GXYVGP |

---

## Related Skills

- **galaxy-tool-wrapping**: For creating Galaxy tool wrappers
- **galaxy-workflow-development**: For creating Galaxy workflows
- **vgp-pipeline**: VGP-specific orchestration (uses this skill as dependency)

---

## Resources

- **BioBlend Documentation**: https://bioblend.readthedocs.io/
- **Planemo Documentation**: https://planemo.readthedocs.io/
- **Galaxy API**: https://docs.galaxyproject.org/en/master/api/
- **Galaxy Training**: https://training.galaxyproject.org/
