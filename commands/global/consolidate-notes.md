---
name: consolidate-notes
description: Consolidate session notes, update project status, and archive processed notes with AI-powered analysis
---

Consolidate all session notes from `sessions-history/`, remove redundancies, track to-do completion, generate comprehensive project status, and archive processed notes.

**Key Features:**
- AI-powered summarization of project progress
- Automatic tag extraction and categorization
- To-do tracking (completed vs pending)
- Redundancy removal
- Project improvement suggestions
- Milestone snapshots

## Your Task

### Step 1: Check for Obsidian Configuration

```bash
# Check for project configuration
PROJECT_CONFIG_FILE=".claude/project-config"

if [ ! -f "$PROJECT_CONFIG_FILE" ]; then
    echo "⚠️  No Obsidian configuration found"
    echo "Run /safe-exit or /safe-clear first to set up Obsidian integration"
    exit 1
fi

# Read configuration
PROJECT_NAME=$(grep "^obsidian_project=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
OBSIDIAN_PATH=$(grep "^obsidian_path=" "$PROJECT_CONFIG_FILE" | cut -d= -f2)
OBSIDIAN_PATH=${OBSIDIAN_PATH:-$PROJECT_NAME}

# Build paths
SESSIONS_DIR="$OBSIDIAN_VAULT/$OBSIDIAN_PATH/sessions-history"
ARCHIVED_DIR="$SESSIONS_DIR/archived"
STATUS_FILE="$OBSIDIAN_VAULT/$OBSIDIAN_PATH/project-status.md"

echo "📊 Consolidate Session Notes"
echo ""
echo "Project: $PROJECT_NAME"
echo "Location: $OBSIDIAN_PATH"
echo ""
```

---

### Step 2: Discover Session Notes

```bash
# Check if sessions-history directory exists
if [ ! -d "$SESSIONS_DIR" ]; then
    echo "📝 No session notes found in $OBSIDIAN_PATH/sessions-history/"
    echo "Nothing to consolidate"
    exit 0
fi

# Count session notes (exclude archived/)
NOTE_COUNT=$(find "$SESSIONS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | xargs)

if [ "$NOTE_COUNT" -eq 0 ]; then
    echo "📝 No unprocessed session notes found"
    echo "All notes have been consolidated or archived"
    exit 0
fi

echo "Found $NOTE_COUNT session notes to consolidate"
echo ""
```

---

### Step 3: Analyze Session Notes with AI

Use Python to read, analyze, and extract information from session notes:

```python
import os
from pathlib import Path
from datetime import datetime
import re
import json

# Setup paths
sessions_dir = Path(os.environ.get('SESSIONS_DIR'))
project_name = os.environ.get('PROJECT_NAME')

# Find all session notes (excluding archived/)
notes = sorted([p for p in sessions_dir.glob('*.md') if p.is_file()])

if not notes:
    print("No notes to process")
    exit(0)

print(f"📚 Reading {len(notes)} session notes...")
print("")

# Data structures
all_accomplishments = []
all_decisions = []
all_discoveries = []
all_todos = []
all_notes = []
contexts = []
tags_found = set()

# Read all notes
for note_path in notes:
    with open(note_path, 'r') as f:
        content = f.read()

    note_date = note_path.stem  # YYYY-MM-DD
    all_notes.append({'date': note_date, 'content': content, 'path': note_path})

    # Extract tags (#tag format)
    tags = re.findall(r'#(\w+(?:-\w+)*)', content)
    tags_found.update(tags)

    # Extract accomplishments
    accomplishments = re.findall(
        r'### What Was Accomplished\s*\n((?:- .+\n?)+)',
        content
    )
    for items in accomplishments:
        tasks = [line.strip('- ').strip()
                for line in items.split('\n')
                if line.strip().startswith('-')]
        all_accomplishments.extend([(task, note_date) for task in tasks])

    # Extract decisions
    decisions = re.findall(
        r'### Key Decisions[^\n]*\s*\n((?:- .+\n?)+)',
        content
    )
    for items in decisions:
        items_list = [line.strip('- ').strip()
                     for line in items.split('\n')
                     if line.strip().startswith('-')]
        all_decisions.extend([(item, note_date) for item in items_list])

    # Extract discoveries
    discoveries = re.findall(
        r'### Important Discoveries\s*\n((?:- .+\n?)+)',
        content
    )
    for items in discoveries:
        items_list = [line.strip('- ').strip()
                     for line in items.split('\n')
                     if line.strip().startswith('-')]
        all_discoveries.extend([(item, note_date) for item in items_list])

    # Extract to-dos
    todo_pattern = r'- \[([ xX])\] (.+)'
    todos = re.findall(todo_pattern, content)
    for status, task in todos:
        all_todos.append({
            'task': task.strip(),
            'completed': status.lower() == 'x',
            'date': note_date,
            'note': note_path.name
        })

    # Extract most recent context
    context_sections = re.findall(
        r'### Context for Next Session\s*\n((?:.+\n?)+?)(?:###|\n---|\Z)',
        content,
        re.MULTILINE
    )
    if context_sections:
        contexts.append((context_sections[-1].strip(), note_date))

# Summary stats
print(f"📊 Analysis Summary:")
print(f"  Total accomplishments: {len(all_accomplishments)}")
print(f"  Total decisions: {len(all_decisions)}")
print(f"  Total discoveries: {len(all_discoveries)}")
print(f"  Total to-dos: {len(all_todos)}")
print(f"    ✅ Completed: {sum(1 for t in all_todos if t['completed'])}")
print(f"    ⏳ Pending: {sum(1 for t in all_todos if not t['completed'])}")
print(f"  Tags found: {len(tags_found)}")
print("")

# Store for next step
analysis_data = {
    'notes': all_notes,
    'accomplishments': all_accomplishments,
    'decisions': all_decisions,
    'discoveries': all_discoveries,
    'todos': all_todos,
    'contexts': contexts,
    'tags': sorted(list(tags_found)),
    'date_range': {
        'start': notes[0].stem,
        'end': notes[-1].stem
    }
}

# Save to temp file for next steps
import json
with open('/tmp/consolidate_analysis.json', 'w') as f:
    json.dump(analysis_data, f)
```

---

### Step 4: Remove Redundancies

```python
from difflib import SequenceMatcher
import json

# Load analysis data
with open('/tmp/consolidate_analysis.json', 'r') as f:
    data = json.load(f)

def similarity(a, b):
    """Calculate text similarity ratio."""
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()

def remove_duplicates(items, threshold=0.85):
    """Remove duplicate/very similar items."""
    unique_items = []
    seen = []

    for item, date in items:
        is_duplicate = False
        for seen_item, seen_date in seen:
            if similarity(item, seen_item) > threshold:
                is_duplicate = True
                break

        if not is_duplicate:
            unique_items.append((item, date))
            seen.append((item, date))

    return unique_items

# Remove redundancies
unique_accomplishments = remove_duplicates(data['accomplishments'])
unique_decisions = remove_duplicates(data['decisions'])
unique_discoveries = remove_duplicates(data['discoveries'])

print(f"🔄 Redundancy Removal:")
print(f"  Accomplishments: {len(data['accomplishments'])} → {len(unique_accomplishments)}")
print(f"  Decisions: {len(data['decisions'])} → {len(unique_decisions)}")
print(f"  Discoveries: {len(data['discoveries'])} → {len(unique_discoveries)}")
print("")

# Update data
data['unique_accomplishments'] = unique_accomplishments
data['unique_decisions'] = unique_decisions
data['unique_discoveries'] = unique_discoveries

# Save updated data
with open('/tmp/consolidate_analysis.json', 'w') as f:
    json.dump(data, f)
```

---

### Step 5: AI-Powered Analysis and Suggestions

Ask Claude to analyze the consolidated data and provide insights:

```
🤖 Generating AI-powered analysis...

Please analyze the following project data and provide:

1. **Executive Summary** (2-3 paragraphs)
   - Overview of what this project has accomplished
   - Main themes and focus areas
   - Current trajectory

2. **Tag-Based Categorization**
   - Group accomplishments/decisions by detected tags
   - Identify main activity areas

3. **Pattern Recognition**
   - Identify recurring themes or patterns
   - Note any shifts in focus over time
   - Highlight potential blockers or challenges mentioned

4. **Future Improvement Suggestions** (5-10 ideas)
   - Technical improvements
   - Process optimizations
   - Areas for exploration
   - Potential risks to address

**Project Data:**

Project Name: {PROJECT_NAME}
Period: {date_range['start']} to {date_range['end']}
Sessions: {len(notes)} notes consolidated

Tags Found: {', '.join(tags)}

Accomplishments ({len(unique_accomplishments)}):
{format_items(unique_accomplishments[:30])}
{f"... and {len(unique_accomplishments) - 30} more" if len(unique_accomplishments) > 30 else ""}

Key Decisions ({len(unique_decisions)}):
{format_items(unique_decisions[:20])}

Important Discoveries ({len(unique_discoveries)}):
{format_items(unique_discoveries[:20])}

Pending To-Dos ({len(pending_todos)}):
{format_todos(pending_todos)}

Current Context:
{contexts[-1][0] if contexts else "No context available"}

---

**Analysis Instructions:**
- Be concise and actionable
- Identify concrete patterns, not generic observations
- Suggest specific, implementable improvements
- Note any concerning patterns (repeated issues, stalled progress)
- Highlight wins and momentum areas
```

Store Claude's response for inclusion in project-status.md.

---

### Step 6: Update or Create Project Status Note

```python
from datetime import datetime
import json
import os
from pathlib import Path

# Load analysis data
with open('/tmp/consolidate_analysis.json', 'r') as f:
    data = json.load(f)

# Get AI analysis from previous step (stored as AI_ANALYSIS variable)
# In practice, this would come from Claude's response

project_name = os.environ.get('PROJECT_NAME')
obsidian_path = os.environ.get('OBSIDIAN_PATH')
status_file = Path(os.environ.get('STATUS_FILE'))

# Check if project-status.md already exists
if status_file.exists():
    print(f"📝 Updating existing project-status.md")

    # Read existing file
    with open(status_file, 'r') as f:
        existing_content = f.read()

    # Check for "Consolidation History" section
    if "## Consolidation History" in existing_content:
        # Append to existing history
        # Insert new entry at the top of history section
        history_marker = "## Consolidation History\n\n"
        history_pos = existing_content.index(history_marker) + len(history_marker)

        new_entry = f"### Update {datetime.now().strftime('%Y-%m-%d')}\n\n"
        new_entry += f"- **Period:** {data['date_range']['start']} to {data['date_range']['end']}\n"
        new_entry += f"- **Sessions:** {len(data['notes'])} notes consolidated\n"
        new_entry += f"- **New accomplishments:** {len(data['unique_accomplishments'])}\n"
        new_entry += f"- **Pending tasks:** {sum(1 for t in data['todos'] if not t['completed'])}\n\n"

        existing_content = (
            existing_content[:history_pos] +
            new_entry +
            existing_content[history_pos:]
        )

        # Replace the sections that need updating
        # (Current Status, Tasks & To-Dos, AI Analysis, etc.)
        action = "updated"
    else:
        # Old format - backup and recreate
        backup_path = status_file.with_suffix('.md.backup')
        with open(backup_path, 'w') as f:
            f.write(existing_content)
        print(f"  ⚠️  Backed up old format to {backup_path.name}")

        existing_content = None
        action = "recreated"
else:
    print(f"📝 Creating new project-status.md")
    existing_content = None
    action = "created"

# Prepare data
pending_todos = [t for t in data['todos'] if not t['completed']]
completed_todos = [t for t in data['todos'] if t['completed']]
current_context = data['contexts'][-1][0] if data['contexts'] else "No context available"

# Generate new project status content
project_status = f"""# Project Status - {project_name}

**Last Updated:** {datetime.now().strftime("%Y-%m-%d %H:%M")}
**Period Covered:** {data['date_range']['start']} to {data['date_range']['end']}
**Sessions Consolidated:** {len(data['notes'])} notes

---

## Executive Summary

{AI_ANALYSIS['executive_summary']}

---

## Current Status

{current_context}

---

## Tags & Categories

**Active Areas:** {', '.join(data['tags']) if data['tags'] else 'No tags found'}

{AI_ANALYSIS['tag_categorization']}

---

## Project Timeline

### Key Accomplishments

"""

# Add accomplishments (grouped by month if many)
if len(data['unique_accomplishments']) > 30:
    # Group by month
    from itertools import groupby
    from operator import itemgetter

    sorted_items = sorted(data['unique_accomplishments'], key=lambda x: x[1], reverse=True)

    for month, items in groupby(sorted_items, key=lambda x: x[1][:7]):  # YYYY-MM
        project_status += f"\n#### {month}\n\n"
        month_items = list(items)[:10]  # Max 10 per month
        for item, date in month_items:
            project_status += f"- {item} _{date}_\n"

        if len(list(items)) > 10:
            project_status += f"\n_... and {len(list(items)) - 10} more from {month}_\n"
else:
    # Show all
    for item, date in data['unique_accomplishments']:
        project_status += f"- {item} _{date}_\n"

project_status += f"""

### Important Decisions Made

"""

if data['unique_decisions']:
    for item, date in data['unique_decisions'][:20]:
        project_status += f"- {item} _{date}_\n"
    if len(data['unique_decisions']) > 20:
        project_status += f"\n_... and {len(data['unique_decisions']) - 20} more decisions_\n"
else:
    project_status += "None documented\n"

project_status += f"""

### Key Discoveries & Insights

"""

if data['unique_discoveries']:
    for item, date in data['unique_discoveries'][:20]:
        project_status += f"- {item} _{date}_\n"
    if len(data['unique_discoveries']) > 20:
        project_status += f"\n_... and {len(data['unique_discoveries']) - 20} more discoveries_\n"
else:
    project_status += "None documented\n"

project_status += f"""

---

## Tasks & To-Dos

### ⏳ Pending Tasks ({len(pending_todos)})

"""

if pending_todos:
    # Group by date (most recent first)
    sorted_todos = sorted(pending_todos, key=lambda x: x['date'], reverse=True)
    for todo in sorted_todos:
        project_status += f"- [ ] {todo['task']} _(from {todo['date']})_\n"
else:
    project_status += "All tasks completed! ✅\n"

project_status += f"""

### ✅ Recently Completed ({len(completed_todos)})

<details>
<summary>Click to expand completed tasks</summary>

"""

if completed_todos:
    recent_completed = sorted(completed_todos, key=lambda x: x['date'], reverse=True)[:30]
    for todo in recent_completed:
        project_status += f"- [x] {todo['task']} _(completed {todo['date']})_\n"

    if len(completed_todos) > 30:
        project_status += f"\n_... and {len(completed_todos) - 30} more completed tasks_\n"
else:
    project_status += "None\n"

project_status += """
</details>

---

## AI Analysis & Patterns

"""

project_status += AI_ANALYSIS['pattern_recognition']

project_status += """

---

## Future Improvement Suggestions

"""

project_status += AI_ANALYSIS['future_improvements']

project_status += f"""

---

## Consolidation History

### Update {datetime.now().strftime('%Y-%m-%d')}

- **Period:** {data['date_range']['start']} to {data['date_range']['end']}
- **Sessions:** {len(data['notes'])} notes consolidated
- **Accomplishments added:** {len(data['unique_accomplishments'])}
- **Decisions documented:** {len(data['unique_decisions'])}
- **Discoveries noted:** {len(data['unique_discoveries'])}
- **Pending tasks:** {len(pending_todos)}
- **Completed tasks:** {len(completed_todos)}

---

*Last consolidated: {datetime.now().strftime("%Y-%m-%d %H:%M")}*
*Command: `/consolidate-notes`*
"""

# Write project status file
with open(status_file, 'w') as f:
    f.write(project_status)

print(f"✅ Project status {action}: {obsidian_path}/project-status.md")
print("")
```

---

### Step 7: Milestone Snapshot (Optional)

```bash
echo "📸 Create Milestone Snapshot?"
echo ""
echo "Save a permanent copy of the current project status"
echo "This is useful for:"
echo "  • End of sprint/iteration"
echo "  • Major feature completion"
echo "  • Before significant changes"
echo "  • Quarterly reviews"
echo ""
read -p "Create milestone? (y/n) [n]: " MILESTONE_CHOICE
MILESTONE_CHOICE=${MILESTONE_CHOICE:-n}

if [[ "$MILESTONE_CHOICE" =~ ^[Yy]$ ]]; then
    # Ask for milestone name
    echo ""
    DEFAULT_NAME="project-status-$(date +%Y-%m-%d)"
    read -p "Milestone filename (without .md) [$DEFAULT_NAME]: " MILESTONE_NAME
    MILESTONE_NAME=${MILESTONE_NAME:-$DEFAULT_NAME}

    # Ensure .md extension
    if [[ ! "$MILESTONE_NAME" =~ \.md$ ]]; then
        MILESTONE_NAME="${MILESTONE_NAME}.md"
    fi

    # Copy to main Obsidian directory (one level up from sessions-history)
    MILESTONE_PATH="$OBSIDIAN_VAULT/$OBSIDIAN_PATH/$MILESTONE_NAME"

    # Copy current project-status
    cp "$STATUS_FILE" "$MILESTONE_PATH"

    # Add milestone marker at the top
    TEMP_FILE=$(mktemp)
    cat > "$TEMP_FILE" << EOF
> [!NOTE] Milestone Snapshot
> This is a permanent snapshot of the project status as of $(date +"%Y-%m-%d %H:%M")
> Original file: project-status.md
> Future updates to project-status.md will not affect this milestone.

---

EOF
    cat "$MILESTONE_PATH" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$MILESTONE_PATH"

    echo "✅ Milestone saved: $OBSIDIAN_PATH/$MILESTONE_NAME"
    echo ""
fi
```

---

### Step 8: Archive Processed Notes

```bash
# Create archived directory if it doesn't exist
mkdir -p "$ARCHIVED_DIR"

echo "📦 Archive Processed Session Notes"
echo ""
echo "The following notes will be moved to sessions-history/archived/:"
ls -1 "$SESSIONS_DIR"/*.md 2>/dev/null
echo ""
echo "These notes have been consolidated into project-status.md"
echo ""
read -p "Move to archived/? (y/n) [y]: " ARCHIVE_CHOICE
ARCHIVE_CHOICE=${ARCHIVE_CHOICE:-y}

if [[ "$ARCHIVE_CHOICE" =~ ^[Yy]$ ]]; then
    # Count files
    FILE_COUNT=$(find "$SESSIONS_DIR" -maxdepth 1 -name "*.md" -type f | wc -l | xargs)

    # Move notes to archived
    mv "$SESSIONS_DIR"/*.md "$ARCHIVED_DIR/" 2>/dev/null

    # Create/update archive index
    ARCHIVE_README="$ARCHIVED_DIR/README.md"

    if [ -f "$ARCHIVE_README" ]; then
        # Append to existing README
        echo "" >> "$ARCHIVE_README"
        echo "## Archived $(date +%Y-%m-%d)" >> "$ARCHIVE_README"
        echo "" >> "$ARCHIVE_README"
        echo "Added $FILE_COUNT notes:" >> "$ARCHIVE_README"
    else
        # Create new README
        cat > "$ARCHIVE_README" << EOF
# Archived Session Notes

This folder contains session notes that have been consolidated into the main project-status note.

Each consolidation is documented below with the date and number of notes archived.

---

## Archived $(date +%Y-%m-%d)

Added $FILE_COUNT notes:
EOF
    fi

    # List archived files
    ls -1 "$ARCHIVED_DIR"/*.md 2>/dev/null | \
        grep -v "README.md" | \
        xargs -n1 basename | \
        sed 's/^/- /' >> "$ARCHIVE_README"

    echo "✅ Archived $FILE_COUNT notes"
    echo "   Location: $OBSIDIAN_PATH/sessions-history/archived/"
    echo ""
else
    echo "Skipping archival - notes remain in sessions-history/"
    echo ""
fi
```

---

### Step 9: Show Summary

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Consolidation Complete!"
echo ""
echo "📊 Summary:"
echo "  • Sessions analyzed: $NOTE_COUNT notes"
echo "  • Period: ${DATA_START} to ${DATA_END}"
echo "  • Redundancies removed: ${DUPLICATES_REMOVED} items"
echo "  • Pending to-dos: ${PENDING_COUNT} tasks"
echo "  • Completed to-dos: ${COMPLETED_COUNT} tasks"
echo "  • Tags extracted: ${TAG_COUNT} unique tags"
echo ""
echo "📝 Updated:"
echo "  • project-status.md (comprehensive overview with AI analysis)"
if [ -n "$MILESTONE_NAME" ]; then
    echo "  • $MILESTONE_NAME (milestone snapshot)"
fi
echo ""
echo "📦 Archived:"
echo "  • $NOTE_COUNT notes moved to sessions-history/archived/"
echo ""
echo "💡 Next Steps:"
echo "  1. Review project-status.md in Obsidian"
echo "  2. Address pending to-dos"
echo "  3. Consider implementing suggested improvements"
echo "  4. Run /consolidate-notes periodically (weekly/bi-weekly)"
echo ""
echo "📍 Quick Links:"
echo "  • Project status: $OBSIDIAN_PATH/project-status.md"
if [ -n "$MILESTONE_NAME" ]; then
    echo "  • Milestone: $OBSIDIAN_PATH/$MILESTONE_NAME"
fi
echo "  • Archived notes: $OBSIDIAN_PATH/sessions-history/archived/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## Key Features

### 1. **AI-Powered Analysis**
- Executive summary of project progress
- Pattern recognition across sessions
- Concrete improvement suggestions
- Risk identification

### 2. **Smart Redundancy Removal**
- Text similarity detection (85% threshold)
- Preserves earliest mention with date
- Reduces noise in project status

### 3. **Tag-Based Organization**
- Automatic tag extraction from notes
- Categorization by activity area
- Trend analysis by tag

### 4. **To-Do Tracking**
- Distinguishes completed vs pending
- Tracks when tasks were created/completed
- Shows progress over time

### 5. **Milestone Snapshots**
- Permanent copies of project status
- Custom naming with date default
- Useful for reviews and retrospectives

### 6. **Safe Archiving**
- Preserves all session notes
- Creates archive index
- Confirmation before moving

---

## Example AI Analysis Output

```markdown
## Executive Summary

Over the past 2 weeks (2026-01-20 to 2026-02-05), the genome-pipeline project has focused
primarily on pathway analysis implementation and visualization. Key accomplishments include
implementing Fisher's exact test for pathway enrichment, developing network visualization
tools, and adding statistical corrections. The project shows strong momentum with 15 major
features completed and only 3 pending tasks.

The main themes have been: statistical rigor in analysis methods, data visualization quality,
and performance optimization. There's been a notable shift from exploratory analysis to
production-ready implementation.

## Pattern Recognition

**Recurring Themes:**
- Statistical methods: Multiple discussions about appropriate statistical tests and corrections
- Visualization: Ongoing focus on creating publication-quality figures
- Performance: Regular mentions of optimization and efficiency

**Focus Shifts:**
- Week 1: Initial implementation and method selection
- Week 2: Refinement, testing, and visualization

**Potential Blockers:**
- Overlapping pathway handling mentioned 3 times without resolution
- Background gene set selection uncertainty noted repeatedly

## Future Improvement Suggestions

### High Priority

1. **Implement pathway clustering algorithm**
   - Use semantic similarity to reduce redundancy in results
   - Addresses recurring "overlapping pathways" concern
   - Libraries: GOSemSim (R) or gseapy (Python)

2. **Create standardized background gene set**
   - Document selection criteria
   - Version control for reproducibility
   - Resolves noted uncertainty about background selection

3. **Add automated testing suite**
   - Unit tests for statistical methods
   - Integration tests for full pipeline
   - Prevents regression as features are added

### Medium Priority

4. **Export pathway results in standard formats**
   - GMT format for sharing
   - JSON for web visualization
   - Increases interoperability

5. **Create user documentation**
   - Parameter selection guide
   - Interpretation guidelines
   - Troubleshooting common issues

6. **Implement caching for large datasets**
   - Speed up repeated analyses
   - Reduce computational overhead
   - Consider using joblib or diskcache

### Low Priority (Future Exploration)

7. **Add multi-species support**
   - Pathway databases for other organisms
   - Homology-based gene mapping

8. **Web interface for visualization**
   - Interactive network exploration
   - Real-time parameter adjustment
   - Consider Plotly Dash or Streamlit

9. **Integration with other analysis tools**
   - Connect to STRING database
   - Link to PubMed for pathway literature

10. **Machine learning for pathway prediction**
    - Predict relevant pathways from gene lists
    - Exploratory research direction
```

---

## Usage Frequency

**Recommended schedule:**
- **Weekly**: For active projects with daily work
- **Bi-weekly**: For moderate-pace projects
- **Monthly**: For long-term projects or maintenance mode
- **On-demand**: Before major milestones or reviews

---

## Related Commands

- `/safe-exit` - End session with note creation
- `/safe-clear` - Clear context with note creation
- `/backup` - Create project backups
- `/update-skills` - Update skills with learnings

---

## Notes

- Always review AI suggestions critically - they're starting points, not mandates
- Milestone snapshots are permanent - project-status.md continues to update
- Archived notes remain accessible for reference
- Tags work best when used consistently (#feature, #bug, #optimization, etc.)
