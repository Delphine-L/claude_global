#!/bin/bash
# Re-inject project context after compaction or clear
# stdout goes into Claude's context

echo "=== Post-compaction context ==="

# Git info
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    echo "Branch: $BRANCH"
    echo "Recent commits:"
    git log --oneline -5 2>/dev/null | sed 's/^/  /'

    # Uncommitted changes summary
    CHANGED=$(git status --porcelain 2>/dev/null | wc -l | xargs)
    if [ "$CHANGED" -gt 0 ]; then
        echo "Uncommitted changes: $CHANGED files"
    fi
fi

# Active conda/venv environment
if [ -n "$CONDA_DEFAULT_ENV" ]; then
    echo "Conda env: $CONDA_DEFAULT_ENV"
elif [ -n "$VIRTUAL_ENV" ]; then
    echo "Venv: $(basename "$VIRTUAL_ENV")"
fi

# Project config (Obsidian, etc.)
if [ -f ".claude/project-config" ]; then
    echo "Project config:"
    cat .claude/project-config | sed 's/^/  /'
fi

# CLAUDE.md reminder
if [ -f "CLAUDE.md" ]; then
    echo "Note: CLAUDE.md is present in this project."
fi

# MANIFEST Active Tasks summary
if [ -f "MANIFEST.md" ]; then
    if grep -q "## Active Tasks" MANIFEST.md 2>/dev/null; then
        echo ""
        echo "=== Active Tasks (from MANIFEST.md) ==="
        # Extract task names and statuses
        grep -E "^### Task:|^\*\*Status\*\*:" MANIFEST.md 2>/dev/null | paste - - | sed 's/### Task: //; s/\*\*Status\*\*: /— /'
        echo "=== End Active Tasks ==="
        echo "Run /read-manifest to load task-specific context."
    fi
fi

# Progress — check for Last Session Save
if [ -f "PROGRESS.md" ]; then
    # Check staleness
    if [[ "$OSTYPE" == darwin* ]]; then
        MOD_TIME=$(stat -f %m "PROGRESS.md" 2>/dev/null)
    else
        MOD_TIME=$(stat -c %Y "PROGRESS.md" 2>/dev/null)
    fi
    NOW=$(date +%s)
    if [ -n "$MOD_TIME" ]; then
        DAYS_OLD=$(( (NOW - MOD_TIME) / 86400 ))
        if [ "$DAYS_OLD" -gt 7 ]; then
            echo ""
            echo "WARNING: PROGRESS.md is ${DAYS_OLD} days old. Consider running /update-manifest to refresh."
        fi
    fi

    # Check for non-empty Last Session Save
    SAVE_CONTENT=$(sed -n '/^## Last Session Save/,/^## /p' PROGRESS.md 2>/dev/null | grep -v "^## \|^<!--\|^$\|^-->" | head -20)
    if [ -n "$SAVE_CONTENT" ]; then
        echo ""
        echo "=== ACTION REQUIRED: Last Session Save found ==="
        echo "PROGRESS.md has unincorporated emergency data from a previous session."
        echo "Review the data below, incorporate key points into File Changelogs"
        echo "(and MANIFEST TODOs if applicable), then clear the Last Session Save section."
        echo "Or run /resume-interrupted for automated recovery from transcript backups."
        echo ""
        echo "$SAVE_CONTENT"
        echo "=== End Last Session Save ==="
    fi
fi

echo "=== End context ==="
