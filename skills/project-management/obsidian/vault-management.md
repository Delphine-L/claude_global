# Vault Management Workflows

Guides for vault reorganization, session note consolidation, link management, and project directory setup.

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
print("Current vault structure:")
print(f"   {vault_path}/")

# Show top-level directories (up to 2 levels)
for item in sorted(vault_path.iterdir()):
    if item.is_dir() and not item.name.startswith('.'):
        print(f"   |- {item.name}/")
        # Show one level deeper
        for subitem in sorted(item.iterdir())[:3]:
            if subitem.is_dir() and not subitem.name.startswith('.'):
                print(f"   |   |- {subitem.name}/")
        # Indicate if there are more
        remaining = len([x for x in item.iterdir() if x.is_dir()]) - 3
        if remaining > 0:
            print(f"   |   +-- ... ({remaining} more)")

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
print(f"Project directory: {project_dir.relative_to(vault_path)}")
```

### Best Practices for Organization

**Root Level:**
- Quick access to frequently used projects
- Simple structure for small vaults
- Can become cluttered with many projects

**Organized Subdirectories:**
- Better organization for many projects
- Logical grouping (Work, Personal, Research, etc.)
- Easier to navigate in large vaults
- Better for team vaults with shared structure

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
    print(f"Directory already exists: {project_dir}")
    overwrite = input("Continue using this directory? (y/n): ")
    if overwrite.lower() != 'y':
        # Ask for different name or path
        return
else:
    # Create with parents
    project_dir.mkdir(parents=True, exist_ok=True)
    print(f"Created directory: {project_dir}")
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
   - Rename `sessions-history/` to `session-saves/` for consistency
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

Group content by topic, not chronology. Use the Thematic Reference Note Template from [templates.md](templates.md).

**2. Extract TODOs to Project TO-DOS.md**

Create or update project TO-DOS.md with extracted tasks. Use the Project TODO Template from [templates.md](templates.md).

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

Wrong - Chronological:
```markdown
# Session Consolidation

## January Work
- Did X on 2026-01-15
- Did Y on 2026-01-20

## February Work
- Did Z on 2026-02-01
```

Right - Thematic:
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
- `2026-01-Session-Summary.md`
- `January-Work-Consolidated.md`
- `Week-3-Notes.md`

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

**Old path structure to new structure:**
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
- Development session links -> Thematic reference notes
- Folder references (with trailing /) -> Remove or link to index
- Non-existent TODO indexes -> Individual project TO-DOS

**4. Verification After Fixes**

Run detection script again to verify:
```bash
# Should output
# SUCCESS! No broken links found. All links have been fixed.
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
