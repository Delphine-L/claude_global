# Documentation Skills

Best practices for creating effective documentation during Claude Code sessions.

## Session Documentation

### Incremental Summary Documents

When working through multiple related issues in a session:

1. **Create summary after each major fix**:
   - `FIX_SUMMARY.md` - First issue resolved
   - `FISH_CLASSIFICATION_FIX_SUMMARY.md` - Second issue
   - `TAXONOMY_COMPLETE_SUMMARY.md` - Final state

2. **Benefits**:
   - User can reference specific fixes
   - Clear audit trail of changes
   - Easy to see what was done and why
   - Supports future troubleshooting

3. **Include in each summary**:
   - **Problem statement**: What was the issue?
   - **Root cause**: Why did it happen?
   - **Species/items affected**: With counts for verification
   - **Solution applied**: Step-by-step what was done
   - **Files modified**: Complete list with paths
   - **Verification results**: Show the fix worked
   - **Next steps**: What to do with the results

### Example Structure

```markdown
# [Issue Name] - [STATUS]

## Problem
[Clear description of what was wrong]

## Root Cause
[Why the problem occurred]

## Items Fixed (N total)
| Item | Details | Category |
|------|---------|----------|
| ... | ... | ... |

## Solution Applied
1. [Step 1]
2. [Step 2]
...

## Verification Results
✓ [What was verified]
✓ [Counts match]

## Files Modified
1. `file1.txt` - [what changed]
2. `file2.txt` - [what changed]

## Next Steps
[What the user should do now]
```

### When to Create Summaries

- **After fixing a significant bug**: Document root cause and solution
- **After completing a major task**: Show what was accomplished
- **After each iteration in multi-step fixes**: Track progress
- **At session end**: Comprehensive final state summary

### Documentation File Naming

Use descriptive names that indicate:
- What was fixed: `FISH_CLASSIFICATION_FIX_SUMMARY.md`
- Scope: `TAXONOMY_COMPLETE_SUMMARY.md`
- Status: Include "FIXED", "COMPLETE", "FINAL" in filename

Avoid generic names like `SUMMARY.md` or `NOTES.md`.

## Related Skills

- **Skill Management**: Capturing learnings from documentation
- **Token Efficiency**: Concise yet complete documentation
