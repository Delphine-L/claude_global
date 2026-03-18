#!/bin/bash
# Fallback: update PROGRESS.md "Last Session Save" section on emergency exit/clear.
# Runs as a SessionEnd/PreCompact command hook.
# Skips if PROGRESS.md was already updated recently (by /safe-exit or /safe-clear).
# ONLY writes to ## Last Session Save — preserves File Changelogs untouched.

PROGRESS_FILE="PROGRESS.md"

# If PROGRESS.md was modified in the last 60 seconds, a graceful command already ran
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

# --- Gather context ---
gather_git_context() {
    BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
    COMMITS=$(git log --oneline -5 2>/dev/null | sed 's/^/  - /')
    CHANGED_FILES=$(git status --porcelain 2>/dev/null | head -20)
    DIFF_STAT=$(git diff --stat 2>/dev/null | tail -5)
    STAGED_STAT=$(git diff --cached --stat 2>/dev/null | tail -5)
}

gather_nongit_context() {
    DIR_NAME=$(basename "$PWD")
    RECENT=$(find . -maxdepth 3 -type f -mmin -120 \
        ! -path './.git/*' ! -path './.claude/*' ! -path './node_modules/*' \
        ! -name '.*' 2>/dev/null | head -15 | sed 's/^/  - /')
}

# --- Build Last Session Save content ---
build_session_save() {
    local content=""

    if git rev-parse --git-dir > /dev/null 2>&1; then
        gather_git_context

        # List changed files with their status
        local changed_list=""
        if [ -n "$CHANGED_FILES" ]; then
            changed_list=$(echo "$CHANGED_FILES" | while read -r line; do
                local status="${line:0:2}"
                local file="${line:3}"
                case "$status" in
                    "M "*|" M") echo "  - \`$file\` — modified" ;;
                    "A "*|" A") echo "  - \`$file\` — added" ;;
                    "D "*|" D") echo "  - \`$file\` — deleted" ;;
                    "R "*|" R") echo "  - \`$file\` — renamed" ;;
                    "??")       echo "  - \`$file\` — new (untracked)" ;;
                    *)          echo "  - \`$file\` — changed ($status)" ;;
                esac
            done)
        fi

        content="**Session ended**: $TIMESTAMP
**Branch**: $BRANCH
**Recent commits**:
$COMMITS
**Changed files**:
${changed_list:-  - (no uncommitted changes)}"

    else
        gather_nongit_context
        content="**Session ended**: $TIMESTAMP
**Directory**: $DIR_NAME
**Recently modified files**:
${RECENT:-  - (no recently modified files)}"
    fi

    echo "$content"
}

# --- Update PROGRESS.md: replace only Last Session Save section ---
update_progress() {
    local save_content
    save_content=$(build_session_save)

    if [ ! -f "$PROGRESS_FILE" ]; then
        # Create new PROGRESS.md with structure
        cat > "$PROGRESS_FILE" <<EOF
# Progress

## File Changelogs

<!-- Per-file history of modifications. Managed by /safe-exit and /safe-clear. -->

## Last Session Save
<!-- Emergency fallback from CLI on crash/forced clear.
     On resume: consolidate entries into File Changelogs above, then clear. -->

$save_content

> *Auto-saved by progress-update-fallback.sh. Run /resume-interrupted for full recovery.*
EOF
        return
    fi

    # File exists — replace Last Session Save section only
    # Strategy: find "## Last Session Save", keep everything before it,
    # write new section content

    local temp_file
    temp_file=$(mktemp)

    local in_save_section=false
    local found_save_section=false

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" == "## Last Session Save"* ]]; then
            in_save_section=true
            found_save_section=true
            # Write the section header
            echo "$line" >> "$temp_file"
            echo '<!-- Emergency fallback from CLI on crash/forced clear.' >> "$temp_file"
            echo '     On resume: consolidate entries into File Changelogs above, then clear. -->' >> "$temp_file"
            echo "" >> "$temp_file"
            echo "$save_content" >> "$temp_file"
            echo "" >> "$temp_file"
            echo "> *Auto-saved by progress-update-fallback.sh. Run /resume-interrupted for full recovery.*" >> "$temp_file"
            continue
        fi

        if [ "$in_save_section" = true ]; then
            # Skip old content until we hit another ## heading or end of file
            if [[ "$line" == "## "* ]] && [[ "$line" != "## Last Session Save"* ]]; then
                in_save_section=false
                echo "$line" >> "$temp_file"
            fi
            # else: skip this line (old Last Session Save content)
            continue
        fi

        echo "$line" >> "$temp_file"
    done < "$PROGRESS_FILE"

    # If no Last Session Save section existed, append one
    if [ "$found_save_section" = false ]; then
        echo "" >> "$temp_file"
        echo "## Last Session Save" >> "$temp_file"
        echo '<!-- Emergency fallback from CLI on crash/forced clear.' >> "$temp_file"
        echo '     On resume: consolidate entries into File Changelogs above, then clear. -->' >> "$temp_file"
        echo "" >> "$temp_file"
        echo "$save_content" >> "$temp_file"
        echo "" >> "$temp_file"
        echo "> *Auto-saved by progress-update-fallback.sh. Run /resume-interrupted for full recovery.*" >> "$temp_file"
    fi

    mv "$temp_file" "$PROGRESS_FILE"
}

# --- Main ---
update_progress

# --- Update MANIFEST.md "Notes for Resuming Work" if it exists ---
update_manifest_notes() {
    local manifest="$1"
    if [ ! -f "$manifest" ]; then
        return
    fi
    if grep -q "## Notes for Resuming Work" "$manifest" 2>/dev/null; then
        LAST_LINE=$(tail -1 "$manifest")
        if [[ "$LAST_LINE" != *"Session ended"* ]] || [[ "$LAST_LINE" != *"$TIMESTAMP"* ]]; then
            echo "" >> "$manifest"
            echo "- Session ended $TIMESTAMP — see PROGRESS.md for details" >> "$manifest"
        fi
    fi
}

if [ -f "MANIFEST.md" ]; then
    update_manifest_notes "MANIFEST.md"
fi
for d in */; do
    if [ -f "${d}MANIFEST.md" ]; then
        update_manifest_notes "${d}MANIFEST.md"
    fi
done
