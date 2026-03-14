---
name: deprecate-file
description: Deprecate files by moving them to deprecated/ folder, recursively handling dependencies, and updating MANIFESTs
disable-model-invocation: true
---

# Deprecate File Command

Move files to the `deprecated/` subfolder at project root, recursively deprecate unused dependencies, and update MANIFEST files to reflect changes.

## Overview

When you deprecate a file, this command:
1. **Moves the file** to `deprecated/` preserving directory structure
2. **Detects dependencies** - finds files that were used to create this file
3. **Recursively deprecates** dependencies that are no longer used by active files
4. **Updates MANIFESTs** to mark files as deprecated or remove entries
5. **Creates deprecation log** documenting what was moved and why

## Usage

```bash
/deprecate-file <file-path> [--reason "explanation"] [--recursive] [--dry-run]
```

**Arguments:**
- `<file-path>` - Path to file to deprecate (relative to project root)
- `--reason "text"` - Optional reason for deprecation (recommended)
- `--recursive` - Automatically deprecate unused dependencies (default: prompt)
- `--dry-run` - Show what would be deprecated without moving files
- `--keep-in-manifest` - Keep entry in MANIFEST marked as deprecated (don't remove)

**Examples:**
```bash
# Deprecate a single file with reason
/deprecate-file figures/old_plot.png --reason "Replaced by new_plot.png with better resolution"

# Deprecate and auto-handle dependencies
/deprecate-file notebooks/exploratory_v1.ipynb --recursive --reason "Superseded by final_analysis.ipynb"

# Dry run to see what would happen
/deprecate-file scripts/old_analysis.py --dry-run

# Deprecate but keep in MANIFEST (for reference)
/deprecate-file data/preliminary_results.csv --keep-in-manifest --reason "Preliminary data, keeping for reference"
```

---

## Step-by-Step Instructions

### Step 1: Validate Input and Setup

**Check file exists:**
```bash
FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
    echo "Error: No file path provided"
    echo "Usage: /deprecate-file <file-path> [--reason \"explanation\"]"
    exit 1
fi

if [ ! -e "$FILE_PATH" ]; then
    echo "Error: File not found: $FILE_PATH"
    exit 1
fi

# Get absolute path
FILE_PATH=$(realpath "$FILE_PATH")
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

**Parse arguments:**
```bash
REASON=""
RECURSIVE_MODE="prompt"  # prompt, auto, none
DRY_RUN=false
KEEP_IN_MANIFEST=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --reason)
            REASON="$2"
            shift 2
            ;;
        --recursive)
            RECURSIVE_MODE="auto"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --keep-in-manifest)
            KEEP_IN_MANIFEST=true
            shift
            ;;
        *)
            if [ -z "$FILE_PATH" ]; then
                FILE_PATH="$1"
            fi
            shift
            ;;
    esac
done
```

**Ensure deprecated/ directory exists:**
```bash
DEPRECATED_DIR="$PROJECT_ROOT/deprecated"
if [ ! -d "$DEPRECATED_DIR" ]; then
    mkdir -p "$DEPRECATED_DIR"
    # Create README and DEPRECATION_LOG.md - see deprecate-file/setup-templates.md
fi
```

> **Supporting detail:** See [setup-templates.md](deprecate-file/setup-templates.md) for the full README and DEPRECATION_LOG.md templates created in the deprecated/ directory.

---

### Step 2: Detect File Dependencies

Analyze the file type and extract dependencies (files used to create the target file).

> **Supporting detail:** See [dependency-detection.md](deprecate-file/dependency-detection.md) for the full Python dependency detection code covering notebooks, Python scripts, figures, and data files.

**Execute dependency detection:**
```bash
echo "Analyzing dependencies for: $FILE_PATH"

DEPENDENCIES=$(python3 << 'DETECT_DEPS'
import sys
sys.path.insert(0, '.')
exec(open('.deprecate_file_detector.py').read())
print('\n'.join(detect_dependencies('$FILE_PATH')))
DETECT_DEPS
)

if [ -n "$DEPENDENCIES" ]; then
    echo "Found dependencies:"
    echo "$DEPENDENCIES" | while read dep; do
        echo "  - $dep"
    done
else
    echo "No dependencies detected"
fi
```

---

### Step 3: Check Dependencies and Build Deprecation Tree

For each dependency, check if it is used by other active files. Build the list of files safe to deprecate.

> **Supporting detail:** See [usage-check-and-deprecation-tree.md](deprecate-file/usage-check-and-deprecation-tree.md) for the full Python usage-checking code and bash deprecation tree builder.

---

### Step 4: Confirm Deprecation Plan

Show the deprecation plan and ask for confirmation (unless `--recursive` auto mode).

```bash
echo "Deprecation Plan"
echo "Primary file to deprecate: $FILE_PATH"
[ -n "$REASON" ] && echo "  Reason: $REASON"

# Show dependencies to deprecate and those kept
# If not auto mode and multiple files, prompt for confirmation

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN - No files will be moved"
    exit 0
fi
```

---

### Step 5: Move Files to deprecated/

**Move each file preserving directory structure:**
```bash
for file in "${TO_DEPRECATE[@]}"; do
    REL_PATH=$(realpath --relative-to="$PROJECT_ROOT" "$file")
    TARGET_PATH="$DEPRECATED_DIR/$REL_PATH"
    TARGET_DIR=$(dirname "$TARGET_PATH")
    mkdir -p "$TARGET_DIR"

    if mv "$file" "$TARGET_PATH"; then
        echo "  Moved: $REL_PATH -> deprecated/$REL_PATH"
    else
        echo "  Failed to move: $REL_PATH"
    fi
done
```

---

### Step 6: Update MANIFESTs and Create Deprecation Log

Find and update affected MANIFEST files (remove or mark entries), then add an entry to `DEPRECATION_LOG.md`.

> **Supporting detail:** See [manifest-and-logging.md](deprecate-file/manifest-and-logging.md) for the full MANIFEST update logic and deprecation log entry format.

---

### Step 7: Show Summary

```bash
echo "Deprecation Complete"
echo "Files deprecated: ${#TO_DEPRECATE[@]}"
echo "Location: deprecated/"
echo ""
echo "Next steps:"
echo "  - Review deprecated/DEPRECATION_LOG.md for details"
echo "  - MANIFEST files have been updated automatically"
echo "  - Commit changes: git add . && git commit -m \"Deprecate: $FILE_PATH\""
echo ""
echo "To recover a file:"
echo "  mv deprecated/<path> <original-path>"
```

---

## Safety Features and Validation

> **Supporting detail:** See [safety-and-examples.md](deprecate-file/safety-and-examples.md) for validation checks (already-deprecated, uncommitted changes, target exists), worked examples, and best practices.

Key safety rules:
1. **No overwrite** - If file already exists in deprecated/, ask to rename
2. **Git status check** - Warn if file has uncommitted changes
3. **Confirm before recursive** - Always confirm when deprecating multiple files
4. **Dry run mode** - Preview what would happen

---

## Related Commands

- `/update-manifest` - Update MANIFESTs after deprecation
- `/cleanup-project` - Clean up project at end (uses deprecation)
- `/safe-exit` - Prompts to deprecate unused files before exit

---

## Implementation Notes

**For Claude:**

When executing this command:

1. **Create Python helper** `.deprecate_file_detector.py` with dependency detection functions (see [dependency-detection.md](deprecate-file/dependency-detection.md))
2. **Run dependency analysis** for the target file
3. **Check usage** of each dependency in active files (see [usage-check-and-deprecation-tree.md](deprecate-file/usage-check-and-deprecation-tree.md))
4. **Build deprecation tree** of files to move
5. **Confirm with user** before moving files (unless --recursive flag)
6. **Move files** preserving directory structure
7. **Update MANIFESTs** removing or marking entries (see [manifest-and-logging.md](deprecate-file/manifest-and-logging.md))
8. **Log deprecation** in DEPRECATION_LOG.md
9. **Clean up** temporary Python helper file

**Token Efficiency:**
- Use bash commands for file operations
- Only read files necessary for dependency detection
- Cache dependency results to avoid re-analysis

**Error Handling:**
- Check file existence before starting
- Validate git status if in git repo
- Handle existing files in deprecated/
- Report partial failures if batch deprecation
