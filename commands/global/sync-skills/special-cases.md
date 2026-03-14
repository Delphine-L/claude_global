# Sync-Skills: Special Cases

## No .claude/ Directory Yet
```
⚠️  No .claude/ directory found at the git root ($PROJECT_ROOT).

This project hasn't been set up for Claude Code yet.

Would you like me to run /setup-project instead?
```

## Symlinked Settings (migrate to local)

If `settings.local.json` is a symlink, recommend replacing it with a local file:

```
⚠️  settings.local.json is symlinked → $CLAUDE_METADATA/.claude/settings.local.json

This can cause issues:
- Concurrent sessions writing "always allow" to the same file
- Project-specific permissions polluting other projects

Recommended: Replace symlink with a local file for project-specific permissions.
Global permissions are already handled by ~/.claude/settings.local.json.

To fix:
  rm "$PROJECT_ROOT/.claude/settings.local.json"
  echo '{"permissions": {"allow": [], "deny": [], "ask": []}}' > "$PROJECT_ROOT/.claude/settings.local.json"

Any project-specific permissions will be added here as you work.
Broad patterns should go in ~/.claude/settings.local.json via /update-skills.
```

## Subdirectory .claude/ Overrides
```
⚠️  Found .claude/ in subdirectory that may override root settings:

  Root:   $PROJECT_ROOT/.claude/settings.local.json
  Subdir: $PWD/.claude/settings.local.json

The subdirectory settings may override the root's permission set.

Recommended: Delete the subdirectory settings file so the root one takes effect.
```

## Everything Up to Date
```
✅ All synced!

Your project has all available skills and commands that are relevant.

Current setup:
- 8 essential global skills ✅
- X project-specific skills ✅
- Y commands ✅

No new skills or commands available.
```

## Broken Symlinks

**When you detect broken symlinks, ALWAYS:**
1. Report them clearly to the user
2. Check `$CLAUDE_METADATA` for renamed/moved files
3. Offer to fix automatically (remove old + add new)
4. Provide manual fix commands as backup

**Example output:**
```
⚠️  Found broken symlinks:

Commands:
- exit.md → /path/to/claude_global/commands/global/exit.md (NOT FOUND)
  └─ Likely renamed to: safe-exit.md ✓ (detected in $CLAUDE_METADATA)

These symlinks point to files that have been renamed or removed.

Recommended fix:
1. Remove broken symlink: rm .claude/commands/exit.md
2. Add new symlink: ln -s $CLAUDE_METADATA/commands/global/safe-exit.md .claude/commands/safe-exit.md

Would you like me to fix this automatically?
```

**Common rename patterns to check:**
- Commands in `global/` that may have been renamed
- Skills that moved to subdirectories (e.g., `vgp-pipeline` → `bioinformatics/vgp-pipeline`)
- Skills split or merged

**Auto-detection strategy:**
```bash
# For broken command symlink "exit.md"
# 1. Extract base name: "exit"
# 2. Search for similar names in $CLAUDE_METADATA/commands/global/
# 3. Check for: safe-exit.md, exit-*.md, *-exit.md
# 4. Suggest most likely match

# Example:
ls $CLAUDE_METADATA/commands/global/ | grep -i "exit"
# Output: safe-exit.md
# Suggestion: "Likely renamed from exit.md to safe-exit.md"
```

**After fixing broken symlinks, verify:**
```bash
# Ensure no more broken links
test -e .claude/commands/safe-exit.md && echo "✓ Fixed" || echo "✗ Still broken"
```
