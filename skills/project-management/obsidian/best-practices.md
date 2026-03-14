# Obsidian Best Practices (2025-2026)

Based on current best practices from the Obsidian community:

## 1. Start Simple, Don't Overthink

**Key Principle**: Write first, organize later (or never)

- Focus on creating notes, not perfecting the system
- Let your vault structure evolve naturally as you add content
- Don't spend hours planning the "perfect" organization
- Begin with a few notes and gradually explore advanced features

**Avoiding Productive Procrastination**:
- Don't spend all your time tweaking the system and calling it work
- Don't endlessly optimize tags, folders, and organization
- Spend 80% time writing/working, 20% organizing
- Organize during weekly reviews, not constantly

## 2. Use MOCs (Maps of Content) Over Deep Folders

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

## 3. Leverage Properties (Metadata)

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

### Critical: Dump Tag Requirement

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

## 4. Actually USE Your Notes

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

## 5. Organize by Note Type, Not Topic

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

## 6. Create a Home/Index MOC

**Central Navigation Hub:**
- Single starting point for entire vault
- Links to all project MOCs
- Quick access to TODOs and recent notes
- Project status overview
- Pin in Obsidian for easy access

**Home MOC Structure:**
```markdown
# Home

## Active Projects
- [[Project-1-MOC]] - Description
- [[Project-2-MOC]] - Description

## Quick Access
- [[TODOs/Master-Index]]
- [[Sessions/Latest]]

## Knowledge by Topic
- [[Topic-1-MOC]]
- [[Topic-2-MOC]]

## By Note Type
- Planning notes
- Development sessions
- Reference docs
```

## 7. Link Profusely, Folder Minimally

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
