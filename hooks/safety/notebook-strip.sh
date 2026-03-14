#!/bin/bash
# Strip outputs from Jupyter notebooks after edits
# Keeps notebooks clean for git. Silently skips if nbstripout not available.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE" ] && exit 0

if [[ "$FILE" == *.ipynb ]] && [ -f "$FILE" ]; then
    if command -v nbstripout > /dev/null 2>&1; then
        nbstripout "$FILE" 2>/dev/null
    fi
fi

exit 0
