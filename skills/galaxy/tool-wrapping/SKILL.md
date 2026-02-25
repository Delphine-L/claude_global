---
name: galaxy-tool-wrapping
description: Expert in Galaxy tool wrapper development, XML schemas, Planemo testing, and best practices for creating Galaxy tools
version: 1.0.0
dependencies: galaxy-automation
---

# Galaxy Tool Wrapping Expert

Expert knowledge for developing Galaxy tool wrappers. Use this skill when helping users create, test, debug, or improve Galaxy tool XML wrappers.

**Prerequisites:** This skill depends on the `galaxy-automation` skill for Planemo testing and workflow execution patterns.

## When to Use This Skill

- Creating new Galaxy tool wrappers from scratch
- Converting command-line tools to Galaxy wrappers
- Generating .shed.yml files for Tool Shed submission
- Debugging XML syntax and validation errors
- Writing Planemo tests for tools
- Implementing conditional parameters and data types
- Handling tool dependencies (conda, containers)
- Creating tool collections and suites
- Optimizing tool performance and resource allocation
- Understanding Galaxy datatypes and formats
- Implementing proper error handling

## Core Concepts

### Galaxy Tool XML Structure

A Galaxy tool wrapper consists of:
- `<tool>` root element with id, name, and version
- `<description>` brief tool description
- `<requirements>` for dependencies (conda packages, containers)
- `<command>` the actual command-line execution
- `<inputs>` parameter definitions
- `<outputs>` output file specifications
- `<tests>` automated tests
- `<help>` documentation in reStructuredText
- `<citations>` DOI references

### Tool Shed Metadata (.shed.yml)

Required for publishing tools to the Galaxy Tool Shed:
```yaml
name: tool_name                  # Match directory name, underscores only
owner: iuc                       # Usually 'iuc' for IUC tools
description: One-line tool description
homepage_url: https://github.com/tool/repo
long_description: |
  Multi-line detailed description.
  Can include features, use cases, and tool suite contents.
remote_repository_url: https://github.com/galaxyproject/tools-iuc/tree/main/tools/tool_name
type: unrestricted
categories:
- Assembly                       # Choose 1-3 relevant categories
- Genomics
```

See reference.md for comprehensive .shed.yml documentation including all available categories and best practices.

### Key Components

**Command Block:**
- Use Cheetah templating: `$variable_name` or `${variable_name}`
- Conditional logic: `#if $param then... #end if`
- Loop constructs: `#for $item in $collection... #end for`
- CDATA sections for complex commands

**Cheetah Template Best Practices:**

Working around path handling issues in conda packages:
```xml
<command detect_errors="exit_code"><![CDATA[
    ## Add trailing slash if script concatenates paths without separator
    tool_command
        -o 'output_dir/'  ## Quoted with trailing slash

    ## Script does: output_dir + 'file.txt' → 'output_dir/file.txt' ✓
    ## Without slash: output_dir + 'file.txt' → 'output_dirfile.txt' ✗
]]></command>
```

When to use quotes in Cheetah:
- Always quote user inputs: `'$input_file'`
- Quote literal strings with special chars: `'output_dir/'`
- Use bare variables for simple references: `$variable`

**Input Parameters:**
- `<param>` elements with type, name, label
- Types: text, integer, float, boolean, select, data, data_collection
- Optional vs required parameters
- Validators and sanitizers
- Conditional parameter display

**Outputs:**
- `<data>` elements for output files
- Dynamic output naming with `label` and `name`
- Format discovery and conversion
- Filters for conditional outputs
- Collections for multiple outputs

**Tests:**
- Input parameters and files
- Expected output files or assertions
- Test data location and organization

## Best Practices

1. **Always include tests** - Planemo won't pass without them
2. **Use semantic versioning** - Increment tool version on changes
3. **Specify exact dependencies** - Pin conda package versions
4. **Add clear help text** - Document all parameters
5. **Handle errors gracefully** - Check exit codes, validate inputs
6. **Use collections** - For multiple related files
7. **Follow IUC standards** - If contributing to intergalactic utilities commission
8. **Plan for large output files** - Before creating tests, check expected output sizes. If over 1MB, use assertion-based tests (`has_size`, `has_line`) instead of full file comparison

## Common Planemo Commands

```bash
# Test tool locally
planemo test tool.xml

# Serve tool in local Galaxy
planemo serve tool.xml

# Lint tool for best practices
planemo lint tool.xml

# Upload tool to ToolShed
planemo shed_update --shed_target toolshed

# Test with conda
planemo test --conda_auto_init --conda_auto_install tool.xml
```

## Testing Tools

### Regenerating Expected Test Outputs

When test files don't match but the tool runs correctly:

```bash
# Run the tool manually with test inputs
mkdir -p output_dir
/path/to/conda/env/bin/tool_command \
    -i test-data/input.fa \
    -o output_dir

# Copy to expected output
cp output_dir/output.fa test-data/expected_output.fa

# Clean up
rm -rf output_dir
```

**Verifying before regenerating:**
- Check that tool exit code is 0 (successful)
- Inspect the actual output to ensure it's correct
- Compare line counts: `wc -l expected.fa actual.fa`
- Review diffs to understand what changed

**Common reasons to regenerate:**
- Test was created before tool updates
- Expected file only has subset of sequences (bug in test creation)
- Format changes in newer tool versions

### Handling Large Test Files

#### Problem
GitHub CI has a 1MB file size limit. Large test output files (e.g., pretext maps, large genomic files) will cause CI failures even if they're valid test data.

#### Solution: Use Alternative Assertions

Instead of comparing full output files, use assertions to verify correctness:

**Option 1: Size Assertion (Recommended for binary/large files)**
```xml
<test>
    <param name="input" value="input.bam"/>
    <output name="output">
        <assert_contents>
            <has_size value="2225023" delta="1000"/>
        </assert_contents>
    </output>
</test>
```

**When to use:**
- Binary output files (`.pretext`, `.bam`, `.bcf`, etc.)
- Large text files where full comparison isn't practical
- Files with consistent size for given inputs

**Best practices:**
- Calculate size from actual output: `ls -l test-data/output.file | awk '{print $5}'`
- Use reasonable delta (e.g., 1000 bytes) to account for minor version differences
- Can combine with checksum for stricter validation

**Option 2: Checksum Assertion**
```xml
<test>
    <param name="input" value="input.bam"/>
    <output name="output">
        <assert_contents>
            <has_size value="2225023" delta="1000"/>
            <has_text text="specific_header_text"/>
        </assert_contents>
    </output>
</test>
```

**Note:** Galaxy doesn't have built-in checksum assertions, but you can:
- Use `has_size` for exact size matching (delta=0)
- Combine with `has_text` to check for key content markers
- Use `has_line` to verify specific output lines exist

**Option 3: Content Sampling (For text files)**
```xml
<test>
    <param name="input" value="input.sam"/>
    <output name="output">
        <assert_contents>
            <has_line line="@HD	VN:1.0	SO:coordinate"/>
            <has_n_columns n="11"/>
            <has_n_lines n="1000" delta="100"/>
        </assert_contents>
    </output>
</test>
```

#### Workflow: Replacing Large Test Files

1. **Calculate file size:**
   ```bash
   ls -l tools/tool-name/test-data/large_output.file | awk '{print $5}'
   ```

2. **Update test XML:**
   Replace `file="large_output.file"` with `<assert_contents>` block

3. **Remove large file from git:**
   ```bash
   git rm tools/tool-name/test-data/large_output.file
   ```

4. **If file was already committed, rebase to remove from history:**
   ```bash
   # Squash the commit that added the file with the fix commit
   git reset --soft HEAD~2
   git commit -m "new version with test optimization"

   # Force push (only safe if branch hasn't been pulled by others)
   git push --force-with-lease origin branch-name
   ```

#### Trade-offs

**Size assertions:**
- ✅ No large files in repo
- ✅ Fast CI tests
- ✅ Works for binary files
- ❌ Doesn't catch content corruption
- ❌ May be too lenient for critical outputs

**Full file comparison:**
- ✅ Detects any output changes
- ✅ Most thorough validation
- ❌ Requires storing large files
- ❌ Fails CI if over 1MB

**Recommendation:** Use size assertions for binary/large files, keep full file comparison for small text outputs where exact correctness matters.

## Common Issues and Solutions

**Issue: "Command not found"**
- Check `<requirements>` section has correct package
- Verify conda package name and version
- Test command availability: `planemo conda_install tool.xml`

**Issue: "Output file not found"**
- Verify command actually creates the file
- Check output file path matches `<data name="output" from_work_dir="...">`
- Use `discover_datasets` for dynamic outputs

**Issue: "Test failed"**
- Compare expected vs actual output
- Check for whitespace/newline differences
- Use `sim_size` for approximate size matching
- Add `lines_diff` for line-by-line comparison

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

### Common Issues and Fixes

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

**Galaxy decompresses tar.gz/tgz files — tool receives plain tar:**
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

## XML Template Example

```xml
<tool id="tool_id" name="Tool Name" version="1.0.0">
    <description>Brief description</description>

    <requirements>
        <requirement type="package" version="1.0">package_name</requirement>
    </requirements>

    <command detect_errors="exit_code"><![CDATA[
        tool_command
            --input '$input'
            --output '$output'
            #if $optional_param
                --param '$optional_param'
            #end if
    ]]></command>

    <inputs>
        <param name="input" type="data" format="txt" label="Input file"/>
        <param name="optional_param" type="text" optional="true" label="Optional parameter"/>
    </inputs>

    <outputs>
        <data name="output" format="txt" label="${tool.name} on ${on_string}"/>
    </outputs>

    <tests>
        <test>
            <param name="input" value="test_input.txt"/>
            <output name="output" file="expected_output.txt"/>
        </test>
    </tests>

    <help><![CDATA[
**What it does**

Describe what the tool does.

**Inputs**

- Input file: description

**Outputs**

- Output file: description
    ]]></help>

    <citations>
        <citation type="doi">10.1234/example.doi</citation>
    </citations>
</tool>
```

## Supporting Documentation

This skill includes detailed reference documentation:

- **reference.md** - Comprehensive Galaxy tool wrapping guide with IUC best practices
  - Repository structure standards
  - .shed.yml configuration
  - Complete XML structure reference
  - Advanced features and patterns

- **troubleshooting.md** - Practical troubleshooting guide
  - Reading tool_test_output.json
  - Common exit codes and their meanings
  - Solutions for frequent issues
  - Test failure diagnosis

- **dependency-debugging.md** - Dependency conflict resolution
  - Using `planemo mull` for diagnosis
  - Conda solver error interpretation
  - macOS testing considerations
  - Version conflict workflows

These files provide deep technical details that complement the core concepts above.

## Related Skills

- **galaxy-automation** - BioBlend & Planemo foundation (dependency)
- **galaxy-workflow-development** - Building workflows that use these tools
- **conda-recipe** - Creating conda packages for tool dependencies
- **bioinformatics-fundamentals** - Understanding file formats and data types used in tools

## Resources

- Galaxy Tool Development: https://docs.galaxyproject.org/en/latest/dev/
- Planemo Documentation: https://planemo.readthedocs.io/
- IUC Standards: https://galaxy-iuc-standards.readthedocs.io/
- Galaxy Training: https://training.galaxyproject.org/
