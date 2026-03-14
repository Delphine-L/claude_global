# Galaxy Tool Troubleshooting Guide

Practical troubleshooting tips learned from real Galaxy tool development.

## Diagnosing Test Failures

### Reading tool_test_output.json

When tests fail, examine `tool_test_output.json` for:
- **exit_code**: Non-zero indicates failure
- **stderr/tool_stderr**: Error messages from the tool
- **command_line**: The actual command that was executed
- **output_problems**: Summary of what went wrong

Common exit codes:
- `1`: General error (often command syntax or missing dependencies)
- `133`: SIGTRAP - Usually binary compatibility issue or dependency conflict
- `137`: SIGKILL - Out of memory
- `139`: SIGSEGV - Segmentation fault

### Example: Analyzing Failures

```json
{
    "exit_code": 133,
    "stderr": "Trace/breakpoint trap",
    "tool_id": "rdeval"
}
```

This indicates a binary crash, often due to:
1. Dependency conflicts
2. Platform incompatibility
3. Corrupted package

## Common Issues and Solutions

### Issue 1: R Command Quoting Errors

**Symptom**: `ERROR: option '-e' requires a non-empty argument`

**Problem**: Shell quoting conflicts when passing complex R code via `R -e "..."`:
```xml
<!-- WRONG: Quotes conflict -->
R -e "rmarkdown::render(..., params=list(input_files=c('file1.rd', 'file2.rd')))"
```

**Solution**: Use a `<configfile>` instead:
```xml
<command><![CDATA[
    Rscript '$r_script'
]]></command>

<configfiles>
    <configfile name="r_script"><![CDATA[
rmarkdown::render(
    'input.Rmd',
    output_file='$output',
    params=list(
        input_files=c('file1.rd', 'file2.rd')
    )
)
]]></configfile>
</configfiles>
```

**Benefits**:
- No shell quoting issues
- Better readability
- Easier debugging

### Issue 2: Dependency Conflicts Between Tools

**Symptom**: Tool works with version X but crashes with version Y after adding new dependencies

**Problem**: Shared requirements macro includes dependencies that conflict with some tools:

```xml
<!-- WRONG: All tools share same requirements -->
<macros>
    <xml name="requirements">
        <requirements>
            <requirement type="package" version="1.0">tool_binary</requirement>
            <requirement type="package" version="2.0">r-somepackage</requirement>
        </requirements>
    </xml>
</macros>
```

When used by:
- `tool.xml` - Binary tool (doesn't need R packages, but they cause conflicts)
- `tool_report.xml` - R reporting tool (needs R packages)

**Solution**: Split requirements into tool-specific macros:

```xml
<macros>
    <!-- For binary tools -->
    <xml name="requirements">
        <requirements>
            <requirement type="package" version="1.0">tool_binary</requirement>
        </requirements>
    </xml>

    <!-- For R reporting tools -->
    <xml name="requirements_report">
        <requirements>
            <requirement type="package" version="1.0">tool_binary</requirement>
            <requirement type="package" version="2.0">r-somepackage</requirement>
            <requirement type="package" version="3.0">r-rmarkdown</requirement>
        </requirements>
    </xml>
</macros>
```

Then use appropriate macro in each tool:
```xml
<!-- tool.xml -->
<expand macro="requirements"/>

<!-- tool_report.xml -->
<expand macro="requirements_report"/>
```

### Issue 3: Missing R Package Dependencies

**Symptom**: R command fails with "there is no package called 'X'"

**Problem**: Tool uses R packages not listed in requirements

**Solution**: Check what R packages are actually used and add them:

Common R packages needed:
- `r-rmarkdown` - For `rmarkdown::render()`
- `r-ggplot2` - For plotting
- `r-cowplot` - For plot arrangements
- `r-dplyr` - For data manipulation
- `r-tidyr` - For data tidying

Example:
```xml
<requirements>
    <requirement type="package" version="2.16">r-rmarkdown</requirement>
    <requirement type="package" version="1.2.0">r-cowplot</requirement>
</requirements>
```

### Issue 4: Platform-Specific Test Failures

**Symptom**: Tests fail on macOS with Rosetta errors but work on Linux

**Error**: `rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2`

**Root Cause**: Testing Linux containers on Apple Silicon Mac

**Solutions**:
1. **Test on Linux** - Use CI/CD or Linux VM
2. **Check for dependency conflicts first** - If version N-1 works but version N doesn't, it's likely not a platform issue
3. **Use native Mac tools** - If available
4. **Docker Desktop settings** - Ensure proper VM configuration

**Key insight**: If an older version works fine but newer version fails with same platform, it's NOT a platform issue—it's a dependency/packaging issue!

## Debugging Workflow

### Step 1: Identify the Failure Pattern

Run tests and check:
```bash
planemo test tool.xml
```

Look at the JSON output:
- How many tests fail?
- Do they all fail the same way?
- What are the exit codes?

### Step 2: Check Recent Changes

Ask yourself:
- What changed between working and non-working version?
- Were new dependencies added?
- Did the tool version change?

### Step 3: Isolate the Problem

For dependency conflicts:
```bash
# Check what changed
git diff HEAD~1 macros.xml

# Test with minimal dependencies
# Temporarily comment out new dependencies in macros.xml
```

### Step 4: Review Command Execution

From `tool_test_output.json`, look at `command_line`:
- Is the command properly formatted?
- Are quotes balanced?
- Are variables expanded correctly?

### Step 5: Check Container/Environment

```bash
# Test if the tool package itself works
planemo conda_install tool.xml
planemo conda_env tool.xml

# Then test manually
source activate <env_name>
tool_binary --version
```

## Best Practices for Robust Tools

### 1. Separate Requirements by Tool Type

```xml
<macros>
    <!-- Minimal requirements for binary tools -->
    <xml name="requirements_base">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
        </requirements>
    </xml>

    <!-- Extended requirements for analysis tools -->
    <xml name="requirements_analysis">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
            <requirement type="package" version="1.0">python-lib</requirement>
        </requirements>
    </xml>

    <!-- Requirements for reporting tools -->
    <xml name="requirements_report">
        <requirements>
            <requirement type="package" version="@TOOL_VERSION@">tool</requirement>
            <requirement type="package" version="2.0">r-rmarkdown</requirement>
        </requirements>
    </xml>
</macros>
```

### 2. Use Configfiles for Complex Scripts

Instead of inline shell/R/Python in `<command>`, use `<configfiles>`:

```xml
<command><![CDATA[
    python '$python_script' > '$output'
]]></command>

<configfiles>
    <configfile name="python_script"><![CDATA[
import sys

# Your Python code here
param1 = '$param1'
param2 = $param2

# Process...
print("Results")
]]></configfile>
</configfiles>
```

### 3. Test Incrementally

When adding features:
1. Add one parameter
2. Run tests
3. Add next parameter
4. Run tests again

Don't add everything at once!

### 4. Version Pin Critical Dependencies

```xml
<!-- GOOD: Specific version -->
<requirement type="package" version="2.16">r-rmarkdown</requirement>

<!-- RISKY: May break when updated -->
<requirement type="package">r-rmarkdown</requirement>
```

### 5. Document Dependency Reasons

```xml
<xml name="requirements_report">
    <requirements>
        <requirement type="package" version="@TOOL_VERSION@">rdeval</requirement>
        <!-- For rendering HTML reports -->
        <requirement type="package" version="2.16">r-rmarkdown</requirement>
        <!-- For plot arrangements in figures -->
        <requirement type="package" version="1.2.0">r-cowplot</requirement>
    </requirements>
</xml>
```

## Real-World Example: rdeval Tool Suite

### Problem
- Tool worked in version 0.0.7
- Added r-cowplot and r-rmarkdown for reporting features
- Version 0.0.8 started crashing with exit code 133
- Binary tool (rdeval.xml) was getting R packages it didn't need

### Solution
1. Split requirements:
   - `requirements` - Just rdeval binary (for rdeval.xml)
   - `requirements_report` - rdeval + R packages (for rdeval_report.xml)

2. Fixed R command quoting:
   - Changed from `R -e "..."` to `Rscript` with configfile

3. Added missing r-rmarkdown dependency

### Result
- Binary tool no longer has conflicting R dependencies
- Report tool has all needed R packages
- Both tools work correctly

### Problem: Report shows wrong statistics (v0.0.8)
- HTML report from `rdeval_report` showed wrong read lengths, N50, plots
- Tabular output from `rdeval --tabular` was correct
- Issue was in upstream `rdeval_interface.R`, not the Galaxy wrapper

### Debugging approach
1. **Compare outputs**: Galaxy tabular vs HTML report vs CLI report on same data
2. **Trace the pipeline**: rdeval → .rd file → R interface → HTML report
3. **Verify .rd files**: Run `rdeval --input-reads file.rd --tabular` to confirm .rd data is correct
4. **Test R interface locally**: Run `rdeval_interface.R` on the .rd file to isolate the R reader
5. **Binary format analysis**: Compute expected data sizes to identify format mismatch
   - `5*len8 + 6*len16 + 12*len64` vs `8*len8 + 8*len16 + 16*len64`
6. **Check release artifacts**: Compare release zip sha256 with conda recipe to detect silent updates

### Lesson
When upstream tools bundle companion scripts (R, Python), format changes in the binary can break the script readers. Always verify both sides match.

### Naming in report tools
When a report tool processes collection elements, use `element_identifier` not numeric indices:
```xml
#set $safe_name = re.sub(r"[^\w\-.]", "_", str($input_file.element_identifier))
ln -s '$input_file' '${safe_name}.rd' &&
```

## Testing Tips

### Local Testing

```bash
# Lint first
planemo lint tool.xml

# Test with fresh environment
planemo test --conda_auto_install tool.xml

# Test specific test case
planemo test --test_index 0 tool.xml
```

### Debug Mode

```bash
# Keep test data after failure
planemo test --no_cleanup tool.xml

# See detailed output
planemo test --verbose tool.xml
```

### Container Testing

```bash
# Build container
planemo container_register tool.xml

# Test in container
planemo test --biocontainers tool.xml
```

## Resources

- **Galaxy Tool Best Practices**: https://galaxy-iuc-standards.readthedocs.io/
- **Planemo Documentation**: https://planemo.readthedocs.io/
- **Conda Package Search**: https://anaconda.org/bioconda/
- **Galaxy Training**: https://training.galaxyproject.org/

## Quick Reference

| Symptom | Likely Cause | Solution |
|---------|-------------|----------|
| Exit code 133 | Binary conflict/dependency issue | Check recent dependency changes |
| "no package called X" | Missing R dependency | Add to requirements |
| Quote/argument errors | Shell quoting issues | Use configfile |
| Works in v1, fails in v2 | Dependency conflict | Review requirement changes |
| Rosetta errors + new deps | Dependency conflict, not platform | Remove/isolate new dependencies |
| All tests fail same way | Systemic issue (deps/command) | Check requirements first |
| Some tests fail | Test-specific issue | Check test parameters |

## Common XML and Runtime Issues

**Issue: "Command not found"**
- Check `<requirements>` section has correct package
- Verify conda package name and version
- Test command availability: `planemo conda_install tool.xml`

**Issue: "Output file not found" or 0-byte output with exit_code=0**
- Verify command actually creates the file
- Check output file path matches `<data name="output" from_work_dir="...">`
- Use `discover_datasets` for dynamic outputs
- **`from_work_dir` vs `$output` conflict**: If command writes to `$output` but output
  definition has `from_work_dir="filename"`, Galaxy looks for `filename` in the working
  directory instead. This causes 0-byte outputs especially on remote/Pulsar job runners.
  Fix: either remove `from_work_dir` (if command uses `$output`) or change the command to
  write to the `from_work_dir` filename instead of `$output`.

**Issue: "Test failed"**
- Compare expected vs actual output
- Check for whitespace/newline differences
- Use `sim_size` for approximate size matching
- Add `lines_diff` for line-by-line comparison

**Issue: Tool has multiple output flags (`-o` vs `-p`) with different behavior**
- `-o`/`--out-file` typically writes to an explicit filename with extension
- `-p`/`--out-prefix` typically constructs filename as `prefix + input_filename`
- These flags may produce different output types (e.g., `-o` generates rd/binary files,
  `-p` generates same-format-as-input files)
- Check the tool's source code to understand naming conventions before wrapping
- Use separate output type conditionals for each mode rather than trying to unify them

**Issue: "Invalid XML"**
- Run `planemo lint tool.xml`
- Check closing tags match opening tags
- Validate CDATA sections for command blocks
- Ensure proper escaping of special characters

## Debugging Tool Test Failures

### General Workflow

1. **Read the test output JSON first**
   ```bash
   cat tool_test_output.json
   ```
   Look for:
   - Exit codes and error messages in `stderr`/`stdout`
   - `output_problems` array for test assertion failures
   - Actual vs expected output differences

2. **Never copy/modify conda package scripts**
   - Tool wrappers should ALWAYS use conda packages
   - If there are bugs in the conda package scripts, work around them in the XML wrapper
   - Common workaround: Add trailing slashes to paths if script concatenates without separators

3. **Wrong test expectations vs bugs**
   - If tests fail but the tool runs successfully (exit code 0), check if expected test files are wrong
   - Regenerate expected outputs by running the tool manually with test inputs
   - Update `expect_num_outputs` if optional outputs are created

### Common Test Failure Fixes

**Path concatenation bugs in Python scripts:**
```xml
<!-- If script does: args.output_dir + 'file.txt' without '/' -->
<!-- Fix in wrapper with trailing slash: -->
-o 'output_dir/'  <!-- instead of -o output_dir -->
```

**Wrong number of expected outputs:**
```xml
<!-- Check if optional outputs are always created -->
<test expect_num_outputs="3">  <!-- Update count -->
```

**Output has extra sequences/data:**
- First check if this is expected behavior
- Regenerate expected test files from actual tool output
- Don't add post-processing filters unless absolutely necessary

**`has_size` attribute restrictions (XSD validation):**
- `has_size` does NOT support `compare="ge"` or similar -- planemo lint will reject it
- Use `value` and `delta` attributes: `<has_size value="148" delta="50"/>`
- This asserts the size is within `value +/- delta` bytes
- For minimum size checks, use a value with a large enough delta

**Galaxy decompresses tar.gz/tgz files -- tool receives plain tar:**
When a param accepts `format="tar.gz"`, `format="tgz"`, or `format="tar,gz,tgz"`,
Galaxy may strip the gzip layer before passing the file to the tool. The tool receives
a plain tar archive, not gzip-compressed. Symptom: `gzip: invalid magic` or
`tar: invalid magic` when trying `tar -xzf` or `gzip -dc`.

```xml
<!-- BAD: assumes file is still gzip-compressed -->
tar -xzf '${input_archive}' -C ./output_dir
gzip -dc '${input_archive}' | tar xf - -C ./output_dir

<!-- GOOD: use plain tar extraction (Galaxy already decompressed) -->
tar xf '${input_archive}' -C ./output_dir

<!-- For creating tar.gz output (gzip is needed here): -->
tar cf - -C ./input_dir . | gzip > output.tar.gz
```

**Cascade failures from empty/broken upstream outputs:**
When debugging multiple errors in a test history, check datasets in order.
A 0-byte or errored output fed as input to a subsequent tool will produce
misleading errors (e.g., "error reading header"). Always fix the root cause
(first failing dataset) before investigating downstream errors.

**tar flag order bug (`-xfz` vs `-xzf`):**
`tar -xfz file.tar.gz` means "extract, file=z, then file.tar.gz is a positional arg".
The `-f` flag consumes the next character as the filename. Error: `tar: can't open 'z'`.
Fix: always put `-f` last (`tar -xzf`) or use positional syntax (`tar xf file`).

**Test conditional nesting must match input structure:**
If a conditional is expanded via macro inside `mode_conditional`, test params must nest it:
```xml
<!-- BAD: blobtk_plot_options outside mode_conditional -->
<conditional name="mode_conditional">
    <param name="selector" value="filter"/>
</conditional>
<conditional name="blobtk_plot_options">
    <param name="blobtk_plot" value="no"/>
</conditional>

<!-- GOOD: nested inside mode_conditional -->
<conditional name="mode_conditional">
    <param name="selector" value="filter"/>
    <conditional name="blobtk_plot_options">
        <param name="blobtk_plot" value="no"/>
    </conditional>
</conditional>
```
Planemo lint reports: `WARNING (TestsCaseValidation): Invalid parameter name found`.

## Lessons Learned

1. **Version changes that break existing functionality are usually dependency-related**, not platform-related
2. **Shared requirements across tool suites can cause conflicts** - split them when tools have different needs
3. **R commands with complex parameters need configfiles** to avoid quoting issues
4. **Always test after adding new dependencies** - they may conflict with existing tools
5. **Exit code 133 often indicates dependency conflicts**, not code bugs
6. **When tabular output is correct but report output is wrong**, the issue is likely in the report's data reader (R/Python script), not the tool itself
7. **Compare release zip sha256 with conda recipe** to check if release artifacts were silently updated: `shasum -a 256 release.zip` vs `meta.yaml` sha256
8. **C struct padding can silently break companion scripts** — when C++ code changes from `sizeof(pair<...>)` to compact writes, all readers must be updated
