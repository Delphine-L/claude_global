# Step 6: Update or Create Project Status Note

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
