# Obsidian Note Templates

Templates for creating notes in Obsidian. Use these as starting points for consistent note creation.

## Session Note Template

```markdown
---
type: session
project: {{project-name}}
date: {{date}}
tags:
  - session
  - dump
  - {{topic-tags}}
status: completed | in-progress
---

# Session: {{topic}} - {{date}}

## Context
What we're working on and why

## Summary
Key points and outcomes from this session

## Decisions
- Decision 1
- Decision 2

## Action Items
- [ ] Task 1
- [ ] Task 2

## Links
- [[Related Note 1]]
- [[Related Note 2]]

## Code References
- `file.py:123` - Description of code location

---
**Session with**: Claude
**Duration**: {{duration}}
```

## Technical Note Template

```markdown
---
date: {{date}}
type: technical-note
tags:
  - technical
  - {{topic}}
---

# {{Title}}

## Problem
Description of the issue or topic

## Solution
How it was resolved or implemented

## Implementation Details
```language
code example
```

## Related Concepts
- [[Concept 1]]
- [[Concept 2]]

## References
- External links or documentation

## Notes
Additional thoughts or considerations
```

## Task Note Template

```markdown
---
date: {{date}}
type: task
tags:
  - task
  - status/pending
project: {{project-name}}
---

# Task: {{task-name}}

## Description
What needs to be done

## Requirements
- Requirement 1
- Requirement 2

## Checklist
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Dependencies
- [[Related Task 1]]
- [[Related Task 2]]

## Notes
Additional context or considerations

## Completion
**Status**: Pending
**Priority**: Medium
**Due**: {{date}}
```

## Analysis Planning Note Template

For complex analyses that need to be implemented later:

```markdown
---
type: analysis-planning
status: planned
priority: medium
tags:
  - analysis
  - planning
created: {{date}}
---

# Analysis: [Title]

## Context
[What question are we trying to answer? What triggered this analysis idea?]

## Available Data
- **Dataset 1**: [name, location, size, key fields]
- **Dataset 2**: [name, location, size, key fields]
- **Related outputs**: [existing figures, tables, or analyses]

## Analysis Options

### Option 1: [Descriptive name]
**Approach**: [Brief description]
**Pros**:
- [Advantage 1]
- [Advantage 2]

**Cons**:
- [Challenge 1]
- [Challenge 2]

**Estimated effort**: [hours/days]

### Option 2: [Descriptive name]
**Approach**: [Brief description]
**Pros**:
- [Advantage 1]

**Cons**:
- [Challenge 1]

**Estimated effort**: [hours/days]

### Option 3: [Descriptive name]
[Continue pattern...]

## Recommended Approach
[Which option to pursue and why]

## Implementation Notes
```python
# Key code patterns or pseudocode
# Example structure for the analysis
```

## Next Steps
1. [ ] [Specific action 1]
2. [ ] [Specific action 2]
3. [ ] [Generate figure/table]

## Related Files
- [[Related Analysis]]
- `path/to/relevant/script.py`
- `path/to/dataset.csv`

## Status Updates
**{{date}}**: Created planning note
```

## Thematic Reference Note Template

For consolidating session notes into topic-based reference:

```markdown
---
type: reference
project: project-name
tags:
  - theme-tag
  - topic-tag
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: completed | in-progress
---

# Thematic Title

**Project:** Project Name
**Period:** Date Range
**Status:** Current status

---

## Overview

High-level summary of this work area

---

## Section 1: Sub-topic

Content from multiple sessions organized coherently

### Key Decisions
- Decision 1 (from session YYYY-MM-DD)
- Decision 2 (from session YYYY-MM-DD)

### Implementation
Details consolidated from sessions

---

## Section 2: Another Sub-topic

[Continue organizing by topic]

---

## Files and Locations

Document relevant files and paths

---

## Related Notes

- [[Other-Thematic-Note|Related Topic]]
- [[Project-Planning|Planning Docs]]

---

*Consolidated from sessions: YYYY-MM-DD, YYYY-MM-DD, YYYY-MM-DD*
```

## Project TODO Template

```markdown
---
type: todo
project: project-name
status: active | completed
tags:
  - todo
  - project-name
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Project Name - TODOs

**Last Updated:** YYYY-MM-DD

---

## Active Tasks

### Phase 1: [Phase Name]
- [ ] Task 1 extracted from session
- [ ] Task 2 from session
- [x] Task 3 (completed)

### Phase 2: [Next Phase]
- [ ] Future task

---

## Completed (Archive)

### [Milestone Name] (Completed YYYY-MM-DD)
- [x] Completed task 1
- [x] Completed task 2

---

## Related Notes
- [[Thematic-Note-1|Reference]]
- [[Project-Planning|Planning Docs]]

---

*Extracted from session notes consolidated on YYYY-MM-DD*
```

## Section HOME.md Template

```markdown
---
type: moc
section: section-name
tags:
  - home
  - moc
---

# Section Name

## Projects

- [[project-1/Project-1-MOC|Project 1]] - Description
- [[project-2/Project-2-MOC|Project 2]] - Description

## Quick Access

- [[TO-DOS|Section TODOs]]
- [[Archives|Archived Work]]

## Other Sections

- [[../Other-Section/HOME|Other Section]]
- [[../../Perso/HOME|Personal]]

---

*Section home for [Category]*
```
