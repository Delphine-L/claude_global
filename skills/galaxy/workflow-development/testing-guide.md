# Galaxy Workflow Testing Guide

Complete reference for testing Galaxy workflows with Planemo, including test file structure, assertions, remote testing, troubleshooting, and test data management.

## Test File Structure

### Test File Naming Convention
- Workflow: `workflow-name.ga`
- Test file: `workflow-name-tests.yml` (identical name + `-tests.yml`)

### Test File Structure (YAML)

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

---

## Assertion Types

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

### Test Assertion Syntax Requirements

**CRITICAL**: Test assertions in `-tests.yml` files must follow exact formatting to avoid `planemo workflow_lint` errors.

**WRONG** (causes `AttributeError: 'str' object has no attribute 'copy'`):
```yaml
outputs:
  Output Name:
    asserts:
      has_text: "expected text here"
```

**CORRECT**:
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
- `has_text` -> `text: "value"`
- `has_size` -> `value: 1000, delta: 100`
- `has_line` -> `line: "exact line"`
- `has_n_lines` -> `n: 100`

---

## Configuring Planemo Tests from Galaxy Invocations

When creating Planemo test configurations, you can extract accurate parameter values from successful Galaxy workflow invocations.

### Step 1: Fetch Invocation Data

```bash
# Get invocation ID from Galaxy workflow invocation URL
# Example: https://galaxy.server.org/workflows/invocations/cc989bc4fb645bb5
INVOCATION_ID="cc989bc4fb645bb5"

# Fetch invocation details
curl -X 'GET' "https://galaxy.server.org/api/invocations/$INVOCATION_ID" \
  -H 'accept: application/json' \
  -H 'x-api-key: '$GALAXY_API_KEY > invocation.json
```

### Step 2: Extract Parameters

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

### Step 3: Structure Test YAML

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
          delta: 30000  # +/-50% tolerance
```

### Common Parameter Types and Formats

| Parameter Type | YAML Format | Example |
|----------------|-------------|---------|
| Boolean | `true`/`false` | `Do you want X?: true` |
| String | Plain or quoted | `Species Name: Test_species` |
| Number | Unquoted | `Minimum Quality: 10` |
| List (comma-sep) | Quoted string | `Patterns: "A,B,C"` |

### Validating Test Parameters

Before running tests, verify:

1. **All mandatory parameters present** - Check workflow file for required inputs
2. **Data types match** - Boolean as boolean, not string "true"
3. **File paths correct** - Zenodo URLs, local paths, or collection structures
4. **Output names match workflow** - Use exact labels from workflow outputs

### Testing Strategy for Collections

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

## Verifying Workflow Output Names

Workflow output names can change between versions. Always verify output names before creating test assertions.

### Extract All Workflow Outputs

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

### Common Output Name Patterns

Some tools change output names over versions:

| Old Name | Current Name | Tool |
|----------|--------------|------|
| `Seqtk-telo Output` | `Telomere Report` | seqtk_telo |
| `Telomeres Bedgraph` | `terminal telomeres` | custom scripts |
| `Coverage Track` | `BigWig Coverage` | bamCoverage |

Always verify against the actual `.ga` file, not documentation.

### Updating Test Assertions

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

## Test Data Organization

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

### Test Data README Template

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

### Documentation Best Practices

1. **README.md in test_data/**: SHA-1 hashes and file list
2. **TEST_DATA_README.md**: Detailed data characteristics
3. **TEST_CONFIGURATION_GUIDE.md**: How to use the test data
4. **TESTS_SUMMARY.md**: Quick start for developers

This helps reviewers understand test data without downloading/inspecting files.

### Matching Test Configuration to Workflow Paths

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

## Synthetic Test Data Generation

For workflow testing, synthetic data should include realistic biological features while remaining compact.

### Example: Assembly with Telomeres, Gaps, and Genes

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

### Key Features to Include

- **Telomeres**: Canonical repeats (TTAGGG/CCCTAA for vertebrates)
- **Assembly gaps**: 200bp N-sequences
- **Gene-like sequences**: ATG start + coding + stop codon (TAA/TAG/TGA)
- **Coverage gaps**: Regions with zero read coverage
- **Duplicates**: For paired-end data (10-15% duplication rate)

### Data Sizes for Testing

| Data Type | Minimal | Typical | Full |
|-----------|---------|---------|------|
| Assembly | 1-2 MB | 5-10 MB | 50+ MB |
| HiFi Reads | 500-1000 reads | 5,000 reads | 50,000+ |
| Hi-C Pairs | 10K pairs | 50K pairs | 1M+ pairs |

Minimal datasets enable fast CI/CD testing (~30-60 min runtime).

---

## Running Planemo Tests on Remote Galaxy Instances

### Best Practice: Always Prefer Live Instances

**IMPORTANT: Always test against live Galaxy instances** instead of spinning up local Galaxy:

```bash
# PREFERRED: Test against live instance
planemo test --fail_fast \
  --galaxy_url https://vgp.usegalaxy.org \
  --galaxy_user_key "$MAINKEY" \
  workflow.ga

# AVOID: Local Galaxy (slow, dependency issues)
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

### Command Structure

```bash
planemo test --galaxy_url https://galaxy.instance.org --galaxy_user_key $API_KEY workflow.ga
```

**Key flags**:
- `--galaxy_url`: The remote Galaxy instance URL
- `--galaxy_user_key`: User API key (NOT `--api_key` or `--galaxy_api_key`)
- `--galaxy_admin_key`: Admin key (for admin operations)
- `--timeout`: Optional timeout in milliseconds (default 120000, max 600000)
- `--check_uploads_ok`: Verify uploads succeed (**always use** for workflow tests)
- `--simultaneous_uploads`: Upload test datasets in parallel (**always use** for workflow tests)
- `--no_shed_install`: Skip tool installation when testing on a server that already has the tools
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

### Monitoring Test Progress

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
Status: Workflow complete (61/61 jobs), collecting outputs (9 test cases)
Recommendation: Check again in 2-3 minutes

Typical phases and durations:
- Workflow execution: 5-15 minutes (depends on workflow complexity)
- Output collection: 2-5 minutes (depends on file sizes and network)
- Local Galaxy startup: Add 5-10 minutes to total time
```

### Re-testing Against an Existing Invocation

To re-run test assertions against a completed invocation without re-executing the workflow:

```bash
planemo workflow_test_on_invocation \
  --galaxy_url "$GXYVGP" \
  --galaxy_user_key "$MAINKEY" \
  WORKFLOW-tests.yml INVOCATION_ID
```

> **Important**: The first argument is the **test YAML file** (not the .ga workflow file). Using the .ga file causes a confusing error about "file must contain a list of tests".

This is useful when:
- A test fails on output assertions only (all jobs succeeded)
- You've updated the test YAML and want to validate without re-running
- Debugging assertion values (size, text, line counts)

### Planemo Installation Fallbacks

If `planemo` is not found directly or in a conda env, try:
```bash
pipx run planemo <command>
```
This uses the pipx cache and doesn't require a dedicated environment.

### Verifying Tests via MCP When Planemo Fails

If `planemo workflow_test_on_invocation` gets stuck, use MCP to manually verify test assertions:

1. Connect to Galaxy: `mcp__Galaxy__connect(url, api_key)`
2. Get invocation details: `mcp__Galaxy__get_invocations(invocation_id, view="element", step_details=True)`
3. For each test output assertion, fetch the dataset:
   - `mcp__Galaxy__get_dataset_details(dataset_id, preview_lines=N)` for content checks
   - Check `metadata_data_lines` for `has_n_lines` assertions
   - Check `file_size` for `has_size` assertions
   - Check preview content for `has_text` assertions
4. Compare against the test YAML assertions manually

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

---

## Common Planemo Lint Errors and Fixes

When running `planemo workflow_lint` or `planemo test`, errors are often related to test file configuration, not the workflow itself.

**IMPORTANT**: Never modify the workflow file (`.ga`) to fix test errors - only modify the test file (`.yml`).

### Input Parameter Name Mismatches

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

### Test File Syntax Errors

**Error Pattern**: YAML parsing errors or unexpected behavior

**Common typos**:
- `ppath` instead of `path`
- Missing colons or incorrect indentation
- Unquoted strings with special characters

**Fix**: Carefully review the test file line-by-line. Use a YAML validator if needed.

### Output Label Mismatches Between Workflow and Test File

**Error Pattern**:
```
ERROR: Test found for unknown workflow output [Old Label], workflow outputs [['New Label', ...]]
```

**Cause**: A workflow output was renamed (e.g., during tool replacement or restructuring) but the test file still uses the old label.

**Fix**: Update the output key in the `-tests.yml` file to match the new workflow output label exactly:
```yaml
# Old (broken):
    Hi-C alignments stats multiqc:
      asserts:
        - has_text: ...

# New (fixed):
    Hi-C alignments on Scaffolds stats multiqc:
      asserts:
        - has_text: ...
```

**When this happens**: Commonly after replacing tools (e.g., MarkDuplicates -> samtools markdup) which changes output labels, or after renaming outputs for clarity.

**Detection**: Always run `planemo workflow_lint --iwc .` after workflow changes and before testing.

### Re-exported Workflows Reset IWC Transformations

**Problem**: When a workflow is modified in Galaxy and re-exported to a `.ga` file, the following IWC transformations are lost:
- `"release"` field is removed
- Runtime parameter descriptions (`"description": "runtime parameter..."`) reappear
- The `"readme"` field may be cleared or outdated

**Solution**: Always re-run `/prepare-for-iwc` after re-exporting a workflow from Galaxy. The command will re-apply all transformations and detect any new inputs/outputs that need documenting in README and CHANGELOG.

**Tip**: If the workflow was modified during testing (e.g., adding a new optional input), the re-exported `.ga` may also have renumbered steps. This is normal -- the preparation command handles it.

---

## Interpreting Planemo Lint Output

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

---

## Adjusting Test Assertions After Initial Runs

After running tests and seeing assertion failures, adjust expectations based on actual outputs:

### File Size Assertions
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
      delta: 5000  # +/-50% tolerance
```

**Guidelines for size assertions**:
- Use **+/-50% delta** for binary files (BAM, BigWig, Pretext) - compression varies
- Use **+/-30% delta** for text files if content may vary slightly
- For multi-collection tests, scale expected sizes proportionally (e.g., 2x data ~ 2x file size)

### Text Pattern Assertions
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

**Workflow**: Run test -> Check failures -> Adjust assertions -> Re-run with `--failed`

---

## Testing with Multiple Read Collections

### MarkDuplicates with Multiple Hi-C Datasets

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

---

## Troubleshooting Tool Failures

When tests fail due to tool errors (not test configuration), the issue may be with the Galaxy tool wrapper itself.

### Tool Wrapper Argument Errors

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

### gfastats Empty FASTA Output from Hifiasm GFA

**Symptom**: gfastats produces 0-byte fasta when converting hifiasm GFA, but GFA-to-GFA conversion works fine. Assembly summary shows `# scaffolds: 0`.

**Cause**: Hifiasm GFA files contain S (segment) and A (alignment) records but no W (walk) or P (path) lines. gfastats produces fasta by iterating over paths -- without `--discover-paths`, the path list is empty.

**Fix**: Ensure `discover_paths: true` is set in the gfastats `tool_state` at the `mode_condition` level (for `galaxy0` wrapper) or in `output_condition` (for `galaxy1` wrapper).

**Note**: gfastats `1.3.11+galaxy1` has a bug where `--discover-paths` was moved inside a GFA-only conditional, making it unavailable for fasta output. Use `1.3.11+galaxy0` until fixed. See [bgruening/galaxytools#1760](https://github.com/bgruening/galaxytools/pull/1760).
