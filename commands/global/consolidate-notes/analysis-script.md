# Step 3: Analyze Session Notes with AI (Python Script)

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
