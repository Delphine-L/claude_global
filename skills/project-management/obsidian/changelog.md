# Obsidian Skill Changelog

## Version 2.2.0 (2026-03-13)

**Major Update**: Added Obsidian CLI (1.12+) reference and updated workflows to prefer CLI over bash patterns

**New File:**
- **[cli-reference.md](cli-reference.md)** — Complete reference for the native Obsidian CLI

**CLI Highlights:**
- File operations: `create`, `read`, `append`, `prepend`, `move`, `rename`, `delete`
- Daily notes: `daily`, `daily:append`, `daily:prepend`, `daily:read`, `daily:path`
- Search: `search`, `search:context`, `search:open`
- Tasks: `tasks`, `task` (list, filter, toggle, mark done)
- Properties: `property:set`, `property:read`, `property:remove`, `properties`
- Tags: `tags`, `tag` (list, count, filter)
- Links/graph: `backlinks`, `links`, `orphans`, `deadends`, `unresolved`
- Templates: `templates`, `template:read`, `template:insert`
- Vault info: `vault`, `vaults`, `files`, `folders`, `file`, `folder`
- Bases (database views): `bases`, `base:query`, `base:create`, `base:views`
- Sync: `sync:status`, `sync:history`, `sync:read`, `sync:restore`
- File history: `history`, `history:read`, `history:restore`, `diff`
- Plugins/themes: `plugins`, `plugin:install`, `plugin:enable`, `themes`, `theme:set`
- Bookmarks, aliases, recents, outline, wordcount
- Developer: `eval`, `dev:screenshot`, `dev:console`, `dev:dom`

**Changes to SKILL.md:**
- Added "Prefer CLI" as core principle #1
- Added CLI setup section under Vault Configuration
- Updated "Creating a Note" workflow with CLI examples
- Added cli-reference.md to supporting files list

**Key Guidance:**
- Prefer CLI for most operations (create, read, append, search, tasks, properties)
- Fall back to bash/heredocs for complex multi-line content
- CLI uses `file=<name>` (wikilink-style) or `path=<path>` (exact) resolution
- Target specific vaults with `vault=<name>` option

## Version 2.0.3 (2026-02-17)

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

## Version 2.0.2 (2026-02-17)

**Major Update**: Added vault reorganization and session consolidation workflows

**New Sections Added:**

1. **Session Note Consolidation Workflow** (~300 lines)
   - Complete guide for consolidating daily session notes into thematic reference notes
   - Organize by topic (not chronology): "Data Collection" not "January Work"
   - Extract TODOs to project TO-DOS.md files
   - Archive processed sessions to archived/daily/
   - Templates for thematic notes and TODO files
   - Real-world example: 9 sessions -> 5 thematic notes + 1 TODO file
   - Verification checklist and integration with other workflows

2. **Home.md File Management** (~90 lines)
   - Pattern for transitioning from central Home.md to section-level HOME.md files
   - Hierarchical structure: Work/Category-1/HOME.md, Work/Category-2/HOME.md, Perso/HOME.md
   - Step-by-step process for finding and updating all Home references
   - Section HOME.md template with cross-section navigation
   - Benefits: logical organization, self-contained sections, clearer navigation

3. **Brain Dump Folder Handling** (~60 lines)
   - Workflow for processing temporary/scratch folders during reorganization
   - Review -> Categorize -> Move -> Archive pattern
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
- Consolidation: 9 sessions -> 5 themes + 1 TODO
- Thematic groupings: "Data Collection and Enrichment", "Statistical Analysis Results"
- File naming: descriptive topics, not dates

**Version Note**: These workflows were developed and tested during actual vault reorganization work, documenting proven patterns for maintaining organized, navigable knowledge bases.

## Version 2.0.1 (2026-02-17)

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

## Version 2.0.0 (2026-02-17)

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
