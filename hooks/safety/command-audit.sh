#!/bin/bash
# Log all Bash commands to an audit file for reproducibility
# Logs to .claude/command-audit.log in the project directory

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$CMD" ] && exit 0

LOGDIR="${CWD}/.claude"
[ -d "$LOGDIR" ] || exit 0

LOGFILE="$LOGDIR/command-audit.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] $CMD" >> "$LOGFILE"

exit 0
