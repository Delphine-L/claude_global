# Step 4: Remove Redundancies

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

# Step 5: AI-Powered Analysis and Suggestions

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
