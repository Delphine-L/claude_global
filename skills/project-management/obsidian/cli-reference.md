# Obsidian CLI Reference

Obsidian 1.12+ includes a native CLI. This replaces most bash helper patterns with direct commands.

## Usage

```bash
obsidian <command> [options]
```

- **`vault=<name>`** — target a specific vault (defaults to active vault)
- **`file=<name>`** — resolve by name (like wikilinks)
- **`path=<path>`** — resolve by exact path (folder/note.md)
- Most commands default to the **active file** when file/path is omitted
- Quote values with spaces: `name="My Note"`
- Use `\n` for newline, `\t` for tab in content values

## CLI vs Bash Patterns

The CLI replaces many bash patterns previously used in this skill:

| Old Pattern | CLI Equivalent |
|---|---|
| `cat > "$OBSIDIAN_VAULT/path.md" <<EOF...EOF` | `obsidian create path="path.md" content="..."` |
| `echo "text" >> "$OBSIDIAN_VAULT/file.md"` | `obsidian append file="name" content="text"` |
| `cat "$OBSIDIAN_VAULT/file.md"` | `obsidian read file="name"` |
| `grep -r "query" "$OBSIDIAN_VAULT"` | `obsidian search query="query"` |
| Custom daily note scripts | `obsidian daily:append content="text"` |

**When to still use bash**: Writing files with complex multi-line content (heredocs are easier than escaped `\n`), or when `$OBSIDIAN_VAULT` direct file access is simpler for bulk operations.

## Core Commands

### File Operations

```bash
# Create a new note
obsidian create name="My Note" content="---\ntype: session\n---\n\n# My Note" open

# Create from template
obsidian create name="Session 2026-03-13" template="session" open

# Read file contents
obsidian read file="My Note"
obsidian read path="projects/my-project/notes.md"

# Append to a file
obsidian append file="My Note" content="\n## New Section\nContent here"

# Prepend to a file
obsidian prepend file="My Note" content="Prepended text\n"

# Move/rename
obsidian move file="Old Name" to="new-folder/Old Name.md"
obsidian rename file="Old Name" name="New Name"

# Delete (to trash by default)
obsidian delete file="My Note"
obsidian delete file="My Note" permanent  # skip trash
```

### Daily Notes

```bash
# Open today's daily note
obsidian daily

# Append to daily note (great for session logging)
obsidian daily:append content="## 14:30 - Session Update\nWorked on feature X"

# Prepend to daily note
obsidian daily:prepend content="## Morning Plan\n- [ ] Task 1"

# Read daily note
obsidian daily:read

# Get daily note path
obsidian daily:path
```

### Search

```bash
# Basic search
obsidian search query="feature implementation"

# Search with context (shows matching lines)
obsidian search:context query="TODO" path="projects/"

# Limit results
obsidian search query="bug" limit=5

# Case sensitive
obsidian search query="ClassName" case

# JSON output for parsing
obsidian search query="tag" format=json

# Get match count only
obsidian search query="TODO" total
```

### Tasks

```bash
# List all incomplete tasks
obsidian tasks todo

# List completed tasks
obsidian tasks done

# Tasks in specific file
obsidian tasks file="Project Plan"

# Tasks from daily note
obsidian tasks daily

# Tasks for active file
obsidian tasks active

# Filter by custom status
obsidian tasks status="/"  # in-progress tasks

# Toggle a task
obsidian task path="projects/todo.md" line=15 toggle

# Mark done
obsidian task file="TODO" line=5 done

# JSON output
obsidian tasks format=json
```

### Properties (Frontmatter)

```bash
# Set a property
obsidian property:set name="status" value="completed" file="My Note"
obsidian property:set name="tags" value="session,dump" type=list file="My Note"

# Read a property
obsidian property:read name="status" file="My Note"

# Remove a property
obsidian property:remove name="old-prop" file="My Note"

# List all properties in vault
obsidian properties
obsidian properties sort=count counts

# Properties for a specific file
obsidian properties file="My Note"
```

### Tags

```bash
# List all tags
obsidian tags

# Tags with counts, sorted
obsidian tags counts sort=count

# Tags for specific file
obsidian tags file="My Note"

# Tag info (occurrences, files)
obsidian tag name="dump" verbose
```

### Links and Graph

```bash
# Backlinks to a file
obsidian backlinks file="My Note"
obsidian backlinks file="My Note" counts total

# Outgoing links from a file
obsidian links file="My Note"

# Orphan notes (no incoming links)
obsidian orphans
obsidian orphans total

# Dead-end notes (no outgoing links)
obsidian deadends

# Unresolved links
obsidian unresolved
obsidian unresolved verbose  # includes source files
```

### Vault Information

```bash
# Vault info
obsidian vault
obsidian vault info=name
obsidian vault info=path

# List vaults
obsidian vaults verbose

# File listing
obsidian files
obsidian files folder="projects/" ext=md
obsidian files total

# Folder listing
obsidian folders
obsidian folders folder="projects/"

# File info
obsidian file file="My Note"

# Word count
obsidian wordcount file="My Note"
```

### Templates

```bash
# List templates
obsidian templates

# Read template content
obsidian template:read name="session"
obsidian template:read name="session" resolve title="My Session"

# Insert template into active file
obsidian template:insert name="session"
```

### Bookmarks

```bash
# Add bookmarks
obsidian bookmark file="Important Note"
obsidian bookmark search="project status"
obsidian bookmark url="https://example.com" title="Reference"

# List bookmarks
obsidian bookmarks
obsidian bookmarks verbose format=json
```

### Aliases

```bash
# List aliases
obsidian aliases
obsidian aliases file="My Note"
obsidian aliases verbose  # include file paths
```

### Recent Files

```bash
# Recently opened
obsidian recents
```

### Outline

```bash
# Show headings for a file
obsidian outline file="My Note"
obsidian outline file="My Note" format=md
obsidian outline file="My Note" format=json
```

## Bases (Database Views)

```bash
# List bases
obsidian bases

# List views in a base
obsidian base:views file="My Database"

# Query a base view
obsidian base:query file="My Database" view="All Items" format=json

# Create item in base
obsidian base:create file="My Database" name="New Item" content="Details"
```

## Sync

```bash
# Check sync status
obsidian sync:status

# Pause/resume
obsidian sync off
obsidian sync on

# Sync version history
obsidian sync:history file="My Note"
obsidian sync:read file="My Note" version=3
obsidian sync:restore file="My Note" version=3

# Deleted files in sync
obsidian sync:deleted
```

## File History (Local)

```bash
# List versions
obsidian history file="My Note"

# Read a version
obsidian history:read file="My Note" version=2

# Restore a version
obsidian history:restore file="My Note" version=2

# Diff versions
obsidian diff file="My Note" from=1 to=3
```

## Plugins and Themes

```bash
# List plugins
obsidian plugins
obsidian plugins filter=community versions

# Enable/disable
obsidian plugin:enable id="dataview"
obsidian plugin:disable id="some-plugin"

# Install community plugin
obsidian plugin:install id="templater-obsidian" enable

# Themes
obsidian themes
obsidian theme:set name="Minimal"
obsidian theme:install name="Minimal" enable
```

## Commands and Hotkeys

```bash
# List all commands
obsidian commands
obsidian commands filter="editor"

# Execute a command
obsidian command id="editor:toggle-bold"

# Hotkeys
obsidian hotkeys
obsidian hotkey id="editor:toggle-bold"
```

## Tab and Workspace Management

```bash
# List open tabs
obsidian tabs

# Open a new tab
obsidian tab:open file="My Note"

# View workspace tree
obsidian workspace
```

## Developer Commands

```bash
# Execute JavaScript
obsidian eval code="app.vault.getFiles().length"

# Take screenshot
obsidian dev:screenshot path="screenshot.png"

# Console messages
obsidian dev:console
obsidian dev:console level=error

# DOM inspection
obsidian dev:dom selector=".workspace-leaf" total

# Toggle devtools
obsidian devtools
```

## Claude Integration Patterns with CLI

### Pattern 1: Session Note via CLI

```bash
# Create session note with template
obsidian create name="2026-03-13-feature-work" template="session" open

# Or with inline content
obsidian create name="2026-03-13-feature-work" content="---\ntype: session\nproject: my-project\ndate: 2026-03-13\ntags:\n  - session\n  - dump\nstatus: completed\n---\n\n# Session: Feature Work\n\n## Context\n\n## Summary\n\n## Action Items\n- [ ] "
```

### Pattern 2: Quick Append During Work

```bash
# Add finding to daily note
obsidian daily:append content="## 14:30 - Discovery\nFound that the API returns paginated results by default. Need to handle pagination in the client.\n\nRelated: [[API Integration]]"

# Add to specific project note
obsidian append file="Project Notes" content="\n## Bug Fix\nFixed null pointer in auth middleware. Root cause: missing null check on token refresh.\n"
```

### Pattern 3: Task Management

```bash
# Check project tasks
obsidian tasks file="TO-DOS" todo

# Mark task complete after fixing
obsidian task file="TO-DOS" line=12 done

# Add new task
obsidian append file="TO-DOS" content="\n- [ ] Refactor auth middleware error handling #high-priority"
```

### Pattern 4: Update Properties Programmatically

```bash
# Mark session as completed
obsidian property:set name="status" value="completed" file="2026-03-13-session"

# Add tags
obsidian property:set name="tags" value="session,dump,api-work" type=list file="2026-03-13-session"
```

### Pattern 5: Vault Analysis

```bash
# Find orphan notes that need linking
obsidian orphans

# Check for broken links
obsidian unresolved verbose

# Count notes by folder
obsidian files folder="projects/" total
```

### Pattern 6: Search and Discovery

```bash
# Find all notes about a topic
obsidian search:context query="authentication" format=json

# Find tagged notes
obsidian tags
obsidian tag name="dump" verbose

# Get backlinks to understand connections
obsidian backlinks file="API Design" counts
```
