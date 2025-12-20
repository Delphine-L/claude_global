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

## Lessons Learned

1. **Version changes that break existing functionality are usually dependency-related**, not platform-related
2. **Shared requirements across tool suites can cause conflicts** - split them when tools have different needs
3. **R commands with complex parameters need configfiles** to avoid quoting issues
4. **Always test after adding new dependencies** - they may conflict with existing tools
5. **Exit code 133 often indicates dependency conflicts**, not code bugs
