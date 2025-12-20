# SKILL-NAME Reference Documentation

Comprehensive technical reference for [skill name]. This file contains detailed information that complements the main SKILL.md file.

---

## Table of Contents

1. [Complete API Reference](#complete-api-reference)
2. [All Configuration Options](#all-configuration-options)
3. [Advanced Usage Patterns](#advanced-usage-patterns)
4. [Edge Cases and Limitations](#edge-cases-and-limitations)
5. [Platform-Specific Details](#platform-specific-details)
6. [Performance Considerations](#performance-considerations)

---

## Complete API Reference

### Function/Command 1

**Syntax:**
```bash
command [options] <arguments>
```

**Parameters:**
- `param1` - Description, type, default value
- `param2` - Description, type, default value
- `param3` - Description, type, default value

**Options:**
- `--option1` - Detailed description
- `--option2` - Detailed description
- `--flag` - Detailed description

**Returns:**
- Success: Description of return value
- Failure: Error codes and meanings

**Example:**
```bash
# Detailed example with explanation
command --option1 value --flag argument
```

### Function/Command 2

[Same structure as above]

---

## All Configuration Options

### Configuration File Format

```yaml
# Complete configuration template
section1:
  option1: value  # Description
  option2: value  # Description

section2:
  option3: value  # Description
  option4: value  # Description
```

### Configuration Options Reference

**section1.option1**
- Type: string/integer/boolean
- Default: default_value
- Description: Detailed explanation
- Valid values: List or range
- Example: `option1: example_value`

**section1.option2**
[Same structure]

---

## Advanced Usage Patterns

### Pattern 1: Advanced Workflow

**Use case:** When you need to...

**Implementation:**
```bash
# Step-by-step advanced workflow
step1 --complex-options
step2 --advanced-flag
step3 --optimization
```

**Explanation:**
- Step 1 does X because...
- Step 2 enables Y which...
- Step 3 optimizes Z by...

### Pattern 2: Integration with Other Tools

**Combining with Tool X:**
```bash
# Integration example
tool-x | command --process | tool-y
```

### Pattern 3: Automation and Scripting

**Automated workflow:**
```bash
#!/bin/bash
# Script example with error handling
set -e

# Setup
setup_command

# Main processing
for item in items; do
    process_command "$item"
done

# Cleanup
cleanup_command
```

---

## Edge Cases and Limitations

### Edge Case 1: Large Files

**Issue:** Processing files larger than X GB

**Limitation:** Memory constraints on systems with < Y GB RAM

**Workaround:**
```bash
# Chunked processing approach
split_command --chunk-size 1G input.file
for chunk in chunks/*; do
    process_command "$chunk"
done
merge_command chunks/* > output.file
```

### Edge Case 2: Special Characters

**Issue:** Handling filenames with spaces or special characters

**Solution:**
```bash
# Proper quoting and escaping
command --input "file with spaces.txt"
```

### Known Limitations

1. **Limitation 1**
   - Description of limitation
   - Affected versions: X.Y.Z
   - Workaround if available

2. **Limitation 2**
   - Description of limitation
   - Why it exists
   - Planned fix (if any)

---

## Platform-Specific Details

### Linux

**Specific considerations:**
- Consideration 1
- Consideration 2

**Linux-specific options:**
```bash
# Linux-only flags
command --linux-specific-flag
```

### macOS

**Specific considerations:**
- macOS differences from Linux
- Homebrew installation notes
- Path differences

**macOS-specific workarounds:**
```bash
# macOS-specific approach
command --macos-flag
```

### Windows

**Specific considerations:**
- Windows path handling
- PowerShell vs CMD differences

**Windows-specific syntax:**
```powershell
# PowerShell syntax
command -WindowsStyle
```

---

## Performance Considerations

### Performance Tuning

**Memory usage:**
- Default: X MB
- Tuning: Adjust `--memory-limit` based on file size
- Formula: `file_size * 1.5` as minimum

**CPU usage:**
- Single-threaded by default
- Enable parallelization: `--threads N`
- Optimal thread count: `num_cores - 1`

**Disk I/O:**
- Temporary files location: Configurable via `--temp-dir`
- SSD recommended for files > X GB
- NFS performance considerations

### Benchmarks

**Typical performance:**
| File Size | Processing Time | Memory Usage |
|-----------|----------------|--------------|
| 100 MB    | 2 seconds      | 150 MB       |
| 1 GB      | 20 seconds     | 1.5 GB       |
| 10 GB     | 3 minutes      | 15 GB        |

**Optimization tips:**
1. Use `--fast-mode` for approximate results
2. Enable caching with `--cache-dir`
3. Disable verbose output for batch processing

---

## Complete Examples

### Example 1: Production Workflow

**Scenario:** Processing production data with error handling and logging

```bash
#!/bin/bash
# Production-ready script

LOG_FILE="process_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="errors_$(date +%Y%m%d_%H%M%S).log"

# Function with error handling
process_data() {
    local input=$1
    local output=$2

    echo "[$(date)] Processing $input" >> "$LOG_FILE"

    if command --input "$input" --output "$output" 2>> "$ERROR_LOG"; then
        echo "[$(date)] Success: $input" >> "$LOG_FILE"
        return 0
    else
        echo "[$(date)] Failed: $input" >> "$LOG_FILE"
        return 1
    fi
}

# Main processing loop
success_count=0
failure_count=0

for file in input_data/*; do
    output_file="output_data/$(basename "$file")"

    if process_data "$file" "$output_file"; then
        ((success_count++))
    else
        ((failure_count++))
    fi
done

# Summary
echo "Processing complete: $success_count succeeded, $failure_count failed"
```

### Example 2: Complex Configuration

**Scenario:** Complete configuration for advanced use case

```yaml
# Complete configuration example
project:
  name: "Advanced Project"
  version: "2.0"

input:
  sources:
    - path: "/data/source1"
      format: "csv"
      options:
        delimiter: ","
        header: true
    - path: "/data/source2"
      format: "json"

processing:
  steps:
    - name: "validation"
      enabled: true
      options:
        strict: true

    - name: "transformation"
      enabled: true
      script: "custom_transform.py"

    - name: "aggregation"
      enabled: true
      groupby: ["date", "category"]

output:
  destination: "/data/output"
  format: "parquet"
  compression: "snappy"
  partitioning:
    - "year"
    - "month"

performance:
  threads: 8
  memory_limit: "16GB"
  cache_enabled: true
  cache_location: "/tmp/cache"
```

---

## Version History

### Version 2.0
- Added feature X
- Improved performance of Y
- Fixed issue with Z

### Version 1.5
- Introduced advanced options
- Deprecated old syntax

### Version 1.0
- Initial release
