#!/bin/bash
# Block destructive git and file commands
# Exit 2 = block with message, Exit 0 = allow

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Normalize: collapse whitespace, trim
CMD_CLEAN=$(echo "$CMD" | tr -s ' ' | sed 's/^ *//;s/ *$//')

# Destructive git commands to block
if echo "$CMD_CLEAN" | grep -qE 'git\s+reset\s+--hard'; then
    echo "BLOCKED: git reset --hard destroys uncommitted work. Use git stash or git checkout <file> instead." >&2
    exit 2
fi

if echo "$CMD_CLEAN" | grep -qE 'git\s+push\s+.*--force|git\s+push\s+-f\b'; then
    echo "BLOCKED: git push --force can overwrite remote history. Use --force-with-lease if you must." >&2
    exit 2
fi

if echo "$CMD_CLEAN" | grep -qE 'git\s+clean\s+-f'; then
    echo "BLOCKED: git clean -f permanently deletes untracked files." >&2
    exit 2
fi

if echo "$CMD_CLEAN" | grep -qE 'git\s+checkout\s+--\s+\.'; then
    echo "BLOCKED: git checkout -- . discards all unstaged changes." >&2
    exit 2
fi

if echo "$CMD_CLEAN" | grep -qE 'git\s+stash\s+(drop|clear)'; then
    echo "BLOCKED: git stash drop/clear permanently deletes stashed work." >&2
    exit 2
fi

if echo "$CMD_CLEAN" | grep -qE 'git\s+branch\s+-D\b'; then
    echo "BLOCKED: git branch -D force-deletes a branch. Use -d for safe delete." >&2
    exit 2
fi

# GitHub PR and issue creation — require user approval of text first
# The hook blocks the command. Claude must show the text to the user, get approval,
# then re-run with CLAUDE_PR_APPROVED=1 or CLAUDE_ISSUE_APPROVED=1 prefix.
if echo "$CMD_CLEAN" | grep -qE 'gh\s+pr\s+create'; then
    if ! echo "$CMD_CLEAN" | grep -qE 'CLAUDE_PR_APPROVED=1'; then
        echo "BLOCKED: You must show the full PR title and body to the user and get their explicit approval before creating the PR. Once approved, re-run the command prefixed with CLAUDE_PR_APPROVED=1." >&2
        exit 2
    fi
fi

if echo "$CMD_CLEAN" | grep -qE 'gh\s+issue\s+create'; then
    if ! echo "$CMD_CLEAN" | grep -qE 'CLAUDE_ISSUE_APPROVED=1'; then
        echo "BLOCKED: You must show the full issue title and body to the user and get their explicit approval before creating the issue. Once approved, re-run the command prefixed with CLAUDE_ISSUE_APPROVED=1." >&2
        exit 2
    fi
fi

# Destructive file commands - block rm -rf outside /tmp
if echo "$CMD_CLEAN" | grep -qE 'rm\s+-rf\s' | grep -qvE 'rm\s+-rf\s+/tmp'; then
    if ! echo "$CMD_CLEAN" | grep -qE 'rm\s+-rf\s+/tmp'; then
        echo "BLOCKED: rm -rf outside /tmp is dangerous. Be specific about what to delete." >&2
        exit 2
    fi
fi

exit 0
