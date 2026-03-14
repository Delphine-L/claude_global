# IWC Standards Reference

Detailed reference for Intergalactic Workflow Commission (IWC) repository structure, documentation, and submission standards.

## Repository Structure Standards

### Required Files per Workflow
```
workflow-folder/              # lowercase, dashes only
├── .dockstore.yml            # Dockstore registry metadata (REQUIRED)
├── .workflowhub.yml          # WorkflowHub metadata (optional)
├── workflow-name.ga          # Galaxy workflow file
├── workflow-name-tests.yml   # Planemo test file (REQUIRED)
├── README.md                 # Usage documentation (REQUIRED)
├── CHANGELOG.md              # Version history (REQUIRED)
└── test-data/                # Test datasets (if < 100KB)
    ├── input1.txt
    └── expected_output.txt
```

### .dockstore.yml Format
```yaml
version: 1.2
workflows:
- name: main
  subclass: Galaxy
  publish: true
  primaryDescriptorPath: /workflow-name.ga
  testParameterFiles:
  - /workflow-name-tests.yml
  authors:
  - name: Author Name
    orcid: 0000-0002-xxxx-xxxx
  - name: IWC
    url: https://github.com/galaxyproject/iwc
```

### .workflowhub.yml Format (optional)
```yaml
version: '0.1'
registries:
- url: https://workflowhub.eu
  project: iwc
  workflow: category/workflow-name/main
```

### README.md Structure
Must include:
1. **Purpose**: What the workflow does
2. **Inputs**: Valid input formats, parameters, requirements
3. **Outputs**: Expected output files and their content
4. **Comparison**: How this differs from similar workflows (if applicable)
5. **Resources**: Links to tutorials, papers, documentation

### In-Workflow README Field

Galaxy `.ga` workflow files contain a `"readme"` JSON field (top-level) that is displayed in the Galaxy workflow editor and on Dockstore. This is **separate from** the `README.md` file.

**Both must be kept in sync.** The `/prepare-for-iwc` command validates README.md against the workflow but should also check the `readme` field. After updating `README.md`, also update the workflow's `readme` field:

```python
import json
with open('workflow.ga') as f:
    wf = json.load(f)
with open('README.md') as f:
    wf['readme'] = f.read()
with open('workflow.ga', 'w') as f:
    json.dump(wf, f, indent=4)
    f.write('\n')
```

**Common drift**: Tool name changes (e.g., BUSCO -> Compleasm), added/removed inputs or outputs, restructured descriptions.

### CHANGELOG.md Format
Follow [keepachangelog.com](https://keepachangelog.com/):
```markdown
# Changelog

## [0.1.2] - 2024-12-11

### Changed
- Updated parameter X to improve Y
- Improved workflow annotation

### Automatic update
- `toolshed.g2.bx.psu.edu/repos/owner/tool/1.0`
  was updated to version `1.1`

## [0.1.1] - 2024-11-01

### Added
- Initial workflow version
```

### Documenting Major Version Updates

For major version releases (e.g., 1.x -> 2.0), structure CHANGELOG entries comprehensively:

**CHANGELOG.md pattern**:
```markdown
## [2.0] - 2026-02-13

### Changed

- Tool replacements (old -> new with reason)
- Output renames
- Behavior changes

### Added

- Major new features (grouped by category)
  - Gene annotation tracks with Compleasm
  - Telomere detection with Teloscope
  - Optional Hi-C duplicate removal
- New inputs (list parameter names)
- New outputs (list output names)

### Automatic update

- `toolshed.../tool/1.0` was updated to `toolshed.../tool/1.1`
- `toolshed.../tool2/2.0` was replaced by `toolshed.../newtool/1.0`
```

**README.md pattern**:
Structure inputs and outputs by category with defaults:

```markdown
## Inputs

### Required Inputs
1. **Input Name** [type] - Description

### Processing Options
6. **Parameter** [type] - Description (default: value)

### Annotation Parameters
10. **Lineage** [text] - BUSCO lineage (e.g., vertebrata_odb10)

## Outputs

### Assembly Outputs
1. **Output** [format] - Description

### Annotation Outputs
4. **Genes** [GFF] - Description
```

**Comparing workflow versions**:
```bash
# Compare with GitHub main branch
curl -s https://raw.githubusercontent.com/galaxyproject/iwc/main/workflows/path/workflow.ga -o /tmp/old.ga

# Extract tool differences with Python
python3 << 'EOF'
import json

with open('/tmp/old.ga') as f:
    old_wf = json.load(f)
with open('workflow.ga') as f:
    new_wf = json.load(f)

def extract_tools(steps_dict):
    result = {}
    for step in steps_dict.values():
        # Guard: tool_id can be None (not just missing) -- use `or ''` before string ops
        tid = step.get('tool_id') or ''
        if tid:
            result[tid] = step.get('tool_version', 'unknown')
        if 'subworkflow' in step and 'steps' in step['subworkflow']:
            result.update(extract_tools(step['subworkflow']['steps']))
    return result

old_tools = extract_tools(old_wf['steps'])
new_tools = extract_tools(new_wf['steps'])

for tool_id in sorted(set(old_tools.keys()) & set(new_tools.keys())):
    if old_tools[tool_id] != new_tools[tool_id]:
        print(f"- `{tool_id}/{old_tools[tool_id]}` was updated to `{tool_id}/{new_tools[tool_id]}`")
EOF
```

> **Pitfall**: Step IDs (dict keys in `steps`) get renumbered between workflow versions.
> Never compare tools by step ID -- always group by `tool_id` and compare version sets.
> Also note that `tool_id` can be `null` in JSON -- always guard with `or ''` before string operations like `endswith()`, `split()`, etc.

---

## Workflow Categories in IWC

Organize workflows by scientific domain:
- `amplicon/` - Amplicon sequencing analysis
- `bacterial_genomics/` - Bacterial genome analysis
- `computational-chemistry/` - Computational chemistry workflows
- `data-fetching/` - Data download and retrieval
- `epigenetics/` - ATAC-seq, ChIP-seq, Hi-C, etc.
- `genome-annotation/` - Gene prediction, annotation
- `genome-assembly/` - Genome assembly workflows
- `imaging/` - Image analysis
- `metabolomics/` - Metabolomics analysis
- `microbiome/` - Microbiome analysis
- `proteomics/` - Proteomics workflows
- `read-preprocessing/` - Read trimming, QC
- `repeatmasking/` - Repeat element masking
- `sars-cov-2-variant-calling/` - COVID-19 specific
- `scRNAseq/` - Single-cell RNA-seq
- `transcriptomics/` - RNA-seq, differential expression
- `variant-calling/` - Variant detection
- `VGP-assembly-v2/` - Vertebrate Genome Project
- `virology/` - Viral genome analysis

---

## Review Checklist

When reviewing workflows, verify:

**Metadata**:
- [ ] `.dockstore.yml` present and valid
- [ ] Creator metadata matches `.dockstore.yml`
- [ ] License specified (MIT preferred)
- [ ] Clear, detailed `annotation` field
- [ ] Human-readable workflow name

**Naming**:
- [ ] Folder/file names lowercase with dashes
- [ ] Workflow name human-readable
- [ ] Input/output labels descriptive
- [ ] No hardcoded sample names

**Documentation**:
- [ ] README.md explains usage
- [ ] CHANGELOG.md has version entries
- [ ] Annotations on all inputs/outputs
- [ ] Tool versions documented

**Testing**:
- [ ] Test file present (`-tests.yml`)
- [ ] At least one test case
- [ ] Large files (>100KB) on Zenodo
- [ ] SHA-1 hashes for all test files
- [ ] Tests cover major outputs

**Quality**:
- [ ] Workflow is generic/reusable
- [ ] Tools pinned to specific versions
- [ ] No unnecessary intermediate outputs
- [ ] Proper workflow output labels

**Technical**:
- [ ] Workflow lints cleanly (`planemo workflow_lint --iwc`)
- [ ] Tests pass (`planemo test`)
- [ ] Valid JSON structure
- [ ] No broken connections

---

## Quality Standards & Best Practices

### Annotation Quality

1. **Workflow annotation**: Detailed description of purpose, method, expected inputs/outputs
2. **Step annotations**: Brief explanation of what each step does
3. **Parameter annotations**: Guidance on choosing values

### Testing Best Practices

1. **Test Coverage**: Minimum one test case; test different input types, edge cases, all major outputs
2. **Test Data Management**: < 100KB local, >= 100KB Zenodo; always SHA-1 hash; use minimal test data
3. **Assertion Strategy**: Strictest possible; prefer exact file comparison; use size/line count when content varies; regex for dynamic content
4. **Test Documentation**: Include `doc:` field; comment complex assertions; document tolerances

### CI/CD Integration

**GitHub Actions Integration**:
- Workflows tested on every PR
- Uses Galaxy release_25.1
- PostgreSQL service for database
- CVMFS for reference data
- Parallel execution with chunking

---

## Tools and Resources

**Planemo (workflow development)**:
```bash
# Install
pip install planemo

# Lint workflow
planemo workflow_lint --iwc workflow.ga

# Test workflow
planemo test workflow-tests.yml

# Serve workflow locally
planemo serve workflow.ga
```

**Galaxy Workflow Editor**:
- Access via any Galaxy instance
- Drag-and-drop interface
- Export as .ga JSON file
- Test with GUI

**IWC Resources**:
- Repository: https://github.com/galaxyproject/iwc
- Dockstore: https://dockstore.org/organizations/iwc
- WorkflowHub: https://workflowhub.eu/projects/33
- Gitter: https://gitter.im/galaxyproject/iwc
- Training: https://training.galaxyproject.org

**Reference Data**:
- CVMFS: http://datacache.galaxyproject.org/
- .loc files: http://datacache.galaxyproject.org/indexes/location/

---

## Preparing Workflows for IWC Submission

Before submitting a workflow to the Intergalactic Workflow Commission (IWC), two transformations are required:

### 1. Add Release Number from CHANGELOG

Extract the latest version from `CHANGELOG.md` and add to workflow:

```bash
# Extract version from CHANGELOG
VERSION=$(grep -m1 "^## \[" CHANGELOG.md | sed 's/## \[\(.*\)\].*/\1/')

# Add release field after license in workflow JSON
# Workflow structure:
{
  "license": "MIT",
  "release": "2.0",  # <-- Add this line
  "name": "Workflow Name",
  ...
}
```

### 2. Remove Runtime Parameter Descriptions

Remove all `"inputs": [...]` arrays that contain `"description": "runtime parameter"`:

**Before**:
```json
"inputs": [
    {
        "description": "runtime parameter for tool Map with minimap2",
        "name": "fastq_input"
    }
],
```

**After**:
```json
"inputs": [],
```

**Python script for automation**:
```python
import json

with open('workflow.ga', 'r') as f:
    workflow = json.load(f)

def clean_runtime_params(obj):
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key == "inputs" and isinstance(value, list):
                has_runtime = any(
                    isinstance(item, dict) and
                    item.get('description', '').startswith('runtime parameter')
                    for item in value
                )
                if has_runtime:
                    obj[key] = []
            else:
                clean_runtime_params(value)
    elif isinstance(obj, list):
        for item in obj:
            clean_runtime_params(item)

clean_runtime_params(workflow)

with open('workflow.ga', 'w') as f:
    json.dump(workflow, f, indent=4)
```

**Verification**:
```bash
# Check release was added
grep -A 1 '"license":' workflow.ga | grep '"release":'

# Verify no runtime parameters remain
grep -c '"description": "runtime parameter' workflow.ga  # Should output 0
```

### Automated Transformation with Python

For large workflows (5000+ lines) with many runtime parameters, use this automated script:

```python
import json

# Read workflow
with open('workflow.ga', 'r') as f:
    workflow = json.loads(f.read())

# 1. Add release after license (main workflow and subworkflows)
def add_release(d, version="2.0"):
    if 'license' in d and 'release' not in d:
        new_dict = {}
        for key, value in d.items():
            new_dict[key] = value
            if key == 'license':
                new_dict['release'] = version
        return new_dict
    return d

workflow = add_release(workflow)
# NOTE: Do NOT add release to embedded subworkflows -- only the top-level workflow

# 2. Remove runtime parameter inputs recursively
def clean_runtime_inputs(d):
    if isinstance(d, dict):
        if 'inputs' in d and isinstance(d['inputs'], list):
            if all(isinstance(i, dict) and 'runtime parameter' in i.get('description', '')
                   for i in d['inputs']):
                d['inputs'] = []

        for key, value in d.items():
            if isinstance(value, dict):
                clean_runtime_inputs(value)
            elif isinstance(value, list):
                for item in value:
                    if isinstance(item, dict):
                        clean_runtime_inputs(item)
    return d

workflow = clean_runtime_inputs(workflow)

# Write back
with open('workflow.ga', 'w') as f:
    json.dump(workflow, f, indent=4)

print("Transformations applied successfully")
```

This script safely processes large workflow files and handles nested subworkflows automatically. It typically cleans 50-150 runtime parameter entries in complex workflows.
