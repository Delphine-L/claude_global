---
description: Debug failed workflows for a species
---

You are debugging a failed VGP workflow for a specific species.

## Your Task

The species name or assembly ID should be provided as an argument.
Example: `/debug-failed bTaeGut2`

1. **Check metadata first** (token-efficient):
   ```bash
   cat metadata/metadata_run.json | jq '.bTaeGut2'
   ```
   - Identify which workflow failed
   - Get the invocation ID
   - Check the failure state

2. **Read log file efficiently** (NOT the entire file):
   ```bash
   # Read only the end where errors appear
   tail -100 {assembly_id}/planemo_log/{assembly_id}_Workflow_{N}.log

   # Or filter for errors
   grep -A 20 -i "error\|fail" {assembly_id}/planemo_log/{assembly_id}_Workflow_{N}.log | head -100
   ```

3. **Identify error pattern**:
   - Check against known VGP failure patterns:
     - **WF0**: No mitochondrial reads (expected, not a real error)
     - **WF8**: Missing Hi-C files or WF4 not complete
     - **WF9**: NCBI datasets tool not installed
     - **General**: Parameter issues, file upload failures

4. **Provide diagnosis**:
   - What failed and why
   - Whether it's expected (e.g., WF0 no mito reads)
   - Specific line numbers or error messages
   - Root cause analysis

5. **Suggest fixes**:
   - Specific parameter changes needed
   - Commands to edit job YAML if needed
   - Command to retry:
     ```bash
     vgp-run-all --resume --retry-failed -p profile.yaml -m ./metadata/
     ```
   - Whether to use `--no-cache` for fresh execution

## Output Format

Provide:
- 🔍 **Error Summary**: What failed
- 📋 **Diagnosis**: Why it failed
- 💡 **Solution**: How to fix it
- ⚙️ **Commands**: Exact commands to run
