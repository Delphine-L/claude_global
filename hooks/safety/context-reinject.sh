#!/bin/bash
# Re-inject project context after compaction
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

# Progress from previous context
if [ -f "PROGRESS.md" ]; then
    echo ""
    echo "=== Session progress (from PROGRESS.md) ==="
    cat PROGRESS.md
    echo "=== End progress ==="
fi

echo "=== End context ==="
