# File Selection Workflows (Step 1.6)

## MANIFEST-Enhanced File Selection

**NEW WORKFLOW: Flexible file organization with MANIFEST intelligence**

Present two options:

```
What would you like to share?

Option 1: Specific files at root (Recommended for focused sharing)
   - You specify which files to highlight (e.g., notebooks)
   - Those files appear at the root of the sharing package
   - Everything else organized in folders
   - Example:
     shared-package/
     |- Analysis_Notebook.ipynb        <- Your file at root
     |- Results_Notebook.ipynb         <- Your file at root
     |- figures/                       <- Supporting files in folders
     |- data/
     |- scripts/
     '- README.md

Option 2: Share entire directory (Full project structure)
   - Copy everything except 'deprecated/' folder
   - Maintains original directory structure
   - Good for complete project handoff

Which would you prefer? [1/2]
```

## Option 1: Specific Files - MANIFEST-Enhanced Selection

```bash
echo ""
echo "Select files for sharing package root:"
echo ""

# If MANIFESTs exist, show intelligent suggestions
if [ "$HAVE_MANIFESTS" = true ] && [ -f ".manifest_data.json" ]; then
    echo "Suggested files based on MANIFEST analysis:"
    echo ""

    # Extract main files from MANIFEST data
    MAIN_FILES=$(python3 << 'EXTRACT_MAIN'
import json
with open('.manifest_data.json', 'r') as f:
    data = json.load(f)

if data['main_files']:
    print("Main/Primary files:")
    for i, filename in enumerate(data['main_files'], 1):
        info = data['file_info'].get(filename, {})
        purpose = info.get('purpose', 'No description')
        print(f"  [{i}] {filename}")
        print(f"      -> {purpose}")
else:
    print("No main files identified in MANIFEST")

# Also show all active files for context
if data['active_files']:
    non_main_active = [f for f in data['active_files'] if f not in data['main_files']]
    if non_main_active:
        print("\nOther active files:")
        start_num = len(data['main_files']) + 1
        for i, filename in enumerate(non_main_active, start_num):
            info = data['file_info'].get(filename, {})
            purpose = info.get('purpose', 'Supporting file')
            print(f"  [{i}] {filename}")
            if purpose != 'Supporting file':
                print(f"      -> {purpose}")

# Output selections for bash
print("\nMAIN_FILE_LIST:")
for filename in data['main_files']:
    print(filename)
EXTRACT_MAIN
    )

    echo "$MAIN_FILES"
    echo ""
    echo "Tip: Main files are good candidates for the sharing package root"
    echo ""

    # Extract just filenames for selection
    SUGGESTED_MAIN=$(echo "$MAIN_FILES" | sed -n '/MAIN_FILE_LIST:/,${p}' | tail -n +2)

else
    # No MANIFEST - show files normally
    echo "Available notebooks:"
    ls -1 *.ipynb 2>/dev/null | nl

    echo ""
    echo "Other files that could go at root:"
    ls -1 *.py *.md 2>/dev/null | nl
fi

# Ask user
echo ""
echo "Which files should go at the root of the sharing package?"
echo ""
echo "Options:"
echo "  - Enter numbers from list above (e.g., '1 2 3')"
echo "  - Enter filenames (e.g., 'Analysis.ipynb Results.ipynb')"
if [ "$HAVE_MANIFESTS" = true ]; then
    echo "  - Type 'main' to select all main files from MANIFEST"
fi
echo "  - Type 'all' to share entire directory structure (Option 2)"
echo ""
read -p "Selection: " FILE_SELECTION

# Process selection
if [ "$FILE_SELECTION" = "all" ]; then
    SHARE_ENTIRE_DIR=true
    echo "Will share entire directory structure"

elif [ "$FILE_SELECTION" = "main" ] && [ "$HAVE_MANIFESTS" = true ]; then
    # Use main files from MANIFEST
    ROOT_FILES=()
    while IFS= read -r filename; do
        if [ -n "$filename" ] && [ -f "$filename" ]; then
            ROOT_FILES+=("$filename")
        fi
    done <<< "$SUGGESTED_MAIN"

    echo "Selected ${#ROOT_FILES[@]} main files:"
    for file in "${ROOT_FILES[@]}"; do
        echo "  - $file"
    done

else
    # Parse user selection (numbers or filenames)
    ROOT_FILES=()
    # [Implementation for parsing numbers/filenames as before]
    echo "Selected files for sharing package root"
fi
```

**Collect user input:**
- Store selected files in array: `ROOT_FILES=()`
- Validate files exist
- Confirm selection with user
- **NEW**: Use MANIFEST data to suggest main files
- **NEW**: Allow quick selection of MANIFEST-identified main files

## Option 2: Entire Directory - MANIFEST-Enhanced Exclusions

```bash
# Set flag to copy entire directory
SHARE_ENTIRE_DIR=true

# Base exclude patterns
EXCLUDE_PATTERNS=("deprecated" ".git" "__pycache__" "*.pyc" ".ipynb_checkpoints")

# If MANIFEST exists, add deprecated files to exclusions
if [ "$HAVE_MANIFESTS" = true ] && [ -f ".manifest_data.json" ]; then
    echo ""
    echo "Using MANIFEST to identify deprecated files..."

    # Extract deprecated files from MANIFEST
    DEPRECATED_FILES=$(python3 << 'EXTRACT_DEPRECATED'
import json
with open('.manifest_data.json', 'r') as f:
    data = json.load(f)

if data['deprecated_files']:
    print(f"Found {len(data['deprecated_files'])} deprecated files in MANIFEST:")
    for filename in data['deprecated_files']:
        print(f"  - {filename}")
        # Add to exclusion list
        print(f"EXCLUDE:{filename}")
EXTRACT_DEPRECATED
    )

    echo "$DEPRECATED_FILES" | grep -v "^EXCLUDE:" || true

    # Parse deprecated files into exclusion array
    while IFS= read -r line; do
        if [[ "$line" == EXCLUDE:* ]]; then
            filename="${line#EXCLUDE:}"
            EXCLUDE_PATTERNS+=("$filename")
        fi
    done <<< "$DEPRECATED_FILES"

    echo "Will exclude ${#EXCLUDE_PATTERNS[@]} patterns (including MANIFEST-identified deprecated files)"
else
    echo "Will exclude standard patterns only"
fi
```
