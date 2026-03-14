# Galaxy Tool Testing Guide

Detailed guidance on testing Galaxy tool wrappers, including regenerating expected outputs, handling large test files, and assertion-based testing strategies.

## Regenerating Expected Test Outputs

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

## Handling Large Test Files

### Problem
GitHub CI has a 1MB file size limit. Large test output files (e.g., pretext maps, large genomic files) will cause CI failures even if they're valid test data.

### Solution: Use Alternative Assertions

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

### Workflow: Replacing Large Test Files

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

### Trade-offs

**Size assertions:**
- No large files in repo
- Fast CI tests
- Works for binary files
- Doesn't catch content corruption
- May be too lenient for critical outputs

**Full file comparison:**
- Detects any output changes
- Most thorough validation
- Requires storing large files
- Fails CI if over 1MB

**Recommendation:** Use size assertions for binary/large files, keep full file comparison for small text outputs where exact correctness matters.
