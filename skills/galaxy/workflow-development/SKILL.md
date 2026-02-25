---
name: galaxy-workflow-development
description: Expert in Galaxy workflow development, testing, and IWC best practices. Create, validate, and optimize .ga workflows following Intergalactic Workflow Commission standards.
version: 1.0.0
---

# Galaxy Workflow Development Expert

You are an expert in Galaxy workflow development, testing, and best practices based on the Intergalactic Workflow Commission (IWC) standards.

## Core Knowledge

### Galaxy Workflow Format (.ga files)

Galaxy workflows are JSON files with `.ga` extension containing:

#### Required Top-Level Metadata
```json
{
    "a_galaxy_workflow": "true",
    "annotation": "Detailed description of workflow purpose and functionality",
    "creator": [
        {
            "class": "Person",
            "identifier": "https://orcid.org/0000-0002-xxxx-xxxx",
            "name": "Author Name"
        },
        {
            "class": "Organization",
            "name": "IWC",
            "url": "https://github.com/galaxyproject/iwc"
        }
    ],
    "format-version": "0.1",
    "license": "MIT",
    "release": "0.1.1",
    "name": "Human-Readable Workflow Name",
    "tags": ["domain-tag", "method-tag"],
    "uuid": "unique-identifier",
    "version": 1
}
```

#### Workflow Steps Structure

Steps are numbered sequentially and define:

1. **Input Datasets**
   - `type: "data_input"` - Single file input
   - `type: "data_collection_input"` - Collection of files
   - Must have descriptive `annotation` and `label`

2. **Input Parameters**
   - `type: "parameter_input"`
   - Types: text, boolean, integer, float, color
   - Used for user-configurable settings

3. **Tool Steps**
   - `type: "tool"`
   - `tool_id` and `content_id` reference Galaxy ToolShed
   - `tool_shed_repository` includes owner, name, changeset_revision
   - `input_connections` link to previous step outputs
   - `tool_state` contains parameter values (JSON-encoded)

4. **Workflow Outputs**
   - Marked with `workflow_outputs` array
   - Each output has a `label` (human-readable name)
   - Can hide intermediate outputs with `hide: true`

#### Advanced Features

- **Comments**: `type: "text"` steps for documentation
- **Frames**: Visual grouping with color-coded boxes
- **Reports**: Embedded Markdown templates using Galaxy report syntax
- **Post-job actions**: Rename, tag, or hide outputs
- **Conditional execution**: `when` field for conditional steps

### Workflow Testing with Planemo

#### Test File Naming Convention
- Workflow: `workflow-name.ga`
- Test file: `workflow-name-tests.yml` (identical name + `-tests.yml`)

#### Test File Structure (YAML)

```yaml
- doc: Description of test case
  job:
    # Input datasets
    Input Label Name:
      class: File
      path: test-data/input.txt
      filetype: txt
      hashes:
      - hash_function: SHA-1
        hash_value: abc123...

    # OR Zenodo-hosted files (for files > 100KB)
    Large Input:
      class: File
      location: https://zenodo.org/records/XXXXXX/files/file.fastq.gz
      filetype: fastqsanger.gz
      hashes:
      - hash_function: SHA-1
        hash_value: def456...

    # Collection inputs
    Collection Input:
      class: Collection
      collection_type: list:paired
      elements:
      - class: File
        identifier: sample1
        path: test-data/sample1_R1.fastq
      - class: File
        identifier: sample1
        path: test-data/sample1_R2.fastq

    # Parameter inputs
    Parameter Label: value
    Boolean Parameter: true
    Numeric Parameter: 42

  outputs:
    # Output assertions
    Output Label:
      file: test-data/expected.txt

    # OR various assertions
    Another Output:
      has_size:
        value: 635210
        delta: 30000
      has_n_lines:
        n: 236
      has_text:
        text: "expected string"
      has_line:
        line: "exact line content"
      has_text_matching:
        expression: "regex.*pattern"

    # Collection output with element tests
    Collection Output:
      element_tests:
        element_identifier:
          file: test-data/expected_element.txt
          decompress: true
          compare: contains
```

#### Assertion Types

1. **File comparison**: Exact match against expected file
   ```yaml
   file: test-data/expected.txt
   ```

2. **Size assertions**: Check file size with delta tolerance
   ```yaml
   has_size:
     value: 1000000
     delta: 50000
   ```

3. **Content assertions**:
   ```yaml
   has_n_lines: {n: 100}
   has_text: {text: "substring"}
   has_line: {line: "exact line"}
   has_text_matching: {expression: "regex.*"}
   ```

4. **Comparison modes**:
   ```yaml
   compare: contains      # Actual contains expected
   compare: re_match      # Regex match
   decompress: true       # Decompress before comparison
   ```

5. **Collection assertions**:
   ```yaml
   element_tests:
     element_id:
       file: test-data/expected.txt
   ```

#### Test Assertion Syntax Requirements

**CRITICAL**: Test assertions in `-tests.yml` files must follow exact formatting to avoid `planemo workflow_lint` errors.

**❌ WRONG** (causes `AttributeError: 'str' object has no attribute 'copy'`):
```yaml
outputs:
  Output Name:
    asserts:
      has_text: "expected text here"
```

**✅ CORRECT**:
```yaml
outputs:
  Output Name:
    asserts:
      has_text:
        text: "expected text here"
```

**Diagnosing Assertion Format Errors**:

When `planemo workflow_lint` crashes with Python traceback containing `AttributeError` or `to_test_assert_list` failures:

```bash
# Find problematic patterns in test file
grep -n 'has_text:.*"' workflow-tests.yml
grep -n 'has_size:.*{' workflow-tests.yml
```

**All assertion types** (`has_text`, `has_size`, `has_line`, `has_n_lines`, etc.) **require nested dict format** with appropriate key:
- `has_text` → `text: "value"`
- `has_size` → `value: 1000, delta: 100`
- `has_line` → `line: "exact line"`
- `has_n_lines` → `n: 100`

---

### Configuring Planemo Tests from Galaxy Invocations

When creating Planemo test configurations, you can extract accurate parameter values from successful Galaxy workflow invocations.

#### Step 1: Fetch Invocation Data

```bash
# Get invocation ID from Galaxy workflow invocation URL
# Example: https://galaxy.server.org/workflows/invocations/cc989bc4fb645bb5
INVOCATION_ID="cc989bc4fb645bb5"

# Fetch invocation details
curl -X 'GET' "https://galaxy.server.org/api/invocations/$INVOCATION_ID" \
  -H 'accept: application/json' \
  -H 'x-api-key: '$GALAXY_API_KEY > invocation.json
```

#### Step 2: Extract Parameters

```python
import json

with open('invocation.json') as f:
    data = json.load(f)

# Get all workflow parameters
params = data.get('input_step_parameters', {})

# Print in YAML-ready format
for label, param_data in params.items():
    value = param_data.get('parameter_value')
    print(f"    {label}: {value}")
```

#### Step 3: Structure Test YAML

```yaml
- doc: Test 1 - Description
  job:
    Input_Dataset:
      class: File
      location: https://zenodo.org/records/RECORD_ID/files/filename.ext
      filetype: format
      hashes:
      - hash_function: SHA-1
        hash_value: abc123...

    # Parameters from invocation
    Parameter Name 1: value1
    Parameter Name 2: value2
    Boolean Parameter: true  # or false
    Numeric Parameter: 10

  outputs:
    Output Name:
      asserts:
        has_text:
          text: "expected content"
        has_size:
          value: 60000
          delta: 30000  # ±50% tolerance
```

#### Common Parameter Types and Formats

| Parameter Type | YAML Format | Example |
|----------------|-------------|---------|
| Boolean | `true`/`false` | `Do you want X?: true` |
| String | Plain or quoted | `Species Name: Test_species` |
| Number | Unquoted | `Minimum Quality: 10` |
| List (comma-sep) | Quoted string | `Patterns: "A,B,C"` |

#### Validating Test Parameters

Before running tests, verify:

1. **All mandatory parameters present** - Check workflow file for required inputs
2. **Data types match** - Boolean as boolean, not string "true"
3. **File paths correct** - Zenodo URLs, local paths, or collection structures
4. **Output names match workflow** - Use exact labels from workflow outputs

#### Testing Strategy for Collections

Create two test cases to validate both single-file and collection inputs:

```yaml
# Test 1: Single dataset per input (minimal)
- doc: Test 1 - Single read set
  job:
    PacBio reads:
      class: Collection
      collection_type: list
      elements:
      - class: File
        identifier: set_1
        location: https://zenodo.org/.../reads_1.fastq.gz

# Test 2: Multiple datasets (collection handling)
- doc: Test 2 - Multiple read sets
  job:
    PacBio reads:
      class: Collection
      collection_type: list
      elements:
      - class: File
        identifier: set_1
        location: https://zenodo.org/.../reads_1.fastq.gz
      - class: File
        identifier: set_2
        location: https://zenodo.org/.../reads_2.fastq.gz
```

This tests both minimal workflow execution and collection merging logic.

---

### Verifying Workflow Output Names

Workflow output names can change between versions. Always verify output names before creating test assertions.

#### Extract All Workflow Outputs

```bash
# Get all workflow output labels
grep -A 2 '"workflow_outputs"' workflow.ga | \
  grep -A 1 '"label":' | \
  grep '"label"' | \
  cut -d'"' -f4 | \
  sort -u

# Or use Python for structured extraction
cat workflow.ga | python3 -c "
import json, sys
wf = json.load(sys.stdin)
outputs = set()
for step in wf['steps'].values():
    for out in step.get('workflow_outputs', []):
        if 'label' in out and out['label']:
            outputs.add(out['label'])
for name in sorted(outputs):
    print(name)
"
```

#### Common Output Name Patterns

Some tools change output names over versions:

| Old Name | Current Name | Tool |
|----------|--------------|------|
| `Seqtk-telo Output` | `Telomere Report` | seqtk_telo |
| `Telomeres Bedgraph` | `terminal telomeres` | custom scripts |
| `Coverage Track` | `BigWig Coverage` | bamCoverage |

Always verify against the actual `.ga` file, not documentation.

#### Updating Test Assertions

When output names change, update test YAML:

```yaml
# OLD (will fail)
outputs:
  Seqtk-telo Output:
    asserts:
      has_text:
        text: "scaffold_10"

# NEW (correct)
outputs:
  Telomere Report:
    asserts:
      has_text:
        text: "scaffold_10"
```

---

### Test Data Organization

For workflows requiring multiple input files (e.g., assemblies + sequencing reads), use this structure:

```
workflow-directory/
├── workflow.ga
├── workflow-tests.yml
├── test_data/
│   ├── README.md              # Quick reference with SHA-1 hashes
│   ├── Haplotype_1.fasta
│   ├── Haplotype_2.fasta
│   ├── PacBio_reads_1.fastq.gz
│   ├── PacBio_reads_2.fastq.gz
│   ├── HiC_forward_1.fastqsanger.gz
│   ├── HiC_reverse_1.fastqsanger.gz
│   ├── HiC_forward_2.fastqsanger.gz
│   └── HiC_reverse_2.fastqsanger.gz
├── TEST_DATA_README.md        # Detailed characteristics
├── TEST_CONFIGURATION_GUIDE.md # Test setup instructions
└── TESTS_SUMMARY.md           # Quick reference guide
```

#### Test Data README Template

```markdown
# Test Data Quick Reference

**Total Files**: 8
**Total Size**: ~33.5 MB

| # | File | Type | Size | SHA-1 Hash |
|---|------|------|------|------------|
| 1 | Haplotype_1.fasta | Assembly | 1.11 MB | `a0ee25...` |
| 2 | PacBio_reads_1.fastq.gz | HiFi | 10.20 MB | `84fe8f...` |
...

## Collection Structure

### PacBio: List Collection
- set_1: 739 reads (~5x coverage)
- set_2: 447 reads (~3x coverage)

### Hi-C: List:Paired Collection
- set_1: 30,000 pairs (forward + reverse)
- set_2: 20,000 pairs (forward + reverse)
```

#### Documentation Best Practices

1. **README.md in test_data/**: SHA-1 hashes and file list
2. **TEST_DATA_README.md**: Detailed data characteristics
3. **TEST_CONFIGURATION_GUIDE.md**: How to use the test data
4. **TESTS_SUMMARY.md**: Quick start for developers

This helps reviewers understand test data without downloading/inspecting files.

#### Matching Test Configuration to Workflow Paths

Test configurations must accurately reflect workflow behavior, especially for workflows with optional processing steps:

**Example**: Optional duplicate removal affects outputs and assertions:

```yaml
- doc: Test 1 - Single read set (with duplicate removal enabled)
  job:
    Remove duplicated Hi-C reads?: true  # Optional feature enabled
    # ... other parameters

  outputs:
    Markduplicates Summary:  # Only present when duplicates removed
      asserts:
        has_text:
          text: "1042\t217\t3942"

- doc: Test 2 - Single read set (without duplicate removal)
  job:
    Remove duplicated Hi-C reads?: false  # Optional feature disabled
    # ... other parameters

  outputs:
    # Markduplicates Summary not tested - not generated
```

**Key Principles**:
1. **Document feature toggles** in test `doc` field (e.g., "with duplicate removal", "without trimming")
2. **Match assertions to enabled features** - don't assert on outputs that won't be generated
3. **Test different paths** when workflow has significant optional steps
4. **Update parameters together** - changing one optional feature may require updating related assertions

**Common optional workflow features**:
- Quality trimming/filtering
- Duplicate removal
- Adapter trimming
- Optional annotations
- Different algorithm choices

When updating test configurations after workflow changes, review all optional parameters and verify assertions match the enabled features.

---

### Synthetic Test Data Generation

For workflow testing, synthetic data should include realistic biological features while remaining compact.

#### Example: Assembly with Telomeres, Gaps, and Genes

```python
import random
random.seed(42)  # Reproducibility

def generate_scaffold(name, length, add_telomeres=False):
    """Generate scaffold with gaps, genes, and optional telomeres"""
    seq = []

    # P-arm telomere (10kb)
    if add_telomeres:
        seq.append("CCCTAA" * 1666)  # ~10kb

    # Main sequence with gaps and genes
    remaining = length
    while remaining > 0:
        # Add random sequence
        chunk = min(50000, remaining)
        seq.append(''.join(random.choices('ACGT', k=chunk)))
        remaining -= chunk

        # Add assembly gap every 150kb
        if remaining > 0 and random.random() < 0.3:
            seq.append('N' * 200)
            remaining -= 200

    # Q-arm telomere (12kb)
    if add_telomeres:
        seq.append("CCCTAA" * 2000)  # ~12kb

    return f">{name}\n" + ''.join(seq)
```

#### Key Features to Include

- **Telomeres**: Canonical repeats (TTAGGG/CCCTAA for vertebrates)
- **Assembly gaps**: 200bp N-sequences
- **Gene-like sequences**: ATG start + coding + stop codon (TAA/TAG/TGA)
- **Coverage gaps**: Regions with zero read coverage
- **Duplicates**: For paired-end data (10-15% duplication rate)

#### Data Sizes for Testing

| Data Type | Minimal | Typical | Full |
|-----------|---------|---------|------|
| Assembly | 1-2 MB | 5-10 MB | 50+ MB |
| HiFi Reads | 500-1000 reads | 5,000 reads | 50,000+ |
| Hi-C Pairs | 10K pairs | 50K pairs | 1M+ pairs |

Minimal datasets enable fast CI/CD testing (~30-60 min runtime).

---

### Repository Structure Standards

#### Required Files per Workflow
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

#### .dockstore.yml Format
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

#### .workflowhub.yml Format (optional)
```yaml
version: '0.1'
registries:
- url: https://workflowhub.eu
  project: iwc
  workflow: category/workflow-name/main
```

#### README.md Structure
Must include:
1. **Purpose**: What the workflow does
2. **Inputs**: Valid input formats, parameters, requirements
3. **Outputs**: Expected output files and their content
4. **Comparison**: How this differs from similar workflows (if applicable)
5. **Resources**: Links to tutorials, papers, documentation

#### CHANGELOG.md Format
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

#### Documenting Major Version Updates

For major version releases (e.g., 1.x → 2.0), structure CHANGELOG entries comprehensively:

**CHANGELOG.md pattern**:
```markdown
## [2.0] - 2026-02-13

### Changed

- Tool replacements (old → new with reason)
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
        if step.get('tool_id'):
            result[step['tool_id']] = step.get('tool_version', 'unknown')
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

### Naming Conventions (STRICT RULES)

#### Folder and File Names
- **MUST** use lowercase only
- **MUST** use dashes (`-`) not underscores
- **NO** spaces in filenames
- Examples:
  - ✅ `parallel-accession-download`
  - ✅ `rnaseq-paired-end`
  - ❌ `Parallel_Accession_Download`
  - ❌ `RNA-Seq_PE`

#### Workflow Name (in .ga file)
- **MUST** be human-readable
- **CAN** use spaces, capitalization
- **NO** abbreviations unless universally known
- Examples:
  - ✅ `"Parallel Accession Download from SRA"`
  - ✅ `"RNA-Seq Analysis: Paired-End Reads"`
  - ❌ `"par_acc_dl"`
  - ❌ `"rnaseq_pe"`

#### Input/Output Labels
- **MUST** be human-readable
- **CAN** use spaces
- **SHOULD** be descriptive
- **NO** technical abbreviations
- Examples:
  - ✅ `"Collection of paired FASTQ files"`
  - ✅ `"Reference genome FASTA"`
  - ❌ `"fastq_coll"`
  - ❌ `"ref_fa"`

#### Compound Adjectives
- Use **singular** form when modifying nouns
- Examples:
  - ✅ `"short-read sequencing"` (read modifies sequencing)
  - ✅ `"single-end library"`
  - ❌ `"short-reads sequencing"`
  - ❌ `"single-ends library"`

### Quality Standards & Best Practices

#### Workflow Design Principles

1. **Generic Workflows**
   - NO hardcoded sample names in labels
   - Use parameter inputs for user-configurable values
   - Design for reusability across datasets

2. **Input/Output Naming**
   - Clear, descriptive labels
   - Explain expected format in annotation
   - Group related inputs logically

3. **Annotation Quality**
   - Workflow annotation: Detailed description of purpose, method, expected inputs/outputs
   - Step annotations: Brief explanation of what each step does
   - Parameter annotations: Guidance on choosing values

4. **Metadata Completeness**
   - Include creator with ORCID
   - Add IWC as organization creator
   - Specify license (default: MIT)
   - Use semantic versioning in `release` field

5. **Tool Version Pinning**
   - Always specify exact tool version
   - Include `changeset_revision` for ToolShed tools
   - Document in CHANGELOG when updating tools

#### Testing Best Practices

1. **Test Coverage**
   - Minimum one test case per workflow
   - Test different input types (if applicable)
   - Test edge cases and common use cases
   - Test all major workflow outputs

2. **Test Data Management**
   - Files < 100KB: Store in `test-data/` directory
   - Files ≥ 100KB: Upload to Zenodo, reference by URL
   - Always include SHA-1 hash for verification
   - Use minimal test data (trim large files to essentials)

3. **Assertion Strategy**
   - Use strictest possible assertions
   - Prefer exact file comparison when possible
   - Use size/line count when content varies
   - Use regex for timestamps or dynamic content

4. **Test Documentation**
   - Include `doc:` field explaining test scenario
   - Comment complex assertions
   - Document why certain tolerances are used

#### CI/CD Integration

**Planemo Commands**:
```bash
# Lint WORKFLOW files (.ga)
planemo workflow_lint --iwc workflow.ga

# Lint TOOL files (.xml)
planemo lint tool.xml

# Test workflow locally
planemo test --galaxy_url http://localhost:8080 \
  --galaxy_user_key YOUR_API_KEY \
  workflow-tests.yml

# Test workflow with Docker
planemo test --galaxy_docker_image quay.io/galaxyproject/galaxy-min:25.1 \
  workflow-tests.yml
```

**IMPORTANT**: Always use `workflow_lint` for workflows (`.ga` files), not `lint`. The `lint` command is only for Galaxy tool XML files.

**GitHub Actions Integration**:
- Workflows tested on every PR
- Uses Galaxy release_25.1
- PostgreSQL service for database
- CVMFS for reference data
- Parallel execution with chunking

### Common Workflow Patterns

#### Pattern 1: Data Fetching
```
Input: Accession list
↓
Tool: Fetch data (e.g., fasterq-dump)
↓
Tool: Quality control (e.g., FastQC)
↓
Output: Raw reads + QC report
```

#### Pattern 2: Read Processing
```
Input: FASTQ files
↓
Tool: Quality trimming
↓
Tool: Alignment/Mapping
↓
Tool: Post-processing
↓
Output: Processed data + statistics
```

#### Pattern 3: Analysis Pipeline
```
Input: Processed data + reference
↓
Tool: Primary analysis (e.g., variant calling, quantification)
↓
Tool: Filtering/Normalization
↓
Tool: Visualization
↓
Output: Results + plots + reports
```

### Workflow Categories in IWC

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

### Review Checklist

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

### Tools and Resources

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

### Common Issues and Solutions

#### Issue: Test fails with "output not found"
**Solution**: Check output label matches exactly (case-sensitive)

#### Issue: Large test files in repository
**Solution**: Upload to Zenodo, reference by URL with hash

#### Issue: Workflow not generic
**Solution**: Replace hardcoded values with parameter inputs

#### Issue: Tool update breaks workflow
**Solution**: Pin exact version in tool_shed_repository.changeset_revision

#### Issue: Tests pass locally but fail in CI
**Solution**: Check reference data availability on CVMFS

#### Issue: Workflow lint warnings
**Solution**: Run `planemo workflow_lint --iwc` and address each warning

### Version Bumping

When updating a workflow:
1. Update `release` field in .ga file
2. Add entry to CHANGELOG.md
3. Update tests if needed
4. Commit with descriptive message

Example:
```bash
# Update release field
# release: "0.1.1" → "0.1.2"

# Add CHANGELOG entry
echo "## [0.1.2] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "### Changed" >> CHANGELOG.md
echo "- Description of changes" >> CHANGELOG.md
```

### Deployment Pipeline

After PR merge:
1. ✅ Tests pass
2. 📦 RO-Crate metadata generated
3. 🚀 Deployed to iwc-workflows organization
4. 📋 Registered on Dockstore
5. 🌐 Registered on WorkflowHub
6. 🌌 Auto-installed on usegalaxy.* servers

---

## Testing Workflows with Planemo

### Common Planemo Lint Errors and Fixes

When running `planemo workflow_lint` or `planemo test`, errors are often related to test file configuration, not the workflow itself.

**IMPORTANT**: Never modify the workflow file (`.ga`) to fix test errors - only modify the test file (`.yml`).

#### Input Parameter Name Mismatches

**Error Pattern**:
```
ERROR: Non-optional input has no value specified in workflow test job [Input Name]
WARNING: Unknown workflow input in test job definition [Input Name], workflow inputs are [['Other Name ', ...]]
```

**Cause**: The workflow input has a trailing space (or other whitespace) that doesn't match the test file key.

**Fix**: Quote the key name in the test YAML file to preserve exact spacing:
```yaml
# Instead of:
Remove adapters from HiFi reads?: false

# Use (note the space before closing quote):
"Remove adapters from HiFi reads? ": false
```

**How to identify**: Look carefully at the error message - it shows both what you provided and what the workflow expects. Compare character-by-character including spaces.

#### Test File Syntax Errors

**Error Pattern**: YAML parsing errors or unexpected behavior

**Common typos**:
- `ppath` instead of `path`
- Missing colons or incorrect indentation
- Unquoted strings with special characters

**Fix**: Carefully review the test file line-by-line. Use a YAML validator if needed.

### Running Planemo Tests on Remote Galaxy Instances

#### Best Practice: Always Prefer Live Instances

**IMPORTANT: Always test against live Galaxy instances** instead of spinning up local Galaxy:

```bash
# ✅ PREFERRED: Test against live instance
planemo test --fail_fast \
  --galaxy_url https://vgp.usegalaxy.org \
  --galaxy_user_key "$MAINKEY" \
  workflow.ga

# ❌ AVOID: Local Galaxy (slow, dependency issues)
planemo test --fail_fast workflow.ga
```

**Why live instances are superior:**
- **Much faster**: No Galaxy setup time (saves 5-10 minutes per test)
- **More reliable**: Dependencies already installed on production instance
- **Tests real environment**: Validates against actual production setup
- **Less resource intensive**: No local Docker/Galaxy overhead
- **Correct tool versions**: Production servers have the exact versions users will use

**Common live instances for VGP workflows:**
- VGP workflows: `https://vgp.usegalaxy.org` with `$MAINKEY`
- General workflows: `https://usegalaxy.org` or `https://usegalaxy.eu`

**When to use local Galaxy:**
- Testing unreleased tools not yet on public instances
- Testing tool wrapper changes before deployment
- Debugging Galaxy configuration issues
- Network/connectivity issues prevent remote access

**Test duration expectations:**
- Complex workflows (80+ steps): 30-60 minutes on live server
- Simple workflows (<20 steps): 5-15 minutes on live server
- Local Galaxy: Add 5-10 minutes for setup time

**Best Practice**: For IWC workflows, always test on the target Galaxy server (usegalaxy.org, usegalaxy.eu, or specialized instances like VGP) to ensure compatibility with production tool versions and configurations.

#### Command Structure

**Command structure**:
```bash
planemo test --galaxy_url https://galaxy.instance.org --galaxy_user_key $API_KEY workflow.ga
```

**Key flags**:
- `--galaxy_url`: The remote Galaxy instance URL
- `--galaxy_user_key`: User API key (NOT `--api_key` or `--galaxy_api_key`)
- `--galaxy_admin_key`: Admin key (for admin operations)
- `--timeout`: Optional timeout in milliseconds (default 120000, max 600000)
- `--fail_fast`: Stop on first job failure (recommended for workflow updates)
- `--failed`: Re-run only failed tests (requires tool_test_output.json from previous run)

**When to use --fail_fast**:
- **Workflow updates** (existing workflow being modified): Use `--fail_fast` by default to save time
  ```bash
  planemo test --fail_fast --galaxy_url ... --galaxy_user_key $KEY workflow.ga
  ```
- **New workflows** (first time testing): Ask the user if they want to use `--fail_fast`
  - Without `--fail_fast`: All tests run to completion, showing all failures
  - With `--fail_fast`: Stops at first failure, faster feedback but incomplete results

**Re-running failed tests**:
After a test run completes with failures, **ask the user** if they want to re-run only the failed tests:
- **Yes (--failed)**: Re-runs only failed tests, faster iteration
  ```bash
  planemo test --failed --galaxy_url ... --galaxy_user_key $KEY workflow.ga
  ```
- **No**: User may want to fix issues first, review logs, or run all tests again

**Running in background**:
For long-running tests, capture the shell ID and check later:
```bash
planemo test --galaxy_url ... --galaxy_user_key $KEY workflow.ga &
# Note the shell ID, then check with:
# jobs or fg
```

#### Monitoring Test Progress

**Best Practice: Don't spam-check test status.** Instead:

1. **Check once** after starting the test
2. **Report last check timestamp** and current status to the user
3. **Recommend specific wait time** based on:
   - Workflow complexity (number of steps/jobs)
   - Test phase (execution vs. output collection)
   - Instance type (live vs. local)

**Example status report**:
```
Last check: 2026-02-16T18:34:25Z
Status: Workflow complete (61/61 jobs ✅), collecting outputs (9 test cases)
Recommendation: Check again in 2-3 minutes

Typical phases and durations:
- Workflow execution: 5-15 minutes (depends on workflow complexity)
- Output collection: 2-5 minutes (depends on file sizes and network)
- Local Galaxy startup: Add 5-10 minutes to total time
```

**Why this matters:**
- Avoids unnecessary API calls and token usage
- Provides better user experience with clear expectations
- Prevents polling fatigue during long-running operations

**How to check status** (when using background execution):
```bash
# For background jobs
BashOutput --bash_id <shell_id>

# Status will show one of:
# - running: Test still executing
# - success: All tests passed
# - failed: One or more tests failed
```

**Exit codes**:
- Exit 1: Linting warnings (workflow still structurally valid if "CHECK: Tests appear structurally correct")
- Exit 2: Command syntax error (wrong flags)
- Exit 0: All tests pass

### Interpreting Planemo Lint Output

Planemo lint shows three categories of messages:

**WARNINGS** (exit code 1):
- Missing annotations, labels on workflow steps
- Disconnected inputs (conditional inputs that may not be used)
- These are quality-of-life issues, not blocking errors
- Workflow is still valid if final checks pass

**ERRORS** (exit code 1):
- Test file configuration issues
- Missing required inputs in test jobs
- Input name mismatches
- Must be fixed before tests will run

**CHECKS** (exit code depends on context):
```
.. CHECK: Tests appear structurally correct for workflow.ga
.. CHECK: All tool ids appear to be valid.
```
- These indicate the workflow structure is valid
- If you see both CHECKs after warnings/errors, the workflow file itself is fine
- Focus on fixing ERROR messages in the test file

**Workflow is ready to test when**:
- Both CHECK messages appear
- No ERROR messages (or all errors fixed)
- Warnings about annotations/labels are acceptable

### Adjusting Test Assertions After Initial Runs

After running tests and seeing assertion failures, adjust expectations based on actual outputs:

**File Size Assertions**:
When `has_size` assertions fail, update based on actual values:

```yaml
# Before (failed):
BigWig Coverage:
  asserts:
    has_size:
      value: 60000
      delta: 30000

# After (adjusted to actual: 9011 bytes):
BigWig Coverage:
  asserts:
    has_size:
      value: 10000
      delta: 5000  # ±50% tolerance
```

**Guidelines for size assertions**:
- Use **±50% delta** for binary files (BAM, BigWig, Pretext) - compression varies
- Use **±30% delta** for text files if content may vary slightly
- For multi-collection tests, scale expected sizes proportionally (e.g., 2x data ≈ 2x file size)

**Text Pattern Assertions**:
When `has_line` with exact patterns fails, simplify to `has_text`:

```yaml
# Too strict (failed):
Gaps Bed:
  asserts:
    has_text:
      text: "scaffold_10.H1"
    has_line:
      line: "scaffold_10.H1\t"  # Exact tab pattern
      n: 2

# Less strict (better):
Gaps Bed:
  asserts:
    has_text:
      text: "scaffold_10.H1"  # Just check presence
```

**Workflow**: Run test → Check failures → Adjust assertions → Re-run with `--failed`

### Testing with Multiple Read Collections

#### MarkDuplicates with Multiple Hi-C Datasets

**Problem**: When testing workflows with multiple Hi-C read sets in a collection (e.g., `list:paired`), Picard MarkDuplicates may fail with:

```
Exception in thread "main" htsjdk.samtools.SAMException:
Value was put into PairInfoMap more than once 3: RGread_3623
```

**Cause**: Test data files contain reads with identical names across different collection elements (e.g., `read_3623` appears in both `Hi-C_set_1` and `Hi-C_set_2`).

**Solution**: For tests with multiple read collections, disable MarkDuplicates:

```yaml
- doc: Test 2 - Multiple read sets with collections
  job:
    Hi-C reads:
      class: Collection
      collection_type: list:paired
      elements:
      - class: Collection
        identifier: Hi-C_set_1
        # ... multiple sets ...
    Remove duplicated Hi-C reads?: false  # Disable for multi-collection tests
```

**Best Practice**:
- **Test 1** (single collection): Enable MarkDuplicates to test the feature
- **Test 2** (multiple collections): Disable MarkDuplicates to avoid duplicate name conflicts

**Alternative**: Rename reads in test data files to ensure globally unique identifiers across all collection elements.

### Troubleshooting Tool Failures

When tests fail due to tool errors (not test configuration), the issue may be with the Galaxy tool wrapper itself.

#### Tool Wrapper Argument Errors

**Symptom**: Test fails with error like `Error: Got unexpected extra argument (path/to/file)`

**Common Causes**:
1. **Tool wrapper bug**: The Galaxy tool wrapper is incorrectly constructing command-line arguments
2. **Version mismatch**: Different galaxy versions of the same tool (e.g., `1.1.3+galaxy3` vs `1.1.3+galaxy6`) may have different bugs
3. **Server-side issue**: Tool may work locally but fail on remote Galaxy server

**Diagnosis Steps**:
```bash
# 1. Check the error file for exact command that failed
cat error_tool_*.txt

# 2. Identify which tool version is used in subworkflow
grep -A 5 "tool_id.*tool_name" workflow.ga

# 3. Check if workflow uses multiple versions of same tool
grep "tool_name" workflow.ga | sort | uniq -c
```

**Resolution**:
- Update workflow to use a newer/fixed version of the tool
- Check Galaxy tool shed for changelog or bug reports
- If affecting production server, contact Galaxy administrators
- Consider testing on different Galaxy instance to isolate issue

**Example**: pairtools_parse tool had argument handling bug in galaxy3/galaxy6 versions that was fixed in later releases.

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

# Apply to subworkflows
for step_id, step in workflow.get('steps', {}).items():
    if step.get('type') == 'subworkflow' and 'subworkflow' in step:
        step['subworkflow'] = add_release(step['subworkflow'])

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

print("✓ Transformations applied successfully")
```

This script safely processes large workflow files and handles nested subworkflows automatically. It typically cleans 50-150 runtime parameter entries in complex workflows.

---

## Writing Methods Sections for Publications

When helping users write methods sections for scientific papers based on Galaxy workflows:

### 1. Workflow Analysis Strategy

**Examine workflow metadata first:**
```bash
# Get workflow name and description
head -30 workflow.ga | grep -E '"name"|"annotation"'

# Extract tool names and versions
grep -o '"tool_id": "[^"]*"' workflow.ga | sort -u

# Find specific tools (e.g., assemblers)
grep -o '"tool_id": "[^"]*hifiasm[^"]*"' workflow.ga
```

**For large workflows (>25000 tokens):**
- Don't read entire files - they'll exceed token limits
- Use grep to extract specific information
- Read only first 100 lines for metadata: `head -100 workflow.ga`
- Search for tool patterns rather than reading everything

### 2. VGP Workflow Documentation Pattern

For VGP pipeline workflows, document in this order:

1. **Platform and pipeline**: "implemented in Galaxy (cite) using VGP workflows (cite)"
2. **Data-specific approach**: Distinguish trio vs non-trio methods
3. **Sequential workflow steps**:
   - K-mer profiling (Meryl, GenomeScope2)
   - Assembly (HiFiasm with appropriate mode)
   - Scaffolding (RagTag with reference)
   - Quality assessment (BUSCO/Compleasm, Merqury, gfastats)
4. **Tool versions**: Always include version numbers
5. **Specific parameters**: Reference genomes, accessions used

### 3. Methods Section Template

```markdown
Genome assemblies were generated using the [Pipeline Name] workflows (Citation)
implemented in Galaxy (Galaxy Community, 2024). For [condition A], we employed
[approach A]: first, [step 1] using [Tool v.X] (Citation), followed by [step 2]
using [Tool v.Y] (Citation). For [condition B], we performed [approach B]
using [Tool v.Z] (Citation). All assemblies were [post-processing step] using
[Tool] with [specific parameter/reference]. Assembly quality was assessed using
multiple metrics including [Tool A] for [metric type], [Tool B] for [metric type],
and [Tool C] for [metric type]. [Annotation or downstream analysis] was performed
using [Tool/Pipeline] (Citation), which [brief description]. [Specific data sources
with accessions].
```

### 4. Common VGP Workflow Tool Citations Needed

**Core tools to cite:**
- Galaxy platform: The Galaxy Community (2024)
- VGP workflows: Larivière et al. (2024) Nature Biotechnology
- HiFiasm: Cheng et al. (2021) Nature Methods
- Meryl: Rhie et al. (2020) Genome Biology
- GenomeScope2: Ranallo-Benavidez et al. (2020) Nature Communications
- Merqury: Rhie et al. (2020) Genome Biology
- BUSCO: Manni et al. (2021) MBE
- Compleasm: Huang & Li (2023) Bioinformatics
- RagTag: Alonge et al. (2022) Genome Biology
- gfastats: Formenti et al. (2022) Bioinformatics
- EGApX: Thibaud-Nissen et al. (2013) NCBI Handbook

### 5. Key Information to Extract from Workflows

**From workflow annotation field:**
- Purpose and description
- Pipeline position (e.g., "Part of VGP suite, run after VGP1")

**From tool_id fields:**
- Primary assembler (hifiasm, flye, etc.)
- Scaffolding tool (ragtag, yahs, etc.)
- QC tools (busco, merqury, etc.)

**From inputs:**
- Data types required (HiFi, Hi-C, Illumina, trio data)
- Reference genome requirements
- RNA-seq accessions for annotation

**From parameters:**
- K-mer lengths
- Ploidy settings
- BUSCO lineages
- Coverage thresholds

### 6. Workflow File Size Considerations

**Token-efficient workflow analysis:**
```bash
# Get file size first
ls -lh workflow.ga

# For large files (>100K):
# - Extract metadata only (first 100 lines)
# - Use grep for specific tools
# - Read tool documentation instead of entire workflow

# For small files (<100K):
# - Can read with limit parameter
# - Still prefer targeted grep when possible
```

---

## Related Skills

- **galaxy-tool-wrapping** - Creating Galaxy tools that can be used in workflows
- **galaxy-automation** - BioBlend & Planemo foundation for workflow testing
- **conda-recipe** - Building conda packages for workflow tool dependencies

---

## Applying This Knowledge

When helping with Galaxy workflow development:

1. **Creating new workflows**: Follow IWC structure and naming conventions
2. **Writing tests**: Use appropriate assertions and test data management
3. **Reviewing workflows**: Apply the review checklist systematically
4. **Debugging**: Check lint output and test logs carefully
5. **Updating workflows**: Maintain CHANGELOG and version properly
6. **Documentation**: Write clear, detailed annotations and READMEs

Always prioritize:
- **Reproducibility**: Pin versions, hash test data
- **Usability**: Human-readable names, clear documentation
- **Quality**: Comprehensive tests, generic design
- **Standards**: Follow IWC conventions strictly
