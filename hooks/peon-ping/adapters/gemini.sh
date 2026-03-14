#!/bin/bash
# peon-ping adapter for Gemini CLI
# Translates Gemini CLI hook events into peon.sh stdin JSON

set -euo pipefail

# Path to peon.sh - handles both local and global installs
PEON_DIR="${CLAUDE_PEON_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
[ ! -f "$PEON_DIR/peon.sh" ] && PEON_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/peon-ping"

GEMINI_EVENT_TYPE="${1:-SessionStart}"

# Gemini CLI sends JSON on stdin
INPUT=$(cat)

# Extract common fields
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('session_id', ''))" 2>/dev/null || echo "gemini-$$")
CWD=$(echo "$INPUT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('cwd', ''))" 2>/dev/null || echo "$PWD")

EVENT=""
case "$GEMINI_EVENT_TYPE" in
  SessionStart)
    EVENT="SessionStart"
    ;;
  AfterAgent)
    EVENT="Stop"
    ;;
  Notification)
    EVENT="Notification"
    ;;
  AfterTool)
    # Check if tool failed
    EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('exit_code', 0))" 2>/dev/null || echo 0)
    if [ "$EXIT_CODE" -ne 0 ]; then
      EVENT="PostToolUseFailure"
      TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys, json; print(json.load(sys.stdin).get('tool_name', 'unknown'))" 2>/dev/null || echo "unknown")
    else
      EVENT="Stop"
    fi
    ;;
  *)
    # Default fallback
    echo "{}"
    exit 0
    ;;
esac

# Prepare payload for peon.sh
if [ "$EVENT" = "PostToolUseFailure" ]; then
  echo "$INPUT" | python3 -c "
import sys, json
input_data = json.load(sys.stdin)
payload = {
    'hook_event_name': '$EVENT',
    'notification_type': '',
    'cwd': '$CWD',
    'session_id': '$SESSION_ID',
    'permission_mode': '',
    'tool_name': 'Bash',
    'error': input_data.get('stderr', 'Tool failed')
}
print(json.dumps(payload))
" | bash "$PEON_DIR/peon.sh" >/dev/null 2>&1 || true
else
  echo "$INPUT" | python3 -c "
import sys, json
payload = {
    'hook_event_name': '$EVENT',
    'notification_type': '',
    'cwd': '$CWD',
    'session_id': '$SESSION_ID',
    'permission_mode': ''
}
print(json.dumps(payload))
" | bash "$PEON_DIR/peon.sh" >/dev/null 2>&1 || true
fi

# Always return valid empty JSON to Gemini CLI
echo "{}"
