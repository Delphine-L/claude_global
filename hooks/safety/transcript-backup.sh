#!/bin/bash
# Backup transcript before compaction
# Saves to ~/.claude/transcript-backups/

INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0

BACKUP_DIR="$HOME/.claude/transcript-backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
BACKUP_FILE="$BACKUP_DIR/${TIMESTAMP}-${SESSION_ID:0:8}.jsonl"

cp "$TRANSCRIPT" "$BACKUP_FILE" 2>/dev/null

# Keep only last 20 backups
ls -t "$BACKUP_DIR"/*.jsonl 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null

exit 0
