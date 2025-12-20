---
description: Check status of all VGP workflows
---

You are checking the status of VGP genome assembly workflows for this project.

## Your Task

1. **Read metadata files efficiently** (using token-efficient methods):
   ```bash
   cat metadata/results_run.json
   cat metadata/metadata_run.json | jq '.[] | {name: .Name, invocations: .invocations}'
   ```

2. **For each species, determine**:
   - Current workflow stage (WF1, WF4, WF8, WF9, PreCuration)
   - Invocation IDs and their states (ok, running, failed, cancelled)
   - Which workflows have completed successfully
   - Which workflows are currently running
   - Which workflows have failed or need attention

3. **Summarize findings**:
   - ✅ Species with all workflows complete
   - ⏳ Species with workflows in progress
   - ⚠️ Species with failed workflows
   - 📋 Next steps needed (what workflows are ready to launch)

4. **Use efficient methods**:
   - Always use `--quiet` mode for commands
   - Read metadata before logs
   - Summarize, don't dump raw output

## Output Format

Present as a clear, concise summary with status icons and next action recommendations.
