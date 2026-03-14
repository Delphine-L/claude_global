#!/bin/bash
# Auto-format Python files after edits
# Runs ruff format on .py files, silently skips if ruff not available

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE" ] && exit 0

if [[ "$FILE" == *.py ]] && [ -f "$FILE" ]; then
    if command -v ruff > /dev/null 2>&1; then
        ruff format --quiet "$FILE" 2>/dev/null
    elif command -v uvx > /dev/null 2>&1; then
        uvx ruff format --quiet "$FILE" 2>/dev/null
    fi
fi

exit 0
