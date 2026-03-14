# MANIFEST Parsing (Step 1.5)

**This step runs ONLY if MANIFEST files exist** (`HAVE_MANIFESTS=true`)

MANIFEST files track all files in a directory with metadata. Use them to intelligently identify:
- **Main files** - Primary analysis notebooks/scripts
- **Active files** - Currently used files (not deprecated)
- **File purposes** - What each file does
- **File relationships** - Dependencies between files

```python
import re
import os
from pathlib import Path
from datetime import datetime

def parse_manifest(manifest_path):
    """
    Parse MANIFEST.md to extract file information.

    Returns:
        dict: {
            'main_files': [],      # Files marked as main/primary
            'active_files': [],    # All non-deprecated files
            'deprecated_files': [], # Files marked as deprecated
            'file_info': {}        # {filename: {purpose, size, notes}}
        }
    """
    result = {
        'main_files': [],
        'active_files': [],
        'deprecated_files': [],
        'file_info': {}
    }

    if not os.path.exists(manifest_path):
        return result

    manifest_dir = os.path.dirname(manifest_path)
    current_file = None
    current_info = {}

    with open(manifest_path, 'r') as f:
        content = f.read()

    # Extract file entries (#### `filename`)
    file_pattern = r'####\s+`([^`]+)`(?:\s+\*\*\[DEPRECATED\]\*\*)?'

    for match in re.finditer(file_pattern, content, re.MULTILINE):
        filename = match.group(1)
        is_deprecated = '[DEPRECATED]' in match.group(0)

        # Get the section after this file header
        start_pos = match.end()
        # Find next file header or section header
        next_match = re.search(r'\n###', content[start_pos:])
        if next_match:
            section = content[start_pos:start_pos + next_match.start()]
        else:
            section = content[start_pos:]

        # Extract file information from section
        info = {
            'filename': filename,
            'path': os.path.join(manifest_dir, filename),
            'deprecated': is_deprecated
        }

        # Look for purpose/description
        purpose_match = re.search(r'\*\*Purpose:\*\*\s*([^\n]+)', section)
        if purpose_match:
            info['purpose'] = purpose_match.group(1).strip()

        # Look for "Main analysis" or similar markers
        is_main = any(marker in section.lower() for marker in [
            'main analysis',
            'primary notebook',
            'final analysis',
            'main script',
            'primary analysis'
        ])

        if is_main:
            info['is_main'] = True

        # Look for size
        size_match = re.search(r'\*\*Size:\*\*\s*([^\n]+)', section)
        if size_match:
            info['size'] = size_match.group(1).strip()

        # Store file info
        result['file_info'][filename] = info

        # Categorize
        if is_deprecated:
            result['deprecated_files'].append(filename)
        else:
            result['active_files'].append(filename)
            if is_main:
                result['main_files'].append(filename)

    return result

def find_all_manifests(project_root='.'):
    """Find all MANIFEST files in project."""
    manifests = []
    for root, dirs, files in os.walk(project_root):
        # Skip deprecated directories
        if 'deprecated' in root:
            continue
        if 'MANIFEST.md' in files:
            manifests.append(os.path.join(root, 'MANIFEST.md'))
    return manifests

def aggregate_manifest_data(project_root='.'):
    """
    Aggregate data from all MANIFEST files in project.

    Returns:
        dict: Aggregated file information from all MANIFESTs
    """
    all_data = {
        'main_files': [],
        'active_files': [],
        'deprecated_files': [],
        'file_info': {}
    }

    manifests = find_all_manifests(project_root)

    if not manifests:
        return None

    print(f"Found {len(manifests)} MANIFEST file(s)")

    for manifest_path in manifests:
        print(f"  Reading: {manifest_path}")
        data = parse_manifest(manifest_path)

        # Merge data
        all_data['main_files'].extend(data['main_files'])
        all_data['active_files'].extend(data['active_files'])
        all_data['deprecated_files'].extend(data['deprecated_files'])
        all_data['file_info'].update(data['file_info'])

    return all_data

# Execute if MANIFESTs exist
if __name__ == '__main__':
    manifest_data = aggregate_manifest_data()

    if manifest_data:
        print("\nMANIFEST Analysis:")
        print(f"  Main files: {len(manifest_data['main_files'])}")
        print(f"  Active files: {len(manifest_data['active_files'])}")
        print(f"  Deprecated files: {len(manifest_data['deprecated_files'])}")

        if manifest_data['main_files']:
            print("\nMain/Primary Files Identified:")
            for filename in manifest_data['main_files']:
                info = manifest_data['file_info'].get(filename, {})
                purpose = info.get('purpose', 'No description')
                print(f"  - {filename}")
                print(f"    Purpose: {purpose}")

        # Output for bash to capture
        import json
        print("\nMANIFEST_DATA_JSON:")
        print(json.dumps(manifest_data, indent=2))
```

**Execute MANIFEST parsing:**

```bash
if [ "$HAVE_MANIFESTS" = true ]; then
    echo ""
    echo "Parsing MANIFEST files..."

    # Create temporary Python script
    cat > .share_manifest_parser.py << 'MANIFEST_PARSER'
# [Insert Python code from above]
MANIFEST_PARSER

    # Execute parser
    MANIFEST_OUTPUT=$(python3 .share_manifest_parser.py)

    # Extract JSON data
    MANIFEST_JSON=$(echo "$MANIFEST_OUTPUT" | sed -n '/MANIFEST_DATA_JSON:/,${p}' | tail -n +2)

    # Store for later use
    echo "$MANIFEST_JSON" > .manifest_data.json

    # Clean up temp script
    rm .share_manifest_parser.py

    echo "MANIFEST data parsed and cached"
fi
```
