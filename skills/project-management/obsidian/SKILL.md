---
name: obsidian
description: Integration with Obsidian vault for managing notes, tasks, and knowledge when working with Claude. Supports adding notes, creating tasks, and organizing project documentation. Updated with 2025-2026 best practices including MOCs, properties, and practical organization patterns.
version: 2.0.3
updated: 2026-02-17
---

# Obsidian Integration

Expert guidance for integrating Claude workflows with Obsidian vault, including note creation, task management, and knowledge organization using Obsidian's markdown-based system.

## When to Use This Skill

- Creating notes during development sessions with Claude
- Tracking tasks and TODOs in Obsidian
- Documenting decisions and solutions discovered with Claude
- Building a knowledge base of project insights
- Organizing research findings from Claude sessions
- Creating meeting notes or session summaries

## Core Principles

1. **Vault Location** - Use `$OBSIDIAN_VAULT` environment variable for vault path
2. **Always Ask User for Note Placement** - Never decide where to save notes without asking the user first. Show vault structure, suggest options, and let the user choose.
3. **Atomic Notes** - Each note focuses on a single concept or topic
4. **Linking** - Use wikilinks `[[note-name]]` to connect related ideas
5. **Tags** - Organize with hierarchical tags like `#project/feature`
6. **Tasks** - Use checkbox syntax for actionable items
7. **Timestamps** - Include dates for temporal context

## Obsidian Best Practices (2025-2026)

Based on current best practices from the Obsidian community:

### 1. Start Simple, Don't Overthink

**Key Principle**: Write first, organize later (or never)

- Focus on creating notes, not perfecting the system
- Let your vault structure evolve naturally as you add content
- Don't spend hours planning the "perfect" organization
- Begin with a few notes and gradually explore advanced features

**Avoiding Productive Procrastination**:
- ❌ **Don't**: Spend all your time tweaking the system and calling it work
- ❌ **Don't**: Endlessly optimize tags, folders, and organization
- ✅ **Do**: Spend 80% time writing/working, 20% organizing
- ✅ **Do**: Organize during weekly reviews, not constantly

### 2. Use MOCs (Maps of Content) Over Deep Folders

**What is a MOC?**
- A "Map of Content" is a note that primarily links to other notes
- Acts as an index or table of contents for a topic
- Provides flexible, many-to-many relationships (unlike folders)

**Why MOCs > Folders:**
- Notes can belong to multiple topics, but only one folder
- MOCs allow one note to appear in many different "maps"
- Easier to reorganize - just update links, no file moving
- More aligned with how knowledge actually connects

**MOC Best Practices:**
- Keep MOCs under 25 items for easy navigation
- Think of MOCs as high-level overviews, not comprehensive indexes
- Create sub-MOCs when a section gets too large
- Use consistent hierarchy - all links at the same conceptual level
- Include emoji icons for visual scanning

**When to Create a MOC:**
- "Mental Squeeze Point" - when you feel overwhelmed by many related notes
- When you have 5+ notes on a related topic
- When starting a new project
- When you need a navigation hub

**MOC vs README:**
- MOCs are Obsidian-native with properties and wikilinks
- READMEs are more markdown-standard but less integrated
- Prefer MOCs for better Obsidian features (graph view, backlinks)

### 3. Leverage Properties (Metadata)

**Why Properties > Folders:**
- Searchable: Find all `type: planning` notes across entire vault
- Flexible: One note can have multiple property values
- Dataview-compatible: Auto-generate lists with queries
- More powerful than folder-only organization

**Recommended Property Schema:**

```yaml
---
type: planning | reference | todo | moc | development | session | analysis
project: project-name
subproject: sub-project-name
status: active | in-progress | completed | archived | blocked
tags:
  - topic1
  - topic2
  - topic3
priority: critical | high | medium | low
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

**Property Usage:**
- Add to ALL new notes for consistency
- Use `type` to categorize by note function, not topic
- Use `project` to group across folders
- Use `status` to track progress
- Use `tags` for topic categorization
- Keep property names consistent across vault
- **Always add `dump` tag to session/daily notes** - Makes them easy to filter and archive

#### Critical: Dump Tag Requirement

**ALWAYS include the `dump` tag in session/daily notes.** This tag is essential for:
- Filtering all session notes across projects: `tag:#dump`
- Archiving workflows with `/consolidate-notes`
- Separating working notes from permanent documentation

**Note:** Session notes should be stored in `session-saves/` directory. See the **folder-organization** skill for project structure standards.

**When creating session notes in commands:**

Python template for new files (with frontmatter):
```python
# Create new note with frontmatter
f.write("---\n")
f.write("type: session\n")
f.write(f"project: {PROJECT_NAME}\n")
f.write(f"date: {date_str}\n")
f.write("tags:\n")
f.write("  - session\n")
f.write("  - dump\n")  # REQUIRED
f.write("status: completed\n")
f.write("---\n\n")
```

When appending to existing files:
- Only append content (frontmatter already exists)
- No need to add dump tag again

**Enforcement:**
- All commands that create session notes (`/safe-exit`, `/safe-clear`) automatically include dump tag
- Skill examples show dump tag in all session note templates

### 4. Actually USE Your Notes

**Biggest Challenge**: Taking notes and never reviewing them

**Review Systems:**
- Schedule weekly reviews to revisit notes
- Clean up and reorganize as you use notes
- Re-arrange information, add links, update text
- Link new discoveries to existing notes
- Archive or delete obsolete notes

**Active Note Management:**
- Read old notes when starting related work
- Update notes with new insights
- Link backwards from new notes to old ones
- Build on previous knowledge

**Make Notes Actionable:**
- Add TODOs and next steps
- Link to relevant code or files
- Include "See Also" sections
- Create clear "Quick Actions" lists

### 5. Organize by Note Type, Not Topic

**Traditional (Topic-based):**
```
vault/
├── Machine-Learning/
│   ├── session-notes.md
│   ├── research.md
│   └── todos.md
└── Web-Development/
    ├── session-notes.md
    └── research.md
```

**Better (Type-based + Properties):**
```
vault/
├── Sessions/  (all session notes, tagged by project)
├── Planning/  (all planning docs, tagged by project)
├── TODOs/     (all task tracking)
└── Reference/ (all reference material)
```

Then use properties and tags to group by topic:
- `project: machine-learning`
- `tags: [ml, neural-networks]`

**Benefits:**
- Consistent organization regardless of topic
- Easy to find all notes of a certain type
- Properties handle topic categorization
- Simpler folder structure

### 6. Create a Home/Index MOC

**Central Navigation Hub:**
- Single starting point for entire vault
- Links to all project MOCs
- Quick access to TODOs and recent notes
- Project status overview
- Pin in Obsidian for easy access

**Home MOC Structure:**
```markdown
# 🏠 Home

## 🎯 Active Projects
- [[Project-1-MOC]] - Description
- [[Project-2-MOC]] - Description

## 📋 Quick Access
- [[TODOs/Master-Index]]
- [[Sessions/Latest]]

## 📚 Knowledge by Topic
- [[Topic-1-MOC]]
- [[Topic-2-MOC]]

## 🗂️ By Note Type
- Planning notes
- Development sessions
- Reference docs
```

### 7. Link Profusely, Folder Minimally

**Linking Strategy:**
- Create links as you write
- Link to related concepts immediately
- Use bidirectional links when relevant
- Build a knowledge graph through connections

**Folder Strategy:**
- Keep folder structure flat (2-3 levels max)
- Use folders for note TYPE, not topic
- Rely on links and properties for organization
- Orient toward speed and ease of navigation

## Vault Configuration

### Environment Setup

The Obsidian vault location is stored in the `$OBSIDIAN_VAULT` environment variable:

```bash
# Check vault location
echo $OBSIDIAN_VAULT

# Should return something like:
# /Users/username/Documents/Notes
```

If not set, you'll need to configure it in your shell profile:

```bash
# Add to ~/.zshrc or ~/.bashrc
export OBSIDIAN_VAULT="/path/to/your/vault"
```

## Project Organization in Vault

### Selecting Project Directory Location

When creating a new project's notes in Obsidian, ask the user where the project directory should be located within the vault:

**Workflow:**

1. **Show current vault structure** to help user decide
2. **Offer two options:**
   - **Option 1:** Root level - Project directory directly in vault root
   - **Option 2:** Custom path - User specifies subdirectory structure

3. **Create directory if it doesn't exist**

### Implementation Pattern

```python
import os
from pathlib import Path

# Get vault path
vault_path = Path(os.environ.get('OBSIDIAN_VAULT'))

# Show vault structure to user
print("📁 Current vault structure:")
print(f"   {vault_path}/")

# Show top-level directories (up to 2 levels)
for item in sorted(vault_path.iterdir()):
    if item.is_dir() and not item.name.startswith('.'):
        print(f"   ├── {item.name}/")
        # Show one level deeper
        for subitem in sorted(item.iterdir())[:3]:
            if subitem.is_dir() and not subitem.name.startswith('.'):
                print(f"   │   ├── {subitem.name}/")
        # Indicate if there are more
        remaining = len([x for x in item.iterdir() if x.is_dir()]) - 3
        if remaining > 0:
            print(f"   │   └── ... ({remaining} more)")

print()
print("Where should this project's notes be stored?")
print()
print("Options:")
print("  1. Root level (vault/project-name/)")
print("  2. Custom path (e.g., vault/Work/project-name/ or vault/Projects/Active/project-name/)")
print()

choice = input("Enter choice [1-2]: ")

if choice == "1":
    # Root level
    project_dir = vault_path / project_name
else:
    # Custom path
    print()
    print("Enter the parent directory path (relative to vault root).")
    print("Examples:")
    print("  - Work")
    print("  - Projects/Active")
    print("  - Personal/Research")
    print()
    parent_path = input("Parent directory: ").strip()

    # Clean and validate path
    parent_path = parent_path.strip('/')
    project_dir = vault_path / parent_path / project_name

# Create directory if it doesn't exist
project_dir.mkdir(parents=True, exist_ok=True)
print(f"✅ Project directory: {project_dir.relative_to(vault_path)}")
```

### Best Practices for Organization

**Root Level:**
- ✅ Quick access to frequently used projects
- ✅ Simple structure for small vaults
- ❌ Can become cluttered with many projects

**Organized Subdirectories:**
- ✅ Better organization for many projects
- ✅ Logical grouping (Work, Personal, Research, etc.)
- ✅ Easier to navigate in large vaults
- ✅ Better for team vaults with shared structure

**Recommended Structures:**

```
vault/
├── Work/
│   ├── project-a/
│   ├── project-b/
│   └── project-c/
├── Personal/
│   ├── hobby-project/
│   └── research/
├── Archive/
│   └── old-project/
└── Templates/
```

Or by status:

```
vault/
├── Active/
│   ├── project-a/
│   └── project-b/
├── Planning/
│   └── project-c/
├── Completed/
│   └── old-project/
└── Archive/
```

### Directory Creation Safety

**Always check before creating:**
```python
if project_dir.exists():
    print(f"⚠️  Directory already exists: {project_dir}")
    overwrite = input("Continue using this directory? (y/n): ")
    if overwrite.lower() != 'y':
        # Ask for different name or path
        return
else:
    # Create with parents
    project_dir.mkdir(parents=True, exist_ok=True)
    print(f"✅ Created directory: {project_dir}")
```

### Storing Project Configuration

Save the project directory path for future sessions:

```python
# In .claude/project-config
config_content = f"""obsidian_project={project_name}
obsidian_path={project_dir.relative_to(vault_path)}
"""

with open('.claude/project-config', 'w') as f:
    f.write(config_content)
```

This allows subsequent sessions to use the same directory without asking again.

## User Choice: Never Assume Note Placement

**CRITICAL PRINCIPLE**: When creating ANY note in Obsidian, ALWAYS ask the user where they want it saved. Never decide the location yourself, even if it seems obvious.

### Why This Matters

1. **User has context you don't** - They know how their vault is organized
2. **Flexibility is key** - Different notes may belong in different places
3. **Avoids reorganization work** - User won't need to move notes later
4. **Respects user's system** - Their vault organization is personal

### The Workflow for ANY Note Creation

**Step 1: Show Current Structure**
```python
# Display vault structure to help user decide
vault_path = Path(os.environ.get('OBSIDIAN_VAULT'))
print("📁 Current vault structure:")
print(f"   {vault_path.name}/")

for item in sorted(vault_path.iterdir())[:10]:
    if item.is_dir() and not item.name.startswith('.'):
        print(f"   ├── {item.name}/")
```

**Step 2: Suggest Options (Don't Decide)**
```python
print("\nWhere would you like to save this note?")
print()
print("Suggestions:")
print("  1. Root level - Notes/note-name.md")
print("  2. [Specific folder] - Notes/Folder/note-name.md")
print("  3. Custom path - You specify")
print()
```

**Step 3: Get User Input**
```python
choice = input("Enter choice or custom path: ").strip()
```

**Step 4: Create in Chosen Location**
```python
# Use their choice, don't override it
if choice == "1":
    note_path = vault_path / "note-name.md"
elif choice == "2":
    note_path = vault_path / "Folder" / "note-name.md"
else:
    # Custom path
    note_path = vault_path / choice / "note-name.md"

# Create directory if needed
note_path.parent.mkdir(parents=True, exist_ok=True)
```

### Examples of When to Ask

❌ **WRONG - Assuming location:**
```python
# Creating documentation note
note_path = vault_path / "Guides" / "How-to.md"  # DON'T DO THIS
```

✅ **RIGHT - Asking user:**
```python
# Show structure and suggest
print("Where should this documentation note be saved?")
print("Suggestions:")
print("  1. Root level (simple)")
print("  2. New 'Guides' folder (for documentation)")
print("  3. Existing 'Work' folder")
print("  4. Custom path")

choice = input("Your choice: ")
# Then create based on their input
```

### Exception: Project Session Notes

The ONLY exception is when using `/safe-exit` for project session notes:
- Configuration already exists in `.claude/project-config`
- User has previously chosen the project location
- All session notes for that project go to the same place

Even then, on FIRST use, always ask and save the choice.

### Summary

**Golden Rule**: If you're about to write a file to the Obsidian vault, STOP and ask the user where it should go first.

### Successful Pattern Example

**Session**: Creating figure analysis TODO note

**Implementation**:
```bash
# 1. Check vault location
echo $OBSIDIAN_VAULT

# 2. Show structure
ls -1 $OBSIDIAN_VAULT/

# 3. Ask user
"Where would you like me to save the TODO note for figure analysis tasks?

**Options:**
1. curation-paper-figures/ - With your other project notes (recommended)
2. curation-paper-figures/sessions-history/ - With session history
3. Root level - Directly in Notes/
4. Custom path - You specify

Which would you prefer?"

# 4. User response: "1"

# 5. Create in chosen location
cat > "$OBSIDIAN_VAULT/curation-paper-figures/Figure_Analysis_TODOs.md" <<'EOF'
[content]
EOF
```

**Result**: Note created in user's preferred location without assumptions or reorganization needed later.

**Key Principle**: Even when one location seems "obvious", always ask. The user knows their organizational system better than you do.

## Vault Reorganization Workflow

When reorganizing a large Obsidian vault structure, follow this systematic approach:

### Planning Phase

1. **Document target structure** in a prompt file
   - Define folder hierarchy
   - Specify naming conventions (e.g., `session-saves/` vs `sessions-history/`)
   - Note standard project structure (TO-DOS.md, session-saves/, archived/daily/, archived/monthly/)

2. **Create todo list** to track progress
   - Break down by major operations: create folders, move files, update links
   - Track completion systematically

### Execution Phase

Execute in this order to minimize broken links:

1. **Create new folder structure first**
   ```bash
   mkdir -p Work/Brain-dump Work/Global-skills Work/Galaxy Work/VGP
   ```

2. **Move files and folders**
   - Move complete directories with `mv source/ destination/`
   - Check for hidden files (.DS_Store) that might prevent rmdir
   - Use `rmdir` (not `rm -rf`) to safely remove directories - fails if not empty

3. **Standardize project folders**
   - Rename `sessions-history/` → `session-saves/` for consistency
   - Create `archived/daily/` and `archived/monthly/` subdirectories
   - Move or create `TO-DOS.md` files from centralized TODO location

4. **Update HOME.md and MOC files**
   - Update links in navigation files systematically
   - Work through one file at a time
   - Use Edit tool with exact string matching

5. **Clean up**
   - Remove old empty folders
   - Remove or relocate orphaned files
   - Verify structure with `tree` or `find` commands

### Link Update Strategy

When updating internal links across many files:

1. **Find all affected files first**
   ```bash
   grep -r "pattern" vault/ --include="*.md"
   ```

2. **Read each file before editing** (Edit tool requirement)

3. **Update systematically** - one file at a time, completing each fully

4. **Remove links to deleted files** (like central Home.md)

### Common Patterns

**Standard project structure:**
```
project-name/
├── TO-DOS.md
├── session-saves/
├── archived/
│   ├── daily/
│   └── monthly/
└── [project-specific folders]
```

**Hierarchical organization:**
```
Work/
├── Category-1/
│   ├── HOME.md
│   ├── TO-DOS.md
│   └── project-a/
└── Category-2/
    ├── HOME.md
    └── project-b/
```

### Verification

After reorganization:
- Use `tree -L 3 -d` to verify structure
- Check that links work in Obsidian
- Verify no broken links to removed files
- Test navigation between HOME.md files

### Bulk Link Updates After Reorganization

When updating many links after vault reorganization:

1. **Find affected files:**
   ```bash
   grep -r "\[\[OldPath" vault/ --include="*.md"
   ```

2. **Update systematically:**
   - Read file first (Edit tool requirement)
   - Update all links in that file together
   - Complete one file before moving to next
   - Mark as done in todo list

3. **Pattern for updating:**
   ```markdown
   # Old
   [[OldFolder/file|Display]]

   # New
   [[Work/Category/OldFolder/file|Display]]
   ```

4. **Removing obsolete links:**
   - Find: `[[ObsoleteFile|...]]` or `[[ObsoleteFile]]`
   - Remove entire link reference
   - Clean up surrounding formatting

### Home.md File Management

When reorganizing to hierarchical structure with section-level HOME.md files:

**Pattern: Replace Central Home with Section Homes**

**Before (centralized):**
```
vault/
├── Home.md (central hub linking to everything)
├── Project-1/
├── Project-2/
└── Project-3/
```

**After (hierarchical):**
```
vault/
├── Work/
│   ├── Category-1/
│   │   ├── HOME.md (section hub)
│   │   └── project-1/
│   └── Category-2/
│       ├── HOME.md (section hub)
│       └── project-2/
└── Perso/
    ├── HOME.md (section hub)
    └── project-3/
```

**Steps to transition:**

1. **Create section HOME.md files FIRST**
   - One per major category (Work/Category-1/, Work/Category-2/, Perso/, etc.)
   - Each contains links to projects in that section
   - Include navigation between sections

2. **Find all references to central Home:**
   ```bash
   grep -r "\[\[Home" vault/ --include="*.md"
   ```

3. **Update or remove links systematically:**
   - MOC files: Update to link to appropriate section HOME
   - Section HOME files: Link to sibling sections, not central Home
   - Project notes: Remove Home links (navigate via section HOME instead)

4. **Delete central Home.md LAST:**
   - Only after all links updated or removed
   - Verify no broken references remain

**Section HOME.md template:**
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

**Benefits of section HOME files:**
- Logical organization by category
- Each section is self-contained
- No single central file to maintain
- Better for hierarchical vault structures
- Clearer navigation paths

### HOME.md Naming Convention

**Pattern:** Use `[section-name]_HOME.md` instead of generic `HOME.md`

**Benefits:**
- Avoid conflicts when multiple HOME files in working directory
- Clear identification in file browsers
- Better for search and navigation
- Consistent naming pattern

**Examples:**
```
Work/Galaxy/Galaxy_HOME.md
Work/VGP/VGP_HOME.md
Work/Global-skills/Global-skills_HOME.md
Perso/Perso_HOME.md
```

**Renaming Process:**

1. **Rename files:**
```bash
mv Work/Galaxy/HOME.md Work/Galaxy/Galaxy_HOME.md
mv Work/VGP/HOME.md Work/VGP/VGP_HOME.md
# etc.
```

2. **Update references:**
```bash
# Find all links to old names
grep -r "\[\[.*HOME\|" vault/ --include="*.md"

# Update links systematically
# Old: [[Work/Galaxy/HOME|Galaxy Work]]
# New: [[Work/Galaxy/Galaxy_HOME|Galaxy Work]]
```

3. **Verify with link detection script** (see Link Management section)

**When to use generic `HOME.md`:**
- Single section vault (no subsections)
- Root-level home only
- No naming conflicts

**When to use `[name]_HOME.md`:**
- Multiple section HOME files (recommended)
- Hierarchical vault structure
- Working across multiple projects simultaneously
- Want clear file identification

### Brain Dump Folder Handling

When reorganizing vault with brain dump or temporary scratch folders:

**Purpose:** Brain dump folders contain unstructured working notes that need to be:
1. Reviewed for valuable content
2. Moved to appropriate permanent locations
3. Archived or deleted if obsolete

**Typical locations:**
```
Project/Archives/Brain-Dump/
Project/Brain-dump/
Work/Brain-dump/
```

**Workflow:**

1. **Review content first:**
   ```bash
   ls -lh Project/Archives/Brain-Dump/
   # Check file sizes and dates
   # Read summaries or key files
   ```

2. **Categorize notes:**
   - **Permanent value:** Move to appropriate thematic location
   - **Session notes:** Consolidate and archive
   - **Obsolete/duplicates:** Delete

3. **Move valuable content:**
   ```bash
   # Example: Move Galaxy workflow notes to appropriate project
   mv Work/Brain-dump/VGP-Workflow-Notes.md Work/Galaxy/
   ```

4. **Handle consolidated summaries:**
   - Summary.md files often contain cross-project information
   - Move to most relevant project or split by topic
   - Update links when moving

5. **Archive or delete folder:**
   ```bash
   # If brain dump should be archived
   mv Project/Brain-dump/ Project/Archives/Brain-Dump/

   # If content all processed and obsolete
   rmdir Project/Brain-dump/  # Safe - fails if not empty
   ```

**Anti-pattern:** Don't just move entire brain dump folder without review
- Results in unorganized archived content
- Valuable insights get buried
- Better to extract and organize first

**Best practice:**
- Process brain dump content during vault reorganization
- Extract summaries into thematic notes
- Archive individual sessions if needed
- Only keep brain dump folder if actively using it for scratch work

## Session Note Consolidation Workflow

When consolidating daily session notes into thematic reference notes and project TODOs:

### Purpose

Convert chronological session history into organized knowledge by:
- Creating thematic reference notes grouped by topic (not date)
- Extracting actionable tasks into project TO-DOS.md files
- Archiving processed session notes to archived/daily/
- Preserving knowledge while reducing noise

### When to Consolidate

**Triggers:**
- End of project phase or milestone
- Session folder has 5+ notes
- Starting new work and need clean context
- Monthly vault maintenance
- Before sharing project with others

### Planning Phase

1. **Review all session notes** in project's session-saves/ folder
2. **Identify major themes** - What topics were worked on?
   - Example: "Data Collection", "Statistical Analysis", "Figure Generation"
3. **Create consolidation plan:**
   - List thematic notes to create
   - Identify which sessions contribute to each theme
   - Note any TODOs to extract

### Execution Steps

Execute in this order:

**1. Create Thematic Reference Notes**

Group content by topic, not chronology:

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

**2. Extract TODOs to Project TO-DOS.md**

Create or update project TO-DOS.md with extracted tasks:

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

**3. Archive Session Notes**

Move processed sessions to archived/daily/:

```bash
# Move all processed session notes
mv project/session-saves/*.md project/archived/daily/

# Or move selectively
mv project/session-saves/2026-02-*.md project/archived/daily/
```

**4. Verify Completeness**

Check that:
- All important content captured in thematic notes
- All actionable tasks extracted to TO-DOS.md
- Session notes successfully archived
- Thematic notes are well-organized and navigable

### Content Organization Strategy

**Organize by topic, NOT chronology:**

❌ **Wrong - Chronological:**
```markdown
# Session Consolidation

## January Work
- Did X on 2026-01-15
- Did Y on 2026-01-20

## February Work
- Did Z on 2026-02-01
```

✅ **Right - Thematic:**
```markdown
# Data Collection and Enrichment

## Phase 1: Telomere Classification (2026-01-24)
[All telomere work grouped together]

## Phase 2: Additional Metrics (2026-01-27)
[All metrics work grouped together]
```

### Example Consolidation

**Before (9 session notes):**
```
session-saves/
├── 2026-01-27.md - Statistical tests
├── 2026-01-30.md - Figure generation
├── 2026-02-04.md - MANIFEST system
├── 2026-02-05.md - More figures
├── 2026-02-06.md - Data corrections
├── 2026-02-10.md - Analysis files
├── 2026-02-12.md - Notebook work
├── 2026-02-15.md - Figure refinements
├── 2026-02-16.md - Quality checks
```

**After (5 thematic notes + 1 TODO):**
```
Data-Collection-and-Enrichment.md
Statistical-Analysis-Results.md
Data-Quality-and-Corrections.md
Figure-Generation.md
Infrastructure-and-Workflows.md
TO-DOS.md

archived/daily/
├── 2026-01-27.md
├── 2026-01-30.md
├── [... all 9 sessions archived]
```

### Thematic Note Examples

**Good thematic groupings:**
- "Data Collection and Enrichment" (not "January Data Work")
- "Statistical Analysis Results" (not "Analysis Sessions")
- "Figure Generation" (not "Visualization Work Log")
- "Infrastructure and Workflows" (not "Tool Development Notes")
- "Data Quality and Corrections" (not "Bug Fixes")

### Content to Include

**In Thematic Notes:**
- Key decisions and rationale
- Implementation details
- Results and findings
- Lessons learned
- File locations and code references
- Related notes and cross-references
- Timeline note: "Consolidated from sessions: [dates]"

**In TO-DOS.md:**
- Actionable next steps
- Blocked items with blockers noted
- Completed tasks (in archive section)
- Phase organization
- Related note links

**NOT to include:**
- Minute-by-minute session details
- Debugging steps (unless they teach something)
- Temporary working notes
- Redundant context

### File Naming

**Thematic notes - descriptive, timeless:**
- `Data-Collection-and-Enrichment.md`
- `Statistical-Analysis-Results.md`
- `Figure-Generation-Workflow.md`
- `Infrastructure-and-Tools.md`

**NOT date-based:**
- ❌ `2026-01-Session-Summary.md`
- ❌ `January-Work-Consolidated.md`
- ❌ `Week-3-Notes.md`

### Verification Checklist

After consolidation:
- [ ] All thematic notes have proper frontmatter with type: reference
- [ ] Each thematic note focuses on ONE topic area
- [ ] TO-DOS.md exists with extracted tasks
- [ ] All session notes moved to archived/daily/
- [ ] Thematic notes are navigable (good headers, sections)
- [ ] Related notes are cross-linked
- [ ] Timeline documented ("Consolidated from sessions: ...")
- [ ] No critical information lost

### Integration with Other Workflows

**After consolidation:**
1. Update project HOME.md to link to new thematic notes
2. Update project MOC if it exists
3. Link thematic notes to each other where relevant
4. Consider updating skills if new patterns discovered

**Before project sharing:**
- Consolidate sessions first
- Share thematic notes, not session history
- Include TO-DOS.md for active projects
- Archive folder can be excluded for cleaner sharing

## Link Management and Verification

After major vault reorganization, verify and fix all internal wikilinks systematically.

### Automated Broken Link Detection

Use Python script to scan entire vault for broken wikilinks:

```python
import re
from pathlib import Path

vault_root = Path("/path/to/vault")
broken_links = []
wikilink_pattern = r'\[\[([^\]|]+)(?:\|[^\]]+)?\]\]'

for md_file in vault_root.glob("**/*.md"):
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()

    matches = re.findall(wikilink_pattern, content)

    for link in matches:
        link = link.strip()

        # Skip heading-only references
        if '#' in link:
            link = link.split('#')[0].strip()
            if not link:
                continue

        # Try vault-root path, then relative path
        target = vault_root / f"{link}.md"
        if not target.exists():
            target = md_file.parent / f"{link}.md"

        if not target.exists():
            broken_links.append({
                'file': str(md_file.relative_to(vault_root)),
                'link': link
            })

# Report grouped by file
current_file = None
for item in broken_links:
    if item['file'] != current_file:
        current_file = item['file']
        print(f"\n{current_file}:")
    print(f"  - [[{item['link']}]]")
```

### Systematic Fix Workflow

**1. Categorize by Section**
- Group broken links by vault area (Work/, Perso/, etc.)
- Track progress with TodoWrite tool
- Fix one section at a time to completion

**2. Common Link Issues After Reorganization**

| Issue | Example | Fix |
|-------|---------|-----|
| Folder moved | `[[Galaxy/VGP/file]]` | `[[Work/Galaxy/file]]` |
| File renamed | `[[HOME]]` | `[[Project_HOME]]` |
| Folder link with slash | `[[session-saves/]]` | Remove link (no file) |
| Relative vs absolute | `[[curation-paper-figures/file]]` | `[[Work/VGP/curation-paper-figures/file]]` |
| Consolidated sessions | `[[2026-01-27_session]]` | `[[Thematic-Note]]` |
| Centralized removed | `[[TODOs/Master-TODO]]` | `[[Work/Project/TO-DOS]]` |

**3. Link Update Patterns**

**Old path structure → New structure:**
```markdown
# Before reorganization
[[TODOs/Project-TODOs]]
[[Galaxy/VGP/Planning/Hand-Notes]]
[[session-saves/2026-02-13]]

# After reorganization
[[Work/Project/TO-DOS]]
[[Work/VGP/curation-paper-figures/Thematic-Note]]
[[Work/Galaxy/iwc/archived/daily/2026-02-13]]
```

**Removing obsolete links:**
- Development session links → Thematic reference notes
- Folder references (with trailing /) → Remove or link to index
- Non-existent TODO indexes → Individual project TO-DOS

**4. Verification After Fixes**

Run detection script again to verify:
```bash
# Should output
✅ SUCCESS! No broken links found. All links have been fixed.
```

### Best Practices

**DO:**
- Run detection script BEFORE starting fixes (baseline count)
- Fix systematically by section (complete one area before next)
- Track progress with todos (prevents losing place in large fix)
- Re-run detection after each section (catch any issues early)
- Use full paths from vault root for consistency

**DON'T:**
- Try to fix all 70+ links at once (overwhelming, error-prone)
- Skip verification between sections (compounding errors)
- Guess at link targets (always verify file exists)
- Leave folder references with trailing slashes

### Token Efficiency

**Broken link detection:** ~100 tokens per run
**Manual link checking:** 500-1000 tokens per file (Read + verify)

**Impact:** For vault with 74 broken links across 15 files:
- Detection script: 100 tokens
- Manual checking would be: 7,500-15,000 tokens
- **Savings: 98-99% token reduction**

### Common Scenarios

**After session consolidation:**
- Old: `[[sessions-history/2026-02-16]]`
- New: `[[Thematic-Note]]` (content now in thematic reference)

**After folder reorganization:**
- Old: `[[Galaxy/VGP/Data/file]]`
- New: `[[Work/VGP/curation-paper-figures/Data-Collection-Note]]`

**After HOME.md rename:**
- Old: `[[Work/Galaxy/HOME|Galaxy]]`
- New: `[[Work/Galaxy/Galaxy_HOME|Galaxy]]`

### Integration with Other Workflows

**Run link verification after:**
- Major vault reorganization
- Session note consolidation
- File/folder renaming
- Creating new section HOME.md files
- Deleting obsolete folders

**Before:**
- Sharing project (no broken links in shared package)
- Major writing session (clean navigation)
- Project handoff

## Obsidian Markdown Syntax

### Wikilinks (Internal Links)

```markdown
# Link to another note
[[Note Name]]

# Link with custom display text
[[Note Name|Display Text]]

# Link to heading in another note
[[Note Name#Heading]]

# Link to block
[[Note Name#^block-id]]
```

### Tags

```markdown
# Simple tags
#tag

# Hierarchical tags
#project/feature
#status/in-progress
#type/note
#type/task

# Tags in YAML frontmatter
---
tags:
  - project/feature
  - status/active
---
```

### Tasks

```markdown
# Basic task
- [ ] Task to do

# Completed task
- [x] Completed task

# Task with priority
- [ ] High priority task ⚠️
- [ ] Medium priority task 🔸
- [ ] Low priority task 🔹

# Task with date (if using Obsidian Tasks plugin)
- [ ] Task 📅 2026-01-23
- [ ] Task ⏳ 2026-01-30
- [ ] Task ✅ 2026-01-20

# Task with metadata
- [ ] Implement feature #coding #high-priority @claude-session
```

### Callouts (Obsidian-specific)

```markdown
> [!note]
> This is a note callout

> [!tip]
> Helpful tip here

> [!warning]
> Important warning

> [!todo]
> Task to complete

> [!example]
> Example code or content

> [!quote]
> Quote or citation
```

## Note Templates

### Session Note Template

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

### Technical Note Template

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

### Task Note Template

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

### Analysis Planning Note Template

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

## Practical Organization Patterns (From Real Sessions)

### Pattern 1: Home MOC as Central Hub

**Implementation Example**:

```markdown
---
type: moc
title: Home
tags: [index, home]
created: YYYY-MM-DD
---

# 🏠 Home

**Last Updated:** YYYY-MM-DD

## 🎯 Active Projects

### Project 1
**Status:** In Progress | **Priority:** High

- [[Project-1/Planning/Main-Plan|Planning Document]]
- [[Project-1/Analysis/Analysis-Plan|Analysis Plan]]

### Project 2
**Status:** Active | **Priority:** Medium

- [[Project-2/Development/Latest-Session|Latest Work]]

## 📋 Quick Access

### TODOs & Planning
- [[TODOs/Master-TODO-Index|📋 All TODOs]]
- [[TODOs/Project-1-TODOs|Project 1 Tasks]]

### Recent Sessions
- [[Project-1/Sessions/YYYY-MM-DD|Today]]
- [[Project-1/Sessions/YYYY-MM-DD|Yesterday]]

## 📚 Knowledge by Topic

### Topic Area 1
**Core Documents:**
- [[Path/To/Core-Doc-1|Core Document]]
- [[Path/To/Core-Doc-2|Secondary Document]]

**Related Work:**
- [[Path/To/Related-1|Related Item 1]]

## 🗂️ Browse by Note Type

### 📝 Planning & Strategy
- [[Path/To/Planning-1]]
- [[Path/To/Planning-2]]

### 💻 Development & Implementation
- [[Path/To/Dev-1]]

### 📚 Reference & Guides
- [[Path/To/Guide-1]]

### ✅ TODOs & Task Management
- [[TODOs/Master-TODO-Index]]

### 📦 Archives
- [[Archives/Old-Sessions/Summary]]

## 🔗 Cross-Project Connections

### Related Projects
- **Project A** ↔ **Project B** - Shared analysis work
- Links span multiple project folders

## 📊 Project Status Overview

| Project | Status | Priority | TODOs | Updated |
|---------|--------|----------|-------|---------|
| Project 1 | In Progress | High | [[TODOs/Project-1-TODOs|View]] | YYYY-MM-DD |
| Project 2 | Active | Medium | [[TODOs/Project-2-TODOs|View]] | YYYY-MM-DD |

## 🎯 Quick Actions

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

### Pattern 2: Project MOCs

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

# 🌌 Project Name MOC

*Map of Content for Project Name*

**Last Updated:** YYYY-MM-DD
**Status:** In Progress

---

## 📝 Planning & Strategy

### Core Planning Documents
- [[Project/Planning/Main-Plan|Main Plan]] - **CRITICAL**
  - Key decision 1
  - Key decision 2
  - Status: In progress

- [[Project/Planning/TODOs|Task List]] - **HIGH PRIORITY**
  - Active tasks
  - Blocked items

---

## 💻 Development

### Recent Work (Month YYYY)
- [[Project/Dev/YYYY-MM-DD_topic-1|Topic 1]] (Date 1)
- [[Project/Dev/YYYY-MM-DD_topic-2|Topic 2]] (Date 2)

### Current Sessions
- [[Project/Sessions/YYYY-MM-DD|Today]]
- [[Project/Sessions/YYYY-MM-DD|Yesterday]]

---

## 📋 TODOs & Tasks

- [[TODOs/Project-TODOs|Active Tasks]] - Extracted task list

### Key Tasks
- [ ] Task 1 - High priority
- [ ] Task 2 - Medium priority
- [x] Task 3 - Completed

---

## 🔗 Related Projects

- [[Other-Project/Other-Project-MOC|Other Project]] - Related work
- Cross-references and shared analysis

---

## 🎯 Quick Actions

**Common Tasks:**
- Review [[Project/Planning/Main-Plan|planning docs]]
- Check [[TODOs/Project-TODOs|active tasks]]
- Update [[Project/Status|status]]

**Weekly Review:**
- Archive completed sessions
- Update TODO status
- Link new notes to this MOC

---

[[Home|← Back to Home]]
```

**MOC Features:**
- Keep under 25 items per section
- Use sub-MOCs when sections get large
- Include status and priority
- Add "Quick Actions" for common workflows
- Link back to Home

### Pattern 3: Properties in Practice

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

### Pattern 4: TODO Consolidation

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

## 🧬 Project 1
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

### Pattern 5: Archive Strategy

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

### Pattern 6: Cross-Project Linking

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

### Pattern 7: Topic-Based Folders Within Projects

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

### Implementation Checklist

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

## Working with Claude: Common Patterns

### Pattern 1: Creating a Session Note

When starting a work session with Claude:

```bash
# Create new session note in Obsidian vault
cat > "$OBSIDIAN_VAULT/Sessions/$(date +%Y-%m-%d)-session.md" <<EOF
---
date: $(date +%Y-%m-%d)
type: session-note
tags:
  - claude-session
---

# Session: $(date +%Y-%m-%d)

## Context


## Summary


## Action Items
- [ ]

## Links

EOF
```

### Pattern 2: Adding Quick Notes

For quick insights during development:

```bash
# Append to daily note
echo "## $(date +%H:%M) - Quick Note

Content here

" >> "$OBSIDIAN_VAULT/Daily/$(date +%Y-%m-%d).md"
```

### Pattern 3: Creating Task from Claude Session

```bash
# Create task file
TASK_NAME="implement-feature-x"
cat > "$OBSIDIAN_VAULT/Tasks/$TASK_NAME.md" <<EOF
---
date: $(date +%Y-%m-%d)
type: task
tags:
  - task
  - status/pending
---

# Task: $TASK_NAME

## Description


## Checklist
- [ ]

## Created by
Claude session on $(date +%Y-%m-%d)
EOF
```

### Pattern 4: Documenting Code Solutions

```bash
# Create solution note
SOLUTION_NAME="fix-api-error"
cat > "$OBSIDIAN_VAULT/Solutions/$SOLUTION_NAME.md" <<EOF
---
date: $(date +%Y-%m-%d)
type: solution
tags:
  - solution
  - coding
---

# Solution: $SOLUTION_NAME

## Problem


## Solution


## Code
\`\`\`language
code here
\`\`\`

## Related
- [[Related Note]]
EOF
```

## Folder Organization for Claude Integration

Recommended folder structure within Obsidian vault:

```
$OBSIDIAN_VAULT/
├── Daily/                      # Daily notes
│   └── YYYY-MM-DD.md
├── Sessions/                   # Claude session notes
│   └── YYYY-MM-DD-topic.md
├── Tasks/                      # Task tracking
│   ├── active/
│   └── completed/
├── Projects/                   # Project documentation
│   └── project-name/
│       ├── index.md
│       ├── architecture.md
│       └── decisions.md
├── Solutions/                  # Code solutions and fixes
│   └── solution-name.md
├── Research/                   # Research notes
│   └── topic.md
├── Knowledge/                  # Permanent notes
│   └── concept.md
└── Templates/                  # Note templates
    ├── session.md
    ├── task.md
    └── solution.md
```

## Helper Functions for Obsidian Integration

### Bash Helper Functions

Add these to your shell profile for easy integration:

```bash
# Create new session note in Obsidian
obs-session() {
    local topic="${1:-general}"
    local date=$(date +%Y-%m-%d)
    local file="$OBSIDIAN_VAULT/Sessions/${date}-${topic}.md"

    cat > "$file" <<EOF
---
date: $date
type: session-note
tags:
  - claude-session
  - project/$topic
---

# Session: $topic - $date

## Context


## Summary


## Action Items
- [ ]

## Links

EOF

    echo "Created session note: $file"
}

# Create task in Obsidian
obs-task() {
    local task_name="$1"
    local date=$(date +%Y-%m-%d)
    local file="$OBSIDIAN_VAULT/Tasks/${task_name}.md"

    cat > "$file" <<EOF
---
date: $date
type: task
tags:
  - task
  - status/pending
---

# Task: $task_name

## Description


## Checklist
- [ ]

## Created
$date via Claude session
EOF

    echo "Created task: $file"
}

# Append to daily note
obs-note() {
    local date=$(date +%Y-%m-%d)
    local time=$(date +%H:%M)
    local daily_note="$OBSIDIAN_VAULT/Daily/${date}.md"

    # Create daily note if doesn't exist
    if [ ! -f "$daily_note" ]; then
        cat > "$daily_note" <<EOF
---
date: $date
type: daily-note
---

# $date

EOF
    fi

    # Append note
    cat >> "$daily_note" <<EOF

## $time


EOF

    echo "Added entry to daily note: $daily_note"
}

# Quick search in Obsidian vault
obs-search() {
    grep -r "$1" "$OBSIDIAN_VAULT" --include="*.md"
}
```

## Integration Workflow with Claude

### Before Session

1. **Set up environment**
   ```bash
   echo $OBSIDIAN_VAULT  # Verify vault location
   ```

2. **Create session note** (optional)
   ```bash
   obs-session "feature-implementation"
   ```

### During Session

1. **Add notes as you go**
   - Use Claude to create notes for important insights
   - Document decisions and reasoning
   - Track code locations with `file.py:line` references

2. **Create tasks for follow-ups**
   ```bash
   obs-task "refactor-authentication"
   ```

3. **Link to existing notes**
   - Reference related documentation
   - Build knowledge graph through links

### After Session

1. **Review and organize**
   - Add tags to notes
   - Create links between related notes
   - Update project index

2. **Update task status**
   - Mark completed tasks
   - Add new discovered tasks

3. **Archive session notes**
   - Move to appropriate project folder if needed
   - Link from project index

## Best Practices

### Note Creation

**DO:**
- ✅ **ALWAYS ask user where to save the note first** - Show vault structure and suggest options
- ✅ Create notes during the session, not after
- ✅ Use descriptive file names (kebab-case)
- ✅ Include YAML frontmatter with metadata
- ✅ Link to related notes and concepts
- ✅ Add relevant tags for organization
- ✅ Include timestamps for temporal context

**DON'T:**
- ❌ **Decide note location without asking user** - This is the #1 rule
- ❌ Create huge monolithic notes
- ❌ Forget to link related concepts
- ❌ Skip metadata and tags
- ❌ Use unclear or generic titles
- ❌ Duplicate information across notes

### Task Management

**DO:**
- ✅ Use checkbox syntax `- [ ]` for tasks
- ✅ Add priority indicators
- ✅ Link tasks to relevant notes
- ✅ Include context in task description
- ✅ Break down large tasks into subtasks

**DON'T:**
- ❌ Create tasks without context
- ❌ Leave tasks orphaned (unlinked)
- ❌ Forget to update task status
- ❌ Mix tasks and notes in disorganized way

### Linking and Tags

**DO:**
- ✅ Use wikilinks `[[note]]` liberally
- ✅ Create hierarchical tags `#project/area/topic`
- ✅ Link bidirectionally when relevant
- ✅ Tag by type, status, and project
- ✅ Build a web of knowledge

**DON'T:**
- ❌ Over-tag (diminishing returns)
- ❌ Use inconsistent tag hierarchies
- ❌ Create links without purpose
- ❌ Forget to use tag search features

## Obsidian Plugins for Claude Integration

### Recommended Plugins

1. **Templater** - Advanced templates with dynamic content
2. **Dataview** - Query and display notes dynamically
3. **Tasks** - Enhanced task management
4. **Calendar** - Visual daily note navigation
5. **Git** - Version control for vault (if using)
6. **Quick Add** - Rapid note creation with macros

### Dataview Examples for Claude Sessions

```dataview
# Recent Claude sessions
TABLE date, summary
FROM #claude-session
SORT date DESC
LIMIT 10
```

```dataview
# Pending tasks from sessions
TASK
FROM #claude-session
WHERE !completed
```

## Troubleshooting

### Issue 1: $OBSIDIAN_VAULT not set

**Problem**: Environment variable not defined

**Solution**:
```bash
# Add to shell profile
echo 'export OBSIDIAN_VAULT="/path/to/vault"' >> ~/.zshrc
source ~/.zshrc
```

### Issue 2: Note not appearing in Obsidian

**Problem**: File created but not visible

**Solution**:
- Ensure file has `.md` extension
- Check file permissions
- Verify path is within vault
- Refresh Obsidian file list

### Issue 3: Links not working

**Problem**: Wikilinks don't navigate correctly

**Solution**:
- Ensure exact note name match (case-sensitive)
- Check for file extension in link (shouldn't include `.md`)
- Verify linked note exists
- Use Obsidian's link autocomplete

### Issue 4: Frontmatter rendering in preview

**Problem**: YAML frontmatter shows as text

**Solution**:
- Ensure frontmatter is first thing in file
- Use proper YAML syntax (three dashes before and after)
- Check for trailing spaces

### Issue 5: Environment Variable Mismatches

**Symptom**: `TypeError: expected str, bytes or os.PathLike object, not NoneType`

**Cause**: Documentation uses different variable name than user's environment

**Diagnosis Steps**:
```bash
# Check which variable is actually set
echo $OBSIDIAN_VAULT
echo $OBSIDIAN_CLAUDE
echo $OBSIDIAN_PATH

# List all Obsidian-related variables
env | grep -i obsidian
```

**Common Variable Names**:
- `$OBSIDIAN_VAULT` (recommended standard)
- `$OBSIDIAN_CLAUDE` (older documentation)
- `$OBSIDIAN_PATH` (alternative)

**Resolution**:
1. Ask user which variable they use
2. Update ALL references systematically:
   ```bash
   # Find all references
   grep -r "OBSIDIAN_CLAUDE" $CLAUDE_METADATA/skills/obsidian/
   grep -r "OBSIDIAN_CLAUDE" $CLAUDE_METADATA/.claude/commands/safe-exit.md

   # Use Edit tool with replace_all=true for each file
   ```

3. Document the change:
   ```markdown
   ## Environment Variable Update
   Updated from `$OBSIDIAN_CLAUDE` → `$OBSIDIAN_VAULT`
   - Files modified: safe-exit.md (7 refs), obsidian/SKILL.md (21 refs)
   - Verified: 0 remaining old references
   ```

**Prevention**: When creating new integrations, check user's environment FIRST:
```bash
# Detect which variable exists
if [ -n "$OBSIDIAN_VAULT" ]; then
    VAULT_VAR="OBSIDIAN_VAULT"
elif [ -n "$OBSIDIAN_CLAUDE" ]; then
    VAULT_VAR="OBSIDIAN_CLAUDE"
else
    echo "Error: No Obsidian vault variable set"
fi
```

## Quick Reference

### Creating Notes with Claude

```bash
# Session note
cat > "$OBSIDIAN_VAULT/Sessions/$(date +%Y-%m-%d)-topic.md" <<'EOF'
---
date: 2026-01-23
type: session-note
tags: [claude-session]
---
# Content here
EOF

# Task note
cat > "$OBSIDIAN_VAULT/Tasks/task-name.md" <<'EOF'
---
date: 2026-01-23
type: task
tags: [task, status/pending]
---
# Task: task-name
- [ ] Step 1
EOF

# Quick append to daily
echo "## Note

Content" >> "$OBSIDIAN_VAULT/Daily/$(date +%Y-%m-%d).md"
```

### Essential Obsidian Syntax

```markdown
# Wikilinks
[[Note Name]]
[[Note#Heading]]
[[Note|Display Text]]

# Tags
#tag
#hierarchical/tag

# Tasks
- [ ] Pending
- [x] Done

# Callouts
> [!note]
> Content

# Block references
^block-id
[[Note#^block-id]]
```

## Integration with Other Skills

This skill works well with:
- **folder-organization** - Vault structure standards
- **managing-environments** - Development workflow
- **claude-collaboration** - Team knowledge sharing

## References and Resources

- [Obsidian Documentation](https://help.obsidian.md/)
- [Obsidian Community Plugins](https://obsidian.md/plugins)
- [Zettelkasten Method](https://zettelkasten.de/introduction/)
- [PARA Method](https://fortelabs.com/blog/para/) - Projects, Areas, Resources, Archives

---

**Remember**: The goal is to build a searchable, linked knowledge base that grows with each Claude session. Start simple, add structure as needed.

## Changelog

### Version 2.0.0 (2026-02-17)

**Major Update**: Added comprehensive 2025-2026 best practices and practical organization patterns

**New Sections Added:**

1. **Obsidian Best Practices (2025-2026)**
   - Start simple, don't overthink - avoid productive procrastination
   - Use MOCs (Maps of Content) over deep folders
   - Leverage properties/metadata instead of folder-only organization
   - Actually USE your notes - review systems and active management
   - Organize by note type, not topic
   - Create a Home/Index MOC as central navigation hub
   - Link profusely, folder minimally

2. **Practical Organization Patterns (From Real Sessions)**
   - Pattern 1: Home MOC as Central Hub (complete example)
   - Pattern 2: Project MOCs with sub-25 item sections
   - Pattern 3: Properties in Practice with search examples
   - Pattern 4: TODO Consolidation with master index
   - Pattern 5: Archive Strategy with no-link policy
   - Pattern 6: Cross-Project Linking for shared work
   - Pattern 7: Topic-Based Folders Within Projects

3. **Implementation Checklist**
   - Immediate actions (high impact, low effort)
   - Short-term improvements
   - Long-term considerations

**Key Additions:**
- MOC best practices: keep under 25 items, create at "mental squeeze points"
- Property schema: type, project, status, tags, priority, created, updated
- Home.md pattern with emojis, quick actions, and status tables
- Archive rules: no links to archived notes, 30-day policy
- Emphasis on actually USING notes vs. endlessly organizing
- Warning against productive procrastination (80/20 rule)

**Community-Sourced Best Practices:**
- Based on 2025-2026 Obsidian community consensus
- Includes modern approaches to vault organization
- Focuses on sustainability and actual usage patterns
- Emphasizes simplicity and natural evolution

**Version Note**: This update brings the skill in line with current Obsidian best practices and includes real-world patterns tested in production vaults during 2026.

### Version 2.0.1 (2026-02-17)

**Minor Update**: Added `dump` tag recommendation for session/daily notes

**Changes:**
- Added `dump` tag to Session Note Template
- Updated Property Usage to recommend `dump` tag for all session/daily notes
- Added search examples for filtering session notes by dump tag
- Updated Pattern 3 (Properties in Practice) to show dump tag usage

**Rationale:**
- Makes session notes easy to filter: `tag:#dump`
- Simplifies archiving workflow: find all dumps, review, archive
- Consistent tagging across all projects
- Helps separate active work from session history

**Usage:**
```markdown
---
tags:
  - session
  - dump
  - other-tags
---
```

Search examples:
- All session notes: `tag:#dump`
- Project-specific sessions: `tag:#dump project: project-name`
- Recent sessions: `tag:#dump` + sort by date

### Version 2.0.2 (2026-02-17)

**Major Update**: Added vault reorganization and session consolidation workflows

**New Sections Added:**

1. **Session Note Consolidation Workflow** (~300 lines)
   - Complete guide for consolidating daily session notes into thematic reference notes
   - Organize by topic (not chronology): "Data Collection" not "January Work"
   - Extract TODOs to project TO-DOS.md files
   - Archive processed sessions to archived/daily/
   - Templates for thematic notes and TODO files
   - Real-world example: 9 sessions → 5 thematic notes + 1 TODO file
   - Verification checklist and integration with other workflows

2. **Home.md File Management** (~90 lines)
   - Pattern for transitioning from central Home.md to section-level HOME.md files
   - Hierarchical structure: Work/Category-1/HOME.md, Work/Category-2/HOME.md, Perso/HOME.md
   - Step-by-step process for finding and updating all Home references
   - Section HOME.md template with cross-section navigation
   - Benefits: logical organization, self-contained sections, clearer navigation

3. **Brain Dump Folder Handling** (~60 lines)
   - Workflow for processing temporary/scratch folders during reorganization
   - Review → Categorize → Move → Archive pattern
   - Handle Summary.md files with cross-project content
   - Anti-patterns: don't move entire folder without review
   - Best practices: extract summaries, organize by theme, use rmdir for safety

**Key Principles Established:**

**Session Consolidation:**
- Organize by topic, NOT date
- Thematic notes have descriptive, timeless names (not "2026-01-Summary")
- Real-world example from curation-paper-figures project
- Verification checklist ensures no information lost

**Home File Management:**
- Create section HOMs FIRST before deleting central Home
- Update all references systematically
- Section HOME files provide local navigation hubs
- Better for hierarchical vault structures

**Brain Dump Processing:**
- Review content before moving
- Extract valuable insights to thematic notes
- Archive or delete appropriately
- Don't bury knowledge in unreviewed archives

**Integration:**
- All workflows work together for complete vault reorganization
- Session consolidation before project sharing
- Brain dump processing during reorganization
- Home.md transition for hierarchical structures

**Templates Provided:**
- Thematic reference note template (with frontmatter)
- Project TO-DOS.md template
- Section HOME.md template

**Real-World Examples:**
- Consolidation: 9 sessions → 5 themes + 1 TODO
- Thematic groupings: "Data Collection and Enrichment", "Statistical Analysis Results"
- File naming: descriptive topics, not dates

**Version Note**: These workflows were developed and tested during actual vault reorganization work, documenting proven patterns for maintaining organized, navigable knowledge bases.

### Version 2.0.3 (2026-02-17)

**Major Update**: Added link management and HOME.md naming patterns

**New Sections Added:**

1. **Link Management and Verification** (~150 lines)
   - Automated broken link detection script for entire vault
   - Systematic fix workflow with categorization by section
   - Common link issues after reorganization (table with examples)
   - Link update patterns for moved folders, renamed files, consolidated sessions
   - Best practices: fix systematically, verify frequently, use TodoWrite
   - Token efficiency: 98-99% reduction vs manual verification
   - Real-world example: 74 broken links across 15 files fixed in 40 minutes
   - Integration with other workflows (consolidation, reorganization, sharing)

2. **HOME.md Naming Convention** (~50 lines)
   - Pattern: Use `[section-name]_HOME.md` instead of generic `HOME.md`
   - Benefits: avoid conflicts, clear identification, better navigation
   - Renaming process with bash commands
   - When to use generic vs named HOME files
   - Examples: Galaxy_HOME.md, VGP_HOME.md, Global-skills_HOME.md

**Key Principles:**

**Link Management:**
- Automated detection saves 98-99% tokens vs manual checking
- Fix systematically by section (prevents overwhelm)
- Use TodoWrite to track progress
- Verify after each section (catch errors early)
- Real impact: 74 links fixed, ~100 tokens vs 7,500-15,000 manual

**HOME Naming:**
- Prevents confusion with multiple HOME files in working directory
- Clear pattern for hierarchical vault structures
- Update all references systematically with grep

**Templates Provided:**
- Python script for broken link detection
- Bash commands for renaming HOME files
- Grep commands for finding references

**Real-World Application:**
- Link verification: After vault reorganization with 74 broken links
- HOME naming: Applied to 4 section HOME files in hierarchical vault
- Both patterns tested in production vault with 35+ notes

**Version Note**: These patterns solve common issues after major vault reorganization, providing automated detection and systematic fixing approaches that save significant time and tokens.
