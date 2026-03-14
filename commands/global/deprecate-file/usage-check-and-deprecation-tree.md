# Usage Check and Deprecation Tree

Code for checking whether dependencies are still used by active files, and building the deprecation tree.

## Usage Check (Python)

```python
def check_if_file_is_used(file_path, exclude_file=None):
    """
    Check if file_path is used by any active files in the project.

    Args:
        file_path: Path to check
        exclude_file: File to exclude from check (the one being deprecated)

    Returns:
        List of files that use this file
    """
    used_by = []
    project_root = Path.cwd()
    file_name = Path(file_path).name

    for search_file in list(project_root.rglob('*.ipynb')) + list(project_root.rglob('*.py')):
        # Skip deprecated files
        if 'deprecated' in str(search_file):
            continue

        # Skip the file being deprecated
        if exclude_file and search_file.resolve() == Path(exclude_file).resolve():
            continue

        try:
            with open(search_file, 'r') as f:
                content = f.read()

            if file_name in content or str(file_path) in content:
                # More precise check - look for actual usage patterns
                if (re.search(rf'[\'"].*{re.escape(file_name)}[\'"]', content) or
                    re.search(rf'[\'"].*{re.escape(str(file_path))}[\'"]', content)):
                    used_by.append(str(search_file.resolve()))
        except:
            pass

    return used_by


# CLI entry point
if __name__ == '__main__':
    import sys
    file_to_check = sys.argv[1]
    exclude = sys.argv[2] if len(sys.argv) > 2 else None

    users = check_if_file_is_used(file_to_check, exclude)
    if users:
        print("USED_BY:")
        for user in users:
            print(user)
    else:
        print("NOT_USED")
```

## Build Deprecation Tree (Bash)

```bash
declare -A DEP_USAGE  # Maps dependency -> files that use it
declare -a TO_DEPRECATE  # List of files to deprecate

TO_DEPRECATE+=("$FILE_PATH")

if [ -n "$DEPENDENCIES" ]; then
    echo "Checking which dependencies are still needed..."
    echo ""

    echo "$DEPENDENCIES" | while read dep; do
        if [ -z "$dep" ]; then continue; fi

        # Check if dependency is used by other files
        USED_BY=$(python3 << CHECK_USAGE
import sys
exec(open('.deprecate_file_detector.py').read())
users = check_if_file_is_used('$dep', '$FILE_PATH')
if users:
    print('USED_BY:')
    for user in users:
        print(user)
else:
    print('NOT_USED')
CHECK_USAGE
        )

        if echo "$USED_BY" | grep -q "NOT_USED"; then
            echo "  $dep - not used elsewhere (can deprecate)"
            TO_DEPRECATE+=("$dep")
        else
            echo "  $dep - still used by:"
            echo "$USED_BY" | grep -v "USED_BY:" | while read user; do
                echo "      - $user"
            done
            DEP_USAGE["$dep"]="$USED_BY"
        fi
    done
    echo ""
fi
```

## Confirm Deprecation Plan (Bash)

```bash
echo "Deprecation Plan"
echo ""
echo "Primary file to deprecate:"
echo "  $FILE_PATH"
if [ -n "$REASON" ]; then
    echo "  Reason: $REASON"
fi
echo ""

if [ ${#TO_DEPRECATE[@]} -gt 1 ]; then
    echo "Dependencies that will also be deprecated:"
    for ((i=1; i<${#TO_DEPRECATE[@]}; i++)); do
        echo "  ${TO_DEPRECATE[$i]}"
    done
    echo ""
fi

if [ ${#DEP_USAGE[@]} -gt 0 ]; then
    echo "Dependencies that will NOT be deprecated (still in use):"
    for dep in "${!DEP_USAGE[@]}"; do
        echo "  $dep"
    done
    echo ""
fi

echo "Files will be moved to:"
echo "  $DEPRECATED_DIR/<original-path>"

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN - No files will be moved"
    exit 0
fi

# Ask for confirmation if not in recursive auto mode
if [ "$RECURSIVE_MODE" != "auto" ] && [ ${#TO_DEPRECATE[@]} -gt 1 ]; then
    echo ""
    read -p "Deprecate ${#TO_DEPRECATE[@]} files? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "Deprecation cancelled."
        exit 0
    fi
fi
```
