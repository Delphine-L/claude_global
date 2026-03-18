---
name: update-manifest
description: Quick-update existing MANIFEST.md files preserving user content - faster than full regeneration
---

# Update MANIFEST Command

## Instructions

You are tasked with updating existing MANIFEST.md file(s). This command can update a single MANIFEST or recursively update all MANIFESTs that have been modified during the current session.

### 1. Locate MANIFEST(s)

**Determine update scope**:

If user specifies a directory:
- Look for `[directory]/MANIFEST.md`
- Update only that MANIFEST

If no directory specified (default behavior):
- **RECURSIVE MODE**: Find and update ALL MANIFESTs in directories with modifications during this session
- Use git or file timestamps to detect modified directories (if available)
- Exclude `deprecated/` and subdirectories
- Process in order: deepest subdirectories first, then parent directories

**Finding modified directories**:
```bash
# If git repo, find modified files in this session
git status --short 2>/dev/null | cut -c4- | xargs -I {} dirname {} | sort -u

# Or use recent file modifications (files modified in last hour)
find . -type f -mmin -60 -not -path "*/deprecated/*" -not -path "*/.git/*" | xargs -I {} dirname {} | sort -u
```

If MANIFEST doesn't exist in a modified directory:
- Note it and suggest using `/generate-manifest` for that directory
- Continue with other MANIFESTs

### 2. Read Existing MANIFEST

**Parse the current MANIFEST.md**:
- Read the entire file
- Identify sections and their content
- Note which fields are user-filled vs auto-generated
- Preserve structure and formatting

### 3. Detect Changes

**Compare current directory state with MANIFEST**:

Check for:
- **New files** not documented in MANIFEST
- **Deleted files** still listed in MANIFEST (verify they don't exist)
- **Modified files** with updated dates/sizes
- **Moved files** (deleted from one location, new in another)

**IMPORTANT - File Existence Verification**:
For each file listed in the MANIFEST:
```bash
# Extract filenames from MANIFEST and verify they exist
grep -E "^####? \`.*\`" MANIFEST.md | sed 's/.*`\(.*\)`.*/\1/' | while read file; do
    if [ ! -e "$file" ]; then
        echo "MISSING: $file"
    fi
done
```

Mark missing files with **[FILE NOT FOUND]** or move to "Recently Removed" section.

Use efficient commands for file information:
```bash
# Get current file list with dates and sizes
ls -lh [directory]/

# For subdirectories, also check
ls -lhd [directory]/*/
```

### 4. Update File Information

**For files already in MANIFEST**:

Update only these fields:
- **Last modified** dates (check file timestamps)
- **File sizes** (update if changed significantly)
- **Status** (Active → Deprecated if moved to deprecated/)

**Preserve these user-entered fields**:
- Purpose/Description
- Key findings
- Priority
- Notes
- Any [USER TO FILL] content that has been filled in

**For new files**:
- Add basic entry with filename, size, date
- Mark description as [TO BE DOCUMENTED]
- Place in appropriate section based on file type

**For deleted/moved files**:
- Move entry to a "Recently Removed" section at bottom
- Or note in "Notes for Resuming Work" if significant

### 5. Update Active Tasks (Root MANIFEST only)

**If root MANIFEST has `## Active Tasks`**, update it:

#### Task Status
Ask user: "Did you complete or start any tasks? Any new tasks to add?"
- Update task statuses (`Active` → `Complete`, `Paused` → `In progress`, etc.)
- Add new tasks with active files and TODOs
- For completed tasks, move them to a `## Completed Tasks` section at the bottom

#### Per-Task TODOs
- Check off completed TODO items: `- [ ]` → `- [x] ~~text~~ (DATE)`
- Add new TODO items the user mentions
- **Prune completed TODOs older than 14 days** — remove `[x]` items where the date is > 14 days ago

#### Active Files
- Add/remove files from task active lists based on session work
- Verify active files still exist

#### Task Pruning
- Move `Complete` tasks to `## Completed Tasks` archive section
- **Remove archived tasks older than 30 days**

### 5b. Purge Non-Active PROGRESS Entries

**After updating Active Tasks**, cross-reference PROGRESS.md:
- Read PROGRESS.md `## File Changelogs`
- Collect all file paths from all Active Tasks' active files lists
- For any file changelog entry in PROGRESS.md that is NOT in any Active Task's active files, **remove that file's changelog section**
- Show user what was purged: "Removed PROGRESS entries for files no longer in Active Tasks: [list]"

This keeps PROGRESS.md focused on currently relevant files.

### 5c. Update Metadata Sections

**Always update these sections**:

#### Header
- **Last Updated**: Set to today's date

#### Quick Reference
- Update if key outputs or entry points changed

#### Directory Structure
- Update if new subdirectories were added

### 6. Smart Update Mode

**Determine update scope based on context**:

**Quick Update** (default):
- Update dates and sizes
- Add new files
- Update "Last Updated" and "Notes for Resuming Work"
- Takes ~1-2 minutes

**Full Update**:
- Everything in Quick Update, plus:
- Re-analyze file dependencies
- Update workflow diagrams
- Refresh all descriptions
- Takes ~5-10 minutes
- Use when: major restructuring, many changes, user requests it

Ask user which mode unless obvious from context.

### 7. Handle User Input Strategically

**Use AskUserQuestion for**:
- Session context (current status, next steps, known issues) - ALWAYS ASK
- New file purposes - if filename isn't self-explanatory
- Priority of new notebooks - if multiple notebooks added
- Whether to use Quick or Full update mode - if ambiguous

**Don't ask about**:
- File sizes, dates (auto-detect)
- File existence (check filesystem)
- Technical metadata (extract from files)

### 8. Preserve Formatting

**Maintain consistency**:
- Keep same markdown formatting style
- Preserve custom sections user may have added
- Maintain indentation and spacing
- Keep same section order unless reorganization needed

### 9. Provide Update Summary

**After updating, show user**:

**For single MANIFEST update**:
```markdown
## MANIFEST Update Summary

**Updated**: [directory]/MANIFEST.md
**Date**: YYYY-MM-DD

### Changes Made:
- Updated "Last Updated" date
- Updated "Notes for Resuming Work" section
- Added X new files: [list]
- Updated Y existing files: [list]
- Removed/archived Z files: [list]

### File Verification:
- ✅ All files verified to exist
- ⚠️ Missing files found: [list with **[FILE NOT FOUND]** markers]

### Requires Attention:
- [New file 1] needs description
- [New file 2] needs priority classification
- [Field X] marked as [USER TO FILL]

### Next Steps:
- Fill in new file descriptions when you have time
- Consider running `/generate-manifest [directory]` if major restructuring occurred
```

**For recursive update (multiple MANIFESTs)**:
```markdown
## MANIFEST Update Summary - Recursive

**Date**: YYYY-MM-DD
**Directories Updated**: X

### MANIFESTs Updated:
1. ✅ ./MANIFEST.md (root)
   - Added 2 new files, updated 5 files
   - ⚠️ 1 missing file found
2. ✅ clade_analyses/mammals/MANIFEST.md
   - Updated 3 files, no missing files
3. ✅ data/MANIFEST.md
   - Added 1 new file, no changes

### Directories with Modifications but No MANIFEST:
- scripts/utils/ - Consider creating MANIFEST
- figures/comparative/ - Consider creating MANIFEST

### Total Changes:
- MANIFESTs updated: X
- New files added: Y
- Files verified: Z
- Missing files found: W

### Requires Attention:
[Consolidated list from all MANIFESTs]

### Next Steps:
- Create MANIFESTs for new directories if needed
- Address missing file issues
- Fill in new file descriptions
```

### 10. Integration with Workflow

**When to use this command**:
- End of coding session (update project status)
- After adding new files
- After generating new figures
- Before using `/safe-exit` or `/safe-clear`
- When notebook modifications are complete

**When to use `/generate-manifest` instead**:
- MANIFEST doesn't exist yet
- Major project restructuring
- Too many changes for quick update
- Want to re-analyze all dependencies
- MANIFEST structure needs overhaul

## Usage Examples

```bash
/update-manifest
# RECURSIVE MODE: Updates ALL MANIFESTs in directories with modifications
# Excludes deprecated/ directories
# Asks for session context once, applies to all

/update-manifest data
# Updates only data/MANIFEST.md

/update-manifest --all
# Explicit recursive mode (same as no args)

/update-manifest --quick
# Quick update mode (no dependency re-analysis)

/update-manifest --full
# Full update mode (re-analyze everything)

/update-manifest --verify-only
# Only verify file existence, don't update session context
```

## Recursive Update Protocol

### When Updating Multiple MANIFESTs:

**1. Discovery Phase**:
- Find all directories with modifications (exclude deprecated/)
- Find all existing MANIFESTs in those directories
- Build update list from deepest to shallowest (subdirs first, then parents)

**2. User Input Phase**:
- Ask session context questions ONCE (applies to all MANIFESTs)
- Use same answers for all "Notes for Resuming Work" sections
- This saves time and ensures consistency

**3. Update Phase**:
Process each MANIFEST in order:
- Update file lists and verification
- Apply session context
- Track changes for summary report

**4. Reporting Phase**:
- Show consolidated summary of all updates
- List directories needing new MANIFESTs
- Highlight missing files across all directories

### Session Context for Recursive Updates:

Ask once, apply to all:
- **Current Status**: What did you accomplish? (applies to project overall)
- **Next Steps**: What should be done next? (project-wide)
- **Known Issues**: Any new issues? (affects all MANIFESTs)

For directory-specific context:
- File-level changes are auto-detected
- Only generic session info is shared across MANIFESTs

## Update Protocol

### Minimal Update (Always Do This):
1. Update "Last Updated" date
2. Ask user about session context (current status, next steps, issues)
3. Check for new/deleted files
4. **Verify file existence** for all listed files
5. Update file modification dates

### Standard Update (Default):
1. All minimal updates, plus:
2. Update file sizes for changed files
3. Add basic entries for new files
4. Mark removed files appropriately with **[FILE NOT FOUND]**
5. Update Quick Reference if outputs changed

### Full Update (When Requested):
1. All standard updates, plus:
2. Re-scan file dependencies
3. Update workflow dependency diagrams
4. Refresh file descriptions from code
5. Re-analyze directory structure
6. Update all cross-references

## Best Practices

1. **Update regularly** - After each significant work session
2. **Capture context immediately** - Don't wait; you'll forget details
3. **Be specific in status updates** - "Added curation category analysis" not "worked on analysis"
4. **Document decisions** - Why did you choose this approach?
5. **Note blockers** - What prevented you from finishing something?
6. **Link to commits** - If you made a git commit, reference it
7. **Quick is better than perfect** - A brief update now beats detailed update never

## Quick Session Close Pattern

At end of session, run these in sequence:
```bash
/update-manifest              # Update project status
/update-skills               # Capture new knowledge in skills
/safe-exit                   # Clean exit with Obsidian notes
```

Or for continuing work:
```bash
/update-manifest              # Update project status
/safe-clear                  # Clear context, keep working
```

## Field Preservation Rules

**Always Preserve** (user-entered content):
- Purpose/Description text
- Key findings
- Priority classifications
- Custom notes
- Filled-in [USER TO FILL] fields
- Custom sections user added

**Always Update** (auto-generated):
- Last Updated date
- File sizes
- Last modified dates
- File existence checks

**Ask Before Updating** (context-dependent):
- Current Status
- Next Steps
- Known Issues
- Priority of new items

---

**Remember**: This command is about maintaining continuity and capturing session context. The goal is to keep the MANIFEST current without losing user insights. Think "git commit message for your analysis work" - what would you want to know when you resume later?
