---
name: obsidian
description: Integration with Obsidian vault for managing notes, tasks, and knowledge when working with Claude. Supports adding notes, creating tasks, and organizing project documentation. Updated with 2025-2026 best practices including MOCs, properties, practical organization patterns, and Obsidian CLI (1.12+).
version: 2.2.0
updated: 2026-03-13
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

## Supporting Files

This skill is split across several files. Load the relevant file when needed:

- **[best-practices.md](best-practices.md)** - MOCs, properties, organization philosophy, dump tag requirements
- **[templates.md](templates.md)** - Note templates: session, technical, task, analysis planning, thematic reference, TODO, HOME.md
- **[organization-patterns.md](organization-patterns.md)** - Home MOC, Project MOC, TODO consolidation, archive strategy, cross-project linking
- **[vault-management.md](vault-management.md)** - Vault reorganization, session consolidation, link management, project directory setup, brain dump handling
- **[reference.md](reference.md)** - Obsidian markdown syntax, bash helpers, plugins, Claude integration patterns, troubleshooting
- **[cli-reference.md](cli-reference.md)** - Obsidian CLI (1.12+) command reference, replaces many bash patterns
- **[changelog.md](changelog.md)** - Version history

## Core Principles

1. **Prefer CLI** - Use `obsidian` CLI commands (1.12+) over bash/cat patterns when possible. See [cli-reference.md](cli-reference.md)
2. **Vault Location** - Use `$OBSIDIAN_VAULT` environment variable for direct file access; CLI uses `vault=<name>` option
3. **Always Ask User for Note Placement** - Never decide where to save notes without asking the user first. Show vault structure, suggest options, and let the user choose.
4. **Atomic Notes** - Each note focuses on a single concept or topic
5. **Linking** - Use wikilinks `[[note-name]]` to connect related ideas
6. **Tags** - Organize with hierarchical tags like `#project/feature`
7. **Tasks** - Use checkbox syntax for actionable items
8. **Timestamps** - Include dates for temporal context

## Essential Rules

### Rule 1: Never Assume Note Placement

**CRITICAL**: When creating ANY note in Obsidian, ALWAYS ask the user where they want it saved. Never decide the location yourself, even if it seems obvious.

**Why**: The user knows how their vault is organized. Assuming a location means they'll need to reorganize later.

**Workflow for ANY note creation:**

1. **Show current vault structure** to help user decide
2. **Suggest options** (root level, specific folder, custom path) -- do NOT decide
3. **Get user input** before writing anything
4. **Create in chosen location**

**Only exception**: Project session notes when `.claude/project-config` already specifies the location from a previous user choice.

**Golden Rule**: If you're about to write a file to the Obsidian vault, STOP and ask the user where it should go first.

### Rule 2: Always Include Dump Tag in Session Notes

**ALWAYS** include the `dump` tag in session/daily notes. This is essential for:
- Filtering all session notes across projects: `tag:#dump`
- Archiving workflows with `/consolidate-notes`
- Separating working notes from permanent documentation

Python template for new session files:
```python
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

### Rule 3: Always Add Properties (Frontmatter)

Every note must have YAML frontmatter with at minimum:

```yaml
---
type: session | planning | reference | todo | moc | development | analysis
project: project-name
status: active | in-progress | completed | archived
tags:
  - relevant-tags
created: YYYY-MM-DD
---
```

For the full property schema, see [best-practices.md](best-practices.md).

### Rule 4: Use MOCs Over Deep Folders

- Keep folder structure flat (2-3 levels max)
- Use Maps of Content (MOC) notes as navigation hubs
- Keep MOCs under 25 items
- Create sub-MOCs when sections grow too large
- Use properties and tags for topic categorization, not folders

For detailed MOC guidance, see [best-practices.md](best-practices.md).

## Vault Configuration

### Environment Setup

```bash
# Check vault location
echo $OBSIDIAN_VAULT
# Should return something like: /Users/username/Documents/Notes

# If not set, add to ~/.zshrc or ~/.bashrc
export OBSIDIAN_VAULT="/path/to/your/vault"
```

### Obsidian CLI (1.12+)

Obsidian now ships with a native CLI (`obsidian`). **Prefer CLI commands over bash patterns** for creating, reading, appending, and searching notes.

```bash
# Verify CLI is available
obsidian version

# List vaults
obsidian vaults verbose

# Target a specific vault
obsidian files vault="My Vault"
```

For the full CLI command reference, see [cli-reference.md](cli-reference.md).

## Key Workflows

### Creating a Note

1. Check vault is accessible (`obsidian vault` or `echo $OBSIDIAN_VAULT`)
2. Show vault structure to user (`obsidian folders` or `obsidian files`)
3. Ask where to save the note
4. Create with proper frontmatter (type, project, tags, created date)
5. Include `dump` tag if it's a session note
6. Add wikilinks to related notes

**Using CLI:**
```bash
obsidian create name="my-note" path="projects/my-note.md" template="session" open
# Or with inline content:
obsidian create name="my-note" content="---\ntype: session\ntags:\n  - dump\n---\n\n# Content"
```

**Using bash** (for complex multi-line content):
```bash
cat > "$OBSIDIAN_VAULT/projects/my-note.md" <<'EOF'
---
type: session
tags:
  - dump
---
# Content
EOF
```

For note templates, see [templates.md](templates.md).

### Creating a Session Summary

Used by `/safe-exit` and `/safe-clear` commands:

1. Read project config from `.claude/project-config` for vault path
2. Create note in project's `session-saves/` directory
3. Include frontmatter with `type: session`, `dump` tag
4. Document: context, summary, decisions, action items, code references
5. Link to related notes

### Consolidating Session Notes

When session folder has 5+ notes or at project milestones:

1. Review all session notes, identify themes
2. Create thematic reference notes (by topic, not date)
3. Extract TODOs to project TO-DOS.md
4. Archive processed sessions to `archived/daily/`
5. Update project HOME.md and MOCs

For the full consolidation workflow, see [vault-management.md](vault-management.md).

### Vault Reorganization

When restructuring the vault:

1. Document target structure
2. Create new folders first
3. Move files and folders
4. Update all links systematically
5. Run broken link detection
6. Verify with `tree` command

For detailed reorganization steps, see [vault-management.md](vault-management.md).

## Standard Project Structure

```
project-name/
├── TO-DOS.md
├── session-saves/
├── archived/
│   ├── daily/
│   └── monthly/
└── [project-specific folders]
```

## Obsidian Syntax Quick Reference

```markdown
[[Note Name]]              # Wikilink
[[Note Name|Display Text]] # Wikilink with alias
[[Note#Heading]]           # Link to heading
#tag  #project/feature     # Tags
- [ ] Task to do           # Task
- [x] Completed task       # Done task
> [!note]                  # Callout
> Content here
```

For full syntax reference, see [reference.md](reference.md).

## Integration with Other Skills

- **folder-organization** - Vault structure standards
- **managing-environments** - Development workflow
- **claude-collaboration** - Team knowledge sharing

---

**Remember**: The goal is to build a searchable, linked knowledge base that grows with each Claude session. Start simple, add structure as needed.
