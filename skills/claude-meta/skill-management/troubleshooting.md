# Troubleshooting

## Broken Symlinks (Renamed or Moved Skills/Commands)

**Symptom:** Symlink exists but points to non-existent file (renamed or moved in `$CLAUDE_METADATA`)

**Detection:**
```bash
# Detect broken skill symlinks
for skill in .claude/skills/*; do
  if [ -L "$skill" ] && [ ! -e "$skill" ]; then
    echo "BROKEN: $skill -> $(readlink "$skill")"
  fi
done

# Detect broken command symlinks
for cmd in .claude/commands/*; do
  if [ -L "$cmd" ] && [ ! -e "$cmd" ]; then
    echo "BROKEN: $cmd -> $(readlink "$cmd")"
  fi
done
```

**Common causes:**
- Command renamed (e.g., `exit.md` -> `safe-exit.md`)
- Skill reorganized in `$CLAUDE_METADATA`
- Skill deleted from central repository

**Fix:**
```bash
# Remove broken symlink
rm .claude/commands/old-name.md

# Add new symlink
ln -s $CLAUDE_METADATA/commands/global/new-name.md .claude/commands/new-name.md

# Verify
ls -la .claude/commands/ | grep new-name
```

**Prevention:** Use `/sync-skills` regularly to detect and fix broken symlinks automatically

## Skill Not Activating

**Check 1: Verify symlink exists**
```bash
ls -la .claude/skills/
# Should show: skill-name -> $CLAUDE_METADATA/skills/skill-name
```

**Check 2: Verify target exists (detect broken symlink)**
```bash
ls -L .claude/skills/skill-name
# Should show: SKILL.md
# If error: broken symlink - target doesn't exist

# Or use this check:
test -e .claude/skills/skill-name && echo "OK" || echo "BROKEN SYMLINK"
```

**Check 3: Check frontmatter**
```bash
head -10 .claude/skills/skill-name/SKILL.md
# Should have:
# ---
# name: skill-name
# description: ...
# ---
```

**Check 4: Description clarity**
- Is the description clear about when to use the skill?
- Does it match your request?
- Try explicitly mentioning: "Use the skill-name skill to..."

## Command Not Found

**Check 1: Verify symlink**
```bash
ls -la .claude/commands/command-name.md
```

**Check 2: Restart Claude Code**
Commands are loaded at session start, so restart if you just added it.

**Check 3: Check frontmatter**
```bash
head -5 .claude/commands/command-name.md
# Should have:
# ---
# name: command-name
# description: ...
# ---
```

## $CLAUDE_METADATA Not Set

**Symptom:** Symlink commands fail with "No such file or directory"

**Fix:**
```bash
# Check current value
echo $CLAUDE_METADATA

# If empty, add to shell config
echo 'export CLAUDE_METADATA="$HOME/path/to/claude_data"  # Adjust to your actual path' >> ~/.zshrc
source ~/.zshrc

# Verify
echo $CLAUDE_METADATA
```

## Symlink Points to Wrong Location

**Symptom:** `ls -la .claude/skills/skill-name` shows wrong path

**Fix:**
```bash
# Remove broken symlink
rm .claude/skills/skill-name

# Recreate with correct path
ln -s $CLAUDE_METADATA/skills/skill-name .claude/skills/skill-name

# Verify
ls -L .claude/skills/skill-name
```

## Changes Not Appearing in Projects

**Symptom:** Updated skill in `$CLAUDE_METADATA` but projects don't see changes

**Possible causes:**
1. **Not using symlinks** - Projects have copies instead
   ```bash
   # Check if it's a symlink
   ls -la .claude/skills/skill-name
   # Should show -> pointing to $CLAUDE_METADATA
   ```

2. **Claude Code hasn't restarted** - Skills loaded at session start
   - Fix: Restart Claude Code session

3. **Editing wrong file** - Multiple copies exist
   ```bash
   # Find all copies
   find ~/Workdir -name "SKILL.md" -path "*/skill-name/*"
   # Should only show one in $CLAUDE_METADATA
   ```

## Hook Troubleshooting

### Background Processes in Synchronous Hooks (fd Leak)

**Symptom:** All user input disappears instantly with no spinner or response. Disabling all hooks (`"disableAllHooks": true` in `settings.json`) fixes it.

**Root cause:** A synchronous hook spawns a background process with `( ... ) &`. The child inherits the parent's stdout pipe. Claude Code waits for EOF on that pipe before considering the hook "done." The background child keeps the fd open indefinitely, so Claude Code hangs.

**Fix:** Redirect all file descriptors in the background subshell:
```bash
# BAD — child holds parent's stdout pipe open
(
    while true; do sleep 900; do_work; done
) &

# GOOD — detach child from parent's stdio
(
    while true; do sleep 900; do_work; done
) </dev/null >/dev/null 2>&1 &
```

**Key insight:** This affects ALL synchronous hooks that spawn background processes, not just `SessionStart`. The same pattern in `UserPromptSubmit`, `PreToolUse`, or `PreCompact` hooks would cause identical symptoms.

### Silent Input Swallowing from Hook Crashes

**Symptom:** Same as above — input disappears with no response.

**Root cause:** A synchronous `UserPromptSubmit` hook exits non-zero (crash) or returns invalid JSON. Claude Code blocks the prompt.

**Fix:** Add a safety trap at the top of synchronous UserPromptSubmit hooks:
```bash
set -uo pipefail  # NOT -euo — remove -e
trap 'echo "{\"continue\": true}"; exit 0' ERR
```

This ensures the hook always passes the prompt through, even on unexpected errors.

### Binary Search Method for Isolating Broken Hooks

When hooks break Claude Code and you can't identify which one:

1. Set `"disableAllHooks": true` to confirm hooks are the cause
2. Replace ALL hooks with a minimal passthrough:
   ```bash
   #!/bin/bash
   cat > /dev/null
   echo '{"continue": true}'
   exit 0
   ```
3. If that works, restore hooks by **event type** (SessionStart, UserPromptSubmit, etc.) one at a time
4. Once the broken event type is found, test hooks within that group individually
5. Each test requires a **new session** (hooks load at startup)

**Tip:** Create `~/.claude/hooks/safety/test-passthrough.sh` as a permanent diagnostic tool.
