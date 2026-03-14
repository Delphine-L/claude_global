# MANIFEST Updates and Deprecation Logging

## Update MANIFEST Files

Find and update affected MANIFESTs after moving files to deprecated/.

```bash
echo "Updating MANIFEST files..."

# Find all MANIFEST files in the project
MANIFESTS=$(find "$PROJECT_ROOT" -name "MANIFEST.md" -not -path "*/deprecated/*")

if [ -z "$MANIFESTS" ]; then
    echo "  No MANIFEST files found in project"
else
    for manifest in $MANIFESTS; do
        MANIFEST_DIR=$(dirname "$manifest")
        UPDATED=false

        # Check if any deprecated files were in this directory
        for file in "${TO_DEPRECATE[@]}"; do
            FILE_DIR=$(dirname "$file")

            # Check if file was in this MANIFEST's directory
            if [[ "$FILE_DIR" == "$MANIFEST_DIR"* ]]; then
                FILE_NAME=$(basename "$file")

                if grep -q "$FILE_NAME" "$manifest"; then
                    if [ "$KEEP_IN_MANIFEST" = true ]; then
                        # Mark as deprecated in place
                        echo "  Marking as deprecated in $(realpath --relative-to="$PROJECT_ROOT" "$manifest"): $FILE_NAME"
                        sed -i.bak "s/#### \`$FILE_NAME\`/#### \`$FILE_NAME\` **[DEPRECATED]**/" "$manifest"
                        rm "$manifest.bak"
                    else
                        # Remove from MANIFEST
                        echo "  Removing from $(realpath --relative-to="$PROJECT_ROOT" "$manifest"): $FILE_NAME"
                        sed -i.bak "/#### \`$FILE_NAME\`/,/^###/{ /^###/!d; }" "$manifest"
                        rm "$manifest.bak"
                    fi

                    UPDATED=true
                fi
            fi
        done

        if [ "$UPDATED" = true ]; then
            # Update "Last Updated" date in MANIFEST
            TODAY=$(date +%Y-%m-%d)
            sed -i.bak "s/^Last Updated: .*/Last Updated: $TODAY/" "$manifest"
            rm "$manifest.bak"
        fi
    done
fi
```

## Create Deprecation Log Entry

Add an entry to `deprecated/DEPRECATION_LOG.md`.

```bash
echo "Updating deprecation log..."

LOG_FILE="$DEPRECATED_DIR/DEPRECATION_LOG.md"

# Create log entry
cat >> "$LOG_FILE" << LOGENTRY

## $(date +"%Y-%m-%d %H:%M")

**Primary File:** \`$FILE_PATH\`

**Reason:** ${REASON:-"Not specified"}

**Files Deprecated:**
LOGENTRY

for file in "${TO_DEPRECATE[@]}"; do
    REL_PATH=$(realpath --relative-to="$PROJECT_ROOT" "$file")
    echo "- \`$REL_PATH\`" >> "$LOG_FILE"
done

if [ ${#DEP_USAGE[@]} -gt 0 ]; then
    cat >> "$LOG_FILE" << LOGENTRY2

**Dependencies Kept (still in use):**
LOGENTRY2
    for dep in "${!DEP_USAGE[@]}"; do
        REL_PATH=$(realpath --relative-to="$PROJECT_ROOT" "$dep")
        echo "- \`$REL_PATH\`" >> "$LOG_FILE"
    done
fi

echo "" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

echo "Deprecation log updated: deprecated/DEPRECATION_LOG.md"
```
