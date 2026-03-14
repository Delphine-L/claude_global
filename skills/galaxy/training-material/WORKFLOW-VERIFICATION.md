# Tutorial-Workflow Verification

When updating a tutorial to match a new workflow, verify consistency with these checks:

## Cross-check tool versions between tutorial and workflow

```python
import json, re

with open('workflows/main_workflow.ga') as f:
    wf = json.load(f)

# Collect all tool_ids (including subworkflows)
wf_tools = set()
for step in wf['steps'].values():
    if step.get('content_id'):
        wf_tools.add(step['content_id'])
    if step.get('type') == 'subworkflow' and step.get('subworkflow'):
        for substep in step['subworkflow']['steps'].values():
            if substep.get('content_id'):
                wf_tools.add(substep['content_id'])

with open('tutorial.md') as f:
    tutorial = f.read()

tutorial_tools = set(re.findall(r'\{% tool \[.*?\]\((.*?)\) %\}', tutorial))

# Tutorial tools not in workflow = potential version mismatches
mismatches = {t for t in tutorial_tools - wf_tools if 'toolshed' in t}

# Workflow tools not in tutorial = expected for utility/subworkflow tools
# (e.g., compose_text_param, pick_value, map_param_value, param_value_from_file)
```

## Additional checks after a tutorial rewrite

1. **Validate workflow JSON**: `python3 -c "import json; json.load(open('main_workflow.ga'))"`
2. **Grep for old tool references**: search for old tool names (e.g., `Kraken2`) and old versions (e.g., `2.14.1`)
3. **Workflow-only tools are OK**: utility tools inside subworkflows (e.g., `pick_value`, `map_param_value`, `compose_text_param`) don't need `{% tool %}` references in the tutorial

## Updating tutorials that use external IWC workflows

Some tutorials (e.g., `vgp_workflow_training`) don't bundle .ga files — they instruct users to import from Dockstore. Update process:

1. **Check latest IWC versions** via Dockstore API or IWC GitHub releases
2. **Fetch the .ga file** from GitHub (`raw.githubusercontent.com/iwc-workflows/...`) to inspect inputs
3. **Update `workflows_run_ds.md` snippet** version parameter
4. **Update input lists**: check for new required inputs, changed input types (e.g., separate files → collections), renamed parameters
5. **Update tool references**: check if QC tools changed (e.g., BUSCO → Compleasm)
6. **Mark outdated screenshots** with `<!-- TODO -->` comments rather than leaving incorrect images
7. **Grep for old references**: search for old tool names and version strings to catch stragglers

## GTA track update process

For systematic multi-tutorial updates (e.g., GTA yearly refresh), use the reusable prompt template `GTA-track-update-prompt.md` which guides 4 iterations:

1. **Tutorial inventory** — audit staleness, identify candidates
2. **Tool version audit** — compare tutorial vs Galaxy server versions using MCP
3. **Workflow updates** — update .ga files and tutorial text
4. **Fix known issues** — address blockers, compile final action plan

State is tracked in `track-content.md` (detailed audit) and `MANIFEST.md` (status overview). Work can be paused and resumed between iterations.

Key tip: The prompt supports a "Target workflows" field where users specify IWC workflows with versions. This enables a top-down update approach (match tutorial to target workflow) rather than bottom-up (discover changes tool by tool).

## Galaxy MCP IWC function failures

The MCP functions `get_iwc_workflow_details()` and `search_iwc_workflows()` can fail with `'function' object has no attribute 'fn'` errors. Always use these fallbacks:

- **Version list**: `https://dockstore.org/api/ga4gh/trs/v2/tools/%23workflow%2Fgithub.com%2Fiwc-workflows%2F{REPO}%2Fmain/versions`
- **Workflow .ga file**: `https://raw.githubusercontent.com/iwc-workflows/{REPO}/main/{WORKFLOW_NAME}.ga`
- **Input inspection**: Fetch the .ga file and examine input steps (step 0, 1, 2...) for labels, types, defaults, and optional flags

Always verify actual inputs from the .ga file rather than relying on documentation — upstream changes are frequent and plans may reference outdated versions.

## Adapting IWC test files for tutorials

When copying an IWC workflow to a tutorial, adapt the test file:
- Change input data URLs to the tutorial's Zenodo dataset
- Update parameter values (e.g., taxonomic IDs for the tutorial species)
- Keep output assertions minimal but meaningful (check key scaffolds are present/absent)
- The test file name must be `main_workflow-tests.yml` (matching `main_workflow.ga`)
