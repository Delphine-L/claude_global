# Practical Organization Patterns (From Real Sessions)

Proven patterns for organizing Obsidian vaults, tested in production use.

## Pattern 1: Home MOC as Central Hub

**Implementation Example**:

```markdown
---
type: moc
title: Home
tags: [index, home]
created: YYYY-MM-DD
---

# Home

**Last Updated:** YYYY-MM-DD

## Active Projects

### Project 1
**Status:** In Progress | **Priority:** High

- [[Project-1/Planning/Main-Plan|Planning Document]]
- [[Project-1/Analysis/Analysis-Plan|Analysis Plan]]

### Project 2
**Status:** Active | **Priority:** Medium

- [[Project-2/Development/Latest-Session|Latest Work]]

## Quick Access

### TODOs & Planning
- [[TODOs/Master-TODO-Index|All TODOs]]
- [[TODOs/Project-1-TODOs|Project 1 Tasks]]

### Recent Sessions
- [[Project-1/Sessions/YYYY-MM-DD|Today]]
- [[Project-1/Sessions/YYYY-MM-DD|Yesterday]]

## Knowledge by Topic

### Topic Area 1
**Core Documents:**
- [[Path/To/Core-Doc-1|Core Document]]
- [[Path/To/Core-Doc-2|Secondary Document]]

**Related Work:**
- [[Path/To/Related-1|Related Item 1]]

## Browse by Note Type

### Planning & Strategy
- [[Path/To/Planning-1]]
- [[Path/To/Planning-2]]

### Development & Implementation
- [[Path/To/Dev-1]]

### Reference & Guides
- [[Path/To/Guide-1]]

### TODOs & Task Management
- [[TODOs/Master-TODO-Index]]

### Archives
- [[Archives/Old-Sessions/Summary]]

## Cross-Project Connections

### Related Projects
- **Project A** <-> **Project B** - Shared analysis work
- Links span multiple project folders

## Project Status Overview

| Project | Status | Priority | TODOs | Updated |
|---------|--------|----------|-------|---------|
| Project 1 | In Progress | High | [[TODOs/Project-1-TODOs|View]] | YYYY-MM-DD |
| Project 2 | Active | Medium | [[TODOs/Project-2-TODOs|View]] | YYYY-MM-DD |

## Quick Actions

**Most Common Tasks:**
- Review [[TODOs/Master-TODO-Index|Active TODOs]]
- Check [[Project-1/Planning/Main-Plan|Planning docs]]
- Update [[Path/To/Status-Doc|Status]]

**Weekly Review:**
- Update project statuses in this note
- Archive old session notes
- Consolidate TODOs
- Link related notes discovered during week
```

**Benefits:**
- Single entry point for entire vault
- Visual hierarchy with emojis
- Status tracking in tables
- Quick actions for common workflows
- Weekly review checklist

## Pattern 2: Project MOCs

**Implementation Example**:

```markdown
---
type: moc
project: project-name
status: active
tags:
  - project-name
  - moc
priority: high
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Project Name MOC

*Map of Content for Project Name*

**Last Updated:** YYYY-MM-DD
**Status:** In Progress

---

## Planning & Strategy

### Core Planning Documents
- [[Project/Planning/Main-Plan|Main Plan]] - **CRITICAL**
  - Key decision 1
  - Key decision 2
  - Status: In progress

- [[Project/Planning/TODOs|Task List]] - **HIGH PRIORITY**
  - Active tasks
  - Blocked items

---

## Development

### Recent Work (Month YYYY)
- [[Project/Dev/YYYY-MM-DD_topic-1|Topic 1]] (Date 1)
- [[Project/Dev/YYYY-MM-DD_topic-2|Topic 2]] (Date 2)

### Current Sessions
- [[Project/Sessions/YYYY-MM-DD|Today]]
- [[Project/Sessions/YYYY-MM-DD|Yesterday]]

---

## TODOs & Tasks

- [[TODOs/Project-TODOs|Active Tasks]] - Extracted task list

### Key Tasks
- [ ] Task 1 - High priority
- [ ] Task 2 - Medium priority
- [x] Task 3 - Completed

---

## Related Projects

- [[Other-Project/Other-Project-MOC|Other Project]] - Related work
- Cross-references and shared analysis

---

## Quick Actions

**Common Tasks:**
- Review [[Project/Planning/Main-Plan|planning docs]]
- Check [[TODOs/Project-TODOs|active tasks]]
- Update [[Project/Status|status]]

**Weekly Review:**
- Archive completed sessions
- Update TODO status
- Link new notes to this MOC

---

[[Home|<- Back to Home]]
```

**MOC Features:**
- Keep under 25 items per section
- Use sub-MOCs when sections get large
- Include status and priority
- Add "Quick Actions" for common workflows
- Link back to Home

## Pattern 3: Properties in Practice

**Add to ALL Notes:**

```markdown
---
type: planning | reference | todo | moc | development | session
project: project-name
subproject: optional-subproject
status: active | in-progress | completed | archived
tags:
  - relevant-tag-1
  - relevant-tag-2
  - dump  # Add to ALL session/daily notes for easy filtering
priority: critical | high | medium | low
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

**Practical Usage:**

```bash
# Find all high-priority planning notes
# In Obsidian search: priority: high type: planning

# Find all active TODOs
# In Obsidian search: type: todo status: active

# Find all notes for a project
# In Obsidian search: project: project-name

# Find all completed work
# In Obsidian search: status: completed

# Find all session/daily notes (for archiving)
# In Obsidian search: tag:#dump

# Find all session notes for a specific project
# In Obsidian search: tag:#dump project: curation-paper
```

## Pattern 4: TODO Consolidation

**Create Central TODO Directory:**

```
TODOs/
├── Master-TODO-Index.md     # Central index
├── Project-1-TODOs.md       # Project-specific
├── Project-2-TODOs.md
└── Archive/                 # Completed TODOs
```

**Master Index Structure:**

```markdown
---
type: todo
project: all
status: active
tags: [todo, index, master]
priority: high
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Master TODO Index

## Project 1
**Status:** In Progress | **Priority:** High

[[TODOs/Project-1-TODOs|Project 1 TODOs]]

**Key Tasks:**
- Task 1
- Task 2

**Related Projects:**
- [[TODOs/Project-2-TODOs|Project 2]]

## Quick Navigation

### By Project Area
- [[TODOs/Project-1-TODOs|Project 1]]
- [[TODOs/Project-2-TODOs|Project 2]]

### By Source Location
- [[Project-1/Planning/Main-Plan|Project 1 Planning]]
- [[Project-2/Analysis/Analysis-Plan|Project 2 Analysis]]
```

**Project-Specific TODO:**

```markdown
---
type: todo
project: project-1
status: in-progress
tags: [project-1, todo]
priority: high
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Project 1 - TODOs

**Source:** [[Project-1/Planning/Main-Plan|Main Planning Doc]]

## Active TODOs

### Category 1
- [ ] Task 1 #priority/high #due/YYYY-MM-DD
- [ ] Task 2 #priority/medium

## Completed
- [x] Task 3 - Completed YYYY-MM-DD

## Related Notes
- [[Project-1/Planning/Main-Plan|Planning]]
- [[Project-1/Analysis/Analysis-Plan|Analysis]]

---

**Link back to:** [[TODOs/Master-TODO-Index|Master Index]]
```

## Pattern 5: Archive Strategy

**Per-Project Archives:**

```
Project/
├── Planning/
├── Development/
├── Sessions/          # Active sessions
└── Archives/
    └── Brain-Dump/    # Old unstructured notes
        ├── YYYY-MM-DD.md
        └── Summary.md
```

**Archive Rules:**
1. **No links FROM current work TO archived notes**
   - Archives are historical reference only
   - Don't create dependencies on old notes

2. **Archive after 30 days** for session notes

3. **Create archive summaries** before archiving
   - Extract key decisions
   - Link to where information moved
   - Summary stays accessible

4. **Monthly archive folders** for high-volume projects:
   ```
   Archives/
   ├── 2026-01/
   ├── 2026-02/
   └── README.md  # Explains what's archived and why
   ```

## Pattern 6: Cross-Project Linking

**When projects share work:**

```markdown
# In Project A notes:

## Related Work in Project B
- [[Project-B/Planning/Shared-Analysis|Shared Analysis]] - Detailed statistical work
- [[Project-B/Development/YYYY-MM-DD_implementation|Implementation]] - How it was built

## See Also
- [[Project-B/Project-B-MOC|Project B MOC]] - Full context
```

```markdown
# In Project B notes:

## Related Requirements from Project A
- [[Project-A/Planning/Requirements|Requirements]] - What needs to be analyzed
- [[Project-A/Data/Dataset|Dataset]] - Source data

## Cross-Project Context
The Project A work provides requirements, Project B implements the analysis.
```

**Benefits:**
- Clear relationship documentation
- Bidirectional navigation
- Context preserved in both locations

## Pattern 7: Topic-Based Folders Within Projects

**Structure:**

```
Project/
├── Tools/            # Topic: Tool development
│   ├── Tool-1.md
│   └── Tool-2.md
├── Planning/         # Topic: Planning docs
│   └── Main-Plan.md
├── Analysis/         # Topic: Analysis work
│   └── Analysis-Plan.md
├── Figures/          # Topic: Visualizations
│   └── Figure-1.md
└── Archives/         # Topic: Historical
    └── Old-Sessions/
```

**Benefits:**
- Clear topic separation
- Easy to navigate
- Logical grouping
- 2-3 levels deep maximum

## Implementation Checklist

When setting up a new vault or reorganizing:

**Immediate (High Impact):**
- [ ] Create `Home.md` central navigation hub
- [ ] Add properties to all existing notes
- [ ] Convert READMEs to MOCs with properties

**Short-term (This Week):**
- [ ] Implement consistent tagging strategy
- [ ] Create weekly review template
- [ ] Set up TODO consolidation structure

**Long-term (As Needed):**
- [ ] Consider flattening deep folders
- [ ] Set up Dataview queries (if using plugin)
- [ ] Implement monthly archive rotation
