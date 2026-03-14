# Safe-Clear Examples

Supporting file for `/safe-clear` command. Contains detailed interaction examples.

---

## Example 1: Default Mode (Date-based)

```
User: /safe-clear

📝 Save session notes to Obsidian before clearing?

This will create a note documenting:
  • What was accomplished in this session
  • Key decisions made
  • Important discoveries or patterns

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]: 1

✍️ Generating session notes...

📝 Appending to existing note: 2026-02-05.md
✅ Session notes appended to: genome-pipeline/sessions-history/2026-02-05.md

🧠 Reviewing session for skill updates...

Would you like to update skills with knowledge from this session?

Update skills? (y/n): y

Running /update-skills command...

[update-skills runs and shows suggested updates]

✅ 3 skills updated with session knowledge

⚠️  Ready to clear context

Session knowledge preserved:
  • Obsidian notes: Appended
  • Skill updates: Applied

Clear context now? (y/n): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context Clear Summary:

Project: genome-pipeline
Session notes: Appended to genome-pipeline/sessions-history/2026-02-05.md
MANIFEST updates: 2 MANIFESTs updated
Skills updated: Yes (3 skills)
Context: Cleared ✓

💡 Your session notes are preserved in Obsidian
   Review them when you return: genome-pipeline/sessions-history/

💡 Skills updated with session knowledge

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context cleared. Ready for fresh start! 🔄
```

---

## Example 2: Custom Mode

```
User: /safe-clear

📝 Save session notes to Obsidian before clearing?

Options:
  1. Default (save to sessions-history/ with today's date)
  2. Custom (specify folder, filename, and theme)
  3. Skip

Enter choice [1-3]: 2

📝 Custom note configuration:

Subfolder within project (e.g., 'meetings', 'sprints'): sprints

Note filename (without .md, e.g., 'sprint-review', '2026-02-05-planning'): sprint-15-retrospective

Session theme/topic: Sprint 15 Review and Planning

✍️ Generating session notes...

📝 Creating new note: sprint-15-retrospective.md
✅ Session notes saved to: genome-pipeline/sprints/sprint-15-retrospective.md

🧠 Reviewing session for skill updates...

Would you like to update skills with knowledge from this session?

Update skills? (y/n): n

Skipping skill updates...

⚠️  Ready to clear context

Session knowledge preserved:
  • Obsidian notes: Saved
  • Skill updates: Skipped

Clear context now? (y/n): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context Clear Summary:

Session notes: Saved to genome-pipeline/sprints/sprint-15-retrospective.md
MANIFEST updates: Skipped
Skills updated: Skipped
Context: Cleared ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context cleared. Ready for fresh start! 🔄
```

---

## Example 3: Default Mode Note Structure (Multiple Sessions per Day)

**File:** `genome-pipeline/sessions-history/2026-02-05.md`

```markdown
---
type: session
project: genome-pipeline
date: 2026-02-05
tags:
  - session
  - dump
status: completed
---

# 2026-02-05

## Session 09:30

### What Was Accomplished

- Implemented pathway enrichment analysis using Fisher's exact test
- Created visualization script for pathway networks
- Added statistical correction (Benjamini-Hochberg FDR)

### Key Decisions & Rationale

- Chose Fisher's exact test over hypergeometric due to small sample sizes
- FDR correction at 0.05 threshold (standard in field)

### Context for Next Session

- Currently working on: pathway visualization improvements
- Next steps: add gene-level annotations to network

---

## Session 14:30

### What Was Accomplished

- Added gene-level annotations to network visualization
- Tested on sample dataset with 200 genes
- Created export functionality for Cytoscape

### Important Discoveries

- Found that pathway overlap affects enrichment scores
- Background gene set selection significantly impacts results
- Need to filter pathways with <5 genes for reliable statistics

### Context for Next Session

- Next steps: implement pathway clustering
- Open questions: best way to handle overlapping pathways

### Notes

Consider using semantic similarity for pathway clustering to reduce redundancy.

---
```

**Benefits of this structure:**
- All work for a given day in one file (easy to review)
- Sessions appended chronologically with timestamps
- Can see progression of work throughout the day
- Searchable by date in Obsidian
