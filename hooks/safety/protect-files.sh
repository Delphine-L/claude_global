#!/bin/bash
# Block edits to protected file patterns
# Exit 2 = block with message, Exit 0 = allow

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# No file path = not a file edit, allow
[ -z "$FILE" ] && exit 0

# Get just the filename for extension checks
BASENAME=$(basename "$FILE")

# --- Protected patterns ---

# .env files (secrets/credentials)
if [[ "$BASENAME" == .env* ]] || [[ "$BASENAME" == *.env ]]; then
    echo "BLOCKED: .env files contain secrets and should not be edited by Claude." >&2
    exit 2
fi

# Raw data directories
if [[ "$FILE" == */raw/* ]] || [[ "$FILE" == */data/raw/* ]] || [[ "$FILE" == */datasets/* ]]; then
    echo "BLOCKED: Raw data files should not be modified. Work with copies instead." >&2
    exit 2
fi

# Lock files
if [[ "$BASENAME" == "package-lock.json" ]] || \
   [[ "$BASENAME" == "conda-lock.yml" ]] || \
   [[ "$BASENAME" == "poetry.lock" ]] || \
   [[ "$BASENAME" == "yarn.lock" ]] || \
   [[ "$BASENAME" == "Pipfile.lock" ]]; then
    echo "BLOCKED: Lock files should be updated by package managers, not edited directly." >&2
    exit 2
fi

# Log files
if [[ "$BASENAME" == *.log ]]; then
    echo "BLOCKED: Log files should not be edited." >&2
    exit 2
fi

exit 0
