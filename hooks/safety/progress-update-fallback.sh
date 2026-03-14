#!/bin/bash
# Fallback: write a mechanical PROGRESS.md from git state / filesystem
# Runs after the prompt hook. Skips if PROGRESS.md was already updated recently.

PROGRESS_FILE="PROGRESS.md"

# If PROGRESS.md was modified in the last 60 seconds, the prompt hook already ran
if [ -f "$PROGRESS_FILE" ]; then
    if [[ "$OSTYPE" == darwin* ]]; then
        MOD_TIME=$(stat -f %m "$PROGRESS_FILE" 2>/dev/null)
    else
        MOD_TIME=$(stat -c %Y "$PROGRESS_FILE" 2>/dev/null)
    fi
    NOW=$(date +%s)
    if [ -n "$MOD_TIME" ] && [ $((NOW - MOD_TIME)) -lt 60 ]; then
        exit 0
    fi
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# --- Git repo ---
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")

    # Recent commits
    COMMITS=$(git log --oneline -5 2>/dev/null | sed 's/^/- /')

    # Uncommitted / changed files
    CHANGED=$(git status --porcelain 2>/dev/null | head -20)
    if [ -n "$CHANGED" ]; then
        IN_PROGRESS=$(echo "$CHANGED" | sed 's/^/- /')
    else
        IN_PROGRESS="- (no uncommitted changes)"
    fi

    cat > "$PROGRESS_FILE" <<EOF
# Progress

**Last updated:** $TIMESTAMP
**Branch:** $BRANCH

## Recent Work
$COMMITS

## In Progress
$IN_PROGRESS

## Next Steps
- (continue from where you left off)

> Auto-generated fallback. Use /safe-exit for a detailed AI-written summary.
EOF

# --- Non-git directory ---
else
    DIR_NAME=$(basename "$PWD")

    # Recently modified files (last 2 hours)
    RECENT=$(find . -maxdepth 3 -type f -mmin -120 \
        ! -path './.git/*' ! -path './.claude/*' ! -path './node_modules/*' \
        ! -name '.*' 2>/dev/null | head -15 | sed 's/^/- /')
    if [ -z "$RECENT" ]; then
        RECENT="- (no recently modified files)"
    fi

    # Key file types present
    CONTENTS=""
    for ext in ipynb py ga md R sh json yaml yml; do
        COUNT=$(find . -maxdepth 3 -name "*.$ext" ! -path './.git/*' 2>/dev/null | wc -l | xargs)
        if [ "$COUNT" -gt 0 ]; then
            CONTENTS="$CONTENTS\n- $COUNT .$ext files"
        fi
    done
    if [ -z "$CONTENTS" ]; then
        CONTENTS="- (no recognized project files)"
    fi

    cat > "$PROGRESS_FILE" <<EOF
# Progress

**Last updated:** $TIMESTAMP
**Directory:** $DIR_NAME

## Recent Work
$RECENT

## Project Contents
$(echo -e "$CONTENTS")

## Next Steps
- (continue from where you left off)

> Auto-generated fallback. Use /safe-exit for a detailed AI-written summary.
EOF
fi

# --- Update MANIFEST.md "Notes for Resuming Work" if it exists ---
update_manifest_notes() {
    local manifest="$1"
    if [ ! -f "$manifest" ]; then
        return
    fi
    # Check if it has a "Notes for Resuming Work" section
    if grep -q "## Notes for Resuming Work" "$manifest" 2>/dev/null; then
        # Append a timestamp note (avoid duplicating if already done)
        LAST_LINE=$(tail -1 "$manifest")
        if [[ "$LAST_LINE" != *"Session ended"* ]] || [[ "$LAST_LINE" != *"$TIMESTAMP"* ]]; then
            echo "" >> "$manifest"
            echo "- Session ended $TIMESTAMP — see PROGRESS.md for details" >> "$manifest"
        fi
    fi
}

# Check root and one level of subdirectories
if [ -f "MANIFEST.md" ]; then
    update_manifest_notes "MANIFEST.md"
fi
for d in */; do
    if [ -f "${d}MANIFEST.md" ]; then
        update_manifest_notes "${d}MANIFEST.md"
    fi
done
