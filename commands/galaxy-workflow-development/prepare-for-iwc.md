---
description: Prepare a Galaxy workflow for IWC submission (release version, cleanup, validation)
---

You are preparing a Galaxy workflow for IWC submission. Find the `.ga` workflow file in the current directory and perform all checks and transformations.

## Step 1: Identify Files

Find the `.ga` workflow file, `CHANGELOG.md`, `README.md`, and `-tests.yml` file in the current directory.

## Step 2: Extract Release Version

Read `CHANGELOG.md` and extract the latest version number (first `## [X.Y.Z]` entry).

## Step 3: Compare Workflow Versions (Changelog Completeness)

Compare the current workflow against the **main branch version** to detect all changes that need documenting:

```bash
# Fetch the previous version from main branch
WORKFLOW_FILE=$(ls *.ga | head -1)
REPO_ROOT=$(git rev-parse --show-toplevel)
REL_PATH=$(realpath --relative-to="$REPO_ROOT" "$WORKFLOW_FILE")
git show main:"$REL_PATH" > /tmp/old_workflow.ga 2>/dev/null
```

If the old version exists, compare:

1. **Tool version changes**: Extract all `tool_id` + `tool_version` from both files, report any updates
2. **Input changes**: Compare input labels and types
3. **Output changes**: Compare workflow output labels
4. **Annotation changes**: Compare workflow-level annotation text
5. **Structural changes**: New/removed steps, changed connections

Cross-reference each detected change against `CHANGELOG.md`. Report:
- Changes documented in CHANGELOG
- Changes **missing** from CHANGELOG (flag these clearly)
- CHANGELOG entries that don't match any detected change (possible stale entries)

## Step 4: Validate README Against Workflow

Read `README.md` and the workflow file, then check:

1. **Inputs section**: Every workflow input (parameter and dataset inputs) should be listed in README. Flag any missing or extra inputs.
2. **Outputs section**: Every workflow output label should be documented in README. Flag any missing or extra outputs.
3. **Description accuracy**: Check that the workflow annotation and README description are consistent.
4. **Tool references**: If README mentions specific tools, verify they still exist in the workflow.
5. **In-workflow README sync**: Compare the `"readme"` field in the .ga JSON against `README.md`. Report if they differ significantly (missing inputs, outdated tool names, different outputs, etc.). Offer to sync the `readme` field from `README.md`.

Report discrepancies clearly so the user can decide what to update.

## Step 5: Apply Transformations to .ga File

### 5a. Add/Update Release Field

Add or update the `"release"` field in the workflow JSON, placed after `"license"`:

```python
import json, re, sys

workflow_file = sys.argv[1]
version = sys.argv[2]

with open(workflow_file, 'r') as f:
    workflow = json.load(f)

# Update main workflow only (do NOT add release to embedded subworkflows)
workflow['release'] = version

with open(workflow_file, 'w') as f:
    json.dump(workflow, f, indent=4)
    f.write('\n')
```

### 5b. Remove Runtime Parameter Descriptions

Remove all `"inputs": [...]` arrays where entries contain `"description": "runtime parameter..."`:

```python
import json, sys

workflow_file = sys.argv[1]

with open(workflow_file, 'r') as f:
    workflow = json.load(f)

def clean_runtime_inputs(obj):
    if isinstance(obj, dict):
        if 'inputs' in obj and isinstance(obj['inputs'], list):
            has_runtime = any(
                isinstance(item, dict) and
                'runtime parameter' in item.get('description', '')
                for item in obj['inputs']
            )
            if has_runtime:
                obj['inputs'] = []
        for value in obj.values():
            clean_runtime_inputs(value)
    elif isinstance(obj, list):
        for item in obj:
            clean_runtime_inputs(item)

clean_runtime_inputs(workflow)

with open(workflow_file, 'w') as f:
    json.dump(workflow, f, indent=4)
    f.write('\n')
```

## Step 5c: Validate Test File Against Workflow

Read the `-tests.yml` file and cross-reference it against the current workflow:

1. **Input labels**: Every `job:` key should match a workflow input label exactly. Flag mismatches.
2. **Output labels**: Every `outputs:` key should match a workflow output label exactly. Flag:
   - Test output keys that reference **removed/renamed** workflow outputs
   - New workflow outputs that are **not tested**
3. **Suggest fixes**: For each discrepancy, suggest the correction (e.g., rename to new output label, remove stale assertion, add minimal assertion for new outputs).

Report discrepancies clearly. When the user asks to fix, update the test file:
- Remove assertions for outputs that no longer exist
- Rename output keys to match current workflow output labels
- Add minimal assertions for new outputs (e.g., `has_text` with a generic marker)

## Step 6: Validate

1. **JSON validity**: `python3 -c "import json; json.load(open('workflow.ga'))"`
2. **Release field present**: `grep '"release"' workflow.ga`
3. **No runtime parameters remain**: `grep -c '"runtime parameter"' workflow.ga` should be 0
4. **Run planemo lint**: `planemo workflow_lint --iwc workflow.ga` (if planemo is available)

## Step 7: Report Summary

Present a clear summary:

```
## Preparation Summary

### Release
- Version: X.Y.Z (from CHANGELOG)
- Release field: added/updated

### Runtime Parameters
- Removed: N runtime parameter entries

### Changelog Completeness
- [list of documented changes]
- [list of MISSING changes, if any]

### README Accuracy
- Inputs: X/Y documented [list any missing]
- Outputs: X/Y documented [list any missing]
- [any other discrepancies]

### Test File
- Inputs: all matching / [list mismatches]
- Outputs: X/Y tested [list stale or missing]
- [fixes applied, if any]

### Validation
- JSON: valid
- Runtime params: clean
- Planemo lint: [result]

### Action Items
- [any remaining issues the user should address]
```

## Important Notes

- NEVER modify `CHANGELOG.md` or `README.md` without asking the user first - only report discrepancies
- ALWAYS read files before modifying them
- Only add `"release"` to the top-level workflow, NOT to embedded subworkflows
- If the workflow has subworkflows, apply runtime cleanup to those too
- The `.ga` file JSON should end with a newline
